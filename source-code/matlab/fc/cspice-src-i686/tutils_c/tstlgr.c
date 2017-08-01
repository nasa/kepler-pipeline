/* tstlgr.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__2 = 2;
static integer c__14 = 14;

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

/* Subroutine */ int tstlgr_0_(int n__, char *messge, logical *errlog, char *
	gstyle, char *fstyle, char *marker, integer *int__, doublereal *dp, 
	ftnlen messge_len, ftnlen gstyle_len, ftnlen fstyle_len, ftnlen 
	marker_len)
{
    /* Initialized data */

    static logical opnerr = TRUE_;
    static logical show = FALSE_;
    static char extra[520] = "                                              "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                          ";
    static char seen[128] = "LEFT 1 RIGHT 78                                "
	    "                                                                "
	    "                 ";
    static char hide[128] = "LEFT 1 RIGHT 78                                "
	    "                                                                "
	    "                 ";
    static char mymark[1] = "#";

    /* System generated locals */
    address a__1[2];
    integer i__1[2];
    char ch__1[41];

    /* Builtin functions */
    /* Subroutine */ int s_cat(char *, char **, integer *, integer *, ftnlen);
    integer s_cmp(char *, char *, ftnlen, ftnlen);
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    static char name__[32], time[80];
    static integer fnum, pnum;
    extern /* Subroutine */ int t_fcount__(integer *);
    static integer r__;
    static char cname[520];
    extern /* Subroutine */ int repmc_(char *, char *, char *, char *, ftnlen,
	     ftnlen, ftnlen, ftnlen), repmd_(char *, char *, doublereal *, 
	    integer *, char *, ftnlen, ftnlen, ftnlen), repmf_(char *, char *,
	     doublereal *, integer *, char *, char *, ftnlen, ftnlen, ftnlen, 
	    ftnlen), repmi_(char *, char *, integer *, char *, ftnlen, ftnlen,
	     ftnlen);
    extern integer rtrim_(char *, ftnlen);
    static char versn[80];
    extern /* Subroutine */ int t_name__(char *, ftnlen);
    static char errfil[255];
    extern /* Subroutine */ int repmct_(char *, char *, integer *, char *, 
	    char *, ftnlen, ftnlen, ftnlen, ftnlen);
    extern logical verbos_(void);
    extern /* Subroutine */ int tstioa_(char *, ftnlen), tstfil_(char *, char 
	    *, char *, ftnlen, ftnlen, ftnlen), tstget_(char *, char *, char *
	    , ftnlen, ftnlen, ftnlen), tstioh_(char *, ftnlen), repmot_(char *
	    , char *, integer *, char *, char *, ftnlen, ftnlen, ftnlen, 
	    ftnlen), tstwln_(char *, ftnlen), t_cfail__(void), t_cname__(char 
	    *, ftnlen);
    static char env[80];
    extern /* Subroutine */ int nicepr_1__(char *, char *, S_fp, ftnlen, 
	    ftnlen);


/* $ Version */

/* -     Test Utilities Version 1.2.1, 30-DEC-2002 (EDW) */

/*         Corrected several spelling errors. */

/* -     Test Utilities Version 1.2.0, 19-JUN-2001 (WLT) */

/*         Added an entry point that turns off the test message.  This */
/*         should be called only by TCASE. */

/* -     Test Utilities Version 1.1.0, 18-JUN-1999 (WLT) */

/*         Added a return before the first entry point. */

/* -     Test Utilities Version 1.0.0, 3-NOV-1994 (WLT) */



/*     Save the contents of the command to a log file and any save */
/*     file that might be open and active. */


/*     Test Utility Functions. */


/*     SPICELIB Functions */


/*     Local Variables */

    switch(n__) {
	case 1: goto L_tstlog;
	case 2: goto L_tstlgs;
	case 3: goto L_tststy;
	case 4: goto L_vrblog;
	case 5: goto L_tstmsg;
	case 6: goto L_tstmsi;
	case 7: goto L_tstmsd;
	case 8: goto L_tstmsf;
	case 9: goto L_tstmsc;
	case 10: goto L_tstmso;
	case 11: goto L_tstmst;
	case 12: goto L_tstmof;
	}

    return 0;

/*     This entry point handles the logging of commands. */


L_tstlog:

/* $ Version */

/* -     Test Utilities Version 1.0.0, 3-NOV-1994 (WLT) */

    if (*errlog) {

/*        We need to possibly open a log file and write some */
/*        special additional information if this is the first */
/*        message for this test case. */

	t_name__(name__, (ftnlen)32);
	t_cname__(cname, (ftnlen)520);
	t_fcount__(&pnum);
	t_cfail__();
	t_fcount__(&fnum);
	if (opnerr) {
	    opnerr = FALSE_;
	    tstfil_("ERR{0-9}{0-9}{0-9}{0-9}.LOG", "SAVE", errfil, (ftnlen)27,
		     (ftnlen)4, (ftnlen)255);
	    tstget_(env, versn, time, (ftnlen)80, (ftnlen)80, (ftnlen)80);
	    tstioa_("SAVE", (ftnlen)4);
	    tstioh_("SCREEN", (ftnlen)6);
	    tstioh_("LOG", (ftnlen)3);
	    tstwln_(env, (ftnlen)80);
	    tstwln_(versn, (ftnlen)80);
	    tstwln_(time, (ftnlen)80);
	}

/*        Activate the port for reporting errors, inhibit writing to the */
/*        screen or log file. */

	tstioa_("SAVE", (ftnlen)4);
	tstioa_("SCREEN", (ftnlen)6);
	tstioa_("LOG", (ftnlen)3);

/*        If there had been no previous errors reported for this */
/*        family of errors, we create a special message concerning */
/*        this family and case. */

	if (pnum == 0) {
	    tstwln_(" ", (ftnlen)1);
	    tstwln_("A test failure occurred in the test family:", (ftnlen)43)
		    ;
	    tstwln_(" ", (ftnlen)1);
/* Writing concatenation */
	    i__1[0] = 9, a__1[0] = "Family : ";
	    i__1[1] = 32, a__1[1] = name__;
	    s_cat(ch__1, a__1, i__1, &c__2, (ftnlen)41);
	    tstwln_(ch__1, (ftnlen)41);
	    nicepr_1__(cname, "LEFT 1 RIGHT 78 HARDSPACE ^ FLAG CASE^^^:", (
		    S_fp)tstwln_, (ftnlen)520, (ftnlen)41);
	    tstwln_(" ", (ftnlen)1);

/*        If this is the first error message to be reported for this */
/*        test case we note the failure for this test case. */

	} else if (pnum != fnum) {
	    tstwln_(" ", (ftnlen)1);
	    tstwln_("Test Case FAILURE. ", (ftnlen)19);
	    nicepr_1__(cname, "LEFT 1 RIGHT 78 HARDSPACE ^ FLAG CASE^^^:", (
		    S_fp)tstwln_, (ftnlen)520, (ftnlen)41);
	    tstwln_(" ", (ftnlen)1);
	}

/*        Reactivate the screen and log file. */

	tstioa_("SCREEN", (ftnlen)6);
	tstioa_("LOG", (ftnlen)3);
    }
    if (*errlog) {
	if (s_cmp(messge, " ", messge_len, (ftnlen)1) == 0) {
	    tstwln_(" ", (ftnlen)1);
	} else {
	    if (show) {
		nicepr_1__(extra, hide, (S_fp)tstwln_, (ftnlen)520, (ftnlen)
			128);
		show = FALSE_;
		tstwln_(" ", (ftnlen)1);
	    }
	    nicepr_1__(messge, hide, (S_fp)tstwln_, messge_len, (ftnlen)128);
	}
    } else {
	if (s_cmp(messge, " ", messge_len, (ftnlen)1) == 0) {
	    tstwln_(" ", (ftnlen)1);
	} else {
	    nicepr_1__(messge, seen, (S_fp)tstwln_, messge_len, (ftnlen)128);
	}
    }

/*     Inhibit writing to the error log. */

    tstioh_("SAVE", (ftnlen)4);
    return 0;

/*     This entry point allows users to set the style used for */
/*     logging failure and non-failure and visible commands. */


L_tstlgs:

/* $ Version */

/* -     Test Utilities Version 1.0.0, 3-NOV-1994 (WLT) */


    s_copy(seen, gstyle, (ftnlen)128, gstyle_len);
    s_copy(hide, fstyle, (ftnlen)128, fstyle_len);
    return 0;

/*     This entry point allows users to get the style used for */
/*     logging failure and non-failure and visible commands. */


L_tststy:

/* $ Version */

/* -     Test Utilities Version 1.0.0, 3-NOV-1994 (WLT) */


    s_copy(gstyle, seen, gstyle_len, (ftnlen)128);
    s_copy(fstyle, hide, fstyle_len, (ftnlen)128);
    return 0;

/*     This entry point handles the logging of commands when we want */
/*     only verbose logging. */


L_vrblog:

/* $ Version */

/* -     Test Utilities Version 1.0.0, 3-NOV-1994 (WLT) */

    if (*errlog) {

/*        We need to possibly open a log file and write some */
/*        special additional information if this is the first */
/*        message for this test case. */

	t_name__(name__, (ftnlen)32);
	t_cname__(cname, (ftnlen)520);
	t_fcount__(&pnum);
	t_cfail__();
	t_fcount__(&fnum);
	if (opnerr) {
	    opnerr = FALSE_;
	    tstfil_("ERR{0-9}{0-9}{0-9}{0-9}.LOG", "SAVE", errfil, (ftnlen)27,
		     (ftnlen)4, (ftnlen)255);
	    tstget_(env, versn, time, (ftnlen)80, (ftnlen)80, (ftnlen)80);
	    tstioa_("SAVE", (ftnlen)4);
	    tstioh_("SCREEN", (ftnlen)6);
	    tstioh_("LOG", (ftnlen)3);
	    tstwln_(env, (ftnlen)80);
	    tstwln_(versn, (ftnlen)80);
	    tstwln_(time, (ftnlen)80);
	}

/*        Activate the port for reporting errors, inhibit writing to the */
/*        screen or log file. */

	tstioa_("SAVE", (ftnlen)4);
	tstioa_("SCREEN", (ftnlen)6);
	tstioa_("LOG", (ftnlen)3);

/*        If there had been no previous errors reported for this */
/*        family of errors, we create a special message concerning */
/*        this family and case. */

	if (pnum == 0) {
	    tstwln_(" ", (ftnlen)1);
	    tstwln_("A test failure occurred in the test family:", (ftnlen)43)
		    ;
	    tstwln_(" ", (ftnlen)1);
/* Writing concatenation */
	    i__1[0] = 9, a__1[0] = "Family : ";
	    i__1[1] = 32, a__1[1] = name__;
	    s_cat(ch__1, a__1, i__1, &c__2, (ftnlen)41);
	    tstwln_(ch__1, (ftnlen)41);
	    nicepr_1__(cname, "LEFT 1 RIGHT 78 HARDSPACE ^ FLAG CASE^^^:", (
		    S_fp)tstwln_, (ftnlen)520, (ftnlen)41);
	    tstwln_(" ", (ftnlen)1);

/*        If this is the first error message to be reported for this */
/*        test case we note the failure for this test case. */

	} else if (pnum != fnum) {
	    tstwln_(" ", (ftnlen)1);
	    tstwln_("Test Case FAILURE. ", (ftnlen)19);
	    nicepr_1__(cname, "LEFT 1 RIGHT 78 HARDSPACE ^ FLAG CASE^^^:", (
		    S_fp)tstwln_, (ftnlen)520, (ftnlen)41);
	    tstwln_(" ", (ftnlen)1);
	}

/*        Reactivate the screen and log file. */

	tstioa_("SCREEN", (ftnlen)6);
	tstioa_("LOG", (ftnlen)3);
    }

/*     If there is an error, write to every place. */

    if (*errlog) {
	if (s_cmp(messge, " ", messge_len, (ftnlen)1) == 0) {
	    tstwln_(" ", (ftnlen)1);
	} else {
	    if (show) {
		nicepr_1__(extra, hide, (S_fp)tstwln_, (ftnlen)520, (ftnlen)
			128);
		tstwln_(" ", (ftnlen)1);
		show = FALSE_;
	    }
	    nicepr_1__(messge, hide, (S_fp)tstwln_, messge_len, (ftnlen)128);
	}

/*     Otherwise we write out the message only if in verbose mode. */

    } else if (verbos_()) {
	if (s_cmp(messge, " ", messge_len, (ftnlen)1) == 0) {
	    tstwln_(" ", (ftnlen)1);
	} else {
	    nicepr_1__(messge, seen, (S_fp)tstwln_, messge_len, (ftnlen)128);
	}
    }

/*     Inhibit writing to the error log. */

    tstioh_("SAVE", (ftnlen)4);
    return 0;

/*     Establish a special message to be printed if an error is */
/*     detected. */


L_tstmsg:
    *(unsigned char *)&mymark[0] = *(unsigned char *)marker;
    s_copy(extra, messge, (ftnlen)520, messge_len);
    show = TRUE_;
    return 0;

/*     Fill in the next marker with the string representing INT. */


L_tstmsi:
    repmi_(extra, mymark, int__, extra, (ftnlen)520, (ftnlen)1, (ftnlen)520);
    return 0;

/*     Fill in the next marker with the string representing DP */


L_tstmsd:
    repmd_(extra, mymark, dp, &c__14, extra, (ftnlen)520, (ftnlen)1, (ftnlen)
	    520);
    return 0;

L_tstmsf:
    repmf_(extra, mymark, dp, &c__14, "F", extra, (ftnlen)520, (ftnlen)1, (
	    ftnlen)1, (ftnlen)520);
    return 0;

/*     Fill in the next marker with the character string MESSGE. */


L_tstmsc:
    r__ = rtrim_(messge, messge_len);
    repmc_(extra, mymark, messge, extra, (ftnlen)520, (ftnlen)1, r__, (ftnlen)
	    520);
    return 0;

/*     Fill in the next marker with an ordinal */


L_tstmso:
    if (*(unsigned char *)marker != 'C' && *(unsigned char *)marker != 'c' && 
	    *(unsigned char *)marker != 'l' && *(unsigned char *)marker != 
	    'u' && *(unsigned char *)marker != 'L' && *(unsigned char *)
	    marker != 'U') {
	repmot_(extra, mymark, int__, "l", extra, (ftnlen)520, (ftnlen)1, (
		ftnlen)1, (ftnlen)520);
    } else {
	repmot_(extra, mymark, int__, marker, extra, (ftnlen)520, (ftnlen)1, (
		ftnlen)1, (ftnlen)520);
    }
    return 0;

L_tstmst:
    if (*(unsigned char *)marker != 'C' && *(unsigned char *)marker != 'c' && 
	    *(unsigned char *)marker != 'l' && *(unsigned char *)marker != 
	    'u' && *(unsigned char *)marker != 'L' && *(unsigned char *)
	    marker != 'U') {
	repmct_(extra, mymark, int__, "l", extra, (ftnlen)520, (ftnlen)1, (
		ftnlen)1, (ftnlen)520);
    } else {
	repmct_(extra, mymark, int__, marker, extra, (ftnlen)520, (ftnlen)1, (
		ftnlen)1, (ftnlen)520);
    }
    return 0;

/*    Turn off the test message so that it will not be shown. */


L_tstmof:
    show = FALSE_;
    return 0;
} /* tstlgr_ */

/* Subroutine */ int tstlgr_(char *messge, logical *errlog, char *gstyle, 
	char *fstyle, char *marker, integer *int__, doublereal *dp, ftnlen 
	messge_len, ftnlen gstyle_len, ftnlen fstyle_len, ftnlen marker_len)
{
    return tstlgr_0_(0, messge, errlog, gstyle, fstyle, marker, int__, dp, 
	    messge_len, gstyle_len, fstyle_len, marker_len);
    }

/* Subroutine */ int tstlog_(char *messge, logical *errlog, ftnlen messge_len)
{
    return tstlgr_0_(1, messge, errlog, (char *)0, (char *)0, (char *)0, (
	    integer *)0, (doublereal *)0, messge_len, (ftnint)0, (ftnint)0, (
	    ftnint)0);
    }

/* Subroutine */ int tstlgs_(char *gstyle, char *fstyle, ftnlen gstyle_len, 
	ftnlen fstyle_len)
{
    return tstlgr_0_(2, (char *)0, (logical *)0, gstyle, fstyle, (char *)0, (
	    integer *)0, (doublereal *)0, (ftnint)0, gstyle_len, fstyle_len, (
	    ftnint)0);
    }

/* Subroutine */ int tststy_(char *gstyle, char *fstyle, ftnlen gstyle_len, 
	ftnlen fstyle_len)
{
    return tstlgr_0_(3, (char *)0, (logical *)0, gstyle, fstyle, (char *)0, (
	    integer *)0, (doublereal *)0, (ftnint)0, gstyle_len, fstyle_len, (
	    ftnint)0);
    }

/* Subroutine */ int vrblog_(char *messge, logical *errlog, ftnlen messge_len)
{
    return tstlgr_0_(4, messge, errlog, (char *)0, (char *)0, (char *)0, (
	    integer *)0, (doublereal *)0, messge_len, (ftnint)0, (ftnint)0, (
	    ftnint)0);
    }

/* Subroutine */ int tstmsg_(char *marker, char *messge, ftnlen marker_len, 
	ftnlen messge_len)
{
    return tstlgr_0_(5, messge, (logical *)0, (char *)0, (char *)0, marker, (
	    integer *)0, (doublereal *)0, messge_len, (ftnint)0, (ftnint)0, 
	    marker_len);
    }

/* Subroutine */ int tstmsi_(integer *int__)
{
    return tstlgr_0_(6, (char *)0, (logical *)0, (char *)0, (char *)0, (char *
	    )0, int__, (doublereal *)0, (ftnint)0, (ftnint)0, (ftnint)0, (
	    ftnint)0);
    }

/* Subroutine */ int tstmsd_(doublereal *dp)
{
    return tstlgr_0_(7, (char *)0, (logical *)0, (char *)0, (char *)0, (char *
	    )0, (integer *)0, dp, (ftnint)0, (ftnint)0, (ftnint)0, (ftnint)0);
    }

/* Subroutine */ int tstmsf_(doublereal *dp)
{
    return tstlgr_0_(8, (char *)0, (logical *)0, (char *)0, (char *)0, (char *
	    )0, (integer *)0, dp, (ftnint)0, (ftnint)0, (ftnint)0, (ftnint)0);
    }

/* Subroutine */ int tstmsc_(char *messge, ftnlen messge_len)
{
    return tstlgr_0_(9, messge, (logical *)0, (char *)0, (char *)0, (char *)0,
	     (integer *)0, (doublereal *)0, messge_len, (ftnint)0, (ftnint)0, 
	    (ftnint)0);
    }

/* Subroutine */ int tstmso_(integer *int__, char *marker, ftnlen marker_len)
{
    return tstlgr_0_(10, (char *)0, (logical *)0, (char *)0, (char *)0, 
	    marker, int__, (doublereal *)0, (ftnint)0, (ftnint)0, (ftnint)0, 
	    marker_len);
    }

/* Subroutine */ int tstmst_(integer *int__, char *marker, ftnlen marker_len)
{
    return tstlgr_0_(11, (char *)0, (logical *)0, (char *)0, (char *)0, 
	    marker, int__, (doublereal *)0, (ftnint)0, (ftnint)0, (ftnint)0, 
	    marker_len);
    }

/* Subroutine */ int tstmof_(void)
{
    return tstlgr_0_(12, (char *)0, (logical *)0, (char *)0, (char *)0, (char 
	    *)0, (integer *)0, (doublereal *)0, (ftnint)0, (ftnint)0, (ftnint)
	    0, (ftnint)0);
    }

