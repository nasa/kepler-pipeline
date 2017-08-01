/* chwcml.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__2 = 2;
static integer c_b68 = 1000000;
static integer c__1000 = 1000;
static integer c__17 = 17;
static integer c__0 = 0;
static integer c__6 = 6;
static integer c__60000 = 60000;
static integer c__60002 = 60002;
static doublereal c_b452 = 1e-8;

/* $Procedure      CHWCML ( Extract arguments from SPKDIFF command line ) */
/* Subroutine */ int chwcml_(char *line, char *spk, char *bodnam, integer *
	bodid, char *cennam, integer *cenid, char *frame, char *time, 
	doublereal *et, integer *nitr, doublereal *step, char *diftyp, char *
	timfmt, char *kernls, ftnlen line_len, ftnlen spk_len, ftnlen 
	bodnam_len, ftnlen cennam_len, ftnlen frame_len, ftnlen time_len, 
	ftnlen diftyp_len, ftnlen timfmt_len, ftnlen kernls_len)
{
    /* Initialized data */

    static char clkeys[32*17] = "-b1                             " "-c1     "
	    "                        " "-r1                             " 
	    "-b2                             " "-c2                         "
	    "    " "-r2                             " "-k                    "
	    "          " "-b                              " "-e              "
	    "                " "-n                              " "-s        "
	    "                      " "-f                              " "-t  "
	    "                            " "-usage                          " 
	    "-u                              " "-help                       "
	    "    " "-h                              ";

    /* System generated locals */
    address a__1[2];
    integer i__1, i__2, i__3[2], i__4, i__5;
    doublereal d__1;

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer);
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen), s_cat(char *,
	     char **, integer *, integer *, ftnlen), s_stop(char *, ftnlen);
    integer s_cmp(char *, char *, ftnlen, ftnlen), i_dnnt(doublereal *);

    /* Local variables */
    static char arch[3], type__[3];
    static integer i__;
    extern integer cardd_(doublereal *);
    extern /* Subroutine */ int dafgs_(doublereal *), etcal_(doublereal *, 
	    char *, ftnlen), chkin_(char *, ftnlen);
    static char hline[1024];
    static doublereal descr[5];
    extern /* Subroutine */ int ucase_(char *, char *, ftnlen, ftnlen), 
	    filli_(integer *, integer *, integer *), errch_(char *, char *, 
	    ftnlen, ftnlen), dafus_(doublereal *, integer *, integer *, 
	    doublereal *, integer *), repmc_(char *, char *, char *, char *, 
	    ftnlen, ftnlen, ftnlen, ftnlen);
    extern doublereal dpmin_(void), dpmax_(void);
    static integer nargs;
    static logical found;
    extern /* Subroutine */ int repmi_(char *, char *, integer *, char *, 
	    ftnlen, ftnlen, ftnlen), errdp_(char *, doublereal *, ftnlen);
    extern integer wdcnt_(char *, ftnlen);
    extern /* Subroutine */ int movei_(integer *, integer *, integer *);
    static char hword[32];
    extern /* Subroutine */ int nthwd_(char *, integer *, char *, integer *, 
	    ftnlen, ftnlen);
    static char error[1024];
    extern integer rtrim_(char *, ftnlen);
    extern logical eqstr_(char *, char *, ftnlen, ftnlen);
    extern /* Subroutine */ int bodn2c_(char *, integer *, logical *, ftnlen),
	     bodc2n_(integer *, char *, logical *, ftnlen);
    static doublereal cover1[60006], cover2[60006], dc[2];
    static integer ic[6];
    extern /* Subroutine */ int dafbbs_(integer *), str2et_(char *, 
	    doublereal *, ftnlen), daffpa_(logical *);
    static logical clflag[17];
    static integer handle;
    extern /* Subroutine */ int dafcls_(integer *);
    static integer framid;
    extern /* Subroutine */ int appndd_(doublereal *, doublereal *);
    extern integer isrchc_(char *, integer *, char *, ftnlen, ftnlen);
    extern /* Subroutine */ int getcml_(char *, ftnlen);
    static char clvals[1024*17], kernam[1024];
    static doublereal coverc[60008];
    static integer iclstb[6];
    extern /* Subroutine */ int parcml_(char *, integer *, char *, logical *, 
	    char *, logical *, ftnlen, ftnlen, ftnlen);
    static char clkeyu[32*17];
    extern integer intmax_(void);
    extern logical exists_(char *, ftnlen);
    static char usgmsg[80*23], vermsg[80*3];
    static integer iclstn[6], iclsts[6];
    extern /* Subroutine */ int tkvrsn_(char *, char *, ftnlen, ftnlen), 
	    tostdo_(char *, ftnlen), getfat_(char *, char *, char *, ftnlen, 
	    ftnlen, ftnlen), setmsg_(char *, ftnlen), sigerr_(char *, ftnlen),
	     nextwd_(char *, char *, char *, ftnlen, ftnlen, ftnlen), furnsh_(
	    char *, ftnlen), nparsi_(char *, integer *, char *, integer *, 
	    ftnlen, ftnlen), namfrm_(char *, integer *, ftnlen), errint_(char 
	    *, integer *, ftnlen), dafopr_(char *, integer *, ftnlen), 
	    intstr_(integer *, char *, ftnlen), frmnam_(integer *, char *, 
	    ftnlen), ssized_(integer *, doublereal *), spkcov_(char *, 
	    integer *, doublereal *, ftnlen), wnintd_(doublereal *, 
	    doublereal *, doublereal *), nparsd_(char *, doublereal *, char *,
	     integer *, ftnlen, ftnlen), rmaind_(doublereal *, doublereal *, 
	    doublereal *, doublereal *), chkout_(char *, ftnlen);
    static integer ptr;
    static doublereal hdp1, hdp2;

/* $ Abstract */

/*     Extract arguments from SPKDIFF command line and return them */
/*     and or default values via individual variables. If input command */
/*     line is incomplete or if specific command line keys requesting */
/*     help are specified, this routine displays usage and stops the */
/*     program. */

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

/*     SPKDIFF User's Guide. */

/* $ Keywords */

/*     TBD. */

/* $ Declarations */
/* $ Abstract */

/*     Include Section:  SPKDIFF Global Parameters */

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

/* $ Author_and_Institution */

/*     B.V. Semenov   (JPL) */

/* $ Version */

/* -    Version 1.0.0, 20-JUL-2006 (BVS). */

/* -& */

/*     Program name and version. */


/*     Command line keys. */


/*     Max and min number states that the program can handle. */


/*     Default number states. */


/*     Line size parameters. */


/*     Version/usage display parameters. */


/*     Maximum segment buffer size for Nat's ZZGEOSEG. */


/*     DAF descriptor size and component counts. */


/*     Cell lower boundary. */


/*     Maximum allowed number of coverage windows. */


/*     Smallest allowed step. */

/* $ Brief_I/O */

/*     Variable  I/O  Description */
/*     --------  ---  -------------------------------------------------- */
/*     LINE       I   SPKDIFF command line */
/*     SPK        O   1st and 2nd SPK file names */
/*     BODNAM     O   1st and 2nd body names */
/*     BODID      O   1st and 2nd body IDs */
/*     CENNAM     O   1st and 2nd center names */
/*     CENID      O   1st and 2nd center IDs */
/*     FRAME      O   1st and 2nd frame names */
/*     TIME       O   Start and stop time as strings */
/*     ET         O   Start and stop time as ET seconds */
/*     NITR       O   Number of points to be used in comparison. */
/*     STEP       O   Time step in seconds. */
/*     DIFTYP     O   Type of summary to be generated by SPKDIFF. */
/*     TIMFMT     O   Output time format string "dump" summaries. */
/*     KERNLS     O   List of additional kernels. */

/* $ Detailed_Input */

/*     LINE        is the command line provided to SPKDIFF. See SPKDIFF */
/*                 User's Guide for the command line syntax and detailed */
/*                 specification of allowed arguments. */

/* $ Detailed_Output */

/*     SPK         is a two element array containing the names of the */
/*                 first and second SPK files. */

/*     BODNAM      is a two element array containing the names of the */
/*                 first and second bodies, position of which is to be */
/*                 computed. */

/*     BODID       is a two element array containing the ID of the first */
/*                 and second bodies, position of which is to be */
/*                 computed. */

/*     CENNAM      is a two element array containing the names of the */
/*                 first and second bodies, position with respect to */
/*                 which is to be computed. */

/*     CENID       is a two element array containing the IDs of the first */
/*                 and second bodies, position with respect to which is */
/*                 to be computed. */

/*     FRAME       is a two element array containing the names of the */
/*                 first and second frames, in which position is to be */
/*                 computed. */

/*     TIME        is a two element array containing the start and stop */
/*                 times of the comparison interval presented as */
/*                 strings. */

/*     ET          is a two element array containing the start and stop */
/*                 times of the comparison interval presented as */
/*                 ET seconds past J2000. */

/*     NITR        is the number of points to be used in comparison. */

/*     STEP        is the time step in seconds. */

/*     DIFTYP      is a string indicating the type of summary to be */
/*                 generated by SPKDIFF. */

/*     TIMFMT      is a string containing output time format picture for */
/*                 "dump"-type summaries. */

/*     KERNLS      is a string containing the list of additional kernels */
/*                 provided on the command line. */

/* $ Parameters */

/*     See include file. */

/* $ Exceptions */

/*     TBD. */

/* $ Files */

/*     TBD. */

/* $ Particulars */

/*     TBD. */

/* $ Examples */

/*     TBD. */

/* $ Restrictions */

/*     TBD. */

/* $ Literature_References */

/*     TBD. */

/* $ Author_and_Institution */

/*     B.V. Semenov   (JPL) */

/* $ Version */

/* -    Version 1.0.0, 18-APR-2006 (BVS). */

/* -& */

/*     SPICELIB functions */


/*     Local variables. */


/*     Save everything to prevent potential memory problems in f2c'ed */
/*     version. */


/*     Initialize command line keys. */


/*     Check in. */

    chkin_("CHWCML", (ftnlen)6);

/*     Generate uppercase version of command lines keys. */

    for (i__ = 1; i__ <= 17; ++i__) {
	ucase_(clkeys + (((i__1 = i__ - 1) < 17 && 0 <= i__1 ? i__1 : s_rnge(
		"clkeys", i__1, "chwcml_", (ftnlen)269)) << 5), clkeyu + (((
		i__2 = i__ - 1) < 17 && 0 <= i__2 ? i__2 : s_rnge("clkeyu", 
		i__2, "chwcml_", (ftnlen)269)) << 5), (ftnlen)32, (ftnlen)32);
    }

/*     Initialize version display. */

    tkvrsn_("TOOLKIT", hword, (ftnlen)7, (ftnlen)32);
    s_copy(vermsg, " ", (ftnlen)80, (ftnlen)1);
/* Writing concatenation */
    i__3[0] = 59, a__1[0] = "spkdiff -- Version 1.0.0, July 20, 2006 -- Tool"
	    "kit Version ";
    i__3[1] = rtrim_(hword, (ftnlen)32), a__1[1] = hword;
    s_cat(vermsg + 80, a__1, i__3, &c__2, (ftnlen)80);
    s_copy(vermsg + 160, " ", (ftnlen)80, (ftnlen)1);

/*     Initialize usage display. */

    s_copy(usgmsg, "   # computes differences between geometric states obtai"
	    "ned from ", (ftnlen)80, (ftnlen)65);
    s_copy(usgmsg + 80, "   two SPK files and either displays these differen"
	    "ces or shows statistics ", (ftnlen)80, (ftnlen)75);
    s_copy(usgmsg + 160, "   about them (see the User's Guide for more detai"
	    "ls.) The program usage is:", (ftnlen)80, (ftnlen)76);
    s_copy(usgmsg + 240, " ", (ftnlen)80, (ftnlen)1);
    s_copy(usgmsg + 320, "      % # [options] <first SPK file> <second SPK f"
	    "ile>", (ftnlen)80, (ftnlen)54);
    s_copy(usgmsg + 400, " ", (ftnlen)80, (ftnlen)1);
    s_copy(usgmsg + 480, "   Options are shown below. Order and case of keys"
	    " are not significant.", (ftnlen)80, (ftnlen)71);
    s_copy(usgmsg + 560, "   Values must be space-separated from keys, i.e. "
	    "'# 10', not '#10'.", (ftnlen)80, (ftnlen)68);
    s_copy(usgmsg + 640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(usgmsg + 720, "      # <first body name or ID>", (ftnlen)80, (
	    ftnlen)31);
    s_copy(usgmsg + 800, "      # <first center name or ID>", (ftnlen)80, (
	    ftnlen)33);
    s_copy(usgmsg + 880, "      # <first reference frame name>", (ftnlen)80, (
	    ftnlen)36);
    s_copy(usgmsg + 960, "      # <second body name or ID>", (ftnlen)80, (
	    ftnlen)32);
    s_copy(usgmsg + 1040, "      # <second center name or ID>", (ftnlen)80, (
	    ftnlen)34);
    s_copy(usgmsg + 1120, "      # <second reference frame name>", (ftnlen)80,
	     (ftnlen)37);
    s_copy(usgmsg + 1200, "      #  <other kernel file name(s)>", (ftnlen)80, 
	    (ftnlen)36);
    s_copy(usgmsg + 1280, "      #  <interval start time>", (ftnlen)80, (
	    ftnlen)30);
    s_copy(usgmsg + 1360, "      #  <interval stop time>", (ftnlen)80, (
	    ftnlen)29);
    s_copy(usgmsg + 1440, "      #  <time step in seconds>", (ftnlen)80, (
	    ftnlen)31);
    s_copy(usgmsg + 1520, "      #  <number of states: # to # (default: #)>", 
	    (ftnlen)80, (ftnlen)48);
    s_copy(usgmsg + 1600, "      #  <output time format (default: TDB second"
	    "s past J2000)>", (ftnlen)80, (ftnlen)63);
    s_copy(usgmsg + 1680, "      #  <report type: #|#|#|# (default: #)>", (
	    ftnlen)80, (ftnlen)44);
    s_copy(usgmsg + 1760, " ", (ftnlen)80, (ftnlen)1);
    repmc_(usgmsg, "#", "spkdiff", usgmsg, (ftnlen)80, (ftnlen)1, (ftnlen)7, (
	    ftnlen)80);
    repmc_(usgmsg + 320, "#", "spkdiff", usgmsg + 320, (ftnlen)80, (ftnlen)1, 
	    (ftnlen)7, (ftnlen)80);
    repmc_(usgmsg + 560, "#", "-n", usgmsg + 560, (ftnlen)80, (ftnlen)1, (
	    ftnlen)2, (ftnlen)80);
    repmc_(usgmsg + 560, "#", "-n", usgmsg + 560, (ftnlen)80, (ftnlen)1, (
	    ftnlen)2, (ftnlen)80);
    repmc_(usgmsg + 720, "#", "-b1", usgmsg + 720, (ftnlen)80, (ftnlen)1, (
	    ftnlen)3, (ftnlen)80);
    repmc_(usgmsg + 800, "#", "-c1", usgmsg + 800, (ftnlen)80, (ftnlen)1, (
	    ftnlen)3, (ftnlen)80);
    repmc_(usgmsg + 880, "#", "-r1", usgmsg + 880, (ftnlen)80, (ftnlen)1, (
	    ftnlen)3, (ftnlen)80);
    repmc_(usgmsg + 960, "#", "-b2", usgmsg + 960, (ftnlen)80, (ftnlen)1, (
	    ftnlen)3, (ftnlen)80);
    repmc_(usgmsg + 1040, "#", "-c2", usgmsg + 1040, (ftnlen)80, (ftnlen)1, (
	    ftnlen)3, (ftnlen)80);
    repmc_(usgmsg + 1120, "#", "-r2", usgmsg + 1120, (ftnlen)80, (ftnlen)1, (
	    ftnlen)3, (ftnlen)80);
    repmc_(usgmsg + 1200, "#", "-k", usgmsg + 1200, (ftnlen)80, (ftnlen)1, (
	    ftnlen)2, (ftnlen)80);
    repmc_(usgmsg + 1280, "#", "-b", usgmsg + 1280, (ftnlen)80, (ftnlen)1, (
	    ftnlen)2, (ftnlen)80);
    repmc_(usgmsg + 1360, "#", "-e", usgmsg + 1360, (ftnlen)80, (ftnlen)1, (
	    ftnlen)2, (ftnlen)80);
    repmc_(usgmsg + 1440, "#", "-s", usgmsg + 1440, (ftnlen)80, (ftnlen)1, (
	    ftnlen)2, (ftnlen)80);
    repmc_(usgmsg + 1520, "#", "-n", usgmsg + 1520, (ftnlen)80, (ftnlen)1, (
	    ftnlen)2, (ftnlen)80);
    repmi_(usgmsg + 1520, "#", &c__2, usgmsg + 1520, (ftnlen)80, (ftnlen)1, (
	    ftnlen)80);
    repmi_(usgmsg + 1520, "#", &c_b68, usgmsg + 1520, (ftnlen)80, (ftnlen)1, (
	    ftnlen)80);
    repmi_(usgmsg + 1520, "#", &c__1000, usgmsg + 1520, (ftnlen)80, (ftnlen)1,
	     (ftnlen)80);
    repmc_(usgmsg + 1600, "#", "-f", usgmsg + 1600, (ftnlen)80, (ftnlen)1, (
	    ftnlen)2, (ftnlen)80);
    repmc_(usgmsg + 1680, "#", "-t", usgmsg + 1680, (ftnlen)80, (ftnlen)1, (
	    ftnlen)2, (ftnlen)80);
    repmc_(usgmsg + 1680, "#", "basic", usgmsg + 1680, (ftnlen)80, (ftnlen)1, 
	    (ftnlen)5, (ftnlen)80);
    repmc_(usgmsg + 1680, "#", "stats", usgmsg + 1680, (ftnlen)80, (ftnlen)1, 
	    (ftnlen)5, (ftnlen)80);
    repmc_(usgmsg + 1680, "#", "dump", usgmsg + 1680, (ftnlen)80, (ftnlen)1, (
	    ftnlen)4, (ftnlen)80);
    repmc_(usgmsg + 1680, "#", "dumpvf", usgmsg + 1680, (ftnlen)80, (ftnlen)1,
	     (ftnlen)6, (ftnlen)80);
    repmc_(usgmsg + 1680, "#", "basic", usgmsg + 1680, (ftnlen)80, (ftnlen)1, 
	    (ftnlen)5, (ftnlen)80);

/*     Get command line and do first attempt at parsing. All we need to */
/*     find out in this try is if one of the help/usage key variations */
/*     was present. */

    getcml_(line, line_len);
    s_copy(hline, line, (ftnlen)1024, line_len);
    parcml_(hline, &c__17, clkeyu, clflag, clvals, &found, (ftnlen)1024, (
	    ftnlen)32, (ftnlen)1024);

/*     Was command line blank? Is one of the usage or help keys */
/*     present? Display USAGE and STOP if yes. */

    nargs = wdcnt_(line, line_len);
    if (nargs < 2 || clflag[(i__1 = isrchc_("-help", &c__17, clkeys, (ftnlen)
	    5, (ftnlen)32) - 1) < 17 && 0 <= i__1 ? i__1 : s_rnge("clflag", 
	    i__1, "chwcml_", (ftnlen)356)] || clflag[(i__2 = isrchc_("-h", &
	    c__17, clkeys, (ftnlen)2, (ftnlen)32) - 1) < 17 && 0 <= i__2 ? 
	    i__2 : s_rnge("clflag", i__2, "chwcml_", (ftnlen)356)] || clflag[(
	    i__4 = isrchc_("-usage", &c__17, clkeys, (ftnlen)6, (ftnlen)32) - 
	    1) < 17 && 0 <= i__4 ? i__4 : s_rnge("clflag", i__4, "chwcml_", (
	    ftnlen)356)] || clflag[(i__5 = isrchc_("-u", &c__17, clkeys, (
	    ftnlen)2, (ftnlen)32) - 1) < 17 && 0 <= i__5 ? i__5 : s_rnge(
	    "clflag", i__5, "chwcml_", (ftnlen)356)]) {

/*        Display version. */

	for (i__ = 1; i__ <= 3; ++i__) {
	    tostdo_(vermsg + ((i__1 = i__ - 1) < 3 && 0 <= i__1 ? i__1 : 
		    s_rnge("vermsg", i__1, "chwcml_", (ftnlen)366)) * 80, (
		    ftnlen)80);
	}

/*        Display usage and stop. */

	for (i__ = 1; i__ <= 23; ++i__) {
	    tostdo_(usgmsg + ((i__1 = i__ - 1) < 23 && 0 <= i__1 ? i__1 : 
		    s_rnge("usgmsg", i__1, "chwcml_", (ftnlen)373)) * 80, (
		    ftnlen)80);
	}
	s_stop("", (ftnlen)0);
    }

/*     Pull the last and second to last words from the command line. */
/*     These two words are supposed to be the names of the first and */
/*     second SPKs. Then parse what's left of the line again. */

    nthwd_(line, &nargs, spk + spk_len, &ptr, line_len, spk_len);
    i__1 = nargs - 1;
    nthwd_(line, &i__1, spk, &ptr, line_len, spk_len);
    s_copy(line + (ptr - 1), " ", line_len - (ptr - 1), (ftnlen)1);
    s_copy(hline, line, (ftnlen)1024, line_len);
    parcml_(hline, &c__17, clkeyu, clflag, clvals, &found, (ftnlen)1024, (
	    ftnlen)32, (ftnlen)1024);

/*     Check if the first SPK exists and is an SPK. */

    if (exists_(spk, spk_len)) {
	getfat_(spk, arch, type__, spk_len, (ftnlen)3, (ftnlen)3);
	if (! (s_cmp(arch, "DAF", (ftnlen)3, (ftnlen)3) == 0 && s_cmp(type__, 
		"SPK", (ftnlen)3, (ftnlen)3) == 0)) {
	    setmsg_("File '#' specified as the second to last argument on th"
		    "e command line is not an SPK file.", (ftnlen)89);
	    errch_("#", spk, (ftnlen)1, spk_len);
	    sigerr_("SPICE(NOTANSPKFILE1)", (ftnlen)20);
	}
    } else {
	setmsg_("File '#' specified as the second to last  argument on the c"
		"ommand line does not exist.", (ftnlen)86);
	errch_("#", spk, (ftnlen)1, spk_len);
	sigerr_("SPICE(SPK1DOESNOTEXIST)", (ftnlen)23);
    }

/*     Check if the second SPK exists and is an SPK. */

    if (exists_(spk + spk_len, spk_len)) {
	getfat_(spk + spk_len, arch, type__, spk_len, (ftnlen)3, (ftnlen)3);
	if (! (s_cmp(arch, "DAF", (ftnlen)3, (ftnlen)3) == 0 && s_cmp(type__, 
		"SPK", (ftnlen)3, (ftnlen)3) == 0)) {
	    setmsg_("File '#' specified as the last argument on the command "
		    "line is not an SPK file.", (ftnlen)79);
	    errch_("#", spk + spk_len, (ftnlen)1, spk_len);
	    sigerr_("SPICE(NOTANSPKFILE2)", (ftnlen)20);
	}
    } else {
	setmsg_("File '#' specified as the last argument on the command line"
		" does not exist.", (ftnlen)75);
	errch_("#", spk + spk_len, (ftnlen)1, spk_len);
	sigerr_("SPICE(SPK2DOESNOTEXIST)", (ftnlen)23);
    }

/*     Go on processing the rest of the command line. All other */
/*     arguments are optional and, if not present, will have to be set */
/*     to some default values. */


/*     Were any other kernels provided on the command line? We need to */
/*     deal with kernels first because some of them may define frames */
/*     and/or name-ID mappings that are needed to process the rest of */
/*     command line arguments. */

    i__ = isrchc_("-k", &c__17, clkeys, (ftnlen)2, (ftnlen)32);
    if (clflag[(i__1 = i__ - 1) < 17 && 0 <= i__1 ? i__1 : s_rnge("clflag", 
	    i__1, "chwcml_", (ftnlen)452)]) {
	s_copy(kernls, clvals + (((i__1 = i__ - 1) < 17 && 0 <= i__1 ? i__1 : 
		s_rnge("clvals", i__1, "chwcml_", (ftnlen)454)) << 10), 
		kernls_len, (ftnlen)1024);
	if (s_cmp(kernls, " ", kernls_len, (ftnlen)1) != 0) {

/*           Extract other kernels specified on the command line from */
/*           the list and load them one-by-one using FURNSH. */

	    while(s_cmp(kernls, " ", kernls_len, (ftnlen)1) != 0) {
		nextwd_(kernls, kernam, kernls, kernls_len, (ftnlen)1024, 
			kernls_len);
		furnsh_(kernam, (ftnlen)1024);
	    }

/*           Reset kernel list variable; this list will be included into */
/*           some of the reports generated by the program. */

	    s_copy(kernls, clvals + (((i__1 = i__ - 1) < 17 && 0 <= i__1 ? 
		    i__1 : s_rnge("clvals", i__1, "chwcml_", (ftnlen)471)) << 
		    10), kernls_len, (ftnlen)1024);
	} else {
	    setmsg_("Although '#' key was provided on the command line no ke"
		    "rnel file names were following it.", (ftnlen)89);
	    errch_("#", "-k", (ftnlen)1, (ftnlen)2);
	    sigerr_("SPICE(MISSINGKERNELNAMES)", (ftnlen)25);
	}
    } else {
	s_copy(kernls, " ", kernls_len, (ftnlen)1);
    }

/*     Was the center name or ID for the first SPK provided on the */
/*     command line? */

    s_copy(cennam, " ", cennam_len, (ftnlen)1);
    i__ = isrchc_("-c1", &c__17, clkeys, (ftnlen)3, (ftnlen)32);
    if (clflag[(i__1 = i__ - 1) < 17 && 0 <= i__1 ? i__1 : s_rnge("clflag", 
	    i__1, "chwcml_", (ftnlen)495)]) {
	s_copy(cennam, clvals + (((i__1 = i__ - 1) < 17 && 0 <= i__1 ? i__1 : 
		s_rnge("clvals", i__1, "chwcml_", (ftnlen)497)) << 10), 
		cennam_len, (ftnlen)1024);
	nparsi_(clvals + (((i__1 = i__ - 1) < 17 && 0 <= i__1 ? i__1 : s_rnge(
		"clvals", i__1, "chwcml_", (ftnlen)498)) << 10), cenid, error,
		 &ptr, (ftnlen)1024, (ftnlen)1024);
	if (ptr != 0) {
	    bodn2c_(clvals + (((i__1 = i__ - 1) < 17 && 0 <= i__1 ? i__1 : 
		    s_rnge("clvals", i__1, "chwcml_", (ftnlen)502)) << 10), 
		    cenid, &found, (ftnlen)1024);
	    if (! found) {
		setmsg_("'#' specified after '#' key is neither an integer n"
			"umber representing a legitimate NAIF ID nor an objec"
			"t name recognized in SPICE.", (ftnlen)130);
		errch_("#", clvals + (((i__1 = i__ - 1) < 17 && 0 <= i__1 ? 
			i__1 : s_rnge("clvals", i__1, "chwcml_", (ftnlen)510))
			 << 10), (ftnlen)1, (ftnlen)1024);
		errch_("#", "-c1", (ftnlen)1, (ftnlen)3);
		sigerr_("SPICE(BADCENTER1SPEC)", (ftnlen)21);
	    }
	} else {
	    bodc2n_(cenid, hword, &found, (ftnlen)32);
	    if (found) {
		s_copy(cennam, hword, cennam_len, (ftnlen)32);
	    }
	}
    }

/*     Was the body name or ID for the first SPK provided on the */
/*     command line? */

    s_copy(bodnam, " ", bodnam_len, (ftnlen)1);
    i__ = isrchc_("-b1", &c__17, clkeys, (ftnlen)3, (ftnlen)32);
    if (clflag[(i__1 = i__ - 1) < 17 && 0 <= i__1 ? i__1 : s_rnge("clflag", 
	    i__1, "chwcml_", (ftnlen)534)]) {
	s_copy(bodnam, clvals + (((i__1 = i__ - 1) < 17 && 0 <= i__1 ? i__1 : 
		s_rnge("clvals", i__1, "chwcml_", (ftnlen)536)) << 10), 
		bodnam_len, (ftnlen)1024);
	nparsi_(clvals + (((i__1 = i__ - 1) < 17 && 0 <= i__1 ? i__1 : s_rnge(
		"clvals", i__1, "chwcml_", (ftnlen)537)) << 10), bodid, error,
		 &ptr, (ftnlen)1024, (ftnlen)1024);
	if (ptr != 0) {
	    bodn2c_(clvals + (((i__1 = i__ - 1) < 17 && 0 <= i__1 ? i__1 : 
		    s_rnge("clvals", i__1, "chwcml_", (ftnlen)541)) << 10), 
		    bodid, &found, (ftnlen)1024);
	    if (! found) {
		setmsg_("'#' specified after '#' key is neither an integer n"
			"umber representing a legitimate NAIF ID nor an objec"
			"t name recognized in SPICE.", (ftnlen)130);
		errch_("#", clvals + (((i__1 = i__ - 1) < 17 && 0 <= i__1 ? 
			i__1 : s_rnge("clvals", i__1, "chwcml_", (ftnlen)549))
			 << 10), (ftnlen)1, (ftnlen)1024);
		errch_("#", "-b1", (ftnlen)1, (ftnlen)3);
		sigerr_("SPICE(BADBODY1SPEC)", (ftnlen)19);
	    }
	} else {
	    bodc2n_(bodid, hword, &found, (ftnlen)32);
	    if (found) {
		s_copy(bodnam, hword, bodnam_len, (ftnlen)32);
	    }
	}
    }

/*     Was the first frame name provided on the command line? */

    s_copy(frame, " ", frame_len, (ftnlen)1);
    i__ = isrchc_("-r1", &c__17, clkeys, (ftnlen)3, (ftnlen)32);
    if (clflag[(i__1 = i__ - 1) < 17 && 0 <= i__1 ? i__1 : s_rnge("clflag", 
	    i__1, "chwcml_", (ftnlen)572)]) {
	s_copy(frame, clvals + (((i__1 = i__ - 1) < 17 && 0 <= i__1 ? i__1 : 
		s_rnge("clvals", i__1, "chwcml_", (ftnlen)574)) << 10), 
		frame_len, (ftnlen)1024);
	namfrm_(frame, &framid, frame_len);
	if (framid == 0) {
	    setmsg_("Cannot recognize frame '#' provided on the command line"
		    " after '#' key.", (ftnlen)70);
	    errch_("#", frame, (ftnlen)1, frame_len);
	    errch_("#", "-r1", (ftnlen)1, (ftnlen)3);
	    sigerr_("SPICE(BADFRAME1NAME)", (ftnlen)20);
	}
    }

/*     Was the center name or ID for the second SPK provided on the */
/*     command line? */

    s_copy(cennam + cennam_len, " ", cennam_len, (ftnlen)1);
    i__ = isrchc_("-c2", &c__17, clkeys, (ftnlen)3, (ftnlen)32);
    if (clflag[(i__1 = i__ - 1) < 17 && 0 <= i__1 ? i__1 : s_rnge("clflag", 
	    i__1, "chwcml_", (ftnlen)595)]) {
	s_copy(cennam + cennam_len, clvals + (((i__1 = i__ - 1) < 17 && 0 <= 
		i__1 ? i__1 : s_rnge("clvals", i__1, "chwcml_", (ftnlen)597)) 
		<< 10), cennam_len, (ftnlen)1024);
	nparsi_(clvals + (((i__1 = i__ - 1) < 17 && 0 <= i__1 ? i__1 : s_rnge(
		"clvals", i__1, "chwcml_", (ftnlen)598)) << 10), &cenid[1], 
		error, &ptr, (ftnlen)1024, (ftnlen)1024);
	if (ptr != 0) {
	    bodn2c_(clvals + (((i__1 = i__ - 1) < 17 && 0 <= i__1 ? i__1 : 
		    s_rnge("clvals", i__1, "chwcml_", (ftnlen)602)) << 10), &
		    cenid[1], &found, (ftnlen)1024);
	    if (! found) {
		setmsg_("'#' specified after '#' key is neither an integer n"
			"umber representing  a legitimate NAIF ID nor an obje"
			"ct name recognized in SPICE.", (ftnlen)131);
		errch_("#", clvals + (((i__1 = i__ - 1) < 17 && 0 <= i__1 ? 
			i__1 : s_rnge("clvals", i__1, "chwcml_", (ftnlen)610))
			 << 10), (ftnlen)1, (ftnlen)1024);
		errch_("#", "-c2", (ftnlen)1, (ftnlen)3);
		sigerr_("SPICE(BADCENTER2SPEC)", (ftnlen)21);
	    }
	} else {
	    bodc2n_(&cenid[1], hword, &found, (ftnlen)32);
	    if (found) {
		s_copy(cennam + cennam_len, hword, cennam_len, (ftnlen)32);
	    }
	}
    }

/*     Was the body name or ID for the second SPK provided on the */
/*     command line? */

    s_copy(bodnam + bodnam_len, " ", bodnam_len, (ftnlen)1);
    i__ = isrchc_("-b2", &c__17, clkeys, (ftnlen)3, (ftnlen)32);
    if (clflag[(i__1 = i__ - 1) < 17 && 0 <= i__1 ? i__1 : s_rnge("clflag", 
	    i__1, "chwcml_", (ftnlen)634)]) {
	s_copy(bodnam + bodnam_len, clvals + (((i__1 = i__ - 1) < 17 && 0 <= 
		i__1 ? i__1 : s_rnge("clvals", i__1, "chwcml_", (ftnlen)636)) 
		<< 10), bodnam_len, (ftnlen)1024);
	nparsi_(clvals + (((i__1 = i__ - 1) < 17 && 0 <= i__1 ? i__1 : s_rnge(
		"clvals", i__1, "chwcml_", (ftnlen)637)) << 10), &bodid[1], 
		error, &ptr, (ftnlen)1024, (ftnlen)1024);
	if (ptr != 0) {
	    bodn2c_(clvals + (((i__1 = i__ - 1) < 17 && 0 <= i__1 ? i__1 : 
		    s_rnge("clvals", i__1, "chwcml_", (ftnlen)641)) << 10), &
		    bodid[1], &found, (ftnlen)1024);
	    if (! found) {
		setmsg_("'#' specified after '#' key is neither an integer n"
			"umber representing a legitimate NAIF ID nor an objec"
			"t name recognized in SPICE.", (ftnlen)130);
		errch_("#", clvals + (((i__1 = i__ - 1) < 17 && 0 <= i__1 ? 
			i__1 : s_rnge("clvals", i__1, "chwcml_", (ftnlen)649))
			 << 10), (ftnlen)1, (ftnlen)1024);
		errch_("#", "-b2", (ftnlen)1, (ftnlen)3);
		sigerr_("SPICE(BADBODY2SPEC)", (ftnlen)19);
	    }
	} else {
	    bodc2n_(&bodid[1], hword, &found, (ftnlen)32);
	    if (found) {
		s_copy(bodnam + bodnam_len, hword, bodnam_len, (ftnlen)32);
	    }
	}
    }

/*     Was the second frame name provided on the command line? */

    s_copy(frame + frame_len, " ", frame_len, (ftnlen)1);
    i__ = isrchc_("-r2", &c__17, clkeys, (ftnlen)3, (ftnlen)32);
    if (clflag[(i__1 = i__ - 1) < 17 && 0 <= i__1 ? i__1 : s_rnge("clflag", 
	    i__1, "chwcml_", (ftnlen)672)]) {
	s_copy(frame + frame_len, clvals + (((i__1 = i__ - 1) < 17 && 0 <= 
		i__1 ? i__1 : s_rnge("clvals", i__1, "chwcml_", (ftnlen)674)) 
		<< 10), frame_len, (ftnlen)1024);
	namfrm_(frame + frame_len, &framid, frame_len);
	if (framid == 0) {
	    setmsg_("Cannot recognize frame '#' provided on the command line"
		    " after '#' key.", (ftnlen)70);
	    errch_("#", frame + frame_len, (ftnlen)1, frame_len);
	    errch_("#", "-r2", (ftnlen)1, (ftnlen)3);
	    sigerr_("SPICE(BADFRAME2NAME)", (ftnlen)20);
	}
    }

/*     Were begin and end times provided on the command line? */

    s_copy(time, " ", time_len, (ftnlen)1);
    i__ = isrchc_("-b", &c__17, clkeys, (ftnlen)2, (ftnlen)32);
    if (clflag[(i__1 = i__ - 1) < 17 && 0 <= i__1 ? i__1 : s_rnge("clflag", 
	    i__1, "chwcml_", (ftnlen)694)]) {
	s_copy(time, clvals + (((i__1 = i__ - 1) < 17 && 0 <= i__1 ? i__1 : 
		s_rnge("clvals", i__1, "chwcml_", (ftnlen)695)) << 10), 
		time_len, (ftnlen)1024);
	str2et_(clvals + (((i__1 = i__ - 1) < 17 && 0 <= i__1 ? i__1 : s_rnge(
		"clvals", i__1, "chwcml_", (ftnlen)696)) << 10), et, (ftnlen)
		1024);
    }
    s_copy(time + time_len, " ", time_len, (ftnlen)1);
    i__ = isrchc_("-e", &c__17, clkeys, (ftnlen)2, (ftnlen)32);
    if (clflag[(i__1 = i__ - 1) < 17 && 0 <= i__1 ? i__1 : s_rnge("clflag", 
	    i__1, "chwcml_", (ftnlen)703)]) {
	s_copy(time + time_len, clvals + (((i__1 = i__ - 1) < 17 && 0 <= i__1 
		? i__1 : s_rnge("clvals", i__1, "chwcml_", (ftnlen)704)) << 
		10), time_len, (ftnlen)1024);
	str2et_(clvals + (((i__1 = i__ - 1) < 17 && 0 <= i__1 ? i__1 : s_rnge(
		"clvals", i__1, "chwcml_", (ftnlen)705)) << 10), &et[1], (
		ftnlen)1024);
    }

/*     Check that begin time is less than the end time. */

    if (s_cmp(time, " ", time_len, (ftnlen)1) != 0 && s_cmp(time + time_len, 
	    " ", time_len, (ftnlen)1) != 0) {
	if (et[1] < et[0]) {
	    setmsg_("Specified start time '#' is greater than specified stop"
		    " time '#'.", (ftnlen)65);
	    errch_("#", time, (ftnlen)1, time_len);
	    errch_("#", time + time_len, (ftnlen)1, time_len);
	    sigerr_("SPICE(INCONSISTENTTIMES)", (ftnlen)24);
	}
    }

/*     Sanity check: body should be distinct from center for all possible */
/*     input combinations (-b1/-c1, -b2/-c2, -b1/-c2 and -b2/-c1). */

    if (s_cmp(bodnam, " ", bodnam_len, (ftnlen)1) != 0 && s_cmp(cennam, " ", 
	    cennam_len, (ftnlen)1) != 0) {
	if (bodid[0] == cenid[0]) {
	    setmsg_("Body and center specified on the command line line must"
		    " be distinct. They were '#'(#) and '#'(#).", (ftnlen)97);
	    errch_("#", bodnam, (ftnlen)1, bodnam_len);
	    errint_("#", bodid, (ftnlen)1);
	    errch_("#", cennam, (ftnlen)1, cennam_len);
	    errint_("#", cenid, (ftnlen)1);
	    sigerr_("SPICE(SAMEBODY1CENTER1)", (ftnlen)23);
	}
    } else if (s_cmp(bodnam + bodnam_len, " ", bodnam_len, (ftnlen)1) != 0 && 
	    s_cmp(cennam + cennam_len, " ", cennam_len, (ftnlen)1) != 0) {
	if (bodid[1] == cenid[1]) {
	    setmsg_("Body and center specified on the command line line must"
		    " be distinct.  They were '#'(#) and '#'(#).", (ftnlen)98);
	    errch_("#", bodnam + bodnam_len, (ftnlen)1, bodnam_len);
	    errint_("#", &bodid[1], (ftnlen)1);
	    errch_("#", cennam + cennam_len, (ftnlen)1, cennam_len);
	    errint_("#", &cenid[1], (ftnlen)1);
	    sigerr_("SPICE(SAMEBODY2CENTER2)", (ftnlen)23);
	}
    } else if (s_cmp(bodnam, " ", bodnam_len, (ftnlen)1) != 0 && s_cmp(cennam 
	    + cennam_len, " ", cennam_len, (ftnlen)1) != 0 && s_cmp(cennam, 
	    " ", cennam_len, (ftnlen)1) == 0) {
	if (bodid[0] == cenid[1]) {
	    setmsg_("Body and center specified on the command line line must"
		    " be distinct.  They were '#'(#) and '#'(#).", (ftnlen)98);
	    errch_("#", bodnam, (ftnlen)1, bodnam_len);
	    errint_("#", bodid, (ftnlen)1);
	    errch_("#", cennam + cennam_len, (ftnlen)1, cennam_len);
	    errint_("#", &cenid[1], (ftnlen)1);
	    sigerr_("SPICE(SAMEBODY1CENTER2)", (ftnlen)23);
	}
    } else if (s_cmp(bodnam + bodnam_len, " ", bodnam_len, (ftnlen)1) != 0 && 
	    s_cmp(cennam, " ", cennam_len, (ftnlen)1) != 0 && s_cmp(cennam + 
	    cennam_len, " ", cennam_len, (ftnlen)1) == 0) {
	if (bodid[1] == cenid[0]) {
	    setmsg_("Body and center specified on the command line line must"
		    " be distinct.  They were '#'(#) and '#'(#).", (ftnlen)98);
	    errch_("#", bodnam + bodnam_len, (ftnlen)1, bodnam_len);
	    errint_("#", &bodid[1], (ftnlen)1);
	    errch_("#", cennam, (ftnlen)1, cennam_len);
	    errint_("#", cenid, (ftnlen)1);
	    sigerr_("SPICE(SAMEBODY2CENTER1)", (ftnlen)23);
	}
    }

/*     Before we move on to processing the final command line keys that */
/*     determine how many steps and/or steps of what size we will do */
/*     in this comparison, we will need to fill in all ``blanks'', i.e. */
/*     any center, body, frame and coverage inputs that were missing */
/*     on the command line. */


/*     If only one body name/ID was provided, set the other one to be */
/*     the same. */

    if (s_cmp(bodnam, " ", bodnam_len, (ftnlen)1) == 0 && s_cmp(bodnam + 
	    bodnam_len, " ", bodnam_len, (ftnlen)1) != 0) {
	bodid[0] = bodid[1];
	s_copy(bodnam, bodnam + bodnam_len, bodnam_len, bodnam_len);
    } else if (s_cmp(bodnam + bodnam_len, " ", bodnam_len, (ftnlen)1) == 0 && 
	    s_cmp(bodnam, " ", bodnam_len, (ftnlen)1) != 0) {
	bodid[1] = bodid[0];
	s_copy(bodnam + bodnam_len, bodnam, bodnam_len, bodnam_len);
    }

/*     If only one center name/ID was provided, set the other one to be */
/*     the same. */

    if (s_cmp(cennam, " ", cennam_len, (ftnlen)1) == 0 && s_cmp(cennam + 
	    cennam_len, " ", cennam_len, (ftnlen)1) != 0) {
	cenid[0] = cenid[1];
	s_copy(cennam, cennam + cennam_len, cennam_len, cennam_len);
    } else if (s_cmp(cennam + cennam_len, " ", cennam_len, (ftnlen)1) == 0 && 
	    s_cmp(cennam, " ", cennam_len, (ftnlen)1) != 0) {
	cenid[1] = cenid[0];
	s_copy(cennam + cennam_len, cennam, cennam_len, cennam_len);
    }

/*     If only one frame name was provided, set the other one to be the */
/*     same. */

    if (s_cmp(frame, " ", frame_len, (ftnlen)1) == 0 && s_cmp(frame + 
	    frame_len, " ", frame_len, (ftnlen)1) != 0) {
	s_copy(frame, frame + frame_len, frame_len, frame_len);
    } else if (s_cmp(frame + frame_len, " ", frame_len, (ftnlen)1) == 0 && 
	    s_cmp(frame, " ", frame_len, (ftnlen)1) != 0) {
	s_copy(frame + frame_len, frame, frame_len, frame_len);
    }

/*     Check if at least one body, center, and frame were provided on */
/*     the command line. If not, obtain default values by looking at the */
/*     first SPK file. */

    if (s_cmp(bodnam, " ", bodnam_len, (ftnlen)1) == 0 && s_cmp(bodnam + 
	    bodnam_len, " ", bodnam_len, (ftnlen)1) == 0 || s_cmp(cennam, 
	    " ", cennam_len, (ftnlen)1) == 0 && s_cmp(cennam + cennam_len, 
	    " ", cennam_len, (ftnlen)1) == 0 || s_cmp(frame, " ", frame_len, (
	    ftnlen)1) == 0 && s_cmp(frame + frame_len, " ", frame_len, (
	    ftnlen)1) == 0) {

/*        We don't have complete body-center-frame triplets on the */
/*        command line and need to get some defaults. Open the first SPK */
/*        and look through it. */

/*        If first, second, or both body IDs were specified on the */
/*        command line, then center and frame from the segment for this */
/*        body closest to the end of the file will be picked as default */
/*        values. */

/*        If neither first nor second body ID was specified on the */
/*        command line and SPK contains segments for one or more */
/*        spacecraft, the body, center, and frame from the spacecraft */
/*        segment closest to the end of the file will be picked as */
/*        default values. */

/*        If neither first nor second body ID was specified on the */
/*        command line and SPK contains no spacecraft segments, the */
/*        body, center, and frame from the very last segment of the file */
/*        will be picked as default values. */


/*        Zero out descriptor buffers for last segment, last s/c segment */
/*        and last segment for specified body. Note that SPK type */
/*        element (ICXXXX(4)) cannot be 0 for any real SPK segment; this */
/*        property will be relied upon in checks in the loop below to */
/*        determine if any of these descriptors have already been set. */

	filli_(&c__0, &c__6, iclstn);
	filli_(&c__0, &c__6, iclsts);
	filli_(&c__0, &c__6, iclstb);

/*        Open first SPK file and search it in backward order. */

	dafopr_(spk, &handle, spk_len);
	dafbbs_(&handle);
	daffpa_(&found);
	while(found) {

/*           Fetch and unpack the segment descriptor. */

	    dafgs_(descr);
	    dafus_(descr, &c__2, &c__6, dc, ic);

/*           Save integer components of the last descriptor. */

	    if (iclstn[3] == 0) {
		movei_(ic, &c__6, iclstn);
	    }

/*           Save integer components of the last descriptor for a */
/*           spacecraft. */

	    if (iclsts[3] == 0 && ic[0] < 0) {
		movei_(ic, &c__6, iclsts);
	    }

/*           Save integer components of the data descriptor for */
/*           the specified body. */

	    if (iclstb[3] == 0 && s_cmp(bodnam, " ", bodnam_len, (ftnlen)1) !=
		     0 && bodid[0] == ic[0]) {
		movei_(ic, &c__6, iclstb);
	    }

/*           Find next segment. */

	    daffpa_(&found);
	}

/*        Release the file. */

	dafcls_(&handle);

/*        Set default values based on priorities described above and the */
/*        descriptor data collected in the loop. */

	if (s_cmp(bodnam, " ", bodnam_len, (ftnlen)1) != 0) {

/*           Check if any segments for specified body were found. If */
/*           yes, set defaults. If no, complain and stop. */

	    if (iclstb[3] != 0) {
		movei_(iclstb, &c__6, ic);
	    } else {
		setmsg_("SPK file '#' does not contain any data for body '#'"
			"(#) specified on the command line,", (ftnlen)85);
		errch_("#", spk, (ftnlen)1, spk_len);
		errch_("#", bodnam, (ftnlen)1, bodnam_len);
		errint_("#", bodid, (ftnlen)1);
		sigerr_("SPICE(1NODATAFORBODY)", (ftnlen)21);
	    }
	} else if (iclsts[3] != 0) {

/*           Set defaults to the values from the last segment for a */
/*           spacecraft. */

	    movei_(iclsts, &c__6, ic);
	} else {

/*           Set defaults to the values from the last segment */

	    movei_(iclstn, &c__6, ic);
	}

/*        Do a sanity check. At this point descriptor containing defaults */
/*        (IC) should have been set to something meaningful therefore */
/*        IC(4) should be non-zero. */

	if (ic[3] == 0) {
	    setmsg_("Cannot retrieve default values from SPK file '#'. It ei"
		    "ther is damaged or contains no data segments.", (ftnlen)
		    100);
	    errch_("#", spk, (ftnlen)1, spk_len);
	    sigerr_("SPICE(CANNOTGETDEFAULTS)", (ftnlen)24);
	}

/*        Set default body. */

	if (s_cmp(bodnam, " ", bodnam_len, (ftnlen)1) == 0) {
	    bodid[0] = ic[0];
	    bodid[1] = ic[0];
	    bodc2n_(bodid, bodnam, &found, bodnam_len);
	    if (! found) {
		intstr_(ic, bodnam, bodnam_len);
	    }
	    s_copy(bodnam + bodnam_len, bodnam, bodnam_len, bodnam_len);
	}

/*        Set default center. */

	if (s_cmp(cennam, " ", cennam_len, (ftnlen)1) == 0) {
	    cenid[0] = ic[1];
	    cenid[1] = ic[1];
	    bodc2n_(cenid, cennam, &found, cennam_len);
	    if (! found) {
		intstr_(&ic[1], cennam, cennam_len);
	    }
	    s_copy(cennam + cennam_len, cennam, cennam_len, cennam_len);
	}

/*        Set default frame. */

	if (s_cmp(frame, " ", frame_len, (ftnlen)1) == 0) {
	    frmnam_(&ic[2], frame, frame_len);
	    if (s_cmp(frame, " ", frame_len, (ftnlen)1) == 0) {
		setmsg_("Cannot pick default frame for this run. Please, spe"
			"cify the frame relative to which states should be co"
			"mputed using '#' or '#' command line keys.", (ftnlen)
			145);
		errch_("#", "-r1", (ftnlen)1, (ftnlen)3);
		errch_("#", "-r2", (ftnlen)1, (ftnlen)3);
		sigerr_("SPICE(CANNOTPICKFRAME)", (ftnlen)22);
	    }
	    s_copy(frame + frame_len, frame, frame_len, frame_len);
	}
    }

/*     Now that we have body and center for each pair we can repeat the */
/*     same sanity check: body should be distinct from center. */

    if (bodid[0] == cenid[0]) {
	setmsg_("Body and center picked from SPK and/or command line line mu"
		"st be distinct. They were '#'(#) and '#'(#).", (ftnlen)103);
	errch_("#", bodnam, (ftnlen)1, bodnam_len);
	errint_("#", bodid, (ftnlen)1);
	errch_("#", cennam, (ftnlen)1, cennam_len);
	errint_("#", cenid, (ftnlen)1);
	sigerr_("SPICE(SAMEBODYANDCENTER3)", (ftnlen)25);
    } else if (bodid[1] == cenid[1]) {
	setmsg_("Body and center picked from SPK and/or command line line mu"
		"st be distinct. They were '#'(#) and '#'(#).", (ftnlen)103);
	errch_("#", bodnam + bodnam_len, (ftnlen)1, bodnam_len);
	errint_("#", &bodid[1], (ftnlen)1);
	errch_("#", cennam + cennam_len, (ftnlen)1, cennam_len);
	errint_("#", &cenid[1], (ftnlen)1);
	sigerr_("SPICE(SAMEBODYANDCENTER4)", (ftnlen)25);
    }

/*     If either begin or end time was not provided on the command we */
/*     need to examine both SPKs to determine the range for which do the */
/*     comparison. */

    if (s_cmp(time, " ", time_len, (ftnlen)1) == 0 || s_cmp(time + time_len, 
	    " ", time_len, (ftnlen)1) == 0) {

/*        Initialize coverage windows for the first and seconds SPKs */
/*        and for intersection between them. */

	ssized_(&c__60000, cover1);
	ssized_(&c__60000, cover2);
	ssized_(&c__60002, coverc);

/*        Get coverage for the first body from the first SPK file. */

	spkcov_(spk, bodid, cover1, spk_len);

/*        Check if the first SPK provides any coverage for the body */
/*        of interest. */

	if (cardd_(cover1) == 0) {
	    setmsg_("SPK file '#' does not contain any data for body '#'(#) "
		    "specified on the command line,", (ftnlen)85);
	    errch_("#", spk, (ftnlen)1, spk_len);
	    errch_("#", bodnam, (ftnlen)1, bodnam_len);
	    errint_("#", bodid, (ftnlen)1);
	    sigerr_("SPICE(2NODATAFORBODY)", (ftnlen)21);
	}

/*        Get coverage for the second body from the second SPK file. */

	spkcov_(spk + spk_len, &bodid[1], cover2, spk_len);

/*        Check if the second SPK provides any coverage for the body of */
/*        interest. */

	if (cardd_(cover2) == 0) {
	    setmsg_("SPK file '#' does not contain any data for body '#'(#) "
		    "specified on the command line,", (ftnlen)85);
	    errch_("#", spk + spk_len, (ftnlen)1, spk_len);
	    errch_("#", bodnam + bodnam_len, (ftnlen)1, bodnam_len);
	    errint_("#", &bodid[1], (ftnlen)1);
	    sigerr_("SPICE(3NODATAFORBODY)", (ftnlen)21);
	}

/*        Find the intersection of the two coverages. */

	wnintd_(cover1, cover2, coverc);

/*        Check if we have an intersection. */

	if (cardd_(coverc) == 0) {
	    setmsg_("Coverage for body '#'(#) provided by SPK '#' and covera"
		    "ge for body '#'(#) provided by SPK '#' do not overlap.", (
		    ftnlen)109);
	    errch_("#", bodnam, (ftnlen)1, bodnam_len);
	    errint_("#", bodid, (ftnlen)1);
	    errch_("#", spk, (ftnlen)1, spk_len);
	    errch_("#", bodnam + bodnam_len, (ftnlen)1, bodnam_len);
	    errint_("#", &bodid[1], (ftnlen)1);
	    errch_("#", spk + spk_len, (ftnlen)1, spk_len);
	    sigerr_("SPICE(NOOVERLAP1)", (ftnlen)17);
	}
    }

/*     If begin, end or both times were not set yet, now is the time */
/*     to do it since we have our defaults in hand. */

    if (s_cmp(time, " ", time_len, (ftnlen)1) == 0 && s_cmp(time + time_len, 
	    " ", time_len, (ftnlen)1) == 0) {

/*        If neither begin nor end time are set, we will use the */
/*        coverage intersection begin and end as boundaries. We just */
/*        need to make sure that we have only one window. */

	if (cardd_(coverc) > 2) {
	    setmsg_("The intersection of coverage for body '#'(#) provided b"
		    "y SPK '#' and coverage for body '#'(#) provided by SPK '"
		    "#' includes more than one continuous window. ", (ftnlen)
		    156);
	    errch_("#", bodnam, (ftnlen)1, bodnam_len);
	    errint_("#", bodid, (ftnlen)1);
	    errch_("#", spk, (ftnlen)1, spk_len);
	    errch_("#", bodnam + bodnam_len, (ftnlen)1, bodnam_len);
	    errint_("#", &bodid[1], (ftnlen)1);
	    errch_("#", spk + spk_len, (ftnlen)1, spk_len);
	    sigerr_("SPICE(MORETHAN1INTERVAL1)", (ftnlen)25);
	}

/*        Set begin and end time. */

	et[0] = coverc[6];
	et[1] = coverc[7];
    } else if (s_cmp(time, " ", time_len, (ftnlen)1) == 0) {

/*        End time was provided while begin time was not. We need to */
/*        constrain the coverage intercept by the end time. */

	ssized_(&c__60000, cover1);
	d__1 = dpmin_();
	appndd_(&d__1, cover1);
	appndd_(&et[1], cover1);
	wnintd_(coverc, cover1, cover2);

/*        Check if we have any coverage and if it is exactly one window. */

	if (cardd_(cover2) == 0) {
	    setmsg_("There is no overlap of coverage for body '#'(#) provide"
		    "d by SPK '#' and coverage for body '#'(#) provided by SP"
		    "K '#' before '#'(# TDB seconds).", (ftnlen)143);
	    errch_("#", bodnam, (ftnlen)1, bodnam_len);
	    errint_("#", bodid, (ftnlen)1);
	    errch_("#", spk, (ftnlen)1, spk_len);
	    errch_("#", bodnam + bodnam_len, (ftnlen)1, bodnam_len);
	    errint_("#", &bodid[1], (ftnlen)1);
	    errch_("#", spk + spk_len, (ftnlen)1, spk_len);
	    errch_("#", time + time_len, (ftnlen)1, time_len);
	    errdp_("#", &et[1], (ftnlen)1);
	    sigerr_("SPICE(NOOVERLAP2)", (ftnlen)17);
	} else if (cardd_(cover2) > 2) {
	    setmsg_("The intersection of coverage for body '#'(#) provided b"
		    "y SPK '#' and coverage for body '#'(#) provided by SPK '"
		    "#' before '#'(# TDB seconds) includes more than one cont"
		    "inuous window. ", (ftnlen)182);
	    errch_("#", bodnam, (ftnlen)1, bodnam_len);
	    errint_("#", bodid, (ftnlen)1);
	    errch_("#", spk, (ftnlen)1, spk_len);
	    errch_("#", bodnam + bodnam_len, (ftnlen)1, bodnam_len);
	    errint_("#", &bodid[1], (ftnlen)1);
	    errch_("#", spk + spk_len, (ftnlen)1, spk_len);
	    errch_("#", time + time_len, (ftnlen)1, time_len);
	    errdp_("#", &et[1], (ftnlen)1);
	    sigerr_("SPICE(MORETHAN1INTERVAL2)", (ftnlen)25);
	}

/*        Set begin and end time. */

	et[0] = cover2[6];
	et[1] = cover2[7];
    } else if (s_cmp(time + time_len, " ", time_len, (ftnlen)1) == 0) {

/*        Begin time was provided while end time was not. We need to */
/*        constrain the coverage intercept by the begin time. */

	ssized_(&c__60000, cover1);
	appndd_(et, cover1);
	d__1 = dpmax_();
	appndd_(&d__1, cover1);
	wnintd_(coverc, cover1, cover2);

/*        Check if we have any coverage and if it is exactly one window. */

	if (cardd_(cover2) == 0) {
	    setmsg_("There is no overlap of coverage for body '#'(#) provide"
		    "d by SPK '#' and coverage for body '#'(#) provided by SP"
		    "K '#' after '#'(# TDB seconds).", (ftnlen)142);
	    errch_("#", bodnam, (ftnlen)1, bodnam_len);
	    errint_("#", bodid, (ftnlen)1);
	    errch_("#", spk, (ftnlen)1, spk_len);
	    errch_("#", bodnam + bodnam_len, (ftnlen)1, bodnam_len);
	    errint_("#", &bodid[1], (ftnlen)1);
	    errch_("#", spk + spk_len, (ftnlen)1, spk_len);
	    errch_("#", time, (ftnlen)1, time_len);
	    errdp_("#", et, (ftnlen)1);
	    sigerr_("SPICE(NOOVERLAP3)", (ftnlen)17);
	} else if (cardd_(cover2) > 2) {
	    setmsg_("The intersection of coverage for body '#'(#) provided b"
		    "y SPK '#' and coverage for body '#'(#) provided by SPK '"
		    "#' after '#'(# TDB seconds) includes more than one conti"
		    "nuous window. ", (ftnlen)181);
	    errch_("#", bodnam, (ftnlen)1, bodnam_len);
	    errint_("#", bodid, (ftnlen)1);
	    errch_("#", spk, (ftnlen)1, spk_len);
	    errch_("#", bodnam + bodnam_len, (ftnlen)1, bodnam_len);
	    errint_("#", &bodid[1], (ftnlen)1);
	    errch_("#", spk + spk_len, (ftnlen)1, spk_len);
	    errch_("#", time, (ftnlen)1, time_len);
	    errdp_("#", et, (ftnlen)1);
	    sigerr_("SPICE(MORETHAN1INTERVAL3)", (ftnlen)25);
	}

/*        Set begin and end time. */

	et[0] = cover2[6];
	et[1] = cover2[7];
    }

/*     Set begin and end time in calendar ET format for banner output. */

    etcal_(et, time, time_len);
    etcal_(&et[1], time + time_len, time_len);
/* Writing concatenation */
    i__3[0] = rtrim_(time, time_len), a__1[0] = time;
    i__3[1] = 4, a__1[1] = " TDB";
    s_cat(time, a__1, i__3, &c__2, time_len);
/* Writing concatenation */
    i__3[0] = rtrim_(time + time_len, time_len), a__1[0] = time + time_len;
    i__3[1] = 4, a__1[1] = " TDB";
    s_cat(time + time_len, a__1, i__3, &c__2, time_len);

/*     Was time step or number of steps provided on the command line? If */
/*     both are specified, time step has higher priority and, for this */
/*     reason, should be processed first. */

    i__ = isrchc_("-s", &c__17, clkeys, (ftnlen)2, (ftnlen)32);
    if (clflag[(i__1 = i__ - 1) < 17 && 0 <= i__1 ? i__1 : s_rnge("clflag", 
	    i__1, "chwcml_", (ftnlen)1294)]) {

/*        Is the step a DP number? */

	nparsd_(clvals + (((i__1 = i__ - 1) < 17 && 0 <= i__1 ? i__1 : s_rnge(
		"clvals", i__1, "chwcml_", (ftnlen)1299)) << 10), step, error,
		 &ptr, (ftnlen)1024, (ftnlen)1024);
	if (ptr == 0) {

/*           Check that step is a positive number and is greater that */
/*           the smallest step we can allow. */

	    if (*step < 1e-8) {
		setmsg_("Time step '#' specified after '#' key is smaller th"
			"an # seconds.", (ftnlen)64);
		errch_("#", clvals + (((i__1 = i__ - 1) < 17 && 0 <= i__1 ? 
			i__1 : s_rnge("clvals", i__1, "chwcml_", (ftnlen)1310)
			) << 10), (ftnlen)1, (ftnlen)1024);
		errch_("#", "-s", (ftnlen)1, (ftnlen)2);
		errdp_("#", &c_b452, (ftnlen)1);
		sigerr_("SPICE(STEPTOOSMALL1)", (ftnlen)20);
	    }

/*           Compute the number of steps that will be required to step */
/*           over the time interval with this step. */

	    d__1 = et[1] - et[0];
	    rmaind_(&d__1, step, &hdp1, &hdp2);

/*           If step is greater than time range, we will have only two */
/*           points. If step overflows maximum integer we reset it to */
/*           INTMAX-2 and error out later. If remainder is closer than */
/*           tolerance to zero, we will not introduce "extra" step for */
/*           the end of the interval. If otherwise we will add an extra */
/*           step for end of the interval. */

	    if (hdp1 == 0.) {
		*nitr = 2;
	    } else if (hdp1 > (doublereal) (intmax_() - 2)) {
		*nitr = intmax_() - 2;
	    } else if (hdp2 <= 1e-8) {
		*nitr = i_dnnt(&hdp1) + 1;
		hdp1 += 1;
	    } else {
		*nitr = i_dnnt(&hdp1) + 2;
		hdp1 += 2;
	    }

/*           Check that this number of states will fit into the */
/*           buffer. */

	    if (*nitr > 1000000) {
		setmsg_("The number of states, #, computed using step of # s"
			"econds within time interval from '#'(# TDB seconds) "
			"to '#'(# TDB seconds) is greater than can fit into p"
			"rogram's buffers (# states maximum.) Increase step o"
			"r make the time window smaller in order to run the p"
			"rogram.", (ftnlen)266);
		errdp_("#", &hdp1, (ftnlen)1);
		errdp_("#", step, (ftnlen)1);
		errch_("#", time, (ftnlen)1, time_len);
		errdp_("#", et, (ftnlen)1);
		errch_("#", time + time_len, (ftnlen)1, time_len);
		errdp_("#", &et[1], (ftnlen)1);
		errint_("#", &c_b68, (ftnlen)1);
		sigerr_("SPICE(STEPTOOSMALL2)", (ftnlen)20);
	    }
	} else {
	    setmsg_("Time step '#' specified after '#' key is not a DP numbe"
		    "r.", (ftnlen)57);
	    errch_("#", clvals + (((i__1 = i__ - 1) < 17 && 0 <= i__1 ? i__1 :
		     s_rnge("clvals", i__1, "chwcml_", (ftnlen)1369)) << 10), 
		    (ftnlen)1, (ftnlen)1024);
	    errch_("#", "-s", (ftnlen)1, (ftnlen)2);
	    sigerr_("SPICE(NOTANDPNUMBER)", (ftnlen)20);
	}
    } else {

/*        Step was not provided on the command line. What about the */
/*        number of steps? */

	i__ = isrchc_("-n", &c__17, clkeys, (ftnlen)2, (ftnlen)32);
	if (clflag[(i__1 = i__ - 1) < 17 && 0 <= i__1 ? i__1 : s_rnge("clflag"
		, i__1, "chwcml_", (ftnlen)1382)]) {

/*           Is the number of step an integer number? */

	    nparsi_(clvals + (((i__1 = i__ - 1) < 17 && 0 <= i__1 ? i__1 : 
		    s_rnge("clvals", i__1, "chwcml_", (ftnlen)1387)) << 10), 
		    nitr, error, &ptr, (ftnlen)1024, (ftnlen)1024);
	    if (ptr == 0) {
		if (*nitr < 2 || *nitr > 1000000) {
		    setmsg_("Number of states must be an integer number betw"
			    "een # and #. It was #.", (ftnlen)69);
		    errint_("#", &c__2, (ftnlen)1);
		    errint_("#", &c_b68, (ftnlen)1);
		    errint_("#", nitr, (ftnlen)1);
		    sigerr_("SPICE(BADNOFSTATES)", (ftnlen)19);
		}
	    } else {
		setmsg_("Number of states '#' specified after '#'  key is no"
			"t an integer number.", (ftnlen)71);
		errch_("#", clvals + (((i__1 = i__ - 1) < 17 && 0 <= i__1 ? 
			i__1 : s_rnge("clvals", i__1, "chwcml_", (ftnlen)1405)
			) << 10), (ftnlen)1, (ftnlen)1024);
		errch_("#", "-n", (ftnlen)1, (ftnlen)2);
		sigerr_("SPICE(NOTANINTEGERNUMBER)", (ftnlen)25);
	    }
	} else {

/*           Set number of states to the default number. */

	    if (et[1] == et[0]) {
		*nitr = 2;
	    } else {
		*nitr = 1000;
	    }
	}

/*        Calculate step. */

	*step = (et[1] - et[0]) / (doublereal) (*nitr - 1);
    }

/*     Was the type of output specified on the command line? */

    i__ = isrchc_("-t", &c__17, clkeys, (ftnlen)2, (ftnlen)32);
    if (clflag[(i__1 = i__ - 1) < 17 && 0 <= i__1 ? i__1 : s_rnge("clflag", 
	    i__1, "chwcml_", (ftnlen)1435)]) {
	s_copy(diftyp, clvals + (((i__1 = i__ - 1) < 17 && 0 <= i__1 ? i__1 : 
		s_rnge("clvals", i__1, "chwcml_", (ftnlen)1437)) << 10), 
		diftyp_len, (ftnlen)1024);
	if (! (eqstr_(diftyp, "stats", diftyp_len, (ftnlen)5) || eqstr_(
		diftyp, "dump", diftyp_len, (ftnlen)4) || eqstr_(diftyp, 
		"dumpvf", diftyp_len, (ftnlen)6) || eqstr_(diftyp, "basic", 
		diftyp_len, (ftnlen)5))) {
	    setmsg_("Output type '#' specified after '#' key is not recogniz"
		    "ed. Recognized output types are '#', '#', '#', and '#'.", 
		    (ftnlen)110);
	    errch_("#", clvals + (((i__1 = i__ - 1) < 17 && 0 <= i__1 ? i__1 :
		     s_rnge("clvals", i__1, "chwcml_", (ftnlen)1448)) << 10), 
		    (ftnlen)1, (ftnlen)1024);
	    errch_("#", "-t", (ftnlen)1, (ftnlen)2);
	    errch_("#", "basic", (ftnlen)1, (ftnlen)5);
	    errch_("#", "stats", (ftnlen)1, (ftnlen)5);
	    errch_("#", "dump", (ftnlen)1, (ftnlen)4);
	    errch_("#", "dumpvf", (ftnlen)1, (ftnlen)6);
	    sigerr_("SPICE(BADOUTPUTTYPE)", (ftnlen)20);
	}
    } else {
	s_copy(diftyp, "basic", diftyp_len, (ftnlen)5);
    }

/*     If simple dump of the differences was requested we need to check */
/*     whether output time format was provided on the command line. */

    s_copy(timfmt, " ", timfmt_len, (ftnlen)1);
    if (eqstr_(diftyp, "dump", diftyp_len, (ftnlen)4) || eqstr_(diftyp, "dum"
	    "pvf", diftyp_len, (ftnlen)6)) {
	i__ = isrchc_("-f", &c__17, clkeys, (ftnlen)2, (ftnlen)32);
	if (clflag[(i__1 = i__ - 1) < 17 && 0 <= i__1 ? i__1 : s_rnge("clflag"
		, i__1, "chwcml_", (ftnlen)1474)]) {
	    s_copy(timfmt, clvals + (((i__1 = i__ - 1) < 17 && 0 <= i__1 ? 
		    i__1 : s_rnge("clvals", i__1, "chwcml_", (ftnlen)1476)) <<
		     10), timfmt_len, (ftnlen)1024);

/*           In this incarnation of the program we are not going to try */
/*           to verify that the format is OK at the time when we process */
/*           command line. We will let TIMOUT fail when it's called for */
/*           the first time down stream from here. The only thing that */
/*           makes sense to check for is if the format string is non */
/*           blank. */

	    if (s_cmp(timfmt, " ", timfmt_len, (ftnlen)1) == 0) {
		setmsg_("Output time format specified after '#' key is blank."
			, (ftnlen)52);
		errch_("#", "-f", (ftnlen)1, (ftnlen)2);
		sigerr_("SPICE(BLANKTIMEFORMAT)", (ftnlen)22);
	    }
	}
    }

/*     Check out. */

    chkout_("CHWCML", (ftnlen)6);
    return 0;
} /* chwcml_ */

