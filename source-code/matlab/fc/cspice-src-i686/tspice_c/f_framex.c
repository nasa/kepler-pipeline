/* f_framex.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static integer c__0 = 0;
static integer c__1 = 1;
static integer c__2 = 2;
static integer c__9 = 9;
static integer c__20000 = 20000;
static integer c_n399 = -399;
static integer c_n499 = -499;
static integer c_b125 = 1000000;
static logical c_true = TRUE_;
static integer c__399 = 399;
static integer c__3000 = 3000;
static integer c__13000 = 13000;
static integer c__4 = 4;
static integer c__10081 = 10081;
static integer c__10 = 10;
static integer c__199 = 199;
static integer c_b339 = 1000131;
static integer c_b344 = 2000433;
static integer c_b354 = 1000001;

/* $Procedure      F_FRAMEX ( Family of tests for FRAMEX) */
/* Subroutine */ int f_framex__(logical *ok)
{
    /* System generated locals */
    address a__1[2];
    integer i__1, i__2[2];
    char ch__1[16], ch__2[16];
    cllist cl__1;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_wsle(cilist *), do_lio(integer *, integer *, char *, ftnlen), 
	    e_wsle(void), f_clos(cllist *), s_rnge(char *, integer, char *, 
	    integer);
    /* Subroutine */ int s_cat(char *, char **, integer *, integer *, ftnlen);

    /* Local variables */
    integer code;
    char name__[32];
    integer cent;
    char text[80*20];
    integer i__, ecode;
    char ename[32];
    integer frame, codes[40];
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    char names[32*40];
    integer class__;
    logical found;
    extern /* Subroutine */ int topen_(char *, ftnlen);
    integer sunit;
    extern /* Subroutine */ int bodc2n_(integer *, char *, logical *, ftnlen),
	     t_success__(logical *);
    logical found1, found2;
    extern /* Character */ VOID begdat_(char *, ftnlen);
    integer idcode;
    extern /* Subroutine */ int chcksc_(char *, char *, char *, char *, 
	    logical *, ftnlen, ftnlen, ftnlen, ftnlen);
    integer frcode;
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     chcksi_(char *, integer *, char *, integer *, integer *, logical 
	    *, ftnlen, ftnlen), cidfrm_(integer *, integer *, char *, logical 
	    *, ftnlen), chcksl_(char *, logical *, logical *, logical *, 
	    ftnlen);
    char frname[32];
    extern /* Subroutine */ int kilfil_(char *, ftnlen), frmnam_(integer *, 
	    char *, ftnlen);
    integer clssid;
    extern /* Subroutine */ int framex_(char *, char *, integer *, integer *, 
	    integer *, integer *, logical *, ftnlen, ftnlen);
    char messge[240];
    extern /* Subroutine */ int frinfo_(integer *, integer *, integer *, 
	    integer *, logical *), namfrm_(char *, integer *, ftnlen), 
	    cnmfrm_(char *, integer *, char *, logical *, ftnlen, ftnlen), 
	    ldpool_(char *, ftnlen);
    logical istrue;
    extern /* Subroutine */ int tstmsg_(char *, char *, ftnlen, ftnlen), 
	    tstmsi_(integer *), txtopn_(char *, integer *, ftnlen), tsttxt_(
	    char *, char *, integer *, logical *, logical *, ftnlen, ftnlen);

    /* Fortran I/O blocks */
    static cilist io___14 = { 0, 0, 0, 0, 0 };
    static cilist io___15 = { 0, 0, 0, 0, 0 };
    static cilist io___16 = { 0, 0, 0, 0, 0 };
    static cilist io___17 = { 0, 0, 0, 0, 0 };
    static cilist io___18 = { 0, 0, 0, 0, 0 };
    static cilist io___19 = { 0, 0, 0, 0, 0 };
    static cilist io___20 = { 0, 0, 0, 0, 0 };


/* $ Abstract */

/*     This test family checks out the frame expert utility FRAMEX. */
/*     It exercises all entry points and checks that data loaded */
/*     in the kernel pool is visible and properly retrieved. */

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

/* -& */

/*     Test Utility Functions */


/*     SPICELIB Functions */


/*     Local Variables */


/*     Begin every test family with an open call. */

    topen_("F_FRAMEX", (ftnlen)8);
    istrue = TRUE_;
    tcase_("Test the exception that should be signalled if FRAMEX is called "
	    "directly. ", (ftnlen)74);
    framex_(ename, frname, &frcode, &cent, &class__, &clssid, &found, (ftnlen)
	    32, (ftnlen)32);
    chckxc_(&istrue, "SPICE(BOGUSENTRY)", ok, (ftnlen)17);
    tcase_("Perform check to make sure that every inertial frame is recogniz"
	    "ed. ", (ftnlen)68);

/*        Note that the upper bound of the loop should be increased */
/*        if the number of inertial frames increases. */

    for (i__ = 1; i__ <= 18; ++i__) {
	frcode = i__;
	frinfo_(&frcode, &cent, &class__, &clssid, &found);
	s_copy(messge, "The case failed when the inertial frame code supplie"
		"d to FRINFO was #. ", (ftnlen)240, (ftnlen)71);
	tstmsg_("#", messge, (ftnlen)1, (ftnlen)240);
	tstmsi_(&frcode);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &istrue, ok, (ftnlen)5);
	chcksi_("CENTER", &cent, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);
	chcksi_("CLASS", &class__, "=", &c__1, &c__0, ok, (ftnlen)5, (ftnlen)
		1);
	chcksi_("CLSSID", &clssid, "=", &i__, &c__0, ok, (ftnlen)6, (ftnlen)1)
		;
    }
    tcase_("Check to make sure that the the recognized non-inertial frames a"
	    "re all type PCK. ", (ftnlen)81);
    for (i__ = 1; i__ <= 79; ++i__) {
	frcode = i__ + 10000;
	frinfo_(&frcode, &cent, &class__, &clssid, &found);
	s_copy(messge, "The case failed when the non-inertial frame code sup"
		"plied to FRINFO was #. ", (ftnlen)240, (ftnlen)75);
	tstmsg_("#", messge, (ftnlen)1, (ftnlen)240);
	tstmsi_(&frcode);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &istrue, ok, (ftnlen)5);
	chcksi_("CLASS", &class__, "=", &c__2, &c__0, ok, (ftnlen)5, (ftnlen)
		1);
    }
    tcase_("Make sure that the id-code to name to id-code path works.", (
	    ftnlen)57);
    for (i__ = 1; i__ <= 18; ++i__) {
	frcode = i__;
	s_copy(name__, " ", (ftnlen)32, (ftnlen)1);
	frmnam_(&frcode, name__, (ftnlen)32);
	namfrm_(name__, &code, (ftnlen)32);
	s_copy(messge, "The case failed when the frame code was #. ", (ftnlen)
		240, (ftnlen)43);
	tstmsg_("#", messge, (ftnlen)1, (ftnlen)240);
	tstmsi_(&frcode);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksi_("FRCODE", &frcode, "=", &code, &c__0, ok, (ftnlen)6, (ftnlen)
		1);
	chcksc_("NAME", name__, "!=", " ", ok, (ftnlen)4, (ftnlen)32, (ftnlen)
		2, (ftnlen)1);
    }
    for (i__ = 1; i__ <= 79; ++i__) {
	frcode = i__ + 10000;
	s_copy(name__, " ", (ftnlen)32, (ftnlen)1);
	frmnam_(&frcode, name__, (ftnlen)32);
	namfrm_(name__, &code, (ftnlen)32);
	s_copy(messge, "The case failed when the frame code was #. ", (ftnlen)
		240, (ftnlen)43);
	tstmsg_("#", messge, (ftnlen)1, (ftnlen)240);
	tstmsi_(&frcode);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksi_("FRCODE", &frcode, "=", &code, &c__0, ok, (ftnlen)6, (ftnlen)
		1);
	chcksc_("NAME", name__, "!=", " ", ok, (ftnlen)4, (ftnlen)32, (ftnlen)
		2, (ftnlen)1);
    }
    tcase_("Check to make sure we can get data from the kernel pool.", (
	    ftnlen)56);
    kilfil_("framedat.cnk", (ftnlen)12);
    txtopn_("framedat.cnk", &sunit, (ftnlen)12);
    io___14.ciunit = sunit;
    s_wsle(&io___14);
    begdat_(ch__2, (ftnlen)16);
    s_copy(ch__1, ch__2, (ftnlen)16, (ftnlen)16);
    do_lio(&c__9, &c__1, ch__1, (ftnlen)16);
    e_wsle();
    io___15.ciunit = sunit;
    s_wsle(&io___15);
    do_lio(&c__9, &c__1, "FRAME_20000_CLASS    = 2 ", (ftnlen)25);
    e_wsle();
    io___16.ciunit = sunit;
    s_wsle(&io___16);
    do_lio(&c__9, &c__1, "FRAME_20000_CENTER   = -399 ", (ftnlen)28);
    e_wsle();
    io___17.ciunit = sunit;
    s_wsle(&io___17);
    do_lio(&c__9, &c__1, "FRAME_20000_CLASS_ID = -499 ", (ftnlen)28);
    e_wsle();
    io___18.ciunit = sunit;
    s_wsle(&io___18);
    do_lio(&c__9, &c__1, "FRAME_20000_NAME     = 'TESTFRAME' ", (ftnlen)35);
    e_wsle();
    io___19.ciunit = sunit;
    s_wsle(&io___19);
    do_lio(&c__9, &c__1, "FRAME_TESTFRAME      = 20000 ", (ftnlen)29);
    e_wsle();
    io___20.ciunit = sunit;
    s_wsle(&io___20);
    do_lio(&c__9, &c__1, " ", (ftnlen)1);
    e_wsle();
    cl__1.cerr = 0;
    cl__1.cunit = sunit;
    cl__1.csta = 0;
    f_clos(&cl__1);
    s_copy(messge, "This is before loading the kernel pool.", (ftnlen)240, (
	    ftnlen)39);
    tstmsg_("#", messge, (ftnlen)1, (ftnlen)240);
    frinfo_(&c__20000, &cent, &class__, &clssid, &found1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND1", &found1, &c_false, ok, (ftnlen)6);
    ldpool_("framedat.cnk", (ftnlen)12);
    s_copy(messge, "This is after loading the kernel pool.", (ftnlen)240, (
	    ftnlen)38);
    tstmsg_("#", messge, (ftnlen)1, (ftnlen)240);
    frmnam_(&c__20000, name__, (ftnlen)32);
    namfrm_("TESTFRAME", &idcode, (ftnlen)9);
    frinfo_(&c__20000, &cent, &class__, &clssid, &found2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND2", &found2, &istrue, ok, (ftnlen)6);
    chcksc_("NAME", name__, "=", "TESTFRAME", ok, (ftnlen)4, (ftnlen)32, (
	    ftnlen)1, (ftnlen)9);
    chcksi_("IDCODE", &idcode, "=", &c__20000, &c__0, ok, (ftnlen)6, (ftnlen)
	    1);
    chcksi_("CENT", &cent, "=", &c_n399, &c__0, ok, (ftnlen)4, (ftnlen)1);
    chcksi_("CLASS", &class__, "=", &c__2, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksi_("CLSSID", &clssid, "=", &c_n499, &c__0, ok, (ftnlen)6, (ftnlen)1);
    kilfil_("framedat.cnk", (ftnlen)12);
    tstmsg_("#", " ", (ftnlen)1, (ftnlen)1);
    tcase_("Make sure that unrecognized names don't produce a non-zero frame"
	    " code. ", (ftnlen)71);
    namfrm_("SPUD", &idcode, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("IDCODE", &idcode, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);
    tcase_("Make sure that unknown idcodes produce blank names and that they"
	    " are not found by FRINFO ", (ftnlen)89);
    frmnam_(&c_b125, name__, (ftnlen)32);
    frinfo_(&c_b125, &cent, &class__, &clssid, &found);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND2", &found, &c_false, ok, (ftnlen)6);
    chcksc_("NAME", name__, "=", " ", ok, (ftnlen)4, (ftnlen)32, (ftnlen)1, (
	    ftnlen)1);
    tcase_("Make sure that frames with id-codes in the range from 13001 to 1"
	    "3999 produce correct CENT, CLASS, and CLSSID values. ", (ftnlen)
	    117);
    for (i__ = 13001; i__ <= 13999; i__ += 37) {
	frame = i__;
	frinfo_(&frame, &cent, &class__, &clssid, &found);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	chcksi_("CENT", &cent, "=", &c__399, &c__0, ok, (ftnlen)4, (ftnlen)1);
	chcksi_("CENT", &class__, "=", &c__2, &c__0, ok, (ftnlen)4, (ftnlen)1)
		;
	i__1 = frame - 10000;
	chcksi_("CENT", &clssid, "=", &i__1, &c__0, ok, (ftnlen)4, (ftnlen)1);
    }
    tcase_("Make sure the frame 'ITRF93' is a recognized frame and the frame"
	    " information associated with it is correct. ", (ftnlen)108);
    namfrm_("ITRF93", &frame, (ftnlen)6);
    frmnam_(&frame, name__, (ftnlen)32);
    frinfo_(&frame, &cent, &class__, &clssid, &found);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CENT", &cent, "=", &c__399, &c__0, ok, (ftnlen)4, (ftnlen)1);
    chcksi_("CENT", &class__, "=", &c__2, &c__0, ok, (ftnlen)4, (ftnlen)1);
    chcksi_("CENT", &clssid, "=", &c__3000, &c__0, ok, (ftnlen)4, (ftnlen)1);
    chcksc_("NAME", name__, "=", "ITRF93", ok, (ftnlen)4, (ftnlen)32, (ftnlen)
	    1, (ftnlen)6);
    chcksi_("FRAME", &frame, "=", &c__13000, &c__0, ok, (ftnlen)5, (ftnlen)1);
    tcase_("Make sure the frame 'EARTH_FIXED' is a recognized frame and the "
	    "frame information associated with it is correct. ", (ftnlen)113);
    namfrm_("EARTH_FIXED", &frame, (ftnlen)11);
    frmnam_(&frame, name__, (ftnlen)32);
    frinfo_(&frame, &cent, &class__, &clssid, &found);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CENT", &cent, "=", &c__399, &c__0, ok, (ftnlen)4, (ftnlen)1);
    chcksi_("CENT", &class__, "=", &c__4, &c__0, ok, (ftnlen)4, (ftnlen)1);
    chcksi_("CENT", &clssid, "=", &c__10081, &c__0, ok, (ftnlen)4, (ftnlen)1);
    chcksc_("NAME", name__, "=", "EARTH_FIXED", ok, (ftnlen)4, (ftnlen)32, (
	    ftnlen)1, (ftnlen)11);
    chcksi_("FRAME", &frame, "=", &c__10081, &c__0, ok, (ftnlen)5, (ftnlen)1);
    tcase_("Make sure that the frame to associate with the planets and satel"
	    "lites are known from the built-in list. ", (ftnlen)104);
    s_copy(names, "MERCURY", (ftnlen)32, (ftnlen)7);
    s_copy(names + 32, "VENUS", (ftnlen)32, (ftnlen)5);
    s_copy(names + 64, "EARTH", (ftnlen)32, (ftnlen)5);
    s_copy(names + 96, "MARS", (ftnlen)32, (ftnlen)4);
    s_copy(names + 128, "JUPITER", (ftnlen)32, (ftnlen)7);
    s_copy(names + 160, "SATURN", (ftnlen)32, (ftnlen)6);
    s_copy(names + 192, "URANUS", (ftnlen)32, (ftnlen)6);
    s_copy(names + 224, "NEPTUNE", (ftnlen)32, (ftnlen)7);
    s_copy(names + 256, "PLUTO", (ftnlen)32, (ftnlen)5);
    s_copy(names + 288, "SUN", (ftnlen)32, (ftnlen)3);
    s_copy(names + 320, "MOON", (ftnlen)32, (ftnlen)4);
    s_copy(names + 352, "PHOBOS", (ftnlen)32, (ftnlen)6);
    s_copy(names + 384, "DEIMOS", (ftnlen)32, (ftnlen)6);
    s_copy(names + 416, "IO", (ftnlen)32, (ftnlen)2);
    s_copy(names + 448, "EUROPA", (ftnlen)32, (ftnlen)6);
    s_copy(names + 480, "GANYMEDE", (ftnlen)32, (ftnlen)8);
    s_copy(names + 512, "CALLISTO", (ftnlen)32, (ftnlen)8);
    s_copy(names + 544, "AMALTHEA", (ftnlen)32, (ftnlen)8);
    s_copy(names + 576, "ADRASTEA", (ftnlen)32, (ftnlen)8);
    s_copy(names + 608, "METIS", (ftnlen)32, (ftnlen)5);
    s_copy(names + 640, "TITAN", (ftnlen)32, (ftnlen)5);
    s_copy(names + 672, "OBERON", (ftnlen)32, (ftnlen)6);
    s_copy(names + 704, "TITANIA", (ftnlen)32, (ftnlen)7);
    s_copy(names + 736, "UMBRIEL", (ftnlen)32, (ftnlen)7);
    s_copy(names + 768, "PUCK", (ftnlen)32, (ftnlen)4);
    s_copy(names + 800, "MIRANDA", (ftnlen)32, (ftnlen)7);
    s_copy(names + 832, "HIMALIA", (ftnlen)32, (ftnlen)7);
    s_copy(names + 864, "ARIEL", (ftnlen)32, (ftnlen)5);
    s_copy(names + 896, "ELARA", (ftnlen)32, (ftnlen)5);
    s_copy(names + 928, "TRITON", (ftnlen)32, (ftnlen)6);
    s_copy(names + 960, "NEREID", (ftnlen)32, (ftnlen)6);
    s_copy(names + 992, "CHARON", (ftnlen)32, (ftnlen)6);
    for (i__ = 1; i__ <= 32; ++i__) {
	cnmfrm_(names + (((i__1 = i__ - 1) < 40 && 0 <= i__1 ? i__1 : s_rnge(
		"names", i__1, "f_framex__", (ftnlen)364)) << 5), &frcode, 
		frname, &found, (ftnlen)32, (ftnlen)32);
/* Writing concatenation */
	i__2[0] = 4, a__1[0] = "IAU_";
	i__2[1] = 32, a__1[1] = names + (((i__1 = i__ - 1) < 40 && 0 <= i__1 ?
		 i__1 : s_rnge("names", i__1, "f_framex__", (ftnlen)366)) << 
		5);
	s_cat(ename, a__1, i__2, &c__2, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	chcksc_("FRNAME", frname, "=", ename, ok, (ftnlen)6, (ftnlen)32, (
		ftnlen)1, (ftnlen)32);
	namfrm_(frname, &ecode, (ftnlen)32);
	chcksi_("FRCODE", &frcode, "=", &ecode, &c__0, ok, (ftnlen)6, (ftnlen)
		1);
    }
    tcase_("Verify that the mapping between centers input as id-codes and as"
	    "sociated frames is correctly maintained for the default set of b"
	    "odyfixed frames. ", (ftnlen)145);
    codes[0] = 199;
    codes[1] = 299;
    codes[2] = 399;
    codes[3] = 499;
    codes[4] = 599;
    codes[5] = 699;
    codes[6] = 799;
    codes[7] = 899;
    codes[8] = 999;
    codes[9] = 301;
    codes[10] = 10;
    codes[11] = 401;
    codes[12] = 402;
    codes[13] = 501;
    codes[14] = 502;
    codes[15] = 503;
    codes[16] = 504;
    codes[17] = 505;
    codes[18] = 506;
    codes[19] = 507;
    codes[20] = 508;
    codes[21] = 509;
    codes[22] = 510;
    codes[23] = 601;
    codes[24] = 602;
    codes[25] = 603;
    codes[26] = 604;
    codes[27] = 605;
    codes[28] = 606;
    codes[29] = 607;
    codes[30] = 701;
    codes[31] = 702;
    codes[32] = 703;
    codes[33] = 704;
    codes[34] = 705;
    codes[35] = 801;
    codes[36] = 802;
    codes[37] = 901;
    codes[38] = 801;
    for (i__ = 1; i__ <= 39; ++i__) {
	bodc2n_(&codes[(i__1 = i__ - 1) < 40 && 0 <= i__1 ? i__1 : s_rnge(
		"codes", i__1, "f_framex__", (ftnlen)427)], name__, &found, (
		ftnlen)32);
/* Writing concatenation */
	i__2[0] = 4, a__1[0] = "IAU_";
	i__2[1] = 32, a__1[1] = name__;
	s_cat(ename, a__1, i__2, &c__2, (ftnlen)32);
	cidfrm_(&codes[(i__1 = i__ - 1) < 40 && 0 <= i__1 ? i__1 : s_rnge(
		"codes", i__1, "f_framex__", (ftnlen)431)], &frcode, frname, &
		found, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	chcksc_("FRNAME", frname, "=", ename, ok, (ftnlen)6, (ftnlen)32, (
		ftnlen)1, (ftnlen)32);
	namfrm_(frname, &ecode, (ftnlen)32);
	chcksi_("FRCODE", &frcode, "=", &ecode, &c__0, ok, (ftnlen)6, (ftnlen)
		1);
	frinfo_(&frcode, &code, &class__, &clssid, &found);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	chcksi_("CODE", &code, "=", &codes[(i__1 = i__ - 1) < 40 && 0 <= i__1 
		? i__1 : s_rnge("codes", i__1, "f_framex__", (ftnlen)443)], &
		c__0, ok, (ftnlen)4, (ftnlen)1);
    }
    tcase_("Load a preferred frame into the kernel pool and make sure that t"
	    "he frame subsystem can locate the preferred frame. ", (ftnlen)115)
	    ;
    begdat_(ch__1, (ftnlen)16);
    s_copy(text, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(text + 80, "OBJECT_EARTH_FRAME = 'ITRF93'", (ftnlen)80, (ftnlen)29)
	    ;
    s_copy(text + 160, "OBJECT_199_FRAME   = 'J2000'", (ftnlen)80, (ftnlen)28)
	    ;
    s_copy(text + 240, "FRAME_EROSFIXED        = 1000001", (ftnlen)80, (
	    ftnlen)32);
    s_copy(text + 320, "FRAME_1000001_NAME     = 'EROSFIXED'", (ftnlen)80, (
	    ftnlen)36);
    s_copy(text + 400, "FRAME_1000001_CLASS    = 2", (ftnlen)80, (ftnlen)26);
    s_copy(text + 480, "FRAME_1000001_CLASS_ID = 2000433", (ftnlen)80, (
	    ftnlen)32);
    s_copy(text + 560, "FRAME_1000001_CENTER   = 2000433", (ftnlen)80, (
	    ftnlen)32);
    s_copy(text + 640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(text + 720, "OBJECT_2000433_FRAME   = 'EROSFIXED'", (ftnlen)80, (
	    ftnlen)36);
    kilfil_("framedat.cnk", (ftnlen)12);
    tsttxt_("framedat.cnk", text, &c__10, &c_true, &c_false, (ftnlen)12, (
	    ftnlen)80);

/*        Check CIDFRM and CNMFRM to make sure they can find */
/*        a built-in frame associated with the Earth via a */
/*        kernel pool assignment. */

    cidfrm_(&c__399, &frcode, frname, &found, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("FRNAME", frname, "=", "ITRF93", ok, (ftnlen)6, (ftnlen)32, (
	    ftnlen)1, (ftnlen)6);
    chcksi_("FRCODE", &frcode, "=", &c__13000, &c__0, ok, (ftnlen)6, (ftnlen)
	    1);
    cnmfrm_("EARTH", &frcode, frname, &found, (ftnlen)5, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("FRNAME", frname, "=", "ITRF93", ok, (ftnlen)6, (ftnlen)32, (
	    ftnlen)1, (ftnlen)6);
    chcksi_("FRCODE", &frcode, "=", &c__13000, &c__0, ok, (ftnlen)6, (ftnlen)
	    1);
    cidfrm_(&c__199, &frcode, frname, &found, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("FRNAME", frname, "=", "J2000", ok, (ftnlen)6, (ftnlen)32, (
	    ftnlen)1, (ftnlen)5);
    chcksi_("FRCODE", &frcode, "=", &c__1, &c__0, ok, (ftnlen)6, (ftnlen)1);
    cnmfrm_("MERCURY", &frcode, frname, &found, (ftnlen)7, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("FRNAME", frname, "=", "J2000", ok, (ftnlen)6, (ftnlen)32, (
	    ftnlen)1, (ftnlen)5);
    chcksi_("FRCODE", &frcode, "=", &c__1, &c__0, ok, (ftnlen)6, (ftnlen)1);
    cnmfrm_("MATHILDE", &frcode, frname, &found, (ftnlen)8, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    cidfrm_(&c_b339, &frcode, frname, &found, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);

/*        Check CIDFRM and CNMFRM to make sure they can find */
/*        a TK frame associated with Eros via a */
/*        kernel pool assignment. */

    cidfrm_(&c_b344, &frcode, frname, &found, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("FRNAME", frname, "=", "EROSFIXED", ok, (ftnlen)6, (ftnlen)32, (
	    ftnlen)1, (ftnlen)9);
    chcksi_("FRCODE", &frcode, "=", &c_b354, &c__0, ok, (ftnlen)6, (ftnlen)1);
    cnmfrm_("EROS", &frcode, frname, &found, (ftnlen)4, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("FRNAME", frname, "=", "EROSFIXED", ok, (ftnlen)6, (ftnlen)32, (
	    ftnlen)1, (ftnlen)9);
    chcksi_("FRCODE", &frcode, "=", &c_b354, &c__0, ok, (ftnlen)6, (ftnlen)1);
    t_success__(ok);
    return 0;
} /* f_framex__ */

