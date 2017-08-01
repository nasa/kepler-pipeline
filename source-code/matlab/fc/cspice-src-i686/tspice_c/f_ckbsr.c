/* f_ckbsr.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__1 = 1;
static logical c_false = FALSE_;
static doublereal c_b15 = 0.;
static logical c_true = TRUE_;
static integer c__0 = 0;
static integer c__4 = 4;
static integer c__2 = 2;

/* $Procedure  F_CKBSR ( Family of tests for T_CBR ) */
/* Subroutine */ int f_ckbsr__(logical *ok)
{
    /* Initialized data */

    static char cks[255*15] = "bsr1.bc                                      "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                  " "bsr2.bc                                    "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                    " "bsr3.bc                                  "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                      " "bsr4.bc                                "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                        " "bsr5.bc                              "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                          " "bsr6.bc                            "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                            " "bsr7.bc                          "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                              " "bsr8.bc                        "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                                " "bsr9.bc                      "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                                  " "bsr10.bc                   "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                                    " "bsr11.bc                 "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                                      " "bsr12.bc               "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                                        " "bsr13.bc             "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                                          " "bsr14.bc           "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                                            " "bsr15.bc         "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                                              ";
    static integer nseg[15] = { 1,50,50,10,100,110,20,23,23,400,388,100,10,60,
	    50 };

    /* System generated locals */
    integer i__1, i__2, i__3, i__4, i__5;
    doublereal d__1;
    logical L__1;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    integer ckno;
    extern logical even_(integer *);
    char smsg[25];
    extern /* Subroutine */ int t_crckds__(integer *, integer *, doublereal *,
	     doublereal *, doublereal *, logical *);
    integer inst, i__, j;
    doublereal t;
    extern /* Subroutine */ int t_clf__(char *, integer *, ftnlen), t_cbr__(
	    char *, integer *, integer *, doublereal *, doublereal *, logical 
	    *, doublereal *, char *, logical *, ftnlen, ftnlen), t_cbs__(
	    integer *, doublereal *, doublereal *, logical *);
    char segid[40];
    doublereal descr[5], tbegs[400];
    extern /* Subroutine */ int tcase_(char *, ftnlen), repmc_(char *, char *,
	     char *, char *, ftnlen, ftnlen, ftnlen, ftnlen), t_csn__(integer 
	    *, doublereal *, char *, logical *, ftnlen), t_cuf__(integer *);
    char ckcpy[255*110];
    extern /* Subroutine */ int ckopn_(char *, char *, integer *, integer *, 
	    ftnlen, ftnlen);
    integer segno;
    logical found;
    doublereal tends[400];
    extern /* Subroutine */ int repmi_(char *, char *, integer *, char *, 
	    ftnlen, ftnlen, ftnlen), ckcls_(integer *), topen_(char *, ftnlen)
	    , t_success__(logical *), dafbna_(integer *, doublereal *, char *,
	     ftnlen), dafena_(void);
    integer handle;
    extern /* Subroutine */ int chcksc_(char *, char *, char *, char *, 
	    logical *, ftnlen, ftnlen, ftnlen, ftnlen), delfil_(char *, 
	    ftnlen);
    logical avflag;
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     chcksi_(char *, integer *, char *, integer *, integer *, logical 
	    *, ftnlen, ftnlen), t_chds__(char *, doublereal *, char *, 
	    doublereal *, integer *, doublereal *, logical *, ftnlen, ftnlen),
	     chcksl_(char *, logical *, logical *, logical *, ftnlen);
    integer hndles[15], cpyhan[110];
    char xsegid[40*400];
    doublereal xdescr[2000]	/* was [5][400] */;
    extern /* Subroutine */ int sigerr_(char *, ftnlen);
    extern logical return_(void);
    integer ids[400];
    extern /* Subroutine */ int t_crdaf__(char *, char *, integer *, integer *
	    , doublereal *, doublereal *, char *, ftnlen, ftnlen, ftnlen);
    doublereal tol;

/* $ Abstract */

/*     This routine tests the CK segment selection and buffering system, */
/*     which is implemented by T_CBR. */


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


/*     MAXSEG should be set to MAX ( NINST * STSIZE, FTSIZE ). */


/*     The number of segments in the respective CK files: */


/*     Other parameters: */


/*     Local variables */


/*     Saved variables */


/*     Initial values */


/*     Begin every test family with an open call. */

    topen_("F_CKBSR", (ftnlen)7);
    tcase_("The first CK file contains 1 segment for instrument 1. Make sure"
	    " we can look up data from this file.", (ftnlen)100);

/*     Create the first CK file. */

    inst = 1;
    tbegs[0] = 1e4;
    tends[0] = 10001.;
    ckno = 1;
    s_copy(xsegid, "File: # Segno: #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid, "#", cks, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)255, (
	    ftnlen)40);
    repmi_(xsegid, "#", &c__1, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_crdaf__("CK", cks, nseg, &inst, tbegs, tends, xsegid, (ftnlen)2, (
	    ftnlen)255, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_clf__(cks, hndles, (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    d__1 = tbegs[0] + .5f;
    t_cbs__(&inst, &d__1, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     In this case, the segment should be found.  Make sure we get */
/*     back the right handle and segment identifier. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", hndles, &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1,
	     (ftnlen)40);

/*     Check the descriptor as well.  However, don't check the */
/*     segment addresses. */

    t_crckds__(&c__1, &inst, tbegs, tends, xdescr, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_chds__("DESCR", descr, "=", xdescr, &c__4, &c_b15, ok, (ftnlen)5, (
	    ftnlen)1);
    tcase_("Try to look up data for a different instrumentin CK 1.  Also loo"
	    "k up data for instrument 1 for a time which is not covered.", (
	    ftnlen)123);
    d__1 = tbegs[0] + .5f;
    t_cbs__(&c__2, &d__1, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     In this case, the segment should not be found. */

    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    d__1 = tbegs[0] + 10.;
    t_cbs__(&c__1, &d__1, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     In this case, the segment should not be found. */

    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    tcase_("Create a second CK containing data for instrument 1 and instrume"
	    "nt 2.  Load this CK, then look up a state covered by the new fil"
	    "e.", (ftnlen)130);
    inst = 1;
    ckno = 2;
    i__2 = nseg[(i__1 = ckno - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge("nseg", 
	    i__1, "f_ckbsr__", (ftnlen)304)];
    for (i__ = 1; i__ <= i__2; ++i__) {
	if (i__ <= nseg[(i__1 = ckno - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge(
		"nseg", i__1, "f_ckbsr__", (ftnlen)306)] / 2) {
	    ids[(i__1 = i__ - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("ids", 
		    i__1, "f_ckbsr__", (ftnlen)307)] = 2;
	} else {
	    ids[(i__1 = i__ - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("ids", 
		    i__1, "f_ckbsr__", (ftnlen)309)] = 1;
	}
	tbegs[(i__1 = i__ - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("tbegs", 
		i__1, "f_ckbsr__", (ftnlen)312)] = (doublereal) (ckno * 10000 
		+ i__ - 1);
	tends[(i__1 = i__ - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("tends", 
		i__1, "f_ckbsr__", (ftnlen)313)] = tbegs[(i__3 = i__ - 1) < 
		400 && 0 <= i__3 ? i__3 : s_rnge("tbegs", i__3, "f_ckbsr__", (
		ftnlen)313)] + 1;
	s_copy(xsegid + ((i__1 = i__ - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge(
		"xsegid", i__1, "f_ckbsr__", (ftnlen)315)) * 40, "File: # Se"
		"gno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid + ((i__1 = i__ - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge(
		"xsegid", i__1, "f_ckbsr__", (ftnlen)317)) * 40, "#", cks + ((
		i__3 = ckno - 1) < 15 && 0 <= i__3 ? i__3 : s_rnge("cks", 
		i__3, "f_ckbsr__", (ftnlen)317)) * 255, xsegid + ((i__4 = i__ 
		- 1) < 400 && 0 <= i__4 ? i__4 : s_rnge("xsegid", i__4, "f_c"
		"kbsr__", (ftnlen)317)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)
		255, (ftnlen)40);
	repmi_(xsegid + ((i__1 = i__ - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge(
		"xsegid", i__1, "f_ckbsr__", (ftnlen)318)) * 40, "#", &i__, 
		xsegid + ((i__3 = i__ - 1) < 400 && 0 <= i__3 ? i__3 : s_rnge(
		"xsegid", i__3, "f_ckbsr__", (ftnlen)318)) * 40, (ftnlen)40, (
		ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    t_crdaf__("CK", cks + ((i__2 = ckno - 1) < 15 && 0 <= i__2 ? i__2 : 
	    s_rnge("cks", i__2, "f_ckbsr__", (ftnlen)324)) * 255, &nseg[(i__1 
	    = ckno - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge("nseg", i__1, "f_c"
	    "kbsr__", (ftnlen)324)], ids, tbegs, tends, xsegid, (ftnlen)2, (
	    ftnlen)255, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_clf__(cks + ((i__2 = ckno - 1) < 15 && 0 <= i__2 ? i__2 : s_rnge("cks", 
	    i__2, "f_ckbsr__", (ftnlen)329)) * 255, &hndles[(i__1 = ckno - 1) 
	    < 15 && 0 <= i__1 ? i__1 : s_rnge("hndles", i__1, "f_ckbsr__", (
	    ftnlen)329)], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    segno = nseg[(i__2 = ckno - 1) < 15 && 0 <= i__2 ? i__2 : s_rnge("nseg", 
	    i__2, "f_ckbsr__", (ftnlen)332)];
    d__1 = tbegs[(i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbegs"
	    , i__2, "f_ckbsr__", (ftnlen)335)] + .5;
    t_cbs__(&inst, &d__1, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     In this case, the segment should be found.  Make sure we get */
/*     back the right handle and segment identifier. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__2 = ckno - 1) < 15 && 0 <= 
	    i__2 ? i__2 : s_rnge("hndles", i__2, "f_ckbsr__", (ftnlen)345)], &
	    c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + ((i__2 = segno - 1) < 400 && 0 <= 
	    i__2 ? i__2 : s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)346)) * 
	    40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (ftnlen)40);

/*     Check the descriptor as well.  However, don't check the */
/*     segment addresses. */

    t_crckds__(&segno, &inst, &tbegs[(i__2 = segno - 1) < 400 && 0 <= i__2 ? 
	    i__2 : s_rnge("tbegs", i__2, "f_ckbsr__", (ftnlen)352)], &tends[(
	    i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("tends", 
	    i__1, "f_ckbsr__", (ftnlen)352)], &xdescr[(i__3 = segno * 5 - 5) <
	     2000 && 0 <= i__3 ? i__3 : s_rnge("xdescr", i__3, "f_ckbsr__", (
	    ftnlen)352)], &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[(i__2 = segno * 5 - 5) < 2000 && 0 
	    <= i__2 ? i__2 : s_rnge("xdescr", i__2, "f_ckbsr__", (ftnlen)356)]
	    , &c__4, &c_b15, ok, (ftnlen)5, (ftnlen)1);
    tcase_("Look up data for instrument 2.  This should cause an OLD FILES s"
	    "earch.", (ftnlen)70);
    inst = 2;
    ckno = 2;
    segno = 1;
    d__1 = tbegs[(i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbegs"
	    , i__2, "f_ckbsr__", (ftnlen)371)] + .5;
    t_cbs__(&inst, &d__1, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     In this case, the segment should be found.  Make sure we get */
/*     back the right handle and segment identifier. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__2 = ckno - 1) < 15 && 0 <= 
	    i__2 ? i__2 : s_rnge("hndles", i__2, "f_ckbsr__", (ftnlen)381)], &
	    c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + ((i__2 = segno - 1) < 400 && 0 <= 
	    i__2 ? i__2 : s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)382)) * 
	    40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (ftnlen)40);

/*     Check the descriptor as well.  However, don't check the */
/*     segment addresses. */

    t_crckds__(&segno, &inst, &tbegs[(i__2 = segno - 1) < 400 && 0 <= i__2 ? 
	    i__2 : s_rnge("tbegs", i__2, "f_ckbsr__", (ftnlen)388)], &tends[(
	    i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("tends", 
	    i__1, "f_ckbsr__", (ftnlen)388)], &xdescr[(i__3 = segno * 5 - 5) <
	     2000 && 0 <= i__3 ? i__3 : s_rnge("xdescr", i__3, "f_ckbsr__", (
	    ftnlen)388)], &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[(i__2 = segno * 5 - 5) < 2000 && 0 
	    <= i__2 ? i__2 : s_rnge("xdescr", i__2, "f_ckbsr__", (ftnlen)392)]
	    , &c__4, &c_b15, ok, (ftnlen)5, (ftnlen)1);
    tcase_("Create a third CK containing data for instrument 3. Load this CK"
	    ", then look up a state covered by the new file. This should caus"
	    "e the segment list for instrument 1 to get dumped.", (ftnlen)178);
    inst = 3;
    ckno = 3;
    i__1 = nseg[(i__2 = ckno - 1) < 15 && 0 <= i__2 ? i__2 : s_rnge("nseg", 
	    i__2, "f_ckbsr__", (ftnlen)405)];
    for (i__ = 1; i__ <= i__1; ++i__) {
	ids[(i__2 = i__ - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("ids", i__2, 
		"f_ckbsr__", (ftnlen)407)] = inst;
	tbegs[(i__2 = i__ - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbegs", 
		i__2, "f_ckbsr__", (ftnlen)409)] = (doublereal) (ckno * 10000 
		+ i__ - 1);
	tends[(i__2 = i__ - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tends", 
		i__2, "f_ckbsr__", (ftnlen)410)] = tbegs[(i__3 = i__ - 1) < 
		400 && 0 <= i__3 ? i__3 : s_rnge("tbegs", i__3, "f_ckbsr__", (
		ftnlen)410)] + 1;
	s_copy(xsegid + ((i__2 = i__ - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
		"xsegid", i__2, "f_ckbsr__", (ftnlen)412)) * 40, "File: # Se"
		"gno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid + ((i__2 = i__ - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
		"xsegid", i__2, "f_ckbsr__", (ftnlen)414)) * 40, "#", cks + ((
		i__3 = ckno - 1) < 15 && 0 <= i__3 ? i__3 : s_rnge("cks", 
		i__3, "f_ckbsr__", (ftnlen)414)) * 255, xsegid + ((i__4 = i__ 
		- 1) < 400 && 0 <= i__4 ? i__4 : s_rnge("xsegid", i__4, "f_c"
		"kbsr__", (ftnlen)414)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)
		255, (ftnlen)40);
	repmi_(xsegid + ((i__2 = i__ - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
		"xsegid", i__2, "f_ckbsr__", (ftnlen)415)) * 40, "#", &i__, 
		xsegid + ((i__3 = i__ - 1) < 400 && 0 <= i__3 ? i__3 : s_rnge(
		"xsegid", i__3, "f_ckbsr__", (ftnlen)415)) * 40, (ftnlen)40, (
		ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    t_crdaf__("CK", cks + ((i__1 = ckno - 1) < 15 && 0 <= i__1 ? i__1 : 
	    s_rnge("cks", i__1, "f_ckbsr__", (ftnlen)421)) * 255, &nseg[(i__2 
	    = ckno - 1) < 15 && 0 <= i__2 ? i__2 : s_rnge("nseg", i__2, "f_c"
	    "kbsr__", (ftnlen)421)], ids, tbegs, tends, xsegid, (ftnlen)2, (
	    ftnlen)255, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_clf__(cks + ((i__1 = ckno - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge("cks", 
	    i__1, "f_ckbsr__", (ftnlen)426)) * 255, &hndles[(i__2 = ckno - 1) 
	    < 15 && 0 <= i__2 ? i__2 : s_rnge("hndles", i__2, "f_ckbsr__", (
	    ftnlen)426)], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    segno = nseg[(i__1 = ckno - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge("nseg", 
	    i__1, "f_ckbsr__", (ftnlen)429)];
    d__1 = tbegs[(i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("tbegs"
	    , i__1, "f_ckbsr__", (ftnlen)432)] + .5;
    t_cbs__(&inst, &d__1, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     In this case, the segment should be found.  Make sure we get */
/*     back the right handle and segment identifier. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = ckno - 1) < 15 && 0 <= 
	    i__1 ? i__1 : s_rnge("hndles", i__1, "f_ckbsr__", (ftnlen)442)], &
	    c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + ((i__1 = segno - 1) < 400 && 0 <= 
	    i__1 ? i__1 : s_rnge("xsegid", i__1, "f_ckbsr__", (ftnlen)443)) * 
	    40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (ftnlen)40);

/*     Check the descriptor as well.  However, don't check the */
/*     segment addresses. */

    t_crckds__(&segno, &inst, &tbegs[(i__1 = segno - 1) < 400 && 0 <= i__1 ? 
	    i__1 : s_rnge("tbegs", i__1, "f_ckbsr__", (ftnlen)449)], &tends[(
	    i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tends", 
	    i__2, "f_ckbsr__", (ftnlen)449)], &xdescr[(i__3 = segno * 5 - 5) <
	     2000 && 0 <= i__3 ? i__3 : s_rnge("xdescr", i__3, "f_ckbsr__", (
	    ftnlen)449)], &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[(i__1 = segno * 5 - 5) < 2000 && 0 
	    <= i__1 ? i__1 : s_rnge("xdescr", i__1, "f_ckbsr__", (ftnlen)453)]
	    , &c__4, &c_b15, ok, (ftnlen)5, (ftnlen)1);
    tcase_("Create another CK for instrument 2 and load it. Make another rea"
	    "d request for instrument 2 that will be satisfied by a segment i"
	    "n file 3. This should result in another OLD FILES search.", (
	    ftnlen)185);
    inst = 2;
    ckno = 4;
    i__2 = nseg[(i__1 = ckno - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge("nseg", 
	    i__1, "f_ckbsr__", (ftnlen)470)];
    for (i__ = 1; i__ <= i__2; ++i__) {
	ids[(i__1 = i__ - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("ids", i__1, 
		"f_ckbsr__", (ftnlen)472)] = inst;
	tbegs[(i__1 = i__ - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("tbegs", 
		i__1, "f_ckbsr__", (ftnlen)474)] = (doublereal) (ckno * 10000 
		+ i__ - 1);
	tends[(i__1 = i__ - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("tends", 
		i__1, "f_ckbsr__", (ftnlen)475)] = tbegs[(i__3 = i__ - 1) < 
		400 && 0 <= i__3 ? i__3 : s_rnge("tbegs", i__3, "f_ckbsr__", (
		ftnlen)475)] + 1;
	s_copy(xsegid + ((i__1 = i__ - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge(
		"xsegid", i__1, "f_ckbsr__", (ftnlen)477)) * 40, "File: # Se"
		"gno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid + ((i__1 = i__ - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge(
		"xsegid", i__1, "f_ckbsr__", (ftnlen)479)) * 40, "#", cks + ((
		i__3 = ckno - 1) < 15 && 0 <= i__3 ? i__3 : s_rnge("cks", 
		i__3, "f_ckbsr__", (ftnlen)479)) * 255, xsegid + ((i__4 = i__ 
		- 1) < 400 && 0 <= i__4 ? i__4 : s_rnge("xsegid", i__4, "f_c"
		"kbsr__", (ftnlen)479)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)
		255, (ftnlen)40);
	repmi_(xsegid + ((i__1 = i__ - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge(
		"xsegid", i__1, "f_ckbsr__", (ftnlen)480)) * 40, "#", &i__, 
		xsegid + ((i__3 = i__ - 1) < 400 && 0 <= i__3 ? i__3 : s_rnge(
		"xsegid", i__3, "f_ckbsr__", (ftnlen)480)) * 40, (ftnlen)40, (
		ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    t_crdaf__("CK", cks + ((i__2 = ckno - 1) < 15 && 0 <= i__2 ? i__2 : 
	    s_rnge("cks", i__2, "f_ckbsr__", (ftnlen)485)) * 255, &nseg[(i__1 
	    = ckno - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge("nseg", i__1, "f_c"
	    "kbsr__", (ftnlen)485)], ids, tbegs, tends, xsegid, (ftnlen)2, (
	    ftnlen)255, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    tcase_("Create another CK for instrument 1 and load it. The segment coun"
	    "t in this file is such that all other instrument lists must be d"
	    "umped to make room. Then make a request that is satisfied by CK "
	    "1.  The segment in CK 1 cannot be added to the segment table.", (
	    ftnlen)253);
    inst = 1;
    ckno = 5;
    i__1 = nseg[(i__2 = ckno - 1) < 15 && 0 <= i__2 ? i__2 : s_rnge("nseg", 
	    i__2, "f_ckbsr__", (ftnlen)504)];
    for (i__ = 1; i__ <= i__1; ++i__) {
	ids[(i__2 = i__ - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("ids", i__2, 
		"f_ckbsr__", (ftnlen)506)] = inst;
	tbegs[(i__2 = i__ - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbegs", 
		i__2, "f_ckbsr__", (ftnlen)508)] = (doublereal) (ckno * 10000 
		+ i__ - 1);
	tends[(i__2 = i__ - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tends", 
		i__2, "f_ckbsr__", (ftnlen)509)] = tbegs[(i__3 = i__ - 1) < 
		400 && 0 <= i__3 ? i__3 : s_rnge("tbegs", i__3, "f_ckbsr__", (
		ftnlen)509)] + 1;
	s_copy(xsegid + ((i__2 = i__ - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
		"xsegid", i__2, "f_ckbsr__", (ftnlen)511)) * 40, "File: # Se"
		"gno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid + ((i__2 = i__ - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
		"xsegid", i__2, "f_ckbsr__", (ftnlen)513)) * 40, "#", cks + ((
		i__3 = ckno - 1) < 15 && 0 <= i__3 ? i__3 : s_rnge("cks", 
		i__3, "f_ckbsr__", (ftnlen)513)) * 255, xsegid + ((i__4 = i__ 
		- 1) < 400 && 0 <= i__4 ? i__4 : s_rnge("xsegid", i__4, "f_c"
		"kbsr__", (ftnlen)513)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)
		255, (ftnlen)40);
	repmi_(xsegid + ((i__2 = i__ - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
		"xsegid", i__2, "f_ckbsr__", (ftnlen)514)) * 40, "#", &i__, 
		xsegid + ((i__3 = i__ - 1) < 400 && 0 <= i__3 ? i__3 : s_rnge(
		"xsegid", i__3, "f_ckbsr__", (ftnlen)514)) * 40, (ftnlen)40, (
		ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    t_crdaf__("CK", cks + ((i__1 = ckno - 1) < 15 && 0 <= i__1 ? i__1 : 
	    s_rnge("cks", i__1, "f_ckbsr__", (ftnlen)519)) * 255, &nseg[(i__2 
	    = ckno - 1) < 15 && 0 <= i__2 ? i__2 : s_rnge("nseg", i__2, "f_c"
	    "kbsr__", (ftnlen)519)], ids, tbegs, tends, xsegid, (ftnlen)2, (
	    ftnlen)255, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_clf__(cks + ((i__1 = ckno - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge("cks", 
	    i__1, "f_ckbsr__", (ftnlen)524)) * 255, &hndles[(i__2 = ckno - 1) 
	    < 15 && 0 <= i__2 ? i__2 : s_rnge("hndles", i__2, "f_ckbsr__", (
	    ftnlen)524)], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    ckno = 1;
    segno = 1;
    tbegs[(i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("tbegs", i__1,
	     "f_ckbsr__", (ftnlen)530)] = (doublereal) (ckno * 10000 + segno 
	    - 1);
    tends[(i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("tends", i__1,
	     "f_ckbsr__", (ftnlen)531)] = (doublereal) (ckno * 10000 + segno);
    d__1 = tbegs[(i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("tbegs"
	    , i__1, "f_ckbsr__", (ftnlen)533)] + .5;
    t_cbs__(&inst, &d__1, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     In this case, the segment should be found.  Make sure we get */
/*     back the right handle and segment identifier. */

    s_copy(xsegid + ((i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_ckbsr__", (ftnlen)542)) * 40, "File: # Segno:"
	    " #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid + ((i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_ckbsr__", (ftnlen)543)) * 40, "#", cks + ((
	    i__2 = ckno - 1) < 15 && 0 <= i__2 ? i__2 : s_rnge("cks", i__2, 
	    "f_ckbsr__", (ftnlen)543)) * 255, xsegid + ((i__3 = segno - 1) < 
	    400 && 0 <= i__3 ? i__3 : s_rnge("xsegid", i__3, "f_ckbsr__", (
	    ftnlen)543)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40)
	    ;
    repmi_(xsegid + ((i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_ckbsr__", (ftnlen)544)) * 40, "#", &c__1, 
	    xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_ckbsr__", (ftnlen)544)) * 40, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = ckno - 1) < 15 && 0 <= 
	    i__1 ? i__1 : s_rnge("hndles", i__1, "f_ckbsr__", (ftnlen)548)], &
	    c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + ((i__1 = segno - 1) < 400 && 0 <= 
	    i__1 ? i__1 : s_rnge("xsegid", i__1, "f_ckbsr__", (ftnlen)549)) * 
	    40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (ftnlen)40);

/*     Check the descriptor as well.  However, don't check the */
/*     segment addresses. */

    t_crckds__(&segno, &inst, &tbegs[(i__1 = segno - 1) < 400 && 0 <= i__1 ? 
	    i__1 : s_rnge("tbegs", i__1, "f_ckbsr__", (ftnlen)555)], &tends[(
	    i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tends", 
	    i__2, "f_ckbsr__", (ftnlen)555)], &xdescr[(i__3 = segno * 5 - 5) <
	     2000 && 0 <= i__3 ? i__3 : s_rnge("xdescr", i__3, "f_ckbsr__", (
	    ftnlen)555)], &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[(i__1 = segno * 5 - 5) < 2000 && 0 
	    <= i__1 ? i__1 : s_rnge("xdescr", i__1, "f_ckbsr__", (ftnlen)559)]
	    , &c__4, &c_b15, ok, (ftnlen)5, (ftnlen)1);
    tcase_("Start a segment list for instrument 1 by making a request that i"
	    "s satisfied by CK 1.  Then build a file (CK 6) with too many seg"
	    "ments for instrument 1 to be buffered.  Make a request that is s"
	    "atisfied by CK 6. This tests the logic for searching the subset "
	    "of a segment list that must be dumped due to lack of room.", (
	    ftnlen)314);

/*     Set up by making a request that will be satisfied by the segment */
/*     in CK 1.  This builds up the segment list for instrument 1. */

    inst = 1;
    tbegs[0] = 1e4;
    tends[0] = 10001.;
    ckno = 1;
    segno = 1;
    s_copy(xsegid, "File: # Segno: #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid, "#", cks, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)255, (
	    ftnlen)40);
    repmi_(xsegid, "#", &segno, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    d__1 = tbegs[(i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("tbegs"
	    , i__1, "f_ckbsr__", (ftnlen)588)] + .5;
    t_cbs__(&inst, &d__1, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Go ahead and make the new file. */

    inst = 1;
    ckno = 6;
    i__2 = nseg[(i__1 = ckno - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge("nseg", 
	    i__1, "f_ckbsr__", (ftnlen)599)];
    for (i__ = 1; i__ <= i__2; ++i__) {
	ids[(i__1 = i__ - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("ids", i__1, 
		"f_ckbsr__", (ftnlen)601)] = inst;
	if (i__ == 10 || i__ == 101) {

/*           We want the lower bound of the re-use interval to */
/*           match the right endpoint of the segment's coverage */
/*           interval. */

	    tbegs[(i__1 = i__ - 2) < 400 && 0 <= i__1 ? i__1 : s_rnge("tbegs",
		     i__1, "f_ckbsr__", (ftnlen)609)] = (doublereal) (ckno * 
		    10000 + i__);
	    tends[(i__1 = i__ - 2) < 400 && 0 <= i__1 ? i__1 : s_rnge("tends",
		     i__1, "f_ckbsr__", (ftnlen)610)] = tbegs[(i__3 = i__ - 2)
		     < 400 && 0 <= i__3 ? i__3 : s_rnge("tbegs", i__3, "f_ck"
		    "bsr__", (ftnlen)610)] + 1.;
	    tbegs[(i__1 = i__ - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("tbegs",
		     i__1, "f_ckbsr__", (ftnlen)612)] = (doublereal) (ckno * 
		    10000 + i__ - 1);
	    tends[(i__1 = i__ - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("tends",
		     i__1, "f_ckbsr__", (ftnlen)613)] = tbegs[(i__3 = i__ - 1)
		     < 400 && 0 <= i__3 ? i__3 : s_rnge("tbegs", i__3, "f_ck"
		    "bsr__", (ftnlen)613)] + 1;
	    tbegs[(i__1 = i__) < 400 && 0 <= i__1 ? i__1 : s_rnge("tbegs", 
		    i__1, "f_ckbsr__", (ftnlen)615)] = tbegs[(i__3 = i__ - 1) 
		    < 400 && 0 <= i__3 ? i__3 : s_rnge("tbegs", i__3, "f_ckb"
		    "sr__", (ftnlen)615)];
	    tends[(i__1 = i__) < 400 && 0 <= i__1 ? i__1 : s_rnge("tends", 
		    i__1, "f_ckbsr__", (ftnlen)616)] = tends[(i__3 = i__ - 1) 
		    < 400 && 0 <= i__3 ? i__3 : s_rnge("tends", i__3, "f_ckb"
		    "sr__", (ftnlen)616)];
	    tbegs[(i__1 = i__ + 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("tbegs",
		     i__1, "f_ckbsr__", (ftnlen)618)] = tends[(i__3 = i__ - 1)
		     < 400 && 0 <= i__3 ? i__3 : s_rnge("tends", i__3, "f_ck"
		    "bsr__", (ftnlen)618)] + 1;
	    tends[(i__1 = i__ + 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("tends",
		     i__1, "f_ckbsr__", (ftnlen)619)] = tbegs[(i__3 = i__ + 1)
		     < 400 && 0 <= i__3 ? i__3 : s_rnge("tbegs", i__3, "f_ck"
		    "bsr__", (ftnlen)619)] + 1;
	} else if (i__ == 106) {

/*           Create a singleton segment. */

	    tbegs[(i__1 = i__ - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("tbegs",
		     i__1, "f_ckbsr__", (ftnlen)626)] = (doublereal) (ckno * 
		    10000 + i__ - 1);
	    tends[(i__1 = i__ - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("tends",
		     i__1, "f_ckbsr__", (ftnlen)627)] = tbegs[(i__3 = i__ - 1)
		     < 400 && 0 <= i__3 ? i__3 : s_rnge("tbegs", i__3, "f_ck"
		    "bsr__", (ftnlen)627)];
	} else if (i__ == 107) {

/*           Create an invisible segment. */

	    tbegs[(i__1 = i__ - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("tbegs",
		     i__1, "f_ckbsr__", (ftnlen)633)] = (doublereal) (ckno * 
		    10000 + i__ - 1);
	    tends[(i__1 = i__ - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("tends",
		     i__1, "f_ckbsr__", (ftnlen)634)] = tbegs[(i__3 = i__ - 1)
		     < 400 && 0 <= i__3 ? i__3 : s_rnge("tbegs", i__3, "f_ck"
		    "bsr__", (ftnlen)634)] - 1;
	} else if (i__ < 9 || i__ > 12 && i__ < 100 || i__ > 103) {
	    tbegs[(i__1 = i__ - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("tbegs",
		     i__1, "f_ckbsr__", (ftnlen)640)] = (doublereal) (ckno * 
		    10000 + i__ - 1);
	    tends[(i__1 = i__ - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("tends",
		     i__1, "f_ckbsr__", (ftnlen)641)] = tbegs[(i__3 = i__ - 1)
		     < 400 && 0 <= i__3 ? i__3 : s_rnge("tbegs", i__3, "f_ck"
		    "bsr__", (ftnlen)641)] + 1;
	}
	s_copy(xsegid + ((i__1 = i__ - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge(
		"xsegid", i__1, "f_ckbsr__", (ftnlen)645)) * 40, "File: # Se"
		"gno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid + ((i__1 = i__ - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge(
		"xsegid", i__1, "f_ckbsr__", (ftnlen)647)) * 40, "#", cks + ((
		i__3 = ckno - 1) < 15 && 0 <= i__3 ? i__3 : s_rnge("cks", 
		i__3, "f_ckbsr__", (ftnlen)647)) * 255, xsegid + ((i__4 = i__ 
		- 1) < 400 && 0 <= i__4 ? i__4 : s_rnge("xsegid", i__4, "f_c"
		"kbsr__", (ftnlen)647)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)
		255, (ftnlen)40);
	repmi_(xsegid + ((i__1 = i__ - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge(
		"xsegid", i__1, "f_ckbsr__", (ftnlen)648)) * 40, "#", &i__, 
		xsegid + ((i__3 = i__ - 1) < 400 && 0 <= i__3 ? i__3 : s_rnge(
		"xsegid", i__3, "f_ckbsr__", (ftnlen)648)) * 40, (ftnlen)40, (
		ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    t_crdaf__("CK", cks + ((i__2 = ckno - 1) < 15 && 0 <= i__2 ? i__2 : 
	    s_rnge("cks", i__2, "f_ckbsr__", (ftnlen)654)) * 255, &nseg[(i__1 
	    = ckno - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge("nseg", i__1, "f_c"
	    "kbsr__", (ftnlen)654)], ids, tbegs, tends, xsegid, (ftnlen)2, (
	    ftnlen)255, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_clf__(cks + ((i__2 = ckno - 1) < 15 && 0 <= i__2 ? i__2 : s_rnge("cks", 
	    i__2, "f_ckbsr__", (ftnlen)659)) * 255, &hndles[(i__1 = ckno - 1) 
	    < 15 && 0 <= i__1 ? i__1 : s_rnge("hndles", i__1, "f_ckbsr__", (
	    ftnlen)659)], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    segno = 1;
    d__1 = tbegs[(i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbegs"
	    , i__2, "f_ckbsr__", (ftnlen)664)] + .5;
    t_cbs__(&inst, &d__1, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     In this case, the segment should be found.  Make sure we get */
/*     back the right handle and segment identifier. */

    s_copy(xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_ckbsr__", (ftnlen)674)) * 40, "File: # Segno:"
	    " #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_ckbsr__", (ftnlen)675)) * 40, "#", cks + ((
	    i__1 = ckno - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge("cks", i__1, 
	    "f_ckbsr__", (ftnlen)675)) * 255, xsegid + ((i__3 = segno - 1) < 
	    400 && 0 <= i__3 ? i__3 : s_rnge("xsegid", i__3, "f_ckbsr__", (
	    ftnlen)675)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40)
	    ;
    repmi_(xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_ckbsr__", (ftnlen)676)) * 40, "#", &c__1, 
	    xsegid + ((i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_ckbsr__", (ftnlen)676)) * 40, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__2 = ckno - 1) < 15 && 0 <= 
	    i__2 ? i__2 : s_rnge("hndles", i__2, "f_ckbsr__", (ftnlen)680)], &
	    c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + ((i__2 = segno - 1) < 400 && 0 <= 
	    i__2 ? i__2 : s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)681)) * 
	    40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (ftnlen)40);

/*     Check the descriptor as well.  However, don't check the */
/*     segment addresses. */

    t_crckds__(&segno, &inst, &tbegs[(i__2 = segno - 1) < 400 && 0 <= i__2 ? 
	    i__2 : s_rnge("tbegs", i__2, "f_ckbsr__", (ftnlen)687)], &tends[(
	    i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("tends", 
	    i__1, "f_ckbsr__", (ftnlen)687)], &xdescr[(i__3 = segno * 5 - 5) <
	     2000 && 0 <= i__3 ? i__3 : s_rnge("xdescr", i__3, "f_ckbsr__", (
	    ftnlen)687)], &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[(i__2 = segno * 5 - 5) < 2000 && 0 
	    <= i__2 ? i__2 : s_rnge("xdescr", i__2, "f_ckbsr__", (ftnlen)691)]
	    , &c__4, &c_b15, ok, (ftnlen)5, (ftnlen)1);
    tcase_("Create a CK containing data for ITSIZE new instruments. Look up "
	    "data for each.", (ftnlen)78);

/*     Unload all CKs. */

    for (i__ = 1; i__ <= 15; ++i__) {
	t_cuf__(&hndles[(i__2 = i__ - 1) < 15 && 0 <= i__2 ? i__2 : s_rnge(
		"hndles", i__2, "f_ckbsr__", (ftnlen)707)]);
    }
    ckno = 7;
    i__1 = nseg[(i__2 = ckno - 1) < 15 && 0 <= i__2 ? i__2 : s_rnge("nseg", 
	    i__2, "f_ckbsr__", (ftnlen)712)];
    for (i__ = 1; i__ <= i__1; ++i__) {
	ids[(i__2 = i__ - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("ids", i__2, 
		"f_ckbsr__", (ftnlen)714)] = i__ + 20;
	tbegs[(i__2 = i__ - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbegs", 
		i__2, "f_ckbsr__", (ftnlen)716)] = (doublereal) (ckno * 10000 
		+ i__ - 1);
	tends[(i__2 = i__ - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tends", 
		i__2, "f_ckbsr__", (ftnlen)717)] = tbegs[(i__3 = i__ - 1) < 
		400 && 0 <= i__3 ? i__3 : s_rnge("tbegs", i__3, "f_ckbsr__", (
		ftnlen)717)] + 1;
	s_copy(xsegid + ((i__2 = i__ - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
		"xsegid", i__2, "f_ckbsr__", (ftnlen)719)) * 40, "File: # Se"
		"gno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid + ((i__2 = i__ - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
		"xsegid", i__2, "f_ckbsr__", (ftnlen)721)) * 40, "#", cks + ((
		i__3 = ckno - 1) < 15 && 0 <= i__3 ? i__3 : s_rnge("cks", 
		i__3, "f_ckbsr__", (ftnlen)721)) * 255, xsegid + ((i__4 = i__ 
		- 1) < 400 && 0 <= i__4 ? i__4 : s_rnge("xsegid", i__4, "f_c"
		"kbsr__", (ftnlen)721)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)
		255, (ftnlen)40);
	repmi_(xsegid + ((i__2 = i__ - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
		"xsegid", i__2, "f_ckbsr__", (ftnlen)722)) * 40, "#", &i__, 
		xsegid + ((i__3 = i__ - 1) < 400 && 0 <= i__3 ? i__3 : s_rnge(
		"xsegid", i__3, "f_ckbsr__", (ftnlen)722)) * 40, (ftnlen)40, (
		ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    t_crdaf__("CK", cks + ((i__1 = ckno - 1) < 15 && 0 <= i__1 ? i__1 : 
	    s_rnge("cks", i__1, "f_ckbsr__", (ftnlen)727)) * 255, &nseg[(i__2 
	    = ckno - 1) < 15 && 0 <= i__2 ? i__2 : s_rnge("nseg", i__2, "f_c"
	    "kbsr__", (ftnlen)727)], ids, tbegs, tends, xsegid, (ftnlen)2, (
	    ftnlen)255, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_clf__(cks + ((i__1 = ckno - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge("cks", 
	    i__1, "f_ckbsr__", (ftnlen)732)) * 255, &hndles[(i__2 = ckno - 1) 
	    < 15 && 0 <= i__2 ? i__2 : s_rnge("hndles", i__2, "f_ckbsr__", (
	    ftnlen)732)], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    i__2 = nseg[(i__1 = ckno - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge("nseg", 
	    i__1, "f_ckbsr__", (ftnlen)736)];
    for (i__ = 1; i__ <= i__2; ++i__) {
	inst = ids[(i__1 = i__ - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("ids", 
		i__1, "f_ckbsr__", (ftnlen)738)];
	segno = i__;
	d__1 = tbegs[(i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge(
		"tbegs", i__1, "f_ckbsr__", (ftnlen)741)] + .5;
	t_cbs__(&inst, &d__1, &c_b15, &c_true);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	t_csn__(&handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        In this case, the segment should be found.  Make sure we get */
/*        back the right handle and segment identifier. */

	s_copy(xsegid + ((i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_ckbsr__", (ftnlen)750)) * 40, "Fil"
		"e: # Segno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid + ((i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_ckbsr__", (ftnlen)751)) * 40, "#", 
		cks + ((i__3 = ckno - 1) < 15 && 0 <= i__3 ? i__3 : s_rnge(
		"cks", i__3, "f_ckbsr__", (ftnlen)751)) * 255, xsegid + ((
		i__4 = segno - 1) < 400 && 0 <= i__4 ? i__4 : s_rnge("xsegid",
		 i__4, "f_ckbsr__", (ftnlen)751)) * 40, (ftnlen)40, (ftnlen)1,
		 (ftnlen)255, (ftnlen)40);
	repmi_(xsegid + ((i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_ckbsr__", (ftnlen)752)) * 40, "#", &
		segno, xsegid + ((i__3 = segno - 1) < 400 && 0 <= i__3 ? i__3 
		: s_rnge("xsegid", i__3, "f_ckbsr__", (ftnlen)752)) * 40, (
		ftnlen)40, (ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = ckno - 1) < 15 && 0 <=
		 i__1 ? i__1 : s_rnge("hndles", i__1, "f_ckbsr__", (ftnlen)
		756)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	chcksc_("SEGID", segid, "=", xsegid + ((i__1 = segno - 1) < 400 && 0 
		<= i__1 ? i__1 : s_rnge("xsegid", i__1, "f_ckbsr__", (ftnlen)
		757)) * 40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (ftnlen)40);

/*        Check the descriptor as well.  However, don't check the */
/*        segment addresses. */

	t_crckds__(&segno, &inst, &tbegs[(i__1 = segno - 1) < 400 && 0 <= 
		i__1 ? i__1 : s_rnge("tbegs", i__1, "f_ckbsr__", (ftnlen)763)]
		, &tends[(i__3 = segno - 1) < 400 && 0 <= i__3 ? i__3 : 
		s_rnge("tends", i__3, "f_ckbsr__", (ftnlen)763)], &xdescr[(
		i__4 = segno * 5 - 5) < 2000 && 0 <= i__4 ? i__4 : s_rnge(
		"xdescr", i__4, "f_ckbsr__", (ftnlen)763)], &c_true);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	t_chds__("DESCR", descr, "=", &xdescr[(i__1 = segno * 5 - 5) < 2000 &&
		 0 <= i__1 ? i__1 : s_rnge("xdescr", i__1, "f_ckbsr__", (
		ftnlen)767)], &c__4, &c_b15, ok, (ftnlen)5, (ftnlen)1);
    }
    tcase_("The instrument table should be full now; the segment table shoul"
	    "d have room.  Cause an instrument list to be dumped to make room"
	    " in the instrument table.", (ftnlen)153);

/*     Create a list for instrument 1 more expensive than those for the */
/*     instruments in CK 7.  Instrument 1's list will be placed at the */
/*     head of the instrument table. */

    inst = 1;
    ckno = 2;
    segno = nseg[(i__2 = ckno - 1) < 15 && 0 <= i__2 ? i__2 : s_rnge("nseg", 
	    i__2, "f_ckbsr__", (ftnlen)788)];
    i__ = segno;
    tbegs[(i__2 = i__ - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbegs", i__2, 
	    "f_ckbsr__", (ftnlen)790)] = (doublereal) (ckno * 10000 + i__ - 1)
	    ;
    tends[(i__2 = i__ - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tends", i__2, 
	    "f_ckbsr__", (ftnlen)791)] = tbegs[(i__1 = i__ - 1) < 400 && 0 <= 
	    i__1 ? i__1 : s_rnge("tbegs", i__1, "f_ckbsr__", (ftnlen)791)] + 
	    1;
    s_copy(xsegid, "File: # Segno: #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid, "#", cks + ((i__2 = ckno - 1) < 15 && 0 <= i__2 ? i__2 : 
	    s_rnge("cks", i__2, "f_ckbsr__", (ftnlen)794)) * 255, xsegid, (
	    ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
    repmi_(xsegid, "#", &segno, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_clf__(cks + 255, &hndles[1], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    d__1 = tbegs[(i__2 = i__ - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbegs", 
	    i__2, "f_ckbsr__", (ftnlen)801)] + .5;
    t_cbs__(&inst, &d__1, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     In this case, the segment should be found.  Make sure we get */
/*     back the right handle and segment identifier. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__2 = ckno - 1) < 15 && 0 <= 
	    i__2 ? i__2 : s_rnge("hndles", i__2, "f_ckbsr__", (ftnlen)811)], &
	    c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1,
	     (ftnlen)40);

/*     Check the descriptor as well.  However, don't check the */
/*     segment addresses. */

    t_crckds__(&segno, &inst, &tbegs[(i__2 = i__ - 1) < 400 && 0 <= i__2 ? 
	    i__2 : s_rnge("tbegs", i__2, "f_ckbsr__", (ftnlen)818)], &tends[(
	    i__1 = i__ - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("tends", i__1, 
	    "f_ckbsr__", (ftnlen)818)], xdescr, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_chds__("DESCR", descr, "=", xdescr, &c__4, &c_b15, ok, (ftnlen)5, (
	    ftnlen)1);

/*     Now do a look up for instrument 2.  This will require dumping */
/*     lists from CK 7. */

    inst = 2;
    ckno = 2;
    segno = 1;
    i__ = segno;
    tbegs[(i__2 = i__ - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbegs", i__2, 
	    "f_ckbsr__", (ftnlen)833)] = (doublereal) (ckno * 10000 + i__ - 1)
	    ;
    tends[(i__2 = i__ - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tends", i__2, 
	    "f_ckbsr__", (ftnlen)834)] = tbegs[(i__1 = i__ - 1) < 400 && 0 <= 
	    i__1 ? i__1 : s_rnge("tbegs", i__1, "f_ckbsr__", (ftnlen)834)] + 
	    1;
    s_copy(xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_ckbsr__", (ftnlen)837)) * 40, "File: # Segno:"
	    " #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_ckbsr__", (ftnlen)838)) * 40, "#", cks + ((
	    i__1 = ckno - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge("cks", i__1, 
	    "f_ckbsr__", (ftnlen)838)) * 255, xsegid + ((i__3 = segno - 1) < 
	    400 && 0 <= i__3 ? i__3 : s_rnge("xsegid", i__3, "f_ckbsr__", (
	    ftnlen)838)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40)
	    ;
    repmi_(xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_ckbsr__", (ftnlen)839)) * 40, "#", &segno, 
	    xsegid + ((i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_ckbsr__", (ftnlen)839)) * 40, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    d__1 = tbegs[(i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbegs"
	    , i__2, "f_ckbsr__", (ftnlen)842)] + .5;
    t_cbs__(&inst, &d__1, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     In this case, the segment should be found.  Make sure we get */
/*     back the right handle and segment identifier. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__2 = ckno - 1) < 15 && 0 <= 
	    i__2 ? i__2 : s_rnge("hndles", i__2, "f_ckbsr__", (ftnlen)852)], &
	    c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + ((i__2 = segno - 1) < 400 && 0 <= 
	    i__2 ? i__2 : s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)853)) * 
	    40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (ftnlen)40);

/*     Check the descriptor as well.  However, don't check the */
/*     segment addresses. */

    t_crckds__(&c__1, &inst, tbegs, tends, xdescr, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_chds__("DESCR", descr, "=", xdescr, &c__4, &c_b15, ok, (ftnlen)5, (
	    ftnlen)1);
    tcase_("Look up data from a representative subset of the segments in CK "
	    "6.", (ftnlen)66);
    ckno = 6;
    t_clf__(cks + ((i__2 = ckno - 1) < 15 && 0 <= i__2 ? i__2 : s_rnge("cks", 
	    i__2, "f_ckbsr__", (ftnlen)872)) * 255, &hndles[(i__1 = ckno - 1) 
	    < 15 && 0 <= i__1 ? i__1 : s_rnge("hndles", i__1, "f_ckbsr__", (
	    ftnlen)872)], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    i__1 = nseg[(i__2 = ckno - 1) < 15 && 0 <= i__2 ? i__2 : s_rnge("nseg", 
	    i__2, "f_ckbsr__", (ftnlen)876)];
    for (i__ = 1; i__ <= i__1; ++i__) {
	ids[(i__2 = i__ - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("ids", i__2, 
		"f_ckbsr__", (ftnlen)878)] = inst;
	if (i__ == 10 || i__ == 101) {

/*           We want the lower bound of the re-use interval to */
/*           match the right endpoint of the segment's coverage */
/*           interval. */

	    tbegs[(i__2 = i__ - 2) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbegs",
		     i__2, "f_ckbsr__", (ftnlen)886)] = (doublereal) (ckno * 
		    10000 + i__);
	    tends[(i__2 = i__ - 2) < 400 && 0 <= i__2 ? i__2 : s_rnge("tends",
		     i__2, "f_ckbsr__", (ftnlen)887)] = tbegs[(i__3 = i__ - 2)
		     < 400 && 0 <= i__3 ? i__3 : s_rnge("tbegs", i__3, "f_ck"
		    "bsr__", (ftnlen)887)] + 1.;
	    tbegs[(i__2 = i__ - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbegs",
		     i__2, "f_ckbsr__", (ftnlen)889)] = (doublereal) (ckno * 
		    10000 + i__ - 1);
	    tends[(i__2 = i__ - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tends",
		     i__2, "f_ckbsr__", (ftnlen)890)] = tbegs[(i__3 = i__ - 1)
		     < 400 && 0 <= i__3 ? i__3 : s_rnge("tbegs", i__3, "f_ck"
		    "bsr__", (ftnlen)890)] + 1;
	    tbegs[(i__2 = i__) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbegs", 
		    i__2, "f_ckbsr__", (ftnlen)892)] = tbegs[(i__3 = i__ - 1) 
		    < 400 && 0 <= i__3 ? i__3 : s_rnge("tbegs", i__3, "f_ckb"
		    "sr__", (ftnlen)892)];
	    tends[(i__2 = i__) < 400 && 0 <= i__2 ? i__2 : s_rnge("tends", 
		    i__2, "f_ckbsr__", (ftnlen)893)] = tends[(i__3 = i__ - 1) 
		    < 400 && 0 <= i__3 ? i__3 : s_rnge("tends", i__3, "f_ckb"
		    "sr__", (ftnlen)893)];
	    tbegs[(i__2 = i__ + 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbegs",
		     i__2, "f_ckbsr__", (ftnlen)895)] = tends[(i__3 = i__ - 1)
		     < 400 && 0 <= i__3 ? i__3 : s_rnge("tends", i__3, "f_ck"
		    "bsr__", (ftnlen)895)] + 1;
	    tends[(i__2 = i__ + 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tends",
		     i__2, "f_ckbsr__", (ftnlen)896)] = tbegs[(i__3 = i__ + 1)
		     < 400 && 0 <= i__3 ? i__3 : s_rnge("tbegs", i__3, "f_ck"
		    "bsr__", (ftnlen)896)] + 1;
	} else if (i__ == 106) {

/*           Create a singleton segment. */

	    tbegs[(i__2 = i__ - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbegs",
		     i__2, "f_ckbsr__", (ftnlen)902)] = (doublereal) (ckno * 
		    10000 + i__ - 1);
	    tends[(i__2 = i__ - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tends",
		     i__2, "f_ckbsr__", (ftnlen)903)] = tbegs[(i__3 = i__ - 1)
		     < 400 && 0 <= i__3 ? i__3 : s_rnge("tbegs", i__3, "f_ck"
		    "bsr__", (ftnlen)903)];
	} else if (i__ == 107) {

/*           Create an invisible segment. */

	    tbegs[(i__2 = i__ - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbegs",
		     i__2, "f_ckbsr__", (ftnlen)909)] = (doublereal) (ckno * 
		    10000 + i__ - 1);
	    tends[(i__2 = i__ - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tends",
		     i__2, "f_ckbsr__", (ftnlen)910)] = tbegs[(i__3 = i__ - 1)
		     < 400 && 0 <= i__3 ? i__3 : s_rnge("tbegs", i__3, "f_ck"
		    "bsr__", (ftnlen)910)] - 1;
	} else if (i__ < 10 || i__ > 12 && i__ < 100 || i__ > 103) {
	    tbegs[(i__2 = i__ - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbegs",
		     i__2, "f_ckbsr__", (ftnlen)916)] = (doublereal) (ckno * 
		    10000 + i__ - 1);
	    tends[(i__2 = i__ - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tends",
		     i__2, "f_ckbsr__", (ftnlen)917)] = tbegs[(i__3 = i__ - 1)
		     < 400 && 0 <= i__3 ? i__3 : s_rnge("tbegs", i__3, "f_ck"
		    "bsr__", (ftnlen)917)] + 1;
	}
	s_copy(xsegid + ((i__2 = i__ - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
		"xsegid", i__2, "f_ckbsr__", (ftnlen)921)) * 40, "File: # Se"
		"gno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid + ((i__2 = i__ - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
		"xsegid", i__2, "f_ckbsr__", (ftnlen)923)) * 40, "#", cks + ((
		i__3 = ckno - 1) < 15 && 0 <= i__3 ? i__3 : s_rnge("cks", 
		i__3, "f_ckbsr__", (ftnlen)923)) * 255, xsegid + ((i__4 = i__ 
		- 1) < 400 && 0 <= i__4 ? i__4 : s_rnge("xsegid", i__4, "f_c"
		"kbsr__", (ftnlen)923)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)
		255, (ftnlen)40);
	repmi_(xsegid + ((i__2 = i__ - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
		"xsegid", i__2, "f_ckbsr__", (ftnlen)924)) * 40, "#", &i__, 
		xsegid + ((i__3 = i__ - 1) < 400 && 0 <= i__3 ? i__3 : s_rnge(
		"xsegid", i__3, "f_ckbsr__", (ftnlen)924)) * 40, (ftnlen)40, (
		ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    i__ = 1;
    while(i__ <= nseg[(i__1 = ckno - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge(
	    "nseg", i__1, "f_ckbsr__", (ftnlen)932)]) {
	inst = 1;
	segno = i__;
	d__1 = tbegs[(i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge(
		"tbegs", i__1, "f_ckbsr__", (ftnlen)937)] + .5;
	t_cbs__(&inst, &d__1, &c_b15, &c_true);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	t_csn__(&handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        In this case, the segment should be found.  Make sure we get */
/*        back the right handle and segment identifier. */

	s_copy(xsegid + ((i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_ckbsr__", (ftnlen)946)) * 40, "Fil"
		"e: # Segno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid + ((i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_ckbsr__", (ftnlen)947)) * 40, "#", 
		cks + ((i__2 = ckno - 1) < 15 && 0 <= i__2 ? i__2 : s_rnge(
		"cks", i__2, "f_ckbsr__", (ftnlen)947)) * 255, xsegid + ((
		i__3 = segno - 1) < 400 && 0 <= i__3 ? i__3 : s_rnge("xsegid",
		 i__3, "f_ckbsr__", (ftnlen)947)) * 40, (ftnlen)40, (ftnlen)1,
		 (ftnlen)255, (ftnlen)40);
	repmi_(xsegid + ((i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_ckbsr__", (ftnlen)948)) * 40, "#", &
		segno, xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 
		: s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)948)) * 40, (
		ftnlen)40, (ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = ckno - 1) < 15 && 0 <=
		 i__1 ? i__1 : s_rnge("hndles", i__1, "f_ckbsr__", (ftnlen)
		952)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	chcksc_("SEGID", segid, "=", xsegid + ((i__1 = segno - 1) < 400 && 0 
		<= i__1 ? i__1 : s_rnge("xsegid", i__1, "f_ckbsr__", (ftnlen)
		953)) * 40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (ftnlen)40);

/*        Check the descriptor as well.  However, don't check the */
/*        segment addresses. */

	t_crckds__(&segno, &inst, &tbegs[(i__1 = segno - 1) < 400 && 0 <= 
		i__1 ? i__1 : s_rnge("tbegs", i__1, "f_ckbsr__", (ftnlen)959)]
		, &tends[(i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : 
		s_rnge("tends", i__2, "f_ckbsr__", (ftnlen)959)], &xdescr[(
		i__3 = segno * 5 - 5) < 2000 && 0 <= i__3 ? i__3 : s_rnge(
		"xdescr", i__3, "f_ckbsr__", (ftnlen)959)], &c_true);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	t_chds__("DESCR", descr, "=", &xdescr[(i__1 = segno * 5 - 5) < 2000 &&
		 0 <= i__1 ? i__1 : s_rnge("xdescr", i__1, "f_ckbsr__", (
		ftnlen)963)], &c__4, &c_b15, ok, (ftnlen)5, (ftnlen)1);

/*        Skip some tests that are unlikely to reveal bugs, as well as */
/*        those which would give anomalous results due to the structure */
/*        of CK 6. */

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
    ckno = 6;
    inst = 1;
    t = tends[(i__2 = nseg[(i__1 = ckno - 1) < 15 && 0 <= i__1 ? i__1 : 
	    s_rnge("nseg", i__1, "f_ckbsr__", (ftnlen)992)] - 1) < 400 && 0 <=
	     i__2 ? i__2 : s_rnge("tends", i__2, "f_ckbsr__", (ftnlen)992)] * 
	    2;
    t_cbs__(&inst, &t, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);

/*     Return on entry in RETURN mode, if the error status is set. */

    tcase_("Make sure all T_CBR entry points return on entry when RETURN() i"
	    "s .TRUE.", (ftnlen)72);

/*     Depending on whether we're calling a version of T_CBR that does */
/*     coverage checking, the error status may be reset. */
    s_copy(smsg, "Return on entry", (ftnlen)25, (ftnlen)15);
    sigerr_(smsg, (ftnlen)25);
    t_cbr__(" ", &c__1, &c__1, &c_b15, &c_b15, &c_false, descr, segid, &found,
	     (ftnlen)1, (ftnlen)40);
    if (return_()) {
	chckxc_(&c_true, smsg, ok, (ftnlen)25);
    } else {
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    sigerr_(smsg, (ftnlen)25);
    t_clf__(" ", &handle, (ftnlen)1);
    if (return_()) {
	chckxc_(&c_true, smsg, ok, (ftnlen)25);
    } else {
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    sigerr_(smsg, (ftnlen)25);
    t_cuf__(&handle);
    if (return_()) {
	chckxc_(&c_true, smsg, ok, (ftnlen)25);
    } else {
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    sigerr_(smsg, (ftnlen)25);
    t_cbs__(&c__1, &c_b15, &c_b15, &c_true);
    if (return_()) {
	chckxc_(&c_true, smsg, ok, (ftnlen)25);
    } else {
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    sigerr_(smsg, (ftnlen)25);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    if (return_()) {
	chckxc_(&c_true, smsg, ok, (ftnlen)25);
    } else {
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    tcase_("Make sure an error is signaled if T_CBR is called directly and R"
	    "ETURN() is .FALSE.", (ftnlen)82);
    t_cbr__(" ", &c__1, &c__1, &c_b15, &c_b15, &c_false, descr, segid, &found,
	     (ftnlen)1, (ftnlen)40);
    chckxc_(&c_true, "SPICE(CKBOGUSENTRY)", ok, (ftnlen)19);

/*     Unload the CK files. */

    for (i__ = 1; i__ <= 15; ++i__) {
	t_cuf__(&hndles[(i__1 = i__ - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge(
		"hndles", i__1, "f_ckbsr__", (ftnlen)1084)]);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Make sure an error is signaled if no CKs are loaded. */

    tcase_("Make sure an error is signaled if no CKs are loaded.", (ftnlen)52)
	    ;
    t_cbs__(&c__1, &c_b15, &c_b15, &c_true);
    chckxc_(&c_true, "SPICE(NOLOADEDFILES)", ok, (ftnlen)20);

/*     Load CK1 and look up a state from it to create a cheap list. */
/*     Make the cheap list the second list by looking up data from */
/*     it after looking up data for instrument ITSIZE+1. */

    tcase_("Test removal of cheap list when adding a new instrument; cheap l"
	    "ist is 2nd.", (ftnlen)75);
    t_clf__(cks, hndles, (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Now load the CK containing 100 instruments.  Look up data for */
/*     each one.  The last one will cause the list for instrument 1 to */
/*     be dumped. */

    ckno = 7;
    t_clf__(cks + ((i__1 = ckno - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge("cks", 
	    i__1, "f_ckbsr__", (ftnlen)1114)) * 255, &hndles[(i__2 = ckno - 1)
	     < 15 && 0 <= i__2 ? i__2 : s_rnge("hndles", i__2, "f_ckbsr__", (
	    ftnlen)1114)], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    i__2 = nseg[(i__1 = ckno - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge("nseg", 
	    i__1, "f_ckbsr__", (ftnlen)1117)];
    for (i__ = 1; i__ <= i__2; ++i__) {
	ids[(i__1 = i__ - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("ids", i__1, 
		"f_ckbsr__", (ftnlen)1119)] = i__ + 20;
	tbegs[(i__1 = i__ - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("tbegs", 
		i__1, "f_ckbsr__", (ftnlen)1121)] = (doublereal) (ckno * 
		10000 + i__ - 1);
	tends[(i__1 = i__ - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("tends", 
		i__1, "f_ckbsr__", (ftnlen)1122)] = tbegs[(i__3 = i__ - 1) < 
		400 && 0 <= i__3 ? i__3 : s_rnge("tbegs", i__3, "f_ckbsr__", (
		ftnlen)1122)] + 1;
	s_copy(xsegid + ((i__1 = i__ - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge(
		"xsegid", i__1, "f_ckbsr__", (ftnlen)1124)) * 40, "File: # S"
		"egno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid + ((i__1 = i__ - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge(
		"xsegid", i__1, "f_ckbsr__", (ftnlen)1126)) * 40, "#", cks + (
		(i__3 = ckno - 1) < 15 && 0 <= i__3 ? i__3 : s_rnge("cks", 
		i__3, "f_ckbsr__", (ftnlen)1126)) * 255, xsegid + ((i__4 = 
		i__ - 1) < 400 && 0 <= i__4 ? i__4 : s_rnge("xsegid", i__4, 
		"f_ckbsr__", (ftnlen)1126)) * 40, (ftnlen)40, (ftnlen)1, (
		ftnlen)255, (ftnlen)40);
	repmi_(xsegid + ((i__1 = i__ - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge(
		"xsegid", i__1, "f_ckbsr__", (ftnlen)1127)) * 40, "#", &i__, 
		xsegid + ((i__3 = i__ - 1) < 400 && 0 <= i__3 ? i__3 : s_rnge(
		"xsegid", i__3, "f_ckbsr__", (ftnlen)1127)) * 40, (ftnlen)40, 
		(ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    i__1 = nseg[(i__2 = ckno - 1) < 15 && 0 <= i__2 ? i__2 : s_rnge("nseg", 
	    i__2, "f_ckbsr__", (ftnlen)1133)];
    for (i__ = 1; i__ <= i__1; ++i__) {
	inst = ids[(i__2 = i__ - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("ids", 
		i__2, "f_ckbsr__", (ftnlen)1135)];
	segno = i__;
	d__1 = tbegs[(i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
		"tbegs", i__2, "f_ckbsr__", (ftnlen)1138)] + .5;
	t_cbs__(&inst, &d__1, &c_b15, &c_true);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	t_csn__(&handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        In this case, the segment should be found.  Make sure we get */
/*        back the right handle and segment identifier. */

	s_copy(xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)1147)) * 40, 
		"File: # Segno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)1148)) * 40, 
		"#", cks + ((i__3 = ckno - 1) < 15 && 0 <= i__3 ? i__3 : 
		s_rnge("cks", i__3, "f_ckbsr__", (ftnlen)1148)) * 255, xsegid 
		+ ((i__4 = segno - 1) < 400 && 0 <= i__4 ? i__4 : s_rnge(
		"xsegid", i__4, "f_ckbsr__", (ftnlen)1148)) * 40, (ftnlen)40, 
		(ftnlen)1, (ftnlen)255, (ftnlen)40);
	repmi_(xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)1149)) * 40, 
		"#", &segno, xsegid + ((i__3 = segno - 1) < 400 && 0 <= i__3 ?
		 i__3 : s_rnge("xsegid", i__3, "f_ckbsr__", (ftnlen)1149)) * 
		40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	chcksi_("HANDLE", &handle, "=", &hndles[(i__2 = ckno - 1) < 15 && 0 <=
		 i__2 ? i__2 : s_rnge("hndles", i__2, "f_ckbsr__", (ftnlen)
		1153)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	chcksc_("SEGID", segid, "=", xsegid + ((i__2 = segno - 1) < 400 && 0 
		<= i__2 ? i__2 : s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)
		1154)) * 40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (ftnlen)40)
		;

/*        Check the descriptor as well.  However, don't check the */
/*        segment addresses. */

	t_crckds__(&segno, &inst, &tbegs[(i__2 = segno - 1) < 400 && 0 <= 
		i__2 ? i__2 : s_rnge("tbegs", i__2, "f_ckbsr__", (ftnlen)1160)
		], &tends[(i__3 = segno - 1) < 400 && 0 <= i__3 ? i__3 : 
		s_rnge("tends", i__3, "f_ckbsr__", (ftnlen)1160)], &xdescr[(
		i__4 = segno * 5 - 5) < 2000 && 0 <= i__4 ? i__4 : s_rnge(
		"xdescr", i__4, "f_ckbsr__", (ftnlen)1160)], &c_true);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	t_chds__("DESCR", descr, "=", &xdescr[(i__2 = segno * 5 - 5) < 2000 &&
		 0 <= i__2 ? i__2 : s_rnge("xdescr", i__2, "f_ckbsr__", (
		ftnlen)1164)], &c__4, &c_b15, ok, (ftnlen)5, (ftnlen)1);
	if (i__ == 1) {

/*           Create a cheap list for instrument 1. */

	    inst = 1;
	    t_clf__(cks + ((i__2 = ckno - 1) < 15 && 0 <= i__2 ? i__2 : 
		    s_rnge("cks", i__2, "f_ckbsr__", (ftnlen)1173)) * 255, &
		    hndles[(i__3 = ckno - 1) < 15 && 0 <= i__3 ? i__3 : 
		    s_rnge("hndles", i__3, "f_ckbsr__", (ftnlen)1173)], (
		    ftnlen)255);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    tbegs[0] = 1e4;
	    d__1 = tbegs[0] + .5;
	    t_cbs__(&inst, &d__1, &c_b15, &c_true);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	}
    }
    tcase_("Test ability to make room by deleting an instrument table entry "
	    "with an empty list.", (ftnlen)83);

/*     Create an example of the list in question by forcing a search */
/*     without buffering on instrument 1, where the highest priority file */
/*     contains too many segments to buffer.  However, we want this */
/*     list to have a high expense, so load a CK with many segments */
/*     for this instrument and search it first. */

    ckno = 6;
    t_clf__(cks + ((i__1 = ckno - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge("cks", 
	    i__1, "f_ckbsr__", (ftnlen)1198)) * 255, &hndles[(i__2 = ckno - 1)
	     < 15 && 0 <= i__2 ? i__2 : s_rnge("hndles", i__2, "f_ckbsr__", (
	    ftnlen)1198)], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    inst = 1;
    t = ckno * 10000 + 100 + .5;
    t_cbs__(&inst, &t, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Now look up data for the first NSEG-1 instruments in CK 7.  This */
/*     should fill up the instrument table. */

    ckno = 7;
    i__2 = nseg[(i__1 = ckno - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge("nseg", 
	    i__1, "f_ckbsr__", (ftnlen)1215)] - 1;
    for (i__ = 1; i__ <= i__2; ++i__) {
	ids[(i__1 = i__ - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("ids", i__1, 
		"f_ckbsr__", (ftnlen)1217)] = i__ + 20;
	tbegs[(i__1 = i__ - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("tbegs", 
		i__1, "f_ckbsr__", (ftnlen)1219)] = (doublereal) (ckno * 
		10000 + i__ - 1);
	tends[(i__1 = i__ - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("tends", 
		i__1, "f_ckbsr__", (ftnlen)1220)] = tbegs[(i__3 = i__ - 1) < 
		400 && 0 <= i__3 ? i__3 : s_rnge("tbegs", i__3, "f_ckbsr__", (
		ftnlen)1220)] + 1;
	inst = ids[(i__1 = i__ - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("ids", 
		i__1, "f_ckbsr__", (ftnlen)1222)];
	segno = i__;
	d__1 = tbegs[(i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge(
		"tbegs", i__1, "f_ckbsr__", (ftnlen)1225)] + .5;
	t_cbs__(&inst, &d__1, &c_b15, &c_true);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	t_csn__(&handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        In this case, the segment should be found.  Make sure we get */
/*        back the right handle and segment identifier. */

	s_copy(xsegid + ((i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_ckbsr__", (ftnlen)1234)) * 40, 
		"File: # Segno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid + ((i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_ckbsr__", (ftnlen)1235)) * 40, 
		"#", cks + ((i__3 = ckno - 1) < 15 && 0 <= i__3 ? i__3 : 
		s_rnge("cks", i__3, "f_ckbsr__", (ftnlen)1235)) * 255, xsegid 
		+ ((i__4 = segno - 1) < 400 && 0 <= i__4 ? i__4 : s_rnge(
		"xsegid", i__4, "f_ckbsr__", (ftnlen)1235)) * 40, (ftnlen)40, 
		(ftnlen)1, (ftnlen)255, (ftnlen)40);
	repmi_(xsegid + ((i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_ckbsr__", (ftnlen)1236)) * 40, 
		"#", &segno, xsegid + ((i__3 = segno - 1) < 400 && 0 <= i__3 ?
		 i__3 : s_rnge("xsegid", i__3, "f_ckbsr__", (ftnlen)1236)) * 
		40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = ckno - 1) < 15 && 0 <=
		 i__1 ? i__1 : s_rnge("hndles", i__1, "f_ckbsr__", (ftnlen)
		1240)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	chcksc_("SEGID", segid, "=", xsegid + ((i__1 = segno - 1) < 400 && 0 
		<= i__1 ? i__1 : s_rnge("xsegid", i__1, "f_ckbsr__", (ftnlen)
		1241)) * 40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (ftnlen)40)
		;

/*        Check the descriptor as well.  However, don't check the */
/*        segment addresses. */

	t_crckds__(&segno, &inst, &tbegs[(i__1 = segno - 1) < 400 && 0 <= 
		i__1 ? i__1 : s_rnge("tbegs", i__1, "f_ckbsr__", (ftnlen)1247)
		], &tends[(i__3 = segno - 1) < 400 && 0 <= i__3 ? i__3 : 
		s_rnge("tends", i__3, "f_ckbsr__", (ftnlen)1247)], &xdescr[(
		i__4 = segno * 5 - 5) < 2000 && 0 <= i__4 ? i__4 : s_rnge(
		"xdescr", i__4, "f_ckbsr__", (ftnlen)1247)], &c_true);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	t_chds__("DESCR", descr, "=", &xdescr[(i__1 = segno * 5 - 5) < 2000 &&
		 0 <= i__1 ? i__1 : s_rnge("xdescr", i__1, "f_ckbsr__", (
		ftnlen)1251)], &c__4, &c_b15, ok, (ftnlen)5, (ftnlen)1);
    }

/*     Try some cases where the re-use interval matches the selected */
/*     segment's coverage interval. */

    tcase_("Search w/o buffering case, selected segment is in dumped list, c"
	    "overage interval matches re-use interval, request time is in cen"
	    "ter of re-use interval.", (ftnlen)151);

/*     Set up the case by unloading the currently loaded CKs.  Load */
/*     CK 1 and look up a state from it.  Then load CK 6. */


/*     Unload the CK files. */

    for (i__ = 1; i__ <= 14; ++i__) {
	t_cuf__(&hndles[(i__2 = i__ - 1) < 15 && 0 <= i__2 ? i__2 : s_rnge(
		"hndles", i__2, "f_ckbsr__", (ftnlen)1275)]);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Load CK 1 and look up a state from this file. */

    t_clf__(cks, hndles, (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    inst = 1;
    tbegs[0] = 1e4;
    tends[0] = 10001.;
    ckno = 1;
    segno = 1;
    s_copy(xsegid, "File: # Segno: #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid, "#", cks, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)255, (
	    ftnlen)40);
    repmi_(xsegid, "#", &c__1, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    d__1 = tbegs[(i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbegs"
	    , i__2, "f_ckbsr__", (ftnlen)1296)] + .5;
    t_cbs__(&inst, &d__1, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
/*     Now load CK 6.  Look up a state from segment 9, where the */
/*     request time is to the right of a segment whose right endpoint */
/*     is at the left endpoint of the re-use interval. */

    t_clf__(cks + 1275, &hndles[5], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    ckno = 6;
    inst = 1;
    segno = 9;
    tbegs[(i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbegs", i__2,
	     "f_ckbsr__", (ftnlen)1314)] = (doublereal) (ckno * 10000 + segno 
	    + 1);
    tends[(i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tends", i__2,
	     "f_ckbsr__", (ftnlen)1315)] = tbegs[(i__1 = segno - 1) < 400 && 
	    0 <= i__1 ? i__1 : s_rnge("tbegs", i__1, "f_ckbsr__", (ftnlen)
	    1315)] + 1;
    t = tbegs[(i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbegs", 
	    i__2, "f_ckbsr__", (ftnlen)1317)] + .25;
    t_cbs__(&inst, &t, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     In this case, segment 9 should match. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    segno = 9;
    s_copy(xsegid, "File: # Segno: #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid, "#", cks + 1275, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)
	    255, (ftnlen)40);
    repmi_(xsegid, "#", &segno, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__2 = ckno - 1) < 15 && 0 <= 
	    i__2 ? i__2 : s_rnge("hndles", i__2, "f_ckbsr__", (ftnlen)1336)], 
	    &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1,
	     (ftnlen)40);

/*     Check the descriptor as well.  However, don't check the */
/*     segment addresses. */

    t_crckds__(&segno, &inst, &tbegs[(i__2 = segno - 1) < 400 && 0 <= i__2 ? 
	    i__2 : s_rnge("tbegs", i__2, "f_ckbsr__", (ftnlen)1343)], &tends[(
	    i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("tends", 
	    i__1, "f_ckbsr__", (ftnlen)1343)], &xdescr[(i__3 = segno * 5 - 5) 
	    < 2000 && 0 <= i__3 ? i__3 : s_rnge("xdescr", i__3, "f_ckbsr__", (
	    ftnlen)1343)], &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[(i__2 = segno * 5 - 5) < 2000 && 0 
	    <= i__2 ? i__2 : s_rnge("xdescr", i__2, "f_ckbsr__", (ftnlen)1347)
	    ], &c__4, &c_b15, ok, (ftnlen)5, (ftnlen)1);

/*     Create a situation where the segment list for instrument 1 */
/*     contributed by CK 6 gets dumped, and where the request is */
/*     satisfied by a segment in CK 1. */

    tcase_("Dump segment list from CK 6; find segment for instrument 1 in CK"
	    " 1.", (ftnlen)67);
    t_clf__(cks, hndles, (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_clf__(cks + 1275, &hndles[5], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    inst = 1;
    tbegs[0] = 1e4;
    tends[0] = 10001.;
    t = (tbegs[0] + tends[0]) * .5;
    t_cbs__(&inst, &t, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Check handle, segment descriptor and ID. */

    chcksi_("HANDLE", &handle, "=", hndles, &c__0, ok, (ftnlen)6, (ftnlen)1);
    t_crckds__(&c__1, &inst, tbegs, tends, xdescr, &c_true);
    t_chds__("DESCR", descr, "=", xdescr, &c__4, &c_b15, ok, (ftnlen)5, (
	    ftnlen)1);
    s_copy(xsegid, "File: # Segno: #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid, "#", cks, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)255, (
	    ftnlen)40);
    repmi_(xsegid, "#", &c__1, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1,
	     (ftnlen)40);
    tcase_("Dump segment list from CK 6.  While searching list for segment f"
	    "or instrument 1, make lower bound of re-use interval match lower"
	    " bound of segment descriptor.", (ftnlen)157);

/*     Make CK 1 higher priority than CK 6. */

    t_clf__(cks, hndles, (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Place request time in the "hole" between segments STSIZE+1 and */
/*     STSIZE+3. */

    i__ = 101;
    tbegs[(i__2 = i__ - 2) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbegs", i__2, 
	    "f_ckbsr__", (ftnlen)1417)] = (doublereal) (ckno * 10000 + i__);
    tends[(i__2 = i__ - 2) < 400 && 0 <= i__2 ? i__2 : s_rnge("tends", i__2, 
	    "f_ckbsr__", (ftnlen)1418)] = tbegs[(i__1 = i__ - 2) < 400 && 0 <=
	     i__1 ? i__1 : s_rnge("tbegs", i__1, "f_ckbsr__", (ftnlen)1418)] 
	    + 1.;
    tbegs[(i__2 = i__ - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbegs", i__2, 
	    "f_ckbsr__", (ftnlen)1420)] = (doublereal) (ckno * 10000 + i__ - 
	    1);
    tends[(i__2 = i__ - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tends", i__2, 
	    "f_ckbsr__", (ftnlen)1421)] = tbegs[(i__1 = i__ - 1) < 400 && 0 <=
	     i__1 ? i__1 : s_rnge("tbegs", i__1, "f_ckbsr__", (ftnlen)1421)] 
	    + 1;
    tbegs[(i__2 = i__) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbegs", i__2, 
	    "f_ckbsr__", (ftnlen)1423)] = tbegs[(i__1 = i__ - 1) < 400 && 0 <=
	     i__1 ? i__1 : s_rnge("tbegs", i__1, "f_ckbsr__", (ftnlen)1423)];
    tends[(i__2 = i__) < 400 && 0 <= i__2 ? i__2 : s_rnge("tends", i__2, 
	    "f_ckbsr__", (ftnlen)1424)] = tends[(i__1 = i__ - 1) < 400 && 0 <=
	     i__1 ? i__1 : s_rnge("tends", i__1, "f_ckbsr__", (ftnlen)1424)];
    tbegs[(i__2 = i__ + 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbegs", i__2, 
	    "f_ckbsr__", (ftnlen)1426)] = tends[(i__1 = i__ - 1) < 400 && 0 <=
	     i__1 ? i__1 : s_rnge("tends", i__1, "f_ckbsr__", (ftnlen)1426)] 
	    + 1;
    tends[(i__2 = i__ + 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tends", i__2, 
	    "f_ckbsr__", (ftnlen)1427)] = tbegs[(i__1 = i__ + 1) < 400 && 0 <=
	     i__1 ? i__1 : s_rnge("tbegs", i__1, "f_ckbsr__", (ftnlen)1427)] 
	    + 1;
    t = tbegs[(i__2 = i__ - 2) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbegs", 
	    i__2, "f_ckbsr__", (ftnlen)1429)] + .5;
    t_cbs__(&inst, &t, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     In this case, segment STSIZE should match. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    segno = 100;
    s_copy(xsegid, "File: # Segno: #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid, "#", cks + 1275, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)
	    255, (ftnlen)40);
    repmi_(xsegid, "#", &segno, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__2 = ckno - 1) < 15 && 0 <= 
	    i__2 ? i__2 : s_rnge("hndles", i__2, "f_ckbsr__", (ftnlen)1448)], 
	    &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1,
	     (ftnlen)40);

/*     Check the descriptor as well.  However, don't check the */
/*     segment addresses. */

    i__ = segno + 1;
    tbegs[(i__2 = i__ - 2) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbegs", i__2, 
	    "f_ckbsr__", (ftnlen)1456)] = (doublereal) (ckno * 10000 + i__);
    tends[(i__2 = i__ - 2) < 400 && 0 <= i__2 ? i__2 : s_rnge("tends", i__2, 
	    "f_ckbsr__", (ftnlen)1457)] = tbegs[(i__1 = i__ - 2) < 400 && 0 <=
	     i__1 ? i__1 : s_rnge("tbegs", i__1, "f_ckbsr__", (ftnlen)1457)] 
	    + 1.;
    t_crckds__(&segno, &inst, &tbegs[(i__2 = segno - 1) < 400 && 0 <= i__2 ? 
	    i__2 : s_rnge("tbegs", i__2, "f_ckbsr__", (ftnlen)1459)], &tends[(
	    i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("tends", 
	    i__1, "f_ckbsr__", (ftnlen)1459)], &xdescr[(i__3 = segno * 5 - 5) 
	    < 2000 && 0 <= i__3 ? i__3 : s_rnge("xdescr", i__3, "f_ckbsr__", (
	    ftnlen)1459)], &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[(i__2 = segno * 5 - 5) < 2000 && 0 
	    <= i__2 ? i__2 : s_rnge("xdescr", i__2, "f_ckbsr__", (ftnlen)1463)
	    ], &c__4, &c_b15, ok, (ftnlen)5, (ftnlen)1);

/*     Check correct handling of re-use intervals.  Create a new */
/*     CK file that contains coverage that exemplifies the various */
/*     masking possibilities that may occur. */

    tcase_("Check re-use for a 1-instrument segment list.", (ftnlen)45);
    ckno = 8;

/*     Segment 1: */

    inst = 1;
    ids[0] = inst;
    tbegs[0] = (doublereal) (ckno * 10000);
    tends[0] = tbegs[0] + 1.;

/*     Segments 2-3: */

    inst = 2;
    ids[1] = inst;
    ids[2] = inst;
    tbegs[2] = (doublereal) (ckno * 10000);
    tends[2] = tbegs[2] + 1.;
    tbegs[1] = tends[2] + 1.;
    tends[1] = tbegs[1] + 1.;

/*     Segments 4-6: */

    inst = 3;
    ids[3] = inst;
    ids[4] = inst;
    ids[5] = inst;
    tbegs[5] = (doublereal) (ckno * 10000);
    tends[5] = tbegs[5] + 3.;
    tbegs[4] = tends[5] - 1.;
    tends[4] = tbegs[4] + 3.;
    tbegs[3] = tbegs[4] + 1.;
    tends[3] = tends[4] - 1.;

/*     Segments 7-9: */

    inst = 4;
    ids[6] = inst;
    ids[7] = inst;
    ids[8] = inst;
    tbegs[8] = (doublereal) (ckno * 10000);
    tends[8] = tbegs[8] + 3.;
    tbegs[7] = tbegs[8];
    tends[7] = tends[8];
    tbegs[6] = tbegs[8] - 2.;
    tends[6] = tbegs[8] + 3.;

/*     Segments 10-12: */

    inst = 5;
    ids[9] = inst;
    ids[10] = inst;
    ids[11] = inst;
    tbegs[11] = (doublereal) (ckno * 10000);
    tends[11] = tbegs[11] + 3.;
    tbegs[10] = tbegs[11] - 2.;
    tends[10] = tbegs[10] + 3.;
    tbegs[9] = tbegs[10] - 2.;
    tends[9] = tends[11] + 1.;

/*     Segments 13-14: */

    inst = 6;
    ids[12] = inst;
    ids[13] = inst;

/*     Singleton segment: */

    tbegs[12] = (doublereal) (ckno * 10000);
    tends[12] = tbegs[12];

/*     Invisible segment: */

    tbegs[13] = tends[12] + 3.;
    tends[13] = tbegs[13] - 1.;

/*     Three more segments for instrument 4: */

    ids[14] = 4;
    ids[15] = 4;
    ids[16] = 4;
    tbegs[14] = ckno * 10000 + 10.;
    tends[14] = tbegs[14] + 3.;
    tbegs[15] = tbegs[14] + 1.;
    tends[15] = tends[14] - 1.;
    tbegs[16] = tbegs[15];
    tends[16] = tends[15];

/*     Three more segments for instrument 5: */

    inst = 5;
    ids[17] = inst;
    ids[18] = inst;
    ids[19] = inst;
    tbegs[19] = ckno * 10000 + 10.;
    tends[19] = tbegs[19] + 3.;
    tbegs[18] = tbegs[19] - 2.;
    tends[18] = tbegs[18] + 3.;
    tbegs[17] = tbegs[18] - 2.;
    tends[17] = tends[19] + 1.;

/*     Create a sequence of segments for instrument 6 with the */
/*     following topology: */


/*              +++++++           segment 21 */
/*                    +++++++             22 */
/*        +++++++                         23 */


    inst = 6;
    ids[20] = inst;
    ids[21] = inst;
    ids[22] = inst;
    tbegs[20] = ckno * 10000 + 10.;
    tends[20] = tbegs[20] + 3.;
    tbegs[21] = tends[20];
    tends[21] = tbegs[20] + 3.;
    tbegs[22] = tbegs[20] - 3.;
    tends[22] = tbegs[20];

/*     Create the ninth CK, which is just a copy of the 8th, except */
/*     for descriptors and segment IDs. */

    ckno = 9;
    i__2 = nseg[8];
    for (segno = 1; segno <= i__2; ++segno) {
	t_crckds__(&segno, &ids[(i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 :
		 s_rnge("ids", i__1, "f_ckbsr__", (ftnlen)1641)], &tbegs[(
		i__3 = segno - 1) < 400 && 0 <= i__3 ? i__3 : s_rnge("tbegs", 
		i__3, "f_ckbsr__", (ftnlen)1641)], &tends[(i__4 = segno - 1) <
		 400 && 0 <= i__4 ? i__4 : s_rnge("tends", i__4, "f_ckbsr__", 
		(ftnlen)1641)], &xdescr[(i__5 = segno * 5 - 5) < 2000 && 0 <= 
		i__5 ? i__5 : s_rnge("xdescr", i__5, "f_ckbsr__", (ftnlen)
		1641)], &c_true);
	s_copy(xsegid + ((i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_ckbsr__", (ftnlen)1645)) * 40, 
		"File: # Segno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid + ((i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_ckbsr__", (ftnlen)1646)) * 40, 
		"#", cks + ((i__3 = ckno - 1) < 15 && 0 <= i__3 ? i__3 : 
		s_rnge("cks", i__3, "f_ckbsr__", (ftnlen)1646)) * 255, xsegid 
		+ ((i__4 = segno - 1) < 400 && 0 <= i__4 ? i__4 : s_rnge(
		"xsegid", i__4, "f_ckbsr__", (ftnlen)1646)) * 40, (ftnlen)40, 
		(ftnlen)1, (ftnlen)255, (ftnlen)40);
	repmi_(xsegid + ((i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_ckbsr__", (ftnlen)1647)) * 40, 
		"#", &segno, xsegid + ((i__3 = segno - 1) < 400 && 0 <= i__3 ?
		 i__3 : s_rnge("xsegid", i__3, "f_ckbsr__", (ftnlen)1647)) * 
		40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    t_crdaf__("CK", cks + 2040, &nseg[8], ids, tbegs, tends, xsegid, (ftnlen)
	    2, (ftnlen)255, (ftnlen)40);

/*     Create the segment descriptors and segment identifiers for */
/*     this CK file. */

    ckno = 8;
    i__2 = nseg[7];
    for (segno = 1; segno <= i__2; ++segno) {
	t_crckds__(&segno, &ids[(i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 :
		 s_rnge("ids", i__1, "f_ckbsr__", (ftnlen)1665)], &tbegs[(
		i__3 = segno - 1) < 400 && 0 <= i__3 ? i__3 : s_rnge("tbegs", 
		i__3, "f_ckbsr__", (ftnlen)1665)], &tends[(i__4 = segno - 1) <
		 400 && 0 <= i__4 ? i__4 : s_rnge("tends", i__4, "f_ckbsr__", 
		(ftnlen)1665)], &xdescr[(i__5 = segno * 5 - 5) < 2000 && 0 <= 
		i__5 ? i__5 : s_rnge("xdescr", i__5, "f_ckbsr__", (ftnlen)
		1665)], &c_true);
	s_copy(xsegid + ((i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_ckbsr__", (ftnlen)1669)) * 40, 
		"File: # Segno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid + ((i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_ckbsr__", (ftnlen)1670)) * 40, 
		"#", cks + ((i__3 = ckno - 1) < 15 && 0 <= i__3 ? i__3 : 
		s_rnge("cks", i__3, "f_ckbsr__", (ftnlen)1670)) * 255, xsegid 
		+ ((i__4 = segno - 1) < 400 && 0 <= i__4 ? i__4 : s_rnge(
		"xsegid", i__4, "f_ckbsr__", (ftnlen)1670)) * 40, (ftnlen)40, 
		(ftnlen)1, (ftnlen)255, (ftnlen)40);
	repmi_(xsegid + ((i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : 
		s_rnge("xsegid", i__1, "f_ckbsr__", (ftnlen)1671)) * 40, 
		"#", &segno, xsegid + ((i__3 = segno - 1) < 400 && 0 <= i__3 ?
		 i__3 : s_rnge("xsegid", i__3, "f_ckbsr__", (ftnlen)1671)) * 
		40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Unload the other CK files.  Create and load the CK file. */


/*     Unload the CK files.  Again. */

    i__2 = ckno - 1;
    for (i__ = 1; i__ <= i__2; ++i__) {
	t_cuf__(&hndles[(i__1 = i__ - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge(
		"hndles", i__1, "f_ckbsr__", (ftnlen)1683)]);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    t_crdaf__("CK", cks + 1785, &nseg[7], ids, tbegs, tends, xsegid, (ftnlen)
	    2, (ftnlen)255, (ftnlen)40);
/*      CALL BYEBYE ( 'SUCCESS' ) */
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_clf__(cks + 1785, &hndles[7], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Time for tests. */


/*     Make sure we can re-use data from the first segment for */
/*     instrument 1. */

    ckno = 8;
    inst = ids[0];
    t = (tbegs[0] + tends[0]) * .5;
    for (i__ = 1; i__ <= 3; ++i__) {
	t_cbs__(&inst, &t, &c_b15, &c_true);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	t_csn__(&handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*        Check handle, segment descriptor and ID. */

	chcksi_("HANDLE", &handle, "=", &hndles[7], &c__0, ok, (ftnlen)6, (
		ftnlen)1);
	t_chds__("DESCR", descr, "=", xdescr, &c__4, &c_b15, ok, (ftnlen)5, (
		ftnlen)1);
	chcksc_("SEGID", segid, "=", xsegid, ok, (ftnlen)5, (ftnlen)40, (
		ftnlen)1, (ftnlen)40);
    }
    t = tbegs[0] - 1.;
    t_cbs__(&inst, &t, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    t = tends[0] + 1.;
    t_cbs__(&inst, &t, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    t = tbegs[0];
    t_cbs__(&inst, &t, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    t = tends[0];
    t_cbs__(&inst, &t, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Check out behavior for coverage consisting of two non-overlapping */
/*     segments.  The coverage topology is as follows: */


/*                      ++++++++++    segment 2 */
/*        +++++++++++                         3 */



    tcase_("Coverage is union of two disjoint intervals. Test re-use of each."
	    , (ftnlen)65);
    inst = ids[1];
    t = (tbegs[1] + tends[1]) * .5;
    for (i__ = 1; i__ <= 3; ++i__) {
	t_cbs__(&inst, &t, &c_b15, &c_true);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	t_csn__(&handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*        Check handle, segment descriptor and ID. */

	chcksi_("HANDLE", &handle, "=", &hndles[7], &c__0, ok, (ftnlen)6, (
		ftnlen)1);
	t_chds__("DESCR", descr, "=", &xdescr[5], &c__4, &c_b15, ok, (ftnlen)
		5, (ftnlen)1);
	chcksc_("SEGID", segid, "=", xsegid + 40, ok, (ftnlen)5, (ftnlen)40, (
		ftnlen)1, (ftnlen)40);
    }
    t = (tbegs[2] + tends[2]) * .5;
    for (i__ = 1; i__ <= 3; ++i__) {
	t_cbs__(&inst, &t, &c_b15, &c_true);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	t_csn__(&handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*        Check handle, segment descriptor and ID. */

	chcksi_("HANDLE", &handle, "=", &hndles[7], &c__0, ok, (ftnlen)6, (
		ftnlen)1);
	t_chds__("DESCR", descr, "=", &xdescr[10], &c__4, &c_b15, ok, (ftnlen)
		5, (ftnlen)1);
	chcksc_("SEGID", segid, "=", xsegid + 80, ok, (ftnlen)5, (ftnlen)40, (
		ftnlen)1, (ftnlen)40);
    }

/*     Hit the endpoints of the left interval. */

    t = tbegs[2];
    t_cbs__(&inst, &t, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Check handle, segment descriptor and ID. */

    chcksi_("HANDLE", &handle, "=", &hndles[7], &c__0, ok, (ftnlen)6, (ftnlen)
	    1);
    t_chds__("DESCR", descr, "=", &xdescr[10], &c__4, &c_b15, ok, (ftnlen)5, (
	    ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + 80, ok, (ftnlen)5, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);
    t = tends[2];
    t_cbs__(&inst, &t, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Check handle, segment descriptor and ID. */

    chcksi_("HANDLE", &handle, "=", &hndles[7], &c__0, ok, (ftnlen)6, (ftnlen)
	    1);
    t_chds__("DESCR", descr, "=", &xdescr[10], &c__4, &c_b15, ok, (ftnlen)5, (
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
    inst = ids[4];
    t = tends[5] + .25f;
    for (i__ = 1; i__ <= 3; ++i__) {
	t_cbs__(&inst, &t, &c_b15, &c_true);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	t_csn__(&handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*        Check handle, segment descriptor and ID. */

	chcksi_("HANDLE", &handle, "=", &hndles[7], &c__0, ok, (ftnlen)6, (
		ftnlen)1);
	t_chds__("DESCR", descr, "=", &xdescr[20], &c__4, &c_b15, ok, (ftnlen)
		5, (ftnlen)1);
	chcksc_("SEGID", segid, "=", xsegid + 160, ok, (ftnlen)5, (ftnlen)40, 
		(ftnlen)1, (ftnlen)40);
    }
    inst = ids[3];
    t = tbegs[5] + .25f;
    for (i__ = 1; i__ <= 3; ++i__) {
	t_cbs__(&inst, &t, &c_b15, &c_true);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	t_csn__(&handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*        Check handle, segment descriptor and ID. */

	chcksi_("HANDLE", &handle, "=", &hndles[7], &c__0, ok, (ftnlen)6, (
		ftnlen)1);
	t_chds__("DESCR", descr, "=", &xdescr[25], &c__4, &c_b15, ok, (ftnlen)
		5, (ftnlen)1);
	chcksc_("SEGID", segid, "=", xsegid + 200, ok, (ftnlen)5, (ftnlen)40, 
		(ftnlen)1, (ftnlen)40);
    }
    t = tbegs[4] + .25f;
    t_cbs__(&inst, &t, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    t = tbegs[5] - .25f;
    t_cbs__(&inst, &t, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
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
/*     the left endpoint of a descriptor, where T lies to the left */
/*     of the segment, in the CHECK LIST state: */

    inst = ids[6];
    t = tbegs[6] + .25f;
    t_cbs__(&inst, &t, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[7], &c__0, ok, (ftnlen)6, (ftnlen)
	    1);
    t_chds__("DESCR", descr, "=", &xdescr[30], &c__4, &c_b15, ok, (ftnlen)5, (
	    ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + 240, ok, (ftnlen)5, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);

/*     Check out behavior for coverage consisting of three segments */
/*     whose coverage is as shown: */


/*       ++++++++++++++++++        segment 10 */
/*           +++++++                       11 */
/*               ++++++++                  12 */


    tcase_("Three-segment overlapping case #2.", (ftnlen)34);
    inst = ids[9];
    t = tends[11] + .25f;
    for (i__ = 1; i__ <= 3; ++i__) {
	t_cbs__(&inst, &t, &c_b15, &c_true);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	t_csn__(&handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*        Check handle, segment descriptor and ID. */

	chcksi_("HANDLE", &handle, "=", &hndles[7], &c__0, ok, (ftnlen)6, (
		ftnlen)1);
	t_chds__("DESCR", descr, "=", &xdescr[45], &c__4, &c_b15, ok, (ftnlen)
		5, (ftnlen)1);
	chcksc_("SEGID", segid, "=", xsegid + 360, ok, (ftnlen)5, (ftnlen)40, 
		(ftnlen)1, (ftnlen)40);
    }
    t = tends[9] + 1.;
    t_cbs__(&inst, &t, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    t = tbegs[9] + .25f;
    for (i__ = 1; i__ <= 3; ++i__) {
	t_cbs__(&inst, &t, &c_b15, &c_true);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	t_csn__(&handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*        Check handle, segment descriptor and ID. */

	chcksi_("HANDLE", &handle, "=", &hndles[7], &c__0, ok, (ftnlen)6, (
		ftnlen)1);
	t_chds__("DESCR", descr, "=", &xdescr[45], &c__4, &c_b15, ok, (ftnlen)
		5, (ftnlen)1);
	chcksc_("SEGID", segid, "=", xsegid + 360, ok, (ftnlen)5, (ftnlen)40, 
		(ftnlen)1, (ftnlen)40);
    }
    t = tbegs[10] - .25f;
    t_cbs__(&inst, &t, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[7], &c__0, ok, (ftnlen)6, (ftnlen)
	    1);
    t_chds__("DESCR", descr, "=", &xdescr[45], &c__4, &c_b15, ok, (ftnlen)5, (
	    ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + 360, ok, (ftnlen)5, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);

/*     Check out behavior for coverage consisting of three segments */
/*     whose coverage is as shown: */


/*       ++++++++++++++++++        segment 15 */
/*            +++++++                      16 */
/*            +++++++                      17 */


    tcase_("T > segment uppper bound.  Lower bound of re-use interval = uppe"
	    "r bound of segment.", (ftnlen)83);
    inst = ids[14];
    t = tends[16] + .5;
    t_cbs__(&inst, &t, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Check handle, segment descriptor and ID. */

    chcksi_("HANDLE", &handle, "=", &hndles[7], &c__0, ok, (ftnlen)6, (ftnlen)
	    1);
    t_chds__("DESCR", descr, "=", &xdescr[70], &c__4, &c_b15, ok, (ftnlen)5, (
	    ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + 560, ok, (ftnlen)5, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);

/*     Check out behavior for coverage consisting of three segments */
/*     whose coverage is as shown: */


/*              +++++++           segment 21 */
/*                    +++++++             22 */
/*        +++++++                         23 */


    tcase_("T is in segment.  Lower bound of re-use interval = lower bound o"
	    "f segment.", (ftnlen)74);
    inst = 6;
    ids[20] = inst;
    ids[21] = inst;
    ids[22] = inst;
    tbegs[20] = ckno * 10000 + 10.;
    tends[20] = tbegs[20] + 3.;
    tbegs[21] = tends[20];
    tends[21] = tbegs[20] + 3.;
    tbegs[22] = tbegs[20] - 3.;
    tends[22] = tbegs[20];
    inst = ids[20];
    t = tbegs[20] + .5;
    t_cbs__(&inst, &t, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Check handle, segment descriptor and ID. */

    chcksi_("HANDLE", &handle, "=", &hndles[7], &c__0, ok, (ftnlen)6, (ftnlen)
	    1);
    t_chds__("DESCR", descr, "=", &xdescr[100], &c__4, &c_b15, ok, (ftnlen)5, 
	    (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + 800, ok, (ftnlen)5, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);

/*     Check out behavior for coverage consisting singleton and */
/*     invisible segments. */


    tcase_("Look up data from a singleton segment.", (ftnlen)38);
    t = tbegs[12];
    inst = ids[12];
    t_cbs__(&inst, &t, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[7], &c__0, ok, (ftnlen)6, (ftnlen)
	    1);
    t_chds__("DESCR", descr, "=", &xdescr[60], &c__4, &c_b15, ok, (ftnlen)5, (
	    ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + 480, ok, (ftnlen)5, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);

/*     Exercise the logic for handling singleton and invisible */
/*     segments during a NEW INST search. */

    tcase_("Look up data from a singleton segment, this time in a NEW SEGMEN"
	    "TS search.", (ftnlen)74);
    t_clf__(cks + 2040, &hndles[8], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    segno = 13;
    ckno = 9;
    t_crckds__(&segno, &ids[(i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : 
	    s_rnge("ids", i__2, "f_ckbsr__", (ftnlen)2230)], &tbegs[(i__1 = 
	    segno - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("tbegs", i__1, 
	    "f_ckbsr__", (ftnlen)2230)], &tends[(i__3 = segno - 1) < 400 && 0 
	    <= i__3 ? i__3 : s_rnge("tends", i__3, "f_ckbsr__", (ftnlen)2230)]
	    , &xdescr[(i__4 = segno * 5 - 5) < 2000 && 0 <= i__4 ? i__4 : 
	    s_rnge("xdescr", i__4, "f_ckbsr__", (ftnlen)2230)], &c_true);
    s_copy(xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_ckbsr__", (ftnlen)2234)) * 40, "File: # Segno"
	    ": #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_ckbsr__", (ftnlen)2235)) * 40, "#", cks + ((
	    i__1 = ckno - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge("cks", i__1, 
	    "f_ckbsr__", (ftnlen)2235)) * 255, xsegid + ((i__3 = segno - 1) < 
	    400 && 0 <= i__3 ? i__3 : s_rnge("xsegid", i__3, "f_ckbsr__", (
	    ftnlen)2235)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)
	    40);
    repmi_(xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_ckbsr__", (ftnlen)2236)) * 40, "#", &segno, 
	    xsegid + ((i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_ckbsr__", (ftnlen)2236)) * 40, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t = tbegs[12];
    inst = ids[12];
    t_cbs__(&inst, &t, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[8], &c__0, ok, (ftnlen)6, (ftnlen)
	    1);
    t_chds__("DESCR", descr, "=", &xdescr[60], &c__4, &c_b15, ok, (ftnlen)5, (
	    ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + 480, ok, (ftnlen)5, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);
    tcase_("Prepare for search w/o buffering tests: create a CK with STSIZE "
	    "segments for instruments 1-NINST.", (ftnlen)97);

/*     Create a CK file with STSIZE segments for instruments 1-NINST. */

    ckno = 10;
    for (inst = 1; inst <= 4; ++inst) {
	for (i__ = 1; i__ <= 100; ++i__) {
	    j = (inst - 1) * 100 + i__;
	    ids[(i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("ids", i__2,
		     "f_ckbsr__", (ftnlen)2275)] = inst;
	    if (inst == 4) {
		tbegs[(i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbe"
			"gs", i__2, "f_ckbsr__", (ftnlen)2278)] = (doublereal) 
			(ckno * 10000 - i__ - 1);
	    } else {
		tbegs[(i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbe"
			"gs", i__2, "f_ckbsr__", (ftnlen)2280)] = (doublereal) 
			(ckno * 10000 + i__ - 1);
	    }
	    tends[(i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tends", 
		    i__2, "f_ckbsr__", (ftnlen)2283)] = tbegs[(i__1 = j - 1) <
		     400 && 0 <= i__1 ? i__1 : s_rnge("tbegs", i__1, "f_ckbs"
		    "r__", (ftnlen)2283)] + 1;
	    s_copy(xsegid + ((i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : 
		    s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)2285)) * 40, 
		    "File: # Segno: #  Inst:  #", (ftnlen)40, (ftnlen)26);
	    repmc_(xsegid + ((i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : 
		    s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)2287)) * 40, 
		    "#", cks + ((i__1 = ckno - 1) < 15 && 0 <= i__1 ? i__1 : 
		    s_rnge("cks", i__1, "f_ckbsr__", (ftnlen)2287)) * 255, 
		    xsegid + ((i__3 = j - 1) < 400 && 0 <= i__3 ? i__3 : 
		    s_rnge("xsegid", i__3, "f_ckbsr__", (ftnlen)2287)) * 40, (
		    ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
	    repmi_(xsegid + ((i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : 
		    s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)2288)) * 40, 
		    "#", &j, xsegid + ((i__1 = j - 1) < 400 && 0 <= i__1 ? 
		    i__1 : s_rnge("xsegid", i__1, "f_ckbsr__", (ftnlen)2288)) 
		    * 40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	    repmi_(xsegid + ((i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : 
		    s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)2289)) * 40, 
		    "#", &inst, xsegid + ((i__1 = j - 1) < 400 && 0 <= i__1 ? 
		    i__1 : s_rnge("xsegid", i__1, "f_ckbsr__", (ftnlen)2289)) 
		    * 40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	}
    }
    t_crdaf__("CK", cks + ((i__2 = ckno - 1) < 15 && 0 <= i__2 ? i__2 : 
	    s_rnge("cks", i__2, "f_ckbsr__", (ftnlen)2296)) * 255, &nseg[(
	    i__1 = ckno - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge("nseg", i__1, 
	    "f_ckbsr__", (ftnlen)2296)], ids, tbegs, tends, xsegid, (ftnlen)2,
	     (ftnlen)255, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    tcase_("Prepare for search w/o buffering tests: create a CK with STSIZE-"
	    "3 segments for instruments 1-NINST.", (ftnlen)99);

/*     Create a CK file with STSIZE-3 segments for instruments */
/*     1-NINST. */

    ckno = 11;
    for (inst = 1; inst <= 4; ++inst) {
	for (i__ = 1; i__ <= 97; ++i__) {
	    j = (inst - 1) * 97 + i__;
	    ids[(i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("ids", i__2,
		     "f_ckbsr__", (ftnlen)2319)] = inst;
	    if (inst == 4) {
		tbegs[(i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbe"
			"gs", i__2, "f_ckbsr__", (ftnlen)2322)] = (doublereal) 
			(ckno * 10000 - i__ - 1);
	    } else {
		tbegs[(i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbe"
			"gs", i__2, "f_ckbsr__", (ftnlen)2324)] = (doublereal) 
			(ckno * 10000 + i__ - 1);
	    }
	    tends[(i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tends", 
		    i__2, "f_ckbsr__", (ftnlen)2327)] = tbegs[(i__1 = j - 1) <
		     400 && 0 <= i__1 ? i__1 : s_rnge("tbegs", i__1, "f_ckbs"
		    "r__", (ftnlen)2327)] + 1;
	    s_copy(xsegid + ((i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : 
		    s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)2329)) * 40, 
		    "File: # Segno: #  Inst:  #", (ftnlen)40, (ftnlen)26);
	    repmc_(xsegid + ((i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : 
		    s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)2331)) * 40, 
		    "#", cks + ((i__1 = ckno - 1) < 15 && 0 <= i__1 ? i__1 : 
		    s_rnge("cks", i__1, "f_ckbsr__", (ftnlen)2331)) * 255, 
		    xsegid + ((i__3 = j - 1) < 400 && 0 <= i__3 ? i__3 : 
		    s_rnge("xsegid", i__3, "f_ckbsr__", (ftnlen)2331)) * 40, (
		    ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
	    repmi_(xsegid + ((i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : 
		    s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)2332)) * 40, 
		    "#", &j, xsegid + ((i__1 = j - 1) < 400 && 0 <= i__1 ? 
		    i__1 : s_rnge("xsegid", i__1, "f_ckbsr__", (ftnlen)2332)) 
		    * 40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	    repmi_(xsegid + ((i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : 
		    s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)2333)) * 40, 
		    "#", &inst, xsegid + ((i__1 = j - 1) < 400 && 0 <= i__1 ? 
		    i__1 : s_rnge("xsegid", i__1, "f_ckbsr__", (ftnlen)2333)) 
		    * 40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	}
    }
    t_crdaf__("CK", cks + ((i__2 = ckno - 1) < 15 && 0 <= i__2 ? i__2 : 
	    s_rnge("cks", i__2, "f_ckbsr__", (ftnlen)2340)) * 255, &nseg[(
	    i__1 = ckno - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge("nseg", i__1, 
	    "f_ckbsr__", (ftnlen)2340)], ids, tbegs, tends, xsegid, (ftnlen)2,
	     (ftnlen)255, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    tcase_("Search w/o buffering, T < segment begin, re-use interval right e"
	    "ndpoint < segment begin.", (ftnlen)88);

/*     Unload the CK files.  Again. */

    for (i__ = 1; i__ <= 15; ++i__) {
	t_cuf__(&hndles[(i__2 = i__ - 1) < 15 && 0 <= i__2 ? i__2 : s_rnge(
		"hndles", i__2, "f_ckbsr__", (ftnlen)2357)]);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Load CKs 8 and 10. */

    t_clf__(cks + 1785, &hndles[7], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_clf__(cks + 2295, &hndles[9], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     The request time should precede the coverage of segment 3 in */
/*     CK 8. */

    inst = 2;
    t = 79999.;
    t_cbs__(&inst, &t, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    tcase_("Search w/o buffering, T within segment, re-use interval, left en"
	    "dpoint > segment begin.", (ftnlen)87);

/*     The request time should precede the coverage of segment 3 in */
/*     CK 8. */

    inst = 3;
    segno = 5;
    ckno = 8;
    tbegs[5] = (doublereal) (ckno * 10000);
    tends[5] = tbegs[5] + 3.;
    tbegs[4] = tends[5] - 1.;
    tends[4] = tbegs[4] + 3.;
    t = ckno * 10000 + 4.;
    t_cbs__(&inst, &t, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    s_copy(xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_ckbsr__", (ftnlen)2416)) * 40, "File: # Segno"
	    ": #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_ckbsr__", (ftnlen)2417)) * 40, "#", cks + ((
	    i__1 = ckno - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge("cks", i__1, 
	    "f_ckbsr__", (ftnlen)2417)) * 255, xsegid + ((i__3 = segno - 1) < 
	    400 && 0 <= i__3 ? i__3 : s_rnge("xsegid", i__3, "f_ckbsr__", (
	    ftnlen)2417)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)
	    40);
    repmi_(xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_ckbsr__", (ftnlen)2418)) * 40, "#", &segno, 
	    xsegid + ((i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_ckbsr__", (ftnlen)2418)) * 40, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + ((i__2 = segno - 1) < 400 && 0 <= 
	    i__2 ? i__2 : s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)2421)) *
	     40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (ftnlen)40);

/*     Check the descriptor as well.  However, don't check the */
/*     segment addresses. */

    t_crckds__(&segno, &inst, &tbegs[(i__2 = segno - 1) < 400 && 0 <= i__2 ? 
	    i__2 : s_rnge("tbegs", i__2, "f_ckbsr__", (ftnlen)2427)], &tends[(
	    i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("tends", 
	    i__1, "f_ckbsr__", (ftnlen)2427)], &xdescr[(i__3 = segno * 5 - 5) 
	    < 2000 && 0 <= i__3 ? i__3 : s_rnge("xdescr", i__3, "f_ckbsr__", (
	    ftnlen)2427)], &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[(i__2 = segno * 5 - 5) < 2000 && 0 
	    <= i__2 ? i__2 : s_rnge("xdescr", i__2, "f_ckbsr__", (ftnlen)2433)
	    ], &c__4, &c_b15, ok, (ftnlen)5, (ftnlen)1);
    tcase_("Search w/o buffering, T < segment begin, re-use interval right e"
	    "ndpoint = segment begin.", (ftnlen)88);
    inst = 4;
    segno = 7;
    ids[6] = inst;
    ids[7] = inst;
    ids[8] = inst;
    tbegs[8] = (doublereal) (ckno * 10000);
    tends[8] = tbegs[8] + 3.;
    tbegs[7] = tbegs[8];
    tends[7] = tends[8];
    tbegs[6] = tbegs[8] - 2.;
    tends[6] = tbegs[8] + 3.;
    t = tbegs[7] - 1.;
    t_cbs__(&inst, &t, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[7], &c__0, ok, (ftnlen)6, (ftnlen)
	    1);
    s_copy(xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_ckbsr__", (ftnlen)2469)) * 40, "File: # Segno"
	    ": #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_ckbsr__", (ftnlen)2470)) * 40, "#", cks + ((
	    i__1 = ckno - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge("cks", i__1, 
	    "f_ckbsr__", (ftnlen)2470)) * 255, xsegid + ((i__3 = segno - 1) < 
	    400 && 0 <= i__3 ? i__3 : s_rnge("xsegid", i__3, "f_ckbsr__", (
	    ftnlen)2470)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)
	    40);
    repmi_(xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_ckbsr__", (ftnlen)2471)) * 40, "#", &segno, 
	    xsegid + ((i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_ckbsr__", (ftnlen)2471)) * 40, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + ((i__2 = segno - 1) < 400 && 0 <= 
	    i__2 ? i__2 : s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)2474)) *
	     40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (ftnlen)40);

/*     Check the descriptor as well.  However, don't check the */
/*     segment addresses. */

    t_crckds__(&segno, &inst, &tbegs[(i__2 = segno - 1) < 400 && 0 <= i__2 ? 
	    i__2 : s_rnge("tbegs", i__2, "f_ckbsr__", (ftnlen)2480)], &tends[(
	    i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("tends", 
	    i__1, "f_ckbsr__", (ftnlen)2480)], &xdescr[(i__3 = segno * 5 - 5) 
	    < 2000 && 0 <= i__3 ? i__3 : s_rnge("xdescr", i__3, "f_ckbsr__", (
	    ftnlen)2480)], &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[(i__2 = segno * 5 - 5) < 2000 && 0 
	    <= i__2 ? i__2 : s_rnge("xdescr", i__2, "f_ckbsr__", (ftnlen)2486)
	    ], &c__4, &c_b15, ok, (ftnlen)5, (ftnlen)1);

/*     Some cases where a partial list must be dumped: */

    tcase_("Dump segment list from CK 11.  While searching list for segment "
	    "for instrument 4, make upper bound of re-use interval < upper bo"
	    "und of segment descriptor.", (ftnlen)154);

/*     Unload CK 10; load CK 11. */

    t_cuf__(&hndles[9]);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_clf__(cks + 2550, &hndles[10], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Our request time should be in the interior of segment 15 in */
/*     CK 8. */

    ckno = 8;
    segno = 15;
    ids[14] = 4;
    ids[15] = 4;
    ids[16] = 4;
    tbegs[14] = ckno * 10000 + 10.;
    tends[14] = tbegs[14] + 3.;
    tbegs[15] = tbegs[14] + 1.;
    tends[15] = tends[14] - 1.;
    tbegs[16] = tbegs[15];
    tends[16] = tbegs[16];
    t = tbegs[14] + .5;
    t_cbs__(&inst, &t, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[7], &c__0, ok, (ftnlen)6, (ftnlen)
	    1);
    s_copy(xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_ckbsr__", (ftnlen)2538)) * 40, "File: # Segno"
	    ": #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_ckbsr__", (ftnlen)2539)) * 40, "#", cks + ((
	    i__1 = ckno - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge("cks", i__1, 
	    "f_ckbsr__", (ftnlen)2539)) * 255, xsegid + ((i__3 = segno - 1) < 
	    400 && 0 <= i__3 ? i__3 : s_rnge("xsegid", i__3, "f_ckbsr__", (
	    ftnlen)2539)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)
	    40);
    repmi_(xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_ckbsr__", (ftnlen)2540)) * 40, "#", &segno, 
	    xsegid + ((i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_ckbsr__", (ftnlen)2540)) * 40, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + ((i__2 = segno - 1) < 400 && 0 <= 
	    i__2 ? i__2 : s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)2543)) *
	     40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (ftnlen)40);

/*     Check the descriptor as well.  However, don't check the */
/*     segment addresses. */

    t_crckds__(&segno, &inst, &tbegs[(i__2 = segno - 1) < 400 && 0 <= i__2 ? 
	    i__2 : s_rnge("tbegs", i__2, "f_ckbsr__", (ftnlen)2549)], &tends[(
	    i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("tends", 
	    i__1, "f_ckbsr__", (ftnlen)2549)], &xdescr[(i__3 = segno * 5 - 5) 
	    < 2000 && 0 <= i__3 ? i__3 : s_rnge("xdescr", i__3, "f_ckbsr__", (
	    ftnlen)2549)], &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[(i__2 = segno * 5 - 5) < 2000 && 0 
	    <= i__2 ? i__2 : s_rnge("xdescr", i__2, "f_ckbsr__", (ftnlen)2555)
	    ], &c__4, &c_b15, ok, (ftnlen)5, (ftnlen)1);
    tcase_("Dump segment list from CK 11.  While searching list for segment "
	    "for instrument 4, make lower bound of re-use interval = upper bo"
	    "und of segment descriptor.", (ftnlen)154);
    ckno = 8;
    inst = 4;
    tbegs[8] = (doublereal) (ckno * 10000);
    tends[8] = tbegs[8] + 3.;
    t = tends[8] + .5;
    t_cbs__(&inst, &t, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    tcase_("Dump segment list from CK 11.  While searching list for segment "
	    "for instrument 5, make lower bound of re-use interval > lower bo"
	    "und of segment descriptor.", (ftnlen)154);
    inst = 5;
    ids[17] = inst;
    ids[18] = inst;
    ids[19] = inst;
    tbegs[19] = ckno * 10000 + 10.;
    tends[19] = tbegs[19] + 3.;
    tbegs[18] = tbegs[19] - 2.;
    tends[18] = tbegs[18] + 3.;
    tbegs[17] = tbegs[18] - 2.;
    tends[17] = tends[19] + 1.;
    t = tends[17] - .5;
    t_cbs__(&inst, &t, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[7], &c__0, ok, (ftnlen)6, (ftnlen)
	    1);
    segno = 18;
    s_copy(xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_ckbsr__", (ftnlen)2615)) * 40, "File: # Segno"
	    ": #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_ckbsr__", (ftnlen)2616)) * 40, "#", cks + ((
	    i__1 = ckno - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge("cks", i__1, 
	    "f_ckbsr__", (ftnlen)2616)) * 255, xsegid + ((i__3 = segno - 1) < 
	    400 && 0 <= i__3 ? i__3 : s_rnge("xsegid", i__3, "f_ckbsr__", (
	    ftnlen)2616)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)
	    40);
    repmi_(xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_ckbsr__", (ftnlen)2617)) * 40, "#", &segno, 
	    xsegid + ((i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_ckbsr__", (ftnlen)2617)) * 40, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("SEGID", segid, "=", xsegid + ((i__2 = segno - 1) < 400 && 0 <= 
	    i__2 ? i__2 : s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)2620)) *
	     40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (ftnlen)40);

/*     Check the descriptor as well.  However, don't check the */
/*     segment addresses. */

    t_crckds__(&segno, &inst, &tbegs[(i__2 = segno - 1) < 400 && 0 <= i__2 ? 
	    i__2 : s_rnge("tbegs", i__2, "f_ckbsr__", (ftnlen)2626)], &tends[(
	    i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("tends", 
	    i__1, "f_ckbsr__", (ftnlen)2626)], &xdescr[(i__3 = segno * 5 - 5) 
	    < 2000 && 0 <= i__3 ? i__3 : s_rnge("xdescr", i__3, "f_ckbsr__", (
	    ftnlen)2626)], &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_chds__("DESCR", descr, "=", &xdescr[(i__2 = segno * 5 - 5) < 2000 && 0 
	    <= i__2 ? i__2 : s_rnge("xdescr", i__2, "f_ckbsr__", (ftnlen)2632)
	    ], &c__4, &c_b15, ok, (ftnlen)5, (ftnlen)1);
    tcase_("Create a situation where room is needed in the instrument table,"
	    " and the second instrument list has expense greater than the fir"
	    "st.", (ftnlen)131);

/*     Unload CKs 8 and 11. */

    t_cuf__(&hndles[7]);
    t_cuf__(&hndles[10]);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Fill up (nearly) the segment table with a cheap list for */
/*     instrument 2 and an expensive list for instrument 1. */

    t_clf__(cks + 1785, &hndles[7], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    inst = 2;
    ids[1] = inst;
    ids[2] = inst;
    tbegs[2] = (doublereal) (ckno * 10000);
    tends[2] = tbegs[2] + 1.;
    inst = 2;
    ckno = 8;
    segno = 3;
    d__1 = tbegs[(i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbegs"
	    , i__2, "f_ckbsr__", (ftnlen)2667)] + .5;
    t_cbs__(&inst, &d__1, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     In this case, the segment should be found.  Make sure we get */
/*     back the right handle and segment identifier. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__2 = ckno - 1) < 15 && 0 <= 
	    i__2 ? i__2 : s_rnge("hndles", i__2, "f_ckbsr__", (ftnlen)2677)], 
	    &c__0, ok, (ftnlen)6, (ftnlen)1);
    t_clf__(cks + 2550, &hndles[10], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    inst = 1;
    ckno = 11;
    segno = 1;
    i__ = 1;
    tbegs[(i__2 = i__ - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbegs", i__2, 
	    "f_ckbsr__", (ftnlen)2687)] = (doublereal) (ckno * 10000 + i__ - 
	    1);
    tends[(i__2 = i__ - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tends", i__2, 
	    "f_ckbsr__", (ftnlen)2688)] = tbegs[(i__1 = i__ - 1) < 400 && 0 <=
	     i__1 ? i__1 : s_rnge("tbegs", i__1, "f_ckbsr__", (ftnlen)2688)] 
	    + 1;
    d__1 = tbegs[(i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbegs"
	    , i__2, "f_ckbsr__", (ftnlen)2690)] + .5;
    t_cbs__(&inst, &d__1, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__2 = ckno - 1) < 15 && 0 <= 
	    i__2 ? i__2 : s_rnge("hndles", i__2, "f_ckbsr__", (ftnlen)2696)], 
	    &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Now do a look up for instrument 3.  This should cause the segment */
/*     lists for instruments 2 and 1 to get dumped. */

    inst = 3;
    ckno = 11;
    i__ = 1;
    j = (inst - 1) * 97 + i__;
    tbegs[(i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbegs", i__2, 
	    "f_ckbsr__", (ftnlen)2708)] = (doublereal) (ckno * 10000 + i__ - 
	    1);
    tends[(i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tends", i__2, 
	    "f_ckbsr__", (ftnlen)2709)] = tbegs[(i__1 = i__ - 1) < 400 && 0 <=
	     i__1 ? i__1 : s_rnge("tbegs", i__1, "f_ckbsr__", (ftnlen)2709)] 
	    + 1;
    s_copy(xsegid + ((i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("xseg"
	    "id", i__2, "f_ckbsr__", (ftnlen)2711)) * 40, "File: # Segno: #  "
	    "Instrument:  #", (ftnlen)40, (ftnlen)32);
    repmc_(xsegid + ((i__2 = i__ - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_ckbsr__", (ftnlen)2713)) * 40, "#", cks + ((
	    i__1 = ckno - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge("cks", i__1, 
	    "f_ckbsr__", (ftnlen)2713)) * 255, xsegid + ((i__3 = i__ - 1) < 
	    400 && 0 <= i__3 ? i__3 : s_rnge("xsegid", i__3, "f_ckbsr__", (
	    ftnlen)2713)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)
	    40);
    repmi_(xsegid + ((i__2 = i__ - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_ckbsr__", (ftnlen)2714)) * 40, "#", &j, xsegid 
	    + ((i__1 = i__ - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("xsegid", 
	    i__1, "f_ckbsr__", (ftnlen)2714)) * 40, (ftnlen)40, (ftnlen)1, (
	    ftnlen)40);
    repmi_(xsegid + ((i__2 = i__ - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_ckbsr__", (ftnlen)2715)) * 40, "#", &inst, 
	    xsegid + ((i__1 = i__ - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_ckbsr__", (ftnlen)2715)) * 40, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    segno = j;
    d__1 = tbegs[(i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbegs"
	    , i__2, "f_ckbsr__", (ftnlen)2720)] + .5;
    t_cbs__(&inst, &d__1, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &hndles[(i__2 = ckno - 1) < 15 && 0 <= 
	    i__2 ? i__2 : s_rnge("hndles", i__2, "f_ckbsr__", (ftnlen)2726)], 
	    &c__0, ok, (ftnlen)6, (ftnlen)1);
    tcase_("Try DAFOPR error handling.", (ftnlen)26);
    t_clf__("ThisFileDoesNotExist", &handle, (ftnlen)20);
    if (return_()) {
	chckxc_(&c_true, "SPICE(FILENOTFOUND)", ok, (ftnlen)19);
    } else {
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    tcase_("Test partial deletion of a segment list when a file is unloaded.",
	     (ftnlen)64);

/*     Unload the CK files.  The load files 1 and 2. */

    for (i__ = 1; i__ <= 15; ++i__) {
	t_cuf__(&hndles[(i__2 = i__ - 1) < 15 && 0 <= i__2 ? i__2 : s_rnge(
		"hndles", i__2, "f_ckbsr__", (ftnlen)2752)]);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    for (i__ = 1; i__ <= 2; ++i__) {
	t_clf__(cks + ((i__2 = i__ - 1) < 15 && 0 <= i__2 ? i__2 : s_rnge(
		"cks", i__2, "f_ckbsr__", (ftnlen)2758)) * 255, &hndles[(i__1 
		= i__ - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge("hndles", i__1, 
		"f_ckbsr__", (ftnlen)2758)], (ftnlen)255);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Do lookups for intrument 1 that hit both files. */

    inst = 1;
    tbegs[0] = 1e4;
    d__1 = tbegs[0] + .5;
    t_cbs__(&inst, &d__1, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    inst = 1;
    ckno = 2;
    segno = nseg[(i__2 = ckno - 1) < 15 && 0 <= i__2 ? i__2 : s_rnge("nseg", 
	    i__2, "f_ckbsr__", (ftnlen)2778)] / 2 + 1;
    tbegs[(i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbegs", i__2,
	     "f_ckbsr__", (ftnlen)2780)] = (doublereal) (ckno * 10000 + segno 
	    - 1);
    d__1 = tbegs[(i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbegs"
	    , i__2, "f_ckbsr__", (ftnlen)2782)] + .5;
    t_cbs__(&inst, &d__1, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Do a lookup for instrument 2 to create a segment list for that */
/*     instrument. */

    inst = 2;
    ckno = 2;
    segno = nseg[(i__2 = ckno - 1) < 15 && 0 <= i__2 ? i__2 : s_rnge("nseg", 
	    i__2, "f_ckbsr__", (ftnlen)2795)] / 2;
    tbegs[(i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbegs", i__2,
	     "f_ckbsr__", (ftnlen)2797)] = (doublereal) (ckno * 10000 + segno 
	    - 1);
    d__1 = tbegs[(i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbegs"
	    , i__2, "f_ckbsr__", (ftnlen)2800)] + .5;
    t_cbs__(&inst, &d__1, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Reload file 1, removing the portion of instrument 1's segment list */
/*     that came from file 1, as part of the unload process that */
/*     precedes re-loading file 1. */

    t_clf__(cks, hndles, (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Create FTSIZE copies of CK 1 and load FTSIZE-1 of them.  We */
/*     should get a file table overflow error. */

    tcase_("File table overflow error.", (ftnlen)26);
    for (i__ = 1; i__ <= 110; ++i__) {
	s_copy(ckcpy + ((i__2 = i__ - 1) < 110 && 0 <= i__2 ? i__2 : s_rnge(
		"ckcpy", i__2, "f_ckbsr__", (ftnlen)2824)) * 255, "copy#.bc", 
		(ftnlen)255, (ftnlen)8);
	repmi_(ckcpy + ((i__2 = i__ - 1) < 110 && 0 <= i__2 ? i__2 : s_rnge(
		"ckcpy", i__2, "f_ckbsr__", (ftnlen)2825)) * 255, "#", &i__, 
		ckcpy + ((i__1 = i__ - 1) < 110 && 0 <= i__1 ? i__1 : s_rnge(
		"ckcpy", i__1, "f_ckbsr__", (ftnlen)2825)) * 255, (ftnlen)255,
		 (ftnlen)1, (ftnlen)255);
	inst = 1;
	tbegs[0] = 1e4;
	tends[0] = 10001.;
	ckno = 1;
	segno = 1;
	s_copy(xsegid, "File: # Segno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid, "#", ckcpy + ((i__2 = i__ - 1) < 110 && 0 <= i__2 ? 
		i__2 : s_rnge("ckcpy", i__2, "f_ckbsr__", (ftnlen)2834)) * 
		255, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
	repmi_(xsegid, "#", &segno, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)40)
		;
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	t_crdaf__("CK", ckcpy + ((i__2 = i__ - 1) < 110 && 0 <= i__2 ? i__2 : 
		s_rnge("ckcpy", i__2, "f_ckbsr__", (ftnlen)2838)) * 255, nseg,
		 &inst, tbegs, tends, xsegid, (ftnlen)2, (ftnlen)255, (ftnlen)
		40);
    }
    for (i__ = 1; i__ <= 108; ++i__) {
	t_clf__(ckcpy + ((i__2 = i__ - 1) < 110 && 0 <= i__2 ? i__2 : s_rnge(
		"ckcpy", i__2, "f_ckbsr__", (ftnlen)2844)) * 255, &cpyhan[(
		i__1 = i__ - 1) < 110 && 0 <= i__1 ? i__1 : s_rnge("cpyhan", 
		i__1, "f_ckbsr__", (ftnlen)2844)], (ftnlen)255);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    t_clf__(ckcpy + 27540, &cpyhan[108], (ftnlen)255);

/*     If the error is caught by the handle manager, the short message */
/*     check should be: */

/*        CALL CHCKXC ( .TRUE., 'SPICE(FTFULL)', OK ) */

/*     Since the BSR file table is smaller than the handle manager */
/*     table, the error check is as shown below: */

    chckxc_(&c_true, "SPICE(CKTOOMANYFILES)", ok, (ftnlen)21);

/*     Loading, unloading, and priority checks: */

    tcase_("Load all copies of CK 1, looking up the same state from each.  U"
	    "nload the files in reverse order.  Repeat 3 times.", (ftnlen)114);

/*     First, make sure all files are unloaded. */

    for (i__ = 1; i__ <= 15; ++i__) {
	t_cuf__(&hndles[(i__2 = i__ - 1) < 15 && 0 <= i__2 ? i__2 : s_rnge(
		"hndles", i__2, "f_ckbsr__", (ftnlen)2873)]);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    for (i__ = 1; i__ <= 109; ++i__) {
	t_cuf__(&cpyhan[(i__2 = i__ - 1) < 110 && 0 <= i__2 ? i__2 : s_rnge(
		"cpyhan", i__2, "f_ckbsr__", (ftnlen)2880)]);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    inst = 1;
    for (i__ = 1; i__ <= 3; ++i__) {
	for (j = 1; j <= 110; ++j) {
	    tbegs[(i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbegs", 
		    i__2, "f_ckbsr__", (ftnlen)2892)] = 1e4;
	    tends[(i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tends", 
		    i__2, "f_ckbsr__", (ftnlen)2893)] = 10001.;
	    t_clf__(ckcpy + ((i__2 = j - 1) < 110 && 0 <= i__2 ? i__2 : 
		    s_rnge("ckcpy", i__2, "f_ckbsr__", (ftnlen)2895)) * 255, &
		    cpyhan[(i__1 = j - 1) < 110 && 0 <= i__1 ? i__1 : s_rnge(
		    "cpyhan", i__1, "f_ckbsr__", (ftnlen)2895)], (ftnlen)255);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    s_copy(xsegid + ((i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : 
		    s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)2898)) * 40, 
		    "File: # Segno: #", (ftnlen)40, (ftnlen)16);
	    repmc_(xsegid + ((i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : 
		    s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)2899)) * 40, 
		    "#", ckcpy + ((i__1 = j - 1) < 110 && 0 <= i__1 ? i__1 : 
		    s_rnge("ckcpy", i__1, "f_ckbsr__", (ftnlen)2899)) * 255, 
		    xsegid + ((i__3 = j - 1) < 400 && 0 <= i__3 ? i__3 : 
		    s_rnge("xsegid", i__3, "f_ckbsr__", (ftnlen)2899)) * 40, (
		    ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
	    repmi_(xsegid + ((i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : 
		    s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)2900)) * 40, 
		    "#", &c__1, xsegid + ((i__1 = j - 1) < 400 && 0 <= i__1 ? 
		    i__1 : s_rnge("xsegid", i__1, "f_ckbsr__", (ftnlen)2900)) 
		    * 40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    d__1 = tbegs[(i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
		    "tbegs", i__2, "f_ckbsr__", (ftnlen)2903)] + .5;
	    t_cbs__(&inst, &d__1, &c_b15, &c_true);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           In this case, the segment should be found.  Make sure */
/*           we get back the right handle and segment identifier. */

	    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	    chcksi_("HANDLE", &handle, "=", &cpyhan[(i__2 = j - 1) < 110 && 0 
		    <= i__2 ? i__2 : s_rnge("cpyhan", i__2, "f_ckbsr__", (
		    ftnlen)2913)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	    chcksc_("SEGID", segid, "=", xsegid + ((i__2 = j - 1) < 400 && 0 
		    <= i__2 ? i__2 : s_rnge("xsegid", i__2, "f_ckbsr__", (
		    ftnlen)2914)) * 40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, 
		    (ftnlen)40);

/*           Check the descriptor as well.  However, don't check the */
/*           segment addresses. */

	    t_crckds__(&segno, &inst, &tbegs[(i__2 = j - 1) < 400 && 0 <= 
		    i__2 ? i__2 : s_rnge("tbegs", i__2, "f_ckbsr__", (ftnlen)
		    2920)], &tends[(i__1 = j - 1) < 400 && 0 <= i__1 ? i__1 : 
		    s_rnge("tends", i__1, "f_ckbsr__", (ftnlen)2920)], &
		    xdescr[(i__3 = j * 5 - 5) < 2000 && 0 <= i__3 ? i__3 : 
		    s_rnge("xdescr", i__3, "f_ckbsr__", (ftnlen)2920)], &
		    c_true);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    t_chds__("DESCR", descr, "=", &xdescr[(i__2 = j * 5 - 5) < 2000 &&
		     0 <= i__2 ? i__2 : s_rnge("xdescr", i__2, "f_ckbsr__", (
		    ftnlen)2926)], &c__4, &c_b15, ok, (ftnlen)5, (ftnlen)1);
	}

/*        Now unload files, looking up states as we go. */

	for (j = 109; j >= 1; --j) {
	    t_cuf__(&cpyhan[(i__2 = j) < 110 && 0 <= i__2 ? i__2 : s_rnge(
		    "cpyhan", i__2, "f_ckbsr__", (ftnlen)2936)]);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    tbegs[(i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbegs", 
		    i__2, "f_ckbsr__", (ftnlen)2939)] = 1e4;
	    tends[(i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tends", 
		    i__2, "f_ckbsr__", (ftnlen)2940)] = 10001.;
	    s_copy(xsegid + ((i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : 
		    s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)2942)) * 40, 
		    "File: # Segno: #", (ftnlen)40, (ftnlen)16);
	    repmc_(xsegid + ((i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : 
		    s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)2943)) * 40, 
		    "#", ckcpy + ((i__1 = j - 1) < 110 && 0 <= i__1 ? i__1 : 
		    s_rnge("ckcpy", i__1, "f_ckbsr__", (ftnlen)2943)) * 255, 
		    xsegid + ((i__3 = j - 1) < 400 && 0 <= i__3 ? i__3 : 
		    s_rnge("xsegid", i__3, "f_ckbsr__", (ftnlen)2943)) * 40, (
		    ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
	    repmi_(xsegid + ((i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : 
		    s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)2944)) * 40, 
		    "#", &c__1, xsegid + ((i__1 = j - 1) < 400 && 0 <= i__1 ? 
		    i__1 : s_rnge("xsegid", i__1, "f_ckbsr__", (ftnlen)2944)) 
		    * 40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    d__1 = tbegs[(i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
		    "tbegs", i__2, "f_ckbsr__", (ftnlen)2947)] + .5;
	    t_cbs__(&inst, &d__1, &c_b15, &c_true);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           In this case, the segment should be found.  Make sure */
/*           we get back the right handle and segment identifier. */

	    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	    chcksi_("HANDLE", &handle, "=", &cpyhan[(i__2 = j - 1) < 110 && 0 
		    <= i__2 ? i__2 : s_rnge("cpyhan", i__2, "f_ckbsr__", (
		    ftnlen)2957)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	    chcksc_("SEGID", segid, "=", xsegid + ((i__2 = j - 1) < 400 && 0 
		    <= i__2 ? i__2 : s_rnge("xsegid", i__2, "f_ckbsr__", (
		    ftnlen)2958)) * 40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, 
		    (ftnlen)40);

/*           Check the descriptor as well.  However, don't check the */
/*           segment addresses. */

	    t_crckds__(&segno, &inst, &tbegs[(i__2 = j - 1) < 400 && 0 <= 
		    i__2 ? i__2 : s_rnge("tbegs", i__2, "f_ckbsr__", (ftnlen)
		    2964)], &tends[(i__1 = j - 1) < 400 && 0 <= i__1 ? i__1 : 
		    s_rnge("tends", i__1, "f_ckbsr__", (ftnlen)2964)], &
		    xdescr[(i__3 = j * 5 - 5) < 2000 && 0 <= i__3 ? i__3 : 
		    s_rnge("xdescr", i__3, "f_ckbsr__", (ftnlen)2964)], &
		    c_true);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    t_chds__("DESCR", descr, "=", &xdescr[(i__2 = j * 5 - 5) < 2000 &&
		     0 <= i__2 ? i__2 : s_rnge("xdescr", i__2, "f_ckbsr__", (
		    ftnlen)2971)], &c__4, &c_b15, ok, (ftnlen)5, (ftnlen)1);
	}
    }

/*     Make sure we don't accumulate DAF links by re-loading a file. */

    tcase_("Load the first CK file 2*FTSIZE times.", (ftnlen)38);
    for (i__ = 1; i__ <= 220; ++i__) {
	segno = 1;
	tbegs[0] = 1e4;
	tends[0] = 10001.;
	t_clf__(cks, hndles, (ftnlen)255);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	s_copy(xsegid, "File: # Segno: #", (ftnlen)40, (ftnlen)16);
	repmc_(xsegid, "#", cks, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)255, (
		ftnlen)40);
	repmi_(xsegid, "#", &segno, xsegid, (ftnlen)40, (ftnlen)1, (ftnlen)40)
		;
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	d__1 = tbegs[0] + .5;
	t_cbs__(&inst, &d__1, &c_b15, &c_true);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	t_csn__(&handle, descr, segid, &found, (ftnlen)40);
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

	t_chds__("DESCR", descr, "=", xdescr, &c__4, &c_b15, ok, (ftnlen)5, (
		ftnlen)1);
    }

/*     Tests using non-zero tolerance follow... */
/*     We'll make use of CK8. */

    t_clf__(cks + 1785, &hndles[7], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     The topology of the coverage for segments 10-12 is as shown. */

/*       ++++++++++++++++++        segment 10 */
/*           +++++++                       11 */
/*               ++++++++                  12 */

    tcase_("Request time is covered by segment 11, but tolerance allows segm"
	    "ent 12 to cover request.Repeat the lookup to test the re-use int"
	    "erval.", (ftnlen)134);
    ckno = 8;
    inst = 5;
    segno = 12;
    tol = 1.5;
    tbegs[11] = (doublereal) (ckno * 10000);
    tends[11] = tbegs[11] + 3.;
    tbegs[10] = tbegs[11] - 2.;
    tends[10] = tbegs[10] + 3.;
    tbegs[9] = tbegs[10] - 2.;
    tends[9] = tends[11] + 1.;
    tbegs[(i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbegs", i__2,
	     "f_ckbsr__", (ftnlen)3057)] = (doublereal) (ckno * 10000);
    tends[(i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tends", i__2,
	     "f_ckbsr__", (ftnlen)3058)] = tbegs[(i__1 = segno - 1) < 400 && 
	    0 <= i__1 ? i__1 : s_rnge("tbegs", i__1, "f_ckbsr__", (ftnlen)
	    3058)] + 3.;
    s_copy(xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_ckbsr__", (ftnlen)3060)) * 40, "File: # Segno"
	    ": #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_ckbsr__", (ftnlen)3061)) * 40, "#", cks + ((
	    i__1 = ckno - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge("cks", i__1, 
	    "f_ckbsr__", (ftnlen)3061)) * 255, xsegid + ((i__3 = segno - 1) < 
	    400 && 0 <= i__3 ? i__3 : s_rnge("xsegid", i__3, "f_ckbsr__", (
	    ftnlen)3061)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)
	    40);
    repmi_(xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_ckbsr__", (ftnlen)3062)) * 40, "#", &segno, 
	    xsegid + ((i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_ckbsr__", (ftnlen)3062)) * 40, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_crckds__(&segno, &inst, &tbegs[(i__2 = segno - 1) < 400 && 0 <= i__2 ? 
	    i__2 : s_rnge("tbegs", i__2, "f_ckbsr__", (ftnlen)3065)], &tends[(
	    i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("tends", 
	    i__1, "f_ckbsr__", (ftnlen)3065)], xdescr, &c_true);
    for (i__ = 1; i__ <= 3; ++i__) {
	d__1 = tbegs[(i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
		"tbegs", i__2, "f_ckbsr__", (ftnlen)3071)] - 1.;
	t_cbs__(&inst, &d__1, &tol, &c_true);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	t_csn__(&handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        In this case, the segment should be found.  Make sure */
/*        we get back the right handle and segment identifier. */

	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	chcksi_("HANDLE", &handle, "=", &hndles[(i__2 = ckno - 1) < 15 && 0 <=
		 i__2 ? i__2 : s_rnge("hndles", i__2, "f_ckbsr__", (ftnlen)
		3081)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	chcksc_("SEGID", segid, "=", xsegid + ((i__2 = segno - 1) < 400 && 0 
		<= i__2 ? i__2 : s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)
		3082)) * 40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (ftnlen)40)
		;

/*        Check the descriptor as well.  However, don't check the */
/*        segment addresses. */

	t_chds__("DESCR", descr, "=", xdescr, &c__4, &c_b15, ok, (ftnlen)5, (
		ftnlen)1);
    }
    tcase_("Repeat the test with tolerance too small to catch segment 12.  W"
	    "e should hit segment 11.", (ftnlen)88);
    tol = .5;
    segno = 11;
    s_copy(xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_ckbsr__", (ftnlen)3100)) * 40, "File: # Segno"
	    ": #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_ckbsr__", (ftnlen)3101)) * 40, "#", cks + ((
	    i__1 = ckno - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge("cks", i__1, 
	    "f_ckbsr__", (ftnlen)3101)) * 255, xsegid + ((i__3 = segno - 1) < 
	    400 && 0 <= i__3 ? i__3 : s_rnge("xsegid", i__3, "f_ckbsr__", (
	    ftnlen)3101)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)
	    40);
    repmi_(xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_ckbsr__", (ftnlen)3102)) * 40, "#", &segno, 
	    xsegid + ((i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_ckbsr__", (ftnlen)3102)) * 40, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_crckds__(&segno, &inst, &tbegs[(i__2 = segno - 1) < 400 && 0 <= i__2 ? 
	    i__2 : s_rnge("tbegs", i__2, "f_ckbsr__", (ftnlen)3105)], &tends[(
	    i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("tends", 
	    i__1, "f_ckbsr__", (ftnlen)3105)], xdescr, &c_true);
    for (i__ = 1; i__ <= 3; ++i__) {
	d__1 = tbegs[11] - 1.;
	t_cbs__(&inst, &d__1, &tol, &c_true);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	t_csn__(&handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        In this case, the segment should be found.  Make sure */
/*        we get back the right handle and segment identifier. */

	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	chcksi_("HANDLE", &handle, "=", &hndles[(i__2 = ckno - 1) < 15 && 0 <=
		 i__2 ? i__2 : s_rnge("hndles", i__2, "f_ckbsr__", (ftnlen)
		3120)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	chcksc_("SEGID", segid, "=", xsegid + ((i__2 = segno - 1) < 400 && 0 
		<= i__2 ? i__2 : s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)
		3121)) * 40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (ftnlen)40)
		;

/*        Check the descriptor as well.  However, don't check the */
/*        segment addresses. */

	t_chds__("DESCR", descr, "=", xdescr, &c__4, &c_b15, ok, (ftnlen)5, (
		ftnlen)1);
    }
    tcase_("Request time is covered by segment 10, but tolerance allows segm"
	    "ent 10 to cover request.Repeat the lookup to test the re-use int"
	    "erval.", (ftnlen)134);
    segno = 11;
    tol = 1.1;
    for (i__ = 1; i__ <= 3; ++i__) {
	d__1 = tbegs[10] - 1.;
	t_cbs__(&inst, &d__1, &tol, &c_true);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	t_csn__(&handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        In this case, the segment should be found.  Make sure */
/*        we get back the right handle and segment identifier. */

	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	chcksi_("HANDLE", &handle, "=", &hndles[(i__2 = ckno - 1) < 15 && 0 <=
		 i__2 ? i__2 : s_rnge("hndles", i__2, "f_ckbsr__", (ftnlen)
		3151)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	chcksc_("SEGID", segid, "=", xsegid + ((i__2 = segno - 1) < 400 && 0 
		<= i__2 ? i__2 : s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)
		3152)) * 40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (ftnlen)40)
		;

/*        Check the descriptor as well.  However, don't check the */
/*        segment addresses. */

	t_chds__("DESCR", descr, "=", xdescr, &c__4, &c_b15, ok, (ftnlen)5, (
		ftnlen)1);
    }

/*     Now check handling of tolerance of the left side of the */
/*     request time. */

    tcase_("Request time is covered by segment 10, but tolerance allows segm"
	    "ent 12 to cover request.Repeat the lookup to test the re-use int"
	    "erval.", (ftnlen)134);
    segno = 12;
    tol = .5;
    s_copy(xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_ckbsr__", (ftnlen)3174)) * 40, "File: # Segno"
	    ": #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_ckbsr__", (ftnlen)3175)) * 40, "#", cks + ((
	    i__1 = ckno - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge("cks", i__1, 
	    "f_ckbsr__", (ftnlen)3175)) * 255, xsegid + ((i__3 = segno - 1) < 
	    400 && 0 <= i__3 ? i__3 : s_rnge("xsegid", i__3, "f_ckbsr__", (
	    ftnlen)3175)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)
	    40);
    repmi_(xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_ckbsr__", (ftnlen)3176)) * 40, "#", &segno, 
	    xsegid + ((i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_ckbsr__", (ftnlen)3176)) * 40, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_crckds__(&segno, &inst, &tbegs[(i__2 = segno - 1) < 400 && 0 <= i__2 ? 
	    i__2 : s_rnge("tbegs", i__2, "f_ckbsr__", (ftnlen)3179)], &tends[(
	    i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("tends", 
	    i__1, "f_ckbsr__", (ftnlen)3179)], xdescr, &c_true);
    for (i__ = 1; i__ <= 3; ++i__) {
	d__1 = tends[(i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
		"tends", i__2, "f_ckbsr__", (ftnlen)3185)] + .01;
	t_cbs__(&inst, &d__1, &tol, &c_true);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	t_csn__(&handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        In this case, the segment should be found.  Make sure */
/*        we get back the right handle and segment identifier. */

	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	chcksi_("HANDLE", &handle, "=", &hndles[(i__2 = ckno - 1) < 15 && 0 <=
		 i__2 ? i__2 : s_rnge("hndles", i__2, "f_ckbsr__", (ftnlen)
		3195)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	chcksc_("SEGID", segid, "=", xsegid + ((i__2 = segno - 1) < 400 && 0 
		<= i__2 ? i__2 : s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)
		3196)) * 40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (ftnlen)40)
		;

/*        Check the descriptor as well.  However, don't check the */
/*        segment addresses. */

	t_chds__("DESCR", descr, "=", xdescr, &c__4, &c_b15, ok, (ftnlen)5, (
		ftnlen)1);
    }
    tcase_("Repeat the test with tolerance too small to catch segment 12.  W"
	    "e should hit segment 10.", (ftnlen)88);
    segno = 10;
    tol = .001;
    s_copy(xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_ckbsr__", (ftnlen)3214)) * 40, "File: # Segno"
	    ": #", (ftnlen)40, (ftnlen)16);
    repmc_(xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_ckbsr__", (ftnlen)3215)) * 40, "#", cks + ((
	    i__1 = ckno - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge("cks", i__1, 
	    "f_ckbsr__", (ftnlen)3215)) * 255, xsegid + ((i__3 = segno - 1) < 
	    400 && 0 <= i__3 ? i__3 : s_rnge("xsegid", i__3, "f_ckbsr__", (
	    ftnlen)3215)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)
	    40);
    repmi_(xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
	    "xsegid", i__2, "f_ckbsr__", (ftnlen)3216)) * 40, "#", &segno, 
	    xsegid + ((i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge(
	    "xsegid", i__1, "f_ckbsr__", (ftnlen)3216)) * 40, (ftnlen)40, (
	    ftnlen)1, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_crckds__(&segno, &inst, &tbegs[(i__2 = segno - 1) < 400 && 0 <= i__2 ? 
	    i__2 : s_rnge("tbegs", i__2, "f_ckbsr__", (ftnlen)3219)], &tends[(
	    i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("tends", 
	    i__1, "f_ckbsr__", (ftnlen)3219)], xdescr, &c_true);

/*     Repeat lookup to test the re-use interval. */

    for (i__ = 1; i__ <= 3; ++i__) {
	d__1 = tends[11] + .01;
	t_cbs__(&inst, &d__1, &tol, &c_true);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	t_csn__(&handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        In this case, the segment should be found.  Make sure */
/*        we get back the right handle and segment identifier. */

	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	chcksi_("HANDLE", &handle, "=", &hndles[(i__2 = ckno - 1) < 15 && 0 <=
		 i__2 ? i__2 : s_rnge("hndles", i__2, "f_ckbsr__", (ftnlen)
		3238)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	chcksc_("SEGID", segid, "=", xsegid + ((i__2 = segno - 1) < 400 && 0 
		<= i__2 ? i__2 : s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)
		3239)) * 40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (ftnlen)40)
		;

/*        Check the descriptor as well.  However, don't check the */
/*        segment addresses. */

	t_chds__("DESCR", descr, "=", xdescr, &c__4, &c_b15, ok, (ftnlen)5, (
		ftnlen)1);
    }

/*     Load CKs 11 and 10, in that order.  Most segments from */
/*     CK 10 can't be buffered. */

    t_clf__(cks + 2550, &hndles[10], (ftnlen)255);
    t_clf__(cks + 2295, &hndles[9], (ftnlen)255);

/*     Do a look up that will hit the last segment for inst NINST */
/*     in CK 10, using non-zero tolerance. */

    tcase_("Do a look up that will hit the last segment for instrument NINST"
	    " in CK 10, relying on tolerance to catch the segment.", (ftnlen)
	    117);
    ckno = 10;
    inst = 4;
    i__ = 100;
    j = (inst - 1) * 100 + i__;
    ids[(i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("ids", i__2, "f_ck"
	    "bsr__", (ftnlen)3271)] = inst;
    tbegs[(i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbegs", i__2, 
	    "f_ckbsr__", (ftnlen)3273)] = (doublereal) (ckno * 10000 - i__ - 
	    1);
    tends[(i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tends", i__2, 
	    "f_ckbsr__", (ftnlen)3275)] = tbegs[(i__1 = j - 1) < 400 && 0 <= 
	    i__1 ? i__1 : s_rnge("tbegs", i__1, "f_ckbsr__", (ftnlen)3275)] + 
	    1;
    s_copy(xsegid + ((i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("xseg"
	    "id", i__2, "f_ckbsr__", (ftnlen)3277)) * 40, "File: # Segno: #  "
	    "Inst:  #", (ftnlen)40, (ftnlen)26);
    repmc_(xsegid + ((i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("xseg"
	    "id", i__2, "f_ckbsr__", (ftnlen)3279)) * 40, "#", cks + ((i__1 = 
	    ckno - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge("cks", i__1, "f_ckbs"
	    "r__", (ftnlen)3279)) * 255, xsegid + ((i__3 = j - 1) < 400 && 0 <=
	     i__3 ? i__3 : s_rnge("xsegid", i__3, "f_ckbsr__", (ftnlen)3279)) 
	    * 40, (ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
    repmi_(xsegid + ((i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("xseg"
	    "id", i__2, "f_ckbsr__", (ftnlen)3280)) * 40, "#", &j, xsegid + ((
	    i__1 = j - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("xsegid", i__1, 
	    "f_ckbsr__", (ftnlen)3280)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)
	    40);
    repmi_(xsegid + ((i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("xseg"
	    "id", i__2, "f_ckbsr__", (ftnlen)3281)) * 40, "#", &inst, xsegid + 
	    ((i__1 = j - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("xsegid", i__1,
	     "f_ckbsr__", (ftnlen)3281)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)
	    40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    segno = j;
    t_crckds__(&segno, &inst, &tbegs[(i__2 = segno - 1) < 400 && 0 <= i__2 ? 
	    i__2 : s_rnge("tbegs", i__2, "f_ckbsr__", (ftnlen)3286)], &tends[(
	    i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("tends", 
	    i__1, "f_ckbsr__", (ftnlen)3286)], xdescr, &c_true);
    tol = .1;
    for (i__ = 1; i__ <= 3; ++i__) {
	d__1 = tbegs[(i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
		"tbegs", i__2, "f_ckbsr__", (ftnlen)3294)] - .01;
	t_cbs__(&inst, &d__1, &tol, &c_true);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	t_csn__(&handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        In this case, the segment should be found.  Make sure */
/*        we get back the right handle and segment identifier. */

	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	chcksi_("HANDLE", &handle, "=", &hndles[(i__2 = ckno - 1) < 15 && 0 <=
		 i__2 ? i__2 : s_rnge("hndles", i__2, "f_ckbsr__", (ftnlen)
		3304)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	chcksc_("SEGID", segid, "=", xsegid + ((i__2 = segno - 1) < 400 && 0 
		<= i__2 ? i__2 : s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)
		3305)) * 40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (ftnlen)40)
		;

/*        Check the descriptor as well.  However, don't check the */
/*        segment addresses. */

	t_chds__("DESCR", descr, "=", xdescr, &c__4, &c_b15, ok, (ftnlen)5, (
		ftnlen)1);
    }

/*     Do a look up that will hit the last segment for inst NINST-1 */
/*     in CK 10, using non-zero tolerance. */

    tcase_("Do a look up that will hit the last segment for instrument NINST"
	    "-1 in CK 10, relying on tolerance to catch the segment.", (ftnlen)
	    119);
    ckno = 10;
    inst = 3;
    i__ = 100;
    j = (inst - 1) * 100 + i__;
    ids[(i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("ids", i__2, "f_ck"
	    "bsr__", (ftnlen)3329)] = inst;
    tbegs[(i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbegs", i__2, 
	    "f_ckbsr__", (ftnlen)3331)] = (doublereal) (ckno * 10000 + i__ - 
	    1);
    tends[(i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tends", i__2, 
	    "f_ckbsr__", (ftnlen)3333)] = tbegs[(i__1 = j - 1) < 400 && 0 <= 
	    i__1 ? i__1 : s_rnge("tbegs", i__1, "f_ckbsr__", (ftnlen)3333)] + 
	    1;
    s_copy(xsegid + ((i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("xseg"
	    "id", i__2, "f_ckbsr__", (ftnlen)3335)) * 40, "File: # Segno: #  "
	    "Inst:  #", (ftnlen)40, (ftnlen)26);
    repmc_(xsegid + ((i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("xseg"
	    "id", i__2, "f_ckbsr__", (ftnlen)3337)) * 40, "#", cks + ((i__1 = 
	    ckno - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge("cks", i__1, "f_ckbs"
	    "r__", (ftnlen)3337)) * 255, xsegid + ((i__3 = j - 1) < 400 && 0 <=
	     i__3 ? i__3 : s_rnge("xsegid", i__3, "f_ckbsr__", (ftnlen)3337)) 
	    * 40, (ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
    repmi_(xsegid + ((i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("xseg"
	    "id", i__2, "f_ckbsr__", (ftnlen)3338)) * 40, "#", &j, xsegid + ((
	    i__1 = j - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("xsegid", i__1, 
	    "f_ckbsr__", (ftnlen)3338)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)
	    40);
    repmi_(xsegid + ((i__2 = j - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("xseg"
	    "id", i__2, "f_ckbsr__", (ftnlen)3339)) * 40, "#", &inst, xsegid + 
	    ((i__1 = j - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("xsegid", i__1,
	     "f_ckbsr__", (ftnlen)3339)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)
	    40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    segno = j;
    t_crckds__(&segno, &inst, &tbegs[(i__2 = segno - 1) < 400 && 0 <= i__2 ? 
	    i__2 : s_rnge("tbegs", i__2, "f_ckbsr__", (ftnlen)3344)], &tends[(
	    i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("tends", 
	    i__1, "f_ckbsr__", (ftnlen)3344)], xdescr, &c_true);
    tol = .1;
    for (i__ = 1; i__ <= 3; ++i__) {
	d__1 = tends[(i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
		"tends", i__2, "f_ckbsr__", (ftnlen)3352)] + .01;
	t_cbs__(&inst, &d__1, &tol, &c_true);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	t_csn__(&handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        In this case, the segment should be found.  Make sure */
/*        we get back the right handle and segment identifier. */

	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	chcksi_("HANDLE", &handle, "=", &hndles[(i__2 = ckno - 1) < 15 && 0 <=
		 i__2 ? i__2 : s_rnge("hndles", i__2, "f_ckbsr__", (ftnlen)
		3362)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	chcksc_("SEGID", segid, "=", xsegid + ((i__2 = segno - 1) < 400 && 0 
		<= i__2 ? i__2 : s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)
		3363)) * 40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (ftnlen)40)
		;

/*        Check the descriptor as well.  However, don't check the */
/*        segment addresses. */

	t_chds__("DESCR", descr, "=", xdescr, &c__4, &c_b15, ok, (ftnlen)5, (
		ftnlen)1);
    }
    tcase_("Make sure presence of a.v. data is not considered for lookups fo"
	    "r which T_CBS was supplied a \"need a.v.\" flag of .FALSE.", (
	    ftnlen)120);

/*     Now check that segments w/o angular velocity are handled */
/*     correctly.  Create a CK file with STSIZE segments for */
/*     instrument 1.  For N = 1, ... STSIZE/2, the segments */
/*     indexed 2N-1 have no angular velocity, while the segments */
/*     indexed 2N do have angular velocity. */


/*     Create a CK file with STSIZE segments for instruments 1-NINST. */

    ckno = 12;
    inst = 1;
    i__1 = nseg[(i__2 = ckno - 1) < 15 && 0 <= i__2 ? i__2 : s_rnge("nseg", 
	    i__2, "f_ckbsr__", (ftnlen)3394)];
    for (segno = 1; segno <= i__1; ++segno) {
	ids[(i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("ids", i__2,
		 "f_ckbsr__", (ftnlen)3396)] = inst;
	tbegs[(i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbegs", 
		i__2, "f_ckbsr__", (ftnlen)3398)] = (doublereal) (ckno * 
		10000 + segno - 1);
	tends[(i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tends", 
		i__2, "f_ckbsr__", (ftnlen)3399)] = tbegs[(i__3 = segno - 1) <
		 400 && 0 <= i__3 ? i__3 : s_rnge("tbegs", i__3, "f_ckbsr__", 
		(ftnlen)3399)] + 1;
	s_copy(xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)3401)) * 40, 
		"File: # Segno: #  Inst:  #", (ftnlen)40, (ftnlen)26);
	repmc_(xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)3403)) * 40, 
		"#", cks + ((i__3 = ckno - 1) < 15 && 0 <= i__3 ? i__3 : 
		s_rnge("cks", i__3, "f_ckbsr__", (ftnlen)3403)) * 255, xsegid 
		+ ((i__4 = segno - 1) < 400 && 0 <= i__4 ? i__4 : s_rnge(
		"xsegid", i__4, "f_ckbsr__", (ftnlen)3403)) * 40, (ftnlen)40, 
		(ftnlen)1, (ftnlen)255, (ftnlen)40);
	repmi_(xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)3404)) * 40, 
		"#", &segno, xsegid + ((i__3 = segno - 1) < 400 && 0 <= i__3 ?
		 i__3 : s_rnge("xsegid", i__3, "f_ckbsr__", (ftnlen)3404)) * 
		40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	repmi_(xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : 
		s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)3405)) * 40, 
		"#", &inst, xsegid + ((i__3 = segno - 1) < 400 && 0 <= i__3 ? 
		i__3 : s_rnge("xsegid", i__3, "f_ckbsr__", (ftnlen)3405)) * 
		40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	avflag = even_(&segno);
	t_crckds__(&segno, &ids[(i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 :
		 s_rnge("ids", i__2, "f_ckbsr__", (ftnlen)3410)], &tbegs[(
		i__3 = segno - 1) < 400 && 0 <= i__3 ? i__3 : s_rnge("tbegs", 
		i__3, "f_ckbsr__", (ftnlen)3410)], &tends[(i__4 = segno - 1) <
		 400 && 0 <= i__4 ? i__4 : s_rnge("tends", i__4, "f_ckbsr__", 
		(ftnlen)3410)], &xdescr[(i__5 = segno * 5 - 5) < 2000 && 0 <= 
		i__5 ? i__5 : s_rnge("xdescr", i__5, "f_ckbsr__", (ftnlen)
		3410)], &avflag);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Create the CK directly, since we want to have control over the */
/*     value of the a.v. flag. */

    ckopn_(cks + ((i__1 = ckno - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge("cks", 
	    i__1, "f_ckbsr__", (ftnlen)3422)) * 255, " ", &c__0, &hndles[(
	    i__2 = ckno - 1) < 15 && 0 <= i__2 ? i__2 : s_rnge("hndles", i__2,
	     "f_ckbsr__", (ftnlen)3422)], (ftnlen)255, (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    i__2 = nseg[(i__1 = ckno - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge("nseg", 
	    i__1, "f_ckbsr__", (ftnlen)3425)];
    for (segno = 1; segno <= i__2; ++segno) {
	dafbna_(&hndles[(i__1 = ckno - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge(
		"hndles", i__1, "f_ckbsr__", (ftnlen)3427)], &xdescr[(i__3 = 
		segno * 5 - 5) < 2000 && 0 <= i__3 ? i__3 : s_rnge("xdescr", 
		i__3, "f_ckbsr__", (ftnlen)3427)], xsegid + ((i__4 = segno - 
		1) < 400 && 0 <= i__4 ? i__4 : s_rnge("xsegid", i__4, "f_ckb"
		"sr__", (ftnlen)3427)) * 40, (ftnlen)40);
	dafena_();
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    ckcls_(&hndles[(i__2 = ckno - 1) < 15 && 0 <= i__2 ? i__2 : s_rnge("hndl"
	    "es", i__2, "f_ckbsr__", (ftnlen)3433)]);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Unload all files. */

    for (i__ = 1; i__ <= 15; ++i__) {
	t_cuf__(&hndles[(i__2 = i__ - 1) < 15 && 0 <= i__2 ? i__2 : s_rnge(
		"hndles", i__2, "f_ckbsr__", (ftnlen)3441)]);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    for (i__ = 1; i__ <= 110; ++i__) {
	t_cuf__(&cpyhan[(i__2 = i__ - 1) < 110 && 0 <= i__2 ? i__2 : s_rnge(
		"cpyhan", i__2, "f_ckbsr__", (ftnlen)3448)]);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
/*     Let's look up data without requiring a.v. */

    t_clf__(cks + ((i__2 = ckno - 1) < 15 && 0 <= i__2 ? i__2 : s_rnge("cks", 
	    i__2, "f_ckbsr__", (ftnlen)3456)) * 255, &hndles[(i__1 = ckno - 1)
	     < 15 && 0 <= i__1 ? i__1 : s_rnge("hndles", i__1, "f_ckbsr__", (
	    ftnlen)3456)], (ftnlen)255);
    i__1 = nseg[(i__2 = ckno - 1) < 15 && 0 <= i__2 ? i__2 : s_rnge("nseg", 
	    i__2, "f_ckbsr__", (ftnlen)3458)];
    for (segno = 1; segno <= i__1; ++segno) {
	d__1 = tbegs[(i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
		"tbegs", i__2, "f_ckbsr__", (ftnlen)3460)] + .5;
	t_cbs__(&inst, &d__1, &c_b15, &c_false);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	t_csn__(&handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        In this case, the segment should be found.  Make sure */
/*        we get back the right handle and segment identifier. */

	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	chcksi_("HANDLE", &handle, "=", &hndles[(i__2 = ckno - 1) < 15 && 0 <=
		 i__2 ? i__2 : s_rnge("hndles", i__2, "f_ckbsr__", (ftnlen)
		3470)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	chcksc_("SEGID", segid, "=", xsegid + ((i__2 = segno - 1) < 400 && 0 
		<= i__2 ? i__2 : s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)
		3471)) * 40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (ftnlen)40)
		;

/*        Check the descriptor as well.  However, don't check the */
/*        segment addresses. */

	t_chds__("DESCR", descr, "=", &xdescr[(i__2 = segno * 5 - 5) < 2000 &&
		 0 <= i__2 ? i__2 : s_rnge("xdescr", i__2, "f_ckbsr__", (
		ftnlen)3477)], &c__4, &c_b15, ok, (ftnlen)5, (ftnlen)1);
    }
    tcase_("Now make sure that segments without a.v. are not seen when a.v. "
	    "is requested.", (ftnlen)77);

/*     Repeat, now requiring a.v. */

    i__2 = nseg[(i__1 = ckno - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge("nseg", 
	    i__1, "f_ckbsr__", (ftnlen)3490)];
    for (segno = 1; segno <= i__2; ++segno) {
	d__1 = tbegs[(i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge(
		"tbegs", i__1, "f_ckbsr__", (ftnlen)3492)] + .5;
	t_cbs__(&inst, &d__1, &c_b15, &c_true);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	t_csn__(&handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        In this case, the segment should be found.  Make sure */
/*        we get back the right handle and segment identifier. */

	L__1 = even_(&segno);
	chcksl_("FOUND", &found, &L__1, ok, (ftnlen)5);
	if (found) {
	    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = ckno - 1) < 15 && 
		    0 <= i__1 ? i__1 : s_rnge("hndles", i__1, "f_ckbsr__", (
		    ftnlen)3505)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	    chcksc_("SEGID", segid, "=", xsegid + ((i__1 = segno - 1) < 400 &&
		     0 <= i__1 ? i__1 : s_rnge("xsegid", i__1, "f_ckbsr__", (
		    ftnlen)3506)) * 40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, 
		    (ftnlen)40);

/*           Check the descriptor as well.  However, don't check the */
/*           segment addresses. */

	    t_chds__("DESCR", descr, "=", &xdescr[(i__1 = segno * 5 - 5) < 
		    2000 && 0 <= i__1 ? i__1 : s_rnge("xdescr", i__1, "f_ckb"
		    "sr__", (ftnlen)3511)], &c__4, &c_b15, ok, (ftnlen)5, (
		    ftnlen)1);
	}
    }
    tcase_("Repeat the previous tests after loading CK2. This requires the s"
	    "earch to be performed on a partial segment list.", (ftnlen)112);
    t_clf__(cks + 255, &hndles[1], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    i__1 = nseg[(i__2 = ckno - 1) < 15 && 0 <= i__2 ? i__2 : s_rnge("nseg", 
	    i__2, "f_ckbsr__", (ftnlen)3528)];
    for (segno = 1; segno <= i__1; ++segno) {
	d__1 = tbegs[(i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
		"tbegs", i__2, "f_ckbsr__", (ftnlen)3530)] + .5;
	t_cbs__(&inst, &d__1, &c_b15, &c_false);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	t_csn__(&handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        In this case, the segment should be found.  Make sure */
/*        we get back the right handle and segment identifier. */

	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	chcksi_("HANDLE", &handle, "=", &hndles[(i__2 = ckno - 1) < 15 && 0 <=
		 i__2 ? i__2 : s_rnge("hndles", i__2, "f_ckbsr__", (ftnlen)
		3540)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	chcksc_("SEGID", segid, "=", xsegid + ((i__2 = segno - 1) < 400 && 0 
		<= i__2 ? i__2 : s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)
		3541)) * 40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (ftnlen)40)
		;

/*        Check the descriptor as well.  However, don't check the */
/*        segment addresses. */

	t_chds__("DESCR", descr, "=", &xdescr[(i__2 = segno * 5 - 5) < 2000 &&
		 0 <= i__2 ? i__2 : s_rnge("xdescr", i__2, "f_ckbsr__", (
		ftnlen)3547)], &c__4, &c_b15, ok, (ftnlen)5, (ftnlen)1);
    }

/*     Repeat, now requiring a.v. */

    i__2 = nseg[(i__1 = ckno - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge("nseg", 
	    i__1, "f_ckbsr__", (ftnlen)3557)];
    for (segno = 1; segno <= i__2; ++segno) {
	d__1 = tbegs[(i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge(
		"tbegs", i__1, "f_ckbsr__", (ftnlen)3559)] + .5;
	t_cbs__(&inst, &d__1, &c_b15, &c_true);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	t_csn__(&handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        In this case, the segment should be found.  Make sure */
/*        we get back the right handle and segment identifier. */

	L__1 = even_(&segno);
	chcksl_("FOUND", &found, &L__1, ok, (ftnlen)5);
	if (found) {
	    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = ckno - 1) < 15 && 
		    0 <= i__1 ? i__1 : s_rnge("hndles", i__1, "f_ckbsr__", (
		    ftnlen)3572)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	    chcksc_("SEGID", segid, "=", xsegid + ((i__1 = segno - 1) < 400 &&
		     0 <= i__1 ? i__1 : s_rnge("xsegid", i__1, "f_ckbsr__", (
		    ftnlen)3573)) * 40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, 
		    (ftnlen)40);

/*           Check the descriptor as well.  However, don't check the */
/*           segment addresses. */

	    t_chds__("DESCR", descr, "=", &xdescr[(i__1 = segno * 5 - 5) < 
		    2000 && 0 <= i__1 ? i__1 : s_rnge("xdescr", i__1, "f_ckb"
		    "sr__", (ftnlen)3578)], &c__4, &c_b15, ok, (ftnlen)5, (
		    ftnlen)1);
	}
    }
    tcase_("Repeat the previous tests after loading CK10. This requires the "
	    "search to be performed on an unbuffered file (CK12).", (ftnlen)
	    116);
    t_clf__(cks + 2295, &hndles[9], (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    i__1 = nseg[(i__2 = ckno - 1) < 15 && 0 <= i__2 ? i__2 : s_rnge("nseg", 
	    i__2, "f_ckbsr__", (ftnlen)3593)];
    for (segno = 1; segno <= i__1; ++segno) {
	d__1 = tbegs[(i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge(
		"tbegs", i__2, "f_ckbsr__", (ftnlen)3595)] + .5;
	t_cbs__(&inst, &d__1, &c_b15, &c_false);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	t_csn__(&handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        In this case, the segment should be found.  Make sure */
/*        we get back the right handle and segment identifier. */

	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	chcksi_("HANDLE", &handle, "=", &hndles[(i__2 = ckno - 1) < 15 && 0 <=
		 i__2 ? i__2 : s_rnge("hndles", i__2, "f_ckbsr__", (ftnlen)
		3605)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	chcksc_("SEGID", segid, "=", xsegid + ((i__2 = segno - 1) < 400 && 0 
		<= i__2 ? i__2 : s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)
		3606)) * 40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, (ftnlen)40)
		;

/*        Check the descriptor as well.  However, don't check the */
/*        segment addresses. */

	t_chds__("DESCR", descr, "=", &xdescr[(i__2 = segno * 5 - 5) < 2000 &&
		 0 <= i__2 ? i__2 : s_rnge("xdescr", i__2, "f_ckbsr__", (
		ftnlen)3612)], &c__4, &c_b15, ok, (ftnlen)5, (ftnlen)1);
    }

/*     Repeat, now requiring a.v. */

    i__2 = nseg[(i__1 = ckno - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge("nseg", 
	    i__1, "f_ckbsr__", (ftnlen)3621)];
    for (segno = 1; segno <= i__2; ++segno) {
	d__1 = tbegs[(i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge(
		"tbegs", i__1, "f_ckbsr__", (ftnlen)3623)] + .5;
	t_cbs__(&inst, &d__1, &c_b15, &c_true);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	t_csn__(&handle, descr, segid, &found, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        In this case, the segment should be found.  Make sure */
/*        we get back the right handle and segment identifier. */

	L__1 = even_(&segno);
	chcksl_("FOUND", &found, &L__1, ok, (ftnlen)5);
	if (found) {
	    chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = ckno - 1) < 15 && 
		    0 <= i__1 ? i__1 : s_rnge("hndles", i__1, "f_ckbsr__", (
		    ftnlen)3636)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	    chcksc_("SEGID", segid, "=", xsegid + ((i__1 = segno - 1) < 400 &&
		     0 <= i__1 ? i__1 : s_rnge("xsegid", i__1, "f_ckbsr__", (
		    ftnlen)3637)) * 40, ok, (ftnlen)5, (ftnlen)40, (ftnlen)1, 
		    (ftnlen)40);

/*           Check the descriptor as well.  However, don't check the */
/*           segment addresses. */

	    t_chds__("DESCR", descr, "=", &xdescr[(i__1 = segno * 5 - 5) < 
		    2000 && 0 <= i__1 ? i__1 : s_rnge("xdescr", i__1, "f_ckb"
		    "sr__", (ftnlen)3642)], &c__4, &c_b15, ok, (ftnlen)5, (
		    ftnlen)1);
	}
    }
    tcase_("Test our ability to resume searches after a segment is found.  R"
	    "esume searches of the normal segment list, partial list, and of "
	    "an unbuffered file.", (ftnlen)147);

/*     Create files to be used in continued searches.  All segments */
/*     in these files have identical coverage. */

    for (ckno = 13; ckno <= 15; ++ckno) {
	inst = 1;
	i__1 = nseg[(i__2 = ckno - 1) < 15 && 0 <= i__2 ? i__2 : s_rnge("nseg"
		, i__2, "f_ckbsr__", (ftnlen)3663)];
	for (segno = 1; segno <= i__1; ++segno) {
	    ids[(i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("ids", 
		    i__2, "f_ckbsr__", (ftnlen)3665)] = inst;
	    tbegs[(i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("tbe"
		    "gs", i__2, "f_ckbsr__", (ftnlen)3667)] = 129999.;
	    tends[(i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : s_rnge("ten"
		    "ds", i__2, "f_ckbsr__", (ftnlen)3668)] = tbegs[(i__3 = 
		    segno - 1) < 400 && 0 <= i__3 ? i__3 : s_rnge("tbegs", 
		    i__3, "f_ckbsr__", (ftnlen)3668)] + 1;
	    s_copy(xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : 
		    s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)3670)) * 40, 
		    "File: # Segno: #  Inst:  #", (ftnlen)40, (ftnlen)26);
	    repmc_(xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : 
		    s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)3672)) * 40, 
		    "#", cks + ((i__3 = ckno - 1) < 15 && 0 <= i__3 ? i__3 : 
		    s_rnge("cks", i__3, "f_ckbsr__", (ftnlen)3672)) * 255, 
		    xsegid + ((i__4 = segno - 1) < 400 && 0 <= i__4 ? i__4 : 
		    s_rnge("xsegid", i__4, "f_ckbsr__", (ftnlen)3672)) * 40, (
		    ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
	    repmi_(xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : 
		    s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)3673)) * 40, 
		    "#", &segno, xsegid + ((i__3 = segno - 1) < 400 && 0 <= 
		    i__3 ? i__3 : s_rnge("xsegid", i__3, "f_ckbsr__", (ftnlen)
		    3673)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	    repmi_(xsegid + ((i__2 = segno - 1) < 400 && 0 <= i__2 ? i__2 : 
		    s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)3674)) * 40, 
		    "#", &inst, xsegid + ((i__3 = segno - 1) < 400 && 0 <= 
		    i__3 ? i__3 : s_rnge("xsegid", i__3, "f_ckbsr__", (ftnlen)
		    3674)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	}
	t_crdaf__("CK", cks + ((i__1 = ckno - 1) < 15 && 0 <= i__1 ? i__1 : 
		s_rnge("cks", i__1, "f_ckbsr__", (ftnlen)3679)) * 255, &nseg[(
		i__2 = ckno - 1) < 15 && 0 <= i__2 ? i__2 : s_rnge("nseg", 
		i__2, "f_ckbsr__", (ftnlen)3679)], ids, tbegs, tends, xsegid, 
		(ftnlen)2, (ftnlen)255, (ftnlen)40);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Load the files. */

    for (ckno = 13; ckno <= 15; ++ckno) {
	t_clf__(cks + ((i__1 = ckno - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge(
		"cks", i__1, "f_ckbsr__", (ftnlen)3691)) * 255, &hndles[(i__2 
		= ckno - 1) < 15 && 0 <= i__2 ? i__2 : s_rnge("hndles", i__2, 
		"f_ckbsr__", (ftnlen)3691)], (ftnlen)255);
    }

/*     Start the search. */

    d__1 = tbegs[0] + .5;
    t_cbs__(&inst, &d__1, &c_b15, &c_true);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    for (ckno = 15; ckno >= 13; --ckno) {
	for (segno = nseg[(i__1 = ckno - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge(
		"nseg", i__1, "f_ckbsr__", (ftnlen)3702)]; segno >= 1; 
		--segno) {
	    s_copy(xsegid + ((i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : 
		    s_rnge("xsegid", i__1, "f_ckbsr__", (ftnlen)3704)) * 40, 
		    "File: # Segno: #  Inst:  #", (ftnlen)40, (ftnlen)26);
	    repmc_(xsegid + ((i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : 
		    s_rnge("xsegid", i__1, "f_ckbsr__", (ftnlen)3705)) * 40, 
		    "#", cks + ((i__2 = ckno - 1) < 15 && 0 <= i__2 ? i__2 : 
		    s_rnge("cks", i__2, "f_ckbsr__", (ftnlen)3705)) * 255, 
		    xsegid + ((i__3 = segno - 1) < 400 && 0 <= i__3 ? i__3 : 
		    s_rnge("xsegid", i__3, "f_ckbsr__", (ftnlen)3705)) * 40, (
		    ftnlen)40, (ftnlen)1, (ftnlen)255, (ftnlen)40);
	    repmi_(xsegid + ((i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : 
		    s_rnge("xsegid", i__1, "f_ckbsr__", (ftnlen)3706)) * 40, 
		    "#", &segno, xsegid + ((i__2 = segno - 1) < 400 && 0 <= 
		    i__2 ? i__2 : s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)
		    3706)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	    repmi_(xsegid + ((i__1 = segno - 1) < 400 && 0 <= i__1 ? i__1 : 
		    s_rnge("xsegid", i__1, "f_ckbsr__", (ftnlen)3707)) * 40, 
		    "#", &inst, xsegid + ((i__2 = segno - 1) < 400 && 0 <= 
		    i__2 ? i__2 : s_rnge("xsegid", i__2, "f_ckbsr__", (ftnlen)
		    3707)) * 40, (ftnlen)40, (ftnlen)1, (ftnlen)40);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           The segment should be found.  Make sure */
/*           we get back the right handle and segment identifier. */

	    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	    if (found) {
		chcksi_("HANDLE", &handle, "=", &hndles[(i__1 = ckno - 1) < 
			15 && 0 <= i__1 ? i__1 : s_rnge("hndles", i__1, "f_c"
			"kbsr__", (ftnlen)3721)], &c__0, ok, (ftnlen)6, (
			ftnlen)1);
		chcksc_("SEGID", segid, "=", xsegid + ((i__1 = segno - 1) < 
			400 && 0 <= i__1 ? i__1 : s_rnge("xsegid", i__1, 
			"f_ckbsr__", (ftnlen)3722)) * 40, ok, (ftnlen)5, (
			ftnlen)40, (ftnlen)1, (ftnlen)40);

/*              Check the descriptor as well.  However, don't check the */
/*              segment addresses. */

		t_crckds__(&segno, &ids[(i__1 = segno - 1) < 400 && 0 <= i__1 
			? i__1 : s_rnge("ids", i__1, "f_ckbsr__", (ftnlen)
			3727)], &tbegs[(i__2 = segno - 1) < 400 && 0 <= i__2 ?
			 i__2 : s_rnge("tbegs", i__2, "f_ckbsr__", (ftnlen)
			3727)], &tends[(i__3 = segno - 1) < 400 && 0 <= i__3 ?
			 i__3 : s_rnge("tends", i__3, "f_ckbsr__", (ftnlen)
			3727)], &xdescr[(i__4 = segno * 5 - 5) < 2000 && 0 <= 
			i__4 ? i__4 : s_rnge("xdescr", i__4, "f_ckbsr__", (
			ftnlen)3727)], &c_true);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		t_chds__("DESCR", descr, "=", &xdescr[(i__1 = segno * 5 - 5) <
			 2000 && 0 <= i__1 ? i__1 : s_rnge("xdescr", i__1, 
			"f_ckbsr__", (ftnlen)3733)], &c__4, &c_b15, ok, (
			ftnlen)5, (ftnlen)1);
	    }
	}
    }

/*     Finally, we should end up with FOUND = .FALSE. */

    t_csn__(&handle, descr, segid, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);

/*     Last step:  delete all of the CK files we created. */

    for (i__ = 1; i__ <= 15; ++i__) {
	t_cuf__(&hndles[(i__1 = i__ - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge(
		"hndles", i__1, "f_ckbsr__", (ftnlen)3756)]);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	delfil_(cks + ((i__1 = i__ - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge(
		"cks", i__1, "f_ckbsr__", (ftnlen)3759)) * 255, (ftnlen)255);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    for (i__ = 1; i__ <= 110; ++i__) {
	t_cuf__(&cpyhan[(i__1 = i__ - 1) < 110 && 0 <= i__1 ? i__1 : s_rnge(
		"cpyhan", i__1, "f_ckbsr__", (ftnlen)3766)]);
	delfil_(ckcpy + ((i__1 = i__ - 1) < 110 && 0 <= i__1 ? i__1 : s_rnge(
		"ckcpy", i__1, "f_ckbsr__", (ftnlen)3767)) * 255, (ftnlen)255)
		;
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    t_success__(ok);
    return 0;
} /* f_ckbsr__ */

