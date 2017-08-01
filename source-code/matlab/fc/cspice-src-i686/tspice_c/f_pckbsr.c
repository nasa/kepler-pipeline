/* f_pckbsr.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__1 = 1;
static logical c_false = FALSE_;
static logical c_true = TRUE_;
static integer c__0 = 0;
static integer c__3 = 3;
static doublereal c_b31 = 0.;
static integer c__2 = 2;

/* $Procedure  F_PCKBSR ( Family of tests for PCKBSR ) */
/* Subroutine */ int f_pckbsr__(logical *ok)
{
    /* Initialized data */

    static char pcks[255*10] = "sfs1.bpc                                    "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                   " "sfs2.bpc                                  "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                     " "sfs3.bpc                                "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                       " "sfs4.bpc                              "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                         " "sfs5.bpc                            "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                           " "sfs6.bpc                          "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                             " "sfs7.bpc                        "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                               " "sfs8.bpc                      "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                                 " "sfs9.bpc                    "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                                   " "sfs10.bpc                 "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                                     ";
    static integer nseg[10] = { 1,50,50,100,110,20,23,23,400,388 };

    /* System generated locals */
    integer i__1, i__2, i__3, i__4, i__5;
    doublereal d__1;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    integer body;
    extern /* Subroutine */ int t_crdesc__(char *, integer *, integer *, 
	    doublereal *, doublereal *, doublereal *, ftnlen);
    char smsg[25];
    integer i__, j;
    doublereal t;
    char segid[40];
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    doublereal descr[5], tbegs[16000];
    extern /* Subroutine */ int repmc_(char *, char *, char *, char *, ftnlen,
	     ftnlen, ftnlen, ftnlen);
    integer pckno, segno;
    doublereal tends[16000];
    logical found;
    extern /* Subroutine */ int repmi_(char *, char *, integer *, char *, 
	    ftnlen, ftnlen, ftnlen), topen_(char *, ftnlen), t_success__(
	    logical *);
    integer handle;
    extern /* Subroutine */ int chcksc_(char *, char *, char *, char *, 
	    logical *, ftnlen, ftnlen, ftnlen, ftnlen), delfil_(char *, 
	    ftnlen), chckxc_(logical *, char *, logical *, ftnlen), chcksi_(
	    char *, integer *, char *, integer *, integer *, logical *, 
	    ftnlen, ftnlen), t_chds__(char *, doublereal *, char *, 
	    doublereal *, integer *, doublereal *, logical *, ftnlen, ftnlen),
	     chcksl_(char *, logical *, logical *, logical *, ftnlen);
    integer hndles[10];
    extern /* Subroutine */ int pcklof_(char *, integer *, ftnlen);
    integer cpyhan[1000];
    char xsegid[40*16000];
    extern /* Subroutine */ int pckbsr_(char *, integer *, integer *, 
	    doublereal *, doublereal *, char *, logical *, ftnlen, ftnlen), 
	    pckuof_(integer *);
    char pckcpy[255*1000];
    doublereal xdescr[80000]	/* was [5][16000] */;
    extern /* Subroutine */ int pcksfs_(integer *, doublereal *, integer *, 
	    doublereal *, char *, logical *, ftnlen), sigerr_(char *, ftnlen);
    extern logical return_(void);
    integer ids[16000];
    extern /* Subroutine */ int t_crdaf__(char *, char *, integer *, integer *
	    , doublereal *, doublereal *, char *, ftnlen, ftnlen, ftnlen);

/* $ Abstract */

/*     This routine tests the PCK segment selection and buffering system, */
/*     which is implemented by PCKSFS. */


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

/* $ Version */

/*   Version 2.0.0 30-SEP-2005 (NJB) */

/*      Updated to work with the SPICELIB suite of routines */
/*      contained in PCKBSR.  Formerly this routine tested a derived, */
/*      scaled, down family of routines. */

/*   Version 1.0.0 29-NOV-2001 (NJB) */

/* -& */

/*     SPICELIB functions */


/*     Local parameters */


/*     The number of segments in the respective PCK files: */


/*     Other parameters: */


/*     Local variables */


/*     Saved variables */


/*     Initial values */


/*     Begin every test family with an open call. */

    topen_("F_PCKBSR", (ftnlen)8);
    tcase_("The first PCK file contains 1 segment for body 1. Make sure we c"
	    "an look up data from this file.", (ftnlen)95);

/*     Create the first PCK file. */

    body = 1;
    tbegs[0] = 1e4;
    tends[0] = 10001.;
    pckno = 1;
    s_copy(xsegid, "File: # Segno: #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid, "#", pcks, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)255, (
	    ftnlen)40);
    repmi_(xsegid, "#", &c__1, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_crdaf__("PCK", pcks, nseg, &body, tbegs, tends, xsegid, (ftnlen)3, (
	    ftnlen)255, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    pcklof_(pcks, hndles, (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    d__1 = tbegs[0] + .5f;
    pcksfs_(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     In this case, the segment should be found.  Make sure we get */
/*     back the right handle and segment identifier. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", hndles, &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1,
	     (ftnlen)40);

/*     Check the descriptor as well.  However, don't check the */
/*     segment addresses. */

    t_crdesc__("PCK", &c__1, &body, tbegs, tends, xdescr, (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_chds__("DESCR", descr, "=", xdescr, &c__3, &c_b31, ok, (ftnlen)5, (
	    ftnlen)1);
    tcase_("Try to look up data for a different body in PCK 1.  Also look up"
	    " data for body 1 for a time which is not covered.", (ftnlen)113);
    d__1 = tbegs[0] + .5f;
    pcksfs_(&c__2, &d__1, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     In this case, the segment should not be found. */

    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    d__1 = tbegs[0] + 10;
    pcksfs_(&c__1, &d__1, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     In this case, the segment should not be found. */

    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    tcase_("Create a second PCK containing data for body 1 and body 2.  Load"
	    " this PCK, then look up a state covered by the new file.", (
	    ftnlen)120);
    body = 1;
    pckno = 2;
    i__2 = nseg[(i__1 = pckno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("nseg", 
	    i__1, "f_pckbsr__", (ftnlen)285)];
    for (i__ = 1; i__ <= i__2; ++i__) {
	if (i__ <= nseg[(i__1 = pckno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge(
		"nseg", i__1, "f_pckbsr__", (ftnlen)287)] / 2) {
	    ids[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("ids", 
		    i__1, "f_pckbsr__", (ftnlen)288)] = 2;
	} else {
	    ids[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("ids", 
		    i__1, "f_pckbsr__", (ftnlen)290)] = 1;
	}
	tbegs[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs", 
		i__1, "f_pckbsr__", (ftnlen)293)] = (doublereal) (pckno * 
		10000 + i__ - 1);
	tends[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tends", 
		i__1, "f_pckbsr__", (ftnlen)294)] = tbegs[(i__3 = i__ - 1) < 
		16000 && 0 <= i__3 ? i__3 : s_rnge("tbegs", i__3, "f_pckbsr__"
		, (ftnlen)294)] + 1;
	s_copy(xsegid + ((i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_pckbsr__", (ftnlen)296)) * 40, 
		"File: # Segno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid + ((i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_pckbsr__", (ftnlen)298)) * 40, 
		"#", pcks + ((i__3 = pckno - 1) < 10 && 0 <= i__3 ? i__3 : 
		s_rnge("pcks", i__3, "f_pckbsr__", (ftnlen)298)) * 255, 
		xsegid + ((i__4 = i__ - 1) < 16000 && 0 <= i__4 ? i__4 : 
		s_rnge("xsegid", i__4, "f_pckbsr__", (ftnlen)298)) * 40, (
		ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
	repmi_(xsegid + ((i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_pckbsr__", (ftnlen)299)) * 40, 
		"#", &i__, xsegid + ((i__3 = i__ - 1) < 16000 && 0 <= i__3 ? 
		i__3 : s_rnge("xsegid", i__3, "f_pckbsr__", (ftnlen)299)) * 
		40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    t_crdaf__("PCK", pcks + ((i__2 = pckno - 1) < 10 && 0 <= i__2 ? i__2 : 
	    s_rnge("pcks", i__2, "f_pckbsr__", (ftnlen)305)) * 255, &nseg[(
	    i__1 = pckno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("nseg", i__1, 
	    "f_pckbsr__", (ftnlen)305)], ids, tbegs, tends, xsegid, (ftnlen)3,
	     (ftnlen)255, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    pcklof_(pcks + ((i__2 = pckno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge(
	    "pcks", i__2, "f_pckbsr__", (ftnlen)310)) * 255, &hndles[(i__1 = 
	    pckno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("hndles", i__1, 
	    "f_pckbsr__", (ftnlen)310)], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    segno = nseg[(i__2 = pckno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("nseg", 
	    i__2, "f_pckbsr__", (ftnlen)313)];
    d__1 = tbegs[(i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
	    "tbegs", i__2, "f_pckbsr__", (ftnlen)315)] + .5f;
    pcksfs_(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     In this case, the segment should be found.  Make sure we get */
/*     back the right handle and segment identifier. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__2 = pckno - 1) < 10 && 0 <= 
	    i__2 ? i__2 : s_rnge("hndles", i__2, "f_pckbsr__", (ftnlen)324)], 
	    &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + ((i__2 = segno - 1) < 16000 && 0 <= 
	    i__2 ? i__2 : s_rnge("xsegid", i__2, "f_pckbsr__", (ftnlen)325)) *
	     40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (ftnlen)40);

/*     Check the descriptor as well.  However, don't check the */
/*     segment addresses. */

    t_crdesc__("PCK", &segno, &body, &tbegs[(i__2 = segno - 1) < 16000 && 0 <=
	     i__2 ? i__2 : s_rnge("tbegs", i__2, "f_pckbsr__", (ftnlen)331)], 
	    &tends[(i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "tends", i__1, "f_pckbsr__", (ftnlen)331)], &xdescr[(i__3 = segno 
	    * 5 - 5) < 80000 && 0 <= i__3 ? i__3 : s_rnge("xdescr", i__3, 
	    "f_pckbsr__", (ftnlen)331)], (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[(i__2 = segno * 5 - 5) < 80000 && 0 
	    <= i__2 ? i__2 : s_rnge("xdescr", i__2, "f_pckbsr__", (ftnlen)335)
	    ], &c__3, &c_b31, ok, (ftnlen)5, (ftnlen)1);
    tcase_("Look up data for body 2.  This should cause an OLD FILES search.",
	     (ftnlen)64);
    body = 2;
    pckno = 2;
    segno = 1;
    d__1 = tbegs[0] + .5f;
    pcksfs_(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     In this case, the segment should be found.  Make sure we get */
/*     back the right handle and segment identifier. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__2 = pckno - 1) < 10 && 0 <= 
	    i__2 ? i__2 : s_rnge("hndles", i__2, "f_pckbsr__", (ftnlen)357)], 
	    &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + ((i__2 = segno - 1) < 16000 && 0 <= 
	    i__2 ? i__2 : s_rnge("xsegid", i__2, "f_pckbsr__", (ftnlen)358)) *
	     40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (ftnlen)40);

/*     Check the descriptor as well.  However, don't check the */
/*     segment addresses. */

    t_crdesc__("PCK", &segno, &body, &tbegs[(i__2 = segno - 1) < 16000 && 0 <=
	     i__2 ? i__2 : s_rnge("tbegs", i__2, "f_pckbsr__", (ftnlen)364)], 
	    &tends[(i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "tends", i__1, "f_pckbsr__", (ftnlen)364)], &xdescr[(i__3 = segno 
	    * 5 - 5) < 80000 && 0 <= i__3 ? i__3 : s_rnge("xdescr", i__3, 
	    "f_pckbsr__", (ftnlen)364)], (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[(i__2 = segno * 5 - 5) < 80000 && 0 
	    <= i__2 ? i__2 : s_rnge("xdescr", i__2, "f_pckbsr__", (ftnlen)368)
	    ], &c__3, &c_b31, ok, (ftnlen)5, (ftnlen)1);
    tcase_("Create a third PCK containing data for body 3. Load this PCK, th"
	    "en look up a state covered by the new file. This should cause th"
	    "e segment list for body 1 to get dumped.", (ftnlen)168);
    body = 3;
    pckno = 3;
    i__1 = nseg[(i__2 = pckno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("nseg", 
	    i__2, "f_pckbsr__", (ftnlen)381)];
    for (i__ = 1; i__ <= i__1; ++i__) {
	ids[(i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("ids", i__2,
		 "f_pckbsr__", (ftnlen)383)] = body;
	tbegs[(i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("tbegs", 
		i__2, "f_pckbsr__", (ftnlen)385)] = (doublereal) (pckno * 
		10000 + i__ - 1);
	tends[(i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("tends", 
		i__2, "f_pckbsr__", (ftnlen)386)] = tbegs[(i__3 = i__ - 1) < 
		16000 && 0 <= i__3 ? i__3 : s_rnge("tbegs", i__3, "f_pckbsr__"
		, (ftnlen)386)] + 1;
	s_copy(xsegid + ((i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_pckbsr__", (ftnlen)388)) * 40, 
		"File: # Segno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid + ((i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_pckbsr__", (ftnlen)390)) * 40, 
		"#", pcks + ((i__3 = pckno - 1) < 10 && 0 <= i__3 ? i__3 : 
		s_rnge("pcks", i__3, "f_pckbsr__", (ftnlen)390)) * 255, 
		xsegid + ((i__4 = i__ - 1) < 16000 && 0 <= i__4 ? i__4 : 
		s_rnge("xsegid", i__4, "f_pckbsr__", (ftnlen)390)) * 40, (
		ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
	repmi_(xsegid + ((i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_pckbsr__", (ftnlen)391)) * 40, 
		"#", &i__, xsegid + ((i__3 = i__ - 1) < 16000 && 0 <= i__3 ? 
		i__3 : s_rnge("xsegid", i__3, "f_pckbsr__", (ftnlen)391)) * 
		40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    t_crdaf__("PCK", pcks + ((i__1 = pckno - 1) < 10 && 0 <= i__1 ? i__1 : 
	    s_rnge("pcks", i__1, "f_pckbsr__", (ftnlen)397)) * 255, &nseg[(
	    i__2 = pckno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("nseg", i__2, 
	    "f_pckbsr__", (ftnlen)397)], ids, tbegs, tends, xsegid, (ftnlen)3,
	     (ftnlen)255, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    pcklof_(pcks + ((i__1 = pckno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge(
	    "pcks", i__1, "f_pckbsr__", (ftnlen)402)) * 255, &hndles[(i__2 = 
	    pckno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("hndles", i__2, 
	    "f_pckbsr__", (ftnlen)402)], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    segno = nseg[(i__1 = pckno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("nseg", 
	    i__1, "f_pckbsr__", (ftnlen)405)];
    d__1 = tbegs[(i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "tbegs", i__1, "f_pckbsr__", (ftnlen)407)] + .5f;
    pcksfs_(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     In this case, the segment should be found.  Make sure we get */
/*     back the right handle and segment identifier. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = pckno - 1) < 10 && 0 <= 
	    i__1 ? i__1 : s_rnge("hndles", i__1, "f_pckbsr__", (ftnlen)416)], 
	    &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + ((i__1 = segno - 1) < 16000 && 0 <= 
	    i__1 ? i__1 : s_rnge("xsegid", i__1, "f_pckbsr__", (ftnlen)417)) *
	     40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (ftnlen)40);

/*     Check the descriptor as well.  However, don't check the */
/*     segment addresses. */

    t_crdesc__("PCK", &segno, &body, &tbegs[(i__1 = segno - 1) < 16000 && 0 <=
	     i__1 ? i__1 : s_rnge("tbegs", i__1, "f_pckbsr__", (ftnlen)423)], 
	    &tends[(i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
	    "tends", i__2, "f_pckbsr__", (ftnlen)423)], &xdescr[(i__3 = segno 
	    * 5 - 5) < 80000 && 0 <= i__3 ? i__3 : s_rnge("xdescr", i__3, 
	    "f_pckbsr__", (ftnlen)423)], (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[(i__1 = segno * 5 - 5) < 80000 && 0 
	    <= i__1 ? i__1 : s_rnge("xdescr", i__1, "f_pckbsr__", (ftnlen)427)
	    ], &c__3, &c_b31, ok, (ftnlen)5, (ftnlen)1);
    tcase_("Create another PCK for body 1 and load it. The segment count in "
	    "this file is such that all other body lists must be dumped to ma"
	    "ke room. Then make a request that is satisfied by PCK 1. The seg"
	    "ment in PCK 1 cannot be added to the segment table.", (ftnlen)243)
	    ;
    body = 1;
    pckno = 4;
    i__2 = nseg[(i__1 = pckno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("nseg", 
	    i__1, "f_pckbsr__", (ftnlen)446)];
    for (i__ = 1; i__ <= i__2; ++i__) {
	ids[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("ids", i__1,
		 "f_pckbsr__", (ftnlen)448)] = body;
	tbegs[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs", 
		i__1, "f_pckbsr__", (ftnlen)450)] = (doublereal) (pckno * 
		10000 + i__ - 1);
	tends[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tends", 
		i__1, "f_pckbsr__", (ftnlen)451)] = tbegs[(i__3 = i__ - 1) < 
		16000 && 0 <= i__3 ? i__3 : s_rnge("tbegs", i__3, "f_pckbsr__"
		, (ftnlen)451)] + 1;
	s_copy(xsegid + ((i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_pckbsr__", (ftnlen)453)) * 40, 
		"File: # Segno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid + ((i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_pckbsr__", (ftnlen)455)) * 40, 
		"#", pcks + ((i__3 = pckno - 1) < 10 && 0 <= i__3 ? i__3 : 
		s_rnge("pcks", i__3, "f_pckbsr__", (ftnlen)455)) * 255, 
		xsegid + ((i__4 = i__ - 1) < 16000 && 0 <= i__4 ? i__4 : 
		s_rnge("xsegid", i__4, "f_pckbsr__", (ftnlen)455)) * 40, (
		ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
	repmi_(xsegid + ((i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_pckbsr__", (ftnlen)456)) * 40, 
		"#", &i__, xsegid + ((i__3 = i__ - 1) < 16000 && 0 <= i__3 ? 
		i__3 : s_rnge("xsegid", i__3, "f_pckbsr__", (ftnlen)456)) * 
		40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    t_crdaf__("PCK", pcks + ((i__2 = pckno - 1) < 10 && 0 <= i__2 ? i__2 : 
	    s_rnge("pcks", i__2, "f_pckbsr__", (ftnlen)461)) * 255, &nseg[(
	    i__1 = pckno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("nseg", i__1, 
	    "f_pckbsr__", (ftnlen)461)], ids, tbegs, tends, xsegid, (ftnlen)3,
	     (ftnlen)255, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    pcklof_(pcks + ((i__2 = pckno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge(
	    "pcks", i__2, "f_pckbsr__", (ftnlen)466)) * 255, &hndles[(i__1 = 
	    pckno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("hndles", i__1, 
	    "f_pckbsr__", (ftnlen)466)], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    pckno = 1;
    segno = 1;
    tbegs[(i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("tbegs", 
	    i__2, "f_pckbsr__", (ftnlen)472)] = (doublereal) (pckno * 10000 + 
	    segno - 1);
    tends[(i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("tends", 
	    i__2, "f_pckbsr__", (ftnlen)473)] = (doublereal) (pckno * 10000 + 
	    segno);
    d__1 = tbegs[(i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
	    "tbegs", i__2, "f_pckbsr__", (ftnlen)475)] + .5f;
    pcksfs_(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     In this case, the segment should be found.  Make sure we get */
/*     back the right handle and segment identifier. */

    s_copy(xsegid + ((i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_pckbsr__", (ftnlen)484)) * 40, "File: # Segno"
	    ": #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid + ((i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_pckbsr__", (ftnlen)485)) * 40, "#", pcks + ((
	    i__1 = pckno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("pcks", i__1, 
	    "f_pckbsr__", (ftnlen)485)) * 255, xsegid + ((i__3 = segno - 1) < 
	    16000 && 0 <= i__3 ? i__3 : s_rnge("xsegid", i__3, "f_pckbsr__", (
	    ftnlen)485)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40)
	    ;
    repmi_(xsegid + ((i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_pckbsr__", (ftnlen)486)) * 40, "#", &c__1, 
	    xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_pckbsr__", (ftnlen)486)) * 40, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__2 = pckno - 1) < 10 && 0 <= 
	    i__2 ? i__2 : s_rnge("hndles", i__2, "f_pckbsr__", (ftnlen)490)], 
	    &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + ((i__2 = segno - 1) < 16000 && 0 <= 
	    i__2 ? i__2 : s_rnge("xsegid", i__2, "f_pckbsr__", (ftnlen)491)) *
	     40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (ftnlen)40);

/*     Check the descriptor as well.  However, don't check the */
/*     segment addresses. */

    t_crdesc__("PCK", &segno, &body, &tbegs[(i__2 = segno - 1) < 16000 && 0 <=
	     i__2 ? i__2 : s_rnge("tbegs", i__2, "f_pckbsr__", (ftnlen)497)], 
	    &tends[(i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "tends", i__1, "f_pckbsr__", (ftnlen)497)], &xdescr[(i__3 = segno 
	    * 5 - 5) < 80000 && 0 <= i__3 ? i__3 : s_rnge("xdescr", i__3, 
	    "f_pckbsr__", (ftnlen)497)], (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[(i__2 = segno * 5 - 5) < 80000 && 0 
	    <= i__2 ? i__2 : s_rnge("xdescr", i__2, "f_pckbsr__", (ftnlen)501)
	    ], &c__3, &c_b31, ok, (ftnlen)5, (ftnlen)1);
    tcase_("Start a segment list for body 1 by making a request that is sati"
	    "sfied by PCK 1.  Then build a file (PCK 5) with too many segment"
	    "s for body 1 to be buffered.  Make a request that is satisfied b"
	    "y PCK 5. This tests the logic for searching the subset of a segm"
	    "ent list that must be dumped due to lack of room.", (ftnlen)305);

/*     Set up by making a request that will be satisfied by the segment */
/*     in PCK 1.  This builds up the segment list for body 1. */

    body = 1;
    tbegs[0] = 1e4;
    tends[0] = 10001.;
    pckno = 1;
    s_copy(xsegid, "File: # Segno: #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid, "#", pcks, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)255, (
	    ftnlen)40);
    repmi_(xsegid, "#", &c__1, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    d__1 = tbegs[0] + .5f;
    pcksfs_(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Go ahead and make the new file. */

    body = 1;
    pckno = 5;
    i__1 = nseg[(i__2 = pckno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("nseg", 
	    i__2, "f_pckbsr__", (ftnlen)544)];
    for (i__ = 1; i__ <= i__1; ++i__) {
	ids[(i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("ids", i__2,
		 "f_pckbsr__", (ftnlen)546)] = body;
	if (i__ == 10 || i__ == 101) {

/*           We want the lower bound of the re-use interval to */
/*           match the right endpoint of the segment's coverage */
/*           interval. */

	    tbegs[(i__2 = i__ - 2) < 16000 && 0 <= i__2 ? i__2 : s_rnge("tbe"
		    "gs", i__2, "f_pckbsr__", (ftnlen)554)] = (doublereal) (
		    pckno * 10000 + i__);
	    tends[(i__2 = i__ - 2) < 16000 && 0 <= i__2 ? i__2 : s_rnge("ten"
		    "ds", i__2, "f_pckbsr__", (ftnlen)555)] = tbegs[(i__3 = 
		    i__ - 2) < 16000 && 0 <= i__3 ? i__3 : s_rnge("tbegs", 
		    i__3, "f_pckbsr__", (ftnlen)555)] + 1.;
	    tbegs[(i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("tbe"
		    "gs", i__2, "f_pckbsr__", (ftnlen)557)] = (doublereal) (
		    pckno * 10000 + i__ - 1);
	    tends[(i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("ten"
		    "ds", i__2, "f_pckbsr__", (ftnlen)558)] = tbegs[(i__3 = 
		    i__ - 1) < 16000 && 0 <= i__3 ? i__3 : s_rnge("tbegs", 
		    i__3, "f_pckbsr__", (ftnlen)558)] + 1;
	    tbegs[(i__2 = i__) < 16000 && 0 <= i__2 ? i__2 : s_rnge("tbegs", 
		    i__2, "f_pckbsr__", (ftnlen)560)] = tbegs[(i__3 = i__ - 1)
		     < 16000 && 0 <= i__3 ? i__3 : s_rnge("tbegs", i__3, 
		    "f_pckbsr__", (ftnlen)560)];
	    tends[(i__2 = i__) < 16000 && 0 <= i__2 ? i__2 : s_rnge("tends", 
		    i__2, "f_pckbsr__", (ftnlen)561)] = tends[(i__3 = i__ - 1)
		     < 16000 && 0 <= i__3 ? i__3 : s_rnge("tends", i__3, 
		    "f_pckbsr__", (ftnlen)561)];
	    tbegs[(i__2 = i__ + 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("tbe"
		    "gs", i__2, "f_pckbsr__", (ftnlen)563)] = tends[(i__3 = 
		    i__ - 1) < 16000 && 0 <= i__3 ? i__3 : s_rnge("tends", 
		    i__3, "f_pckbsr__", (ftnlen)563)] + 1;
	    tends[(i__2 = i__ + 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("ten"
		    "ds", i__2, "f_pckbsr__", (ftnlen)564)] = tbegs[(i__3 = 
		    i__ + 1) < 16000 && 0 <= i__3 ? i__3 : s_rnge("tbegs", 
		    i__3, "f_pckbsr__", (ftnlen)564)] + 1;
	} else if (i__ == 106) {

/*           Create a singleton segment. */

	    tbegs[(i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("tbe"
		    "gs", i__2, "f_pckbsr__", (ftnlen)571)] = (doublereal) (
		    pckno * 10000 + i__ - 1);
	    tends[(i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("ten"
		    "ds", i__2, "f_pckbsr__", (ftnlen)572)] = tbegs[(i__3 = 
		    i__ - 1) < 16000 && 0 <= i__3 ? i__3 : s_rnge("tbegs", 
		    i__3, "f_pckbsr__", (ftnlen)572)];
	} else if (i__ == 107) {

/*           Create an invisible segment. */

	    tbegs[(i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("tbe"
		    "gs", i__2, "f_pckbsr__", (ftnlen)578)] = (doublereal) (
		    pckno * 10000 + i__ - 1);
	    tends[(i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("ten"
		    "ds", i__2, "f_pckbsr__", (ftnlen)579)] = tbegs[(i__3 = 
		    i__ - 1) < 16000 && 0 <= i__3 ? i__3 : s_rnge("tbegs", 
		    i__3, "f_pckbsr__", (ftnlen)579)] - 1;
	} else if (i__ < 9 || i__ > 12 && i__ < 100 || i__ > 103) {
	    tbegs[(i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("tbe"
		    "gs", i__2, "f_pckbsr__", (ftnlen)585)] = (doublereal) (
		    pckno * 10000 + i__ - 1);
	    tends[(i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("ten"
		    "ds", i__2, "f_pckbsr__", (ftnlen)586)] = tbegs[(i__3 = 
		    i__ - 1) < 16000 && 0 <= i__3 ? i__3 : s_rnge("tbegs", 
		    i__3, "f_pckbsr__", (ftnlen)586)] + 1;
	}
	s_copy(xsegid + ((i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_pckbsr__", (ftnlen)590)) * 40, 
		"File: # Segno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid + ((i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_pckbsr__", (ftnlen)592)) * 40, 
		"#", pcks + ((i__3 = pckno - 1) < 10 && 0 <= i__3 ? i__3 : 
		s_rnge("pcks", i__3, "f_pckbsr__", (ftnlen)592)) * 255, 
		xsegid + ((i__4 = i__ - 1) < 16000 && 0 <= i__4 ? i__4 : 
		s_rnge("xsegid", i__4, "f_pckbsr__", (ftnlen)592)) * 40, (
		ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
	repmi_(xsegid + ((i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_pckbsr__", (ftnlen)593)) * 40, 
		"#", &i__, xsegid + ((i__3 = i__ - 1) < 16000 && 0 <= i__3 ? 
		i__3 : s_rnge("xsegid", i__3, "f_pckbsr__", (ftnlen)593)) * 
		40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    t_crdaf__("PCK", pcks + ((i__1 = pckno - 1) < 10 && 0 <= i__1 ? i__1 : 
	    s_rnge("pcks", i__1, "f_pckbsr__", (ftnlen)598)) * 255, &nseg[(
	    i__2 = pckno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("nseg", i__2, 
	    "f_pckbsr__", (ftnlen)598)], ids, tbegs, tends, xsegid, (ftnlen)3,
	     (ftnlen)255, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    pcklof_(pcks + ((i__1 = pckno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge(
	    "pcks", i__1, "f_pckbsr__", (ftnlen)603)) * 255, &hndles[(i__2 = 
	    pckno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("hndles", i__2, 
	    "f_pckbsr__", (ftnlen)603)], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    segno = 1;
    d__1 = tbegs[(i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "tbegs", i__1, "f_pckbsr__", (ftnlen)608)] + .5f;
    pcksfs_(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     In this case, the segment should be found.  Make sure we get */
/*     back the right handle and segment identifier. */

    s_copy(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_pckbsr__", (ftnlen)617)) * 40, "File: # Segno"
	    ": #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_pckbsr__", (ftnlen)618)) * 40, "#", pcks + ((
	    i__2 = pckno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("pcks", i__2, 
	    "f_pckbsr__", (ftnlen)618)) * 255, xsegid + ((i__3 = segno - 1) < 
	    16000 && 0 <= i__3 ? i__3 : s_rnge("xsegid", i__3, "f_pckbsr__", (
	    ftnlen)618)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40)
	    ;
    repmi_(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_pckbsr__", (ftnlen)619)) * 40, "#", &c__1, 
	    xsegid + ((i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_pckbsr__", (ftnlen)619)) * 40, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = pckno - 1) < 10 && 0 <= 
	    i__1 ? i__1 : s_rnge("hndles", i__1, "f_pckbsr__", (ftnlen)623)], 
	    &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + ((i__1 = segno - 1) < 16000 && 0 <= 
	    i__1 ? i__1 : s_rnge("xsegid", i__1, "f_pckbsr__", (ftnlen)624)) *
	     40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (ftnlen)40);

/*     Check the descriptor as well.  However, don't check the */
/*     segment addresses. */

    t_crdesc__("PCK", &segno, &body, &tbegs[(i__1 = segno - 1) < 16000 && 0 <=
	     i__1 ? i__1 : s_rnge("tbegs", i__1, "f_pckbsr__", (ftnlen)630)], 
	    &tends[(i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
	    "tends", i__2, "f_pckbsr__", (ftnlen)630)], &xdescr[(i__3 = segno 
	    * 5 - 5) < 80000 && 0 <= i__3 ? i__3 : s_rnge("xdescr", i__3, 
	    "f_pckbsr__", (ftnlen)630)], (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[(i__1 = segno * 5 - 5) < 80000 && 0 
	    <= i__1 ? i__1 : s_rnge("xdescr", i__1, "f_pckbsr__", (ftnlen)634)
	    ], &c__3, &c_b31, ok, (ftnlen)5, (ftnlen)1);
    tcase_("Create an PCK containing data for BTSIZE new bodies. Look up dat"
	    "a for each.", (ftnlen)75);

/*     Unload all PCKs. */

    for (i__ = 1; i__ <= 10; ++i__) {
	pckuof_(&hndles[(i__1 = i__ - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge(
		"hndles", i__1, "f_pckbsr__", (ftnlen)649)]);
    }
    pckno = 6;
    i__2 = nseg[(i__1 = pckno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("nseg", 
	    i__1, "f_pckbsr__", (ftnlen)654)];
    for (i__ = 1; i__ <= i__2; ++i__) {
	ids[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("ids", i__1,
		 "f_pckbsr__", (ftnlen)656)] = i__ + 20;
	tbegs[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs", 
		i__1, "f_pckbsr__", (ftnlen)658)] = (doublereal) (pckno * 
		10000 + i__ - 1);
	tends[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tends", 
		i__1, "f_pckbsr__", (ftnlen)659)] = tbegs[(i__3 = i__ - 1) < 
		16000 && 0 <= i__3 ? i__3 : s_rnge("tbegs", i__3, "f_pckbsr__"
		, (ftnlen)659)] + 1;
	s_copy(xsegid + ((i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_pckbsr__", (ftnlen)661)) * 40, 
		"File: # Segno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid + ((i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_pckbsr__", (ftnlen)663)) * 40, 
		"#", pcks + ((i__3 = pckno - 1) < 10 && 0 <= i__3 ? i__3 : 
		s_rnge("pcks", i__3, "f_pckbsr__", (ftnlen)663)) * 255, 
		xsegid + ((i__4 = i__ - 1) < 16000 && 0 <= i__4 ? i__4 : 
		s_rnge("xsegid", i__4, "f_pckbsr__", (ftnlen)663)) * 40, (
		ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
	repmi_(xsegid + ((i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_pckbsr__", (ftnlen)664)) * 40, 
		"#", &i__, xsegid + ((i__3 = i__ - 1) < 16000 && 0 <= i__3 ? 
		i__3 : s_rnge("xsegid", i__3, "f_pckbsr__", (ftnlen)664)) * 
		40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    t_crdaf__("PCK", pcks + ((i__2 = pckno - 1) < 10 && 0 <= i__2 ? i__2 : 
	    s_rnge("pcks", i__2, "f_pckbsr__", (ftnlen)669)) * 255, &nseg[(
	    i__1 = pckno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("nseg", i__1, 
	    "f_pckbsr__", (ftnlen)669)], ids, tbegs, tends, xsegid, (ftnlen)3,
	     (ftnlen)255, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    pcklof_(pcks + ((i__2 = pckno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge(
	    "pcks", i__2, "f_pckbsr__", (ftnlen)674)) * 255, &hndles[(i__1 = 
	    pckno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("hndles", i__1, 
	    "f_pckbsr__", (ftnlen)674)], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    i__1 = nseg[(i__2 = pckno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("nseg", 
	    i__2, "f_pckbsr__", (ftnlen)678)];
    for (i__ = 1; i__ <= i__1; ++i__) {
	body = ids[(i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
		"ids", i__2, "f_pckbsr__", (ftnlen)680)];
	segno = i__;
	d__1 = tbegs[(i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
		"tbegs", i__2, "f_pckbsr__", (ftnlen)683)] + .5f;
	pcksfs_(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        In this case, the segment should be found.  Make sure we get */
/*        back the right handle and segment identifier. */

	s_copy(xsegid + ((i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_pckbsr__", (ftnlen)691)) * 40, 
		"File: # Segno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid + ((i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_pckbsr__", (ftnlen)692)) * 40, 
		"#", pcks + ((i__3 = pckno - 1) < 10 && 0 <= i__3 ? i__3 : 
		s_rnge("pcks", i__3, "f_pckbsr__", (ftnlen)692)) * 255, 
		xsegid + ((i__4 = segno - 1) < 16000 && 0 <= i__4 ? i__4 : 
		s_rnge("xsegid", i__4, "f_pckbsr__", (ftnlen)692)) * 40, (
		ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
	repmi_(xsegid + ((i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_pckbsr__", (ftnlen)693)) * 40, 
		"#", &segno, xsegid + ((i__3 = segno - 1) < 16000 && 0 <= 
		i__3 ? i__3 : s_rnge("xsegid", i__3, "f_pckbsr__", (ftnlen)
		693)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	chcksi_("HANDLE", &handle, "=", &hndles[(i__2 = pckno - 1) < 10 && 0 
		<= i__2 ? i__2 : s_rnge("hndles", i__2, "f_pckbsr__", (ftnlen)
		697)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	chcksc_("SEGID", segid, "=", xsegid + ((i__2 = segno - 1) < 16000 && 
		0 <= i__2 ? i__2 : s_rnge("xsegid", i__2, "f_pckbsr__", (
		ftnlen)698)) * 40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (
		ftnlen)40);

/*        Check the descriptor as well.  However, don't check the */
/*        segment addresses. */

	t_crdesc__("PCK", &segno, &body, &tbegs[(i__2 = segno - 1) < 16000 && 
		0 <= i__2 ? i__2 : s_rnge("tbegs", i__2, "f_pckbsr__", (
		ftnlen)704)], &tends[(i__3 = segno - 1) < 16000 && 0 <= i__3 ?
		 i__3 : s_rnge("tends", i__3, "f_pckbsr__", (ftnlen)704)], &
		xdescr[(i__4 = segno * 5 - 5) < 80000 && 0 <= i__4 ? i__4 : 
		s_rnge("xdescr", i__4, "f_pckbsr__", (ftnlen)704)], (ftnlen)3)
		;
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	t_chds__("DESCR", descr, "=", &xdescr[(i__2 = segno * 5 - 5) < 80000 
		&& 0 <= i__2 ? i__2 : s_rnge("xdescr", i__2, "f_pckbsr__", (
		ftnlen)708)], &c__3, &c_b31, ok, (ftnlen)5, (ftnlen)1);
    }
    tcase_("The body table should be full now; the segment table should have"
	    " room.  Cause a body list to be dumped to make room in the body "
	    "table.", (ftnlen)134);

/*     Create a list for body 1 more expensive than those for the */
/*     bodies in PCK 6.  Body 1's list will be placed at the head of */
/*     the body table. */

    body = 1;
    pckno = 2;
    segno = nseg[(i__1 = pckno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("nseg", 
	    i__1, "f_pckbsr__", (ftnlen)729)];
    i__ = segno;
    tbegs[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs", i__1,
	     "f_pckbsr__", (ftnlen)731)] = (doublereal) (pckno * 10000 + i__ 
	    - 1);
    tends[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tends", i__1,
	     "f_pckbsr__", (ftnlen)732)] = tbegs[(i__2 = i__ - 1) < 16000 && 
	    0 <= i__2 ? i__2 : s_rnge("tbegs", i__2, "f_pckbsr__", (ftnlen)
	    732)] + 1;
    s_copy(xsegid, "File: # Segno: #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid, "#", pcks + ((i__1 = pckno - 1) < 10 && 0 <= i__1 ? i__1 : 
	    s_rnge("pcks", i__1, "f_pckbsr__", (ftnlen)735)) * 255, xsegid, (
	    ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
    repmi_(xsegid, "#", &segno, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    pcklof_(pcks + 255, &hndles[1], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    d__1 = tbegs[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs"
	    , i__1, "f_pckbsr__", (ftnlen)743)] + .5f;
    pcksfs_(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     In this case, the segment should be found.  Make sure we get */
/*     back the right handle and segment identifier. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = pckno - 1) < 10 && 0 <= 
	    i__1 ? i__1 : s_rnge("hndles", i__1, "f_pckbsr__", (ftnlen)752)], 
	    &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1,
	     (ftnlen)40);

/*     Check the descriptor as well.  However, don't check the */
/*     segment addresses. */

    t_crdesc__("PCK", &segno, &body, &tbegs[(i__1 = i__ - 1) < 16000 && 0 <= 
	    i__1 ? i__1 : s_rnge("tbegs", i__1, "f_pckbsr__", (ftnlen)759)], &
	    tends[(i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("ten"
	    "ds", i__2, "f_pckbsr__", (ftnlen)759)], xdescr, (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_chds__("DESCR", descr, "=", xdescr, &c__3, &c_b31, ok, (ftnlen)5, (
	    ftnlen)1);

/*     Now do a look up for body 2.  This will require dumping lists */
/*     from PCK 6. */

    body = 2;
    pckno = 2;
    segno = 1;
    i__ = segno;
    tbegs[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs", i__1,
	     "f_pckbsr__", (ftnlen)774)] = (doublereal) (pckno * 10000 + i__ 
	    - 1);
    tends[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tends", i__1,
	     "f_pckbsr__", (ftnlen)775)] = tbegs[(i__2 = i__ - 1) < 16000 && 
	    0 <= i__2 ? i__2 : s_rnge("tbegs", i__2, "f_pckbsr__", (ftnlen)
	    775)] + 1;
    s_copy(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_pckbsr__", (ftnlen)779)) * 40, "File: # Segno"
	    ": #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_pckbsr__", (ftnlen)780)) * 40, "#", pcks + ((
	    i__2 = pckno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("pcks", i__2, 
	    "f_pckbsr__", (ftnlen)780)) * 255, xsegid + ((i__3 = segno - 1) < 
	    16000 && 0 <= i__3 ? i__3 : s_rnge("xsegid", i__3, "f_pckbsr__", (
	    ftnlen)780)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40)
	    ;
    repmi_(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_pckbsr__", (ftnlen)781)) * 40, "#", &segno, 
	    xsegid + ((i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_pckbsr__", (ftnlen)781)) * 40, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    d__1 = tbegs[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs"
	    , i__1, "f_pckbsr__", (ftnlen)784)] + .5f;
    pcksfs_(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     In this case, the segment should be found.  Make sure we get */
/*     back the right handle and segment identifier. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = pckno - 1) < 10 && 0 <= 
	    i__1 ? i__1 : s_rnge("hndles", i__1, "f_pckbsr__", (ftnlen)793)], 
	    &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + ((i__1 = segno - 1) < 16000 && 0 <= 
	    i__1 ? i__1 : s_rnge("xsegid", i__1, "f_pckbsr__", (ftnlen)794)) *
	     40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (ftnlen)40);

/*     Check the descriptor as well.  However, don't check the */
/*     segment addresses. */

    t_crdesc__("PCK", &c__1, &body, tbegs, tends, xdescr, (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_chds__("DESCR", descr, "=", xdescr, &c__3, &c_b31, ok, (ftnlen)5, (
	    ftnlen)1);
    tcase_("Look up data from a representative subset of the segments in PCK"
	    " 5.", (ftnlen)67);
    pckno = 5;
    pcklof_(pcks + ((i__1 = pckno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge(
	    "pcks", i__1, "f_pckbsr__", (ftnlen)816)) * 255, &hndles[(i__2 = 
	    pckno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("hndles", i__2, 
	    "f_pckbsr__", (ftnlen)816)], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    i__2 = nseg[(i__1 = pckno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("nseg", 
	    i__1, "f_pckbsr__", (ftnlen)820)];
    for (i__ = 1; i__ <= i__2; ++i__) {
	ids[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("ids", i__1,
		 "f_pckbsr__", (ftnlen)822)] = body;
	if (i__ == 10 || i__ == 101) {

/*           We want the lower bound of the re-use interval to */
/*           match the right endpoint of the segment's coverage */
/*           interval. */

	    tbegs[(i__1 = i__ - 2) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbe"
		    "gs", i__1, "f_pckbsr__", (ftnlen)830)] = (doublereal) (
		    pckno * 10000 + i__);
	    tends[(i__1 = i__ - 2) < 16000 && 0 <= i__1 ? i__1 : s_rnge("ten"
		    "ds", i__1, "f_pckbsr__", (ftnlen)831)] = tbegs[(i__3 = 
		    i__ - 2) < 16000 && 0 <= i__3 ? i__3 : s_rnge("tbegs", 
		    i__3, "f_pckbsr__", (ftnlen)831)] + 1.;
	    tbegs[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbe"
		    "gs", i__1, "f_pckbsr__", (ftnlen)833)] = (doublereal) (
		    pckno * 10000 + i__ - 1);
	    tends[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("ten"
		    "ds", i__1, "f_pckbsr__", (ftnlen)834)] = tbegs[(i__3 = 
		    i__ - 1) < 16000 && 0 <= i__3 ? i__3 : s_rnge("tbegs", 
		    i__3, "f_pckbsr__", (ftnlen)834)] + 1;
	    tbegs[(i__1 = i__) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs", 
		    i__1, "f_pckbsr__", (ftnlen)836)] = tbegs[(i__3 = i__ - 1)
		     < 16000 && 0 <= i__3 ? i__3 : s_rnge("tbegs", i__3, 
		    "f_pckbsr__", (ftnlen)836)];
	    tends[(i__1 = i__) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tends", 
		    i__1, "f_pckbsr__", (ftnlen)837)] = tends[(i__3 = i__ - 1)
		     < 16000 && 0 <= i__3 ? i__3 : s_rnge("tends", i__3, 
		    "f_pckbsr__", (ftnlen)837)];
	    tbegs[(i__1 = i__ + 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbe"
		    "gs", i__1, "f_pckbsr__", (ftnlen)839)] = tends[(i__3 = 
		    i__ - 1) < 16000 && 0 <= i__3 ? i__3 : s_rnge("tends", 
		    i__3, "f_pckbsr__", (ftnlen)839)] + 1;
	    tends[(i__1 = i__ + 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("ten"
		    "ds", i__1, "f_pckbsr__", (ftnlen)840)] = tbegs[(i__3 = 
		    i__ + 1) < 16000 && 0 <= i__3 ? i__3 : s_rnge("tbegs", 
		    i__3, "f_pckbsr__", (ftnlen)840)] + 1;
	} else if (i__ == 106) {

/*           Create a singleton segment. */

	    tbegs[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbe"
		    "gs", i__1, "f_pckbsr__", (ftnlen)846)] = (doublereal) (
		    pckno * 10000 + i__ - 1);
	    tends[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("ten"
		    "ds", i__1, "f_pckbsr__", (ftnlen)847)] = tbegs[(i__3 = 
		    i__ - 1) < 16000 && 0 <= i__3 ? i__3 : s_rnge("tbegs", 
		    i__3, "f_pckbsr__", (ftnlen)847)];
	} else if (i__ == 107) {

/*           Create an invisible segment. */

	    tbegs[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbe"
		    "gs", i__1, "f_pckbsr__", (ftnlen)853)] = (doublereal) (
		    pckno * 10000 + i__ - 1);
	    tends[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("ten"
		    "ds", i__1, "f_pckbsr__", (ftnlen)854)] = tbegs[(i__3 = 
		    i__ - 1) < 16000 && 0 <= i__3 ? i__3 : s_rnge("tbegs", 
		    i__3, "f_pckbsr__", (ftnlen)854)] - 1;
	} else if (i__ < 10 || i__ > 12 && i__ < 100 || i__ > 103) {
	    tbegs[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbe"
		    "gs", i__1, "f_pckbsr__", (ftnlen)860)] = (doublereal) (
		    pckno * 10000 + i__ - 1);
	    tends[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("ten"
		    "ds", i__1, "f_pckbsr__", (ftnlen)861)] = tbegs[(i__3 = 
		    i__ - 1) < 16000 && 0 <= i__3 ? i__3 : s_rnge("tbegs", 
		    i__3, "f_pckbsr__", (ftnlen)861)] + 1;
	}
	s_copy(xsegid + ((i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_pckbsr__", (ftnlen)865)) * 40, 
		"File: # Segno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid + ((i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_pckbsr__", (ftnlen)867)) * 40, 
		"#", pcks + ((i__3 = pckno - 1) < 10 && 0 <= i__3 ? i__3 : 
		s_rnge("pcks", i__3, "f_pckbsr__", (ftnlen)867)) * 255, 
		xsegid + ((i__4 = i__ - 1) < 16000 && 0 <= i__4 ? i__4 : 
		s_rnge("xsegid", i__4, "f_pckbsr__", (ftnlen)867)) * 40, (
		ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
	repmi_(xsegid + ((i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_pckbsr__", (ftnlen)868)) * 40, 
		"#", &i__, xsegid + ((i__3 = i__ - 1) < 16000 && 0 <= i__3 ? 
		i__3 : s_rnge("xsegid", i__3, "f_pckbsr__", (ftnlen)868)) * 
		40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    i__ = 1;
    while(i__ <= nseg[(i__2 = pckno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge(
	    "nseg", i__2, "f_pckbsr__", (ftnlen)876)]) {
	body = 1;
	segno = i__;
	d__1 = tbegs[(i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
		"tbegs", i__2, "f_pckbsr__", (ftnlen)881)] + .5f;
	pcksfs_(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        In this case, the segment should be found.  Make sure we get */
/*        back the right handle and segment identifier. */

	s_copy(xsegid + ((i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_pckbsr__", (ftnlen)889)) * 40, 
		"File: # Segno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid + ((i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_pckbsr__", (ftnlen)890)) * 40, 
		"#", pcks + ((i__1 = pckno - 1) < 10 && 0 <= i__1 ? i__1 : 
		s_rnge("pcks", i__1, "f_pckbsr__", (ftnlen)890)) * 255, 
		xsegid + ((i__3 = segno - 1) < 16000 && 0 <= i__3 ? i__3 : 
		s_rnge("xsegid", i__3, "f_pckbsr__", (ftnlen)890)) * 40, (
		ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
	repmi_(xsegid + ((i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_pckbsr__", (ftnlen)891)) * 40, 
		"#", &segno, xsegid + ((i__1 = segno - 1) < 16000 && 0 <= 
		i__1 ? i__1 : s_rnge("xsegid", i__1, "f_pckbsr__", (ftnlen)
		891)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	chcksi_("HANDLE", &handle, "=", &hndles[(i__2 = pckno - 1) < 10 && 0 
		<= i__2 ? i__2 : s_rnge("hndles", i__2, "f_pckbsr__", (ftnlen)
		895)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	chcksc_("SEGID", segid, "=", xsegid + ((i__2 = segno - 1) < 16000 && 
		0 <= i__2 ? i__2 : s_rnge("xsegid", i__2, "f_pckbsr__", (
		ftnlen)896)) * 40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (
		ftnlen)40);

/*        Check the descriptor as well.  However, don't check the */
/*        segment addresses. */

	t_crdesc__("PCK", &segno, &body, &tbegs[(i__2 = segno - 1) < 16000 && 
		0 <= i__2 ? i__2 : s_rnge("tbegs", i__2, "f_pckbsr__", (
		ftnlen)902)], &tends[(i__1 = segno - 1) < 16000 && 0 <= i__1 ?
		 i__1 : s_rnge("tends", i__1, "f_pckbsr__", (ftnlen)902)], &
		xdescr[(i__3 = segno * 5 - 5) < 80000 && 0 <= i__3 ? i__3 : 
		s_rnge("xdescr", i__3, "f_pckbsr__", (ftnlen)902)], (ftnlen)3)
		;
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	t_chds__("DESCR", descr, "=", &xdescr[(i__2 = segno * 5 - 5) < 80000 
		&& 0 <= i__2 ? i__2 : s_rnge("xdescr", i__2, "f_pckbsr__", (
		ftnlen)906)], &c__3, &c_b31, ok, (ftnlen)5, (ftnlen)1);

/*        Skip some tests that are unlikely to reveal bugs, as well as */
/*        those which would give anomalous results due to the structure */
/*        of PCK 6. */

	if (i__ == 3) {
	    i__ = 48;
	} else if (i__ == 53) {
	    i__ = 98;
	} else if (i__ == 100) {
	    i__ = 105;
	} else if (i__ == 105) {
	    i__ = 108;
	} else {
	    ++i__;
	}
    }

/*     Try a search w/o buffering case where no segment is found. */

    tcase_("Search w/o buffering, no segment should be found.", (ftnlen)49);
    pckno = 5;
    body = 1;
    t = tends[(i__1 = nseg[(i__2 = pckno - 1) < 10 && 0 <= i__2 ? i__2 : 
	    s_rnge("nseg", i__2, "f_pckbsr__", (ftnlen)935)] - 1) < 16000 && 
	    0 <= i__1 ? i__1 : s_rnge("tends", i__1, "f_pckbsr__", (ftnlen)
	    935)] * 2;
    pcksfs_(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);

/*     Return on entry in RETURN mode, if the error status is set. */

    tcase_("Make sure PCKSFS returns on entry when RETURN()is .TRUE.", (
	    ftnlen)56);
    s_copy(smsg, "Return on entry", (ftnlen)25, (ftnlen)15);
    sigerr_(smsg, (ftnlen)25);
    pcksfs_(&c__1, &c_b31, &handle, descr, segid, &found, (ftnlen)40);

/*     Depending on whether we're calling a version of PCKBSR that does */
/*     coverage checking, the error status may be reset. */

    if (return_()) {
	chckxc_(&c_true, smsg, ok, (ftnlen)25);
    } else {
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Unload the PCK files. */

    for (i__ = 1; i__ <= 10; ++i__) {
	pckuof_(&hndles[(i__2 = i__ - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge(
		"hndles", i__2, "f_pckbsr__", (ftnlen)969)]);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Make sure an error is NOT signaled if no PCKs are loaded. */

    tcase_("Make sure an error is NOT signaled if no PCKs are loaded.", (
	    ftnlen)57);
    pcksfs_(&c__1, &c_b31, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Load PCK1 and look up a state from it to create a cheap list. */
/*     Make the cheap list the second list by looking up data from */
/*     it after looking up data for body BTSIZE+1. */

    tcase_("Test removal of cheap list when adding a new body; cheap list is"
	    " 2nd.", (ftnlen)69);
    pcklof_(pcks, hndles, (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Now load the PCK containing 100 bodies.  Look up data for */
/*     each one.  The last one will cause the list for body 1 to */
/*     be dumped. */

    pckno = 6;
    pcklof_(pcks + ((i__2 = pckno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge(
	    "pcks", i__2, "f_pckbsr__", (ftnlen)1000)) * 255, &hndles[(i__1 = 
	    pckno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("hndles", i__1, 
	    "f_pckbsr__", (ftnlen)1000)], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    i__1 = nseg[(i__2 = pckno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("nseg", 
	    i__2, "f_pckbsr__", (ftnlen)1003)];
    for (i__ = 1; i__ <= i__1; ++i__) {
	ids[(i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("ids", i__2,
		 "f_pckbsr__", (ftnlen)1005)] = i__ + 20;
	tbegs[(i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("tbegs", 
		i__2, "f_pckbsr__", (ftnlen)1007)] = (doublereal) (pckno * 
		10000 + i__ - 1);
	tends[(i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("tends", 
		i__2, "f_pckbsr__", (ftnlen)1008)] = tbegs[(i__3 = i__ - 1) < 
		16000 && 0 <= i__3 ? i__3 : s_rnge("tbegs", i__3, "f_pckbsr__"
		, (ftnlen)1008)] + 1;
	s_copy(xsegid + ((i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_pckbsr__", (ftnlen)1010)) * 40, 
		"File: # Segno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid + ((i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_pckbsr__", (ftnlen)1012)) * 40, 
		"#", pcks + ((i__3 = pckno - 1) < 10 && 0 <= i__3 ? i__3 : 
		s_rnge("pcks", i__3, "f_pckbsr__", (ftnlen)1012)) * 255, 
		xsegid + ((i__4 = i__ - 1) < 16000 && 0 <= i__4 ? i__4 : 
		s_rnge("xsegid", i__4, "f_pckbsr__", (ftnlen)1012)) * 40, (
		ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
	repmi_(xsegid + ((i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_pckbsr__", (ftnlen)1013)) * 40, 
		"#", &i__, xsegid + ((i__3 = i__ - 1) < 16000 && 0 <= i__3 ? 
		i__3 : s_rnge("xsegid", i__3, "f_pckbsr__", (ftnlen)1013)) * 
		40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    i__2 = nseg[(i__1 = pckno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("nseg", 
	    i__1, "f_pckbsr__", (ftnlen)1019)];
    for (i__ = 1; i__ <= i__2; ++i__) {
	body = ids[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
		"ids", i__1, "f_pckbsr__", (ftnlen)1021)];
	segno = i__;
	d__1 = tbegs[(i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
		"tbegs", i__1, "f_pckbsr__", (ftnlen)1024)] + .5f;
	pcksfs_(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        In this case, the segment should be found.  Make sure we get */
/*        back the right handle and segment identifier. */

	s_copy(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_pckbsr__", (ftnlen)1032)) * 40, 
		"File: # Segno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_pckbsr__", (ftnlen)1033)) * 40, 
		"#", pcks + ((i__3 = pckno - 1) < 10 && 0 <= i__3 ? i__3 : 
		s_rnge("pcks", i__3, "f_pckbsr__", (ftnlen)1033)) * 255, 
		xsegid + ((i__4 = segno - 1) < 16000 && 0 <= i__4 ? i__4 : 
		s_rnge("xsegid", i__4, "f_pckbsr__", (ftnlen)1033)) * 40, (
		ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
	repmi_(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_pckbsr__", (ftnlen)1034)) * 40, 
		"#", &segno, xsegid + ((i__3 = segno - 1) < 16000 && 0 <= 
		i__3 ? i__3 : s_rnge("xsegid", i__3, "f_pckbsr__", (ftnlen)
		1034)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = pckno - 1) < 10 && 0 
		<= i__1 ? i__1 : s_rnge("hndles", i__1, "f_pckbsr__", (ftnlen)
		1038)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	chcksc_("SEGID", segid, "=", xsegid + ((i__1 = segno - 1) < 16000 && 
		0 <= i__1 ? i__1 : s_rnge("xsegid", i__1, "f_pckbsr__", (
		ftnlen)1039)) * 40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (
		ftnlen)40);

/*        Check the descriptor as well.  However, don't check the */
/*        segment addresses. */

	t_crdesc__("PCK", &segno, &body, &tbegs[(i__1 = segno - 1) < 16000 && 
		0 <= i__1 ? i__1 : s_rnge("tbegs", i__1, "f_pckbsr__", (
		ftnlen)1045)], &tends[(i__3 = segno - 1) < 16000 && 0 <= i__3 
		? i__3 : s_rnge("tends", i__3, "f_pckbsr__", (ftnlen)1045)], &
		xdescr[(i__4 = segno * 5 - 5) < 80000 && 0 <= i__4 ? i__4 : 
		s_rnge("xdescr", i__4, "f_pckbsr__", (ftnlen)1045)], (ftnlen)
		3);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	t_chds__("DESCR", descr, "=", &xdescr[(i__1 = segno * 5 - 5) < 80000 
		&& 0 <= i__1 ? i__1 : s_rnge("xdescr", i__1, "f_pckbsr__", (
		ftnlen)1049)], &c__3, &c_b31, ok, (ftnlen)5, (ftnlen)1);
	if (i__ == 1) {

/*           Create a cheap list for body 1. */

	    pcklof_(pcks + ((i__1 = pckno - 1) < 10 && 0 <= i__1 ? i__1 : 
		    s_rnge("pcks", i__1, "f_pckbsr__", (ftnlen)1056)) * 255, &
		    hndles[(i__3 = pckno - 1) < 10 && 0 <= i__3 ? i__3 : 
		    s_rnge("hndles", i__3, "f_pckbsr__", (ftnlen)1056)], (
		    ftnlen)255);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    tbegs[0] = 1e4;
	    d__1 = tbegs[0] + .5f;
	    pcksfs_(&c__1, &d__1, &handle, descr, segid, &found, (ftnlen)40);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	}
    }
    tcase_("Test ability to make room by deleting a body table entry with an"
	    " empty list.", (ftnlen)76);

/*     Create an example of the list in question by forcing a search */
/*     without buffering on body 1, where the highest priority file */
/*     contains too many segments to buffer.  However, we want this */
/*     list to have a high expense, so load an PCK with many segments */
/*     for this body and search it first. */

    pckno = 5;
    pcklof_(pcks + ((i__2 = pckno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge(
	    "pcks", i__2, "f_pckbsr__", (ftnlen)1080)) * 255, &hndles[(i__1 = 
	    pckno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("hndles", i__1, 
	    "f_pckbsr__", (ftnlen)1080)], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    body = 1;
    t = pckno * 10000 + 100 + .5;
    pcksfs_(&c__1, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Now look up data for the first NSEG-1 bodies in PCK 6.  This */
/*     should fill up the body table. */

    pckno = 6;
    i__1 = nseg[(i__2 = pckno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("nseg", 
	    i__2, "f_pckbsr__", (ftnlen)1097)] - 1;
    for (i__ = 1; i__ <= i__1; ++i__) {
	ids[(i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("ids", i__2,
		 "f_pckbsr__", (ftnlen)1099)] = i__ + 20;
	tbegs[(i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("tbegs", 
		i__2, "f_pckbsr__", (ftnlen)1101)] = (doublereal) (pckno * 
		10000 + i__ - 1);
	tends[(i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("tends", 
		i__2, "f_pckbsr__", (ftnlen)1102)] = tbegs[(i__3 = i__ - 1) < 
		16000 && 0 <= i__3 ? i__3 : s_rnge("tbegs", i__3, "f_pckbsr__"
		, (ftnlen)1102)] + 1;
	body = ids[(i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
		"ids", i__2, "f_pckbsr__", (ftnlen)1104)];
	segno = i__;
	d__1 = tbegs[(i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
		"tbegs", i__2, "f_pckbsr__", (ftnlen)1107)] + .5f;
	pcksfs_(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        In this case, the segment should be found.  Make sure we get */
/*        back the right handle and segment identifier. */

	s_copy(xsegid + ((i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_pckbsr__", (ftnlen)1115)) * 40, 
		"File: # Segno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid + ((i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_pckbsr__", (ftnlen)1116)) * 40, 
		"#", pcks + ((i__3 = pckno - 1) < 10 && 0 <= i__3 ? i__3 : 
		s_rnge("pcks", i__3, "f_pckbsr__", (ftnlen)1116)) * 255, 
		xsegid + ((i__4 = segno - 1) < 16000 && 0 <= i__4 ? i__4 : 
		s_rnge("xsegid", i__4, "f_pckbsr__", (ftnlen)1116)) * 40, (
		ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
	repmi_(xsegid + ((i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_pckbsr__", (ftnlen)1117)) * 40, 
		"#", &segno, xsegid + ((i__3 = segno - 1) < 16000 && 0 <= 
		i__3 ? i__3 : s_rnge("xsegid", i__3, "f_pckbsr__", (ftnlen)
		1117)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	chcksi_("HANDLE", &handle, "=", &hndles[(i__2 = pckno - 1) < 10 && 0 
		<= i__2 ? i__2 : s_rnge("hndles", i__2, "f_pckbsr__", (ftnlen)
		1121)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	chcksc_("SEGID", segid, "=", xsegid + ((i__2 = segno - 1) < 16000 && 
		0 <= i__2 ? i__2 : s_rnge("xsegid", i__2, "f_pckbsr__", (
		ftnlen)1122)) * 40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (
		ftnlen)40);

/*        Check the descriptor as well.  However, don't check the */
/*        segment addresses. */

	t_crdesc__("PCK", &segno, &body, &tbegs[(i__2 = segno - 1) < 16000 && 
		0 <= i__2 ? i__2 : s_rnge("tbegs", i__2, "f_pckbsr__", (
		ftnlen)1128)], &tends[(i__3 = segno - 1) < 16000 && 0 <= i__3 
		? i__3 : s_rnge("tends", i__3, "f_pckbsr__", (ftnlen)1128)], &
		xdescr[(i__4 = segno * 5 - 5) < 80000 && 0 <= i__4 ? i__4 : 
		s_rnge("xdescr", i__4, "f_pckbsr__", (ftnlen)1128)], (ftnlen)
		3);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	t_chds__("DESCR", descr, "=", &xdescr[(i__2 = segno * 5 - 5) < 80000 
		&& 0 <= i__2 ? i__2 : s_rnge("xdescr", i__2, "f_pckbsr__", (
		ftnlen)1132)], &c__3, &c_b31, ok, (ftnlen)5, (ftnlen)1);
    }

/*     Try some cases where the re-use interval matches the selected */
/*     segment's coverage interval. */

    tcase_("Search w/o buffering case, selected segment is in dumped list, c"
	    "overage interval matches re-use interval, request time is in cen"
	    "ter of re-use interval.", (ftnlen)151);

/*     Set up the case by unloading the currently loaded PCKs.  Load */
/*     PCK 1 and look up a state from it.  Then load PCK 5. */


/*     Unload the PCK files. */

    for (i__ = 1; i__ <= 9; ++i__) {
	pckuof_(&hndles[(i__1 = i__ - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge(
		"hndles", i__1, "f_pckbsr__", (ftnlen)1156)]);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Load PCK 1 and look up a state from this file. */

    pcklof_(pcks, hndles, (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    body = 1;
    tbegs[0] = 1e4;
    tends[0] = 10001.;
    pckno = 1;
    s_copy(xsegid, "File: # Segno: #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid, "#", pcks, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)255, (
	    ftnlen)40);
    repmi_(xsegid, "#", &c__1, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    d__1 = tbegs[0] + .5f;
    pcksfs_(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Now load PCK 5.  Look up a state from segment 9, where the */
/*     request time is to the right of a segment whose right endpoint */
/*     is at the left endpoint of the re-use interval. */

    pcklof_(pcks + 1020, &hndles[4], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    pckno = 5;
    body = 1;
    segno = 9;
    tbegs[(i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs", 
	    i__1, "f_pckbsr__", (ftnlen)1193)] = (doublereal) (pckno * 10000 
	    + segno + 1);
    tends[(i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tends", 
	    i__1, "f_pckbsr__", (ftnlen)1194)] = tbegs[(i__2 = segno - 1) < 
	    16000 && 0 <= i__2 ? i__2 : s_rnge("tbegs", i__2, "f_pckbsr__", (
	    ftnlen)1194)] + 1;
    t = tbegs[(i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs",
	     i__1, "f_pckbsr__", (ftnlen)1196)] + .25;
    pcksfs_(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     In this case, segment 9 should match. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    segno = 9;
    s_copy(xsegid, "File: # Segno: #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid, "#", pcks + 1020, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)
	    255, (ftnlen)40);
    repmi_(xsegid, "#", &segno, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = pckno - 1) < 10 && 0 <= 
	    i__1 ? i__1 : s_rnge("hndles", i__1, "f_pckbsr__", (ftnlen)1213)],
	     &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1,
	     (ftnlen)40);

/*     Check the descriptor as well.  However, don't check the */
/*     segment addresses. */

    t_crdesc__("PCK", &segno, &body, &tbegs[(i__1 = segno - 1) < 16000 && 0 <=
	     i__1 ? i__1 : s_rnge("tbegs", i__1, "f_pckbsr__", (ftnlen)1220)],
	     &tends[(i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
	    "tends", i__2, "f_pckbsr__", (ftnlen)1220)], &xdescr[(i__3 = 
	    segno * 5 - 5) < 80000 && 0 <= i__3 ? i__3 : s_rnge("xdescr", 
	    i__3, "f_pckbsr__", (ftnlen)1220)], (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[(i__1 = segno * 5 - 5) < 80000 && 0 
	    <= i__1 ? i__1 : s_rnge("xdescr", i__1, "f_pckbsr__", (ftnlen)
	    1224)], &c__3, &c_b31, ok, (ftnlen)5, (ftnlen)1);

/*     Create a situation where the segment list for body 1 contributed */
/*     by PCK 5 gets dumped, and where the request is satisfied by */
/*     a segment in PCK 1. */

    tcase_("Dump segment list from PCK 5; find segment for body 1 in PCK 1.", 
	    (ftnlen)63);
    pcklof_(pcks, hndles, (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    pcklof_(pcks + 1020, &hndles[4], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    body = 1;
    tbegs[0] = 1e4;
    tends[0] = 10001.;
    t = (tbegs[0] + tends[0]) * .5;
    pcksfs_(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Check handle, segment descriptor and ID. */

    chcksi_("HANDLE", &handle, "=", hndles, &c__0, ok, (ftnlen)6, (ftnlen)1);
    t_crdesc__("PCK", &c__1, &body, tbegs, tends, xdescr, (ftnlen)3);
    t_chds__("DESCR", descr, "=", xdescr, &c__3, &c_b31, ok, (ftnlen)5, (
	    ftnlen)1);
    s_copy(xsegid, "File: # Segno: #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid, "#", pcks, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)255, (
	    ftnlen)40);
    repmi_(xsegid, "#", &c__1, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1,
	     (ftnlen)40);
    tcase_("Dump segment list from PCK 5.  While searching list for segment "
	    "for body 1, make lower bound of re-use interval match lower boun"
	    "d of segment descriptor.", (ftnlen)152);

/*     Make PCK 1 higher priority than PCK 5. */

    pcklof_(pcks, hndles, (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Place request time in the "hole" between segments STSIZE+1 and */
/*     STSIZE+3. */

    i__ = 101;
    tbegs[(i__1 = i__ - 2) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs", i__1,
	     "f_pckbsr__", (ftnlen)1291)] = (doublereal) (pckno * 10000 + i__)
	    ;
    tends[(i__1 = i__ - 2) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tends", i__1,
	     "f_pckbsr__", (ftnlen)1292)] = tbegs[(i__2 = i__ - 2) < 16000 && 
	    0 <= i__2 ? i__2 : s_rnge("tbegs", i__2, "f_pckbsr__", (ftnlen)
	    1292)] + 1.;
    tbegs[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs", i__1,
	     "f_pckbsr__", (ftnlen)1294)] = (doublereal) (pckno * 10000 + i__ 
	    - 1);
    tends[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tends", i__1,
	     "f_pckbsr__", (ftnlen)1295)] = tbegs[(i__2 = i__ - 1) < 16000 && 
	    0 <= i__2 ? i__2 : s_rnge("tbegs", i__2, "f_pckbsr__", (ftnlen)
	    1295)] + 1;
    tbegs[(i__1 = i__) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs", i__1, 
	    "f_pckbsr__", (ftnlen)1297)] = tbegs[(i__2 = i__ - 1) < 16000 && 
	    0 <= i__2 ? i__2 : s_rnge("tbegs", i__2, "f_pckbsr__", (ftnlen)
	    1297)];
    tends[(i__1 = i__) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tends", i__1, 
	    "f_pckbsr__", (ftnlen)1298)] = tends[(i__2 = i__ - 1) < 16000 && 
	    0 <= i__2 ? i__2 : s_rnge("tends", i__2, "f_pckbsr__", (ftnlen)
	    1298)];
    tbegs[(i__1 = i__ + 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs", i__1,
	     "f_pckbsr__", (ftnlen)1300)] = tends[(i__2 = i__ - 1) < 16000 && 
	    0 <= i__2 ? i__2 : s_rnge("tends", i__2, "f_pckbsr__", (ftnlen)
	    1300)] + 1;
    tends[(i__1 = i__ + 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tends", i__1,
	     "f_pckbsr__", (ftnlen)1301)] = tbegs[(i__2 = i__ + 1) < 16000 && 
	    0 <= i__2 ? i__2 : s_rnge("tbegs", i__2, "f_pckbsr__", (ftnlen)
	    1301)] + 1;
    t = tbegs[(i__1 = i__ - 2) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs", 
	    i__1, "f_pckbsr__", (ftnlen)1303)] + .5;
    pcksfs_(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     In this case, segment STSIZE should match. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    segno = 100;
    s_copy(xsegid, "File: # Segno: #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid, "#", pcks + 1020, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)
	    255, (ftnlen)40);
    repmi_(xsegid, "#", &segno, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = pckno - 1) < 10 && 0 <= 
	    i__1 ? i__1 : s_rnge("hndles", i__1, "f_pckbsr__", (ftnlen)1321)],
	     &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1,
	     (ftnlen)40);

/*     Check the descriptor as well.  However, don't check the */
/*     segment addresses. */

    i__ = segno + 1;
    tbegs[(i__1 = i__ - 2) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs", i__1,
	     "f_pckbsr__", (ftnlen)1329)] = (doublereal) (pckno * 10000 + i__)
	    ;
    tends[(i__1 = i__ - 2) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tends", i__1,
	     "f_pckbsr__", (ftnlen)1330)] = tbegs[(i__2 = i__ - 2) < 16000 && 
	    0 <= i__2 ? i__2 : s_rnge("tbegs", i__2, "f_pckbsr__", (ftnlen)
	    1330)] + 1.;
    t_crdesc__("PCK", &segno, &body, &tbegs[(i__1 = segno - 1) < 16000 && 0 <=
	     i__1 ? i__1 : s_rnge("tbegs", i__1, "f_pckbsr__", (ftnlen)1332)],
	     &tends[(i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
	    "tends", i__2, "f_pckbsr__", (ftnlen)1332)], &xdescr[(i__3 = 
	    segno * 5 - 5) < 80000 && 0 <= i__3 ? i__3 : s_rnge("xdescr", 
	    i__3, "f_pckbsr__", (ftnlen)1332)], (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[(i__1 = segno * 5 - 5) < 80000 && 0 
	    <= i__1 ? i__1 : s_rnge("xdescr", i__1, "f_pckbsr__", (ftnlen)
	    1336)], &c__3, &c_b31, ok, (ftnlen)5, (ftnlen)1);

/*     Check correct handling of re-use intervals.  Create a new */
/*     PCK file that contains coverage that exemplifies the various */
/*     masking possibilities that may occur. */

    tcase_("Check re-use for a 1-body segment list.", (ftnlen)39);
    pckno = 7;

/*     Segment 1: */

    body = 1;
    ids[0] = body;
    tbegs[0] = (doublereal) (pckno * 10000);
    tends[0] = tbegs[0] + 1.;

/*     Segments 2-3: */

    body = 2;
    ids[1] = body;
    ids[2] = body;
    tbegs[2] = (doublereal) (pckno * 10000);
    tends[2] = tbegs[2] + 1.;
    tbegs[1] = tends[2] + 1.;
    tends[1] = tbegs[1] + 1.;

/*     Segments 4-6: */

    body = 3;
    ids[3] = body;
    ids[4] = body;
    ids[5] = body;
    tbegs[5] = (doublereal) (pckno * 10000);
    tends[5] = tbegs[5] + 3.;
    tbegs[4] = tends[5] - 1.;
    tends[4] = tbegs[4] + 3.;
    tbegs[3] = tbegs[4] + 1.;
    tends[3] = tends[4] - 1.;

/*     Segments 7-9: */

    body = 4;
    ids[6] = body;
    ids[7] = body;
    ids[8] = body;
    tbegs[8] = (doublereal) (pckno * 10000);
    tends[8] = tbegs[8] + 3.;
    tbegs[7] = tbegs[8];
    tends[7] = tends[8];
    tbegs[6] = tbegs[8] - 2.;
    tends[6] = tbegs[8] + 3.;

/*     Segments 10-12: */

    body = 5;
    ids[9] = body;
    ids[10] = body;
    ids[11] = body;
    tbegs[11] = (doublereal) (pckno * 10000);
    tends[11] = tbegs[11] + 3.;
    tbegs[10] = tbegs[11] - 2.;
    tends[10] = tbegs[10] + 3.;
    tbegs[9] = tbegs[10] - 2.;
    tends[9] = tends[11] + 1.;

/*     Segments 13-14: */

    body = 6;
    ids[12] = body;
    ids[13] = body;

/*     Singleton segment: */

    tbegs[12] = (doublereal) (pckno * 10000);
    tends[12] = tbegs[12];

/*     Invisible segment: */

    tbegs[13] = tends[12] + 3.;
    tends[13] = tbegs[13] - 1.;

/*     Three more segments for body 4: */

    ids[14] = 4;
    ids[15] = 4;
    ids[16] = 4;
    tbegs[14] = pckno * 10000 + 10.;
    tends[14] = tbegs[14] + 3.;
    tbegs[15] = tbegs[14] + 1.;
    tends[15] = tends[14] - 1.;
    tbegs[16] = tbegs[15];
    tends[16] = tends[15];

/*     Three more segments for body 5: */

    body = 5;
    ids[17] = body;
    ids[18] = body;
    ids[19] = body;
    tbegs[19] = pckno * 10000 + 10.;
    tends[19] = tbegs[19] + 3.;
    tbegs[18] = tbegs[19] - 2.;
    tends[18] = tbegs[18] + 3.;
    tbegs[17] = tbegs[18] - 2.;
    tends[17] = tends[19] + 1.;

/*     Create a segment sequence for body 6 with the following topology: */


/*              +++++++           segment 21 */
/*                    +++++++             22 */
/*        +++++++                         23 */


    body = 6;
    ids[20] = body;
    ids[21] = body;
    ids[22] = body;
    tbegs[20] = pckno * 10000 + 10.;
    tends[20] = tbegs[20] + 3.;
    tbegs[21] = tends[20];
    tends[21] = tbegs[20] + 3.;
    tbegs[22] = tbegs[20] - 3.;
    tends[22] = tbegs[20];

/*     Create the eighth PCK, which is just a copy of the 7th, except */
/*     for descriptors and segment IDs. */

    pckno = 8;
    i__2 = nseg[(i__1 = pckno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("nseg", 
	    i__1, "f_pckbsr__", (ftnlen)1511)];
    for (segno = 1; segno <= i__2; ++segno) {
	t_crdesc__("PCK", &segno, &ids[(i__1 = segno - 1) < 16000 && 0 <= 
		i__1 ? i__1 : s_rnge("ids", i__1, "f_pckbsr__", (ftnlen)1513)]
		, &tbegs[(i__3 = segno - 1) < 16000 && 0 <= i__3 ? i__3 : 
		s_rnge("tbegs", i__3, "f_pckbsr__", (ftnlen)1513)], &tends[(
		i__4 = segno - 1) < 16000 && 0 <= i__4 ? i__4 : s_rnge("tends"
		, i__4, "f_pckbsr__", (ftnlen)1513)], &xdescr[(i__5 = segno * 
		5 - 5) < 80000 && 0 <= i__5 ? i__5 : s_rnge("xdescr", i__5, 
		"f_pckbsr__", (ftnlen)1513)], (ftnlen)3);
	s_copy(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_pckbsr__", (ftnlen)1516)) * 40, 
		"File: # Segno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_pckbsr__", (ftnlen)1517)) * 40, 
		"#", pcks + ((i__3 = pckno - 1) < 10 && 0 <= i__3 ? i__3 : 
		s_rnge("pcks", i__3, "f_pckbsr__", (ftnlen)1517)) * 255, 
		xsegid + ((i__4 = segno - 1) < 16000 && 0 <= i__4 ? i__4 : 
		s_rnge("xsegid", i__4, "f_pckbsr__", (ftnlen)1517)) * 40, (
		ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
	repmi_(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_pckbsr__", (ftnlen)1518)) * 40, 
		"#", &segno, xsegid + ((i__3 = segno - 1) < 16000 && 0 <= 
		i__3 ? i__3 : s_rnge("xsegid", i__3, "f_pckbsr__", (ftnlen)
		1518)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    t_crdaf__("PCK", pcks + ((i__2 = pckno - 1) < 10 && 0 <= i__2 ? i__2 : 
	    s_rnge("pcks", i__2, "f_pckbsr__", (ftnlen)1523)) * 255, &nseg[(
	    i__1 = pckno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("nseg", i__1, 
	    "f_pckbsr__", (ftnlen)1523)], ids, tbegs, tends, xsegid, (ftnlen)
	    3, (ftnlen)255, (ftnlen)40);

/*     Create the segment descriptors and segment identifiers for */
/*     this PCK file. */

    pckno = 7;
    i__1 = nseg[(i__2 = pckno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("nseg", 
	    i__2, "f_pckbsr__", (ftnlen)1534)];
    for (segno = 1; segno <= i__1; ++segno) {
	t_crdesc__("PCK", &segno, &ids[(i__2 = segno - 1) < 16000 && 0 <= 
		i__2 ? i__2 : s_rnge("ids", i__2, "f_pckbsr__", (ftnlen)1536)]
		, &tbegs[(i__3 = segno - 1) < 16000 && 0 <= i__3 ? i__3 : 
		s_rnge("tbegs", i__3, "f_pckbsr__", (ftnlen)1536)], &tends[(
		i__4 = segno - 1) < 16000 && 0 <= i__4 ? i__4 : s_rnge("tends"
		, i__4, "f_pckbsr__", (ftnlen)1536)], &xdescr[(i__5 = segno * 
		5 - 5) < 80000 && 0 <= i__5 ? i__5 : s_rnge("xdescr", i__5, 
		"f_pckbsr__", (ftnlen)1536)], (ftnlen)3);
	s_copy(xsegid + ((i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_pckbsr__", (ftnlen)1539)) * 40, 
		"File: # Segno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid + ((i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_pckbsr__", (ftnlen)1540)) * 40, 
		"#", pcks + ((i__3 = pckno - 1) < 10 && 0 <= i__3 ? i__3 : 
		s_rnge("pcks", i__3, "f_pckbsr__", (ftnlen)1540)) * 255, 
		xsegid + ((i__4 = segno - 1) < 16000 && 0 <= i__4 ? i__4 : 
		s_rnge("xsegid", i__4, "f_pckbsr__", (ftnlen)1540)) * 40, (
		ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
	repmi_(xsegid + ((i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_pckbsr__", (ftnlen)1541)) * 40, 
		"#", &segno, xsegid + ((i__3 = segno - 1) < 16000 && 0 <= 
		i__3 ? i__3 : s_rnge("xsegid", i__3, "f_pckbsr__", (ftnlen)
		1541)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Unload the other PCK files.  Create and load the PCK file. */


/*     Unload the PCK files.  Again. */

    i__1 = pckno - 1;
    for (i__ = 1; i__ <= i__1; ++i__) {
	pckuof_(&hndles[(i__2 = i__ - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge(
		"hndles", i__2, "f_pckbsr__", (ftnlen)1553)]);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    t_crdaf__("PCK", pcks + ((i__1 = pckno - 1) < 10 && 0 <= i__1 ? i__1 : 
	    s_rnge("pcks", i__1, "f_pckbsr__", (ftnlen)1557)) * 255, &nseg[(
	    i__2 = pckno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("nseg", i__2, 
	    "f_pckbsr__", (ftnlen)1557)], ids, tbegs, tends, xsegid, (ftnlen)
	    3, (ftnlen)255, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    pcklof_(pcks + ((i__1 = pckno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge(
	    "pcks", i__1, "f_pckbsr__", (ftnlen)1563)) * 255, &hndles[(i__2 = 
	    pckno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("hndles", i__2, 
	    "f_pckbsr__", (ftnlen)1563)], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Time for tests. */


/*     Make sure we can re-use data from the first segment for body 1. */

    pckno = 7;
    body = ids[0];
    t = (tbegs[0] + tends[0]) * .5;
    for (i__ = 1; i__ <= 3; ++i__) {
	pcksfs_(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*        Check handle, segment descriptor and ID. */

	chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = pckno - 1) < 10 && 0 
		<= i__1 ? i__1 : s_rnge("hndles", i__1, "f_pckbsr__", (ftnlen)
		1587)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	t_chds__("DESCR", descr, "=", xdescr, &c__3, &c_b31, ok, (ftnlen)5, (
		ftnlen)1);
	chcksc_("SEGID", segid, "=", xsegid, ok, (ftnlen)5, (ftnlen)40, (
		ftnlen)1, (ftnlen)40);
    }
    t = tbegs[0] - 1.;
    pcksfs_(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    t = tends[0] + 1.;
    pcksfs_(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    t = tbegs[0];
    pcksfs_(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    t = tends[0];
    pcksfs_(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Check out behavior for coverage consisting of two non-overlapping */
/*     segments.  The coverage topology is as follows: */


/*                      ++++++++++    segment 2 */
/*        +++++++++++                         3 */



    tcase_("Coverage is union of two disjoint intervals. Test re-use of each."
	    , (ftnlen)65);
    body = ids[1];
    t = (tbegs[1] + tends[1]) * .5;
    for (i__ = 1; i__ <= 3; ++i__) {
	pcksfs_(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*        Check handle, segment descriptor and ID. */

	chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = pckno - 1) < 10 && 0 
		<= i__1 ? i__1 : s_rnge("hndles", i__1, "f_pckbsr__", (ftnlen)
		1656)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	t_chds__("DESCR", descr, "=", &xdescr[5], &c__3, &c_b31, ok, (ftnlen)
		5, (ftnlen)1);
	chcksc_("SEGID", segid, "=", xsegid + 40, ok, (ftnlen)5, (ftnlen)40, (
		ftnlen)1, (ftnlen)40);
    }
    t = (tbegs[2] + tends[2]) * .5;
    for (i__ = 1; i__ <= 3; ++i__) {
	pcksfs_(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*        Check handle, segment descriptor and ID. */

	chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = pckno - 1) < 10 && 0 
		<= i__1 ? i__1 : s_rnge("hndles", i__1, "f_pckbsr__", (ftnlen)
		1678)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	t_chds__("DESCR", descr, "=", &xdescr[10], &c__3, &c_b31, ok, (ftnlen)
		5, (ftnlen)1);
	chcksc_("SEGID", segid, "=", xsegid + 80, ok, (ftnlen)5, (ftnlen)40, (
		ftnlen)1, (ftnlen)40);
    }

/*     Hit the endpoints of the left interval. */

    t = tbegs[2];
    pcksfs_(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Check handle, segment descriptor and ID. */

    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = pckno - 1) < 10 && 0 <= 
	    i__1 ? i__1 : s_rnge("hndles", i__1, "f_pckbsr__", (ftnlen)1700)],
	     &c__0, ok, (ftnlen)6, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[10], &c__3, &c_b31, ok, (ftnlen)5, (
	    ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + 80, ok, (ftnlen)5, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);
    t = tends[2];
    pcksfs_(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Check handle, segment descriptor and ID. */

    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = pckno - 1) < 10 && 0 <= 
	    i__1 ? i__1 : s_rnge("hndles", i__1, "f_pckbsr__", (ftnlen)1718)],
	     &c__0, ok, (ftnlen)6, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[10], &c__3, &c_b31, ok, (ftnlen)5, (
	    ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + 80, ok, (ftnlen)5, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);

/*     Segments 4-6: */


/*     Check out behavior for coverage consisting of three segments */
/*     whose coverage is as shown: */


/*                 +++++++          segment 4 */
/*              +++++++++++++               5 */
/*        +++++++++++                       6 */


    tcase_("Segments 4-6:  three-segment overlapping case #1.", (ftnlen)49);
    body = ids[4];
    t = tends[5] + .25f;
    for (i__ = 1; i__ <= 3; ++i__) {
	pcksfs_(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*        Check handle, segment descriptor and ID. */

	chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = pckno - 1) < 10 && 0 
		<= i__1 ? i__1 : s_rnge("hndles", i__1, "f_pckbsr__", (ftnlen)
		1758)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	t_chds__("DESCR", descr, "=", &xdescr[20], &c__3, &c_b31, ok, (ftnlen)
		5, (ftnlen)1);
	chcksc_("SEGID", segid, "=", xsegid + 160, ok, (ftnlen)5, (ftnlen)40, 
		(ftnlen)1, (ftnlen)40);
    }
    body = ids[3];
    t = tbegs[5] + .25f;
    for (i__ = 1; i__ <= 3; ++i__) {
	pcksfs_(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*        Check handle, segment descriptor and ID. */

	chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = pckno - 1) < 10 && 0 
		<= i__1 ? i__1 : s_rnge("hndles", i__1, "f_pckbsr__", (ftnlen)
		1781)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	t_chds__("DESCR", descr, "=", &xdescr[25], &c__3, &c_b31, ok, (ftnlen)
		5, (ftnlen)1);
	chcksc_("SEGID", segid, "=", xsegid + 200, ok, (ftnlen)5, (ftnlen)40, 
		(ftnlen)1, (ftnlen)40);
    }
    t = tbegs[4] + .25f;
    pcksfs_(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    t = tbegs[5] - .25f;
    pcksfs_(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);

/*     Segments 7-9: */


/*     Check out behavior for coverage consisting of three segments */
/*     whose coverage is as shown: */

/*        +++++++++++           segment 7 */
/*             +++++++++++              8 */
/*             +++++++++++              9 */

    tcase_("Segments 7-9:  three-segment overlapping case #2.", (ftnlen)49);

/*     Get the right side of the re-use interval to coincide with */
/*     the left endpoint of a descriptor, where ET lies to the left */
/*     of the segment, in the CHECK LIST state: */

    body = ids[6];
    t = tbegs[6] + .25f;
    pcksfs_(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = pckno - 1) < 10 && 0 <= 
	    i__1 ? i__1 : s_rnge("hndles", i__1, "f_pckbsr__", (ftnlen)1836)],
	     &c__0, ok, (ftnlen)6, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[30], &c__3, &c_b31, ok, (ftnlen)5, (
	    ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + 240, ok, (ftnlen)5, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);

/*     Check out behavior for coverage consisting of three segments */
/*     whose coverage is as shown: */


/*       ++++++++++++++++++        segment 10 */
/*           +++++++                       11 */
/*               ++++++++                  12 */


    tcase_("Three-segment overlapping case #2.", (ftnlen)34);
    body = ids[9];
    t = tends[11] + .25f;
    for (i__ = 1; i__ <= 3; ++i__) {
	pcksfs_(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*        Check handle, segment descriptor and ID. */

	chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = pckno - 1) < 10 && 0 
		<= i__1 ? i__1 : s_rnge("hndles", i__1, "f_pckbsr__", (ftnlen)
		1874)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	t_chds__("DESCR", descr, "=", &xdescr[45], &c__3, &c_b31, ok, (ftnlen)
		5, (ftnlen)1);
	chcksc_("SEGID", segid, "=", xsegid + 360, ok, (ftnlen)5, (ftnlen)40, 
		(ftnlen)1, (ftnlen)40);
    }
    t = tends[9] + 1.;
    pcksfs_(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    t = tbegs[9] + .25f;
    for (i__ = 1; i__ <= 3; ++i__) {
	pcksfs_(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*        Check handle, segment descriptor and ID. */

	chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = pckno - 1) < 10 && 0 
		<= i__1 ? i__1 : s_rnge("hndles", i__1, "f_pckbsr__", (ftnlen)
		1905)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	t_chds__("DESCR", descr, "=", &xdescr[45], &c__3, &c_b31, ok, (ftnlen)
		5, (ftnlen)1);
	chcksc_("SEGID", segid, "=", xsegid + 360, ok, (ftnlen)5, (ftnlen)40, 
		(ftnlen)1, (ftnlen)40);
    }
    t = tbegs[10] - .25f;
    pcksfs_(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = pckno - 1) < 10 && 0 <= 
	    i__1 ? i__1 : s_rnge("hndles", i__1, "f_pckbsr__", (ftnlen)1923)],
	     &c__0, ok, (ftnlen)6, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[45], &c__3, &c_b31, ok, (ftnlen)5, (
	    ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + 360, ok, (ftnlen)5, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);

/*     Check out behavior for coverage consisting of three segments */
/*     whose coverage is as shown: */


/*       ++++++++++++++++++        segment 15 */
/*            +++++++                      16 */
/*            +++++++                      17 */


    tcase_("ET > segment uppper bound.  Lower bound of re-use interval = upp"
	    "er bound of segment.", (ftnlen)84);
    body = ids[14];
    t = tends[16] + .5;
    pcksfs_(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Check handle, segment descriptor and ID. */

    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = pckno - 1) < 10 && 0 <= 
	    i__1 ? i__1 : s_rnge("hndles", i__1, "f_pckbsr__", (ftnlen)1959)],
	     &c__0, ok, (ftnlen)6, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[70], &c__3, &c_b31, ok, (ftnlen)5, (
	    ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + 560, ok, (ftnlen)5, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);

/*     Check out behavior for coverage consisting of three segments */
/*     whose coverage is as shown: */


/*              +++++++           segment 21 */
/*                    +++++++             22 */
/*        +++++++                         23 */


    tcase_("ET is in segment.  Lower bound of re-use interval = lower bound "
	    "of segment.", (ftnlen)75);
    body = 6;
    ids[20] = body;
    ids[21] = body;
    ids[22] = body;
    tbegs[20] = pckno * 10000 + 10.;
    tends[20] = tbegs[20] + 3.;
    tbegs[21] = tends[20];
    tends[21] = tbegs[20] + 3.;
    tbegs[22] = tbegs[20] - 3.;
    tends[22] = tbegs[20];
    body = ids[20];
    t = tbegs[20] + .5;
    pcksfs_(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Check handle, segment descriptor and ID. */

    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = pckno - 1) < 10 && 0 <= 
	    i__1 ? i__1 : s_rnge("hndles", i__1, "f_pckbsr__", (ftnlen)2011)],
	     &c__0, ok, (ftnlen)6, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[100], &c__3, &c_b31, ok, (ftnlen)5, 
	    (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + 800, ok, (ftnlen)5, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);

/*     Check out behavior for coverage consisting singleton and */
/*     invisible segments. */


    tcase_("Look up data from a singleton segment.", (ftnlen)38);
    t = tbegs[12];
    body = ids[12];
    pcksfs_(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = pckno - 1) < 10 && 0 <= 
	    i__1 ? i__1 : s_rnge("hndles", i__1, "f_pckbsr__", (ftnlen)2039)],
	     &c__0, ok, (ftnlen)6, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[60], &c__3, &c_b31, ok, (ftnlen)5, (
	    ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + 480, ok, (ftnlen)5, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);

/*     Exercise the logic for handling singleton and invisible */
/*     segments during a NEW BODY search. */

    tcase_("Look up data from a singleton segment, this time in a NEW SEGMEN"
	    "TS search.", (ftnlen)74);
    pckno = 8;
    pcklof_(pcks + ((i__1 = pckno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge(
	    "pcks", i__1, "f_pckbsr__", (ftnlen)2057)) * 255, &hndles[(i__2 = 
	    pckno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("hndles", i__2, 
	    "f_pckbsr__", (ftnlen)2057)], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    segno = 13;
    t_crdesc__("PCK", &segno, &ids[(i__1 = segno - 1) < 16000 && 0 <= i__1 ? 
	    i__1 : s_rnge("ids", i__1, "f_pckbsr__", (ftnlen)2063)], &tbegs[(
	    i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("tbegs", 
	    i__2, "f_pckbsr__", (ftnlen)2063)], &tends[(i__3 = segno - 1) < 
	    16000 && 0 <= i__3 ? i__3 : s_rnge("tends", i__3, "f_pckbsr__", (
	    ftnlen)2063)], &xdescr[(i__4 = segno * 5 - 5) < 80000 && 0 <= 
	    i__4 ? i__4 : s_rnge("xdescr", i__4, "f_pckbsr__", (ftnlen)2063)],
	     (ftnlen)3);
    s_copy(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_pckbsr__", (ftnlen)2066)) * 40, "File: # Segn"
	    "o: #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_pckbsr__", (ftnlen)2067)) * 40, "#", pcks + ((
	    i__2 = pckno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("pcks", i__2, 
	    "f_pckbsr__", (ftnlen)2067)) * 255, xsegid + ((i__3 = segno - 1) <
	     16000 && 0 <= i__3 ? i__3 : s_rnge("xsegid", i__3, "f_pckbsr__", 
	    (ftnlen)2067)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)
	    40);
    repmi_(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_pckbsr__", (ftnlen)2068)) * 40, "#", &segno, 
	    xsegid + ((i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_pckbsr__", (ftnlen)2068)) * 40, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t = tbegs[12];
    body = ids[12];
    pcksfs_(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = pckno - 1) < 10 && 0 <= 
	    i__1 ? i__1 : s_rnge("hndles", i__1, "f_pckbsr__", (ftnlen)2081)],
	     &c__0, ok, (ftnlen)6, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[60], &c__3, &c_b31, ok, (ftnlen)5, (
	    ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + 480, ok, (ftnlen)5, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);
    tcase_("Prepare for search w/o buffering tests: create an PCK with STSIZ"
	    "E segments for bodies 1-NBODY.", (ftnlen)94);

/*     Create an PCK file with STSIZE segments for bodies 1-NBODY. */

    pckno = 9;
    for (body = 1; body <= 4; ++body) {
	for (i__ = 1; i__ <= 100; ++i__) {
	    j = (body - 1) * 100 + i__;
	    ids[(i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("ids", 
		    i__1, "f_pckbsr__", (ftnlen)2106)] = body;
	    tbegs[(i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs",
		     i__1, "f_pckbsr__", (ftnlen)2108)] = (doublereal) (pckno 
		    * 10000 + i__ - 1);
	    tends[(i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tends",
		     i__1, "f_pckbsr__", (ftnlen)2109)] = tbegs[(i__2 = j - 1)
		     < 16000 && 0 <= i__2 ? i__2 : s_rnge("tbegs", i__2, 
		    "f_pckbsr__", (ftnlen)2109)] + 1;
	    s_copy(xsegid + ((i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : 
		    s_rnge("xsegid", i__1, "f_pckbsr__", (ftnlen)2111)) * 40, 
		    "File: # Segno: #  Body:  #", (ftnlen)40, (ftnlen)26);
	    repmc_(xsegid + ((i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : 
		    s_rnge("xsegid", i__1, "f_pckbsr__", (ftnlen)2113)) * 40, 
		    "#", pcks + ((i__2 = pckno - 1) < 10 && 0 <= i__2 ? i__2 :
		     s_rnge("pcks", i__2, "f_pckbsr__", (ftnlen)2113)) * 255, 
		    xsegid + ((i__3 = j - 1) < 16000 && 0 <= i__3 ? i__3 : 
		    s_rnge("xsegid", i__3, "f_pckbsr__", (ftnlen)2113)) * 40, 
		    (ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
	    repmi_(xsegid + ((i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : 
		    s_rnge("xsegid", i__1, "f_pckbsr__", (ftnlen)2114)) * 40, 
		    "#", &j, xsegid + ((i__2 = j - 1) < 16000 && 0 <= i__2 ? 
		    i__2 : s_rnge("xsegid", i__2, "f_pckbsr__", (ftnlen)2114))
		     * 40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	    repmi_(xsegid + ((i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : 
		    s_rnge("xsegid", i__1, "f_pckbsr__", (ftnlen)2115)) * 40, 
		    "#", &body, xsegid + ((i__2 = j - 1) < 16000 && 0 <= i__2 
		    ? i__2 : s_rnge("xsegid", i__2, "f_pckbsr__", (ftnlen)
		    2115)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	}
    }
    t_crdaf__("PCK", pcks + ((i__1 = pckno - 1) < 10 && 0 <= i__1 ? i__1 : 
	    s_rnge("pcks", i__1, "f_pckbsr__", (ftnlen)2122)) * 255, &nseg[(
	    i__2 = pckno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("nseg", i__2, 
	    "f_pckbsr__", (ftnlen)2122)], ids, tbegs, tends, xsegid, (ftnlen)
	    3, (ftnlen)255, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    tcase_("Prepare for search w/o buffering tests: create an PCK with STSIZ"
	    "E segments for bodies 1-NBODY.", (ftnlen)94);

/*     Create an PCK file with STSIZE segments for bodies 1-NBODY. */

    pckno = 10;
    for (body = 1; body <= 4; ++body) {
	for (i__ = 1; i__ <= 97; ++i__) {
	    j = (body - 1) * 97 + i__;
	    ids[(i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("ids", 
		    i__1, "f_pckbsr__", (ftnlen)2144)] = body;
	    tbegs[(i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs",
		     i__1, "f_pckbsr__", (ftnlen)2146)] = (doublereal) (pckno 
		    * 10000 + i__ - 1);
	    tends[(i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tends",
		     i__1, "f_pckbsr__", (ftnlen)2147)] = tbegs[(i__2 = j - 1)
		     < 16000 && 0 <= i__2 ? i__2 : s_rnge("tbegs", i__2, 
		    "f_pckbsr__", (ftnlen)2147)] + 1;
	    s_copy(xsegid + ((i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : 
		    s_rnge("xsegid", i__1, "f_pckbsr__", (ftnlen)2149)) * 40, 
		    "File: # Segno: #  Body:  #", (ftnlen)40, (ftnlen)26);
	    repmc_(xsegid + ((i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : 
		    s_rnge("xsegid", i__1, "f_pckbsr__", (ftnlen)2151)) * 40, 
		    "#", pcks + ((i__2 = pckno - 1) < 10 && 0 <= i__2 ? i__2 :
		     s_rnge("pcks", i__2, "f_pckbsr__", (ftnlen)2151)) * 255, 
		    xsegid + ((i__3 = j - 1) < 16000 && 0 <= i__3 ? i__3 : 
		    s_rnge("xsegid", i__3, "f_pckbsr__", (ftnlen)2151)) * 40, 
		    (ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
	    repmi_(xsegid + ((i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : 
		    s_rnge("xsegid", i__1, "f_pckbsr__", (ftnlen)2152)) * 40, 
		    "#", &j, xsegid + ((i__2 = j - 1) < 16000 && 0 <= i__2 ? 
		    i__2 : s_rnge("xsegid", i__2, "f_pckbsr__", (ftnlen)2152))
		     * 40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	    repmi_(xsegid + ((i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : 
		    s_rnge("xsegid", i__1, "f_pckbsr__", (ftnlen)2153)) * 40, 
		    "#", &body, xsegid + ((i__2 = j - 1) < 16000 && 0 <= i__2 
		    ? i__2 : s_rnge("xsegid", i__2, "f_pckbsr__", (ftnlen)
		    2153)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	}
    }
    t_crdaf__("PCK", pcks + ((i__1 = pckno - 1) < 10 && 0 <= i__1 ? i__1 : 
	    s_rnge("pcks", i__1, "f_pckbsr__", (ftnlen)2160)) * 255, &nseg[(
	    i__2 = pckno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("nseg", i__2, 
	    "f_pckbsr__", (ftnlen)2160)], ids, tbegs, tends, xsegid, (ftnlen)
	    3, (ftnlen)255, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    tcase_("Search w/o buffering, ET < segment begin, re-use interval right "
	    "endpoint < segment begin.", (ftnlen)89);

/*     Unload the PCK files.  Again. */

    for (i__ = 1; i__ <= 10; ++i__) {
	pckuof_(&hndles[(i__1 = i__ - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge(
		"hndles", i__1, "f_pckbsr__", (ftnlen)2177)]);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Load PCKs 7 and 9. */

    pcklof_(pcks + 1530, &hndles[6], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    pcklof_(pcks + 2040, &hndles[8], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     The request time should precede the coverage of segment 3 in */
/*     PCK 7. */

    body = 2;
    t = 69999.;
    pcksfs_(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    tcase_("Search w/o buffering, ET within segment, re-use interval, left e"
	    "ndpoint > segment begin.", (ftnlen)88);

/*     The request time should precede the coverage of segment 3 in */
/*     PCK 7. */

    body = 3;
    segno = 5;
    pckno = 7;
    tbegs[5] = (doublereal) (pckno * 10000);
    tends[5] = tbegs[5] + 3.;
    tbegs[4] = tends[5] - 1.;
    tends[4] = tbegs[4] + 3.;
    t = pckno * 10000 + 4.;
    pcksfs_(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    s_copy(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_pckbsr__", (ftnlen)2233)) * 40, "File: # Segn"
	    "o: #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_pckbsr__", (ftnlen)2234)) * 40, "#", pcks + ((
	    i__2 = pckno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("pcks", i__2, 
	    "f_pckbsr__", (ftnlen)2234)) * 255, xsegid + ((i__3 = segno - 1) <
	     16000 && 0 <= i__3 ? i__3 : s_rnge("xsegid", i__3, "f_pckbsr__", 
	    (ftnlen)2234)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)
	    40);
    repmi_(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_pckbsr__", (ftnlen)2235)) * 40, "#", &segno, 
	    xsegid + ((i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_pckbsr__", (ftnlen)2235)) * 40, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + ((i__1 = segno - 1) < 16000 && 0 <= 
	    i__1 ? i__1 : s_rnge("xsegid", i__1, "f_pckbsr__", (ftnlen)2238)) 
	    * 40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (ftnlen)40);

/*     Check the descriptor as well.  However, don't check the */
/*     segment addresses. */

    t_crdesc__("PCK", &segno, &body, &tbegs[(i__1 = segno - 1) < 16000 && 0 <=
	     i__1 ? i__1 : s_rnge("tbegs", i__1, "f_pckbsr__", (ftnlen)2244)],
	     &tends[(i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
	    "tends", i__2, "f_pckbsr__", (ftnlen)2244)], &xdescr[(i__3 = 
	    segno * 5 - 5) < 80000 && 0 <= i__3 ? i__3 : s_rnge("xdescr", 
	    i__3, "f_pckbsr__", (ftnlen)2244)], (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[(i__1 = segno * 5 - 5) < 80000 && 0 
	    <= i__1 ? i__1 : s_rnge("xdescr", i__1, "f_pckbsr__", (ftnlen)
	    2249)], &c__3, &c_b31, ok, (ftnlen)5, (ftnlen)1);
    tcase_("Search w/o buffering, ET < segment begin, re-use interval right "
	    "endpoint = segment begin.", (ftnlen)89);
    body = 4;
    segno = 7;
    pckno = 7;
    ids[6] = body;
    ids[7] = body;
    ids[8] = body;
    tbegs[8] = (doublereal) (pckno * 10000);
    tends[8] = tbegs[8] + 3.;
    tbegs[7] = tbegs[8];
    tends[7] = tends[8];
    tbegs[6] = tbegs[8] - 2.;
    tends[6] = tbegs[8] + 3.;
    t = tbegs[7] - 1.;
    pcksfs_(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = pckno - 1) < 10 && 0 <= 
	    i__1 ? i__1 : s_rnge("hndles", i__1, "f_pckbsr__", (ftnlen)2283)],
	     &c__0, ok, (ftnlen)6, (ftnlen)1);
    s_copy(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_pckbsr__", (ftnlen)2285)) * 40, "File: # Segn"
	    "o: #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_pckbsr__", (ftnlen)2286)) * 40, "#", pcks + ((
	    i__2 = pckno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("pcks", i__2, 
	    "f_pckbsr__", (ftnlen)2286)) * 255, xsegid + ((i__3 = segno - 1) <
	     16000 && 0 <= i__3 ? i__3 : s_rnge("xsegid", i__3, "f_pckbsr__", 
	    (ftnlen)2286)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)
	    40);
    repmi_(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_pckbsr__", (ftnlen)2287)) * 40, "#", &segno, 
	    xsegid + ((i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_pckbsr__", (ftnlen)2287)) * 40, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + ((i__1 = segno - 1) < 16000 && 0 <= 
	    i__1 ? i__1 : s_rnge("xsegid", i__1, "f_pckbsr__", (ftnlen)2290)) 
	    * 40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (ftnlen)40);

/*     Check the descriptor as well.  However, don't check the */
/*     segment addresses. */

    t_crdesc__("PCK", &segno, &body, &tbegs[(i__1 = segno - 1) < 16000 && 0 <=
	     i__1 ? i__1 : s_rnge("tbegs", i__1, "f_pckbsr__", (ftnlen)2296)],
	     &tends[(i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
	    "tends", i__2, "f_pckbsr__", (ftnlen)2296)], &xdescr[(i__3 = 
	    segno * 5 - 5) < 80000 && 0 <= i__3 ? i__3 : s_rnge("xdescr", 
	    i__3, "f_pckbsr__", (ftnlen)2296)], (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[(i__1 = segno * 5 - 5) < 80000 && 0 
	    <= i__1 ? i__1 : s_rnge("xdescr", i__1, "f_pckbsr__", (ftnlen)
	    2301)], &c__3, &c_b31, ok, (ftnlen)5, (ftnlen)1);

/*     Some cases where a partial list must be dumped: */

    tcase_("Dump segment list from PCK 10.  While searching list for segment"
	    " for body 4, make upper bound of re-use interval < upper bound o"
	    "f segment descriptor.", (ftnlen)149);

/*     Unload PCK 9; load PCK 10. */

    pckuof_(&hndles[8]);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    pcklof_(pcks + 2295, &hndles[9], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Our request time should be in the interior of segment 15 in */
/*     PCK 7. */

    pckno = 7;
    segno = 15;
    ids[14] = 4;
    ids[15] = 4;
    ids[16] = 4;
    tbegs[14] = pckno * 10000 + 10.;
    tends[14] = tbegs[14] + 3.;
    tbegs[15] = tbegs[14] + 1.;
    tends[15] = tends[14] - 1.;
    tbegs[16] = tbegs[15];
    tends[16] = tbegs[16];
    t = tbegs[14] + .5;
    pcksfs_(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = pckno - 1) < 10 && 0 <= 
	    i__1 ? i__1 : s_rnge("hndles", i__1, "f_pckbsr__", (ftnlen)2349)],
	     &c__0, ok, (ftnlen)6, (ftnlen)1);
    s_copy(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_pckbsr__", (ftnlen)2351)) * 40, "File: # Segn"
	    "o: #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_pckbsr__", (ftnlen)2352)) * 40, "#", pcks + ((
	    i__2 = pckno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("pcks", i__2, 
	    "f_pckbsr__", (ftnlen)2352)) * 255, xsegid + ((i__3 = segno - 1) <
	     16000 && 0 <= i__3 ? i__3 : s_rnge("xsegid", i__3, "f_pckbsr__", 
	    (ftnlen)2352)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)
	    40);
    repmi_(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_pckbsr__", (ftnlen)2353)) * 40, "#", &segno, 
	    xsegid + ((i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_pckbsr__", (ftnlen)2353)) * 40, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + ((i__1 = segno - 1) < 16000 && 0 <= 
	    i__1 ? i__1 : s_rnge("xsegid", i__1, "f_pckbsr__", (ftnlen)2356)) 
	    * 40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (ftnlen)40);

/*     Check the descriptor as well.  However, don't check the */
/*     segment addresses. */

    t_crdesc__("PCK", &segno, &body, &tbegs[(i__1 = segno - 1) < 16000 && 0 <=
	     i__1 ? i__1 : s_rnge("tbegs", i__1, "f_pckbsr__", (ftnlen)2362)],
	     &tends[(i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
	    "tends", i__2, "f_pckbsr__", (ftnlen)2362)], &xdescr[(i__3 = 
	    segno * 5 - 5) < 80000 && 0 <= i__3 ? i__3 : s_rnge("xdescr", 
	    i__3, "f_pckbsr__", (ftnlen)2362)], (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[(i__1 = segno * 5 - 5) < 80000 && 0 
	    <= i__1 ? i__1 : s_rnge("xdescr", i__1, "f_pckbsr__", (ftnlen)
	    2367)], &c__3, &c_b31, ok, (ftnlen)5, (ftnlen)1);
    tcase_("Dump segment list from PCK 10.  While searching list for segment"
	    " for body 4, make lower bound of re-use interval = upper bound o"
	    "f segment descriptor.", (ftnlen)149);
    pckno = 7;
    body = 4;
    tbegs[8] = (doublereal) (pckno * 10000);
    tends[8] = tbegs[8] + 3.;
    t = tends[8] + .5;
    pcksfs_(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    tcase_("Dump segment list from PCK 10.  While searching list for segment"
	    " for body 5, make lower bound of re-use interval > lower bound o"
	    "f segment descriptor.", (ftnlen)149);
    pckno = 7;
    body = 5;
    ids[17] = body;
    ids[18] = body;
    ids[19] = body;
    tbegs[19] = pckno * 10000 + 10.;
    tends[19] = tbegs[19] + 3.;
    tbegs[18] = tbegs[19] - 2.;
    tends[18] = tbegs[18] + 3.;
    tbegs[17] = tbegs[18] - 2.;
    tends[17] = tends[19] + 1.;
    t = tends[17] - .5;
    pcksfs_(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = pckno - 1) < 10 && 0 <= 
	    i__1 ? i__1 : s_rnge("hndles", i__1, "f_pckbsr__", (ftnlen)2419)],
	     &c__0, ok, (ftnlen)6, (ftnlen)1);
    segno = 18;
    s_copy(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_pckbsr__", (ftnlen)2423)) * 40, "File: # Segn"
	    "o: #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_pckbsr__", (ftnlen)2424)) * 40, "#", pcks + ((
	    i__2 = pckno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("pcks", i__2, 
	    "f_pckbsr__", (ftnlen)2424)) * 255, xsegid + ((i__3 = segno - 1) <
	     16000 && 0 <= i__3 ? i__3 : s_rnge("xsegid", i__3, "f_pckbsr__", 
	    (ftnlen)2424)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)
	    40);
    repmi_(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_pckbsr__", (ftnlen)2425)) * 40, "#", &segno, 
	    xsegid + ((i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_pckbsr__", (ftnlen)2425)) * 40, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + ((i__1 = segno - 1) < 16000 && 0 <= 
	    i__1 ? i__1 : s_rnge("xsegid", i__1, "f_pckbsr__", (ftnlen)2428)) 
	    * 40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (ftnlen)40);

/*     Check the descriptor as well.  However, don't check the */
/*     segment addresses. */

    t_crdesc__("PCK", &segno, &body, &tbegs[(i__1 = segno - 1) < 16000 && 0 <=
	     i__1 ? i__1 : s_rnge("tbegs", i__1, "f_pckbsr__", (ftnlen)2434)],
	     &tends[(i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
	    "tends", i__2, "f_pckbsr__", (ftnlen)2434)], &xdescr[(i__3 = 
	    segno * 5 - 5) < 80000 && 0 <= i__3 ? i__3 : s_rnge("xdescr", 
	    i__3, "f_pckbsr__", (ftnlen)2434)], (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[(i__1 = segno * 5 - 5) < 80000 && 0 
	    <= i__1 ? i__1 : s_rnge("xdescr", i__1, "f_pckbsr__", (ftnlen)
	    2439)], &c__3, &c_b31, ok, (ftnlen)5, (ftnlen)1);
    tcase_("Create a situation where room is needed in the body table, and t"
	    "he second body list has expense greater than the first.", (ftnlen)
	    119);

/*     Unload PCKs 7 and 10. */

    pckuof_(&hndles[6]);
    pckuof_(&hndles[9]);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Fill up (nearly) the segment table with a cheap list for body 2 */
/*     and an expensive list for body 1. */

    pckno = 7;
    pcklof_(pcks + ((i__1 = pckno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge(
	    "pcks", i__1, "f_pckbsr__", (ftnlen)2460)) * 255, &hndles[(i__2 = 
	    pckno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("hndles", i__2, 
	    "f_pckbsr__", (ftnlen)2460)], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    body = 2;
    ids[1] = body;
    ids[2] = body;
    tbegs[2] = (doublereal) (pckno * 10000);
    tends[2] = tbegs[2] + 1.;
    body = 2;
    segno = 3;
    d__1 = tbegs[(i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "tbegs", i__1, "f_pckbsr__", (ftnlen)2474)] + .5f;
    pcksfs_(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     In this case, the segment should be found.  Make sure we get */
/*     back the right handle and segment identifier. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = pckno - 1) < 10 && 0 <= 
	    i__1 ? i__1 : s_rnge("hndles", i__1, "f_pckbsr__", (ftnlen)2483)],
	     &c__0, ok, (ftnlen)6, (ftnlen)1);
    pcklof_(pcks + 2295, &hndles[9], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    body = 1;
    pckno = 10;
    segno = 1;
    i__ = 1;
    tbegs[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs", i__1,
	     "f_pckbsr__", (ftnlen)2493)] = (doublereal) (pckno * 10000 + i__ 
	    - 1);
    tends[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tends", i__1,
	     "f_pckbsr__", (ftnlen)2494)] = tbegs[(i__2 = i__ - 1) < 16000 && 
	    0 <= i__2 ? i__2 : s_rnge("tbegs", i__2, "f_pckbsr__", (ftnlen)
	    2494)] + 1;
    d__1 = tbegs[0] + .5f;
    pcksfs_(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = pckno - 1) < 10 && 0 <= 
	    i__1 ? i__1 : s_rnge("hndles", i__1, "f_pckbsr__", (ftnlen)2501)],
	     &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Now do a look up for body 3.  This should cause the segment */
/*     lists for bodies 2 and 1 to get dumped. */

    body = 3;
    pckno = 10;
    i__ = 1;
    j = (body - 1) * 97 + i__;
    tbegs[(i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs", i__1, 
	    "f_pckbsr__", (ftnlen)2513)] = (doublereal) (pckno * 10000 + i__ 
	    - 1);
    tends[(i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tends", i__1, 
	    "f_pckbsr__", (ftnlen)2514)] = tbegs[(i__2 = i__ - 1) < 16000 && 
	    0 <= i__2 ? i__2 : s_rnge("tbegs", i__2, "f_pckbsr__", (ftnlen)
	    2514)] + 1;
    s_copy(xsegid + ((i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_pckbsr__", (ftnlen)2516)) * 40, "File: # Segn"
	    "o: #  Body:  #", (ftnlen)40, (ftnlen)26);
    repmc_(xsegid + ((i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_pckbsr__", (ftnlen)2518)) * 40, "#", pcks + ((
	    i__2 = pckno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("pcks", i__2, 
	    "f_pckbsr__", (ftnlen)2518)) * 255, xsegid + ((i__3 = i__ - 1) < 
	    16000 && 0 <= i__3 ? i__3 : s_rnge("xsegid", i__3, "f_pckbsr__", (
	    ftnlen)2518)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)
	    40);
    repmi_(xsegid + ((i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_pckbsr__", (ftnlen)2519)) * 40, "#", &j, 
	    xsegid + ((i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_pckbsr__", (ftnlen)2519)) * 40, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);
    repmi_(xsegid + ((i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_pckbsr__", (ftnlen)2520)) * 40, "#", &body, 
	    xsegid + ((i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_pckbsr__", (ftnlen)2520)) * 40, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    segno = j;
    d__1 = tbegs[(i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs", 
	    i__1, "f_pckbsr__", (ftnlen)2525)] + .5f;
    pcksfs_(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = pckno - 1) < 10 && 0 <= 
	    i__1 ? i__1 : s_rnge("hndles", i__1, "f_pckbsr__", (ftnlen)2530)],
	     &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Return on entry in RETURN mode, if the error status is set. */

    tcase_("Make sure all PCKBSR entry points return on entry when RETURN() "
	    "is .TRUE.", (ftnlen)73);

/*     Depending on whether we're calling a version of PCKBSR that does */
/*     coverage checking, the error status may be reset. */
    s_copy(smsg, "Return on entry", (ftnlen)25, (ftnlen)15);
    sigerr_(smsg, (ftnlen)25);
    pckbsr_(" ", &c__1, &c__1, &c_b31, descr, segid, &found, (ftnlen)1, (
	    ftnlen)40);
    if (return_()) {
	chckxc_(&c_true, smsg, ok, (ftnlen)25);
    } else {
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    sigerr_(smsg, (ftnlen)25);
    pcklof_(" ", &handle, (ftnlen)1);
    if (return_()) {
	chckxc_(&c_true, smsg, ok, (ftnlen)25);
    } else {
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    sigerr_(smsg, (ftnlen)25);
    pckuof_(&handle);
    if (return_()) {
	chckxc_(&c_true, smsg, ok, (ftnlen)25);
    } else {
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    sigerr_(smsg, (ftnlen)25);
    pcksfs_(&c__1, &c_b31, &handle, descr, segid, &found, (ftnlen)40);
    if (return_()) {
	chckxc_(&c_true, smsg, ok, (ftnlen)25);
    } else {
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    tcase_("Make sure an error is signaled if PCKBSR is called directly and "
	    "RETURN() is .FALSE.", (ftnlen)83);
    pckbsr_(" ", &c__1, &c__1, &c_b31, descr, segid, &found, (ftnlen)1, (
	    ftnlen)40);
    chckxc_(&c_true, "SPICE(BOGUSENTRY)", ok, (ftnlen)17);
    tcase_("Try DAFOPR error handling.", (ftnlen)26);
    pcklof_("ThisFileDoesNotExist", &handle, (ftnlen)20);
    if (return_()) {
	chckxc_(&c_true, "SPICE(FILENOTFOUND)", ok, (ftnlen)19);
    } else {
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    tcase_("Test partial deletion of a segment list when a file is unloaded.",
	     (ftnlen)64);

/*     Unload the PCK files.  The load files 1 and 2. */

    for (i__ = 1; i__ <= 10; ++i__) {
	pckuof_(&hndles[(i__1 = i__ - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge(
		"hndles", i__1, "f_pckbsr__", (ftnlen)2623)]);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    for (i__ = 1; i__ <= 2; ++i__) {
	pcklof_(pcks + ((i__1 = i__ - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge(
		"pcks", i__1, "f_pckbsr__", (ftnlen)2629)) * 255, &hndles[(
		i__2 = i__ - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("hndles", 
		i__2, "f_pckbsr__", (ftnlen)2629)], (ftnlen)255);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Do lookups for body 1 that hit both files. */

    body = 1;
    tbegs[0] = 1e4;
    d__1 = tbegs[0] + .5f;
    pcksfs_(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    body = 1;
    pckno = 2;
    segno = nseg[(i__1 = pckno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("nseg", 
	    i__1, "f_pckbsr__", (ftnlen)2647)] / 2 + 1;
    tbegs[(i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs", 
	    i__1, "f_pckbsr__", (ftnlen)2649)] = (doublereal) (pckno * 10000 
	    + segno - 1);
    d__1 = tbegs[(i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "tbegs", i__1, "f_pckbsr__", (ftnlen)2651)] + .5f;
    pcksfs_(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Do a lookup for body 2 to create a segment list for that */
/*     body. */

    body = 2;
    pckno = 2;
    segno = nseg[(i__1 = pckno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("nseg", 
	    i__1, "f_pckbsr__", (ftnlen)2663)] / 2;
    tbegs[(i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs", 
	    i__1, "f_pckbsr__", (ftnlen)2665)] = (doublereal) (pckno * 10000 
	    + segno - 1);
    d__1 = tbegs[(i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "tbegs", i__1, "f_pckbsr__", (ftnlen)2667)] + .5f;
    pcksfs_(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Reload file 1, removing the portion of body 1's segment list */
/*     that came from file 1, as part of the unload process that */
/*     precedes re-loading file 1. */

    pcklof_(pcks, hndles, (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Create FTSIZE copies of PCK 1 and load FTSIZE-1 of them.  We */
/*     should get a file table overflow error. */

    tcase_("File table overflow error.", (ftnlen)26);
    for (i__ = 1; i__ <= 1000; ++i__) {
	s_copy(pckcpy + ((i__1 = i__ - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge(
		"pckcpy", i__1, "f_pckbsr__", (ftnlen)2692)) * 255, "copy#.b"
		"pc", (ftnlen)255, (ftnlen)9);
	repmi_(pckcpy + ((i__1 = i__ - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge(
		"pckcpy", i__1, "f_pckbsr__", (ftnlen)2693)) * 255, "#", &i__,
		 pckcpy + ((i__2 = i__ - 1) < 1000 && 0 <= i__2 ? i__2 : 
		s_rnge("pckcpy", i__2, "f_pckbsr__", (ftnlen)2693)) * 255, (
		ftnlen)255, (ftnlen)1, (ftnlen)255);
	body = 1;
	tbegs[0] = 1e4;
	tends[0] = 10001.;
	pckno = 1;
	s_copy(xsegid, "File: # Segno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid, "#", pckcpy + ((i__1 = i__ - 1) < 1000 && 0 <= i__1 ? 
		i__1 : s_rnge("pckcpy", i__1, "f_pckbsr__", (ftnlen)2701)) * 
		255, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
	repmi_(xsegid, "#", &c__1, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	t_crdaf__("PCK", pckcpy + ((i__1 = i__ - 1) < 1000 && 0 <= i__1 ? 
		i__1 : s_rnge("pckcpy", i__1, "f_pckbsr__", (ftnlen)2705)) * 
		255, nseg, &body, tbegs, tends, xsegid, (ftnlen)3, (ftnlen)
		255, (ftnlen)40);
    }
    for (i__ = 1; i__ <= 998; ++i__) {
	pcklof_(pckcpy + ((i__1 = i__ - 1) < 1000 && 0 <= i__1 ? i__1 : 
		s_rnge("pckcpy", i__1, "f_pckbsr__", (ftnlen)2712)) * 255, &
		cpyhan[(i__2 = i__ - 1) < 1000 && 0 <= i__2 ? i__2 : s_rnge(
		"cpyhan", i__2, "f_pckbsr__", (ftnlen)2712)], (ftnlen)255);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    pcklof_(pckcpy + 254490, &cpyhan[998], (ftnlen)255);

/*     Note:  if FTSIZE >= the file table size in the handle manager, */
/*     the appropriate check would be */

/*        CALL CHCKXC ( .TRUE., 'SPICE(FTFULL)', OK ) */

    chckxc_(&c_true, "SPICE(FTFULL)", ok, (ftnlen)13);

/*     Loading, unloading, and priority checks: */

    tcase_("Load all copies of PCK 1, looking up the same state from each.  "
	    "Unload the files in reverse order.  Repeat 3 times.", (ftnlen)115)
	    ;

/*     First, make sure all files are unloaded. */

    for (i__ = 1; i__ <= 10; ++i__) {
	pckuof_(&hndles[(i__1 = i__ - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge(
		"hndles", i__1, "f_pckbsr__", (ftnlen)2740)]);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    for (i__ = 1; i__ <= 999; ++i__) {
	pckuof_(&cpyhan[(i__1 = i__ - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge(
		"cpyhan", i__1, "f_pckbsr__", (ftnlen)2747)]);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    body = 1;
    for (i__ = 1; i__ <= 3; ++i__) {
	for (j = 1; j <= 1000; ++j) {
	    tbegs[(i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs",
		     i__1, "f_pckbsr__", (ftnlen)2758)] = 1e4;
	    tends[(i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tends",
		     i__1, "f_pckbsr__", (ftnlen)2759)] = 10001.;
	    pcklof_(pckcpy + ((i__1 = j - 1) < 1000 && 0 <= i__1 ? i__1 : 
		    s_rnge("pckcpy", i__1, "f_pckbsr__", (ftnlen)2761)) * 255,
		     &cpyhan[(i__2 = j - 1) < 1000 && 0 <= i__2 ? i__2 : 
		    s_rnge("cpyhan", i__2, "f_pckbsr__", (ftnlen)2761)], (
		    ftnlen)255);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    s_copy(xsegid + ((i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : 
		    s_rnge("xsegid", i__1, "f_pckbsr__", (ftnlen)2764)) * 40, 
		    "File: # Segno: #", (ftnlen)40, (ftnlen)16);
	    repmc_(xsegid + ((i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : 
		    s_rnge("xsegid", i__1, "f_pckbsr__", (ftnlen)2765)) * 40, 
		    "#", pckcpy + ((i__2 = j - 1) < 1000 && 0 <= i__2 ? i__2 :
		     s_rnge("pckcpy", i__2, "f_pckbsr__", (ftnlen)2765)) * 
		    255, xsegid + ((i__3 = j - 1) < 16000 && 0 <= i__3 ? i__3 
		    : s_rnge("xsegid", i__3, "f_pckbsr__", (ftnlen)2765)) * 
		    40, (ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
	    repmi_(xsegid + ((i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : 
		    s_rnge("xsegid", i__1, "f_pckbsr__", (ftnlen)2766)) * 40, 
		    "#", &c__1, xsegid + ((i__2 = j - 1) < 16000 && 0 <= i__2 
		    ? i__2 : s_rnge("xsegid", i__2, "f_pckbsr__", (ftnlen)
		    2766)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    d__1 = tbegs[(i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
		    "tbegs", i__1, "f_pckbsr__", (ftnlen)2769)] + .5f;
	    pcksfs_(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           In this case, the segment should be found.  Make sure */
/*           we get back the right handle and segment identifier. */

	    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	    chcksi_("HANDLE", &handle, "=", &cpyhan[(i__1 = j - 1) < 1000 && 
		    0 <= i__1 ? i__1 : s_rnge("cpyhan", i__1, "f_pckbsr__", (
		    ftnlen)2778)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	    chcksc_("SEGID", segid, "=", xsegid + ((i__1 = j - 1) < 16000 && 
		    0 <= i__1 ? i__1 : s_rnge("xsegid", i__1, "f_pckbsr__", (
		    ftnlen)2779)) * 40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, 
		    (ftnlen)40);

/*           Check the descriptor as well.  However, don't check the */
/*           segment addresses. */

	    t_crdesc__("PCK", &c__1, &body, &tbegs[(i__1 = j - 1) < 16000 && 
		    0 <= i__1 ? i__1 : s_rnge("tbegs", i__1, "f_pckbsr__", (
		    ftnlen)2785)], &tends[(i__2 = j - 1) < 16000 && 0 <= i__2 
		    ? i__2 : s_rnge("tends", i__2, "f_pckbsr__", (ftnlen)2785)
		    ], &xdescr[(i__3 = j * 5 - 5) < 80000 && 0 <= i__3 ? i__3 
		    : s_rnge("xdescr", i__3, "f_pckbsr__", (ftnlen)2785)], (
		    ftnlen)3);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    t_chds__("DESCR", descr, "=", &xdescr[(i__1 = j * 5 - 5) < 80000 
		    && 0 <= i__1 ? i__1 : s_rnge("xdescr", i__1, "f_pckbsr__",
		     (ftnlen)2789)], &c__3, &c_b31, ok, (ftnlen)5, (ftnlen)1);
	}

/*        Now unload files, looking up states as we go. */

	for (j = 999; j >= 1; --j) {
	    pckuof_(&cpyhan[(i__1 = j) < 1000 && 0 <= i__1 ? i__1 : s_rnge(
		    "cpyhan", i__1, "f_pckbsr__", (ftnlen)2799)]);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    tbegs[(i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs",
		     i__1, "f_pckbsr__", (ftnlen)2802)] = 1e4;
	    tends[(i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tends",
		     i__1, "f_pckbsr__", (ftnlen)2803)] = 10001.;
	    s_copy(xsegid + ((i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : 
		    s_rnge("xsegid", i__1, "f_pckbsr__", (ftnlen)2805)) * 40, 
		    "File: # Segno: #", (ftnlen)40, (ftnlen)16);
	    repmc_(xsegid + ((i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : 
		    s_rnge("xsegid", i__1, "f_pckbsr__", (ftnlen)2806)) * 40, 
		    "#", pckcpy + ((i__2 = j - 1) < 1000 && 0 <= i__2 ? i__2 :
		     s_rnge("pckcpy", i__2, "f_pckbsr__", (ftnlen)2806)) * 
		    255, xsegid + ((i__3 = j - 1) < 16000 && 0 <= i__3 ? i__3 
		    : s_rnge("xsegid", i__3, "f_pckbsr__", (ftnlen)2806)) * 
		    40, (ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
	    repmi_(xsegid + ((i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : 
		    s_rnge("xsegid", i__1, "f_pckbsr__", (ftnlen)2807)) * 40, 
		    "#", &c__1, xsegid + ((i__2 = j - 1) < 16000 && 0 <= i__2 
		    ? i__2 : s_rnge("xsegid", i__2, "f_pckbsr__", (ftnlen)
		    2807)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    d__1 = tbegs[(i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
		    "tbegs", i__1, "f_pckbsr__", (ftnlen)2810)] + .5f;
	    pcksfs_(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           In this case, the segment should be found.  Make sure */
/*           we get back the right handle and segment identifier. */

	    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	    chcksi_("HANDLE", &handle, "=", &cpyhan[(i__1 = j - 1) < 1000 && 
		    0 <= i__1 ? i__1 : s_rnge("cpyhan", i__1, "f_pckbsr__", (
		    ftnlen)2819)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	    chcksc_("SEGID", segid, "=", xsegid + ((i__1 = j - 1) < 16000 && 
		    0 <= i__1 ? i__1 : s_rnge("xsegid", i__1, "f_pckbsr__", (
		    ftnlen)2820)) * 40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, 
		    (ftnlen)40);

/*           Check the descriptor as well.  However, don't check the */
/*           segment addresses. */

	    t_crdesc__("PCK", &c__1, &body, &tbegs[(i__1 = j - 1) < 16000 && 
		    0 <= i__1 ? i__1 : s_rnge("tbegs", i__1, "f_pckbsr__", (
		    ftnlen)2826)], &tends[(i__2 = j - 1) < 16000 && 0 <= i__2 
		    ? i__2 : s_rnge("tends", i__2, "f_pckbsr__", (ftnlen)2826)
		    ], &xdescr[(i__3 = j * 5 - 5) < 80000 && 0 <= i__3 ? i__3 
		    : s_rnge("xdescr", i__3, "f_pckbsr__", (ftnlen)2826)], (
		    ftnlen)3);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    t_chds__("DESCR", descr, "=", &xdescr[(i__1 = j * 5 - 5) < 80000 
		    && 0 <= i__1 ? i__1 : s_rnge("xdescr", i__1, "f_pckbsr__",
		     (ftnlen)2830)], &c__3, &c_b31, ok, (ftnlen)5, (ftnlen)1);
	}
    }

/*     Make sure we don't accumulate DAF links by re-loading a file. */

    tcase_("Load the first PCK file 2*FTSIZE times.", (ftnlen)39);
    for (i__ = 1; i__ <= 2000; ++i__) {
	tbegs[0] = 1e4;
	tends[0] = 10001.;
	pcklof_(pcks, hndles, (ftnlen)255);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	s_copy(xsegid, "File: # Segno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid, "#", pcks, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)255, 
		(ftnlen)40);
	repmi_(xsegid, "#", &c__1, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	d__1 = tbegs[0] + .5f;
	pcksfs_(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        In this case, the segment should be found.  Make sure */
/*        we get back the right handle and segment identifier. */

	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	chcksi_("HANDLE", &handle, "=", hndles, &c__0, ok, (ftnlen)6, (ftnlen)
		1);
	chcksc_("SEGID", segid, "=", xsegid, ok, (ftnlen)5, (ftnlen)40, (
		ftnlen)1, (ftnlen)40);

/*        Check the descriptor as well.  However, don't check the */
/*        segment addresses. */

	t_crdesc__("PCK", &c__1, &body, tbegs, tends, xdescr, (ftnlen)3);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	t_chds__("DESCR", descr, "=", xdescr, &c__3, &c_b31, ok, (ftnlen)5, (
		ftnlen)1);
    }

/*     Last step:  delete all of the PCK files we created. */

    for (i__ = 1; i__ <= 10; ++i__) {
	pckuof_(&hndles[(i__1 = i__ - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge(
		"hndles", i__1, "f_pckbsr__", (ftnlen)2885)]);
	delfil_(pcks + ((i__1 = i__ - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge(
		"pcks", i__1, "f_pckbsr__", (ftnlen)2886)) * 255, (ftnlen)255)
		;
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    for (i__ = 1; i__ <= 1000; ++i__) {
	pckuof_(&cpyhan[(i__1 = i__ - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge(
		"cpyhan", i__1, "f_pckbsr__", (ftnlen)2893)]);
	delfil_(pckcpy + ((i__1 = i__ - 1) < 1000 && 0 <= i__1 ? i__1 : 
		s_rnge("pckcpy", i__1, "f_pckbsr__", (ftnlen)2894)) * 255, (
		ftnlen)255);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    t_success__(ok);
    return 0;
} /* f_pckbsr__ */

