/* keeper.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__3 = 3;
static integer c__1300 = 1300;
static integer c__1 = 1;

/* $Procedure      KEEPER ( Keeps track of SPICE kernels ) */
/* Subroutine */ int keeper_0_(int n__, integer *which, char *kind, char *
	file, integer *count, char *filtyp, integer *handle, char *source, 
	logical *found, ftnlen kind_len, ftnlen file_len, ftnlen filtyp_len, 
	ftnlen source_len)
{
    /* Initialized data */

    static logical first = TRUE_;
    static integer loaded = 0;

    /* System generated locals */
    integer i__1, i__2, i__3, i__4, i__5, i__6, i__7;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer), s_cmp(char *, char *, 
	    ftnlen, ftnlen);

    /* Local variables */
    logical dock, doek;
    char norc[1];
    integer hits, size, b, d__, e, i__, j, l, n;
    logical didck, didek;
    integer r__;
    extern /* Subroutine */ int eklef_(char *, integer *, ftnlen);
    logical doall;
    extern /* Subroutine */ int chkin_(char *, ftnlen), ekuef_(integer *);
    logical dopck;
    extern /* Subroutine */ int cklpf_(char *, integer *, ftnlen);
    static char files[255*1300];
    extern /* Subroutine */ int errch_(char *, char *, ftnlen, ftnlen), 
	    repmc_(char *, char *, char *, char *, ftnlen, ftnlen, ftnlen, 
	    ftnlen), ckupf_(integer *);
    static integer srces[1300];
    logical dospk, paths, gotit;
    static char known[32*3];
    extern integer rtrim_(char *, ftnlen);
    extern logical eqstr_(char *, char *, ftnlen, ftnlen);
    integer n1, n2, n3, start;
    static char types[8*1300];
    char fil2ld[255];
    extern logical failed_(void);
    logical ok, didpck;
    extern /* Subroutine */ int remlac_(integer *, integer *, char *, integer 
	    *, ftnlen);
    extern logical badkpv_(char *, char *, char *, integer *, integer *, char 
	    *, ftnlen, ftnlen, ftnlen, ftnlen);
    static integer handls[1300];
    logical dometa;
    extern integer isrchc_(char *, integer *, char *, ftnlen, ftnlen);
    char nofile[500];
    integer dollar;
    logical didspk;
    integer myhand;
    logical update;
    extern /* Subroutine */ int gcpool_(char *, integer *, integer *, integer 
	    *, char *, logical *, ftnlen, ftnlen), fndnwd_(char *, integer *, 
	    integer *, integer *, ftnlen), remlai_(integer *, integer *, 
	    integer *, integer *), pckuof_(integer *), clpool_(void), ldpool_(
	    char *, ftnlen);
    extern logical samsub_(char *, integer *, integer *, char *, integer *, 
	    integer *, ftnlen, ftnlen);
    integer filnum;
    char pvalue[80];
    integer npaths;
    extern /* Subroutine */ int sigerr_(char *, ftnlen), chkout_(char *, 
	    ftnlen);
    integer cursrc;
    logical didtxt;
    char symbol[80];
    logical dotext;
    extern /* Subroutine */ int setmsg_(char *, ftnlen), cvpool_(char *, 
	    logical *, ftnlen);
    extern logical return_(void);
    extern /* Subroutine */ int errint_(char *, integer *, ftnlen), dtpool_(
	    char *, logical *, integer *, char *, ftnlen, ftnlen), stpool_(
	    char *, integer *, char *, char *, integer *, logical *, ftnlen, 
	    ftnlen, ftnlen), swpool_(char *, integer *, char *, ftnlen, 
	    ftnlen), repsub_(char *, integer *, integer *, char *, char *, 
	    ftnlen, ftnlen, ftnlen), repmot_(char *, char *, integer *, char *
	    , char *, ftnlen, ftnlen, ftnlen, ftnlen), dvpool_(char *, ftnlen)
	    , spkuef_(integer *), spklef_(char *, integer *, ftnlen);
    char thstyp[32];
    extern /* Subroutine */ int pcklof_(char *, integer *, ftnlen);
    logical add, fnd;
    integer src, use;
    extern integer pos_(char *, char *, integer *, ftnlen, ftnlen);
    extern /* Subroutine */ int zzldker_(char *, char *, char *, integer *, 
	    ftnlen, ftnlen, ftnlen);

/* $ Abstract */

/*     This routine is an umbrella for a collection of entry points */
/*     that manage the loading and unloading of SPICE kernels from */
/*     an application program. */

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

/*     KERNEL */

/* $ Declarations */
/* $ Brief_I/O */

/*     VARIABLE  I/O  ENTRY POINT */
/*     --------  ---  -------------------------------------------------- */
/*     KIND       I   KTOTAL, KDATA */
/*     FILE      I/O  FURNSH, KDATA,  UNLOAD, KINFO */
/*     FILTYP    I/O  KTOTAL, KDATA,  KINFO */
/*     COUNT      O   KTOTAL */
/*     HANDLE     O   KDATA,  KINFO */
/*     SOURCE     O   KDATA.  KINFO */
/*     FOUND      O   KDATA.  KINFO */
/*     MAXFIL     P   Is the maximum number of files that can be loaded. */


/* $ Detailed_Input */

/*     See Individual Entry points. */

/* $ Detailed_Output */

/*     See Individual Entry points. */

/* $ Parameters */

/*     MAXFIL    is the maximum number of SPICE kernels that can be */
/*               loaded at any time via the KEEPER interface. */

/*               (The number of SPK,CK, binary PCK and EK files that */
/*                can be loaded is considerably smaller than this */
/*                limit.  The limit is imposed by your computers */
/*                FORTRAN compiler and operating system.  For most */
/*                systems this limit is 20 files.) */
/* $ Files */

/*     None. */

/* $ Exceptions */

/*     1) If the main routine KEEPER is called, the error */
/*       'SPICE(BOGUSENTRY)' will be signaled. */

/* $ Particulars */

/*     This routine serves as an umbrella for a collection of */
/*     entry points that unify the task of loading, tracking, */
/*     and unloading SPICE kernels.  A description of each entry */
/*     point is given below: */

/*     FURNSH    Furnish a kernel to a program.  This entry point */
/*               provides a single interface for loading kernels into */
/*               your application program.  All SPICE kernels (Text */
/*               kernels, SPK, CK, Binary PCK, and EK) can be loaded */
/*               through this entry point.  In addition, special text */
/*               kernels, called meta-Text kernels, that contain a list */
/*               of other kernels to load can be processed by FURNSH. */

/*               Meta-text kernels allow you to easily control which */
/*               kernels will be loaded by your program without having */
/*               to write your own kernel managing routines. */

/*     KTOTAL    returns the number of kernels that are currently */
/*               available to your program as a result of previous calls */
/*               to FURNSH and UNLOAD. */

/*     KDATA     provides an interface for retrieving (in order of their */
/*               specification through FURNSH) kernels that are active in */
/*               your application. */

/*     KINFO     allows you to retrieve information about a loaded */
/*               kernel using the name of that kernel. */

/*     UNLOAD    provides an interface for unloading kernels that have */
/*               been loaded via the routine FURNSH. */

/*     For more details concerning any particular entry point, see the */
/*     header for that entry point. */

/* $ Examples */

/*     The code fragment below illustrates the use of the various entry */
/*     points of KEEPER.  The details of creating meta-text kernels are */
/*     not discussed here, but are spelled out in the entry point */
/*     FURNSH. */


/*     Load several kernels into the program. */


/*     CALL FURNSH ( 'myspk.bsp'    ) */
/*     CALL FURNSH ( 'myck.bc'      ) */
/*     CALL FURNSH ( 'leapsecs.ker' ) */
/*     CALL FURNSH ( 'sclk.tsc'     ) */
/*     CALL FURNSH ( 'metatext.ker' ) */

/*     See how many kernels have been loaded. */

/*     CALL KTOTAL ( 'ALL', COUNT ) */

/*     WRITE (*,*) 'The total number of kernels is: ', COUNT */

/*     Summarize the kernels and types. */

/*     DO WHICH = 1, COUNT */

/*        CALL KDATA( WHICH, 'ALL', FILE, FILTYP, SOURCE, HANDLE, FOUND ) */

/*        IF ( .NOT. FOUND ) THEN */

/*           WRITE (*,*) 'This is NOT supposed to happen.  Call NAIF' */
/*           WRITE (*,*) 'and let them know of this problem.' */

/*        ELSE */

/*           WRITE (*,*) */
/*           WRITE (*,*) 'File  : ', FILE */
/*           WRITE (*,*) 'Type  : ', FILTYP */
/*           WRITE (*,*) 'Handle: ', HANDLE */

/*           IF ( SOURCE .NE. ' ' ) THEN */
/*              WRITE (*,*) 'This file was loaded via meta-text kernel:' */
/*              WRITE (*,*) SOURCE */
/*           END IF */

/*        END IF */

/*     END DO */


/*     Unload the first kernel we loaded. */

/*     CALL UNLOAD ( 'myspk.bsp' ) */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     C.H. Acton      (JPL) */
/*     N.J. Bachman    (JPL) */
/*     W.L. Taber      (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    SPICELIB Version 2.0.2, 29-JUL-2003 (NJB) (CHA) */

/*        Only the header of the entry point FURNSH was modified. */
/*        Numerous updates were made to improve clarity.  Some */
/*        corrections were made. */

/* -    SPICELIB VERSION 2.0.1, 06-DEC-2002 (NJB) */

/*        Typo in header example was corrected. */

/* -    SPICELIB VERSION 2.0.0, 07-JAN-2002 (WLT) */

/*        Added a call to CVPOOL in FURNSH so that watches that are */
/*        triggered are triggered by loading Meta-kernels and not by */
/*        some external interaction with the kernel pool. */

/*        Added code to make sure that UNLOAD has the effect of */
/*        loading all remaining kernels in the order they were first */
/*        introduced. */

/* -    SPICELIB Version 1.1.0, 19-SEP-2000 (WLT) */

/*        Corrected the error message template used */
/*        by ZZLDKER */

/* -    SPICELIB Version 1.0.1, 16-DEC-1999 (NJB) */

/*        Documentation fix:  corrected second code example in the */
/*        header of the entry point FURNSH.  The example previously used */
/*        the kernel variable PATH_NAMES; that name has been replaced */
/*        with the correct name PATH_VALUES. */

/* -    SPICELIB Version 1.0.0, 01-JUL-1999 (WLT) */


/* -& */
/* $ Index_Entries */

/*     Generic loading and unloading of SPICE kernels */

/* -& */

/*     SPICELIB Functions */


/*     Here we set up the database of loaded kernels */

/*     The name of every file loaded through this interface will */
/*     be stored in the array FILES. */


/*     The handle of every loaded file will be stored in the array */
/*     HANDLS.  If the file is a text kernel it will be assigned the */
/*     handle 0. */


/*     The source of each file specified will be stored in the integer */
/*     array SOURCE.  If the file is loaded directly, its source */
/*     will be zero.  If it is loaded as the result of meta-information */
/*     in a text kernel, the index of the source file in FILES will */
/*     be stored in SRCES. */


/*     The file type of every loaded kernel will be stored in the array */
/*     TYPES. */


/*     The number of files loaded through this interfaces is kept in the */
/*     integer LOADED. */

    switch(n__) {
	case 1: goto L_furnsh;
	case 2: goto L_ktotal;
	case 3: goto L_kdata;
	case 4: goto L_kinfo;
	case 5: goto L_unload;
	}

    chkin_("KEEPER", (ftnlen)6);
    setmsg_("The routine KEEPER is an umbrella for a collection of entry poi"
	    "nts that manage the loading, tracking and unloading of SPICE ker"
	    "nels.  KEEPER should not be called directly. It is likely that a"
	    " programming error has been made. ", (ftnlen)225);
    sigerr_("SPICE(BOGUSENTRY)", (ftnlen)17);
    chkout_("KEEPER", (ftnlen)6);
    return 0;
/* $Procedure      FURNSH ( Furnish a program with SPICE kernels ) */

L_furnsh:
/* $ Abstract */

/*     Load one or more SPICE kernels into a program. */

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

/*      UTILITY */

/* $ Declarations */

/*     CHARACTER*(*)         FILE */

/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  -------------------------------------------------- */
/*     FILE       I   SPICE kernel file (text or binary). */

/* $ Detailed_Input */

/*     FILE       is a SPICE kernel file.  The file may be either binary */
/*                or text. If the file is a binary SPICE kernel it will */
/*                be loaded into the appropriate SPICE subsystem.  If */
/*                FILE is a SPICE text kernel it will be loaded into the */
/*                kernel pool. If FILE is a SPICE meta-kernel containing */
/*                initialization instructions (through use of the */
/*                correct kernel pool variables), the files specified in */
/*                those variables will be loaded into the appropriate */
/*                SPICE subsystem. */

/*                The SPICE text kernel format supports association of */
/*                names and data values using a "keyword = value" */
/*                format. The keyword-value pairs thus defined are */
/*                called "kernel variables." */

/*                While any information can be placed in a text kernel */
/*                file, the following string valued kernel variables are */
/*                recognized by SPICE as meta-kernel keywords: */

/*                     KERNELS_TO_LOAD */
/*                     PATH_SYMBOLS */
/*                     PATH_VALUES */

/*                Each kernel variable is discussed below. */

/*                KERNELS_TO_LOAD   is a list of SPICE kernels to be */
/*                                  loaded into a program.  If file */
/*                                  names do not fit within the kernel */
/*                                  pool 80 character limit, they may be */
/*                                  continued to subsequent array */
/*                                  elements by placing the continuation */
/*                                  character ('+') at the end of an */
/*                                  element and then placing the */
/*                                  remainder of the file name in the */
/*                                  next array element.  (See the */
/*                                  examples below for an illustration */
/*                                  of this technique or consult the */
/*                                  routine STPOOL for further details.) */

/*                                  Alternatively you may use a */
/*                                  PATH_SYMBOL (see below) to */
/*                                  substitute for some part of a file */
/*                                  name. */

/*                PATH_SYMBOLS      is a list of strings (without */
/*                                  embedded blanks) which if */
/*                                  encountered following the '$' */
/*                                  character will be replaced with the */
/*                                  corresponding PATH_VALUES string. */
/*                                  Note that PATH_SYMBOLS are */
/*                                  interpreted only in the */
/*                                  KERNELS_TO_LOAD variable. There must */
/*                                  be a one-to-one correspondence */
/*                                  between the values supplied for */
/*                                  PATH_SYMBOLS and PATH_VALUES. */

/*                PATH_VALUES       is a list of expansions to use when */
/*                                  PATH_SYMBOLS are encountered.  See */
/*                                  the examples section for an */
/*                                  illustration of use of PATH_SYMBOLS */
/*                                  and PATH_VALUES. */

/*               These kernel pool variables persist within the kernel */
/*               pool only until all kernels associated with the */
/*               variable KERNELS_TO_LOAD have been loaded.  Once all */
/*               specified kernels have been loaded, the variables */
/*               KERNELS_TO_LOAD, PATH_SYMBOLS and PATH_VALUES are */
/*               removed from the kernel pool. */

/* $ Detailed_Output */

/*     None. The routine loads various SPICE kernels for use by your */
/*     application. */

/* $ Parameters */

/*     None. */

/* $ Files */

/*     The input FILE is examined and loaded into the appropriate SPICE */
/*     subsystem.  If the file is a meta-kernel, any kernels specified */
/*     by the KERNELS_TO_LOAD keyword (and if present, the PATH_SYMBOLS */
/*     and PATH_VALUES keywords) are loaded as well. */

/* $ Exceptions */

/*     1) If a problem is encountered while trying to load FILE, */
/*        it will be diagnosed by a routine from the appropriate */
/*        SPICE subsystem. */

/*     2) If the input FILE is a meta-kernel and some file in the */
/*        KERNELS_TO_LOAD assignment cannot be found, the error */
/*        SPICE(CANTFINDFILE) will be signaled and the routine will */
/*        return. Any files loaded prior to encountering the missing */
/*        file will remain loaded. */

/*     3) If an error is encountered while trying to load one of the */
/*        files specified in the variable LOAD_KERNELS, the routine */
/*        will discontinue attempting to perform any other tasks */
/*        and return. */

/*     4) If a PATH_SYMBOLS assignment is specified without a */
/*        corresponding PATH_VALUES assignment, the error */
/*        SPICE(NOPATHVALUE) will be signaled. */

/*     5) If a meta-text kernel is supplied to FURNSH that contains */
/*        instructions specifying that another meta-text kernel be */
/*        loaded, the error SPICE(RECURSIVELOADING) will be signaled. */

/* $ Particulars */

/*     This routine provides a uniform interface to the SPICE kernel */
/*     loading systems.  It allows you to easily assemble a list of */
/*     SPICE kernels required by your application and to modify that set */
/*     without modifying the source code of programs that make use of */
/*     these kernels. */

/* $ Examples */

/*     Example 1 */
/*     --------- */

/*     Load the leapseconds kernel naif0007.tls and the planetary */
/*     ephemeris SPK file de405s.bsp. */

/*        CALL FURNSH ( naif0007.tls ) */
/*        CALL FURNSH ( de405s.bsp   ) */


/*     Example 2 */
/*     --------- */

/*     This example illustrates how you could create a meta-kernel file */
/*     for a program that requires several text and binary kernels. */

/*     First create a list of the kernels you need in a text file as */
/*     shown below. */

/*        \begintext */

/*           Here are the SPICE kernels required for my application */
/*           program. */

/*           Note that kernels are loaded in the order listed. Thus we */
/*           need to list the highest priority kernel last. */


/*        \begindata */

/*        KERNELS_TO_LOAD = ( */

/*              '/home/mydir/kernels/spk/lowest_priority.bsp', */
/*              '/home/mydir/kernels/spk/next_priority.bsp', */
/*              '/home/mydir/kernels/spk/highest_priority.bsp', */
/*              '/home/mydir/kernels/text/leapsecond.ker', */
/*              '/home/mydir/kernels+', */
/*              '/custom+', */
/*              '/kernel_data/constants.ker', */
/*              '/home/mydir/kernels/text/sclk.tsc', */
/*              '/home/mydir/kernels/ck/c-kernel.bc' ) */


/*     Note that the file name */

/*        /home/mydir/kernels/custom/kernel_data/constants.ker */

/*     is continued across several lines in the right hand side of the */
/*     assignment of the kernel variable KERNELS_TO_LOAD. */

/*     Once you've created your list of kernels, call FURNSH near the */
/*     beginning of your application program to load the meta-kernel */
/*     automatically at program start up. */

/*        CALL FURNSH ( 'myfile.txt' ) */

/*     This will cause each of the kernels listed in your meta-kernel */
/*     to be loaded. */


/*     Example 3 */
/*     --------- */

/*     This example illustrates how you can simplify the previous */
/*     kernel list by using PATH_SYMBOLS. */


/*        \begintext */

/*           Here are the SPICE kernels required for my application */
/*           program. */

/*           We are going to let A substitute for the directory that */
/*           contains SPK files; B substitute for the directory that */
/*           contains C-kernels; and C substitute for the directory that */
/*           contains text kernels.  And we'll let D substitute for */
/*           a "custom" directory that contains a special planetary */
/*           constants kernel made just for our mission. */

/*           Note that the order in which we list our PATH_VALUES must be */
/*           the same order that the corresponding PATH_SYMBOLS are */
/*           listed. */


/*        \begindata */

/*        PATH_VALUES  = ( '/home/mydir/kernels/spk', */
/*                         '/home/mydir/kernels/ck', */
/*                         '/home/mydir/kernels/text', */
/*                         '/home/mydir/kernels/custom/kernel_data' ) */

/*        PATH_SYMBOLS = ( 'A', */
/*                         'B', */
/*                         'C' */
/*                         'D'  ) */

/*        KERNELS_TO_LOAD = (  '$A/lowest_priority.bsp', */
/*                             '$A/next_priority.bsp', */
/*                             '$A/highest_priority.bsp', */
/*                             '$C/leapsecond.ker', */
/*                             '$D/constants.ker', */
/*                             '$C/sclk.tsc', */
/*                             '$B/c-kernel.bc'         ) */


/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     C.H. Acton      (JPL) */
/*     N.J. Bachman    (JPL) */
/*     W.L. Taber      (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    SPICELIB Version 2.0.1, 29-JUL-2003 (NJB) (CHA) */

/*        Numerous updates to improve clarity.  Some corrections were */
/*        made. */

/* -    SPICELIB VERSION 2.0.0, 23-AUG-2001 (WLT) */

/*        Added a call to CVPOOL in FURNSH so that watches that are */
/*        triggered are triggered by loading Meta-kernels and not by */
/*        some external interaction with the kernel pool. */

/* -    SPICELIB Version 1.1.0, 19-SEP-2000 (WLT) */

/*        Corrected the error message template used */
/*        by ZZLDKER */

/* -    SPICELIB Version 1.0.1, 16-DEC-1999 (NJB) */

/*        Documentation fix:  corrected second code example in the */
/*        header of this entry point.  The example previouly used the */
/*        kernel variable PATH_NAMES; that name has been replaced with */
/*        the correct name PATH_VALUES. */

/* -    SPICELIB Version 1.0.0, 01-JUL-1999 (WLT) */


/* -& */
/* $ Index_Entries */

/*     Load SPICE kernels from a list of kernels */

/* -& */

/*     Standard SPICE error handling. */

    if (return_()) {
	return 0;
    }
    chkin_("FURNSH", (ftnlen)6);
    if (first) {
	first = FALSE_;
	s_copy(known, "KERNELS_TO_LOAD", (ftnlen)32, (ftnlen)15);
	s_copy(known + 32, "PATH_SYMBOLS", (ftnlen)32, (ftnlen)12);
	s_copy(known + 64, "PATH_VALUES", (ftnlen)32, (ftnlen)11);
	loaded = 0;
	swpool_("FURNSH", &c__3, known, (ftnlen)6, (ftnlen)32);
	cvpool_("FURNSH", &update, (ftnlen)6);
    }

/*     Make sure we have room to load at least one more file. */

    if (loaded == 1300) {
	setmsg_("There is no room left in KEEPER to load another SPICE kerne"
		"l.  The current limit on the number of files that can be loa"
		"ded is #.  If you really need more than this many files, you"
		" should increase the parameter MAXFIL in the subroutine KEEP"
		"ER. ", (ftnlen)243);
	errint_("#", &c__1300, (ftnlen)1);
	sigerr_("SPICE(NOMOREROOM)", (ftnlen)17);
	chkout_("FURNSH", (ftnlen)6);
	return 0;
    }

/*     We don't want external interactions with the kernel pool to */
/*     have any affect on FURNSH's watch so we check the watcher */
/*     here prior to the call to ZZLDKER. */

    cvpool_("FURNSH", &update, (ftnlen)6);

/*     Set a preliminary value for the error message in case the */
/*     call to ZZLDKER doesn't succeed. */

    s_copy(nofile, "The attempt to load \"#\" by the routine FURNSH failed. "
	    "It #", (ftnlen)500, (ftnlen)58);
    zzldker_(file, nofile, thstyp, &myhand, file_len, (ftnlen)500, (ftnlen)32)
	    ;
    if (failed_()) {
	chkout_("FURNSH", (ftnlen)6);
	return 0;
    }
    ++loaded;
    cursrc = loaded;
    s_copy(files + ((i__1 = loaded - 1) < 1300 && 0 <= i__1 ? i__1 : s_rnge(
	    "files", i__1, "keeper_", (ftnlen)796)) * 255, file, (ftnlen)255, 
	    file_len);
    s_copy(types + (((i__1 = loaded - 1) < 1300 && 0 <= i__1 ? i__1 : s_rnge(
	    "types", i__1, "keeper_", (ftnlen)797)) << 3), thstyp, (ftnlen)8, 
	    (ftnlen)32);
    handls[(i__1 = loaded - 1) < 1300 && 0 <= i__1 ? i__1 : s_rnge("handls", 
	    i__1, "keeper_", (ftnlen)798)] = myhand;
    srces[(i__1 = loaded - 1) < 1300 && 0 <= i__1 ? i__1 : s_rnge("srces", 
	    i__1, "keeper_", (ftnlen)799)] = 0;
    cvpool_("FURNSH", &update, (ftnlen)6);
    if (! update) {

/*        Nothing to do.  None of the control variables */
/*        were set in FILE. */

	chkout_("FURNSH", (ftnlen)6);
	return 0;
    }

/*     See what is present in the kernel pool: Are any path symbols */
/*     defined? */

    dtpool_("PATH_SYMBOLS", &paths, &npaths, norc, (ftnlen)12, (ftnlen)1);
    if (paths && *(unsigned char *)norc == 'C') {

/*        Make sure that the values are equal in number. */

	if (badkpv_("FURNSH", "PATH_VALUES", "=", &npaths, &c__1, "C", (
		ftnlen)6, (ftnlen)11, (ftnlen)1, (ftnlen)1)) {
	    chkout_("FURNSH", (ftnlen)6);
	    return 0;
	}
    } else {
	paths = FALSE_;
    }

/*     This kernel appears to be a legitimate meta-text kernel.  Mark */
/*     it as such and then process its contents. */

    s_copy(types + (((i__1 = loaded - 1) < 1300 && 0 <= i__1 ? i__1 : s_rnge(
	    "types", i__1, "keeper_", (ftnlen)836)) << 3), "META", (ftnlen)8, 
	    (ftnlen)4);

/*     Now load all kernels specified in the KERNELS_TO_LOAD variable. */

    filnum = 1;
    stpool_("KERNELS_TO_LOAD", &filnum, "+", fil2ld, &size, &ok, (ftnlen)15, (
	    ftnlen)1, (ftnlen)255);
    while(ok) {

/*        First resolve any path symbols that may be present. */
/*        Make sure we have room to load at least one more file. */

	if (loaded == 1300) {
	    setmsg_("There is no room left in KEEPER to load another SPICE k"
		    "ernel.  The current limit on the number of files that ca"
		    "n be loaded is #.  If you really need more than this man"
		    "y files, you should increase the parameter MAXFIL in the"
		    " subroutine KEEPER. ", (ftnlen)243);
	    errint_("#", &c__1300, (ftnlen)1);
	    sigerr_("SPICE(NOMOREROOM)", (ftnlen)17);
	    chkout_("FURNSH", (ftnlen)6);
	    return 0;
	}
	if (paths) {
	    start = 1;
	    dollar = pos_(fil2ld, "$", &start, (ftnlen)255, (ftnlen)1);
	    while(dollar > 0) {

/*              Determine the longest path symbol that fits into the */
/*              current file name.  We fetch path symbols one at a */
/*              time and see if they match the portion of the */
/*              string that follows the '$'.  The longest match */
/*              is the one we use as a symbol. */

		size = 0;
		use = 0;
		d__ = dollar;
		i__1 = npaths;
		for (i__ = 1; i__ <= i__1; ++i__) {
		    gcpool_("PATH_SYMBOLS", &i__, &c__1, &n, symbol, &fnd, (
			    ftnlen)12, (ftnlen)80);
		    r__ = rtrim_(symbol, (ftnlen)80);
		    i__2 = d__ + 1;
		    i__3 = d__ + r__;
		    if (r__ > size && samsub_(symbol, &c__1, &r__, fil2ld, &
			    i__2, &i__3, (ftnlen)80, (ftnlen)255)) {
			use = i__;
			size = r__;
		    }
		}

/*              If we found a matching path symbol, get the corresponding */
/*              value and put it into the file name. */

		if (use > 0) {
		    gcpool_("PATH_VALUES", &use, &c__1, &n, pvalue, &fnd, (
			    ftnlen)11, (ftnlen)80);
		    l = rtrim_(pvalue, (ftnlen)80);
		    i__1 = d__ + size;
		    repsub_(fil2ld, &d__, &i__1, pvalue, fil2ld, (ftnlen)255, 
			    l, (ftnlen)255);
		}

/*              Look for the next occurrence of a '$' after the last */
/*              place we found one. */

		start = dollar + 1;
		dollar = pos_(fil2ld, "$", &start, (ftnlen)255, (ftnlen)1);
	    }
	}

/*        If any path symbols were present, they have now been */
/*        resolved.  Let ZZLDKER handle the task of loading this */
/*        kernel.  Make up a message template for use if ZZLDKER */
/*        runs into a problem. */

	s_copy(nofile, "The @ file '#' specified by KERNELS_TO_LOAD in the f"
		"ile @ #", (ftnlen)500, (ftnlen)59);
	repmot_(nofile, "@", &filnum, "L", nofile, (ftnlen)500, (ftnlen)1, (
		ftnlen)1, (ftnlen)500);
	repmc_(nofile, "@", file, nofile, (ftnlen)500, (ftnlen)1, file_len, (
		ftnlen)500);
	zzldker_(fil2ld, nofile, thstyp, &myhand, (ftnlen)255, (ftnlen)500, (
		ftnlen)32);
	if (failed_()) {
	    chkout_("FURNSH", (ftnlen)6);
	    return 0;
	}
	if (s_cmp(thstyp, "TEXT", (ftnlen)32, (ftnlen)4) == 0) {

/*           See if we stepped on any of the recognized variables.  If */
/*           we did, there's no point in trying to continue. */

	    cvpool_("FURNSH", &update, (ftnlen)6);
	    if (update) {

/*              First clean up the debris created by this attempt */
/*              at recursion. */

		for (i__ = 1; i__ <= 3; ++i__) {
		    dvpool_(known + (((i__1 = i__ - 1) < 3 && 0 <= i__1 ? 
			    i__1 : s_rnge("known", i__1, "keeper_", (ftnlen)
			    954)) << 5), (ftnlen)32);
		}

/*              Take care of any watcher activation caused by the */
/*              mop-up of the preceding loop. */

		cvpool_("FURNSH", &update, (ftnlen)6);
		setmsg_("Hmmm.  This is interesting. In the meta-text kernel"
			" '#' you've requested that the text kernel '#' be lo"
			"aded. This second file is also a \"meta-text\" kerne"
			"l and specifies new kernel loading instructions. Alt"
			"hough you receive high marks for creativity, this pa"
			"th is fraught with peril and can not be supported by"
			" FURNSH. ", (ftnlen)318);
		errch_("#", file, (ftnlen)1, file_len);
		errch_("#", fil2ld, (ftnlen)1, (ftnlen)255);
		sigerr_("SPICE(RECURSIVELOADING)", (ftnlen)23);
		chkout_("FURNSH", (ftnlen)6);
		return 0;
	    }
	}

/*        Add the latest file loaded to our database of loaded */
/*        files. */

	++loaded;
	s_copy(files + ((i__1 = loaded - 1) < 1300 && 0 <= i__1 ? i__1 : 
		s_rnge("files", i__1, "keeper_", (ftnlen)986)) * 255, fil2ld, 
		(ftnlen)255, (ftnlen)255);
	s_copy(types + (((i__1 = loaded - 1) < 1300 && 0 <= i__1 ? i__1 : 
		s_rnge("types", i__1, "keeper_", (ftnlen)987)) << 3), thstyp, 
		(ftnlen)8, (ftnlen)32);
	handls[(i__1 = loaded - 1) < 1300 && 0 <= i__1 ? i__1 : s_rnge("hand"
		"ls", i__1, "keeper_", (ftnlen)988)] = myhand;
	srces[(i__1 = loaded - 1) < 1300 && 0 <= i__1 ? i__1 : s_rnge("srces",
		 i__1, "keeper_", (ftnlen)989)] = cursrc;

/*        Get the name of the next file to load. */

	++filnum;
	stpool_("KERNELS_TO_LOAD", &filnum, "+", fil2ld, &size, &ok, (ftnlen)
		15, (ftnlen)1, (ftnlen)255);
    }

/*     Last Step.  Remove the special variables from the kernel pool. */

    for (i__ = 1; i__ <= 3; ++i__) {
	dvpool_(known + (((i__1 = i__ - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge(
		"known", i__1, "keeper_", (ftnlen)1003)) << 5), (ftnlen)32);
    }
    cvpool_("FURNSH", &update, (ftnlen)6);
    chkout_("FURNSH", (ftnlen)6);
    return 0;
/* $Procedure      KTOTAL ( Kernel Totals ) */

L_ktotal:
/* $ Abstract */

/*     Return the number of kernels that are currently loaded */
/*     via the KEEPER interface and that are of a specified type. */

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

/*     KERNEL */

/* $ Declarations */

/*     CHARACTER*(*)         KIND */
/*     INTEGER               COUNT */

/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  -------------------------------------------------- */
/*     KIND       I   A list of kinds of kernels to count. */
/*     COUNT      O   The number of kernels of type KIND. */

/* $ Detailed_Input */

/*     KIND       is a list of types of kernels to count when */
/*                computing loaded kernels.  KIND should consist */
/*                of a list of words of kernels to examine.  Recognized */
/*                types are */

/*                   SPK  --- all SPK files are counted in the total. */
/*                   CK   --- all CK files are counted in the total. */
/*                   PCK  --- all binary PCK files are counted in the */
/*                            total. */
/*                   EK   --- all EK files are counted in the total. */
/*                   TEXT --- all text kernels that are not meta-text */
/*                            kernels are included in the total. */
/*                   META --- all meta-text kernels are counted in the */
/*                            total. */
/*                   ALL  --- every type of kernel is counted in the */
/*                            total. */

/*                 KIND is case insensitive.  If a word appears in KIND */
/*                 that is not one of those listed above it is ignored. */

/*                 See the Examples section for illustrations of the */
/*                 use of KIND. */

/* $ Detailed_Output */

/*     COUNT       is the number of kernels loaded through FURNSH that */
/*                 belong to the list specified by KIND. */

/* $ Parameters */

/*     None. */

/* $ Files */

/*     None. */

/* $ Exceptions */

/*     1) If a word on the list specified by KIND is not recognized */
/*        it is ignored. */

/*     2) If KIND is blank, or none of the words in KIND is on the */
/*        list specified above, COUNT will be returned as zero. */

/* $ Particulars */

/*     KTOTAL allows you to easily determine the number of kernels */
/*     loaded via the interface FURNSH that are of a type of interest. */

/* $ Examples */

/*     Suppose you wish to determine the number of SPK kernels that */
/*     have been loaded via the interface FURNSH.  Assign KIND */
/*     the value 'SPK' and call KTOTAL as shown: */


/*        KIND = 'SPK' */
/*        CALL KTOTAL ( KIND, COUNT ) */

/*        WRITE (*,*) 'The number of loaded SPK files is: ', COUNT */

/*     To determine the number of text kernels that are loaded that */
/*     are not meta-kernels: */

/*        KIND = 'TEXT' */
/*        CALL KTOTAL ( KIND, NTEXT ) */

/*        WRITE (*,*) 'The number of non-meta-text kernels loaded is: ' */
/*       .             NTEXT */

/*     To determine the number of SPK, CK and PCK kernels loaded */
/*     make the following call: */

/*        KIND = 'SPK PCK CK' */
/*        CALL KTOTAL ( KIND, COUNT ) */


/*     To get a count of all loaded kernels */

/*        KIND = 'ALL' */
/*        CALL KTOTAL ( KIND, COUNT ) */

/*        WRITE (*,*) 'There are ', COUNT, ' SPICE kernels loaded.' */


/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     W.L. Taber      (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    SPICELIB Version 1.0.0, 01-JUL-1999 (WLT) */


/* -& */
/* $ Index_Entries */

/*     Number of loaded kernels of a given type */

/* -& */
    if (loaded == 0) {
	*count = 0;
	return 0;
    }
    chkin_("KTOTAL", (ftnlen)6);

/*     Parse KIND to see which kernels are of interest. */

    dospk = FALSE_;
    dock = FALSE_;
    dotext = FALSE_;
    dometa = FALSE_;
    doek = FALSE_;
    dopck = FALSE_;
    doall = FALSE_;
    start = 1;
    fndnwd_(kind, &start, &b, &e, kind_len);
    while(b > 0) {
	if (eqstr_(kind + (b - 1), "ALL", e - (b - 1), (ftnlen)3)) {
	    *count = loaded;
	    chkout_("KTOTAL", (ftnlen)6);
	    return 0;
	} else {
	    dock = dock || eqstr_(kind + (b - 1), "CK", e - (b - 1), (ftnlen)
		    2);
	    doek = doek || eqstr_(kind + (b - 1), "EK", e - (b - 1), (ftnlen)
		    2);
	    dometa = dometa || eqstr_(kind + (b - 1), "META", e - (b - 1), (
		    ftnlen)4);
	    dopck = dopck || eqstr_(kind + (b - 1), "PCK", e - (b - 1), (
		    ftnlen)3);
	    dospk = dospk || eqstr_(kind + (b - 1), "SPK", e - (b - 1), (
		    ftnlen)3);
	    dotext = dotext || eqstr_(kind + (b - 1), "TEXT", e - (b - 1), (
		    ftnlen)4);
	}
	start = e + 1;
	fndnwd_(kind, &start, &b, &e, kind_len);
    }
    *count = 0;
    i__1 = loaded;
    for (i__ = 1; i__ <= i__1; ++i__) {
	add = s_cmp(types + (((i__2 = i__ - 1) < 1300 && 0 <= i__2 ? i__2 : 
		s_rnge("types", i__2, "keeper_", (ftnlen)1225)) << 3), "CK", (
		ftnlen)8, (ftnlen)2) == 0 && dock || s_cmp(types + (((i__3 = 
		i__ - 1) < 1300 && 0 <= i__3 ? i__3 : s_rnge("types", i__3, 
		"keeper_", (ftnlen)1225)) << 3), "EK", (ftnlen)8, (ftnlen)2) 
		== 0 && doek || s_cmp(types + (((i__4 = i__ - 1) < 1300 && 0 
		<= i__4 ? i__4 : s_rnge("types", i__4, "keeper_", (ftnlen)
		1225)) << 3), "META", (ftnlen)8, (ftnlen)4) == 0 && dometa || 
		s_cmp(types + (((i__5 = i__ - 1) < 1300 && 0 <= i__5 ? i__5 : 
		s_rnge("types", i__5, "keeper_", (ftnlen)1225)) << 3), "PCK", 
		(ftnlen)8, (ftnlen)3) == 0 && dopck || s_cmp(types + (((i__6 =
		 i__ - 1) < 1300 && 0 <= i__6 ? i__6 : s_rnge("types", i__6, 
		"keeper_", (ftnlen)1225)) << 3), "SPK", (ftnlen)8, (ftnlen)3) 
		== 0 && dospk || s_cmp(types + (((i__7 = i__ - 1) < 1300 && 0 
		<= i__7 ? i__7 : s_rnge("types", i__7, "keeper_", (ftnlen)
		1225)) << 3), "TEXT", (ftnlen)8, (ftnlen)4) == 0 && dotext;
	if (add) {
	    ++(*count);
	}
    }
    chkout_("KTOTAL", (ftnlen)6);
    return 0;
/* $Procedure      KDATA ( Kernel Data ) */

L_kdata:
/* $ Abstract */

/*     Return data for the nth kernel that is among a list of specified */
/*     kernel types. */

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

/*     KERNEL */

/* $ Declarations */

/*     INTEGER               WHICH */
/*     CHARACTER*(*)         KIND */
/*     CHARACTER*(*)         FILE */
/*     CHARACTER*(*)         FILTYP */
/*     CHARACTER*(*)         SOURCE */
/*     INTEGER               HANDLE */
/*     LOGICAL               FOUND */

/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  -------------------------------------------------- */
/*     WHICH      I   Index of kernel to fetch from the list of kernels. */
/*     KIND       I   The kind of kernel to which fetches are limited. */
/*     FILE       O   The name of the kernel file. */
/*     FILTYP     O   The type of the kernel. */
/*     SOURCE     O   Name of the source file used to load FILE. */
/*     HANDLE     O   The handle attached to FILE. */
/*     FOUND      O   TRUE if the specified file could be located. */

/* $ Detailed_Input */

/*     WHICH      is the number of the kernel to fetch (matching the */
/*                type specified by KIND) from the list of kernels that */
/*                have been loaded through the entry point FURNSH but */
/*                that have not been unloaded through the entry point */
/*                UNLOAD. */

/*     KIND       is a list of types of kernels to be considered when */
/*                fetching kernels from the list of loaded kernels. KIND */
/*                should consist of words from list of kernel types */
/*                given below. */

/*                   SPK  --- All SPK files are counted in the total. */
/*                   CK   --- All CK files are counted in the total. */
/*                   PCK  --- All binary PCK files are counted in the */
/*                            total. */
/*                   EK   --- All EK files are counted in the total. */
/*                   TEXT --- All text kernels that are not meta-text */
/*                            kernels are included in the total. */
/*                   META --- All meta-text kernels are counted in the */
/*                            total. */
/*                   ALL  --- Every type of kernel is counted in the */
/*                            total. */

/*                 KIND is case insensitive.  If a word appears in KIND */
/*                 that is not one of those listed above it is ignored. */

/*                 See the entry point KTOTAL for examples of the use */
/*                 of KIND. */

/* $ Detailed_Output */

/*     FILE        is the name of the WHICH'th file of a type matching */
/*                 KIND that is currently loaded via FURNSH.  FILE */
/*                 will be blank if there is not a WHICH'th kernel. */

/*     FILTYP      is the type of the kernel specified by FILE.  FILE */
/*                 will be blank if there is no file matching the */
/*                 specification of WHICH and KIND. */

/*     SOURCE      is the name of the source file that was used to */
/*                 specify FILE as one to load.  If FILE was loaded */
/*                 directly via a call to FURNSH, SOURCE will be blank. */
/*                 If there is no file matching the specification of */
/*                 WHICH and KIND, SOURCE will be blank. */

/*     HANDLE      is the handle attached to FILE if it is a binary */
/*                 kernel.  If FILE is a text kernel or meta-text kernel */
/*                 HANDLE will be zero.  If there is no file matching */
/*                 the specification of WHICH and KIND, HANDLE will be */
/*                 set to zero. */

/*     FOUND       is returned TRUE if a FILE matching the specification */
/*                 of WHICH and KIND exists.  If there is no such file, */
/*                 FOUND will be set to FALSE. */

/* $ Parameters */

/*     None. */

/* $ Files */

/*     None. */

/* $ Exceptions */

/*     Error free. */

/*     1) If a file is not loaded matching the specification of WHICH */
/*        and KIND, FOUND will be FALSE, FILE, FILTYP, and SOURCE */
/*        will be blank and HANDLE will be set to zero. */

/* $ Particulars */

/*     This entry point allows you to determine which kernels have */
/*     been loaded via FURNSH and to obtain information sufficient */
/*     to directly query those files. */

/* $ Examples */

/*     The following example shows how you could print a summary */
/*     of SPK files that have been loaded through the interface */
/*     FURNSH. */


/*     CALL KTOTAL ( 'SPK', COUNT ) */

/*     IF ( COUNT .EQ. 0 ) THEN */
/*        WRITE (*,*) 'There are no SPK files loaded at this time.' */
/*     ELSE */
/*        WRITE (*,*) 'The loaded SPK files are: ' */
/*        WRITE (*,*) */
/*     END IF */

/*     DO WHICH = 1, COUNT */

/*        CALL KDATA( WHICH, 'SPK', FILE, FILTYP, SOURCE, HANDLE, FOUND ) */
/*        WRITE (*,*) FILE */

/*     END DO */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     W.L. Taber      (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    SPICELIB Version 1.0.1, 06-DEC-2002 (NJB) */

/*        Typo in header example was corrected. */

/* -    SPICELIB Version 1.0.0, 01-JUL-1999 (WLT) */


/* -& */
/* $ Index_Entries */

/*     Retrieve information on loaded SPICE kernels */

/* -& */
    s_copy(file, " ", file_len, (ftnlen)1);
    s_copy(filtyp, " ", filtyp_len, (ftnlen)1);
    s_copy(source, " ", source_len, (ftnlen)1);
    *handle = 0;
    *found = FALSE_;
    if (*which < 1 || *which > loaded) {
	return 0;
    }

/*     Parse KIND to see which kernels are of interest. */

    dospk = FALSE_;
    dock = FALSE_;
    dotext = FALSE_;
    dometa = FALSE_;
    doek = FALSE_;
    dopck = FALSE_;
    doall = FALSE_;
    start = 1;
    fndnwd_(kind, &start, &b, &e, kind_len);
    while(b > 0) {
	if (eqstr_(kind + (b - 1), "ALL", e - (b - 1), (ftnlen)3)) {

/*           There's no point in going on, we can fill in the output */
/*           variables right now. */

	    *found = TRUE_;
	    s_copy(file, files + ((i__1 = *which - 1) < 1300 && 0 <= i__1 ? 
		    i__1 : s_rnge("files", i__1, "keeper_", (ftnlen)1467)) * 
		    255, file_len, (ftnlen)255);
	    s_copy(filtyp, types + (((i__1 = *which - 1) < 1300 && 0 <= i__1 ?
		     i__1 : s_rnge("types", i__1, "keeper_", (ftnlen)1468)) <<
		     3), filtyp_len, (ftnlen)8);
	    *handle = handls[(i__1 = *which - 1) < 1300 && 0 <= i__1 ? i__1 : 
		    s_rnge("handls", i__1, "keeper_", (ftnlen)1469)];
	    if (srces[(i__1 = *which - 1) < 1300 && 0 <= i__1 ? i__1 : s_rnge(
		    "srces", i__1, "keeper_", (ftnlen)1471)] != 0) {
		s_copy(source, files + ((i__2 = srces[(i__1 = *which - 1) < 
			1300 && 0 <= i__1 ? i__1 : s_rnge("srces", i__1, 
			"keeper_", (ftnlen)1472)] - 1) < 1300 && 0 <= i__2 ? 
			i__2 : s_rnge("files", i__2, "keeper_", (ftnlen)1472))
			 * 255, source_len, (ftnlen)255);
	    }
	    return 0;
	} else {
	    dock = dock || eqstr_(kind + (b - 1), "CK", e - (b - 1), (ftnlen)
		    2);
	    doek = doek || eqstr_(kind + (b - 1), "EK", e - (b - 1), (ftnlen)
		    2);
	    dometa = dometa || eqstr_(kind + (b - 1), "META", e - (b - 1), (
		    ftnlen)4);
	    dopck = dopck || eqstr_(kind + (b - 1), "PCK", e - (b - 1), (
		    ftnlen)3);
	    dospk = dospk || eqstr_(kind + (b - 1), "SPK", e - (b - 1), (
		    ftnlen)3);
	    dotext = dotext || eqstr_(kind + (b - 1), "TEXT", e - (b - 1), (
		    ftnlen)4);
	}
	start = e + 1;
	fndnwd_(kind, &start, &b, &e, kind_len);
    }

/*     Examine the loaded kernels one at a time until we match */
/*     WHICH files of the specified KIND. */

    hits = 0;
    i__1 = loaded;
    for (i__ = 1; i__ <= i__1; ++i__) {
	add = s_cmp(types + (((i__2 = i__ - 1) < 1300 && 0 <= i__2 ? i__2 : 
		s_rnge("types", i__2, "keeper_", (ftnlen)1498)) << 3), "CK", (
		ftnlen)8, (ftnlen)2) == 0 && dock || s_cmp(types + (((i__3 = 
		i__ - 1) < 1300 && 0 <= i__3 ? i__3 : s_rnge("types", i__3, 
		"keeper_", (ftnlen)1498)) << 3), "EK", (ftnlen)8, (ftnlen)2) 
		== 0 && doek || s_cmp(types + (((i__4 = i__ - 1) < 1300 && 0 
		<= i__4 ? i__4 : s_rnge("types", i__4, "keeper_", (ftnlen)
		1498)) << 3), "META", (ftnlen)8, (ftnlen)4) == 0 && dometa || 
		s_cmp(types + (((i__5 = i__ - 1) < 1300 && 0 <= i__5 ? i__5 : 
		s_rnge("types", i__5, "keeper_", (ftnlen)1498)) << 3), "PCK", 
		(ftnlen)8, (ftnlen)3) == 0 && dopck || s_cmp(types + (((i__6 =
		 i__ - 1) < 1300 && 0 <= i__6 ? i__6 : s_rnge("types", i__6, 
		"keeper_", (ftnlen)1498)) << 3), "SPK", (ftnlen)8, (ftnlen)3) 
		== 0 && dospk || s_cmp(types + (((i__7 = i__ - 1) < 1300 && 0 
		<= i__7 ? i__7 : s_rnge("types", i__7, "keeper_", (ftnlen)
		1498)) << 3), "TEXT", (ftnlen)8, (ftnlen)4) == 0 && dotext;
	if (add) {
	    ++hits;

/*           If we've reached the specified number, fill in the */
/*           requested information and return. */

	    if (hits == *which) {
		*found = TRUE_;
		s_copy(file, files + ((i__2 = i__ - 1) < 1300 && 0 <= i__2 ? 
			i__2 : s_rnge("files", i__2, "keeper_", (ftnlen)1515))
			 * 255, file_len, (ftnlen)255);
		s_copy(filtyp, types + (((i__2 = i__ - 1) < 1300 && 0 <= i__2 
			? i__2 : s_rnge("types", i__2, "keeper_", (ftnlen)
			1516)) << 3), filtyp_len, (ftnlen)8);
		*handle = handls[(i__2 = i__ - 1) < 1300 && 0 <= i__2 ? i__2 :
			 s_rnge("handls", i__2, "keeper_", (ftnlen)1517)];
		if (srces[(i__2 = i__ - 1) < 1300 && 0 <= i__2 ? i__2 : 
			s_rnge("srces", i__2, "keeper_", (ftnlen)1519)] != 0) 
			{
		    s_copy(source, files + ((i__3 = srces[(i__2 = i__ - 1) < 
			    1300 && 0 <= i__2 ? i__2 : s_rnge("srces", i__2, 
			    "keeper_", (ftnlen)1520)] - 1) < 1300 && 0 <= 
			    i__3 ? i__3 : s_rnge("files", i__3, "keeper_", (
			    ftnlen)1520)) * 255, source_len, (ftnlen)255);
		}
		return 0;
	    }
	}
    }
    return 0;
/* $Procedure      KINFO ( Kernel Information ) */

L_kinfo:
/* $ Abstract */

/*     Return information about a specific kernel */

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

/*     KERNEL */

/* $ Declarations */

/*     CHARACTER*(*)         FILE */
/*     CHARACTER*(*)         FILTYP */
/*     CHARACTER*(*)         SOURCE */
/*     INTEGER               HANDLE */
/*     LOGICAL               FOUND */

/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  -------------------------------------------------- */
/*     FILE       I   Name of a kernel to fetch information for */
/*     FILTYP     O   The type of the kernel */
/*     SOURCE     O   Name of the source file used to load FILE. */
/*     HANDLE     O   The handle attached to FILE. */
/*     FOUND      O   TRUE if the specified file could be located. */

/* $ Detailed_Input */

/*     FILE       is the name of a kernel file for which KEEPER */
/*                information is desired. */

/* $ Detailed_Output */

/*     FILTYP      is the type of the kernel specified by FILE.  FILE */
/*                 will be blank if FILE is not on the list of loaded */
/*                 kernels. */

/*     SOURCE      is the name of the source file that was used to */
/*                 specify FILE as one to load.  If FILE was loaded */
/*                 directly via a call to FURNSH, SOURCE will be blank. */
/*                 If FILE is not on the list of loaded kernels, SOURCE */
/*                 will be blank */

/*     HANDLE      is the handle attached to FILE if it is a binary */
/*                 kernel.  If FILE is a text kernel or meta-text kernel */
/*                 HANDLE will be zero.  If FILE is not on the list of */
/*                 loaded kernels, HANDLE will be set to zero. */

/*     FOUND       is returned TRUE if FILE is on the KEEPER list of */
/*                 loaded kernels.  If there is no such file, FOUND will */
/*                 be set to FALSE. */

/* $ Parameters */

/*     None. */

/* $ Files */

/*     None. */

/* $ Exceptions */

/*     Error free. */

/*     1) If the specified file is not on the list of files that */
/*        are currently loaded via the interface FURNSH, FOUND */
/*        will be FALSE, HANDLE will be set to zero and FILTYP */
/*        and SOURCE will be set to blanks. */

/* $ Particulars */

/*     This entry point allows you to request information directly */
/*     for a specific SPICE kernel. */

/* $ Examples */

/*     Suppose you wish to determine the type of a loaded kernel */
/*     so that you can call the correct summarizing routines */
/*     for the kernel.  The following bit of pseudo code shows */
/*     how you might use this entry point together with summarizing */
/*     code to produce a report on the file.  (Note that the */
/*     routines SPK_SUMMRY, CK_SUMMRY, PCK_SUMMRY and EK_SUMMRY */
/*     are simply names to indicate what you might do with the */
/*     information returned by KINFO.  They are not routines that */
/*     are part of the SPICE toolkit.) */

/*     FILE = '<name of the file of interest>' */

/*     CALL KINFO ( FILE, FILTYP, SOURCE, HANDLE, FOUND ) */

/*     IF ( .NOT. FOUND ) THEN */
/*        WRITE (*,*) FILE */
/*        WRITE (*,*) 'is not loaded at this time.' */
/*     ELSE */

/*        IF      ( FILTYP .EQ. 'SPK' ) THEN */

/*           WRITE (*,*) FILE */
/*           WRITE (*,*) 'is an SPK file.' */

/*           CALL SPK_SUMMRY ( HANDLE ) */

/*        ELSE IF ( FILTYP .EQ. 'CK'  ) THEN */

/*           WRITE (*,*) FILE */
/*           WRITE (*,*) 'is a CK file.' */

/*           CALL CK_SUMMRY ( HANDLE ) */

/*        ELSE IF ( FILTYP .EQ. 'PCK' ) THEN */

/*           WRITE (*,*) FILE */
/*           WRITE (*,*) 'is a  PCK file.' */

/*           CALL PCK_SUMMRY ( HANDLE ) */

/*        ELSE IF ( FILTYP .EQ. 'EK'  ) THEN */

/*           WRITE (*,*) FILE */
/*           WRITE (*,*) 'is an EK file.' */

/*           CALL EK_SUMMRY ( HANDLE ) */

/*        ELSE IF ( FILTYP .EQ. 'META') THEN */
/*           WRITE (*,*) FILE */
/*           WRITE (*,*) 'is a meta-text kernel.' */
/*        ELSE */
/*           WRITE (*,*) FILE */
/*           WRITE (*,*) 'is a text kernel.' */
/*        END IF */


/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     W.L. Taber      (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    SPICELIB Version 1.0.0, 01-JUL-1999 (WLT) */


/* -& */
/* $ Index_Entries */

/*     Fetch information about a loaded SPICE kernel */

/* -& */
    s_copy(filtyp, " ", filtyp_len, (ftnlen)1);
    s_copy(source, " ", source_len, (ftnlen)1);
    *handle = 0;
    *found = FALSE_;
    i__ = isrchc_(file, &loaded, files, file_len, (ftnlen)255);
    if (i__ > 0) {
	*found = TRUE_;
	s_copy(filtyp, types + (((i__1 = i__ - 1) < 1300 && 0 <= i__1 ? i__1 :
		 s_rnge("types", i__1, "keeper_", (ftnlen)1734)) << 3), 
		filtyp_len, (ftnlen)8);
	*handle = handls[(i__1 = i__ - 1) < 1300 && 0 <= i__1 ? i__1 : s_rnge(
		"handls", i__1, "keeper_", (ftnlen)1735)];
	if (srces[(i__1 = i__ - 1) < 1300 && 0 <= i__1 ? i__1 : s_rnge("srces"
		, i__1, "keeper_", (ftnlen)1737)] != 0) {
	    s_copy(source, files + ((i__2 = srces[(i__1 = i__ - 1) < 1300 && 
		    0 <= i__1 ? i__1 : s_rnge("srces", i__1, "keeper_", (
		    ftnlen)1738)] - 1) < 1300 && 0 <= i__2 ? i__2 : s_rnge(
		    "files", i__2, "keeper_", (ftnlen)1738)) * 255, 
		    source_len, (ftnlen)255);
	}
    }
    return 0;
/* $Procedure      UNLOAD ( Unload a kernel ) */

L_unload:
/* $ Abstract */

/*     Unload a SPICE kernel. */

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

/*     KERNEL */

/* $ Declarations */

/*     CHARACTER*(*)         FILE */

/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  -------------------------------------------------- */
/*     FILE       I   The name of a kernel to unload. */

/* $ Detailed_Input */

/*     FILE       is the name of a file to unload.  This file */
/*                should be one loaded through the interface FURNSH. */
/*                If the file is not on the list of loaded kernels */
/*                no action is taken. */

/*                Note that if FILE is a meta-text kernel, all of */
/*                the files loaded as a result of loading the meta-text */
/*                kernel will be unloaded. */

/* $ Detailed_Output */

/*     None. */

/* $ Parameters */

/*     None. */

/* $ Files */

/*     None. */

/* $ Exceptions */

/*     Error free. */

/*     1) If the specified kernel is not on the list of loaded kernels */
/*        no action is taken. */

/* $ Particulars */

/*     The call */

/*        CALL UNLOAD ( FILE ) */

/*     has the effect of "erasing" the last previous call: */

/*        CALL FURNSH ( FILE ) */

/*     This interface allows you to unload binary and text kernels. */
/*     Moreover, if you used a meta-text kernel to set up your */
/*     working environment, you can unload all of the kernels loaded */
/*     through the meta-kernel by unloading the meta-kernel. */

/*     The usual usage of FURNSH is to load each file needed by your */
/*     program exactly one time.  However, it is possible to load a */
/*     kernel more than one time.  (Usually, this is a result of loading */
/*     meta-kernels without taking the care needed to ensure that the */
/*     meta-kernels do not specify the same file more than once.)  The */
/*     effect of unloading a kernel that has been loaded more than once */
/*     is to "undo" the last loading of the kernel.  Depending upon the */
/*     kernel and its relationship to other loaded kernels, this may */
/*     have no visible effect on the working of your program.  To */
/*     illustrate this behaviour suppose that you have a collection of */
/*     files FILE1, FILE2, FILE3, FILE4, FILE5, FILE6, FILE7, FILE8, */
/*     META1, META2  where FILE1 ... FILE8 are SPICE kernels and META1 */
/*     and META2 are meta-kernels with the specified kernels to load as */
/*     shown below. */


/*         META1: */
/*            KERNELS_TO_LOAD = ( FILE2, */
/*                                FILE3, */
/*                                FILE4, */
/*                                FILE5 ) */

/*         META2: */
/*            KERNELS_TO_LOAD = ( FILE2, */
/*                                FILE3, */
/*                                FILE7, */
/*                                FILE8 ) */


/*      The following sequence of calls */

/*          CALL FURNSH ( FILE1 ) */
/*          CALL FURNSH ( FILE2 ) */
/*          CALL FURNSH ( FILE3 ) */
/*          CALL FURNSH ( META1 ) */
/*          CALL FURNSH ( FILE6 ) */
/*          CALL FURNSH ( META2 ) */

/*      has the effect: */

/*          "Load" FILE1 */
/*          "Load" FILE2 */
/*          "Load" FILE3 */
/*          "Load" META1 as a text kernel and then... */
/*                "Load" FILE2 (note that it was loaded from META1) */
/*                "Load" FILE3 (note that it was loaded from META1) */
/*                "Load" FILE4 (note that it was loaded from META1) */
/*                "Load" FILE5 (note that it was loaded from META1) */
/*          "Load" FILE6 */
/*          "Load" META2 as a text kernel and then... */
/*                "Load" FILE2 (note that it was loaded from META2) */
/*                "Load" FILE3 (note that it was loaded from META2) * */
/*                "Load" FILE7 (note that it was loaded from META2) */
/*                "Load" FILE8 (note that it was loaded from META2) */

/*      If we  UNLOAD FILE3 */

/*         CALL UNLOAD ( FILE3 ) */

/*      we locate the last time FILE3 was loaded (* above) and modify the */
/*      state of loaded kernels so that it looks as if we had made the */
/*      following sequence of "load" operations. */

/*          "Load" FILE1 */
/*          "Load" FILE2 */
/*          "Load" FILE3 */
/*          "Load" META1 as a text kernel and then... */
/*                "Load" FILE2 (note that it was loaded from META1) */
/*                "Load" FILE3 (note that it was loaded from META1) */
/*                "Load" FILE4 (note that it was loaded from META1) */
/*                "Load" FILE5 (note that it was loaded from META1) */
/*          "Load" FILE6 */
/*          "Load" META2 as a text kernel and then... */
/*                "Load" FILE2 (note that it was loaded from META2) */
/*                "Load" FILE7 (note that it was loaded from META2) */
/*                "Load" FILE8 (note that it was loaded from META2) */

/*      As you can see, the data from FILE3 is still available to the */
/*      program.  All that may have changed is the usage priority */
/*      associated with that data. */

/*      If we unload META2 (or META1) we remove all remaining files that */
/*      are noted as being loaded from META2 (or META1) */

/*          CALL UNLOAD ( META2 ) */

/*      produces the following load state for the program: */

/*          "Load" FILE1 */
/*          "Load" FILE2 */
/*          "Load" FILE3 */
/*          "Load" META1 as a text kernel and then... */
/*                "Load" FILE2 (note that it was loaded from META1) */
/*                "Load" FILE3 (note that it was loaded from META1) */
/*                "Load" FILE4 (note that it was loaded from META1) */
/*                "Load" FILE5 (note that it was loaded from META1) */
/*          "Load" FILE6 */

/*      If we had unloaded META1 instead, we would have this load state. */

/*          "Load" FILE1 */
/*          "Load" FILE2 */
/*          "Load" FILE3 */
/*          "Load" FILE6 */
/*          "Load" META2 as a text kernel and then... */
/*                "Load" FILE2 (note that it was loaded from META2) */
/*                "Load" FILE7 (note that it was loaded from META2) */
/*                "Load" FILE8 (note that it was loaded from META2) */

/*      So we see that unloading a file does not necessarily make its */
/*      data unavailable to your program.  Unloading modifies the */
/*      precedence of the files loaded in your program. The data */
/*      associated with an unloaded file becomes unavailable only when */
/*      the file has been unloaded as many times as it was loaded. */

/*      When would you encounter such a scenario? The situation of */
/*      loading a file more than once might appear if you were trying to */
/*      contrast the results of computations performed with two */
/*      different meta-kernels.  In such a scenario you might load a */
/*      "baseline" set of kernels early in your program and then load */
/*      and unload meta-kernels to compare results between the two */
/*      different sets of data. */

/*     Unloading Text or Meta-text Kernels. */

/*     Part of the action of unloading text (or meta-text kernels) is */
/*     the clearing of the kernel pool and re-loading any kernels that */
/*     were not in the specified set of kernels to unload.  Since */
/*     loading of text kernels is not a very fast process, unloading */
/*     text kernels takes considerably longer than unloading binary */
/*     kernels.  Moreover, since the kernel pool is cleared, any kernel */
/*     pool variables you have set from your program by using one of the */
/*     interfaces PCPOOL, PDPOOL, PIPOOL, or LMPOOL will be removed from */
/*     the kernel pool.  For this reason, if you plan to use this */
/*     feature in your program, together with one of the routines */
/*     specified above, you will need to take special precautions to */
/*     make sure kernel pool variables required by your program, do not */
/*     inadvertently disappear. */

/* $ Examples */

/*     Suppose that you wish to compare two different sets of kernels */
/*     used to describe the geometry of a mission (for example a predict */
/*     model and a reconstructed model). You can place all of the */
/*     kernels for one model in one meta-text kernel, and the other set */
/*     in a second meta-text kernel.  Let's call these PREDICT.MTA and */
/*     ACTUAL.MTA. */

/*        CALL FURNSH ( 'PREDCT.MTA' ) */

/*        compute quantities of interest and store them */
/*        for comparison with results of reconstructed */
/*        (actual) kernels. */

/*        Now unload the predict model and load the reconstructed */
/*        model. */

/*        CALL UNLOAD ( 'PREDCT.MTA' ) */
/*        CALL FURNSH ( 'ACTUAL.MTA' ) */

/*        re-compute quantities of interest and compare them */
/*        with the stored quantities. */

/* $ Restrictions */

/*     See the note regarding the unloading of Text and meta-text */
/*     Kernels. */

/* $ Author_and_Institution */

/*     W.L. Taber      (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    SPICELIB VERSION 2.0.0, 23-AUG-2001 (WLT) */

/*        Added code to make sure that UNLOAD has the effect of */
/*        loading all remaining kernels in the order they were first */
/*        introduced. */

/* -    SPICELIB Version 1.0.0, 01-JUL-1999 (WLT) */


/* -& */
/* $ Index_Entries */

/*     Unload a SPICE kernel */

/* -& */
    if (return_()) {
	return 0;
    }
    chkin_("UNLOAD", (ftnlen)6);
    didspk = FALSE_;
    didpck = FALSE_;
    didck = FALSE_;
    didek = FALSE_;
    didtxt = FALSE_;

/*     First locate the file we need to unload, we search backward */
/*     through the list of loaded files so that we unload in the right */
/*     order. */

    gotit = FALSE_;
    i__ = loaded;
    while(! gotit && i__ > 0) {
	if (s_cmp(files + ((i__1 = i__ - 1) < 1300 && 0 <= i__1 ? i__1 : 
		s_rnge("files", i__1, "keeper_", (ftnlen)2059)) * 255, file, (
		ftnlen)255, file_len) == 0) {
	    gotit = TRUE_;
	} else {
	    --i__;
	}
    }

/*     If we didn't locate the requested file, there is nothing to do. */

    if (! gotit) {
	chkout_("UNLOAD", (ftnlen)6);
	return 0;
    }

/*     We need to know what type of file we've got so that we */
/*     can take the correct "unload" action. */

    if (s_cmp(types + (((i__1 = i__ - 1) < 1300 && 0 <= i__1 ? i__1 : s_rnge(
	    "types", i__1, "keeper_", (ftnlen)2079)) << 3), "SPK", (ftnlen)8, 
	    (ftnlen)3) == 0) {
	spkuef_(&handls[(i__1 = i__ - 1) < 1300 && 0 <= i__1 ? i__1 : s_rnge(
		"handls", i__1, "keeper_", (ftnlen)2080)]);
	didspk = TRUE_;
    } else if (s_cmp(types + (((i__1 = i__ - 1) < 1300 && 0 <= i__1 ? i__1 : 
	    s_rnge("types", i__1, "keeper_", (ftnlen)2082)) << 3), "CK", (
	    ftnlen)8, (ftnlen)2) == 0) {
	ckupf_(&handls[(i__1 = i__ - 1) < 1300 && 0 <= i__1 ? i__1 : s_rnge(
		"handls", i__1, "keeper_", (ftnlen)2083)]);
	didck = TRUE_;
    } else if (s_cmp(types + (((i__1 = i__ - 1) < 1300 && 0 <= i__1 ? i__1 : 
	    s_rnge("types", i__1, "keeper_", (ftnlen)2085)) << 3), "PCK", (
	    ftnlen)8, (ftnlen)3) == 0) {
	pckuof_(&handls[(i__1 = i__ - 1) < 1300 && 0 <= i__1 ? i__1 : s_rnge(
		"handls", i__1, "keeper_", (ftnlen)2086)]);
	didpck = TRUE_;
    } else if (s_cmp(types + (((i__1 = i__ - 1) < 1300 && 0 <= i__1 ? i__1 : 
	    s_rnge("types", i__1, "keeper_", (ftnlen)2088)) << 3), "EK", (
	    ftnlen)8, (ftnlen)2) == 0) {
	ekuef_(&handls[(i__1 = i__ - 1) < 1300 && 0 <= i__1 ? i__1 : s_rnge(
		"handls", i__1, "keeper_", (ftnlen)2089)]);
	didek = TRUE_;
    } else if (s_cmp(types + (((i__1 = i__ - 1) < 1300 && 0 <= i__1 ? i__1 : 
	    s_rnge("types", i__1, "keeper_", (ftnlen)2091)) << 3), "TEXT", (
	    ftnlen)8, (ftnlen)4) == 0) {
	clpool_();
	didtxt = TRUE_;
    } else if (s_cmp(types + (((i__1 = i__ - 1) < 1300 && 0 <= i__1 ? i__1 : 
	    s_rnge("types", i__1, "keeper_", (ftnlen)2094)) << 3), "META", (
	    ftnlen)8, (ftnlen)4) == 0) {

/*        This is a special case, we need to undo the effect of loading */
/*        the meta-kernel.  This means we need to unload all kernels */
/*        that were loaded using this meta-kernel. */

	didtxt = TRUE_;
	src = i__;
	i__1 = src + 1;
	for (j = loaded; j >= i__1; --j) {
	    if (srces[(i__2 = j - 1) < 1300 && 0 <= i__2 ? i__2 : s_rnge(
		    "srces", i__2, "keeper_", (ftnlen)2105)] == src) {

/*              This file was loaded by the meta-kernel of interest. */
/*              We only need to unload the binary kernels as we */
/*              will get rid of all text kernels by clearing the */
/*              kernel pool. */

		if (s_cmp(types + (((i__2 = j - 1) < 1300 && 0 <= i__2 ? i__2 
			: s_rnge("types", i__2, "keeper_", (ftnlen)2112)) << 
			3), "SPK", (ftnlen)8, (ftnlen)3) == 0) {
		    spkuef_(&handls[(i__2 = j - 1) < 1300 && 0 <= i__2 ? i__2 
			    : s_rnge("handls", i__2, "keeper_", (ftnlen)2113)]
			    );
		    didspk = TRUE_;
		} else if (s_cmp(types + (((i__2 = j - 1) < 1300 && 0 <= i__2 
			? i__2 : s_rnge("types", i__2, "keeper_", (ftnlen)
			2115)) << 3), "CK", (ftnlen)8, (ftnlen)2) == 0) {
		    ckupf_(&handls[(i__2 = j - 1) < 1300 && 0 <= i__2 ? i__2 :
			     s_rnge("handls", i__2, "keeper_", (ftnlen)2116)])
			    ;
		    didck = TRUE_;
		} else if (s_cmp(types + (((i__2 = j - 1) < 1300 && 0 <= i__2 
			? i__2 : s_rnge("types", i__2, "keeper_", (ftnlen)
			2118)) << 3), "PCK", (ftnlen)8, (ftnlen)3) == 0) {
		    pckuof_(&handls[(i__2 = j - 1) < 1300 && 0 <= i__2 ? i__2 
			    : s_rnge("handls", i__2, "keeper_", (ftnlen)2119)]
			    );
		    didpck = TRUE_;
		} else if (s_cmp(types + (((i__2 = j - 1) < 1300 && 0 <= i__2 
			? i__2 : s_rnge("types", i__2, "keeper_", (ftnlen)
			2121)) << 3), "EK", (ftnlen)8, (ftnlen)2) == 0) {
		    ekuef_(&handls[(i__2 = j - 1) < 1300 && 0 <= i__2 ? i__2 :
			     s_rnge("handls", i__2, "keeper_", (ftnlen)2122)])
			    ;
		    didek = TRUE_;
		}
		n1 = loaded;
		n2 = loaded;
		n3 = loaded;
		remlac_(&c__1, &j, files, &n1, (ftnlen)255);
		remlac_(&c__1, &j, types, &n2, (ftnlen)8);
		remlai_(&c__1, &j, srces, &n3);
		remlai_(&c__1, &j, handls, &loaded);
	    }
	}

/*        Now clear the kernel pool. */

	clpool_();
    }

/*     Remove the I'th kernel from our local database. */

    n1 = loaded;
    n2 = loaded;
    n3 = loaded;
    remlac_(&c__1, &i__, files, &n1, (ftnlen)255);
    remlac_(&c__1, &i__, types, &n2, (ftnlen)8);
    remlai_(&c__1, &i__, srces, &n3);
    remlai_(&c__1, &i__, handls, &loaded);

/*     If we unloaded a text kernel, we now need to reload all */
/*     of the text kernels that were not unloaded. */

    if (didtxt) {
	i__1 = loaded;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    if (s_cmp(types + (((i__2 = i__ - 1) < 1300 && 0 <= i__2 ? i__2 : 
		    s_rnge("types", i__2, "keeper_", (ftnlen)2161)) << 3), 
		    "TEXT", (ftnlen)8, (ftnlen)4) == 0 || s_cmp(types + (((
		    i__3 = i__ - 1) < 1300 && 0 <= i__3 ? i__3 : s_rnge("typ"
		    "es", i__3, "keeper_", (ftnlen)2161)) << 3), "META", (
		    ftnlen)8, (ftnlen)4) == 0) {
		ldpool_(files + ((i__2 = i__ - 1) < 1300 && 0 <= i__2 ? i__2 :
			 s_rnge("files", i__2, "keeper_", (ftnlen)2164)) * 
			255, (ftnlen)255);
		if (s_cmp(types + (((i__2 = i__ - 1) < 1300 && 0 <= i__2 ? 
			i__2 : s_rnge("types", i__2, "keeper_", (ftnlen)2166))
			 << 3), "META", (ftnlen)8, (ftnlen)4) == 0) {

/*                 Clean up any debris that may have been left lying */
/*                 around because we reloaded a meta-text kernel. */

		    for (j = 1; j <= 3; ++j) {
			dvpool_(known + (((i__2 = j - 1) < 3 && 0 <= i__2 ? 
				i__2 : s_rnge("known", i__2, "keeper_", (
				ftnlen)2172)) << 5), (ftnlen)32);
		    }
		    cvpool_("FURNSH", &update, (ftnlen)6);
		}
	    }
	}
    }

/*     If any SPK files were unloaded, we need to reload everything */
/*     to establish the right priority sequence for segments. */

    if (didspk) {
	i__1 = loaded;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    if (s_cmp(types + (((i__2 = i__ - 1) < 1300 && 0 <= i__2 ? i__2 : 
		    s_rnge("types", i__2, "keeper_", (ftnlen)2192)) << 3), 
		    "SPK", (ftnlen)8, (ftnlen)3) == 0) {
		spklef_(files + ((i__2 = i__ - 1) < 1300 && 0 <= i__2 ? i__2 :
			 s_rnge("files", i__2, "keeper_", (ftnlen)2193)) * 
			255, &handls[(i__3 = i__ - 1) < 1300 && 0 <= i__3 ? 
			i__3 : s_rnge("handls", i__3, "keeper_", (ftnlen)2193)
			], (ftnlen)255);
	    }
	}
    }

/*     If any CK files were unloaded, we need to reload all of the */
/*     C-kernels to make sure that we have the correct priorities */
/*     for the remaining C-kernels. */

    if (didck) {
	i__1 = loaded;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    if (s_cmp(types + (((i__2 = i__ - 1) < 1300 && 0 <= i__2 ? i__2 : 
		    s_rnge("types", i__2, "keeper_", (ftnlen)2206)) << 3), 
		    "CK", (ftnlen)8, (ftnlen)2) == 0) {
		cklpf_(files + ((i__2 = i__ - 1) < 1300 && 0 <= i__2 ? i__2 : 
			s_rnge("files", i__2, "keeper_", (ftnlen)2207)) * 255,
			 &handls[(i__3 = i__ - 1) < 1300 && 0 <= i__3 ? i__3 :
			 s_rnge("handls", i__3, "keeper_", (ftnlen)2207)], (
			ftnlen)255);
	    }
	}
    }

/*     If any binary PCK files were unloaded, we need to reload any */
/*     remaining ones to re-establish the correct priorities for */
/*     kernels. */

    if (didpck) {
	i__1 = loaded;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    if (s_cmp(types + (((i__2 = i__ - 1) < 1300 && 0 <= i__2 ? i__2 : 
		    s_rnge("types", i__2, "keeper_", (ftnlen)2221)) << 3), 
		    "PCK", (ftnlen)8, (ftnlen)3) == 0) {
		pcklof_(files + ((i__2 = i__ - 1) < 1300 && 0 <= i__2 ? i__2 :
			 s_rnge("files", i__2, "keeper_", (ftnlen)2222)) * 
			255, &handls[(i__3 = i__ - 1) < 1300 && 0 <= i__3 ? 
			i__3 : s_rnge("handls", i__3, "keeper_", (ftnlen)2222)
			], (ftnlen)255);
	    }
	}
    }

/*     Finally, if any E-kernels were unloaded, we reload the remaining */
/*     kernels to make sure the state is restored to the correct set */
/*     of loaded kernels. */

    if (didek) {
	i__1 = loaded;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    if (s_cmp(types + (((i__2 = i__ - 1) < 1300 && 0 <= i__2 ? i__2 : 
		    s_rnge("types", i__2, "keeper_", (ftnlen)2235)) << 3), 
		    "EK", (ftnlen)8, (ftnlen)2) == 0) {
		eklef_(files + ((i__2 = i__ - 1) < 1300 && 0 <= i__2 ? i__2 : 
			s_rnge("files", i__2, "keeper_", (ftnlen)2236)) * 255,
			 &handls[(i__3 = i__ - 1) < 1300 && 0 <= i__3 ? i__3 :
			 s_rnge("handls", i__3, "keeper_", (ftnlen)2236)], (
			ftnlen)255);
	    }
	}
    }
    chkout_("UNLOAD", (ftnlen)6);
    return 0;
} /* keeper_ */

/* Subroutine */ int keeper_(integer *which, char *kind, char *file, integer *
	count, char *filtyp, integer *handle, char *source, logical *found, 
	ftnlen kind_len, ftnlen file_len, ftnlen filtyp_len, ftnlen 
	source_len)
{
    return keeper_0_(0, which, kind, file, count, filtyp, handle, source, 
	    found, kind_len, file_len, filtyp_len, source_len);
    }

/* Subroutine */ int furnsh_(char *file, ftnlen file_len)
{
    return keeper_0_(1, (integer *)0, (char *)0, file, (integer *)0, (char *)
	    0, (integer *)0, (char *)0, (logical *)0, (ftnint)0, file_len, (
	    ftnint)0, (ftnint)0);
    }

/* Subroutine */ int ktotal_(char *kind, integer *count, ftnlen kind_len)
{
    return keeper_0_(2, (integer *)0, kind, (char *)0, count, (char *)0, (
	    integer *)0, (char *)0, (logical *)0, kind_len, (ftnint)0, (
	    ftnint)0, (ftnint)0);
    }

/* Subroutine */ int kdata_(integer *which, char *kind, char *file, char *
	filtyp, char *source, integer *handle, logical *found, ftnlen 
	kind_len, ftnlen file_len, ftnlen filtyp_len, ftnlen source_len)
{
    return keeper_0_(3, which, kind, file, (integer *)0, filtyp, handle, 
	    source, found, kind_len, file_len, filtyp_len, source_len);
    }

/* Subroutine */ int kinfo_(char *file, char *filtyp, char *source, integer *
	handle, logical *found, ftnlen file_len, ftnlen filtyp_len, ftnlen 
	source_len)
{
    return keeper_0_(4, (integer *)0, (char *)0, file, (integer *)0, filtyp, 
	    handle, source, found, (ftnint)0, file_len, filtyp_len, 
	    source_len);
    }

/* Subroutine */ int unload_(char *file, ftnlen file_len)
{
    return keeper_0_(5, (integer *)0, (char *)0, file, (integer *)0, (char *)
	    0, (integer *)0, (char *)0, (logical *)0, (ftnint)0, file_len, (
	    ftnint)0, (ftnint)0);
    }

