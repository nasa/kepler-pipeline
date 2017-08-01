/* f_getfv2.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__478 = 478;
static integer c_b483 = -10000;
static integer c__10 = 10;
static logical c_true = TRUE_;
static integer c_b488 = -11000;
static integer c_b493 = -12000;
static integer c_b498 = -12500;
static integer c_b503 = -13000;
static integer c_b507 = -14000;
static integer c_b512 = -15000;
static integer c_b517 = -16000;
static integer c__4 = 4;
static integer c_b522 = -17000;
static integer c_b527 = -18100;
static integer c_b531 = -18200;
static integer c_b535 = -18300;
static integer c_b539 = -18400;
static integer c_b546 = -20000;
static logical c_false = FALSE_;
static integer c__3 = 3;
static doublereal c_b557 = 1e-15;
static integer c__0 = 0;
static integer c_b573 = -20100;
static integer c_b600 = -20200;
static integer c_b627 = -21000;
static integer c_b654 = -21100;
static integer c_b681 = -21200;
static integer c_b708 = -22000;
static integer c_b735 = -22100;
static integer c_b762 = -22200;
static integer c_b789 = -23000;
static integer c_b816 = -23100;
static integer c_b843 = -23200;
static integer c_b870 = -30000;
static integer c_b897 = -30100;
static integer c_b924 = -30200;
static integer c_b951 = -31000;
static integer c_b978 = -31100;
static integer c_b1005 = -31200;
static integer c_b1032 = -32000;
static integer c_b1059 = -32100;
static integer c_b1086 = -32200;
static integer c_b1113 = -33000;
static integer c_b1140 = -33100;
static integer c_b1167 = -33200;
static integer c_b1192 = -40000;
static integer c_b1197 = -40100;
static integer c_b1202 = -41000;
static integer c_b1207 = -41100;
static integer c_b1211 = -41200;
static integer c_b1215 = -41300;
static integer c_b1220 = -42000;
static integer c_b1225 = -43000;
static integer c_b1230 = -44000;
static integer c_b1235 = -45000;
static integer c_b1240 = -45100;
static integer c_b1245 = -46000;
static integer c_b1250 = -46100;
static integer c_b1255 = -46200;
static integer c_b1343 = -46201;
static integer c_b1370 = -46202;

/* $Procedure F_GETFV2 ( GETFOV Test Family ) */
/* Subroutine */ int f_getfv2__(logical *ok)
{
    /* System generated locals */
    integer i__1, i__2, i__3;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);
    double sqrt(doublereal);

    /* Local variables */
    integer i__, n;
    char frame[81];
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    char shape[81];
    extern /* Subroutine */ int repmi_(char *, char *, integer *, char *, 
	    ftnlen, ftnlen, ftnlen), topen_(char *, ftnlen), t_success__(
	    logical *), chckad_(char *, doublereal *, char *, doublereal *, 
	    integer *, doublereal *, logical *, ftnlen, ftnlen), chcksc_(char 
	    *, char *, char *, char *, logical *, ftnlen, ftnlen, ftnlen, 
	    ftnlen);
    char bndnam[81], ckfram[81];
    doublereal ckbnds[30]	/* was [3][10] */;
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     chcksi_(char *, integer *, char *, integer *, integer *, logical 
	    *, ftnlen, ftnlen);
    char ckshap[81];
    doublereal ckbsgt[3], bsight[3];
    char kbpool[81*478];
    extern /* Subroutine */ int clpool_(void);
    doublereal bounds[30]	/* was [3][10] */;
    extern /* Subroutine */ int getfov_(integer *, integer *, char *, char *, 
	    doublereal *, integer *, doublereal *, ftnlen, ftnlen), lmpool_(
	    char *, integer *, ftnlen);
    integer ckn;

/* $ Abstract */

/*     Test family to exercise the logic and code in the GETFOV routine. */

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

/*     TEST FAMILY */

/* $ Declarations */
/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  -------------------------------------------------- */
/*     OK         O   logical indicating test status. */

/* $ Detailed_Input */

/*     None. */

/* $ Detailed_Output */

/*     OK         is a logical that indicates the test status to the */
/*                caller. */

/* $ Parameters */

/*     None. */

/* $ Files */

/*     None. */

/* $ Exceptions */

/*     This routine does not generate any errors. Routines in its */
/*     call tree may generate erros that are either intentional and */
/*     trapped or unintentional and need reporting.  The test family */
/*     utilities manage this. */

/* $ Particulars */

/*     This routine exercises GETFOV's logic.  This module exists, */
/*     because it was written unknowingly after a F_GETFOV had already */
/*     been delievered to CM. */

/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     F.S. Turner     (JPL) */
/*     B.V. Semenov    (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    TSPICE Version 1.1.0, 08-MAR-2005 (BVS) */

/*        Added tests with non-unit REFVEC and non-normal REFVEC and */
/*        BSIGHT. */

/* -    TSPICE Version 1.0.0, 19-APR-2001 (FST) */


/* -& */

/*     SPICELIB Functions */


/*     Local Parameters */


/*     Local Variables */


/*     Start the test family with an open call. */

    topen_("F_GETFV2", (ftnlen)8);

/*     Build the string buffer with the FOV definitions. */

    s_copy(kbpool, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 81, "INS-10000_FOV_SHAPE    = 'CIRCLE'", (ftnlen)81, (
	    ftnlen)33);
    s_copy(kbpool + 162, "INS-10000_BORESIGHT    = ( 1.0, 0.0, 0.0 )", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 243, "INS-10000_FOV_BOUNDARY = ( 0.0, 1.0, 0.0 )", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 324, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 405, "INS-11000_FOV_FRAME    = '11000-FRAME'", (ftnlen)81,
	     (ftnlen)38);
    s_copy(kbpool + 486, "INS-11000_FOV_SHAPE    = 'SPUD-SHAPED'", (ftnlen)81,
	     (ftnlen)38);
    s_copy(kbpool + 567, "INS-11000_BORESIGHT    = ( 1.0, 0.0, 0.0 )", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 648, "INS-11000_FOV_BOUNDARY = ( 0.0, 1.0, 0.0 )", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 729, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 810, "INS-12000_FOV_FRAME    = '12000-FRAME'", (ftnlen)81,
	     (ftnlen)38);
    s_copy(kbpool + 891, "INS-12000_BORESIGHT    = ( 1.0, 0.0, 0.0 )", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 972, "INS-12000_FOV_BOUNDARY = ( 0.0, 1.0, 0.0 )", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 1053, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 1134, "INS-12500_FOV_FRAME    = '12500-FRAME'", (ftnlen)
	    81, (ftnlen)38);
    s_copy(kbpool + 1215, "INS-12500_FOV_SHAPE    = 'CIRCLE'", (ftnlen)81, (
	    ftnlen)33);
    s_copy(kbpool + 1296, "INS-12500_FOV_BOUNDARY = ( 0.0, 1.0, 0.0 )", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 1377, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 1458, "INS-13000_FOV_FRAME    = '13000-FRAME'", (ftnlen)
	    81, (ftnlen)38);
    s_copy(kbpool + 1539, "INS-13000_FOV_SHAPE    = 'CIRCLE'", (ftnlen)81, (
	    ftnlen)33);
    s_copy(kbpool + 1620, "INS-13000_BORESIGHT    = ( 1.0, 0.0 )", (ftnlen)81,
	     (ftnlen)37);
    s_copy(kbpool + 1701, "INS-13000_FOV_BOUNDARY = ( 0.0, 1.0, 0.0 )", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 1782, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 1863, "INS-14000_FOV_FRAME    = '14000-FRAME'", (ftnlen)
	    81, (ftnlen)38);
    s_copy(kbpool + 1944, "INS-14000_FOV_SHAPE    = 'CIRCLE'", (ftnlen)81, (
	    ftnlen)33);
    s_copy(kbpool + 2025, "INS-14000_BORESIGHT    = ( 'A', 'B', 'C' )", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 2106, "INS-14000_FOV_BOUNDARY = ( 0.0, 1.0, 0.0 )", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 2187, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 2268, "INS-15000_FOV_FRAME    = '15000-FRAME'", (ftnlen)
	    81, (ftnlen)38);
    s_copy(kbpool + 2349, "INS-15000_FOV_SHAPE    = 'CIRCLE'", (ftnlen)81, (
	    ftnlen)33);
    s_copy(kbpool + 2430, "INS-15000_BORESIGHT    = ( 1.0, 0.0, 0.0 )", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 2511, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 2592, "INS-16000_FOV_FRAME    = '16000-FRAME'", (ftnlen)
	    81, (ftnlen)38);
    s_copy(kbpool + 2673, "INS-16000_FOV_SHAPE    = 'POLYGON'", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 2754, "INS-16000_BORESIGHT    = ( 1.0, 0.0, 0.0 )", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 2835, "INS-16000_FOV_BOUNDARY = (", (ftnlen)81, (ftnlen)
	    26);
    s_copy(kbpool + 2916, "                           0.0,  1.0,  0.0", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 2997, "                           0.0, -1.0,  0.0", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 3078, "                           0.0,  0.0,  1.0", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 3159, "                           0.0,  0.0, -1.0", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 3240, "                           1.0,  1.0,  1.0", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 3321, "                         )", (ftnlen)81, (ftnlen)
	    26);
    s_copy(kbpool + 3402, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 3483, "INS-17000_FOV_FRAME    = '17000-FRAME'", (ftnlen)
	    81, (ftnlen)38);
    s_copy(kbpool + 3564, "INS-17000_FOV_SHAPE    = 'CIRCLE'", (ftnlen)81, (
	    ftnlen)33);
    s_copy(kbpool + 3645, "INS-17000_BORESIGHT    = ( 1.0, 0.0, 0.0 )", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 3726, "INS-17000_FOV_BOUNDARY = ( 0.0, 1.0 )", (ftnlen)81,
	     (ftnlen)37);
    s_copy(kbpool + 3807, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 3888, "INS-18100_FOV_FRAME    = '18100-FRAME'", (ftnlen)
	    81, (ftnlen)38);
    s_copy(kbpool + 3969, "INS-18100_FOV_SHAPE    = 'CIRCLE'", (ftnlen)81, (
	    ftnlen)33);
    s_copy(kbpool + 4050, "INS-18100_BORESIGHT    = ( 0.0, 0.0, 1.0 )", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 4131, "INS-18100_FOV_BOUNDARY = (", (ftnlen)81, (ftnlen)
	    26);
    s_copy(kbpool + 4212, "                           1.0, 0.0, 1.0", (ftnlen)
	    81, (ftnlen)40);
    s_copy(kbpool + 4293, "                          -1.0, 0.0, 1.0", (ftnlen)
	    81, (ftnlen)40);
    s_copy(kbpool + 4374, "                         )", (ftnlen)81, (ftnlen)
	    26);
    s_copy(kbpool + 4455, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 4536, "INS-18200_FOV_FRAME    = '18200-FRAME'", (ftnlen)
	    81, (ftnlen)38);
    s_copy(kbpool + 4617, "INS-18200_FOV_SHAPE    = 'ELLIPSE'", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 4698, "INS-18200_BORESIGHT    = ( 0.0, 0.0, 1.0 )", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 4779, "INS-18200_FOV_BOUNDARY = (", (ftnlen)81, (ftnlen)
	    26);
    s_copy(kbpool + 4860, "                           1.0, 0.0, 1.0", (ftnlen)
	    81, (ftnlen)40);
    s_copy(kbpool + 4941, "                         )", (ftnlen)81, (ftnlen)
	    26);
    s_copy(kbpool + 5022, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 5103, "INS-18300_FOV_FRAME    = '18300-FRAME'", (ftnlen)
	    81, (ftnlen)38);
    s_copy(kbpool + 5184, "INS-18300_FOV_SHAPE    = 'RECTANGLE'", (ftnlen)81, 
	    (ftnlen)36);
    s_copy(kbpool + 5265, "INS-18300_BORESIGHT    = ( 0.0, 0.0, 1.0 )", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 5346, "INS-18300_FOV_BOUNDARY = (", (ftnlen)81, (ftnlen)
	    26);
    s_copy(kbpool + 5427, "                           1.0, 0.0, 1.0", (ftnlen)
	    81, (ftnlen)40);
    s_copy(kbpool + 5508, "                         )", (ftnlen)81, (ftnlen)
	    26);
    s_copy(kbpool + 5589, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 5670, "INS-18400_FOV_FRAME    = '18400-FRAME'", (ftnlen)
	    81, (ftnlen)38);
    s_copy(kbpool + 5751, "INS-18400_FOV_SHAPE    = 'POLYGON'", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 5832, "INS-18400_BORESIGHT    = ( 0.0, 0.0, 1.0 )", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 5913, "INS-18400_FOV_BOUNDARY = (", (ftnlen)81, (ftnlen)
	    26);
    s_copy(kbpool + 5994, "                           1.0, 0.0, 1.0", (ftnlen)
	    81, (ftnlen)40);
    s_copy(kbpool + 6075, "                         )", (ftnlen)81, (ftnlen)
	    26);
    s_copy(kbpool + 6156, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 6237, "INS-20000_FOV_FRAME    = '20000-FRAME'", (ftnlen)
	    81, (ftnlen)38);
    s_copy(kbpool + 6318, "INS-20000_FOV_SHAPE    = 'CIRCLE'", (ftnlen)81, (
	    ftnlen)33);
    s_copy(kbpool + 6399, "INS-20000_BORESIGHT    = ( 0.0, 0.0, 1.0 )", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 6480, "INS-20000_FOV_BOUNDARY = (", (ftnlen)81, (ftnlen)
	    26);
    s_copy(kbpool + 6561, "                           1.0, 0.0, 1.0", (ftnlen)
	    81, (ftnlen)40);
    s_copy(kbpool + 6642, "                         )", (ftnlen)81, (ftnlen)
	    26);
    s_copy(kbpool + 6723, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 6804, "INS-20100_FOV_FRAME            = '20100-FRAME'", (
	    ftnlen)81, (ftnlen)46);
    s_copy(kbpool + 6885, "INS-20100_FOV_SHAPE            = 'CIRCLE'", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 6966, "INS-20100_BORESIGHT            = ( 0.0, 0.0, 1.0 )"
	    , (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 7047, "INS-20100_FOV_BOUNDARY_CORNERS = (", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 7128, "                                   1.0, 0.0, 1.0", 
	    (ftnlen)81, (ftnlen)48);
    s_copy(kbpool + 7209, "                                 )", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 7290, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 7371, "INS-20200_FOV_FRAME            = '20200-FRAME'", (
	    ftnlen)81, (ftnlen)46);
    s_copy(kbpool + 7452, "INS-20200_FOV_SHAPE            = 'CIRCLE'", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 7533, "INS-20200_BORESIGHT            = ( 0.0, 0.0, 1.0 )"
	    , (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 7614, "INS-20200_FOV_BOUNDARY_CORNERS = (", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 7695, "                                   1.0, 0.0, 1.0", 
	    (ftnlen)81, (ftnlen)48);
    s_copy(kbpool + 7776, "                                 )", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 7857, "INS-20200_FOV_BOUNDARY         = (", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 7938, "                                   2.0, 0.0, 1.0", 
	    (ftnlen)81, (ftnlen)48);
    s_copy(kbpool + 8019, "                                 )", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 8100, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 8181, "INS-21000_FOV_FRAME    = '21000-FRAME'", (ftnlen)
	    81, (ftnlen)38);
    s_copy(kbpool + 8262, "INS-21000_FOV_SHAPE    = 'ELLIPSE'", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 8343, "INS-21000_BORESIGHT    = ( 0.0, 0.0, 1.0 )", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 8424, "INS-21000_FOV_BOUNDARY = (", (ftnlen)81, (ftnlen)
	    26);
    s_copy(kbpool + 8505, "                           1.0, 0.0, 1.0", (ftnlen)
	    81, (ftnlen)40);
    s_copy(kbpool + 8586, "                           0.0, 1.0, 1.0", (ftnlen)
	    81, (ftnlen)40);
    s_copy(kbpool + 8667, "                         )", (ftnlen)81, (ftnlen)
	    26);
    s_copy(kbpool + 8748, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 8829, "INS-21100_FOV_FRAME            = '21100-FRAME'", (
	    ftnlen)81, (ftnlen)46);
    s_copy(kbpool + 8910, "INS-21100_FOV_SHAPE            = 'ELLIPSE'", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 8991, "INS-21100_BORESIGHT            = ( 0.0, 0.0, 1.0 )"
	    , (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 9072, "INS-21100_FOV_BOUNDARY_CORNERS = (", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 9153, "                                   1.0, 0.0, 1.0", 
	    (ftnlen)81, (ftnlen)48);
    s_copy(kbpool + 9234, "                                   0.0, 1.0, 1.0", 
	    (ftnlen)81, (ftnlen)48);
    s_copy(kbpool + 9315, "                                 )", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 9396, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 9477, "INS-21200_FOV_FRAME            = '21200-FRAME'", (
	    ftnlen)81, (ftnlen)46);
    s_copy(kbpool + 9558, "INS-21200_FOV_SHAPE            = 'ELLIPSE'", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 9639, "INS-21200_BORESIGHT            = ( 0.0, 0.0, 1.0 )"
	    , (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 9720, "INS-21200_FOV_BOUNDARY_CORNERS = (", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 9801, "                                   1.0, 0.0, 1.0", 
	    (ftnlen)81, (ftnlen)48);
    s_copy(kbpool + 9882, "                                   0.0, 1.0, 1.0", 
	    (ftnlen)81, (ftnlen)48);
    s_copy(kbpool + 9963, "                                 )", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 10044, "INS-21200_FOV_BOUNDARY         = (", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 10125, "                                   2.0, 0.0, 1.0",
	     (ftnlen)81, (ftnlen)48);
    s_copy(kbpool + 10206, "                                   0.0, 2.0, 1.0",
	     (ftnlen)81, (ftnlen)48);
    s_copy(kbpool + 10287, "                                 )", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 10368, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 10449, "INS-22000_FOV_FRAME    = '22000-FRAME'", (ftnlen)
	    81, (ftnlen)38);
    s_copy(kbpool + 10530, "INS-22000_FOV_SHAPE    = 'RECTANGLE'", (ftnlen)81,
	     (ftnlen)36);
    s_copy(kbpool + 10611, "INS-22000_BORESIGHT    = ( 0.0, 0.0, 1.0 )", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 10692, "INS-22000_FOV_BOUNDARY = (", (ftnlen)81, (ftnlen)
	    26);
    s_copy(kbpool + 10773, "                            1.0,  1.0, 1.0", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 10854, "                            1.0, -1.0, 1.0", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 10935, "                           -1.0, -1.0, 1.0", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 11016, "                           -1.0,  1.0, 1.0", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 11097, "                         )", (ftnlen)81, (ftnlen)
	    26);
    s_copy(kbpool + 11178, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 11259, "INS-22100_FOV_FRAME            = '22100-FRAME'", (
	    ftnlen)81, (ftnlen)46);
    s_copy(kbpool + 11340, "INS-22100_FOV_SHAPE            = 'RECTANGLE'", (
	    ftnlen)81, (ftnlen)44);
    s_copy(kbpool + 11421, "INS-22100_BORESIGHT            = ( 0.0, 0.0, 1.0"
	    " )", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 11502, "INS-22100_FOV_BOUNDARY_CORNERS = (", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 11583, "                                    1.0,  1.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 11664, "                                    1.0, -1.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 11745, "                                   -1.0, -1.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 11826, "                                   -1.0,  1.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 11907, "                                 )", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 11988, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 12069, "INS-22200_FOV_FRAME            = '22200-FRAME'", (
	    ftnlen)81, (ftnlen)46);
    s_copy(kbpool + 12150, "INS-22200_FOV_SHAPE            = 'RECTANGLE'", (
	    ftnlen)81, (ftnlen)44);
    s_copy(kbpool + 12231, "INS-22200_BORESIGHT            = ( 0.0, 0.0, 1.0"
	    " )", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 12312, "INS-22200_FOV_BOUNDARY_CORNERS = (", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 12393, "                                    1.0,  1.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 12474, "                                    1.0, -1.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 12555, "                                   -1.0, -1.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 12636, "                                   -1.0,  1.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 12717, "                                 )", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 12798, "INS-22200_FOV_BOUNDARY         = (", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 12879, "                                    2.0,  2.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 12960, "                                    2.0, -2.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 13041, "                                   -2.0, -2.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 13122, "                                   -2.0,  2.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 13203, "                                 )", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 13284, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 13365, "INS-23000_FOV_FRAME    = '23000-FRAME'", (ftnlen)
	    81, (ftnlen)38);
    s_copy(kbpool + 13446, "INS-23000_FOV_SHAPE    = 'POLYGON'", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 13527, "INS-23000_BORESIGHT    = ( 0.0, 0.0, 1.0 )", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 13608, "INS-23000_FOV_BOUNDARY = (", (ftnlen)81, (ftnlen)
	    26);
    s_copy(kbpool + 13689, "                            1.0,  1.0, 1.0", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 13770, "                            1.0, -1.0, 1.0", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 13851, "                           -1.0, -1.0, 1.0", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 13932, "                           -1.0,  1.0, 1.0", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 14013, "                         )", (ftnlen)81, (ftnlen)
	    26);
    s_copy(kbpool + 14094, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 14175, "INS-23100_FOV_FRAME            = '23100-FRAME'", (
	    ftnlen)81, (ftnlen)46);
    s_copy(kbpool + 14256, "INS-23100_FOV_SHAPE            = 'POLYGON'", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 14337, "INS-23100_BORESIGHT            = ( 0.0, 0.0, 1.0"
	    " )", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 14418, "INS-23100_FOV_BOUNDARY_CORNERS = (", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 14499, "                                    1.0,  1.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 14580, "                                    1.0, -1.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 14661, "                                   -1.0, -1.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 14742, "                                   -1.0,  1.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 14823, "                                 )", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 14904, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 14985, "INS-23200_FOV_FRAME            = '23200-FRAME'", (
	    ftnlen)81, (ftnlen)46);
    s_copy(kbpool + 15066, "INS-23200_FOV_SHAPE            = 'POLYGON'", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 15147, "INS-23200_BORESIGHT            = ( 0.0, 0.0, 1.0"
	    " )", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 15228, "INS-23200_FOV_BOUNDARY_CORNERS = (", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 15309, "                                    1.0,  1.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 15390, "                                    1.0, -1.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 15471, "                                   -1.0, -1.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 15552, "                                   -1.0,  1.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 15633, "                                 )", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 15714, "INS-23200_FOV_BOUNDARY         = (", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 15795, "                                    2.0,  2.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 15876, "                                    2.0, -2.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 15957, "                                   -2.0, -2.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 16038, "                                   -2.0,  2.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 16119, "                                 )", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 16200, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 16281, "INS-30000_FOV_FRAME    = '30000-FRAME'", (ftnlen)
	    81, (ftnlen)38);
    s_copy(kbpool + 16362, "INS-30000_FOV_SHAPE    = 'CIRCLE'", (ftnlen)81, (
	    ftnlen)33);
    s_copy(kbpool + 16443, "INS-30000_BORESIGHT    = ( 0.0, 0.0, 1.0 )", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 16524, "INS-30000_FOV_CLASS_SPEC       = 'CORNERS'", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 16605, "INS-30000_FOV_BOUNDARY = (", (ftnlen)81, (ftnlen)
	    26);
    s_copy(kbpool + 16686, "                           1.0, 0.0, 1.0", (
	    ftnlen)81, (ftnlen)40);
    s_copy(kbpool + 16767, "                         )", (ftnlen)81, (ftnlen)
	    26);
    s_copy(kbpool + 16848, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 16929, "INS-30100_FOV_FRAME            = '30100-FRAME'", (
	    ftnlen)81, (ftnlen)46);
    s_copy(kbpool + 17010, "INS-30100_FOV_SHAPE            = 'CIRCLE'", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 17091, "INS-30100_BORESIGHT            = ( 0.0, 0.0, 1.0"
	    " )", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 17172, "INS-30100_FOV_CLASS_SPEC       = 'CORNERS'", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 17253, "INS-30100_FOV_BOUNDARY_CORNERS = (", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 17334, "                                   1.0, 0.0, 1.0",
	     (ftnlen)81, (ftnlen)48);
    s_copy(kbpool + 17415, "                                 )", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 17496, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 17577, "INS-30200_FOV_FRAME            = '30200-FRAME'", (
	    ftnlen)81, (ftnlen)46);
    s_copy(kbpool + 17658, "INS-30200_FOV_SHAPE            = 'CIRCLE'", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 17739, "INS-30200_BORESIGHT            = ( 0.0, 0.0, 1.0"
	    " )", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 17820, "INS-30200_FOV_CLASS_SPEC       = 'CORNERS'", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 17901, "INS-30200_FOV_BOUNDARY_CORNERS = (", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 17982, "                                   1.0, 0.0, 1.0",
	     (ftnlen)81, (ftnlen)48);
    s_copy(kbpool + 18063, "                                 )", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 18144, "INS-30200_FOV_BOUNDARY         = (", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 18225, "                                   2.0, 0.0, 1.0",
	     (ftnlen)81, (ftnlen)48);
    s_copy(kbpool + 18306, "                                 )", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 18387, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 18468, "INS-31000_FOV_FRAME    = '31000-FRAME'", (ftnlen)
	    81, (ftnlen)38);
    s_copy(kbpool + 18549, "INS-31000_FOV_SHAPE    = 'ELLIPSE'", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 18630, "INS-31000_BORESIGHT    = ( 0.0, 0.0, 1.0 )", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 18711, "INS-31000_FOV_CLASS_SPEC       = 'CORNERS'", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 18792, "INS-31000_FOV_BOUNDARY = (", (ftnlen)81, (ftnlen)
	    26);
    s_copy(kbpool + 18873, "                           1.0, 0.0, 1.0", (
	    ftnlen)81, (ftnlen)40);
    s_copy(kbpool + 18954, "                           0.0, 1.0, 1.0", (
	    ftnlen)81, (ftnlen)40);
    s_copy(kbpool + 19035, "                         )", (ftnlen)81, (ftnlen)
	    26);
    s_copy(kbpool + 19116, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 19197, "INS-31100_FOV_FRAME            = '31100-FRAME'", (
	    ftnlen)81, (ftnlen)46);
    s_copy(kbpool + 19278, "INS-31100_FOV_SHAPE            = 'ELLIPSE'", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 19359, "INS-31100_BORESIGHT            = ( 0.0, 0.0, 1.0"
	    " )", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 19440, "INS-31100_FOV_CLASS_SPEC       = 'CORNERS'", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 19521, "INS-31100_FOV_BOUNDARY_CORNERS = (", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 19602, "                                   1.0, 0.0, 1.0",
	     (ftnlen)81, (ftnlen)48);
    s_copy(kbpool + 19683, "                                   0.0, 1.0, 1.0",
	     (ftnlen)81, (ftnlen)48);
    s_copy(kbpool + 19764, "                                 )", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 19845, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 19926, "INS-31200_FOV_FRAME            = '31200-FRAME'", (
	    ftnlen)81, (ftnlen)46);
    s_copy(kbpool + 20007, "INS-31200_FOV_SHAPE            = 'ELLIPSE'", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 20088, "INS-31200_BORESIGHT            = ( 0.0, 0.0, 1.0"
	    " )", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 20169, "INS-31200_FOV_CLASS_SPEC       = 'CORNERS'", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 20250, "INS-31200_FOV_BOUNDARY_CORNERS = (", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 20331, "                                   1.0, 0.0, 1.0",
	     (ftnlen)81, (ftnlen)48);
    s_copy(kbpool + 20412, "                                   0.0, 1.0, 1.0",
	     (ftnlen)81, (ftnlen)48);
    s_copy(kbpool + 20493, "                                 )", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 20574, "INS-31200_FOV_BOUNDARY         = (", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 20655, "                                   2.0, 0.0, 1.0",
	     (ftnlen)81, (ftnlen)48);
    s_copy(kbpool + 20736, "                                   0.0, 2.0, 1.0",
	     (ftnlen)81, (ftnlen)48);
    s_copy(kbpool + 20817, "                                 )", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 20898, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 20979, "INS-32000_FOV_FRAME    = '32000-FRAME'", (ftnlen)
	    81, (ftnlen)38);
    s_copy(kbpool + 21060, "INS-32000_FOV_SHAPE    = 'RECTANGLE'", (ftnlen)81,
	     (ftnlen)36);
    s_copy(kbpool + 21141, "INS-32000_BORESIGHT    = ( 0.0, 0.0, 1.0 )", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 21222, "INS-32000_FOV_CLASS_SPEC       = 'CORNERS'", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 21303, "INS-32000_FOV_BOUNDARY = (", (ftnlen)81, (ftnlen)
	    26);
    s_copy(kbpool + 21384, "                            1.0,  1.0, 1.0", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 21465, "                            1.0, -1.0, 1.0", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 21546, "                           -1.0, -1.0, 1.0", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 21627, "                           -1.0,  1.0, 1.0", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 21708, "                         )", (ftnlen)81, (ftnlen)
	    26);
    s_copy(kbpool + 21789, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 21870, "INS-32100_FOV_FRAME            = '32100-FRAME'", (
	    ftnlen)81, (ftnlen)46);
    s_copy(kbpool + 21951, "INS-32100_FOV_SHAPE            = 'RECTANGLE'", (
	    ftnlen)81, (ftnlen)44);
    s_copy(kbpool + 22032, "INS-32100_BORESIGHT            = ( 0.0, 0.0, 1.0"
	    " )", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 22113, "INS-32100_FOV_CLASS_SPEC       = 'CORNERS'", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 22194, "INS-32100_FOV_BOUNDARY_CORNERS = (", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 22275, "                                    1.0,  1.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 22356, "                                    1.0, -1.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 22437, "                                   -1.0, -1.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 22518, "                                   -1.0,  1.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 22599, "                                 )", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 22680, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 22761, "INS-32200_FOV_FRAME            = '32200-FRAME'", (
	    ftnlen)81, (ftnlen)46);
    s_copy(kbpool + 22842, "INS-32200_FOV_SHAPE            = 'RECTANGLE'", (
	    ftnlen)81, (ftnlen)44);
    s_copy(kbpool + 22923, "INS-32200_BORESIGHT            = ( 0.0, 0.0, 1.0"
	    " )", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 23004, "INS-32200_FOV_CLASS_SPEC       = 'CORNERS'", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 23085, "INS-32200_FOV_BOUNDARY_CORNERS = (", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 23166, "                                    1.0,  1.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 23247, "                                    1.0, -1.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 23328, "                                   -1.0, -1.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 23409, "                                   -1.0,  1.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 23490, "                                 )", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 23571, "INS-32200_FOV_BOUNDARY         = (", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 23652, "                                    2.0,  2.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 23733, "                                    2.0, -2.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 23814, "                                   -2.0, -2.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 23895, "                                   -2.0,  2.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 23976, "                                 )", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 24057, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 24138, "INS-33000_FOV_FRAME    = '33000-FRAME'", (ftnlen)
	    81, (ftnlen)38);
    s_copy(kbpool + 24219, "INS-33000_FOV_SHAPE    = 'POLYGON'", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 24300, "INS-33000_BORESIGHT    = ( 0.0, 0.0, 1.0 )", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 24381, "INS-33000_FOV_CLASS_SPEC       = 'CORNERS'", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 24462, "INS-33000_FOV_BOUNDARY = (", (ftnlen)81, (ftnlen)
	    26);
    s_copy(kbpool + 24543, "                            1.0,  1.0, 1.0", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 24624, "                            1.0, -1.0, 1.0", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 24705, "                           -1.0, -1.0, 1.0", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 24786, "                           -1.0,  1.0, 1.0", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 24867, "                         )", (ftnlen)81, (ftnlen)
	    26);
    s_copy(kbpool + 24948, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 25029, "INS-33100_FOV_FRAME            = '33100-FRAME'", (
	    ftnlen)81, (ftnlen)46);
    s_copy(kbpool + 25110, "INS-33100_FOV_SHAPE            = 'POLYGON'", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 25191, "INS-33100_BORESIGHT            = ( 0.0, 0.0, 1.0"
	    " )", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 25272, "INS-33100_FOV_CLASS_SPEC       = 'CORNERS'", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 25353, "INS-33100_FOV_BOUNDARY_CORNERS = (", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 25434, "                                    1.0,  1.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 25515, "                                    1.0, -1.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 25596, "                                   -1.0, -1.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 25677, "                                   -1.0,  1.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 25758, "                                 )", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 25839, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 25920, "INS-33200_FOV_FRAME            = '33200-FRAME'", (
	    ftnlen)81, (ftnlen)46);
    s_copy(kbpool + 26001, "INS-33200_FOV_SHAPE            = 'POLYGON'", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 26082, "INS-33200_BORESIGHT            = ( 0.0, 0.0, 1.0"
	    " )", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 26163, "INS-33200_FOV_CLASS_SPEC       = 'CORNERS'", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 26244, "INS-33200_FOV_BOUNDARY_CORNERS = (", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 26325, "                                    1.0,  1.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 26406, "                                    1.0, -1.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 26487, "                                   -1.0, -1.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 26568, "                                   -1.0,  1.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 26649, "                                 )", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 26730, "INS-33200_FOV_BOUNDARY         = (", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 26811, "                                    2.0,  2.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 26892, "                                    2.0, -2.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 26973, "                                   -2.0, -2.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 27054, "                                   -2.0,  2.0, 1"
	    ".0", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 27135, "                                 )", (ftnlen)81, (
	    ftnlen)34);
    s_copy(kbpool + 27216, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 27297, "INS-40000_FOV_FRAME            = '40000-FRAME'", (
	    ftnlen)81, (ftnlen)46);
    s_copy(kbpool + 27378, "INS-40000_FOV_SHAPE            = 'BOGUS-SHAPE'", (
	    ftnlen)81, (ftnlen)46);
    s_copy(kbpool + 27459, "INS-40000_BORESIGHT            = ( 0.0, 0.0, 1.0"
	    " )", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 27540, "INS-40000_FOV_CLASS_SPEC       = 'ANGLES'", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 27621, "INS-40000_FOV_REF_VECTOR       = ( 1.0, 0.0, 0.0"
	    " )", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 27702, "INS-40000_FOV_REF_ANGLE        = ( 20.0 )", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 27783, "INS-40000_FOV_CROSS_ANGLE      = ( 40.0 )", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 27864, "INS-40000_FOV_ANGLE_UNITS      = 'DEGREES'", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 27945, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 28026, "INS-40100_FOV_FRAME            = '40100-FRAME'", (
	    ftnlen)81, (ftnlen)46);
    s_copy(kbpool + 28107, "INS-40100_FOV_SHAPE            = 'CIRCLE'", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 28188, "INS-40100_BORESIGHT            = ( 0.0, 0.0, 1.0"
	    " )", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 28269, "INS-40100_FOV_CLASS_SPEC       = 'BOGUS-SPEC'", (
	    ftnlen)81, (ftnlen)45);
    s_copy(kbpool + 28350, "INS-40100_FOV_REF_VECTOR       = ( 1.0, 0.0, 0.0"
	    " )", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 28431, "INS-40100_FOV_REF_ANGLE        = ( 20.0 )", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 28512, "INS-40100_FOV_CROSS_ANGLE      = ( 40.0 )", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 28593, "INS-40100_FOV_ANGLE_UNITS      = 'DEGREES'", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 28674, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 28755, "INS-41000_FOV_FRAME            = '41000-FRAME'", (
	    ftnlen)81, (ftnlen)46);
    s_copy(kbpool + 28836, "INS-41000_FOV_SHAPE            = 'ELLIPSE'", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 28917, "INS-41000_BORESIGHT            = ( 0.0, 0.0, 1.0"
	    " )", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 28998, "INS-41000_FOV_CLASS_SPEC       = 'ANGLES'", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 29079, "INS-41000_FOV_REF_ANGLE        = ( 20.0 )", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 29160, "INS-41000_FOV_CROSS_ANGLE      = ( 40.0 )", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 29241, "INS-41000_FOV_ANGLE_UNITS      = 'DEGREES'", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 29322, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 29403, "INS-41100_FOV_FRAME            = '41100-FRAME'", (
	    ftnlen)81, (ftnlen)46);
    s_copy(kbpool + 29484, "INS-41100_FOV_SHAPE            = 'ELLIPSE'", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 29565, "INS-41100_BORESIGHT            = ( 0.0, 0.0, 1.0"
	    " )", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 29646, "INS-41100_FOV_CLASS_SPEC       = 'ANGLES'", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 29727, "INS-41100_FOV_REF_VECTOR       = ( 0.0, 0.1 )", (
	    ftnlen)81, (ftnlen)45);
    s_copy(kbpool + 29808, "INS-41100_FOV_REF_ANGLE        = ( 20.0 )", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 29889, "INS-41100_FOV_CROSS_ANGLE      = ( 40.0 )", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 29970, "INS-41100_FOV_ANGLE_UNITS      = 'DEGREES'", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 30051, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 30132, "INS-41200_FOV_FRAME            = '41200-FRAME'", (
	    ftnlen)81, (ftnlen)46);
    s_copy(kbpool + 30213, "INS-41200_FOV_SHAPE            = 'ELLIPSE'", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 30294, "INS-41200_BORESIGHT            = ( 0.0, 0.0, 1.0"
	    " )", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 30375, "INS-41200_FOV_CLASS_SPEC       = 'ANGLES'", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 30456, "INS-41200_FOV_REF_VECTOR       = ( 'A', 'B', 'C'"
	    " )", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 30537, "INS-41200_FOV_REF_ANGLE        = ( 20.0 )", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 30618, "INS-41200_FOV_CROSS_ANGLE      = ( 40.0 )", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 30699, "INS-41200_FOV_ANGLE_UNITS      = 'DEGREES'", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 30780, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 30861, "INS-41300_FOV_FRAME            = '41300-FRAME'", (
	    ftnlen)81, (ftnlen)46);
    s_copy(kbpool + 30942, "INS-41300_FOV_SHAPE            = 'ELLIPSE'", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 31023, "INS-41300_BORESIGHT            = ( 0.0, 0.0, 1.0"
	    " )", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 31104, "INS-41300_FOV_CLASS_SPEC       = 'ANGLES'", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 31185, "INS-41300_FOV_REF_VECTOR       = ( 0.0, 0.0, 1.0"
	    " )", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 31266, "INS-41300_FOV_REF_ANGLE        = ( 20.0 )", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 31347, "INS-41300_FOV_CROSS_ANGLE      = ( 40.0 )", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 31428, "INS-41300_FOV_ANGLE_UNITS      = 'DEGREES'", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 31509, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 31590, "INS-42000_FOV_FRAME            = '42000-FRAME'", (
	    ftnlen)81, (ftnlen)46);
    s_copy(kbpool + 31671, "INS-42000_FOV_SHAPE            = 'ELLIPSE'", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 31752, "INS-42000_BORESIGHT            = ( 0.0, 0.0, 1.0"
	    " )", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 31833, "INS-42000_FOV_CLASS_SPEC       = 'ANGLES'", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 31914, "INS-42000_FOV_REF_VECTOR       = ( 0.0, 1.0, 0.0"
	    " )", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 31995, "INS-42000_FOV_CROSS_ANGLE      = ( 40.0 )", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 32076, "INS-42000_FOV_ANGLE_UNITS      = 'DEGREES'", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 32157, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 32238, "INS-43000_FOV_FRAME            = '43000-FRAME'", (
	    ftnlen)81, (ftnlen)46);
    s_copy(kbpool + 32319, "INS-43000_FOV_SHAPE            = 'ELLIPSE'", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 32400, "INS-43000_BORESIGHT            = ( 0.0, 0.0, 1.0"
	    " )", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 32481, "INS-43000_FOV_CLASS_SPEC       = 'ANGLES'", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 32562, "INS-43000_FOV_REF_ANGLE        = ( 20.0 )", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 32643, "INS-43000_FOV_REF_VECTOR       = ( 0.0, 1.0, 0.0"
	    " )", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 32724, "INS-43000_FOV_CROSS_ANGLE      = ( 40.0 )", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 32805, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 32886, "INS-44000_FOV_FRAME            = '44000-FRAME'", (
	    ftnlen)81, (ftnlen)46);
    s_copy(kbpool + 32967, "INS-44000_FOV_SHAPE            = 'ELLIPSE'", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 33048, "INS-44000_BORESIGHT            = ( 0.0, 0.0, 1.0"
	    " )", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 33129, "INS-44000_FOV_CLASS_SPEC       = 'ANGLES'", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 33210, "INS-44000_FOV_REF_VECTOR       = ( 0.0, 1.0, 0.0"
	    " )", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 33291, "INS-44000_FOV_REF_ANGLE        = ( 20.0 )", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 33372, "INS-44000_FOV_ANGLE_UNITS      = 'DEGREES'", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 33453, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 33534, "INS-45000_FOV_FRAME            = '45000-FRAME'", (
	    ftnlen)81, (ftnlen)46);
    s_copy(kbpool + 33615, "INS-45000_FOV_SHAPE            = 'RECTANGLE'", (
	    ftnlen)81, (ftnlen)44);
    s_copy(kbpool + 33696, "INS-45000_BORESIGHT            = ( 0.0, 0.0, 1.0"
	    " )", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 33777, "INS-45000_FOV_CLASS_SPEC       = 'ANGLES'", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 33858, "INS-45000_FOV_REF_VECTOR       = ( 0.0, 1.0, 0.0"
	    " )", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 33939, "INS-45000_FOV_REF_ANGLE        = ( 20.0 )", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 34020, "INS-45000_FOV_ANGLE_UNITS      = 'DEGREES'", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 34101, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 34182, "INS-45100_FOV_FRAME            = '45100-FRAME'", (
	    ftnlen)81, (ftnlen)46);
    s_copy(kbpool + 34263, "INS-45100_FOV_SHAPE            = 'RECTANGLE'", (
	    ftnlen)81, (ftnlen)44);
    s_copy(kbpool + 34344, "INS-45100_BORESIGHT            = ( 0.0, 0.0, 1.0"
	    " )", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 34425, "INS-45100_FOV_CLASS_SPEC       = 'ANGLES'", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 34506, "INS-45100_FOV_REF_VECTOR       = ( 0.0, 1.0, 0.0"
	    " )", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 34587, "INS-45100_FOV_REF_ANGLE        = ( 90.0 )", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 34668, "INS-45100_FOV_ANGLE_UNITS      = 'DEGREES'", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 34749, "INS-45100_FOV_CROSS_ANGLE      = ( 90.0 )", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 34830, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 34911, "INS-46000_FOV_FRAME            = '46000-FRAME'", (
	    ftnlen)81, (ftnlen)46);
    s_copy(kbpool + 34992, "INS-46000_FOV_SHAPE            = 'CIRCLE'", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 35073, "INS-46000_BORESIGHT            = ( 0.0, 0.0, 1.0"
	    " )", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 35154, "INS-46000_FOV_CLASS_SPEC       = 'ANGLES'", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 35235, "INS-46000_FOV_REF_VECTOR       = ( 0.0, 1.0, 0.0"
	    " )", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 35316, "INS-46000_FOV_REF_ANGLE        = ( 45.0 )", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 35397, "INS-46000_FOV_ANGLE_UNITS      = 'DEGREES'", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 35478, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 35559, "INS-46100_FOV_FRAME            = '46100-FRAME'", (
	    ftnlen)81, (ftnlen)46);
    s_copy(kbpool + 35640, "INS-46100_FOV_SHAPE            = 'ELLIPSE'", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 35721, "INS-46100_BORESIGHT            = ( 0.0, 0.0, 1.0"
	    " )", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 35802, "INS-46100_FOV_CLASS_SPEC       = 'ANGLES'", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 35883, "INS-46100_FOV_REF_VECTOR       = ( 0.0, 1.0, 0.0"
	    " )", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 35964, "INS-46100_FOV_REF_ANGLE        = ( 45.0 )", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 36045, "INS-46100_FOV_CROSS_ANGLE      = ( 30.0 )", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 36126, "INS-46100_FOV_ANGLE_UNITS      = 'DEGREES'", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 36207, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 36288, "INS-46200_FOV_FRAME            = '46200-FRAME'", (
	    ftnlen)81, (ftnlen)46);
    s_copy(kbpool + 36369, "INS-46200_FOV_SHAPE            = 'RECTANGLE'", (
	    ftnlen)81, (ftnlen)44);
    s_copy(kbpool + 36450, "INS-46200_BORESIGHT            = ( 0.0, 0.0, 1.0"
	    " )", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 36531, "INS-46200_FOV_CLASS_SPEC       = 'ANGLES'", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 36612, "INS-46200_FOV_REF_VECTOR       = ( 0.0, 1.0, 0.0"
	    " )", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 36693, "INS-46200_FOV_REF_ANGLE        = ( 45.0 )", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 36774, "INS-46200_FOV_CROSS_ANGLE      = ( 60.0 )", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 36855, "INS-46200_FOV_ANGLE_UNITS      = 'DEGREES'", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 36936, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 37017, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 37098, "INS-46201_FOV_FRAME            = '46201-FRAME'", (
	    ftnlen)81, (ftnlen)46);
    s_copy(kbpool + 37179, "INS-46201_FOV_SHAPE            = 'RECTANGLE'", (
	    ftnlen)81, (ftnlen)44);
    s_copy(kbpool + 37260, "INS-46201_BORESIGHT            = ( 0.0, 0.0, 1.0"
	    " )", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 37341, "INS-46201_FOV_CLASS_SPEC       = 'ANGLES'", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 37422, "INS-46201_FOV_REF_VECTOR       = ( 0.0, 0.5, 0.0"
	    " )", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 37503, "INS-46201_FOV_REF_ANGLE        = ( 45.0 )", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 37584, "INS-46201_FOV_CROSS_ANGLE      = ( 60.0 )", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 37665, "INS-46201_FOV_ANGLE_UNITS      = 'DEGREES'", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 37746, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 37827, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 37908, "INS-46202_FOV_FRAME            = '46202-FRAME'", (
	    ftnlen)81, (ftnlen)46);
    s_copy(kbpool + 37989, "INS-46202_FOV_SHAPE            = 'RECTANGLE'", (
	    ftnlen)81, (ftnlen)44);
    s_copy(kbpool + 38070, "INS-46202_BORESIGHT            = ( 0.0, 0.0, 1.0"
	    " )", (ftnlen)81, (ftnlen)50);
    s_copy(kbpool + 38151, "INS-46202_FOV_CLASS_SPEC       = 'ANGLES'", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 38232, "INS-46202_FOV_REF_VECTOR       = ( 0.0, 0.707106"
	    "7811865476, 0.7071067811865476 )", (ftnlen)81, (ftnlen)80);
    s_copy(kbpool + 38313, "INS-46202_FOV_REF_ANGLE        = ( 45.0 )", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 38394, "INS-46202_FOV_CROSS_ANGLE      = ( 60.0 )", (
	    ftnlen)81, (ftnlen)41);
    s_copy(kbpool + 38475, "INS-46202_FOV_ANGLE_UNITS      = 'DEGREES'", (
	    ftnlen)81, (ftnlen)42);
    s_copy(kbpool + 38556, " ", (ftnlen)81, (ftnlen)1);
    s_copy(kbpool + 38637, " ", (ftnlen)81, (ftnlen)1);

/*     Clear the kernel pool. */

    clpool_();

/*     Now load the character buffer with the test */
/*     scenario definitions into the kernel pool. */

    lmpool_(kbpool, &c__478, (ftnlen)81);

/* --- Case #1: ------------------------------------------------------ */

    tcase_("No Frame Defined Exception", (ftnlen)26);

/*     Frame with ID Code -10000 is missing it's FOV_FRAME keyword. */

    getfov_(&c_b483, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);
    chckxc_(&c_true, "SPICE(FRAMEMISSING)", ok, (ftnlen)19);

/* --- Case #2: ------------------------------------------------------ */

    tcase_("Unsupported Shape Exception", (ftnlen)27);

/*     The -11000 FOV Shape is 'SPUD-SHAPED', an unsupported GETFOV */
/*     shape. */

    getfov_(&c_b488, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);
    chckxc_(&c_true, "SPICE(SHAPENOTSUPPORTED)", ok, (ftnlen)24);

/* --- Case #3: ------------------------------------------------------ */

    tcase_("Missing Shape Definition Exception", (ftnlen)34);

/*     The -12000 FOV Shape keyword is missing. */

    getfov_(&c_b493, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);
    chckxc_(&c_true, "SPICE(SHAPEMISSING)", ok, (ftnlen)19);

/* --- Case #4: ------------------------------------------------------ */

    tcase_("Missing Boresight Definition Exception", (ftnlen)38);

/*     The -12500 Boresight keyword is missing. */

    getfov_(&c_b498, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);
    chckxc_(&c_true, "SPICE(BORESIGHTMISSING)", ok, (ftnlen)23);

/* --- Case #5: ------------------------------------------------------ */

    tcase_("Improperly Defined Boresight Vector", (ftnlen)35);

/*     The -13000 boresight has only 2 components. */

    getfov_(&c_b503, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);
    chckxc_(&c_true, "SPICE(BADBORESIGHTSPEC)", ok, (ftnlen)23);

/*     The -14000 boresight has 3 character components. */

    getfov_(&c_b507, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);
    chckxc_(&c_true, "SPICE(BADBORESIGHTSPEC)", ok, (ftnlen)23);

/* --- Case #6: ------------------------------------------------------ */

    tcase_("Missing FOV Boundary Definition Exception", (ftnlen)41);

/*     The -15000 FOV boundary keyword is missing. */

    getfov_(&c_b512, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);
    chckxc_(&c_true, "SPICE(BOUNDARYMISSING)", ok, (ftnlen)22);

/* --- Case #7: ------------------------------------------------------ */

    tcase_("Not Enough ROOM Exception", (ftnlen)25);

/*     The -16000 FOV boundary keyword contains 5 vectors, specify */
/*     that ROOM is only 4 and check for the exception. */

    getfov_(&c_b517, &c__4, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);
    chckxc_(&c_true, "SPICE(BOUNDARYTOOBIG)", ok, (ftnlen)21);

/* --- Case #8: ------------------------------------------------------ */

    tcase_("Boundary Vectors are 3 Vectors", (ftnlen)30);

/*     The -17000 FOV boundary keyword contains exactly 2 DP entries. */

    getfov_(&c_b522, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);
    chckxc_(&c_true, "SPICE(BADBOUNDARY)", ok, (ftnlen)18);

/* --- Case #9: ------------------------------------------------------ */

    tcase_("Improper Number of Boundary Corner Vectors", (ftnlen)42);

/*     The -18100 FOV boundary keyword contains 2 boundary corner */
/*     vectors, but the shape is circular. */

    getfov_(&c_b527, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);
    chckxc_(&c_true, "SPICE(BADBOUNDARY)", ok, (ftnlen)18);

/*     The -18200 FOV boundary keyword contains 1 boundary corner */
/*     vector, but the shape is elliptical. */

    getfov_(&c_b531, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);
    chckxc_(&c_true, "SPICE(BADBOUNDARY)", ok, (ftnlen)18);

/*     The -18300 FOV boundary keyword contains 1 boundary corner */
/*     vector, but the shape is rectangular. */

    getfov_(&c_b535, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);
    chckxc_(&c_true, "SPICE(BADBOUNDARY)", ok, (ftnlen)18);

/*     The -18400 FOV boundary keyword contains 1 boundary corner */
/*     vector, but the shape is polygonal. */

    getfov_(&c_b539, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);
    chckxc_(&c_true, "SPICE(BADBOUNDARY)", ok, (ftnlen)18);

/* --- Case #10: ----------------------------------------------------- */

    tcase_("Nominal CIRCLE CORNERS Specification", (ftnlen)36);

/*     The -20000 ID Code contains the definition of a circle with */
/*     the following characteristics: */

    s_copy(ckshap, "CIRCLE", (ftnlen)81, (ftnlen)6);
    s_copy(ckfram, "20000-FRAME", (ftnlen)81, (ftnlen)11);
    ckbsgt[0] = 0.;
    ckbsgt[1] = 0.;
    ckbsgt[2] = 1.;
    ckn = 1;
    ckbnds[0] = 1.;
    ckbnds[1] = 0.;
    ckbnds[2] = 1.;

/*     Fetch the FOV definition. */

    getfov_(&c_b546, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);

/*     Check that no exception was generated. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the parameters returned. */

    chcksc_("SHAPE", shape, "=", ckshap, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chcksc_("FRAME", frame, "=", ckfram, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chckad_("BORESIGHT", bsight, "~", ckbsgt, &c__3, &c_b557, ok, (ftnlen)9, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &ckn, &c__0, ok, (ftnlen)1, (ftnlen)1);
    if (ckn == n) {

/*        Loop over all of the boundary vectors returned and */
/*        check them for any errors. */

	i__1 = ckn;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    s_copy(bndnam, "BOUNDS[#]", (ftnlen)81, (ftnlen)9);
	    repmi_(bndnam, "#", &i__, bndnam, (ftnlen)81, (ftnlen)1, (ftnlen)
		    81);
	    chckad_(bndnam, &bounds[(i__2 = i__ * 3 - 3) < 30 && 0 <= i__2 ? 
		    i__2 : s_rnge("bounds", i__2, "f_getfv2__", (ftnlen)1152)]
		    , "~", &ckbnds[(i__3 = i__ * 3 - 3) < 30 && 0 <= i__3 ? 
		    i__3 : s_rnge("ckbnds", i__3, "f_getfv2__", (ftnlen)1152)]
		    , &c__3, &c_b557, ok, (ftnlen)81, (ftnlen)1);
	}
    }

/* --- Case #11: ----------------------------------------------------- */

    tcase_("Old-Style CIRCLE CORNERS Specification", (ftnlen)38);

/*     The -20100 ID Code contains the definition of a circle with */
/*     the following characteristics: */

    s_copy(ckshap, "CIRCLE", (ftnlen)81, (ftnlen)6);
    s_copy(ckfram, "20100-FRAME", (ftnlen)81, (ftnlen)11);
    ckbsgt[0] = 0.;
    ckbsgt[1] = 0.;
    ckbsgt[2] = 1.;
    ckn = 1;
    ckbnds[0] = 1.;
    ckbnds[1] = 0.;
    ckbnds[2] = 1.;

/*     Fetch the FOV definition. */

    getfov_(&c_b573, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);

/*     Check that no exception was generated. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the parameters returned. */

    chcksc_("SHAPE", shape, "=", ckshap, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chcksc_("FRAME", frame, "=", ckfram, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chckad_("BORESIGHT", bsight, "~", ckbsgt, &c__3, &c_b557, ok, (ftnlen)9, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &ckn, &c__0, ok, (ftnlen)1, (ftnlen)1);
    if (ckn == n) {

/*        Loop over all of the boundary vectors returned and */
/*        check them for any errors. */

	i__1 = ckn;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    s_copy(bndnam, "BOUNDS[#]", (ftnlen)81, (ftnlen)9);
	    repmi_(bndnam, "#", &i__, bndnam, (ftnlen)81, (ftnlen)1, (ftnlen)
		    81);
	    chckad_(bndnam, &bounds[(i__2 = i__ * 3 - 3) < 30 && 0 <= i__2 ? 
		    i__2 : s_rnge("bounds", i__2, "f_getfv2__", (ftnlen)1214)]
		    , "~", &ckbnds[(i__3 = i__ * 3 - 3) < 30 && 0 <= i__3 ? 
		    i__3 : s_rnge("ckbnds", i__3, "f_getfv2__", (ftnlen)1214)]
		    , &c__3, &c_b557, ok, (ftnlen)81, (ftnlen)1);
	}
    }

/* --- Case #12: ----------------------------------------------------- */

    tcase_("Conflict CIRCLE CORNERS Specification", (ftnlen)37);

/*     The -20200 ID Code contains the definition of a circle with */
/*     the following characteristics: */

    s_copy(ckshap, "CIRCLE", (ftnlen)81, (ftnlen)6);
    s_copy(ckfram, "20200-FRAME", (ftnlen)81, (ftnlen)11);
    ckbsgt[0] = 0.;
    ckbsgt[1] = 0.;
    ckbsgt[2] = 1.;
    ckn = 1;
    ckbnds[0] = 2.;
    ckbnds[1] = 0.;
    ckbnds[2] = 1.;

/*     Fetch the FOV definition. */

    getfov_(&c_b600, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);

/*     Check that no exception was generated. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the parameters returned. */

    chcksc_("SHAPE", shape, "=", ckshap, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chcksc_("FRAME", frame, "=", ckfram, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chckad_("BORESIGHT", bsight, "~", ckbsgt, &c__3, &c_b557, ok, (ftnlen)9, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &ckn, &c__0, ok, (ftnlen)1, (ftnlen)1);
    if (ckn == n) {

/*        Loop over all of the boundary vectors returned and */
/*        check them for any errors. */

	i__1 = ckn;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    s_copy(bndnam, "BOUNDS[#]", (ftnlen)81, (ftnlen)9);
	    repmi_(bndnam, "#", &i__, bndnam, (ftnlen)81, (ftnlen)1, (ftnlen)
		    81);
	    chckad_(bndnam, &bounds[(i__2 = i__ * 3 - 3) < 30 && 0 <= i__2 ? 
		    i__2 : s_rnge("bounds", i__2, "f_getfv2__", (ftnlen)1276)]
		    , "~", &ckbnds[(i__3 = i__ * 3 - 3) < 30 && 0 <= i__3 ? 
		    i__3 : s_rnge("ckbnds", i__3, "f_getfv2__", (ftnlen)1276)]
		    , &c__3, &c_b557, ok, (ftnlen)81, (ftnlen)1);
	}
    }

/* --- Case #13: ----------------------------------------------------- */

    tcase_("Nominal ELLIPSE CORNERS Specification", (ftnlen)37);

/*     The -21000 ID Code contains the definition of an ellipse with */
/*     the following characteristics: */

    s_copy(ckshap, "ELLIPSE", (ftnlen)81, (ftnlen)7);
    s_copy(ckfram, "21000-FRAME", (ftnlen)81, (ftnlen)11);
    ckbsgt[0] = 0.;
    ckbsgt[1] = 0.;
    ckbsgt[2] = 1.;
    ckn = 2;
    ckbnds[0] = 1.;
    ckbnds[1] = 0.;
    ckbnds[2] = 1.;
    ckbnds[3] = 0.;
    ckbnds[4] = 1.;
    ckbnds[5] = 1.;

/*     Fetch the FOV definition. */

    getfov_(&c_b627, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);

/*     Check that no exception was generated. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the parameters returned. */

    chcksc_("SHAPE", shape, "=", ckshap, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chcksc_("FRAME", frame, "=", ckfram, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chckad_("BORESIGHT", bsight, "~", ckbsgt, &c__3, &c_b557, ok, (ftnlen)9, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &ckn, &c__0, ok, (ftnlen)1, (ftnlen)1);
    if (ckn == n) {

/*        Loop over all of the boundary vectors returned and */
/*        check them for any errors. */

	i__1 = ckn;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    s_copy(bndnam, "BOUNDS[#]", (ftnlen)81, (ftnlen)9);
	    repmi_(bndnam, "#", &i__, bndnam, (ftnlen)81, (ftnlen)1, (ftnlen)
		    81);
	    chckad_(bndnam, &bounds[(i__2 = i__ * 3 - 3) < 30 && 0 <= i__2 ? 
		    i__2 : s_rnge("bounds", i__2, "f_getfv2__", (ftnlen)1342)]
		    , "~", &ckbnds[(i__3 = i__ * 3 - 3) < 30 && 0 <= i__3 ? 
		    i__3 : s_rnge("ckbnds", i__3, "f_getfv2__", (ftnlen)1342)]
		    , &c__3, &c_b557, ok, (ftnlen)81, (ftnlen)1);
	}
    }

/* --- Case #14: ----------------------------------------------------- */

    tcase_("Old-Style ELLIPSE CORNERS Specification", (ftnlen)39);

/*     The -21100 ID Code contains the definition of an ellipse with */
/*     the following characteristics: */

    s_copy(ckshap, "ELLIPSE", (ftnlen)81, (ftnlen)7);
    s_copy(ckfram, "21100-FRAME", (ftnlen)81, (ftnlen)11);
    ckbsgt[0] = 0.;
    ckbsgt[1] = 0.;
    ckbsgt[2] = 1.;
    ckn = 2;
    ckbnds[0] = 1.;
    ckbnds[1] = 0.;
    ckbnds[2] = 1.;
    ckbnds[3] = 0.;
    ckbnds[4] = 1.;
    ckbnds[5] = 1.;

/*     Fetch the FOV definition. */

    getfov_(&c_b654, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);

/*     Check that no exception was generated. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the parameters returned. */

    chcksc_("SHAPE", shape, "=", ckshap, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chcksc_("FRAME", frame, "=", ckfram, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chckad_("BORESIGHT", bsight, "~", ckbsgt, &c__3, &c_b557, ok, (ftnlen)9, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &ckn, &c__0, ok, (ftnlen)1, (ftnlen)1);
    if (ckn == n) {

/*        Loop over all of the boundary vectors returned and */
/*        check them for any errors. */

	i__1 = ckn;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    s_copy(bndnam, "BOUNDS[#]", (ftnlen)81, (ftnlen)9);
	    repmi_(bndnam, "#", &i__, bndnam, (ftnlen)81, (ftnlen)1, (ftnlen)
		    81);
	    chckad_(bndnam, &bounds[(i__2 = i__ * 3 - 3) < 30 && 0 <= i__2 ? 
		    i__2 : s_rnge("bounds", i__2, "f_getfv2__", (ftnlen)1408)]
		    , "~", &ckbnds[(i__3 = i__ * 3 - 3) < 30 && 0 <= i__3 ? 
		    i__3 : s_rnge("ckbnds", i__3, "f_getfv2__", (ftnlen)1408)]
		    , &c__3, &c_b557, ok, (ftnlen)81, (ftnlen)1);
	}
    }

/* --- Case #15: ----------------------------------------------------- */

    tcase_("Conflict ELLIPSE CORNERS Specification", (ftnlen)38);

/*     The -21200 ID Code contains the definition of an ellipse with */
/*     the following characteristics: */

    s_copy(ckshap, "ELLIPSE", (ftnlen)81, (ftnlen)7);
    s_copy(ckfram, "21200-FRAME", (ftnlen)81, (ftnlen)11);
    ckbsgt[0] = 0.;
    ckbsgt[1] = 0.;
    ckbsgt[2] = 1.;
    ckn = 2;
    ckbnds[0] = 2.;
    ckbnds[1] = 0.;
    ckbnds[2] = 1.;
    ckbnds[3] = 0.;
    ckbnds[4] = 2.;
    ckbnds[5] = 1.;

/*     Fetch the FOV definition. */

    getfov_(&c_b681, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);

/*     Check that no exception was generated. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the parameters returned. */

    chcksc_("SHAPE", shape, "=", ckshap, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chcksc_("FRAME", frame, "=", ckfram, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chckad_("BORESIGHT", bsight, "~", ckbsgt, &c__3, &c_b557, ok, (ftnlen)9, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &ckn, &c__0, ok, (ftnlen)1, (ftnlen)1);
    if (ckn == n) {

/*        Loop over all of the boundary vectors returned and */
/*        check them for any errors. */

	i__1 = ckn;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    s_copy(bndnam, "BOUNDS[#]", (ftnlen)81, (ftnlen)9);
	    repmi_(bndnam, "#", &i__, bndnam, (ftnlen)81, (ftnlen)1, (ftnlen)
		    81);
	    chckad_(bndnam, &bounds[(i__2 = i__ * 3 - 3) < 30 && 0 <= i__2 ? 
		    i__2 : s_rnge("bounds", i__2, "f_getfv2__", (ftnlen)1474)]
		    , "~", &ckbnds[(i__3 = i__ * 3 - 3) < 30 && 0 <= i__3 ? 
		    i__3 : s_rnge("ckbnds", i__3, "f_getfv2__", (ftnlen)1474)]
		    , &c__3, &c_b557, ok, (ftnlen)81, (ftnlen)1);
	}
    }

/* --- Case #16: ----------------------------------------------------- */

    tcase_("Nominal RECTANGLE CORNERS Specification", (ftnlen)39);

/*     The -22000 ID Code contains the definition of a rectangle with */
/*     the following characteristics: */

    s_copy(ckshap, "RECTANGLE", (ftnlen)81, (ftnlen)9);
    s_copy(ckfram, "22000-FRAME", (ftnlen)81, (ftnlen)11);
    ckbsgt[0] = 0.;
    ckbsgt[1] = 0.;
    ckbsgt[2] = 1.;
    ckn = 4;
    ckbnds[0] = 1.;
    ckbnds[1] = 1.;
    ckbnds[2] = 1.;
    ckbnds[3] = 1.;
    ckbnds[4] = -1.;
    ckbnds[5] = 1.;
    ckbnds[6] = -1.;
    ckbnds[7] = -1.;
    ckbnds[8] = 1.;
    ckbnds[9] = -1.;
    ckbnds[10] = 1.;
    ckbnds[11] = 1.;

/*     Fetch the FOV definition. */

    getfov_(&c_b708, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);

/*     Check that no exception was generated. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the parameters returned. */

    chcksc_("SHAPE", shape, "=", ckshap, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chcksc_("FRAME", frame, "=", ckfram, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chckad_("BORESIGHT", bsight, "~", ckbsgt, &c__3, &c_b557, ok, (ftnlen)9, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &ckn, &c__0, ok, (ftnlen)1, (ftnlen)1);
    if (ckn == n) {

/*        Loop over all of the boundary vectors returned and */
/*        check them for any errors. */

	i__1 = ckn;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    s_copy(bndnam, "BOUNDS[#]", (ftnlen)81, (ftnlen)9);
	    repmi_(bndnam, "#", &i__, bndnam, (ftnlen)81, (ftnlen)1, (ftnlen)
		    81);
	    chckad_(bndnam, &bounds[(i__2 = i__ * 3 - 3) < 30 && 0 <= i__2 ? 
		    i__2 : s_rnge("bounds", i__2, "f_getfv2__", (ftnlen)1548)]
		    , "~", &ckbnds[(i__3 = i__ * 3 - 3) < 30 && 0 <= i__3 ? 
		    i__3 : s_rnge("ckbnds", i__3, "f_getfv2__", (ftnlen)1548)]
		    , &c__3, &c_b557, ok, (ftnlen)81, (ftnlen)1);
	}
    }

/* --- Case #17: ----------------------------------------------------- */

    tcase_("Old-Style RECTANGLE CORNERS Specification", (ftnlen)41);

/*     The -22100 ID Code contains the definition of a rectangle with */
/*     the following characteristics: */

    s_copy(ckshap, "RECTANGLE", (ftnlen)81, (ftnlen)9);
    s_copy(ckfram, "22100-FRAME", (ftnlen)81, (ftnlen)11);
    ckbsgt[0] = 0.;
    ckbsgt[1] = 0.;
    ckbsgt[2] = 1.;
    ckn = 4;
    ckbnds[0] = 1.;
    ckbnds[1] = 1.;
    ckbnds[2] = 1.;
    ckbnds[3] = 1.;
    ckbnds[4] = -1.;
    ckbnds[5] = 1.;
    ckbnds[6] = -1.;
    ckbnds[7] = -1.;
    ckbnds[8] = 1.;
    ckbnds[9] = -1.;
    ckbnds[10] = 1.;
    ckbnds[11] = 1.;

/*     Fetch the FOV definition. */

    getfov_(&c_b735, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);

/*     Check that no exception was generated. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the parameters returned. */

    chcksc_("SHAPE", shape, "=", ckshap, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chcksc_("FRAME", frame, "=", ckfram, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chckad_("BORESIGHT", bsight, "~", ckbsgt, &c__3, &c_b557, ok, (ftnlen)9, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &ckn, &c__0, ok, (ftnlen)1, (ftnlen)1);
    if (ckn == n) {

/*        Loop over all of the boundary vectors returned and */
/*        check them for any errors. */

	i__1 = ckn;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    s_copy(bndnam, "BOUNDS[#]", (ftnlen)81, (ftnlen)9);
	    repmi_(bndnam, "#", &i__, bndnam, (ftnlen)81, (ftnlen)1, (ftnlen)
		    81);
	    chckad_(bndnam, &bounds[(i__2 = i__ * 3 - 3) < 30 && 0 <= i__2 ? 
		    i__2 : s_rnge("bounds", i__2, "f_getfv2__", (ftnlen)1622)]
		    , "~", &ckbnds[(i__3 = i__ * 3 - 3) < 30 && 0 <= i__3 ? 
		    i__3 : s_rnge("ckbnds", i__3, "f_getfv2__", (ftnlen)1622)]
		    , &c__3, &c_b557, ok, (ftnlen)81, (ftnlen)1);
	}
    }

/* --- Case #18: ----------------------------------------------------- */

    tcase_("Conflict RECTANGLE CORNERS Specification", (ftnlen)40);

/*     The -22200 ID Code contains the definition of a rectangle with */
/*     the following characteristics: */

    s_copy(ckshap, "RECTANGLE", (ftnlen)81, (ftnlen)9);
    s_copy(ckfram, "22200-FRAME", (ftnlen)81, (ftnlen)11);
    ckbsgt[0] = 0.;
    ckbsgt[1] = 0.;
    ckbsgt[2] = 1.;
    ckn = 4;
    ckbnds[0] = 2.;
    ckbnds[1] = 2.;
    ckbnds[2] = 1.;
    ckbnds[3] = 2.;
    ckbnds[4] = -2.;
    ckbnds[5] = 1.;
    ckbnds[6] = -2.;
    ckbnds[7] = -2.;
    ckbnds[8] = 1.;
    ckbnds[9] = -2.;
    ckbnds[10] = 2.;
    ckbnds[11] = 1.;

/*     Fetch the FOV definition. */

    getfov_(&c_b762, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);

/*     Check that no exception was generated. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the parameters returned. */

    chcksc_("SHAPE", shape, "=", ckshap, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chcksc_("FRAME", frame, "=", ckfram, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chckad_("BORESIGHT", bsight, "~", ckbsgt, &c__3, &c_b557, ok, (ftnlen)9, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &ckn, &c__0, ok, (ftnlen)1, (ftnlen)1);
    if (ckn == n) {

/*        Loop over all of the boundary vectors returned and */
/*        check them for any errors. */

	i__1 = ckn;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    s_copy(bndnam, "BOUNDS[#]", (ftnlen)81, (ftnlen)9);
	    repmi_(bndnam, "#", &i__, bndnam, (ftnlen)81, (ftnlen)1, (ftnlen)
		    81);
	    chckad_(bndnam, &bounds[(i__2 = i__ * 3 - 3) < 30 && 0 <= i__2 ? 
		    i__2 : s_rnge("bounds", i__2, "f_getfv2__", (ftnlen)1696)]
		    , "~", &ckbnds[(i__3 = i__ * 3 - 3) < 30 && 0 <= i__3 ? 
		    i__3 : s_rnge("ckbnds", i__3, "f_getfv2__", (ftnlen)1696)]
		    , &c__3, &c_b557, ok, (ftnlen)81, (ftnlen)1);
	}
    }

/* --- Case #19: ----------------------------------------------------- */

    tcase_("Nominal POLYGON CORNERS Specification", (ftnlen)37);

/*     The -23000 ID Code contains the definition of a polygon with */
/*     the following characteristics: */

    s_copy(ckshap, "POLYGON", (ftnlen)81, (ftnlen)7);
    s_copy(ckfram, "23000-FRAME", (ftnlen)81, (ftnlen)11);
    ckbsgt[0] = 0.;
    ckbsgt[1] = 0.;
    ckbsgt[2] = 1.;
    ckn = 4;
    ckbnds[0] = 1.;
    ckbnds[1] = 1.;
    ckbnds[2] = 1.;
    ckbnds[3] = 1.;
    ckbnds[4] = -1.;
    ckbnds[5] = 1.;
    ckbnds[6] = -1.;
    ckbnds[7] = -1.;
    ckbnds[8] = 1.;
    ckbnds[9] = -1.;
    ckbnds[10] = 1.;
    ckbnds[11] = 1.;

/*     Fetch the FOV definition. */

    getfov_(&c_b789, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);

/*     Check that no exception was generated. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the parameters returned. */

    chcksc_("SHAPE", shape, "=", ckshap, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chcksc_("FRAME", frame, "=", ckfram, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chckad_("BORESIGHT", bsight, "~", ckbsgt, &c__3, &c_b557, ok, (ftnlen)9, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &ckn, &c__0, ok, (ftnlen)1, (ftnlen)1);
    if (ckn == n) {

/*        Loop over all of the boundary vectors returned and */
/*        check them for any errors. */

	i__1 = ckn;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    s_copy(bndnam, "BOUNDS[#]", (ftnlen)81, (ftnlen)9);
	    repmi_(bndnam, "#", &i__, bndnam, (ftnlen)81, (ftnlen)1, (ftnlen)
		    81);
	    chckad_(bndnam, &bounds[(i__2 = i__ * 3 - 3) < 30 && 0 <= i__2 ? 
		    i__2 : s_rnge("bounds", i__2, "f_getfv2__", (ftnlen)1770)]
		    , "~", &ckbnds[(i__3 = i__ * 3 - 3) < 30 && 0 <= i__3 ? 
		    i__3 : s_rnge("ckbnds", i__3, "f_getfv2__", (ftnlen)1770)]
		    , &c__3, &c_b557, ok, (ftnlen)81, (ftnlen)1);
	}
    }

/* --- Case #20: ----------------------------------------------------- */

    tcase_("Old-Style POLYGON CORNERS Specification", (ftnlen)39);

/*     The -23100 ID Code contains the definition of a polygon with */
/*     the following characteristics: */

    s_copy(ckshap, "POLYGON", (ftnlen)81, (ftnlen)7);
    s_copy(ckfram, "23100-FRAME", (ftnlen)81, (ftnlen)11);
    ckbsgt[0] = 0.;
    ckbsgt[1] = 0.;
    ckbsgt[2] = 1.;
    ckn = 4;
    ckbnds[0] = 1.;
    ckbnds[1] = 1.;
    ckbnds[2] = 1.;
    ckbnds[3] = 1.;
    ckbnds[4] = -1.;
    ckbnds[5] = 1.;
    ckbnds[6] = -1.;
    ckbnds[7] = -1.;
    ckbnds[8] = 1.;
    ckbnds[9] = -1.;
    ckbnds[10] = 1.;
    ckbnds[11] = 1.;

/*     Fetch the FOV definition. */

    getfov_(&c_b816, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);

/*     Check that no exception was generated. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the parameters returned. */

    chcksc_("SHAPE", shape, "=", ckshap, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chcksc_("FRAME", frame, "=", ckfram, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chckad_("BORESIGHT", bsight, "~", ckbsgt, &c__3, &c_b557, ok, (ftnlen)9, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &ckn, &c__0, ok, (ftnlen)1, (ftnlen)1);
    if (ckn == n) {

/*        Loop over all of the boundary vectors returned and */
/*        check them for any errors. */

	i__1 = ckn;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    s_copy(bndnam, "BOUNDS[#]", (ftnlen)81, (ftnlen)9);
	    repmi_(bndnam, "#", &i__, bndnam, (ftnlen)81, (ftnlen)1, (ftnlen)
		    81);
	    chckad_(bndnam, &bounds[(i__2 = i__ * 3 - 3) < 30 && 0 <= i__2 ? 
		    i__2 : s_rnge("bounds", i__2, "f_getfv2__", (ftnlen)1844)]
		    , "~", &ckbnds[(i__3 = i__ * 3 - 3) < 30 && 0 <= i__3 ? 
		    i__3 : s_rnge("ckbnds", i__3, "f_getfv2__", (ftnlen)1844)]
		    , &c__3, &c_b557, ok, (ftnlen)81, (ftnlen)1);
	}
    }

/* --- Case #21: ----------------------------------------------------- */

    tcase_("Conflict POLYGON CORNERS Specification", (ftnlen)38);

/*     The -23200 ID Code contains the definition of a polygon with */
/*     the following characteristics: */

    s_copy(ckshap, "POLYGON", (ftnlen)81, (ftnlen)7);
    s_copy(ckfram, "23200-FRAME", (ftnlen)81, (ftnlen)11);
    ckbsgt[0] = 0.;
    ckbsgt[1] = 0.;
    ckbsgt[2] = 1.;
    ckn = 4;
    ckbnds[0] = 2.;
    ckbnds[1] = 2.;
    ckbnds[2] = 1.;
    ckbnds[3] = 2.;
    ckbnds[4] = -2.;
    ckbnds[5] = 1.;
    ckbnds[6] = -2.;
    ckbnds[7] = -2.;
    ckbnds[8] = 1.;
    ckbnds[9] = -2.;
    ckbnds[10] = 2.;
    ckbnds[11] = 1.;

/*     Fetch the FOV definition. */

    getfov_(&c_b843, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);

/*     Check that no exception was generated. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the parameters returned. */

    chcksc_("SHAPE", shape, "=", ckshap, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chcksc_("FRAME", frame, "=", ckfram, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chckad_("BORESIGHT", bsight, "~", ckbsgt, &c__3, &c_b557, ok, (ftnlen)9, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &ckn, &c__0, ok, (ftnlen)1, (ftnlen)1);
    if (ckn == n) {

/*        Loop over all of the boundary vectors returned and */
/*        check them for any errors. */

	i__1 = ckn;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    s_copy(bndnam, "BOUNDS[#]", (ftnlen)81, (ftnlen)9);
	    repmi_(bndnam, "#", &i__, bndnam, (ftnlen)81, (ftnlen)1, (ftnlen)
		    81);
	    chckad_(bndnam, &bounds[(i__2 = i__ * 3 - 3) < 30 && 0 <= i__2 ? 
		    i__2 : s_rnge("bounds", i__2, "f_getfv2__", (ftnlen)1919)]
		    , "~", &ckbnds[(i__3 = i__ * 3 - 3) < 30 && 0 <= i__3 ? 
		    i__3 : s_rnge("ckbnds", i__3, "f_getfv2__", (ftnlen)1919)]
		    , &c__3, &c_b557, ok, (ftnlen)81, (ftnlen)1);
	}
    }

/* --- Case #22: ----------------------------------------------------- */

    tcase_("Nominal CIRCLE CORNERS-SET Specification", (ftnlen)40);

/*     The -30000 ID Code contains the definition of a circle with */
/*     the following characteristics: */

    s_copy(ckshap, "CIRCLE", (ftnlen)81, (ftnlen)6);
    s_copy(ckfram, "30000-FRAME", (ftnlen)81, (ftnlen)11);
    ckbsgt[0] = 0.;
    ckbsgt[1] = 0.;
    ckbsgt[2] = 1.;
    ckn = 1;
    ckbnds[0] = 1.;
    ckbnds[1] = 0.;
    ckbnds[2] = 1.;

/*     Fetch the FOV definition. */

    getfov_(&c_b870, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);

/*     Check that no exception was generated. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the parameters returned. */

    chcksc_("SHAPE", shape, "=", ckshap, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chcksc_("FRAME", frame, "=", ckfram, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chckad_("BORESIGHT", bsight, "~", ckbsgt, &c__3, &c_b557, ok, (ftnlen)9, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &ckn, &c__0, ok, (ftnlen)1, (ftnlen)1);
    if (ckn == n) {

/*        Loop over all of the boundary vectors returned and */
/*        check them for any errors. */

	i__1 = ckn;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    s_copy(bndnam, "BOUNDS[#]", (ftnlen)81, (ftnlen)9);
	    repmi_(bndnam, "#", &i__, bndnam, (ftnlen)81, (ftnlen)1, (ftnlen)
		    81);
	    chckad_(bndnam, &bounds[(i__2 = i__ * 3 - 3) < 30 && 0 <= i__2 ? 
		    i__2 : s_rnge("bounds", i__2, "f_getfv2__", (ftnlen)1981)]
		    , "~", &ckbnds[(i__3 = i__ * 3 - 3) < 30 && 0 <= i__3 ? 
		    i__3 : s_rnge("ckbnds", i__3, "f_getfv2__", (ftnlen)1981)]
		    , &c__3, &c_b557, ok, (ftnlen)81, (ftnlen)1);
	}
    }

/* --- Case #23: ----------------------------------------------------- */

    tcase_("Old-Style CIRCLE CORNERS-SET Specification", (ftnlen)42);

/*     The -30100 ID Code contains the definition of a circle with */
/*     the following characteristics: */

    s_copy(ckshap, "CIRCLE", (ftnlen)81, (ftnlen)6);
    s_copy(ckfram, "30100-FRAME", (ftnlen)81, (ftnlen)11);
    ckbsgt[0] = 0.;
    ckbsgt[1] = 0.;
    ckbsgt[2] = 1.;
    ckn = 1;
    ckbnds[0] = 1.;
    ckbnds[1] = 0.;
    ckbnds[2] = 1.;

/*     Fetch the FOV definition. */

    getfov_(&c_b897, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);

/*     Check that no exception was generated. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the parameters returned. */

    chcksc_("SHAPE", shape, "=", ckshap, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chcksc_("FRAME", frame, "=", ckfram, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chckad_("BORESIGHT", bsight, "~", ckbsgt, &c__3, &c_b557, ok, (ftnlen)9, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &ckn, &c__0, ok, (ftnlen)1, (ftnlen)1);
    if (ckn == n) {

/*        Loop over all of the boundary vectors returned and */
/*        check them for any errors. */

	i__1 = ckn;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    s_copy(bndnam, "BOUNDS[#]", (ftnlen)81, (ftnlen)9);
	    repmi_(bndnam, "#", &i__, bndnam, (ftnlen)81, (ftnlen)1, (ftnlen)
		    81);
	    chckad_(bndnam, &bounds[(i__2 = i__ * 3 - 3) < 30 && 0 <= i__2 ? 
		    i__2 : s_rnge("bounds", i__2, "f_getfv2__", (ftnlen)2043)]
		    , "~", &ckbnds[(i__3 = i__ * 3 - 3) < 30 && 0 <= i__3 ? 
		    i__3 : s_rnge("ckbnds", i__3, "f_getfv2__", (ftnlen)2043)]
		    , &c__3, &c_b557, ok, (ftnlen)81, (ftnlen)1);
	}
    }

/* --- Case #24: ----------------------------------------------------- */

    tcase_("Conflict CIRCLE CORNERS-SET Specification", (ftnlen)41);

/*     The -30200 ID Code contains the definition of a circle with */
/*     the following characteristics: */

    s_copy(ckshap, "CIRCLE", (ftnlen)81, (ftnlen)6);
    s_copy(ckfram, "30200-FRAME", (ftnlen)81, (ftnlen)11);
    ckbsgt[0] = 0.;
    ckbsgt[1] = 0.;
    ckbsgt[2] = 1.;
    ckn = 1;
    ckbnds[0] = 2.;
    ckbnds[1] = 0.;
    ckbnds[2] = 1.;

/*     Fetch the FOV definition. */

    getfov_(&c_b924, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);

/*     Check that no exception was generated. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the parameters returned. */

    chcksc_("SHAPE", shape, "=", ckshap, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chcksc_("FRAME", frame, "=", ckfram, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chckad_("BORESIGHT", bsight, "~", ckbsgt, &c__3, &c_b557, ok, (ftnlen)9, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &ckn, &c__0, ok, (ftnlen)1, (ftnlen)1);
    if (ckn == n) {

/*        Loop over all of the boundary vectors returned and */
/*        check them for any errors. */

	i__1 = ckn;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    s_copy(bndnam, "BOUNDS[#]", (ftnlen)81, (ftnlen)9);
	    repmi_(bndnam, "#", &i__, bndnam, (ftnlen)81, (ftnlen)1, (ftnlen)
		    81);
	    chckad_(bndnam, &bounds[(i__2 = i__ * 3 - 3) < 30 && 0 <= i__2 ? 
		    i__2 : s_rnge("bounds", i__2, "f_getfv2__", (ftnlen)2105)]
		    , "~", &ckbnds[(i__3 = i__ * 3 - 3) < 30 && 0 <= i__3 ? 
		    i__3 : s_rnge("ckbnds", i__3, "f_getfv2__", (ftnlen)2105)]
		    , &c__3, &c_b557, ok, (ftnlen)81, (ftnlen)1);
	}
    }

/* --- Case #25: ----------------------------------------------------- */

    tcase_("Nominal ELLIPSE CORNERS-SET Specification", (ftnlen)41);

/*     The -31000 ID Code contains the definition of an ellipse with */
/*     the following characteristics: */

    s_copy(ckshap, "ELLIPSE", (ftnlen)81, (ftnlen)7);
    s_copy(ckfram, "31000-FRAME", (ftnlen)81, (ftnlen)11);
    ckbsgt[0] = 0.;
    ckbsgt[1] = 0.;
    ckbsgt[2] = 1.;
    ckn = 2;
    ckbnds[0] = 1.;
    ckbnds[1] = 0.;
    ckbnds[2] = 1.;
    ckbnds[3] = 0.;
    ckbnds[4] = 1.;
    ckbnds[5] = 1.;

/*     Fetch the FOV definition. */

    getfov_(&c_b951, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);

/*     Check that no exception was generated. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the parameters returned. */

    chcksc_("SHAPE", shape, "=", ckshap, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chcksc_("FRAME", frame, "=", ckfram, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chckad_("BORESIGHT", bsight, "~", ckbsgt, &c__3, &c_b557, ok, (ftnlen)9, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &ckn, &c__0, ok, (ftnlen)1, (ftnlen)1);
    if (ckn == n) {

/*        Loop over all of the boundary vectors returned and */
/*        check them for any errors. */

	i__1 = ckn;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    s_copy(bndnam, "BOUNDS[#]", (ftnlen)81, (ftnlen)9);
	    repmi_(bndnam, "#", &i__, bndnam, (ftnlen)81, (ftnlen)1, (ftnlen)
		    81);
	    chckad_(bndnam, &bounds[(i__2 = i__ * 3 - 3) < 30 && 0 <= i__2 ? 
		    i__2 : s_rnge("bounds", i__2, "f_getfv2__", (ftnlen)2171)]
		    , "~", &ckbnds[(i__3 = i__ * 3 - 3) < 30 && 0 <= i__3 ? 
		    i__3 : s_rnge("ckbnds", i__3, "f_getfv2__", (ftnlen)2171)]
		    , &c__3, &c_b557, ok, (ftnlen)81, (ftnlen)1);
	}
    }

/* --- Case #26: ----------------------------------------------------- */

    tcase_("Old-Style ELLIPSE CORNERS-SET Specification", (ftnlen)43);

/*     The -31100 ID Code contains the definition of an ellipse with */
/*     the following characteristics: */

    s_copy(ckshap, "ELLIPSE", (ftnlen)81, (ftnlen)7);
    s_copy(ckfram, "31100-FRAME", (ftnlen)81, (ftnlen)11);
    ckbsgt[0] = 0.;
    ckbsgt[1] = 0.;
    ckbsgt[2] = 1.;
    ckn = 2;
    ckbnds[0] = 1.;
    ckbnds[1] = 0.;
    ckbnds[2] = 1.;
    ckbnds[3] = 0.;
    ckbnds[4] = 1.;
    ckbnds[5] = 1.;

/*     Fetch the FOV definition. */

    getfov_(&c_b978, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);

/*     Check that no exception was generated. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the parameters returned. */

    chcksc_("SHAPE", shape, "=", ckshap, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chcksc_("FRAME", frame, "=", ckfram, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chckad_("BORESIGHT", bsight, "~", ckbsgt, &c__3, &c_b557, ok, (ftnlen)9, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &ckn, &c__0, ok, (ftnlen)1, (ftnlen)1);
    if (ckn == n) {

/*        Loop over all of the boundary vectors returned and */
/*        check them for any errors. */

	i__1 = ckn;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    s_copy(bndnam, "BOUNDS[#]", (ftnlen)81, (ftnlen)9);
	    repmi_(bndnam, "#", &i__, bndnam, (ftnlen)81, (ftnlen)1, (ftnlen)
		    81);
	    chckad_(bndnam, &bounds[(i__2 = i__ * 3 - 3) < 30 && 0 <= i__2 ? 
		    i__2 : s_rnge("bounds", i__2, "f_getfv2__", (ftnlen)2237)]
		    , "~", &ckbnds[(i__3 = i__ * 3 - 3) < 30 && 0 <= i__3 ? 
		    i__3 : s_rnge("ckbnds", i__3, "f_getfv2__", (ftnlen)2237)]
		    , &c__3, &c_b557, ok, (ftnlen)81, (ftnlen)1);
	}
    }

/* --- Case #27: ----------------------------------------------------- */

    tcase_("Conflict ELLIPSE CORNERS-SET Specification", (ftnlen)42);

/*     The -31200 ID Code contains the definition of an ellipse with */
/*     the following characteristics: */

    s_copy(ckshap, "ELLIPSE", (ftnlen)81, (ftnlen)7);
    s_copy(ckfram, "31200-FRAME", (ftnlen)81, (ftnlen)11);
    ckbsgt[0] = 0.;
    ckbsgt[1] = 0.;
    ckbsgt[2] = 1.;
    ckn = 2;
    ckbnds[0] = 2.;
    ckbnds[1] = 0.;
    ckbnds[2] = 1.;
    ckbnds[3] = 0.;
    ckbnds[4] = 2.;
    ckbnds[5] = 1.;

/*     Fetch the FOV definition. */

    getfov_(&c_b1005, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);

/*     Check that no exception was generated. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the parameters returned. */

    chcksc_("SHAPE", shape, "=", ckshap, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chcksc_("FRAME", frame, "=", ckfram, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chckad_("BORESIGHT", bsight, "~", ckbsgt, &c__3, &c_b557, ok, (ftnlen)9, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &ckn, &c__0, ok, (ftnlen)1, (ftnlen)1);
    if (ckn == n) {

/*        Loop over all of the boundary vectors returned and */
/*        check them for any errors. */

	i__1 = ckn;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    s_copy(bndnam, "BOUNDS[#]", (ftnlen)81, (ftnlen)9);
	    repmi_(bndnam, "#", &i__, bndnam, (ftnlen)81, (ftnlen)1, (ftnlen)
		    81);
	    chckad_(bndnam, &bounds[(i__2 = i__ * 3 - 3) < 30 && 0 <= i__2 ? 
		    i__2 : s_rnge("bounds", i__2, "f_getfv2__", (ftnlen)2303)]
		    , "~", &ckbnds[(i__3 = i__ * 3 - 3) < 30 && 0 <= i__3 ? 
		    i__3 : s_rnge("ckbnds", i__3, "f_getfv2__", (ftnlen)2303)]
		    , &c__3, &c_b557, ok, (ftnlen)81, (ftnlen)1);
	}
    }

/* --- Case #28: ----------------------------------------------------- */

    tcase_("Nominal RECTANGLE CORNERS-SET Specification", (ftnlen)43);

/*     The -32000 ID Code contains the definition of a rectangle with */
/*     the following characteristics: */

    s_copy(ckshap, "RECTANGLE", (ftnlen)81, (ftnlen)9);
    s_copy(ckfram, "32000-FRAME", (ftnlen)81, (ftnlen)11);
    ckbsgt[0] = 0.;
    ckbsgt[1] = 0.;
    ckbsgt[2] = 1.;
    ckn = 4;
    ckbnds[0] = 1.;
    ckbnds[1] = 1.;
    ckbnds[2] = 1.;
    ckbnds[3] = 1.;
    ckbnds[4] = -1.;
    ckbnds[5] = 1.;
    ckbnds[6] = -1.;
    ckbnds[7] = -1.;
    ckbnds[8] = 1.;
    ckbnds[9] = -1.;
    ckbnds[10] = 1.;
    ckbnds[11] = 1.;

/*     Fetch the FOV definition. */

    getfov_(&c_b1032, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);

/*     Check that no exception was generated. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the parameters returned. */

    chcksc_("SHAPE", shape, "=", ckshap, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chcksc_("FRAME", frame, "=", ckfram, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chckad_("BORESIGHT", bsight, "~", ckbsgt, &c__3, &c_b557, ok, (ftnlen)9, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &ckn, &c__0, ok, (ftnlen)1, (ftnlen)1);
    if (ckn == n) {

/*        Loop over all of the boundary vectors returned and */
/*        check them for any errors. */

	i__1 = ckn;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    s_copy(bndnam, "BOUNDS[#]", (ftnlen)81, (ftnlen)9);
	    repmi_(bndnam, "#", &i__, bndnam, (ftnlen)81, (ftnlen)1, (ftnlen)
		    81);
	    chckad_(bndnam, &bounds[(i__2 = i__ * 3 - 3) < 30 && 0 <= i__2 ? 
		    i__2 : s_rnge("bounds", i__2, "f_getfv2__", (ftnlen)2377)]
		    , "~", &ckbnds[(i__3 = i__ * 3 - 3) < 30 && 0 <= i__3 ? 
		    i__3 : s_rnge("ckbnds", i__3, "f_getfv2__", (ftnlen)2377)]
		    , &c__3, &c_b557, ok, (ftnlen)81, (ftnlen)1);
	}
    }

/* --- Case #29: ----------------------------------------------------- */

    tcase_("Old-Style RECTANGLE CORNERS-SET Specification", (ftnlen)45);

/*     The -32100 ID Code contains the definition of a rectangle with */
/*     the following characteristics: */

    s_copy(ckshap, "RECTANGLE", (ftnlen)81, (ftnlen)9);
    s_copy(ckfram, "32100-FRAME", (ftnlen)81, (ftnlen)11);
    ckbsgt[0] = 0.;
    ckbsgt[1] = 0.;
    ckbsgt[2] = 1.;
    ckn = 4;
    ckbnds[0] = 1.;
    ckbnds[1] = 1.;
    ckbnds[2] = 1.;
    ckbnds[3] = 1.;
    ckbnds[4] = -1.;
    ckbnds[5] = 1.;
    ckbnds[6] = -1.;
    ckbnds[7] = -1.;
    ckbnds[8] = 1.;
    ckbnds[9] = -1.;
    ckbnds[10] = 1.;
    ckbnds[11] = 1.;

/*     Fetch the FOV definition. */

    getfov_(&c_b1059, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);

/*     Check that no exception was generated. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the parameters returned. */

    chcksc_("SHAPE", shape, "=", ckshap, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chcksc_("FRAME", frame, "=", ckfram, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chckad_("BORESIGHT", bsight, "~", ckbsgt, &c__3, &c_b557, ok, (ftnlen)9, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &ckn, &c__0, ok, (ftnlen)1, (ftnlen)1);
    if (ckn == n) {

/*        Loop over all of the boundary vectors returned and */
/*        check them for any errors. */

	i__1 = ckn;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    s_copy(bndnam, "BOUNDS[#]", (ftnlen)81, (ftnlen)9);
	    repmi_(bndnam, "#", &i__, bndnam, (ftnlen)81, (ftnlen)1, (ftnlen)
		    81);
	    chckad_(bndnam, &bounds[(i__2 = i__ * 3 - 3) < 30 && 0 <= i__2 ? 
		    i__2 : s_rnge("bounds", i__2, "f_getfv2__", (ftnlen)2451)]
		    , "~", &ckbnds[(i__3 = i__ * 3 - 3) < 30 && 0 <= i__3 ? 
		    i__3 : s_rnge("ckbnds", i__3, "f_getfv2__", (ftnlen)2451)]
		    , &c__3, &c_b557, ok, (ftnlen)81, (ftnlen)1);
	}
    }

/* --- Case #30: ----------------------------------------------------- */

    tcase_("Conflict RECTANGLE CORNERS-SET Specification", (ftnlen)44);

/*     The -32200 ID Code contains the definition of a rectangle with */
/*     the following characteristics: */

    s_copy(ckshap, "RECTANGLE", (ftnlen)81, (ftnlen)9);
    s_copy(ckfram, "32200-FRAME", (ftnlen)81, (ftnlen)11);
    ckbsgt[0] = 0.;
    ckbsgt[1] = 0.;
    ckbsgt[2] = 1.;
    ckn = 4;
    ckbnds[0] = 2.;
    ckbnds[1] = 2.;
    ckbnds[2] = 1.;
    ckbnds[3] = 2.;
    ckbnds[4] = -2.;
    ckbnds[5] = 1.;
    ckbnds[6] = -2.;
    ckbnds[7] = -2.;
    ckbnds[8] = 1.;
    ckbnds[9] = -2.;
    ckbnds[10] = 2.;
    ckbnds[11] = 1.;

/*     Fetch the FOV definition. */

    getfov_(&c_b1086, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);

/*     Check that no exception was generated. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the parameters returned. */

    chcksc_("SHAPE", shape, "=", ckshap, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chcksc_("FRAME", frame, "=", ckfram, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chckad_("BORESIGHT", bsight, "~", ckbsgt, &c__3, &c_b557, ok, (ftnlen)9, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &ckn, &c__0, ok, (ftnlen)1, (ftnlen)1);
    if (ckn == n) {

/*        Loop over all of the boundary vectors returned and */
/*        check them for any errors. */

	i__1 = ckn;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    s_copy(bndnam, "BOUNDS[#]", (ftnlen)81, (ftnlen)9);
	    repmi_(bndnam, "#", &i__, bndnam, (ftnlen)81, (ftnlen)1, (ftnlen)
		    81);
	    chckad_(bndnam, &bounds[(i__2 = i__ * 3 - 3) < 30 && 0 <= i__2 ? 
		    i__2 : s_rnge("bounds", i__2, "f_getfv2__", (ftnlen)2525)]
		    , "~", &ckbnds[(i__3 = i__ * 3 - 3) < 30 && 0 <= i__3 ? 
		    i__3 : s_rnge("ckbnds", i__3, "f_getfv2__", (ftnlen)2525)]
		    , &c__3, &c_b557, ok, (ftnlen)81, (ftnlen)1);
	}
    }

/* --- Case #31: ----------------------------------------------------- */

    tcase_("Nominal POLYGON CORNERS-SET Specification", (ftnlen)41);

/*     The -33000 ID Code contains the definition of a polygon with */
/*     the following characteristics: */

    s_copy(ckshap, "POLYGON", (ftnlen)81, (ftnlen)7);
    s_copy(ckfram, "33000-FRAME", (ftnlen)81, (ftnlen)11);
    ckbsgt[0] = 0.;
    ckbsgt[1] = 0.;
    ckbsgt[2] = 1.;
    ckn = 4;
    ckbnds[0] = 1.;
    ckbnds[1] = 1.;
    ckbnds[2] = 1.;
    ckbnds[3] = 1.;
    ckbnds[4] = -1.;
    ckbnds[5] = 1.;
    ckbnds[6] = -1.;
    ckbnds[7] = -1.;
    ckbnds[8] = 1.;
    ckbnds[9] = -1.;
    ckbnds[10] = 1.;
    ckbnds[11] = 1.;

/*     Fetch the FOV definition. */

    getfov_(&c_b1113, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);

/*     Check that no exception was generated. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the parameters returned. */

    chcksc_("SHAPE", shape, "=", ckshap, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chcksc_("FRAME", frame, "=", ckfram, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chckad_("BORESIGHT", bsight, "~", ckbsgt, &c__3, &c_b557, ok, (ftnlen)9, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &ckn, &c__0, ok, (ftnlen)1, (ftnlen)1);
    if (ckn == n) {

/*        Loop over all of the boundary vectors returned and */
/*        check them for any errors. */

	i__1 = ckn;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    s_copy(bndnam, "BOUNDS[#]", (ftnlen)81, (ftnlen)9);
	    repmi_(bndnam, "#", &i__, bndnam, (ftnlen)81, (ftnlen)1, (ftnlen)
		    81);
	    chckad_(bndnam, &bounds[(i__2 = i__ * 3 - 3) < 30 && 0 <= i__2 ? 
		    i__2 : s_rnge("bounds", i__2, "f_getfv2__", (ftnlen)2599)]
		    , "~", &ckbnds[(i__3 = i__ * 3 - 3) < 30 && 0 <= i__3 ? 
		    i__3 : s_rnge("ckbnds", i__3, "f_getfv2__", (ftnlen)2599)]
		    , &c__3, &c_b557, ok, (ftnlen)81, (ftnlen)1);
	}
    }

/* --- Case #32: ----------------------------------------------------- */

    tcase_("Old-Style POLYGON CORNERS-SET Specification", (ftnlen)43);

/*     The -33100 ID Code contains the definition of a polygon with */
/*     the following characteristics: */

    s_copy(ckshap, "POLYGON", (ftnlen)81, (ftnlen)7);
    s_copy(ckfram, "33100-FRAME", (ftnlen)81, (ftnlen)11);
    ckbsgt[0] = 0.;
    ckbsgt[1] = 0.;
    ckbsgt[2] = 1.;
    ckn = 4;
    ckbnds[0] = 1.;
    ckbnds[1] = 1.;
    ckbnds[2] = 1.;
    ckbnds[3] = 1.;
    ckbnds[4] = -1.;
    ckbnds[5] = 1.;
    ckbnds[6] = -1.;
    ckbnds[7] = -1.;
    ckbnds[8] = 1.;
    ckbnds[9] = -1.;
    ckbnds[10] = 1.;
    ckbnds[11] = 1.;

/*     Fetch the FOV definition. */

    getfov_(&c_b1140, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);

/*     Check that no exception was generated. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the parameters returned. */

    chcksc_("SHAPE", shape, "=", ckshap, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chcksc_("FRAME", frame, "=", ckfram, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chckad_("BORESIGHT", bsight, "~", ckbsgt, &c__3, &c_b557, ok, (ftnlen)9, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &ckn, &c__0, ok, (ftnlen)1, (ftnlen)1);
    if (ckn == n) {

/*        Loop over all of the boundary vectors returned and */
/*        check them for any errors. */

	i__1 = ckn;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    s_copy(bndnam, "BOUNDS[#]", (ftnlen)81, (ftnlen)9);
	    repmi_(bndnam, "#", &i__, bndnam, (ftnlen)81, (ftnlen)1, (ftnlen)
		    81);
	    chckad_(bndnam, &bounds[(i__2 = i__ * 3 - 3) < 30 && 0 <= i__2 ? 
		    i__2 : s_rnge("bounds", i__2, "f_getfv2__", (ftnlen)2673)]
		    , "~", &ckbnds[(i__3 = i__ * 3 - 3) < 30 && 0 <= i__3 ? 
		    i__3 : s_rnge("ckbnds", i__3, "f_getfv2__", (ftnlen)2673)]
		    , &c__3, &c_b557, ok, (ftnlen)81, (ftnlen)1);
	}
    }

/* --- Case #33: ----------------------------------------------------- */

    tcase_("Conflict POLYGON CORNERS-SET Specification", (ftnlen)42);

/*     The -33200 ID Code contains the definition of a polygon with */
/*     the following characteristics: */

    s_copy(ckshap, "POLYGON", (ftnlen)81, (ftnlen)7);
    s_copy(ckfram, "33200-FRAME", (ftnlen)81, (ftnlen)11);
    ckbsgt[0] = 0.;
    ckbsgt[1] = 0.;
    ckbsgt[2] = 1.;
    ckn = 4;
    ckbnds[0] = 2.;
    ckbnds[1] = 2.;
    ckbnds[2] = 1.;
    ckbnds[3] = 2.;
    ckbnds[4] = -2.;
    ckbnds[5] = 1.;
    ckbnds[6] = -2.;
    ckbnds[7] = -2.;
    ckbnds[8] = 1.;
    ckbnds[9] = -2.;
    ckbnds[10] = 2.;
    ckbnds[11] = 1.;

/*     Fetch the FOV definition. */

    getfov_(&c_b1167, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);

/*     Check that no exception was generated. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the parameters returned. */

    chcksc_("SHAPE", shape, "=", ckshap, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chcksc_("FRAME", frame, "=", ckfram, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chckad_("BORESIGHT", bsight, "~", ckbsgt, &c__3, &c_b557, ok, (ftnlen)9, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &ckn, &c__0, ok, (ftnlen)1, (ftnlen)1);
    if (ckn == n) {

/*        Loop over all of the boundary vectors returned and */
/*        check them for any errors. */

	i__1 = ckn;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    s_copy(bndnam, "BOUNDS[#]", (ftnlen)81, (ftnlen)9);
	    repmi_(bndnam, "#", &i__, bndnam, (ftnlen)81, (ftnlen)1, (ftnlen)
		    81);
	    chckad_(bndnam, &bounds[(i__2 = i__ * 3 - 3) < 30 && 0 <= i__2 ? 
		    i__2 : s_rnge("bounds", i__2, "f_getfv2__", (ftnlen)2748)]
		    , "~", &ckbnds[(i__3 = i__ * 3 - 3) < 30 && 0 <= i__3 ? 
		    i__3 : s_rnge("ckbnds", i__3, "f_getfv2__", (ftnlen)2748)]
		    , &c__3, &c_b557, ok, (ftnlen)81, (ftnlen)1);
	}
    }

/* --- Case #34: ----------------------------------------------------- */

    tcase_("Bad Angles Shape Specification", (ftnlen)30);

/*     Fetch the FOV definition with ID code -40000 since it contains */
/*     a the shape 'BOGUS-SHAPE' and the ANGLES class spec. */

    getfov_(&c_b1192, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);

/*     Check for the exception. */

    chckxc_(&c_true, "SPICE(SHAPENOTSUPPORTED)", ok, (ftnlen)24);

/* --- Case #35: ----------------------------------------------------- */

    tcase_("Unsupported FOV Class Specification", (ftnlen)35);

/*     Fetch the FOV definition with ID code -40100 since it contains */
/*     the class spec 'BOGUS-SPEC'. */

    getfov_(&c_b1197, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);

/*     Check for the exception. */

    chckxc_(&c_true, "SPICE(UNSUPPORTEDSPEC)", ok, (ftnlen)22);

/* --- Case #36: ----------------------------------------------------- */

    tcase_("Missing FOV Reference Vector Exception", (ftnlen)38);

/*     Fetch the FOV definition with ID code -41000 since it is */
/*     missing the FOV_REF_VECTOR keyword. */

    getfov_(&c_b1202, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);

/*     Check for the exception. */

    chckxc_(&c_true, "SPICE(REFVECTORMISSING)", ok, (ftnlen)23);

/* --- Case #37: ----------------------------------------------------- */

    tcase_("Improperly Defined Reference Vector", (ftnlen)35);

/*     Fetch the FOV definition with ID code -41100 since it contains */
/*     a FOV_REF_VECTOR keyword with only 2 DP components. */

    getfov_(&c_b1207, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);

/*     Check for the exception. */

    chckxc_(&c_true, "SPICE(BADREFVECTORSPEC)", ok, (ftnlen)23);

/*     Fetch the FOV definition with ID code -41200 since it contains */
/*     a FOV_REF_VECTOR keyword with 3 character components. */

    getfov_(&c_b1211, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);

/*     Check for the exception. */

    chckxc_(&c_true, "SPICE(BADREFVECTORSPEC)", ok, (ftnlen)23);

/*     Fetch the FOV definition with ID code -41300 since it contains */
/*     a FOV_REF_VECTOR that is parallel to the BORESIGHT. */

    getfov_(&c_b1215, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);

/*     Check for the exception. */

    chckxc_(&c_true, "SPICE(BADREFVECTORSPEC)", ok, (ftnlen)23);

/* --- Case #38: ----------------------------------------------------- */

    tcase_("Missing Reference Angle Exception", (ftnlen)33);

/*     Fetch the FOV definition with ID code -42000 since it is missing */
/*     the FOV_REF_ANGLE keyword. */

    getfov_(&c_b1220, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);

/*     Check for the exception. */

    chckxc_(&c_true, "SPICE(REFANGLEMISSING)", ok, (ftnlen)22);

/* --- Case #39: ----------------------------------------------------- */

    tcase_("Missing Angle Units Exception", (ftnlen)29);

/*     Fetch the FOV definition with ID code -43000 since it is missing */
/*     the FOV_ANGLE_UNITS keyword. */

    getfov_(&c_b1225, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);

/*     Check for the exception. */

    chckxc_(&c_true, "SPICE(UNITSMISSING)", ok, (ftnlen)19);

/* --- Case #40: ----------------------------------------------------- */

    tcase_("Ellipse ANGLE missing Cross Angle Exception", (ftnlen)43);

/*     Fetch the FOV definition with ID code -44000 since it refers */
/*     to the shape ELLIPSE which requires FOV_CROSS_ANGLE, which is */
/*     missing. */

    getfov_(&c_b1230, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);

/*     Check for the exception. */

    chckxc_(&c_true, "SPICE(CROSSANGLEMISSING)", ok, (ftnlen)24);

/* --- Case #41: ----------------------------------------------------- */

    tcase_("Rectangle ANGLE missing Cross Angle Exception", (ftnlen)45);

/*     Fetch the FOV definition with ID code -45000 since it refers */
/*     to the shape RECTANGLE which requires FOV_CROSS_ANGLE, which */
/*     is absent. */

    getfov_(&c_b1235, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);

/*     Check for the exception. */

    chckxc_(&c_true, "SPICE(CROSSANGLEMISSING)", ok, (ftnlen)24);

/* --- Case #42: ----------------------------------------------------- */

    tcase_("Rectangle ANGLE Degenerate Boundary Exception", (ftnlen)45);

/*     Fetch the FOV definition with ID code -45100 since it contains */
/*     reference and cross angles near 90.0 degrees. */

    getfov_(&c_b1240, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);

/*     Check for the exception. */

    chckxc_(&c_true, "SPICE(BADBOUNDARY)", ok, (ftnlen)18);

/* --- Case #43: ----------------------------------------------------- */

    tcase_("Circle ANGLE Room Failure Boundary Exception", (ftnlen)44);

/*     Fetch the FOV definition for -46000.  It is circular, so */
/*     since we are testing the ROOM exception, report we have */
/*     only ROOM for 0 boundary vectors. */

    getfov_(&c_b1245, &c__0, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);

/*     Check for the exception. */

    chckxc_(&c_true, "SPICE(BOUNDARYTOOBIG)", ok, (ftnlen)21);

/* --- Case #44: ----------------------------------------------------- */

    tcase_("Ellipse ANGLE Room Failure Boundary Exception", (ftnlen)45);

/*     Fetch the FOV definition with ID code -46100.  It is elliptical, */
/*     so since we are testing the ROOM exception, report we have only */
/*     ROOM for 0 boundary vectors. */

    getfov_(&c_b1250, &c__0, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);

/*     Check for the exception. */

    chckxc_(&c_true, "SPICE(BOUNDARYTOOBIG)", ok, (ftnlen)21);

/* --- Case #45: ----------------------------------------------------- */

    tcase_("Rectangle ANGLE Room Failure Boundary Exception", (ftnlen)47);

/*     Fetch the FOV definition with ID code -46200. It is rectangular */
/*     so since we are testing the ROOM exception, report we have only */
/*     ROOM for 0 boundary vectors. */

    getfov_(&c_b1255, &c__0, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);

/*     Check for the exception. */

    chckxc_(&c_true, "SPICE(BOUNDARYTOOBIG)", ok, (ftnlen)21);

/* --- Case #46: ----------------------------------------------------- */

    tcase_("Nominal CIRCLE ANGLES Specification", (ftnlen)35);

/*     The -46000 ID Code contains the definition of a circle with */
/*     the following characteristics: */

    s_copy(ckshap, "CIRCLE", (ftnlen)81, (ftnlen)6);
    s_copy(ckfram, "46000-FRAME", (ftnlen)81, (ftnlen)11);
    ckbsgt[0] = 0.;
    ckbsgt[1] = 0.;
    ckbsgt[2] = 1.;
    ckn = 1;
    ckbnds[0] = 0.;
    ckbnds[1] = sqrt(2.) / 2.;
    ckbnds[2] = sqrt(2.) / 2.;

/*     Fetch the FOV definition. */

    getfov_(&c_b1245, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);

/*     Check that no exception was generated. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the parameters returned. */

    chcksc_("SHAPE", shape, "=", ckshap, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chcksc_("FRAME", frame, "=", ckfram, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chckad_("BORESIGHT", bsight, "~", ckbsgt, &c__3, &c_b557, ok, (ftnlen)9, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &ckn, &c__0, ok, (ftnlen)1, (ftnlen)1);
    if (ckn == n) {

/*        Loop over all of the boundary vectors returned and */
/*        check them for any errors. */

	i__1 = ckn;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    s_copy(bndnam, "BOUNDS[#]", (ftnlen)81, (ftnlen)9);
	    repmi_(bndnam, "#", &i__, bndnam, (ftnlen)81, (ftnlen)1, (ftnlen)
		    81);
	    chckad_(bndnam, &bounds[(i__2 = i__ * 3 - 3) < 30 && 0 <= i__2 ? 
		    i__2 : s_rnge("bounds", i__2, "f_getfv2__", (ftnlen)3029)]
		    , "~", &ckbnds[(i__3 = i__ * 3 - 3) < 30 && 0 <= i__3 ? 
		    i__3 : s_rnge("ckbnds", i__3, "f_getfv2__", (ftnlen)3029)]
		    , &c__3, &c_b557, ok, (ftnlen)81, (ftnlen)1);
	}
    }

/* --- Case #47: ----------------------------------------------------- */

    tcase_("Nominal ELLIPSE ANGLES Specification", (ftnlen)36);

/*     The -46100 ID Code contains the definition of an ellipse with */
/*     the following characteristics: */

    s_copy(ckshap, "ELLIPSE", (ftnlen)81, (ftnlen)7);
    s_copy(ckfram, "46100-FRAME", (ftnlen)81, (ftnlen)11);
    ckbsgt[0] = 0.;
    ckbsgt[1] = 0.;
    ckbsgt[2] = 1.;
    ckn = 2;
    ckbnds[0] = 0.;
    ckbnds[1] = sqrt(2.) / 2.;
    ckbnds[2] = sqrt(2.) / 2.;
    ckbnds[3] = -.5;
    ckbnds[4] = 0.;
    ckbnds[5] = sqrt(3.) / 2.;

/*     Fetch the FOV definition. */

    getfov_(&c_b1250, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);

/*     Check that no exception was generated. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the parameters returned. */

    chcksc_("SHAPE", shape, "=", ckshap, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chcksc_("FRAME", frame, "=", ckfram, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chckad_("BORESIGHT", bsight, "~", ckbsgt, &c__3, &c_b557, ok, (ftnlen)9, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &ckn, &c__0, ok, (ftnlen)1, (ftnlen)1);
    if (ckn == n) {

/*        Loop over all of the boundary vectors returned and */
/*        check them for any errors. */

	i__1 = ckn;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    s_copy(bndnam, "BOUNDS[#]", (ftnlen)81, (ftnlen)9);
	    repmi_(bndnam, "#", &i__, bndnam, (ftnlen)81, (ftnlen)1, (ftnlen)
		    81);
	    chckad_(bndnam, &bounds[(i__2 = i__ * 3 - 3) < 30 && 0 <= i__2 ? 
		    i__2 : s_rnge("bounds", i__2, "f_getfv2__", (ftnlen)3095)]
		    , "~", &ckbnds[(i__3 = i__ * 3 - 3) < 30 && 0 <= i__3 ? 
		    i__3 : s_rnge("ckbnds", i__3, "f_getfv2__", (ftnlen)3095)]
		    , &c__3, &c_b557, ok, (ftnlen)81, (ftnlen)1);
	}
    }

/* --- Case #16: ----------------------------------------------------- */

    tcase_("Nominal RECTANGLE CORNERS Specification", (ftnlen)39);

/*     The -46200 ID Code contains the definition of a rectangle with */
/*     the following characteristics: */

    s_copy(ckshap, "RECTANGLE", (ftnlen)81, (ftnlen)9);
    s_copy(ckfram, "46200-FRAME", (ftnlen)81, (ftnlen)11);
    ckbsgt[0] = 0.;
    ckbsgt[1] = 0.;
    ckbsgt[2] = 1.;
    ckn = 4;
    ckbnds[0] = -sqrt(3.) / sqrt(5.);
    ckbnds[1] = 1. / sqrt(5.);
    ckbnds[2] = 1. / sqrt(5.);
    ckbnds[3] = -sqrt(3.) / sqrt(5.);
    ckbnds[4] = -1. / sqrt(5.);
    ckbnds[5] = 1. / sqrt(5.);
    ckbnds[6] = sqrt(3.) / sqrt(5.);
    ckbnds[7] = -1. / sqrt(5.);
    ckbnds[8] = 1. / sqrt(5.);
    ckbnds[9] = sqrt(3.) / sqrt(5.);
    ckbnds[10] = 1. / sqrt(5.);
    ckbnds[11] = 1. / sqrt(5.);

/*     Fetch the FOV definition. */

    getfov_(&c_b1255, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);

/*     Check that no exception was generated. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the parameters returned. */

    chcksc_("SHAPE", shape, "=", ckshap, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chcksc_("FRAME", frame, "=", ckfram, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chckad_("BORESIGHT", bsight, "~", ckbsgt, &c__3, &c_b557, ok, (ftnlen)9, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &ckn, &c__0, ok, (ftnlen)1, (ftnlen)1);
    if (ckn == n) {

/*        Loop over all of the boundary vectors returned and */
/*        check them for any errors. */

	i__1 = ckn;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    s_copy(bndnam, "BOUNDS[#]", (ftnlen)81, (ftnlen)9);
	    repmi_(bndnam, "#", &i__, bndnam, (ftnlen)81, (ftnlen)1, (ftnlen)
		    81);
	    chckad_(bndnam, &bounds[(i__2 = i__ * 3 - 3) < 30 && 0 <= i__2 ? 
		    i__2 : s_rnge("bounds", i__2, "f_getfv2__", (ftnlen)3169)]
		    , "~", &ckbnds[(i__3 = i__ * 3 - 3) < 30 && 0 <= i__3 ? 
		    i__3 : s_rnge("ckbnds", i__3, "f_getfv2__", (ftnlen)3169)]
		    , &c__3, &c_b557, ok, (ftnlen)81, (ftnlen)1);
	}
    }

/* --- Case #17: ----------------------------------------------------- */

    tcase_("RECTANGLE CORNERS Specification: non-unit REFVEC", (ftnlen)48);

/*     The -46201 ID Code contains the definition of a rectangle with */
/*     the following characteristics: */

    s_copy(ckshap, "RECTANGLE", (ftnlen)81, (ftnlen)9);
    s_copy(ckfram, "46201-FRAME", (ftnlen)81, (ftnlen)11);
    ckbsgt[0] = 0.;
    ckbsgt[1] = 0.;
    ckbsgt[2] = 1.;
    ckn = 4;
    ckbnds[0] = -sqrt(3.) / sqrt(5.);
    ckbnds[1] = 1. / sqrt(5.);
    ckbnds[2] = 1. / sqrt(5.);
    ckbnds[3] = -sqrt(3.) / sqrt(5.);
    ckbnds[4] = -1. / sqrt(5.);
    ckbnds[5] = 1. / sqrt(5.);
    ckbnds[6] = sqrt(3.) / sqrt(5.);
    ckbnds[7] = -1. / sqrt(5.);
    ckbnds[8] = 1. / sqrt(5.);
    ckbnds[9] = sqrt(3.) / sqrt(5.);
    ckbnds[10] = 1. / sqrt(5.);
    ckbnds[11] = 1. / sqrt(5.);

/*     Fetch the FOV definition. */

    getfov_(&c_b1343, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);

/*     Check that no exception was generated. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the parameters returned. */

    chcksc_("SHAPE", shape, "=", ckshap, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chcksc_("FRAME", frame, "=", ckfram, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chckad_("BORESIGHT", bsight, "~", ckbsgt, &c__3, &c_b557, ok, (ftnlen)9, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &ckn, &c__0, ok, (ftnlen)1, (ftnlen)1);
    if (ckn == n) {

/*        Loop over all of the boundary vectors returned and */
/*        check them for any errors. */

	i__1 = ckn;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    s_copy(bndnam, "BOUNDS[#]", (ftnlen)81, (ftnlen)9);
	    repmi_(bndnam, "#", &i__, bndnam, (ftnlen)81, (ftnlen)1, (ftnlen)
		    81);
	    chckad_(bndnam, &bounds[(i__2 = i__ * 3 - 3) < 30 && 0 <= i__2 ? 
		    i__2 : s_rnge("bounds", i__2, "f_getfv2__", (ftnlen)3243)]
		    , "~", &ckbnds[(i__3 = i__ * 3 - 3) < 30 && 0 <= i__3 ? 
		    i__3 : s_rnge("ckbnds", i__3, "f_getfv2__", (ftnlen)3243)]
		    , &c__3, &c_b557, ok, (ftnlen)81, (ftnlen)1);
	}
    }

/* --- Case #18: ----------------------------------------------------- */

    tcase_("RECTANGLE CORNERS: non-normal REF and BSIGHT", (ftnlen)44);

/*     The -46201 ID Code contains the definition of a rectangle with */
/*     the following characteristics: */

    s_copy(ckshap, "RECTANGLE", (ftnlen)81, (ftnlen)9);
    s_copy(ckfram, "46202-FRAME", (ftnlen)81, (ftnlen)11);
    ckbsgt[0] = 0.;
    ckbsgt[1] = 0.;
    ckbsgt[2] = 1.;
    ckn = 4;
    ckbnds[0] = -sqrt(3.) / sqrt(5.);
    ckbnds[1] = 1. / sqrt(5.);
    ckbnds[2] = 1. / sqrt(5.);
    ckbnds[3] = -sqrt(3.) / sqrt(5.);
    ckbnds[4] = -1. / sqrt(5.);
    ckbnds[5] = 1. / sqrt(5.);
    ckbnds[6] = sqrt(3.) / sqrt(5.);
    ckbnds[7] = -1. / sqrt(5.);
    ckbnds[8] = 1. / sqrt(5.);
    ckbnds[9] = sqrt(3.) / sqrt(5.);
    ckbnds[10] = 1. / sqrt(5.);
    ckbnds[11] = 1. / sqrt(5.);

/*     Fetch the FOV definition. */

    getfov_(&c_b1370, &c__10, shape, frame, bsight, &n, bounds, (ftnlen)81, (
	    ftnlen)81);

/*     Check that no exception was generated. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the parameters returned. */

    chcksc_("SHAPE", shape, "=", ckshap, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chcksc_("FRAME", frame, "=", ckfram, ok, (ftnlen)5, (ftnlen)81, (ftnlen)1,
	     (ftnlen)81);
    chckad_("BORESIGHT", bsight, "~", ckbsgt, &c__3, &c_b557, ok, (ftnlen)9, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &ckn, &c__0, ok, (ftnlen)1, (ftnlen)1);
    if (ckn == n) {

/*        Loop over all of the boundary vectors returned and */
/*        check them for any errors. */

	i__1 = ckn;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    s_copy(bndnam, "BOUNDS[#]", (ftnlen)81, (ftnlen)9);
	    repmi_(bndnam, "#", &i__, bndnam, (ftnlen)81, (ftnlen)1, (ftnlen)
		    81);
	    chckad_(bndnam, &bounds[(i__2 = i__ * 3 - 3) < 30 && 0 <= i__2 ? 
		    i__2 : s_rnge("bounds", i__2, "f_getfv2__", (ftnlen)3317)]
		    , "~", &ckbnds[(i__3 = i__ * 3 - 3) < 30 && 0 <= i__3 ? 
		    i__3 : s_rnge("ckbnds", i__3, "f_getfv2__", (ftnlen)3317)]
		    , &c__3, &c_b557, ok, (ftnlen)81, (ftnlen)1);
	}
    }

/*     Clear the kernel pool. */

    clpool_();

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_getfv2__ */

