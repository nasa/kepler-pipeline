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

/*     SPICELIB 1.0.0 Wed Jan  9 14:12:55 2008 (EDW) */


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

/*     E.D. Wright, Wed Jan  9 14:12:55 2008 (JPL) */

/* $ Version */

/* -    SPICELIB 1.0.5 09-JAN-2008 (EDW) */

/*     Added: */

/*              -18   LCROSS */
/*              -29   NEXT */
/*              -86   CH1 */
/*              -86   CHANDRAYAAN-1 */
/*             -131   KAGUYA */
/*             -140   EPOXI */
/*             -151   CHANDRA */
/*             -187   SOLAR PROBE */
/*              636   AEGIR */
/*              637   BEBHIONN */
/*              638   BERGELMIR */
/*              639   BESTLA */
/*              640   FARBAUTI */
/*              641   FENRIR */
/*              642   FORNJOT */
/*              643   HATI */
/*              644   HYROKKIN */
/*              645   KARI */
/*              646   LOGE */
/*              647   SKOLL */
/*              648   SURTUR */
/*              649   ANTHE */
/*              650   JARNSAXA */
/*              651   GREIP */
/*              652   TARQEQ */
/*              809   HALIMEDE */
/*              810   PSAMATHE */
/*              811   SAO */
/*              812   LAOMEDEIA */
/*              813   NESO */

/*     NAIF modified the Jovian system listing to conform to the */
/*     current (as of this date) name/body mapping. */

/*              540   MNEME */
/*              541   AOEDE */
/*              542   THELXINOE */
/*              543   ARCHE */
/*              544   KALLICHORE */
/*              545   HELIKE */
/*              546   CARPO */
/*              547   EUKELADE */
/*              548   CYLLENE */
/*              549   KORE */

/*     Removed assignments: */

/*             -172   SPACETECH-3 COMBINER */
/*             -174   PLUTO-KUIPER EXPRESS */
/*             -175   PLUTO-KUIPER EXPRESS SIMULATION */
/*             -205   SPACETECH-3 COLLECTOR */
/*              514   1979J2 */
/*              515   1979J1 */
/*              516   1979J3 */
/*              610   1980S1 */
/*              611   1980S3 */
/*              612   1980S6 */
/*              613   1980S13 */
/*              614   1980S25 */
/*              615   1980S28 */
/*              616   1980S27 */
/*              617   1980S26 */
/*              706   1986U7 */
/*              707   1986U8 */
/*              708   1986U9 */
/*              709   1986U4 */
/*              710   1986U6 */
/*              711   1986U3 */
/*              712   1986U1 */
/*              713   1986U2 */
/*              714   1986U5 */
/*              715   1985U1 */
/*              718   1986U10 */
/*              901   1978P1 */

/*     Spelling correction: */

/*        MAGACLITE to MEGACLITE */

/*     Rename: */

/*        ERRIAPO to ERRIAPUS */
/*        STV-1 to STV51 */
/*        STV-2 to STV52 */
/*        STV-3 to STV53 */


/* -    SPICELIB 1.0.4 01-NOV-2006 (EDW) */

/*     NAIF removed several provisional name/ID mappings from */
/*     the Jovian system listing: */

/*     539         'HEGEMONE'              JXXXIX */
/*     540         'MNEME'                 JXL */
/*     541         'AOEDE'                 JXLI */
/*     542         'THELXINOE'             JXLII */
/*     543         'ARCHE'                 JXLIII */
/*     544         'KALLICHORE'            JXLIV */
/*     545         'HELIKE'                JXLV */
/*     546         'CARPO'                 JXLVI */
/*     547         'EUKELADE'              JXLVII */
/*     548         'CYLLENE'               JXLVIII */

/*     The current mapping set for the range 539-561: */

/*              540   ARCHE */
/*              541   EUKELADE */
/*              546   HELIKE */
/*              547   AOEDE */
/*              548   HEGEMONE */
/*              551   KALLICHORE */
/*              553   CYLLENE */
/*              560   CARPO */
/*              561   MNEME */

/*     The new mapping leaves the IDs 539, 542-545, 549, 550, 552, */
/*     554-559 unassigned. */

/*     Added: */

/*              635   DAPHNIS */
/*              722   FRANCISCO */
/*              723   MARGARET */
/*              724   FERDINAND */
/*              725   PERDITA */
/*              726   MAB */
/*              727   CUPID */
/*              -61   JUNO */
/*              -76   MSL */
/*              -76   MARS SCIENCE LABORATORY */
/*             -212   STV-1 */
/*             -213   STV-2 */
/*             -214   STV-3 */
/*              902   NIX */
/*              903   HYDRA */
/*             -85    LRO */
/*             -85    LUNAR RECON ORBITER */
/*             -85    LUNAR RECONNAISSANCE ORBITER */

/*     Spelling correction */

/*              632   METHODE to METHONE */

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
    s_copy(bltnam + 1296, "THEBE", (ftnlen)36, (ftnlen)5);
    bltcod[37] = 515;
    s_copy(bltnam + 1332, "ADRASTEA", (ftnlen)36, (ftnlen)8);
    bltcod[38] = 516;
    s_copy(bltnam + 1368, "METIS", (ftnlen)36, (ftnlen)5);
    bltcod[39] = 517;
    s_copy(bltnam + 1404, "CALLIRRHOE", (ftnlen)36, (ftnlen)10);
    bltcod[40] = 518;
    s_copy(bltnam + 1440, "THEMISTO", (ftnlen)36, (ftnlen)8);
    bltcod[41] = 519;
    s_copy(bltnam + 1476, "MAGACLITE", (ftnlen)36, (ftnlen)9);
    bltcod[42] = 520;
    s_copy(bltnam + 1512, "TAYGETE", (ftnlen)36, (ftnlen)7);
    bltcod[43] = 521;
    s_copy(bltnam + 1548, "CHALDENE", (ftnlen)36, (ftnlen)8);
    bltcod[44] = 522;
    s_copy(bltnam + 1584, "HARPALYKE", (ftnlen)36, (ftnlen)9);
    bltcod[45] = 523;
    s_copy(bltnam + 1620, "KALYKE", (ftnlen)36, (ftnlen)6);
    bltcod[46] = 524;
    s_copy(bltnam + 1656, "IOCASTE", (ftnlen)36, (ftnlen)7);
    bltcod[47] = 525;
    s_copy(bltnam + 1692, "ERINOME", (ftnlen)36, (ftnlen)7);
    bltcod[48] = 526;
    s_copy(bltnam + 1728, "ISONOE", (ftnlen)36, (ftnlen)6);
    bltcod[49] = 527;
    s_copy(bltnam + 1764, "PRAXIDIKE", (ftnlen)36, (ftnlen)9);
    bltcod[50] = 528;
    s_copy(bltnam + 1800, "AUTONOE", (ftnlen)36, (ftnlen)7);
    bltcod[51] = 529;
    s_copy(bltnam + 1836, "THYONE", (ftnlen)36, (ftnlen)6);
    bltcod[52] = 530;
    s_copy(bltnam + 1872, "HERMIPPE", (ftnlen)36, (ftnlen)8);
    bltcod[53] = 531;
    s_copy(bltnam + 1908, "AITNE", (ftnlen)36, (ftnlen)5);
    bltcod[54] = 532;
    s_copy(bltnam + 1944, "EURYDOME", (ftnlen)36, (ftnlen)8);
    bltcod[55] = 533;
    s_copy(bltnam + 1980, "EUANTHE", (ftnlen)36, (ftnlen)7);
    bltcod[56] = 534;
    s_copy(bltnam + 2016, "EUPORIE", (ftnlen)36, (ftnlen)7);
    bltcod[57] = 535;
    s_copy(bltnam + 2052, "ORTHOSIE", (ftnlen)36, (ftnlen)8);
    bltcod[58] = 536;
    s_copy(bltnam + 2088, "SPONDE", (ftnlen)36, (ftnlen)6);
    bltcod[59] = 537;
    s_copy(bltnam + 2124, "KALE", (ftnlen)36, (ftnlen)4);
    bltcod[60] = 538;
    s_copy(bltnam + 2160, "PASITHEE", (ftnlen)36, (ftnlen)8);
    bltcod[61] = 539;
    s_copy(bltnam + 2196, "HEGEMONE", (ftnlen)36, (ftnlen)8);
    bltcod[62] = 540;
    s_copy(bltnam + 2232, "MNEME", (ftnlen)36, (ftnlen)5);
    bltcod[63] = 541;
    s_copy(bltnam + 2268, "AOEDE", (ftnlen)36, (ftnlen)5);
    bltcod[64] = 542;
    s_copy(bltnam + 2304, "THELXINOE", (ftnlen)36, (ftnlen)9);
    bltcod[65] = 543;
    s_copy(bltnam + 2340, "ARCHE", (ftnlen)36, (ftnlen)5);
    bltcod[66] = 544;
    s_copy(bltnam + 2376, "KALLICHORE", (ftnlen)36, (ftnlen)10);
    bltcod[67] = 545;
    s_copy(bltnam + 2412, "HELIKE", (ftnlen)36, (ftnlen)6);
    bltcod[68] = 546;
    s_copy(bltnam + 2448, "CARPO", (ftnlen)36, (ftnlen)5);
    bltcod[69] = 547;
    s_copy(bltnam + 2484, "EUKELADE", (ftnlen)36, (ftnlen)8);
    bltcod[70] = 548;
    s_copy(bltnam + 2520, "CYLLENE", (ftnlen)36, (ftnlen)7);
    bltcod[71] = 549;
    s_copy(bltnam + 2556, "KORE", (ftnlen)36, (ftnlen)4);
    bltcod[72] = 699;
    s_copy(bltnam + 2592, "SATURN", (ftnlen)36, (ftnlen)6);
    bltcod[73] = 601;
    s_copy(bltnam + 2628, "MIMAS", (ftnlen)36, (ftnlen)5);
    bltcod[74] = 602;
    s_copy(bltnam + 2664, "ENCELADUS", (ftnlen)36, (ftnlen)9);
    bltcod[75] = 603;
    s_copy(bltnam + 2700, "TETHYS", (ftnlen)36, (ftnlen)6);
    bltcod[76] = 604;
    s_copy(bltnam + 2736, "DIONE", (ftnlen)36, (ftnlen)5);
    bltcod[77] = 605;
    s_copy(bltnam + 2772, "RHEA", (ftnlen)36, (ftnlen)4);
    bltcod[78] = 606;
    s_copy(bltnam + 2808, "TITAN", (ftnlen)36, (ftnlen)5);
    bltcod[79] = 607;
    s_copy(bltnam + 2844, "HYPERION", (ftnlen)36, (ftnlen)8);
    bltcod[80] = 608;
    s_copy(bltnam + 2880, "IAPETUS", (ftnlen)36, (ftnlen)7);
    bltcod[81] = 609;
    s_copy(bltnam + 2916, "PHOEBE", (ftnlen)36, (ftnlen)6);
    bltcod[82] = 610;
    s_copy(bltnam + 2952, "JANUS", (ftnlen)36, (ftnlen)5);
    bltcod[83] = 611;
    s_copy(bltnam + 2988, "EPIMETHEUS", (ftnlen)36, (ftnlen)10);
    bltcod[84] = 612;
    s_copy(bltnam + 3024, "HELENE", (ftnlen)36, (ftnlen)6);
    bltcod[85] = 613;
    s_copy(bltnam + 3060, "TELESTO", (ftnlen)36, (ftnlen)7);
    bltcod[86] = 614;
    s_copy(bltnam + 3096, "CALYPSO", (ftnlen)36, (ftnlen)7);
    bltcod[87] = 615;
    s_copy(bltnam + 3132, "ATLAS", (ftnlen)36, (ftnlen)5);
    bltcod[88] = 616;
    s_copy(bltnam + 3168, "PROMETHEUS", (ftnlen)36, (ftnlen)10);
    bltcod[89] = 617;
    s_copy(bltnam + 3204, "PANDORA", (ftnlen)36, (ftnlen)7);
    bltcod[90] = 618;
    s_copy(bltnam + 3240, "PAN", (ftnlen)36, (ftnlen)3);
    bltcod[91] = 619;
    s_copy(bltnam + 3276, "YMIR", (ftnlen)36, (ftnlen)4);
    bltcod[92] = 620;
    s_copy(bltnam + 3312, "PAALIAQ", (ftnlen)36, (ftnlen)7);
    bltcod[93] = 621;
    s_copy(bltnam + 3348, "TARVOS", (ftnlen)36, (ftnlen)6);
    bltcod[94] = 622;
    s_copy(bltnam + 3384, "IJIRAQ", (ftnlen)36, (ftnlen)6);
    bltcod[95] = 623;
    s_copy(bltnam + 3420, "SUTTUNGR", (ftnlen)36, (ftnlen)8);
    bltcod[96] = 624;
    s_copy(bltnam + 3456, "KIVIUQ", (ftnlen)36, (ftnlen)6);
    bltcod[97] = 625;
    s_copy(bltnam + 3492, "MUNDILFARI", (ftnlen)36, (ftnlen)10);
    bltcod[98] = 626;
    s_copy(bltnam + 3528, "ALBIORIX", (ftnlen)36, (ftnlen)8);
    bltcod[99] = 627;
    s_copy(bltnam + 3564, "SKATHI", (ftnlen)36, (ftnlen)6);
    bltcod[100] = 628;
    s_copy(bltnam + 3600, "ERRIAPUS", (ftnlen)36, (ftnlen)8);
    bltcod[101] = 629;
    s_copy(bltnam + 3636, "SIARNAQ", (ftnlen)36, (ftnlen)7);
    bltcod[102] = 630;
    s_copy(bltnam + 3672, "THRYMR", (ftnlen)36, (ftnlen)6);
    bltcod[103] = 631;
    s_copy(bltnam + 3708, "NARVI", (ftnlen)36, (ftnlen)5);
    bltcod[104] = 632;
    s_copy(bltnam + 3744, "METHONE", (ftnlen)36, (ftnlen)7);
    bltcod[105] = 633;
    s_copy(bltnam + 3780, "PALLENE", (ftnlen)36, (ftnlen)7);
    bltcod[106] = 634;
    s_copy(bltnam + 3816, "POLYDEUCES", (ftnlen)36, (ftnlen)10);
    bltcod[107] = 635;
    s_copy(bltnam + 3852, "DAPHNIS", (ftnlen)36, (ftnlen)7);
    bltcod[108] = 636;
    s_copy(bltnam + 3888, "AEGIR", (ftnlen)36, (ftnlen)5);
    bltcod[109] = 637;
    s_copy(bltnam + 3924, "BEBHIONN", (ftnlen)36, (ftnlen)8);
    bltcod[110] = 638;
    s_copy(bltnam + 3960, "BERGELMIR", (ftnlen)36, (ftnlen)9);
    bltcod[111] = 639;
    s_copy(bltnam + 3996, "BESTLA", (ftnlen)36, (ftnlen)6);
    bltcod[112] = 640;
    s_copy(bltnam + 4032, "FARBAUTI", (ftnlen)36, (ftnlen)8);
    bltcod[113] = 641;
    s_copy(bltnam + 4068, "FENRIR", (ftnlen)36, (ftnlen)6);
    bltcod[114] = 642;
    s_copy(bltnam + 4104, "FORNJOT", (ftnlen)36, (ftnlen)7);
    bltcod[115] = 643;
    s_copy(bltnam + 4140, "HATI", (ftnlen)36, (ftnlen)4);
    bltcod[116] = 644;
    s_copy(bltnam + 4176, "HYROKKIN", (ftnlen)36, (ftnlen)8);
    bltcod[117] = 645;
    s_copy(bltnam + 4212, "KARI", (ftnlen)36, (ftnlen)4);
    bltcod[118] = 646;
    s_copy(bltnam + 4248, "LOGE", (ftnlen)36, (ftnlen)4);
    bltcod[119] = 647;
    s_copy(bltnam + 4284, "SKOLL", (ftnlen)36, (ftnlen)5);
    bltcod[120] = 648;
    s_copy(bltnam + 4320, "SURTUR", (ftnlen)36, (ftnlen)6);
    bltcod[121] = 649;
    s_copy(bltnam + 4356, "ANTHE", (ftnlen)36, (ftnlen)5);
    bltcod[122] = 650;
    s_copy(bltnam + 4392, "JARNSAXA", (ftnlen)36, (ftnlen)8);
    bltcod[123] = 651;
    s_copy(bltnam + 4428, "GREIP", (ftnlen)36, (ftnlen)5);
    bltcod[124] = 652;
    s_copy(bltnam + 4464, "TARQEQ", (ftnlen)36, (ftnlen)6);
    bltcod[125] = 799;
    s_copy(bltnam + 4500, "URANUS", (ftnlen)36, (ftnlen)6);
    bltcod[126] = 701;
    s_copy(bltnam + 4536, "ARIEL", (ftnlen)36, (ftnlen)5);
    bltcod[127] = 702;
    s_copy(bltnam + 4572, "UMBRIEL", (ftnlen)36, (ftnlen)7);
    bltcod[128] = 703;
    s_copy(bltnam + 4608, "TITANIA", (ftnlen)36, (ftnlen)7);
    bltcod[129] = 704;
    s_copy(bltnam + 4644, "OBERON", (ftnlen)36, (ftnlen)6);
    bltcod[130] = 705;
    s_copy(bltnam + 4680, "MIRANDA", (ftnlen)36, (ftnlen)7);
    bltcod[131] = 706;
    s_copy(bltnam + 4716, "CORDELIA", (ftnlen)36, (ftnlen)8);
    bltcod[132] = 707;
    s_copy(bltnam + 4752, "OPHELIA", (ftnlen)36, (ftnlen)7);
    bltcod[133] = 708;
    s_copy(bltnam + 4788, "BIANCA", (ftnlen)36, (ftnlen)6);
    bltcod[134] = 709;
    s_copy(bltnam + 4824, "CRESSIDA", (ftnlen)36, (ftnlen)8);
    bltcod[135] = 710;
    s_copy(bltnam + 4860, "DESDEMONA", (ftnlen)36, (ftnlen)9);
    bltcod[136] = 711;
    s_copy(bltnam + 4896, "JULIET", (ftnlen)36, (ftnlen)6);
    bltcod[137] = 712;
    s_copy(bltnam + 4932, "PORTIA", (ftnlen)36, (ftnlen)6);
    bltcod[138] = 713;
    s_copy(bltnam + 4968, "ROSALIND", (ftnlen)36, (ftnlen)8);
    bltcod[139] = 714;
    s_copy(bltnam + 5004, "BELINDA", (ftnlen)36, (ftnlen)7);
    bltcod[140] = 715;
    s_copy(bltnam + 5040, "PUCK", (ftnlen)36, (ftnlen)4);
    bltcod[141] = 716;
    s_copy(bltnam + 5076, "CALIBAN", (ftnlen)36, (ftnlen)7);
    bltcod[142] = 717;
    s_copy(bltnam + 5112, "SYCORAX", (ftnlen)36, (ftnlen)7);
    bltcod[143] = 718;
    s_copy(bltnam + 5148, "PROSPERO", (ftnlen)36, (ftnlen)8);
    bltcod[144] = 719;
    s_copy(bltnam + 5184, "SETEBOS", (ftnlen)36, (ftnlen)7);
    bltcod[145] = 720;
    s_copy(bltnam + 5220, "STEPHANO", (ftnlen)36, (ftnlen)8);
    bltcod[146] = 721;
    s_copy(bltnam + 5256, "TRINCULO", (ftnlen)36, (ftnlen)8);
    bltcod[147] = 722;
    s_copy(bltnam + 5292, "FRANCISCO", (ftnlen)36, (ftnlen)9);
    bltcod[148] = 723;
    s_copy(bltnam + 5328, "MARGARET", (ftnlen)36, (ftnlen)8);
    bltcod[149] = 724;
    s_copy(bltnam + 5364, "FERDINAND", (ftnlen)36, (ftnlen)9);
    bltcod[150] = 725;
    s_copy(bltnam + 5400, "PERDITA", (ftnlen)36, (ftnlen)7);
    bltcod[151] = 726;
    s_copy(bltnam + 5436, "MAB", (ftnlen)36, (ftnlen)3);
    bltcod[152] = 727;
    s_copy(bltnam + 5472, "CUPID", (ftnlen)36, (ftnlen)5);
    bltcod[153] = 899;
    s_copy(bltnam + 5508, "NEPTUNE", (ftnlen)36, (ftnlen)7);
    bltcod[154] = 801;
    s_copy(bltnam + 5544, "TRITON", (ftnlen)36, (ftnlen)6);
    bltcod[155] = 802;
    s_copy(bltnam + 5580, "NEREID", (ftnlen)36, (ftnlen)6);
    bltcod[156] = 803;
    s_copy(bltnam + 5616, "NAIAD", (ftnlen)36, (ftnlen)5);
    bltcod[157] = 804;
    s_copy(bltnam + 5652, "THALASSA", (ftnlen)36, (ftnlen)8);
    bltcod[158] = 805;
    s_copy(bltnam + 5688, "DESPINA", (ftnlen)36, (ftnlen)7);
    bltcod[159] = 806;
    s_copy(bltnam + 5724, "GALATEA", (ftnlen)36, (ftnlen)7);
    bltcod[160] = 807;
    s_copy(bltnam + 5760, "LARISSA", (ftnlen)36, (ftnlen)7);
    bltcod[161] = 808;
    s_copy(bltnam + 5796, "PROTEUS", (ftnlen)36, (ftnlen)7);
    bltcod[162] = 809;
    s_copy(bltnam + 5832, "HALIMEDE", (ftnlen)36, (ftnlen)8);
    bltcod[163] = 810;
    s_copy(bltnam + 5868, "PSAMATHE", (ftnlen)36, (ftnlen)8);
    bltcod[164] = 811;
    s_copy(bltnam + 5904, "SAO", (ftnlen)36, (ftnlen)3);
    bltcod[165] = 812;
    s_copy(bltnam + 5940, "LAOMEDEIA", (ftnlen)36, (ftnlen)9);
    bltcod[166] = 813;
    s_copy(bltnam + 5976, "NESO", (ftnlen)36, (ftnlen)4);
    bltcod[167] = 999;
    s_copy(bltnam + 6012, "PLUTO", (ftnlen)36, (ftnlen)5);
    bltcod[168] = 901;
    s_copy(bltnam + 6048, "CHARON", (ftnlen)36, (ftnlen)6);
    bltcod[169] = 902;
    s_copy(bltnam + 6084, "NIX", (ftnlen)36, (ftnlen)3);
    bltcod[170] = 903;
    s_copy(bltnam + 6120, "HYDRA", (ftnlen)36, (ftnlen)5);
    bltcod[171] = -1;
    s_copy(bltnam + 6156, "GEOTAIL", (ftnlen)36, (ftnlen)7);
    bltcod[172] = -6;
    s_copy(bltnam + 6192, "P6", (ftnlen)36, (ftnlen)2);
    bltcod[173] = -6;
    s_copy(bltnam + 6228, "PIONEER-6", (ftnlen)36, (ftnlen)9);
    bltcod[174] = -7;
    s_copy(bltnam + 6264, "P7", (ftnlen)36, (ftnlen)2);
    bltcod[175] = -7;
    s_copy(bltnam + 6300, "PIONEER-7", (ftnlen)36, (ftnlen)9);
    bltcod[176] = -8;
    s_copy(bltnam + 6336, "WIND", (ftnlen)36, (ftnlen)4);
    bltcod[177] = -12;
    s_copy(bltnam + 6372, "VENUS ORBITER", (ftnlen)36, (ftnlen)13);
    bltcod[178] = -12;
    s_copy(bltnam + 6408, "P12", (ftnlen)36, (ftnlen)3);
    bltcod[179] = -12;
    s_copy(bltnam + 6444, "PIONEER 12", (ftnlen)36, (ftnlen)10);
    bltcod[180] = -13;
    s_copy(bltnam + 6480, "POLAR", (ftnlen)36, (ftnlen)5);
    bltcod[181] = -18;
    s_copy(bltnam + 6516, "MGN", (ftnlen)36, (ftnlen)3);
    bltcod[182] = -18;
    s_copy(bltnam + 6552, "MAGELLAN", (ftnlen)36, (ftnlen)8);
    bltcod[183] = -18;
    s_copy(bltnam + 6588, "LCROSS", (ftnlen)36, (ftnlen)6);
    bltcod[184] = -20;
    s_copy(bltnam + 6624, "P8", (ftnlen)36, (ftnlen)2);
    bltcod[185] = -20;
    s_copy(bltnam + 6660, "PIONEER-8", (ftnlen)36, (ftnlen)9);
    bltcod[186] = -21;
    s_copy(bltnam + 6696, "SOHO", (ftnlen)36, (ftnlen)4);
    bltcod[187] = -23;
    s_copy(bltnam + 6732, "P10", (ftnlen)36, (ftnlen)3);
    bltcod[188] = -23;
    s_copy(bltnam + 6768, "PIONEER-10", (ftnlen)36, (ftnlen)10);
    bltcod[189] = -24;
    s_copy(bltnam + 6804, "P11", (ftnlen)36, (ftnlen)3);
    bltcod[190] = -24;
    s_copy(bltnam + 6840, "PIONEER-11", (ftnlen)36, (ftnlen)10);
    bltcod[191] = -25;
    s_copy(bltnam + 6876, "LP", (ftnlen)36, (ftnlen)2);
    bltcod[192] = -25;
    s_copy(bltnam + 6912, "LUNAR PROSPECTOR", (ftnlen)36, (ftnlen)16);
    bltcod[193] = -27;
    s_copy(bltnam + 6948, "VK1", (ftnlen)36, (ftnlen)3);
    bltcod[194] = -27;
    s_copy(bltnam + 6984, "VIKING 1 ORBITER", (ftnlen)36, (ftnlen)16);
    bltcod[195] = -29;
    s_copy(bltnam + 7020, "STARDUST", (ftnlen)36, (ftnlen)8);
    bltcod[196] = -29;
    s_copy(bltnam + 7056, "SDU", (ftnlen)36, (ftnlen)3);
    bltcod[197] = -29;
    s_copy(bltnam + 7092, "NEXT", (ftnlen)36, (ftnlen)4);
    bltcod[198] = -30;
    s_copy(bltnam + 7128, "VK2", (ftnlen)36, (ftnlen)3);
    bltcod[199] = -30;
    s_copy(bltnam + 7164, "VIKING 2 ORBITER", (ftnlen)36, (ftnlen)16);
    bltcod[200] = -30;
    s_copy(bltnam + 7200, "DS-1", (ftnlen)36, (ftnlen)4);
    bltcod[201] = -31;
    s_copy(bltnam + 7236, "VG1", (ftnlen)36, (ftnlen)3);
    bltcod[202] = -31;
    s_copy(bltnam + 7272, "VOYAGER 1", (ftnlen)36, (ftnlen)9);
    bltcod[203] = -32;
    s_copy(bltnam + 7308, "VG2", (ftnlen)36, (ftnlen)3);
    bltcod[204] = -32;
    s_copy(bltnam + 7344, "VOYAGER 2", (ftnlen)36, (ftnlen)9);
    bltcod[205] = -40;
    s_copy(bltnam + 7380, "CLEMENTINE", (ftnlen)36, (ftnlen)10);
    bltcod[206] = -41;
    s_copy(bltnam + 7416, "MEX", (ftnlen)36, (ftnlen)3);
    bltcod[207] = -41;
    s_copy(bltnam + 7452, "MARS EXPRESS", (ftnlen)36, (ftnlen)12);
    bltcod[208] = -44;
    s_copy(bltnam + 7488, "BEAGLE2", (ftnlen)36, (ftnlen)7);
    bltcod[209] = -44;
    s_copy(bltnam + 7524, "BEAGLE 2", (ftnlen)36, (ftnlen)8);
    bltcod[210] = -46;
    s_copy(bltnam + 7560, "MS-T5", (ftnlen)36, (ftnlen)5);
    bltcod[211] = -46;
    s_copy(bltnam + 7596, "SAKIGAKE", (ftnlen)36, (ftnlen)8);
    bltcod[212] = -47;
    s_copy(bltnam + 7632, "PLANET-A", (ftnlen)36, (ftnlen)8);
    bltcod[213] = -47;
    s_copy(bltnam + 7668, "SUISEI", (ftnlen)36, (ftnlen)6);
    bltcod[214] = -47;
    s_copy(bltnam + 7704, "GNS", (ftnlen)36, (ftnlen)3);
    bltcod[215] = -47;
    s_copy(bltnam + 7740, "GENESIS", (ftnlen)36, (ftnlen)7);
    bltcod[216] = -48;
    s_copy(bltnam + 7776, "HUBBLE SPACE TELESCOPE", (ftnlen)36, (ftnlen)22);
    bltcod[217] = -48;
    s_copy(bltnam + 7812, "HST", (ftnlen)36, (ftnlen)3);
    bltcod[218] = -53;
    s_copy(bltnam + 7848, "MARS PATHFINDER", (ftnlen)36, (ftnlen)15);
    bltcod[219] = -53;
    s_copy(bltnam + 7884, "MPF", (ftnlen)36, (ftnlen)3);
    bltcod[220] = -53;
    s_copy(bltnam + 7920, "MARS ODYSSEY", (ftnlen)36, (ftnlen)12);
    bltcod[221] = -53;
    s_copy(bltnam + 7956, "MARS SURVEYOR 01 ORBITER", (ftnlen)36, (ftnlen)24);
    bltcod[222] = -55;
    s_copy(bltnam + 7992, "ULYSSES", (ftnlen)36, (ftnlen)7);
    bltcod[223] = -58;
    s_copy(bltnam + 8028, "VSOP", (ftnlen)36, (ftnlen)4);
    bltcod[224] = -58;
    s_copy(bltnam + 8064, "HALCA", (ftnlen)36, (ftnlen)5);
    bltcod[225] = -59;
    s_copy(bltnam + 8100, "RADIOASTRON", (ftnlen)36, (ftnlen)11);
    bltcod[226] = -61;
    s_copy(bltnam + 8136, "JUNO", (ftnlen)36, (ftnlen)4);
    bltcod[227] = -76;
    s_copy(bltnam + 8172, "MSL", (ftnlen)36, (ftnlen)3);
    bltcod[228] = -76;
    s_copy(bltnam + 8208, "MARS SCIENCE LABORATORY", (ftnlen)36, (ftnlen)23);
    bltcod[229] = -66;
    s_copy(bltnam + 8244, "VEGA 1", (ftnlen)36, (ftnlen)6);
    bltcod[230] = -67;
    s_copy(bltnam + 8280, "VEGA 2", (ftnlen)36, (ftnlen)6);
    bltcod[231] = -70;
    s_copy(bltnam + 8316, "DEEP IMPACT IMPACTOR SPACECRAFT", (ftnlen)36, (
	    ftnlen)31);
    bltcod[232] = -74;
    s_copy(bltnam + 8352, "MRO", (ftnlen)36, (ftnlen)3);
    bltcod[233] = -74;
    s_copy(bltnam + 8388, "MARS RECON ORBITER", (ftnlen)36, (ftnlen)18);
    bltcod[234] = -77;
    s_copy(bltnam + 8424, "GLL", (ftnlen)36, (ftnlen)3);
    bltcod[235] = -77;
    s_copy(bltnam + 8460, "GALILEO ORBITER", (ftnlen)36, (ftnlen)15);
    bltcod[236] = -78;
    s_copy(bltnam + 8496, "GIOTTO", (ftnlen)36, (ftnlen)6);
    bltcod[237] = -79;
    s_copy(bltnam + 8532, "SPITZER", (ftnlen)36, (ftnlen)7);
    bltcod[238] = -79;
    s_copy(bltnam + 8568, "SPACE INFRARED TELESCOPE FACILITY", (ftnlen)36, (
	    ftnlen)33);
    bltcod[239] = -79;
    s_copy(bltnam + 8604, "SIRTF", (ftnlen)36, (ftnlen)5);
    bltcod[240] = -81;
    s_copy(bltnam + 8640, "CASSINI ITL", (ftnlen)36, (ftnlen)11);
    bltcod[241] = -82;
    s_copy(bltnam + 8676, "CAS", (ftnlen)36, (ftnlen)3);
    bltcod[242] = -82;
    s_copy(bltnam + 8712, "CASSINI", (ftnlen)36, (ftnlen)7);
    bltcod[243] = -84;
    s_copy(bltnam + 8748, "PHOENIX", (ftnlen)36, (ftnlen)7);
    bltcod[244] = -85;
    s_copy(bltnam + 8784, "LRO", (ftnlen)36, (ftnlen)3);
    bltcod[245] = -85;
    s_copy(bltnam + 8820, "LUNAR RECON ORBITER", (ftnlen)36, (ftnlen)19);
    bltcod[246] = -85;
    s_copy(bltnam + 8856, "LUNAR RECONNAISSANCE ORBITER", (ftnlen)36, (ftnlen)
	    28);
    bltcod[247] = -86;
    s_copy(bltnam + 8892, "CH1", (ftnlen)36, (ftnlen)3);
    bltcod[248] = -86;
    s_copy(bltnam + 8928, "CHANDRAYAAN-1", (ftnlen)36, (ftnlen)13);
    bltcod[249] = -90;
    s_copy(bltnam + 8964, "CASSINI SIMULATION", (ftnlen)36, (ftnlen)18);
    bltcod[250] = -93;
    s_copy(bltnam + 9000, "NEAR EARTH ASTEROID RENDEZVOUS", (ftnlen)36, (
	    ftnlen)30);
    bltcod[251] = -93;
    s_copy(bltnam + 9036, "NEAR", (ftnlen)36, (ftnlen)4);
    bltcod[252] = -94;
    s_copy(bltnam + 9072, "MO", (ftnlen)36, (ftnlen)2);
    bltcod[253] = -94;
    s_copy(bltnam + 9108, "MARS OBSERVER", (ftnlen)36, (ftnlen)13);
    bltcod[254] = -94;
    s_copy(bltnam + 9144, "MGS", (ftnlen)36, (ftnlen)3);
    bltcod[255] = -94;
    s_copy(bltnam + 9180, "MARS GLOBAL SURVEYOR", (ftnlen)36, (ftnlen)20);
    bltcod[256] = -95;
    s_copy(bltnam + 9216, "MGS SIMULATION", (ftnlen)36, (ftnlen)14);
    bltcod[257] = -97;
    s_copy(bltnam + 9252, "TOPEX/POSEIDON", (ftnlen)36, (ftnlen)14);
    bltcod[258] = -98;
    s_copy(bltnam + 9288, "NEW HORIZONS", (ftnlen)36, (ftnlen)12);
    bltcod[259] = -107;
    s_copy(bltnam + 9324, "TROPICAL RAINFALL MEASURING MISSION", (ftnlen)36, (
	    ftnlen)35);
    bltcod[260] = -107;
    s_copy(bltnam + 9360, "TRMM", (ftnlen)36, (ftnlen)4);
    bltcod[261] = -112;
    s_copy(bltnam + 9396, "ICE", (ftnlen)36, (ftnlen)3);
    bltcod[262] = -116;
    s_copy(bltnam + 9432, "MARS POLAR LANDER", (ftnlen)36, (ftnlen)17);
    bltcod[263] = -116;
    s_copy(bltnam + 9468, "MPL", (ftnlen)36, (ftnlen)3);
    bltcod[264] = -127;
    s_copy(bltnam + 9504, "MARS CLIMATE ORBITER", (ftnlen)36, (ftnlen)20);
    bltcod[265] = -127;
    s_copy(bltnam + 9540, "MCO", (ftnlen)36, (ftnlen)3);
    bltcod[266] = -130;
    s_copy(bltnam + 9576, "MUSES-C", (ftnlen)36, (ftnlen)7);
    bltcod[267] = -130;
    s_copy(bltnam + 9612, "HAYABUSA", (ftnlen)36, (ftnlen)8);
    bltcod[268] = -131;
    s_copy(bltnam + 9648, "SELENE", (ftnlen)36, (ftnlen)6);
    bltcod[269] = -131;
    s_copy(bltnam + 9684, "KAGUYA", (ftnlen)36, (ftnlen)6);
    bltcod[270] = -135;
    s_copy(bltnam + 9720, "DRTS-W", (ftnlen)36, (ftnlen)6);
    bltcod[271] = -140;
    s_copy(bltnam + 9756, "DEEP IMPACT FLYBY SPACECRAFT", (ftnlen)36, (ftnlen)
	    28);
    bltcod[272] = -140;
    s_copy(bltnam + 9792, "EPOXI", (ftnlen)36, (ftnlen)5);
    bltcod[273] = -142;
    s_copy(bltnam + 9828, "TERRA", (ftnlen)36, (ftnlen)5);
    bltcod[274] = -142;
    s_copy(bltnam + 9864, "EOS-AM1", (ftnlen)36, (ftnlen)7);
    bltcod[275] = -146;
    s_copy(bltnam + 9900, "LUNAR-A", (ftnlen)36, (ftnlen)7);
    bltcod[276] = -150;
    s_copy(bltnam + 9936, "CASSINI PROBE", (ftnlen)36, (ftnlen)13);
    bltcod[277] = -150;
    s_copy(bltnam + 9972, "HUYGENS PROBE", (ftnlen)36, (ftnlen)13);
    bltcod[278] = -150;
    s_copy(bltnam + 10008, "CASP", (ftnlen)36, (ftnlen)4);
    bltcod[279] = -151;
    s_copy(bltnam + 10044, "AXAF", (ftnlen)36, (ftnlen)4);
    bltcod[280] = -151;
    s_copy(bltnam + 10080, "CHANDRA", (ftnlen)36, (ftnlen)7);
    bltcod[281] = -154;
    s_copy(bltnam + 10116, "AQUA", (ftnlen)36, (ftnlen)4);
    bltcod[282] = -159;
    s_copy(bltnam + 10152, "EUROPA ORBITER", (ftnlen)36, (ftnlen)14);
    bltcod[283] = -164;
    s_copy(bltnam + 10188, "YOHKOH", (ftnlen)36, (ftnlen)6);
    bltcod[284] = -164;
    s_copy(bltnam + 10224, "SOLAR-A", (ftnlen)36, (ftnlen)7);
    bltcod[285] = -165;
    s_copy(bltnam + 10260, "MAP", (ftnlen)36, (ftnlen)3);
    bltcod[286] = -166;
    s_copy(bltnam + 10296, "IMAGE", (ftnlen)36, (ftnlen)5);
    bltcod[287] = -178;
    s_copy(bltnam + 10332, "PLANET-B", (ftnlen)36, (ftnlen)8);
    bltcod[288] = -178;
    s_copy(bltnam + 10368, "NOZOMI", (ftnlen)36, (ftnlen)6);
    bltcod[289] = -183;
    s_copy(bltnam + 10404, "CLUSTER 1", (ftnlen)36, (ftnlen)9);
    bltcod[290] = -185;
    s_copy(bltnam + 10440, "CLUSTER 2", (ftnlen)36, (ftnlen)9);
    bltcod[291] = -187;
    s_copy(bltnam + 10476, "SOLAR PROBE", (ftnlen)36, (ftnlen)11);
    bltcod[292] = -188;
    s_copy(bltnam + 10512, "MUSES-B", (ftnlen)36, (ftnlen)7);
    bltcod[293] = -190;
    s_copy(bltnam + 10548, "SIM", (ftnlen)36, (ftnlen)3);
    bltcod[294] = -194;
    s_copy(bltnam + 10584, "CLUSTER 3", (ftnlen)36, (ftnlen)9);
    bltcod[295] = -196;
    s_copy(bltnam + 10620, "CLUSTER 4", (ftnlen)36, (ftnlen)9);
    bltcod[296] = -198;
    s_copy(bltnam + 10656, "INTEGRAL", (ftnlen)36, (ftnlen)8);
    bltcod[297] = -200;
    s_copy(bltnam + 10692, "CONTOUR", (ftnlen)36, (ftnlen)7);
    bltcod[298] = -203;
    s_copy(bltnam + 10728, "DAWN", (ftnlen)36, (ftnlen)4);
    bltcod[299] = -212;
    s_copy(bltnam + 10764, "STV51", (ftnlen)36, (ftnlen)5);
    bltcod[300] = -213;
    s_copy(bltnam + 10800, "STV52", (ftnlen)36, (ftnlen)5);
    bltcod[301] = -214;
    s_copy(bltnam + 10836, "STV53", (ftnlen)36, (ftnlen)5);
    bltcod[302] = -226;
    s_copy(bltnam + 10872, "ROSETTA", (ftnlen)36, (ftnlen)7);
    bltcod[303] = -227;
    s_copy(bltnam + 10908, "KEPLER", (ftnlen)36, (ftnlen)6);
    bltcod[304] = -228;
    s_copy(bltnam + 10944, "GLL PROBE", (ftnlen)36, (ftnlen)9);
    bltcod[305] = -228;
    s_copy(bltnam + 10980, "GALILEO PROBE", (ftnlen)36, (ftnlen)13);
    bltcod[306] = -234;
    s_copy(bltnam + 11016, "STEREO AHEAD", (ftnlen)36, (ftnlen)12);
    bltcod[307] = -235;
    s_copy(bltnam + 11052, "STEREO BEHIND", (ftnlen)36, (ftnlen)13);
    bltcod[308] = -236;
    s_copy(bltnam + 11088, "MESSENGER", (ftnlen)36, (ftnlen)9);
    bltcod[309] = -238;
    s_copy(bltnam + 11124, "SMART1", (ftnlen)36, (ftnlen)6);
    bltcod[310] = -238;
    s_copy(bltnam + 11160, "SM1", (ftnlen)36, (ftnlen)3);
    bltcod[311] = -238;
    s_copy(bltnam + 11196, "S1", (ftnlen)36, (ftnlen)2);
    bltcod[312] = -238;
    s_copy(bltnam + 11232, "SMART-1", (ftnlen)36, (ftnlen)7);
    bltcod[313] = -248;
    s_copy(bltnam + 11268, "VEX", (ftnlen)36, (ftnlen)3);
    bltcod[314] = -248;
    s_copy(bltnam + 11304, "VENUS EXPRESS", (ftnlen)36, (ftnlen)13);
    bltcod[315] = -253;
    s_copy(bltnam + 11340, "OPPORTUNITY", (ftnlen)36, (ftnlen)11);
    bltcod[316] = -253;
    s_copy(bltnam + 11376, "MER-1", (ftnlen)36, (ftnlen)5);
    bltcod[317] = -254;
    s_copy(bltnam + 11412, "SPIRIT", (ftnlen)36, (ftnlen)6);
    bltcod[318] = -254;
    s_copy(bltnam + 11448, "MER-2", (ftnlen)36, (ftnlen)5);
    bltcod[319] = -486;
    s_copy(bltnam + 11484, "HERSCHEL", (ftnlen)36, (ftnlen)8);
    bltcod[320] = -489;
    s_copy(bltnam + 11520, "PLANCK", (ftnlen)36, (ftnlen)6);
    bltcod[321] = -500;
    s_copy(bltnam + 11556, "RSAT", (ftnlen)36, (ftnlen)4);
    bltcod[322] = -500;
    s_copy(bltnam + 11592, "SELENE Relay Satellite", (ftnlen)36, (ftnlen)22);
    bltcod[323] = -500;
    s_copy(bltnam + 11628, "SELENE Rstar", (ftnlen)36, (ftnlen)12);
    bltcod[324] = -500;
    s_copy(bltnam + 11664, "Rstar", (ftnlen)36, (ftnlen)5);
    bltcod[325] = -502;
    s_copy(bltnam + 11700, "VSAT", (ftnlen)36, (ftnlen)4);
    bltcod[326] = -502;
    s_copy(bltnam + 11736, "SELENE VLBI Radio Satellite", (ftnlen)36, (ftnlen)
	    27);
    bltcod[327] = -502;
    s_copy(bltnam + 11772, "SELENE VRAD Satellite", (ftnlen)36, (ftnlen)21);
    bltcod[328] = -502;
    s_copy(bltnam + 11808, "SELENE Vstar", (ftnlen)36, (ftnlen)12);
    bltcod[329] = -502;
    s_copy(bltnam + 11844, "Vstar", (ftnlen)36, (ftnlen)5);
    bltcod[330] = -550;
    s_copy(bltnam + 11880, "MARS-96", (ftnlen)36, (ftnlen)7);
    bltcod[331] = -550;
    s_copy(bltnam + 11916, "M96", (ftnlen)36, (ftnlen)3);
    bltcod[332] = -550;
    s_copy(bltnam + 11952, "MARS 96", (ftnlen)36, (ftnlen)7);
    bltcod[333] = -550;
    s_copy(bltnam + 11988, "MARS96", (ftnlen)36, (ftnlen)6);
    bltcod[334] = 50000001;
    s_copy(bltnam + 12024, "SHOEMAKER-LEVY 9-W", (ftnlen)36, (ftnlen)18);
    bltcod[335] = 50000002;
    s_copy(bltnam + 12060, "SHOEMAKER-LEVY 9-V", (ftnlen)36, (ftnlen)18);
    bltcod[336] = 50000003;
    s_copy(bltnam + 12096, "SHOEMAKER-LEVY 9-U", (ftnlen)36, (ftnlen)18);
    bltcod[337] = 50000004;
    s_copy(bltnam + 12132, "SHOEMAKER-LEVY 9-T", (ftnlen)36, (ftnlen)18);
    bltcod[338] = 50000005;
    s_copy(bltnam + 12168, "SHOEMAKER-LEVY 9-S", (ftnlen)36, (ftnlen)18);
    bltcod[339] = 50000006;
    s_copy(bltnam + 12204, "SHOEMAKER-LEVY 9-R", (ftnlen)36, (ftnlen)18);
    bltcod[340] = 50000007;
    s_copy(bltnam + 12240, "SHOEMAKER-LEVY 9-Q", (ftnlen)36, (ftnlen)18);
    bltcod[341] = 50000008;
    s_copy(bltnam + 12276, "SHOEMAKER-LEVY 9-P", (ftnlen)36, (ftnlen)18);
    bltcod[342] = 50000009;
    s_copy(bltnam + 12312, "SHOEMAKER-LEVY 9-N", (ftnlen)36, (ftnlen)18);
    bltcod[343] = 50000010;
    s_copy(bltnam + 12348, "SHOEMAKER-LEVY 9-M", (ftnlen)36, (ftnlen)18);
    bltcod[344] = 50000011;
    s_copy(bltnam + 12384, "SHOEMAKER-LEVY 9-L", (ftnlen)36, (ftnlen)18);
    bltcod[345] = 50000012;
    s_copy(bltnam + 12420, "SHOEMAKER-LEVY 9-K", (ftnlen)36, (ftnlen)18);
    bltcod[346] = 50000013;
    s_copy(bltnam + 12456, "SHOEMAKER-LEVY 9-J", (ftnlen)36, (ftnlen)18);
    bltcod[347] = 50000014;
    s_copy(bltnam + 12492, "SHOEMAKER-LEVY 9-H", (ftnlen)36, (ftnlen)18);
    bltcod[348] = 50000015;
    s_copy(bltnam + 12528, "SHOEMAKER-LEVY 9-G", (ftnlen)36, (ftnlen)18);
    bltcod[349] = 50000016;
    s_copy(bltnam + 12564, "SHOEMAKER-LEVY 9-F", (ftnlen)36, (ftnlen)18);
    bltcod[350] = 50000017;
    s_copy(bltnam + 12600, "SHOEMAKER-LEVY 9-E", (ftnlen)36, (ftnlen)18);
    bltcod[351] = 50000018;
    s_copy(bltnam + 12636, "SHOEMAKER-LEVY 9-D", (ftnlen)36, (ftnlen)18);
    bltcod[352] = 50000019;
    s_copy(bltnam + 12672, "SHOEMAKER-LEVY 9-C", (ftnlen)36, (ftnlen)18);
    bltcod[353] = 50000020;
    s_copy(bltnam + 12708, "SHOEMAKER-LEVY 9-B", (ftnlen)36, (ftnlen)18);
    bltcod[354] = 50000021;
    s_copy(bltnam + 12744, "SHOEMAKER-LEVY 9-A", (ftnlen)36, (ftnlen)18);
    bltcod[355] = 50000022;
    s_copy(bltnam + 12780, "SHOEMAKER-LEVY 9-Q1", (ftnlen)36, (ftnlen)19);
    bltcod[356] = 50000023;
    s_copy(bltnam + 12816, "SHOEMAKER-LEVY 9-P2", (ftnlen)36, (ftnlen)19);
    bltcod[357] = 1000001;
    s_copy(bltnam + 12852, "AREND", (ftnlen)36, (ftnlen)5);
    bltcod[358] = 1000002;
    s_copy(bltnam + 12888, "AREND-RIGAUX", (ftnlen)36, (ftnlen)12);
    bltcod[359] = 1000003;
    s_copy(bltnam + 12924, "ASHBROOK-JACKSON", (ftnlen)36, (ftnlen)16);
    bltcod[360] = 1000004;
    s_copy(bltnam + 12960, "BOETHIN", (ftnlen)36, (ftnlen)7);
    bltcod[361] = 1000005;
    s_copy(bltnam + 12996, "BORRELLY", (ftnlen)36, (ftnlen)8);
    bltcod[362] = 1000006;
    s_copy(bltnam + 13032, "BOWELL-SKIFF", (ftnlen)36, (ftnlen)12);
    bltcod[363] = 1000007;
    s_copy(bltnam + 13068, "BRADFIELD", (ftnlen)36, (ftnlen)9);
    bltcod[364] = 1000008;
    s_copy(bltnam + 13104, "BROOKS 2", (ftnlen)36, (ftnlen)8);
    bltcod[365] = 1000009;
    s_copy(bltnam + 13140, "BRORSEN-METCALF", (ftnlen)36, (ftnlen)15);
    bltcod[366] = 1000010;
    s_copy(bltnam + 13176, "BUS", (ftnlen)36, (ftnlen)3);
    bltcod[367] = 1000011;
    s_copy(bltnam + 13212, "CHERNYKH", (ftnlen)36, (ftnlen)8);
    bltcod[368] = 1000012;
    s_copy(bltnam + 13248, "67P/CHURYUMOV-GERASIMENKO (1969 R1)", (ftnlen)36, 
	    (ftnlen)35);
    bltcod[369] = 1000012;
    s_copy(bltnam + 13284, "CHURYUMOV-GERASIMENKO", (ftnlen)36, (ftnlen)21);
    bltcod[370] = 1000013;
    s_copy(bltnam + 13320, "CIFFREO", (ftnlen)36, (ftnlen)7);
    bltcod[371] = 1000014;
    s_copy(bltnam + 13356, "CLARK", (ftnlen)36, (ftnlen)5);
    bltcod[372] = 1000015;
    s_copy(bltnam + 13392, "COMAS SOLA", (ftnlen)36, (ftnlen)10);
    bltcod[373] = 1000016;
    s_copy(bltnam + 13428, "CROMMELIN", (ftnlen)36, (ftnlen)9);
    bltcod[374] = 1000017;
    s_copy(bltnam + 13464, "D'ARREST", (ftnlen)36, (ftnlen)8);
    bltcod[375] = 1000018;
    s_copy(bltnam + 13500, "DANIEL", (ftnlen)36, (ftnlen)6);
    bltcod[376] = 1000019;
    s_copy(bltnam + 13536, "DE VICO-SWIFT", (ftnlen)36, (ftnlen)13);
    bltcod[377] = 1000020;
    s_copy(bltnam + 13572, "DENNING-FUJIKAWA", (ftnlen)36, (ftnlen)16);
    bltcod[378] = 1000021;
    s_copy(bltnam + 13608, "DU TOIT 1", (ftnlen)36, (ftnlen)9);
    bltcod[379] = 1000022;
    s_copy(bltnam + 13644, "DU TOIT-HARTLEY", (ftnlen)36, (ftnlen)15);
    bltcod[380] = 1000023;
    s_copy(bltnam + 13680, "DUTOIT-NEUJMIN-DELPORTE", (ftnlen)36, (ftnlen)23);
    bltcod[381] = 1000024;
    s_copy(bltnam + 13716, "DUBIAGO", (ftnlen)36, (ftnlen)7);
    bltcod[382] = 1000025;
    s_copy(bltnam + 13752, "ENCKE", (ftnlen)36, (ftnlen)5);
    bltcod[383] = 1000026;
    s_copy(bltnam + 13788, "FAYE", (ftnlen)36, (ftnlen)4);
    bltcod[384] = 1000027;
    s_copy(bltnam + 13824, "FINLAY", (ftnlen)36, (ftnlen)6);
    bltcod[385] = 1000028;
    s_copy(bltnam + 13860, "FORBES", (ftnlen)36, (ftnlen)6);
    bltcod[386] = 1000029;
    s_copy(bltnam + 13896, "GEHRELS 1", (ftnlen)36, (ftnlen)9);
    bltcod[387] = 1000030;
    s_copy(bltnam + 13932, "GEHRELS 2", (ftnlen)36, (ftnlen)9);
    bltcod[388] = 1000031;
    s_copy(bltnam + 13968, "GEHRELS 3", (ftnlen)36, (ftnlen)9);
    bltcod[389] = 1000032;
    s_copy(bltnam + 14004, "GIACOBINI-ZINNER", (ftnlen)36, (ftnlen)16);
    bltcod[390] = 1000033;
    s_copy(bltnam + 14040, "GICLAS", (ftnlen)36, (ftnlen)6);
    bltcod[391] = 1000034;
    s_copy(bltnam + 14076, "GRIGG-SKJELLERUP", (ftnlen)36, (ftnlen)16);
    bltcod[392] = 1000035;
    s_copy(bltnam + 14112, "GUNN", (ftnlen)36, (ftnlen)4);
    bltcod[393] = 1000036;
    s_copy(bltnam + 14148, "HALLEY", (ftnlen)36, (ftnlen)6);
    bltcod[394] = 1000037;
    s_copy(bltnam + 14184, "HANEDA-CAMPOS", (ftnlen)36, (ftnlen)13);
    bltcod[395] = 1000038;
    s_copy(bltnam + 14220, "HARRINGTON", (ftnlen)36, (ftnlen)10);
    bltcod[396] = 1000039;
    s_copy(bltnam + 14256, "HARRINGTON-ABELL", (ftnlen)36, (ftnlen)16);
    bltcod[397] = 1000040;
    s_copy(bltnam + 14292, "HARTLEY 1", (ftnlen)36, (ftnlen)9);
    bltcod[398] = 1000041;
    s_copy(bltnam + 14328, "HARTLEY 2", (ftnlen)36, (ftnlen)9);
    bltcod[399] = 1000042;
    s_copy(bltnam + 14364, "HARTLEY-IRAS", (ftnlen)36, (ftnlen)12);
    bltcod[400] = 1000043;
    s_copy(bltnam + 14400, "HERSCHEL-RIGOLLET", (ftnlen)36, (ftnlen)17);
    bltcod[401] = 1000044;
    s_copy(bltnam + 14436, "HOLMES", (ftnlen)36, (ftnlen)6);
    bltcod[402] = 1000045;
    s_copy(bltnam + 14472, "HONDA-MRKOS-PAJDUSAKOVA", (ftnlen)36, (ftnlen)23);
    bltcod[403] = 1000046;
    s_copy(bltnam + 14508, "HOWELL", (ftnlen)36, (ftnlen)6);
    bltcod[404] = 1000047;
    s_copy(bltnam + 14544, "IRAS", (ftnlen)36, (ftnlen)4);
    bltcod[405] = 1000048;
    s_copy(bltnam + 14580, "JACKSON-NEUJMIN", (ftnlen)36, (ftnlen)15);
    bltcod[406] = 1000049;
    s_copy(bltnam + 14616, "JOHNSON", (ftnlen)36, (ftnlen)7);
    bltcod[407] = 1000050;
    s_copy(bltnam + 14652, "KEARNS-KWEE", (ftnlen)36, (ftnlen)11);
    bltcod[408] = 1000051;
    s_copy(bltnam + 14688, "KLEMOLA", (ftnlen)36, (ftnlen)7);
    bltcod[409] = 1000052;
    s_copy(bltnam + 14724, "KOHOUTEK", (ftnlen)36, (ftnlen)8);
    bltcod[410] = 1000053;
    s_copy(bltnam + 14760, "KOJIMA", (ftnlen)36, (ftnlen)6);
    bltcod[411] = 1000054;
    s_copy(bltnam + 14796, "KOPFF", (ftnlen)36, (ftnlen)5);
    bltcod[412] = 1000055;
    s_copy(bltnam + 14832, "KOWAL 1", (ftnlen)36, (ftnlen)7);
    bltcod[413] = 1000056;
    s_copy(bltnam + 14868, "KOWAL 2", (ftnlen)36, (ftnlen)7);
    bltcod[414] = 1000057;
    s_copy(bltnam + 14904, "KOWAL-MRKOS", (ftnlen)36, (ftnlen)11);
    bltcod[415] = 1000058;
    s_copy(bltnam + 14940, "KOWAL-VAVROVA", (ftnlen)36, (ftnlen)13);
    bltcod[416] = 1000059;
    s_copy(bltnam + 14976, "LONGMORE", (ftnlen)36, (ftnlen)8);
    bltcod[417] = 1000060;
    s_copy(bltnam + 15012, "LOVAS 1", (ftnlen)36, (ftnlen)7);
    bltcod[418] = 1000061;
    s_copy(bltnam + 15048, "MACHHOLZ", (ftnlen)36, (ftnlen)8);
    bltcod[419] = 1000062;
    s_copy(bltnam + 15084, "MAURY", (ftnlen)36, (ftnlen)5);
    bltcod[420] = 1000063;
    s_copy(bltnam + 15120, "NEUJMIN 1", (ftnlen)36, (ftnlen)9);
    bltcod[421] = 1000064;
    s_copy(bltnam + 15156, "NEUJMIN 2", (ftnlen)36, (ftnlen)9);
    bltcod[422] = 1000065;
    s_copy(bltnam + 15192, "NEUJMIN 3", (ftnlen)36, (ftnlen)9);
    bltcod[423] = 1000066;
    s_copy(bltnam + 15228, "OLBERS", (ftnlen)36, (ftnlen)6);
    bltcod[424] = 1000067;
    s_copy(bltnam + 15264, "PETERS-HARTLEY", (ftnlen)36, (ftnlen)14);
    bltcod[425] = 1000068;
    s_copy(bltnam + 15300, "PONS-BROOKS", (ftnlen)36, (ftnlen)11);
    bltcod[426] = 1000069;
    s_copy(bltnam + 15336, "PONS-WINNECKE", (ftnlen)36, (ftnlen)13);
    bltcod[427] = 1000070;
    s_copy(bltnam + 15372, "REINMUTH 1", (ftnlen)36, (ftnlen)10);
    bltcod[428] = 1000071;
    s_copy(bltnam + 15408, "REINMUTH 2", (ftnlen)36, (ftnlen)10);
    bltcod[429] = 1000072;
    s_copy(bltnam + 15444, "RUSSELL 1", (ftnlen)36, (ftnlen)9);
    bltcod[430] = 1000073;
    s_copy(bltnam + 15480, "RUSSELL 2", (ftnlen)36, (ftnlen)9);
    bltcod[431] = 1000074;
    s_copy(bltnam + 15516, "RUSSELL 3", (ftnlen)36, (ftnlen)9);
    bltcod[432] = 1000075;
    s_copy(bltnam + 15552, "RUSSELL 4", (ftnlen)36, (ftnlen)9);
    bltcod[433] = 1000076;
    s_copy(bltnam + 15588, "SANGUIN", (ftnlen)36, (ftnlen)7);
    bltcod[434] = 1000077;
    s_copy(bltnam + 15624, "SCHAUMASSE", (ftnlen)36, (ftnlen)10);
    bltcod[435] = 1000078;
    s_copy(bltnam + 15660, "SCHUSTER", (ftnlen)36, (ftnlen)8);
    bltcod[436] = 1000079;
    s_copy(bltnam + 15696, "SCHWASSMANN-WACHMANN 1", (ftnlen)36, (ftnlen)22);
    bltcod[437] = 1000080;
    s_copy(bltnam + 15732, "SCHWASSMANN-WACHMANN 2", (ftnlen)36, (ftnlen)22);
    bltcod[438] = 1000081;
    s_copy(bltnam + 15768, "SCHWASSMANN-WACHMANN 3", (ftnlen)36, (ftnlen)22);
    bltcod[439] = 1000082;
    s_copy(bltnam + 15804, "SHAJN-SCHALDACH", (ftnlen)36, (ftnlen)15);
    bltcod[440] = 1000083;
    s_copy(bltnam + 15840, "SHOEMAKER 1", (ftnlen)36, (ftnlen)11);
    bltcod[441] = 1000084;
    s_copy(bltnam + 15876, "SHOEMAKER 2", (ftnlen)36, (ftnlen)11);
    bltcod[442] = 1000085;
    s_copy(bltnam + 15912, "SHOEMAKER 3", (ftnlen)36, (ftnlen)11);
    bltcod[443] = 1000086;
    s_copy(bltnam + 15948, "SINGER-BREWSTER", (ftnlen)36, (ftnlen)15);
    bltcod[444] = 1000087;
    s_copy(bltnam + 15984, "SLAUGHTER-BURNHAM", (ftnlen)36, (ftnlen)17);
    bltcod[445] = 1000088;
    s_copy(bltnam + 16020, "SMIRNOVA-CHERNYKH", (ftnlen)36, (ftnlen)17);
    bltcod[446] = 1000089;
    s_copy(bltnam + 16056, "STEPHAN-OTERMA", (ftnlen)36, (ftnlen)14);
    bltcod[447] = 1000090;
    s_copy(bltnam + 16092, "SWIFT-GEHRELS", (ftnlen)36, (ftnlen)13);
    bltcod[448] = 1000091;
    s_copy(bltnam + 16128, "TAKAMIZAWA", (ftnlen)36, (ftnlen)10);
    bltcod[449] = 1000092;
    s_copy(bltnam + 16164, "TAYLOR", (ftnlen)36, (ftnlen)6);
    bltcod[450] = 1000093;
    s_copy(bltnam + 16200, "TEMPEL 1", (ftnlen)36, (ftnlen)8);
    bltcod[451] = 1000094;
    s_copy(bltnam + 16236, "TEMPEL 2", (ftnlen)36, (ftnlen)8);
    bltcod[452] = 1000095;
    s_copy(bltnam + 16272, "TEMPEL-TUTTLE", (ftnlen)36, (ftnlen)13);
    bltcod[453] = 1000096;
    s_copy(bltnam + 16308, "TRITTON", (ftnlen)36, (ftnlen)7);
    bltcod[454] = 1000097;
    s_copy(bltnam + 16344, "TSUCHINSHAN 1", (ftnlen)36, (ftnlen)13);
    bltcod[455] = 1000098;
    s_copy(bltnam + 16380, "TSUCHINSHAN 2", (ftnlen)36, (ftnlen)13);
    bltcod[456] = 1000099;
    s_copy(bltnam + 16416, "TUTTLE", (ftnlen)36, (ftnlen)6);
    bltcod[457] = 1000100;
    s_copy(bltnam + 16452, "TUTTLE-GIACOBINI-KRESAK", (ftnlen)36, (ftnlen)23);
    bltcod[458] = 1000101;
    s_copy(bltnam + 16488, "VAISALA 1", (ftnlen)36, (ftnlen)9);
    bltcod[459] = 1000102;
    s_copy(bltnam + 16524, "VAN BIESBROECK", (ftnlen)36, (ftnlen)14);
    bltcod[460] = 1000103;
    s_copy(bltnam + 16560, "VAN HOUTEN", (ftnlen)36, (ftnlen)10);
    bltcod[461] = 1000104;
    s_copy(bltnam + 16596, "WEST-KOHOUTEK-IKEMURA", (ftnlen)36, (ftnlen)21);
    bltcod[462] = 1000105;
    s_copy(bltnam + 16632, "WHIPPLE", (ftnlen)36, (ftnlen)7);
    bltcod[463] = 1000106;
    s_copy(bltnam + 16668, "WILD 1", (ftnlen)36, (ftnlen)6);
    bltcod[464] = 1000107;
    s_copy(bltnam + 16704, "WILD 2", (ftnlen)36, (ftnlen)6);
    bltcod[465] = 1000108;
    s_copy(bltnam + 16740, "WILD 3", (ftnlen)36, (ftnlen)6);
    bltcod[466] = 1000109;
    s_copy(bltnam + 16776, "WIRTANEN", (ftnlen)36, (ftnlen)8);
    bltcod[467] = 1000110;
    s_copy(bltnam + 16812, "WOLF", (ftnlen)36, (ftnlen)4);
    bltcod[468] = 1000111;
    s_copy(bltnam + 16848, "WOLF-HARRINGTON", (ftnlen)36, (ftnlen)15);
    bltcod[469] = 1000112;
    s_copy(bltnam + 16884, "LOVAS 2", (ftnlen)36, (ftnlen)7);
    bltcod[470] = 1000113;
    s_copy(bltnam + 16920, "URATA-NIIJIMA", (ftnlen)36, (ftnlen)13);
    bltcod[471] = 1000114;
    s_copy(bltnam + 16956, "WISEMAN-SKIFF", (ftnlen)36, (ftnlen)13);
    bltcod[472] = 1000115;
    s_copy(bltnam + 16992, "HELIN", (ftnlen)36, (ftnlen)5);
    bltcod[473] = 1000116;
    s_copy(bltnam + 17028, "MUELLER", (ftnlen)36, (ftnlen)7);
    bltcod[474] = 1000117;
    s_copy(bltnam + 17064, "SHOEMAKER-HOLT 1", (ftnlen)36, (ftnlen)16);
    bltcod[475] = 1000118;
    s_copy(bltnam + 17100, "HELIN-ROMAN-CROCKETT", (ftnlen)36, (ftnlen)20);
    bltcod[476] = 1000119;
    s_copy(bltnam + 17136, "HARTLEY 3", (ftnlen)36, (ftnlen)9);
    bltcod[477] = 1000120;
    s_copy(bltnam + 17172, "PARKER-HARTLEY", (ftnlen)36, (ftnlen)14);
    bltcod[478] = 1000121;
    s_copy(bltnam + 17208, "HELIN-ROMAN-ALU 1", (ftnlen)36, (ftnlen)17);
    bltcod[479] = 1000122;
    s_copy(bltnam + 17244, "WILD 4", (ftnlen)36, (ftnlen)6);
    bltcod[480] = 1000123;
    s_copy(bltnam + 17280, "MUELLER 2", (ftnlen)36, (ftnlen)9);
    bltcod[481] = 1000124;
    s_copy(bltnam + 17316, "MUELLER 3", (ftnlen)36, (ftnlen)9);
    bltcod[482] = 1000125;
    s_copy(bltnam + 17352, "SHOEMAKER-LEVY 1", (ftnlen)36, (ftnlen)16);
    bltcod[483] = 1000126;
    s_copy(bltnam + 17388, "SHOEMAKER-LEVY 2", (ftnlen)36, (ftnlen)16);
    bltcod[484] = 1000127;
    s_copy(bltnam + 17424, "HOLT-OLMSTEAD", (ftnlen)36, (ftnlen)13);
    bltcod[485] = 1000128;
    s_copy(bltnam + 17460, "METCALF-BREWINGTON", (ftnlen)36, (ftnlen)18);
    bltcod[486] = 1000129;
    s_copy(bltnam + 17496, "LEVY", (ftnlen)36, (ftnlen)4);
    bltcod[487] = 1000130;
    s_copy(bltnam + 17532, "SHOEMAKER-LEVY 9", (ftnlen)36, (ftnlen)16);
    bltcod[488] = 1000131;
    s_copy(bltnam + 17568, "HYAKUTAKE", (ftnlen)36, (ftnlen)9);
    bltcod[489] = 1000132;
    s_copy(bltnam + 17604, "HALE-BOPP", (ftnlen)36, (ftnlen)9);
    bltcod[490] = 9511010;
    s_copy(bltnam + 17640, "GASPRA", (ftnlen)36, (ftnlen)6);
    bltcod[491] = 2431010;
    s_copy(bltnam + 17676, "IDA", (ftnlen)36, (ftnlen)3);
    bltcod[492] = 2431011;
    s_copy(bltnam + 17712, "DACTYL", (ftnlen)36, (ftnlen)6);
    bltcod[493] = 2000001;
    s_copy(bltnam + 17748, "CERES", (ftnlen)36, (ftnlen)5);
    bltcod[494] = 2000004;
    s_copy(bltnam + 17784, "VESTA", (ftnlen)36, (ftnlen)5);
    bltcod[495] = 2000216;
    s_copy(bltnam + 17820, "KLEOPATRA", (ftnlen)36, (ftnlen)9);
    bltcod[496] = 2000433;
    s_copy(bltnam + 17856, "EROS", (ftnlen)36, (ftnlen)4);
    bltcod[497] = 2000253;
    s_copy(bltnam + 17892, "MATHILDE", (ftnlen)36, (ftnlen)8);
    bltcod[498] = 2009969;
    s_copy(bltnam + 17928, "1992KD", (ftnlen)36, (ftnlen)6);
    bltcod[499] = 2009969;
    s_copy(bltnam + 17964, "BRAILLE", (ftnlen)36, (ftnlen)7);
    bltcod[500] = 2004015;
    s_copy(bltnam + 18000, "WILSON-HARRINGTON", (ftnlen)36, (ftnlen)17);
    bltcod[501] = 2025143;
    s_copy(bltnam + 18036, "ITOKAWA", (ftnlen)36, (ftnlen)7);
    bltcod[502] = 398989;
    s_copy(bltnam + 18072, "NOTO", (ftnlen)36, (ftnlen)4);
    bltcod[503] = 398990;
    s_copy(bltnam + 18108, "NEW NORCIA", (ftnlen)36, (ftnlen)10);
    bltcod[504] = 399001;
    s_copy(bltnam + 18144, "GOLDSTONE", (ftnlen)36, (ftnlen)9);
    bltcod[505] = 399002;
    s_copy(bltnam + 18180, "CANBERRA", (ftnlen)36, (ftnlen)8);
    bltcod[506] = 399003;
    s_copy(bltnam + 18216, "MADRID", (ftnlen)36, (ftnlen)6);
    bltcod[507] = 399004;
    s_copy(bltnam + 18252, "USUDA", (ftnlen)36, (ftnlen)5);
    bltcod[508] = 399005;
    s_copy(bltnam + 18288, "DSS-05", (ftnlen)36, (ftnlen)6);
    bltcod[509] = 399005;
    s_copy(bltnam + 18324, "PARKES", (ftnlen)36, (ftnlen)6);
    bltcod[510] = 399012;
    s_copy(bltnam + 18360, "DSS-12", (ftnlen)36, (ftnlen)6);
    bltcod[511] = 399013;
    s_copy(bltnam + 18396, "DSS-13", (ftnlen)36, (ftnlen)6);
    bltcod[512] = 399014;
    s_copy(bltnam + 18432, "DSS-14", (ftnlen)36, (ftnlen)6);
    bltcod[513] = 399015;
    s_copy(bltnam + 18468, "DSS-15", (ftnlen)36, (ftnlen)6);
    bltcod[514] = 399016;
    s_copy(bltnam + 18504, "DSS-16", (ftnlen)36, (ftnlen)6);
    bltcod[515] = 399017;
    s_copy(bltnam + 18540, "DSS-17", (ftnlen)36, (ftnlen)6);
    bltcod[516] = 399023;
    s_copy(bltnam + 18576, "DSS-23", (ftnlen)36, (ftnlen)6);
    bltcod[517] = 399024;
    s_copy(bltnam + 18612, "DSS-24", (ftnlen)36, (ftnlen)6);
    bltcod[518] = 399025;
    s_copy(bltnam + 18648, "DSS-25", (ftnlen)36, (ftnlen)6);
    bltcod[519] = 399026;
    s_copy(bltnam + 18684, "DSS-26", (ftnlen)36, (ftnlen)6);
    bltcod[520] = 399027;
    s_copy(bltnam + 18720, "DSS-27", (ftnlen)36, (ftnlen)6);
    bltcod[521] = 399028;
    s_copy(bltnam + 18756, "DSS-28", (ftnlen)36, (ftnlen)6);
    bltcod[522] = 399033;
    s_copy(bltnam + 18792, "DSS-33", (ftnlen)36, (ftnlen)6);
    bltcod[523] = 399034;
    s_copy(bltnam + 18828, "DSS-34", (ftnlen)36, (ftnlen)6);
    bltcod[524] = 399042;
    s_copy(bltnam + 18864, "DSS-42", (ftnlen)36, (ftnlen)6);
    bltcod[525] = 399043;
    s_copy(bltnam + 18900, "DSS-43", (ftnlen)36, (ftnlen)6);
    bltcod[526] = 399045;
    s_copy(bltnam + 18936, "DSS-45", (ftnlen)36, (ftnlen)6);
    bltcod[527] = 399046;
    s_copy(bltnam + 18972, "DSS-46", (ftnlen)36, (ftnlen)6);
    bltcod[528] = 399049;
    s_copy(bltnam + 19008, "DSS-49", (ftnlen)36, (ftnlen)6);
    bltcod[529] = 399053;
    s_copy(bltnam + 19044, "DSS-53", (ftnlen)36, (ftnlen)6);
    bltcod[530] = 399054;
    s_copy(bltnam + 19080, "DSS-54", (ftnlen)36, (ftnlen)6);
    bltcod[531] = 399055;
    s_copy(bltnam + 19116, "DSS-55", (ftnlen)36, (ftnlen)6);
    bltcod[532] = 399061;
    s_copy(bltnam + 19152, "DSS-61", (ftnlen)36, (ftnlen)6);
    bltcod[533] = 399063;
    s_copy(bltnam + 19188, "DSS-63", (ftnlen)36, (ftnlen)6);
    bltcod[534] = 399064;
    s_copy(bltnam + 19224, "DSS-64", (ftnlen)36, (ftnlen)6);
    bltcod[535] = 399065;
    s_copy(bltnam + 19260, "DSS-65", (ftnlen)36, (ftnlen)6);
    bltcod[536] = 399066;
    s_copy(bltnam + 19296, "DSS-66", (ftnlen)36, (ftnlen)6);
    return 0;
} /* zzidmap_ */

