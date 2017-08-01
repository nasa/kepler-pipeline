/* tstlsk.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__29 = 29;
static logical c_true = TRUE_;
static logical c_false = FALSE_;

/* $Procedure      TSTLSK ( Test Leapseconds Kernel ) */
/* Subroutine */ int tstlsk_(void)
{
    /* System generated locals */
    char ch__1[32];

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    char file[80], text[80*29];
    extern /* Character */ VOID begdat_(char *, ftnlen);
    extern /* Subroutine */ int tsttxt_(char *, char *, integer *, logical *, 
	    logical *, ftnlen, ftnlen), newfil_1__(char *, char *, ftnlen, 
	    ftnlen);

/* $ Abstract */

/*    This test utility routine creates a leapsecond kernel */
/*    (valid as of July 1, 1997) loads the file into the */
/*    kernel pool, and then deletes the resulting file. */

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

/*     TEST UTILITIES */

/* $ Declarations */
/* $ Brief_I/O */

/*     None. */

/* $ Detailed_Input */

/*     None. */

/* $ Detailed_Output */

/*     None. */

/* $ Parameters */

/*     None. */

/* $ Files */

/*     A leapseconds kernel is created, loaded into the kernel pool */
/*     and then deleted. */

/* $ Exceptions */

/*     Error free. */

/* $ Particulars */

/*     This routine creates a temporary file based on the file */
/*     naming pattern (see NEWFIL_1 in support for details) */

/*         lsk{0-9}{0-9}{0-9}{0-9}.tmp */

/*     The resulting file is loaded into the kernel pool and */
/*     then deleted. */

/*     The fact that this file is created is logged in the */
/*     test log file. */

/* $ Examples */

/*     Suppose that you are testing some portion of the toolkit */
/*     that requires the use of a leapseconds kernel.  This routine */
/*     allows you to load a leapseconds kernel without having to */
/*     know where a current leapsecond kernel is located on the */
/*     file system. */

/*        CALL TSTLSK */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     W.L. Taber      (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    SPICELIB Version 1.0.0, 1-JUL-1997 (WLT) */


/* -& */
/* $ Index_Entries */

/*     Generate and load a leapseconds kernel for testing. */

/* -& */
    begdat_(ch__1, (ftnlen)32);
    s_copy(text, ch__1, (ftnlen)80, (ftnlen)32);
    s_copy(text + 80, " ", (ftnlen)80, (ftnlen)1);
    s_copy(text + 160, "DELTET/DELTA_T_A       =   32.184", (ftnlen)80, (
	    ftnlen)33);
    s_copy(text + 240, "DELTET/K               =    1.657D-3", (ftnlen)80, (
	    ftnlen)36);
    s_copy(text + 320, "DELTET/EB              =    1.671D-2", (ftnlen)80, (
	    ftnlen)36);
    s_copy(text + 400, "DELTET/M               = (  6.239996D0   1.99096871D"
	    "-7 )", (ftnlen)80, (ftnlen)56);
    s_copy(text + 480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(text + 560, "DELTET/DELTA_AT        = ( 10,   @1972-JAN-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(text + 640, "                           11,   @1972-JUL-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(text + 720, "                           12,   @1973-JAN-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(text + 800, "                           13,   @1974-JAN-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(text + 880, "                           14,   @1975-JAN-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(text + 960, "                           15,   @1976-JAN-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(text + 1040, "                           16,   @1977-JAN-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(text + 1120, "                           17,   @1978-JAN-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(text + 1200, "                           18,   @1979-JAN-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(text + 1280, "                           19,   @1980-JAN-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(text + 1360, "                           20,   @1981-JUL-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(text + 1440, "                           21,   @1982-JUL-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(text + 1520, "                           22,   @1983-JUL-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(text + 1600, "                           23,   @1985-JUL-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(text + 1680, "                           24,   @1988-JAN-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(text + 1760, "                           25,   @1990-JAN-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(text + 1840, "                           26,   @1991-JAN-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(text + 1920, "                           27,   @1992-JUL-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(text + 2000, "                           28,   @1993-JUL-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(text + 2080, "                           29,   @1994-JUL-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(text + 2160, "                           30,   @1996-JAN-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(text + 2240, "                           31,   @1997-JUL-1 )", (
	    ftnlen)80, (ftnlen)46);
    newfil_1__("lsk{0-9}{0-9}{0-9}{0-9}.tmp", file, (ftnlen)27, (ftnlen)80);
    tsttxt_(file, text, &c__29, &c_true, &c_false, (ftnlen)80, (ftnlen)80);
    return 0;
} /* tstlsk_ */

