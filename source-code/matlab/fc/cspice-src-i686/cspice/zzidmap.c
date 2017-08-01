/* zzidmap.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* $Procedure ZZIDMAP ( SPICE body ID/name assignments ) */
/* Subroutine */ int zzidmap_(integer *bltcod, char *bltnam, ftnlen 
	bltnam_len)
{
    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

/* $ Abstract */

/*     The default SPICE body/ID mapping assignments available */
/*     to the SPICE library. */

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

/*     naif_ids.req */

/* $ Keywords */

/*     Body mappings. */

/* $ Declarations */
/* $ Abstract */

/*     This include file lists the parameter collection */
/*     defining the number of SPICE ID -> NAME mappings. */

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

/*     naif_ids.req */

/* $ Keywords */

/*     Body mappings. */

/* $ Author_and_Institution */

/*     E.D. Wright (JPL) */

/* $ Version */

/*     SPICELIB 1.0.0 Tue Nov 15 13:59:42 2005 (EDW) */


/*     A script generates this file. Do not edit by hand. */
/*     Edit the creation script to modify the contents of */
/*     ZZBODTRN.INC. */


/*     Maximum size of a NAME string */


/*     Count of default SPICE mapping assignments. */

/* $ Brief_I/O */

/*     Variable  I/O  Description */
/*     --------  ---  -------------------------------------------------- */
/*     BLTCOD     O  List of default integer ID codes */
/*     BLTNAM     O  List of default names */
/*     NPERM      P  Number of name/ID mappings */

/* $ Detailed_Input */

/*     None. */

/* $ Detailed_Output */

/*     BLTCOD     The array of NPERM elements listing the body ID codes. */

/*     BLTNAM     The array of NPERM elements listing the body names */
/*                corresponding to the ID entry in BLTCOD */

/* $ Parameters */

/*     NPERM      The length of both BLTCOD, BLTNAM */
/*                (read from zzbodtrn.inc). */

/* $ Exceptions */

/*     None. */

/* $ Files */

/*     None. */

/* $ Particulars */

/*     Each ith entry of BLTCOD maps to the ith entry of BLTNAM. */

/* $ Examples */

/*     Simple to use, a call the ZZIDMAP returns the arrays defining the */
/*     name/ID mappings. */


/*        INCLUDE            'zzbodtrn.inc' */

/*        INTEGER             ID  ( NPERM ) */
/*        CHARACTER*(MAXL)    NAME( NPERM ) */

/*        CALL ZZIDMAP( ID, NAME ) */

/* $ Restrictions */

/*     None. */

/* $ Literature_References */

/*     None. */

/* $ Author_and_Institution */

/*     E.D. Wright, Tue Nov 15 13:59:42 2005 (JPL) */

/* $ Version */

/* -    SPICELIB 1.0.3 14-NOV-2005 (EDW) */

/*     Added: */

/*              539   HEGEMONE */
/*              540   MNEME */
/*              541   AOEDE */
/*              542   THELXINOE */
/*              543   ARCHE */
/*              544   KALLICHORE */
/*              545   HELIKE */
/*              546   CARPO */
/*              547   EUKELADE */
/*              548   CYLLENE */
/*              631   NARVI */
/*              632   METHODE */
/*              633   PALLENE */
/*              634   POLYDEUCES */
/*          2025143   ITOKAWA */
/*              -98   NEW HORIZONS */
/*             -248   VENUS EXPRESS, VEX */
/*             -500   RSAT, SELENE Relay Satellite, SELENE Rstar, Rstar */
/*             -502   VSAT, SELENE VLBI Radio Satellite, */
/*                    SELENE VRAD Satellite, SELENE Vstar */
/*           399064   DSS-64 */

/*      Change in spelling: */

/*              623   SUTTUNG to SUTTUNGR */
/*              627   SKADI   to SKATHI */
/*              630   THRYM   to THRYMR */

/* -    SPICELIB 1.0.2 20-DEC-2004 (EDW) */

/*     Added: */

/*           Due to the previous definition of Parkes with DSS-05, */
/*           the Parkes ID remains 399005. */

/*             -486   HERSCHEL */
/*             -489   PLANCK */
/*           399049   DSS-49 */
/*           399055   DSS-55 */
/*             -203   DAWN */
/*          1000012   67P/CHURYUMOV-GERASIMENKO (1969 R1) */
/*          1000012   CHURYUMOV-GERASIMENKO */
/*          398989    NOTO */
/*             -84    PHOENIX */
/*            -131    SELENE */
/*            -238    SMART-1, S1, SM1, SMART1 */
/*            -130    HAYABUSA */

/* -    SPICELIB 1.0.1 19-DEC-2003 (EDW) */

/*     Added: */
/*              -79   SPITZER */
/*          2000216   KLEOPATRA */

/* -    SPICELIB 1.0.0 27-JUL-2003 (EDW) */

/*     Added: */
/*              -47   GNS */
/*              -74   MRO */
/*              -74   MARS RECON ORBITER */
/*             -130   MUSES-C */
/*             -142   TERRA */
/*             -154   AQUA */
/*             -159   EUROPA ORBITER */
/*             -190   SIM */
/*             -198   INTEGRAL */
/*             -227   KEPLER */
/*             -234   STEREO AHEAD */
/*             -235   STEREO BEHIND */
/*             -253   OPPORTUNITY */
/*             -254   SPIRIT */
/*              528   AUTONOE */
/*              529   THYONE */
/*              530   HERMIPPE */
/*              531   AITNE */
/*              532   EURYDOME */
/*              533   EUANTHE */
/*              534   EUPORIE */
/*              535   ORTHOSIE */
/*              536   SPONDE */
/*              537   KALE */
/*              538   PASITHEE */
/*              619   YMIR */
/*              620   PAALIAQ */
/*              621   TARVOS */
/*              622   IJIRAQ */
/*              623   SUTTUNG */
/*              624   KIVIUQ */
/*              625   MUNDILFARI */
/*              626   ALBIORIX */
/*              627   SKADI */
/*              628   ERRIAPO */
/*              629   SIARNAQ */
/*              630   THRYM */
/*              718   PROSPERO */
/*              719   SETEBOS */
/*              720   STEPHANO */
/*              721   TRINCULO */
/*           398990   NEW NORCIA */
/*          2431011   DACTYL */
/*          2000001   CERES */
/*          2000004   VESTA */

/*     Renamed: */

/*              -25   LPM to */
/*              -25   LP */

/*             -180   MUSES-C to */
/*             -130   MUSES-B */

/*             -172   STARLIGHT COMBINER to */
/*             -172   SPACETECH-3 COMBINER */

/*             -205   STARLIGHT COLLECTOR to */
/*             -205   SPACETECH-3 COLLECTOR */

/*      Removed: */
/*             -172   SLCOMB */


/* -& */
/* $ Index_Entries */

/*     body ID mapping */

/* -& */

/*     A script generates this file. Do not edit by hand. */
/*     Edit the creation script to modify the contents of */
/*     ZZIDMAP. */

    bltcod[0] = 0;
    s_copy(bltnam, "SSB", (ftnlen)36, (ftnlen)3);
    bltcod[1] = 0;
    s_copy(bltnam + 36, "SOLAR SYSTEM BARYCENTER", (ftnlen)36, (ftnlen)23);
    bltcod[2] = 1;
    s_copy(bltnam + 72, "MERCURY BARYCENTER", (ftnlen)36, (ftnlen)18);
    bltcod[3] = 2;
    s_copy(bltnam + 108, "VENUS BARYCENTER", (ftnlen)36, (ftnlen)16);
    bltcod[4] = 3;
    s_copy(bltnam + 144, "EMB", (ftnlen)36, (ftnlen)3);
    bltcod[5] = 3;
    s_copy(bltnam + 180, "EARTH MOON BARYCENTER", (ftnlen)36, (ftnlen)21);
    bltcod[6] = 3;
    s_copy(bltnam + 216, "EARTH-MOON BARYCENTER", (ftnlen)36, (ftnlen)21);
    bltcod[7] = 3;
    s_copy(bltnam + 252, "EARTH BARYCENTER", (ftnlen)36, (ftnlen)16);
    bltcod[8] = 4;
    s_copy(bltnam + 288, "MARS BARYCENTER", (ftnlen)36, (ftnlen)15);
    bltcod[9] = 5;
    s_copy(bltnam + 324, "JUPITER BARYCENTER", (ftnlen)36, (ftnlen)18);
    bltcod[10] = 6;
    s_copy(bltnam + 360, "SATURN BARYCENTER", (ftnlen)36, (ftnlen)17);
    bltcod[11] = 7;
    s_copy(bltnam + 396, "URANUS BARYCENTER", (ftnlen)36, (ftnlen)17);
    bltcod[12] = 8;
    s_copy(bltnam + 432, "NEPTUNE BARYCENTER", (ftnlen)36, (ftnlen)18);
    bltcod[13] = 9;
    s_copy(bltnam + 468, "PLUTO BARYCENTER", (ftnlen)36, (ftnlen)16);
    bltcod[14] = 10;
    s_copy(bltnam + 504, "SUN", (ftnlen)36, (ftnlen)3);
    bltcod[15] = 199;
    s_copy(bltnam + 540, "MERCURY", (ftnlen)36, (ftnlen)7);
    bltcod[16] = 299;
    s_copy(bltnam + 576, "VENUS", (ftnlen)36, (ftnlen)5);
    bltcod[17] = 399;
    s_copy(bltnam + 612, "EARTH", (ftnlen)36, (ftnlen)5);
    bltcod[18] = 301;
    s_copy(bltnam + 648, "MOON", (ftnlen)36, (ftnlen)4);
    bltcod[19] = 499;
    s_copy(bltnam + 684, "MARS", (ftnlen)36, (ftnlen)4);
    bltcod[20] = 401;
    s_copy(bltnam + 720, "PHOBOS", (ftnlen)36, (ftnlen)6);
    bltcod[21] = 402;
    s_copy(bltnam + 756, "DEIMOS", (ftnlen)36, (ftnlen)6);
    bltcod[22] = 599;
    s_copy(bltnam + 792, "JUPITER", (ftnlen)36, (ftnlen)7);
    bltcod[23] = 501;
    s_copy(bltnam + 828, "IO", (ftnlen)36, (ftnlen)2);
    bltcod[24] = 502;
    s_copy(bltnam + 864, "EUROPA", (ftnlen)36, (ftnlen)6);
    bltcod[25] = 503;
    s_copy(bltnam + 900, "GANYMEDE", (ftnlen)36, (ftnlen)8);
    bltcod[26] = 504;
    s_copy(bltnam + 936, "CALLISTO", (ftnlen)36, (ftnlen)8);
    bltcod[27] = 505;
    s_copy(bltnam + 972, "AMALTHEA", (ftnlen)36, (ftnlen)8);
    bltcod[28] = 506;
    s_copy(bltnam + 1008, "HIMALIA", (ftnlen)36, (ftnlen)7);
    bltcod[29] = 507;
    s_copy(bltnam + 1044, "ELARA", (ftnlen)36, (ftnlen)5);
    bltcod[30] = 508;
    s_copy(bltnam + 1080, "PASIPHAE", (ftnlen)36, (ftnlen)8);
    bltcod[31] = 509;
    s_copy(bltnam + 1116, "SINOPE", (ftnlen)36, (ftnlen)6);
    bltcod[32] = 510;
    s_copy(bltnam + 1152, "LYSITHEA", (ftnlen)36, (ftnlen)8);
    bltcod[33] = 511;
    s_copy(bltnam + 1188, "CARME", (ftnlen)36, (ftnlen)5);
    bltcod[34] = 512;
    s_copy(bltnam + 1224, "ANANKE", (ftnlen)36, (ftnlen)6);
    bltcod[35] = 513;
    s_copy(bltnam + 1260, "LEDA", (ftnlen)36, (ftnlen)4);
    bltcod[36] = 514;
    s_copy(bltnam + 1296, "1979J2", (ftnlen)36, (ftnlen)6);
    bltcod[37] = 514;
    s_copy(bltnam + 1332, "THEBE", (ftnlen)36, (ftnlen)5);
    bltcod[38] = 515;
    s_copy(bltnam + 1368, "1979J1", (ftnlen)36, (ftnlen)6);
    bltcod[39] = 515;
    s_copy(bltnam + 1404, "ADRASTEA", (ftnlen)36, (ftnlen)8);
    bltcod[40] = 516;
    s_copy(bltnam + 1440, "1979J3", (ftnlen)36, (ftnlen)6);
    bltcod[41] = 516;
    s_copy(bltnam + 1476, "METIS", (ftnlen)36, (ftnlen)5);
    bltcod[42] = 517;
    s_copy(bltnam + 1512, "CALLIRRHOE", (ftnlen)36, (ftnlen)10);
    bltcod[43] = 518;
    s_copy(bltnam + 1548, "THEMISTO", (ftnlen)36, (ftnlen)8);
    bltcod[44] = 519;
    s_copy(bltnam + 1584, "MAGACLITE", (ftnlen)36, (ftnlen)9);
    bltcod[45] = 520;
    s_copy(bltnam + 1620, "TAYGETE", (ftnlen)36, (ftnlen)7);
    bltcod[46] = 521;
    s_copy(bltnam + 1656, "CHALDENE", (ftnlen)36, (ftnlen)8);
    bltcod[47] = 522;
    s_copy(bltnam + 1692, "HARPALYKE", (ftnlen)36, (ftnlen)9);
    bltcod[48] = 523;
    s_copy(bltnam + 1728, "KALYKE", (ftnlen)36, (ftnlen)6);
    bltcod[49] = 524;
    s_copy(bltnam + 1764, "IOCASTE", (ftnlen)36, (ftnlen)7);
    bltcod[50] = 525;
    s_copy(bltnam + 1800, "ERINOME", (ftnlen)36, (ftnlen)7);
    bltcod[51] = 526;
    s_copy(bltnam + 1836, "ISONOE", (ftnlen)36, (ftnlen)6);
    bltcod[52] = 527;
    s_copy(bltnam + 1872, "PRAXIDIKE", (ftnlen)36, (ftnlen)9);
    bltcod[53] = 528;
    s_copy(bltnam + 1908, "AUTONOE", (ftnlen)36, (ftnlen)7);
    bltcod[54] = 529;
    s_copy(bltnam + 1944, "THYONE", (ftnlen)36, (ftnlen)6);
    bltcod[55] = 530;
    s_copy(bltnam + 1980, "HERMIPPE", (ftnlen)36, (ftnlen)8);
    bltcod[56] = 531;
    s_copy(bltnam + 2016, "AITNE", (ftnlen)36, (ftnlen)5);
    bltcod[57] = 532;
    s_copy(bltnam + 2052, "EURYDOME", (ftnlen)36, (ftnlen)8);
    bltcod[58] = 533;
    s_copy(bltnam + 2088, "EUANTHE", (ftnlen)36, (ftnlen)7);
    bltcod[59] = 534;
    s_copy(bltnam + 2124, "EUPORIE", (ftnlen)36, (ftnlen)7);
    bltcod[60] = 535;
    s_copy(bltnam + 2160, "ORTHOSIE", (ftnlen)36, (ftnlen)8);
    bltcod[61] = 536;
    s_copy(bltnam + 2196, "SPONDE", (ftnlen)36, (ftnlen)6);
    bltcod[62] = 537;
    s_copy(bltnam + 2232, "KALE", (ftnlen)36, (ftnlen)4);
    bltcod[63] = 538;
    s_copy(bltnam + 2268, "PASITHEE", (ftnlen)36, (ftnlen)8);
    bltcod[64] = 539;
    s_copy(bltnam + 2304, "HEGEMONE", (ftnlen)36, (ftnlen)8);
    bltcod[65] = 540;
    s_copy(bltnam + 2340, "MNEME", (ftnlen)36, (ftnlen)5);
    bltcod[66] = 541;
    s_copy(bltnam + 2376, "AOEDE", (ftnlen)36, (ftnlen)5);
    bltcod[67] = 542;
    s_copy(bltnam + 2412, "THELXINOE", (ftnlen)36, (ftnlen)9);
    bltcod[68] = 543;
    s_copy(bltnam + 2448, "ARCHE", (ftnlen)36, (ftnlen)5);
    bltcod[69] = 544;
    s_copy(bltnam + 2484, "KALLICHORE", (ftnlen)36, (ftnlen)10);
    bltcod[70] = 545;
    s_copy(bltnam + 2520, "HELIKE", (ftnlen)36, (ftnlen)6);
    bltcod[71] = 546;
    s_copy(bltnam + 2556, "CARPO", (ftnlen)36, (ftnlen)5);
    bltcod[72] = 547;
    s_copy(bltnam + 2592, "EUKELADE", (ftnlen)36, (ftnlen)8);
    bltcod[73] = 548;
    s_copy(bltnam + 2628, "CYLLENE", (ftnlen)36, (ftnlen)7);
    bltcod[74] = 699;
    s_copy(bltnam + 2664, "SATURN", (ftnlen)36, (ftnlen)6);
    bltcod[75] = 601;
    s_copy(bltnam + 2700, "MIMAS", (ftnlen)36, (ftnlen)5);
    bltcod[76] = 602;
    s_copy(bltnam + 2736, "ENCELADUS", (ftnlen)36, (ftnlen)9);
    bltcod[77] = 603;
    s_copy(bltnam + 2772, "TETHYS", (ftnlen)36, (ftnlen)6);
    bltcod[78] = 604;
    s_copy(bltnam + 2808, "DIONE", (ftnlen)36, (ftnlen)5);
    bltcod[79] = 605;
    s_copy(bltnam + 2844, "RHEA", (ftnlen)36, (ftnlen)4);
    bltcod[80] = 606;
    s_copy(bltnam + 2880, "TITAN", (ftnlen)36, (ftnlen)5);
    bltcod[81] = 607;
    s_copy(bltnam + 2916, "HYPERION", (ftnlen)36, (ftnlen)8);
    bltcod[82] = 608;
    s_copy(bltnam + 2952, "IAPETUS", (ftnlen)36, (ftnlen)7);
    bltcod[83] = 609;
    s_copy(bltnam + 2988, "PHOEBE", (ftnlen)36, (ftnlen)6);
    bltcod[84] = 610;
    s_copy(bltnam + 3024, "1980S1", (ftnlen)36, (ftnlen)6);
    bltcod[85] = 610;
    s_copy(bltnam + 3060, "JANUS", (ftnlen)36, (ftnlen)5);
    bltcod[86] = 611;
    s_copy(bltnam + 3096, "1980S3", (ftnlen)36, (ftnlen)6);
    bltcod[87] = 611;
    s_copy(bltnam + 3132, "EPIMETHEUS", (ftnlen)36, (ftnlen)10);
    bltcod[88] = 612;
    s_copy(bltnam + 3168, "1980S6", (ftnlen)36, (ftnlen)6);
    bltcod[89] = 612;
    s_copy(bltnam + 3204, "HELENE", (ftnlen)36, (ftnlen)6);
    bltcod[90] = 613;
    s_copy(bltnam + 3240, "1980S13", (ftnlen)36, (ftnlen)7);
    bltcod[91] = 613;
    s_copy(bltnam + 3276, "TELESTO", (ftnlen)36, (ftnlen)7);
    bltcod[92] = 614;
    s_copy(bltnam + 3312, "1980S25", (ftnlen)36, (ftnlen)7);
    bltcod[93] = 614;
    s_copy(bltnam + 3348, "CALYPSO", (ftnlen)36, (ftnlen)7);
    bltcod[94] = 615;
    s_copy(bltnam + 3384, "1980S28", (ftnlen)36, (ftnlen)7);
    bltcod[95] = 615;
    s_copy(bltnam + 3420, "ATLAS", (ftnlen)36, (ftnlen)5);
    bltcod[96] = 616;
    s_copy(bltnam + 3456, "1980S27", (ftnlen)36, (ftnlen)7);
    bltcod[97] = 616;
    s_copy(bltnam + 3492, "PROMETHEUS", (ftnlen)36, (ftnlen)10);
    bltcod[98] = 617;
    s_copy(bltnam + 3528, "1980S26", (ftnlen)36, (ftnlen)7);
    bltcod[99] = 617;
    s_copy(bltnam + 3564, "PANDORA", (ftnlen)36, (ftnlen)7);
    bltcod[100] = 618;
    s_copy(bltnam + 3600, "PAN", (ftnlen)36, (ftnlen)3);
    bltcod[101] = 619;
    s_copy(bltnam + 3636, "YMIR", (ftnlen)36, (ftnlen)4);
    bltcod[102] = 620;
    s_copy(bltnam + 3672, "PAALIAQ", (ftnlen)36, (ftnlen)7);
    bltcod[103] = 621;
    s_copy(bltnam + 3708, "TARVOS", (ftnlen)36, (ftnlen)6);
    bltcod[104] = 622;
    s_copy(bltnam + 3744, "IJIRAQ", (ftnlen)36, (ftnlen)6);
    bltcod[105] = 623;
    s_copy(bltnam + 3780, "SUTTUNGR", (ftnlen)36, (ftnlen)8);
    bltcod[106] = 624;
    s_copy(bltnam + 3816, "KIVIUQ", (ftnlen)36, (ftnlen)6);
    bltcod[107] = 625;
    s_copy(bltnam + 3852, "MUNDILFARI", (ftnlen)36, (ftnlen)10);
    bltcod[108] = 626;
    s_copy(bltnam + 3888, "ALBIORIX", (ftnlen)36, (ftnlen)8);
    bltcod[109] = 627;
    s_copy(bltnam + 3924, "SKATHI", (ftnlen)36, (ftnlen)6);
    bltcod[110] = 628;
    s_copy(bltnam + 3960, "ERRIAPO", (ftnlen)36, (ftnlen)7);
    bltcod[111] = 629;
    s_copy(bltnam + 3996, "SIARNAQ", (ftnlen)36, (ftnlen)7);
    bltcod[112] = 630;
    s_copy(bltnam + 4032, "THRYMR", (ftnlen)36, (ftnlen)6);
    bltcod[113] = 631;
    s_copy(bltnam + 4068, "NARVI", (ftnlen)36, (ftnlen)5);
    bltcod[114] = 632;
    s_copy(bltnam + 4104, "METHODE", (ftnlen)36, (ftnlen)7);
    bltcod[115] = 633;
    s_copy(bltnam + 4140, "PALLENE", (ftnlen)36, (ftnlen)7);
    bltcod[116] = 634;
    s_copy(bltnam + 4176, "POLYDEUCES", (ftnlen)36, (ftnlen)10);
    bltcod[117] = 799;
    s_copy(bltnam + 4212, "URANUS", (ftnlen)36, (ftnlen)6);
    bltcod[118] = 701;
    s_copy(bltnam + 4248, "ARIEL", (ftnlen)36, (ftnlen)5);
    bltcod[119] = 702;
    s_copy(bltnam + 4284, "UMBRIEL", (ftnlen)36, (ftnlen)7);
    bltcod[120] = 703;
    s_copy(bltnam + 4320, "TITANIA", (ftnlen)36, (ftnlen)7);
    bltcod[121] = 704;
    s_copy(bltnam + 4356, "OBERON", (ftnlen)36, (ftnlen)6);
    bltcod[122] = 705;
    s_copy(bltnam + 4392, "MIRANDA", (ftnlen)36, (ftnlen)7);
    bltcod[123] = 706;
    s_copy(bltnam + 4428, "1986U7", (ftnlen)36, (ftnlen)6);
    bltcod[124] = 706;
    s_copy(bltnam + 4464, "CORDELIA", (ftnlen)36, (ftnlen)8);
    bltcod[125] = 707;
    s_copy(bltnam + 4500, "1986U8", (ftnlen)36, (ftnlen)6);
    bltcod[126] = 707;
    s_copy(bltnam + 4536, "OPHELIA", (ftnlen)36, (ftnlen)7);
    bltcod[127] = 708;
    s_copy(bltnam + 4572, "1986U9", (ftnlen)36, (ftnlen)6);
    bltcod[128] = 708;
    s_copy(bltnam + 4608, "BIANCA", (ftnlen)36, (ftnlen)6);
    bltcod[129] = 709;
    s_copy(bltnam + 4644, "1986U4", (ftnlen)36, (ftnlen)6);
    bltcod[130] = 709;
    s_copy(bltnam + 4680, "CRESSIDA", (ftnlen)36, (ftnlen)8);
    bltcod[131] = 710;
    s_copy(bltnam + 4716, "1986U6", (ftnlen)36, (ftnlen)6);
    bltcod[132] = 710;
    s_copy(bltnam + 4752, "DESDEMONA", (ftnlen)36, (ftnlen)9);
    bltcod[133] = 711;
    s_copy(bltnam + 4788, "1986U3", (ftnlen)36, (ftnlen)6);
    bltcod[134] = 711;
    s_copy(bltnam + 4824, "JULIET", (ftnlen)36, (ftnlen)6);
    bltcod[135] = 712;
    s_copy(bltnam + 4860, "1986U1", (ftnlen)36, (ftnlen)6);
    bltcod[136] = 712;
    s_copy(bltnam + 4896, "PORTIA", (ftnlen)36, (ftnlen)6);
    bltcod[137] = 713;
    s_copy(bltnam + 4932, "1986U2", (ftnlen)36, (ftnlen)6);
    bltcod[138] = 713;
    s_copy(bltnam + 4968, "ROSALIND", (ftnlen)36, (ftnlen)8);
    bltcod[139] = 714;
    s_copy(bltnam + 5004, "1986U5", (ftnlen)36, (ftnlen)6);
    bltcod[140] = 714;
    s_copy(bltnam + 5040, "BELINDA", (ftnlen)36, (ftnlen)7);
    bltcod[141] = 715;
    s_copy(bltnam + 5076, "1985U1", (ftnlen)36, (ftnlen)6);
    bltcod[142] = 715;
    s_copy(bltnam + 5112, "PUCK", (ftnlen)36, (ftnlen)4);
    bltcod[143] = 716;
    s_copy(bltnam + 5148, "CALIBAN", (ftnlen)36, (ftnlen)7);
    bltcod[144] = 717;
    s_copy(bltnam + 5184, "SYCORAX", (ftnlen)36, (ftnlen)7);
    bltcod[145] = 718;
    s_copy(bltnam + 5220, "1986U10", (ftnlen)36, (ftnlen)7);
    bltcod[146] = 718;
    s_copy(bltnam + 5256, "PROSPERO", (ftnlen)36, (ftnlen)8);
    bltcod[147] = 719;
    s_copy(bltnam + 5292, "SETEBOS", (ftnlen)36, (ftnlen)7);
    bltcod[148] = 720;
    s_copy(bltnam + 5328, "STEPHANO", (ftnlen)36, (ftnlen)8);
    bltcod[149] = 721;
    s_copy(bltnam + 5364, "TRINCULO", (ftnlen)36, (ftnlen)8);
    bltcod[150] = 899;
    s_copy(bltnam + 5400, "NEPTUNE", (ftnlen)36, (ftnlen)7);
    bltcod[151] = 801;
    s_copy(bltnam + 5436, "TRITON", (ftnlen)36, (ftnlen)6);
    bltcod[152] = 802;
    s_copy(bltnam + 5472, "NEREID", (ftnlen)36, (ftnlen)6);
    bltcod[153] = 803;
    s_copy(bltnam + 5508, "NAIAD", (ftnlen)36, (ftnlen)5);
    bltcod[154] = 804;
    s_copy(bltnam + 5544, "THALASSA", (ftnlen)36, (ftnlen)8);
    bltcod[155] = 805;
    s_copy(bltnam + 5580, "DESPINA", (ftnlen)36, (ftnlen)7);
    bltcod[156] = 806;
    s_copy(bltnam + 5616, "GALATEA", (ftnlen)36, (ftnlen)7);
    bltcod[157] = 807;
    s_copy(bltnam + 5652, "LARISSA", (ftnlen)36, (ftnlen)7);
    bltcod[158] = 808;
    s_copy(bltnam + 5688, "PROTEUS", (ftnlen)36, (ftnlen)7);
    bltcod[159] = 999;
    s_copy(bltnam + 5724, "PLUTO", (ftnlen)36, (ftnlen)5);
    bltcod[160] = 901;
    s_copy(bltnam + 5760, "1978P1", (ftnlen)36, (ftnlen)6);
    bltcod[161] = 901;
    s_copy(bltnam + 5796, "CHARON", (ftnlen)36, (ftnlen)6);
    bltcod[162] = -1;
    s_copy(bltnam + 5832, "GEOTAIL", (ftnlen)36, (ftnlen)7);
    bltcod[163] = -6;
    s_copy(bltnam + 5868, "P6", (ftnlen)36, (ftnlen)2);
    bltcod[164] = -6;
    s_copy(bltnam + 5904, "PIONEER-6", (ftnlen)36, (ftnlen)9);
    bltcod[165] = -7;
    s_copy(bltnam + 5940, "P7", (ftnlen)36, (ftnlen)2);
    bltcod[166] = -7;
    s_copy(bltnam + 5976, "PIONEER-7", (ftnlen)36, (ftnlen)9);
    bltcod[167] = -8;
    s_copy(bltnam + 6012, "WIND", (ftnlen)36, (ftnlen)4);
    bltcod[168] = -12;
    s_copy(bltnam + 6048, "VENUS ORBITER", (ftnlen)36, (ftnlen)13);
    bltcod[169] = -12;
    s_copy(bltnam + 6084, "P12", (ftnlen)36, (ftnlen)3);
    bltcod[170] = -12;
    s_copy(bltnam + 6120, "PIONEER 12", (ftnlen)36, (ftnlen)10);
    bltcod[171] = -13;
    s_copy(bltnam + 6156, "POLAR", (ftnlen)36, (ftnlen)5);
    bltcod[172] = -18;
    s_copy(bltnam + 6192, "MGN", (ftnlen)36, (ftnlen)3);
    bltcod[173] = -18;
    s_copy(bltnam + 6228, "MAGELLAN", (ftnlen)36, (ftnlen)8);
    bltcod[174] = -20;
    s_copy(bltnam + 6264, "P8", (ftnlen)36, (ftnlen)2);
    bltcod[175] = -20;
    s_copy(bltnam + 6300, "PIONEER-8", (ftnlen)36, (ftnlen)9);
    bltcod[176] = -21;
    s_copy(bltnam + 6336, "SOHO", (ftnlen)36, (ftnlen)4);
    bltcod[177] = -23;
    s_copy(bltnam + 6372, "P10", (ftnlen)36, (ftnlen)3);
    bltcod[178] = -23;
    s_copy(bltnam + 6408, "PIONEER-10", (ftnlen)36, (ftnlen)10);
    bltcod[179] = -24;
    s_copy(bltnam + 6444, "P11", (ftnlen)36, (ftnlen)3);
    bltcod[180] = -24;
    s_copy(bltnam + 6480, "PIONEER-11", (ftnlen)36, (ftnlen)10);
    bltcod[181] = -25;
    s_copy(bltnam + 6516, "LP", (ftnlen)36, (ftnlen)2);
    bltcod[182] = -25;
    s_copy(bltnam + 6552, "LUNAR PROSPECTOR", (ftnlen)36, (ftnlen)16);
    bltcod[183] = -27;
    s_copy(bltnam + 6588, "VK1", (ftnlen)36, (ftnlen)3);
    bltcod[184] = -27;
    s_copy(bltnam + 6624, "VIKING 1 ORBITER", (ftnlen)36, (ftnlen)16);
    bltcod[185] = -29;
    s_copy(bltnam + 6660, "STARDUST", (ftnlen)36, (ftnlen)8);
    bltcod[186] = -29;
    s_copy(bltnam + 6696, "SDU", (ftnlen)36, (ftnlen)3);
    bltcod[187] = -30;
    s_copy(bltnam + 6732, "VK2", (ftnlen)36, (ftnlen)3);
    bltcod[188] = -30;
    s_copy(bltnam + 6768, "VIKING 2 ORBITER", (ftnlen)36, (ftnlen)16);
    bltcod[189] = -30;
    s_copy(bltnam + 6804, "DS-1", (ftnlen)36, (ftnlen)4);
    bltcod[190] = -31;
    s_copy(bltnam + 6840, "VG1", (ftnlen)36, (ftnlen)3);
    bltcod[191] = -31;
    s_copy(bltnam + 6876, "VOYAGER 1", (ftnlen)36, (ftnlen)9);
    bltcod[192] = -32;
    s_copy(bltnam + 6912, "VG2", (ftnlen)36, (ftnlen)3);
    bltcod[193] = -32;
    s_copy(bltnam + 6948, "VOYAGER 2", (ftnlen)36, (ftnlen)9);
    bltcod[194] = -40;
    s_copy(bltnam + 6984, "CLEMENTINE", (ftnlen)36, (ftnlen)10);
    bltcod[195] = -41;
    s_copy(bltnam + 7020, "MEX", (ftnlen)36, (ftnlen)3);
    bltcod[196] = -41;
    s_copy(bltnam + 7056, "MARS EXPRESS", (ftnlen)36, (ftnlen)12);
    bltcod[197] = -44;
    s_copy(bltnam + 7092, "BEAGLE2", (ftnlen)36, (ftnlen)7);
    bltcod[198] = -44;
    s_copy(bltnam + 7128, "BEAGLE 2", (ftnlen)36, (ftnlen)8);
    bltcod[199] = -46;
    s_copy(bltnam + 7164, "MS-T5", (ftnlen)36, (ftnlen)5);
    bltcod[200] = -46;
    s_copy(bltnam + 7200, "SAKIGAKE", (ftnlen)36, (ftnlen)8);
    bltcod[201] = -47;
    s_copy(bltnam + 7236, "PLANET-A", (ftnlen)36, (ftnlen)8);
    bltcod[202] = -47;
    s_copy(bltnam + 7272, "SUISEI", (ftnlen)36, (ftnlen)6);
    bltcod[203] = -47;
    s_copy(bltnam + 7308, "GNS", (ftnlen)36, (ftnlen)3);
    bltcod[204] = -47;
    s_copy(bltnam + 7344, "GENESIS", (ftnlen)36, (ftnlen)7);
    bltcod[205] = -48;
    s_copy(bltnam + 7380, "HUBBLE SPACE TELESCOPE", (ftnlen)36, (ftnlen)22);
    bltcod[206] = -48;
    s_copy(bltnam + 7416, "HST", (ftnlen)36, (ftnlen)3);
    bltcod[207] = -53;
    s_copy(bltnam + 7452, "MARS PATHFINDER", (ftnlen)36, (ftnlen)15);
    bltcod[208] = -53;
    s_copy(bltnam + 7488, "MPF", (ftnlen)36, (ftnlen)3);
    bltcod[209] = -53;
    s_copy(bltnam + 7524, "MARS ODYSSEY", (ftnlen)36, (ftnlen)12);
    bltcod[210] = -53;
    s_copy(bltnam + 7560, "MARS SURVEYOR 01 ORBITER", (ftnlen)36, (ftnlen)24);
    bltcod[211] = -55;
    s_copy(bltnam + 7596, "ULYSSES", (ftnlen)36, (ftnlen)7);
    bltcod[212] = -58;
    s_copy(bltnam + 7632, "VSOP", (ftnlen)36, (ftnlen)4);
    bltcod[213] = -58;
    s_copy(bltnam + 7668, "HALCA", (ftnlen)36, (ftnlen)5);
    bltcod[214] = -59;
    s_copy(bltnam + 7704, "RADIOASTRON", (ftnlen)36, (ftnlen)11);
    bltcod[215] = -66;
    s_copy(bltnam + 7740, "VEGA 1", (ftnlen)36, (ftnlen)6);
    bltcod[216] = -67;
    s_copy(bltnam + 7776, "VEGA 2", (ftnlen)36, (ftnlen)6);
    bltcod[217] = -70;
    s_copy(bltnam + 7812, "DEEP IMPACT IMPACTOR SPACECRAFT", (ftnlen)36, (
	    ftnlen)31);
    bltcod[218] = -74;
    s_copy(bltnam + 7848, "MRO", (ftnlen)36, (ftnlen)3);
    bltcod[219] = -74;
    s_copy(bltnam + 7884, "MARS RECON ORBITER", (ftnlen)36, (ftnlen)18);
    bltcod[220] = -77;
    s_copy(bltnam + 7920, "GLL", (ftnlen)36, (ftnlen)3);
    bltcod[221] = -77;
    s_copy(bltnam + 7956, "GALILEO ORBITER", (ftnlen)36, (ftnlen)15);
    bltcod[222] = -78;
    s_copy(bltnam + 7992, "GIOTTO", (ftnlen)36, (ftnlen)6);
    bltcod[223] = -79;
    s_copy(bltnam + 8028, "SPITZER", (ftnlen)36, (ftnlen)7);
    bltcod[224] = -79;
    s_copy(bltnam + 8064, "SPACE INFRARED TELESCOPE FACILITY", (ftnlen)36, (
	    ftnlen)33);
    bltcod[225] = -79;
    s_copy(bltnam + 8100, "SIRTF", (ftnlen)36, (ftnlen)5);
    bltcod[226] = -81;
    s_copy(bltnam + 8136, "CASSINI ITL", (ftnlen)36, (ftnlen)11);
    bltcod[227] = -82;
    s_copy(bltnam + 8172, "CAS", (ftnlen)36, (ftnlen)3);
    bltcod[228] = -82;
    s_copy(bltnam + 8208, "CASSINI", (ftnlen)36, (ftnlen)7);
    bltcod[229] = -84;
    s_copy(bltnam + 8244, "PHOENIX", (ftnlen)36, (ftnlen)7);
    bltcod[230] = -90;
    s_copy(bltnam + 8280, "CASSINI SIMULATION", (ftnlen)36, (ftnlen)18);
    bltcod[231] = -93;
    s_copy(bltnam + 8316, "NEAR EARTH ASTEROID RENDEZVOUS", (ftnlen)36, (
	    ftnlen)30);
    bltcod[232] = -93;
    s_copy(bltnam + 8352, "NEAR", (ftnlen)36, (ftnlen)4);
    bltcod[233] = -94;
    s_copy(bltnam + 8388, "MO", (ftnlen)36, (ftnlen)2);
    bltcod[234] = -94;
    s_copy(bltnam + 8424, "MARS OBSERVER", (ftnlen)36, (ftnlen)13);
    bltcod[235] = -94;
    s_copy(bltnam + 8460, "MGS", (ftnlen)36, (ftnlen)3);
    bltcod[236] = -94;
    s_copy(bltnam + 8496, "MARS GLOBAL SURVEYOR", (ftnlen)36, (ftnlen)20);
    bltcod[237] = -95;
    s_copy(bltnam + 8532, "MGS SIMULATION", (ftnlen)36, (ftnlen)14);
    bltcod[238] = -97;
    s_copy(bltnam + 8568, "TOPEX/POSEIDON", (ftnlen)36, (ftnlen)14);
    bltcod[239] = -98;
    s_copy(bltnam + 8604, "NEW HORIZONS", (ftnlen)36, (ftnlen)12);
    bltcod[240] = -107;
    s_copy(bltnam + 8640, "TROPICAL RAINFALL MEASURING MISSION", (ftnlen)36, (
	    ftnlen)35);
    bltcod[241] = -107;
    s_copy(bltnam + 8676, "TRMM", (ftnlen)36, (ftnlen)4);
    bltcod[242] = -112;
    s_copy(bltnam + 8712, "ICE", (ftnlen)36, (ftnlen)3);
    bltcod[243] = -116;
    s_copy(bltnam + 8748, "MARS POLAR LANDER", (ftnlen)36, (ftnlen)17);
    bltcod[244] = -116;
    s_copy(bltnam + 8784, "MPL", (ftnlen)36, (ftnlen)3);
    bltcod[245] = -127;
    s_copy(bltnam + 8820, "MARS CLIMATE ORBITER", (ftnlen)36, (ftnlen)20);
    bltcod[246] = -127;
    s_copy(bltnam + 8856, "MCO", (ftnlen)36, (ftnlen)3);
    bltcod[247] = -130;
    s_copy(bltnam + 8892, "MUSES-C", (ftnlen)36, (ftnlen)7);
    bltcod[248] = -130;
    s_copy(bltnam + 8928, "HAYABUSA", (ftnlen)36, (ftnlen)8);
    bltcod[249] = -131;
    s_copy(bltnam + 8964, "SELENE", (ftnlen)36, (ftnlen)6);
    bltcod[250] = -135;
    s_copy(bltnam + 9000, "DRTS-W", (ftnlen)36, (ftnlen)6);
    bltcod[251] = -140;
    s_copy(bltnam + 9036, "DEEP IMPACT FLYBY SPACECRAFT", (ftnlen)36, (ftnlen)
	    28);
    bltcod[252] = -142;
    s_copy(bltnam + 9072, "TERRA", (ftnlen)36, (ftnlen)5);
    bltcod[253] = -142;
    s_copy(bltnam + 9108, "EOS-AM1", (ftnlen)36, (ftnlen)7);
    bltcod[254] = -146;
    s_copy(bltnam + 9144, "LUNAR-A", (ftnlen)36, (ftnlen)7);
    bltcod[255] = -150;
    s_copy(bltnam + 9180, "CASSINI PROBE", (ftnlen)36, (ftnlen)13);
    bltcod[256] = -150;
    s_copy(bltnam + 9216, "HUYGENS PROBE", (ftnlen)36, (ftnlen)13);
    bltcod[257] = -150;
    s_copy(bltnam + 9252, "CASP", (ftnlen)36, (ftnlen)4);
    bltcod[258] = -151;
    s_copy(bltnam + 9288, "AXAF", (ftnlen)36, (ftnlen)4);
    bltcod[259] = -154;
    s_copy(bltnam + 9324, "AQUA", (ftnlen)36, (ftnlen)4);
    bltcod[260] = -159;
    s_copy(bltnam + 9360, "EUROPA ORBITER", (ftnlen)36, (ftnlen)14);
    bltcod[261] = -164;
    s_copy(bltnam + 9396, "YOHKOH", (ftnlen)36, (ftnlen)6);
    bltcod[262] = -164;
    s_copy(bltnam + 9432, "SOLAR-A", (ftnlen)36, (ftnlen)7);
    bltcod[263] = -165;
    s_copy(bltnam + 9468, "MAP", (ftnlen)36, (ftnlen)3);
    bltcod[264] = -166;
    s_copy(bltnam + 9504, "IMAGE", (ftnlen)36, (ftnlen)5);
    bltcod[265] = -172;
    s_copy(bltnam + 9540, "SPACETECH-3 COMBINER", (ftnlen)36, (ftnlen)20);
    bltcod[266] = -174;
    s_copy(bltnam + 9576, "PLUTO-KUIPER EXPRESS", (ftnlen)36, (ftnlen)20);
    bltcod[267] = -175;
    s_copy(bltnam + 9612, "PLUTO-KUIPER EXPRESS SIMULATION", (ftnlen)36, (
	    ftnlen)31);
    bltcod[268] = -178;
    s_copy(bltnam + 9648, "PLANET-B", (ftnlen)36, (ftnlen)8);
    bltcod[269] = -178;
    s_copy(bltnam + 9684, "NOZOMI", (ftnlen)36, (ftnlen)6);
    bltcod[270] = -183;
    s_copy(bltnam + 9720, "CLUSTER 1", (ftnlen)36, (ftnlen)9);
    bltcod[271] = -185;
    s_copy(bltnam + 9756, "CLUSTER 2", (ftnlen)36, (ftnlen)9);
    bltcod[272] = -188;
    s_copy(bltnam + 9792, "MUSES-B", (ftnlen)36, (ftnlen)7);
    bltcod[273] = -190;
    s_copy(bltnam + 9828, "SIM", (ftnlen)36, (ftnlen)3);
    bltcod[274] = -194;
    s_copy(bltnam + 9864, "CLUSTER 3", (ftnlen)36, (ftnlen)9);
    bltcod[275] = -196;
    s_copy(bltnam + 9900, "CLUSTER 4", (ftnlen)36, (ftnlen)9);
    bltcod[276] = -198;
    s_copy(bltnam + 9936, "INTEGRAL", (ftnlen)36, (ftnlen)8);
    bltcod[277] = -200;
    s_copy(bltnam + 9972, "CONTOUR", (ftnlen)36, (ftnlen)7);
    bltcod[278] = -203;
    s_copy(bltnam + 10008, "DAWN", (ftnlen)36, (ftnlen)4);
    bltcod[279] = -205;
    s_copy(bltnam + 10044, "SPACETECH-3 COLLECTOR", (ftnlen)36, (ftnlen)21);
    bltcod[280] = -226;
    s_copy(bltnam + 10080, "ROSETTA", (ftnlen)36, (ftnlen)7);
    bltcod[281] = -227;
    s_copy(bltnam + 10116, "KEPLER", (ftnlen)36, (ftnlen)6);
    bltcod[282] = -228;
    s_copy(bltnam + 10152, "GLL PROBE", (ftnlen)36, (ftnlen)9);
    bltcod[283] = -228;
    s_copy(bltnam + 10188, "GALILEO PROBE", (ftnlen)36, (ftnlen)13);
    bltcod[284] = -234;
    s_copy(bltnam + 10224, "STEREO AHEAD", (ftnlen)36, (ftnlen)12);
    bltcod[285] = -235;
    s_copy(bltnam + 10260, "STEREO BEHIND", (ftnlen)36, (ftnlen)13);
    bltcod[286] = -236;
    s_copy(bltnam + 10296, "MESSENGER", (ftnlen)36, (ftnlen)9);
    bltcod[287] = -238;
    s_copy(bltnam + 10332, "SMART1", (ftnlen)36, (ftnlen)6);
    bltcod[288] = -238;
    s_copy(bltnam + 10368, "SM1", (ftnlen)36, (ftnlen)3);
    bltcod[289] = -238;
    s_copy(bltnam + 10404, "S1", (ftnlen)36, (ftnlen)2);
    bltcod[290] = -238;
    s_copy(bltnam + 10440, "SMART-1", (ftnlen)36, (ftnlen)7);
    bltcod[291] = -248;
    s_copy(bltnam + 10476, "VEX", (ftnlen)36, (ftnlen)3);
    bltcod[292] = -248;
    s_copy(bltnam + 10512, "VENUS EXPRESS", (ftnlen)36, (ftnlen)13);
    bltcod[293] = -253;
    s_copy(bltnam + 10548, "OPPORTUNITY", (ftnlen)36, (ftnlen)11);
    bltcod[294] = -253;
    s_copy(bltnam + 10584, "MER-1", (ftnlen)36, (ftnlen)5);
    bltcod[295] = -254;
    s_copy(bltnam + 10620, "SPIRIT", (ftnlen)36, (ftnlen)6);
    bltcod[296] = -254;
    s_copy(bltnam + 10656, "MER-2", (ftnlen)36, (ftnlen)5);
    bltcod[297] = -486;
    s_copy(bltnam + 10692, "HERSCHEL", (ftnlen)36, (ftnlen)8);
    bltcod[298] = -489;
    s_copy(bltnam + 10728, "PLANCK", (ftnlen)36, (ftnlen)6);
    bltcod[299] = -500;
    s_copy(bltnam + 10764, "RSAT", (ftnlen)36, (ftnlen)4);
    bltcod[300] = -500;
    s_copy(bltnam + 10800, "SELENE Relay Satellite", (ftnlen)36, (ftnlen)22);
    bltcod[301] = -500;
    s_copy(bltnam + 10836, "SELENE Rstar", (ftnlen)36, (ftnlen)12);
    bltcod[302] = -500;
    s_copy(bltnam + 10872, "Rstar", (ftnlen)36, (ftnlen)5);
    bltcod[303] = -502;
    s_copy(bltnam + 10908, "VSAT", (ftnlen)36, (ftnlen)4);
    bltcod[304] = -502;
    s_copy(bltnam + 10944, "SELENE VLBI Radio Satellite", (ftnlen)36, (ftnlen)
	    27);
    bltcod[305] = -502;
    s_copy(bltnam + 10980, "SELENE VRAD Satellite", (ftnlen)36, (ftnlen)21);
    bltcod[306] = -502;
    s_copy(bltnam + 11016, "SELENE Vstar", (ftnlen)36, (ftnlen)12);
    bltcod[307] = -502;
    s_copy(bltnam + 11052, "Vstar", (ftnlen)36, (ftnlen)5);
    bltcod[308] = -550;
    s_copy(bltnam + 11088, "MARS-96", (ftnlen)36, (ftnlen)7);
    bltcod[309] = -550;
    s_copy(bltnam + 11124, "M96", (ftnlen)36, (ftnlen)3);
    bltcod[310] = -550;
    s_copy(bltnam + 11160, "MARS 96", (ftnlen)36, (ftnlen)7);
    bltcod[311] = -550;
    s_copy(bltnam + 11196, "MARS96", (ftnlen)36, (ftnlen)6);
    bltcod[312] = 50000001;
    s_copy(bltnam + 11232, "SHOEMAKER-LEVY 9-W", (ftnlen)36, (ftnlen)18);
    bltcod[313] = 50000002;
    s_copy(bltnam + 11268, "SHOEMAKER-LEVY 9-V", (ftnlen)36, (ftnlen)18);
    bltcod[314] = 50000003;
    s_copy(bltnam + 11304, "SHOEMAKER-LEVY 9-U", (ftnlen)36, (ftnlen)18);
    bltcod[315] = 50000004;
    s_copy(bltnam + 11340, "SHOEMAKER-LEVY 9-T", (ftnlen)36, (ftnlen)18);
    bltcod[316] = 50000005;
    s_copy(bltnam + 11376, "SHOEMAKER-LEVY 9-S", (ftnlen)36, (ftnlen)18);
    bltcod[317] = 50000006;
    s_copy(bltnam + 11412, "SHOEMAKER-LEVY 9-R", (ftnlen)36, (ftnlen)18);
    bltcod[318] = 50000007;
    s_copy(bltnam + 11448, "SHOEMAKER-LEVY 9-Q", (ftnlen)36, (ftnlen)18);
    bltcod[319] = 50000008;
    s_copy(bltnam + 11484, "SHOEMAKER-LEVY 9-P", (ftnlen)36, (ftnlen)18);
    bltcod[320] = 50000009;
    s_copy(bltnam + 11520, "SHOEMAKER-LEVY 9-N", (ftnlen)36, (ftnlen)18);
    bltcod[321] = 50000010;
    s_copy(bltnam + 11556, "SHOEMAKER-LEVY 9-M", (ftnlen)36, (ftnlen)18);
    bltcod[322] = 50000011;
    s_copy(bltnam + 11592, "SHOEMAKER-LEVY 9-L", (ftnlen)36, (ftnlen)18);
    bltcod[323] = 50000012;
    s_copy(bltnam + 11628, "SHOEMAKER-LEVY 9-K", (ftnlen)36, (ftnlen)18);
    bltcod[324] = 50000013;
    s_copy(bltnam + 11664, "SHOEMAKER-LEVY 9-J", (ftnlen)36, (ftnlen)18);
    bltcod[325] = 50000014;
    s_copy(bltnam + 11700, "SHOEMAKER-LEVY 9-H", (ftnlen)36, (ftnlen)18);
    bltcod[326] = 50000015;
    s_copy(bltnam + 11736, "SHOEMAKER-LEVY 9-G", (ftnlen)36, (ftnlen)18);
    bltcod[327] = 50000016;
    s_copy(bltnam + 11772, "SHOEMAKER-LEVY 9-F", (ftnlen)36, (ftnlen)18);
    bltcod[328] = 50000017;
    s_copy(bltnam + 11808, "SHOEMAKER-LEVY 9-E", (ftnlen)36, (ftnlen)18);
    bltcod[329] = 50000018;
    s_copy(bltnam + 11844, "SHOEMAKER-LEVY 9-D", (ftnlen)36, (ftnlen)18);
    bltcod[330] = 50000019;
    s_copy(bltnam + 11880, "SHOEMAKER-LEVY 9-C", (ftnlen)36, (ftnlen)18);
    bltcod[331] = 50000020;
    s_copy(bltnam + 11916, "SHOEMAKER-LEVY 9-B", (ftnlen)36, (ftnlen)18);
    bltcod[332] = 50000021;
    s_copy(bltnam + 11952, "SHOEMAKER-LEVY 9-A", (ftnlen)36, (ftnlen)18);
    bltcod[333] = 50000022;
    s_copy(bltnam + 11988, "SHOEMAKER-LEVY 9-Q1", (ftnlen)36, (ftnlen)19);
    bltcod[334] = 50000023;
    s_copy(bltnam + 12024, "SHOEMAKER-LEVY 9-P2", (ftnlen)36, (ftnlen)19);
    bltcod[335] = 1000001;
    s_copy(bltnam + 12060, "AREND", (ftnlen)36, (ftnlen)5);
    bltcod[336] = 1000002;
    s_copy(bltnam + 12096, "AREND-RIGAUX", (ftnlen)36, (ftnlen)12);
    bltcod[337] = 1000003;
    s_copy(bltnam + 12132, "ASHBROOK-JACKSON", (ftnlen)36, (ftnlen)16);
    bltcod[338] = 1000004;
    s_copy(bltnam + 12168, "BOETHIN", (ftnlen)36, (ftnlen)7);
    bltcod[339] = 1000005;
    s_copy(bltnam + 12204, "BORRELLY", (ftnlen)36, (ftnlen)8);
    bltcod[340] = 1000006;
    s_copy(bltnam + 12240, "BOWELL-SKIFF", (ftnlen)36, (ftnlen)12);
    bltcod[341] = 1000007;
    s_copy(bltnam + 12276, "BRADFIELD", (ftnlen)36, (ftnlen)9);
    bltcod[342] = 1000008;
    s_copy(bltnam + 12312, "BROOKS 2", (ftnlen)36, (ftnlen)8);
    bltcod[343] = 1000009;
    s_copy(bltnam + 12348, "BRORSEN-METCALF", (ftnlen)36, (ftnlen)15);
    bltcod[344] = 1000010;
    s_copy(bltnam + 12384, "BUS", (ftnlen)36, (ftnlen)3);
    bltcod[345] = 1000011;
    s_copy(bltnam + 12420, "CHERNYKH", (ftnlen)36, (ftnlen)8);
    bltcod[346] = 1000012;
    s_copy(bltnam + 12456, "67P/CHURYUMOV-GERASIMENKO (1969 R1)", (ftnlen)36, 
	    (ftnlen)35);
    bltcod[347] = 1000012;
    s_copy(bltnam + 12492, "CHURYUMOV-GERASIMENKO", (ftnlen)36, (ftnlen)21);
    bltcod[348] = 1000013;
    s_copy(bltnam + 12528, "CIFFREO", (ftnlen)36, (ftnlen)7);
    bltcod[349] = 1000014;
    s_copy(bltnam + 12564, "CLARK", (ftnlen)36, (ftnlen)5);
    bltcod[350] = 1000015;
    s_copy(bltnam + 12600, "COMAS SOLA", (ftnlen)36, (ftnlen)10);
    bltcod[351] = 1000016;
    s_copy(bltnam + 12636, "CROMMELIN", (ftnlen)36, (ftnlen)9);
    bltcod[352] = 1000017;
    s_copy(bltnam + 12672, "D'ARREST", (ftnlen)36, (ftnlen)8);
    bltcod[353] = 1000018;
    s_copy(bltnam + 12708, "DANIEL", (ftnlen)36, (ftnlen)6);
    bltcod[354] = 1000019;
    s_copy(bltnam + 12744, "DE VICO-SWIFT", (ftnlen)36, (ftnlen)13);
    bltcod[355] = 1000020;
    s_copy(bltnam + 12780, "DENNING-FUJIKAWA", (ftnlen)36, (ftnlen)16);
    bltcod[356] = 1000021;
    s_copy(bltnam + 12816, "DU TOIT 1", (ftnlen)36, (ftnlen)9);
    bltcod[357] = 1000022;
    s_copy(bltnam + 12852, "DU TOIT-HARTLEY", (ftnlen)36, (ftnlen)15);
    bltcod[358] = 1000023;
    s_copy(bltnam + 12888, "DUTOIT-NEUJMIN-DELPORTE", (ftnlen)36, (ftnlen)23);
    bltcod[359] = 1000024;
    s_copy(bltnam + 12924, "DUBIAGO", (ftnlen)36, (ftnlen)7);
    bltcod[360] = 1000025;
    s_copy(bltnam + 12960, "ENCKE", (ftnlen)36, (ftnlen)5);
    bltcod[361] = 1000026;
    s_copy(bltnam + 12996, "FAYE", (ftnlen)36, (ftnlen)4);
    bltcod[362] = 1000027;
    s_copy(bltnam + 13032, "FINLAY", (ftnlen)36, (ftnlen)6);
    bltcod[363] = 1000028;
    s_copy(bltnam + 13068, "FORBES", (ftnlen)36, (ftnlen)6);
    bltcod[364] = 1000029;
    s_copy(bltnam + 13104, "GEHRELS 1", (ftnlen)36, (ftnlen)9);
    bltcod[365] = 1000030;
    s_copy(bltnam + 13140, "GEHRELS 2", (ftnlen)36, (ftnlen)9);
    bltcod[366] = 1000031;
    s_copy(bltnam + 13176, "GEHRELS 3", (ftnlen)36, (ftnlen)9);
    bltcod[367] = 1000032;
    s_copy(bltnam + 13212, "GIACOBINI-ZINNER", (ftnlen)36, (ftnlen)16);
    bltcod[368] = 1000033;
    s_copy(bltnam + 13248, "GICLAS", (ftnlen)36, (ftnlen)6);
    bltcod[369] = 1000034;
    s_copy(bltnam + 13284, "GRIGG-SKJELLERUP", (ftnlen)36, (ftnlen)16);
    bltcod[370] = 1000035;
    s_copy(bltnam + 13320, "GUNN", (ftnlen)36, (ftnlen)4);
    bltcod[371] = 1000036;
    s_copy(bltnam + 13356, "HALLEY", (ftnlen)36, (ftnlen)6);
    bltcod[372] = 1000037;
    s_copy(bltnam + 13392, "HANEDA-CAMPOS", (ftnlen)36, (ftnlen)13);
    bltcod[373] = 1000038;
    s_copy(bltnam + 13428, "HARRINGTON", (ftnlen)36, (ftnlen)10);
    bltcod[374] = 1000039;
    s_copy(bltnam + 13464, "HARRINGTON-ABELL", (ftnlen)36, (ftnlen)16);
    bltcod[375] = 1000040;
    s_copy(bltnam + 13500, "HARTLEY 1", (ftnlen)36, (ftnlen)9);
    bltcod[376] = 1000041;
    s_copy(bltnam + 13536, "HARTLEY 2", (ftnlen)36, (ftnlen)9);
    bltcod[377] = 1000042;
    s_copy(bltnam + 13572, "HARTLEY-IRAS", (ftnlen)36, (ftnlen)12);
    bltcod[378] = 1000043;
    s_copy(bltnam + 13608, "HERSCHEL-RIGOLLET", (ftnlen)36, (ftnlen)17);
    bltcod[379] = 1000044;
    s_copy(bltnam + 13644, "HOLMES", (ftnlen)36, (ftnlen)6);
    bltcod[380] = 1000045;
    s_copy(bltnam + 13680, "HONDA-MRKOS-PAJDUSAKOVA", (ftnlen)36, (ftnlen)23);
    bltcod[381] = 1000046;
    s_copy(bltnam + 13716, "HOWELL", (ftnlen)36, (ftnlen)6);
    bltcod[382] = 1000047;
    s_copy(bltnam + 13752, "IRAS", (ftnlen)36, (ftnlen)4);
    bltcod[383] = 1000048;
    s_copy(bltnam + 13788, "JACKSON-NEUJMIN", (ftnlen)36, (ftnlen)15);
    bltcod[384] = 1000049;
    s_copy(bltnam + 13824, "JOHNSON", (ftnlen)36, (ftnlen)7);
    bltcod[385] = 1000050;
    s_copy(bltnam + 13860, "KEARNS-KWEE", (ftnlen)36, (ftnlen)11);
    bltcod[386] = 1000051;
    s_copy(bltnam + 13896, "KLEMOLA", (ftnlen)36, (ftnlen)7);
    bltcod[387] = 1000052;
    s_copy(bltnam + 13932, "KOHOUTEK", (ftnlen)36, (ftnlen)8);
    bltcod[388] = 1000053;
    s_copy(bltnam + 13968, "KOJIMA", (ftnlen)36, (ftnlen)6);
    bltcod[389] = 1000054;
    s_copy(bltnam + 14004, "KOPFF", (ftnlen)36, (ftnlen)5);
    bltcod[390] = 1000055;
    s_copy(bltnam + 14040, "KOWAL 1", (ftnlen)36, (ftnlen)7);
    bltcod[391] = 1000056;
    s_copy(bltnam + 14076, "KOWAL 2", (ftnlen)36, (ftnlen)7);
    bltcod[392] = 1000057;
    s_copy(bltnam + 14112, "KOWAL-MRKOS", (ftnlen)36, (ftnlen)11);
    bltcod[393] = 1000058;
    s_copy(bltnam + 14148, "KOWAL-VAVROVA", (ftnlen)36, (ftnlen)13);
    bltcod[394] = 1000059;
    s_copy(bltnam + 14184, "LONGMORE", (ftnlen)36, (ftnlen)8);
    bltcod[395] = 1000060;
    s_copy(bltnam + 14220, "LOVAS 1", (ftnlen)36, (ftnlen)7);
    bltcod[396] = 1000061;
    s_copy(bltnam + 14256, "MACHHOLZ", (ftnlen)36, (ftnlen)8);
    bltcod[397] = 1000062;
    s_copy(bltnam + 14292, "MAURY", (ftnlen)36, (ftnlen)5);
    bltcod[398] = 1000063;
    s_copy(bltnam + 14328, "NEUJMIN 1", (ftnlen)36, (ftnlen)9);
    bltcod[399] = 1000064;
    s_copy(bltnam + 14364, "NEUJMIN 2", (ftnlen)36, (ftnlen)9);
    bltcod[400] = 1000065;
    s_copy(bltnam + 14400, "NEUJMIN 3", (ftnlen)36, (ftnlen)9);
    bltcod[401] = 1000066;
    s_copy(bltnam + 14436, "OLBERS", (ftnlen)36, (ftnlen)6);
    bltcod[402] = 1000067;
    s_copy(bltnam + 14472, "PETERS-HARTLEY", (ftnlen)36, (ftnlen)14);
    bltcod[403] = 1000068;
    s_copy(bltnam + 14508, "PONS-BROOKS", (ftnlen)36, (ftnlen)11);
    bltcod[404] = 1000069;
    s_copy(bltnam + 14544, "PONS-WINNECKE", (ftnlen)36, (ftnlen)13);
    bltcod[405] = 1000070;
    s_copy(bltnam + 14580, "REINMUTH 1", (ftnlen)36, (ftnlen)10);
    bltcod[406] = 1000071;
    s_copy(bltnam + 14616, "REINMUTH 2", (ftnlen)36, (ftnlen)10);
    bltcod[407] = 1000072;
    s_copy(bltnam + 14652, "RUSSELL 1", (ftnlen)36, (ftnlen)9);
    bltcod[408] = 1000073;
    s_copy(bltnam + 14688, "RUSSELL 2", (ftnlen)36, (ftnlen)9);
    bltcod[409] = 1000074;
    s_copy(bltnam + 14724, "RUSSELL 3", (ftnlen)36, (ftnlen)9);
    bltcod[410] = 1000075;
    s_copy(bltnam + 14760, "RUSSELL 4", (ftnlen)36, (ftnlen)9);
    bltcod[411] = 1000076;
    s_copy(bltnam + 14796, "SANGUIN", (ftnlen)36, (ftnlen)7);
    bltcod[412] = 1000077;
    s_copy(bltnam + 14832, "SCHAUMASSE", (ftnlen)36, (ftnlen)10);
    bltcod[413] = 1000078;
    s_copy(bltnam + 14868, "SCHUSTER", (ftnlen)36, (ftnlen)8);
    bltcod[414] = 1000079;
    s_copy(bltnam + 14904, "SCHWASSMANN-WACHMANN 1", (ftnlen)36, (ftnlen)22);
    bltcod[415] = 1000080;
    s_copy(bltnam + 14940, "SCHWASSMANN-WACHMANN 2", (ftnlen)36, (ftnlen)22);
    bltcod[416] = 1000081;
    s_copy(bltnam + 14976, "SCHWASSMANN-WACHMANN 3", (ftnlen)36, (ftnlen)22);
    bltcod[417] = 1000082;
    s_copy(bltnam + 15012, "SHAJN-SCHALDACH", (ftnlen)36, (ftnlen)15);
    bltcod[418] = 1000083;
    s_copy(bltnam + 15048, "SHOEMAKER 1", (ftnlen)36, (ftnlen)11);
    bltcod[419] = 1000084;
    s_copy(bltnam + 15084, "SHOEMAKER 2", (ftnlen)36, (ftnlen)11);
    bltcod[420] = 1000085;
    s_copy(bltnam + 15120, "SHOEMAKER 3", (ftnlen)36, (ftnlen)11);
    bltcod[421] = 1000086;
    s_copy(bltnam + 15156, "SINGER-BREWSTER", (ftnlen)36, (ftnlen)15);
    bltcod[422] = 1000087;
    s_copy(bltnam + 15192, "SLAUGHTER-BURNHAM", (ftnlen)36, (ftnlen)17);
    bltcod[423] = 1000088;
    s_copy(bltnam + 15228, "SMIRNOVA-CHERNYKH", (ftnlen)36, (ftnlen)17);
    bltcod[424] = 1000089;
    s_copy(bltnam + 15264, "STEPHAN-OTERMA", (ftnlen)36, (ftnlen)14);
    bltcod[425] = 1000090;
    s_copy(bltnam + 15300, "SWIFT-GEHRELS", (ftnlen)36, (ftnlen)13);
    bltcod[426] = 1000091;
    s_copy(bltnam + 15336, "TAKAMIZAWA", (ftnlen)36, (ftnlen)10);
    bltcod[427] = 1000092;
    s_copy(bltnam + 15372, "TAYLOR", (ftnlen)36, (ftnlen)6);
    bltcod[428] = 1000093;
    s_copy(bltnam + 15408, "TEMPEL 1", (ftnlen)36, (ftnlen)8);
    bltcod[429] = 1000094;
    s_copy(bltnam + 15444, "TEMPEL 2", (ftnlen)36, (ftnlen)8);
    bltcod[430] = 1000095;
    s_copy(bltnam + 15480, "TEMPEL-TUTTLE", (ftnlen)36, (ftnlen)13);
    bltcod[431] = 1000096;
    s_copy(bltnam + 15516, "TRITTON", (ftnlen)36, (ftnlen)7);
    bltcod[432] = 1000097;
    s_copy(bltnam + 15552, "TSUCHINSHAN 1", (ftnlen)36, (ftnlen)13);
    bltcod[433] = 1000098;
    s_copy(bltnam + 15588, "TSUCHINSHAN 2", (ftnlen)36, (ftnlen)13);
    bltcod[434] = 1000099;
    s_copy(bltnam + 15624, "TUTTLE", (ftnlen)36, (ftnlen)6);
    bltcod[435] = 1000100;
    s_copy(bltnam + 15660, "TUTTLE-GIACOBINI-KRESAK", (ftnlen)36, (ftnlen)23);
    bltcod[436] = 1000101;
    s_copy(bltnam + 15696, "VAISALA 1", (ftnlen)36, (ftnlen)9);
    bltcod[437] = 1000102;
    s_copy(bltnam + 15732, "VAN BIESBROECK", (ftnlen)36, (ftnlen)14);
    bltcod[438] = 1000103;
    s_copy(bltnam + 15768, "VAN HOUTEN", (ftnlen)36, (ftnlen)10);
    bltcod[439] = 1000104;
    s_copy(bltnam + 15804, "WEST-KOHOUTEK-IKEMURA", (ftnlen)36, (ftnlen)21);
    bltcod[440] = 1000105;
    s_copy(bltnam + 15840, "WHIPPLE", (ftnlen)36, (ftnlen)7);
    bltcod[441] = 1000106;
    s_copy(bltnam + 15876, "WILD 1", (ftnlen)36, (ftnlen)6);
    bltcod[442] = 1000107;
    s_copy(bltnam + 15912, "WILD 2", (ftnlen)36, (ftnlen)6);
    bltcod[443] = 1000108;
    s_copy(bltnam + 15948, "WILD 3", (ftnlen)36, (ftnlen)6);
    bltcod[444] = 1000109;
    s_copy(bltnam + 15984, "WIRTANEN", (ftnlen)36, (ftnlen)8);
    bltcod[445] = 1000110;
    s_copy(bltnam + 16020, "WOLF", (ftnlen)36, (ftnlen)4);
    bltcod[446] = 1000111;
    s_copy(bltnam + 16056, "WOLF-HARRINGTON", (ftnlen)36, (ftnlen)15);
    bltcod[447] = 1000112;
    s_copy(bltnam + 16092, "LOVAS 2", (ftnlen)36, (ftnlen)7);
    bltcod[448] = 1000113;
    s_copy(bltnam + 16128, "URATA-NIIJIMA", (ftnlen)36, (ftnlen)13);
    bltcod[449] = 1000114;
    s_copy(bltnam + 16164, "WISEMAN-SKIFF", (ftnlen)36, (ftnlen)13);
    bltcod[450] = 1000115;
    s_copy(bltnam + 16200, "HELIN", (ftnlen)36, (ftnlen)5);
    bltcod[451] = 1000116;
    s_copy(bltnam + 16236, "MUELLER", (ftnlen)36, (ftnlen)7);
    bltcod[452] = 1000117;
    s_copy(bltnam + 16272, "SHOEMAKER-HOLT 1", (ftnlen)36, (ftnlen)16);
    bltcod[453] = 1000118;
    s_copy(bltnam + 16308, "HELIN-ROMAN-CROCKETT", (ftnlen)36, (ftnlen)20);
    bltcod[454] = 1000119;
    s_copy(bltnam + 16344, "HARTLEY 3", (ftnlen)36, (ftnlen)9);
    bltcod[455] = 1000120;
    s_copy(bltnam + 16380, "PARKER-HARTLEY", (ftnlen)36, (ftnlen)14);
    bltcod[456] = 1000121;
    s_copy(bltnam + 16416, "HELIN-ROMAN-ALU 1", (ftnlen)36, (ftnlen)17);
    bltcod[457] = 1000122;
    s_copy(bltnam + 16452, "WILD 4", (ftnlen)36, (ftnlen)6);
    bltcod[458] = 1000123;
    s_copy(bltnam + 16488, "MUELLER 2", (ftnlen)36, (ftnlen)9);
    bltcod[459] = 1000124;
    s_copy(bltnam + 16524, "MUELLER 3", (ftnlen)36, (ftnlen)9);
    bltcod[460] = 1000125;
    s_copy(bltnam + 16560, "SHOEMAKER-LEVY 1", (ftnlen)36, (ftnlen)16);
    bltcod[461] = 1000126;
    s_copy(bltnam + 16596, "SHOEMAKER-LEVY 2", (ftnlen)36, (ftnlen)16);
    bltcod[462] = 1000127;
    s_copy(bltnam + 16632, "HOLT-OLMSTEAD", (ftnlen)36, (ftnlen)13);
    bltcod[463] = 1000128;
    s_copy(bltnam + 16668, "METCALF-BREWINGTON", (ftnlen)36, (ftnlen)18);
    bltcod[464] = 1000129;
    s_copy(bltnam + 16704, "LEVY", (ftnlen)36, (ftnlen)4);
    bltcod[465] = 1000130;
    s_copy(bltnam + 16740, "SHOEMAKER-LEVY 9", (ftnlen)36, (ftnlen)16);
    bltcod[466] = 1000131;
    s_copy(bltnam + 16776, "HYAKUTAKE", (ftnlen)36, (ftnlen)9);
    bltcod[467] = 1000132;
    s_copy(bltnam + 16812, "HALE-BOPP", (ftnlen)36, (ftnlen)9);
    bltcod[468] = 9511010;
    s_copy(bltnam + 16848, "GASPRA", (ftnlen)36, (ftnlen)6);
    bltcod[469] = 2431010;
    s_copy(bltnam + 16884, "IDA", (ftnlen)36, (ftnlen)3);
    bltcod[470] = 2431011;
    s_copy(bltnam + 16920, "DACTYL", (ftnlen)36, (ftnlen)6);
    bltcod[471] = 2000001;
    s_copy(bltnam + 16956, "CERES", (ftnlen)36, (ftnlen)5);
    bltcod[472] = 2000004;
    s_copy(bltnam + 16992, "VESTA", (ftnlen)36, (ftnlen)5);
    bltcod[473] = 2000216;
    s_copy(bltnam + 17028, "KLEOPATRA", (ftnlen)36, (ftnlen)9);
    bltcod[474] = 2000433;
    s_copy(bltnam + 17064, "EROS", (ftnlen)36, (ftnlen)4);
    bltcod[475] = 2000253;
    s_copy(bltnam + 17100, "MATHILDE", (ftnlen)36, (ftnlen)8);
    bltcod[476] = 2009969;
    s_copy(bltnam + 17136, "1992KD", (ftnlen)36, (ftnlen)6);
    bltcod[477] = 2009969;
    s_copy(bltnam + 17172, "BRAILLE", (ftnlen)36, (ftnlen)7);
    bltcod[478] = 2004015;
    s_copy(bltnam + 17208, "WILSON-HARRINGTON", (ftnlen)36, (ftnlen)17);
    bltcod[479] = 2025143;
    s_copy(bltnam + 17244, "ITOKAWA", (ftnlen)36, (ftnlen)7);
    bltcod[480] = 398989;
    s_copy(bltnam + 17280, "NOTO", (ftnlen)36, (ftnlen)4);
    bltcod[481] = 398990;
    s_copy(bltnam + 17316, "NEW NORCIA", (ftnlen)36, (ftnlen)10);
    bltcod[482] = 399001;
    s_copy(bltnam + 17352, "GOLDSTONE", (ftnlen)36, (ftnlen)9);
    bltcod[483] = 399002;
    s_copy(bltnam + 17388, "CANBERRA", (ftnlen)36, (ftnlen)8);
    bltcod[484] = 399003;
    s_copy(bltnam + 17424, "MADRID", (ftnlen)36, (ftnlen)6);
    bltcod[485] = 399004;
    s_copy(bltnam + 17460, "USUDA", (ftnlen)36, (ftnlen)5);
    bltcod[486] = 399005;
    s_copy(bltnam + 17496, "DSS-05", (ftnlen)36, (ftnlen)6);
    bltcod[487] = 399005;
    s_copy(bltnam + 17532, "PARKES", (ftnlen)36, (ftnlen)6);
    bltcod[488] = 399012;
    s_copy(bltnam + 17568, "DSS-12", (ftnlen)36, (ftnlen)6);
    bltcod[489] = 399013;
    s_copy(bltnam + 17604, "DSS-13", (ftnlen)36, (ftnlen)6);
    bltcod[490] = 399014;
    s_copy(bltnam + 17640, "DSS-14", (ftnlen)36, (ftnlen)6);
    bltcod[491] = 399015;
    s_copy(bltnam + 17676, "DSS-15", (ftnlen)36, (ftnlen)6);
    bltcod[492] = 399016;
    s_copy(bltnam + 17712, "DSS-16", (ftnlen)36, (ftnlen)6);
    bltcod[493] = 399017;
    s_copy(bltnam + 17748, "DSS-17", (ftnlen)36, (ftnlen)6);
    bltcod[494] = 399023;
    s_copy(bltnam + 17784, "DSS-23", (ftnlen)36, (ftnlen)6);
    bltcod[495] = 399024;
    s_copy(bltnam + 17820, "DSS-24", (ftnlen)36, (ftnlen)6);
    bltcod[496] = 399025;
    s_copy(bltnam + 17856, "DSS-25", (ftnlen)36, (ftnlen)6);
    bltcod[497] = 399026;
    s_copy(bltnam + 17892, "DSS-26", (ftnlen)36, (ftnlen)6);
    bltcod[498] = 399027;
    s_copy(bltnam + 17928, "DSS-27", (ftnlen)36, (ftnlen)6);
    bltcod[499] = 399028;
    s_copy(bltnam + 17964, "DSS-28", (ftnlen)36, (ftnlen)6);
    bltcod[500] = 399033;
    s_copy(bltnam + 18000, "DSS-33", (ftnlen)36, (ftnlen)6);
    bltcod[501] = 399034;
    s_copy(bltnam + 18036, "DSS-34", (ftnlen)36, (ftnlen)6);
    bltcod[502] = 399042;
    s_copy(bltnam + 18072, "DSS-42", (ftnlen)36, (ftnlen)6);
    bltcod[503] = 399043;
    s_copy(bltnam + 18108, "DSS-43", (ftnlen)36, (ftnlen)6);
    bltcod[504] = 399045;
    s_copy(bltnam + 18144, "DSS-45", (ftnlen)36, (ftnlen)6);
    bltcod[505] = 399046;
    s_copy(bltnam + 18180, "DSS-46", (ftnlen)36, (ftnlen)6);
    bltcod[506] = 399049;
    s_copy(bltnam + 18216, "DSS-49", (ftnlen)36, (ftnlen)6);
    bltcod[507] = 399053;
    s_copy(bltnam + 18252, "DSS-53", (ftnlen)36, (ftnlen)6);
    bltcod[508] = 399054;
    s_copy(bltnam + 18288, "DSS-54", (ftnlen)36, (ftnlen)6);
    bltcod[509] = 399055;
    s_copy(bltnam + 18324, "DSS-55", (ftnlen)36, (ftnlen)6);
    bltcod[510] = 399061;
    s_copy(bltnam + 18360, "DSS-61", (ftnlen)36, (ftnlen)6);
    bltcod[511] = 399063;
    s_copy(bltnam + 18396, "DSS-63", (ftnlen)36, (ftnlen)6);
    bltcod[512] = 399064;
    s_copy(bltnam + 18432, "DSS-64", (ftnlen)36, (ftnlen)6);
    bltcod[513] = 399065;
    s_copy(bltnam + 18468, "DSS-65", (ftnlen)36, (ftnlen)6);
    bltcod[514] = 399066;
    s_copy(bltnam + 18504, "DSS-66", (ftnlen)36, (ftnlen)6);
    return 0;
} /* zzidmap_ */

