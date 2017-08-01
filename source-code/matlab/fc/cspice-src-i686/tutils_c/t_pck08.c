/* t_pck08.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* $Procedure      T_PCK08 (Create a test text PCK based on pck00008.tpc ) */
/* Subroutine */ int t_pck08__(char *namepc, logical *loadpc, logical *keeppc,
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
    integer unit, i__, r__;
    extern integer rtrim_(char *, ftnlen);
    extern /* Character */ VOID begdat_(char *, ftnlen);
    extern /* Subroutine */ int kilfil_(char *, ftnlen), tfiles_(char *, 
	    ftnlen), ldpool_(char *, ftnlen);
    extern /* Character */ VOID begtxt_(char *, ftnlen);
    extern /* Subroutine */ int writln_(char *, integer *, ftnlen), txtopn_(
	    char *, integer *, ftnlen);
    char pck[80*2605];

/* $ Abstract */

/*     Create and if appropriate load a test PCK kernel.  The kernel */
/*     created by this routine is meant to contain data consistent with */
/*     the equations implemented in the test utility routine t_pckeq. */

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

/*      VARIABLE  I/O  DESCRIPTION */
/*      --------  ---  -------------------------------------------------- */
/*      NAMEPC     I   The name of the PC-kernel to create */
/*      LOADPC     I   Load the PC-kernel if TRUE */
/*      KEEPPC     I   Keep the PC-kernel if TRUE, else delete it. */

/* $ Detailed_Input */

/*     NAMEPC      is the name of a PC-kernel to create and load if */
/*                 LOADPC is set to TRUE.  If a PC-kernel of the same */
/*                 name already exists it is deleted. */


/*     LOADPC      is a logical that indicates whether or not the PCK */
/*                 file should be loaded after it is created.  If it */
/*                 has the value TRUE the PC-kernel is loaded after */
/*                 it is created.  Otherwise it is left un-opened. */


/*     KEEPPC      is a logical that indicates whether or not the PCK */
/*                 file should be deleted after it is loaded.  If KEEPPC */
/*                 is TRUE the file is not deleted.  If KEEPPC is FALSE */
/*                 the file is deleted after it is loaded.  NOTE that */
/*                 unless LOADSC is TRUE, the PCK file is not deleted */
/*                 by this routine.  This routine deletes the PC-kernel */
/*                 only if it LOADSC is TRUE and KEEPPC is FALSE. */

/* $ Detailed_Output */

/*     None. */

/* $ Parameters */

/*      None. */

/* $ Files */

/*      This routine creates single PC-kernel. See C$ Particulars */
/*      for more details. */

/* $ Exceptions */

/*     None. */

/* $ Particulars */

/*     This routine creates a planetary constants file for use in */
/*     testing.  The data in the PCK are those contained in the */
/*     draft version of the kernel pck00008.tpc as of 2004-09-10. */

/* $ Examples */

/*     This is intended to be used in those instances when you */
/*     need a well defined PC-kernel for use in testing.  By using */
/*     this routine you can avoid having to know in advance where */
/*     a PCK file is on the system where you plan to do your testing. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     N.J. Bachman    (JPL) */
/*     W.L. Taber      (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    Test Utilities 1.0.0, 13-FEB-2004 (WLT) (NJB) */

/* -& */
/* $ Index_Entries */

/*     Create test PCK file. */

/* -& */

/*     Spicelib Functions */


/*     Test Utility Functions */


/*     Local Variables. */

    kilfil_(namepc, namepc_len);
    s_copy(pck, "P_constants (PcK) SPICE kernel file", (ftnlen)80, (ftnlen)35)
	    ;
    s_copy(pck + 80, "======================================================"
	    "=====================", (ftnlen)80, (ftnlen)75);
    s_copy(pck + 160, "Orientation constants for the Sun and planets", (
	    ftnlen)80, (ftnlen)45);
    s_copy(pck + 240, "-----------------------------------------------------"
	    "---", (ftnlen)80, (ftnlen)56);
    s_copy(pck + 320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 400, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 480, "Sun", (ftnlen)80, (ftnlen)3);
    s_copy(pck + 560, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 640, "     Old values:", (ftnlen)80, (ftnlen)16);
    s_copy(pck + 720, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 800, "        Values are unchanged in the 2000 IAU report.", 
	    (ftnlen)80, (ftnlen)52);
    s_copy(pck + 880, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 960, "     Current values:", (ftnlen)80, (ftnlen)20);
    s_copy(pck + 1040, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 1120, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 1200, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 1280, "        BODY10_POLE_RA         = (  286.13       0. "
	    "         0. )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 1360, "        BODY10_POLE_DEC        = (   63.87       0. "
	    "         0. )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 1440, "        BODY10_PM              = (   84.10      14.1"
	    "8440     0. )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 1520, "        BODY10_LONG_AXIS       = (    0.            "
	    "            )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 1600, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 1680, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 1760, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 1840, "Mercury", (ftnlen)80, (ftnlen)7);
    s_copy(pck + 1920, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 2000, "     Old values:", (ftnlen)80, (ftnlen)16);
    s_copy(pck + 2080, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 2160, "        body199_pole_ra          = (  281.01,     -0"
	    ".033,      0. )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 2240, "        body199_pole_dec         = (   61.45,     -0"
	    ".005,      0. )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 2320, "        body199_pm               = (  329.55       6"
	    ".1385025   0. )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 2400, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 2480, "        body199_long_axis        = (    0.          "
	    "              )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 2560, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 2640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 2720, "     Current values:", (ftnlen)80, (ftnlen)20);
    s_copy(pck + 2800, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 2880, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 2960, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 3040, "        BODY199_POLE_RA          = (  281.01     -0."
	    "033      0. )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 3120, "        BODY199_POLE_DEC         = (   61.45     -0."
	    "005      0. )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 3200, "        BODY199_PM               = (  329.548     6."
	    "1385025  0. )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 3280, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 3360, "        BODY199_LONG_AXIS        = (    0.          "
	    "              )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 3440, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 3520, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 3600, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 3680, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 3760, "Venus", (ftnlen)80, (ftnlen)5);
    s_copy(pck + 3840, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 3920, "     Old values:", (ftnlen)80, (ftnlen)16);
    s_copy(pck + 4000, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 4080, "        Values are unchanged in the 2000 IAU report.",
	     (ftnlen)80, (ftnlen)52);
    s_copy(pck + 4160, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 4240, "     Current values:", (ftnlen)80, (ftnlen)20);
    s_copy(pck + 4320, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 4400, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 4480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 4560, "        BODY299_POLE_RA          = (  272.76       0"
	    ".          0. )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 4640, "        BODY299_POLE_DEC         = (   67.16       0"
	    ".          0. )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 4720, "        BODY299_PM               = (  160.20      -1"
	    ".4813688   0. )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 4800, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 4880, "        BODY299_LONG_AXIS        = (    0.          "
	    "              )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 4960, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 5040, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 5120, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 5200, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 5280, "Earth", (ftnlen)80, (ftnlen)5);
    s_copy(pck + 5360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 5440, "     Old values:", (ftnlen)80, (ftnlen)16);
    s_copy(pck + 5520, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 5600, "        Values shown are from the 1997 IAU report.", (
	    ftnlen)80, (ftnlen)50);
    s_copy(pck + 5680, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 5760, "           body399_pole_ra        = (    0.      -0."
	    "641         0. )", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 5840, "           body399_pole_dec       = (   90.      -0."
	    "557         0. )", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 5920, "           body399_pm             = (  190.16   360."
	    "9856235     0. )", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 6000, "           body399_long_axis      = (    0.         "
	    "               )", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 6080, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 6160, "        Nutation precession angles are unchanged in "
	    "the 2000 report.", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 6240, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 6320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 6400, "     Current values:", (ftnlen)80, (ftnlen)20);
    s_copy(pck + 6480, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 6560, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 6640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 6720, "        BODY399_POLE_RA        = (    0.      -0.641"
	    "         0. )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 6800, "        BODY399_POLE_DEC       = (   90.      -0.557"
	    "         0. )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 6880, "        BODY399_PM             = (  190.147  360.985"
	    "6235     0. )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 6960, "        BODY399_LONG_AXIS      = (    0.            "
	    "            )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 7040, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 7120, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 7200, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 7280, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 7360, "        Nutation precession angles for the Earth-Moo"
	    "n system:", (ftnlen)80, (ftnlen)61);
    s_copy(pck + 7440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 7520, "           The linear coefficients have been scaled "
	    "up from degrees/day", (ftnlen)80, (ftnlen)71);
    s_copy(pck + 7600, "           to degrees/century, because the SPICELIB "
	    "PCK reader expects", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 7680, "           these units.  The original constants were:"
	    , (ftnlen)80, (ftnlen)53);
    s_copy(pck + 7760, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 7840, "                                    125.045D0   -0.0"
	    "529921D0", (ftnlen)80, (ftnlen)60);
    s_copy(pck + 7920, "                                    250.089D0   -0.1"
	    "059842D0", (ftnlen)80, (ftnlen)60);
    s_copy(pck + 8000, "                                    260.008D0   13.0"
	    "120009D0", (ftnlen)80, (ftnlen)60);
    s_copy(pck + 8080, "                                    176.625D0   13.3"
	    "407154D0", (ftnlen)80, (ftnlen)60);
    s_copy(pck + 8160, "                                    357.529D0    0.9"
	    "856003D0", (ftnlen)80, (ftnlen)60);
    s_copy(pck + 8240, "                                    311.589D0   26.4"
	    "057084D0", (ftnlen)80, (ftnlen)60);
    s_copy(pck + 8320, "                                    134.963D0   13.0"
	    "649930D0", (ftnlen)80, (ftnlen)60);
    s_copy(pck + 8400, "                                    276.617D0    0.3"
	    "287146D0", (ftnlen)80, (ftnlen)60);
    s_copy(pck + 8480, "                                     34.226D0    1.7"
	    "484877D0", (ftnlen)80, (ftnlen)60);
    s_copy(pck + 8560, "                                     15.134D0   -0.1"
	    "589763D0", (ftnlen)80, (ftnlen)60);
    s_copy(pck + 8640, "                                    119.743D0    0.0"
	    "036096D0", (ftnlen)80, (ftnlen)60);
    s_copy(pck + 8720, "                                    239.961D0    0.1"
	    "643573D0", (ftnlen)80, (ftnlen)60);
    s_copy(pck + 8800, "                                     25.053D0   12.9"
	    "590088D0", (ftnlen)80, (ftnlen)60);
    s_copy(pck + 8880, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 8960, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 9040, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 9120, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 9200, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 9280, "        BODY3_NUT_PREC_ANGLES  = (  125.045         "
	    "-1935.5364525000", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 9360, "                                    250.089         "
	    "-3871.0729050000", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 9440, "                                    260.008        4"
	    "75263.3328725000", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 9520, "                                    176.625        4"
	    "87269.6299850000", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 9600, "                                    357.529         "
	    "35999.0509575000", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 9680, "                                    311.589        9"
	    "64468.4993100001", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 9760, "                                    134.963        4"
	    "77198.8693250000", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 9840, "                                    276.617         "
	    "12006.3007650000", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 9920, "                                     34.226         "
	    "63863.5132425000", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 10000, "                                     15.134        "
	    " -5806.6093575000", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 10080, "                                    119.743        "
	    "   131.8406400000", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 10160, "                                    239.961        "
	    "  6003.1503825000", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 10240, "                                     25.053        "
	    "473327.7964200000 )", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 10320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 10400, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 10480, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 10560, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 10640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 10720, "        Northern hemisphere projection of the Earth"
	    "'s magnetic dipole:", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 10800, "        Coordinates are planetocentric.  Values are"
	    " from [5].", (ftnlen)80, (ftnlen)61);
    s_copy(pck + 10880, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 10960, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 11040, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 11120, "        BODY399_MAG_NORTH_POLE_LON  =  ( -69.761 )", 
	    (ftnlen)80, (ftnlen)50);
    s_copy(pck + 11200, "        BODY399_MAG_NORTH_POLE_LAT  =  (  78.565 )", 
	    (ftnlen)80, (ftnlen)50);
    s_copy(pck + 11280, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 11360, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 11440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 11520, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 11600, "Mars", (ftnlen)80, (ftnlen)4);
    s_copy(pck + 11680, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 11760, "     Old values:", (ftnlen)80, (ftnlen)16);
    s_copy(pck + 11840, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 11920, "        Values shown are from the 1997 IAU report.", 
	    (ftnlen)80, (ftnlen)50);
    s_copy(pck + 12000, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 12080, "           body499_pole_ra          = (  317.681   "
	    "  -0.108       0.  )", (ftnlen)80, (ftnlen)71);
    s_copy(pck + 12160, "           body499_pole_dec         = (   52.886   "
	    "  -0.061       0.  )", (ftnlen)80, (ftnlen)71);
    s_copy(pck + 12240, "           body499_pm               = (  176.901   "
	    " 350.8919830   0.  )", (ftnlen)80, (ftnlen)71);
    s_copy(pck + 12320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 12400, "        Nutation precession angles are unchanged in"
	    " the 2000 IAU report.", (ftnlen)80, (ftnlen)72);
    s_copy(pck + 12480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 12560, "     Current values:", (ftnlen)80, (ftnlen)20);
    s_copy(pck + 12640, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 12720, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 12800, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 12880, "        BODY499_POLE_RA          = (  317.68143   -"
	    "0.1061      0.  )", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 12960, "        BODY499_POLE_DEC         = (   52.88650   -"
	    "0.0609      0.  )", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 13040, "        BODY499_PM               = (  176.630    35"
	    "0.89198226  0.  )", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 13120, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 13200, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 13280, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 13360, "        Source [3] specifies the following value fo"
	    "r the lambda_a term", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 13440, "        (BODY4_LONG_AXIS ) for Mars.", (ftnlen)80, (
	    ftnlen)36);
    s_copy(pck + 13520, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 13600, "        This term is the POSITIVE WEST LONGITUDE, m"
	    "easured from the prime", (ftnlen)80, (ftnlen)73);
    s_copy(pck + 13680, "        meridian, of the longest axis of the ellips"
	    "oid representing the ``mean", (ftnlen)80, (ftnlen)78);
    s_copy(pck + 13760, "        planet surface,'' as the article states.", (
	    ftnlen)80, (ftnlen)48);
    s_copy(pck + 13840, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 13920, "           body499_long_axis        = (  110.  )", (
	    ftnlen)80, (ftnlen)48);
    s_copy(pck + 14000, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 14080, "        Source [4] specifies the lambda_a value", (
	    ftnlen)80, (ftnlen)47);
    s_copy(pck + 14160, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 14240, "           body499_long_axis        = (  104.9194  )"
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 14320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 14400, "        We list these lambda_a values for completen"
	    "ess. The IAU gives equal", (ftnlen)80, (ftnlen)75);
    s_copy(pck + 14480, "        values for both equatorial radii, so the la"
	    "mbda_a offset does not", (ftnlen)80, (ftnlen)73);
    s_copy(pck + 14560, "        apply to the IAU model.", (ftnlen)80, (
	    ftnlen)31);
    s_copy(pck + 14640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 14720, "        The 2000 IAU report defines M2, the second "
	    "nutation precession angle,", (ftnlen)80, (ftnlen)77);
    s_copy(pck + 14800, "        by:", (ftnlen)80, (ftnlen)11);
    s_copy(pck + 14880, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 14960, "                                                2", (
	    ftnlen)80, (ftnlen)49);
    s_copy(pck + 15040, "           192.93  +  1128.4096700 d  +  8.864 T", (
	    ftnlen)80, (ftnlen)48);
    s_copy(pck + 15120, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 15200, "        We truncate the M2 series to a linear expre"
	    "ssion, because the PCK", (ftnlen)80, (ftnlen)73);
    s_copy(pck + 15280, "        software cannot handle the quadratic term.", 
	    (ftnlen)80, (ftnlen)50);
    s_copy(pck + 15360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 15440, "        Again, the linear terms are scaled by 36525"
	    ".0:", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 15520, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 15600, "            -0.4357640000000000       -->     -1591"
	    "6.28010000000", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 15680, "          1128.409670000000           -->   4121516"
	    "3.19675000", (ftnlen)80, (ftnlen)61);
    s_copy(pck + 15760, "            -1.8151000000000000E-02   -->       -66"
	    "2.9652750000000", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 15840, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 15920, "        We also introduce a fourth nutation precess"
	    "ion angle, which", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 16000, "        is the pi/2-complement of the third angle. "
	    " This angle is used", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 16080, "        in computing the prime meridian location fo"
	    "r Deimos.  See the", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 16160, "        discussion of this angle below in the secti"
	    "on containing orientation", (ftnlen)80, (ftnlen)76);
    s_copy(pck + 16240, "        constants for Deimos.", (ftnlen)80, (ftnlen)
	    29);
    s_copy(pck + 16320, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 16400, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 16480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 16560, "        BODY4_NUT_PREC_ANGLES  = (  169.51     -159"
	    "16.2801", (ftnlen)80, (ftnlen)58);
    s_copy(pck + 16640, "                                    192.93   412151"
	    "63.19675", (ftnlen)80, (ftnlen)59);
    s_copy(pck + 16720, "                                     53.47       -6"
	    "62.965275", (ftnlen)80, (ftnlen)60);
    s_copy(pck + 16800, "                                     36.53        6"
	    "62.965275  )", (ftnlen)80, (ftnlen)63);
    s_copy(pck + 16880, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 16960, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 17040, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 17120, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 17200, "Jupiter", (ftnlen)80, (ftnlen)7);
    s_copy(pck + 17280, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 17360, "     Old values:", (ftnlen)80, (ftnlen)16);
    s_copy(pck + 17440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 17520, "        body599_pole_ra        = (   268.05    -0.0"
	    "09      0.  )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 17600, "        body599_pole_dec       = (   +64.49    +0.0"
	    "03      0.  )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 17680, "        body599_pm             = (   284.95  +870.5"
	    "366420  0.  )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 17760, "        body599_long_axis      = (     0.          "
	    "            )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 17840, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 17920, "        body5_nut_prec_angles  = (   73.32   +91472"
	    ".9", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 18000, "                                     24.62   +45137"
	    ".2", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 18080, "                                    283.90    +4850"
	    ".7", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 18160, "                                    355.80    +1191"
	    ".3", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 18240, "                                    119.90     +262"
	    ".1", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 18320, "                                    229.80      +64"
	    ".3", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 18400, "                                    352.25    +2382"
	    ".6", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 18480, "                                    113.35    +6070"
	    ".0", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 18560, "                                    146.64  +182945"
	    ".8", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 18640, "                                     49.24   +90274"
	    ".4  )", (ftnlen)80, (ftnlen)56);
    s_copy(pck + 18720, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 18800, "     Current values:", (ftnlen)80, (ftnlen)20);
    s_copy(pck + 18880, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 18960, "        The number of nutation precession angles is"
	    " ten. The ninth and", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 19040, "        tenth are twice the first and second, respe"
	    "ctively.", (ftnlen)80, (ftnlen)59);
    s_copy(pck + 19120, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 19200, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 19280, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 19360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 19440, "        BODY599_POLE_RA        = (   268.05      -0"
	    ".009       0. )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 19520, "        BODY599_POLE_DEC       = (    64.49       0"
	    ".003       0. )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 19600, "        BODY599_PM             = (   284.95     870"
	    ".5366420   0. )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 19680, "        BODY599_LONG_AXIS      = (     0.          "
	    "              )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 19760, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 19840, "        BODY5_NUT_PREC_ANGLES  = (    73.32   91472"
	    ".9", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 19920, "                                      24.62   45137"
	    ".2", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 20000, "                                     283.90    4850"
	    ".7", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 20080, "                                     355.80    1191"
	    ".3", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 20160, "                                     119.90     262"
	    ".1", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 20240, "                                     229.80      64"
	    ".3", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 20320, "                                     352.35    2382"
	    ".6", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 20400, "                                     113.35    6070"
	    ".0", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 20480, "                                     146.64  182945"
	    ".8", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 20560, "                                      49.24   90274"
	    ".4  )", (ftnlen)80, (ftnlen)56);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 20640, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 20720, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 20800, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 20880, "Saturn", (ftnlen)80, (ftnlen)6);
    s_copy(pck + 20960, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 21040, "     Old values:", (ftnlen)80, (ftnlen)16);
    s_copy(pck + 21120, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 21200, "        Values are unchanged in the 2000 IAU report."
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 21280, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 21360, "     Current values:", (ftnlen)80, (ftnlen)20);
    s_copy(pck + 21440, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 21520, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 21600, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 21680, "        BODY699_POLE_RA        = (    40.589    -0."
	    "036      0.  )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 21760, "        BODY699_POLE_DEC       = (    83.537    -0."
	    "004      0.  )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 21840, "        BODY699_PM             = (    38.90    810."
	    "7939024  0.  )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 21920, "        BODY699_LONG_AXIS      = (     0.          "
	    "             )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 22000, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 22080, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 22160, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 22240, "        The first seven angles given here are the a"
	    "ngles S1", (ftnlen)80, (ftnlen)59);
    s_copy(pck + 22320, "        through S7 from the 2000 report; the eighth"
	    " and", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 22400, "        ninth angles are 2*S1 and 2*S2, respectivel"
	    "y.", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 22480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 22560, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 22640, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 22720, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 22800, "        BODY6_NUT_PREC_ANGLES  = (  353.32   75706.7"
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 22880, "                                     28.72   75706.7"
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 22960, "                                    177.40  -36505.5"
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 23040, "                                    300.00   -7225.9"
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 23120, "                                    316.45     506.2"
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 23200, "                                    345.20   -1016.3"
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 23280, "                                     29.80     -52.1"
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 23360, "                                    706.64  151413.4"
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 23440, "                                     57.44  151413."
	    "4  )", (ftnlen)80, (ftnlen)55);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 23520, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 23600, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 23680, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 23760, "Uranus", (ftnlen)80, (ftnlen)6);
    s_copy(pck + 23840, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 23920, "     Old values:", (ftnlen)80, (ftnlen)16);
    s_copy(pck + 24000, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 24080, "        Values are unchanged in the 2000 IAU report."
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 24160, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 24240, "     Current values:", (ftnlen)80, (ftnlen)20);
    s_copy(pck + 24320, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 24400, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 24480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 24560, "        BODY799_POLE_RA        = (  257.311     0. "
	    "        0.  )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 24640, "        BODY799_POLE_DEC       = (  -15.175     0. "
	    "        0.  )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 24720, "        BODY799_PM             = (  203.81   -501.1"
	    "600928  0.  )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 24800, "        BODY799_LONG_AXIS      = (    0.           "
	    "            )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 24880, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 24960, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 25040, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 25120, "        The first 16 angles given here are the angl"
	    "es U1", (ftnlen)80, (ftnlen)56);
    s_copy(pck + 25200, "        through U16 from the 2000 report; the 17th "
	    "and", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 25280, "        18th angles are 2*U11 and 2*U12, respective"
	    "ly.", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 25360, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 25440, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 25520, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 25600, "        BODY7_NUT_PREC_ANGLES  = (  115.75   54991."
	    "87", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 25680, "                                    141.69   41887."
	    "66", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 25760, "                                    135.03   29927."
	    "35", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 25840, "                                     61.77   25733."
	    "59", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 25920, "                                    249.32   24471."
	    "46", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 26000, "                                     43.86   22278."
	    "41", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 26080, "                                     77.66   20289."
	    "42", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 26160, "                                    157.36   16652."
	    "76", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 26240, "                                    101.81   12872."
	    "63", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 26320, "                                    138.64    8061."
	    "81", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 26400, "                                    102.23   -2024."
	    "22", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 26480, "                                    316.41    2863."
	    "96", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 26560, "                                    304.01     -51."
	    "94", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 26640, "                                    308.71     -93."
	    "17", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 26720, "                                    340.82     -75."
	    "32", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 26800, "                                    259.14    -504."
	    "81", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 26880, "                                    204.46   -4048."
	    "44", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 26960, "                                    632.82    5727."
	    "92     )", (ftnlen)80, (ftnlen)59);
    s_copy(pck + 27040, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 27120, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 27200, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 27280, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 27360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 27440, "Neptune", (ftnlen)80, (ftnlen)7);
    s_copy(pck + 27520, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 27600, "     Old values:", (ftnlen)80, (ftnlen)16);
    s_copy(pck + 27680, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 27760, "        Values are unchanged in the 2000 IAU report"
	    ".  However,", (ftnlen)80, (ftnlen)62);
    s_copy(pck + 27840, "        the kernel variables used to store the valu"
	    "es have changed.", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 27920, "        See note immediately below.", (ftnlen)80, (
	    ftnlen)35);
    s_copy(pck + 28000, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 28080, "     Current values:", (ftnlen)80, (ftnlen)20);
    s_copy(pck + 28160, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 28240, "        The kernel variables", (ftnlen)80, (ftnlen)
	    28);
    s_copy(pck + 28320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 28400, "           BODY899_NUT_PREC_RA", (ftnlen)80, (ftnlen)
	    30);
    s_copy(pck + 28480, "           BODY899_NUT_PREC_DEC", (ftnlen)80, (
	    ftnlen)31);
    s_copy(pck + 28560, "           BODY899_NUT_PREC_PM", (ftnlen)80, (ftnlen)
	    30);
    s_copy(pck + 28640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 28720, "        are new in this PCK version (dated October "
	    "17, 2003).", (ftnlen)80, (ftnlen)61);
    s_copy(pck + 28800, "        These variables capture trigonmetric terms "
	    "in the expressions", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 28880, "        for Neptune's pole direction and prime meri"
	    "dian location.", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 28960, "        Version N0057 of the SPICE Toolkit uses the"
	    "se variables;", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 29040, "        earlier versions can read them but ignore t"
	    "hem when", (ftnlen)80, (ftnlen)59);
    s_copy(pck + 29120, "        computing Neptune's orientation.", (ftnlen)
	    80, (ftnlen)40);
    s_copy(pck + 29200, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 29280, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 29360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 29440, "           BODY899_POLE_RA        = (  299.36     0"
	    ".         0. )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 29520, "           BODY899_POLE_DEC       = (   43.46     0"
	    ".         0. )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 29600, "           BODY899_PM             = (  253.18   536"
	    ".3128492  0. )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 29680, "           BODY899_LONG_AXIS      = (    0.        "
	    "             )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 29760, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 29840, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 29920, "           BODY899_NUT_PREC_RA    = (  0.70 0. 0. 0"
	    ". 0. 0. 0. 0. )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 30000, "           BODY899_NUT_PREC_DEC   = ( -0.51 0. 0. 0"
	    ". 0. 0. 0. 0. )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 30080, "           BODY899_NUT_PREC_PM    = ( -0.48 0. 0. 0"
	    ". 0. 0. 0. 0. )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 30160, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 30240, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 30320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 30400, "           The 2000 report defines the nutation pre"
	    "cession angles", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 30480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 30560, "              N, N1, N2, ... , N7", (ftnlen)80, (
	    ftnlen)33);
    s_copy(pck + 30640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 30720, "           and also uses the multiples of N1 and N7",
	     (ftnlen)80, (ftnlen)51);
    s_copy(pck + 30800, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 30880, "              2*N1", (ftnlen)80, (ftnlen)18);
    s_copy(pck + 30960, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 31040, "           and", (ftnlen)80, (ftnlen)14);
    s_copy(pck + 31120, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 31200, "              2*N7, 3*N7, ..., 9*N7", (ftnlen)80, (
	    ftnlen)35);
    s_copy(pck + 31280, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 31360, "           In this file, we treat the angles and th"
	    "eir multiples as", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 31440, "           separate angles.  In the kernel variable",
	     (ftnlen)80, (ftnlen)51);
    s_copy(pck + 31520, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 31600, "              BODY8_NUT_PREC_ANGLES", (ftnlen)80, (
	    ftnlen)35);
    s_copy(pck + 31680, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 31760, "           the order of the angles is", (ftnlen)80, (
	    ftnlen)37);
    s_copy(pck + 31840, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 31920, "              N, N1, N2, ... , N7, 2*N1, 2*N7, 3*N7"
	    ", ..., 9*N7", (ftnlen)80, (ftnlen)62);
    s_copy(pck + 32000, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 32080, "           Each angle is defined by a linear polyno"
	    "mial, so two", (ftnlen)80, (ftnlen)63);
    s_copy(pck + 32160, "           consecutive array elements are allocated"
	    " for each", (ftnlen)80, (ftnlen)60);
    s_copy(pck + 32240, "           angle.  The first term of each pair is t"
	    "he constant term,", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 32320, "           the second is the linear term.", (ftnlen)
	    80, (ftnlen)41);
    s_copy(pck + 32400, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 32480, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 32560, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 32640, "              BODY8_NUT_PREC_ANGLES = (   357.85   "
	    "      52.316", (ftnlen)80, (ftnlen)63);
    s_copy(pck + 32720, "                                          323.92   "
	    "   62606.6", (ftnlen)80, (ftnlen)61);
    s_copy(pck + 32800, "                                          220.51   "
	    "   55064.2", (ftnlen)80, (ftnlen)61);
    s_copy(pck + 32880, "                                          354.27   "
	    "   46564.5", (ftnlen)80, (ftnlen)61);
    s_copy(pck + 32960, "                                           75.31   "
	    "   26109.4", (ftnlen)80, (ftnlen)61);
    s_copy(pck + 33040, "                                           35.36   "
	    "   14325.4", (ftnlen)80, (ftnlen)61);
    s_copy(pck + 33120, "                                          142.61   "
	    "    2824.6", (ftnlen)80, (ftnlen)61);
    s_copy(pck + 33200, "                                          177.85   "
	    "      52.316", (ftnlen)80, (ftnlen)63);
    s_copy(pck + 33280, "                                          647.840  "
	    "  125213.200", (ftnlen)80, (ftnlen)63);
    s_copy(pck + 33360, "                                          355.700  "
	    "     104.632", (ftnlen)80, (ftnlen)63);
    s_copy(pck + 33440, "                                          533.550  "
	    "     156.948", (ftnlen)80, (ftnlen)63);
    s_copy(pck + 33520, "                                          711.400  "
	    "     209.264", (ftnlen)80, (ftnlen)63);
    s_copy(pck + 33600, "                                          889.250  "
	    "     261.580", (ftnlen)80, (ftnlen)63);
    s_copy(pck + 33680, "                                         1067.100  "
	    "     313.896", (ftnlen)80, (ftnlen)63);
    s_copy(pck + 33760, "                                         1244.950  "
	    "     366.212", (ftnlen)80, (ftnlen)63);
    s_copy(pck + 33840, "                                         1422.800  "
	    "     418.528", (ftnlen)80, (ftnlen)63);
    s_copy(pck + 33920, "                                         1600.650  "
	    "     470.844   )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 34000, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 34080, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 34160, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 34240, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 34320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 34400, "Pluto", (ftnlen)80, (ftnlen)5);
    s_copy(pck + 34480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 34560, "     Old values:", (ftnlen)80, (ftnlen)16);
    s_copy(pck + 34640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 34720, "         Values are unchanged in the 2000 IAU repor"
	    "t.", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 34800, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 34880, "     Current values:", (ftnlen)80, (ftnlen)20);
    s_copy(pck + 34960, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 35040, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 35120, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 35200, "        BODY999_POLE_RA        = (  313.02    0.   "
	    "      0.   )", (ftnlen)80, (ftnlen)63);
    s_copy(pck + 35280, "        BODY999_POLE_DEC       = (    9.09    0.   "
	    "      0.   )", (ftnlen)80, (ftnlen)63);
    s_copy(pck + 35360, "        BODY999_PM             = (  236.77  -56.362"
	    "3195  0.   )", (ftnlen)80, (ftnlen)63);
    s_copy(pck + 35440, "        BODY999_LONG_AXIS      = (    0.           "
	    "          )", (ftnlen)80, (ftnlen)62);
    s_copy(pck + 35520, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 35600, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 35680, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 35760, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 35840, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 35920, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 36000, "Orientation constants for the satellites", (ftnlen)
	    80, (ftnlen)40);
    s_copy(pck + 36080, "---------------------------------------------------"
	    "-----", (ftnlen)80, (ftnlen)56);
    s_copy(pck + 36160, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 36240, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 36320, "Moon", (ftnlen)80, (ftnlen)4);
    s_copy(pck + 36400, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 36480, "     Old values:", (ftnlen)80, (ftnlen)16);
    s_copy(pck + 36560, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 36640, "        Values are from the 1988 IAU report.", (
	    ftnlen)80, (ftnlen)44);
    s_copy(pck + 36720, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 36800, "        body301_pole_ra        = (  270.000    0.  "
	    "         0. )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 36880, "        body301_pole_dec       = (   66.534    0.  "
	    "         0. )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 36960, "        body301_pm             = (   38.314   13.17"
	    "63581    0. )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 37040, "        body301_long_axis      = (    0.           "
	    "            )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 37120, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 37200, "        body301_nut_prec_ra  = (  -3.878  -0.120   "
	    "0.070  -0.017   0.    )", (ftnlen)80, (ftnlen)74);
    s_copy(pck + 37280, "        body301_nut_prec_dec = (   1.543   0.024  -"
	    "0.028   0.007   0.    )", (ftnlen)80, (ftnlen)74);
    s_copy(pck + 37360, "        body301_nut_prec_pm  = (   3.558   0.121  -"
	    "0.064   0.016   0.025 )", (ftnlen)80, (ftnlen)74);
    s_copy(pck + 37440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 37520, "        BODY301_POLE_RA      = (  269.9949    0.003"
	    "1        0.        )", (ftnlen)80, (ftnlen)71);
    s_copy(pck + 37600, "        BODY301_POLE_DEC     = (   66.5392    0.013"
	    "0        0.        )", (ftnlen)80, (ftnlen)71);
    s_copy(pck + 37680, "        BODY301_PM           = (   38.3213   13.176"
	    "35815   -1.4D-12   )", (ftnlen)80, (ftnlen)71);
    s_copy(pck + 37760, "        BODY301_LONG_AXIS    = (    0.             "
	    "                   )", (ftnlen)80, (ftnlen)71);
    s_copy(pck + 37840, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 37920, "        BODY301_NUT_PREC_RA  = (  -3.8787   -0.1204"
	    "   0.0700  -0.0172", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 38000, "                                   0.        0.0072"
	    "   0.       0.", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 38080, "                                   0.       -0.0052"
	    "   0.       0.", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 38160, "                                   0.0043          "
	    "                   )", (ftnlen)80, (ftnlen)71);
    s_copy(pck + 38240, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 38320, "        BODY301_NUT_PREC_DEC = (   1.5419   0.0239 "
	    "  -0.0278   0.0068", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 38400, "                                   0.      -0.0029 "
	    "   0.0009   0.", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 38480, "                                   0.       0.0008 "
	    "   0.       0.", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 38560, "                                  -0.0009          "
	    "                   )", (ftnlen)80, (ftnlen)71);
    s_copy(pck + 38640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 38720, "        BODY301_NUT_PREC_PM  = (  3.5610    0.1208 "
	    "  -0.0642   0.0158", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 38800, "                                  0.0252   -0.0066 "
	    "  -0.0047  -0.0046", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 38880, "                                  0.0028    0.0052 "
	    "   0.0040   0.0019", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 38960, "                                 -0.0044           "
	    "                   )", (ftnlen)80, (ftnlen)71);
    s_copy(pck + 39040, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 39120, "     New values:", (ftnlen)80, (ftnlen)16);
    s_copy(pck + 39200, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 39280, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 39360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 39440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 39520, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 39600, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 39680, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 39760, "        BODY301_POLE_RA      = (  269.9949        0"
	    ".0031        0.      )", (ftnlen)80, (ftnlen)73);
    s_copy(pck + 39840, "        BODY301_POLE_DEC     = (   66.5392        0"
	    ".0130        0.      )", (ftnlen)80, (ftnlen)73);
    s_copy(pck + 39920, "        BODY301_PM           = (   38.3213       13"
	    ".17635815   -1.4D-12 )", (ftnlen)80, (ftnlen)73);
    s_copy(pck + 40000, "        BODY301_LONG_AXIS    = (    0.             "
	    "                     )", (ftnlen)80, (ftnlen)73);
    s_copy(pck + 40080, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 40160, "        BODY301_NUT_PREC_RA  = (   -3.8787   -0.120"
	    "4   0.0700   -0.0172", (ftnlen)80, (ftnlen)71);
    s_copy(pck + 40240, "                                    0.0       0.007"
	    "2   0.0       0.0", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 40320, "                                    0.0      -0.005"
	    "2   0.0       0.0", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 40400, "                                    0.0043         "
	    "                     )", (ftnlen)80, (ftnlen)73);
    s_copy(pck + 40480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 40560, "        BODY301_NUT_PREC_DEC = (   1.5419     0.023"
	    "9  -0.0278    0.0068", (ftnlen)80, (ftnlen)71);
    s_copy(pck + 40640, "                                   0.0       -0.002"
	    "9   0.0009    0.0", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 40720, "                                   0.0        0.000"
	    "8   0.0       0.0", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 40800, "                                  -0.0009          "
	    "                     )", (ftnlen)80, (ftnlen)73);
    s_copy(pck + 40880, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 40960, "        BODY301_NUT_PREC_PM  = (   3.5610     0.120"
	    "8  -0.0642    0.0158", (ftnlen)80, (ftnlen)71);
    s_copy(pck + 41040, "                                   0.0252    -0.006"
	    "6  -0.0047   -0.0046", (ftnlen)80, (ftnlen)71);
    s_copy(pck + 41120, "                                   0.0028     0.005"
	    "2   0.0040    0.0019", (ftnlen)80, (ftnlen)71);
    s_copy(pck + 41200, "                                  -0.0044          "
	    "                     )", (ftnlen)80, (ftnlen)73);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 41280, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 41360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 41440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 41520, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 41600, "Satellites of Mars", (ftnlen)80, (ftnlen)18);
    s_copy(pck + 41680, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 41760, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 41840, "     Phobos", (ftnlen)80, (ftnlen)11);
    s_copy(pck + 41920, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 42000, "          Old values:", (ftnlen)80, (ftnlen)21);
    s_copy(pck + 42080, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 42160, "             Values are unchanged in the 2000 IAU r"
	    "eport.", (ftnlen)80, (ftnlen)57);
    s_copy(pck + 42240, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 42320, "          Current values:", (ftnlen)80, (ftnlen)25);
    s_copy(pck + 42400, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 42480, "            The quadratic prime meridian term is sc"
	    "aled by 1/36525**2:", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 42560, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 42640, "               8.864000000000000   --->   6.6443009"
	    "930565219E-09", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 42720, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 42800, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 42880, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 42960, "          BODY401_POLE_RA  = ( 317.68    -0.108    "
	    " 0.                     )", (ftnlen)80, (ftnlen)76);
    s_copy(pck + 43040, "          BODY401_POLE_DEC = (  52.90    -0.061    "
	    " 0.                     )", (ftnlen)80, (ftnlen)76);
    s_copy(pck + 43120, "          BODY401_PM       = (  35.06  1128.8445850"
	    " 6.6443009930565219E-09 )", (ftnlen)80, (ftnlen)76);
    s_copy(pck + 43200, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 43280, "          BODY401_LONG_AXIS     = (    0.       )", (
	    ftnlen)80, (ftnlen)49);
    s_copy(pck + 43360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 43440, "          BODY401_NUT_PREC_RA   = (   1.79    0.   "
	    " 0.   0. )", (ftnlen)80, (ftnlen)61);
    s_copy(pck + 43520, "          BODY401_NUT_PREC_DEC  = (  -1.08    0.   "
	    " 0.   0. )", (ftnlen)80, (ftnlen)61);
    s_copy(pck + 43600, "          BODY401_NUT_PREC_PM   = (  -1.42   -0.78 "
	    " 0.   0. )", (ftnlen)80, (ftnlen)61);
    s_copy(pck + 43680, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 43760, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 43840, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 43920, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 44000, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 44080, "     Deimos", (ftnlen)80, (ftnlen)11);
    s_copy(pck + 44160, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 44240, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 44320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 44400, "           Values are unchanged in the 2000 IAU rep"
	    "ort.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 44480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 44560, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 44640, "        New values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 44720, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 44800, "           The Deimos prime meridian expression is:",
	     (ftnlen)80, (ftnlen)51);
    s_copy(pck + 44880, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 44960, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 45040, "                                                   "
	    "  2", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 45120, "              W = 79.41  +  285.1618970 d  -  0.520"
	    " T  -  2.58 sin M", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 45200, "                                                   "
	    "                 3", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 45280, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 45360, "                                                   "
	    "    +  0.19 cos M .", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 45440, "                                                   "
	    "                 3", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 45520, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 45600, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 45680, "           At the present time, the PCK kernel soft"
	    "ware (the routine", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 45760, "           BODEUL in particular) cannot handle the "
	    "cosine term directly,", (ftnlen)80, (ftnlen)72);
    s_copy(pck + 45840, "           but we can represent it as", (ftnlen)80, (
	    ftnlen)37);
    s_copy(pck + 45920, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 46000, "              0.19 sin M", (ftnlen)80, (ftnlen)24);
    s_copy(pck + 46080, "                        4", (ftnlen)80, (ftnlen)25);
    s_copy(pck + 46160, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 46240, "           where", (ftnlen)80, (ftnlen)16);
    s_copy(pck + 46320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 46400, "              M   =  90.D0 - M", (ftnlen)80, (ftnlen)
	    30);
    s_copy(pck + 46480, "               4              3", (ftnlen)80, (
	    ftnlen)31);
    s_copy(pck + 46560, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 46640, "           Therefore, the nutation precession angle"
	    " assignments for Phobos", (ftnlen)80, (ftnlen)74);
    s_copy(pck + 46720, "           and Deimos contain four coefficients rat"
	    "her than three.", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 46800, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 46880, "           The quadratic prime meridian term is sca"
	    "led by 1/36525**2:", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 46960, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 47040, "              -0.5200000000000000  --->   -3.897830"
	    "0049519307E-10", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 47120, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 47200, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 47280, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 47360, "           BODY402_POLE_RA       = (  316.65     -0"
	    ".108       0.           )", (ftnlen)80, (ftnlen)76);
    s_copy(pck + 47440, "           BODY402_POLE_DEC      = (   53.52     -0"
	    ".061       0.           )", (ftnlen)80, (ftnlen)76);
    s_copy(pck + 47520, "           BODY402_PM            = (   79.41    285"
	    ".1618970  -3.897830D-10 )", (ftnlen)80, (ftnlen)76);
    s_copy(pck + 47600, "           BODY402_LONG_AXIS     = (    0.         "
	    "                        )", (ftnlen)80, (ftnlen)76);
    s_copy(pck + 47680, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 47760, "           BODY402_NUT_PREC_RA   = (    0.   0.   2"
	    ".98    0.   )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 47840, "           BODY402_NUT_PREC_DEC  = (    0.   0.  -1"
	    ".78    0.   )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 47920, "           BODY402_NUT_PREC_PM   = (    0.   0.  -2"
	    ".58    0.19 )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 48000, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 48080, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 48160, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 48240, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 48320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 48400, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 48480, "Satellites of Jupiter", (ftnlen)80, (ftnlen)21);
    s_copy(pck + 48560, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 48640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 48720, "     Io", (ftnlen)80, (ftnlen)7);
    s_copy(pck + 48800, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 48880, "          Old values:", (ftnlen)80, (ftnlen)21);
    s_copy(pck + 48960, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 49040, "             Values are unchanged in the 2000 IAU r"
	    "eport.", (ftnlen)80, (ftnlen)57);
    s_copy(pck + 49120, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 49200, "          Current values:", (ftnlen)80, (ftnlen)25);
    s_copy(pck + 49280, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 49360, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 49440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 49520, "        BODY501_POLE_RA       = (  268.05          "
	    "-0.009      0. )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 49600, "        BODY501_POLE_DEC      = (   64.50          "
	    " 0.003      0. )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 49680, "        BODY501_PM            = (  200.39         2"
	    "03.4889538  0. )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 49760, "        BODY501_LONG_AXIS     = (    0.            "
	    "               )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 49840, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 49920, "        BODY501_NUT_PREC_RA   = (    0.   0.     0."
	    "094    0.024   )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 50000, "        BODY501_NUT_PREC_DEC  = (    0.   0.     0."
	    "040    0.011   )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 50080, "        BODY501_NUT_PREC_PM   = (    0.   0.    -0."
	    "085   -0.022   )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 50160, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 50240, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 50320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 50400, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 50480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 50560, "     Europa", (ftnlen)80, (ftnlen)11);
    s_copy(pck + 50640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 50720, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 50800, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 50880, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 50960, "        body502_pole_ra       = (  268.08          "
	    "-0.009      0.   )", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 51040, "        body502_pole_dec      = (   64.51          "
	    " 0.003      0.   )", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 51120, "        body502_pm            = (   35.67         1"
	    "01.3747235  0.   )", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 51200, "        body502_long_axis     = (    0.            "
	    "                 )", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 51280, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 51360, "        body502_nut_prec_ra   = ( 0. 0. 0.   1.086 "
	    "  0.060   0.015   0.009 )", (ftnlen)80, (ftnlen)76);
    s_copy(pck + 51440, "        body502_nut_prec_dec  = ( 0. 0. 0.   0.468 "
	    "  0.026   0.007   0.002 )", (ftnlen)80, (ftnlen)76);
    s_copy(pck + 51520, "        body502_nut_prec_pm   = ( 0. 0. 0.  -0.980 "
	    " -0.054  -0.014  -0.008 )", (ftnlen)80, (ftnlen)76);
    s_copy(pck + 51600, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 51680, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 51760, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 51840, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 51920, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 52000, "        BODY502_POLE_RA       = (  268.08          "
	    "-0.009      0.   )", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 52080, "        BODY502_POLE_DEC      = (   64.51          "
	    " 0.003      0.   )", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 52160, "        BODY502_PM            = (   36.022        1"
	    "01.3747235  0.   )", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 52240, "        BODY502_LONG_AXIS     = (    0.            "
	    "                 )", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 52320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 52400, "        BODY502_NUT_PREC_RA   = ( 0. 0. 0.   1.086 "
	    "  0.060   0.015   0.009 )", (ftnlen)80, (ftnlen)76);
    s_copy(pck + 52480, "        BODY502_NUT_PREC_DEC  = ( 0. 0. 0.   0.468 "
	    "  0.026   0.007   0.002 )", (ftnlen)80, (ftnlen)76);
    s_copy(pck + 52560, "        BODY502_NUT_PREC_PM   = ( 0. 0. 0.  -0.980 "
	    " -0.054  -0.014  -0.008 )", (ftnlen)80, (ftnlen)76);
    s_copy(pck + 52640, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 52720, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 52800, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 52880, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 52960, "     Ganymede", (ftnlen)80, (ftnlen)13);
    s_copy(pck + 53040, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 53120, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 53200, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 53280, "        body503_pole_ra       = (  268.20          "
	    "-0.009      0.   )", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 53360, "        body503_pole_dec      = (  +64.57          "
	    "+0.003      0.   )", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 53440, "        body503_pm            = (   44.04         +"
	    "50.3176081  0.   )", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 53520, "        body503_long_axis     = (    0.            "
	    "                 )", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 53600, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 53680, "        body503_nut_prec_ra   = ( 0. 0. 0.  -0.037 "
	    " +0.431  +0.091   )", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 53760, "        body503_nut_prec_dec  = ( 0. 0. 0.  -0.016 "
	    " +0.186  +0.039   )", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 53840, "        body503_nut_prec_pm   = ( 0. 0. 0.  +0.033 "
	    " -0.389  -0.082   )", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 53920, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 54000, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 54080, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 54160, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 54240, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 54320, "        BODY503_POLE_RA       = (  268.20         -"
	    "0.009       0.  )", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 54400, "        BODY503_POLE_DEC      = (   64.57          "
	    "0.003       0.  )", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 54480, "        BODY503_PM            = (   44.064        5"
	    "0.3176081   0.  )", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 54560, "        BODY503_LONG_AXIS     = (    0.            "
	    "                )", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 54640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 54720, "        BODY503_NUT_PREC_RA   = ( 0. 0. 0.  -0.037 "
	    "  0.431   0.091   )", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 54800, "        BODY503_NUT_PREC_DEC  = ( 0. 0. 0.  -0.016 "
	    "  0.186   0.039   )", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 54880, "        BODY503_NUT_PREC_PM   = ( 0. 0. 0.   0.033 "
	    " -0.389  -0.082   )", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 54960, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 55040, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 55120, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 55200, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 55280, "     Callisto", (ftnlen)80, (ftnlen)13);
    s_copy(pck + 55360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 55440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 55520, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 55600, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 55680, "        body504_pole_ra       = (   268.72   -0.009"
	    "      0.  )", (ftnlen)80, (ftnlen)62);
    s_copy(pck + 55760, "        body504_pole_dec      = (   +64.83   +0.003"
	    "      0.  )", (ftnlen)80, (ftnlen)62);
    s_copy(pck + 55840, "        body504_pm            = (   259.73  +21.571"
	    "0715  0.  )", (ftnlen)80, (ftnlen)62);
    s_copy(pck + 55920, "        body504_long_axis     = (     0.           "
	    "          )", (ftnlen)80, (ftnlen)62);
    s_copy(pck + 56000, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 56080, "        body504_nut_prec_ra   = ( 0. 0. 0. 0. -0.06"
	    "8 +0.590  0. +0.010 )", (ftnlen)80, (ftnlen)72);
    s_copy(pck + 56160, "        body504_nut_prec_dec  = ( 0. 0. 0. 0. -0.02"
	    "9 +0.254  0. -0.004 )", (ftnlen)80, (ftnlen)72);
    s_copy(pck + 56240, "        body504_nut_prec_pm   = ( 0. 0. 0. 0. +0.06"
	    "1 -0.533  0. -0.009 )", (ftnlen)80, (ftnlen)72);
    s_copy(pck + 56320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 56400, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 56480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 56560, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 56640, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 56720, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 56800, "        BODY504_POLE_RA       = (   268.72    -0.00"
	    "9       0.  )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 56880, "        BODY504_POLE_DEC      = (    64.83     0.00"
	    "3       0.  )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 56960, "        BODY504_PM            = (   259.51    21.57"
	    "10715   0.  )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 57040, "        BODY504_LONG_AXIS     = (     0.           "
	    "            )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 57120, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 57200, "        BODY504_NUT_PREC_RA   = ( 0. 0. 0. 0.  -0.0"
	    "68   0.590  0.   0.010 )", (ftnlen)80, (ftnlen)75);
    s_copy(pck + 57280, "        BODY504_NUT_PREC_DEC  = ( 0. 0. 0. 0.  -0.0"
	    "29   0.254  0.  -0.004 )", (ftnlen)80, (ftnlen)75);
    s_copy(pck + 57360, "        BODY504_NUT_PREC_PM   = ( 0. 0. 0. 0.   0.0"
	    "61  -0.533  0.  -0.009 )", (ftnlen)80, (ftnlen)75);
    s_copy(pck + 57440, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 57520, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 57600, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 57680, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 57760, "     Amalthea", (ftnlen)80, (ftnlen)13);
    s_copy(pck + 57840, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 57920, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 58000, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 58080, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 58160, "           Values are unchanged in the 2000 IAU rep"
	    "ort.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 58240, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 58320, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 58400, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 58480, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 58560, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 58640, "        BODY505_POLE_RA       = (   268.05    -0.00"
	    "9      0.  )", (ftnlen)80, (ftnlen)63);
    s_copy(pck + 58720, "        BODY505_POLE_DEC      = (    64.49     0.00"
	    "3      0.  )", (ftnlen)80, (ftnlen)63);
    s_copy(pck + 58800, "        BODY505_PM            = (   231.67   722.63"
	    "14560  0.  )", (ftnlen)80, (ftnlen)63);
    s_copy(pck + 58880, "        BODY505_LONG_AXIS     = (     0.           "
	    "           )", (ftnlen)80, (ftnlen)63);
    s_copy(pck + 58960, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 59040, "        BODY505_NUT_PREC_RA  = ( -0.84  0. 0. 0. 0."
	    " 0. 0. 0.   0.01  0. )", (ftnlen)80, (ftnlen)73);
    s_copy(pck + 59120, "        BODY505_NUT_PREC_DEC = ( -0.36  0. 0. 0. 0."
	    " 0. 0. 0.   0.    0. )", (ftnlen)80, (ftnlen)73);
    s_copy(pck + 59200, "        BODY505_NUT_PREC_PM  = (  0.76  0. 0. 0. 0."
	    " 0. 0. 0.  -0.01  0. )", (ftnlen)80, (ftnlen)73);
    s_copy(pck + 59280, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 59360, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 59440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 59520, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 59600, "     Thebe", (ftnlen)80, (ftnlen)10);
    s_copy(pck + 59680, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 59760, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 59840, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 59920, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 60000, "           Values are unchanged in the 2000 IAU rep"
	    "ort.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 60080, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 60160, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 60240, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 60320, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 60400, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 60480, "        BODY514_POLE_RA       = (  268.05     -0.00"
	    "9       0.  )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 60560, "        BODY514_POLE_DEC      = (   64.49      0.00"
	    "3       0.  )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 60640, "        BODY514_PM            = (    8.56    533.70"
	    "04100   0.  )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 60720, "        BODY514_LONG_AXIS     = (    0.            "
	    "            )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 60800, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 60880, "        BODY514_NUT_PREC_RA  = ( 0.  -2.11  0. 0. 0"
	    ". 0. 0. 0. 0.  0.04 )", (ftnlen)80, (ftnlen)72);
    s_copy(pck + 60960, "        BODY514_NUT_PREC_DEC = ( 0.  -0.91  0. 0. 0"
	    ". 0. 0. 0. 0.  0.01 )", (ftnlen)80, (ftnlen)72);
    s_copy(pck + 61040, "        BODY514_NUT_PREC_PM  = ( 0.   1.91  0. 0. 0"
	    ". 0. 0. 0. 0. -0.04 )", (ftnlen)80, (ftnlen)72);
    s_copy(pck + 61120, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 61200, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 61280, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 61360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 61440, "     Adrastea", (ftnlen)80, (ftnlen)13);
    s_copy(pck + 61520, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 61600, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 61680, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 61760, "           Values are unchanged in the 2000 IAU rep"
	    "ort.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 61840, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 61920, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 62000, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 62080, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 62160, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 62240, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 62320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 62400, "        BODY515_POLE_RA       = (  268.05     -0.00"
	    "9       0.  )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 62480, "        BODY515_POLE_DEC      = (   64.49      0.00"
	    "3       0.  )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 62560, "        BODY515_PM            = (   33.29   1206.99"
	    "86602   0.  )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 62640, "        BODY515_LONG_AXIS     = (    0.            "
	    "            )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 62720, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 62800, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 62880, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 62960, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 63040, "     Metis", (ftnlen)80, (ftnlen)10);
    s_copy(pck + 63120, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 63200, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 63280, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 63360, "           Values are unchanged in the 2000 IAU rep"
	    "ort.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 63440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 63520, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 63600, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 63680, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 63760, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 63840, "        BODY516_POLE_RA       = (  268.05     -0.00"
	    "9       0.  )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 63920, "        BODY516_POLE_DEC      = (   64.49      0.00"
	    "3       0.  )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 64000, "        BODY516_PM            = (  346.09   1221.25"
	    "47301   0.  )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 64080, "        BODY516_LONG_AXIS     = (    0.            "
	    "            )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 64160, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 64240, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 64320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 64400, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 64480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 64560, "Satellites of Saturn", (ftnlen)80, (ftnlen)20);
    s_copy(pck + 64640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 64720, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 64800, "     Mimas", (ftnlen)80, (ftnlen)10);
    s_copy(pck + 64880, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 64960, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 65040, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 65120, "           Values are unchanged in the 2000 IAU rep"
	    "ort.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 65200, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 65280, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 65360, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 65440, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 65520, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 65600, "           BODY601_POLE_RA       = (   40.66     -0"
	    ".036      0.  )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 65680, "           BODY601_POLE_DEC      = (   83.52     -0"
	    ".004      0.  )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 65760, "           BODY601_PM            = (  337.46    381"
	    ".9945550  0.  )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 65840, "           BODY601_LONG_AXIS     = (     0.        "
	    "              )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 65920, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 66000, "           BODY601_NUT_PREC_RA   = ( 0. 0.   13.56 "
	    " 0.    0.    0. 0. 0. 0. )", (ftnlen)80, (ftnlen)77);
    s_copy(pck + 66080, "           BODY601_NUT_PREC_DEC  = ( 0. 0.   -1.53 "
	    " 0.    0.    0. 0. 0. 0. )", (ftnlen)80, (ftnlen)77);
    s_copy(pck + 66160, "           BODY601_NUT_PREC_PM   = ( 0. 0.  -13.48 "
	    " 0.  -44.85  0. 0. 0. 0. )", (ftnlen)80, (ftnlen)77);
    s_copy(pck + 66240, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 66320, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 66400, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 66480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 66560, "     Enceladus", (ftnlen)80, (ftnlen)14);
    s_copy(pck + 66640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 66720, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 66800, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 66880, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 66960, "           Values are unchanged in the 2000 IAU rep"
	    "ort.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 67040, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 67120, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 67200, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 67280, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 67360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 67440, "           BODY602_POLE_RA       = (   40.66    -0."
	    "036       0. )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 67520, "           BODY602_POLE_DEC      = (   83.52    -0."
	    "004       0. )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 67600, "           BODY602_PM            = (    2.82   262."
	    "7318996   0. )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 67680, "           BODY602_LONG_AXIS     = (    0.         "
	    "             )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 67760, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 67840, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 67920, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 68000, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 68080, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 68160, "     Tethys", (ftnlen)80, (ftnlen)11);
    s_copy(pck + 68240, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 68320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 68400, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 68480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 68560, "           Values are unchanged in the 2000 IAU rep"
	    "ort.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 68640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 68720, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 68800, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 68880, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 68960, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 69040, "           BODY603_POLE_RA       = (   40.66    -0."
	    "036       0. )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 69120, "           BODY603_POLE_DEC      = (   83.52    -0."
	    "004       0. )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 69200, "           BODY603_PM            = (   10.45   190."
	    "6979085   0. )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 69280, "           BODY603_LONG_AXIS     = (    0.         "
	    "             )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 69360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 69440, "           BODY603_NUT_PREC_RA   = ( 0. 0. 0.   9.6"
	    "6   0.    0.  0.  0.  0. )", (ftnlen)80, (ftnlen)77);
    s_copy(pck + 69520, "           BODY603_NUT_PREC_DEC  = ( 0. 0. 0.  -1.0"
	    "9   0.    0.  0.  0.  0. )", (ftnlen)80, (ftnlen)77);
    s_copy(pck + 69600, "           BODY603_NUT_PREC_PM   = ( 0. 0. 0.  -9.6"
	    "0   2.23  0.  0.  0.  0. )", (ftnlen)80, (ftnlen)77);
    s_copy(pck + 69680, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 69760, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 69840, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 69920, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 70000, "     Dione", (ftnlen)80, (ftnlen)10);
    s_copy(pck + 70080, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 70160, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 70240, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 70320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 70400, "           Values are unchanged in the 2000 IAU rep"
	    "ort.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 70480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 70560, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 70640, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 70720, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 70800, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 70880, "           BODY604_POLE_RA       = (  40.66      -0"
	    ".036      0.  )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 70960, "           BODY604_POLE_DEC      = (  83.52      -0"
	    ".004      0.  )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 71040, "           BODY604_PM            = (  357.00    131"
	    ".5349316  0.  )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 71120, "           BODY604_LONG_AXIS     = (    0.         "
	    "              )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 71200, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 71280, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 71360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 71440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 71520, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 71600, "     Rhea", (ftnlen)80, (ftnlen)9);
    s_copy(pck + 71680, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 71760, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 71840, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 71920, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 72000, "           Values are unchanged in the 2000 IAU rep"
	    "ort.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 72080, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 72160, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 72240, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 72320, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 72400, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 72480, "           BODY605_POLE_RA       = (   40.38   -0.0"
	    "36       0. )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 72560, "           BODY605_POLE_DEC      = (   83.55   -0.0"
	    "04       0. )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 72640, "           BODY605_PM            = (  235.16   79.6"
	    "900478   0. )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 72720, "           BODY605_LONG_AXIS     = (    0.         "
	    "            )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 72800, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 72880, "           BODY605_NUT_PREC_RA   = ( 0. 0. 0. 0. 0."
	    "   3.10   0. 0. 0. )", (ftnlen)80, (ftnlen)71);
    s_copy(pck + 72960, "           BODY605_NUT_PREC_DEC  = ( 0. 0. 0. 0. 0."
	    "  -0.35   0. 0. 0. )", (ftnlen)80, (ftnlen)71);
    s_copy(pck + 73040, "           BODY605_NUT_PREC_PM   = ( 0. 0. 0. 0. 0."
	    "  -3.08   0. 0. 0. )", (ftnlen)80, (ftnlen)71);
    s_copy(pck + 73120, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 73200, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 73280, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 73360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 73440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 73520, "     Titan", (ftnlen)80, (ftnlen)10);
    s_copy(pck + 73600, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 73680, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 73760, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 73840, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 73920, "           Values are unchanged in the 2000 IAU rep"
	    "ort.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 74000, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 74080, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 74160, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 74240, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 74320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 74400, "           BODY606_POLE_RA       = (    36.41   -0."
	    "036      0. )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 74480, "           BODY606_POLE_DEC      = (    83.94   -0."
	    "004      0. )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 74560, "           BODY606_PM            = (   189.64   22."
	    "5769768  0. )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 74640, "           BODY606_LONG_AXIS     = (     0.        "
	    "            )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 74720, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 74800, "           BODY606_NUT_PREC_RA   = ( 0. 0. 0. 0. 0."
	    " 0.  2.66  0. 0 )", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 74880, "           BODY606_NUT_PREC_DEC  = ( 0. 0. 0. 0. 0."
	    " 0. -0.30  0. 0 )", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 74960, "           BODY606_NUT_PREC_PM   = ( 0. 0. 0. 0. 0."
	    " 0. -2.64  0. 0 )", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 75040, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 75120, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 75200, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 75280, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 75360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 75440, "     Hyperion", (ftnlen)80, (ftnlen)13);
    s_copy(pck + 75520, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 75600, "         The IAU report does not give an orientatio"
	    "n model for Hyperion.", (ftnlen)80, (ftnlen)72);
    s_copy(pck + 75680, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 75760, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 75840, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 75920, "     Iapetus", (ftnlen)80, (ftnlen)12);
    s_copy(pck + 76000, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 76080, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 76160, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 76240, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 76320, "           Values are unchanged in the 2000 IAU rep"
	    "ort.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 76400, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 76480, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 76560, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 76640, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 76720, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 76800, "           BODY608_POLE_RA       = (   318.16  -3.9"
	    "49      0.  )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 76880, "           BODY608_POLE_DEC      = (    75.03  -1.1"
	    "43      0.  )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 76960, "           BODY608_PM            = (   350.20   4.5"
	    "379572  0.  )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 77040, "           BODY608_LONG_AXIS     = (     0.        "
	    "            )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 77120, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 77200, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 77280, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 77360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 77440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 77520, "     Phoebe", (ftnlen)80, (ftnlen)11);
    s_copy(pck + 77600, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 77680, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 77760, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 77840, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 77920, "           Values are unchanged in the 2000 IAU rep"
	    "ort.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 78000, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 78080, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 78160, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 78240, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 78320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 78400, "           BODY609_POLE_RA       = ( 355.00       0"
	    ".         0.  )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 78480, "           BODY609_POLE_DEC      = (  68.70       0"
	    ".         0.  )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 78560, "           BODY609_PM            = ( 304.70     930"
	    ".8338720  0.  )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 78640, "           BODY609_LONG_AXIS     = (    0.         "
	    "              )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 78720, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 78800, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 78880, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 78960, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 79040, "     Janus", (ftnlen)80, (ftnlen)10);
    s_copy(pck + 79120, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 79200, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 79280, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 79360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 79440, "           Values are unchanged in the 2000 IAU rep"
	    "ort.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 79520, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 79600, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 79680, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 79760, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 79840, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 79920, "           BODY610_POLE_RA       = (  40.58    -0.0"
	    "36       0. )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 80000, "           BODY610_POLE_DEC      = (  83.52    -0.0"
	    "04       0. )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 80080, "           BODY610_PM            = (  58.83   518.2"
	    "359876   0. )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 80160, "           BODY610_LONG_AXIS     = (   0.          "
	    "            )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 80240, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 80320, "           BODY610_NUT_PREC_RA   = ( 0. -1.623  0. "
	    "0. 0. 0. 0. 0.  0.023 )", (ftnlen)80, (ftnlen)74);
    s_copy(pck + 80400, "           BODY610_NUT_PREC_DEC  = ( 0. -0.183  0. "
	    "0. 0. 0. 0. 0.  0.001 )", (ftnlen)80, (ftnlen)74);
    s_copy(pck + 80480, "           BODY610_NUT_PREC_PM   = ( 0.  1.613  0. "
	    "0. 0. 0. 0. 0. -0.023 )", (ftnlen)80, (ftnlen)74);
    s_copy(pck + 80560, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 80640, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 80720, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 80800, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 80880, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 80960, "     Epimetheus", (ftnlen)80, (ftnlen)15);
    s_copy(pck + 81040, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 81120, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 81200, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 81280, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 81360, "           Values are unchanged in the 2000 IAU rep"
	    "ort.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 81440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 81520, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 81600, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 81680, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 81760, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 81840, "           BODY611_POLE_RA       = (  40.58    -0.0"
	    "36        0. )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 81920, "           BODY611_POLE_DEC      = (  83.52    -0.0"
	    "04        0. )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 82000, "           BODY611_PM            = ( 293.87   518.4"
	    "907239    0. )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 82080, "           BODY611_LONG_AXIS     = (   0.          "
	    "             )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 82160, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 82240, "           BODY611_NUT_PREC_RA   = ( -3.153   0. 0."
	    " 0. 0. 0. 0.   0.086  0. )", (ftnlen)80, (ftnlen)77);
    s_copy(pck + 82320, "           BODY611_NUT_PREC_DEC  = ( -0.356   0. 0."
	    " 0. 0. 0. 0.   0.005  0. )", (ftnlen)80, (ftnlen)77);
    s_copy(pck + 82400, "           BODY611_NUT_PREC_PM   = (  3.133   0. 0."
	    " 0. 0. 0. 0.  -0.086  0. )", (ftnlen)80, (ftnlen)77);
    s_copy(pck + 82480, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 82560, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 82640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 82720, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 82800, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 82880, "     Helene", (ftnlen)80, (ftnlen)11);
    s_copy(pck + 82960, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 83040, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 83120, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 83200, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 83280, "           Values are unchanged in the 2000 IAU rep"
	    "ort.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 83360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 83440, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 83520, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 83600, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 83680, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 83760, "           BODY612_POLE_RA       = (  40.85     -0."
	    "036        0. )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 83840, "           BODY612_POLE_DEC      = (  83.34     -0."
	    "004        0. )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 83920, "           BODY612_PM            = ( 245.12    131."
	    "6174056    0. )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 84000, "           BODY612_LONG_AXIS     = (   0.          "
	    "              )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 84080, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 84160, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 84240, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 84320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 84400, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 84480, "     Telesto", (ftnlen)80, (ftnlen)12);
    s_copy(pck + 84560, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 84640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 84720, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 84800, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 84880, "           Values are unchanged in the 2000 IAU rep"
	    "ort.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 84960, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 85040, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 85120, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 85200, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 85280, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 85360, "           BODY613_POLE_RA       = ( 50.51    -0.03"
	    "6      0.  )", (ftnlen)80, (ftnlen)63);
    s_copy(pck + 85440, "           BODY613_POLE_DEC      = ( 84.06    -0.00"
	    "4      0.  )", (ftnlen)80, (ftnlen)63);
    s_copy(pck + 85520, "           BODY613_PM            = ( 56.88   190.69"
	    "79332  0.  )", (ftnlen)80, (ftnlen)63);
    s_copy(pck + 85600, "           BODY613_LONG_AXIS     = (  0.           "
	    "           )", (ftnlen)80, (ftnlen)63);
    s_copy(pck + 85680, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 85760, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 85840, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 85920, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 86000, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 86080, "     Calypso", (ftnlen)80, (ftnlen)12);
    s_copy(pck + 86160, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 86240, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 86320, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 86400, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 86480, "           Values are unchanged in the 2000 IAU rep"
	    "ort.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 86560, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 86640, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 86720, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 86800, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 86880, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 86960, "           BODY614_POLE_RA       = (   36.41    -0."
	    "036        0.  )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 87040, "           BODY614_POLE_DEC      = (   85.04    -0."
	    "004        0.  )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 87120, "           BODY614_PM            = (  153.51   190."
	    "6742373    0.  )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 87200, "           BODY614_LONG_AXIS     = (    0.         "
	    "               )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 87280, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 87360, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 87440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 87520, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 87600, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 87680, "     Atlas", (ftnlen)80, (ftnlen)10);
    s_copy(pck + 87760, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 87840, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 87920, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 88000, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 88080, "           Values are unchanged in the 2000 IAU rep"
	    "ort.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 88160, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 88240, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 88320, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 88400, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 88480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 88560, "           BODY615_POLE_RA       = (   40.58     -0"
	    ".036      0. )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 88640, "           BODY615_POLE_DEC      = (   83.53     -0"
	    ".004      0. )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 88720, "           BODY615_PM            = (  137.88    598"
	    ".3060000  0. )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 88800, "           BODY615_LONG_AXIS     = (    0.         "
	    "             )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 88880, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 88960, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 89040, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 89120, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 89200, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 89280, "     Prometheus", (ftnlen)80, (ftnlen)15);
    s_copy(pck + 89360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 89440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 89520, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 89600, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 89680, "           Values are unchanged in the 2000 IAU rep"
	    "ort.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 89760, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 89840, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 89920, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 90000, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 90080, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 90160, "           BODY616_POLE_RA       = (  40.58      -0"
	    ".036    )", (ftnlen)80, (ftnlen)60);
    s_copy(pck + 90240, "           BODY616_POLE_DEC      = (  83.53      -0"
	    ".004    )", (ftnlen)80, (ftnlen)60);
    s_copy(pck + 90320, "           BODY616_PM            = ( 296.14     587"
	    ".289000 )", (ftnlen)80, (ftnlen)60);
    s_copy(pck + 90400, "           BODY616_LONG_AXIS     = (   0.          "
	    "        )", (ftnlen)80, (ftnlen)60);
    s_copy(pck + 90480, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 90560, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 90640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 90720, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 90800, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 90880, "     Pandora", (ftnlen)80, (ftnlen)12);
    s_copy(pck + 90960, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 91040, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 91120, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 91200, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 91280, "           Values are unchanged in the 2000 IAU rep"
	    "ort.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 91360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 91440, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 91520, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 91600, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 91680, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 91760, "           BODY617_POLE_RA       = (   40.58     -0"
	    ".036      0.  )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 91840, "           BODY617_POLE_DEC      = (   83.53     -0"
	    ".004      0.  )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 91920, "           BODY617_PM            = (  162.92    572"
	    ".7891000  0.  )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 92000, "           BODY617_LONG_AXIS     = (     0.        "
	    "              )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 92080, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 92160, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 92240, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 92320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 92400, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 92480, "     Pan", (ftnlen)80, (ftnlen)8);
    s_copy(pck + 92560, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 92640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 92720, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 92800, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 92880, "           Values are unchanged in the 2000 IAU rep"
	    "ort.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 92960, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 93040, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 93120, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 93200, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 93280, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 93360, "           BODY618_POLE_RA       = (   40.6     -0."
	    "036       0. )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 93440, "           BODY618_POLE_DEC      = (   83.5     -0."
	    "004       0. )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 93520, "           BODY618_PM            = (   48.8    626."
	    "0440000   0. )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 93600, "           BODY618_LONG_AXIS     = (    0.         "
	    "             )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 93680, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 93760, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 93840, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 93920, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 94000, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 94080, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 94160, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 94240, "Satellites of Uranus", (ftnlen)80, (ftnlen)20);
    s_copy(pck + 94320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 94400, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 94480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 94560, "     Ariel", (ftnlen)80, (ftnlen)10);
    s_copy(pck + 94640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 94720, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 94800, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 94880, "           Values are unchanged in the 2000 IAU rep"
	    "ort.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 94960, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 95040, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 95120, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 95200, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 95280, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 95360, "           BODY701_POLE_RA       = ( 257.43     0. "
	    "         0. )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 95440, "           BODY701_POLE_DEC      = ( -15.10     0. "
	    "         0. )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 95520, "           BODY701_PM            = ( 156.22  -142.8"
	    "356681   0. )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 95600, "           BODY701_LONG_AXIS     = (   0.          "
	    "            )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 95680, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 95760, "           BODY701_NUT_PREC_RA   = (  0. 0. 0. 0. 0."
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 95840, "                                      0. 0. 0. 0. 0"
	    ".  0.    0.    0.29 )", (ftnlen)80, (ftnlen)72);
    s_copy(pck + 95920, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 96000, "           BODY701_NUT_PREC_DEC  = (  0. 0. 0. 0. 0."
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 96080, "                                      0. 0. 0. 0. 0"
	    ".  0.    0.    0.28 )", (ftnlen)80, (ftnlen)72);
    s_copy(pck + 96160, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 96240, "           BODY701_NUT_PREC_PM   = (  0. 0. 0. 0. 0."
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 96320, "                                      0. 0. 0. 0. 0"
	    ".  0.   0.05   0.08 )", (ftnlen)80, (ftnlen)72);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 96400, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 96480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 96560, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 96640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 96720, "     Umbriel", (ftnlen)80, (ftnlen)12);
    s_copy(pck + 96800, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 96880, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 96960, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 97040, "           Values are unchanged in the 2000 IAU rep"
	    "ort.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 97120, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 97200, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 97280, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 97360, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 97440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 97520, "           BODY702_POLE_RA       = (  257.43     0."
	    "          0. )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 97600, "           BODY702_POLE_DEC      = (  -15.10     0."
	    "          0. )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 97680, "           BODY702_PM            = (  108.05   -86."
	    "8688923   0. )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 97760, "           BODY702_LONG_AXIS     = (    0.         "
	    "             )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 97840, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 97920, "           BODY702_NUT_PREC_RA   = ( 0. 0. 0. 0. 0.",
	     (ftnlen)80, (ftnlen)51);
    s_copy(pck + 98000, "                                     0. 0. 0. 0. 0."
	    "   0.   0.    0.   0.21 )", (ftnlen)80, (ftnlen)76);
    s_copy(pck + 98080, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 98160, "           BODY702_NUT_PREC_DEC  = ( 0. 0. 0. 0. 0.",
	     (ftnlen)80, (ftnlen)51);
    s_copy(pck + 98240, "                                     0. 0. 0. 0. 0."
	    "   0.   0.    0.   0.20 )", (ftnlen)80, (ftnlen)76);
    s_copy(pck + 98320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 98400, "           BODY702_NUT_PREC_PM   = ( 0. 0. 0. 0. 0.",
	     (ftnlen)80, (ftnlen)51);
    s_copy(pck + 98480, "                                     0. 0. 0. 0. 0."
	    "   0.  -0.09  0.   0.06 )", (ftnlen)80, (ftnlen)76);
    s_copy(pck + 98560, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 98640, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 98720, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 98800, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 98880, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 98960, "     Titania", (ftnlen)80, (ftnlen)12);
    s_copy(pck + 99040, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 99120, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 99200, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 99280, "           Values are unchanged in the 2000 IAU rep"
	    "ort.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 99360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 99440, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 99520, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 99600, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 99680, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 99760, "           BODY703_POLE_RA       = (  257.43    0. "
	    "         0. )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 99840, "           BODY703_POLE_DEC      = (  -15.10    0. "
	    "         0. )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 99920, "           BODY703_PM            = (   77.74  -41.3"
	    "514316   0. )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 100000, "           BODY703_LONG_AXIS     = (    0.        "
	    "             )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 100080, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 100160, "           BODY703_NUT_PREC_RA   = ( 0. 0. 0. 0. 0."
	    , (ftnlen)80, (ftnlen)51);
    s_copy(pck + 100240, "                                     0. 0. 0. 0. 0"
	    ".   0. 0. 0. 0.   0.29 )", (ftnlen)80, (ftnlen)74);
    s_copy(pck + 100320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 100400, "           BODY703_NUT_PREC_DEC  = ( 0. 0. 0. 0. 0."
	    , (ftnlen)80, (ftnlen)51);
    s_copy(pck + 100480, "                                     0. 0. 0. 0. 0"
	    ".   0. 0. 0. 0.   0.28 )", (ftnlen)80, (ftnlen)74);
    s_copy(pck + 100560, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 100640, "           BODY703_NUT_PREC_PM   = ( 0. 0. 0. 0. 0."
	    , (ftnlen)80, (ftnlen)51);
    s_copy(pck + 100720, "                                     0. 0. 0. 0. 0"
	    ".   0. 0. 0. 0.   0.08 )", (ftnlen)80, (ftnlen)74);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 100800, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 100880, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 100960, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 101040, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 101120, "     Oberon", (ftnlen)80, (ftnlen)11);
    s_copy(pck + 101200, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 101280, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 101360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 101440, "           Values are unchanged in the 2000 IAU re"
	    "port.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 101520, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 101600, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 101680, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 101760, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 101840, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 101920, "           BODY704_POLE_RA       = (  257.43    0."
	    "          0. )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 102000, "           BODY704_POLE_DEC      = (  -15.10    0."
	    "          0. )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 102080, "           BODY704_PM            = (    6.77  -26."
	    "7394932   0. )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 102160, "           BODY704_LONG_AXIS     = (    0.        "
	    "             )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 102240, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 102320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 102400, "           BODY704_NUT_PREC_RA   = ( 0. 0. 0. 0. 0."
	    , (ftnlen)80, (ftnlen)51);
    s_copy(pck + 102480, "                                     0. 0. 0. 0. 0."
	    , (ftnlen)80, (ftnlen)51);
    s_copy(pck + 102560, "                                     0. 0. 0. 0. 0"
	    ".   0.16 )", (ftnlen)80, (ftnlen)60);
    s_copy(pck + 102640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 102720, "           BODY704_NUT_PREC_DEC  = ( 0. 0. 0. 0. 0."
	    , (ftnlen)80, (ftnlen)51);
    s_copy(pck + 102800, "                                     0. 0. 0. 0. 0."
	    , (ftnlen)80, (ftnlen)51);
    s_copy(pck + 102880, "                                     0. 0. 0. 0. 0"
	    ".   0.16 )", (ftnlen)80, (ftnlen)60);
    s_copy(pck + 102960, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 103040, "           BODY704_NUT_PREC_PM   = ( 0. 0. 0. 0. 0."
	    , (ftnlen)80, (ftnlen)51);
    s_copy(pck + 103120, "                                     0. 0. 0. 0. 0."
	    , (ftnlen)80, (ftnlen)51);
    s_copy(pck + 103200, "                                     0. 0. 0. 0. 0"
	    ".   0.04 )", (ftnlen)80, (ftnlen)60);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 103280, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 103360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 103440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 103520, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 103600, "     Miranda", (ftnlen)80, (ftnlen)12);
    s_copy(pck + 103680, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 103760, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 103840, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 103920, "           Values are unchanged in the 2000 IAU re"
	    "port.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 104000, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 104080, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 104160, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 104240, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 104320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 104400, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 104480, "           BODY705_POLE_RA      = (  257.43     0."
	    "         0. )", (ftnlen)80, (ftnlen)63);
    s_copy(pck + 104560, "           BODY705_POLE_DEC     = (  -15.08     0."
	    "         0. )", (ftnlen)80, (ftnlen)63);
    s_copy(pck + 104640, "           BODY705_PM           = (   30.70  -254."
	    "6906892  0. )", (ftnlen)80, (ftnlen)63);
    s_copy(pck + 104720, "           BODY705_LONG_AXIS    = (    0.         "
	    "            )", (ftnlen)80, (ftnlen)63);
    s_copy(pck + 104800, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 104880, "           BODY705_NUT_PREC_RA  = ( 0.     0.     "
	    "0.    0.    0.", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 104960, "                                    0.     0.     "
	    "0.    0.    0.", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 105040, "                                    4.41   0.     "
	    "0.    0.    0.", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 105120, "                                    0.    -0.04   "
	    "0.             )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 105200, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 105280, "           BODY705_NUT_PREC_DEC = ( 0.     0.     "
	    "0.    0.    0.", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 105360, "                                    0.     0.     "
	    "0.    0.    0.", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 105440, "                                    4.25   0.     "
	    "0.    0.    0.", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 105520, "                                    0.    -0.02   "
	    "0.             )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 105600, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 105680, "           BODY705_NUT_PREC_PM  = ( 0.     0.     "
	    "0.    0.    0.", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 105760, "                                    0.     0.     "
	    "0.    0.    0.", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 105840, "                                    1.15  -1.27   "
	    "0.    0.    0.", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 105920, "                                    0.    -0.09   "
	    "0.15           )", (ftnlen)80, (ftnlen)66);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 106000, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 106080, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 106160, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 106240, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 106320, "     Cordelia", (ftnlen)80, (ftnlen)13);
    s_copy(pck + 106400, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 106480, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 106560, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 106640, "           Values are unchanged in the 2000 IAU re"
	    "port.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 106720, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 106800, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 106880, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 106960, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 107040, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 107120, "           BODY706_POLE_RA      = (   257.31      "
	    "0.         0.  )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 107200, "           BODY706_POLE_DEC     = (   -15.18      "
	    "0.         0.  )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 107280, "           BODY706_PM           = (   127.69  -107"
	    "4.5205730  0.  )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 107360, "           BODY706_LONG_AXIS    = (     0.        "
	    "               )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 107440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 107520, "           BODY706_NUT_PREC_RA  = (   -0.15    0. "
	    "    0.    0.    0.", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 107600, "                                       0.      0. "
	    "    0.    0.    0.", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 107680, "                                       0.      0. "
	    "    0.    0.    0.", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 107760, "                                       0.      0. "
	    "    0.             )", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 107840, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 107920, "           BODY706_NUT_PREC_DEC = (    0.14    0. "
	    "    0.    0.    0.", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 108000, "                                       0.      0. "
	    "    0.    0.    0.", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 108080, "                                       0.      0. "
	    "    0.    0.    0.", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 108160, "                                       0.      0. "
	    "    0.             )", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 108240, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 108320, "           BODY706_NUT_PREC_PM  = (   -0.04    0. "
	    "    0.    0.    0.", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 108400, "                                       0.      0. "
	    "    0.    0.    0.", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 108480, "                                       0.      0. "
	    "    0.    0.    0.", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 108560, "                                       0.      0. "
	    "    0.             )", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 108640, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 108720, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 108800, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 108880, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 108960, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 109040, "     Ophelia", (ftnlen)80, (ftnlen)12);
    s_copy(pck + 109120, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 109200, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 109280, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 109360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 109440, "           Values are unchanged in the 2000 IAU re"
	    "port.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 109520, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 109600, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 109680, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 109760, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 109840, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 109920, "           BODY707_POLE_RA      = (  257.31     0."
	    "         0. )", (ftnlen)80, (ftnlen)63);
    s_copy(pck + 110000, "           BODY707_POLE_DEC     = (  -15.18     0."
	    "         0. )", (ftnlen)80, (ftnlen)63);
    s_copy(pck + 110080, "           BODY707_PM           = (  130.35  -956."
	    "4068150  0. )", (ftnlen)80, (ftnlen)63);
    s_copy(pck + 110160, "           BODY707_LONG_AXIS    = (    0.         "
	    "            )", (ftnlen)80, (ftnlen)63);
    s_copy(pck + 110240, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 110320, "           BODY707_NUT_PREC_RA  = (    0.     -0.0"
	    "9   0.    0.    0.", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 110400, "                                       0.      0. "
	    "    0.    0.    0.", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 110480, "                                       0.      0. "
	    "    0.    0.    0.", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 110560, "                                       0.      0. "
	    "    0.             )", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 110640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 110720, "           BODY707_NUT_PREC_DEC = (    0.      0.0"
	    "9   0.    0.    0.", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 110800, "                                       0.      0. "
	    "    0.    0.    0.", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 110880, "                                       0.      0. "
	    "    0.    0.    0.", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 110960, "                                       0.      0. "
	    "    0.             )", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 111040, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 111120, "           BODY707_NUT_PREC_PM  = (    0.     -0.0"
	    "3   0.    0.    0.", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 111200, "                                       0.      0. "
	    "    0.    0.    0.", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 111280, "                                       0.      0. "
	    "    0.    0.    0.", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 111360, "                                       0.      0. "
	    "    0.             )", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 111440, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 111520, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 111600, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 111680, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 111760, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 111840, "     Bianca", (ftnlen)80, (ftnlen)11);
    s_copy(pck + 111920, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 112000, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 112080, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 112160, "           Values are unchanged in the 2000 IAU re"
	    "port.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 112240, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 112320, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 112400, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 112480, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 112560, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 112640, "           BODY708_POLE_RA      = (  257.31     0."
	    "         0.  )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 112720, "           BODY708_POLE_DEC     = (  -15.18     0."
	    "         0.  )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 112800, "           BODY708_PM           = (  105.46  -828."
	    "3914760  0.  )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 112880, "           BODY708_LONG_AXIS    = (    0.         "
	    "             )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 112960, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 113040, "           BODY708_NUT_PREC_RA  = (    0.      0. "
	    "   -0.16    0.    0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 113120, "                                       0.      0. "
	    "    0.      0.    0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 113200, "                                       0.      0. "
	    "    0.      0.    0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 113280, "                                       0.      0. "
	    "    0.               )", (ftnlen)80, (ftnlen)72);
    s_copy(pck + 113360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 113440, "           BODY708_NUT_PREC_DEC = (    0.      0. "
	    "    0.16    0.    0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 113520, "                                       0.      0. "
	    "    0.      0.    0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 113600, "                                       0.      0. "
	    "    0.      0.    0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 113680, "                                       0.      0. "
	    "    0.               )", (ftnlen)80, (ftnlen)72);
    s_copy(pck + 113760, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 113840, "           BODY708_NUT_PREC_PM  = (    0.      0. "
	    "   -0.04    0.    0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 113920, "                                       0.      0. "
	    "    0.      0.    0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 114000, "                                       0.      0. "
	    "    0.      0.    0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 114080, "                                       0.      0. "
	    "    0.               )", (ftnlen)80, (ftnlen)72);
    s_copy(pck + 114160, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 114240, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 114320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 114400, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 114480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 114560, "     Cressida", (ftnlen)80, (ftnlen)13);
    s_copy(pck + 114640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 114720, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 114800, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 114880, "           Values are unchanged in the 2000 IAU re"
	    "port.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 114960, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 115040, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 115120, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 115200, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 115280, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 115360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 115440, "           BODY709_POLE_RA      = (  257.31      0"
	    ".          0.  )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 115520, "           BODY709_POLE_DEC     = (  -15.18      0"
	    ".          0.  )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 115600, "           BODY709_PM           = (   59.16   -776"
	    ".5816320   0.  )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 115680, "           BODY709_LONG_AXIS    = (    0.         "
	    "               )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 115760, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 115840, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 115920, "           BODY709_NUT_PREC_RA  = (    0.      0. "
	    "    0.     -0.04   0.", (ftnlen)80, (ftnlen)71);
    s_copy(pck + 116000, "                                       0.      0. "
	    "    0.      0.     0.", (ftnlen)80, (ftnlen)71);
    s_copy(pck + 116080, "                                       0.      0. "
	    "    0.      0.     0.", (ftnlen)80, (ftnlen)71);
    s_copy(pck + 116160, "                                       0.      0. "
	    "    0.                )", (ftnlen)80, (ftnlen)73);
    s_copy(pck + 116240, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 116320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 116400, "           BODY709_NUT_PREC_DEC = (    0.      0. "
	    "    0.      0.04   0.", (ftnlen)80, (ftnlen)71);
    s_copy(pck + 116480, "                                       0.      0. "
	    "    0.      0.     0.", (ftnlen)80, (ftnlen)71);
    s_copy(pck + 116560, "                                       0.      0. "
	    "    0.      0.     0.", (ftnlen)80, (ftnlen)71);
    s_copy(pck + 116640, "                                       0.      0. "
	    "    0.                )", (ftnlen)80, (ftnlen)73);
    s_copy(pck + 116720, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 116800, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 116880, "           BODY709_NUT_PREC_PM  = (    0.      0. "
	    "    0.     -0.01   0.", (ftnlen)80, (ftnlen)71);
    s_copy(pck + 116960, "                                       0.      0. "
	    "    0.      0.     0.", (ftnlen)80, (ftnlen)71);
    s_copy(pck + 117040, "                                       0.      0. "
	    "    0.      0.     0.", (ftnlen)80, (ftnlen)71);
    s_copy(pck + 117120, "                                       0.      0. "
	    "    0.                )", (ftnlen)80, (ftnlen)73);
    s_copy(pck + 117200, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 117280, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 117360, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 117440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 117520, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 117600, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 117680, "     Desdemona", (ftnlen)80, (ftnlen)14);
    s_copy(pck + 117760, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 117840, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 117920, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 118000, "           Values are unchanged in the 2000 IAU re"
	    "port.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 118080, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 118160, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 118240, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 118320, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 118400, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 118480, "           BODY710_POLE_RA      = ( 257.31      0."
	    "           0.  )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 118560, "           BODY710_POLE_DEC     = ( -15.18      0."
	    "           0.  )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 118640, "           BODY710_PM           = (  95.08   -760."
	    "0531690    0.  )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 118720, "           BODY710_LONG_AXIS    = (   0.          "
	    "               )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 118800, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 118880, "           BODY710_NUT_PREC_RA  = (   0.      0.  "
	    "   0.      0.    -0.17", (ftnlen)80, (ftnlen)72);
    s_copy(pck + 118960, "                                      0.      0.  "
	    "   0.      0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 119040, "                                      0.      0.  "
	    "   0.      0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 119120, "                                      0.      0.  "
	    "   0.                  )", (ftnlen)80, (ftnlen)74);
    s_copy(pck + 119200, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 119280, "           BODY710_NUT_PREC_DEC = (   0.      0.  "
	    "   0.      0.     0.16", (ftnlen)80, (ftnlen)72);
    s_copy(pck + 119360, "                                      0.      0.  "
	    "   0.      0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 119440, "                                      0.      0.  "
	    "   0.      0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 119520, "                                      0.      0.  "
	    "   0.                  )", (ftnlen)80, (ftnlen)74);
    s_copy(pck + 119600, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 119680, "           BODY710_NUT_PREC_PM  = (   0.      0.  "
	    "   0.      0.    -0.04", (ftnlen)80, (ftnlen)72);
    s_copy(pck + 119760, "                                      0.      0.  "
	    "   0.      0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 119840, "                                      0.      0.  "
	    "   0.      0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 119920, "                                      0.      0.  "
	    "   0.                 )", (ftnlen)80, (ftnlen)73);
    s_copy(pck + 120000, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 120080, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 120160, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 120240, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 120320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 120400, "     Juliet", (ftnlen)80, (ftnlen)11);
    s_copy(pck + 120480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 120560, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 120640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 120720, "           Values are unchanged in the 2000 IAU re"
	    "port.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 120800, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 120880, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 120960, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 121040, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 121120, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 121200, "           BODY711_POLE_RA      = (  257.31     0."
	    "           0.   )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 121280, "           BODY711_POLE_DEC     = (  -15.18     0."
	    "           0.   )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 121360, "           BODY711_PM           = (  302.56  -730."
	    "1253660    0.   )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 121440, "           BODY711_LONG_AXIS    = (    0.         "
	    "                )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 121520, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 121600, "           BODY711_NUT_PREC_RA  = (   0.      0.  "
	    "   0.      0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 121680, "                                     -0.06    0.  "
	    "   0.      0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 121760, "                                      0.      0.  "
	    "   0.      0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 121840, "                                      0.      0.  "
	    "   0.                 )", (ftnlen)80, (ftnlen)73);
    s_copy(pck + 121920, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 122000, "           BODY711_NUT_PREC_DEC = (   0.      0.  "
	    "   0.      0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 122080, "                                      0.06    0.  "
	    "   0.      0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 122160, "                                      0.      0.  "
	    "   0.      0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 122240, "                                      0.      0.  "
	    "   0.                 )", (ftnlen)80, (ftnlen)73);
    s_copy(pck + 122320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 122400, "           BODY711_NUT_PREC_PM  = (   0.      0.  "
	    "   0.      0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 122480, "                                     -0.02    0.  "
	    "   0.      0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 122560, "                                      0.      0.  "
	    "   0.      0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 122640, "                                      0.      0.  "
	    "   0.                 )", (ftnlen)80, (ftnlen)73);
    s_copy(pck + 122720, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 122800, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 122880, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 122960, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 123040, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 123120, "     Portia", (ftnlen)80, (ftnlen)11);
    s_copy(pck + 123200, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 123280, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 123360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 123440, "           Values are unchanged in the 2000 IAU re"
	    "port.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 123520, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 123600, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 123680, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 123760, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 123840, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 123920, "           BODY712_POLE_RA      = (  257.31      0"
	    ".           0.   )", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 124000, "           BODY712_POLE_DEC     = (  -15.18      0"
	    ".           0.   )", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 124080, "           BODY712_PM           = (   25.03   -701"
	    ".4865870    0.   )", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 124160, "           BODY712_LONG_AXIS    = (    0.         "
	    "                 )", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 124240, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 124320, "           BODY712_NUT_PREC_RA  = (   0.      0.  "
	    "   0.      0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 124400, "                                      0.     -0.09"
	    "   0.      0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 124480, "                                      0.      0.  "
	    "   0.      0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 124560, "                                      0.      0.  "
	    "   0.                )", (ftnlen)80, (ftnlen)72);
    s_copy(pck + 124640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 124720, "           BODY712_NUT_PREC_DEC = (   0.      0.  "
	    "   0.      0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 124800, "                                      0.      0.09"
	    "   0.      0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 124880, "                                      0.      0.  "
	    "   0.      0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 124960, "                                      0.      0.  "
	    "   0.               )", (ftnlen)80, (ftnlen)71);
    s_copy(pck + 125040, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 125120, "           BODY712_NUT_PREC_PM  = (   0.      0.  "
	    "   0.      0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 125200, "                                      0.     -0.02"
	    "   0.      0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 125280, "                                      0.      0.  "
	    "   0.      0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 125360, "                                      0.      0.  "
	    "   0.               )", (ftnlen)80, (ftnlen)71);
    s_copy(pck + 125440, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 125520, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 125600, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 125680, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 125760, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 125840, "     Rosalind", (ftnlen)80, (ftnlen)13);
    s_copy(pck + 125920, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 126000, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 126080, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 126160, "           Values are unchanged in the 2000 IAU re"
	    "port.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 126240, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 126320, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 126400, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 126480, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 126560, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 126640, "           BODY713_POLE_RA      = ( 257.31      0."
	    "          0.  )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 126720, "           BODY713_POLE_DEC     = ( -15.18      0."
	    "          0.  )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 126800, "           BODY713_PM           = ( 314.90   -644."
	    "6311260   0.  )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 126880, "           BODY713_LONG_AXIS    = (   0.          "
	    "              )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 126960, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 127040, "           BODY713_NUT_PREC_RA  = (   0.      0.  "
	    "   0.      0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 127120, "                                      0.      0.  "
	    "  -0.29    0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 127200, "                                      0.      0.  "
	    "   0.      0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 127280, "                                      0.      0.  "
	    "   0.               )", (ftnlen)80, (ftnlen)71);
    s_copy(pck + 127360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 127440, "           BODY713_NUT_PREC_DEC = (   0.      0.  "
	    "   0.      0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 127520, "                                      0.      0.  "
	    "   0.28    0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 127600, "                                      0.      0.  "
	    "   0.      0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 127680, "                                      0.      0.  "
	    "   0.              )", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 127760, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 127840, "           BODY713_NUT_PREC_PM  = (   0.      0.  "
	    "   0.      0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 127920, "                                      0.      0.  "
	    "  -0.08    0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 128000, "                                      0.      0.  "
	    "   0.      0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 128080, "                                      0.      0.  "
	    "   0.              )", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 128160, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 128240, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 128320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 128400, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 128480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 128560, "     Belinda", (ftnlen)80, (ftnlen)12);
    s_copy(pck + 128640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 128720, "       Old values:", (ftnlen)80, (ftnlen)18);
    s_copy(pck + 128800, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 128880, "           Values are unchanged in the 2000 IAU re"
	    "port.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 128960, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 129040, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 129120, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 129200, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 129280, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 129360, "           BODY714_POLE_RA      = (   257.31      "
	    "0.         0. )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 129440, "           BODY714_POLE_DEC     = (   -15.18      "
	    "0.         0. )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 129520, "           BODY714_PM           = (   297.46   -57"
	    "7.3628170  0. )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 129600, "           BODY714_LONG_AXIS    = (     0.        "
	    "              )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 129680, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 129760, "           BODY714_NUT_PREC_RA  = (   0.      0.  "
	    "   0.      0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 129840, "                                      0.      0.  "
	    "   0.     -0.03   0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 129920, "                                      0.      0.  "
	    "   0.      0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 130000, "                                      0.      0.  "
	    "   0.                )", (ftnlen)80, (ftnlen)72);
    s_copy(pck + 130080, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 130160, "           BODY714_NUT_PREC_DEC = (   0.      0.  "
	    "   0.      0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 130240, "                                      0.      0.  "
	    "   0.      0.03   0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 130320, "                                      0.      0.  "
	    "   0.      0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 130400, "                                      0.      0.  "
	    "   0.                )", (ftnlen)80, (ftnlen)72);
    s_copy(pck + 130480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 130560, "           BODY714_NUT_PREC_PM  = (   0.      0.  "
	    "   0.      0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 130640, "                                      0.      0.  "
	    "   0.     -0.01   0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 130720, "                                      0.      0.  "
	    "   0.      0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 130800, "                                      0.      0.  "
	    "   0.                )", (ftnlen)80, (ftnlen)72);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 130880, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 130960, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 131040, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 131120, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 131200, "     Puck", (ftnlen)80, (ftnlen)9);
    s_copy(pck + 131280, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 131360, "       Old values:", (ftnlen)80, (ftnlen)18);
    s_copy(pck + 131440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 131520, "           Values are unchanged in the 2000 IAU re"
	    "port.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 131600, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 131680, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 131760, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 131840, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 131920, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 132000, "           BODY715_POLE_RA      = (  257.31      0"
	    ".         0.  )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 132080, "           BODY715_POLE_DEC     = (  -15.18      0"
	    ".         0.  )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 132160, "           BODY715_PM           = (   91.24   -472"
	    ".5450690  0.  )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 132240, "           BODY715_LONG_AXIS    = (    0.         "
	    "              )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 132320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 132400, "           BODY715_NUT_PREC_RA  = (   0.      0.  "
	    "   0.      0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 132480, "                                      0.      0.  "
	    "   0.      0.    -0.33", (ftnlen)80, (ftnlen)72);
    s_copy(pck + 132560, "                                      0.      0.  "
	    "   0.      0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 132640, "                                      0.      0.  "
	    "   0.                  )", (ftnlen)80, (ftnlen)74);
    s_copy(pck + 132720, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 132800, "           BODY715_NUT_PREC_DEC = (   0.      0.  "
	    "   0.      0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 132880, "                                      0.      0.  "
	    "   0.      0.     0.31", (ftnlen)80, (ftnlen)72);
    s_copy(pck + 132960, "                                      0.      0.  "
	    "   0.      0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 133040, "                                      0.      0.  "
	    "   0.                  )", (ftnlen)80, (ftnlen)74);
    s_copy(pck + 133120, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 133200, "           BODY715_NUT_PREC_PM  = (   0.      0.  "
	    "   0.      0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 133280, "                                      0.      0.  "
	    "   0.      0.    -0.09", (ftnlen)80, (ftnlen)72);
    s_copy(pck + 133360, "                                      0.      0.  "
	    "   0.      0.     0.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 133440, "                                      0.      0.  "
	    "   0.                  )", (ftnlen)80, (ftnlen)74);
    s_copy(pck + 133520, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 133600, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 133680, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 133760, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 133840, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 133920, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 134000, "Satellites of Neptune", (ftnlen)80, (ftnlen)21);
    s_copy(pck + 134080, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 134160, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 134240, "     Triton", (ftnlen)80, (ftnlen)11);
    s_copy(pck + 134320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 134400, "       Old values:", (ftnlen)80, (ftnlen)18);
    s_copy(pck + 134480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 134560, "           Values are unchanged in the 2000 IAU re"
	    "port.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 134640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 134720, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 134800, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 134880, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 134960, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 135040, "           BODY801_POLE_RA       = ( 299.36     0."
	    "         0.  )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 135120, "           BODY801_POLE_DEC      = (  41.17     0."
	    "         0.  )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 135200, "           BODY801_PM            = ( 296.53   -61."
	    "2572637  0.  )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 135280, "           BODY801_LONG_AXIS     = (   0.         "
	    "             )", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 135360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 135440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 135520, "           BODY801_NUT_PREC_RA   = (  0.      0.  "
	    "    0.      0.", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 135600, "                                      0.      0.  "
	    "    0.    -32.35", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 135680, "                                      0.     -6.28"
	    "   -2.08   -0.74", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 135760, "                                     -0.28   -0.11"
	    "   -0.07   -0.02", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 135840, "                                     -0.01        "
	    "                 )", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 135920, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 136000, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 136080, "           BODY801_NUT_PREC_DEC  = (  0.      0.  "
	    "    0.      0.", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 136160, "                                      0.      0.  "
	    "    0.     22.55", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 136240, "                                      0.      2.10"
	    "    0.55    0.16", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 136320, "                                      0.05    0.02"
	    "    0.01    0.", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 136400, "                                      0.          "
	    "                 )", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 136480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 136560, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 136640, "           BODY801_NUT_PREC_PM   = (  0.      0.  "
	    "    0.      0.", (ftnlen)80, (ftnlen)64);
    s_copy(pck + 136720, "                                      0.      0.  "
	    "    0.     22.25", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 136800, "                                      0.      6.73"
	    "    2.05    0.74", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 136880, "                                      0.28    0.11"
	    "    0.05    0.02", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 136960, "                                      0.01        "
	    "                 )", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 137040, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 137120, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 137200, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 137280, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 137360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 137440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 137520, "     Nereid", (ftnlen)80, (ftnlen)11);
    s_copy(pck + 137600, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 137680, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 137760, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 137840, "           Values are from the 1988 IAU report.", (
	    ftnlen)80, (ftnlen)47);
    s_copy(pck + 137920, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 138000, "           body802_pole_ra       = (    273.48    "
	    "0.        0.  )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 138080, "           body802_pole_dec      = (     67.22    "
	    "0.        0.  )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 138160, "           body802_pm            = (    237.22    "
	    "0.9996465 0.  )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 138240, "           body802_long_axis     = (      0.      "
	    "              )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 138320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 138400, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 138480, "           The report seems to have a typo:  in th"
	    "e nut_prec_ra expression,", (ftnlen)80, (ftnlen)75);
    s_copy(pck + 138560, "           where the report gives  -0.51 sin 3N3, "
	    "we use -0.51 3N2.", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 138640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 138720, "           body802_nut_prec_ra   = (  0.    -17.81",
	     (ftnlen)80, (ftnlen)50);
    s_copy(pck + 138800, "                                      0.      0.  "
	    "   0.      0.", (ftnlen)80, (ftnlen)63);
    s_copy(pck + 138880, "                                      0.      0.  "
	    "   0.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 138960, "                                      2.56   -0.51"
	    "   0.11   -0.03  )", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 139040, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 139120, "           body802_nut_prec_dec  = (  0.     -6.67",
	     (ftnlen)80, (ftnlen)50);
    s_copy(pck + 139200, "                                      0.      0.  "
	    "   0.      0.", (ftnlen)80, (ftnlen)63);
    s_copy(pck + 139280, "                                      0.      0.  "
	    "   0.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 139360, "                                      0.47   -0.07"
	    "   0.01          )", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 139440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 139520, "           body802_nut_prec_pm   = (  0.     16.48",
	     (ftnlen)80, (ftnlen)50);
    s_copy(pck + 139600, "                                      0.      0.  "
	    "   0.      0.", (ftnlen)80, (ftnlen)63);
    s_copy(pck + 139680, "                                      0.      0.  "
	    "   0.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 139760, "                                     -2.57    0.51"
	    " -0.11    0.02  )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 139840, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 139920, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 140000, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 140080, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 140160, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 140240, "           The 2000 report does not give values fo"
	    "r Nereid.  In order", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 140320, "           to obtain rotational elements for Nerei"
	    "d, a separate PCK", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 140400, "           file must be loaded.", (ftnlen)80, (
	    ftnlen)31);
    s_copy(pck + 140480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 140560, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 140640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 140720, "     Naiad", (ftnlen)80, (ftnlen)10);
    s_copy(pck + 140800, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 140880, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 140960, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 141040, "           Values are unchanged in the 2000 IAU re"
	    "port.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 141120, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 141200, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 141280, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 141360, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 141440, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 141520, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 141600, "           BODY803_POLE_RA       = (  299.36      "
	    "0.          0.  )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 141680, "           BODY803_POLE_DEC      = (   43.36      "
	    "0.          0.  )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 141760, "           BODY803_PM            = (  254.06  +122"
	    "2.8441209   0.  )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 141840, "           BODY803_LONG_AXIS     = (    0.        "
	    "                )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 141920, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 142000, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 142080, "           BODY803_NUT_PREC_RA   = (    0.70     -"
	    "6.49     0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 142160, "                                        0.        "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 142240, "                                        0.25      "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 142320, "                                        0.        "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 142400, "                                        0.        "
	    "                    )", (ftnlen)80, (ftnlen)71);
    s_copy(pck + 142480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 142560, "           BODY803_NUT_PREC_DEC  = (   -0.51     -"
	    "4.75     0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 142640, "                                        0.        "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 142720, "                                        0.09      "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 142800, "                                        0.        "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 142880, "                                        0.        "
	    "                    )", (ftnlen)80, (ftnlen)71);
    s_copy(pck + 142960, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 143040, "           BODY803_NUT_PREC_PM   = (   -0.48      "
	    "4.40     0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 143120, "                                        0.        "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 143200, "                                       -0.27      "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 143280, "                                        0.        "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 143360, "                                        0.        "
	    "                    )", (ftnlen)80, (ftnlen)71);
    s_copy(pck + 143440, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 143520, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 143600, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 143680, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 143760, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 143840, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 143920, "     Thalassa", (ftnlen)80, (ftnlen)13);
    s_copy(pck + 144000, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 144080, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 144160, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 144240, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 144320, "           Values are unchanged in the 2000 IAU re"
	    "port.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 144400, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 144480, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 144560, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 144640, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 144720, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 144800, "           BODY804_POLE_RA       = (  299.36      "
	    "0.          0. )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 144880, "           BODY804_POLE_DEC      = (   43.45      "
	    "0.          0. )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 144960, "           BODY804_PM            = (  102.06   115"
	    "5.7555612   0. )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 145040, "           BODY804_LONG_AXIS     = (    0.        "
	    "               )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 145120, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 145200, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 145280, "           BODY804_NUT_PREC_RA   = (    0.70      "
	    "0.      -0.28    0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 145360, "                                        0.        "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 145440, "                                        0.        "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 145520, "                                        0.        "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 145600, "                                        0.        "
	    "                     )", (ftnlen)80, (ftnlen)72);
    s_copy(pck + 145680, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 145760, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 145840, "           BODY804_NUT_PREC_DEC  = (   -0.51      "
	    "0.      -0.21    0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 145920, "                                        0.        "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 146000, "                                        0.        "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 146080, "                                        0.        "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 146160, "                                        0.        "
	    "                     )", (ftnlen)80, (ftnlen)72);
    s_copy(pck + 146240, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 146320, "           BODY804_NUT_PREC_PM   = (   -0.48      "
	    "0.       0.19    0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 146400, "                                        0.        "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 146480, "                                        0.        "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 146560, "                                        0.        "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 146640, "                                        0.        "
	    "                     )", (ftnlen)80, (ftnlen)72);
    s_copy(pck + 146720, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 146800, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 146880, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 146960, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 147040, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 147120, "     Despina", (ftnlen)80, (ftnlen)12);
    s_copy(pck + 147200, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 147280, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 147360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 147440, "           Values are unchanged in the 2000 IAU re"
	    "port.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 147520, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 147600, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 147680, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 147760, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 147840, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 147920, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 148000, "           BODY805_POLE_RA       = (  299.36      "
	    "0.          0. )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 148080, "           BODY805_POLE_DEC      = (   43.45      "
	    "0.          0. )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 148160, "           BODY805_PM            = (  306.51  +107"
	    "5.7341562   0. )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 148240, "           BODY805_LONG_AXIS     = (    0.        "
	    "               )", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 148320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 148400, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 148480, "           BODY805_NUT_PREC_RA   = (    0.70      "
	    "0.       0.     -0.09", (ftnlen)80, (ftnlen)71);
    s_copy(pck + 148560, "                                        0.        "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 148640, "                                        0.        "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 148720, "                                        0.        "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 148800, "                                        0.        "
	    "                      )", (ftnlen)80, (ftnlen)73);
    s_copy(pck + 148880, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 148960, "           BODY805_NUT_PREC_DEC  = (   -0.51      "
	    "0.       0.     -0.07", (ftnlen)80, (ftnlen)71);
    s_copy(pck + 149040, "                                        0.        "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 149120, "                                        0.        "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 149200, "                                        0.        "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 149280, "                                        0.        "
	    "                      )", (ftnlen)80, (ftnlen)73);
    s_copy(pck + 149360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 149440, "           BODY805_NUT_PREC_PM   = (   -0.49      "
	    "0.       0.      0.06", (ftnlen)80, (ftnlen)71);
    s_copy(pck + 149520, "                                        0.        "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 149600, "                                        0.        "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 149680, "                                        0.        "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 149760, "                                        0.        "
	    "                      )", (ftnlen)80, (ftnlen)73);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 149840, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 149920, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 150000, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 150080, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 150160, "     Galatea", (ftnlen)80, (ftnlen)12);
    s_copy(pck + 150240, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 150320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 150400, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 150480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 150560, "           Values are unchanged in the 2000 IAU re"
	    "port.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 150640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 150720, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 150800, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 150880, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 150960, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 151040, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 151120, "           BODY806_POLE_RA       = (   299.36     "
	    " 0.          0. )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 151200, "           BODY806_POLE_DEC      = (    43.43     "
	    " 0.          0. )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 151280, "           BODY806_PM            = (   258.09    8"
	    "39.6597686   0. )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 151360, "           BODY806_LONG_AXIS     = (     0.       "
	    "                )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 151440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 151520, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 151600, "           BODY806_NUT_PREC_RA   = (    0.70      "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 151680, "                                       -0.07      "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 151760, "                                        0.        "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 151840, "                                        0.        "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 151920, "                                        0.        "
	    "                     )", (ftnlen)80, (ftnlen)72);
    s_copy(pck + 152000, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 152080, "           BODY806_NUT_PREC_DEC  = (   -0.51      "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 152160, "                                       -0.05      "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 152240, "                                        0.        "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 152320, "                                        0.        "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 152400, "                                        0.        "
	    "                     )", (ftnlen)80, (ftnlen)72);
    s_copy(pck + 152480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 152560, "           BODY806_NUT_PREC_PM   = (   -0.48      "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 152640, "                                        0.05      "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 152720, "                                        0.        "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 152800, "                                        0.        "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 152880, "                                        0.        "
	    "                     )", (ftnlen)80, (ftnlen)72);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 152960, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 153040, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 153120, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 153200, "     Larissa", (ftnlen)80, (ftnlen)12);
    s_copy(pck + 153280, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 153360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 153440, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 153520, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 153600, "           Values are unchanged in the 2000 IAU re"
	    "port.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 153680, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 153760, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 153840, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 153920, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 154000, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 154080, "           BODY807_POLE_RA       = (   299.36     "
	    "0.           0. )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 154160, "           BODY807_POLE_DEC      = (    43.41     "
	    "0.           0. )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 154240, "           BODY807_PM            = (   179.41  +64"
	    "9.0534470    0. )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 154320, "           BODY807_LONG_AXIS     = (     0.       "
	    "                )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 154400, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 154480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 154560, "           BODY807_NUT_PREC_RA   = (    0.70      "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 154640, "                                        0.       -"
	    "0.27     0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 154720, "                                        0.        "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 154800, "                                        0.        "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 154880, "                                        0.        "
	    "                    )", (ftnlen)80, (ftnlen)71);
    s_copy(pck + 154960, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 155040, "           BODY807_NUT_PREC_DEC  = (   -0.51      "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 155120, "                                        0.       -"
	    "0.20     0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 155200, "                                        0.        "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 155280, "                                        0.        "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 155360, "                                        0.        "
	    "                    )", (ftnlen)80, (ftnlen)71);
    s_copy(pck + 155440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 155520, "           BODY807_NUT_PREC_PM   = (   -0.48      "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 155600, "                                        0.        "
	    "0.19     0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 155680, "                                        0.        "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 155760, "                                        0.        "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 155840, "                                        0.        "
	    "                    )", (ftnlen)80, (ftnlen)71);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 155920, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 156000, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 156080, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 156160, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 156240, "     Proteus", (ftnlen)80, (ftnlen)12);
    s_copy(pck + 156320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 156400, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 156480, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 156560, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 156640, "           Values are unchanged in the 2000 IAU re"
	    "port.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 156720, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 156800, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 156880, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 156960, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 157040, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 157120, "           BODY808_POLE_RA       = (  299.27      "
	    "0.          0.  )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 157200, "           BODY808_POLE_DEC      = (   42.91      "
	    "0.          0.  )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 157280, "           BODY808_PM            = (   93.38   +32"
	    "0.7654228   0.  )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 157360, "           BODY808_LONG_AXIS     = (    0.        "
	    "                )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 157440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 157520, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 157600, "           BODY808_NUT_PREC_RA   = (    0.70      "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 157680, "                                        0.        "
	    "0.      -0.05    0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 157760, "                                        0.        "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 157840, "                                        0.        "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 157920, "                                        0.        "
	    "                     )", (ftnlen)80, (ftnlen)72);
    s_copy(pck + 158000, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 158080, "           BODY808_NUT_PREC_DEC  = (   -0.51      "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 158160, "                                        0.        "
	    "0.      -0.04    0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 158240, "                                        0.        "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 158320, "                                        0.        "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 158400, "                                        0.        "
	    "                     )", (ftnlen)80, (ftnlen)72);
    s_copy(pck + 158480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 158560, "           BODY808_NUT_PREC_PM   = (   -0.48      "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 158640, "                                        0.        "
	    "0.       0.04    0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 158720, "                                        0.        "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 158800, "                                        0.        "
	    "0.       0.      0.", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 158880, "                                        0.        "
	    "                     )", (ftnlen)80, (ftnlen)72);
    s_copy(pck + 158960, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 159040, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 159120, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 159200, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 159280, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 159360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 159440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 159520, "Satellites of Pluto", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 159600, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 159680, "     Charon", (ftnlen)80, (ftnlen)11);
    s_copy(pck + 159760, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 159840, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 159920, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 160000, "           Values are unchanged in the 2000 IAU re"
	    "port.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 160080, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 160160, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 160240, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 160320, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 160400, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 160480, "           BODY901_POLE_RA       = (   313.02     "
	    "0.         0. )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 160560, "           BODY901_POLE_DEC      = (     9.09     "
	    "0.         0. )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 160640, "           BODY901_PM            = (    56.77   -5"
	    "6.3623195  0. )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 160720, "           BODY901_LONG_AXIS     = (     0.       "
	    "              )", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 160800, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 160880, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 160960, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 161040, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 161120, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 161200, "Orientation constants for Asteroids Gaspra and Ida",
	     (ftnlen)80, (ftnlen)50);
    s_copy(pck + 161280, "--------------------------------------------------"
	    "------", (ftnlen)80, (ftnlen)56);
    s_copy(pck + 161360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 161440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 161520, "Gaspra", (ftnlen)80, (ftnlen)6);
    s_copy(pck + 161600, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 161680, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 161760, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 161840, "           Values are unchanged in the 2000 IAU re"
	    "port.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 161920, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 162000, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 162080, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 162160, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 162240, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 162320, "           BODY9511010_POLE_RA       = (   9.47   "
	    "  0.         0. )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 162400, "           BODY9511010_POLE_DEC      = (  26.70   "
	    "  0.         0. )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 162480, "           BODY9511010_PM            = (  83.67  1"
	    "226.9114850  0. )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 162560, "           BODY9511010_LONG_AXIS     = (   0.     "
	    "                )", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 162640, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 162720, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 162800, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 162880, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 162960, "Ida", (ftnlen)80, (ftnlen)3);
    s_copy(pck + 163040, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 163120, "        Old values:", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 163200, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 163280, "           Values are unchanged in the 2000 IAU re"
	    "port.", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 163360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 163440, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 163520, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 163600, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 163680, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 163760, "           BODY2431010_POLE_RA       = (  348.76  "
	    "    0.         0. )", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 163840, "           BODY2431010_POLE_DEC      = (   87.12  "
	    "    0.         0. )", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 163920, "           BODY2431010_PM            = (  265.95  "
	    "-1864.6280070  0. )", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 164000, "           BODY2431010_LONG_AXIS     = (    0.    "
	    "                  )", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 164080, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 164160, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 164240, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 164320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 164400, "Vesta", (ftnlen)80, (ftnlen)5);
    s_copy(pck + 164480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 164560, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 164640, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 164720, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 164800, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 164880, "           BODY2000004_POLE_RA       = (   301.   "
	    "   0.         0.  )", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 164960, "           BODY2000004_POLE_DEC      = (    41.   "
	    "   0.         0.  )", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 165040, "           BODY2000004_PM            = (   292.   "
	    "1617.332776   0.  )", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 165120, "           BODY2000004_LONG_AXIS     = (     0.   "
	    "                  )", (ftnlen)80, (ftnlen)69);
    s_copy(pck + 165200, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 165280, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 165360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 165440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 165520, "Eros", (ftnlen)80, (ftnlen)4);
    s_copy(pck + 165600, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 165680, "        Current values:", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 165760, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 165840, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 165920, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 166000, "           BODY2000433_POLE_RA       = (   11.35  "
	    "     0.           0. )", (ftnlen)80, (ftnlen)72);
    s_copy(pck + 166080, "           BODY2000433_POLE_DEC      = (   17.22  "
	    "     0.           0. )", (ftnlen)80, (ftnlen)72);
    s_copy(pck + 166160, "           BODY2000433_PM            = (  326.07  "
	    "  1639.38864745   0. )", (ftnlen)80, (ftnlen)72);
    s_copy(pck + 166240, "           BODY2000433_LONG_AXIS     = (    0.    "
	    "                     )", (ftnlen)80, (ftnlen)72);
    s_copy(pck + 166320, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 166400, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 166480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 166560, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 166640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 166720, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 166800, "Radii of Sun and Planets", (ftnlen)80, (ftnlen)24);
    s_copy(pck + 166880, "--------------------------------------------------"
	    "------", (ftnlen)80, (ftnlen)56);
    s_copy(pck + 166960, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 167040, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 167120, "Sun", (ftnlen)80, (ftnlen)3);
    s_copy(pck + 167200, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 167280, "     Value for the Sun is from the [2], page K7.", (
	    ftnlen)80, (ftnlen)48);
    s_copy(pck + 167360, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 167440, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 167520, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 167600, "        BODY10_RADII      = (   696000.     696000"
	    ".      696000.     )", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 167680, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 167760, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 167840, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 167920, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 168000, "Mercury", (ftnlen)80, (ftnlen)7);
    s_copy(pck + 168080, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 168160, "     Old values:", (ftnlen)80, (ftnlen)16);
    s_copy(pck + 168240, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 168320, "        Values are unchanged in the 2000 IAU repor"
	    "t.", (ftnlen)80, (ftnlen)52);
    s_copy(pck + 168400, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 168480, "     Current values:", (ftnlen)80, (ftnlen)20);
    s_copy(pck + 168560, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 168640, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 168720, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 168800, "        BODY199_RADII     = ( 2439.7   2439.7   24"
	    "39.7 )", (ftnlen)80, (ftnlen)56);
    s_copy(pck + 168880, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 168960, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 169040, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 169120, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 169200, "Venus", (ftnlen)80, (ftnlen)5);
    s_copy(pck + 169280, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 169360, "     Old values:", (ftnlen)80, (ftnlen)16);
    s_copy(pck + 169440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 169520, "        Values are unchanged in the 2000 IAU repor"
	    "t.", (ftnlen)80, (ftnlen)52);
    s_copy(pck + 169600, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 169680, "     Current values:", (ftnlen)80, (ftnlen)20);
    s_copy(pck + 169760, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 169840, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 169920, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 170000, "        BODY299_RADII     = ( 6051.8   6051.8   60"
	    "51.8 )", (ftnlen)80, (ftnlen)56);
    s_copy(pck + 170080, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 170160, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 170240, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 170320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 170400, "Earth", (ftnlen)80, (ftnlen)5);
    s_copy(pck + 170480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 170560, "     Old values:", (ftnlen)80, (ftnlen)16);
    s_copy(pck + 170640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 170720, "        Values are unchanged in the 2000 IAU repor"
	    "t.", (ftnlen)80, (ftnlen)52);
    s_copy(pck + 170800, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 170880, "     Current values:", (ftnlen)80, (ftnlen)20);
    s_copy(pck + 170960, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 171040, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 171120, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 171200, "        BODY399_RADII     = ( 6378.14   6378.14   "
	    "6356.75 )", (ftnlen)80, (ftnlen)59);
    s_copy(pck + 171280, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 171360, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 171440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 171520, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 171600, "Mars", (ftnlen)80, (ftnlen)4);
    s_copy(pck + 171680, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 171760, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 171840, "     Old values:", (ftnlen)80, (ftnlen)16);
    s_copy(pck + 171920, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 172000, "        body499_radii       = (     3397.      339"
	    "7.         3375.     )", (ftnlen)80, (ftnlen)72);
    s_copy(pck + 172080, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 172160, "     Current values:", (ftnlen)80, (ftnlen)20);
    s_copy(pck + 172240, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 172320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 172400, "        The IAU report gives separate values for t"
	    "he north and south", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 172480, "        polar radii:", (ftnlen)80, (ftnlen)20);
    s_copy(pck + 172560, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 172640, "           north:  3373.19", (ftnlen)80, (ftnlen)26)
	    ;
    s_copy(pck + 172720, "           south:  3379.21", (ftnlen)80, (ftnlen)26)
	    ;
    s_copy(pck + 172800, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 172880, "        We use the average of these values as the "
	    "polar radius for", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 172960, "        the triaxial model.", (ftnlen)80, (ftnlen)
	    27);
    s_copy(pck + 173040, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 173120, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 173200, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 173280, "        BODY499_RADII       = ( 3396.19   3396.19 "
	    "  3376.20 )", (ftnlen)80, (ftnlen)61);
    s_copy(pck + 173360, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 173440, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 173520, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 173600, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 173680, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 173760, "Jupiter", (ftnlen)80, (ftnlen)7);
    s_copy(pck + 173840, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 173920, "     Old values:", (ftnlen)80, (ftnlen)16);
    s_copy(pck + 174000, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 174080, "        Values are unchanged in the 2000 IAU repor"
	    "t.", (ftnlen)80, (ftnlen)52);
    s_copy(pck + 174160, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 174240, "     Current values:", (ftnlen)80, (ftnlen)20);
    s_copy(pck + 174320, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 174400, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 174480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 174560, "        BODY599_RADII     = ( 71492   71492   6685"
	    "4 )", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 174640, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 174720, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 174800, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 174880, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 174960, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 175040, "Saturn", (ftnlen)80, (ftnlen)6);
    s_copy(pck + 175120, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 175200, "     Old values:", (ftnlen)80, (ftnlen)16);
    s_copy(pck + 175280, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 175360, "        Values are unchanged in the 2000 IAU repor"
	    "t.", (ftnlen)80, (ftnlen)52);
    s_copy(pck + 175440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 175520, "     Current values:", (ftnlen)80, (ftnlen)20);
    s_copy(pck + 175600, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 175680, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 175760, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 175840, "        BODY699_RADII     = ( 60268   60268   5436"
	    "4 )", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 175920, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 176000, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 176080, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 176160, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 176240, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 176320, "Uranus", (ftnlen)80, (ftnlen)6);
    s_copy(pck + 176400, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 176480, "     Old values:", (ftnlen)80, (ftnlen)16);
    s_copy(pck + 176560, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 176640, "        Values are unchanged in the 2000 IAU repor"
	    "t.", (ftnlen)80, (ftnlen)52);
    s_copy(pck + 176720, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 176800, "     Current values:", (ftnlen)80, (ftnlen)20);
    s_copy(pck + 176880, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 176960, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 177040, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 177120, "        BODY799_RADII     = ( 25559   25559   2497"
	    "3 )", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 177200, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 177280, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 177360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 177440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 177520, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 177600, "Neptune", (ftnlen)80, (ftnlen)7);
    s_copy(pck + 177680, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 177760, "     Old values:", (ftnlen)80, (ftnlen)16);
    s_copy(pck + 177840, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 177920, "        Values are unchanged in the 2000 IAU repor"
	    "t.", (ftnlen)80, (ftnlen)52);
    s_copy(pck + 178000, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 178080, "     Current values:", (ftnlen)80, (ftnlen)20);
    s_copy(pck + 178160, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 178240, "        (Values are for the 1 bar pressure level.)",
	     (ftnlen)80, (ftnlen)50);
    s_copy(pck + 178320, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 178400, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 178480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 178560, "        BODY899_RADII     = ( 24764   24764  24341"
	    " )", (ftnlen)80, (ftnlen)52);
    s_copy(pck + 178640, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 178720, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 178800, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 178880, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 178960, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 179040, "Pluto", (ftnlen)80, (ftnlen)5);
    s_copy(pck + 179120, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 179200, "     Old values:", (ftnlen)80, (ftnlen)16);
    s_copy(pck + 179280, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 179360, "        Values are unchanged in the 2000 IAU repor"
	    "t.", (ftnlen)80, (ftnlen)52);
    s_copy(pck + 179440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 179520, "     Current values:", (ftnlen)80, (ftnlen)20);
    s_copy(pck + 179600, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 179680, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 179760, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 179840, "        BODY999_RADII     = ( 1195   1195   1195 )",
	     (ftnlen)80, (ftnlen)50);
    s_copy(pck + 179920, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 180000, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 180080, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 180160, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 180240, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 180320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 180400, "Radii of Satellites", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 180480, "--------------------------------------------------"
	    "------", (ftnlen)80, (ftnlen)56);
    s_copy(pck + 180560, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 180640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 180720, "Moon", (ftnlen)80, (ftnlen)4);
    s_copy(pck + 180800, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 180880, "     Old values:", (ftnlen)80, (ftnlen)16);
    s_copy(pck + 180960, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 181040, "        Values are unchanged in the 2000 IAU repor"
	    "t.", (ftnlen)80, (ftnlen)52);
    s_copy(pck + 181120, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 181200, "     Current values:", (ftnlen)80, (ftnlen)20);
    s_copy(pck + 181280, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 181360, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 181440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 181520, "        BODY301_RADII     = ( 1737.4   1737.4   17"
	    "37.4 )", (ftnlen)80, (ftnlen)56);
    s_copy(pck + 181600, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 181680, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 181760, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 181840, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 181920, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 182000, "Satellites of Mars", (ftnlen)80, (ftnlen)18);
    s_copy(pck + 182080, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 182160, "     Old values:", (ftnlen)80, (ftnlen)16);
    s_copy(pck + 182240, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 182320, "        Values are unchanged in the 2000 IAU repor"
	    "t.", (ftnlen)80, (ftnlen)52);
    s_copy(pck + 182400, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 182480, "     Current values:", (ftnlen)80, (ftnlen)20);
    s_copy(pck + 182560, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 182640, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 182720, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 182800, "        BODY401_RADII     = ( 13.4    11.2    9.2 )"
	    , (ftnlen)80, (ftnlen)51);
    s_copy(pck + 182880, "        BODY402_RADII     = (  7.5     6.1    5.2 )"
	    , (ftnlen)80, (ftnlen)51);
    s_copy(pck + 182960, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 183040, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 183120, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 183200, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 183280, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 183360, "Satellites of Jupiter", (ftnlen)80, (ftnlen)21);
    s_copy(pck + 183440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 183520, "     Old values:", (ftnlen)80, (ftnlen)16);
    s_copy(pck + 183600, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 183680, "        Old values for Io, Europa, Ganymede, Calli"
	    "sto and Amalthea.", (ftnlen)80, (ftnlen)67);
    s_copy(pck + 183760, "        These are from the 1997 IAU report.", (
	    ftnlen)80, (ftnlen)43);
    s_copy(pck + 183840, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 183920, "        body501_radii     = (     1826.       1815"
	    ".        1812.     )", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 184000, "        body502_radii     = (     1562.       1560"
	    ".        1559.     )", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 184080, "        body503_radii     = (     2635.       2633"
	    ".        2633.     )", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 184160, "        body504_radii     = (     2409.       2409"
	    ".        2409.     )", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 184240, "        body505_radii     = (      131.         73"
	    ".          67.     )", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 184320, "        body506_radii    = (  85      85      85  "
	    " )", (ftnlen)80, (ftnlen)52);
    s_copy(pck + 184400, "        body507_radii    = (  40      40      40  "
	    " )", (ftnlen)80, (ftnlen)52);
    s_copy(pck + 184480, "        body508_radii    = (  18      18      18  "
	    " )", (ftnlen)80, (ftnlen)52);
    s_copy(pck + 184560, "        body509_radii    = (  14      14      14  "
	    " )", (ftnlen)80, (ftnlen)52);
    s_copy(pck + 184640, "        body510_radii    = (  12      12      12  "
	    " )", (ftnlen)80, (ftnlen)52);
    s_copy(pck + 184720, "        body511_radii    = (  15      15      15  "
	    " )", (ftnlen)80, (ftnlen)52);
    s_copy(pck + 184800, "        body512_radii    = (  10      10      10  "
	    " )", (ftnlen)80, (ftnlen)52);
    s_copy(pck + 184880, "        body513_radii    = (   5       5       5  "
	    " )", (ftnlen)80, (ftnlen)52);
    s_copy(pck + 184960, "        body514_radii    = (  50      50      50  "
	    " )", (ftnlen)80, (ftnlen)52);
    s_copy(pck + 185040, "        body515_radii    = (  13      10       8  "
	    " )", (ftnlen)80, (ftnlen)52);
    s_copy(pck + 185120, "        body516_radii    = (  20      20    20   )",
	     (ftnlen)80, (ftnlen)50);
    s_copy(pck + 185200, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 185280, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 185360, "     Current values:", (ftnlen)80, (ftnlen)20);
    s_copy(pck + 185440, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 185520, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 185600, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 185680, "        BODY501_RADII     = ( 1829.4   1819.3   18"
	    "15.7  )", (ftnlen)80, (ftnlen)57);
    s_copy(pck + 185760, "        BODY502_RADII     = ( 1564.13  1561.23  15"
	    "60.93 )", (ftnlen)80, (ftnlen)57);
    s_copy(pck + 185840, "        BODY503_RADII     = ( 2632.4   2632.29  26"
	    "32.35 )", (ftnlen)80, (ftnlen)57);
    s_copy(pck + 185920, "        BODY504_RADII     = ( 2409.4   2409.2   24"
	    "09.3  )", (ftnlen)80, (ftnlen)57);
    s_copy(pck + 186000, "        BODY505_RADII     = (  125       73       "
	    "64    )", (ftnlen)80, (ftnlen)57);
    s_copy(pck + 186080, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 186160, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 186240, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 186320, "        Only mean radii are available in the 2000 "
	    "IAU report for bodies", (ftnlen)80, (ftnlen)71);
    s_copy(pck + 186400, "        506-513.", (ftnlen)80, (ftnlen)16);
    s_copy(pck + 186480, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 186560, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 186640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 186720, "        BODY506_RADII    = (    85       85       "
	    "85   )", (ftnlen)80, (ftnlen)56);
    s_copy(pck + 186800, "        BODY507_RADII    = (    40       40       "
	    "40   )", (ftnlen)80, (ftnlen)56);
    s_copy(pck + 186880, "        BODY508_RADII    = (    18       18       "
	    "18   )", (ftnlen)80, (ftnlen)56);
    s_copy(pck + 186960, "        BODY509_RADII    = (    14       14       "
	    "14   )", (ftnlen)80, (ftnlen)56);
    s_copy(pck + 187040, "        BODY510_RADII    = (    12       12       "
	    "12   )", (ftnlen)80, (ftnlen)56);
    s_copy(pck + 187120, "        BODY511_RADII    = (    15       15       "
	    "15   )", (ftnlen)80, (ftnlen)56);
    s_copy(pck + 187200, "        BODY512_RADII    = (    10       10       "
	    "10   )", (ftnlen)80, (ftnlen)56);
    s_copy(pck + 187280, "        BODY513_RADII    = (     5        5       "
	    " 5   )", (ftnlen)80, (ftnlen)56);
    s_copy(pck + 187360, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 187440, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 187520, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 187600, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 187680, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 187760, "        BODY514_RADII    = (    58       49       "
	    "42   )", (ftnlen)80, (ftnlen)56);
    s_copy(pck + 187840, "        BODY515_RADII    = (    10        8       "
	    " 7   )", (ftnlen)80, (ftnlen)56);
    s_copy(pck + 187920, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 188000, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 188080, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 188160, "        The value for the second radius for body 5"
	    "16 is not given in", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 188240, "        2000 IAU report.   The values given are:", (
	    ftnlen)80, (ftnlen)48);
    s_copy(pck + 188320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 188400, "           BODY516_RADII    = (  30   ---   20   )",
	     (ftnlen)80, (ftnlen)50);
    s_copy(pck + 188480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 188560, "        For use within the SPICE system, we use on"
	    "ly the mean radius.", (ftnlen)80, (ftnlen)69);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 188640, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 188720, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 188800, "        BODY516_RADII    = (  21.5   21.5  21.5  )",
	     (ftnlen)80, (ftnlen)50);
    s_copy(pck + 188880, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 188960, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 189040, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 189120, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 189200, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 189280, "Satellites of Saturn", (ftnlen)80, (ftnlen)20);
    s_copy(pck + 189360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 189440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 189520, "     Old values:", (ftnlen)80, (ftnlen)16);
    s_copy(pck + 189600, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 189680, "        body601_radii     = (      210.3       197"
	    ".4        192.6    )", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 189760, "        body602_radii     = (      256.2       247"
	    ".3        244.0    )", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 189840, "        body603_radii     = (      535.6       528"
	    ".2        525.8    )", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 189920, "        body604_radii     = (      560.        560"
	    ".         560.     )", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 190000, "        body605_radii     = (      764.        764"
	    ".         764.     )", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 190080, "        body606_radii     = (     2575.       2575"
	    ".        2575.     )", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 190160, "        body607_radii     = (      180.        140"
	    ".         112.5    )", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 190240, "        body608_radii     = (      718.        718"
	    ".         718.     )", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 190320, "        body609_radii     = (      115.        110"
	    ".         105.     )", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 190400, "        body610_radii     = (       97.         95"
	    ".          77.     )", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 190480, "        body611_radii     = (       69.         55"
	    ".          55.     )", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 190560, "        body612_radii     = (       16          16"
	    "           16      )", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 190640, "        body613_radii     = (       15          12"
	    ".5          7.5    )", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 190720, "        body614_radii     = (       15           8"
	    "            8      )", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 190800, "        body615_radii     = (       18.5        17"
	    ".2         13.5    )", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 190880, "        body616_radii     = (       74          50"
	    "           34      )", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 190960, "        body617_radii     = (       55          44"
	    "           31      )", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 191040, "        body618_radii     = (       10          10"
	    "           10      )", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 191120, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 191200, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 191280, "     Current values:", (ftnlen)80, (ftnlen)20);
    s_copy(pck + 191360, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 191440, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 191520, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 191600, "        BODY601_RADII     = (  209.1   196.2   191"
	    ".4 )", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 191680, "        BODY602_RADII     = (  256.3   247.3   244"
	    ".6 )", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 191760, "        BODY603_RADII     = (  535.6   528.2   525"
	    ".8 )", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 191840, "        BODY604_RADII     = (  560     560     560"
	    "   )", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 191920, "        BODY605_RADII     = (  764     764     764"
	    "   )", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 192000, "        BODY606_RADII     = ( 2575    2575    2575"
	    "   )", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 192080, "        BODY607_RADII     = (  164     130     107"
	    "   )", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 192160, "        BODY608_RADII     = (  718     718     718"
	    "   )", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 192240, "        BODY609_RADII     = (  115     110     105"
	    "   )", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 192320, "        BODY610_RADII     = (   97.0    95.0    77"
	    ".0 )", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 192400, "        BODY611_RADII     = (   69.0    55.0    55"
	    ".0 )", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 192480, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 192560, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 192640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 192720, "        Only the first equatorial radius for Helen"
	    "e (body 612) is given in the", (ftnlen)80, (ftnlen)78);
    s_copy(pck + 192800, "        2000 IAU report:", (ftnlen)80, (ftnlen)24);
    s_copy(pck + 192880, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 192960, "            BODY612_RADII     = (       17.5      "
	    "  ---          ---     )", (ftnlen)80, (ftnlen)74);
    s_copy(pck + 193040, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 193120, "        The mean radius is 16km; we use this radiu"
	    "s for all three axes, as", (ftnlen)80, (ftnlen)74);
    s_copy(pck + 193200, "        we do for the satellites for which only th"
	    "e mean radius is available.", (ftnlen)80, (ftnlen)77);
    s_copy(pck + 193280, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 193360, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 193440, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 193520, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 193600, "        BODY612_RADII     = (   16      16       1"
	    "6  )", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 193680, "        BODY613_RADII     = (   15      12.5     7"
	    ".5 )", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 193760, "        BODY614_RADII     = (   15.0     8.0     8"
	    ".0 )", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 193840, "        BODY615_RADII     = (   18.5    17.2    13"
	    ".5 )", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 193920, "        BODY616_RADII     = (   74.0    50.0    34"
	    ".0 )", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 194000, "        BODY617_RADII     = (   55.0    44.0    31"
	    ".0 )", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 194080, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 194160, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 194240, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 194320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 194400, "         For Pan, only a mean radius is given in t"
	    "he 2000 report.", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 194480, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 194560, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 194640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 194720, "        BODY618_RADII     = (   10       10     10"
	    "   )", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 194800, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 194880, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 194960, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 195040, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 195120, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 195200, "Satellites of Uranus", (ftnlen)80, (ftnlen)20);
    s_copy(pck + 195280, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 195360, "     Old values:", (ftnlen)80, (ftnlen)16);
    s_copy(pck + 195440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 195520, "        Values are unchanged in the 2000 IAU repor"
	    "t.", (ftnlen)80, (ftnlen)52);
    s_copy(pck + 195600, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 195680, "     Current values:", (ftnlen)80, (ftnlen)20);
    s_copy(pck + 195760, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 195840, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 195920, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 196000, "        BODY701_RADII     = (  581.1   577.9   577"
	    ".7 )", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 196080, "        BODY702_RADII     = (  584.7   584.7   584"
	    ".7 )", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 196160, "        BODY703_RADII     = (  788.9   788.9   788"
	    ".9 )", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 196240, "        BODY704_RADII     = (  761.4   761.4   761"
	    ".4 )", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 196320, "        BODY705_RADII     = (  240.4   234.2   232"
	    ".9 )", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 196400, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 196480, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 196560, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 196640, "        The 2000 report gives only mean radii for "
	    "satellites 706--715.", (ftnlen)80, (ftnlen)70);
    s_copy(pck + 196720, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 196800, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 196880, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 196960, "        BODY706_RADII     = (   13      13      13"
	    " )", (ftnlen)80, (ftnlen)52);
    s_copy(pck + 197040, "        BODY707_RADII     = (   15      15      15"
	    " )", (ftnlen)80, (ftnlen)52);
    s_copy(pck + 197120, "        BODY708_RADII     = (   21      21      21"
	    " )", (ftnlen)80, (ftnlen)52);
    s_copy(pck + 197200, "        BODY709_RADII     = (   31      31      31"
	    " )", (ftnlen)80, (ftnlen)52);
    s_copy(pck + 197280, "        BODY710_RADII     = (   27      27      27"
	    " )", (ftnlen)80, (ftnlen)52);
    s_copy(pck + 197360, "        BODY711_RADII     = (   42      42      42"
	    " )", (ftnlen)80, (ftnlen)52);
    s_copy(pck + 197440, "        BODY712_RADII     = (   54      54      54"
	    " )", (ftnlen)80, (ftnlen)52);
    s_copy(pck + 197520, "        BODY713_RADII     = (   27      27      27"
	    " )", (ftnlen)80, (ftnlen)52);
    s_copy(pck + 197600, "        BODY714_RADII     = (   33      33      33"
	    " )", (ftnlen)80, (ftnlen)52);
    s_copy(pck + 197680, "        BODY715_RADII     = (   77      77      77"
	    " )", (ftnlen)80, (ftnlen)52);
    s_copy(pck + 197760, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 197840, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 197920, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 198000, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 198080, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 198160, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 198240, "Satellites of Neptune", (ftnlen)80, (ftnlen)21);
    s_copy(pck + 198320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 198400, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 198480, "     Old values:", (ftnlen)80, (ftnlen)16);
    s_copy(pck + 198560, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 198640, "        Values are unchanged in the 2000 IAU repor"
	    "t.", (ftnlen)80, (ftnlen)52);
    s_copy(pck + 198720, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 198800, "     Current values:", (ftnlen)80, (ftnlen)20);
    s_copy(pck + 198880, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 198960, "        The 2000 report gives mean radii only for "
	    "bodies 801-806.", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 199040, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 199120, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 199200, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 199280, "        BODY801_RADII     = ( 1352.6  1352.6  1352"
	    ".6 )", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 199360, "        BODY802_RADII     = (  170     170     170"
	    "   )", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 199440, "        BODY803_RADII     = (   29      29     29 "
	    "   )", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 199520, "        BODY804_RADII     = (   40      40     40 "
	    "   )", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 199600, "        BODY805_RADII     = (   74      74     74 "
	    "   )", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 199680, "        BODY806_RADII     = (   79      79     79 "
	    "   )", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 199760, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 199840, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 199920, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 200000, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 200080, "        The second equatorial radius for Larissa i"
	    "s not given in the 2000", (ftnlen)80, (ftnlen)73);
    s_copy(pck + 200160, "        report.  The available values are:", (
	    ftnlen)80, (ftnlen)42);
    s_copy(pck + 200240, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 200320, "            BODY807_RADII     = (   104     ---   "
	    "  89   )", (ftnlen)80, (ftnlen)58);
    s_copy(pck + 200400, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 200480, "        For use within the SPICE system, we use on"
	    "ly the mean radius.", (ftnlen)80, (ftnlen)69);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 200560, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 200640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 200720, "        BODY807_RADII     = (   96      96     96 "
	    "  )", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 200800, "        BODY808_RADII     = (  218     208    201 "
	    "  )", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 200880, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 200960, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 201040, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 201120, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 201200, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 201280, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 201360, "Satellites of Pluto", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 201440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 201520, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 201600, "     Old values:", (ftnlen)80, (ftnlen)16);
    s_copy(pck + 201680, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 201760, "        Values are unchanged in the 2000 IAU repor"
	    "t.", (ftnlen)80, (ftnlen)52);
    s_copy(pck + 201840, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 201920, "     Current values:", (ftnlen)80, (ftnlen)20);
    s_copy(pck + 202000, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 202080, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 202160, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 202240, "        BODY901_RADII     = (  593     593    593 "
	    "  )", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 202320, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 202400, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 202480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 202560, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 202640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 202720, "Radii of Selected Asteroids", (ftnlen)80, (ftnlen)
	    27);
    s_copy(pck + 202800, "--------------------------------------------------"
	    "------", (ftnlen)80, (ftnlen)56);
    s_copy(pck + 202880, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 202960, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 203040, "Gaspra", (ftnlen)80, (ftnlen)6);
    s_copy(pck + 203120, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 203200, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 203280, "     Current values:", (ftnlen)80, (ftnlen)20);
    s_copy(pck + 203360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 203440, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 203520, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 203600, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 203680, "        BODY9511010_RADII     = (    9.1    5.2   "
	    " 4.4 )", (ftnlen)80, (ftnlen)56);
    s_copy(pck + 203760, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 203840, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 203920, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 204000, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 204080, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 204160, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 204240, "Ida", (ftnlen)80, (ftnlen)3);
    s_copy(pck + 204320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 204400, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 204480, "     Current values:", (ftnlen)80, (ftnlen)20);
    s_copy(pck + 204560, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 204640, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 204720, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 204800, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 204880, "        BODY2431010_RADII     = (   26.8   12.0   "
	    " 7.6 )", (ftnlen)80, (ftnlen)56);
    s_copy(pck + 204960, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 205040, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 205120, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 205200, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 205280, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 205360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 205440, "Kleopatra", (ftnlen)80, (ftnlen)9);
    s_copy(pck + 205520, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 205600, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 205680, "     Current values:", (ftnlen)80, (ftnlen)20);
    s_copy(pck + 205760, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 205840, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 205920, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 206000, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 206080, "        BODY2000216_RADII     = (   108.5      47 "
	    "   40.5  )", (ftnlen)80, (ftnlen)60);
    s_copy(pck + 206160, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 206240, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 206320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 206400, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 206480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 206560, "Eros", (ftnlen)80, (ftnlen)4);
    s_copy(pck + 206640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 206720, "     Current values:", (ftnlen)80, (ftnlen)20);
    s_copy(pck + 206800, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 206880, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 206960, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 207040, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 207120, "        BODY2000433_RADII     = (  7.311  7.311  7"
	    ".311  )", (ftnlen)80, (ftnlen)57);
    s_copy(pck + 207200, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 207280, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 207360, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 207440, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 207520, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 207600, "BODY-10_CONSTANTS_REF_FRAME = 2", (ftnlen)80, (
	    ftnlen)31);
    s_copy(pck + 207680, "BODY-10_CONSTANTS_JED_EPOCH = 2433282.42345905D0", (
	    ftnlen)80, (ftnlen)48);
    s_copy(pck + 207760, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 207840, "BODY-10_POLE_RA         = (  286.13       0.      "
	    "    0. )", (ftnlen)80, (ftnlen)58);
    s_copy(pck + 207920, "BODY-10_POLE_DEC        = (   63.87       0.      "
	    "    0. )", (ftnlen)80, (ftnlen)58);
    s_copy(pck + 208000, "BODY-10_PM              = (   84.10      14.18440 "
	    "    0. )", (ftnlen)80, (ftnlen)58);
    s_copy(pck + 208080, "BODY-10_LONG_AXIS       = (  459.00               "
	    "       )", (ftnlen)80, (ftnlen)58);
    s_copy(pck + 208160, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 208240, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 208320, " ", (ftnlen)80, (ftnlen)1);

/*     Create the PCK kernel. */

    txtopn_(namepc, &unit, namepc_len);
    for (i__ = 1; i__ <= 2605; ++i__) {
	r__ = rtrim_(pck + ((i__1 = i__ - 1) < 2605 && 0 <= i__1 ? i__1 : 
		s_rnge("pck", i__1, "t_pck08__", (ftnlen)3815)) * 80, (ftnlen)
		80);
	writln_(pck + ((i__1 = i__ - 1) < 2605 && 0 <= i__1 ? i__1 : s_rnge(
		"pck", i__1, "t_pck08__", (ftnlen)3817)) * 80, &unit, r__);
    }
    cl__1.cerr = 0;
    cl__1.cunit = unit;
    cl__1.csta = 0;
    f_clos(&cl__1);

/*     If this file needs to be loaded.  Do it now.  If not we are */
/*     done and can return. */

    if (*loadpc) {
	ldpool_(namepc, namepc_len);
	if (*keeppc) {

/*           If we are keeping this file, we need to register it */
/*           with FILREG. */

	    tfiles_(namepc, namepc_len);
	    return 0;
	}
    } else {

/*        We are keeping this file, so we need to register it */
/*        with FILREG. */

	tfiles_(namepc, namepc_len);
	return 0;
    }
    kilfil_(namepc, namepc_len);
    return 0;
} /* t_pck08__ */

