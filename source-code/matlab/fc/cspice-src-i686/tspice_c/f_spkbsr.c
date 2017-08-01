/* f_spkbsr.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__1 = 1;
static logical c_false = FALSE_;
static logical c_true = TRUE_;
static integer c__0 = 0;
static integer c__4 = 4;
static doublereal c_b31 = 0.;
static integer c__2 = 2;

/* $Procedure  F_SPKBSR ( Family of tests for T_SSFS ) */
/* Subroutine */ int f_spkbsr__(logical *ok)
{
    /* Initialized data */

    static char spks[255*10] = "sfs1.bsp                                    "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                   " "sfs2.bsp                                  "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                     " "sfs3.bsp                                "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                       " "sfs4.bsp                              "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                         " "sfs5.bsp                            "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                           " "sfs6.bsp                          "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                             " "sfs7.bsp                        "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                               " "sfs8.bsp                      "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                                 " "sfs9.bsp                    "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                                   " "sfs10.bsp                 "
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
    integer segno;
    doublereal tends[16000];
    logical found;
    extern /* Subroutine */ int repmi_(char *, char *, integer *, char *, 
	    ftnlen, ftnlen, ftnlen), topen_(char *, ftnlen);
    integer spkno;
    extern /* Subroutine */ int t_success__(logical *);
    integer handle;
    extern /* Subroutine */ int chcksc_(char *, char *, char *, char *, 
	    logical *, ftnlen, ftnlen, ftnlen, ftnlen), delfil_(char *, 
	    ftnlen), chckxc_(logical *, char *, logical *, ftnlen), chcksi_(
	    char *, integer *, char *, integer *, integer *, logical *, 
	    ftnlen, ftnlen), t_chds__(char *, doublereal *, char *, 
	    doublereal *, integer *, doublereal *, logical *, ftnlen, ftnlen),
	     chcksl_(char *, logical *, logical *, logical *, ftnlen), 
	    t_slef__(char *, integer *, ftnlen);
    integer hndles[10], cpyhan[110];
    char xsegid[40*16000];
    extern /* Subroutine */ int t_suef__(integer *);
    doublereal xdescr[80000]	/* was [5][16000] */;
    extern /* Subroutine */ int sigerr_(char *, ftnlen), t_sbsr__(char *, 
	    integer *, integer *, doublereal *, doublereal *, char *, logical 
	    *, ftnlen, ftnlen), t_ssfs__(integer *, doublereal *, integer *, 
	    doublereal *, char *, logical *, ftnlen);
    char spkcpy[255*110];
    extern logical return_(void);
    integer ids[16000];
    extern /* Subroutine */ int t_crdaf__(char *, char *, integer *, integer *
	    , doublereal *, doublereal *, char *, ftnlen, ftnlen, ftnlen);

/* $ Abstract */

/*     This routine tests the SPK segment selection and buffering system, */
/*     which is implemented by T_SSFS. */


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

/*   Version 1.0.0 28-NOV-2001 (NJB) */

/* -& */

/*     SPICELIB functions */


/*     Local parameters */


/*     The number of segments in the respective SPK files: */


/*     Other parameters: */


/*     Local variables */


/*     Saved variables */


/*     Initial values */


/*     Begin every test family with an open call. */

    topen_("F_SPKBSR", (ftnlen)8);
    tcase_("The first SPK file contains 1 segment for body 1. Make sure we c"
	    "an look up data from this file.", (ftnlen)95);

/*     Create the first SPK file. */

    body = 1;
    tbegs[0] = 1e4;
    tends[0] = 10001.;
    spkno = 1;
    s_copy(xsegid, "File: # Segno: #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid, "#", spks, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)255, (
	    ftnlen)40);
    repmi_(xsegid, "#", &c__1, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_crdaf__("SPK", spks, nseg, &body, tbegs, tends, xsegid, (ftnlen)3, (
	    ftnlen)255, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_slef__(spks, hndles, (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    d__1 = tbegs[0] + .5f;
    t_ssfs__(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     In this case, the segment should be found.  Make sure we get */
/*     back the right handle and segment identifier. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", hndles, &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1,
	     (ftnlen)40);

/*     Check the descriptor as well.  However, don't check the */
/*     segment addresses. */

    t_crdesc__("SPK", &c__1, &body, tbegs, tends, xdescr, (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_chds__("DESCR", descr, "=", xdescr, &c__4, &c_b31, ok, (ftnlen)5, (
	    ftnlen)1);
    tcase_("Try to look up data for a different body in SPK 1.  Also look up"
	    " data for body 1 for a time which is not covered.", (ftnlen)113);
    d__1 = tbegs[0] + .5f;
    t_ssfs__(&c__2, &d__1, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     In this case, the segment should not be found. */

    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    d__1 = tbegs[0] + 10;
    t_ssfs__(&c__1, &d__1, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     In this case, the segment should not be found. */

    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    tcase_("Create a second SPK containing data for body 1 and body 2.  Load"
	    " this SPK, then look up a state covered by the new file.", (
	    ftnlen)120);
    body = 1;
    spkno = 2;
    i__2 = nseg[(i__1 = spkno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("nseg", 
	    i__1, "f_spkbsr__", (ftnlen)278)];
    for (i__ = 1; i__ <= i__2; ++i__) {
	if (i__ <= nseg[(i__1 = spkno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge(
		"nseg", i__1, "f_spkbsr__", (ftnlen)280)] / 2) {
	    ids[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("ids", 
		    i__1, "f_spkbsr__", (ftnlen)281)] = 2;
	} else {
	    ids[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("ids", 
		    i__1, "f_spkbsr__", (ftnlen)283)] = 1;
	}
	tbegs[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs", 
		i__1, "f_spkbsr__", (ftnlen)286)] = (doublereal) (spkno * 
		10000 + i__ - 1);
	tends[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tends", 
		i__1, "f_spkbsr__", (ftnlen)287)] = tbegs[(i__3 = i__ - 1) < 
		16000 && 0 <= i__3 ? i__3 : s_rnge("tbegs", i__3, "f_spkbsr__"
		, (ftnlen)287)] + 1;
	s_copy(xsegid + ((i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_spkbsr__", (ftnlen)289)) * 40, 
		"File: # Segno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid + ((i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_spkbsr__", (ftnlen)291)) * 40, 
		"#", spks + ((i__3 = spkno - 1) < 10 && 0 <= i__3 ? i__3 : 
		s_rnge("spks", i__3, "f_spkbsr__", (ftnlen)291)) * 255, 
		xsegid + ((i__4 = i__ - 1) < 16000 && 0 <= i__4 ? i__4 : 
		s_rnge("xsegid", i__4, "f_spkbsr__", (ftnlen)291)) * 40, (
		ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
	repmi_(xsegid + ((i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_spkbsr__", (ftnlen)292)) * 40, 
		"#", &i__, xsegid + ((i__3 = i__ - 1) < 16000 && 0 <= i__3 ? 
		i__3 : s_rnge("xsegid", i__3, "f_spkbsr__", (ftnlen)292)) * 
		40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    t_crdaf__("SPK", spks + ((i__2 = spkno - 1) < 10 && 0 <= i__2 ? i__2 : 
	    s_rnge("spks", i__2, "f_spkbsr__", (ftnlen)298)) * 255, &nseg[(
	    i__1 = spkno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("nseg", i__1, 
	    "f_spkbsr__", (ftnlen)298)], ids, tbegs, tends, xsegid, (ftnlen)3,
	     (ftnlen)255, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_slef__(spks + ((i__2 = spkno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge(
	    "spks", i__2, "f_spkbsr__", (ftnlen)303)) * 255, &hndles[(i__1 = 
	    spkno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("hndles", i__1, 
	    "f_spkbsr__", (ftnlen)303)], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    segno = nseg[(i__2 = spkno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("nseg", 
	    i__2, "f_spkbsr__", (ftnlen)306)];
    d__1 = tbegs[(i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
	    "tbegs", i__2, "f_spkbsr__", (ftnlen)308)] + .5f;
    t_ssfs__(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     In this case, the segment should be found.  Make sure we get */
/*     back the right handle and segment identifier. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__2 = spkno - 1) < 10 && 0 <= 
	    i__2 ? i__2 : s_rnge("hndles", i__2, "f_spkbsr__", (ftnlen)317)], 
	    &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + ((i__2 = segno - 1) < 16000 && 0 <= 
	    i__2 ? i__2 : s_rnge("xsegid", i__2, "f_spkbsr__", (ftnlen)318)) *
	     40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (ftnlen)40);

/*     Check the descriptor as well.  However, don't check the */
/*     segment addresses. */

    t_crdesc__("SPK", &segno, &body, &tbegs[(i__2 = segno - 1) < 16000 && 0 <=
	     i__2 ? i__2 : s_rnge("tbegs", i__2, "f_spkbsr__", (ftnlen)324)], 
	    &tends[(i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "tends", i__1, "f_spkbsr__", (ftnlen)324)], &xdescr[(i__3 = segno 
	    * 5 - 5) < 80000 && 0 <= i__3 ? i__3 : s_rnge("xdescr", i__3, 
	    "f_spkbsr__", (ftnlen)324)], (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[(i__2 = segno * 5 - 5) < 80000 && 0 
	    <= i__2 ? i__2 : s_rnge("xdescr", i__2, "f_spkbsr__", (ftnlen)328)
	    ], &c__4, &c_b31, ok, (ftnlen)5, (ftnlen)1);
    tcase_("Look up data for body 2.  This should cause an OLD FILES search.",
	     (ftnlen)64);
    body = 2;
    spkno = 2;
    segno = 1;
    d__1 = tbegs[0] + .5f;
    t_ssfs__(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     In this case, the segment should be found.  Make sure we get */
/*     back the right handle and segment identifier. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__2 = spkno - 1) < 10 && 0 <= 
	    i__2 ? i__2 : s_rnge("hndles", i__2, "f_spkbsr__", (ftnlen)350)], 
	    &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + ((i__2 = segno - 1) < 16000 && 0 <= 
	    i__2 ? i__2 : s_rnge("xsegid", i__2, "f_spkbsr__", (ftnlen)351)) *
	     40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (ftnlen)40);

/*     Check the descriptor as well.  However, don't check the */
/*     segment addresses. */

    t_crdesc__("SPK", &segno, &body, &tbegs[(i__2 = segno - 1) < 16000 && 0 <=
	     i__2 ? i__2 : s_rnge("tbegs", i__2, "f_spkbsr__", (ftnlen)357)], 
	    &tends[(i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "tends", i__1, "f_spkbsr__", (ftnlen)357)], &xdescr[(i__3 = segno 
	    * 5 - 5) < 80000 && 0 <= i__3 ? i__3 : s_rnge("xdescr", i__3, 
	    "f_spkbsr__", (ftnlen)357)], (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[(i__2 = segno * 5 - 5) < 80000 && 0 
	    <= i__2 ? i__2 : s_rnge("xdescr", i__2, "f_spkbsr__", (ftnlen)361)
	    ], &c__4, &c_b31, ok, (ftnlen)5, (ftnlen)1);
    tcase_("Create a third SPK containing data for body 3. Load this SPK, th"
	    "en look up a state covered by the new file. This should cause th"
	    "e segment list for body 1 to get dumped.", (ftnlen)168);
    body = 3;
    spkno = 3;
    i__1 = nseg[(i__2 = spkno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("nseg", 
	    i__2, "f_spkbsr__", (ftnlen)374)];
    for (i__ = 1; i__ <= i__1; ++i__) {
	ids[(i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("ids", i__2,
		 "f_spkbsr__", (ftnlen)376)] = body;
	tbegs[(i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("tbegs", 
		i__2, "f_spkbsr__", (ftnlen)378)] = (doublereal) (spkno * 
		10000 + i__ - 1);
	tends[(i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("tends", 
		i__2, "f_spkbsr__", (ftnlen)379)] = tbegs[(i__3 = i__ - 1) < 
		16000 && 0 <= i__3 ? i__3 : s_rnge("tbegs", i__3, "f_spkbsr__"
		, (ftnlen)379)] + 1;
	s_copy(xsegid + ((i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_spkbsr__", (ftnlen)381)) * 40, 
		"File: # Segno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid + ((i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_spkbsr__", (ftnlen)383)) * 40, 
		"#", spks + ((i__3 = spkno - 1) < 10 && 0 <= i__3 ? i__3 : 
		s_rnge("spks", i__3, "f_spkbsr__", (ftnlen)383)) * 255, 
		xsegid + ((i__4 = i__ - 1) < 16000 && 0 <= i__4 ? i__4 : 
		s_rnge("xsegid", i__4, "f_spkbsr__", (ftnlen)383)) * 40, (
		ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
	repmi_(xsegid + ((i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_spkbsr__", (ftnlen)384)) * 40, 
		"#", &i__, xsegid + ((i__3 = i__ - 1) < 16000 && 0 <= i__3 ? 
		i__3 : s_rnge("xsegid", i__3, "f_spkbsr__", (ftnlen)384)) * 
		40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    t_crdaf__("SPK", spks + ((i__1 = spkno - 1) < 10 && 0 <= i__1 ? i__1 : 
	    s_rnge("spks", i__1, "f_spkbsr__", (ftnlen)390)) * 255, &nseg[(
	    i__2 = spkno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("nseg", i__2, 
	    "f_spkbsr__", (ftnlen)390)], ids, tbegs, tends, xsegid, (ftnlen)3,
	     (ftnlen)255, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_slef__(spks + ((i__1 = spkno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge(
	    "spks", i__1, "f_spkbsr__", (ftnlen)395)) * 255, &hndles[(i__2 = 
	    spkno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("hndles", i__2, 
	    "f_spkbsr__", (ftnlen)395)], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    segno = nseg[(i__1 = spkno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("nseg", 
	    i__1, "f_spkbsr__", (ftnlen)398)];
    d__1 = tbegs[(i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "tbegs", i__1, "f_spkbsr__", (ftnlen)400)] + .5f;
    t_ssfs__(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     In this case, the segment should be found.  Make sure we get */
/*     back the right handle and segment identifier. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = spkno - 1) < 10 && 0 <= 
	    i__1 ? i__1 : s_rnge("hndles", i__1, "f_spkbsr__", (ftnlen)409)], 
	    &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + ((i__1 = segno - 1) < 16000 && 0 <= 
	    i__1 ? i__1 : s_rnge("xsegid", i__1, "f_spkbsr__", (ftnlen)410)) *
	     40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (ftnlen)40);

/*     Check the descriptor as well.  However, don't check the */
/*     segment addresses. */

    t_crdesc__("SPK", &segno, &body, &tbegs[(i__1 = segno - 1) < 16000 && 0 <=
	     i__1 ? i__1 : s_rnge("tbegs", i__1, "f_spkbsr__", (ftnlen)416)], 
	    &tends[(i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
	    "tends", i__2, "f_spkbsr__", (ftnlen)416)], &xdescr[(i__3 = segno 
	    * 5 - 5) < 80000 && 0 <= i__3 ? i__3 : s_rnge("xdescr", i__3, 
	    "f_spkbsr__", (ftnlen)416)], (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[(i__1 = segno * 5 - 5) < 80000 && 0 
	    <= i__1 ? i__1 : s_rnge("xdescr", i__1, "f_spkbsr__", (ftnlen)420)
	    ], &c__4, &c_b31, ok, (ftnlen)5, (ftnlen)1);
    tcase_("Create another SPK for body 1 and load it. The segment count in "
	    "this file is such that all other body lists must be dumped to ma"
	    "ke room. Then make a request that is satisfied by SPK 1. The seg"
	    "ment in SPK 1 cannot be added to the segment table.", (ftnlen)243)
	    ;
    body = 1;
    spkno = 4;
    i__2 = nseg[(i__1 = spkno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("nseg", 
	    i__1, "f_spkbsr__", (ftnlen)438)];
    for (i__ = 1; i__ <= i__2; ++i__) {
	ids[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("ids", i__1,
		 "f_spkbsr__", (ftnlen)440)] = body;
	tbegs[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs", 
		i__1, "f_spkbsr__", (ftnlen)442)] = (doublereal) (spkno * 
		10000 + i__ - 1);
	tends[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tends", 
		i__1, "f_spkbsr__", (ftnlen)443)] = tbegs[(i__3 = i__ - 1) < 
		16000 && 0 <= i__3 ? i__3 : s_rnge("tbegs", i__3, "f_spkbsr__"
		, (ftnlen)443)] + 1;
	s_copy(xsegid + ((i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_spkbsr__", (ftnlen)445)) * 40, 
		"File: # Segno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid + ((i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_spkbsr__", (ftnlen)447)) * 40, 
		"#", spks + ((i__3 = spkno - 1) < 10 && 0 <= i__3 ? i__3 : 
		s_rnge("spks", i__3, "f_spkbsr__", (ftnlen)447)) * 255, 
		xsegid + ((i__4 = i__ - 1) < 16000 && 0 <= i__4 ? i__4 : 
		s_rnge("xsegid", i__4, "f_spkbsr__", (ftnlen)447)) * 40, (
		ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
	repmi_(xsegid + ((i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_spkbsr__", (ftnlen)448)) * 40, 
		"#", &i__, xsegid + ((i__3 = i__ - 1) < 16000 && 0 <= i__3 ? 
		i__3 : s_rnge("xsegid", i__3, "f_spkbsr__", (ftnlen)448)) * 
		40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    t_crdaf__("SPK", spks + ((i__2 = spkno - 1) < 10 && 0 <= i__2 ? i__2 : 
	    s_rnge("spks", i__2, "f_spkbsr__", (ftnlen)453)) * 255, &nseg[(
	    i__1 = spkno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("nseg", i__1, 
	    "f_spkbsr__", (ftnlen)453)], ids, tbegs, tends, xsegid, (ftnlen)3,
	     (ftnlen)255, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_slef__(spks + ((i__2 = spkno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge(
	    "spks", i__2, "f_spkbsr__", (ftnlen)458)) * 255, &hndles[(i__1 = 
	    spkno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("hndles", i__1, 
	    "f_spkbsr__", (ftnlen)458)], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    spkno = 1;
    segno = 1;
    tbegs[(i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("tbegs", 
	    i__2, "f_spkbsr__", (ftnlen)464)] = (doublereal) (spkno * 10000 + 
	    segno - 1);
    tends[(i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("tends", 
	    i__2, "f_spkbsr__", (ftnlen)465)] = (doublereal) (spkno * 10000 + 
	    segno);
    d__1 = tbegs[(i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
	    "tbegs", i__2, "f_spkbsr__", (ftnlen)467)] + .5f;
    t_ssfs__(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     In this case, the segment should be found.  Make sure we get */
/*     back the right handle and segment identifier. */

    s_copy(xsegid + ((i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_spkbsr__", (ftnlen)476)) * 40, "File: # Segno"
	    ": #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid + ((i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_spkbsr__", (ftnlen)477)) * 40, "#", spks + ((
	    i__1 = spkno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("spks", i__1, 
	    "f_spkbsr__", (ftnlen)477)) * 255, xsegid + ((i__3 = segno - 1) < 
	    16000 && 0 <= i__3 ? i__3 : s_rnge("xsegid", i__3, "f_spkbsr__", (
	    ftnlen)477)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40)
	    ;
    repmi_(xsegid + ((i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_spkbsr__", (ftnlen)478)) * 40, "#", &c__1, 
	    xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_spkbsr__", (ftnlen)478)) * 40, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__2 = spkno - 1) < 10 && 0 <= 
	    i__2 ? i__2 : s_rnge("hndles", i__2, "f_spkbsr__", (ftnlen)482)], 
	    &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + ((i__2 = segno - 1) < 16000 && 0 <= 
	    i__2 ? i__2 : s_rnge("xsegid", i__2, "f_spkbsr__", (ftnlen)483)) *
	     40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (ftnlen)40);

/*     Check the descriptor as well.  However, don't check the */
/*     segment addresses. */

    t_crdesc__("SPK", &segno, &body, &tbegs[(i__2 = segno - 1) < 16000 && 0 <=
	     i__2 ? i__2 : s_rnge("tbegs", i__2, "f_spkbsr__", (ftnlen)489)], 
	    &tends[(i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "tends", i__1, "f_spkbsr__", (ftnlen)489)], &xdescr[(i__3 = segno 
	    * 5 - 5) < 80000 && 0 <= i__3 ? i__3 : s_rnge("xdescr", i__3, 
	    "f_spkbsr__", (ftnlen)489)], (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[(i__2 = segno * 5 - 5) < 80000 && 0 
	    <= i__2 ? i__2 : s_rnge("xdescr", i__2, "f_spkbsr__", (ftnlen)493)
	    ], &c__4, &c_b31, ok, (ftnlen)5, (ftnlen)1);
    tcase_("Start a segment list for body 1 by making a request that is sati"
	    "sfied by SPK 1.  Then build a file (SPK 5) with too many segment"
	    "s for body 1 to be buffered.  Make a request that is satisfied b"
	    "y SPK 5. This tests the logic for searching the subset of a segm"
	    "ent list that must be dumped due to lack of room.", (ftnlen)305);

/*     Set up by making a request that will be satisfied by the segment */
/*     in SPK 1.  This builds up the segment list for body 1. */

    body = 1;
    tbegs[0] = 1e4;
    tends[0] = 10001.;
    spkno = 1;
    s_copy(xsegid, "File: # Segno: #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid, "#", spks, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)255, (
	    ftnlen)40);
    repmi_(xsegid, "#", &c__1, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    d__1 = tbegs[0] + .5f;
    t_ssfs__(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Go ahead and make the new file. */

    body = 1;
    spkno = 5;
    i__1 = nseg[(i__2 = spkno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("nseg", 
	    i__2, "f_spkbsr__", (ftnlen)536)];
    for (i__ = 1; i__ <= i__1; ++i__) {
	ids[(i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("ids", i__2,
		 "f_spkbsr__", (ftnlen)538)] = body;
	if (i__ == 10 || i__ == 101) {

/*           We want the lower bound of the re-use interval to */
/*           match the right endpoint of the segment's coverage */
/*           interval. */

	    tbegs[(i__2 = i__ - 2) < 16000 && 0 <= i__2 ? i__2 : s_rnge("tbe"
		    "gs", i__2, "f_spkbsr__", (ftnlen)546)] = (doublereal) (
		    spkno * 10000 + i__);
	    tends[(i__2 = i__ - 2) < 16000 && 0 <= i__2 ? i__2 : s_rnge("ten"
		    "ds", i__2, "f_spkbsr__", (ftnlen)547)] = tbegs[(i__3 = 
		    i__ - 2) < 16000 && 0 <= i__3 ? i__3 : s_rnge("tbegs", 
		    i__3, "f_spkbsr__", (ftnlen)547)] + 1.;
	    tbegs[(i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("tbe"
		    "gs", i__2, "f_spkbsr__", (ftnlen)549)] = (doublereal) (
		    spkno * 10000 + i__ - 1);
	    tends[(i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("ten"
		    "ds", i__2, "f_spkbsr__", (ftnlen)550)] = tbegs[(i__3 = 
		    i__ - 1) < 16000 && 0 <= i__3 ? i__3 : s_rnge("tbegs", 
		    i__3, "f_spkbsr__", (ftnlen)550)] + 1;
	    tbegs[(i__2 = i__) < 16000 && 0 <= i__2 ? i__2 : s_rnge("tbegs", 
		    i__2, "f_spkbsr__", (ftnlen)552)] = tbegs[(i__3 = i__ - 1)
		     < 16000 && 0 <= i__3 ? i__3 : s_rnge("tbegs", i__3, 
		    "f_spkbsr__", (ftnlen)552)];
	    tends[(i__2 = i__) < 16000 && 0 <= i__2 ? i__2 : s_rnge("tends", 
		    i__2, "f_spkbsr__", (ftnlen)553)] = tends[(i__3 = i__ - 1)
		     < 16000 && 0 <= i__3 ? i__3 : s_rnge("tends", i__3, 
		    "f_spkbsr__", (ftnlen)553)];
	    tbegs[(i__2 = i__ + 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("tbe"
		    "gs", i__2, "f_spkbsr__", (ftnlen)555)] = tends[(i__3 = 
		    i__ - 1) < 16000 && 0 <= i__3 ? i__3 : s_rnge("tends", 
		    i__3, "f_spkbsr__", (ftnlen)555)] + 1;
	    tends[(i__2 = i__ + 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("ten"
		    "ds", i__2, "f_spkbsr__", (ftnlen)556)] = tbegs[(i__3 = 
		    i__ + 1) < 16000 && 0 <= i__3 ? i__3 : s_rnge("tbegs", 
		    i__3, "f_spkbsr__", (ftnlen)556)] + 1;
	} else if (i__ == 106) {

/*           Create a singleton segment. */

	    tbegs[(i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("tbe"
		    "gs", i__2, "f_spkbsr__", (ftnlen)563)] = (doublereal) (
		    spkno * 10000 + i__ - 1);
	    tends[(i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("ten"
		    "ds", i__2, "f_spkbsr__", (ftnlen)564)] = tbegs[(i__3 = 
		    i__ - 1) < 16000 && 0 <= i__3 ? i__3 : s_rnge("tbegs", 
		    i__3, "f_spkbsr__", (ftnlen)564)];
	} else if (i__ == 107) {

/*           Create an invisible segment. */

	    tbegs[(i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("tbe"
		    "gs", i__2, "f_spkbsr__", (ftnlen)570)] = (doublereal) (
		    spkno * 10000 + i__ - 1);
	    tends[(i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("ten"
		    "ds", i__2, "f_spkbsr__", (ftnlen)571)] = tbegs[(i__3 = 
		    i__ - 1) < 16000 && 0 <= i__3 ? i__3 : s_rnge("tbegs", 
		    i__3, "f_spkbsr__", (ftnlen)571)] - 1;
	} else if (i__ < 9 || i__ > 12 && i__ < 100 || i__ > 103) {
	    tbegs[(i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("tbe"
		    "gs", i__2, "f_spkbsr__", (ftnlen)577)] = (doublereal) (
		    spkno * 10000 + i__ - 1);
	    tends[(i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("ten"
		    "ds", i__2, "f_spkbsr__", (ftnlen)578)] = tbegs[(i__3 = 
		    i__ - 1) < 16000 && 0 <= i__3 ? i__3 : s_rnge("tbegs", 
		    i__3, "f_spkbsr__", (ftnlen)578)] + 1;
	}
	s_copy(xsegid + ((i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_spkbsr__", (ftnlen)582)) * 40, 
		"File: # Segno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid + ((i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_spkbsr__", (ftnlen)584)) * 40, 
		"#", spks + ((i__3 = spkno - 1) < 10 && 0 <= i__3 ? i__3 : 
		s_rnge("spks", i__3, "f_spkbsr__", (ftnlen)584)) * 255, 
		xsegid + ((i__4 = i__ - 1) < 16000 && 0 <= i__4 ? i__4 : 
		s_rnge("xsegid", i__4, "f_spkbsr__", (ftnlen)584)) * 40, (
		ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
	repmi_(xsegid + ((i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_spkbsr__", (ftnlen)585)) * 40, 
		"#", &i__, xsegid + ((i__3 = i__ - 1) < 16000 && 0 <= i__3 ? 
		i__3 : s_rnge("xsegid", i__3, "f_spkbsr__", (ftnlen)585)) * 
		40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    t_crdaf__("SPK", spks + ((i__1 = spkno - 1) < 10 && 0 <= i__1 ? i__1 : 
	    s_rnge("spks", i__1, "f_spkbsr__", (ftnlen)590)) * 255, &nseg[(
	    i__2 = spkno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("nseg", i__2, 
	    "f_spkbsr__", (ftnlen)590)], ids, tbegs, tends, xsegid, (ftnlen)3,
	     (ftnlen)255, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_slef__(spks + ((i__1 = spkno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge(
	    "spks", i__1, "f_spkbsr__", (ftnlen)595)) * 255, &hndles[(i__2 = 
	    spkno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("hndles", i__2, 
	    "f_spkbsr__", (ftnlen)595)], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    segno = 1;
    d__1 = tbegs[(i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "tbegs", i__1, "f_spkbsr__", (ftnlen)600)] + .5f;
    t_ssfs__(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     In this case, the segment should be found.  Make sure we get */
/*     back the right handle and segment identifier. */

    s_copy(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_spkbsr__", (ftnlen)609)) * 40, "File: # Segno"
	    ": #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_spkbsr__", (ftnlen)610)) * 40, "#", spks + ((
	    i__2 = spkno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("spks", i__2, 
	    "f_spkbsr__", (ftnlen)610)) * 255, xsegid + ((i__3 = segno - 1) < 
	    16000 && 0 <= i__3 ? i__3 : s_rnge("xsegid", i__3, "f_spkbsr__", (
	    ftnlen)610)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40)
	    ;
    repmi_(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_spkbsr__", (ftnlen)611)) * 40, "#", &c__1, 
	    xsegid + ((i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_spkbsr__", (ftnlen)611)) * 40, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = spkno - 1) < 10 && 0 <= 
	    i__1 ? i__1 : s_rnge("hndles", i__1, "f_spkbsr__", (ftnlen)615)], 
	    &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + ((i__1 = segno - 1) < 16000 && 0 <= 
	    i__1 ? i__1 : s_rnge("xsegid", i__1, "f_spkbsr__", (ftnlen)616)) *
	     40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (ftnlen)40);

/*     Check the descriptor as well.  However, don't check the */
/*     segment addresses. */

    t_crdesc__("SPK", &segno, &body, &tbegs[(i__1 = segno - 1) < 16000 && 0 <=
	     i__1 ? i__1 : s_rnge("tbegs", i__1, "f_spkbsr__", (ftnlen)622)], 
	    &tends[(i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
	    "tends", i__2, "f_spkbsr__", (ftnlen)622)], &xdescr[(i__3 = segno 
	    * 5 - 5) < 80000 && 0 <= i__3 ? i__3 : s_rnge("xdescr", i__3, 
	    "f_spkbsr__", (ftnlen)622)], (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[(i__1 = segno * 5 - 5) < 80000 && 0 
	    <= i__1 ? i__1 : s_rnge("xdescr", i__1, "f_spkbsr__", (ftnlen)626)
	    ], &c__4, &c_b31, ok, (ftnlen)5, (ftnlen)1);
    tcase_("Create an SPK containing data for BTSIZE new bodies. Look up dat"
	    "a for each.", (ftnlen)75);

/*     Unload all SPKs. */

    for (i__ = 1; i__ <= 10; ++i__) {
	t_suef__(&hndles[(i__1 = i__ - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge(
		"hndles", i__1, "f_spkbsr__", (ftnlen)642)]);
    }
    spkno = 6;
    i__2 = nseg[(i__1 = spkno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("nseg", 
	    i__1, "f_spkbsr__", (ftnlen)647)];
    for (i__ = 1; i__ <= i__2; ++i__) {
	ids[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("ids", i__1,
		 "f_spkbsr__", (ftnlen)649)] = i__ + 20;
	tbegs[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs", 
		i__1, "f_spkbsr__", (ftnlen)651)] = (doublereal) (spkno * 
		10000 + i__ - 1);
	tends[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tends", 
		i__1, "f_spkbsr__", (ftnlen)652)] = tbegs[(i__3 = i__ - 1) < 
		16000 && 0 <= i__3 ? i__3 : s_rnge("tbegs", i__3, "f_spkbsr__"
		, (ftnlen)652)] + 1;
	s_copy(xsegid + ((i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_spkbsr__", (ftnlen)654)) * 40, 
		"File: # Segno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid + ((i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_spkbsr__", (ftnlen)656)) * 40, 
		"#", spks + ((i__3 = spkno - 1) < 10 && 0 <= i__3 ? i__3 : 
		s_rnge("spks", i__3, "f_spkbsr__", (ftnlen)656)) * 255, 
		xsegid + ((i__4 = i__ - 1) < 16000 && 0 <= i__4 ? i__4 : 
		s_rnge("xsegid", i__4, "f_spkbsr__", (ftnlen)656)) * 40, (
		ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
	repmi_(xsegid + ((i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_spkbsr__", (ftnlen)657)) * 40, 
		"#", &i__, xsegid + ((i__3 = i__ - 1) < 16000 && 0 <= i__3 ? 
		i__3 : s_rnge("xsegid", i__3, "f_spkbsr__", (ftnlen)657)) * 
		40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    t_crdaf__("SPK", spks + ((i__2 = spkno - 1) < 10 && 0 <= i__2 ? i__2 : 
	    s_rnge("spks", i__2, "f_spkbsr__", (ftnlen)662)) * 255, &nseg[(
	    i__1 = spkno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("nseg", i__1, 
	    "f_spkbsr__", (ftnlen)662)], ids, tbegs, tends, xsegid, (ftnlen)3,
	     (ftnlen)255, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_slef__(spks + ((i__2 = spkno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge(
	    "spks", i__2, "f_spkbsr__", (ftnlen)667)) * 255, &hndles[(i__1 = 
	    spkno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("hndles", i__1, 
	    "f_spkbsr__", (ftnlen)667)], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    i__1 = nseg[(i__2 = spkno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("nseg", 
	    i__2, "f_spkbsr__", (ftnlen)671)];
    for (i__ = 1; i__ <= i__1; ++i__) {
	body = ids[(i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
		"ids", i__2, "f_spkbsr__", (ftnlen)673)];
	segno = i__;
	d__1 = tbegs[(i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
		"tbegs", i__2, "f_spkbsr__", (ftnlen)676)] + .5f;
	t_ssfs__(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        In this case, the segment should be found.  Make sure we get */
/*        back the right handle and segment identifier. */

	s_copy(xsegid + ((i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_spkbsr__", (ftnlen)684)) * 40, 
		"File: # Segno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid + ((i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_spkbsr__", (ftnlen)685)) * 40, 
		"#", spks + ((i__3 = spkno - 1) < 10 && 0 <= i__3 ? i__3 : 
		s_rnge("spks", i__3, "f_spkbsr__", (ftnlen)685)) * 255, 
		xsegid + ((i__4 = segno - 1) < 16000 && 0 <= i__4 ? i__4 : 
		s_rnge("xsegid", i__4, "f_spkbsr__", (ftnlen)685)) * 40, (
		ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
	repmi_(xsegid + ((i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_spkbsr__", (ftnlen)686)) * 40, 
		"#", &segno, xsegid + ((i__3 = segno - 1) < 16000 && 0 <= 
		i__3 ? i__3 : s_rnge("xsegid", i__3, "f_spkbsr__", (ftnlen)
		686)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	chcksi_("HANDLE", &handle, "=", &hndles[(i__2 = spkno - 1) < 10 && 0 
		<= i__2 ? i__2 : s_rnge("hndles", i__2, "f_spkbsr__", (ftnlen)
		690)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	chcksc_("SEGID", segid, "=", xsegid + ((i__2 = segno - 1) < 16000 && 
		0 <= i__2 ? i__2 : s_rnge("xsegid", i__2, "f_spkbsr__", (
		ftnlen)691)) * 40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (
		ftnlen)40);

/*        Check the descriptor as well.  However, don't check the */
/*        segment addresses. */

	t_crdesc__("SPK", &segno, &body, &tbegs[(i__2 = segno - 1) < 16000 && 
		0 <= i__2 ? i__2 : s_rnge("tbegs", i__2, "f_spkbsr__", (
		ftnlen)697)], &tends[(i__3 = segno - 1) < 16000 && 0 <= i__3 ?
		 i__3 : s_rnge("tends", i__3, "f_spkbsr__", (ftnlen)697)], &
		xdescr[(i__4 = segno * 5 - 5) < 80000 && 0 <= i__4 ? i__4 : 
		s_rnge("xdescr", i__4, "f_spkbsr__", (ftnlen)697)], (ftnlen)3)
		;
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	t_chds__("DESCR", descr, "=", &xdescr[(i__2 = segno * 5 - 5) < 80000 
		&& 0 <= i__2 ? i__2 : s_rnge("xdescr", i__2, "f_spkbsr__", (
		ftnlen)701)], &c__4, &c_b31, ok, (ftnlen)5, (ftnlen)1);
    }
    tcase_("The body table should be full now; the segment table should have"
	    " room.  Cause a body list to be dumped to make room in the body "
	    "table.", (ftnlen)134);

/*     Create a list for body 1 more expensive than those for the */
/*     bodies in SPK 6.  Body 1's list will be placed at the head of */
/*     the body table. */

    body = 1;
    spkno = 2;
    segno = nseg[(i__1 = spkno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("nseg", 
	    i__1, "f_spkbsr__", (ftnlen)724)];
    i__ = segno;
    tbegs[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs", i__1,
	     "f_spkbsr__", (ftnlen)726)] = (doublereal) (spkno * 10000 + i__ 
	    - 1);
    tends[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tends", i__1,
	     "f_spkbsr__", (ftnlen)727)] = tbegs[(i__2 = i__ - 1) < 16000 && 
	    0 <= i__2 ? i__2 : s_rnge("tbegs", i__2, "f_spkbsr__", (ftnlen)
	    727)] + 1;
    s_copy(xsegid, "File: # Segno: #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid, "#", spks + ((i__1 = spkno - 1) < 10 && 0 <= i__1 ? i__1 : 
	    s_rnge("spks", i__1, "f_spkbsr__", (ftnlen)730)) * 255, xsegid, (
	    ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
    repmi_(xsegid, "#", &segno, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_slef__(spks + 255, &hndles[1], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    d__1 = tbegs[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs"
	    , i__1, "f_spkbsr__", (ftnlen)738)] + .5f;
    t_ssfs__(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     In this case, the segment should be found.  Make sure we get */
/*     back the right handle and segment identifier. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = spkno - 1) < 10 && 0 <= 
	    i__1 ? i__1 : s_rnge("hndles", i__1, "f_spkbsr__", (ftnlen)747)], 
	    &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1,
	     (ftnlen)40);

/*     Check the descriptor as well.  However, don't check the */
/*     segment addresses. */

    t_crdesc__("SPK", &segno, &body, &tbegs[(i__1 = i__ - 1) < 16000 && 0 <= 
	    i__1 ? i__1 : s_rnge("tbegs", i__1, "f_spkbsr__", (ftnlen)754)], &
	    tends[(i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("ten"
	    "ds", i__2, "f_spkbsr__", (ftnlen)754)], xdescr, (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_chds__("DESCR", descr, "=", xdescr, &c__4, &c_b31, ok, (ftnlen)5, (
	    ftnlen)1);

/*     Now do a look up for body 2.  This will require dumping lists */
/*     from SPK 6. */

    body = 2;
    spkno = 2;
    segno = 1;
    i__ = segno;
    tbegs[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs", i__1,
	     "f_spkbsr__", (ftnlen)769)] = (doublereal) (spkno * 10000 + i__ 
	    - 1);
    tends[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tends", i__1,
	     "f_spkbsr__", (ftnlen)770)] = tbegs[(i__2 = i__ - 1) < 16000 && 
	    0 <= i__2 ? i__2 : s_rnge("tbegs", i__2, "f_spkbsr__", (ftnlen)
	    770)] + 1;
    s_copy(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_spkbsr__", (ftnlen)774)) * 40, "File: # Segno"
	    ": #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_spkbsr__", (ftnlen)775)) * 40, "#", spks + ((
	    i__2 = spkno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("spks", i__2, 
	    "f_spkbsr__", (ftnlen)775)) * 255, xsegid + ((i__3 = segno - 1) < 
	    16000 && 0 <= i__3 ? i__3 : s_rnge("xsegid", i__3, "f_spkbsr__", (
	    ftnlen)775)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40)
	    ;
    repmi_(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_spkbsr__", (ftnlen)776)) * 40, "#", &segno, 
	    xsegid + ((i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_spkbsr__", (ftnlen)776)) * 40, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    d__1 = tbegs[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs"
	    , i__1, "f_spkbsr__", (ftnlen)779)] + .5f;
    t_ssfs__(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     In this case, the segment should be found.  Make sure we get */
/*     back the right handle and segment identifier. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = spkno - 1) < 10 && 0 <= 
	    i__1 ? i__1 : s_rnge("hndles", i__1, "f_spkbsr__", (ftnlen)788)], 
	    &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + ((i__1 = segno - 1) < 16000 && 0 <= 
	    i__1 ? i__1 : s_rnge("xsegid", i__1, "f_spkbsr__", (ftnlen)789)) *
	     40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (ftnlen)40);

/*     Check the descriptor as well.  However, don't check the */
/*     segment addresses. */

    t_crdesc__("SPK", &c__1, &body, tbegs, tends, xdescr, (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_chds__("DESCR", descr, "=", xdescr, &c__4, &c_b31, ok, (ftnlen)5, (
	    ftnlen)1);
    tcase_("Look up data from a representative subset of the segments in SPK"
	    " 5.", (ftnlen)67);
    spkno = 5;
    t_slef__(spks + ((i__1 = spkno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge(
	    "spks", i__1, "f_spkbsr__", (ftnlen)811)) * 255, &hndles[(i__2 = 
	    spkno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("hndles", i__2, 
	    "f_spkbsr__", (ftnlen)811)], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    i__2 = nseg[(i__1 = spkno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("nseg", 
	    i__1, "f_spkbsr__", (ftnlen)815)];
    for (i__ = 1; i__ <= i__2; ++i__) {
	ids[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("ids", i__1,
		 "f_spkbsr__", (ftnlen)817)] = body;
	if (i__ == 10 || i__ == 101) {

/*           We want the lower bound of the re-use interval to */
/*           match the right endpoint of the segment's coverage */
/*           interval. */

	    tbegs[(i__1 = i__ - 2) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbe"
		    "gs", i__1, "f_spkbsr__", (ftnlen)825)] = (doublereal) (
		    spkno * 10000 + i__);
	    tends[(i__1 = i__ - 2) < 16000 && 0 <= i__1 ? i__1 : s_rnge("ten"
		    "ds", i__1, "f_spkbsr__", (ftnlen)826)] = tbegs[(i__3 = 
		    i__ - 2) < 16000 && 0 <= i__3 ? i__3 : s_rnge("tbegs", 
		    i__3, "f_spkbsr__", (ftnlen)826)] + 1.;
	    tbegs[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbe"
		    "gs", i__1, "f_spkbsr__", (ftnlen)828)] = (doublereal) (
		    spkno * 10000 + i__ - 1);
	    tends[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("ten"
		    "ds", i__1, "f_spkbsr__", (ftnlen)829)] = tbegs[(i__3 = 
		    i__ - 1) < 16000 && 0 <= i__3 ? i__3 : s_rnge("tbegs", 
		    i__3, "f_spkbsr__", (ftnlen)829)] + 1;
	    tbegs[(i__1 = i__) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs", 
		    i__1, "f_spkbsr__", (ftnlen)831)] = tbegs[(i__3 = i__ - 1)
		     < 16000 && 0 <= i__3 ? i__3 : s_rnge("tbegs", i__3, 
		    "f_spkbsr__", (ftnlen)831)];
	    tends[(i__1 = i__) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tends", 
		    i__1, "f_spkbsr__", (ftnlen)832)] = tends[(i__3 = i__ - 1)
		     < 16000 && 0 <= i__3 ? i__3 : s_rnge("tends", i__3, 
		    "f_spkbsr__", (ftnlen)832)];
	    tbegs[(i__1 = i__ + 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbe"
		    "gs", i__1, "f_spkbsr__", (ftnlen)834)] = tends[(i__3 = 
		    i__ - 1) < 16000 && 0 <= i__3 ? i__3 : s_rnge("tends", 
		    i__3, "f_spkbsr__", (ftnlen)834)] + 1;
	    tends[(i__1 = i__ + 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("ten"
		    "ds", i__1, "f_spkbsr__", (ftnlen)835)] = tbegs[(i__3 = 
		    i__ + 1) < 16000 && 0 <= i__3 ? i__3 : s_rnge("tbegs", 
		    i__3, "f_spkbsr__", (ftnlen)835)] + 1;
	} else if (i__ == 106) {

/*           Create a singleton segment. */

	    tbegs[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbe"
		    "gs", i__1, "f_spkbsr__", (ftnlen)841)] = (doublereal) (
		    spkno * 10000 + i__ - 1);
	    tends[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("ten"
		    "ds", i__1, "f_spkbsr__", (ftnlen)842)] = tbegs[(i__3 = 
		    i__ - 1) < 16000 && 0 <= i__3 ? i__3 : s_rnge("tbegs", 
		    i__3, "f_spkbsr__", (ftnlen)842)];
	} else if (i__ == 107) {

/*           Create an invisible segment. */

	    tbegs[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbe"
		    "gs", i__1, "f_spkbsr__", (ftnlen)848)] = (doublereal) (
		    spkno * 10000 + i__ - 1);
	    tends[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("ten"
		    "ds", i__1, "f_spkbsr__", (ftnlen)849)] = tbegs[(i__3 = 
		    i__ - 1) < 16000 && 0 <= i__3 ? i__3 : s_rnge("tbegs", 
		    i__3, "f_spkbsr__", (ftnlen)849)] - 1;
	} else if (i__ < 10 || i__ > 12 && i__ < 100 || i__ > 103) {
	    tbegs[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbe"
		    "gs", i__1, "f_spkbsr__", (ftnlen)855)] = (doublereal) (
		    spkno * 10000 + i__ - 1);
	    tends[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("ten"
		    "ds", i__1, "f_spkbsr__", (ftnlen)856)] = tbegs[(i__3 = 
		    i__ - 1) < 16000 && 0 <= i__3 ? i__3 : s_rnge("tbegs", 
		    i__3, "f_spkbsr__", (ftnlen)856)] + 1;
	}
	s_copy(xsegid + ((i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_spkbsr__", (ftnlen)860)) * 40, 
		"File: # Segno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid + ((i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_spkbsr__", (ftnlen)862)) * 40, 
		"#", spks + ((i__3 = spkno - 1) < 10 && 0 <= i__3 ? i__3 : 
		s_rnge("spks", i__3, "f_spkbsr__", (ftnlen)862)) * 255, 
		xsegid + ((i__4 = i__ - 1) < 16000 && 0 <= i__4 ? i__4 : 
		s_rnge("xsegid", i__4, "f_spkbsr__", (ftnlen)862)) * 40, (
		ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
	repmi_(xsegid + ((i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_spkbsr__", (ftnlen)863)) * 40, 
		"#", &i__, xsegid + ((i__3 = i__ - 1) < 16000 && 0 <= i__3 ? 
		i__3 : s_rnge("xsegid", i__3, "f_spkbsr__", (ftnlen)863)) * 
		40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    i__ = 1;
    while(i__ <= nseg[(i__2 = spkno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge(
	    "nseg", i__2, "f_spkbsr__", (ftnlen)871)]) {
	body = 1;
	segno = i__;
	d__1 = tbegs[(i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
		"tbegs", i__2, "f_spkbsr__", (ftnlen)876)] + .5f;
	t_ssfs__(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        In this case, the segment should be found.  Make sure we get */
/*        back the right handle and segment identifier. */

	s_copy(xsegid + ((i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_spkbsr__", (ftnlen)884)) * 40, 
		"File: # Segno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid + ((i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_spkbsr__", (ftnlen)885)) * 40, 
		"#", spks + ((i__1 = spkno - 1) < 10 && 0 <= i__1 ? i__1 : 
		s_rnge("spks", i__1, "f_spkbsr__", (ftnlen)885)) * 255, 
		xsegid + ((i__3 = segno - 1) < 16000 && 0 <= i__3 ? i__3 : 
		s_rnge("xsegid", i__3, "f_spkbsr__", (ftnlen)885)) * 40, (
		ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
	repmi_(xsegid + ((i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_spkbsr__", (ftnlen)886)) * 40, 
		"#", &segno, xsegid + ((i__1 = segno - 1) < 16000 && 0 <= 
		i__1 ? i__1 : s_rnge("xsegid", i__1, "f_spkbsr__", (ftnlen)
		886)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	chcksi_("HANDLE", &handle, "=", &hndles[(i__2 = spkno - 1) < 10 && 0 
		<= i__2 ? i__2 : s_rnge("hndles", i__2, "f_spkbsr__", (ftnlen)
		890)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	chcksc_("SEGID", segid, "=", xsegid + ((i__2 = segno - 1) < 16000 && 
		0 <= i__2 ? i__2 : s_rnge("xsegid", i__2, "f_spkbsr__", (
		ftnlen)891)) * 40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (
		ftnlen)40);

/*        Check the descriptor as well.  However, don't check the */
/*        segment addresses. */

	t_crdesc__("SPK", &segno, &body, &tbegs[(i__2 = segno - 1) < 16000 && 
		0 <= i__2 ? i__2 : s_rnge("tbegs", i__2, "f_spkbsr__", (
		ftnlen)897)], &tends[(i__1 = segno - 1) < 16000 && 0 <= i__1 ?
		 i__1 : s_rnge("tends", i__1, "f_spkbsr__", (ftnlen)897)], &
		xdescr[(i__3 = segno * 5 - 5) < 80000 && 0 <= i__3 ? i__3 : 
		s_rnge("xdescr", i__3, "f_spkbsr__", (ftnlen)897)], (ftnlen)3)
		;
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	t_chds__("DESCR", descr, "=", &xdescr[(i__2 = segno * 5 - 5) < 80000 
		&& 0 <= i__2 ? i__2 : s_rnge("xdescr", i__2, "f_spkbsr__", (
		ftnlen)901)], &c__4, &c_b31, ok, (ftnlen)5, (ftnlen)1);

/*        Skip some tests that are unlikely to reveal bugs, as well as */
/*        those which would give anomalous results due to the structure */
/*        of SPK 5. */

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
    spkno = 5;
    body = 1;
    t = tends[(i__1 = nseg[(i__2 = spkno - 1) < 10 && 0 <= i__2 ? i__2 : 
	    s_rnge("nseg", i__2, "f_spkbsr__", (ftnlen)930)] - 1) < 16000 && 
	    0 <= i__1 ? i__1 : s_rnge("tends", i__1, "f_spkbsr__", (ftnlen)
	    930)] * 2;
    t_ssfs__(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);

/*     Return on entry in RETURN mode, if the error status is set. */

    tcase_("Make sure T_SSFS returns on entry when RETURN()is .TRUE.", (
	    ftnlen)56);
    s_copy(smsg, "Return on entry", (ftnlen)25, (ftnlen)15);
    sigerr_(smsg, (ftnlen)25);
    t_ssfs__(&c__1, &c_b31, &handle, descr, segid, &found, (ftnlen)40);

/*     Depending on whether we're calling a version of T_SBSR that does */
/*     coverage checking, the error status may be reset. */

    if (return_()) {
	chckxc_(&c_true, smsg, ok, (ftnlen)25);
    } else {
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Unload the SPK files. */

    for (i__ = 1; i__ <= 10; ++i__) {
	t_suef__(&hndles[(i__2 = i__ - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge(
		"hndles", i__2, "f_spkbsr__", (ftnlen)964)]);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Make sure an error is signaled if no SPKs are loaded. */

    tcase_("Make sure an error is signaled if no SPKs are loaded.", (ftnlen)
	    53);
    t_ssfs__(&c__1, &c_b31, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_true, "SPICE(NOLOADEDFILES)", ok, (ftnlen)20);

/*     Load SPK1 and look up a state from it to create a cheap list. */
/*     Make the cheap list the second list by looking up data from */
/*     it after looking up data for body BTSIZE+1. */

    tcase_("Test removal of cheap list when adding a new body; cheap list is"
	    " 2nd.", (ftnlen)69);
    t_slef__(spks, hndles, (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Now load the SPK containing 100 bodies.  Look up data for */
/*     each one.  The last one will cause the list for body 1 to */
/*     be dumped. */

    spkno = 6;
    t_slef__(spks + ((i__2 = spkno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge(
	    "spks", i__2, "f_spkbsr__", (ftnlen)995)) * 255, &hndles[(i__1 = 
	    spkno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("hndles", i__1, 
	    "f_spkbsr__", (ftnlen)995)], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    i__1 = nseg[(i__2 = spkno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("nseg", 
	    i__2, "f_spkbsr__", (ftnlen)998)];
    for (i__ = 1; i__ <= i__1; ++i__) {
	ids[(i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("ids", i__2,
		 "f_spkbsr__", (ftnlen)1000)] = i__ + 20;
	tbegs[(i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("tbegs", 
		i__2, "f_spkbsr__", (ftnlen)1002)] = (doublereal) (spkno * 
		10000 + i__ - 1);
	tends[(i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("tends", 
		i__2, "f_spkbsr__", (ftnlen)1003)] = tbegs[(i__3 = i__ - 1) < 
		16000 && 0 <= i__3 ? i__3 : s_rnge("tbegs", i__3, "f_spkbsr__"
		, (ftnlen)1003)] + 1;
	s_copy(xsegid + ((i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_spkbsr__", (ftnlen)1005)) * 40, 
		"File: # Segno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid + ((i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_spkbsr__", (ftnlen)1007)) * 40, 
		"#", spks + ((i__3 = spkno - 1) < 10 && 0 <= i__3 ? i__3 : 
		s_rnge("spks", i__3, "f_spkbsr__", (ftnlen)1007)) * 255, 
		xsegid + ((i__4 = i__ - 1) < 16000 && 0 <= i__4 ? i__4 : 
		s_rnge("xsegid", i__4, "f_spkbsr__", (ftnlen)1007)) * 40, (
		ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
	repmi_(xsegid + ((i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_spkbsr__", (ftnlen)1008)) * 40, 
		"#", &i__, xsegid + ((i__3 = i__ - 1) < 16000 && 0 <= i__3 ? 
		i__3 : s_rnge("xsegid", i__3, "f_spkbsr__", (ftnlen)1008)) * 
		40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    i__2 = nseg[(i__1 = spkno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("nseg", 
	    i__1, "f_spkbsr__", (ftnlen)1014)];
    for (i__ = 1; i__ <= i__2; ++i__) {
	body = ids[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
		"ids", i__1, "f_spkbsr__", (ftnlen)1016)];
	segno = i__;
	d__1 = tbegs[(i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
		"tbegs", i__1, "f_spkbsr__", (ftnlen)1019)] + .5f;
	t_ssfs__(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        In this case, the segment should be found.  Make sure we get */
/*        back the right handle and segment identifier. */

	s_copy(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_spkbsr__", (ftnlen)1027)) * 40, 
		"File: # Segno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_spkbsr__", (ftnlen)1028)) * 40, 
		"#", spks + ((i__3 = spkno - 1) < 10 && 0 <= i__3 ? i__3 : 
		s_rnge("spks", i__3, "f_spkbsr__", (ftnlen)1028)) * 255, 
		xsegid + ((i__4 = segno - 1) < 16000 && 0 <= i__4 ? i__4 : 
		s_rnge("xsegid", i__4, "f_spkbsr__", (ftnlen)1028)) * 40, (
		ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
	repmi_(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_spkbsr__", (ftnlen)1029)) * 40, 
		"#", &segno, xsegid + ((i__3 = segno - 1) < 16000 && 0 <= 
		i__3 ? i__3 : s_rnge("xsegid", i__3, "f_spkbsr__", (ftnlen)
		1029)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = spkno - 1) < 10 && 0 
		<= i__1 ? i__1 : s_rnge("hndles", i__1, "f_spkbsr__", (ftnlen)
		1033)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	chcksc_("SEGID", segid, "=", xsegid + ((i__1 = segno - 1) < 16000 && 
		0 <= i__1 ? i__1 : s_rnge("xsegid", i__1, "f_spkbsr__", (
		ftnlen)1034)) * 40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (
		ftnlen)40);

/*        Check the descriptor as well.  However, don't check the */
/*        segment addresses. */

	t_crdesc__("SPK", &segno, &body, &tbegs[(i__1 = segno - 1) < 16000 && 
		0 <= i__1 ? i__1 : s_rnge("tbegs", i__1, "f_spkbsr__", (
		ftnlen)1040)], &tends[(i__3 = segno - 1) < 16000 && 0 <= i__3 
		? i__3 : s_rnge("tends", i__3, "f_spkbsr__", (ftnlen)1040)], &
		xdescr[(i__4 = segno * 5 - 5) < 80000 && 0 <= i__4 ? i__4 : 
		s_rnge("xdescr", i__4, "f_spkbsr__", (ftnlen)1040)], (ftnlen)
		3);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	t_chds__("DESCR", descr, "=", &xdescr[(i__1 = segno * 5 - 5) < 80000 
		&& 0 <= i__1 ? i__1 : s_rnge("xdescr", i__1, "f_spkbsr__", (
		ftnlen)1044)], &c__4, &c_b31, ok, (ftnlen)5, (ftnlen)1);
	if (i__ == 1) {

/*           Create a cheap list for body 1. */

	    t_slef__(spks + ((i__1 = spkno - 1) < 10 && 0 <= i__1 ? i__1 : 
		    s_rnge("spks", i__1, "f_spkbsr__", (ftnlen)1051)) * 255, &
		    hndles[(i__3 = spkno - 1) < 10 && 0 <= i__3 ? i__3 : 
		    s_rnge("hndles", i__3, "f_spkbsr__", (ftnlen)1051)], (
		    ftnlen)255);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    tbegs[0] = 1e4;
	    d__1 = tbegs[0] + .5f;
	    t_ssfs__(&c__1, &d__1, &handle, descr, segid, &found, (ftnlen)40);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	}
    }
    tcase_("Test ability to make room by deleting a body table entry with an"
	    " empty list.", (ftnlen)76);

/*     Create an example of the list in question by forcing a search */
/*     without buffering on body 1, where the highest priority file */
/*     contains too many segments to buffer.  However, we want this */
/*     list to have a high expense, so load an SPK with many segments */
/*     for this body and search it first. */

    spkno = 5;
    t_slef__(spks + ((i__2 = spkno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge(
	    "spks", i__2, "f_spkbsr__", (ftnlen)1075)) * 255, &hndles[(i__1 = 
	    spkno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("hndles", i__1, 
	    "f_spkbsr__", (ftnlen)1075)], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    body = 1;
    t = spkno * 10000 + 100 + .5;
    t_ssfs__(&c__1, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Now look up data for the first NSEG-1 bodies in SPK 6.  This */
/*     should fill up the body table. */

    spkno = 6;
    i__1 = nseg[(i__2 = spkno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("nseg", 
	    i__2, "f_spkbsr__", (ftnlen)1092)] - 1;
    for (i__ = 1; i__ <= i__1; ++i__) {
	ids[(i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("ids", i__2,
		 "f_spkbsr__", (ftnlen)1094)] = i__ + 20;
	tbegs[(i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("tbegs", 
		i__2, "f_spkbsr__", (ftnlen)1096)] = (doublereal) (spkno * 
		10000 + i__ - 1);
	tends[(i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("tends", 
		i__2, "f_spkbsr__", (ftnlen)1097)] = tbegs[(i__3 = i__ - 1) < 
		16000 && 0 <= i__3 ? i__3 : s_rnge("tbegs", i__3, "f_spkbsr__"
		, (ftnlen)1097)] + 1;
	body = ids[(i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
		"ids", i__2, "f_spkbsr__", (ftnlen)1099)];
	segno = i__;
	d__1 = tbegs[(i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
		"tbegs", i__2, "f_spkbsr__", (ftnlen)1102)] + .5f;
	t_ssfs__(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        In this case, the segment should be found.  Make sure we get */
/*        back the right handle and segment identifier. */

	s_copy(xsegid + ((i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_spkbsr__", (ftnlen)1110)) * 40, 
		"File: # Segno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid + ((i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_spkbsr__", (ftnlen)1111)) * 40, 
		"#", spks + ((i__3 = spkno - 1) < 10 && 0 <= i__3 ? i__3 : 
		s_rnge("spks", i__3, "f_spkbsr__", (ftnlen)1111)) * 255, 
		xsegid + ((i__4 = segno - 1) < 16000 && 0 <= i__4 ? i__4 : 
		s_rnge("xsegid", i__4, "f_spkbsr__", (ftnlen)1111)) * 40, (
		ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
	repmi_(xsegid + ((i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_spkbsr__", (ftnlen)1112)) * 40, 
		"#", &segno, xsegid + ((i__3 = segno - 1) < 16000 && 0 <= 
		i__3 ? i__3 : s_rnge("xsegid", i__3, "f_spkbsr__", (ftnlen)
		1112)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	chcksi_("HANDLE", &handle, "=", &hndles[(i__2 = spkno - 1) < 10 && 0 
		<= i__2 ? i__2 : s_rnge("hndles", i__2, "f_spkbsr__", (ftnlen)
		1116)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	chcksc_("SEGID", segid, "=", xsegid + ((i__2 = segno - 1) < 16000 && 
		0 <= i__2 ? i__2 : s_rnge("xsegid", i__2, "f_spkbsr__", (
		ftnlen)1117)) * 40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (
		ftnlen)40);

/*        Check the descriptor as well.  However, don't check the */
/*        segment addresses. */

	t_crdesc__("SPK", &segno, &body, &tbegs[(i__2 = segno - 1) < 16000 && 
		0 <= i__2 ? i__2 : s_rnge("tbegs", i__2, "f_spkbsr__", (
		ftnlen)1123)], &tends[(i__3 = segno - 1) < 16000 && 0 <= i__3 
		? i__3 : s_rnge("tends", i__3, "f_spkbsr__", (ftnlen)1123)], &
		xdescr[(i__4 = segno * 5 - 5) < 80000 && 0 <= i__4 ? i__4 : 
		s_rnge("xdescr", i__4, "f_spkbsr__", (ftnlen)1123)], (ftnlen)
		3);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	t_chds__("DESCR", descr, "=", &xdescr[(i__2 = segno * 5 - 5) < 80000 
		&& 0 <= i__2 ? i__2 : s_rnge("xdescr", i__2, "f_spkbsr__", (
		ftnlen)1127)], &c__4, &c_b31, ok, (ftnlen)5, (ftnlen)1);
    }

/*     Try some cases where the re-use interval matches the selected */
/*     segment's coverage interval. */

    tcase_("Search w/o buffering case, selected segment is in dumped list, c"
	    "overage interval matches re-use interval, request time is in cen"
	    "ter of re-use interval.", (ftnlen)151);

/*     Set up the case by unloading the currently loaded SPKs.  Load */
/*     SPK 1 and look up a state from it. */


/*     Unload the SPK files. */

    for (i__ = 1; i__ <= 9; ++i__) {
	t_suef__(&hndles[(i__1 = i__ - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge(
		"hndles", i__1, "f_spkbsr__", (ftnlen)1151)]);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Load SPK 1 and look up a state from this file. */

    t_slef__(spks, hndles, (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    body = 1;
    tbegs[0] = 1e4;
    tends[0] = 10001.;
    spkno = 1;
    s_copy(xsegid, "File: # Segno: #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid, "#", spks, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)255, (
	    ftnlen)40);
    repmi_(xsegid, "#", &c__1, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    d__1 = tbegs[0] + .5f;
    t_ssfs__(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Now load SPK 5.  Look up a state from segment 9, where the */
/*     request time is to the right of a segment whose right endpoint */
/*     is at the left endpoint of the re-use interval. */

    t_slef__(spks + 1020, &hndles[4], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    spkno = 5;
    body = 1;
    segno = 9;
    tbegs[(i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs", 
	    i__1, "f_spkbsr__", (ftnlen)1188)] = (doublereal) (spkno * 10000 
	    + segno + 1);
    tends[(i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tends", 
	    i__1, "f_spkbsr__", (ftnlen)1189)] = tbegs[(i__2 = segno - 1) < 
	    16000 && 0 <= i__2 ? i__2 : s_rnge("tbegs", i__2, "f_spkbsr__", (
	    ftnlen)1189)] + 1;
    t = tbegs[(i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs",
	     i__1, "f_spkbsr__", (ftnlen)1191)] + .25;
    t_ssfs__(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     In this case, segment 9 should match. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    segno = 9;
    s_copy(xsegid, "File: # Segno: #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid, "#", spks + 1020, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)
	    255, (ftnlen)40);
    repmi_(xsegid, "#", &segno, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = spkno - 1) < 10 && 0 <= 
	    i__1 ? i__1 : s_rnge("hndles", i__1, "f_spkbsr__", (ftnlen)1208)],
	     &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1,
	     (ftnlen)40);

/*     Check the descriptor as well.  However, don't check the */
/*     segment addresses. */

    t_crdesc__("SPK", &segno, &body, &tbegs[(i__1 = segno - 1) < 16000 && 0 <=
	     i__1 ? i__1 : s_rnge("tbegs", i__1, "f_spkbsr__", (ftnlen)1215)],
	     &tends[(i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
	    "tends", i__2, "f_spkbsr__", (ftnlen)1215)], &xdescr[(i__3 = 
	    segno * 5 - 5) < 80000 && 0 <= i__3 ? i__3 : s_rnge("xdescr", 
	    i__3, "f_spkbsr__", (ftnlen)1215)], (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[(i__1 = segno * 5 - 5) < 80000 && 0 
	    <= i__1 ? i__1 : s_rnge("xdescr", i__1, "f_spkbsr__", (ftnlen)
	    1219)], &c__4, &c_b31, ok, (ftnlen)5, (ftnlen)1);

/*     Create a situation where the segment list for body 1 contributed */
/*     by SPK 5 gets dumped, and where the request is satisfied by */
/*     a segment in SPK 1. */

    tcase_("Dump segment list from SPK 5; find segment for body 1 in SPK 1.", 
	    (ftnlen)63);
    t_slef__(spks, hndles, (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_slef__(spks + 1020, &hndles[4], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    body = 1;
    tbegs[0] = 1e4;
    tends[0] = 10001.;
    t = (tbegs[0] + tends[0]) * .5;
    t_ssfs__(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Check handle, segment descriptor and ID. */

    chcksi_("HANDLE", &handle, "=", hndles, &c__0, ok, (ftnlen)6, (ftnlen)1);
    t_crdesc__("SPK", &c__1, &body, tbegs, tends, xdescr, (ftnlen)3);
    t_chds__("DESCR", descr, "=", xdescr, &c__4, &c_b31, ok, (ftnlen)5, (
	    ftnlen)1);
    s_copy(xsegid, "File: # Segno: #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid, "#", spks, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)255, (
	    ftnlen)40);
    repmi_(xsegid, "#", &c__1, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1,
	     (ftnlen)40);
    tcase_("Dump segment list from SPK 5.  While searching list for segment "
	    "for body 1, make lower bound of re-use interval match lower boun"
	    "d of segment descriptor.", (ftnlen)152);

/*     Make SPK 1 higher priority than SPK 5. */

    t_slef__(spks, hndles, (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Place request time in the "hole" between segments STSIZE+1 and */
/*     STSIZE+3. */

    i__ = 101;
    tbegs[(i__1 = i__ - 2) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs", i__1,
	     "f_spkbsr__", (ftnlen)1284)] = (doublereal) (spkno * 10000 + i__)
	    ;
    tends[(i__1 = i__ - 2) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tends", i__1,
	     "f_spkbsr__", (ftnlen)1285)] = tbegs[(i__2 = i__ - 2) < 16000 && 
	    0 <= i__2 ? i__2 : s_rnge("tbegs", i__2, "f_spkbsr__", (ftnlen)
	    1285)] + 1.;
    tbegs[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs", i__1,
	     "f_spkbsr__", (ftnlen)1287)] = (doublereal) (spkno * 10000 + i__ 
	    - 1);
    tends[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tends", i__1,
	     "f_spkbsr__", (ftnlen)1288)] = tbegs[(i__2 = i__ - 1) < 16000 && 
	    0 <= i__2 ? i__2 : s_rnge("tbegs", i__2, "f_spkbsr__", (ftnlen)
	    1288)] + 1;
    tbegs[(i__1 = i__) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs", i__1, 
	    "f_spkbsr__", (ftnlen)1290)] = tbegs[(i__2 = i__ - 1) < 16000 && 
	    0 <= i__2 ? i__2 : s_rnge("tbegs", i__2, "f_spkbsr__", (ftnlen)
	    1290)];
    tends[(i__1 = i__) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tends", i__1, 
	    "f_spkbsr__", (ftnlen)1291)] = tends[(i__2 = i__ - 1) < 16000 && 
	    0 <= i__2 ? i__2 : s_rnge("tends", i__2, "f_spkbsr__", (ftnlen)
	    1291)];
    tbegs[(i__1 = i__ + 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs", i__1,
	     "f_spkbsr__", (ftnlen)1293)] = tends[(i__2 = i__ - 1) < 16000 && 
	    0 <= i__2 ? i__2 : s_rnge("tends", i__2, "f_spkbsr__", (ftnlen)
	    1293)] + 1;
    tends[(i__1 = i__ + 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tends", i__1,
	     "f_spkbsr__", (ftnlen)1294)] = tbegs[(i__2 = i__ + 1) < 16000 && 
	    0 <= i__2 ? i__2 : s_rnge("tbegs", i__2, "f_spkbsr__", (ftnlen)
	    1294)] + 1;
    t = tbegs[(i__1 = i__ - 2) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs", 
	    i__1, "f_spkbsr__", (ftnlen)1296)] + .5;
    t_ssfs__(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     In this case, segment STSIZE should match. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    segno = 100;
    s_copy(xsegid, "File: # Segno: #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid, "#", spks + 1020, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)
	    255, (ftnlen)40);
    repmi_(xsegid, "#", &segno, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = spkno - 1) < 10 && 0 <= 
	    i__1 ? i__1 : s_rnge("hndles", i__1, "f_spkbsr__", (ftnlen)1314)],
	     &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1,
	     (ftnlen)40);

/*     Check the descriptor as well.  However, don't check the */
/*     segment addresses. */

    i__ = segno + 1;
    tbegs[(i__1 = i__ - 2) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs", i__1,
	     "f_spkbsr__", (ftnlen)1322)] = (doublereal) (spkno * 10000 + i__)
	    ;
    tends[(i__1 = i__ - 2) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tends", i__1,
	     "f_spkbsr__", (ftnlen)1323)] = tbegs[(i__2 = i__ - 2) < 16000 && 
	    0 <= i__2 ? i__2 : s_rnge("tbegs", i__2, "f_spkbsr__", (ftnlen)
	    1323)] + 1.;
    t_crdesc__("SPK", &segno, &body, &tbegs[(i__1 = segno - 1) < 16000 && 0 <=
	     i__1 ? i__1 : s_rnge("tbegs", i__1, "f_spkbsr__", (ftnlen)1325)],
	     &tends[(i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
	    "tends", i__2, "f_spkbsr__", (ftnlen)1325)], &xdescr[(i__3 = 
	    segno * 5 - 5) < 80000 && 0 <= i__3 ? i__3 : s_rnge("xdescr", 
	    i__3, "f_spkbsr__", (ftnlen)1325)], (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[(i__1 = segno * 5 - 5) < 80000 && 0 
	    <= i__1 ? i__1 : s_rnge("xdescr", i__1, "f_spkbsr__", (ftnlen)
	    1329)], &c__4, &c_b31, ok, (ftnlen)5, (ftnlen)1);

/*     Check correct handling of re-use intervals.  Create a new */
/*     SPK file that contains coverage that exemplifies the various */
/*     masking possibilities that may occur. */

    tcase_("Check re-use for a 1-body segment list.", (ftnlen)39);
    spkno = 7;

/*     Segment 1: */

    body = 1;
    ids[0] = body;
    tbegs[0] = (doublereal) (spkno * 10000);
    tends[0] = tbegs[0] + 1.;

/*     Segments 2-3: */

    body = 2;
    ids[1] = body;
    ids[2] = body;
    tbegs[2] = (doublereal) (spkno * 10000);
    tends[2] = tbegs[2] + 1.;
    tbegs[1] = tends[2] + 1.;
    tends[1] = tbegs[1] + 1.;

/*     Segments 4-6: */

    body = 3;
    ids[3] = body;
    ids[4] = body;
    ids[5] = body;
    tbegs[5] = (doublereal) (spkno * 10000);
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
    tbegs[8] = (doublereal) (spkno * 10000);
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
    tbegs[11] = (doublereal) (spkno * 10000);
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

    tbegs[12] = (doublereal) (spkno * 10000);
    tends[12] = tbegs[12];

/*     Invisible segment: */

    tbegs[13] = tends[12] + 3.;
    tends[13] = tbegs[13] - 1.;

/*     Three more segments for body 4: */

    ids[14] = 4;
    ids[15] = 4;
    ids[16] = 4;
    tbegs[14] = spkno * 10000 + 10.;
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
    tbegs[19] = spkno * 10000 + 10.;
    tends[19] = tbegs[19] + 3.;
    tbegs[18] = tbegs[19] - 2.;
    tends[18] = tbegs[18] + 3.;
    tbegs[17] = tbegs[18] - 2.;
    tends[17] = tends[19] + 1.;

/*     Create a segment for body 6 with the following topology: */


/*              +++++++           segment 21 */
/*                    +++++++             22 */
/*        +++++++                         23 */


    body = 6;
    ids[20] = body;
    ids[21] = body;
    ids[22] = body;
    tbegs[20] = spkno * 10000 + 10.;
    tends[20] = tbegs[20] + 3.;
    tbegs[21] = tends[20];
    tends[21] = tbegs[20] + 3.;
    tbegs[22] = tbegs[20] - 3.;
    tends[22] = tbegs[20];

/*     Create the eighth SPK, which is just a copy of the 7th, except */
/*     for descriptors and segment IDs. */

    spkno = 8;
    i__2 = nseg[(i__1 = spkno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("nseg", 
	    i__1, "f_spkbsr__", (ftnlen)1504)];
    for (segno = 1; segno <= i__2; ++segno) {
	t_crdesc__("SPK", &segno, &ids[(i__1 = segno - 1) < 16000 && 0 <= 
		i__1 ? i__1 : s_rnge("ids", i__1, "f_spkbsr__", (ftnlen)1506)]
		, &tbegs[(i__3 = segno - 1) < 16000 && 0 <= i__3 ? i__3 : 
		s_rnge("tbegs", i__3, "f_spkbsr__", (ftnlen)1506)], &tends[(
		i__4 = segno - 1) < 16000 && 0 <= i__4 ? i__4 : s_rnge("tends"
		, i__4, "f_spkbsr__", (ftnlen)1506)], &xdescr[(i__5 = segno * 
		5 - 5) < 80000 && 0 <= i__5 ? i__5 : s_rnge("xdescr", i__5, 
		"f_spkbsr__", (ftnlen)1506)], (ftnlen)3);
	s_copy(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_spkbsr__", (ftnlen)1509)) * 40, 
		"File: # Segno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_spkbsr__", (ftnlen)1510)) * 40, 
		"#", spks + ((i__3 = spkno - 1) < 10 && 0 <= i__3 ? i__3 : 
		s_rnge("spks", i__3, "f_spkbsr__", (ftnlen)1510)) * 255, 
		xsegid + ((i__4 = segno - 1) < 16000 && 0 <= i__4 ? i__4 : 
		s_rnge("xsegid", i__4, "f_spkbsr__", (ftnlen)1510)) * 40, (
		ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
	repmi_(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_spkbsr__", (ftnlen)1511)) * 40, 
		"#", &segno, xsegid + ((i__3 = segno - 1) < 16000 && 0 <= 
		i__3 ? i__3 : s_rnge("xsegid", i__3, "f_spkbsr__", (ftnlen)
		1511)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    t_crdaf__("SPK", spks + ((i__2 = spkno - 1) < 10 && 0 <= i__2 ? i__2 : 
	    s_rnge("spks", i__2, "f_spkbsr__", (ftnlen)1516)) * 255, &nseg[(
	    i__1 = spkno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("nseg", i__1, 
	    "f_spkbsr__", (ftnlen)1516)], ids, tbegs, tends, xsegid, (ftnlen)
	    3, (ftnlen)255, (ftnlen)40);

/*     Create the segment descriptors and segment identifiers for */
/*     this SPK file. */

    spkno = 7;
    i__1 = nseg[(i__2 = spkno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("nseg", 
	    i__2, "f_spkbsr__", (ftnlen)1527)];
    for (segno = 1; segno <= i__1; ++segno) {
	t_crdesc__("SPK", &segno, &ids[(i__2 = segno - 1) < 16000 && 0 <= 
		i__2 ? i__2 : s_rnge("ids", i__2, "f_spkbsr__", (ftnlen)1529)]
		, &tbegs[(i__3 = segno - 1) < 16000 && 0 <= i__3 ? i__3 : 
		s_rnge("tbegs", i__3, "f_spkbsr__", (ftnlen)1529)], &tends[(
		i__4 = segno - 1) < 16000 && 0 <= i__4 ? i__4 : s_rnge("tends"
		, i__4, "f_spkbsr__", (ftnlen)1529)], &xdescr[(i__5 = segno * 
		5 - 5) < 80000 && 0 <= i__5 ? i__5 : s_rnge("xdescr", i__5, 
		"f_spkbsr__", (ftnlen)1529)], (ftnlen)3);
	s_copy(xsegid + ((i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_spkbsr__", (ftnlen)1532)) * 40, 
		"File: # Segno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid + ((i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_spkbsr__", (ftnlen)1533)) * 40, 
		"#", spks + ((i__3 = spkno - 1) < 10 && 0 <= i__3 ? i__3 : 
		s_rnge("spks", i__3, "f_spkbsr__", (ftnlen)1533)) * 255, 
		xsegid + ((i__4 = segno - 1) < 16000 && 0 <= i__4 ? i__4 : 
		s_rnge("xsegid", i__4, "f_spkbsr__", (ftnlen)1533)) * 40, (
		ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
	repmi_(xsegid + ((i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_spkbsr__", (ftnlen)1534)) * 40, 
		"#", &segno, xsegid + ((i__3 = segno - 1) < 16000 && 0 <= 
		i__3 ? i__3 : s_rnge("xsegid", i__3, "f_spkbsr__", (ftnlen)
		1534)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Unload the other SPK files.  Create and load the SPK file. */


/*     Unload the SPK files.  Again. */

    i__1 = spkno - 1;
    for (i__ = 1; i__ <= i__1; ++i__) {
	t_suef__(&hndles[(i__2 = i__ - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge(
		"hndles", i__2, "f_spkbsr__", (ftnlen)1546)]);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    t_crdaf__("SPK", spks + ((i__1 = spkno - 1) < 10 && 0 <= i__1 ? i__1 : 
	    s_rnge("spks", i__1, "f_spkbsr__", (ftnlen)1550)) * 255, &nseg[(
	    i__2 = spkno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("nseg", i__2, 
	    "f_spkbsr__", (ftnlen)1550)], ids, tbegs, tends, xsegid, (ftnlen)
	    3, (ftnlen)255, (ftnlen)40);
/*      CALL BYEBYE ( 'SUCCESS' ) */
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_slef__(spks + ((i__1 = spkno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge(
	    "spks", i__1, "f_spkbsr__", (ftnlen)1559)) * 255, &hndles[(i__2 = 
	    spkno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("hndles", i__2, 
	    "f_spkbsr__", (ftnlen)1559)], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Time for tests. */


/*     Make sure we can re-use data from the first segment for body 1. */

    spkno = 7;
    body = ids[0];
    t = (tbegs[0] + tends[0]) * .5;
    for (i__ = 1; i__ <= 3; ++i__) {
	t_ssfs__(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*        Check handle, segment descriptor and ID. */

	chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = spkno - 1) < 10 && 0 
		<= i__1 ? i__1 : s_rnge("hndles", i__1, "f_spkbsr__", (ftnlen)
		1583)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	t_chds__("DESCR", descr, "=", xdescr, &c__4, &c_b31, ok, (ftnlen)5, (
		ftnlen)1);
	chcksc_("SEGID", segid, "=", xsegid, ok, (ftnlen)5, (ftnlen)40, (
		ftnlen)1, (ftnlen)40);
    }
    t = tbegs[0] - 1.;
    t_ssfs__(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    t = tends[0] + 1.;
    t_ssfs__(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    t = tbegs[0];
    t_ssfs__(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    t = tends[0];
    t_ssfs__(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
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
	t_ssfs__(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*        Check handle, segment descriptor and ID. */

	chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = spkno - 1) < 10 && 0 
		<= i__1 ? i__1 : s_rnge("hndles", i__1, "f_spkbsr__", (ftnlen)
		1652)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	t_chds__("DESCR", descr, "=", &xdescr[5], &c__4, &c_b31, ok, (ftnlen)
		5, (ftnlen)1);
	chcksc_("SEGID", segid, "=", xsegid + 40, ok, (ftnlen)5, (ftnlen)40, (
		ftnlen)1, (ftnlen)40);
    }
    t = (tbegs[2] + tends[2]) * .5;
    for (i__ = 1; i__ <= 3; ++i__) {
	t_ssfs__(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*        Check handle, segment descriptor and ID. */

	chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = spkno - 1) < 10 && 0 
		<= i__1 ? i__1 : s_rnge("hndles", i__1, "f_spkbsr__", (ftnlen)
		1674)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	t_chds__("DESCR", descr, "=", &xdescr[10], &c__4, &c_b31, ok, (ftnlen)
		5, (ftnlen)1);
	chcksc_("SEGID", segid, "=", xsegid + 80, ok, (ftnlen)5, (ftnlen)40, (
		ftnlen)1, (ftnlen)40);
    }

/*     Hit the endpoints of the left interval. */

    t = tbegs[2];
    t_ssfs__(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Check handle, segment descriptor and ID. */

    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = spkno - 1) < 10 && 0 <= 
	    i__1 ? i__1 : s_rnge("hndles", i__1, "f_spkbsr__", (ftnlen)1696)],
	     &c__0, ok, (ftnlen)6, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[10], &c__4, &c_b31, ok, (ftnlen)5, (
	    ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + 80, ok, (ftnlen)5, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);
    t = tends[2];
    t_ssfs__(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Check handle, segment descriptor and ID. */

    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = spkno - 1) < 10 && 0 <= 
	    i__1 ? i__1 : s_rnge("hndles", i__1, "f_spkbsr__", (ftnlen)1714)],
	     &c__0, ok, (ftnlen)6, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[10], &c__4, &c_b31, ok, (ftnlen)5, (
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
	t_ssfs__(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*        Check handle, segment descriptor and ID. */

	chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = spkno - 1) < 10 && 0 
		<= i__1 ? i__1 : s_rnge("hndles", i__1, "f_spkbsr__", (ftnlen)
		1754)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	t_chds__("DESCR", descr, "=", &xdescr[20], &c__4, &c_b31, ok, (ftnlen)
		5, (ftnlen)1);
	chcksc_("SEGID", segid, "=", xsegid + 160, ok, (ftnlen)5, (ftnlen)40, 
		(ftnlen)1, (ftnlen)40);
    }
    body = ids[3];
    t = tbegs[5] + .25f;
    for (i__ = 1; i__ <= 3; ++i__) {
	t_ssfs__(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*        Check handle, segment descriptor and ID. */

	chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = spkno - 1) < 10 && 0 
		<= i__1 ? i__1 : s_rnge("hndles", i__1, "f_spkbsr__", (ftnlen)
		1777)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	t_chds__("DESCR", descr, "=", &xdescr[25], &c__4, &c_b31, ok, (ftnlen)
		5, (ftnlen)1);
	chcksc_("SEGID", segid, "=", xsegid + 200, ok, (ftnlen)5, (ftnlen)40, 
		(ftnlen)1, (ftnlen)40);
    }
    t = tbegs[4] + .25f;
    t_ssfs__(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    t = tbegs[5] - .25f;
    t_ssfs__(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
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
    t_ssfs__(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = spkno - 1) < 10 && 0 <= 
	    i__1 ? i__1 : s_rnge("hndles", i__1, "f_spkbsr__", (ftnlen)1837)],
	     &c__0, ok, (ftnlen)6, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[30], &c__4, &c_b31, ok, (ftnlen)5, (
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
	t_ssfs__(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*        Check handle, segment descriptor and ID. */

	chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = spkno - 1) < 10 && 0 
		<= i__1 ? i__1 : s_rnge("hndles", i__1, "f_spkbsr__", (ftnlen)
		1875)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	t_chds__("DESCR", descr, "=", &xdescr[45], &c__4, &c_b31, ok, (ftnlen)
		5, (ftnlen)1);
	chcksc_("SEGID", segid, "=", xsegid + 360, ok, (ftnlen)5, (ftnlen)40, 
		(ftnlen)1, (ftnlen)40);
    }
    t = tends[9] + 1.;
    t_ssfs__(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    t = tbegs[9] + .25f;
    for (i__ = 1; i__ <= 3; ++i__) {
	t_ssfs__(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*        Check handle, segment descriptor and ID. */

	chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = spkno - 1) < 10 && 0 
		<= i__1 ? i__1 : s_rnge("hndles", i__1, "f_spkbsr__", (ftnlen)
		1906)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	t_chds__("DESCR", descr, "=", &xdescr[45], &c__4, &c_b31, ok, (ftnlen)
		5, (ftnlen)1);
	chcksc_("SEGID", segid, "=", xsegid + 360, ok, (ftnlen)5, (ftnlen)40, 
		(ftnlen)1, (ftnlen)40);
    }
    t = tbegs[10] - .25f;
    t_ssfs__(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = spkno - 1) < 10 && 0 <= 
	    i__1 ? i__1 : s_rnge("hndles", i__1, "f_spkbsr__", (ftnlen)1924)],
	     &c__0, ok, (ftnlen)6, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[45], &c__4, &c_b31, ok, (ftnlen)5, (
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
    t_ssfs__(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Check handle, segment descriptor and ID. */

    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = spkno - 1) < 10 && 0 <= 
	    i__1 ? i__1 : s_rnge("hndles", i__1, "f_spkbsr__", (ftnlen)1960)],
	     &c__0, ok, (ftnlen)6, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[70], &c__4, &c_b31, ok, (ftnlen)5, (
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
    tbegs[20] = spkno * 10000 + 10.;
    tends[20] = tbegs[20] + 3.;
    tbegs[21] = tends[20];
    tends[21] = tbegs[20] + 3.;
    tbegs[22] = tbegs[20] - 3.;
    tends[22] = tbegs[20];
    body = ids[20];
    t = tbegs[20] + .5;
    t_ssfs__(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Check handle, segment descriptor and ID. */

    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = spkno - 1) < 10 && 0 <= 
	    i__1 ? i__1 : s_rnge("hndles", i__1, "f_spkbsr__", (ftnlen)2012)],
	     &c__0, ok, (ftnlen)6, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[100], &c__4, &c_b31, ok, (ftnlen)5, 
	    (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + 800, ok, (ftnlen)5, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);

/*     Check out behavior for coverage consisting singleton and */
/*     invisible segments. */


    tcase_("Look up data from a singleton segment.", (ftnlen)38);
    t = tbegs[12];
    body = ids[12];
    t_ssfs__(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = spkno - 1) < 10 && 0 <= 
	    i__1 ? i__1 : s_rnge("hndles", i__1, "f_spkbsr__", (ftnlen)2040)],
	     &c__0, ok, (ftnlen)6, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[60], &c__4, &c_b31, ok, (ftnlen)5, (
	    ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + 480, ok, (ftnlen)5, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);

/*     Exercise the logic for handling singleton and invisible */
/*     segments during a NEW BODY search. */

    tcase_("Look up data from a singleton segment, this time in a NEW SEGMEN"
	    "TS search.", (ftnlen)74);
    spkno = 8;
    t_slef__(spks + ((i__1 = spkno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge(
	    "spks", i__1, "f_spkbsr__", (ftnlen)2057)) * 255, &hndles[(i__2 = 
	    spkno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("hndles", i__2, 
	    "f_spkbsr__", (ftnlen)2057)], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    segno = 13;
    t_crdesc__("SPK", &segno, &ids[(i__1 = segno - 1) < 16000 && 0 <= i__1 ? 
	    i__1 : s_rnge("ids", i__1, "f_spkbsr__", (ftnlen)2063)], &tbegs[(
	    i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge("tbegs", 
	    i__2, "f_spkbsr__", (ftnlen)2063)], &tends[(i__3 = segno - 1) < 
	    16000 && 0 <= i__3 ? i__3 : s_rnge("tends", i__3, "f_spkbsr__", (
	    ftnlen)2063)], &xdescr[(i__4 = segno * 5 - 5) < 80000 && 0 <= 
	    i__4 ? i__4 : s_rnge("xdescr", i__4, "f_spkbsr__", (ftnlen)2063)],
	     (ftnlen)3);
    s_copy(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_spkbsr__", (ftnlen)2066)) * 40, "File: # Segn"
	    "o: #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_spkbsr__", (ftnlen)2067)) * 40, "#", spks + ((
	    i__2 = spkno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("spks", i__2, 
	    "f_spkbsr__", (ftnlen)2067)) * 255, xsegid + ((i__3 = segno - 1) <
	     16000 && 0 <= i__3 ? i__3 : s_rnge("xsegid", i__3, "f_spkbsr__", 
	    (ftnlen)2067)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)
	    40);
    repmi_(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_spkbsr__", (ftnlen)2068)) * 40, "#", &segno, 
	    xsegid + ((i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_spkbsr__", (ftnlen)2068)) * 40, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t = tbegs[12];
    body = ids[12];
    t_ssfs__(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = spkno - 1) < 10 && 0 <= 
	    i__1 ? i__1 : s_rnge("hndles", i__1, "f_spkbsr__", (ftnlen)2081)],
	     &c__0, ok, (ftnlen)6, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[60], &c__4, &c_b31, ok, (ftnlen)5, (
	    ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + 480, ok, (ftnlen)5, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);
    tcase_("Prepare for search w/o buffering tests: create an SPK with STSIZ"
	    "E segments for bodies 1-NBODY.", (ftnlen)94);

/*     Create an SPK file with STSIZE segments for bodies 1-NBODY. */

    spkno = 9;
    for (body = 1; body <= 4; ++body) {
	for (i__ = 1; i__ <= 100; ++i__) {
	    j = (body - 1) * 100 + i__;
	    ids[(i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("ids", 
		    i__1, "f_spkbsr__", (ftnlen)2106)] = body;
	    tbegs[(i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs",
		     i__1, "f_spkbsr__", (ftnlen)2108)] = (doublereal) (spkno 
		    * 10000 + i__ - 1);
	    tends[(i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tends",
		     i__1, "f_spkbsr__", (ftnlen)2109)] = tbegs[(i__2 = j - 1)
		     < 16000 && 0 <= i__2 ? i__2 : s_rnge("tbegs", i__2, 
		    "f_spkbsr__", (ftnlen)2109)] + 1;
	    s_copy(xsegid + ((i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : 
		    s_rnge("xsegid", i__1, "f_spkbsr__", (ftnlen)2111)) * 40, 
		    "File: # Segno: #  Body:  #", (ftnlen)40, (ftnlen)26);
	    repmc_(xsegid + ((i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : 
		    s_rnge("xsegid", i__1, "f_spkbsr__", (ftnlen)2113)) * 40, 
		    "#", spks + ((i__2 = spkno - 1) < 10 && 0 <= i__2 ? i__2 :
		     s_rnge("spks", i__2, "f_spkbsr__", (ftnlen)2113)) * 255, 
		    xsegid + ((i__3 = j - 1) < 16000 && 0 <= i__3 ? i__3 : 
		    s_rnge("xsegid", i__3, "f_spkbsr__", (ftnlen)2113)) * 40, 
		    (ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
	    repmi_(xsegid + ((i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : 
		    s_rnge("xsegid", i__1, "f_spkbsr__", (ftnlen)2114)) * 40, 
		    "#", &j, xsegid + ((i__2 = j - 1) < 16000 && 0 <= i__2 ? 
		    i__2 : s_rnge("xsegid", i__2, "f_spkbsr__", (ftnlen)2114))
		     * 40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	    repmi_(xsegid + ((i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : 
		    s_rnge("xsegid", i__1, "f_spkbsr__", (ftnlen)2115)) * 40, 
		    "#", &body, xsegid + ((i__2 = j - 1) < 16000 && 0 <= i__2 
		    ? i__2 : s_rnge("xsegid", i__2, "f_spkbsr__", (ftnlen)
		    2115)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	}
    }
    t_crdaf__("SPK", spks + ((i__1 = spkno - 1) < 10 && 0 <= i__1 ? i__1 : 
	    s_rnge("spks", i__1, "f_spkbsr__", (ftnlen)2122)) * 255, &nseg[(
	    i__2 = spkno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("nseg", i__2, 
	    "f_spkbsr__", (ftnlen)2122)], ids, tbegs, tends, xsegid, (ftnlen)
	    3, (ftnlen)255, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    tcase_("Prepare for search w/o buffering tests: create an SPK with STSIZ"
	    "E segments for bodies 1-NBODY.", (ftnlen)94);

/*     Create an SPK file with STSIZE segments for bodies 1-NBODY. */

    spkno = 10;
    for (body = 1; body <= 4; ++body) {
	for (i__ = 1; i__ <= 97; ++i__) {
	    j = (body - 1) * 97 + i__;
	    ids[(i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("ids", 
		    i__1, "f_spkbsr__", (ftnlen)2144)] = body;
	    tbegs[(i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs",
		     i__1, "f_spkbsr__", (ftnlen)2146)] = (doublereal) (spkno 
		    * 10000 + i__ - 1);
	    tends[(i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tends",
		     i__1, "f_spkbsr__", (ftnlen)2147)] = tbegs[(i__2 = j - 1)
		     < 16000 && 0 <= i__2 ? i__2 : s_rnge("tbegs", i__2, 
		    "f_spkbsr__", (ftnlen)2147)] + 1;
	    s_copy(xsegid + ((i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : 
		    s_rnge("xsegid", i__1, "f_spkbsr__", (ftnlen)2149)) * 40, 
		    "File: # Segno: #  Body:  #", (ftnlen)40, (ftnlen)26);
	    repmc_(xsegid + ((i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : 
		    s_rnge("xsegid", i__1, "f_spkbsr__", (ftnlen)2151)) * 40, 
		    "#", spks + ((i__2 = spkno - 1) < 10 && 0 <= i__2 ? i__2 :
		     s_rnge("spks", i__2, "f_spkbsr__", (ftnlen)2151)) * 255, 
		    xsegid + ((i__3 = j - 1) < 16000 && 0 <= i__3 ? i__3 : 
		    s_rnge("xsegid", i__3, "f_spkbsr__", (ftnlen)2151)) * 40, 
		    (ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
	    repmi_(xsegid + ((i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : 
		    s_rnge("xsegid", i__1, "f_spkbsr__", (ftnlen)2152)) * 40, 
		    "#", &j, xsegid + ((i__2 = j - 1) < 16000 && 0 <= i__2 ? 
		    i__2 : s_rnge("xsegid", i__2, "f_spkbsr__", (ftnlen)2152))
		     * 40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	    repmi_(xsegid + ((i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : 
		    s_rnge("xsegid", i__1, "f_spkbsr__", (ftnlen)2153)) * 40, 
		    "#", &body, xsegid + ((i__2 = j - 1) < 16000 && 0 <= i__2 
		    ? i__2 : s_rnge("xsegid", i__2, "f_spkbsr__", (ftnlen)
		    2153)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	}
    }
    t_crdaf__("SPK", spks + ((i__1 = spkno - 1) < 10 && 0 <= i__1 ? i__1 : 
	    s_rnge("spks", i__1, "f_spkbsr__", (ftnlen)2160)) * 255, &nseg[(
	    i__2 = spkno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("nseg", i__2, 
	    "f_spkbsr__", (ftnlen)2160)], ids, tbegs, tends, xsegid, (ftnlen)
	    3, (ftnlen)255, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    tcase_("Search w/o buffering, ET < segment begin, re-use interval right "
	    "endpoint < segment begin.", (ftnlen)89);

/*     Unload the SPK files.  Again. */

    for (i__ = 1; i__ <= 10; ++i__) {
	t_suef__(&hndles[(i__1 = i__ - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge(
		"hndles", i__1, "f_spkbsr__", (ftnlen)2177)]);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Load SPKs 7 and 9. */

    t_slef__(spks + 1530, &hndles[6], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_slef__(spks + 2040, &hndles[8], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     The request time should precede the coverage of segment 3 in */
/*     SPK 7. */

    body = 2;
    t = 69999.;
    t_ssfs__(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    tcase_("Search w/o buffering, ET within segment, re-use interval, left e"
	    "ndpoint > segment begin.", (ftnlen)88);

/*     The request time should precede the coverage of segment 3 in */
/*     SPK 7. */

    body = 3;
    segno = 5;
    spkno = 7;
    tbegs[5] = (doublereal) (spkno * 10000);
    tends[5] = tbegs[5] + 3.;
    tbegs[4] = tends[5] - 1.;
    tends[4] = tbegs[4] + 3.;
    t = spkno * 10000 + 4.;
    t_ssfs__(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    s_copy(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_spkbsr__", (ftnlen)2233)) * 40, "File: # Segn"
	    "o: #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_spkbsr__", (ftnlen)2234)) * 40, "#", spks + ((
	    i__2 = spkno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("spks", i__2, 
	    "f_spkbsr__", (ftnlen)2234)) * 255, xsegid + ((i__3 = segno - 1) <
	     16000 && 0 <= i__3 ? i__3 : s_rnge("xsegid", i__3, "f_spkbsr__", 
	    (ftnlen)2234)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)
	    40);
    repmi_(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_spkbsr__", (ftnlen)2235)) * 40, "#", &segno, 
	    xsegid + ((i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_spkbsr__", (ftnlen)2235)) * 40, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + ((i__1 = segno - 1) < 16000 && 0 <= 
	    i__1 ? i__1 : s_rnge("xsegid", i__1, "f_spkbsr__", (ftnlen)2238)) 
	    * 40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (ftnlen)40);

/*     Check the descriptor as well.  However, don't check the */
/*     segment addresses. */

    t_crdesc__("SPK", &segno, &body, &tbegs[(i__1 = segno - 1) < 16000 && 0 <=
	     i__1 ? i__1 : s_rnge("tbegs", i__1, "f_spkbsr__", (ftnlen)2244)],
	     &tends[(i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
	    "tends", i__2, "f_spkbsr__", (ftnlen)2244)], &xdescr[(i__3 = 
	    segno * 5 - 5) < 80000 && 0 <= i__3 ? i__3 : s_rnge("xdescr", 
	    i__3, "f_spkbsr__", (ftnlen)2244)], (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[(i__1 = segno * 5 - 5) < 80000 && 0 
	    <= i__1 ? i__1 : s_rnge("xdescr", i__1, "f_spkbsr__", (ftnlen)
	    2249)], &c__4, &c_b31, ok, (ftnlen)5, (ftnlen)1);
    tcase_("Search w/o buffering, ET < segment begin, re-use interval right "
	    "endpoint = segment begin.", (ftnlen)89);
    body = 4;
    segno = 7;
    spkno = 7;
    ids[6] = body;
    ids[7] = body;
    ids[8] = body;
    tbegs[8] = (doublereal) (spkno * 10000);
    tends[8] = tbegs[8] + 3.;
    tbegs[7] = tbegs[8];
    tends[7] = tends[8];
    tbegs[6] = tbegs[8] - 2.;
    tends[6] = tbegs[8] + 3.;
    t = tbegs[7] - 1.;
    t_ssfs__(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = spkno - 1) < 10 && 0 <= 
	    i__1 ? i__1 : s_rnge("hndles", i__1, "f_spkbsr__", (ftnlen)2283)],
	     &c__0, ok, (ftnlen)6, (ftnlen)1);
    s_copy(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_spkbsr__", (ftnlen)2285)) * 40, "File: # Segn"
	    "o: #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_spkbsr__", (ftnlen)2286)) * 40, "#", spks + ((
	    i__2 = spkno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("spks", i__2, 
	    "f_spkbsr__", (ftnlen)2286)) * 255, xsegid + ((i__3 = segno - 1) <
	     16000 && 0 <= i__3 ? i__3 : s_rnge("xsegid", i__3, "f_spkbsr__", 
	    (ftnlen)2286)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)
	    40);
    repmi_(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_spkbsr__", (ftnlen)2287)) * 40, "#", &segno, 
	    xsegid + ((i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_spkbsr__", (ftnlen)2287)) * 40, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + ((i__1 = segno - 1) < 16000 && 0 <= 
	    i__1 ? i__1 : s_rnge("xsegid", i__1, "f_spkbsr__", (ftnlen)2290)) 
	    * 40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (ftnlen)40);

/*     Check the descriptor as well.  However, don't check the */
/*     segment addresses. */

    t_crdesc__("SPK", &segno, &body, &tbegs[(i__1 = segno - 1) < 16000 && 0 <=
	     i__1 ? i__1 : s_rnge("tbegs", i__1, "f_spkbsr__", (ftnlen)2296)],
	     &tends[(i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
	    "tends", i__2, "f_spkbsr__", (ftnlen)2296)], &xdescr[(i__3 = 
	    segno * 5 - 5) < 80000 && 0 <= i__3 ? i__3 : s_rnge("xdescr", 
	    i__3, "f_spkbsr__", (ftnlen)2296)], (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[(i__1 = segno * 5 - 5) < 80000 && 0 
	    <= i__1 ? i__1 : s_rnge("xdescr", i__1, "f_spkbsr__", (ftnlen)
	    2301)], &c__4, &c_b31, ok, (ftnlen)5, (ftnlen)1);

/*     Some cases where a partial list must be dumped: */

    tcase_("Dump segment list from SPK 10.  While searching list for segment"
	    " for body 4, make upper bound of re-use interval < upper bound o"
	    "f segment descriptor.", (ftnlen)149);

/*     Unload SPK 9; load SPK 10. */

    t_suef__(&hndles[8]);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_slef__(spks + 2295, &hndles[9], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Our request time should be in the interior of segment 15 in */
/*     SPK 7. */

    spkno = 7;
    segno = 15;
    ids[14] = 4;
    ids[15] = 4;
    ids[16] = 4;
    tbegs[14] = spkno * 10000 + 10.;
    tends[14] = tbegs[14] + 3.;
    tbegs[15] = tbegs[14] + 1.;
    tends[15] = tends[14] - 1.;
    tbegs[16] = tbegs[15];
    tends[16] = tbegs[16];
    t = tbegs[14] + .5;
    t_ssfs__(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = spkno - 1) < 10 && 0 <= 
	    i__1 ? i__1 : s_rnge("hndles", i__1, "f_spkbsr__", (ftnlen)2349)],
	     &c__0, ok, (ftnlen)6, (ftnlen)1);
    s_copy(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_spkbsr__", (ftnlen)2351)) * 40, "File: # Segn"
	    "o: #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_spkbsr__", (ftnlen)2352)) * 40, "#", spks + ((
	    i__2 = spkno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("spks", i__2, 
	    "f_spkbsr__", (ftnlen)2352)) * 255, xsegid + ((i__3 = segno - 1) <
	     16000 && 0 <= i__3 ? i__3 : s_rnge("xsegid", i__3, "f_spkbsr__", 
	    (ftnlen)2352)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)
	    40);
    repmi_(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_spkbsr__", (ftnlen)2353)) * 40, "#", &segno, 
	    xsegid + ((i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_spkbsr__", (ftnlen)2353)) * 40, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + ((i__1 = segno - 1) < 16000 && 0 <= 
	    i__1 ? i__1 : s_rnge("xsegid", i__1, "f_spkbsr__", (ftnlen)2356)) 
	    * 40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (ftnlen)40);

/*     Check the descriptor as well.  However, don't check the */
/*     segment addresses. */

    t_crdesc__("SPK", &segno, &body, &tbegs[(i__1 = segno - 1) < 16000 && 0 <=
	     i__1 ? i__1 : s_rnge("tbegs", i__1, "f_spkbsr__", (ftnlen)2362)],
	     &tends[(i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
	    "tends", i__2, "f_spkbsr__", (ftnlen)2362)], &xdescr[(i__3 = 
	    segno * 5 - 5) < 80000 && 0 <= i__3 ? i__3 : s_rnge("xdescr", 
	    i__3, "f_spkbsr__", (ftnlen)2362)], (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[(i__1 = segno * 5 - 5) < 80000 && 0 
	    <= i__1 ? i__1 : s_rnge("xdescr", i__1, "f_spkbsr__", (ftnlen)
	    2367)], &c__4, &c_b31, ok, (ftnlen)5, (ftnlen)1);
    tcase_("Dump segment list from SPK 10.  While searching list for segment"
	    " for body 4, make lower bound of re-use interval = upper bound o"
	    "f segment descriptor.", (ftnlen)149);
    spkno = 7;
    body = 4;
    tbegs[8] = (doublereal) (spkno * 10000);
    tends[8] = tbegs[8] + 3.;
    t = tends[8] + .5;
    t_ssfs__(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    tcase_("Dump segment list from SPK 10.  While searching list for segment"
	    " for body 5, make lower bound of re-use interval > lower bound o"
	    "f segment descriptor.", (ftnlen)149);
    spkno = 7;
    body = 5;
    ids[17] = body;
    ids[18] = body;
    ids[19] = body;
    tbegs[19] = spkno * 10000 + 10.;
    tends[19] = tbegs[19] + 3.;
    tbegs[18] = tbegs[19] - 2.;
    tends[18] = tbegs[18] + 3.;
    tbegs[17] = tbegs[18] - 2.;
    tends[17] = tends[19] + 1.;
    t = tends[17] - .5;
    t_ssfs__(&body, &t, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = spkno - 1) < 10 && 0 <= 
	    i__1 ? i__1 : s_rnge("hndles", i__1, "f_spkbsr__", (ftnlen)2420)],
	     &c__0, ok, (ftnlen)6, (ftnlen)1);
    segno = 18;
    s_copy(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_spkbsr__", (ftnlen)2424)) * 40, "File: # Segn"
	    "o: #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_spkbsr__", (ftnlen)2425)) * 40, "#", spks + ((
	    i__2 = spkno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("spks", i__2, 
	    "f_spkbsr__", (ftnlen)2425)) * 255, xsegid + ((i__3 = segno - 1) <
	     16000 && 0 <= i__3 ? i__3 : s_rnge("xsegid", i__3, "f_spkbsr__", 
	    (ftnlen)2425)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)
	    40);
    repmi_(xsegid + ((i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_spkbsr__", (ftnlen)2426)) * 40, "#", &segno, 
	    xsegid + ((i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_spkbsr__", (ftnlen)2426)) * 40, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + ((i__1 = segno - 1) < 16000 && 0 <= 
	    i__1 ? i__1 : s_rnge("xsegid", i__1, "f_spkbsr__", (ftnlen)2429)) 
	    * 40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (ftnlen)40);

/*     Check the descriptor as well.  However, don't check the */
/*     segment addresses. */

    t_crdesc__("SPK", &segno, &body, &tbegs[(i__1 = segno - 1) < 16000 && 0 <=
	     i__1 ? i__1 : s_rnge("tbegs", i__1, "f_spkbsr__", (ftnlen)2435)],
	     &tends[(i__2 = segno - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
	    "tends", i__2, "f_spkbsr__", (ftnlen)2435)], &xdescr[(i__3 = 
	    segno * 5 - 5) < 80000 && 0 <= i__3 ? i__3 : s_rnge("xdescr", 
	    i__3, "f_spkbsr__", (ftnlen)2435)], (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[(i__1 = segno * 5 - 5) < 80000 && 0 
	    <= i__1 ? i__1 : s_rnge("xdescr", i__1, "f_spkbsr__", (ftnlen)
	    2440)], &c__4, &c_b31, ok, (ftnlen)5, (ftnlen)1);
    tcase_("Create a situation where room is needed in the body table, and t"
	    "he second body list has expense greater than the first.", (ftnlen)
	    119);

/*     Unload SPKs 7 and 10. */

    t_suef__(&hndles[6]);
    t_suef__(&hndles[9]);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Fill up (nearly) the segment table with a cheap list for body 2 */
/*     and an expensive list for body 1. */

    spkno = 7;
    t_slef__(spks + ((i__1 = spkno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge(
	    "spks", i__1, "f_spkbsr__", (ftnlen)2461)) * 255, &hndles[(i__2 = 
	    spkno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("hndles", i__2, 
	    "f_spkbsr__", (ftnlen)2461)], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    body = 2;
    ids[1] = body;
    ids[2] = body;
    tbegs[2] = (doublereal) (spkno * 10000);
    tends[2] = tbegs[2] + 1.;
    body = 2;
    segno = 3;
    d__1 = tbegs[(i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "tbegs", i__1, "f_spkbsr__", (ftnlen)2475)] + .5f;
    t_ssfs__(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     In this case, the segment should be found.  Make sure we get */
/*     back the right handle and segment identifier. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = spkno - 1) < 10 && 0 <= 
	    i__1 ? i__1 : s_rnge("hndles", i__1, "f_spkbsr__", (ftnlen)2484)],
	     &c__0, ok, (ftnlen)6, (ftnlen)1);
    t_slef__(spks + 2295, &hndles[9], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    body = 1;
    spkno = 10;
    segno = 1;
    i__ = 1;
    tbegs[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs", i__1,
	     "f_spkbsr__", (ftnlen)2494)] = (doublereal) (spkno * 10000 + i__ 
	    - 1);
    tends[(i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tends", i__1,
	     "f_spkbsr__", (ftnlen)2495)] = tbegs[(i__2 = i__ - 1) < 16000 && 
	    0 <= i__2 ? i__2 : s_rnge("tbegs", i__2, "f_spkbsr__", (ftnlen)
	    2495)] + 1;
    d__1 = tbegs[0] + .5f;
    t_ssfs__(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = spkno - 1) < 10 && 0 <= 
	    i__1 ? i__1 : s_rnge("hndles", i__1, "f_spkbsr__", (ftnlen)2502)],
	     &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Now do a look up for body 3.  This should cause the segment */
/*     lists for bodies 2 and 1 to get dumped. */

    body = 3;
    spkno = 10;
    i__ = 1;
    j = (body - 1) * 97 + i__;
    tbegs[(i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs", i__1, 
	    "f_spkbsr__", (ftnlen)2514)] = (doublereal) (spkno * 10000 + i__ 
	    - 1);
    tends[(i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tends", i__1, 
	    "f_spkbsr__", (ftnlen)2515)] = tbegs[(i__2 = i__ - 1) < 16000 && 
	    0 <= i__2 ? i__2 : s_rnge("tbegs", i__2, "f_spkbsr__", (ftnlen)
	    2515)] + 1;
    s_copy(xsegid + ((i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_spkbsr__", (ftnlen)2517)) * 40, "File: # Segn"
	    "o: #  Body:  #", (ftnlen)40, (ftnlen)26);
    repmc_(xsegid + ((i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_spkbsr__", (ftnlen)2519)) * 40, "#", spks + ((
	    i__2 = spkno - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("spks", i__2, 
	    "f_spkbsr__", (ftnlen)2519)) * 255, xsegid + ((i__3 = i__ - 1) < 
	    16000 && 0 <= i__3 ? i__3 : s_rnge("xsegid", i__3, "f_spkbsr__", (
	    ftnlen)2519)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)
	    40);
    repmi_(xsegid + ((i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_spkbsr__", (ftnlen)2520)) * 40, "#", &j, 
	    xsegid + ((i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_spkbsr__", (ftnlen)2520)) * 40, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);
    repmi_(xsegid + ((i__1 = i__ - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_spkbsr__", (ftnlen)2521)) * 40, "#", &body, 
	    xsegid + ((i__2 = i__ - 1) < 16000 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_spkbsr__", (ftnlen)2521)) * 40, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    segno = j;
    d__1 = tbegs[(i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs", 
	    i__1, "f_spkbsr__", (ftnlen)2526)] + .5f;
    t_ssfs__(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = spkno - 1) < 10 && 0 <= 
	    i__1 ? i__1 : s_rnge("hndles", i__1, "f_spkbsr__", (ftnlen)2531)],
	     &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Return on entry in RETURN mode, if the error status is set. */

    tcase_("Make sure all T_SBSR entry points return on entry when RETURN() "
	    "is .TRUE.", (ftnlen)73);

/*     Depending on whether we're calling a version of T_SBSR that does */
/*     coverage checking, the error status may be reset. */
    s_copy(smsg, "Return on entry", (ftnlen)25, (ftnlen)15);
    sigerr_(smsg, (ftnlen)25);
    t_sbsr__(" ", &c__1, &c__1, &c_b31, descr, segid, &found, (ftnlen)1, (
	    ftnlen)40);
    if (return_()) {
	chckxc_(&c_true, smsg, ok, (ftnlen)25);
    } else {
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    sigerr_(smsg, (ftnlen)25);
    t_slef__(" ", &handle, (ftnlen)1);
    if (return_()) {
	chckxc_(&c_true, smsg, ok, (ftnlen)25);
    } else {
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    sigerr_(smsg, (ftnlen)25);
    t_suef__(&handle);
    if (return_()) {
	chckxc_(&c_true, smsg, ok, (ftnlen)25);
    } else {
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    sigerr_(smsg, (ftnlen)25);
    t_ssfs__(&c__1, &c_b31, &handle, descr, segid, &found, (ftnlen)40);
    if (return_()) {
	chckxc_(&c_true, smsg, ok, (ftnlen)25);
    } else {
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    tcase_("Make sure an error is signaled if T_SBSR is called directly and "
	    "RETURN() is .FALSE.", (ftnlen)83);
    t_sbsr__(" ", &c__1, &c__1, &c_b31, descr, segid, &found, (ftnlen)1, (
	    ftnlen)40);
    chckxc_(&c_true, "SPICE(BOGUSENTRY)", ok, (ftnlen)17);
    tcase_("Try DAFOPR error handling.", (ftnlen)26);
    t_slef__("ThisFileDoesNotExist", &handle, (ftnlen)20);
    if (return_()) {
	chckxc_(&c_true, "SPICE(FILENOTFOUND)", ok, (ftnlen)19);
    } else {
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    tcase_("Test partial deletion of a segment list when a file is unloaded.",
	     (ftnlen)64);

/*     Unload the SPK files.  The load files 1 and 2. */

    for (i__ = 1; i__ <= 10; ++i__) {
	t_suef__(&hndles[(i__1 = i__ - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge(
		"hndles", i__1, "f_spkbsr__", (ftnlen)2624)]);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    for (i__ = 1; i__ <= 2; ++i__) {
	t_slef__(spks + ((i__1 = i__ - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge(
		"spks", i__1, "f_spkbsr__", (ftnlen)2630)) * 255, &hndles[(
		i__2 = i__ - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("hndles", 
		i__2, "f_spkbsr__", (ftnlen)2630)], (ftnlen)255);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Do lookups for body 1 that hit both files. */

    body = 1;
    tbegs[0] = 1e4;
    d__1 = tbegs[0] + .5f;
    t_ssfs__(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    body = 1;
    spkno = 2;
    segno = nseg[(i__1 = spkno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("nseg", 
	    i__1, "f_spkbsr__", (ftnlen)2648)] / 2 + 1;
    tbegs[(i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs", 
	    i__1, "f_spkbsr__", (ftnlen)2650)] = (doublereal) (spkno * 10000 
	    + segno - 1);
    d__1 = tbegs[(i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "tbegs", i__1, "f_spkbsr__", (ftnlen)2652)] + .5f;
    t_ssfs__(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Do a lookup for body 2 to create a segment list for that */
/*     body. */

    body = 2;
    spkno = 2;
    segno = nseg[(i__1 = spkno - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("nseg", 
	    i__1, "f_spkbsr__", (ftnlen)2664)] / 2;
    tbegs[(i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs", 
	    i__1, "f_spkbsr__", (ftnlen)2666)] = (doublereal) (spkno * 10000 
	    + segno - 1);
    d__1 = tbegs[(i__1 = segno - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
	    "tbegs", i__1, "f_spkbsr__", (ftnlen)2668)] + .5f;
    t_ssfs__(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Reload file 1, removing the portion of body 1's segment list */
/*     that came from file 1, as part of the unload process that */
/*     precedes re-loading file 1. */

    t_slef__(spks, hndles, (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Create FTSIZE copies of SPK 1 and load FTSIZE-1 of them.  We */
/*     should get a file table overflow error. */

    tcase_("File table overflow error.", (ftnlen)26);
    for (i__ = 1; i__ <= 110; ++i__) {
	s_copy(spkcpy + ((i__1 = i__ - 1) < 110 && 0 <= i__1 ? i__1 : s_rnge(
		"spkcpy", i__1, "f_spkbsr__", (ftnlen)2693)) * 255, "copy#.b"
		"sp", (ftnlen)255, (ftnlen)9);
	repmi_(spkcpy + ((i__1 = i__ - 1) < 110 && 0 <= i__1 ? i__1 : s_rnge(
		"spkcpy", i__1, "f_spkbsr__", (ftnlen)2694)) * 255, "#", &i__,
		 spkcpy + ((i__2 = i__ - 1) < 110 && 0 <= i__2 ? i__2 : 
		s_rnge("spkcpy", i__2, "f_spkbsr__", (ftnlen)2694)) * 255, (
		ftnlen)255, (ftnlen)1, (ftnlen)255);
	body = 1;
	tbegs[0] = 1e4;
	tends[0] = 10001.;
	spkno = 1;
	s_copy(xsegid, "File: # Segno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid, "#", spkcpy + ((i__1 = i__ - 1) < 110 && 0 <= i__1 ? 
		i__1 : s_rnge("spkcpy", i__1, "f_spkbsr__", (ftnlen)2702)) * 
		255, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
	repmi_(xsegid, "#", &c__1, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	t_crdaf__("SPK", spkcpy + ((i__1 = i__ - 1) < 110 && 0 <= i__1 ? i__1 
		: s_rnge("spkcpy", i__1, "f_spkbsr__", (ftnlen)2706)) * 255, 
		nseg, &body, tbegs, tends, xsegid, (ftnlen)3, (ftnlen)255, (
		ftnlen)40);
    }
    for (i__ = 1; i__ <= 108; ++i__) {
	t_slef__(spkcpy + ((i__1 = i__ - 1) < 110 && 0 <= i__1 ? i__1 : 
		s_rnge("spkcpy", i__1, "f_spkbsr__", (ftnlen)2713)) * 255, &
		cpyhan[(i__2 = i__ - 1) < 110 && 0 <= i__2 ? i__2 : s_rnge(
		"cpyhan", i__2, "f_spkbsr__", (ftnlen)2713)], (ftnlen)255);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    t_slef__(spkcpy + 27540, &cpyhan[108], (ftnlen)255);

/*     Note:  if FTSIZE were >= the handle manager file table's size, */
/*     we would expect the short error message */

/*        SPICE(FTFULL) */

    chckxc_(&c_true, "SPICE(SPKFILETABLEFULL)", ok, (ftnlen)23);

/*     Loading, unloading, and priority checks: */

    tcase_("Load all copies of SPK 1, looking up the same state from each.  "
	    "Unload the files in reverse order.  Repeat 3 times.", (ftnlen)115)
	    ;

/*     First, make sure all files are unloaded. */

    for (i__ = 1; i__ <= 10; ++i__) {
	t_suef__(&hndles[(i__1 = i__ - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge(
		"hndles", i__1, "f_spkbsr__", (ftnlen)2740)]);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    for (i__ = 1; i__ <= 109; ++i__) {
	t_suef__(&cpyhan[(i__1 = i__ - 1) < 110 && 0 <= i__1 ? i__1 : s_rnge(
		"cpyhan", i__1, "f_spkbsr__", (ftnlen)2747)]);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    body = 1;
    for (i__ = 1; i__ <= 3; ++i__) {
	for (j = 1; j <= 110; ++j) {
	    tbegs[(i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs",
		     i__1, "f_spkbsr__", (ftnlen)2758)] = 1e4;
	    tends[(i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tends",
		     i__1, "f_spkbsr__", (ftnlen)2759)] = 10001.;
	    t_slef__(spkcpy + ((i__1 = j - 1) < 110 && 0 <= i__1 ? i__1 : 
		    s_rnge("spkcpy", i__1, "f_spkbsr__", (ftnlen)2761)) * 255,
		     &cpyhan[(i__2 = j - 1) < 110 && 0 <= i__2 ? i__2 : 
		    s_rnge("cpyhan", i__2, "f_spkbsr__", (ftnlen)2761)], (
		    ftnlen)255);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    s_copy(xsegid + ((i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : 
		    s_rnge("xsegid", i__1, "f_spkbsr__", (ftnlen)2764)) * 40, 
		    "File: # Segno: #", (ftnlen)40, (ftnlen)16);
	    repmc_(xsegid + ((i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : 
		    s_rnge("xsegid", i__1, "f_spkbsr__", (ftnlen)2765)) * 40, 
		    "#", spkcpy + ((i__2 = j - 1) < 110 && 0 <= i__2 ? i__2 : 
		    s_rnge("spkcpy", i__2, "f_spkbsr__", (ftnlen)2765)) * 255,
		     xsegid + ((i__3 = j - 1) < 16000 && 0 <= i__3 ? i__3 : 
		    s_rnge("xsegid", i__3, "f_spkbsr__", (ftnlen)2765)) * 40, 
		    (ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
	    repmi_(xsegid + ((i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : 
		    s_rnge("xsegid", i__1, "f_spkbsr__", (ftnlen)2766)) * 40, 
		    "#", &c__1, xsegid + ((i__2 = j - 1) < 16000 && 0 <= i__2 
		    ? i__2 : s_rnge("xsegid", i__2, "f_spkbsr__", (ftnlen)
		    2766)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    d__1 = tbegs[(i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
		    "tbegs", i__1, "f_spkbsr__", (ftnlen)2769)] + .5f;
	    t_ssfs__(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           In this case, the segment should be found.  Make sure */
/*           we get back the right handle and segment identifier. */

	    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	    chcksi_("HANDLE", &handle, "=", &cpyhan[(i__1 = j - 1) < 110 && 0 
		    <= i__1 ? i__1 : s_rnge("cpyhan", i__1, "f_spkbsr__", (
		    ftnlen)2778)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	    chcksc_("SEGID", segid, "=", xsegid + ((i__1 = j - 1) < 16000 && 
		    0 <= i__1 ? i__1 : s_rnge("xsegid", i__1, "f_spkbsr__", (
		    ftnlen)2779)) * 40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, 
		    (ftnlen)40);

/*           Check the descriptor as well.  However, don't check the */
/*           segment addresses. */

	    t_crdesc__("SPK", &c__1, &body, &tbegs[(i__1 = j - 1) < 16000 && 
		    0 <= i__1 ? i__1 : s_rnge("tbegs", i__1, "f_spkbsr__", (
		    ftnlen)2785)], &tends[(i__2 = j - 1) < 16000 && 0 <= i__2 
		    ? i__2 : s_rnge("tends", i__2, "f_spkbsr__", (ftnlen)2785)
		    ], &xdescr[(i__3 = j * 5 - 5) < 80000 && 0 <= i__3 ? i__3 
		    : s_rnge("xdescr", i__3, "f_spkbsr__", (ftnlen)2785)], (
		    ftnlen)3);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    t_chds__("DESCR", descr, "=", &xdescr[(i__1 = j * 5 - 5) < 80000 
		    && 0 <= i__1 ? i__1 : s_rnge("xdescr", i__1, "f_spkbsr__",
		     (ftnlen)2789)], &c__4, &c_b31, ok, (ftnlen)5, (ftnlen)1);
	}

/*        Now unload files, looking up states as we go. */

	for (j = 109; j >= 1; --j) {
	    t_suef__(&cpyhan[(i__1 = j) < 110 && 0 <= i__1 ? i__1 : s_rnge(
		    "cpyhan", i__1, "f_spkbsr__", (ftnlen)2799)]);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    tbegs[(i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tbegs",
		     i__1, "f_spkbsr__", (ftnlen)2802)] = 1e4;
	    tends[(i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge("tends",
		     i__1, "f_spkbsr__", (ftnlen)2803)] = 10001.;
	    s_copy(xsegid + ((i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : 
		    s_rnge("xsegid", i__1, "f_spkbsr__", (ftnlen)2805)) * 40, 
		    "File: # Segno: #", (ftnlen)40, (ftnlen)16);
	    repmc_(xsegid + ((i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : 
		    s_rnge("xsegid", i__1, "f_spkbsr__", (ftnlen)2806)) * 40, 
		    "#", spkcpy + ((i__2 = j - 1) < 110 && 0 <= i__2 ? i__2 : 
		    s_rnge("spkcpy", i__2, "f_spkbsr__", (ftnlen)2806)) * 255,
		     xsegid + ((i__3 = j - 1) < 16000 && 0 <= i__3 ? i__3 : 
		    s_rnge("xsegid", i__3, "f_spkbsr__", (ftnlen)2806)) * 40, 
		    (ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
	    repmi_(xsegid + ((i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : 
		    s_rnge("xsegid", i__1, "f_spkbsr__", (ftnlen)2807)) * 40, 
		    "#", &c__1, xsegid + ((i__2 = j - 1) < 16000 && 0 <= i__2 
		    ? i__2 : s_rnge("xsegid", i__2, "f_spkbsr__", (ftnlen)
		    2807)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    d__1 = tbegs[(i__1 = j - 1) < 16000 && 0 <= i__1 ? i__1 : s_rnge(
		    "tbegs", i__1, "f_spkbsr__", (ftnlen)2810)] + .5f;
	    t_ssfs__(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           In this case, the segment should be found.  Make sure */
/*           we get back the right handle and segment identifier. */

	    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	    chcksi_("HANDLE", &handle, "=", &cpyhan[(i__1 = j - 1) < 110 && 0 
		    <= i__1 ? i__1 : s_rnge("cpyhan", i__1, "f_spkbsr__", (
		    ftnlen)2819)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	    chcksc_("SEGID", segid, "=", xsegid + ((i__1 = j - 1) < 16000 && 
		    0 <= i__1 ? i__1 : s_rnge("xsegid", i__1, "f_spkbsr__", (
		    ftnlen)2820)) * 40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, 
		    (ftnlen)40);

/*           Check the descriptor as well.  However, don't check the */
/*           segment addresses. */

	    t_crdesc__("SPK", &c__1, &body, &tbegs[(i__1 = j - 1) < 16000 && 
		    0 <= i__1 ? i__1 : s_rnge("tbegs", i__1, "f_spkbsr__", (
		    ftnlen)2826)], &tends[(i__2 = j - 1) < 16000 && 0 <= i__2 
		    ? i__2 : s_rnge("tends", i__2, "f_spkbsr__", (ftnlen)2826)
		    ], &xdescr[(i__3 = j * 5 - 5) < 80000 && 0 <= i__3 ? i__3 
		    : s_rnge("xdescr", i__3, "f_spkbsr__", (ftnlen)2826)], (
		    ftnlen)3);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    t_chds__("DESCR", descr, "=", &xdescr[(i__1 = j * 5 - 5) < 80000 
		    && 0 <= i__1 ? i__1 : s_rnge("xdescr", i__1, "f_spkbsr__",
		     (ftnlen)2830)], &c__4, &c_b31, ok, (ftnlen)5, (ftnlen)1);
	}
    }

/*     Make sure we don't accumulate DAF links by re-loading a file. */

    tcase_("Load the first SPK file 2*FTSIZE times.", (ftnlen)39);
    for (i__ = 1; i__ <= 220; ++i__) {
	tbegs[0] = 1e4;
	tends[0] = 10001.;
	t_slef__(spks, hndles, (ftnlen)255);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	s_copy(xsegid, "File: # Segno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid, "#", spks, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)255, 
		(ftnlen)40);
	repmi_(xsegid, "#", &c__1, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	d__1 = tbegs[0] + .5f;
	t_ssfs__(&body, &d__1, &handle, descr, segid, &found, (ftnlen)40);
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

	t_crdesc__("SPK", &c__1, &body, tbegs, tends, xdescr, (ftnlen)3);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	t_chds__("DESCR", descr, "=", xdescr, &c__4, &c_b31, ok, (ftnlen)5, (
		ftnlen)1);
    }

/*     Last step:  delete all of the SPK files we created. */

    for (i__ = 1; i__ <= 10; ++i__) {
	t_suef__(&hndles[(i__1 = i__ - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge(
		"hndles", i__1, "f_spkbsr__", (ftnlen)2885)]);
	delfil_(spks + ((i__1 = i__ - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge(
		"spks", i__1, "f_spkbsr__", (ftnlen)2886)) * 255, (ftnlen)255)
		;
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    for (i__ = 1; i__ <= 110; ++i__) {
	t_suef__(&cpyhan[(i__1 = i__ - 1) < 110 && 0 <= i__1 ? i__1 : s_rnge(
		"cpyhan", i__1, "f_spkbsr__", (ftnlen)2893)]);
	delfil_(spkcpy + ((i__1 = i__ - 1) < 110 && 0 <= i__1 ? i__1 : s_rnge(
		"spkcpy", i__1, "f_spkbsr__", (ftnlen)2894)) * 255, (ftnlen)
		255);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    t_success__(ok);
    return 0;
} /* f_spkbsr__ */

