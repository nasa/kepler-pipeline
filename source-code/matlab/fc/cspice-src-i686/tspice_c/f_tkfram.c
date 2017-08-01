/* f_tkfram.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_true = TRUE_;
static integer c__53 = 53;
static integer c__71 = 71;
static logical c_false = FALSE_;
static integer c__9 = 9;
static doublereal c_b101 = 1e-14;
static integer c__0 = 0;
static integer c__277 = 277;
static integer c__3 = 3;
static integer c__2 = 2;
static integer c__10013 = 10013;
static doublereal c_b411 = 1e-13;
static integer c_b415 = 1000003;

/* $Procedure      F_TKFRAM ( Family Test of  TKFRAM ) */
/* Subroutine */ int f_tkfram__(logical *ok)
{
    /* System generated locals */
    integer i__1, i__2, i__3, i__4;
    char ch__1[16];

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    doublereal erot[9];
    extern /* Subroutine */ int eul2m_(doublereal *, doublereal *, doublereal 
	    *, integer *, integer *, integer *, doublereal *);
    integer i__, j;
    doublereal r__[225]	/* was [3][3][25] */;
    integer frame;
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    char lines[80*300];
    logical found;
    extern /* Subroutine */ int topen_(char *, ftnlen);
    doublereal angle1[25], angle2[25], angle3[25];
    extern /* Subroutine */ int t_success__(logical *);
    integer id;
    extern /* Subroutine */ int chckad_(char *, doublereal *, char *, 
	    doublereal *, integer *, doublereal *, logical *, ftnlen, ftnlen);
    extern /* Character */ VOID begdat_(char *, ftnlen);
    extern doublereal pi_(void);
    integer eframe;
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     chcksi_(char *, integer *, char *, integer *, integer *, logical 
	    *, ftnlen, ftnlen), kilfil_(char *, ftnlen), tkfram_(integer *, 
	    doublereal *, integer *, logical *), clpool_(void);
    extern /* Character */ VOID begtxt_(char *, ftnlen);
    extern /* Subroutine */ int tsttxt_(char *, char *, integer *, logical *, 
	    logical *, ftnlen, ftnlen);
    extern doublereal rpd_(void);
    doublereal rot[9]	/* was [3][3] */;

/* $ Abstract */

/*     Test the routine TKFRAM. */

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

/* $ Version */

/* -    SPICELIB Version 1.1.0, 20-OCT-1999 (WLT) */

/*        Declared PI to be an EXTERNAL Functions. */

/* -& */

/*     Test Utility Functions */


/*     SPICELIB Functions */


/*     Local Variables */


/*     Begin every test family with an open call. */

    topen_("F_TKFRAM", (ftnlen)8);

/*     Clear the kernel pool so that we don't have to worry */
/*     about previous test cases contaminating the kernel pool. */

    clpool_();

/*     Get rid of any existing frame kernels. */

    kilfil_("phoenix.tk", (ftnlen)10);
    kilfil_("phoenix.prt", (ftnlen)11);

/*     Create an I-kernel that we can load later on. */

    s_copy(lines, "This is a test TK Frame kernel for the fictional instrume"
	    "nt TST_PHEONIX", (ftnlen)80, (ftnlen)71);
    s_copy(lines + 80, "on board the fictional spacecraft PHEONIX.  A C-kern"
	    "el for", (ftnlen)80, (ftnlen)58);
    s_copy(lines + 160, "the platform on which TST_PHEONIX is mounted can be"
	    " generated", (ftnlen)80, (ftnlen)61);
    s_copy(lines + 240, "by calling the test utility TSTCK3.", (ftnlen)80, (
	    ftnlen)35);
    s_copy(lines + 320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 400, "This kernel describes only the orientation attribut"
	    "es of the", (ftnlen)80, (ftnlen)60);
    s_copy(lines + 480, "TST_PHOENIX instrument.", (ftnlen)80, (ftnlen)23);
    s_copy(lines + 560, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 640, "This kernel is intended only for test purposes.  It"
	    " is primarily", (ftnlen)80, (ftnlen)64);
    s_copy(lines + 720, "useful for testing the TKFRAM data fetching routine."
	    , (ftnlen)80, (ftnlen)52);
    s_copy(lines + 800, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(lines + 880, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(lines + 960, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 1040, "TKFRAME_-111111_SPEC      = 'MATRIX'", (ftnlen)80, (
	    ftnlen)36);
    s_copy(lines + 1120, "TKFRAME_-111111_RELATIVE  = 'PHOENIX'", (ftnlen)80, 
	    (ftnlen)37);
    s_copy(lines + 1200, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 1280, "TKFRAME_-111111_MATRIX    = ( 0.48", (ftnlen)80, (
	    ftnlen)34);
    s_copy(lines + 1360, " 0.60", (ftnlen)80, (ftnlen)5);
    s_copy(lines + 1440, " 0.64", (ftnlen)80, (ftnlen)5);
    s_copy(lines + 1520, "-0.8", (ftnlen)80, (ftnlen)4);
    s_copy(lines + 1600, " 0.0", (ftnlen)80, (ftnlen)4);
    s_copy(lines + 1680, " 0.6", (ftnlen)80, (ftnlen)4);
    s_copy(lines + 1760, " 0.36", (ftnlen)80, (ftnlen)5);
    s_copy(lines + 1840, "-0.80", (ftnlen)80, (ftnlen)5);
    s_copy(lines + 1920, " 0.48 )", (ftnlen)80, (ftnlen)7);
    s_copy(lines + 2000, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 2080, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 2160, "TKFRAME_TST2-PHOENIX_SPEC      = 'ROTATION'", (
	    ftnlen)80, (ftnlen)43);
    s_copy(lines + 2240, "TKFRAME_TST2-PHOENIX_RELATIVE  = 'PHOENIX'", (
	    ftnlen)80, (ftnlen)42);
    s_copy(lines + 2320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 2400, "TKFRAME_-111112_ROTATION  = ( 0.48", (ftnlen)80, (
	    ftnlen)34);
    s_copy(lines + 2480, " 0.60", (ftnlen)80, (ftnlen)5);
    s_copy(lines + 2560, " 0.64", (ftnlen)80, (ftnlen)5);
    s_copy(lines + 2640, "-0.8", (ftnlen)80, (ftnlen)4);
    s_copy(lines + 2720, " 0.0", (ftnlen)80, (ftnlen)4);
    s_copy(lines + 2800, " 0.6", (ftnlen)80, (ftnlen)4);
    s_copy(lines + 2880, " 0.36", (ftnlen)80, (ftnlen)5);
    s_copy(lines + 2960, "-0.80", (ftnlen)80, (ftnlen)5);
    s_copy(lines + 3040, " 0.48 )", (ftnlen)80, (ftnlen)7);
    s_copy(lines + 3120, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 3200, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(lines + 3280, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(lines + 3360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 3440, "Next we need to supply the various bits of frame i"
	    "dentification for", (ftnlen)80, (ftnlen)67);
    s_copy(lines + 3520, "this instrument.", (ftnlen)80, (ftnlen)16);
    s_copy(lines + 3600, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(lines + 3680, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(lines + 3760, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 3840, "FRAME_-111111_CLASS    =  4", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 3920, "FRAME_-111111_CENTER   = -9", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 4000, "FRAME_-111111_CLASS_ID = -111111", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 4080, "FRAME_-111111_NAME     = 'TST-PHOENIX'", (ftnlen)80,
	     (ftnlen)38);
    s_copy(lines + 4160, "FRAME_TST-PHOENIX      = -111111", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 4240, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 4320, "FRAME_-9999_CLASS      =  3", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 4400, "FRAME_-9999_CENTER     = -9", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 4480, "FRAME_-9999_CLASS_ID   = -9999", (ftnlen)80, (
	    ftnlen)30);
    s_copy(lines + 4560, "FRAME_-9999_NAME       = 'PHOENIX'", (ftnlen)80, (
	    ftnlen)34);
    s_copy(lines + 4640, "FRAME_PHOENIX          = -9999", (ftnlen)80, (
	    ftnlen)30);
    s_copy(lines + 4720, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 4800, "FRAME_-111112_CLASS    =  4", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 4880, "FRAME_-111112_CENTER   = -9", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 4960, "FRAME_-111112_CLASS_ID = -111112", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 5040, "FRAME_-111112_NAME     = 'TST2-PHOENIX'", (ftnlen)
	    80, (ftnlen)39);
    s_copy(lines + 5120, "FRAME_TST2-PHOENIX     = -111112", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 5200, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 5280, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 5360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 5440, "CK_-9999_SCLK          =  -9", (ftnlen)80, (ftnlen)
	    28);
    s_copy(lines + 5520, "CK_-9999_SPK           =  -9", (ftnlen)80, (ftnlen)
	    28);
    s_copy(lines + 5600, " ", (ftnlen)80, (ftnlen)1);
    tcase_("Check that a zero instrument ID causes an error to be signalled. "
	    , (ftnlen)65);
    id = 0;
    tkfram_(&id, rot, &frame, &found);
    chckxc_(&c_true, "SPICE(ZEROFRAMEID)", ok, (ftnlen)18);
    tcase_("Check that a proper error is signalled if there is no frame data"
	    " for the requestedframe. ", (ftnlen)89);
    id = -10;
    tkfram_(&id, rot, &frame, &found);
    chckxc_(&c_true, "SPICE(INCOMPLETFRAME)", ok, (ftnlen)21);
    tcase_("Load a TK frame that is missing the orientation information and "
	    "check that the deficiency is properly diagnosed.", (ftnlen)112);
    id = -111111;
    clpool_();
    tsttxt_("phoenix.prt", lines, &c__53, &c_true, &c_true, (ftnlen)11, (
	    ftnlen)80);
    tkfram_(&id, rot, &frame, &found);
    chckxc_(&c_true, "SPICE(BADFRAMESPEC)", ok, (ftnlen)19);
    tcase_("Make sure that the proper error is signalled if the frame 'SPEC'"
	    " is not recognized. ", (ftnlen)84);
    id = -111112;
    clpool_();
    tsttxt_("phoenix.tk", lines, &c__71, &c_true, &c_true, (ftnlen)10, (
	    ftnlen)80);
    tkfram_(&id, rot, &frame, &found);
    chckxc_(&c_true, "SPICE(UNKNOWNFRAMESPEC)", ok, (ftnlen)23);
    tcase_("Clear the kernel pool, load a complete TK frame kernel (from the"
	    " point of frames) and determine the orientation of the instrumen"
	    "t and its C-kernel frame. ", (ftnlen)154);
    id = -111111;
    tkfram_(&id, rot, &frame, &found);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    erot[0] = .48;
    erot[1] = .6;
    erot[2] = .64;
    erot[3] = -.8;
    erot[4] = 0.;
    erot[5] = .6;
    erot[6] = .36;
    erot[7] = -.8;
    erot[8] = .48;
    eframe = -9999;
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("ROT", rot, "~", erot, &c__9, &c_b101, ok, (ftnlen)3, (ftnlen)1);
    chcksi_("FRAME", &frame, "=", &eframe, &c__0, ok, (ftnlen)5, (ftnlen)1);
    tcase_("Make sure that we can successfully retrieve rotations when the i"
	    "nternal buffer for the TK Frames has gets full. ", (ftnlen)112);
    s_copy(lines, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 80, "This PCK file contains definitions for TOPOGRAPHIC r"
	    "eference", (ftnlen)80, (ftnlen)60);
    s_copy(lines + 160, "frames at 25 different observatories around the wor"
	    "ld.  Note", (ftnlen)80, (ftnlen)60);
    s_copy(lines + 240, "that the definition of these frames is approximate "
	    "and that", (ftnlen)80, (ftnlen)59);
    s_copy(lines + 320, "they are accurate to only about 0.1 degrees.", (
	    ftnlen)80, (ftnlen)44);
    s_copy(lines + 400, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(lines + 480, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(lines + 560, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 640, "FRAME_LAPLATA_TOPO     = 1000001", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 720, "FRAME_CANBERRA_TOPO    = 1000002", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 800, "FRAME_URANIA_TOPO      = 1000003", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 880, "FRAME_VALONGO_TOPO     = 1000004", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 960, "FRAME_LASCAMPANAS_TOPO = 1000005", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 1040, "FRAME_YUNNAN_TOPO      = 1000006", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 1120, "FRAME_QUITO_TOPO       = 1000007", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 1200, "FRAME_TUORLA_TOPO      = 1000008", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 1280, "FRAME_GRENOBLE_TOPO    = 1000009", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 1360, "FRAME_HAMBURG_TOPO     = 1000010", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 1440, "FRAME_MUNICH_TOPO      = 1000011", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 1520, "FRAME_KODAIKANAL_TOPO  = 1000012", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 1600, "FRAME_DUNSINK_TOPO     = 1000013", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 1680, "FRAME_TURIN_TOPO       = 1000014", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 1760, "FRAME_HIDA_TOPO        = 1000015", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 1840, "FRAME_ARECIBO_TOPO     = 1000016", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 1920, "FRAME_PULKOVO_TOPO     = 1000017", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 2000, "FRAME_BOYDEN_TOPO      = 1000018", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 2080, "FRAME_MADRID_TOPO      = 1000019", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 2160, "FRAME_AROSA_TOPO       = 1000020", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 2240, "FRAME_GREENWICH_TOPO   = 1000021", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 2320, "FRAME_KITTPEAK_TOPO    = 1000022", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 2400, "FRAME_GOLDSTONE_TOPO   = 1000023", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 2480, "FRAME_PALOMAR_TOPO     = 1000024", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 2560, "FRAME_USNO_TOPO        = 1000025", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 2640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 2720, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 2800, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 2880, "FRAME_1000001_CLASS    =  4", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 2960, "FRAME_1000002_CLASS    =  4", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 3040, "FRAME_1000003_CLASS    =  4", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 3120, "FRAME_1000004_CLASS    =  4", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 3200, "FRAME_1000005_CLASS    =  4", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 3280, "FRAME_1000006_CLASS    =  4", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 3360, "FRAME_1000007_CLASS    =  4", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 3440, "FRAME_1000008_CLASS    =  4", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 3520, "FRAME_1000009_CLASS    =  4", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 3600, "FRAME_1000010_CLASS    =  4", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 3680, "FRAME_1000011_CLASS    =  4", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 3760, "FRAME_1000012_CLASS    =  4", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 3840, "FRAME_1000013_CLASS    =  4", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 3920, "FRAME_1000014_CLASS    =  4", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 4000, "FRAME_1000015_CLASS    =  4", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 4080, "FRAME_1000016_CLASS    =  4", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 4160, "FRAME_1000017_CLASS    =  4", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 4240, "FRAME_1000018_CLASS    =  4", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 4320, "FRAME_1000019_CLASS    =  4", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 4400, "FRAME_1000020_CLASS    =  4", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 4480, "FRAME_1000021_CLASS    =  4", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 4560, "FRAME_1000022_CLASS    =  4", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 4640, "FRAME_1000023_CLASS    =  4", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 4720, "FRAME_1000024_CLASS    =  4", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 4800, "FRAME_1000025_CLASS    =  4", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 4880, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 4960, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 5040, "FRAME_1000001_CENTER   =  399", (ftnlen)80, (ftnlen)
	    29);
    s_copy(lines + 5120, "FRAME_1000002_CENTER   =  399", (ftnlen)80, (ftnlen)
	    29);
    s_copy(lines + 5200, "FRAME_1000003_CENTER   =  399", (ftnlen)80, (ftnlen)
	    29);
    s_copy(lines + 5280, "FRAME_1000004_CENTER   =  399", (ftnlen)80, (ftnlen)
	    29);
    s_copy(lines + 5360, "FRAME_1000005_CENTER   =  399", (ftnlen)80, (ftnlen)
	    29);
    s_copy(lines + 5440, "FRAME_1000006_CENTER   =  399", (ftnlen)80, (ftnlen)
	    29);
    s_copy(lines + 5520, "FRAME_1000007_CENTER   =  399", (ftnlen)80, (ftnlen)
	    29);
    s_copy(lines + 5600, "FRAME_1000008_CENTER   =  399", (ftnlen)80, (ftnlen)
	    29);
    s_copy(lines + 5680, "FRAME_1000009_CENTER   =  399", (ftnlen)80, (ftnlen)
	    29);
    s_copy(lines + 5760, "FRAME_1000010_CENTER   =  399", (ftnlen)80, (ftnlen)
	    29);
    s_copy(lines + 5840, "FRAME_1000011_CENTER   =  399", (ftnlen)80, (ftnlen)
	    29);
    s_copy(lines + 5920, "FRAME_1000012_CENTER   =  399", (ftnlen)80, (ftnlen)
	    29);
    s_copy(lines + 6000, "FRAME_1000013_CENTER   =  399", (ftnlen)80, (ftnlen)
	    29);
    s_copy(lines + 6080, "FRAME_1000014_CENTER   =  399", (ftnlen)80, (ftnlen)
	    29);
    s_copy(lines + 6160, "FRAME_1000015_CENTER   =  399", (ftnlen)80, (ftnlen)
	    29);
    s_copy(lines + 6240, "FRAME_1000016_CENTER   =  399", (ftnlen)80, (ftnlen)
	    29);
    s_copy(lines + 6320, "FRAME_1000017_CENTER   =  399", (ftnlen)80, (ftnlen)
	    29);
    s_copy(lines + 6400, "FRAME_1000018_CENTER   =  399", (ftnlen)80, (ftnlen)
	    29);
    s_copy(lines + 6480, "FRAME_1000019_CENTER   =  399", (ftnlen)80, (ftnlen)
	    29);
    s_copy(lines + 6560, "FRAME_1000020_CENTER   =  399", (ftnlen)80, (ftnlen)
	    29);
    s_copy(lines + 6640, "FRAME_1000021_CENTER   =  399", (ftnlen)80, (ftnlen)
	    29);
    s_copy(lines + 6720, "FRAME_1000022_CENTER   =  399", (ftnlen)80, (ftnlen)
	    29);
    s_copy(lines + 6800, "FRAME_1000023_CENTER   =  399", (ftnlen)80, (ftnlen)
	    29);
    s_copy(lines + 6880, "FRAME_1000024_CENTER   =  399", (ftnlen)80, (ftnlen)
	    29);
    s_copy(lines + 6960, "FRAME_1000025_CENTER   =  399", (ftnlen)80, (ftnlen)
	    29);
    s_copy(lines + 7040, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 7120, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 7200, "FRAME_1000001_CLASS_ID = 1000001", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 7280, "FRAME_1000002_CLASS_ID = 1000002", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 7360, "FRAME_1000003_CLASS_ID = 1000003", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 7440, "FRAME_1000004_CLASS_ID = 1000004", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 7520, "FRAME_1000005_CLASS_ID = 1000005", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 7600, "FRAME_1000006_CLASS_ID = 1000006", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 7680, "FRAME_1000007_CLASS_ID = 1000007", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 7760, "FRAME_1000008_CLASS_ID = 1000008", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 7840, "FRAME_1000009_CLASS_ID = 1000009", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 7920, "FRAME_1000010_CLASS_ID = 1000010", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 8000, "FRAME_1000011_CLASS_ID = 1000011", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 8080, "FRAME_1000012_CLASS_ID = 1000012", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 8160, "FRAME_1000013_CLASS_ID = 1000013", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 8240, "FRAME_1000014_CLASS_ID = 1000014", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 8320, "FRAME_1000015_CLASS_ID = 1000015", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 8400, "FRAME_1000016_CLASS_ID = 1000016", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 8480, "FRAME_1000017_CLASS_ID = 1000017", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 8560, "FRAME_1000018_CLASS_ID = 1000018", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 8640, "FRAME_1000019_CLASS_ID = 1000019", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 8720, "FRAME_1000020_CLASS_ID = 1000020", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 8800, "FRAME_1000021_CLASS_ID = 1000021", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 8880, "FRAME_1000022_CLASS_ID = 1000022", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 8960, "FRAME_1000023_CLASS_ID = 1000023", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 9040, "FRAME_1000024_CLASS_ID = 1000024", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 9120, "FRAME_1000025_CLASS_ID = 1000025", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 9200, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 9280, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 9360, "FRAME_1000001_NAME     = 'LAPLATA_TOPO'", (ftnlen)
	    80, (ftnlen)39);
    s_copy(lines + 9440, "FRAME_1000002_NAME     = 'CANBERRA_TOPO'", (ftnlen)
	    80, (ftnlen)40);
    s_copy(lines + 9520, "FRAME_1000003_NAME     = 'URANIA_TOPO'", (ftnlen)80,
	     (ftnlen)38);
    s_copy(lines + 9600, "FRAME_1000004_NAME     = 'VALONGO_TOPO'", (ftnlen)
	    80, (ftnlen)39);
    s_copy(lines + 9680, "FRAME_1000005_NAME     = 'LASCAMPANAS_TOPO'", (
	    ftnlen)80, (ftnlen)43);
    s_copy(lines + 9760, "FRAME_1000006_NAME     = 'YUNNAN_TOPO'", (ftnlen)80,
	     (ftnlen)38);
    s_copy(lines + 9840, "FRAME_1000007_NAME     = 'QUITO_TOPO'", (ftnlen)80, 
	    (ftnlen)37);
    s_copy(lines + 9920, "FRAME_1000008_NAME     = 'TUORLA_TOPO'", (ftnlen)80,
	     (ftnlen)38);
    s_copy(lines + 10000, "FRAME_1000009_NAME     = 'GRENOBLE_TOPO'", (ftnlen)
	    80, (ftnlen)40);
    s_copy(lines + 10080, "FRAME_1000010_NAME     = 'HAMBURG_TOPO'", (ftnlen)
	    80, (ftnlen)39);
    s_copy(lines + 10160, "FRAME_1000011_NAME     = 'MUNICH_TOPO'", (ftnlen)
	    80, (ftnlen)38);
    s_copy(lines + 10240, "FRAME_1000012_NAME     = 'KODAIKANAL_TOPO'", (
	    ftnlen)80, (ftnlen)42);
    s_copy(lines + 10320, "FRAME_1000013_NAME     = 'DUNSINK_TOPO'", (ftnlen)
	    80, (ftnlen)39);
    s_copy(lines + 10400, "FRAME_1000014_NAME     = 'TURIN_TOPO'", (ftnlen)80,
	     (ftnlen)37);
    s_copy(lines + 10480, "FRAME_1000015_NAME     = 'HIDA_TOPO'", (ftnlen)80, 
	    (ftnlen)36);
    s_copy(lines + 10560, "FRAME_1000016_NAME     = 'ARECIBO_TOPO'", (ftnlen)
	    80, (ftnlen)39);
    s_copy(lines + 10640, "FRAME_1000017_NAME     = 'PULKOVO_TOPO'", (ftnlen)
	    80, (ftnlen)39);
    s_copy(lines + 10720, "FRAME_1000018_NAME     = 'BOYDEN_TOPO'", (ftnlen)
	    80, (ftnlen)38);
    s_copy(lines + 10800, "FRAME_1000019_NAME     = 'MADRID_TOPO'", (ftnlen)
	    80, (ftnlen)38);
    s_copy(lines + 10880, "FRAME_1000020_NAME     = 'AROSA_TOPO'", (ftnlen)80,
	     (ftnlen)37);
    s_copy(lines + 10960, "FRAME_1000021_NAME     = 'GREENWICH_TOPO'", (
	    ftnlen)80, (ftnlen)41);
    s_copy(lines + 11040, "FRAME_1000022_NAME     = 'KITTPEAK_TOPO'", (ftnlen)
	    80, (ftnlen)40);
    s_copy(lines + 11120, "FRAME_1000023_NAME     = 'GOLDSTONE_TOPO'", (
	    ftnlen)80, (ftnlen)41);
    s_copy(lines + 11200, "FRAME_1000024_NAME     = 'PALOMAR_TOPO'", (ftnlen)
	    80, (ftnlen)39);
    s_copy(lines + 11280, "FRAME_1000025_NAME     = 'USNO_TOPO'", (ftnlen)80, 
	    (ftnlen)36);
    s_copy(lines + 11360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 11440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 11520, "TKFRAME_1000001_SPEC     = 'ANGLES'", (ftnlen)80, (
	    ftnlen)35);
    s_copy(lines + 11600, "TKFRAME_1000002_SPEC     = 'ANGLES'", (ftnlen)80, (
	    ftnlen)35);
    s_copy(lines + 11680, "TKFRAME_1000003_SPEC     = 'ANGLES'", (ftnlen)80, (
	    ftnlen)35);
    s_copy(lines + 11760, "TKFRAME_1000004_SPEC     = 'ANGLES'", (ftnlen)80, (
	    ftnlen)35);
    s_copy(lines + 11840, "TKFRAME_1000005_SPEC     = 'ANGLES'", (ftnlen)80, (
	    ftnlen)35);
    s_copy(lines + 11920, "TKFRAME_1000006_SPEC     = 'ANGLES'", (ftnlen)80, (
	    ftnlen)35);
    s_copy(lines + 12000, "TKFRAME_1000007_SPEC     = 'ANGLES'", (ftnlen)80, (
	    ftnlen)35);
    s_copy(lines + 12080, "TKFRAME_1000008_SPEC     = 'ANGLES'", (ftnlen)80, (
	    ftnlen)35);
    s_copy(lines + 12160, "TKFRAME_1000009_SPEC     = 'ANGLES'", (ftnlen)80, (
	    ftnlen)35);
    s_copy(lines + 12240, "TKFRAME_1000010_SPEC     = 'ANGLES'", (ftnlen)80, (
	    ftnlen)35);
    s_copy(lines + 12320, "TKFRAME_1000011_SPEC     = 'ANGLES'", (ftnlen)80, (
	    ftnlen)35);
    s_copy(lines + 12400, "TKFRAME_1000012_SPEC     = 'ANGLES'", (ftnlen)80, (
	    ftnlen)35);
    s_copy(lines + 12480, "TKFRAME_1000013_SPEC     = 'ANGLES'", (ftnlen)80, (
	    ftnlen)35);
    s_copy(lines + 12560, "TKFRAME_1000014_SPEC     = 'ANGLES'", (ftnlen)80, (
	    ftnlen)35);
    s_copy(lines + 12640, "TKFRAME_1000015_SPEC     = 'ANGLES'", (ftnlen)80, (
	    ftnlen)35);
    s_copy(lines + 12720, "TKFRAME_1000016_SPEC     = 'ANGLES'", (ftnlen)80, (
	    ftnlen)35);
    s_copy(lines + 12800, "TKFRAME_1000017_SPEC     = 'ANGLES'", (ftnlen)80, (
	    ftnlen)35);
    s_copy(lines + 12880, "TKFRAME_1000018_SPEC     = 'ANGLES'", (ftnlen)80, (
	    ftnlen)35);
    s_copy(lines + 12960, "TKFRAME_1000019_SPEC     = 'ANGLES'", (ftnlen)80, (
	    ftnlen)35);
    s_copy(lines + 13040, "TKFRAME_AROSA_TOPO_SPEC  = 'ANGLES'", (ftnlen)80, (
	    ftnlen)35);
    s_copy(lines + 13120, "TKFRAME_1000021_SPEC     = 'ANGLES'", (ftnlen)80, (
	    ftnlen)35);
    s_copy(lines + 13200, "TKFRAME_1000022_SPEC     = 'ANGLES'", (ftnlen)80, (
	    ftnlen)35);
    s_copy(lines + 13280, "TKFRAME_1000023_SPEC     = 'ANGLES'", (ftnlen)80, (
	    ftnlen)35);
    s_copy(lines + 13360, "TKFRAME_1000024_SPEC     = 'ANGLES'", (ftnlen)80, (
	    ftnlen)35);
    s_copy(lines + 13440, "TKFRAME_1000025_SPEC     = 'ANGLES'", (ftnlen)80, (
	    ftnlen)35);
    s_copy(lines + 13520, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 13600, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 13680, "TKFRAME_1000001_RELATIVE = 'IAU_EARTH'", (ftnlen)
	    80, (ftnlen)38);
    s_copy(lines + 13760, "TKFRAME_1000002_RELATIVE = 'IAU_EARTH'", (ftnlen)
	    80, (ftnlen)38);
    s_copy(lines + 13840, "TKFRAME_1000003_RELATIVE = 'IAU_EARTH'", (ftnlen)
	    80, (ftnlen)38);
    s_copy(lines + 13920, "TKFRAME_1000004_RELATIVE = 'IAU_EARTH'", (ftnlen)
	    80, (ftnlen)38);
    s_copy(lines + 14000, "TKFRAME_1000005_RELATIVE = 'IAU_EARTH'", (ftnlen)
	    80, (ftnlen)38);
    s_copy(lines + 14080, "TKFRAME_1000006_RELATIVE = 'IAU_EARTH'", (ftnlen)
	    80, (ftnlen)38);
    s_copy(lines + 14160, "TKFRAME_1000007_RELATIVE = 'IAU_EARTH'", (ftnlen)
	    80, (ftnlen)38);
    s_copy(lines + 14240, "TKFRAME_1000008_RELATIVE = 'IAU_EARTH'", (ftnlen)
	    80, (ftnlen)38);
    s_copy(lines + 14320, "TKFRAME_1000009_RELATIVE = 'IAU_EARTH'", (ftnlen)
	    80, (ftnlen)38);
    s_copy(lines + 14400, "TKFRAME_1000010_RELATIVE = 'IAU_EARTH'", (ftnlen)
	    80, (ftnlen)38);
    s_copy(lines + 14480, "TKFRAME_1000011_RELATIVE = 'IAU_EARTH'", (ftnlen)
	    80, (ftnlen)38);
    s_copy(lines + 14560, "TKFRAME_1000012_RELATIVE = 'IAU_EARTH'", (ftnlen)
	    80, (ftnlen)38);
    s_copy(lines + 14640, "TKFRAME_1000013_RELATIVE = 'IAU_EARTH'", (ftnlen)
	    80, (ftnlen)38);
    s_copy(lines + 14720, "TKFRAME_1000014_RELATIVE = 'IAU_EARTH'", (ftnlen)
	    80, (ftnlen)38);
    s_copy(lines + 14800, "TKFRAME_1000015_RELATIVE = 'IAU_EARTH'", (ftnlen)
	    80, (ftnlen)38);
    s_copy(lines + 14880, "TKFRAME_1000016_RELATIVE = 'IAU_EARTH'", (ftnlen)
	    80, (ftnlen)38);
    s_copy(lines + 14960, "TKFRAME_1000017_RELATIVE = 'IAU_EARTH'", (ftnlen)
	    80, (ftnlen)38);
    s_copy(lines + 15040, "TKFRAME_1000018_RELATIVE = 'IAU_EARTH'", (ftnlen)
	    80, (ftnlen)38);
    s_copy(lines + 15120, "TKFRAME_1000019_RELATIVE = 'IAU_EARTH'", (ftnlen)
	    80, (ftnlen)38);
    s_copy(lines + 15200, "TKFRAME_AROSA_TOPO_RELATIVE = 'IAU_EARTH'", (
	    ftnlen)80, (ftnlen)41);
    s_copy(lines + 15280, "TKFRAME_1000021_RELATIVE = 'IAU_EARTH'", (ftnlen)
	    80, (ftnlen)38);
    s_copy(lines + 15360, "TKFRAME_1000022_RELATIVE = 'IAU_EARTH'", (ftnlen)
	    80, (ftnlen)38);
    s_copy(lines + 15440, "TKFRAME_1000023_RELATIVE = 'IAU_EARTH'", (ftnlen)
	    80, (ftnlen)38);
    s_copy(lines + 15520, "TKFRAME_1000024_RELATIVE = 'IAU_EARTH'", (ftnlen)
	    80, (ftnlen)38);
    s_copy(lines + 15600, "TKFRAME_1000025_RELATIVE = 'IAU_EARTH'", (ftnlen)
	    80, (ftnlen)38);
    s_copy(lines + 15680, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 15760, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 15840, "TKFRAME_1000001_AXES     = (       3,        2,  "
	    " 3 )", (ftnlen)80, (ftnlen)53);
    s_copy(lines + 15920, "TKFRAME_1000002_AXES     = (       3,        2,  "
	    " 3 )", (ftnlen)80, (ftnlen)53);
    s_copy(lines + 16000, "TKFRAME_1000003_AXES     = (       3,        2,  "
	    " 3 )", (ftnlen)80, (ftnlen)53);
    s_copy(lines + 16080, "TKFRAME_1000004_AXES     = (       3,        2,  "
	    " 3 )", (ftnlen)80, (ftnlen)53);
    s_copy(lines + 16160, "TKFRAME_1000005_AXES     = (       3,        2,  "
	    " 3 )", (ftnlen)80, (ftnlen)53);
    s_copy(lines + 16240, "TKFRAME_1000006_AXES     = (       3,        2,  "
	    " 3 )", (ftnlen)80, (ftnlen)53);
    s_copy(lines + 16320, "TKFRAME_1000007_AXES     = (       3,        2,  "
	    " 3 )", (ftnlen)80, (ftnlen)53);
    s_copy(lines + 16400, "TKFRAME_1000008_AXES     = (       3,        2,  "
	    " 3 )", (ftnlen)80, (ftnlen)53);
    s_copy(lines + 16480, "TKFRAME_1000009_AXES     = (       3,        2,  "
	    " 3 )", (ftnlen)80, (ftnlen)53);
    s_copy(lines + 16560, "TKFRAME_1000010_AXES     = (       3,        2,  "
	    " 3 )", (ftnlen)80, (ftnlen)53);
    s_copy(lines + 16640, "TKFRAME_1000011_AXES     = (       3,        2,  "
	    " 3 )", (ftnlen)80, (ftnlen)53);
    s_copy(lines + 16720, "TKFRAME_1000012_AXES     = (       3,        2,  "
	    " 3 )", (ftnlen)80, (ftnlen)53);
    s_copy(lines + 16800, "TKFRAME_1000013_AXES     = (       3,        2,  "
	    " 3 )", (ftnlen)80, (ftnlen)53);
    s_copy(lines + 16880, "TKFRAME_1000014_AXES     = (       3,        2,  "
	    " 3 )", (ftnlen)80, (ftnlen)53);
    s_copy(lines + 16960, "TKFRAME_1000015_AXES     = (       3,        2,  "
	    " 3 )", (ftnlen)80, (ftnlen)53);
    s_copy(lines + 17040, "TKFRAME_1000016_AXES     = (       3,        2,  "
	    " 3 )", (ftnlen)80, (ftnlen)53);
    s_copy(lines + 17120, "TKFRAME_1000017_AXES =     (       3,        2,  "
	    " 3 )", (ftnlen)80, (ftnlen)53);
    s_copy(lines + 17200, "TKFRAME_BOYDEN_TOPO_AXES = (       3,        2,  "
	    " 3 )", (ftnlen)80, (ftnlen)53);
    s_copy(lines + 17280, "TKFRAME_1000019_AXES     = (       3,        2,  "
	    " 3 )", (ftnlen)80, (ftnlen)53);
    s_copy(lines + 17360, "TKFRAME_1000020_AXES     = (       3,        2,  "
	    " 3 )", (ftnlen)80, (ftnlen)53);
    s_copy(lines + 17440, "TKFRAME_1000021_AXES     = (       3,        2,  "
	    " 3 )", (ftnlen)80, (ftnlen)53);
    s_copy(lines + 17520, "TKFRAME_1000022_AXES     = (       3,        2,  "
	    " 3 )", (ftnlen)80, (ftnlen)53);
    s_copy(lines + 17600, "TKFRAME_1000023_AXES     = (       3,        2,  "
	    " 3 )", (ftnlen)80, (ftnlen)53);
    s_copy(lines + 17680, "TKFRAME_1000024_AXES     = (       3,        2,  "
	    " 3 )", (ftnlen)80, (ftnlen)53);
    s_copy(lines + 17760, "TKFRAME_1000025_AXES     = (       3,        2,  "
	    " 3 )", (ftnlen)80, (ftnlen)53);
    s_copy(lines + 17840, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 17920, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 18000, "TKFRAME_1000001_UNITS    = 'DEGREES'", (ftnlen)80, 
	    (ftnlen)36);
    s_copy(lines + 18080, "TKFRAME_1000002_UNITS    = 'DEGREES'", (ftnlen)80, 
	    (ftnlen)36);
    s_copy(lines + 18160, "TKFRAME_1000003_UNITS    = 'DEGREES'", (ftnlen)80, 
	    (ftnlen)36);
    s_copy(lines + 18240, "TKFRAME_1000004_UNITS    = 'DEGREES'", (ftnlen)80, 
	    (ftnlen)36);
    s_copy(lines + 18320, "TKFRAME_1000005_UNITS    = 'DEGREES'", (ftnlen)80, 
	    (ftnlen)36);
    s_copy(lines + 18400, "TKFRAME_1000006_UNITS    = 'DEGREES'", (ftnlen)80, 
	    (ftnlen)36);
    s_copy(lines + 18480, "TKFRAME_1000007_UNITS    = 'DEGREES'", (ftnlen)80, 
	    (ftnlen)36);
    s_copy(lines + 18560, "TKFRAME_1000008_UNITS    = 'DEGREES'", (ftnlen)80, 
	    (ftnlen)36);
    s_copy(lines + 18640, "TKFRAME_1000009_UNITS    = 'DEGREES'", (ftnlen)80, 
	    (ftnlen)36);
    s_copy(lines + 18720, "TKFRAME_1000010_UNITS    = 'DEGREES'", (ftnlen)80, 
	    (ftnlen)36);
    s_copy(lines + 18800, "TKFRAME_1000011_UNITS    = 'DEGREES'", (ftnlen)80, 
	    (ftnlen)36);
    s_copy(lines + 18880, "TKFRAME_1000012_UNITS    = 'DEGREES'", (ftnlen)80, 
	    (ftnlen)36);
    s_copy(lines + 18960, "TKFRAME_1000013_UNITS    = 'DEGREES'", (ftnlen)80, 
	    (ftnlen)36);
    s_copy(lines + 19040, "TKFRAME_1000014_UNITS    = 'DEGREES'", (ftnlen)80, 
	    (ftnlen)36);
    s_copy(lines + 19120, "TKFRAME_1000015_UNITS    = 'DEGREES'", (ftnlen)80, 
	    (ftnlen)36);
    s_copy(lines + 19200, "TKFRAME_1000016_UNITS    = 'DEGREES'", (ftnlen)80, 
	    (ftnlen)36);
    s_copy(lines + 19280, "TKFRAME_1000017_UNITS    = 'DEGREES'", (ftnlen)80, 
	    (ftnlen)36);
    s_copy(lines + 19360, "TKFRAME_BOYDEN_TOPO_UNITS = 'DEGREES'", (ftnlen)80,
	     (ftnlen)37);
    s_copy(lines + 19440, "TKFRAME_1000019_UNITS    = 'DEGREES'", (ftnlen)80, 
	    (ftnlen)36);
    s_copy(lines + 19520, "TKFRAME_1000020_UNITS    = 'DEGREES'", (ftnlen)80, 
	    (ftnlen)36);
    s_copy(lines + 19600, "TKFRAME_1000021_UNITS    = 'DEGREES'", (ftnlen)80, 
	    (ftnlen)36);
    s_copy(lines + 19680, "TKFRAME_1000022_UNITS    = 'DEGREES'", (ftnlen)80, 
	    (ftnlen)36);
    s_copy(lines + 19760, "TKFRAME_1000023_UNITS    = 'DEGREES'", (ftnlen)80, 
	    (ftnlen)36);
    s_copy(lines + 19840, "TKFRAME_1000024_UNITS    = 'DEGREES'", (ftnlen)80, 
	    (ftnlen)36);
    s_copy(lines + 19920, "TKFRAME_1000025_UNITS    = 'DEGREES'", (ftnlen)80, 
	    (ftnlen)36);
    s_copy(lines + 20000, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 20080, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 20160, "TKFRAME_1000001_ANGLES   = ( 57.9, -124.9, 180 )", 
	    (ftnlen)80, (ftnlen)48);
    s_copy(lines + 20240, "TKFRAME_1000002_ANGLES   = ( -149.0, -125.3, 180 )"
	    , (ftnlen)80, (ftnlen)50);
    s_copy(lines + 20320, "TKFRAME_1000003_ANGLES   = ( -16.4, -41.8, 180 )", 
	    (ftnlen)80, (ftnlen)48);
    s_copy(lines + 20400, "TKFRAME_1000004_ANGLES   = ( 43.2, -112.9, 180 )", 
	    (ftnlen)80, (ftnlen)48);
    s_copy(lines + 20480, "TKFRAME_1000005_ANGLES   = ( 70.7, -123.5, 180 )", 
	    (ftnlen)80, (ftnlen)48);
    s_copy(lines + 20560, "TKFRAME_1000006_ANGLES   = ( -102.8, -65.0, 180 )",
	     (ftnlen)80, (ftnlen)49);
    s_copy(lines + 20640, "TKFRAME_1000007_ANGLES   = ( 78.5, -90.2, 180 )", (
	    ftnlen)80, (ftnlen)47);
    s_copy(lines + 20720, "TKFRAME_1000008_ANGLES   = ( -22.4, -29.6, 180 )", 
	    (ftnlen)80, (ftnlen)48);
    s_copy(lines + 20800, "TKFRAME_1000009_ANGLES   = ( -05.9, -45.4, 180 )", 
	    (ftnlen)80, (ftnlen)48);
    s_copy(lines + 20880, "TKFRAME_1000010_ANGLES   = ( -10.2, -36.5, 180 )", 
	    (ftnlen)80, (ftnlen)48);
    s_copy(lines + 20960, "TKFRAME_1000011_ANGLES   = ( -11.6, -41.9, 180 )", 
	    (ftnlen)80, (ftnlen)48);
    s_copy(lines + 21040, "TKFRAME_1000012_ANGLES   = ( -77.5, -79.8, 180 )", 
	    (ftnlen)80, (ftnlen)48);
    s_copy(lines + 21120, "TKFRAME_1000013_ANGLES   = ( 06.3, -36.6, 180 )", (
	    ftnlen)80, (ftnlen)47);
    s_copy(lines + 21200, "TKFRAME_1000014_ANGLES   = ( -07.8, -45.0, 180 )", 
	    (ftnlen)80, (ftnlen)48);
    s_copy(lines + 21280, "TKFRAME_1000015_ANGLES   = ( -137.6, -53.7, 180 )",
	     (ftnlen)80, (ftnlen)49);
    s_copy(lines + 21360, "TKFRAME_1000016_ANGLES   = ( 66.8, -71.6, 180 )", (
	    ftnlen)80, (ftnlen)47);
    s_copy(lines + 21440, "TKFRAME_1000017_ANGLES   = ( -42.5, -46.3, 180 )", 
	    (ftnlen)80, (ftnlen)48);
    s_copy(lines + 21520, "TKFRAME_1000018_ANGLES   = ( -26.6, -119.0, 180 )",
	     (ftnlen)80, (ftnlen)49);
    s_copy(lines + 21600, "TKFRAME_1000019_ANGLES   = ( 03.7, -49.6, 180 )", (
	    ftnlen)80, (ftnlen)47);
    s_copy(lines + 21680, "TKFRAME_1000020_ANGLES   = ( -09.7, -43.2, 180 )", 
	    (ftnlen)80, (ftnlen)48);
    s_copy(lines + 21760, "TKFRAME_1000021_ANGLES   = ( -00.1, -37.8, 180 )", 
	    (ftnlen)80, (ftnlen)48);
    s_copy(lines + 21840, "TKFRAME_1000022_ANGLES   = ( 111.6, -58.0, 180 )", 
	    (ftnlen)80, (ftnlen)48);
    s_copy(lines + 21920, "TKFRAME_1000023_ANGLES   = ( 116.8, -54.6, 180 )", 
	    (ftnlen)80, (ftnlen)48);
    s_copy(lines + 22000, "TKFRAME_1000024_ANGLES   = ( 116.8, -56.7, 180 )", 
	    (ftnlen)80, (ftnlen)48);
    s_copy(lines + 22080, "TKFRAME_1000025_ANGLES   = ( 77.1, -51.1, 180 )", (
	    ftnlen)80, (ftnlen)47);
    kilfil_("topcentrc.frm", (ftnlen)13);
    tsttxt_("topcentrc.frm", lines, &c__277, &c_true, &c_true, (ftnlen)13, (
	    ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    angle1[0] = rpd_() * 57.9;
    angle1[1] = rpd_() * -149.;
    angle1[2] = rpd_() * -16.4;
    angle1[3] = rpd_() * 43.2;
    angle1[4] = rpd_() * 70.7;
    angle1[5] = rpd_() * -102.8;
    angle1[6] = rpd_() * 78.5;
    angle1[7] = rpd_() * -22.4;
    angle1[8] = rpd_() * -5.9;
    angle1[9] = rpd_() * -10.2;
    angle1[10] = rpd_() * -11.6;
    angle1[11] = rpd_() * -77.5;
    angle1[12] = rpd_() * 6.3;
    angle1[13] = rpd_() * -7.8;
    angle1[14] = rpd_() * -137.6;
    angle1[15] = rpd_() * 66.8;
    angle1[16] = rpd_() * -42.5;
    angle1[17] = rpd_() * -26.6;
    angle1[18] = rpd_() * 3.7;
    angle1[19] = rpd_() * -9.7;
    angle1[20] = rpd_() * -.1;
    angle1[21] = rpd_() * 111.6;
    angle1[22] = rpd_() * 116.8;
    angle1[23] = rpd_() * 116.8;
    angle1[24] = rpd_() * 77.1;
    angle2[0] = rpd_() * -124.9;
    angle2[1] = rpd_() * -125.3;
    angle2[2] = rpd_() * -41.8;
    angle2[3] = rpd_() * -112.9;
    angle2[4] = rpd_() * -123.5;
    angle2[5] = rpd_() * -65.;
    angle2[6] = rpd_() * -90.2;
    angle2[7] = rpd_() * -29.6;
    angle2[8] = rpd_() * -45.4;
    angle2[9] = rpd_() * -36.5;
    angle2[10] = rpd_() * -41.9;
    angle2[11] = rpd_() * -79.8;
    angle2[12] = rpd_() * -36.6;
    angle2[13] = rpd_() * -45.;
    angle2[14] = rpd_() * -53.7;
    angle2[15] = rpd_() * -71.6;
    angle2[16] = rpd_() * -46.3;
    angle2[17] = rpd_() * -119.;
    angle2[18] = rpd_() * -49.6;
    angle2[19] = rpd_() * -43.2;
    angle2[20] = rpd_() * -37.8;
    angle2[21] = rpd_() * -58.;
    angle2[22] = rpd_() * -54.6;
    angle2[23] = rpd_() * -56.7;
    angle2[24] = rpd_() * -51.1;
    for (i__ = 1; i__ <= 25; ++i__) {
	angle3[(i__1 = i__ - 1) < 25 && 0 <= i__1 ? i__1 : s_rnge("angle3", 
		i__1, "f_tkfram__", (ftnlen)673)] = pi_();
    }
    for (i__ = 1; i__ <= 25; ++i__) {
	eul2m_(&angle1[(i__1 = i__ - 1) < 25 && 0 <= i__1 ? i__1 : s_rnge(
		"angle1", i__1, "f_tkfram__", (ftnlen)678)], &angle2[(i__2 = 
		i__ - 1) < 25 && 0 <= i__2 ? i__2 : s_rnge("angle2", i__2, 
		"f_tkfram__", (ftnlen)678)], &angle3[(i__3 = i__ - 1) < 25 && 
		0 <= i__3 ? i__3 : s_rnge("angle3", i__3, "f_tkfram__", (
		ftnlen)678)], &c__3, &c__2, &c__3, &r__[(i__4 = (i__ * 3 + 1) 
		* 3 - 12) < 225 && 0 <= i__4 ? i__4 : s_rnge("r", i__4, "f_t"
		"kfram__", (ftnlen)678)]);
    }
    for (j = 1; j <= 3; ++j) {
	for (i__ = 1; i__ <= 25; ++i__) {
	    id = i__ + 1000000;
	    tkfram_(&id, rot, &frame, &found);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    chcksi_("FRAME", &frame, "=", &c__10013, &c__0, ok, (ftnlen)5, (
		    ftnlen)1);
	    chckad_("ROT", rot, "~", &r__[(i__1 = (i__ * 3 + 1) * 3 - 12) < 
		    225 && 0 <= i__1 ? i__1 : s_rnge("r", i__1, "f_tkfram__", 
		    (ftnlen)690)], &c__9, &c_b411, ok, (ftnlen)3, (ftnlen)1);
	}
    }
    tcase_("Make sure we can get the right answer if we ask for the same fra"
	    "me several times in a row. ", (ftnlen)91);
    for (i__ = 1; i__ <= 3; ++i__) {
	tkfram_(&c_b415, rot, &frame, &found);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksi_("FRAME", &frame, "=", &c__10013, &c__0, ok, (ftnlen)5, (
		ftnlen)1);
	chckad_("ROT", rot, "~", &r__[18], &c__9, &c_b411, ok, (ftnlen)3, (
		ftnlen)1);
    }

/*     That's all.  Clean up the kernel files we created. */

    kilfil_("phoenix.tk", (ftnlen)10);
    kilfil_("phoenix.prt", (ftnlen)11);
    kilfil_("topcentrc.frm", (ftnlen)13);
    t_success__(ok);
    return 0;
} /* f_tkfram__ */

