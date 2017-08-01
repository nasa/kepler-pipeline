/* f_tparse.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static doublereal c_b40 = 0.;

/* $Procedure      F_TPARSE ( Family of tests for TPARSE ) */
/* Subroutine */ int f_tparse__(logical *ok)
{
    /* System generated locals */
    integer i__1;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    doublereal sp2000;
    integer i__;
    extern /* Subroutine */ int tcase_(char *, ftnlen), topen_(char *, ftnlen)
	    ;
    char error[80];
    extern /* Subroutine */ int t_success__(logical *), chcksc_(char *, char *
	    , char *, char *, logical *, ftnlen, ftnlen, ftnlen, ftnlen), 
	    chcksd_(char *, doublereal *, char *, doublereal *, doublereal *, 
	    logical *, ftnlen, ftnlen), chckxc_(logical *, char *, logical *, 
	    ftnlen), tparch_(char *, ftnlen);
    doublereal expdet[23];
    extern /* Subroutine */ int tparse_(char *, doublereal *, char *, ftnlen, 
	    ftnlen);
    char tstrng[80*23];
    extern /* Subroutine */ int tstmsg_(char *, char *, ftnlen, ftnlen), 
	    tstmsi_(integer *);

/* $ Abstract */

/*     This routine tests the routine TPARSE.  This test is aimed */
/*     primarily at verifying that the routine has not changed */
/*     the SP2000 values that it returns from previous editions */
/*     of the toolkit. */
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

    topen_("F_TPARSE", (ftnlen)8);
    tcase_("Check to make a standard list of strings map to the expected ET'"
	    "s ", (ftnlen)66);
    tparch_("NO", (ftnlen)2);
    s_copy(tstrng, "1/9/1986 3:12:59.2", (ftnlen)80, (ftnlen)18);
    expdet[0] = -441103620.8;
    s_copy(tstrng + 80, "9 JAN 1986 03:12:59.2", (ftnlen)80, (ftnlen)21);
    expdet[1] = -441103620.8;
    s_copy(tstrng + 160, "1 9 1986 3:12:59.2", (ftnlen)80, (ftnlen)18);
    expdet[2] = -441103620.8;
    s_copy(tstrng + 240, "9 JAN 1986 03:12:59.2", (ftnlen)80, (ftnlen)21);
    expdet[3] = -441103620.8;
    s_copy(tstrng + 320, "2 jan 1991 3:00:12.2", (ftnlen)80, (ftnlen)20);
    expdet[4] = -283942787.8;
    s_copy(tstrng + 400, "2 JAN 1991 03:00:12.2", (ftnlen)80, (ftnlen)21);
    expdet[5] = -283942787.8;
    s_copy(tstrng + 480, "1991 MAR 10 12:00:00", (ftnlen)80, (ftnlen)20);
    expdet[6] = -278121600.;
    s_copy(tstrng + 560, "10 MAR 1991 12:00:00", (ftnlen)80, (ftnlen)20);
    expdet[7] = -278121600.;
    s_copy(tstrng + 640, "29 February 1975 3:00", (ftnlen)80, (ftnlen)21);
    expdet[8] = -783853200.;
    s_copy(tstrng + 720, "1 MAR 1975 03:00:00", (ftnlen)80, (ftnlen)19);
    expdet[9] = -783853200.;
    s_copy(tstrng + 800, "2010 October 29 3:58", (ftnlen)80, (ftnlen)20);
    expdet[10] = 341596680.;
    s_copy(tstrng + 880, "29 OCT 2010 03:58:00", (ftnlen)80, (ftnlen)20);
    expdet[11] = 341596680.;
    s_copy(tstrng + 960, "dec 31 86 12", (ftnlen)80, (ftnlen)12);
    expdet[12] = -410313600.;
    s_copy(tstrng + 1040, "31 DEC 1986 12:00:00", (ftnlen)80, (ftnlen)20);
    expdet[13] = -410313600.;
    s_copy(tstrng + 1120, "86-365 // 12:00", (ftnlen)80, (ftnlen)15);
    expdet[14] = -410313600.;
    s_copy(tstrng + 1200, "31 DEC 1986 12:00:00", (ftnlen)80, (ftnlen)20);
    expdet[15] = -410313600.;
    s_copy(tstrng + 1280, "JD 2451545.", (ftnlen)80, (ftnlen)11);
    expdet[16] = 0.;
    s_copy(tstrng + 1360, "1 JAN 2000 12:00:00", (ftnlen)80, (ftnlen)19);
    expdet[17] = 0.;
    s_copy(tstrng + 1440, "jd 2451545.", (ftnlen)80, (ftnlen)11);
    expdet[18] = 0.;
    s_copy(tstrng + 1520, "1 JAN 2000 12:00:00", (ftnlen)80, (ftnlen)19);
    expdet[19] = 0.;
    s_copy(tstrng + 1600, "JD2451545.", (ftnlen)80, (ftnlen)10);
    expdet[20] = 0.;
    s_copy(tstrng + 1680, "1 JAN 2000 12:00:00", (ftnlen)80, (ftnlen)19);
    expdet[21] = 0.;
    s_copy(tstrng + 1760, "321 B.C. MAR 15 12:00:00", (ftnlen)80, (ftnlen)24);
    expdet[22] = -73205683200.;
    s_copy(error, " ", (ftnlen)80, (ftnlen)1);
    for (i__ = 1; i__ <= 23; ++i__) {
	tstmsg_("#", "Test subcase #.", (ftnlen)1, (ftnlen)15);
	tstmsi_(&i__);
	tparse_(tstrng + ((i__1 = i__ - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge(
		"tstrng", i__1, "f_tparse__", (ftnlen)153)) * 80, &sp2000, 
		error, (ftnlen)80, (ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksc_("ERROR", error, "=", " ", ok, (ftnlen)5, (ftnlen)80, (ftnlen)
		1, (ftnlen)1);
	chcksd_("SP2000", &sp2000, "=", &expdet[(i__1 = i__ - 1) < 23 && 0 <= 
		i__1 ? i__1 : s_rnge("expdet", i__1, "f_tparse__", (ftnlen)
		156)], &c_b40, ok, (ftnlen)6, (ftnlen)1);
    }
    t_success__(ok);
    return 0;
} /* f_tparse__ */

