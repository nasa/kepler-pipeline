/* tstst.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* $Procedure      TSTST ( Test States ) */
/* Subroutine */ int tstst_0_(int n__, integer *body, doublereal *et, char *
	segid, integer *frame, doublereal *state, integer *center, doublereal 
	*gm, ftnlen segid_len)
{
    /* Initialized data */

    static logical first = TRUE_;

    /* System generated locals */
    integer i__1;
    doublereal d__1;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    static doublereal long__, incnd[6], epoch, elems[8];
    extern /* Subroutine */ int prop2b_(doublereal *, doublereal *, 
	    doublereal *, doublereal *);
    static doublereal dt;
    extern doublereal pi_(void);
    static integer bodcod[46];
    extern /* Subroutine */ int latrec_(doublereal *, doublereal *, 
	    doublereal *, doublereal *), conics_(doublereal *, doublereal *, 
	    doublereal *), namfrm_(char *, integer *, ftnlen);
    static doublereal rad, lat;
    extern doublereal dpr_(void);

/* $ Abstract */

/*     This routine provides artificial state data for a large number */
/*     of solar system objects.  This file is intended for use in */
/*     testing SPK calculations. */

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

/*      TSETING */

/* $ Declarations */
/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  -------------------------------------------------- */
/*     BODY       I   Id code for the body of interest. */
/*     ET         I   Epoch of interest. */
/*     SEGID      O   Segment identifier stored in SPK files via TSTSPK. */
/*     FRAME      O   Id code for reference frame of the output state. */
/*     CENTER     O   Object that the state is relative to. */
/*     GM         O   Central mass if two body propagation is used */

/* $ Detailed_Input */

/*     BODY      is the id code of some object.  The id codes recognized */
/*               by this routine and the objects they represent are given */
/*               below. */

/*     ET        is the epoch at which a state is desired.  States */
/*               are available for all epochs. */

/* $ Detailed_Output */

/*     SEGID     is the segment identifier that will be stored in any */
/*               SPK file created by TSTSPK.  This is the name of the */
/*               body of interest. */

/*     FRAME     is the idcode of reference frame in which state */
/*               information is returned. */

/*     STATE     is the state of BODY in the reference frame given */
/*               by FRAME. */

/*     CENTER    is the object that STATE is relative to. */


/*     GM        is the MASS of center if states are determined by */
/*               two body propagation about CENTER.  Zero if */
/*               state is constant. */

/* $ Parameters */

/*     None. */

/* $ Files */

/*     None. */

/* $ Exceptions */

/*     1) If the requested body is not on the list of known objects */
/*        this routine will signal the error 'TEST(NOEPHEMERIS)' */

/* $ Particulars */

/*     This is a test routine that provides an SPK independent mechanism */
/*     for generating states of solar system objects.  This is also */
/*     the routine used by TSTSPK to create a test SPK file for use */
/*     in system testing. */

/*     This routine returns the data needed to construct various kinds */
/*     of SPK segments. */

/*     Essentially this routine provides the a file independent */
/*     capability to the information returned by SPKSFS and SPKPVN */
/*     in the SPK system. */

/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*       W.L. Taber      (JPL) */

/* $ Literature_References */

/*       None. */

/* $ Version */

/* -    SPICELIB Version 1.1.0, 20-FEB-2003 (LSE) */

/*        Turned all numbers into DP numbers by adding Dx. Changed */
/*        center for 'TRANQUILITY BASE' to 301. */

/* -    SPICELIB Version 1.0.0, 4-MAY-1995 (WLT) */


/* -& */
/* $ Index_Entries */

/*     SPK independent solar system test model. */

/* -& */

/*     Spicelib Functions. */


/*     Local Variables. */

    /* Parameter adjustments */
    if (state) {
	}

    /* Function Body */
    switch(n__) {
	case 1: goto L_tststc;
	}

    *gm = 0.;
    if (*body == 1) {
	*center = 10;
	*frame = 1;
	s_copy(segid, "MERCURY BARYCENTER", segid_len, (ftnlen)18);
	*gm = 132712439812.232;
	incnd[0] = 6207609.7897357;
	incnd[1] = -60298891.717493;
	incnd[2] = -32852628.5165522;
	incnd[3] = 38.745299986085;
	incnd[4] = 7.53210082426381;
	incnd[5] = .004182185953812643;
	epoch = -189345600.;
	dt = *et - epoch;
	prop2b_(gm, incnd, &dt, state);
    } else if (*body == 2) {
	*center = 10;
	*frame = 2;
	s_copy(segid, "VENUS BARYCENTER", segid_len, (ftnlen)16);
	*gm = 132712439812.232;
	incnd[0] = 1312825.17425851;
	incnd[1] = -99125997.5689186;
	incnd[2] = -44760147.8732995;
	incnd[3] = 34.7805759160042;
	incnd[4] = 1.06667067580094;
	incnd[5] = -1.71517793493851;
	epoch = -189345600.;
	dt = *et - epoch;
	prop2b_(gm, incnd, &dt, state);
    } else if (*body == 3) {
	*center = 10;
	*frame = 3;
	s_copy(segid, "EARTH BARYCENTER", segid_len, (ftnlen)16);
	*gm = 132712439812.232;
	incnd[0] = -24848019.402164;
	incnd[1] = 133025176.220672;
	incnd[2] = 57675709.08939;
	incnd[3] = -29.8465259739246;
	incnd[4] = -4.71231481326271;
	incnd[5] = -2.04279835682576;
	epoch = -189345600.;
	dt = *et - epoch;
	prop2b_(gm, incnd, &dt, state);
    } else if (*body == 4) {
	*center = 10;
	*frame = 4;
	s_copy(segid, "MARS BARYCENTER", segid_len, (ftnlen)15);
	*gm = 132712439812.232;
	incnd[0] = 28451451.7577781;
	incnd[1] = -193607199.534214;
	incnd[2] = -89632951.5594207;
	incnd[3] = 24.9574701756996;
	incnd[4] = 5.0346156092184;
	incnd[5] = 1.64262344268785;
	epoch = -189345600.;
	dt = *et - epoch;
	prop2b_(gm, incnd, &dt, state);
    } else if (*body == 5) {
	*center = 10;
	*frame = 5;
	s_copy(segid, "JUPITER BARYCENTER", segid_len, (ftnlen)18);
	*gm = 132712439812.232;
	incnd[0] = -704576067.694724;
	incnd[1] = -381531065.492479;
	incnd[2] = -146450554.954635;
	incnd[3] = 6.39243901369846;
	incnd[4] = -9.78250291412574;
	incnd[5] = -4.35258281505283;
	epoch = -189345600.;
	dt = *et - epoch;
	prop2b_(gm, incnd, &dt, state);
    } else if (*body == 6) {
	*center = 10;
	*frame = 6;
	s_copy(segid, "SATURN BARYCENTER", segid_len, (ftnlen)17);
	*gm = 132712439812.232;
	incnd[0] = 1273788376.1546;
	incnd[1] = -643544424.24411;
	incnd[2] = -321266985.888865;
	incnd[3] = 4.22310030788441;
	incnd[4] = 7.82646875968136;
	incnd[5] = 3.05408851781389;
	epoch = -189345600.;
	dt = *et - epoch;
	prop2b_(gm, incnd, &dt, state);
    } else if (*body == 7) {
	*center = 10;
	*frame = 7;
	s_copy(segid, "URANUS BARYCENTER", segid_len, (ftnlen)17);
	*gm = 132712439812.232;
	incnd[0] = 1077677273.8789;
	incnd[1] = -2496912503.08958;
	incnd[2] = -1109243386.02389;
	incnd[3] = 6.2879788913549;
	incnd[4] = 2.02629977465106;
	incnd[5] = .799052496371982;
	epoch = -189345600.;
	dt = *et - epoch;
	prop2b_(gm, incnd, &dt, state);
    } else if (*body == 8) {
	*center = 10;
	*frame = 8;
	s_copy(segid, "NEPTUNE BARYCENTER", segid_len, (ftnlen)18);
	*gm = 132712439812.232;
	incnd[0] = 1557167603.67853;
	incnd[1] = -3907790548.02631;
	incnd[2] = -1639997084.052;
	incnd[3] = 5.07463401994239;
	incnd[4] = 1.80430448197816;
	incnd[5] = .611157155988252;
	epoch = -189345600.;
	dt = *et - epoch;
	prop2b_(gm, incnd, &dt, state);
    } else if (*body == 9) {
	*center = 10;
	*frame = 9;
	s_copy(segid, "PLUTO BARYCENTER", segid_len, (ftnlen)16);
	*gm = 132712439812.232;
	incnd[0] = -2469292714.21367;
	incnd[1] = -3681472580.33229;
	incnd[2] = -414761412.770993;
	incnd[3] = 4.6660184508844;
	incnd[4] = -3.13082213350134;
	incnd[5] = -2.40190082431715;
	epoch = -189345600.;
	dt = *et - epoch;
	prop2b_(gm, incnd, &dt, state);
    } else if (*body == 301) {
	*center = 399;
	*frame = 11;
	s_copy(segid, "MOON", segid_len, (ftnlen)4);
	*gm = 398600.447703261;
	incnd[0] = -276834.343369683;
	incnd[1] = 244566.81570172;
	incnd[2] = 70213.2363667674;
	incnd[3] = -.68298447864965;
	incnd[4] = -.719654421362183;
	incnd[5] = -.334442098948741;
	epoch = -189345600.;
	dt = *et - epoch;
	prop2b_(gm, incnd, &dt, state);
    } else if (*body == 401) {
	*center = 499;
	*frame = 12;
	s_copy(segid, "PHOBOS", segid_len, (ftnlen)6);
	*gm = 42826.2865489937;
	incnd[0] = 5791.99461342131;
	incnd[1] = -4660.30566140624;
	incnd[2] = -5831.14238473872;
	incnd[3] = 1.37607578437703;
	incnd[4] = 1.6153209117764;
	incnd[5] = .0322007203899467;
	epoch = -189345600.;
	dt = *et - epoch;
	prop2b_(gm, incnd, &dt, state);
    } else if (*body == 402) {
	*center = 499;
	*frame = 13;
	s_copy(segid, "DEIMOS", segid_len, (ftnlen)6);
	*gm = 42826.2865489937;
	incnd[0] = 11967.6502996;
	incnd[1] = 1968.17389762766;
	incnd[2] = -20084.9533725419;
	incnd[3] = -1.15747991364628;
	incnd[4] = -.056523665463048;
	incnd[5] = -.695674823559072;
	epoch = -189345600.;
	dt = *et - epoch;
	prop2b_(gm, incnd, &dt, state);
    } else if (*body == 501) {
	*center = 599;
	*frame = 14;
	s_copy(segid, "IO", segid_len, (ftnlen)2);
	*gm = 126686531.827629;
	incnd[0] = -156343.978772058;
	incnd[1] = 355461.582129399;
	incnd[2] = 166607.587136994;
	incnd[3] = -16.0503792563007;
	incnd[4] = -5.73360628238377;
	incnd[5] = -2.99230255081418;
	epoch = -189345600.;
	dt = *et - epoch;
	prop2b_(gm, incnd, &dt, state);
    } else if (*body == 502) {
	*center = 599;
	*frame = 15;
	s_copy(segid, "EUROPA", segid_len, (ftnlen)6);
	*gm = 126686531.827629;
	incnd[0] = -665935.363781086;
	incnd[1] = 102197.012487387;
	incnd[2] = 32367.8703226054;
	incnd[3] = -2.25722400520517;
	incnd[4] = -12.1638661807118;
	incnd[5] = -5.82073291279444;
	epoch = -189345600.;
	dt = *et - epoch;
	prop2b_(gm, incnd, &dt, state);
    } else if (*body == 503) {
	*center = 599;
	*frame = 16;
	s_copy(segid, "GANYMEDE", segid_len, (ftnlen)8);
	*gm = 126686531.827629;
	incnd[0] = 445009.819719306;
	incnd[1] = 958239.206929093;
	incnd[2] = -181485.142558463;
	incnd[3] = -9.23698674982273;
	incnd[4] = 3.40288638916646;
	incnd[5] = -4.60022413967004;
	epoch = -189345600.;
	dt = *et - epoch;
	prop2b_(gm, incnd, &dt, state);
    } else if (*body == 504) {
	*center = 599;
	*frame = 17;
	s_copy(segid, "CALLISTO", segid_len, (ftnlen)8);
	*gm = 126686531.827629;
	incnd[0] = 1547991.4905258;
	incnd[1] = -1048659.29881788;
	incnd[2] = -14378.2106926829;
	incnd[3] = 4.61018643816157;
	incnd[4] = 6.84588572010446;
	incnd[5] = .286500136474338;
	epoch = -189345600.;
	dt = *et - epoch;
	prop2b_(gm, incnd, &dt, state);
    } else if (*body == 603) {
	*center = 699;
	*frame = 18;
	s_copy(segid, "TETHYS", segid_len, (ftnlen)6);
	*gm = 37931155.3789196;
	incnd[0] = 292490.649450078;
	incnd[1] = -5308.30689534882;
	incnd[2] = -33634.0118571163;
	incnd[3] = -.42479607325554;
	incnd[4] = 10.0579643101737;
	incnd[5] = -5.26247103964504;
	epoch = -189345600.;
	dt = *et - epoch;
	prop2b_(gm, incnd, &dt, state);
    } else if (*body == 604) {
	*center = 699;
	*frame = 19;
	s_copy(segid, "DIONE", segid_len, (ftnlen)5);
	*gm = 37931155.3789196;
	incnd[0] = 251050.720397599;
	incnd[1] = 278878.775217632;
	incnd[2] = -43154.4685975013;
	incnd[3] = -7.44063083238366;
	incnd[4] = 6.70899210529303;
	incnd[5] = .189011010218273;
	epoch = -189345600.;
	dt = *et - epoch;
	prop2b_(gm, incnd, &dt, state);
    } else if (*body == 605) {
	*center = 699;
	*frame = 20;
	s_copy(segid, "RHEA", segid_len, (ftnlen)4);
	*gm = 37931155.3789196;
	incnd[0] = -412045.348984376;
	incnd[1] = 329704.135818218;
	incnd[2] = 12131.8372350238;
	incnd[3] = -5.23810061755777;
	incnd[4] = -6.58388420161942;
	incnd[5] = .995089328747382;
	epoch = -189345600.;
	dt = *et - epoch;
	prop2b_(gm, incnd, &dt, state);
    } else if (*body == 606) {
	*center = 699;
	*frame = 2;
	s_copy(segid, "TITAN", segid_len, (ftnlen)5);
	*gm = 37931155.3789196;
	incnd[0] = 1116223.22368248;
	incnd[1] = -396622.004714643;
	incnd[2] = -77422.7928937469;
	incnd[3] = 1.90395167708842;
	incnd[4] = 5.38118918386284;
	incnd[5] = -.537090832149415;
	epoch = -189345600.;
	dt = *et - epoch;
	prop2b_(gm, incnd, &dt, state);
    } else if (*body == 607) {
	*center = 699;
	*frame = 3;
	s_copy(segid, "HYPERION", segid_len, (ftnlen)8);
	*gm = 37931155.3789196;
	incnd[0] = 1012186.14004221;
	incnd[1] = 981982.837615797;
	incnd[2] = -158943.65784032;
	incnd[3] = -3.9151626724989;
	incnd[4] = 3.53031359608563;
	incnd[5] = .191202803576989;
	epoch = -189345600.;
	dt = *et - epoch;
	prop2b_(gm, incnd, &dt, state);
    } else if (*body == 608) {
	*center = 699;
	*frame = 4;
	s_copy(segid, "IAPETUS", segid_len, (ftnlen)7);
	*gm = 37931155.3789196;
	incnd[0] = 3365669.21755382;
	incnd[1] = -340417.567250275;
	incnd[2] = -740618.039233572;
	incnd[3] = .418440545037304;
	incnd[4] = 3.29253312667935;
	incnd[5] = .502126937288676;
	epoch = -189345600.;
	dt = *et - epoch;
	prop2b_(gm, incnd, &dt, state);
    } else if (*body == 701) {
	*center = 799;
	*frame = 5;
	s_copy(segid, "ARIEL", segid_len, (ftnlen)5);
	*gm = 5788511.27856709;
	incnd[0] = -179058.782466409;
	incnd[1] = 26052.4008543776;
	incnd[2] = 59968.3113388014;
	incnd[3] = 1.43394935766916;
	incnd[4] = -1.73817676665214;
	incnd[5] = 5.03675749813222;
	epoch = -189345600.;
	dt = *et - epoch;
	prop2b_(gm, incnd, &dt, state);
    } else if (*body == 702) {
	*center = 799;
	*frame = 6;
	s_copy(segid, "UMBRIEL", segid_len, (ftnlen)7);
	*gm = 5788511.27856709;
	incnd[0] = -181894.849454923;
	incnd[1] = 90817.6994578275;
	incnd[2] = -170086.092798569;
	incnd[3] = -3.23724294238563;
	incnd[4] = -.168144857094752;
	incnd[5] = 3.38038687224653;
	epoch = -189345600.;
	dt = *et - epoch;
	prop2b_(gm, incnd, &dt, state);
    } else if (*body == 703) {
	*center = 799;
	*frame = 7;
	s_copy(segid, "TITANIA", segid_len, (ftnlen)7);
	*gm = 5788511.27856709;
	incnd[0] = -408091.863866807;
	incnd[1] = 56862.0566637421;
	incnd[2] = 146993.806998521;
	incnd[3] = 1.02245002389835;
	incnd[4] = -1.15183420243745;
	incnd[5] = 3.29200952278993;
	epoch = -189345600.;
	dt = *et - epoch;
	prop2b_(gm, incnd, &dt, state);
    } else if (*body == 704) {
	*center = 799;
	*frame = 8;
	s_copy(segid, "OBERON", segid_len, (ftnlen)6);
	*gm = 5788511.27856709;
	incnd[0] = -197133.527861026;
	incnd[1] = -101978.461776863;
	incnd[2] = 539503.290982823;
	incnd[3] = 2.88316088766759;
	incnd[4] = -.922225470067102;
	incnd[5] = .87934240195532;
	epoch = -189345600.;
	dt = *et - epoch;
	prop2b_(gm, incnd, &dt, state);
    } else if (*body == 705) {
	*center = 799;
	*frame = 9;
	s_copy(segid, "MIRANDA", segid_len, (ftnlen)7);
	*gm = 5788511.27856709;
	incnd[0] = 123194.232663384;
	incnd[1] = -39655.2816164707;
	incnd[2] = 9072.41076452709;
	incnd[3] = 1.07540475602442;
	incnd[4] = 1.87215079605174;
	incnd[5] = -6.32811314849574;
	epoch = -189345600.;
	dt = *et - epoch;
	prop2b_(gm, incnd, &dt, state);
    } else if (*body == 801) {
	*center = 899;
	*frame = 10;
	s_copy(segid, "TRITON", segid_len, (ftnlen)6);
	*gm = 6822317.25434592;
	incnd[0] = -29804.0635385521;
	incnd[1] = 121869.821676598;
	incnd[2] = 331834.43952858;
	incnd[3] = 3.9668310117962;
	incnd[4] = 1.85216130354845;
	incnd[5] = -.323871607592234;
	epoch = -189345600.;
	dt = *et - epoch;
	prop2b_(gm, incnd, &dt, state);
    } else if (*body == 802) {
	*center = 899;
	*frame = 11;
	s_copy(segid, "NERIED", segid_len, (ftnlen)6);
	*gm = 6822317.25434592;
	incnd[0] = 2169661.50023747;
	incnd[1] = 8308261.24967138;
	incnd[2] = 4422710.82502134;
	incnd[3] = -.41186378812063;
	incnd[4] = .07367507286839281;
	incnd[5] = .01073818194480183;
	epoch = -189345600.;
	dt = *et - epoch;
	prop2b_(gm, incnd, &dt, state);
    } else if (*body == 901) {
	*center = 999;
	*frame = 12;
	s_copy(segid, "CHARON", segid_len, (ftnlen)6);
	*gm = 825.510499463536;
	incnd[0] = 3194.09001334327;
	incnd[1] = -1184.3591754164;
	incnd[2] = -19340.0401110163;
	incnd[3] = -.162746497898968;
	incnd[4] = -.152373801539905;
	incnd[5] = -.0175845011453347;
	epoch = -189345600.;
	dt = *et - epoch;
	prop2b_(gm, incnd, &dt, state);
    } else if (*body == 199) {
	*center = 1;
	s_copy(segid, "MERCURY", segid_len, (ftnlen)7);
	*frame = 1;
	state[0] = 10.;
	state[1] = 8.;
	state[2] = 6.;
	state[3] = 0.;
	state[4] = 0.;
	state[5] = 0.;
    } else if (*body == 299) {
	*center = 2;
	s_copy(segid, "VENUS", segid_len, (ftnlen)5);
	*frame = 2;
	state[0] = 20.;
	state[1] = 16.;
	state[2] = 12.;
	state[3] = 0.;
	state[4] = 0.;
	state[5] = 0.;
    } else if (*body == 399) {
	*center = 3;
	s_copy(segid, "EARTH", segid_len, (ftnlen)5);
	*frame = 3;
	state[0] = 30.;
	state[1] = 24.;
	state[2] = 18.;
	state[3] = 0.;
	state[4] = 0.;
	state[5] = 0.;
    } else if (*body == 499) {
	*center = 4;
	s_copy(segid, "MARS", segid_len, (ftnlen)4);
	*frame = 4;
	state[0] = 40.;
	state[1] = 32.;
	state[2] = 24.;
	state[3] = 0.;
	state[4] = 0.;
	state[5] = 0.;
    } else if (*body == 599) {
	*center = 5;
	s_copy(segid, "JUPITER", segid_len, (ftnlen)7);
	*frame = 5;
	state[0] = 50.;
	state[1] = 40.;
	state[2] = 30.;
	state[3] = 0.;
	state[4] = 0.;
	state[5] = 0.;
    } else if (*body == 699) {
	*center = 6;
	s_copy(segid, "SATURN", segid_len, (ftnlen)6);
	*frame = 6;
	state[0] = 60.;
	state[1] = 48.;
	state[2] = 36.;
	state[3] = 0.;
	state[4] = 0.;
	state[5] = 0.;
    } else if (*body == 799) {
	*center = 7;
	s_copy(segid, "URANUS", segid_len, (ftnlen)6);
	*frame = 7;
	state[0] = 70.;
	state[1] = 56.;
	state[2] = 42.;
	state[3] = 0.;
	state[4] = 0.;
	state[5] = 0.;
    } else if (*body == 899) {
	*center = 8;
	s_copy(segid, "NEPTUNE", segid_len, (ftnlen)7);
	*frame = 8;
	state[0] = 80.;
	state[1] = 64.;
	state[2] = 48.;
	state[3] = 0.;
	state[4] = 0.;
	state[5] = 0.;
    } else if (*body == 999) {
	*center = 9;
	s_copy(segid, "PLUTO", segid_len, (ftnlen)5);
	*frame = 9;
	state[0] = 90.;
	state[1] = 72.;
	state[2] = 54.;
	state[3] = 0.;
	state[4] = 0.;
	state[5] = 0.;
    } else if (*body == 10) {
	*center = 0;
	s_copy(segid, "SUN", segid_len, (ftnlen)3);
	*frame = 1;
	state[0] = 10.;
	state[1] = 10.;
	state[2] = 10.;
	state[3] = 0.;
	state[4] = 0.;
	state[5] = 0.;
    } else if (*body == 399001) {
	*center = 399;
	s_copy(segid, "GOLDSTONE", segid_len, (ftnlen)9);
	namfrm_("IAU_EARTH", frame, (ftnlen)9);
	state[0] = -2356.1565;
	state[1] = -4646.8408;
	state[2] = 3668.287;
	state[3] = 0.;
	state[4] = 0.;
	state[5] = 0.;
    } else if (*body == 399002) {
	*center = 399;
	s_copy(segid, "CANBERRA", segid_len, (ftnlen)8);
	namfrm_("IAU_EARTH", frame, (ftnlen)9);
	state[0] = -4450.9405;
	state[1] = 2676.8718;
	state[2] = -3691.4945;
	state[3] = 0.;
	state[4] = 0.;
	state[5] = 0.;
    } else if (*body == 399003) {
	*center = 399;
	s_copy(segid, "MADRID", segid_len, (ftnlen)6);
	namfrm_("IAU_EARTH", frame, (ftnlen)9);
	state[0] = 4847.9106;
	state[1] = -353.3451;
	state[2] = 4117.1925;
	state[3] = 0.;
	state[4] = 0.;
	state[5] = 0.;
    } else if (*body == -9) {
	*center = 301;
	namfrm_("ECLIPJ2000", frame, (ftnlen)10);
	s_copy(segid, "PHOENIX SPACECRAFT", segid_len, (ftnlen)18);
	epoch = -189345600.;
	*gm = 4902.79906388137;
	elems[0] = 3e3;
	elems[1] = 0.;
	elems[2] = pi_() / 3.;
	elems[3] = 0.;
	elems[4] = 0.;
	elems[5] = 0.;
	elems[6] = 0.;
	elems[7] = *gm;
	conics_(elems, &epoch, incnd);
	d__1 = *et - epoch;
	prop2b_(gm, incnd, &d__1, state);
    } else if (*body == 401001) {
	*center = 401;
	s_copy(segid, "PHOBOS BASECAMP", segid_len, (ftnlen)15);
	namfrm_("IAU_PHOBOS", frame, (ftnlen)10);
	state[0] = 13.502;
	state[1] = 0.;
	state[2] = 0.;
	state[3] = 0.;
	state[4] = 0.;
	state[5] = 0.;
    } else if (*body == 301001) {
	*center = 301;
	s_copy(segid, "TRANQUILITY BASE", segid_len, (ftnlen)16);
	namfrm_("IAU_MOON", frame, (ftnlen)8);
	lat = dpr_() * 5.;
	long__ = dpr_() * -25.;
	rad = 1737.402f;
	latrec_(&rad, &long__, &lat, state);
	state[3] = 0.;
	state[4] = 0.;
	state[5] = 0.;
    }
    return 0;

L_tststc:
    if (first) {
	first = FALSE_;
	bodcod[0] = -9;
	bodcod[1] = 1;
	bodcod[2] = 2;
	bodcod[3] = 3;
	bodcod[4] = 4;
	bodcod[5] = 5;
	bodcod[6] = 6;
	bodcod[7] = 7;
	bodcod[8] = 8;
	bodcod[9] = 9;
	bodcod[10] = 301;
	bodcod[11] = 401;
	bodcod[12] = 402;
	bodcod[13] = 501;
	bodcod[14] = 502;
	bodcod[15] = 503;
	bodcod[16] = 504;
	bodcod[17] = 603;
	bodcod[18] = 604;
	bodcod[19] = 605;
	bodcod[20] = 606;
	bodcod[21] = 607;
	bodcod[22] = 608;
	bodcod[23] = 701;
	bodcod[24] = 702;
	bodcod[25] = 703;
	bodcod[26] = 704;
	bodcod[27] = 705;
	bodcod[28] = 801;
	bodcod[29] = 802;
	bodcod[30] = 901;
	bodcod[31] = 199;
	bodcod[32] = 299;
	bodcod[33] = 399;
	bodcod[34] = 499;
	bodcod[35] = 599;
	bodcod[36] = 699;
	bodcod[37] = 799;
	bodcod[38] = 899;
	bodcod[39] = 999;
	bodcod[40] = 10;
	bodcod[41] = 399001;
	bodcod[42] = 399002;
	bodcod[43] = 399003;
	bodcod[44] = 401001;
	bodcod[45] = 301001;
    }
    if (*body < 0 || *body > 46) {
	*center = 0;
    } else {
	*center = bodcod[(i__1 = *body - 1) < 46 && 0 <= i__1 ? i__1 : s_rnge(
		"bodcod", i__1, "tstst_", (ftnlen)1016)];
    }
    return 0;
} /* tstst_ */

/* Subroutine */ int tstst_(integer *body, doublereal *et, char *segid, 
	integer *frame, doublereal *state, integer *center, doublereal *gm, 
	ftnlen segid_len)
{
    return tstst_0_(0, body, et, segid, frame, state, center, gm, segid_len);
    }

/* Subroutine */ int tststc_(integer *body, integer *center)
{
    return tstst_0_(1, body, (doublereal *)0, (char *)0, (integer *)0, (
	    doublereal *)0, center, (doublereal *)0, (ftnint)0);
    }

