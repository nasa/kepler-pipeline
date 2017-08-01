/* tstckn.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__9 = 9;
static integer c__1 = 1;

/* $Procedure      TSTCKN (Test CK No angular velocity) */
/* Subroutine */ int tstckn_(char *cknm, char *sclknm, logical *loadck, 
	logical *loadsc, logical *keepsc, integer *handle, ftnlen cknm_len, 
	ftnlen sclknm_len)
{
    /* System generated locals */
    integer i__1, i__2;
    char ch__1[16];
    cllist cl__1;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer), s_wsle(cilist *), 
	    do_lio(integer *, integer *, char *, ftnlen), e_wsle(void), 
	    f_clos(cllist *);

    /* Local variables */
    extern /* Subroutine */ int ckw03_(integer *, doublereal *, doublereal *, 
	    integer *, char *, logical *, char *, integer *, doublereal *, 
	    doublereal *, doublereal *, integer *, doublereal *, ftnlen, 
	    ftnlen);
    doublereal tick[205];
    integer inst, unit, i__, j, r__;
    char segid[32];
    logical avflg;
    extern /* Subroutine */ int cklpf_(char *, integer *, ftnlen);
    doublereal maxet;
    char error[80];
    integer nints;
    extern integer rtrim_(char *, ftnlen);
    extern /* Character */ VOID begdat_(char *, ftnlen);
    doublereal et;
    extern /* Subroutine */ int dafcls_(integer *);
    doublereal tk;
    char sclkbf[80*98];
    doublereal begtim;
    extern /* Subroutine */ int kilfil_(char *, ftnlen);
    doublereal angvel[615]	/* was [3][205] */;
    extern /* Subroutine */ int shelld_(integer *, doublereal *);
    doublereal endtim;
    extern /* Subroutine */ int tfiles_(char *, ftnlen), ldpool_(char *, 
	    ftnlen);
    integer nticks;
    extern /* Subroutine */ int tparse_(char *, doublereal *, char *, ftnlen, 
	    ftnlen), spcopn_(char *, char *, integer *, ftnlen, ftnlen), 
	    tstatd_(doublereal *, doublereal *, doublereal *);
    doublereal quatrn[820]	/* was [4][205] */, starts[1];
    extern /* Subroutine */ int m2q_(doublereal *, doublereal *);
    doublereal zeropt;
    extern /* Subroutine */ int txtopn_(char *, integer *, ftnlen);
    char ref[32];
    doublereal rot[9]	/* was [3][3] */;

    /* Fortran I/O blocks */
    static cilist io___5 = { 0, 0, 0, 0, 0 };


/* $ Abstract */

/*     Create and if appropriate load a test type 03 C-kernel and */
/*     associated S-clock kernel file. */

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
/*      CKNM       I   The name of the C-kernel to create */
/*      SCLKNM     I   The name of the S-clock kernel to create. */
/*      LOADCK     I   Load the C-kernel if TRUE */
/*      LOADSC     I   Load the S-clock kernel if TRUE */
/*      KEEPSC     I   Keep the S-clock kernel if TRUE, else delete it. */
/*      HANDLE     O   Handle of the c-kernel if it is loaded. */

/* $ Detailed_Input */

/*     CKNM        is the name of a C-kernel to create and load if */
/*                 LOADCK is set to TRUE.  If a C-kernel of the same */
/*                 name already exists it is deleted. */

/*     SCLKNM      is the name of an S-clock Kernel to create and load */
/*                 if LOADSC is set to TRUE.  If an S-clock kernel of */
/*                 the same name already exists, delete the existing */
/*                 kernel before creating this one. */

/*     LOADCK      is a logical that indicates whether or not the CK */
/*                 file should be loaded after it is created.  If it */
/*                 has the value TRUE the C-kernel is loaded after */
/*                 it is created.  Otherwise it is left un-opened. */

/*     LOADSC      is a logical that indicates whether or not the SCLK */
/*                 file should be loaded into the kernel pool.  If it */
/*                 has the value TRUE the SCLK file is loaded, otherwise */
/*                 it is left un-opened. */

/*     KEEPSC      is a logical that indicates whether or not the SCLK */
/*                 file should be deleted after it is loaded.  If KEEPSC */
/*                 is TRUE the file is not deleted.  If KEEPSC is FALSE */
/*                 the file is deleted after it is loaded.  NOTE that */
/*                 unless LOADSC is TRUE, the SCLK file is not deleted */
/*                 by this routine.  This routine deletes the SCLK kernel */
/*                 only if it LOADSC is TRUE and KEEPSC is FALSE. */

/* $ Detailed_Output */

/*     HANDLE      is the handle attached to the created C-kernel if */
/*                 the kernel is loaded because LOADCK has a value of */
/*                 TRUE.  Otherwise the value of HANDLE has no meaning. */

/* $ Parameters */

/*      None. */

/* $ Files */

/*      This routine creates two files a C-kernel with a three type 03 */
/*      segments and an associated SCLK kernel that contains all of the */
/*      connection information about the CK file and its associated */
/*      ephemeris and S-clock.  See C$ Particulars for more details. */

/* $ Exceptions */

/*     None. */

/* $ Particulars */

/*     This routine creates two files. */

/*     1) A C-kernel without angular velocity for the fictional */
/*        objects with ID codes -9999, -10000, and -10001. */

/*     2) A SCLK kernel to be associated with the C-kernel. */

/*     The C-kernel contains a single segment for each of the */
/*     fictional objects.  These segments give continous attitude */
/*     over the time interval */
/*     from 1980 JAN 1, 00:00:00.000 (ET) */
/*     to   2011 SEP 9, 01:46:40.000 (ET) */
/*     (a span of exactly 1 billion seconds). */


/*     The frames of the objects are */

/*     Object    Frame */
/*     -------   -------- */
/*     -9999     Galactic */
/*     -10000    FK5 */
/*     -10001    J2000 */

/*     All three objects rotate  at a rate of 1 radian per 10 million */
/*     seconds. The axis of rotation changes every 100 million seconds. */

/*     At various epochs the axes of the objects are exactly aligned */
/*     with their associated reference frame. */

/*     Object     Aligned with reference frame at epoch */
/*     ------     ------------------------------------- */
/*     -9999      Epoch of the J2000 frame */
/*     -10000     Epoch of J2000 */
/*     -10001     Epoch of J2000 */

/*     At the moment when the frames are aligned. The are rotating */
/*     around the direction (2, 1, 3) in their associated frames. */

/*     The C-kernel contains 606 attitude instances. */

/*     The attitude  produced by the CK software should very nearly */
/*     duplicate the results returned by the test routine TSTATD. */

/*     More specifically suppose we set up the arrays: */

/*        ID(1)     = -9999 */
/*        ID(2)     = -10000 */
/*        ID(3)     = -10001 */


/*        FRAME(1)  = 'GALACTIC' */
/*        FRAME(2)  = 'FK4' */
/*        FRAME(3)  = 'J2000' */


/*     Then the two methods of getting ROT  below should */
/*     produce results that agree to nearly roundoff. */

/*     Method 1. */

/*        CALL SCE2T ( -9, ET, TICK ) */
/*        CALL CKGP  ( ID(I), TICK, 0.0D0, FRAME(I), ROT, OUT, FND ) */

/*     Method 2. */

/*        CALL TSTATD ( ET , ROT, AV ) */


/* $ Examples */

/*     This is intended to be used in those instances when you */
/*     need a well defined C-kernel whose attitude can be accurately */
/*     predicted in advance. */

/*     The routine TSTATD returns the continuous attitude and angular */
/*     velocity of the C-kernel for all time.  As such it provides */
/*     a convenient method for testing the CK software for an individual */
/*     segment. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*      W.L. Taber      (JPL) */

/* $ Literature_References */

/*      None. */

/* $ Version */

/* -    Test Utilities 1.1.0, 28-JUL-1999 (WLT) */

/*        Added code so that the files created are "registered" with */
/*        the Test Utilities File Registry ( FILREG ).  By doing so */
/*        files will be deleted automatically at the end of a test */
/*        family. */

/* -    Test Utilities 1.0.0, 05-APR-1999 (WLT) */


/* -& */
/* $ Index_Entries */

/*     Create test CK and SCLK files. */

/* -& */

/*     Spicelib Functions */


/*     Test Utility Functions */


/*     Inline functions. */


/*     Local Variables. */


/*     Definitions of inline functions. */


/*     The first order of business is to wipe out any existing */
/*     files with the same name. */

    kilfil_(cknm, cknm_len);
    kilfil_(sclknm, sclknm_len);

/*     Fill up the buffer SCLKBF with the text that will make up */
/*     our test SCLK file. */

    s_copy(sclkbf, "TEST SPICE SCLK Kernel ", (ftnlen)80, (ftnlen)23);
    s_copy(sclkbf + 80, "------------------------------------------- -------"
	    "------ ", (ftnlen)80, (ftnlen)58);
    s_copy(sclkbf + 160, " ", (ftnlen)80, (ftnlen)1);
    s_copy(sclkbf + 240, "This file contains the data necessary for converti"
	    "ng from ", (ftnlen)80, (ftnlen)58);
    s_copy(sclkbf + 320, "ET to ticks for the fictional spacecraft -9999.  I"
	    "t is produced ", (ftnlen)80, (ftnlen)64);
    s_copy(sclkbf + 400, "by the Test Utility routine TSTCKN. ", (ftnlen)80, (
	    ftnlen)36);
    s_copy(sclkbf + 480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(sclkbf + 560, "This SCLK kernel is intended to be used with the t"
	    "est CK file ", (ftnlen)80, (ftnlen)62);
    s_copy(sclkbf + 640, "produced by that same routine.  The internal file "
	    "name of the ", (ftnlen)80, (ftnlen)62);
    s_copy(sclkbf + 720, "test C-Kernel is ZZ-TEST-CK-ZZ.  It contains a sin"
	    "gle type 03 ", (ftnlen)80, (ftnlen)62);
    s_copy(sclkbf + 800, "segment. ", (ftnlen)80, (ftnlen)9);
    s_copy(sclkbf + 880, " ", (ftnlen)80, (ftnlen)1);
    s_copy(sclkbf + 960, "This fictional clock begins a 1 JAN 1980 00:00:00 "
	    "ET and continues ", (ftnlen)80, (ftnlen)67);
    s_copy(sclkbf + 1040, "for 1 billion seconds.  (i.e. until 2011 SEP 9, 0"
	    "1:46:40.000 ET ). ", (ftnlen)80, (ftnlen)67);
    s_copy(sclkbf + 1120, " ", (ftnlen)80, (ftnlen)1);
    s_copy(sclkbf + 1200, "This is intended for test purposes only and can b"
	    "e easily rebuilt ", (ftnlen)80, (ftnlen)66);
    s_copy(sclkbf + 1280, "by calling the routine TSTCKN. ", (ftnlen)80, (
	    ftnlen)31);
    s_copy(sclkbf + 1360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(sclkbf + 1440, "If you have any questions about this file that th"
	    "ese comments don't ", (ftnlen)80, (ftnlen)68);
    s_copy(sclkbf + 1520, "answer, contact Bill Taber at NAIF. ", (ftnlen)80, 
	    (ftnlen)36);
    s_copy(sclkbf + 1600, " ", (ftnlen)80, (ftnlen)1);
    s_copy(sclkbf + 1680, "(818) 354-4279 ", (ftnlen)80, (ftnlen)15);
    s_copy(sclkbf + 1760, "btaber@spice.jpl.nasa.gov ", (ftnlen)80, (ftnlen)
	    26);
    s_copy(sclkbf + 1840, " ", (ftnlen)80, (ftnlen)1);
    s_copy(sclkbf + 1920, " ", (ftnlen)80, (ftnlen)1);
    s_copy(sclkbf + 2000, " ", (ftnlen)80, (ftnlen)1);
    s_copy(sclkbf + 2080, "Implementation notes ", (ftnlen)80, (ftnlen)21);
    s_copy(sclkbf + 2160, "-------------------------------------------------"
	    "------- ", (ftnlen)80, (ftnlen)57);
    s_copy(sclkbf + 2240, " ", (ftnlen)80, (ftnlen)1);
    s_copy(sclkbf + 2320, "This SCLK file is constructed so that the valid S"
	    "CLK strings ", (ftnlen)80, (ftnlen)61);
    s_copy(sclkbf + 2400, "are simply the number of TDB seconds that have pa"
	    "ssed ", (ftnlen)80, (ftnlen)54);
    s_copy(sclkbf + 2480, "since the Ephemeris epoch 1 Jan 1980 00:00:00 ", (
	    ftnlen)80, (ftnlen)46);
    s_copy(sclkbf + 2560, " ", (ftnlen)80, (ftnlen)1);
    s_copy(sclkbf + 2640, "So that 1/ 288929292.82017  simply represents the"
	    " epoch that occurs ", (ftnlen)80, (ftnlen)68);
    s_copy(sclkbf + 2720, "288929292.82017 TDB seconds past the ET epoch 1 J"
	    "an 1980. ", (ftnlen)80, (ftnlen)58);
    s_copy(sclkbf + 2800, " ", (ftnlen)80, (ftnlen)1);
    s_copy(sclkbf + 2880, "For all time, the clock runs at the same rate as "
	    "TDB. There is only ", (ftnlen)80, (ftnlen)68);
    s_copy(sclkbf + 2960, "one partition for this clock. ", (ftnlen)80, (
	    ftnlen)30);
    s_copy(sclkbf + 3040, " ", (ftnlen)80, (ftnlen)1);
    s_copy(sclkbf + 3120, "You must load this file into the kernel pool befo"
	    "re using any of the ", (ftnlen)80, (ftnlen)69);
    s_copy(sclkbf + 3200, "SPICELIB SCLK routines. The code fragment ", (
	    ftnlen)80, (ftnlen)42);
    s_copy(sclkbf + 3280, " ", (ftnlen)80, (ftnlen)1);
    s_copy(sclkbf + 3360, "CALL LDPOOL ( < name of this file > ) ", (ftnlen)
	    80, (ftnlen)38);
    s_copy(sclkbf + 3440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(sclkbf + 3520, "performs this task. To convert between ET and UTC"
	    ", you will also need ", (ftnlen)80, (ftnlen)70);
    s_copy(sclkbf + 3600, "to load a leapseconds kernel. The additional call"
	    " to LDPOOL, ", (ftnlen)80, (ftnlen)61);
    s_copy(sclkbf + 3680, " ", (ftnlen)80, (ftnlen)1);
    s_copy(sclkbf + 3760, "CALL LDPOOL ( < name of your leapsecond file > ) ",
	     (ftnlen)80, (ftnlen)49);
    s_copy(sclkbf + 3840, " ", (ftnlen)80, (ftnlen)1);
    s_copy(sclkbf + 3920, "will accomplish this. Note that you must supply t"
	    "he actual names of ", (ftnlen)80, (ftnlen)68);
    s_copy(sclkbf + 4000, "the files used on your system as arguments to LDP"
	    "OOL. Because the file ", (ftnlen)80, (ftnlen)71);
    s_copy(sclkbf + 4080, "names are system dependent, we do not list them h"
	    "ere. ", (ftnlen)80, (ftnlen)54);
    s_copy(sclkbf + 4160, " ", (ftnlen)80, (ftnlen)1);
    s_copy(sclkbf + 4240, "For more information, consult your SPICELIB requi"
	    "red reading files. ", (ftnlen)80, (ftnlen)68);
    s_copy(sclkbf + 4320, "The following areas are covered: ", (ftnlen)80, (
	    ftnlen)33);
    s_copy(sclkbf + 4400, " ", (ftnlen)80, (ftnlen)1);
    s_copy(sclkbf + 4480, "SCLK system                     SCLK required rea"
	    "ding ", (ftnlen)80, (ftnlen)54);
    s_copy(sclkbf + 4560, "Time systems and conversion     TIME required rea"
	    "ding ", (ftnlen)80, (ftnlen)54);
    s_copy(sclkbf + 4640, "Kernel pool                     KERNEL required r"
	    "eading ", (ftnlen)80, (ftnlen)56);
    s_copy(sclkbf + 4720, " ", (ftnlen)80, (ftnlen)1);
    s_copy(sclkbf + 4800, " ", (ftnlen)80, (ftnlen)1);
    s_copy(sclkbf + 4880, "Kernel data ", (ftnlen)80, (ftnlen)12);
    s_copy(sclkbf + 4960, "-------------------------------------------------"
	    "------- ", (ftnlen)80, (ftnlen)57);
    s_copy(sclkbf + 5040, " ", (ftnlen)80, (ftnlen)1);
    s_copy(sclkbf + 5120, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(sclkbf + 5200, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(sclkbf + 5280, " ", (ftnlen)80, (ftnlen)1);
    s_copy(sclkbf + 5360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(sclkbf + 5440, "SCLK_KERNEL_ID                = ( @28-OCT-1994   "
	    "     ) ", (ftnlen)80, (ftnlen)56);
    s_copy(sclkbf + 5520, " ", (ftnlen)80, (ftnlen)1);
    s_copy(sclkbf + 5600, "SCLK_DATA_TYPE_9              = ( 1 ) ", (ftnlen)
	    80, (ftnlen)38);
    s_copy(sclkbf + 5680, " ", (ftnlen)80, (ftnlen)1);
    s_copy(sclkbf + 5760, "SCLK01_TIME_SYSTEM_9          = ( 1 ) ", (ftnlen)
	    80, (ftnlen)38);
    s_copy(sclkbf + 5840, "SCLK01_N_FIELDS_9             = ( 2 ) ", (ftnlen)
	    80, (ftnlen)38);
    s_copy(sclkbf + 5920, "SCLK01_MODULI_9               = ( 1000000000     "
	    "10000 ) ", (ftnlen)80, (ftnlen)57);
    s_copy(sclkbf + 6000, "SCLK01_OFFSETS_9              = ( 0         0 ) ", 
	    (ftnlen)80, (ftnlen)48);
    s_copy(sclkbf + 6080, "SCLK01_OUTPUT_DELIM_9         = ( 1 ) ", (ftnlen)
	    80, (ftnlen)38);
    s_copy(sclkbf + 6160, " ", (ftnlen)80, (ftnlen)1);
    s_copy(sclkbf + 6240, "SCLK_PARTITION_START_9        = ( 0.0000000000000"
	    "E+00 ) ", (ftnlen)80, (ftnlen)56);
    s_copy(sclkbf + 6320, "SCLK_PARTITION_END_9          = ( 1.00000000E+14 "
	    "     ) ", (ftnlen)80, (ftnlen)56);
    s_copy(sclkbf + 6400, "SCLK01_COEFFICIENTS_9         = ( 0.00000000E+00 ",
	     (ftnlen)80, (ftnlen)49);
    s_copy(sclkbf + 6480, "@01-JAN-1980-00:00:00.000 ", (ftnlen)80, (ftnlen)
	    26);
    s_copy(sclkbf + 6560, "1  ) ", (ftnlen)80, (ftnlen)5);
    s_copy(sclkbf + 6640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(sclkbf + 6720, " ", (ftnlen)80, (ftnlen)1);
    s_copy(sclkbf + 6800, "DELTET/DELTA_T_A       =   32.184 ", (ftnlen)80, (
	    ftnlen)34);
    s_copy(sclkbf + 6880, "DELTET/K               =    1.657D-3 ", (ftnlen)80,
	     (ftnlen)37);
    s_copy(sclkbf + 6960, "DELTET/EB              =    1.671D-2 ", (ftnlen)80,
	     (ftnlen)37);
    s_copy(sclkbf + 7040, "DELTET/M               = (  6.239996D0 1.99096871"
	    "D-7 ) ", (ftnlen)80, (ftnlen)55);
    s_copy(sclkbf + 7120, " ", (ftnlen)80, (ftnlen)1);
    s_copy(sclkbf + 7200, "CK_-9999_SCLK          =   -9 ", (ftnlen)80, (
	    ftnlen)30);
    s_copy(sclkbf + 7280, "CK_-9999_SPK           =   -9 ", (ftnlen)80, (
	    ftnlen)30);
    s_copy(sclkbf + 7360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(sclkbf + 7440, "CK_-10000_SCLK         =   -9 ", (ftnlen)80, (
	    ftnlen)30);
    s_copy(sclkbf + 7520, "CK_-10000_SPK          =   -9 ", (ftnlen)80, (
	    ftnlen)30);
    s_copy(sclkbf + 7600, " ", (ftnlen)80, (ftnlen)1);
    s_copy(sclkbf + 7680, "CK_-10001_SCLK         =   -9 ", (ftnlen)80, (
	    ftnlen)30);
    s_copy(sclkbf + 7760, "CK_-10001_SPK          =   -9 ", (ftnlen)80, (
	    ftnlen)30);

/*     Create the SCLK kernel. */

    txtopn_(sclknm, &unit, sclknm_len);
    for (i__ = 1; i__ <= 98; ++i__) {
	r__ = rtrim_(sclkbf + ((i__1 = i__ - 1) < 98 && 0 <= i__1 ? i__1 : 
		s_rnge("sclkbf", i__1, "tstckn_", (ftnlen)452)) * 80, (ftnlen)
		80);
	io___5.ciunit = unit;
	s_wsle(&io___5);
	do_lio(&c__9, &c__1, sclkbf + ((i__1 = i__ - 1) < 98 && 0 <= i__1 ? 
		i__1 : s_rnge("sclkbf", i__1, "tstckn_", (ftnlen)453)) * 80, 
		r__);
	e_wsle();
    }
    cl__1.cerr = 0;
    cl__1.cunit = unit;
    cl__1.csta = 0;
    f_clos(&cl__1);

/*     Next create the C-kernel. Recall the relationship between */
/*     ET and encoded SCLK ticks.  There are 10000 ticks/second. */
/*     The zero point of the clock is 1 Jan 1980 TDB. */

    tparse_("1 Jan 1980", &zeropt, error, (ftnlen)10, (ftnlen)80);
    maxet = zeropt + 1e9;
    et = 0.;
    j = 0;
    while(et > zeropt) {
	++j;
	tick[(i__1 = j - 1) < 205 && 0 <= i__1 ? i__1 : s_rnge("tick", i__1, 
		"tstckn_", (ftnlen)473)] = (et - zeropt) * 1e4;
	++j;
	tick[(i__1 = j - 1) < 205 && 0 <= i__1 ? i__1 : s_rnge("tick", i__1, 
		"tstckn_", (ftnlen)476)] = tick[(i__2 = j - 2) < 205 && 0 <= 
		i__2 ? i__2 : s_rnge("tick", i__2, "tstckn_", (ftnlen)476)] - 
		1.;
	et += -1e7;
    }
    ++j;
    tick[(i__1 = j - 1) < 205 && 0 <= i__1 ? i__1 : s_rnge("tick", i__1, 
	    "tstckn_", (ftnlen)483)] = 0.;
    et = 1e7;
    while(et < maxet) {
	++j;
	tick[(i__1 = j - 1) < 205 && 0 <= i__1 ? i__1 : s_rnge("tick", i__1, 
		"tstckn_", (ftnlen)491)] = (et - zeropt) * 1e4;
	++j;
	tick[(i__1 = j - 1) < 205 && 0 <= i__1 ? i__1 : s_rnge("tick", i__1, 
		"tstckn_", (ftnlen)494)] = tick[(i__2 = j - 2) < 205 && 0 <= 
		i__2 ? i__2 : s_rnge("tick", i__2, "tstckn_", (ftnlen)494)] - 
		1.;
	et += 1e7;
    }
    ++j;
    tick[(i__1 = j - 1) < 205 && 0 <= i__1 ? i__1 : s_rnge("tick", i__1, 
	    "tstckn_", (ftnlen)501)] = (maxet - zeropt) * 1e4;
    nticks = j;

/*     Sort the ticks. */

    shelld_(&nticks, tick);
    begtim = tick[0];
    endtim = tick[(i__1 = nticks - 1) < 205 && 0 <= i__1 ? i__1 : s_rnge(
	    "tick", i__1, "tstckn_", (ftnlen)510)];
    inst = -9999;
    s_copy(ref, "GALACTIC", (ftnlen)32, (ftnlen)8);
    avflg = FALSE_;
    s_copy(segid, "Test Segment for object -9999", (ftnlen)32, (ftnlen)29);
    i__1 = nticks;
    for (i__ = 1; i__ <= i__1; ++i__) {
	tk = tick[(i__2 = i__ - 1) < 205 && 0 <= i__2 ? i__2 : s_rnge("tick", 
		i__2, "tstckn_", (ftnlen)519)];
	et = zeropt + tk / 1e4;
	tstatd_(&et, rot, &angvel[(i__2 = i__ * 3 - 3) < 615 && 0 <= i__2 ? 
		i__2 : s_rnge("angvel", i__2, "tstckn_", (ftnlen)521)]);
	m2q_(rot, &quatrn[(i__2 = (i__ << 2) - 4) < 820 && 0 <= i__2 ? i__2 : 
		s_rnge("quatrn", i__2, "tstckn_", (ftnlen)522)]);
    }
    nints = 1;
    starts[0] = 0.;
    spcopn_(cknm, "Test C-kernel", handle, cknm_len, (ftnlen)13);
    ckw03_(handle, &begtim, &endtim, &inst, ref, &avflg, segid, &nticks, tick,
	     quatrn, angvel, &nints, starts, (ftnlen)32, (ftnlen)32);

/*     Now create a second segment by simply taking that attitude */
/*     10 million seconds later than those for body -9999 */

    begtim = tick[0];
    endtim = tick[(i__1 = nticks - 1) < 205 && 0 <= i__1 ? i__1 : s_rnge(
	    "tick", i__1, "tstckn_", (ftnlen)539)];
    inst = -10000;
    s_copy(ref, "FK4", (ftnlen)32, (ftnlen)3);
    avflg = FALSE_;
    s_copy(segid, "Object -10000", (ftnlen)32, (ftnlen)13);
    i__1 = nticks;
    for (i__ = 1; i__ <= i__1; ++i__) {
	tk = tick[(i__2 = i__ - 1) < 205 && 0 <= i__2 ? i__2 : s_rnge("tick", 
		i__2, "tstckn_", (ftnlen)548)];
	et = zeropt + tk / 1e4;
	tstatd_(&et, rot, &angvel[(i__2 = i__ * 3 - 3) < 615 && 0 <= i__2 ? 
		i__2 : s_rnge("angvel", i__2, "tstckn_", (ftnlen)550)]);
	m2q_(rot, &quatrn[(i__2 = (i__ << 2) - 4) < 820 && 0 <= i__2 ? i__2 : 
		s_rnge("quatrn", i__2, "tstckn_", (ftnlen)551)]);
    }
    nints = 1;
    starts[0] = 0.;
    ckw03_(handle, &begtim, &endtim, &inst, ref, &avflg, segid, &nticks, tick,
	     quatrn, angvel, &nints, starts, (ftnlen)32, (ftnlen)32);

/*     Finally for the third segment take take the same attitudes */
/*     but 100 million seconds later than those for object -9999 */

    begtim = tick[0];
    endtim = tick[(i__1 = nticks - 1) < 205 && 0 <= i__1 ? i__1 : s_rnge(
	    "tick", i__1, "tstckn_", (ftnlen)568)];
    inst = -10001;
    s_copy(ref, "J2000", (ftnlen)32, (ftnlen)5);
    avflg = FALSE_;
    s_copy(segid, "Test Segment for object -10001", (ftnlen)32, (ftnlen)30);
    i__1 = nticks;
    for (i__ = 1; i__ <= i__1; ++i__) {
	tk = tick[(i__2 = i__ - 1) < 205 && 0 <= i__2 ? i__2 : s_rnge("tick", 
		i__2, "tstckn_", (ftnlen)577)];
	et = zeropt + tk / 1e4;
	tstatd_(&et, rot, &angvel[(i__2 = i__ * 3 - 3) < 615 && 0 <= i__2 ? 
		i__2 : s_rnge("angvel", i__2, "tstckn_", (ftnlen)579)]);
	m2q_(rot, &quatrn[(i__2 = (i__ << 2) - 4) < 820 && 0 <= i__2 ? i__2 : 
		s_rnge("quatrn", i__2, "tstckn_", (ftnlen)580)]);
    }
    nints = 1;
    starts[0] = 0.;
    ckw03_(handle, &begtim, &endtim, &inst, ref, &avflg, segid, &nticks, tick,
	     quatrn, angvel, &nints, starts, (ftnlen)32, (ftnlen)32);
    dafcls_(handle);

/*     Now take care of loading the test kernels if they are needed. */

    if (*loadsc) {
	ldpool_(sclknm, sclknm_len);
	if (! (*keepsc)) {
	    kilfil_(sclknm, sclknm_len);
	}
    }
    if (*loadck) {
	cklpf_(cknm, handle, cknm_len);
    }
    tfiles_(cknm, cknm_len);
    tfiles_(sclknm, sclknm_len);
    return 0;
} /* tstckn_ */

