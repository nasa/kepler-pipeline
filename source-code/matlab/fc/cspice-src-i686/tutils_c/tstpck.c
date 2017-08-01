/* tstpck.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__9 = 9;
static integer c__1 = 1;

/* $Procedure      TSTPCK (Create at test CK of type 3 and SCLK file) */
/* Subroutine */ int tstpck_(char *namepc, logical *loadpc, logical *keeppc, 
	ftnlen namepc_len)
{
    /* System generated locals */
    integer i__1;
    char ch__1[16];
    cllist cl__1;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer), s_wsle(cilist *), 
	    do_lio(integer *, integer *, char *, ftnlen), e_wsle(void), 
	    f_clos(cllist *);

    /* Local variables */
    integer unit, i__, r__;
    extern integer rtrim_(char *, ftnlen);
    extern /* Character */ VOID begdat_(char *, ftnlen);
    extern /* Subroutine */ int kilfil_(char *, ftnlen), tfiles_(char *, 
	    ftnlen), ldpool_(char *, ftnlen), txtopn_(char *, integer *, 
	    ftnlen);
    char pck[80*466];

    /* Fortran I/O blocks */
    static cilist io___5 = { 0, 0, 0, 0, 0 };


/* $ Abstract */

/*     Create and if appropriate load a test PCK kernel. */

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

/*      None. */

/* $ Keywords */

/*       TESTING */

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
/*     testing. */



/* $ Examples */

/*     This is intended to be used in those instances when you */
/*     need a well defined PC-kernel for use in testing.  By using */
/*     this routine you can avoid having to know in advance where */
/*     a PCK file is on the system where you plan to do your testing. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*      W.L. Taber      (JPL) */

/* $ Literature_References */

/*      None. */

/* $ Version */

/* -    Test Utilities 1.1.0, 28-JUL-1999 (WLT) */

/*        Added code so that the PCK file (if not deleted at termination */
/*        of this routine) is registered with the Test Utility File */
/*        Registry (FILREG).  This way, the file will automatically */
/*        be deleted, after its test family is done. */

/* -    Test Utilities 1.0.0, 24-JAN-1995 (WLT) */


/* -& */
/* $ Index_Entries */

/*     Create test CK and SCLK files. */

/* -& */

/*     Spicelib Functions */


/*     Test Utility Functions */


/*     Local Variables. */

    kilfil_(namepc, namepc_len);
    s_copy(pck, "P_constants (PcK) SPICE kernel file ", (ftnlen)80, (ftnlen)
	    36);
    s_copy(pck + 80, "======================================== ============="
	    "====================== ", (ftnlen)80, (ftnlen)77);
    s_copy(pck + 160, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 240, "This kernel is a condensation of the SPICE kernel com"
	    "plete.tpc ", (ftnlen)80, (ftnlen)63);
    s_copy(pck + 320, "It is intended only for use in testing so that users "
	    "do not ", (ftnlen)80, (ftnlen)60);
    s_copy(pck + 400, "need to locate PCK kernels to use in testing software"
	    ". ", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 560, "This should not be your default PCK file as it is lik"
	    "ely to ", (ftnlen)80, (ftnlen)60);
    s_copy(pck + 640, "go out of date.  It will not be updated because it is "
	    , (ftnlen)80, (ftnlen)54);
    s_copy(pck + 720, "generated automatically at run time by the routine TS"
	    "TPCK. ", (ftnlen)80, (ftnlen)59);
    s_copy(pck + 800, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(pck + 880, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 960, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 1040, "BODY10_POLE_RA         = (  286.13 0.          0. ) ",
	     (ftnlen)80, (ftnlen)52);
    s_copy(pck + 1120, "BODY10_POLE_DEC        = (   63.87 0.          0. ) ",
	     (ftnlen)80, (ftnlen)52);
    s_copy(pck + 1200, "BODY10_PM              = (   84.10 +14.18440     0. "
	    ") ", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 1280, "BODY10_LONG_AXIS       = (    0. ) ", (ftnlen)80, (
	    ftnlen)35);
    s_copy(pck + 1360, "BODY199_POLE_RA        = (  281.01, -0.003,      0. "
	    ") ", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 1440, "BODY199_POLE_DEC       = (   61.45, -0.005,      0. "
	    ") ", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 1520, "BODY199_PM             = (  329.71 +6.1385025   0. ) "
	    , (ftnlen)80, (ftnlen)53);
    s_copy(pck + 1600, "BODY199_LONG_AXIS      = (    0. ) ", (ftnlen)80, (
	    ftnlen)35);
    s_copy(pck + 1680, "BODY299_POLE_RA        = (  272.69 0.          0. ) ",
	     (ftnlen)80, (ftnlen)52);
    s_copy(pck + 1760, "BODY299_POLE_DEC       = (  +67.17 0.          0. ) ",
	     (ftnlen)80, (ftnlen)52);
    s_copy(pck + 1840, "BODY299_PM             = (  160.39 -1.4813291   0. ) "
	    , (ftnlen)80, (ftnlen)53);
    s_copy(pck + 1920, "BODY299_LONG_AXIS      = (    0. ) ", (ftnlen)80, (
	    ftnlen)35);
    s_copy(pck + 2000, "BODY399_POLE_RA        = (    0. -0.641         0. ) "
	    , (ftnlen)80, (ftnlen)53);
    s_copy(pck + 2080, "BODY399_POLE_DEC       = (  +90. -0.557         0. ) "
	    , (ftnlen)80, (ftnlen)53);
    s_copy(pck + 2160, "BODY399_PM             = (  190.16 +360.9856235     "
	    "0. ) ", (ftnlen)80, (ftnlen)57);
    s_copy(pck + 2240, "BODY399_LONG_AXIS      = (    0. ) ", (ftnlen)80, (
	    ftnlen)35);
    s_copy(pck + 2320, "BODY399_MAG_NORTH_POLE_LON  =  ( -69.761 ) ", (ftnlen)
	    80, (ftnlen)43);
    s_copy(pck + 2400, "BODY399_MAG_NORTH_POLE_LAT  =  (  78.565 ) ", (ftnlen)
	    80, (ftnlen)43);
    s_copy(pck + 2480, "BODY3_NUT_PREC_ANGLES  = (  125.045 -1935.5328 ", (
	    ftnlen)80, (ftnlen)47);
    s_copy(pck + 2560, "249.390    -3871.0656 ", (ftnlen)80, (ftnlen)22);
    s_copy(pck + 2640, "196.694  -475263.3 ", (ftnlen)80, (ftnlen)19);
    s_copy(pck + 2720, "176.630  +487269.6519 ", (ftnlen)80, (ftnlen)22);
    s_copy(pck + 2800, "358.219   -35999.04     ) ", (ftnlen)80, (ftnlen)26);
    s_copy(pck + 2880, "BODY499_POLE_RA          = (  317.681 -0.108       0"
	    ".  ) ", (ftnlen)80, (ftnlen)57);
    s_copy(pck + 2960, "BODY499_POLE_DEC         = (  +52.886 -0.061       0"
	    ".  ) ", (ftnlen)80, (ftnlen)57);
    s_copy(pck + 3040, "BODY499_PM               = (  176.868 +350.8919830  "
	    " 0.  ) ", (ftnlen)80, (ftnlen)59);
    s_copy(pck + 3120, "BODY4_NUT_PREC_ANGLES  = (  169.51 -15916.2801 ", (
	    ftnlen)80, (ftnlen)47);
    s_copy(pck + 3200, "192.93  +41215163.19675 ", (ftnlen)80, (ftnlen)24);
    s_copy(pck + 3280, "53.47       -662.965275  ) ", (ftnlen)80, (ftnlen)27);
    s_copy(pck + 3360, "BODY599_POLE_RA        = (   268.05 -0.009  0.  ) ", (
	    ftnlen)80, (ftnlen)50);
    s_copy(pck + 3440, "BODY599_POLE_DEC       = (   +64.49 +0.003  0.  ) ", (
	    ftnlen)80, (ftnlen)50);
    s_copy(pck + 3520, "BODY599_PM             = (   284.95 +870.536  0.  ) ",
	     (ftnlen)80, (ftnlen)52);
    s_copy(pck + 3600, "BODY599_LONG_AXIS      = (     0. ) ", (ftnlen)80, (
	    ftnlen)36);
    s_copy(pck + 3680, "BODY5_NUT_PREC_ANGLES  = (   73.32 +91472.9 ", (
	    ftnlen)80, (ftnlen)44);
    s_copy(pck + 3760, "198.54   +44243.8 ", (ftnlen)80, (ftnlen)18);
    s_copy(pck + 3840, "283.90    +4850.7 ", (ftnlen)80, (ftnlen)18);
    s_copy(pck + 3920, "355.80    +1191.3 ", (ftnlen)80, (ftnlen)18);
    s_copy(pck + 4000, "119.90     +262.1 ", (ftnlen)80, (ftnlen)18);
    s_copy(pck + 4080, "229.80      +64.3 ", (ftnlen)80, (ftnlen)18);
    s_copy(pck + 4160, "352.25    +2382.6 ", (ftnlen)80, (ftnlen)18);
    s_copy(pck + 4240, "113.35    +6070.0 ", (ftnlen)80, (ftnlen)18);
    s_copy(pck + 4320, "146.64  +182945.8 ", (ftnlen)80, (ftnlen)18);
    s_copy(pck + 4400, "397.08   +88487.6  ) ", (ftnlen)80, (ftnlen)21);
    s_copy(pck + 4480, "BODY699_POLE_RA        = (    40.58 -0.036      0.  "
	    ") ", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 4560, "BODY699_POLE_DEC       = (   +83.54 -0.004      0.  "
	    ") ", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 4640, "BODY699_PM             = (    38.90 +810.7939024  0."
	    "  ) ", (ftnlen)80, (ftnlen)56);
    s_copy(pck + 4720, "BODY699_LONG_AXIS      = (     0. ) ", (ftnlen)80, (
	    ftnlen)36);
    s_copy(pck + 4800, "BODY6_NUT_PREC_ANGLES  = (  177.40 -36505.5 ", (
	    ftnlen)80, (ftnlen)44);
    s_copy(pck + 4880, "300.00   -7225.9 ", (ftnlen)80, (ftnlen)17);
    s_copy(pck + 4960, "345.20   -1016.3 ", (ftnlen)80, (ftnlen)17);
    s_copy(pck + 5040, "29.80     -52.1 ", (ftnlen)80, (ftnlen)16);
    s_copy(pck + 5120, "316.45    +506.2  ) ", (ftnlen)80, (ftnlen)20);
    s_copy(pck + 5200, "BODY799_POLE_RA        = (  257.43 0.         0.  ) ",
	     (ftnlen)80, (ftnlen)52);
    s_copy(pck + 5280, "BODY799_POLE_DEC       = (  -15.10 0.         0.  ) ",
	     (ftnlen)80, (ftnlen)52);
    s_copy(pck + 5360, "BODY799_PM             = (  203.81 -501.1600928  0. "
	    " ) ", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 5440, "BODY799_LONG_AXIS      = (    0. ) ", (ftnlen)80, (
	    ftnlen)35);
    s_copy(pck + 5520, "BODY7_NUT_PREC_ANGLES  = (  115.75 +54991.87 ", (
	    ftnlen)80, (ftnlen)45);
    s_copy(pck + 5600, "141.69  +41887.66 ", (ftnlen)80, (ftnlen)18);
    s_copy(pck + 5680, "135.03  +29927.35 ", (ftnlen)80, (ftnlen)18);
    s_copy(pck + 5760, "61.77  +25733.59 ", (ftnlen)80, (ftnlen)17);
    s_copy(pck + 5840, "249.32  +24471.46 ", (ftnlen)80, (ftnlen)18);
    s_copy(pck + 5920, "43.86  +22278.41 ", (ftnlen)80, (ftnlen)17);
    s_copy(pck + 6000, "77.66  +20289.42 ", (ftnlen)80, (ftnlen)17);
    s_copy(pck + 6080, "157.36  +16652.76 ", (ftnlen)80, (ftnlen)18);
    s_copy(pck + 6160, "101.81  +12872.63 ", (ftnlen)80, (ftnlen)18);
    s_copy(pck + 6240, "138.64   +8061.81 ", (ftnlen)80, (ftnlen)18);
    s_copy(pck + 6320, "102.23   -2024.22 ", (ftnlen)80, (ftnlen)18);
    s_copy(pck + 6400, "316.41    2863.96 ", (ftnlen)80, (ftnlen)18);
    s_copy(pck + 6480, "304.01     -51.94 ", (ftnlen)80, (ftnlen)18);
    s_copy(pck + 6560, "308.71     -93.17 ", (ftnlen)80, (ftnlen)18);
    s_copy(pck + 6640, "340.82     -75.32 ", (ftnlen)80, (ftnlen)18);
    s_copy(pck + 6720, "259.14    -504.81 ", (ftnlen)80, (ftnlen)18);
    s_copy(pck + 6800, "204.46   -4048.44 ", (ftnlen)80, (ftnlen)18);
    s_copy(pck + 6880, "632.82    5727.92     ) ", (ftnlen)80, (ftnlen)24);
    s_copy(pck + 6960, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 7040, "BODY899_POLE_RA        = (  298.72 0.         0.  ) ",
	     (ftnlen)80, (ftnlen)52);
    s_copy(pck + 7120, "BODY899_POLE_DEC       = (  +42.63 0.         0.  ) ",
	     (ftnlen)80, (ftnlen)52);
    s_copy(pck + 7200, "BODY899_PM             = (  313.66 +483.7625981  0. "
	    " ) ", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 7280, "BODY899_LONG_AXIS      = (    0. ) ", (ftnlen)80, (
	    ftnlen)35);
    s_copy(pck + 7360, "BODY8_NUT_PREC_ANGLES = (   179.280 54.3080 ", (
	    ftnlen)80, (ftnlen)44);
    s_copy(pck + 7440, "45.0600        3.65000 ", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 7520, "358.560       108.616 ", (ftnlen)80, (ftnlen)22);
    s_copy(pck + 7600, "537.840       162.924 ", (ftnlen)80, (ftnlen)22);
    s_copy(pck + 7680, "717.120       217.232 ", (ftnlen)80, (ftnlen)22);
    s_copy(pck + 7760, "896.400       271.540 ", (ftnlen)80, (ftnlen)22);
    s_copy(pck + 7840, "1075.68        325.848 ", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 7920, "1254.96        380.156 ", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 8000, "1434.24        434.464 ", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 8080, "90.1200        7.30000 ", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 8160, "135.180        10.9500 ", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 8240, "180.240        14.6000 ", (ftnlen)80, (ftnlen)23);
    s_copy(pck + 8320, "225.300        18.2500    ) ", (ftnlen)80, (ftnlen)28)
	    ;
    s_copy(pck + 8400, "BODY999_POLE_RA        = (  311.63    0. 0.  ) ", (
	    ftnlen)80, (ftnlen)47);
    s_copy(pck + 8480, "BODY999_POLE_DEC       = (   +4.18    0. 0.  ) ", (
	    ftnlen)80, (ftnlen)47);
    s_copy(pck + 8560, "BODY999_PM             = (  252.66 -56.364  0.  ) ", (
	    ftnlen)80, (ftnlen)50);
    s_copy(pck + 8640, "BODY999_LONG_AXIS      = (    0. ) ", (ftnlen)80, (
	    ftnlen)35);
    s_copy(pck + 8720, "BODY9511010_CONSTANTS_REF_FRAME  =   ( 2 ) ", (ftnlen)
	    80, (ftnlen)43);
    s_copy(pck + 8800, "BODY9511010_CONSTANTS_JED_EPOCH  =   ( 2433282.5 ) ", 
	    (ftnlen)80, (ftnlen)51);
    s_copy(pck + 8880, "BODY9511010_POLE_RA              =   ( 10.2        0"
	    "           0  ) ", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 8960, "BODY9511010_POLE_DEC             =   ( 26.2        0"
	    "           0  ) ", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 9040, "BODY9511010_PM                   =   ( 251.924  1226"
	    ".906747    0  ) ", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 9120, "BODY301_POLE_RA        = (  270.000 0.           0. "
	    ") ", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 9200, "BODY301_POLE_DEC       = (  +66.534 0.           0. "
	    ") ", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 9280, "BODY301_PM             = (   38.314 +13.1763581    0"
	    ". ) ", (ftnlen)80, (ftnlen)56);
    s_copy(pck + 9360, "BODY301_LONG_AXIS      = (    0. ) ", (ftnlen)80, (
	    ftnlen)35);
    s_copy(pck + 9440, "BODY301_NUT_PREC_RA  = (  -3.878  -0.120 +0.070  -0."
	    "017   0.    ) ", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 9520, "BODY301_NUT_PREC_DEC = (  +1.543  +0.024 -0.028  +0."
	    "007   0.    ) ", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 9600, "BODY301_NUT_PREC_PM  = (  +3.558  +0.121 -0.064  +0."
	    "016  +0.025 ) ", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 9680, "BODY401_POLE_RA       = (  317.68 -0.108       0.   "
	    "       ) ", (ftnlen)80, (ftnlen)61);
    s_copy(pck + 9760, "BODY401_POLE_DEC      = (  +52.90 -0.061       0.   "
	    "       ) ", (ftnlen)80, (ftnlen)61);
    s_copy(pck + 9840, "BODY401_PM            = (   35.06 +1128.8445850 6.64"
	    "4300D-09 ) ", (ftnlen)80, (ftnlen)63);
    s_copy(pck + 9920, "BODY401_LONG_AXIS     = (    0. ) ", (ftnlen)80, (
	    ftnlen)34);
    s_copy(pck + 10000, "BODY401_NUT_PREC_RA   = (   +1.79   0. 0.  ) ", (
	    ftnlen)80, (ftnlen)45);
    s_copy(pck + 10080, "BODY401_NUT_PREC_DEC  = (   -1.08   0. 0.  ) ", (
	    ftnlen)80, (ftnlen)45);
    s_copy(pck + 10160, "BODY401_NUT_PREC_PM   = (   -1.42  -0.78 0.  ) ", (
	    ftnlen)80, (ftnlen)47);
    s_copy(pck + 10240, "BODY402_POLE_RA       = (  316.65 -0.108       0.  "
	    "          ) ", (ftnlen)80, (ftnlen)63);
    s_copy(pck + 10320, "BODY402_POLE_DEC      = (  +53.52 -0.061       0.  "
	    "          ) ", (ftnlen)80, (ftnlen)63);
    s_copy(pck + 10400, "BODY402_PM            = (   79.41 +285.1618970  -3."
	    "897830D-10  ) ", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 10480, "BODY402_LONG_AXIS     = (    0. ) ", (ftnlen)80, (
	    ftnlen)34);
    s_copy(pck + 10560, "BODY402_NUT_PREC_RA   = (    0.   0. +2.98  ) ", (
	    ftnlen)80, (ftnlen)46);
    s_copy(pck + 10640, "BODY402_NUT_PREC_DEC  = (    0.   0. -1.78  ) ", (
	    ftnlen)80, (ftnlen)46);
    s_copy(pck + 10720, "BODY402_NUT_PREC_PM   = (    0.   0. -2.58  ) ", (
	    ftnlen)80, (ftnlen)46);
    s_copy(pck + 10800, "BODY501_POLE_RA       = (  268.05 -0.009      0.  ) "
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 10880, "BODY501_POLE_DEC      = (  +64.50 +0.003      0.  ) "
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 10960, "BODY501_PM            = (  200.39 +203.4889538  0. "
	    " ) ", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 11040, "BODY501_LONG_AXIS     = (    0. ) ", (ftnlen)80, (
	    ftnlen)34);
    s_copy(pck + 11120, "BODY501_NUT_PREC_RA   = (    0.   0. +0.094   +0.02"
	    "4   ) ", (ftnlen)80, (ftnlen)57);
    s_copy(pck + 11200, "BODY501_NUT_PREC_DEC  = (    0.   0. +0.040   +0.01"
	    "1   ) ", (ftnlen)80, (ftnlen)57);
    s_copy(pck + 11280, "BODY501_NUT_PREC_PM   = (    0.   0. -0.085   -0.02"
	    "2   ) ", (ftnlen)80, (ftnlen)57);
    s_copy(pck + 11360, "BODY502_POLE_RA       = (  268.08 -0.009      0.   "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 11440, "BODY502_POLE_DEC      = (  +64.51 +0.003      0.   "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 11520, "BODY502_PM            = (   35.72 +101.3747235  0. "
	    "  ) ", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 11600, "BODY502_LONG_AXIS     = (    0. ) ", (ftnlen)80, (
	    ftnlen)34);
    s_copy(pck + 11680, "BODY502_NUT_PREC_RA   = ( 0. 0. 0. +1.086  +0.060  "
	    "+0.015  +0.009 ) ", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 11760, "BODY502_NUT_PREC_DEC  = ( 0. 0. 0. +0.468  +0.026  "
	    "+0.007  +0.002 ) ", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 11840, "BODY502_NUT_PREC_PM   = ( 0. 0. 0. -0.980  -0.054  "
	    "-0.014  -0.008 ) ", (ftnlen)80, (ftnlen)68);
    s_copy(pck + 11920, "BODY503_POLE_RA       = (  268.20 -0.009      0.   "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 12000, "BODY503_POLE_DEC      = (  +64.57 +0.003      0.   "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 12080, "BODY503_PM            = (   43.14 +50.3176081  0.  "
	    " ) ", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 12160, "BODY503_LONG_AXIS     = (    0. ) ", (ftnlen)80, (
	    ftnlen)34);
    s_copy(pck + 12240, "BODY503_NUT_PREC_RA   = ( 0. 0. 0. -0.037  +0.431  "
	    "+0.091   ) ", (ftnlen)80, (ftnlen)62);
    s_copy(pck + 12320, "BODY503_NUT_PREC_DEC  = ( 0. 0. 0. -0.016  +0.186  "
	    "+0.039   ) ", (ftnlen)80, (ftnlen)62);
    s_copy(pck + 12400, "BODY503_NUT_PREC_PM   = ( 0. 0. 0. +0.033  -0.389  "
	    "-0.082   ) ", (ftnlen)80, (ftnlen)62);
    s_copy(pck + 12480, "BODY504_POLE_RA       = (   268.72 -0.009      0.  "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 12560, "BODY504_POLE_DEC      = (   +64.83 +0.003      0.  "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 12640, "BODY504_PM            = (   259.67 +21.5710715  0. "
	    " ) ", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 12720, "BODY504_LONG_AXIS     = (     0. ) ", (ftnlen)80, (
	    ftnlen)35);
    s_copy(pck + 12800, "BODY504_NUT_PREC_RA   = ( 0. 0. 0. 0. -0.068 +0.590"
	    "  0. +0.010 ) ", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 12880, "BODY504_NUT_PREC_DEC  = ( 0. 0. 0. 0. -0.029 +0.254"
	    "  0. -0.004 ) ", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 12960, "BODY504_NUT_PREC_PM   = ( 0. 0. 0. 0. +0.061 -0.533"
	    "  0. -0.009 ) ", (ftnlen)80, (ftnlen)65);
    s_copy(pck + 13040, "BODY505_POLE_RA       = (   268.05 -0.009      0.  "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 13120, "BODY505_POLE_DEC      = (   +64.49 +0.003      0.  "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 13200, "BODY505_PM            = (   231.67 +722.6314560  0."
	    "  ) ", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 13280, "BODY505_LONG_AXIS     = (     0. ) ", (ftnlen)80, (
	    ftnlen)35);
    s_copy(pck + 13360, "BODY505_NUT_PREC_RA  = ( -0.84  0. 0. 0. 0. 0. 0. 0"
	    ".  +0.01  ) ", (ftnlen)80, (ftnlen)63);
    s_copy(pck + 13440, "BODY505_NUT_PREC_DEC = ( -0.36  0. 0. 0. 0. 0. 0. 0"
	    ".   0.    ) ", (ftnlen)80, (ftnlen)63);
    s_copy(pck + 13520, "BODY505_NUT_PREC_PM  = ( +0.76  0. 0. 0. 0. 0. 0. 0"
	    ".  -0.01  ) ", (ftnlen)80, (ftnlen)63);
    s_copy(pck + 13600, "BODY514_POLE_RA       = (  268.05 -0.009       0.  "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 13680, "BODY514_POLE_DEC      = (   64.49 +0.003       0.  "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 13760, "BODY514_PM            = (    9.91 +533.7005330   0."
	    "  ) ", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 13840, "BODY514_LONG_AXIS     = (    0. ) ", (ftnlen)80, (
	    ftnlen)34);
    s_copy(pck + 13920, "BODY514_NUT_PREC_RA  = ( 0. -2.12  0. 0. 0. 0. 0. 0"
	    ". 0.  +0.04  ) ", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 14000, "BODY514_NUT_PREC_DEC = ( 0. -0.91  0. 0. 0. 0. 0. 0"
	    ". 0.  +0.01  ) ", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 14080, "BODY514_NUT_PREC_PM  = ( 0. +1.91  0. 0. 0. 0. 0. 0"
	    ". 0.  -0.04  ) ", (ftnlen)80, (ftnlen)66);
    s_copy(pck + 14160, "BODY515_POLE_RA       = (  268.05 -0.009       0.  "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 14240, "BODY515_POLE_DEC      = (   64.49 +0.003       0.  "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 14320, "BODY515_PM            = (    5.75 +1206.9950400   0"
	    ".  ) ", (ftnlen)80, (ftnlen)56);
    s_copy(pck + 14400, "BODY515_LONG_AXIS     = (    0. ) ", (ftnlen)80, (
	    ftnlen)34);
    s_copy(pck + 14480, "BODY516_POLE_RA       = (  268.05 -0.009       0.  "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 14560, "BODY516_POLE_DEC      = (   64.49 +0.003       0.  "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 14640, "BODY516_PM            = (  302.24 +1221.2489660   0"
	    ".  ) ", (ftnlen)80, (ftnlen)56);
    s_copy(pck + 14720, "BODY516_LONG_AXIS     = (    0. ) ", (ftnlen)80, (
	    ftnlen)34);
    s_copy(pck + 14800, "BODY601_POLE_RA       = (    40.66 -0.036      0.  "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 14880, "BODY601_POLE_DEC      = (   +83.52 -0.004      0.  "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 14960, "BODY601_PM            = (   337.46 +381.9945550  0."
	    "  ) ", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 15040, "BODY601_LONG_AXIS     = (     0. ) ", (ftnlen)80, (
	    ftnlen)35);
    s_copy(pck + 15120, "BODY601_NUT_PREC_RA   = (   +13.56  0. 0.  0.    0."
	    "     ) ", (ftnlen)80, (ftnlen)58);
    s_copy(pck + 15200, "BODY601_NUT_PREC_DEC  = (    -1.53  0. 0.  0.    0."
	    "     ) ", (ftnlen)80, (ftnlen)58);
    s_copy(pck + 15280, "BODY601_NUT_PREC_PM   = (   -13.48  0. 0.  0.  -44."
	    "85   ) ", (ftnlen)80, (ftnlen)58);
    s_copy(pck + 15360, "BODY602_POLE_RA       = (   40.66 -0.036      0.  ) "
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 15440, "BODY602_POLE_DEC      = (  +83.52 -0.004      0.  ) "
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 15520, "BODY602_PM            = (    2.82 +262.7318996  0. "
	    " ) ", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 15600, "BODY602_LONG_AXIS     = (    0. ) ", (ftnlen)80, (
	    ftnlen)34);
    s_copy(pck + 15680, "BODY603_POLE_RA       = (    40.66 -0.036      0.  "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 15760, "BODY603_POLE_DEC      = (   +83.52 -0.004      0.  "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 15840, "BODY603_PM            = (    10.45 +190.6979085  0."
	    "  ) ", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 15920, "BODY603_LONG_AXIS     = (     0. ) ", (ftnlen)80, (
	    ftnlen)35);
    s_copy(pck + 16000, "BODY603_NUT_PREC_RA   = (   0.  +9.66 0.  0.   0.  "
	    "  ) ", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 16080, "BODY603_NUT_PREC_DEC  = (   0.  -1.09 0.  0.   0.  "
	    "  ) ", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 16160, "BODY603_NUT_PREC_PM   = (   0.  -9.60 0.  0.  +2.23"
	    "  ) ", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 16240, "BODY604_POLE_RA       = (    40.66 -0.036      0.  "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 16320, "BODY604_POLE_DEC      = (   +83.52 -0.004      0.  "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 16400, "BODY604_PM            = (   357.00 +131.5349316  0."
	    "  ) ", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 16480, "BODY604_LONG_AXIS     = (     0. ) ", (ftnlen)80, (
	    ftnlen)35);
    s_copy(pck + 16560, "BODY605_POLE_RA       = (   40.38 -0.036      0.   "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 16640, "BODY605_POLE_DEC      = (  +83.55 -0.004      0.   "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 16720, "BODY605_PM            = (  235.16 +79.6900478  0.  "
	    " ) ", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 16800, "BODY605_LONG_AXIS     = (    0. ) ", (ftnlen)80, (
	    ftnlen)34);
    s_copy(pck + 16880, "BODY605_NUT_PREC_RA   = (   0.  0. +3.10   ) ", (
	    ftnlen)80, (ftnlen)45);
    s_copy(pck + 16960, "BODY605_NUT_PREC_DEC  = (   0.  0. -0.35   ) ", (
	    ftnlen)80, (ftnlen)45);
    s_copy(pck + 17040, "BODY605_NUT_PREC_PM   = (   0.  0. -3.08   ) ", (
	    ftnlen)80, (ftnlen)45);
    s_copy(pck + 17120, "BODY606_POLE_RA       = (    36.41 -0.036      0.  "
	    " ) ", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 17200, "BODY606_POLE_DEC      = (   +83.94 -0.004      0.  "
	    " ) ", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 17280, "BODY606_PM            = (   189.64 +22.5769768  0. "
	    "  ) ", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 17360, "BODY606_LONG_AXIS     = (     0. ) ", (ftnlen)80, (
	    ftnlen)35);
    s_copy(pck + 17440, "BODY606_NUT_PREC_RA   = (   0.  0.  0. +2.66  ) ", (
	    ftnlen)80, (ftnlen)48);
    s_copy(pck + 17520, "BODY606_NUT_PREC_DEC  = (   0.  0.  0. -0.30  ) ", (
	    ftnlen)80, (ftnlen)48);
    s_copy(pck + 17600, "BODY606_NUT_PREC_PM   = (   0.  0.  0. -2.64  ) ", (
	    ftnlen)80, (ftnlen)48);
    s_copy(pck + 17680, "BODY608_POLE_RA       = (   318.16 -3.949      0.  "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 17760, "BODY608_POLE_DEC      = (   +75.03 -1.143      0.  "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 17840, "BODY608_PM            = (   350.20 +4.5379572  0.  "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 17920, "BODY608_LONG_AXIS     = (     0. ) ", (ftnlen)80, (
	    ftnlen)35);
    s_copy(pck + 18000, "BODY613_POLE_RA       = (    50.50 -0.036      0.  "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 18080, "BODY613_POLE_DEC      = (    84.06 -0.004      0.  "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 18160, "BODY613_PM            = (    56.88 +190.6979330  0."
	    "  ) ", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 18240, "BODY613_LONG_AXIS     = (     0. ) ", (ftnlen)80, (
	    ftnlen)35);
    s_copy(pck + 18320, "BODY615_POLE_RA       = (    40.58 -0.036      0.  "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 18400, "BODY615_POLE_DEC      = (    83.53 -0.004      0.  "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 18480, "BODY615_PM            = (   137.88 +598.3060000  0."
	    "  ) ", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 18560, "BODY615_LONG_AXIS     = (     0. ) ", (ftnlen)80, (
	    ftnlen)35);
    s_copy(pck + 18640, "BODY616_POLE_RA       = (    40.58 -0.036      0.  "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 18720, "BODY616_POLE_DEC      = (    83.53 -0.004      0.  "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 18800, "BODY616_PM            = (   296.14 +587.2890000  0."
	    "  ) ", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 18880, "BODY616_LONG_AXIS     = (     0. ) ", (ftnlen)80, (
	    ftnlen)35);
    s_copy(pck + 18960, "BODY617_POLE_RA       = (    40.58 -0.036      0.  "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 19040, "BODY617_POLE_DEC      = (    83.53 -0.004      0.  "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 19120, "BODY617_PM            = (   162.92 +572.7891000  0."
	    "  ) ", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 19200, "BODY617_LONG_AXIS     = (     0. ) ", (ftnlen)80, (
	    ftnlen)35);
    s_copy(pck + 19280, "BODY701_POLE_RA       = (   257.43 0.         0.  ) "
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 19360, "BODY701_POLE_DEC      = (   -15.10 0.         0.  ) "
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 19440, "BODY701_PM            = (   156.22 -142.8356681  0."
	    "  ) ", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 19520, "BODY701_LONG_AXIS     = (     0. ) ", (ftnlen)80, (
	    ftnlen)35);
    s_copy(pck + 19600, "BODY701_NUT_PREC_RA   = (  0. 0. 0. 0. 0. ", (ftnlen)
	    80, (ftnlen)42);
    s_copy(pck + 19680, "0. 0. 0. 0. 0.    0.   0.    +0.29 ) ", (ftnlen)80, (
	    ftnlen)37);
    s_copy(pck + 19760, "BODY701_NUT_PREC_DEC  = (  0. 0. 0. 0. 0. ", (ftnlen)
	    80, (ftnlen)42);
    s_copy(pck + 19840, "0. 0. 0. 0. 0.    0.   0.    +0.28 ) ", (ftnlen)80, (
	    ftnlen)37);
    s_copy(pck + 19920, "BODY701_NUT_PREC_PM   = (  0. 0. 0. 0. 0. ", (ftnlen)
	    80, (ftnlen)42);
    s_copy(pck + 20000, "0. 0. 0. 0. 0.    0.  +0.05  +0.08 ) ", (ftnlen)80, (
	    ftnlen)37);
    s_copy(pck + 20080, "BODY702_POLE_RA       = (   257.43    0. 0.   ) ", (
	    ftnlen)80, (ftnlen)48);
    s_copy(pck + 20160, "BODY702_POLE_DEC      = (   -15.10    0. 0.   ) ", (
	    ftnlen)80, (ftnlen)48);
    s_copy(pck + 20240, "BODY702_PM            = (   108.05 -86.8688923  0. "
	    "  ) ", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 20320, "BODY702_LONG_AXIS     = (     0. ) ", (ftnlen)80, (
	    ftnlen)35);
    s_copy(pck + 20400, "BODY702_NUT_PREC_RA   = (  0. 0. 0. 0. 0. ", (ftnlen)
	    80, (ftnlen)42);
    s_copy(pck + 20480, "0. 0. 0. 0. 0.   0.   0.    0.  +0.21 ) ", (ftnlen)
	    80, (ftnlen)40);
    s_copy(pck + 20560, "BODY702_NUT_PREC_DEC  = (  0. 0. 0. 0. 0. ", (ftnlen)
	    80, (ftnlen)42);
    s_copy(pck + 20640, "0. 0. 0. 0. 0.   0.   0.    0.  +0.20 ) ", (ftnlen)
	    80, (ftnlen)40);
    s_copy(pck + 20720, "BODY702_NUT_PREC_PM   = (  0. 0. 0. 0. 0. ", (ftnlen)
	    80, (ftnlen)42);
    s_copy(pck + 20800, "0. 0. 0. 0. 0.   0.  -0.09  0.  +0.06 ) ", (ftnlen)
	    80, (ftnlen)40);
    s_copy(pck + 20880, "BODY703_POLE_RA       = (   257.43    0. 0.   ) ", (
	    ftnlen)80, (ftnlen)48);
    s_copy(pck + 20960, "BODY703_POLE_DEC      = (   -15.10    0. 0.   ) ", (
	    ftnlen)80, (ftnlen)48);
    s_copy(pck + 21040, "BODY703_PM            = (    77.74 -41.3514316  0. "
	    "  ) ", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 21120, "BODY703_LONG_AXIS     = (     0. ) ", (ftnlen)80, (
	    ftnlen)35);
    s_copy(pck + 21200, "BODY703_NUT_PREC_RA   = (  0. 0. 0. 0. 0. ", (ftnlen)
	    80, (ftnlen)42);
    s_copy(pck + 21280, "0. 0. 0. 0. 0.   0. 0. 0. 0.  +0.29 ) ", (ftnlen)80, 
	    (ftnlen)38);
    s_copy(pck + 21360, "BODY703_NUT_PREC_DEC  = (  0. 0. 0. 0. 0. ", (ftnlen)
	    80, (ftnlen)42);
    s_copy(pck + 21440, "0. 0. 0. 0. 0.   0. 0. 0. 0.  +0.28 ) ", (ftnlen)80, 
	    (ftnlen)38);
    s_copy(pck + 21520, "BODY703_NUT_PREC_PM   = (  0. 0. 0. 0. 0. ", (ftnlen)
	    80, (ftnlen)42);
    s_copy(pck + 21600, "0. 0. 0. 0. 0.   0. 0. 0. 0.  +0.08 ) ", (ftnlen)80, 
	    (ftnlen)38);
    s_copy(pck + 21680, "BODY704_POLE_RA       = (   257.43    0. 0.   ) ", (
	    ftnlen)80, (ftnlen)48);
    s_copy(pck + 21760, "BODY704_POLE_DEC      = (   -15.10    0. 0.   ) ", (
	    ftnlen)80, (ftnlen)48);
    s_copy(pck + 21840, "BODY704_PM            = (     6.77 -26.7394932  0. "
	    "  ) ", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 21920, "BODY704_LONG_AXIS     = (     0. ) ", (ftnlen)80, (
	    ftnlen)35);
    s_copy(pck + 22000, "BODY704_NUT_PREC_RA   = (  0. 0. 0. 0. 0. ", (ftnlen)
	    80, (ftnlen)42);
    s_copy(pck + 22080, "0. 0. 0. 0. 0. ", (ftnlen)80, (ftnlen)15);
    s_copy(pck + 22160, "0. 0. 0. 0. 0.  +0.16 ) ", (ftnlen)80, (ftnlen)24);
    s_copy(pck + 22240, "BODY704_NUT_PREC_DEC  = (  0. 0. 0. 0. 0. ", (ftnlen)
	    80, (ftnlen)42);
    s_copy(pck + 22320, "0. 0. 0. 0. 0. ", (ftnlen)80, (ftnlen)15);
    s_copy(pck + 22400, "0. 0. 0. 0. 0.  +0.16 ) ", (ftnlen)80, (ftnlen)24);
    s_copy(pck + 22480, "BODY704_NUT_PREC_PM   = (  0. 0. 0. 0. 0. ", (ftnlen)
	    80, (ftnlen)42);
    s_copy(pck + 22560, "0. 0. 0. 0. 0. ", (ftnlen)80, (ftnlen)15);
    s_copy(pck + 22640, "0. 0. 0. 0. 0.  +0.04 ) ", (ftnlen)80, (ftnlen)24);
    s_copy(pck + 22720, "BODY705_POLE_RA      = (   257.43     0. 0.   ) ", (
	    ftnlen)80, (ftnlen)48);
    s_copy(pck + 22800, "BODY705_POLE_DEC     = (   -15.08     0. 0.   ) ", (
	    ftnlen)80, (ftnlen)48);
    s_copy(pck + 22880, "BODY705_PM           = (    30.70 -254.6906892  0. "
	    "  ) ", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 22960, "BODY705_LONG_AXIS    = (     0. ) ", (ftnlen)80, (
	    ftnlen)34);
    s_copy(pck + 23040, "BODY705_NUT_PREC_RA  = (  0.     0. 0.    0.    0. ",
	     (ftnlen)80, (ftnlen)51);
    s_copy(pck + 23120, "0.     0.     0.    0.    0. ", (ftnlen)80, (ftnlen)
	    29);
    s_copy(pck + 23200, "4.41   0.     0.    0.    0. ", (ftnlen)80, (ftnlen)
	    29);
    s_copy(pck + 23280, "0.    -0.04                   ) ", (ftnlen)80, (
	    ftnlen)32);
    s_copy(pck + 23360, "BODY705_NUT_PREC_DEC = (  0.     0. 0.    0.    0. ",
	     (ftnlen)80, (ftnlen)51);
    s_copy(pck + 23440, "0.     0.     0.    0.    0. ", (ftnlen)80, (ftnlen)
	    29);
    s_copy(pck + 23520, "4.25   0.     0.    0.    0. ", (ftnlen)80, (ftnlen)
	    29);
    s_copy(pck + 23600, "0.    -0.02                   ) ", (ftnlen)80, (
	    ftnlen)32);
    s_copy(pck + 23680, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 23760, "BODY705_NUT_PREC_PM  = (  0.     0. 0.    0.    0. ",
	     (ftnlen)80, (ftnlen)51);
    s_copy(pck + 23840, "0.     0.     0.    0.    0. ", (ftnlen)80, (ftnlen)
	    29);
    s_copy(pck + 23920, "1.15  -1.27   0.    0.    0. ", (ftnlen)80, (ftnlen)
	    29);
    s_copy(pck + 24000, "0.    -0.09   0.15            ) ", (ftnlen)80, (
	    ftnlen)32);
    s_copy(pck + 24080, "BODY706_POLE_RA      = (   257.31 0.         0.   ) "
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 24160, "BODY706_POLE_DEC     = (   -15.18 0.         0.   ) "
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 24240, "BODY706_PM           = (   127.69 -1074.5205730  0."
	    "   ) ", (ftnlen)80, (ftnlen)56);
    s_copy(pck + 24320, "BODY706_LONG_AXIS    = (     0. ) ", (ftnlen)80, (
	    ftnlen)34);
    s_copy(pck + 24400, "BODY706_NUT_PREC_RA  = (  -0.15  ) ", (ftnlen)80, (
	    ftnlen)35);
    s_copy(pck + 24480, "BODY706_NUT_PREC_DEC = (  +0.14  ) ", (ftnlen)80, (
	    ftnlen)35);
    s_copy(pck + 24560, "BODY706_NUT_PREC_PM  = (  -0.04  ) ", (ftnlen)80, (
	    ftnlen)35);
    s_copy(pck + 24640, "BODY707_POLE_RA      = (   257.31 0.         0.   ) "
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 24720, "BODY707_POLE_DEC     = (   -15.18 0.         0.   ) "
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 24800, "BODY707_PM           = (   130.35 -956.4068150  0. "
	    "  ) ", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 24880, "BODY707_LONG_AXIS    = (     0. ) ", (ftnlen)80, (
	    ftnlen)34);
    s_copy(pck + 24960, "BODY707_NUT_PREC_RA  = ( 0.   -0.09 ) ", (ftnlen)80, 
	    (ftnlen)38);
    s_copy(pck + 25040, "BODY707_NUT_PREC_DEC = ( 0.   +0.09 ) ", (ftnlen)80, 
	    (ftnlen)38);
    s_copy(pck + 25120, "BODY707_NUT_PREC_PM  = ( 0.   -0.03 ) ", (ftnlen)80, 
	    (ftnlen)38);
    s_copy(pck + 25200, "BODY708_POLE_RA      = (   257.31 0.         0.   ) "
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 25280, "BODY708_POLE_DEC     = (   -15.18 0.         0.   ) "
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 25360, "BODY708_PM           = (   105.46 -828.3914760  0. "
	    "  ) ", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 25440, "BODY708_LONG_AXIS    = (     0. ) ", (ftnlen)80, (
	    ftnlen)34);
    s_copy(pck + 25520, "BODY708_NUT_PREC_RA  = ( 0. 0.  -0.16 ) ", (ftnlen)
	    80, (ftnlen)40);
    s_copy(pck + 25600, "BODY708_NUT_PREC_DEC = ( 0. 0.  +0.16 ) ", (ftnlen)
	    80, (ftnlen)40);
    s_copy(pck + 25680, "BODY708_NUT_PREC_PM  = ( 0. 0.  -0.04 ) ", (ftnlen)
	    80, (ftnlen)40);
    s_copy(pck + 25760, "BODY709_POLE_RA      = (   257.31 0.         0.   ) "
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 25840, "BODY709_POLE_DEC     = (   -15.18 0.         0.   ) "
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 25920, "BODY709_PM           = (    59.16 -776.5816320  0. "
	    "  ) ", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 26000, "BODY709_LONG_AXIS    = (     0. ) ", (ftnlen)80, (
	    ftnlen)34);
    s_copy(pck + 26080, "BODY709_NUT_PREC_RA  = ( 0. 0. 0. -0.04 ) ", (ftnlen)
	    80, (ftnlen)42);
    s_copy(pck + 26160, "BODY709_NUT_PREC_DEC = ( 0. 0. 0. +0.04 ) ", (ftnlen)
	    80, (ftnlen)42);
    s_copy(pck + 26240, "BODY709_NUT_PREC_PM  = ( 0. 0. 0. -0.01 ) ", (ftnlen)
	    80, (ftnlen)42);
    s_copy(pck + 26320, "BODY710_POLE_RA      = (   257.31 0.         0.   ) "
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 26400, "BODY710_POLE_DEC     = (   -15.18 0.         0.   ) "
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 26480, "BODY710_PM           = (    95.08 -760.0531690  0. "
	    "  ) ", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 26560, "BODY710_LONG_AXIS    = (     0. ) ", (ftnlen)80, (
	    ftnlen)34);
    s_copy(pck + 26640, "BODY710_NUT_PREC_RA  = ( 0. 0. 0.  0. -0.17 ) ", (
	    ftnlen)80, (ftnlen)46);
    s_copy(pck + 26720, "BODY710_NUT_PREC_DEC = ( 0. 0. 0.  0. +0.16 ) ", (
	    ftnlen)80, (ftnlen)46);
    s_copy(pck + 26800, "BODY710_NUT_PREC_PM  = ( 0. 0. 0.  0. -0.04 ) ", (
	    ftnlen)80, (ftnlen)46);
    s_copy(pck + 26880, "BODY711_POLE_RA      = (   257.31 0.         0.   ) "
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 26960, "BODY711_POLE_DEC     = (   -15.18 0.         0.   ) "
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 27040, "BODY711_PM           = (   302.56 -730.1253660  0. "
	    "  ) ", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 27120, "BODY711_LONG_AXIS    = (     0. ) ", (ftnlen)80, (
	    ftnlen)34);
    s_copy(pck + 27200, "BODY711_NUT_PREC_RA  = ( 0. 0. 0. 0. 0. -0.06 ) ", (
	    ftnlen)80, (ftnlen)48);
    s_copy(pck + 27280, "BODY711_NUT_PREC_DEC = ( 0. 0. 0. 0. 0. +0.06 ) ", (
	    ftnlen)80, (ftnlen)48);
    s_copy(pck + 27360, "BODY711_NUT_PREC_PM  = ( 0. 0. 0. 0. 0. -0.02 ) ", (
	    ftnlen)80, (ftnlen)48);
    s_copy(pck + 27440, "BODY712_POLE_RA      = (   257.31 0.         0.   ) "
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 27520, "BODY712_POLE_DEC     = (   -15.18 0.         0.   ) "
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 27600, "BODY712_PM           = (    25.03 -701.4865870  0. "
	    "  ) ", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 27680, "BODY712_LONG_AXIS    = (     0. ) ", (ftnlen)80, (
	    ftnlen)34);
    s_copy(pck + 27760, "BODY712_NUT_PREC_RA  = ( 0. 0. 0. 0. 0. 0.  -0.09 ) "
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 27840, "BODY712_NUT_PREC_DEC = ( 0. 0. 0. 0. 0. 0.  +0.09 ) "
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 27920, "BODY712_NUT_PREC_PM  = ( 0. 0. 0. 0. 0. 0.  -0.02 ) "
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 28000, "BODY713_POLE_RA      = (   257.31 0.         0.   ) "
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 28080, "BODY713_POLE_DEC     = (   -15.18 0.         0.   ) "
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 28160, "BODY713_PM           = (   314.90 -644.6311260  0. "
	    "  ) ", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 28240, "BODY713_LONG_AXIS    = (     0. ) ", (ftnlen)80, (
	    ftnlen)34);
    s_copy(pck + 28320, "BODY713_NUT_PREC_RA  = ( 0. 0. 0. 0. 0. 0. 0.   -0."
	    "29 ) ", (ftnlen)80, (ftnlen)56);
    s_copy(pck + 28400, "BODY713_NUT_PREC_DEC = ( 0. 0. 0. 0. 0. 0. 0.   +0."
	    "28 ) ", (ftnlen)80, (ftnlen)56);
    s_copy(pck + 28480, "BODY713_NUT_PREC_PM  = ( 0. 0. 0. 0. 0. 0. 0.   -0."
	    "08 ) ", (ftnlen)80, (ftnlen)56);
    s_copy(pck + 28560, "BODY714_POLE_RA      = (   257.31 0.         0.   ) "
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 28640, "BODY714_POLE_DEC     = (   -15.18 0.         0.   ) "
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 28720, "BODY714_PM           = (   297.46 -577.3628170  0. "
	    "  ) ", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 28800, "BODY714_LONG_AXIS    = (     0. ) ", (ftnlen)80, (
	    ftnlen)34);
    s_copy(pck + 28880, "BODY714_NUT_PREC_RA  = ( 0. 0. 0. 0. 0. 0. 0. 0.   "
	    "-0.03 ) ", (ftnlen)80, (ftnlen)59);
    s_copy(pck + 28960, "BODY714_NUT_PREC_DEC = ( 0. 0. 0. 0. 0. 0. 0. 0.   "
	    "+0.03 ) ", (ftnlen)80, (ftnlen)59);
    s_copy(pck + 29040, "BODY714_NUT_PREC_PM  = ( 0. 0. 0. 0. 0. 0. 0. 0.   "
	    "-0.01 ) ", (ftnlen)80, (ftnlen)59);
    s_copy(pck + 29120, "BODY715_POLE_RA      = (   257.31 0.         0.   ) "
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 29200, "BODY715_POLE_DEC     = (   -15.18 0.         0.   ) "
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 29280, "BODY715_PM           = (    91.24 -472.5450690  0. "
	    "  ) ", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 29360, "BODY715_LONG_AXIS    = (     0. ) ", (ftnlen)80, (
	    ftnlen)34);
    s_copy(pck + 29440, "BODY715_NUT_PREC_RA  = ( 0. 0. 0. 0. 0. 0. 0. 0. 0."
	    "   -0.33 ) ", (ftnlen)80, (ftnlen)62);
    s_copy(pck + 29520, "BODY715_NUT_PREC_DEC = ( 0. 0. 0. 0. 0. 0. 0. 0. 0."
	    "   +0.31 ) ", (ftnlen)80, (ftnlen)62);
    s_copy(pck + 29600, "BODY715_NUT_PREC_PM  = ( 0. 0. 0. 0. 0. 0. 0. 0. 0."
	    "   -0.99 ) ", (ftnlen)80, (ftnlen)62);
    s_copy(pck + 29680, "BODY801_POLE_RA       = (   298.72    0. 0.  ) ", (
	    ftnlen)80, (ftnlen)47);
    s_copy(pck + 29760, "BODY801_POLE_DEC      = (   +40.59    0. 0.  ) ", (
	    ftnlen)80, (ftnlen)47);
    s_copy(pck + 29840, "BODY801_PM            = (   297.14 -61.2572675  0. "
	    " ) ", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 29920, "BODY801_LONG_AXIS     = (     0. ) ", (ftnlen)80, (
	    ftnlen)35);
    s_copy(pck + 30000, "BODY801_NUT_PREC_RA   = (  -30.72    0. -5.58   -1."
	    "75 ", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 30080, "-0.58   -0.21   -0.08   -0.03  -0.01  ) ", (ftnlen)
	    80, (ftnlen)40);
    s_copy(pck + 30160, "BODY801_NUT_PREC_DEC  = (  +21.79    0. +1.91   +0."
	    "48 ", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 30240, "+0.13   +0.04   +0.01            ) ", (ftnlen)80, (
	    ftnlen)35);
    s_copy(pck + 30320, "BODY801_NUT_PREC_PM   = (  +20.81    0. +6.01   +1."
	    "73  +0.59 ", (ftnlen)80, (ftnlen)61);
    s_copy(pck + 30400, "+0.21   +0.08   +0.03   +0.01         ) ", (ftnlen)
	    80, (ftnlen)40);
    s_copy(pck + 30480, "BODY802_POLE_RA       = (    273.48 0.        0.  ) "
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 30560, "BODY802_POLE_DEC      = (     67.22 0.        0.  ) "
	    , (ftnlen)80, (ftnlen)52);
    s_copy(pck + 30640, "BODY802_PM            = (    237.22 +0.9996465 0.  "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 30720, "BODY802_LONG_AXIS     = (      0. ) ", (ftnlen)80, (
	    ftnlen)36);
    s_copy(pck + 30800, "BODY802_NUT_PREC_RA   = (  0.    -17.81 ", (ftnlen)
	    80, (ftnlen)40);
    s_copy(pck + 30880, "0.      0.     0.      0. ", (ftnlen)80, (ftnlen)26);
    s_copy(pck + 30960, "0.      0.     0. ", (ftnlen)80, (ftnlen)18);
    s_copy(pck + 31040, "+2.56   -0.51  +0.11   -0.03  ) ", (ftnlen)80, (
	    ftnlen)32);
    s_copy(pck + 31120, "BODY802_NUT_PREC_DEC  = (  0.     -6.67 ", (ftnlen)
	    80, (ftnlen)40);
    s_copy(pck + 31200, "0.      0.     0.      0. ", (ftnlen)80, (ftnlen)26);
    s_copy(pck + 31280, "0.      0.     0. ", (ftnlen)80, (ftnlen)18);
    s_copy(pck + 31360, "+0.47   -0.07  +0.01          ) ", (ftnlen)80, (
	    ftnlen)32);
    s_copy(pck + 31440, "BODY802_NUT_PREC_PM   = (  0.     16.48 ", (ftnlen)
	    80, (ftnlen)40);
    s_copy(pck + 31520, "0.      0.     0.      0. ", (ftnlen)80, (ftnlen)26);
    s_copy(pck + 31600, "0.      0.     0. ", (ftnlen)80, (ftnlen)18);
    s_copy(pck + 31680, "-2.57   +0.51 -0.11   +0.02  ) ", (ftnlen)80, (
	    ftnlen)31);
    s_copy(pck + 31760, "BODY901_POLE_RA       = (    312.98 0.         0.  "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 31840, "BODY901_POLE_DEC      = (     +8.49 0.         0.  "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 31920, "BODY901_PM            = (     56.11 -56.3624607  0."
	    "  ) ", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 32000, "BODY901_LONG_AXIS     = (      0. ) ", (ftnlen)80, (
	    ftnlen)36);
    s_copy(pck + 32080, "BODY10_RADII      = (   696000. 696000.      696000"
	    ".     ) ", (ftnlen)80, (ftnlen)59);
    s_copy(pck + 32160, "BODY199_RADII     = (     2439.7 2439.7      2439.7"
	    "     ) ", (ftnlen)80, (ftnlen)58);
    s_copy(pck + 32240, "BODY299_RADII     = (     6051.9 6051.9      6051.9"
	    "     ) ", (ftnlen)80, (ftnlen)58);
    s_copy(pck + 32320, "BODY399_RADII     = (     6378.140 6378.140     635"
	    "6.75   ) ", (ftnlen)80, (ftnlen)60);
    s_copy(pck + 32400, "BODY499_RADII       = (     3397. 3397.         337"
	    "5.     ) ", (ftnlen)80, (ftnlen)60);
    s_copy(pck + 32480, "BODY599_RADII     = (    71492. 71492.       66854."
	    "     ) ", (ftnlen)80, (ftnlen)58);
    s_copy(pck + 32560, "BODY699_RADII     = (    60268. 60268.       54364."
	    "     ) ", (ftnlen)80, (ftnlen)58);
    s_copy(pck + 32640, "BODY799_RADII     = (    25559. 25559.       24973."
	    "     ) ", (ftnlen)80, (ftnlen)58);
    s_copy(pck + 32720, "BODY899_RADII   = (    25269. 25269.       24800   "
	    "   ) ", (ftnlen)80, (ftnlen)56);
    s_copy(pck + 32800, "BODY999_RADII     = (     1162. 1162.        1162. "
	    "    ) ", (ftnlen)80, (ftnlen)57);
    s_copy(pck + 32880, "BODY9511010_RADII     =   (  9 5.5         5  ) ", (
	    ftnlen)80, (ftnlen)48);
    s_copy(pck + 32960, "BODY301_RADII     = (     1737.4 1737.4       1737."
	    "4    ) ", (ftnlen)80, (ftnlen)58);
    s_copy(pck + 33040, "BODY401_RADII     = (       13.4 11.2          9.2 "
	    "   ) ", (ftnlen)80, (ftnlen)56);
    s_copy(pck + 33120, "BODY402_RADII     = (        7.5 6.1          5.2  "
	    "  ) ", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 33200, "BODY501_RADII     = (     1830. 1818.7       1815.3"
	    "    ) ", (ftnlen)80, (ftnlen)57);
    s_copy(pck + 33280, "BODY502_RADII     = (     1565. 1565.        1565. "
	    "    ) ", (ftnlen)80, (ftnlen)57);
    s_copy(pck + 33360, "BODY503_RADII     = (     2634. 2634.        2634. "
	    "    ) ", (ftnlen)80, (ftnlen)57);
    s_copy(pck + 33440, "BODY504_RADII     = (     2403. 2403.        2403. "
	    "    ) ", (ftnlen)80, (ftnlen)57);
    s_copy(pck + 33520, "BODY505_RADII     = (      131. 73.          67.   "
	    "  ) ", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 33600, "BODY506_RADII    = (  85      85      85 ) ", (
	    ftnlen)80, (ftnlen)43);
    s_copy(pck + 33680, "BODY507_RADII    = (  40      40      40 ) ", (
	    ftnlen)80, (ftnlen)43);
    s_copy(pck + 33760, "BODY508_RADII    = (  18      18      18 ) ", (
	    ftnlen)80, (ftnlen)43);
    s_copy(pck + 33840, "BODY509_RADII    = (  14      14      14 ) ", (
	    ftnlen)80, (ftnlen)43);
    s_copy(pck + 33920, "BODY510_RADII    = (  12      12      12 ) ", (
	    ftnlen)80, (ftnlen)43);
    s_copy(pck + 34000, "BODY511_RADII    = (  15      15      15 ) ", (
	    ftnlen)80, (ftnlen)43);
    s_copy(pck + 34080, "BODY512_RADII    = (  10      10      10 ) ", (
	    ftnlen)80, (ftnlen)43);
    s_copy(pck + 34160, "BODY513_RADII    = (   5       5       5 ) ", (
	    ftnlen)80, (ftnlen)43);
    s_copy(pck + 34240, "BODY514_RADII    = (  55      55    45 ) ", (ftnlen)
	    80, (ftnlen)41);
    s_copy(pck + 34320, "BODY515_RADII    = (  13      10     8 ) ", (ftnlen)
	    80, (ftnlen)41);
    s_copy(pck + 34400, "BODY516_RADII    = (  20      20    20 ) ", (ftnlen)
	    80, (ftnlen)41);
    s_copy(pck + 34480, "BODY601_RADII     = (      210.3 197.4        192.6"
	    "    ) ", (ftnlen)80, (ftnlen)57);
    s_copy(pck + 34560, "BODY602_RADII     = (      256.2 247.3        244.0"
	    "    ) ", (ftnlen)80, (ftnlen)57);
    s_copy(pck + 34640, "BODY603_RADII     = (      523. 523.         523.  "
	    "   ) ", (ftnlen)80, (ftnlen)56);
    s_copy(pck + 34720, "BODY604_RADII     = (      560. 560.         560.  "
	    "   ) ", (ftnlen)80, (ftnlen)56);
    s_copy(pck + 34800, "BODY605_RADII     = (      764. 764.         764.  "
	    "   ) ", (ftnlen)80, (ftnlen)56);
    s_copy(pck + 34880, "BODY606_RADII     = (     2575. 2575.        2575. "
	    "    ) ", (ftnlen)80, (ftnlen)57);
    s_copy(pck + 34960, "BODY607_RADII     = (      180. 140.         112.5 "
	    "   ) ", (ftnlen)80, (ftnlen)56);
    s_copy(pck + 35040, "BODY608_RADII     = (      718. 718.         718.  "
	    "   ) ", (ftnlen)80, (ftnlen)56);
    s_copy(pck + 35120, "BODY609_RADII     = (      115. 110.         105.  "
	    "   ) ", (ftnlen)80, (ftnlen)56);
    s_copy(pck + 35200, "BODY610_RADII     = (       97. 95.          77.   "
	    "  ) ", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 35280, "BODY611_RADII     = (       69. 55.          55.   "
	    "  ) ", (ftnlen)80, (ftnlen)55);
    s_copy(pck + 35360, "BODY612_RADII     = (       17.5 16.          15.  "
	    "   ) ", (ftnlen)80, (ftnlen)56);
    s_copy(pck + 35440, "BODY613_RADII     = (       15 12.5          7.5   "
	    " ) ", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 35520, "BODY614_RADII     = (       15 8            8      "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 35600, "BODY615_RADII     = (       18.5 17.2         13.5 "
	    "   ) ", (ftnlen)80, (ftnlen)56);
    s_copy(pck + 35680, "BODY616_RADII     = (       74 50           34     "
	    " ) ", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 35760, "BODY617_RADII     = (       55 44           31     "
	    " ) ", (ftnlen)80, (ftnlen)54);
    s_copy(pck + 35840, "BODY701_RADII     = (      581.1 577.9        577.7"
	    "    ) ", (ftnlen)80, (ftnlen)57);
    s_copy(pck + 35920, "BODY702_RADII     = (      584.7 584.7        584.7"
	    "    ) ", (ftnlen)80, (ftnlen)57);
    s_copy(pck + 36000, "BODY703_RADII     = (      788.9 788.9        788.9"
	    "    ) ", (ftnlen)80, (ftnlen)57);
    s_copy(pck + 36080, "BODY704_RADII     = (      761.4 761.4        761.4"
	    "    ) ", (ftnlen)80, (ftnlen)57);
    s_copy(pck + 36160, "BODY705_RADII     = (      240.4 234.2        232.9"
	    "    ) ", (ftnlen)80, (ftnlen)57);
    s_copy(pck + 36240, "BODY706_RADII     = (      13. 13.          13.    "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 36320, "BODY707_RADII     = (      15. 15.          15.    "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 36400, "BODY708_RADII     = (      21. 21.          21.    "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 36480, "BODY709_RADII     = (      31. 31.          31.    "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 36560, "BODY710_RADII     = (      27. 27.          27.    "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 36640, "BODY711_RADII     = (      42. 42.          42.    "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 36720, "BODY712_RADII     = (      54. 54.          54.    "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 36800, "BODY713_RADII     = (      27. 27.          27.    "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 36880, "BODY714_RADII     = (      33. 33.          33.    "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 36960, "BODY715_RADII     = (      77. 77.          77.    "
	    ") ", (ftnlen)80, (ftnlen)53);
    s_copy(pck + 37040, "BODY801_RADII     = (     1750. 1750.        1750. "
	    "    ) ", (ftnlen)80, (ftnlen)57);
    s_copy(pck + 37120, "BODY802_RADII     = (      345. 345.         345.  "
	    "   ) ", (ftnlen)80, (ftnlen)56);
    s_copy(pck + 37200, "BODY901_RADII     = (      606. 606.         606.  "
	    "   ) ", (ftnlen)80, (ftnlen)56);

/*     Create the SCLK kernel. */

    txtopn_(namepc, &unit, namepc_len);
    for (i__ = 1; i__ <= 466; ++i__) {
	r__ = rtrim_(pck + ((i__1 = i__ - 1) < 466 && 0 <= i__1 ? i__1 : 
		s_rnge("pck", i__1, "tstpck_", (ftnlen)1005)) * 80, (ftnlen)
		80);
	io___5.ciunit = unit;
	s_wsle(&io___5);
	do_lio(&c__9, &c__1, pck + ((i__1 = i__ - 1) < 466 && 0 <= i__1 ? 
		i__1 : s_rnge("pck", i__1, "tstpck_", (ftnlen)1006)) * 80, 
		r__);
	e_wsle();
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
} /* tstpck_ */

