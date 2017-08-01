/* pool.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__5003 = 5003;
static integer c__40000 = 40000;
static integer c__4000 = 4000;
static integer c__1000 = 1000;
static integer c__2000 = 2000;
static integer c__1 = 1;

/* $Procedure      POOL ( Maintain a pool of kernel variables ) */
/* Subroutine */ int pool_0_(int n__, char *kernel, integer *unit, char *
	name__, char *names, integer *nnames, char *agent, integer *n, 
	doublereal *values, logical *found, logical *update, integer *start, 
	integer *room, char *cvals, integer *ivals, char *type__, ftnlen 
	kernel_len, ftnlen name_len, ftnlen names_len, ftnlen agent_len, 
	ftnlen cvals_len, ftnlen type_len)
{
    /* Initialized data */

    static logical first = TRUE_;

    /* System generated locals */
    integer i__1, i__2;
    cilist ci__1;

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer);
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_cmp(char *, char *, ftnlen, ftnlen), s_wsfe(cilist *), do_fio(
	    integer *, char *, ftnlen), e_wsfe(void), i_dnnt(doublereal *);

    /* Local variables */
    static integer head, code, free, node;
    static char line[132];
    static integer tail, hits, i__, j, k;
    extern integer cardc_(char *, ftnlen);
    static integer r__, begin;
    extern logical elemc_(char *, char *, ftnlen, ftnlen);
    static integer dnode, avail;
    extern /* Subroutine */ int chkin_(char *, ftnlen);
    static integer nnode;
    extern /* Subroutine */ int errch_(char *, char *, ftnlen, ftnlen), 
	    lnkan_(integer *, integer *);
    static doublereal small;
    extern /* Subroutine */ int errdp_(char *, doublereal *, ftnlen), copyc_(
	    char *, char *, ftnlen, ftnlen), ioerr_(char *, char *, integer *,
	     ftnlen, ftnlen);
    static logical gotit;
    extern integer rtrim_(char *, ftnlen);
    extern logical eqstr_(char *, char *, ftnlen, ftnlen);
    extern /* Subroutine */ int zzcln_(integer *, integer *, integer *, 
	    integer *, integer *, integer *, integer *);
    extern logical failed_(void);
    static integer datahd;
    static char begdat[10];
    static logical dp;
    static integer chnode;
    extern /* Subroutine */ int validc_(integer *, integer *, char *, ftnlen);
    extern integer bsrchc_(char *, integer *, char *, ftnlen, ftnlen);
    extern logical matchi_(char *, char *, char *, char *, ftnlen, ftnlen, 
	    ftnlen, ftnlen);
    static integer nameat, nfetch, dpnode;
    extern /* Subroutine */ int lnkila_(integer *, integer *, integer *);
    static char active[32*1006];
    static integer margin;
    static char cvalue[132];
    extern integer lnknfn_(integer *);
    static char pnames[32*5003];
    static integer datlst[5003];
    static char begtxt[10];
    extern integer intmax_(void), intmin_(void);
    static integer namlst[5003], chpool[8012]	/* was [2][4006] */, nmpool[
	    10018]	/* was [2][5009] */, dppool[80012]	/* was [2][
	    40006] */;
    extern integer zzhash_(char *, ftnlen);
    static char chvals[80*4000];
    static doublereal dpvals[40000];
    static char watval[32*2006], agents[32*1006], notify[32*1006], finish[2];
    extern logical return_(void);
    static char varnam[32];
    static integer watptr[5009];
    static doublereal dvalue;
    static integer iostat;
    static char watsym[32*5009];
    static integer iquote, linnum, lookat, tofree;
    static logical noagnt, succes, vector;
    extern /* Subroutine */ int setmsg_(char *, ftnlen), sigerr_(char *, 
	    ftnlen), chkout_(char *, ftnlen), zzpini_(logical *, integer *, 
	    integer *, integer *, char *, char *, integer *, integer *, 
	    integer *, integer *, integer *, integer *, integer *, char *, 
	    integer *, char *, char *, char *, char *, ftnlen, ftnlen, ftnlen,
	     ftnlen, ftnlen, ftnlen, ftnlen), lnkini_(integer *, integer *), 
	    syfetc_(integer *, char *, integer *, char *, char *, logical *, 
	    ftnlen, ftnlen, ftnlen), sygetc_(char *, char *, integer *, char *
	    , integer *, char *, logical *, ftnlen, ftnlen, ftnlen, ftnlen), 
	    unionc_(char *, char *, char *, ftnlen, ftnlen, ftnlen), rdknew_(
	    char *, ftnlen), zzrvar_(integer *, integer *, char *, integer *, 
	    integer *, doublereal *, integer *, char *, char *, logical *, 
	    ftnlen, ftnlen, ftnlen), cltext_(char *, ftnlen), sypshc_(char *, 
	    char *, char *, integer *, char *, ftnlen, ftnlen, ftnlen, ftnlen)
	    , syordc_(char *, char *, integer *, char *, ftnlen, ftnlen, 
	    ftnlen), errint_(char *, integer *, ftnlen), insrtc_(char *, char 
	    *, ftnlen, ftnlen);
    static doublereal big;
    extern /* Subroutine */ int removc_(char *, char *, ftnlen, ftnlen);
    static logical eof, chr;
    extern /* Subroutine */ int zzgpnm_(integer *, integer *, char *, integer 
	    *, integer *, doublereal *, integer *, char *, char *, logical *, 
	    integer *, integer *, ftnlen, ftnlen, ftnlen), lnkfsl_(integer *, 
	    integer *, integer *), zzrvbf_(char *, integer *, integer *, 
	    integer *, integer *, char *, integer *, integer *, doublereal *, 
	    integer *, char *, char *, logical *, ftnlen, ftnlen, ftnlen, 
	    ftnlen);
    static logical got;

/* $ Abstract */

/*     Maintain a pool of variables read from SPICE ASCII kernel files. */

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

/*     KERNEL */

/* $ Keywords */

/*     CONSTANTS */
/*     FILES */

/* $ Declarations */
/* $ Brief_I/O */

/*     Variable  I/O  Entry */
/*     --------  ---  -------------------------------------------------- */
/*     AGENT      I   CVPOOL, SWPOOL */
/*     KERNEL     I   LDPOOL */
/*     NAME       I   RTPOOL, EXPOOL, GIPOOL, GDPOOL, GCPOOL, PCPOOL, */
/*                    PDPOOL, PIPOOL, DTPOOL, SZPOOL, DVPOOL, GNPOOL */
/*     NAMES      I   SWPOOL */
/*     NNAMES     I   SWPOOL */
/*     START      I   GIPOOL, GDPOOL, GCPOOL, GNPOOL */
/*     ROOM       I   GIPOOL, GDPOOL, GCPOOL. GNPOOL */
/*     UNIT       I   WRPOOL */
/*     CVALS     I/O  GCPOOL, PCPOOL, LMPOOL, GNPOOL */
/*     IVALS     I/O  GIPOOL, PIPOOL */
/*     N         I/O  RTPOOL, GIPOOL, GCPOOL, GDPOOL, DTPOOL, PCPOOL, */
/*                    PDPOOL, PIPOOL, LMPOOL, SZPOOL, GNPOOL */
/*     VALUES    I/O  RTPOOL  GDPOOL, PDPOOL */
/*     FOUND      O   RTPOOL, EXPOOL, GIPOOL, GCPOOL, GDPOOL, DTPOOL, */
/*                    SZPOOL, GNPOOL */
/*     TYPE       O   DTPOOL */
/*     UPDATE     O   CVPOOL */
/*     MAXVAR     P   (All) */
/*     MAXLEN     P   (All) */
/*     MXNOTE     P   (All) */
/*     MAXVAL     P   (All) */
/*     MAXAGT     P   (All) */
/*     BEGDAT     P   WRPOOL */
/*     BEGTXT     P   WRPOOL */

/* $ Detailed_Input */

/*     See the ENTRY points for a discussion of their arguments. */

/* $ Detailed_Output */

/*     See the ENTRY points for a discussion of their arguments. */

/* $ Parameters */

/*     MAXVAR      is the maximum number of variables that the */
/*                 kernel pool may contain at any one time. */
/*                 MAXVAR should be a prime number. */

/*                 Here's a list of primes that should make */
/*                 it easy to upgrade MAXVAR when/if the need arises. */

/*                     103 */
/*                     199 */
/*                     307 */
/*                     401 */
/*                     503 */
/*                     601 */
/*                     701 */
/*                     751 */
/*                     811 */
/*                     911 */
/*                    1013 */
/*                    1213 */
/*                    1303 */
/*                    1511 */
/*                    1811 */
/*                    1913 */
/*                    2003 */
/*                    2203 */
/*                    2503 */
/*                    2803 */
/*                    3203 */
/*                    3607 */
/*                    4001 */
/*                    4507 */
/*                    4801 */
/*                    5003 Current Value */
/*                    6007 */
/*                    6521 */
/*                    7001 */
/*                    7507 */
/*                    8009 */
/*                    8501 */
/*                    9001 */
/*                    9511 */
/*                   10007 */
/*                   10501 */
/*                   11003 */
/*                   11503 */


/*     MAXLEN      is the maximum length of the variable names */
/*                 that can be stored in the kernel pool. */

/*     MAXVAL      is the maximum number of distinct values that */
/*                 may belong to the variables in the kernel pool. */
/*                 Each variable must have at least one value, and */
/*                 may have any number, so long as the total number */
/*                 does not exceed MAXVAL. MAXVAL must be at least */
/*                 as large as MAXVAR. */

/*     MXNOTE      is the maximum number of distinct variable-agents */
/*                 pairs that can be maintained by the kernel pool. */
/*                 (A variable is "paired" with an agent, if that agent */
/*                 is to be notified whenever the variable is updated.) */

/*     MAXAGT      is the maximum number of agents that can be kept */
/*                 on the distribution list for notification of updates */
/*                 to kernel variables. */

/*     MAXCHR      is the maximum number of characters that can be */
/*                 stored in a component of a string valued kernel */
/*                 variable. */

/*     MAXLIN      is the maximum number of character strings that */
/*                 can be stored as data for kernel pool variables. */

/* $ Files */

/*     See the ENTRY points for a discussion of their arguments. */

/* $ Exceptions */

/*     1) If POOL is called directly, the error SPICE(BOGUSENTRY) is */
/*        signaled. */

/* $ Particulars */

/*     POOL should never be called directly, but should instead be */
/*     accessed only through its entry points. */

/*     The purpose of this routine is to maintain a pool of variables */
/*     read from ASCII kernel files. The following entry points may be */
/*     used to access the pool. */

/*           CLPOOL         Clears the pool. */

/*           LDPOOL         Loads the variables from a kernel file into */
/*                          the pool. */

/*           RTPOOL         Returns the value of a variable from */
/*                          the pool. (Obsolete use GDPOOL) */

/*           EXPOOL         Confirms the existence of a numeric */
/*                          variable in the pool. */

/*           WRPOOL         Writes the contents of the pool to an */
/*                          ASCII kernel file. */

/*           SWPOOL         Sets up a "watcher" on a variable so that */
/*                          various "agents" can be notified when a */
/*                          variable has been updated. */

/*           CVPOOL         Indicates whether or not an agent's */
/*                          variable has been updated since the last */
/*                          time an agent checked with the pool. */

/*           GCPOOL         Returns the value of a string valued */
/*                          variable in the pool. */

/*           GDPOOL         Returns the d.p. value of a numeric valued */
/*                          variable in the pool. */

/*           GIPOOL         Returns the integer value of a numeric valued */
/*                          variable in the pool. */

/*           DTPOOL         Returns the attributes of a variable in the */
/*                          pool. */

/*           PCPOOL         Allows the insertion of a character variable */
/*                          directly into the kernel pool without */
/*                          supplying a text kernel. */

/*           PDPOOL         Allows the insertion of a double precision */
/*                          variable directly into the kernel pool */
/*                          without supplying a text kernel. */

/*           PIPOOL         Allows the insertion of an integer variable */
/*                          directly into the kernel pool without */
/*                          supplying a text kernel. */

/*           LMPOOL         Similar to LDPOOL, but the text kernel is */
/*                          stored in an array of strings instead of an */
/*                          external file. */

/*           SZPOOL         allows run time retrieval of kernel pool */
/*                          memory parameters. */

/*           DVPOOL         allows deletion of a specific variable from */
/*                          the kernel pool.  (CLPOOL deletes all */
/*                          variables from the kernel pool.) */

/*           GNPOOL         assists in determining which variables are */
/*                          defined in the kernel pool via variable name */
/*                          template matching. */

/*     Nominally, the kernel pool contains up to 2003 separate variables */
/*     and up to 6000 numeric values, 400 string values. The names of the */
/*     individual variables may contain up to 32 characters. All of these */
/*     figures may be increased or decreased as necessary. */

/* $ Examples */

/*     The following code fragment demonstrates how the data from */
/*     several kernel files can be loaded into a kernel pool. After the */
/*     pool is loaded, the values in the pool are written to a kernel */
/*     file. */

/*     C */
/*     C     Store in an array the names of the kernel files whose */
/*     C     values will be loaded into the kernel pool. */
/*     C */
/*           KERNEL (1) = 'AXES.KER' */
/*           KERNEL (2) = 'GM.KER' */
/*           KERNEL (3) = 'LEAP_SECONDS.KER' */

/*     C */
/*     C     Clear the kernel pool. (This is optional.) */
/*     C */
/*           CALL CLPOOL */

/*     C */
/*     C     Load the variables from the three kernel files into the */
/*     C     the kernel pool. */
/*     C */
/*           DO I = 1, 3 */
/*             CALL LDPOOL ( KERNEL (I) ) */
/*           END DO */

/*     C */
/*     C     We can examine the values associated with any d.p. variable */
/*     C     in the kernel pool using GDPOOL. */
/*     C */
/*           CALL GDPOOL ( VARIABLE, START, ROOM, NVALS, VALUES, FOUND ) */

/*     C */
/*     C     Get a free logical unit and open the file 'NEWKERNEL.KER'. */
/*     C */
/*           CALL GETLUN ( UNIT ) */

/*           OPEN ( FILE            = 'NEWKERNEL.KER', */
/*          .       UNIT            = UNIT, */
/*          .       STATUS          = 'NEW', */
/*          .       IOSTAT          = IOSTAT, */
/*          .       CARRIAGECONTROL = 'LIST'  ) */

/*     C */
/*     C     Write the values in the kernel pool to the file. */
/*     C */
/*           CALL WRPOOL ( UNIT ) */


/* $ Restrictions */

/*     None. */

/* $ Literature_References */

/*     None. */

/* $ Author_and_Institution */

/*     N.J. Bachman    (JPL) */
/*     H.A. Neilan     (JPL) */
/*     B.V. Semenov    (JPL) */
/*     W.L. Taber      (JPL) */
/*     F.S. Turner     (JPL) */
/*     R.E. Thurman    (JPL) */
/*     I.M. Underwood  (JPL) */

/* $ Version */

/* -    SPICELIB Version 8.3.0, 22-DEC-2004 (NJB) */

/*        Fixed bug in DVPOOL.  Made corrections to comments in */
/*        other entry points.  The updated routines are DTPOOL, */
/*        DVPOOL, EXPOOL, GCPOOL, GDPOOL, GIPOOL, RTPOOL. */

/* -    SPICELIB Version 8.2.0, 24-JAN-2003 (BVS) */

/*        Increased MAXVAL to 40000. */

/* -    SPICELIB Version 8.1.0, 13-MAR-2001 (FST) (NJB) */

/*        Increased kernel pool size and agent parameters. MAXVAR is now */
/*        5000, MAXVAL is 10000, MAXLIN is 4000, MXNOTE is 2000, and */
/*        MAXAGT is 1000. */

/*        Modified Fortran output formats used in entry point WRPOOL to */
/*        remove list-directed formatting.  This change was made to */
/*        work around problems with the way f2c translates list- */
/*        directed I/O. */


/* -    SPICELIB Version 8.0.0, 04-JUN-1999 (WLT) */

/*        Added the entry points PCPOOL, PDPOOL and PIPOOL to allow */
/*        direct insertion of data into the kernel pool without having */
/*        to read an external file. */

/*        Added the interface LMPOOL that allows SPICE */
/*        programs to load text kernels directly from memory */
/*        instead of requiring a text file. */

/*        Added the entry point SZPOOL to return kernel pool definition */
/*        parameters. */

/*        Added the entry point DVPOOL to allow the removal of a variable */
/*        from the kernel pool. */

/*        Added the entry point GNPOOL to allow users to determine */
/*        variables that are present in the kernel pool */

/* -    SPICELIB Version 7.0.0, 20-SEP-1995 (WLT) */

/*        The implementation of the kernel pool was completely redone */
/*        to improve performance in loading and fetching data.  In */
/*        addition the pool was upgraded so that variables may be */
/*        either string or numeric valued. */

/*        The entry points GCPOOL, GDPOOL, GIPOOL and DTPOOL were added */
/*        to the routine. */

/*        The entry point RTPOOL should now be regarded as obsolete */
/*        and is maintained soley for backward compatibility with */
/*        existing routines that make use of it. */

/* -    SPICELIB Version 6.0.0, 31-MAR-1992 (WLT) */

/*        The entry points SWPOOL and CVPOOL were added. */

/* -    SPICELIB Version 5.0.0, 22-AUG-1990 (NJB) */

/*        Increased value of parameter MAXVAL to 5000 to accommodate */
/*        storage of SCLK coefficients in the kernel pool. */

/* -    SPICELIB Version 4.0.0, 12-JUN-1990 (IMU) */

/*        All entry points except POOL and CLPOOL now initialize the */
/*        pool if it has not been done yet. */

/* -    SPICELIB Version 3.0.0, 23-OCT-1989 (HAN) */

/*        Added declaration of FAILED. FAILED is checked in the */
/*        DO-loops in LDPOOL and WRPOOL to prevent infinite looping. */

/* -    SPICELIB Version 2.0.0, 18-OCT-1989 (RET) */

/*       A FAILED test was inserted into the control of the DO-loop which */
/*       reads in each kernel variable in LDPOOL. */

/* -    SPICELIB Version 1.2.0, 9-MAR-1989 (HAN) */

/*        Parameters BEGDAT and BEGTXT have been moved into the */
/*        Declarations section. */

/* -    SPICELIB Version 1.1.0, 16-FEB-1989 (IMU) (NJB) */

/*        Parameters MAXVAR, MAXVAL, MAXLEN moved into Declarations. */
/*        (Actually, MAXLEN was implicitly 32 characters, and has only */
/*        now been made an explicit---and changeable---limit.) */

/*        Declaration of unused function FAILED removed. */

/* -    SPICELIB Version 1.0.0, 8-JAN-1989 (IMU) */

/* -& */
/* $ Index_Entries */

/*     MAINTAIN a pool of kernel variables */

/* -& */
/* $ Revisions */

/* -    SPICELIB Version 8.3.0, 22-DEC-2004 (NJB) */

/*        Fixed bug in DVPOOL.  Made corrections to comments in */
/*        other entry points.  The updated routines are DTPOOL, */
/*        DVPOOL, EXPOOL, GCPOOL, GDPOOL, GIPOOL, RTPOOL. */

/* -    SPICELIB Version 8.2.0, 24-JAN-2003 (BVS) */

/*        Increased MAXVAL to 40000. */

/* -    SPICELIB Version 8.1.0, 13-MAR-2001 (FST) (NJB) */

/*        Increased kernel pool size and agent parameters. MAXVAR is now */
/*        5000, MAXVAL is 10000, MAXLIN is 4000, MXNOTE is 2000, and */
/*        MAXAGT is 1000. */

/*        Modified Fortran output formats used in entry point WRPOOL to */
/*        remove list-directed formatting.  This change was made to */
/*        work around problems with the way f2c translates list- */
/*        directed I/O. */

/* -    SPICELIB Version 8.0.0, 04-JUN-1999 (WLT) */

/*        Added the entry points PCPOOL, PDPOOL and PIPOOL to allow */
/*        direct insertion of data into the kernel pool without having */
/*        to read an external file. */

/*        Added the interface LMPOOL that allows SPICE */
/*        programs to load text kernels directly from memory */
/*        instead of requiring a text file. */

/*        Added the entry point SZPOOL to return kernel pool definition */
/*        parameters. */

/* -    SPICELIB Version 7.0.0, 20-SEP-1995 (WLT) */

/*        The implementation of the kernel pool was completely redone */
/*        to improve performance in loading and fetching data.  In */
/*        addition the pool was upgraded so that variables may be */
/*        either string or numeric valued. */

/*        The entry points GCPOOL, GDPOOL, GIPOOL and DTPOOL were added */
/*        to the routine. */

/*        The entry point RTPOOL should now be regarded as obsolete */
/*        and is maintained soley for backward compatibility with */
/*        existing routines that make use of it. */

/*        The basic data structure used to maintain the list of */
/*        variable names and values was replaced with a hash table */
/*        implementation.  Data and names are accessed by means */
/*        of a hash function and linked lists of pointers to exising */
/*        variable names and data values. */

/* -    SPICELIB Version 6.0.0, 31-MAR-1992 (WLT) */

/*        The entry points SWPOOL (set watch on a pool variable) */
/*        and CVPOOL (check variable for update) so that routines */
/*        that buffer data stored in the kernel pool can fetch */
/*        that data only when it is updated. */

/*        Also the control of initializations was modified to be */
/*        consistent with other SPICELIB practices. */

/*        Finally, the revision history was upgraded so that the */
/*        version number increases over time.  This wasn't true */
/*        before. In addition some early revision data that referred to */
/*        pre-SPICELIB modifications were removed. This editing of */
/*        the version numbers makes it unlikely that anyone can track */
/*        down which previous version of this routine they have by */
/*        looking at the version number.  The best way to determine */
/*        the routine you had previously is to compare the dates */
/*        stored in the Version line of the routine. */

/* -    SPICELIB Version 5.0.0, 22-AUG-1990 (NJB) */

/*        Increased value of parameter MAXVAL to 5000 to accommodate */
/*        storage of SCLK coefficients in the kernel pool. */

/*        Also, changed version number in previous `Revisions' entry */
/*        from SPICELIB Version 2.0.0 to SPICELIB Version 2.0.0.  The */
/*        last version entry in the `Version' section had been */
/*        Version 1.0.0, dated later than the entry for `version 2' */
/*        in the revisions section! */

/* -    SPICELIB Version 4.0.0, 12-JUN-1990 (IMU) */

/*        All entry points except POOL and CLPOOL now initialize the */
/*        pool if it has not been done yet. */

/* -    SPICELIB Version 3.0.0, 23-OCT-1989 (HAN) */

/*        Added declaration of FAILED. FAILED is checked in the */
/*        DO-loops in LDPOOL and WRPOOL to prevent infinite looping. */

/* -    SPICELIB Version 2.0.0, 18-OCT-1989 (RET) */

/*       A FAILED test was inserted into the control of the DO-loop which */
/*       reads in each kernel variable. */

/*       Previously, if the error action 'RETURN' had been set by a */
/*       calling program, and the call to RDKNEW by LDPOOL failed, */
/*       then execution would continue through LDPOOL, with SPICELIB */
/*       routines returning upon entry. This meant that the routine */
/*       RDKVAR never got a chance to set the EOF flag, which was the */
/*       only control of the DO-loop. An infinite loop resulted in such */
/*       cases.  The FAILED test resolves that situation. */

/* -    SPICELIB Version 1.2.0, 9-MAR-1989 (HAN) */

/*        Parameters BEGDAT and BEGTXT have been moved into the */
/*        Declarations section. */

/* -    SPICELIB Version 1.1.0, 16-FEB-1989 (IMU) (NJB) */

/*        Parameters MAXVAR, MAXVAL, MAXLEN moved into Declarations. */
/*        (Actually, MAXLEN was implicitly 32 characters, and has only */
/*        now been made an explicit---and changeable---limit.) */

/*        Declaration of unused function FAILED removed. */

/* -    SPICELIB Version 1.0.0, 8-JAN-1989 (IMU) */

/* -& */

/*     SPICELIB functions */


/*     Private SPICELIB functions. */


/*     Local Parameters */


/*     The next two variables are for use in traversing linked lists. */


/*     Local variables */


/*     Because some environments (such as the SUN) are too stupid to */
/*     treat the backslash character correctly we have to go through */
/*     some girations to put it into a variable in a "portable" way. */
/*     This is the reason for the following block of declarations. */
/*     Admittedly this is bizarre, but it works. */


/*     The following is the hash table used for holding kernel pool */
/*     variables.  Here's the basic structure: */

/*     The function ZZHASH computes the address of the head of a linked */
/*     list that contains the collisions for the range of ZZHASH. */

/*     The head node of the collision lists is stored in NAMLST. */

/*     If NAMLST has a value zero then */

/*        there is no name corresponding to that value of the */
/*        hash function. */

/*     If NAMLST is non-zero then */

/*        it is the head node of the list of names that have been */
/*        stored so far. */

/*        The list of addresses of names is stored in NMPOOL. */
/*        The names that have been stored so far are in PNAMES. */

/*     The data associated with  PNAMES is pointed to by DATLST */
/*     and CHPOOL or DPPOOL.  If a name of interest is stored in */
/*     PNAMES(I) then the DATLST(I) points to the first data node */
/*     associated with the name. */

/*     If DATLST(I) is less than zero then */

/*        its opposite is the address of the first node of */
/*        character data associated with PNAMES(I). */

/*     If DATLST(I) is positive then */

/*        it points to the address of the first node of numeric */
/*        data associated with PNAMES(I). */

/*     If DATLST(I) is zero */

/*        there is no data associated with PNAMES(I). */


/*     The arrays DPPOOL and CHPOOL are linked list pools that */
/*     give the address lists of values associated with a name. */

/*     The actual data is stored in DPVALS and CHVALS. */

/*     Here's a picture of how this all works. */


/*                                             Linked list Pool */
/*                                             of HASH collisions */
/*                       NAMLST                  NMPOOL         PNAME */
/*                     +------------+          +---------+    +--------+ */
/*                     |            |          |         |    |        | */
/*                     +------------+ if not 0 +---------+    +--------+ */
/*  ZZHASH( NAME ) --->|  Head Node | ---.     |         |    |        | */
/*                     +------------+    |     +---------+    +--------+ */
/*                                       |     |         |    |        | */
/*                                       |     +---------+    +--------+ */
/*                                       `-->  |Head of  |    |Name    | */
/*                                             |collision|    |corresp.| */
/*                                             |list for | -. |to head | */
/*                                             | NAME    |  | |of list | */
/*                                             +---------+  | +--------+ */
/*                                             |         |  | |        | */
/*                                             +---------+  | +--------+ */
/*                                             |         |  | |        | */
/*                                             +---------+  | +--------+ */
/*                                             |Next Node|<-' |NextName| */
/*                                             +---------+etc.+--------+ */
/*                                                  .              . */
/*                                                  .              . */
/*                                                  .              . */
/*                                             +---------+    +--------+ */
/*                                             |         |    |        | */
/*                                             +---------+    +--------+ */




/*      Linked       Variable    Heads of */
/*      List Pool     Names      Data lists */
/*       NMPOOL       PNAME       DATLST */
/*     +--------+   +--------+   +---------+          Head of linked list */
/*     |        |   |        |   |         |     .--> in DPPOOL linked */
/*     +--------+   +--------+   +---------+    |     list pool */
/*     |        |   |        |   |         |    | */
/*     +--------+   +--------+   +---------+    | Positive Value */
/*     |        |<->|        |<->|         |---< */
/*     +--------+   +--------+   +---------+    | */
/*     |        |   |        |   |         |    | Negative Value */
/*     +--------+   +--------+   +---------+    | */
/*     |        |   |        |   |         |    `--> Opposite of head */
/*     +--------+   +--------+   +---------+          of linked list */
/*     |        |   |        |   |         |          in CHPOOL linked */
/*     +--------+   +--------+   +---------+          list pool. */





/*      Linked                Values */
/*      List Pool             of data */
/*       DPPOOL (CHPOOL)      DPVALS (CHVALS) */
/*     +------------+         +------------+ */
/*     |            |         |            | */
/*     +------------+         +------------+ */
/*     |            |         |            | */
/*     +------------+         +------------+ */
/*     | HEAD       |--. <--> | head value | */
/*     +------------+  |      +------------+ */
/*     |            |  |      |            | */
/*     +------------+  |      +------------+ */
/*     |            |  |      |            | */
/*     +------------+  |      +------------+ */
/*     | Node 2     |<-' <--> | 2nd value  | */
/*     +------------+ etc.    +------------+ */
/*     |            |         |            | */
/*     +------------+         +------------+ */
/*     |            |         |            | */
/*     +------------+         +------------+ */
/*     |            |         |            | */
/*     +------------+         +------------+ */
/*     |            |         |            | */
/*     +------------+         +------------+ */
/*     |            |         |            | */
/*     +------------+         +------------+ */
/*     |            |         |            | */
/*     +------------+         +------------+ */



/*     The WAT... variables make up the symbol table that contains */
/*     variables (WATSYM) and their associated agents (WATVAL). */


/*     Agents contains the list of agents that need to be notified */
/*     about updates to their variables.  NOTIFY and ACTIVE are both */
/*     temporary sets. */


/*     First is our initialization flag. */


/*     The remaining local variables... */


/*     Save EVERYTHING. */


/*     Initial values */

    /* Parameter adjustments */
    if (names) {
	}
    if (values) {
	}
    if (cvals) {
	}
    if (ivals) {
	}

    /* Function Body */
    switch(n__) {
	case 1: goto L_clpool;
	case 2: goto L_ldpool;
	case 3: goto L_rtpool;
	case 4: goto L_expool;
	case 5: goto L_wrpool;
	case 6: goto L_swpool;
	case 7: goto L_cvpool;
	case 8: goto L_gcpool;
	case 9: goto L_gdpool;
	case 10: goto L_gipool;
	case 11: goto L_dtpool;
	case 12: goto L_pcpool;
	case 13: goto L_pdpool;
	case 14: goto L_pipool;
	case 15: goto L_lmpool;
	case 16: goto L_szpool;
	case 17: goto L_dvpool;
	case 18: goto L_gnpool;
	}


/*     Set up the definition of our in-line functions. */


/*     Standard SPICE error handling. */

    if (return_()) {
	return 0;
    } else {
	chkin_("POOL", (ftnlen)4);
    }

/*     This routine should never be called. If this routine is called, */
/*     an error is signaled. */

    setmsg_("POOL: You have called an entry which performs performs no run-t"
	    "ime function. This may indicate a bug. Please check the document"
	    "ation for the subroutine POOL.", (ftnlen)157);
    sigerr_("SPICE(BOGUSENTRY)", (ftnlen)17);
    chkout_("POOL", (ftnlen)4);
    return 0;
/* $Procedure CLPOOL ( Clear the pool of kernel variables ) */

L_clpool:
/* $ Abstract */

/*     Remove all variables from the kernel pool. */

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

/*     KERNEL */

/* $ Keywords */

/*     CONSTANTS */
/*     FILES */

/* $ Declarations */

/*     None. */

/* $ Brief_I/O */

/*     None. */

/* $ Detailed_Input */

/*     None. */

/* $ Detailed_Output */

/*     None. */

/* $ Parameters */

/*     None. */

/* $ Exceptions */

/*     1) All known agents (those established through SWPOOL) will */
/*        be "notified" that their watched variables have been updated */
/*        whenever CLPOOL is called. */

/* $ Files */

/*     None. */

/* $ Particulars */

/*     CLPOOL clears the pool of kernel variables maintained by */
/*     the subroutine POOL. All the variables in the pool are deleted. */
/*     However, all watcher information is retained. */

/*     Each watched variable will be regarded as having been updated. */
/*     Any agent associated with that variable will have a notice */
/*     posted for it indicating that it's watched variable has been */
/*     updated. */

/* $ Examples */


/*     The following code fragment demonstrates how the data from */
/*     several kernel files can be loaded into a kernel pool. After the */
/*     pool is loaded, the values in the pool are written to a kernel */
/*     file. */


/*     C */
/*     C     Store in an array the names of the kernel files whose */
/*     C     values will be loaded into the kernel pool. */
/*     C */
/*           KERNEL (1) = 'AXES.KER' */
/*           KERNEL (2) = 'GM.KER' */
/*           KERNEL (3) = 'LEAP_SECONDS.KER' */

/*     C */
/*     C     Clear the kernel pool. (This is optional.) */
/*     C */
/*           CALL CLPOOL */

/*     C */
/*     C     Load the variables from the three kernel files into the */
/*     C     the kernel pool. */
/*     C */
/*           DO I = 1, 3 */
/*             CALL LDPOOL ( KERNEL (I) ) */
/*           END DO */

/*     C */
/*     C     We can examine the values associated with any d.p. variable */
/*     C     in the kernel pool using GDPOOL. */
/*     C */
/*           CALL GDPOOL ( VARIABLE, START, ROOM, NVALS, VALUES, FOUND ) */

/*     C */
/*     C     Get a free logical unit and open the file 'NEWKERNEL.KER'. */
/*     C */
/*           CALL GETLUN ( UNIT ) */

/*           OPEN ( FILE            = 'NEWKERNEL.KER', */
/*          .       UNIT            = UNIT, */
/*          .       STATUS          = 'NEW', */
/*          .       IOSTAT          = IOSTAT, */
/*          .       CARRIAGECONTROL = 'LIST'  ) */


/*     C */
/*     C     Write the values in the kernel pool to the file. */
/*     C */
/*           CALL WRPOOL ( UNIT ) */


/* $ Restrictions */

/*     None. */

/* $ Literature_References */

/*     None. */

/* $ Author_and_Institution */

/*     I.M. Underwood  (JPL) */
/*     W.L. Taber      (JPL) */

/* $ Version */


/* -    SPICELIB Version 8.0.0, 04-JUN-1999 (WLT) */

/*        Added the entry points PCPOOL, PDPOOL and PIPOOL to allow */
/*        direct insertion of data into the kernel pool without having */
/*        to read an external file. */

/*        Added the interface LMPOOL that allows SPICE */
/*        programs to load text kernels directly from memory */
/*        instead of requiring a text file. */

/*        Added the entry point SZPOOL to return kernel pool definition */
/*        parameters. */

/*        Added the entry point DVPOOL to allow the removal of a variable */
/*        from the kernel pool. */

/*        Added the entry point GNPOOL to allow users to determine */
/*        variables that are present in the kernel pool */

/* -    SPICELIB Version 7.0.0, 20-SEP-1995 (WLT) */

/*        The implementation of the kernel pool was completely redone */
/*        to improve performance in loading and fetching data.  In */
/*        addition the pool was upgraded so that variables may be */
/*        either string or numeric valued. */

/*        This entry point clears the string valued variables as well as */
/*        the numeric valued variables. */

/* -    SPICELIB Version 6.0.0, 31-MAR-1992 (WLT) */

/*        The entry points SWPOOL and CVPOOL were added. */

/* -    SPICELIB Version 4.0.0, 12-JUN-1990 (IMU) */

/*        All entry points except POOL and CLPOOL now initialize the */
/*        pool if it has not been done yet. */

/* -    SPICELIB Version 1.0.0, 8-JAN-1989 (IMU) */

/* -& */
/* $ Index_Entries */

/*     CLEAR the pool of kernel variables */

/* -& */
/* $ Revisions */

/* -    SPICELIB Version 8.0.0, 04-JUN-1999 (WLT) */

/*        Added the entry points PCPOOL, PDPOOL and PIPOOL to allow */
/*        direct insertion of data into the kernel pool without having */
/*        to read an external file. */

/*        Added the interface LMPOOL that allows SPICE */
/*        programs to load text kernels directly from memory */
/*        instead of requiring a text file. */

/*        Added the entry point SZPOOL to return kernel pool definition */
/*        parameters. */

/* -    SPICELIB Version 7.0.0, 20-SEP-1995 (WLT) */

/*        The implementation of the kernel pool was completely redone */
/*        to improve performance in loading and fetching data.  In */
/*        addition the pool was upgraded so that variables may be */
/*        either string or numeric valued. */

/*        This entry point clears the string valued variables as well as */
/*        the numeric valued variables. */

/* -    SPICELIB Version 6.0.0, 31-MAR-1992 (WLT) */

/*        The entry points SWPOOL (set watch on a pool variable) */
/*        and CVPOOL (check variable for update) so that routines */
/*        that buffer data stored in the kernel pool can fetch */
/*        that data only when it is updated. */


/*        Also the control of initializations was modified to be */
/*        consistent with other SPICELIB practices. */

/*        Finally, the revision history was upgraded so that the */
/*        version number increases over time.  This wasn't true */
/*        before. In addition some early revision data that referred to */
/*        pre-SPICELIB modifications were removed. This editing of */
/*        the version numbers makes it unlikely that anyone can track */
/*        down which previous version of this routine they have by */
/*        looking at the version number.  The best way to determine */
/*        the routine you had previously is to compare the dates */
/*        stored in the Version line of the routine. */

/* -    SPICELIB Version 4.0.0, 12-JUN-1990 (IMU) */

/*        All entry points except POOL and CLPOOL now initialize the */
/*        pool if it has not been done yet. */

/* -    SPICELIB Version 1.0.0, 8-JAN-1989 (IMU) */

/* -& */

/*     Standard SPICE error handling. */

    if (return_()) {
	return 0;
    } else {
	chkin_("CLPOOL", (ftnlen)6);
    }

/*     Initialize the pool if necessary. */

    zzpini_(&first, &c__5003, &c__40000, &c__4000, begdat, begtxt, nmpool, 
	    dppool, chpool, namlst, datlst, &c__1000, &c__2000, watsym, 
	    watptr, watval, agents, active, notify, (ftnlen)10, (ftnlen)10, (
	    ftnlen)32, (ftnlen)32, (ftnlen)32, (ftnlen)32, (ftnlen)32);

/*     Wipe out all of the PNAMES data. */

    for (i__ = 1; i__ <= 5003; ++i__) {
	namlst[(i__1 = i__ - 1) < 5003 && 0 <= i__1 ? i__1 : s_rnge("namlst", 
		i__1, "pool_", (ftnlen)1200)] = 0;
	datlst[(i__1 = i__ - 1) < 5003 && 0 <= i__1 ? i__1 : s_rnge("datlst", 
		i__1, "pool_", (ftnlen)1201)] = 0;
	s_copy(pnames + (((i__1 = i__ - 1) < 5003 && 0 <= i__1 ? i__1 : 
		s_rnge("pnames", i__1, "pool_", (ftnlen)1202)) << 5), " ", (
		ftnlen)32, (ftnlen)1);
    }

/*     Free up all of the space in all of the linked list pools. */

    lnkini_(&c__5003, nmpool);
    lnkini_(&c__40000, dppool);
    lnkini_(&c__4000, chpool);

/*     Copy all of the current AGENTS to notify onto the ACTIVE list. */

    copyc_(agents, active, (ftnlen)32, (ftnlen)32);
    i__1 = cardc_(watsym, (ftnlen)32);
    for (i__ = 1; i__ <= i__1; ++i__) {

/*        Get the name of the i'th variable to watch and look up its */
/*        associated agents. */

	syfetc_(&i__, watsym, watptr, watval, varnam, &gotit, (ftnlen)32, (
		ftnlen)32, (ftnlen)32);
	sygetc_(varnam, watsym, watptr, watval, &nfetch, notify + 192, &gotit,
		 (ftnlen)32, (ftnlen)32, (ftnlen)32, (ftnlen)32);
	validc_(&c__1000, &nfetch, notify, (ftnlen)32);
	unionc_(active, notify, agents, (ftnlen)32, (ftnlen)32, (ftnlen)32);
	copyc_(agents, active, (ftnlen)32, (ftnlen)32);
    }
    chkout_("CLPOOL", (ftnlen)6);
    return 0;
/* $Procedure LDPOOL ( Load variables from a kernel file into the pool ) */

L_ldpool:
/* $ Abstract */

/*     Load the variables contained in a NAIF ASCII kernel file into the */
/*     kernel pool. */

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

/*     KERNEL */

/* $ Keywords */

/*     CONSTANTS */
/*     FILES */

/* $ Declarations */

/*     CHARACTER*(*)         KERNEL */

/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  -------------------------------------------------- */
/*     KERNEL     I   Name of the kernel file. */

/* $ Detailed_Input */

/*     KERNEL     is the name of the kernel file whose variables will be */
/*                loaded into the pool. */

/* $ Detailed_Output */

/*     None. */

/* $ Parameters */

/*     None. */

/* $ Exceptions */

/*     None. */

/* $ Files */

/*     The NAIF ASCII kernel file KERNEL is opened by RDKNEW. */

/* $ Particulars */

/*     None. */

/* $ Examples */

/*     The following code fragment demonstrates how the data from */
/*     several kernel files can be loaded into a kernel pool. After the */
/*     pool is loaded, the values in the pool are written to a kernel */
/*     file. */

/*     C */
/*     C     Store in an array the names of the kernel files whose */
/*     C     values will be loaded into the kernel pool. */
/*     C */
/*           KERNEL (1) = 'AXES.KER' */
/*           KERNEL (2) = 'GM.KER' */
/*           KERNEL (3) = 'LEAP_SECONDS.KER' */

/*     C */
/*     C     Clear the kernel pool. (This is optional.) */
/*     C */
/*           CALL CLPOOL */

/*     C */
/*     C     Load the variables from the three kernel files into the */
/*     C     the kernel pool. */
/*     C */
/*           DO I = 1, 3 */
/*             CALL LDPOOL ( KERNEL (I) ) */
/*           END DO */

/*     C */
/*     C     We can examine the values associated with any d.p. variable */
/*     C     in the kernel pool using GDPOOL. */
/*     C */
/*           CALL GDPOOL ( VARIABLE, START, ROOM, NVALS, VALUES, FOUND ) */

/*     C */
/*     C     Get a free logical unit and open the file 'NEWKERNEL.KER'. */
/*     C */
/*           CALL GETLUN ( UNIT ) */

/*           OPEN ( FILE            = 'NEWKERNEL.KER', */
/*          .       UNIT            = UNIT, */
/*          .       STATUS          = 'NEW', */
/*          .       IOSTAT          = IOSTAT, */
/*          .       CARRIAGECONTROL = 'LIST'  ) */


/*     C */
/*     C     Write the values in the kernel pool to the file. */
/*     C */
/*           CALL WRPOOL ( UNIT ) */


/* $ Restrictions */

/*     None. */

/* $ Literature_References */

/*     None. */

/* $ Author_and_Institution */

/*     R.E. Thurman    (JPL) */
/*     I.M. Underwood  (JPL) */
/*     W.L. Taber      (JPL) */

/* $ Version */


/* -    SPICELIB Version 8.0.0, 04-JUN-1999 (WLT) */

/*        Added the entry points PCPOOL, PDPOOL and PIPOOL to allow */
/*        direct insertion of data into the kernel pool without having */
/*        to read an external file. */

/*        Added the interface LMPOOL that allows SPICE */
/*        programs to load text kernels directly from memory */
/*        instead of requiring a text file. */

/*        Added the entry point SZPOOL to return kernel pool definition */
/*        parameters. */

/*        Added the entry point DVPOOL to allow the removal of a variable */
/*        from the kernel pool. */

/*        Added the entry point GNPOOL to allow users to determine */
/*        variables that are present in the kernel pool */

/* -    SPICELIB Version 7.0.0, 20-SEP-1995 (WLT) */

/*        The implementation of the kernel pool was completely redone */
/*        to improve performance in loading and fetching data.  In */
/*        addition the pool was upgraded so that variables may be */
/*        either string or numeric valued. */

/*        In addition much greater error checking is performed on */
/*        the input file to guarantee valid inputs. */

/* -    SPICELIB Version 6.0.0, 31-MAR-1992 (WLT) */

/*        The entry points SWPOOL and CVPOOL were added. */

/* -    SPICELIB Version 5.0.0, 22-AUG-1990 (NJB) */

/*        Increased value of parameter MAXVAL to 5000 to accommodate */
/*        storage of SCLK coefficients in the kernel pool. */

/* -    SPICELIB Version 4.0.0, 12-JUN-1990 (IMU) */

/*        All entry points except POOL and CLPOOL now initialize the */
/*        pool if it has not been done yet. */

/* -    SPICELIB Version 3.0.0, 23-OCT-1989 (HAN) */

/*        Added declaration of FAILED. FAILED is checked in the */
/*        DO-loops in LDPOOL and WRPOOL to prevent infinite looping. */

/* -    SPICELIB Version 2.0.0, 18-OCT-1989 (RET) */

/*       A FAILED test was inserted into the control of the DO-loop which */
/*       reads in each kernel variable in LDPOOL. */

/* -    SPICELIB Version 1.2.0, 9-MAR-1989 (HAN) */

/*        Parameters BEGDAT and BEGTXT have been moved into the */
/*        Declarations section. */

/* -    SPICELIB Version 1.1.0, 16-FEB-1989 (IMU) (NJB) */

/*        Parameters MAXVAR, MAXVAL, MAXLEN moved into Declarations. */
/*        (Actually, MAXLEN was implicitly 32 characters, and has only */
/*        now been made an explicit---and changeable---limit.) */

/*        Declaration of unused function FAILED removed. */

/* -    SPICELIB Version 1.0.0, 8-JAN-1989 (IMU) */

/* -& */
/* $ Index_Entries */

/*     LOAD variables from a text kernel file into the pool */

/* -& */
/* $ Revisions */

/* -    SPICELIB Version 8.0.0, 04-JUN-1999 (WLT) */

/*        Added the entry points PCPOOL, PDPOOL and PIPOOL to allow */
/*        direct insertion of data into the kernel pool without having */
/*        to read an external file. */

/*        Added the interface LMPOOL that allows SPICE */
/*        programs to load text kernels directly from memory */
/*        instead of requiring a text file. */

/*        Added the entry point SZPOOL to return kernel pool definition */
/*        parameters. */

/* -    SPICELIB Version 7.0.0, 20-SEP-1995 (WLT) */

/*        The implementation of the kernel pool was completely redone */
/*        to improve performance in loading and fetching data.  In */
/*        addition the pool was upgraded so that variables may be */
/*        either string or numeric valued. */

/*        The entry points GCPOOL, GDPOOL, GIPOOL and DTPOOL were added */
/*        to the routine. */

/*        The entry point RTPOOL should now be regarded as obsolete */
/*        and is maintained soley for backward compatibility with */
/*        existing routines that make use of it. */

/*        The basic data structure used to maintain the list of */
/*        variable names and values was replaced with a hash table */
/*        implementation.  Data and names are accessed by means */
/*        of a hash function and linked lists of pointers to exising */
/*        variable names and data values. */

/*        In addition much greater error checking is performed on */
/*        the input file to guarantee valid inputs. */

/* -    SPICELIB Version 6.0.0, 31-MAR-1992 (WLT) */

/*        The entry points SWPOOL (set watch on a pool variable) */
/*        and CVPOOL (check variable for update) so that routines */
/*        that buffer data stored in the kernel pool can fetch */
/*        that data only when it is updated. */

/*        In addition, the revision history was upgraded so that the */
/*        version number increases over time.  This wasn't true */
/*        before. In addition some early revision data that referred to */
/*        pre-SPICELIB modifications were removed. This editing of */
/*        the version numbers makes it unlikely that anyone can track */
/*        down which previous version of this routine they have by */
/*        looking at the version number.  The best way to determine */
/*        the routine you had previously is to compare the dates */
/*        stored in the Version line of the routine. */

/* -    SPICELIB Version 5.0.0, 22-AUG-1990 (NJB) */

/*        Increased value of parameter MAXVAL to 5000 to accommodate */
/*        storage of SCLK coefficients in the kernel pool. */

/*        Also, changed version number in previous `Revisions' entry */
/*        from SPICELIB Version 2.0.0 to SPICELIB Version 2.0.0.  The */
/*        last version entry in the `Version' section had been */
/*        Version 1.0.0, dated later than the entry for `version 2' */
/*        in the revisions section! */

/* -    SPICELIB Version 4.0.0, 12-JUN-1990 (IMU) */

/*        All entry points except POOL and CLPOOL now initialize the */
/*        pool if it has not been done yet. */

/* -    SPICELIB Version 3.0.0, 23-OCT-1989 (HAN) */

/*        Added declaration of FAILED. FAILED is checked in the */
/*        DO-loops in LDPOOL and WRPOOL to prevent infinite looping. */

/* -    SPICELIB Version 2.0.0, 18-OCT-1989 (RET) */

/*       A FAILED test was inserted into the control of the DO-loop which */
/*       reads in each kernel variable. */

/*       Previously, if the error action 'RETURN' had been set by a */
/*       calling program, and the call to RDKNEW by LDPOOL failed, */
/*       then execution would continue through LDPOOL, with SPICELIB */
/*       routines returning upon entry. This meant that the routine */
/*       RDKVAR never got a chance to set the EOF flag, which was the */
/*       only control of the DO-loop. An infinite loop resulted in such */
/*       cases.  The FAILED test resolves that situation. */

/* -    SPICELIB Version 1.2.0, 9-MAR-1989 (HAN) */

/*        Parameters BEGDAT and BEGTXT have been moved into the */
/*        Declarations section. */

/* -    SPICELIB Version 1.1.0, 16-FEB-1989 (IMU) (NJB) */

/*        Parameters MAXVAR, MAXVAL, MAXLEN moved into Declarations. */
/*        (Actually, MAXLEN was implicitly 32 characters, and has only */
/*        now been made an explicit---and changeable---limit.) */

/*        Declaration of unused function FAILED removed. */

/* -    SPICELIB Version 1.0.0, 8-JAN-1989 (IMU) */

/* -& */

/*     Standard SPICE error handling. */

    if (return_()) {
	return 0;
    } else {
	chkin_("LDPOOL", (ftnlen)6);
    }

/*     Initialize the pool if necessary. */

    zzpini_(&first, &c__5003, &c__40000, &c__4000, begdat, begtxt, nmpool, 
	    dppool, chpool, namlst, datlst, &c__1000, &c__2000, watsym, 
	    watptr, watval, agents, active, notify, (ftnlen)10, (ftnlen)10, (
	    ftnlen)32, (ftnlen)32, (ftnlen)32, (ftnlen)32, (ftnlen)32);

/*     Open the kernel file and read the first variable. */

    rdknew_(kernel, kernel_len);
    zzrvar_(namlst, nmpool, pnames, datlst, dppool, dpvals, chpool, chvals, 
	    varnam, &eof, (ftnlen)32, (ftnlen)80, (ftnlen)32);

/*     Read the variables in the file, one at a time. */

    while(! eof && ! failed_()) {
	if (s_cmp(varnam, " ", (ftnlen)32, (ftnlen)1) != 0) {

/*           See if this variable is being watched ... */

	    sygetc_(varnam, watsym, watptr, watval, &nfetch, notify + 192, &
		    got, (ftnlen)32, (ftnlen)32, (ftnlen)32, (ftnlen)32);

/*           ... if it is, add its associated agents to the list of */
/*           AGENTS to be notified of a watched variable update. */

	    if (got) {
		copyc_(agents, active, (ftnlen)32, (ftnlen)32);
		validc_(&c__1000, &nfetch, notify, (ftnlen)32);
		unionc_(notify, active, agents, (ftnlen)32, (ftnlen)32, (
			ftnlen)32);
	    }
	}
	zzrvar_(namlst, nmpool, pnames, datlst, dppool, dpvals, chpool, 
		chvals, varnam, &eof, (ftnlen)32, (ftnlen)80, (ftnlen)32);
    }

/*     We need to make sure that the kernel file gets closed.  Normally */
/*     the calling tree of ZZRVAR take care of this, but if a parsing */
/*     or syntax error occurs there,  ZZRVAR just returns and the */
/*     closing of the kernel is never handled.  This takes care */
/*     of the problem.  If the file has been closed already, this */
/*     doesn't hurt anything. */

    cltext_(kernel, kernel_len);
    chkout_("LDPOOL", (ftnlen)6);
    return 0;
/* $Procedure RTPOOL ( Return the value of a pooled kernel variable ) */

L_rtpool:
/* $ Abstract */

/*     Return the value of a kernel variable from the kernel pool. */

/*     This routine is maintained only for backward compatibility. */
/*     It should be regarded as obsolete.  Use one of the entry points */
/*     GDPOOL, GIPOOL or GCPOOL in its place. */

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

/*     KERNEL */

/* $ Keywords */

/*     CONSTANTS */
/*     FILES */

/* $ Declarations */

/*     CHARACTER*(*)         NAME */
/*     INTEGER               N */
/*     DOUBLE PRECISION      VALUES   ( * ) */
/*     LOGICAL               FOUND */

/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  -------------------------------------------------- */
/*     NAME       I   Name of the variable whose value is to be returned. */
/*     N          O   Number of values associated with NAME. */
/*     VALUES     O   Values associated with NAME. */
/*     FOUND      O   True if variable is in pool. */

/* $ Detailed_Input */

/*     NAME       is the name of the variable whose values are to be */
/*                returned. If the variable is not in the pool, FOUND */
/*                will be FALSE. */

/* $ Detailed_Output */

/*     N          is the number of values associated with NAME. */
/*                If NAME is not in the pool, no value is given to */
/*                N. */

/*     VALUES     is the array of values associated with NAME. */
/*                If NAME is not in the pool, no values are given to */
/*                the elements of VALUES. */

/*     FOUND      is TRUE if the variable is in the pool, FALSE if it */
/*                is not. */

/* $ Parameters */

/*     None. */

/* $ Exceptions */

/*     None. */

/* $ Files */

/*     None. */

/* $ Particulars */

/*     None. */

/* $ Examples */


/*     The following code fragment demonstrates how the data from */
/*     several kernel files can be loaded into a kernel pool. After the */
/*     pool is loaded, the values in the pool are written to a kernel */
/*     file. */


/*     C */
/*     C     Store in an array the names of the kernel files whose */
/*     C     values will be loaded into the kernel pool. */
/*     C */
/*           KERNEL (1) = 'AXES.KER' */
/*           KERNEL (2) = 'GM.KER' */
/*           KERNEL (3) = 'LEAP_SECONDS.KER' */

/*     C */
/*     C     Clear the kernel pool. (This is optional.) */
/*     C */
/*           CALL CLPOOL */

/*     C */
/*     C     Load the variables from the three kernel files into the */
/*     C     the kernel pool. */
/*     C */
/*           DO I = 1, 3 */
/*             CALL LDPOOL ( KERNEL (I) ) */
/*           END DO */

/*     C */
/*     C     We can examine the values associated with any variable */
/*     C     in the kernel pool using RTPOOL. */
/*     C */
/*           CALL RTPOOL ( VARIABLE, NUMVAL, VALUES, FOUND ) */

/*     C */
/*     C     Get a free logical unit and open the file 'NEWKERNEL.KER'. */
/*     C */
/*           CALL GETLUN ( UNIT ) */

/*           OPEN ( FILE            = 'NEWKERNEL.KER', */
/*          .       UNIT            = UNIT, */
/*          .       STATUS          = 'NEW', */
/*          .       IOSTAT          = IOSTAT, */
/*          .       CARRIAGECONTROL = 'LIST'  ) */


/*     C */
/*     C     Write the values in the kernel pool to the file. */
/*     C */
/*           CALL WRPOOL ( UNIT ) */

/* $ Restrictions */

/*     None. */

/* $ Literature_References */

/*     None. */

/* $ Author_and_Institution */

/*     I.M. Underwood  (JPL) */

/* $ Version */

/* -    SPICELIB Version 8.0.1, 22-DEC-2004 (NJB) */

/*        Corrected an in-line comment relating to finding the */
/*        head node of the conflict resolution list for NAME. */

/* -    SPICELIB Version 8.0.0, 04-JUN-1999 (WLT) */

/*        Added the entry points PCPOOL, PDPOOL and PIPOOL to allow */
/*        direct insertion of data into the kernel pool without having */
/*        to read an external file. */

/*        Added the interface LMPOOL that allows SPICE */
/*        programs to load text kernels directly from memory */
/*        instead of requiring a text file. */

/*        Added the entry point SZPOOL to return kernel pool definition */
/*        parameters. */

/*        Added the entry point DVPOOL to allow the removal of a variable */
/*        from the kernel pool. */

/*        Added the entry point GNPOOL to allow users to determine */
/*        variables that are present in the kernel pool */

/* -    SPICELIB Version 7.0.0, 20-SEP-1995 (WLT) */

/*        The implementation of the kernel pool was completely redone */
/*        to improve performance in loading and fetching data.  In */
/*        addition the pool was upgraded so that variables may be */
/*        either string or numeric valued. */

/*        The entry points GCPOOL, GDPOOL, GIPOOL and DTPOOL were added */
/*        to the routine. */

/*        The entry point RTPOOL should now be regarded as obsolete */
/*        and is maintained soley for backward compatibility with */
/*        existing routines that make use of it. */

/* -    SPICELIB Version 4.0.0, 12-JUN-1990 (IMU) */

/*        All entry points except POOL and CLPOOL now initialize the */
/*        pool if it has not been done yet. */

/* -    SPICELIB Version 1.0.0, 8-JAN-1989 (IMU) */

/* -& */
/* $ Index_Entries */

/*     RETURN the value of a pooled kernel variable */

/* -& */
/* $ Revisions */

/* -    SPICELIB Version 4.0.0, 12-JUN-1990 (IMU) */

/*        All entry points except POOL and CLPOOL now initialize the */
/*        pool if it has not been done yet. */

/* -    SPICELIB Version 1.0.0, 8-JAN-1989 (IMU) */

/* -& */

/*     Standard SPICE error handling. */

    if (return_()) {
	return 0;
    } else {
	chkin_("RTPOOL", (ftnlen)6);
    }

/*     Initialize the pool if necessary. */

    zzpini_(&first, &c__5003, &c__40000, &c__4000, begdat, begtxt, nmpool, 
	    dppool, chpool, namlst, datlst, &c__1000, &c__2000, watsym, 
	    watptr, watval, agents, active, notify, (ftnlen)10, (ftnlen)10, (
	    ftnlen)32, (ftnlen)32, (ftnlen)32, (ftnlen)32, (ftnlen)32);

/*     Compute the hash value of this name. */

    lookat = zzhash_(name__, name_len);

/*     Now see if there is a non-empty conflict resolution list for the */
/*     input string NAME.  If so, NAMLST(LOOKAT) contains the head node */
/*     of the conflict resolution list; this node is a postive value. */

    if (namlst[(i__1 = lookat - 1) < 5003 && 0 <= i__1 ? i__1 : s_rnge("naml"
	    "st", i__1, "pool_", (ftnlen)1911)] == 0) {
	*found = FALSE_;
	chkout_("RTPOOL", (ftnlen)6);
	return 0;
    }

/*     If were are still here NAMLST(LOOKAT) is the first node of */
/*     a conflict resolution list.  See if the NAME corresposnding */
/*     to this node is the one we are looking for. */

    node = namlst[(i__1 = lookat - 1) < 5003 && 0 <= i__1 ? i__1 : s_rnge(
	    "namlst", i__1, "pool_", (ftnlen)1923)];
    succes = s_cmp(name__, pnames + (((i__1 = node - 1) < 5003 && 0 <= i__1 ? 
	    i__1 : s_rnge("pnames", i__1, "pool_", (ftnlen)1924)) << 5), 
	    name_len, (ftnlen)32) == 0;
    while(! succes) {
	node = nmpool[(i__1 = (node << 1) + 10) < 10018 && 0 <= i__1 ? i__1 : 
		s_rnge("nmpool", i__1, "pool_", (ftnlen)1928)];
	if (node < 0) {
	    *found = FALSE_;
	    chkout_("RTPOOL", (ftnlen)6);
	    return 0;
	}
	succes = s_cmp(name__, pnames + (((i__1 = node - 1) < 5003 && 0 <= 
		i__1 ? i__1 : s_rnge("pnames", i__1, "pool_", (ftnlen)1938)) 
		<< 5), name_len, (ftnlen)32) == 0;
    }

/*     If you get to this point, the variable NAME is present in the */
/*     list of names at PNAMES(NODE), ABS( DATLST(NODE) ) points to the */
/*     head of a linked list of values for this NAME. */

/*     However, recall that RTPOOL can only return d.p. values. */
/*     DATLST(NODE) is the head of a d.p. list of values if it */
/*     is positive.  We use negative values to point to character */
/*     values. */

    if (datlst[(i__1 = node - 1) < 5003 && 0 <= i__1 ? i__1 : s_rnge("datlst",
	     i__1, "pool_", (ftnlen)1951)] <= 0) {
	*found = FALSE_;
    } else {
	*found = TRUE_;
	*n = 0;
	node = datlst[(i__1 = node - 1) < 5003 && 0 <= i__1 ? i__1 : s_rnge(
		"datlst", i__1, "pool_", (ftnlen)1959)];
	while(node > 0) {
	    ++(*n);
	    values[*n - 1] = dpvals[(i__1 = node - 1) < 40000 && 0 <= i__1 ? 
		    i__1 : s_rnge("dpvals", i__1, "pool_", (ftnlen)1963)];
	    node = dppool[(i__1 = (node << 1) + 10) < 80012 && 0 <= i__1 ? 
		    i__1 : s_rnge("dppool", i__1, "pool_", (ftnlen)1964)];
	}
    }
    chkout_("RTPOOL", (ftnlen)6);
    return 0;
/* $Procedure EXPOOL ( Confirm the existence of a pooled kernel variable ) */

L_expool:
/* $ Abstract */

/*     Confirm the existence of a kernel variable in the kernel pool. */

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

/*     KERNEL */

/* $ Keywords */

/*     CONSTANTS */
/*     FILES */

/* $ Declarations */

/*     CHARACTER*(*)         NAME */
/*     LOGICAL               FOUND */

/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  -------------------------------------------------- */
/*     NAME       I   Name of the variable whose value is to be returned. */
/*     FOUND      O   True when the variable is in the pool. */

/* $ Detailed_Input */

/*     NAME       is the name of the variable whose values are to be */
/*                returned. */

/* $ Detailed_Output */

/*     FOUND      is true whenever the specified variable is included */
/*                in the pool. */

/* $ Parameters */

/*     None. */

/* $ Exceptions */

/*     None. */

/* $ Files */

/*     None. */

/* $ Particulars */

/*     This routine detemines whether or not a numeric kernel pool */
/*     variable exists.  It does not detect the existence of */
/*     string valued kernel pool variables. */

/*     A better routine for determining the existence of kernel pool */
/*     variables is the entry point DTPOOL which determines the */
/*     existence, size and type of kernel pool variables. */

/* $ Examples */

/*     See BODFND. */

/* $ Restrictions */

/*     None. */

/* $ Literature_References */

/*     None. */

/* $ Author_and_Institution */

/*     I.M. Underwood  (JPL) */

/* $ Version */

/* -    SPICELIB Version 8.0.1, 22-DEC-2004 (NJB) */

/*        Corrected an in-line comment relating to finding the */
/*        head node of the conflict resolution list for NAME. */

/* -    SPICELIB Version 8.0.0, 04-JUN-1999 (WLT) */

/*        Added the entry points PCPOOL, PDPOOL and PIPOOL to allow */
/*        direct insertion of data into the kernel pool without having */
/*        to read an external file. */

/*        Added the interface LMPOOL that allows SPICE */
/*        programs to load text kernels directly from memory */
/*        instead of requiring a text file. */

/*        Added the entry point SZPOOL to return kernel pool definition */
/*        parameters. */

/*        Added the entry point DVPOOL to allow the removal of a variable */
/*        from the kernel pool. */

/*        Added the entry point GNPOOL to allow users to determine */
/*        variables that are present in the kernel pool */

/* -    SPICELIB Version 7.0.0, 20-SEP-1995 (WLT) */

/*        The implementation of the kernel pool was completely redone */
/*        to improve performance in loading and fetching data.  In */
/*        addition the pool was upgraded so that variables may be */
/*        either string or numeric valued. */

/*        The entry points GCPOOL, GDPOOL, GIPOOL and DTPOOL were added */
/*        to the routine. */

/* -    SPICELIB Version 4.0.0, 12-JUN-1990 (IMU) */

/*        All entry points except POOL and CLPOOL now initialize the */
/*        pool if it has not been done yet. */

/* -    SPICELIB Version 1.0.0, 8-JAN-1989 (IMU) */

/* -& */
/* $ Index_Entries */

/*     CONFIRM the existence of a pooled kernel variable */

/* -& */
/* $ Revisions */

/*        The implementation of the kernel pool was completely redone */
/*        to improve performance in loading and fetching data.  In */
/*        addition the pool was upgraded so that variables may be */
/*        either string or numeric valued. */

/*        The entry points GCPOOL, GDPOOL, GIPOOL and DTPOOL were added */
/*        to the routine. */

/*        The entry point RTPOOL should now be regarded as obsolete */
/*        and is maintained soley for backward compatibility with */
/*        existing routines that make use of it. */

/*        The basic data structure used to maintain the list of */
/*        variable names and values was replaced with a hash table */
/*        implementation.  Data and names are accessed by means */
/*        of a hash function and linked lists of pointers to exising */
/*        variable names and data values. */

/* -    SPICELIB Version 4.0.0, 12-JUN-1990 (IMU) */

/*        All entry points except POOL and CLPOOL now initialize the */
/*        pool if it has not been done yet. */

/* -    SPICELIB Version 1.0.0, 8-JAN-1989 (IMU) */

/* -& */

/*     Standard SPICE error handling. */

    if (return_()) {
	return 0;
    } else {
	chkin_("EXPOOL", (ftnlen)6);
    }

/*     Initialize the pool if necessary. */

    zzpini_(&first, &c__5003, &c__40000, &c__4000, begdat, begtxt, nmpool, 
	    dppool, chpool, namlst, datlst, &c__1000, &c__2000, watsym, 
	    watptr, watval, agents, active, notify, (ftnlen)10, (ftnlen)10, (
	    ftnlen)32, (ftnlen)32, (ftnlen)32, (ftnlen)32, (ftnlen)32);

/*     Compute the hash value of this name. */

    lookat = zzhash_(name__, name_len);

/*     Now see if there is a non-empty conflict resolution list for the */
/*     input string NAME.  If so, NAMLST(LOOKAT) contains the head node */
/*     of the conflict resolution list; this node is a postive value. */

    if (namlst[(i__1 = lookat - 1) < 5003 && 0 <= i__1 ? i__1 : s_rnge("naml"
	    "st", i__1, "pool_", (ftnlen)2195)] == 0) {
	*found = FALSE_;
	chkout_("EXPOOL", (ftnlen)6);
	return 0;
    }

/*     If were are still here NAMLST(LOOKAT) is the first node of */
/*     a conflict resolution list.  See if the NAME corresposnding */
/*     to this node is the one we are looking for. */

    node = namlst[(i__1 = lookat - 1) < 5003 && 0 <= i__1 ? i__1 : s_rnge(
	    "namlst", i__1, "pool_", (ftnlen)2207)];
    succes = s_cmp(name__, pnames + (((i__1 = node - 1) < 5003 && 0 <= i__1 ? 
	    i__1 : s_rnge("pnames", i__1, "pool_", (ftnlen)2208)) << 5), 
	    name_len, (ftnlen)32) == 0;
    while(! succes) {
	node = nmpool[(i__1 = (node << 1) + 10) < 10018 && 0 <= i__1 ? i__1 : 
		s_rnge("nmpool", i__1, "pool_", (ftnlen)2212)];
	if (node < 0) {
	    *found = FALSE_;
	    chkout_("EXPOOL", (ftnlen)6);
	    return 0;
	}
	succes = s_cmp(name__, pnames + (((i__1 = node - 1) < 5003 && 0 <= 
		i__1 ? i__1 : s_rnge("pnames", i__1, "pool_", (ftnlen)2222)) 
		<< 5), name_len, (ftnlen)32) == 0;
    }

/*     If you get to this point, the variable NAME is present in the */
/*     list of names at PNAMES(NODE), ABS( DATLST(NODE) ) points to the */
/*     head of a linked list of values for this NAME. */

/*     However, recall that EXPOOL indicates the existence only of */
/*     d.p. values. */

    *found = datlst[(i__1 = node - 1) < 5003 && 0 <= i__1 ? i__1 : s_rnge(
	    "datlst", i__1, "pool_", (ftnlen)2233)] > 0;
    chkout_("EXPOOL", (ftnlen)6);
    return 0;
/* $Procedure WRPOOL ( Write the values in pool to a specified unit ) */

L_wrpool:
/* $ Abstract */

/*     Write the values in the pool to the specified unit. */

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

/*     KERNEL */

/* $ Keywords */

/*     CONSTANTS */
/*     FILES */

/* $ Declarations */

/*     INTEGER        UNIT */

/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  -------------------------------------------------- */
/*     UNIT       I   Logical unit to which the values in the pool will */
/*                    be written. */

/* $ Detailed_Input */

/*     UNIT       is the logical unit to which the values in the pool */
/*                will be written. */

/* $ Detailed_Output */

/*     None. */

/* $ Parameters */

/*     None. */

/* $ Files */

/*     If the values are to be written to an output kernel file, the */
/*     file should be opened with a logical unit determined by the */
/*     calling program. */

/* $ Exceptions */

/*     None. */

/* $ Particulars */

/*     None. */

/* $ Examples */


/*     The following code fragment demonstrates how the data from */
/*     several kernel files can be loaded into a kernel pool. After the */
/*     pool is loaded, the values in the pool are written to a kernel */
/*     file. */


/*     C */
/*     C     Store in an array the names of the kernel files whose */
/*     C     values will be loaded into the kernel pool. */
/*     C */
/*           KERNEL (1) = 'AXES.KER' */
/*           KERNEL (2) = 'GM.KER' */
/*           KERNEL (3) = 'LEAP_SECONDS.KER' */

/*     C */
/*     C     Clear the kernel pool. (This is optional.) */
/*     C */
/*           CALL CLPOOL */

/*     C */
/*     C     Load the variables from the three kernel files into the */
/*     C     the kernel pool. */
/*     C */
/*           DO I = 1, 3 */
/*             CALL LDPOOL ( KERNEL (I) ) */
/*           END DO */

/*     C */
/*     C     We can examine the values associated with any variable */
/*     C     in the kernel pool using RTPOOL. */
/*     C */
/*           CALL RTPOOL ( VARIABLE, NUMVAL, VALUES, FOUND ) */

/*     C */
/*     C     Get a free logical unit and open the file 'NEWKERNEL.KER'. */
/*     C */
/*           CALL GETLUN ( UNIT ) */

/*           OPEN ( FILE            = 'NEWKERNEL.KER', */
/*          .       UNIT            = UNIT, */
/*          .       STATUS          = 'NEW', */
/*          .       IOSTAT          = IOSTAT, */
/*          .       CARRIAGECONTROL = 'LIST'  ) */


/*     C */
/*     C     Write the values in the kernel pool to the file. */
/*     C */
/*           CALL WRPOOL ( UNIT ) */


/* $ Restrictions */

/*     None. */

/* $ Literature_References */

/*     None. */

/* $ Author_and_Institution */

/*     H.A. Neilan     (JPL) */
/*     I.M. Underwood  (JPL) */

/* $ Version */


/* -    SPICELIB Version 8.0.0, 04-JUN-1999 (WLT) */

/*        Added the entry points PCPOOL, PDPOOL and PIPOOL to allow */
/*        direct insertion of data into the kernel pool without having */
/*        to read an external file. */

/*        Added the interface LMPOOL that allows SPICE */
/*        programs to load text kernels directly from memory */
/*        instead of requiring a text file. */

/*        Added the entry point SZPOOL to return kernel pool definition */
/*        parameters. */

/*        Added the entry point DVPOOL to allow the removal of a variable */
/*        from the kernel pool. */

/*        Added the entry point GNPOOL to allow users to determine */
/*        variables that are present in the kernel pool */

/* -    SPICELIB Version 7.0.0, 20-SEP-1995 (WLT) */

/*        The implementation of the kernel pool was completely redone */
/*        to improve performance in loading and fetching data.  In */
/*        addition the pool was upgraded so that variables may be */
/*        either string or numeric valued.  Both types are supported */
/*        by WRPOOL. */

/* -    SPICELIB Version 5.0.0, 22-AUG-1990 (NJB) */

/*        Increased value of parameter MAXVAL to 5000 to accommodate */
/*        storage of SCLK coefficients in the kernel pool. */

/* -    SPICELIB Version 4.0.0, 12-JUN-1990 (IMU) */

/*        All entry points except POOL and CLPOOL now initialize the */
/*        pool if it has not been done yet. */

/* -    SPICELIB Version 3.0.0, 23-OCT-1989 (HAN) */

/*        Added declaration of FAILED. FAILED is checked in the */
/*        DO-loops in LDPOOL and WRPOOL to prevent infinite looping. */

/* -    SPICELIB Version 1.2.0, 9-MAR-1989 (HAN) */

/*        Parameters BEGDAT and BEGTXT have been moved into the */
/*        Declarations section. */

/* -    SPICELIB Version 1.1.0, 16-FEB-1989 (IMU) (NJB) */

/*        Parameters MAXVAR, MAXVAL, MAXLEN moved into Declarations. */
/*        (Actually, MAXLEN was implicitly 32 characters, and has only */
/*        now been made an explicit---and changeable---limit.) */

/*        Declaration of unused function FAILED removed. */

/* -    SPICELIB Version 1.0.0, 8-JAN-1989 (IMU) */

/* -& */
/* $ Index_Entries */

/*     WRITE the values in pool to a specified unit */

/* -& */
/* $ Revisions */

/*        The implementation of the kernel pool was completely redone */
/*        to improve performance in loading and fetching data.  In */
/*        addition the pool was upgraded so that variables may be */
/*        either string or numeric valued. */

/*        The basic data structure used to maintain the list of */
/*        variable names and values was replaced with a hash table */
/*        implementation.  Data and names are accessed by means */
/*        of a hash function and linked lists of pointers to exising */
/*        variable names and data values. */

/* -    SPICELIB Version 5.0.0, 22-AUG-1990 (NJB) */

/*        Increased value of parameter MAXVAL to 5000 to accommodate */
/*        storage of SCLK coefficients in the kernel pool. */

/*        Also, changed version number in previous `Revisions' entry */
/*        from SPICELIB Version 2.0.0 to SPICELIB Version 2.0.0.  The */
/*        last version entry in the `Version' section had been */
/*        Version 1.0.0, dated later than the entry for `version 2' */
/*        in the revisions section! */

/* -    SPICELIB Version 4.0.0, 12-JUN-1990 (IMU) */

/*        All entry points except POOL and CLPOOL now initialize the */
/*        pool if it has not been done yet. */

/* -    SPICELIB Version 3.0.0, 23-OCT-1989 (HAN) */

/*        Added declaration of FAILED. FAILED is checked in the */
/*        DO-loops in LDPOOL and WRPOOL to prevent infinite looping. */

/* -    SPICELIB Version 2.0.0, 18-OCT-1989 (RET) */

/*       A FAILED test was inserted into the control of the DO-loop which */
/*       reads in each kernel variable. */

/*       Previously, if the error action 'RETURN' had been set by a */
/*       calling program, and the call to RDKNEW by LDPOOL failed, */
/*       then execution would continue through LDPOOL, with SPICELIB */
/*       routines returning upon entry. This meant that the routine */
/*       RDKVAR never got a chance to set the EOF flag, which was the */
/*       only control of the DO-loop. An infinite loop resulted in such */
/*       cases.  The FAILED test resolves that situation. */

/* -    SPICELIB Version 1.2.0, 9-MAR-1989 (HAN) */

/*        Parameters BEGDAT and BEGTXT have been moved into the */
/*        Declarations section. */

/* -    SPICELIB Version 1.1.0, 16-FEB-1989 (IMU) (NJB) */

/*        Parameters MAXVAR, MAXVAL, MAXLEN moved into Declarations. */
/*        (Actually, MAXLEN was implicitly 32 characters, and has only */
/*        now been made an explicit---and changeable---limit.) */

/*        Declaration of unused function FAILED removed. */

/* -    SPICELIB Version 1.0.0, 8-JAN-1989 (IMU) */

/* -& */

/*     Standard SPICE error handling. */

    if (return_()) {
	return 0;
    } else {
	chkin_("WRPOOL", (ftnlen)6);
    }

/*     Indicate the beginning of a data section. */

    ci__1.cierr = 1;
    ci__1.ciunit = *unit;
    ci__1.cifmt = "(1X,A)";
    iostat = s_wsfe(&ci__1);
    if (iostat != 0) {
	goto L100001;
    }
    iostat = do_fio(&c__1, begdat, (ftnlen)10);
    if (iostat != 0) {
	goto L100001;
    }
    iostat = e_wsfe();
L100001:
    ci__1.cierr = 1;
    ci__1.ciunit = *unit;
    ci__1.cifmt = "(1X,A)";
    iostat = s_wsfe(&ci__1);
    if (iostat != 0) {
	goto L100002;
    }
    iostat = e_wsfe();
L100002:
    if (iostat != 0) {
	ioerr_("writing a variable to the output kernel file ", " ", &iostat, 
		(ftnlen)45, (ftnlen)1);
	sigerr_("SPICE(WRITEERROR)", (ftnlen)17);
	chkout_("WRPOOL", (ftnlen)6);
	return 0;
    }

/*     Next prepare for writing out the data. */

    iquote = '\'';
    margin = 38;
    for (k = 1; k <= 5003; ++k) {

/*        Get the head of this list. */

	nnode = namlst[(i__1 = k - 1) < 5003 && 0 <= i__1 ? i__1 : s_rnge(
		"namlst", i__1, "pool_", (ftnlen)2558)];
	while(nnode > 0) {
	    s_copy(line, pnames + (((i__1 = nnode - 1) < 5003 && 0 <= i__1 ? 
		    i__1 : s_rnge("pnames", i__1, "pool_", (ftnlen)2562)) << 
		    5), (ftnlen)132, (ftnlen)32);
	    datahd = datlst[(i__1 = nnode - 1) < 5003 && 0 <= i__1 ? i__1 : 
		    s_rnge("datlst", i__1, "pool_", (ftnlen)2563)];
	    dp = datahd > 0;
	    chr = datahd < 0;
	    dnode = abs(datahd);

/*           Determine whether or not this is a vector object. */

	    if (dp) {
		vector = dppool[(i__1 = (dnode << 1) + 10) < 80012 && 0 <= 
			i__1 ? i__1 : s_rnge("dppool", i__1, "pool_", (ftnlen)
			2571)] > 0;
	    } else if (chr) {
		vector = chpool[(i__1 = (dnode << 1) + 10) < 8012 && 0 <= 
			i__1 ? i__1 : s_rnge("chpool", i__1, "pool_", (ftnlen)
			2573)] > 0;
	    } else {
		setmsg_("This error is never supposed to occur. No data was "
			"available for the variable '#'. ", (ftnlen)83);
		r__ = rtrim_(pnames + (((i__1 = nnode - 1) < 5003 && 0 <= 
			i__1 ? i__1 : s_rnge("pnames", i__1, "pool_", (ftnlen)
			2579)) << 5), (ftnlen)32);
		errch_("#", pnames + (((i__1 = nnode - 1) < 5003 && 0 <= i__1 
			? i__1 : s_rnge("pnames", i__1, "pool_", (ftnlen)2580)
			) << 5), (ftnlen)1, r__);
		sigerr_("SPICE(BUG)", (ftnlen)10);
		chkout_("WRPOOL", (ftnlen)6);
		return 0;
	    }

/*           If still here, then we can set up the beginning of this */
/*           output line. */

	    s_copy(line + 33, "= ", (ftnlen)99, (ftnlen)2);
	    if (vector) {
		s_copy(line + 35, "( ", (ftnlen)97, (ftnlen)2);
	    }

/*           Now fetch all of the data associated with this variable. */
/*           We'll write them out one per line. */

	    while(dnode > 0) {

/*              Get the next data value and the address of the next node. */

		if (dp) {
		    dvalue = dpvals[(i__1 = dnode - 1) < 40000 && 0 <= i__1 ? 
			    i__1 : s_rnge("dpvals", i__1, "pool_", (ftnlen)
			    2603)];
		    dnode = dppool[(i__1 = (dnode << 1) + 10) < 80012 && 0 <= 
			    i__1 ? i__1 : s_rnge("dppool", i__1, "pool_", (
			    ftnlen)2604)];
		} else {
		    s_copy(cvalue, "'", (ftnlen)132, (ftnlen)1);
		    j = 1;

/*                 We have to double up each of the quotes on output. */
/*                 For this reason we copy the letters one at a time */
/*                 into the output holding area CVALUE. */

		    i__2 = rtrim_(chvals + ((i__1 = dnode - 1) < 4000 && 0 <= 
			    i__1 ? i__1 : s_rnge("chvals", i__1, "pool_", (
			    ftnlen)2613)) * 80, (ftnlen)80);
		    for (i__ = 1; i__ <= i__2; ++i__) {
			++j;
			*(unsigned char *)&cvalue[j - 1] = *(unsigned char *)&
				chvals[((i__1 = dnode - 1) < 4000 && 0 <= 
				i__1 ? i__1 : s_rnge("chvals", i__1, "pool_", 
				(ftnlen)2615)) * 80 + (i__ - 1)];
			code = *(unsigned char *)&chvals[((i__1 = dnode - 1) <
				 4000 && 0 <= i__1 ? i__1 : s_rnge("chvals", 
				i__1, "pool_", (ftnlen)2617)) * 80 + (i__ - 1)
				];
			if (code == iquote) {
			    ++j;
			    *(unsigned char *)&cvalue[j - 1] = *(unsigned 
				    char *)&chvals[((i__1 = dnode - 1) < 4000 
				    && 0 <= i__1 ? i__1 : s_rnge("chvals", 
				    i__1, "pool_", (ftnlen)2621)) * 80 + (i__ 
				    - 1)];
			}
		    }
		    ++j;
		    *(unsigned char *)&cvalue[j - 1] = '\'';
		    dnode = chpool[(i__2 = (dnode << 1) + 10) < 8012 && 0 <= 
			    i__2 ? i__2 : s_rnge("chpool", i__2, "pool_", (
			    ftnlen)2627)];
		}

/*              We will need to properly finish off this write with */
/*              either a comma, a blank or a right parenthesis. */

		if (dnode > 0) {
		    s_copy(finish, ", ", (ftnlen)2, (ftnlen)2);
		} else if (vector) {
		    s_copy(finish, " )", (ftnlen)2, (ftnlen)2);
		} else {
		    s_copy(finish, " ", (ftnlen)2, (ftnlen)1);
		}

/*              Now write out our data. */

		if (dp) {
		    ci__1.cierr = 1;
		    ci__1.ciunit = *unit;
		    ci__1.cifmt = "(1X,A,D25.17,A)";
		    iostat = s_wsfe(&ci__1);
		    if (iostat != 0) {
			goto L100003;
		    }
		    iostat = do_fio(&c__1, line, margin);
		    if (iostat != 0) {
			goto L100003;
		    }
		    iostat = do_fio(&c__1, (char *)&dvalue, (ftnlen)sizeof(
			    doublereal));
		    if (iostat != 0) {
			goto L100003;
		    }
		    iostat = do_fio(&c__1, finish, (ftnlen)2);
		    if (iostat != 0) {
			goto L100003;
		    }
		    iostat = e_wsfe();
L100003:
		    ;
		} else {
		    ci__1.cierr = 1;
		    ci__1.ciunit = *unit;
		    ci__1.cifmt = "(1X,3A)";
		    iostat = s_wsfe(&ci__1);
		    if (iostat != 0) {
			goto L100004;
		    }
		    iostat = do_fio(&c__1, line, margin);
		    if (iostat != 0) {
			goto L100004;
		    }
		    iostat = do_fio(&c__1, cvalue, j);
		    if (iostat != 0) {
			goto L100004;
		    }
		    iostat = do_fio(&c__1, finish, (ftnlen)2);
		    if (iostat != 0) {
			goto L100004;
		    }
		    iostat = e_wsfe();
L100004:
		    ;
		}

/*              Check the IOSTAT code.  Afterall, that's why it's there. */

		if (iostat != 0) {
		    ioerr_("writing a variable to the output kernel file ", 
			    " ", &iostat, (ftnlen)45, (ftnlen)1);
		    sigerr_("SPICE(WRITEERROR)", (ftnlen)17);
		    chkout_("WRPOOL", (ftnlen)6);
		    return 0;
		}

/*              Blank out the output line so that we'll have */
/*              leading blanks for subsequent components of the */
/*              vector (if we are in fact writing one). */

		s_copy(line, " ", (ftnlen)132, (ftnlen)1);
	    }

/*           Get the next name for this node: */

	    nnode = nmpool[(i__2 = (nnode << 1) + 10) < 10018 && 0 <= i__2 ? 
		    i__2 : s_rnge("nmpool", i__2, "pool_", (ftnlen)2676)];
	}

/*        Get the next node (if there is one). */

    }

/*     Indicate the beginning of a text section. Data sections and */
/*     text sections must alternate, even if the text section is blank. */

    ci__1.cierr = 1;
    ci__1.ciunit = *unit;
    ci__1.cifmt = "(1X,A)";
    iostat = s_wsfe(&ci__1);
    if (iostat != 0) {
	goto L100005;
    }
    iostat = e_wsfe();
L100005:
    ci__1.cierr = 1;
    ci__1.ciunit = *unit;
    ci__1.cifmt = "(1X,A)";
    iostat = s_wsfe(&ci__1);
    if (iostat != 0) {
	goto L100006;
    }
    iostat = do_fio(&c__1, begtxt, (ftnlen)10);
    if (iostat != 0) {
	goto L100006;
    }
    iostat = e_wsfe();
L100006:
    if (iostat != 0) {
	ioerr_("writing a variable to the output kernel file ", " ", &iostat, 
		(ftnlen)45, (ftnlen)1);
	sigerr_("SPICE(WRITEERROR)", (ftnlen)17);
	chkout_("WRPOOL", (ftnlen)6);
	return 0;
    }
    chkout_("WRPOOL", (ftnlen)6);
    return 0;
/* $Procedure SWPOOL ( Set watch on a pool variable ) */

L_swpool:
/* $ Abstract */

/*     Add a name to the list of agents to notify whenever a member of */
/*     a list of kernel variables is updated. */

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

/*     KERNEL */

/* $ Keywords */

/*     CONSTANTS */
/*     FILES */

/* $ Declarations */

/*     CHARACTER*(*)         AGENT */
/*     INTEGER               NNAMES */
/*     CHARACTER*(*)         NAMES  ( * ) */

/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  -------------------------------------------------- */
/*     AGENT      I   The name of an agent to be notified after updates. */
/*     NNAMES     I   The number of variables to associate with AGENT. */
/*     NAMES      I   Variable names whose update causes the notice. */

/* $ Detailed_Input */

/*     AGENT       is the name of a routine or entry point (agency) that */
/*                 will want to know when a some variables in the kernel */
/*                 pool have been updated. */

/*     NNAMES      is the number of kernel pool variable names that will */
/*                 be associated with AGENT. */

/*     NAMES       is an array of names of variables in the kernel pool. */
/*                 Whenever any of these is updated, a notice will be */
/*                 posted for AGENT so that one can quickly check */
/*                 whether needed data has been modified. */

/* $ Detailed_Output */

/*     None. */

/* $ Parameters */

/*     None. */

/* $ Files */

/*     None. */

/* $ Exceptions */

/*     1) If sufficient room is not available to hold the name or */
/*        new agent, a routine in the calling tree for this routine */
/*        will signal an error. */

/* $ Particulars */

/*     The kernel pool is a convenient place to store a wide */
/*     variety of data needed by routines in SPICELIB and routines */
/*     that interface with SPICELIB routines.  However, when */
/*     a single name has a large quantity of data associated with */
/*     it, it becomes inefficient to constantly query the kernel */
/*     pool for values that are not updated on a frequent basis. */

/*     This entry point allows a routine to instruct the kernel pool */
/*     to post a message whenever a particular value gets updated. */
/*     In this way, a routine can quickly determine whether or not */
/*     data it requires has been updated since the last time the */
/*     data was accessed.  This makes it reasonable to buffer */
/*     the data in local storage and update it only when */
/*     a variable in the kernel pool that affects this data has */
/*     been updated. */

/*     Note that SWPOOL has a side effect.  Whenever a call to */
/*     SWPOOL is made, the agent specified in the calling sequence */
/*     is added to the list of agents that should be notified that */
/*     an update of its variables has occurred.  In other words */
/*     the code */

/*         CALL SWPOOL ( AGENT, NNAMES, NAMES  ) */
/*         CALL CVPOOL ( AGENT,         UPDATE ) */

/*     will always return UPDATE as .TRUE. */

/*     This feature allows for a slightly cleaner use of SWPOOL and */
/*     CVPOOL as shown in the example below.  Because SWPOOL */
/*     automatically loads AGENT into the list of agents to notify of */
/*     a kernel pool update, you do not have to include the code for */
/*     fetching the initial values of the kernel variables in the */
/*     initialization portion of a subroutine.  Instead, the code for */
/*     the first fetch from the pool is the same as the code for */
/*     fetching when the pool is updated. */

/* $ Examples */

/*     Suppose that you have an application subroutine, MYTASK, that */
/*     needs to access a large data set in the kernel pool.  If this */
/*     data could be kept in local storage and kernel pool queries */
/*     performed only when the data in the kernel pool has been */
/*     updated, the routine can perform much more efficiently. */

/*     The code fragment below illustrates how you might make use of this */
/*     feature. */

/*     C */
/*     C     On the first call to this routine establish those variables */
/*     C     that we will want to read from the kernel pool only when */
/*     C     new values have been established. */
/*     C */
/*           IF ( FIRST ) THEN */

/*              FIRST = .FALSE. */
/*              CALL SWPOOL ( 'MYTASK', NNAMES, NAMES ) */

/*           END IF */

/*      C */
/*      C    If any of the variables has been updated fetch */
/*      C    them from the kernel pool. (Note that this also */
/*      C    handles getting variables the for the first time.) */
/*      C */
/*           CALL CVPOOL ( 'MYTASK', UPDATE ) */

/*           IF ( UPDATE ) THEN */

/*              CALL RTPOOL ( 'MYTASK_VARIABLE_1', N1, VALS1, FOUND(1) ) */
/*              CALL RTPOOL ( 'MYTASK_VARIABLE_2', N2, VALS2, FOUND(2) ) */
/*                      . */
/*                      . */
/*                      . */
/*              CALL RTPOOL ( 'MYTASK_VARIABLE_N', NN, VALSN, FOUND(N) ) */

/*           END IF */

/*           IF ( FAILED() ) THEN */
/*                 . */
/*                 . */
/*              do something about the failure */
/*                 . */
/*                 . */

/*           END IF */


/* $ Restrictions */

/*     None. */

/* $ Literature_References */

/*     None. */

/* $ Author_and_Institution */

/*     W.L. Taber      (JPL) */

/* $ Version */

/* -    SPICELIB Version 8.0.0, 04-JUN-1999 (WLT) */

/*        Added the entry points PCPOOL, PDPOOL and PIPOOL to allow */
/*        direct insertion of data into the kernel pool without having */
/*        to read an external file. */

/*        Added the interface LMPOOL that allows SPICE */
/*        programs to load text kernels directly from memory */
/*        instead of requiring a text file. */

/*        Added the entry point SZPOOL to return kernel pool definition */
/*        parameters. */

/*        Added the entry point DVPOOL to allow the removal of a variable */
/*        from the kernel pool. */

/*        Added the entry point GNPOOL to allow users to determine */
/*        variables that are present in the kernel pool */

/* -    SPICELIB Version 7.0.0, 20-SEP-1995 (WLT) */

/*        The implementation of the kernel pool was completely redone */
/*        to improve performance in loading and fetching data.  In */
/*        addition the pool was upgraded so that variables may be */
/*        either string or numeric valued. */

/* -    SPICELIB Version 6.0.0, 31-MAR-1992 (WLT) */

/*        The entry points SWPOOL and CVPOOL were added. */

/* -& */
/* $ Index_Entries */

/*     Watch for an update to a kernel pool variable */
/*     Notify a routine of an update to a kernel pool variable */
/* -& */
/* $ Revisions */

/*        The implementation of the kernel pool was completely redone */
/*        to improve performance in loading and fetching data.  In */
/*        addition the pool was upgraded so that variables may be */
/*        either string or numeric valued. */

/*        The basic data structure used to maintain the list of */
/*        variable names and values was replaced with a hash table */
/*        implementation.  Data and names are accessed by means */
/*        of a hash function and linked lists of pointers to exising */
/*        variable names and data values. */

/* -    SPICELIB Version 6.0.0, 31-MAR-1992 (WLT) */

/*        The entry points SWPOOL (set watch on a pool variable) */
/*        and CVPOOL (check variable for update) so that routines */
/*        that buffer data stored in the kernel pool can fetch */
/*        that data only when it is updated. */

/*        In addition, the revision history was upgraded so that the */
/*        version number increases over time.  This wasn't true */
/*        before. In addition some early revision data that referred to */
/*        pre-SPICELIB modifications were removed. This editing of */
/*        the version numbers makes it unlikely that anyone can track */
/*        down which previous version of this routine they have by */
/*        looking at the version number.  The best way to determine */
/*        the routine you had previously is to compare the dates */
/*        stored in the Version line of the routine. */


/* -& */

/*     Standard SPICE error handling. */

    if (return_()) {
	return 0;
    } else {
	chkin_("SWPOOL", (ftnlen)6);
    }

/*     Initialize the pool if necessary. */

    zzpini_(&first, &c__5003, &c__40000, &c__4000, begdat, begtxt, nmpool, 
	    dppool, chpool, namlst, datlst, &c__1000, &c__2000, watsym, 
	    watptr, watval, agents, active, notify, (ftnlen)10, (ftnlen)10, (
	    ftnlen)32, (ftnlen)32, (ftnlen)32, (ftnlen)32, (ftnlen)32);

/*     For each variable specified by the array NAMES, put AGENT */
/*     into its list of guys to be notified when a variable change */
/*     occurs. */

    i__2 = *nnames;
    for (i__ = 1; i__ <= i__2; ++i__) {

/*        Get the agents associated with NAMES(I). */

	sygetc_(names + (i__ - 1) * names_len, watsym, watptr, watval, &
		nfetch, active + 192, &got, names_len, (ftnlen)32, (ftnlen)32,
		 (ftnlen)32);
	if (got) {
	    noagnt = bsrchc_(agent, &nfetch, active + 192, agent_len, (ftnlen)
		    32) == 0;
	} else {
	    noagnt = TRUE_;
	}

/*        If we didn't find this agent in the list of agents for this */
/*        name, put him in and then sort the list of agents for */
/*        this name (NAMES(I)). */

	if (noagnt && cardc_(active, (ftnlen)32) < 1000) {
	    sypshc_(names + (i__ - 1) * names_len, agent, watsym, watptr, 
		    watval, names_len, agent_len, (ftnlen)32, (ftnlen)32);
	    syordc_(names + (i__ - 1) * names_len, watsym, watptr, watval, 
		    names_len, (ftnlen)32, (ftnlen)32);
	} else if (noagnt) {
	    setmsg_("The list of agents to notify when # is updated is too b"
		    "ig.  The maximum number of agents that any kernel pool v"
		    "ariable can activate is ?.", (ftnlen)137);
	    errch_("#", names + (i__ - 1) * names_len, (ftnlen)1, names_len);
	    errint_("?", &c__1000, (ftnlen)1);
	    sigerr_("SPICE(TOOMANYAGENTS)", (ftnlen)20);
	    chkout_("SWPOOL", (ftnlen)6);
	    return 0;
	}
    }

/*     We ALWAYS put this agent into the list of agents to be notified. */

    insrtc_(agent, agents, agent_len, (ftnlen)32);

/*     That is all. */

    chkout_("SWPOOL", (ftnlen)6);
    return 0;
/* $Procedure CVPOOL ( Check variable in the pool for update) */

L_cvpool:
/* $ Abstract */

/*     Determine whether or not any of the variables that are to */
/*     be watched and have AGENT on their distribution list have been */
/*     updated. */

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

/*     KERNEL */

/* $ Keywords */

/*     SYMBOLS */
/*     UTILITY */

/* $ Declarations */

/*     CHARACTER*(*)         AGENT */
/*     LOGICAL               UPDATE */

/* $ Brief_I/O */

/*     Variable  I/O  Description */
/*     --------  ---  -------------------------------------------------- */
/*     AGENT      I   Name of the agent to check for notices. */
/*     UPDATE     O   .TRUE. if variables for AGENT have been updated. */

/* $ Detailed_Input */

/*     AGENT     is the name of a subroutine, entry point, or significant */
/*               portion of code that needs to access variables in the */
/*               kernel pool.  Generally this agent will buffer these */
/*               variables internally and fetch them from the kernel */
/*               pool only when they are updated. */

/* $ Detailed_Output */

/*     UPDATE    is a logical flag that will be set to true if the */
/*               variables in the kernel pool that are required by */
/*               AGENT have been updated since the last call to CVPOOL. */

/* $ Parameters */

/*     See the umbrella subroutine POOL. */

/* $ Exceptions */

/*     None. */

/* $ Files */

/*     None. */

/* $ Particulars */

/*     This entry point allows the calling program to determine */
/*     whether or not variables associated with with AGENT have */
/*     been updated.  Making use of this entry point in conjunction */
/*     with the entry point SWPOOL (set watch on pool variables) */
/*     modules can buffer kernel pool variables they need and */
/*     fetch values from the kernel pool only when variables have */
/*     been updated. */

/*     Note that the call to CVPOOL has a side effect. */
/*     Two consecutive calls to CVPOOL with the same */
/*     AGENT will always result in the UPDATE being .FALSE. */
/*     on the second call.  In other words, if you imbed */
/*     the following two lines of code in a piece of code */

/*                  CALL CVPOOL ( AGENT, UPDATE ) */
/*                  CALL CVPOOL ( AGENT, UPDATE ) */

/*     and then test UPDATE, it will be FALSE.  The idea is */
/*     that once a call to CVPOOL has been made, the */
/*     kernel pool has performed its duty and notified the */
/*     calling routine that one of the AGENT's variables */
/*     has been updated.  Consequently, on the second call */
/*     to CVPOOL above, the kernel pool will not have any */
/*     updates to report about any of AGENT's variables. */

/*     If, on the other hand, you have code such as */

/*                  CALL CVPOOL ( AGENT, UPDATE ) */
/*                  CALL LDPOOL ( 'MYFILE.DAT'  ) */
/*                  CALL CVPOOL ( AGENT, UPDATE ) */

/*     the value of UPDATE will be true if one of the variables */
/*     associated with AGENT was updated by the call to */
/*     LDPOOL (and that variable has been specified as one */
/*     to watch by call a call to SWPOOL). */

/*     It should also be noted that any call to CVPOOL that */
/*     occurs immediately after a call to SWPOOL will result in */
/*     UPDATE being returned as .TRUE.  In other words, code */
/*     such as shown below, will always result in the value */
/*     of UPDATE as being returned .TRUE. */

/*                  CALL SWPOOL ( AGENT, NNAMES, NAMES  ) */
/*                  CALL CVPOOL ( AGENT,         UPDATE ) */

/*     See the header for SWPOOL for a full discussion of this */
/*     feature. */

/* $ Examples */

/*     Suppose that you have an application subroutine, MYTASK, that */
/*     needs to access a large data set in the kernel pool.  If this */
/*     data could be kept in local storage and kernel pool queries */
/*     performed only when the data in the kernel pool has been */
/*     updated, the routine can perform much more efficiently. */

/*     The code fragment below illustrates how you might make use of this */
/*     feature. */

/*     C */
/*     C     On the first call to this routine establish those variables */
/*     C     that we will want to read from the kernel pool only when */
/*     C     new values have been established. */
/*     C */
/*           IF ( FIRST ) THEN */

/*              FIRST = .FALSE. */

/*              CALL SWPOOL ( 'MYTASK', NNAMES, NAMES ) */

/*           END IF */

/*      C */
/*      C    If any of the variables has been updated fetch */
/*      C    them from the kernel pool. */
/*      C */
/*           CALL CVPOOL ( 'MYTASK', UPDATE ) */

/*           IF ( UPDATE ) THEN */

/*              CALL RTPOOL ( 'MYTASK_VARIABLE_1', N1, VALS1, FOUND(1) ) */
/*              CALL RTPOOL ( 'MYTASK_VARIABLE_2', N2, VALS2, FOUND(2) ) */
/*                      . */
/*                      . */
/*                      . */
/*              CALL RTPOOL ( 'MYTASK_VARIABLE_N', NN, VALSN, FOUND(N) ) */

/*           END IF */

/* $ Restrictions */

/*     None. */

/* $ Literature_References */

/*     None. */

/* $ Author_and_Institution */

/*     W.L. Taber     (JPL) */

/* $ Version */


/* -    SPICELIB Version 8.0.0, 04-JUN-1999 (WLT) */

/*        Added the entry points PCPOOL, PDPOOL and PIPOOL to allow */
/*        direct insertion of data into the kernel pool without having */
/*        to read an external file. */

/*        Added the interface LMPOOL that allows SPICE */
/*        programs to load text kernels directly from memory */
/*        instead of requiring a text file. */

/*        Added the entry point SZPOOL to return kernel pool definition */
/*        parameters. */

/*        Added the entry point DVPOOL to allow the removal of a variable */
/*        from the kernel pool. */

/*        Added the entry point GNPOOL to allow users to determine */
/*        variables that are present in the kernel pool */

/* -    SPICELIB Version 7.0.0, 20-SEP-1995 (WLT) */

/*        The implementation of the kernel pool was completely redone */
/*        to improve performance in loading and fetching data.  In */
/*        addition the pool was upgraded so that variables may be */
/*        either string or numeric valued. */

/* -    SPICELIB Version 6.0.0, 31-MAR-1992 (WLT) */

/*        The entry points SWPOOL and CVPOOL were added. */

/* -& */
/* $ Index_Entries */

/*     Check the kernel pool for updated variables */

/* -& */
/* $ Revisions */

/*        The implementation of the kernel pool was completely redone */
/*        to improve performance in loading and fetching data.  In */
/*        addition the pool was upgraded so that variables may be */
/*        either string or numeric valued. */

/*        The basic data structure used to maintain the list of */
/*        variable names and values was replaced with a hash table */
/*        implementation.  Data and names are accessed by means */
/*        of a hash function and linked lists of pointers to exising */
/*        variable names and data values. */

/* -    SPICELIB Version 6.0.0, 31-MAR-1992 (WLT) */

/*        The entry points SWPOOL (set watch on a pool variable) */
/*        and CVPOOL (check variable for update) so that routines */
/*        that buffer data stored in the kernel pool can fetch */
/*        that data only when it is updated. */

/*        In addition, the revision history was upgraded so that the */
/*        version number increases over time.  This wasn't true */
/*        before. In addition some early revision data that referred to */
/*        pre-SPICELIB modifications were removed. This editing of */
/*        the version numbers makes it unlikely that anyone can track */
/*        down which previous version of this routine they have by */
/*        looking at the version number.  The best way to determine */
/*        the routine you had previously is to compare the dates */
/*        stored in the Version line of the routine. */

/* -& */

/*     Standard SPICE error handling. */

    if (return_()) {
	return 0;
    } else {
	chkin_("CVPOOL", (ftnlen)6);
    }

/*     Initialize the pool if necessary. */

    zzpini_(&first, &c__5003, &c__40000, &c__4000, begdat, begtxt, nmpool, 
	    dppool, chpool, namlst, datlst, &c__1000, &c__2000, watsym, 
	    watptr, watval, agents, active, notify, (ftnlen)10, (ftnlen)10, (
	    ftnlen)32, (ftnlen)32, (ftnlen)32, (ftnlen)32, (ftnlen)32);

/*     Check to see if our agent is on the list of agents to be */
/*     notified.  If it is, we take this agent off the list---he's */
/*     now considered to have been notified. */

    *update = elemc_(agent, agents, agent_len, (ftnlen)32);
    if (*update) {
	removc_(agent, agents, agent_len, (ftnlen)32);
    }
    chkout_("CVPOOL", (ftnlen)6);
    return 0;
/* $Procedure      GCPOOL (Get character data from the kernel pool) */

L_gcpool:
/* $ Abstract */

/*     Return the character value of a kernel variable from the */
/*     kernel pool. */

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

/*     KERNEL */

/* $ Keywords */

/*     CONSTANTS */
/*     FILES */

/* $ Declarations */

/*     CHARACTER*(*)         NAME */
/*     INTEGER               START */
/*     INTEGER               ROOM */
/*     INTEGER               N */
/*     CHARACTER*(*)         CVALS    ( * ) */
/*     LOGICAL               FOUND */

/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  -------------------------------------------------- */
/*     NAME       I   Name of the variable whose value is to be returned. */
/*     START      I   Which component to start retrieving for NAME */
/*     ROOM       I   The largest number of values to return. */
/*     N          O   Number of values returned for NAME. */
/*     CVALS      O   Values associated with NAME. */
/*     FOUND      O   True if variable is in pool. */

/* $ Detailed_Input */

/*     NAME       is the name of the variable whose values are to be */
/*                returned. If the variable is not in the pool with */
/*                character type, FOUND will be FALSE. */

/*     START      is the index of the first component of NAME to return. */
/*                If START is less than 1, it will be treated as 1.  If */
/*                START is greater than the total number of components */
/*                available for NAME, no values will be returned (N will */
/*                be set to zero).  However, FOUND will still be set to */
/*                .TRUE. */

/*     ROOM       is the maximum number of components that should be */
/*                returned for this variable.  (Usually it is the amount */
/*                of ROOM available in the array CVALS). If ROOM is */
/*                less than 1 the error 'SPICE(BADARRAYSIZE)' will be */
/*                signaled. */

/* $ Detailed_Output */

/*     N          is the number of values associated with NAME that */
/*                are returned.  It will always be less than or equal */
/*                to ROOM. */

/*                If NAME is not in the pool with character type, no */
/*                value is given to N. */

/*     CVALS      is the array of values associated with NAME. */
/*                If NAME is not in the pool with character type, no */
/*                values are given to the elements of CVALS. */

/*                If the length of CVALS is less than the length of */
/*                strings stored in the kernel pool (see MAXCHR) the */
/*                values returned will be truncated on the right. */

/*     FOUND      is TRUE if the variable is in the pool and has */
/*                character type, FALSE if it is not. */

/* $ Parameters */

/*     None. */

/* $ Exceptions */

/*     1) If the value of ROOM is less than one the error */
/*        'SPICE(BADARRAYSIZE)' is signaled. */

/*     2) If CVALS has declared length less than the size of a */
/*        string to be returned, the value will be truncated on */
/*        the right.  See MAXCHR for the maximum stored size of */
/*        string variables. */

/* $ Files */

/*     None. */

/* $ Particulars */

/*     This routine provides the user interface to retrieving */
/*     character data stored in the kernel pool.  This interface */
/*     allows you to retrieve the data associated with a variable */
/*     in multiplce accesses.  Under some circumstances this alleviates */
/*     the problem of having to know in advance the maximum amount */
/*     of space needed to accommodate all kernel variables. */

/*     However, this method of access does come with a price. It is */
/*     always more efficient to retrieve all of the data associated */
/*     with a kernel pool data in one call than it is to retrieve */
/*     it in sections. */

/*     See also the entry points GDPOOL and GIPOOL. */

/* $ Examples */


/*     The following code fragment demonstrates how the data stored */
/*     in a kernel pool variable can be retrieved in pieces. */

/*     First we need some declarations. */

/*        INTEGER               ROOM */
/*        PARAMETER           ( ROOM = 3 ) */

/*        CHARACTER*(8)         VARNAM */
/*        CHARACTER*(3)         INDENT */
/*        INTEGER               START */
/*        INTEGER               N */
/*        LOGICAL               FOUND */
/*        CHARACTER*(80)        CVALS(ROOM) */


/*     Next load the data in the file 'typical.ker' into the */
/*     kernel pool. */

/*        CALL LDPOOL ( 'typical.ker' ) */

/*     Next we shall print the values stored for the kernel pool */
/*     variable 'MYDATA' */

/*        VARNAM = 'MYDATA' */
/*        INDENT = ' ' */
/*        START  =  1 */

/*        CALL GCPOOL ( VARNAM, START, ROOM, N, CVALS, FOUND ) */

/*        IF ( .NOT. FOUND ) */
/*           WRITE (*,*) 'There is no string data available for MYDATA.' */
/*        ELSE */

/*           WRITE (*,*) 'Values for MYDATA.' */
/*           WRITE (*,*) */

/*           DO I = 1, N */
/*              WRITE (*,*) INDENT, CVALS(I) */
/*           END DO */

/*           DO WHILE ( N .EQ. ROOM ) */

/*              START = START + N */
/*              CALL GCPOOL ( VARNAM, START, ROOM, N, CVALS, FOUND ) */

/*              DO I = 1, N */
/*                 WRITE (*,*) INDENT, CVALS(I) */
/*              END DO */

/*           END DO */

/*        END IF */

/* $ Restrictions */

/*     None. */

/* $ Literature_References */

/*     None. */

/* $ Author_and_Institution */

/*     W.L. Taber  (JPL) */

/* $ Version */

/* -    SPICELIB Version 8.0.1, 22-DEC-2004 (NJB) */

/*        Corrected an in-line comment relating to finding the */
/*        head node of the conflict resolution list for NAME. */

/* -    SPICELIB Version 8.0.0, 04-JUN-1999 (WLT) */

/*        Added the entry points PCPOOL, PDPOOL and PIPOOL to allow */
/*        direct insertion of data into the kernel pool without having */
/*        to read an external file. */

/*        Added the interface LMPOOL that allows SPICE */
/*        programs to load text kernels directly from memory */
/*        instead of requiring a text file. */

/*        Added the entry point SZPOOL to return kernel pool definition */
/*        parameters. */

/*        Added the entry point DVPOOL to allow the removal of a variable */
/*        from the kernel pool. */

/*        Added the entry point GNPOOL to allow users to determine */
/*        variables that are present in the kernel pool */

/* -    SPICELIB Version 7.0.0, 20-SEP-1995 (WLT) */

/*        The implementation of the kernel pool was completely redone */
/*        to improve performance in loading and fetching data.  In */
/*        addition the pool was upgraded so that variables may be */
/*        either string or numeric valued. */

/*        The entry points GCPOOL, GDPOOL, GIPOOL and DTPOOL were added */
/*        to the routine. */

/* -& */
/* $ Index_Entries */

/*     RETURN the character value of a pooled kernel variable */
/*     RETURN the string value of a pooled kernel variable */

/* -& */

/*     Standard SPICE error handling. */

    if (return_()) {
	return 0;
    } else {
	chkin_("GCPOOL", (ftnlen)6);
    }

/*     Initialize the pool if necessary. */

    zzpini_(&first, &c__5003, &c__40000, &c__4000, begdat, begtxt, nmpool, 
	    dppool, chpool, namlst, datlst, &c__1000, &c__2000, watsym, 
	    watptr, watval, agents, active, notify, (ftnlen)10, (ftnlen)10, (
	    ftnlen)32, (ftnlen)32, (ftnlen)32, (ftnlen)32, (ftnlen)32);

/*     Perform the one obvious error check first. */

    if (*room < 1) {
	setmsg_("The amount of room specified as available for output in the"
		" output array was: #.  The amount of room must be positive. ",
		 (ftnlen)119);
	errint_("#", room, (ftnlen)1);
	sigerr_("SPICE(BADARRAYSIZE)", (ftnlen)19);
	chkout_("GCPOOL", (ftnlen)6);
	return 0;
    }

/*     Compute the hash value of this name. */

    lookat = zzhash_(name__, name_len);

/*     Now see if there is a non-empty conflict resolution list for the */
/*     input string NAME.  If so, NAMLST(LOOKAT) contains the head node */
/*     of the conflict resolution list; this node is a postive value. */

    if (namlst[(i__2 = lookat - 1) < 5003 && 0 <= i__2 ? i__2 : s_rnge("naml"
	    "st", i__2, "pool_", (ftnlen)3652)] == 0) {
	*found = FALSE_;
	chkout_("GCPOOL", (ftnlen)6);
	return 0;
    }

/*     If were are still here NAMLST(LOOKAT) is the first node of */
/*     a conflict resolution list.  See if the NAME corresposnding */
/*     to this node is the one we are looking for. */

    node = namlst[(i__2 = lookat - 1) < 5003 && 0 <= i__2 ? i__2 : s_rnge(
	    "namlst", i__2, "pool_", (ftnlen)3664)];
    succes = s_cmp(name__, pnames + (((i__2 = node - 1) < 5003 && 0 <= i__2 ? 
	    i__2 : s_rnge("pnames", i__2, "pool_", (ftnlen)3665)) << 5), 
	    name_len, (ftnlen)32) == 0;
    while(! succes) {
	node = nmpool[(i__2 = (node << 1) + 10) < 10018 && 0 <= i__2 ? i__2 : 
		s_rnge("nmpool", i__2, "pool_", (ftnlen)3669)];
	if (node < 0) {
	    *found = FALSE_;
	    chkout_("GCPOOL", (ftnlen)6);
	    return 0;
	}
	succes = s_cmp(name__, pnames + (((i__2 = node - 1) < 5003 && 0 <= 
		i__2 ? i__2 : s_rnge("pnames", i__2, "pool_", (ftnlen)3679)) 
		<< 5), name_len, (ftnlen)32) == 0;
    }

/*     If you get to this point, the variable NAME is present in the */
/*     list of names at PNAMES(NODE), ABS( DATLST(NODE) ) points to the */
/*     head of a linked list of values for this NAME. */

    datahd = datlst[(i__2 = node - 1) < 5003 && 0 <= i__2 ? i__2 : s_rnge(
	    "datlst", i__2, "pool_", (ftnlen)3687)];
    if (datahd > 0) {
	*n = 0;
	*found = FALSE_;
	chkout_("GCPOOL", (ftnlen)6);
	return 0;
    } else if (datahd == 0) {
	setmsg_("This is never supposed to happen.  The requested name, '#',"
		" was found in the name list, but the pointer to the head of "
		"the data for this variable is zero. Please note your activit"
		"ies and report this error to NAIF. ", (ftnlen)214);
	errch_("#", name__, (ftnlen)1, rtrim_(name__, name_len));
	sigerr_("SPICE(BUG)", (ftnlen)10);
	chkout_("GCPOOL", (ftnlen)6);
	return 0;
    }
    *found = TRUE_;
    k = 0;
    *n = 0;
    begin = max(*start,1);
    node = -datahd;
    while(node > 0) {
	++k;
	if (k >= begin) {
	    ++(*n);
	    s_copy(cvals + (*n - 1) * cvals_len, chvals + ((i__2 = node - 1) <
		     4000 && 0 <= i__2 ? i__2 : s_rnge("chvals", i__2, "pool_"
		    , (ftnlen)3723)) * 80, cvals_len, (ftnlen)80);
	    if (*n == *room) {
		chkout_("GCPOOL", (ftnlen)6);
		return 0;
	    }
	}
	node = chpool[(i__2 = (node << 1) + 10) < 8012 && 0 <= i__2 ? i__2 : 
		s_rnge("chpool", i__2, "pool_", (ftnlen)3732)];
    }
    chkout_("GCPOOL", (ftnlen)6);
    return 0;
/* $Procedure      GDPOOL (Get d.p. values from the kernel pool) */

L_gdpool:
/* $ Abstract */

/*     Return the d.p. value of a kernel variable from the kernel pool. */

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

/*     KERNEL */

/* $ Keywords */

/*     CONSTANTS */
/*     FILES */

/* $ Declarations */

/*     CHARACTER*(*)         NAME */
/*     INTEGER               START */
/*     INTEGER               ROOM */
/*     INTEGER               N */
/*     DOUBLE PRECISION      VALUES   ( * ) */
/*     LOGICAL               FOUND */

/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  -------------------------------------------------- */
/*     NAME       I   Name of the variable whose value is to be returned. */
/*     START      I   Which component to start retrieving for NAME */
/*     ROOM       I   The largest number of values to return. */
/*     N          O   Number of values returned for NAME. */
/*     VALUES     O   Values associated with NAME. */
/*     FOUND      O   True if variable is in pool. */

/* $ Detailed_Input */

/*     NAME       is the name of the variable whose values are to be */
/*                returned. If the variable is not in the pool with */
/*                numeric type, FOUND will be FALSE. */

/*     START      is the index of the first component of NAME to return. */
/*                If START is less than 1, it will be treated as 1.  If */
/*                START is greater than the total number of components */
/*                available for NAME, no values will be returned (N will */
/*                be set to zero).  However, FOUND will still be set to */
/*                .TRUE. */

/*     ROOM       is the maximum number of components that should be */
/*                returned for this variable.  (Usually it is the amount */
/*                of ROOM available in the array VALUES). If ROOM is */
/*                less than 1 the error 'SPICE(BADARRAYSIZE)' will be */
/*                signaled. */

/* $ Detailed_Output */

/*     N          is the number of values associated with NAME that */
/*                are returned.  It will always be less than or equal */
/*                to ROOM. */

/*                If NAME is not in the pool with numeric type, no value */
/*                is given to N. */

/*     VALUES     is the array of values associated with NAME. */
/*                If NAME is not in the pool with numeric type, no */
/*                values are given to the elements of VALUES. */

/*     FOUND      is TRUE if the variable is in the pool and has numeric */
/*                type, FALSE if it is not. */

/* $ Parameters */

/*     None. */

/* $ Exceptions */

/*     1) If the value of ROOM is less than one the error */
/*        'SPICE(BADARRAYSIZE)' is signaled. */


/* $ Files */

/*     None. */

/* $ Particulars */

/*     This routine provides the user interface to retrieving */
/*     numeric data stored in the kernel pool.  This interface */
/*     allows you to retrieve the data associated with a variable */
/*     in multiplce accesses.  Under some circumstances this alleviates */
/*     the problem of having to know in advance the maximum amount */
/*     of space needed to accommodate all kernel variables. */

/*     However, this method of access does come with a price. It is */
/*     always more efficient to retrieve all of the data associated */
/*     with a kernel pool data in one call than it is to retrieve */
/*     it in sections. */

/*     This routine should be used in place of RTPOOL when possible */
/*     as it avoids errors associated with writing data past the */
/*     end of an array. */

/*     See also the entry points GIPOOL and GCPOOL. */

/* $ Examples */


/*     The following code fragment demonstrates how the data stored */
/*     in a kernel pool variable can be retrieved in pieces. */

/*     First we need some declarations. */

/*        INTEGER               ROOM */
/*        PARAMETER           ( ROOM = 3 ) */

/*        CHARACTER*(8)         VARNAM */
/*        CHARACTER*(3)         INDENT */
/*        INTEGER               START */
/*        INTEGER               N */
/*        LOGICAL               FOUND */
/*        DOUBLE PRECISION      VALUES(ROOM) */


/*     Next load the data in the file 'typical.ker' into the */
/*     kernel pool. */



/*        CALL LDPOOL ( 'typical.ker' ) */

/*     Next we shall print the values stored for the kernel pool */
/*     variable 'MYDATA' */

/*        VARNAM = 'MYDATA' */
/*        INDENT = ' ' */
/*        START  =  1 */

/*        CALL GDPOOL ( VARNAM, START, ROOM, N, VALUES, FOUND ) */

/*        IF ( .NOT. FOUND ) */
/*           WRITE (*,*) 'There is no numeric data available for MYDATA.' */
/*        ELSE */

/*           WRITE (*,*) 'Values for MYDATA.' */
/*           WRITE (*,*) */

/*           DO I = 1, N */
/*              WRITE (*,*) INDENT, VALUES(I) */
/*           END DO */

/*           DO WHILE ( N .EQ. ROOM ) */

/*              START = START + N */
/*              CALL GDPOOL ( VARNAM, START, ROOM, N, VALUES, FOUND ) */

/*              DO I = 1, N */
/*                 WRITE (*,*) INDENT, VALUES(I) */
/*              END DO */

/*           END DO */

/*        END IF */


/* $ Restrictions */

/*     None. */

/* $ Literature_References */

/*     None. */

/* $ Author_and_Institution */

/*     W.L. Taber  (JPL) */

/* $ Version */

/* -    SPICELIB Version 8.0.1, 22-DEC-2004 (NJB) */

/*        Corrected an in-line comment relating to finding the */
/*        head node of the conflict resolution list for NAME. */

/* -    SPICELIB Version 8.0.0, 04-JUN-1999 (WLT) */

/*        Added the entry points PCPOOL, PDPOOL and PIPOOL to allow */
/*        direct insertion of data into the kernel pool without having */
/*        to read an external file. */

/*        Added the interface LMPOOL that allows SPICE */
/*        programs to load text kernels directly from memory */
/*        instead of requiring a text file. */

/*        Added the entry point SZPOOL to return kernel pool definition */
/*        parameters. */

/*        Added the entry point DVPOOL to allow the removal of a variable */
/*        from the kernel pool. */

/*        Added the entry point GNPOOL to allow users to determine */
/*        variables that are present in the kernel pool */

/* -    SPICELIB Version 7.0.0, 20-SEP-1995 (WLT) */

/*        The implementation of the kernel pool was completely redone */
/*        to improve performance in loading and fetching data.  In */
/*        addition the pool was upgraded so that variables may be */
/*        either string or numeric valued. */

/*        The entry points GCPOOL, GDPOOL, GIPOOL and DTPOOL were added */
/*        to the routine. */

/* -& */
/* $ Index_Entries */

/*     RETURN the d.p. value of a pooled kernel variable */
/*     RETURN the numeric value of a pooled kernel variable */

/* -& */

/*     Standard SPICE error handling. */

    if (return_()) {
	return 0;
    } else {
	chkin_("GDPOOL", (ftnlen)6);
    }

/*     Initialize the pool if necessary. */

    zzpini_(&first, &c__5003, &c__40000, &c__4000, begdat, begtxt, nmpool, 
	    dppool, chpool, namlst, datlst, &c__1000, &c__2000, watsym, 
	    watptr, watval, agents, active, notify, (ftnlen)10, (ftnlen)10, (
	    ftnlen)32, (ftnlen)32, (ftnlen)32, (ftnlen)32, (ftnlen)32);

/*     Perform the one obvious error check first. */

    if (*room < 1) {
	setmsg_("The amount of room specified as available for output in the"
		" output array was: #.  The amount of room must be positive. ",
		 (ftnlen)119);
	errint_("#", room, (ftnlen)1);
	sigerr_("SPICE(BADARRAYSIZE)", (ftnlen)19);
	chkout_("GDPOOL", (ftnlen)6);
	return 0;
    }

/*     Compute the hash value of this name. */

    lookat = zzhash_(name__, name_len);

/*     Now see if there is a non-empty conflict resolution list for the */
/*     input string NAME.  If so, NAMLST(LOOKAT) contains the head node */
/*     of the conflict resolution list; this node is a postive value. */

    if (namlst[(i__2 = lookat - 1) < 5003 && 0 <= i__2 ? i__2 : s_rnge("naml"
	    "st", i__2, "pool_", (ftnlen)4044)] == 0) {
	*found = FALSE_;
	chkout_("GDPOOL", (ftnlen)6);
	return 0;
    }

/*     If were are still here NAMLST(LOOKAT) is the first node of */
/*     a conflict resolution list.  See if the NAME corresposnding */
/*     to this node is the one we are looking for. */

    node = namlst[(i__2 = lookat - 1) < 5003 && 0 <= i__2 ? i__2 : s_rnge(
	    "namlst", i__2, "pool_", (ftnlen)4056)];
    succes = s_cmp(name__, pnames + (((i__2 = node - 1) < 5003 && 0 <= i__2 ? 
	    i__2 : s_rnge("pnames", i__2, "pool_", (ftnlen)4057)) << 5), 
	    name_len, (ftnlen)32) == 0;
    while(! succes) {
	node = nmpool[(i__2 = (node << 1) + 10) < 10018 && 0 <= i__2 ? i__2 : 
		s_rnge("nmpool", i__2, "pool_", (ftnlen)4061)];
	if (node < 0) {
	    *found = FALSE_;
	    chkout_("GDPOOL", (ftnlen)6);
	    return 0;
	}
	succes = s_cmp(name__, pnames + (((i__2 = node - 1) < 5003 && 0 <= 
		i__2 ? i__2 : s_rnge("pnames", i__2, "pool_", (ftnlen)4071)) 
		<< 5), name_len, (ftnlen)32) == 0;
    }

/*     If you get to this point, the variable NAME is present in the */
/*     list of names at PNAMES(NODE), ABS( DATLST(NODE) ) points to the */
/*     head of a linked list of values for this NAME. */

    datahd = datlst[(i__2 = node - 1) < 5003 && 0 <= i__2 ? i__2 : s_rnge(
	    "datlst", i__2, "pool_", (ftnlen)4079)];
    if (datahd < 0) {
	*n = 0;
	*found = FALSE_;
	chkout_("GDPOOL", (ftnlen)6);
	return 0;
    } else if (datahd == 0) {
	setmsg_("This is never supposed to happen.  The requested name, '#',"
		" was found in the name list, but the pointer to the head of "
		"the data for this variable is zero. Please note your activit"
		"ies and report this error to NAIF. ", (ftnlen)214);
	errch_("#", name__, (ftnlen)1, rtrim_(name__, name_len));
	sigerr_("SPICE(BUG)", (ftnlen)10);
	chkout_("GDPOOL", (ftnlen)6);
	return 0;
    }
    *found = TRUE_;
    k = 0;
    *n = 0;
    begin = max(*start,1);
    node = datahd;
    while(node > 0) {
	++k;
	if (k >= begin) {
	    ++(*n);
	    values[*n - 1] = dpvals[(i__2 = node - 1) < 40000 && 0 <= i__2 ? 
		    i__2 : s_rnge("dpvals", i__2, "pool_", (ftnlen)4115)];
	    if (*n == *room) {
		chkout_("GDPOOL", (ftnlen)6);
		return 0;
	    }
	}
	node = dppool[(i__2 = (node << 1) + 10) < 80012 && 0 <= i__2 ? i__2 : 
		s_rnge("dppool", i__2, "pool_", (ftnlen)4124)];
    }
    chkout_("GDPOOL", (ftnlen)6);
    return 0;
/* $Procedure      GIPOOL (Get integers from the kernel pool) */

L_gipool:
/* $ Abstract */

/*     Return the integer value of a kernel variable from the */
/*     kernel pool. */

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

/*     KERNEL */

/* $ Keywords */

/*     CONSTANTS */
/*     FILES */

/* $ Declarations */

/*     CHARACTER*(*)         NAME */
/*     INTEGER               START */
/*     INTEGER               ROOM */
/*     INTEGER               N */
/*     INTEGER               IVALS    ( * ) */
/*     LOGICAL               FOUND */

/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  -------------------------------------------------- */
/*     NAME       I   Name of the variable whose value is to be returned. */
/*     START      I   Which component to start retrieving for NAME */
/*     ROOM       I   The largest number of values to return. */
/*     N          O   Number of values returned for NAME. */
/*     IVALS      O   Values associated with NAME. */
/*     FOUND      O   True if variable is in pool. */

/* $ Detailed_Input */

/*     NAME       is the name of the variable whose values are to be */
/*                returned. If the variable is not in the pool with */
/*                numeric type, FOUND will be FALSE. */

/*     START      is the index of the first component of NAME to return. */
/*                If START is less than 1, it will be treated as 1.  If */
/*                START is greater than the total number of components */
/*                available for NAME, no values will be returned (N will */
/*                be set to zero).  However, FOUND will still be set to */
/*                .TRUE. */

/*     ROOM       is the maximum number of components that should be */
/*                returned for this variable.  (Usually it is the amount */
/*                of ROOM available in the array IVALS). If ROOM is */
/*                less than 1 the error 'SPICE(BADARRAYSIZE)' will be */
/*                signaled. */

/* $ Detailed_Output */

/*     N          is the number of values associated with NAME that */
/*                are returned.  It will always be less than or equal */
/*                to ROOM. */

/*                If NAME is not in the pool with numeric type, no value */
/*                is given to N. */

/*     IVALS      is the array of values associated with NAME. */
/*                If NAME is not in the pool with numeric type, no */
/*                values are given to the elements of IVALS. */

/*     FOUND      is TRUE if the variable is in the pool and has numeric */
/*                type, FALSE if it is not. */

/* $ Parameters */

/*     None. */

/* $ Exceptions */

/*     1) If the value of ROOM is less than one the error */
/*        'SPICE(BADARRAYSIZE)' is signaled. */

/*     2) If a value requested is outside the valid range */
/*        of integers, the error 'SPICE(INTOUTOFRANGE)' is signaled. */


/* $ Files */

/*     None. */

/* $ Particulars */

/*     This routine provides the user interface for retrieving */
/*     integer data stored in the kernel pool.  This interface */
/*     allows you to retrieve the data associated with a variable */
/*     in multiplce accesses.  Under some circumstances this alleviates */
/*     the problem of having to know in advance the maximum amount */
/*     of space needed to accommodate all kernel variables. */

/*     However, this method of access does come with a price. It is */
/*     always more efficient to retrieve all of the data associated */
/*     with a kernel pool data in one call than it is to retrieve */
/*     it in sections. */

/*     See also the entry points GDPOOL and GCPOOL. */

/* $ Examples */


/*     The following code fragment demonstrates how the data stored */
/*     in a kernel pool variable can be retrieved in pieces. */

/*     First we need some declarations. */

/*        INTEGER               ROOM */
/*        PARAMETER           ( ROOM = 3 ) */

/*        CHARACTER*(8)         VARNAM */
/*        CHARACTER*(3)         INDENT */
/*        INTEGER               START */
/*        INTEGER               N */
/*        LOGICAL               FOUND */
/*        INTEGER               IVALS(ROOM) */


/*     Next load the data in the file 'typical.ker' into the */
/*     kernel pool. */

/*        CALL LDPOOL ( 'typical.ker' ) */

/*     Next we shall print the values stored for the kernel pool */
/*     variable 'MYDATA' */

/*        VARNAM = 'MYDATA' */
/*        INDENT = ' ' */
/*        START  =  1 */

/*        CALL GIPOOL ( VARNAM, START, ROOM, N, IVALS, FOUND ) */

/*        IF ( .NOT. FOUND ) */
/*           WRITE (*,*) 'There is no numeric data available for MYDATA.' */
/*        ELSE */

/*           WRITE (*,*) 'Values for MYDATA.' */
/*           WRITE (*,*) */

/*           DO I = 1, N */
/*              WRITE (*,*) INDENT, IVALS(I) */
/*           END DO */

/*           DO WHILE ( N .EQ. ROOM ) */

/*              START = START + N */
/*              CALL GIPOOL ( VARNAM, START, ROOM, N, IVALS, FOUND ) */

/*              DO I = 1, N */
/*                 WRITE (*,*) INDENT, IVALS(I) */
/*              END DO */

/*           END DO */

/*        END IF */

/* $ Restrictions */

/*     None. */

/* $ Literature_References */

/*     None. */

/* $ Author_and_Institution */

/*     W.L. Taber  (JPL) */

/* $ Version */

/* -    SPICELIB Version 8.0.1, 22-DEC-2004 (NJB) */

/*        Corrected an in-line comment relating to finding the */
/*        head node of the conflict resolution list for NAME. */

/* -    SPICELIB Version 8.0.0, 04-JUN-1999 (WLT) */

/*        Added the entry points PCPOOL, PDPOOL and PIPOOL to allow */
/*        direct insertion of data into the kernel pool without having */
/*        to read an external file. */

/*        Added the interface LMPOOL that allows SPICE */
/*        programs to load text kernels directly from memory */
/*        instead of requiring a text file. */

/*        Added the entry point SZPOOL to return kernel pool definition */
/*        parameters. */

/*        Added the entry point DVPOOL to allow the removal of a variable */
/*        from the kernel pool. */

/*        Added the entry point GNPOOL to allow users to determine */
/*        variables that are present in the kernel pool */

/* -    SPICELIB Version 7.0.0, 20-SEP-1995 (WLT) */

/*        The implementation of the kernel pool was completely redone */
/*        to improve performance in loading and fetching data.  In */
/*        addition the pool was upgraded so that variables may be */
/*        either string or numeric valued. */

/*        The entry points GCPOOL, GDPOOL, GIPOOL and DTPOOL were added */
/*        to the routine. */

/* -& */
/* $ Index_Entries */

/*     RETURN the integer value of a pooled kernel variable */

/* -& */

/*     Standard SPICE error handling. */

    if (return_()) {
	return 0;
    } else {
	chkin_("GIPOOL", (ftnlen)6);
    }

/*     Initialize the pool if necessary. */

    zzpini_(&first, &c__5003, &c__40000, &c__4000, begdat, begtxt, nmpool, 
	    dppool, chpool, namlst, datlst, &c__1000, &c__2000, watsym, 
	    watptr, watval, agents, active, notify, (ftnlen)10, (ftnlen)10, (
	    ftnlen)32, (ftnlen)32, (ftnlen)32, (ftnlen)32, (ftnlen)32);

/*     Perform the one obvious error check first. */

    if (*room < 1) {
	setmsg_("The amount of room specified as available for output in the"
		" output array was: #.  The amount of room must be positive. ",
		 (ftnlen)119);
	errint_("#", room, (ftnlen)1);
	sigerr_("SPICE(BADARRAYSIZE)", (ftnlen)19);
	chkout_("GIPOOL", (ftnlen)6);
	return 0;
    }

/*     Compute the hash value of this name. */

    lookat = zzhash_(name__, name_len);

/*     Now see if there is a non-empty conflict resolution list for the */
/*     input string NAME.  If so, NAMLST(LOOKAT) contains the head node */
/*     of the conflict resolution list; this node is a postive value. */

    if (namlst[(i__2 = lookat - 1) < 5003 && 0 <= i__2 ? i__2 : s_rnge("naml"
	    "st", i__2, "pool_", (ftnlen)4429)] == 0) {
	*found = FALSE_;
	chkout_("GIPOOL", (ftnlen)6);
	return 0;
    }

/*     If were are still here NAMLST(LOOKAT) is the first node of */
/*     a conflict resolution list.  See if the NAME corresposnding */
/*     to this node is the one we are looking for. */

    node = namlst[(i__2 = lookat - 1) < 5003 && 0 <= i__2 ? i__2 : s_rnge(
	    "namlst", i__2, "pool_", (ftnlen)4441)];
    succes = s_cmp(name__, pnames + (((i__2 = node - 1) < 5003 && 0 <= i__2 ? 
	    i__2 : s_rnge("pnames", i__2, "pool_", (ftnlen)4442)) << 5), 
	    name_len, (ftnlen)32) == 0;
    while(! succes) {
	node = nmpool[(i__2 = (node << 1) + 10) < 10018 && 0 <= i__2 ? i__2 : 
		s_rnge("nmpool", i__2, "pool_", (ftnlen)4446)];
	if (node < 0) {
	    *found = FALSE_;
	    chkout_("GIPOOL", (ftnlen)6);
	    return 0;
	}
	succes = s_cmp(name__, pnames + (((i__2 = node - 1) < 5003 && 0 <= 
		i__2 ? i__2 : s_rnge("pnames", i__2, "pool_", (ftnlen)4456)) 
		<< 5), name_len, (ftnlen)32) == 0;
    }

/*     If you get to this point, the variable NAME is present in the */
/*     list of names at PNAMES(NODE), ABS( DATLST(NODE) ) points to the */
/*     head of a linked list of values for this NAME. */

    datahd = datlst[(i__2 = node - 1) < 5003 && 0 <= i__2 ? i__2 : s_rnge(
	    "datlst", i__2, "pool_", (ftnlen)4464)];
    if (datahd < 0) {
	*n = 0;
	*found = FALSE_;
	chkout_("GIPOOL", (ftnlen)6);
	return 0;
    } else if (datahd == 0) {
	setmsg_("This is never supposed to happen.  The requested name, '#',"
		" was found in the name list, but the pointer to the head of "
		"the data for this variable is zero. Please note your activit"
		"ies and report this error to NAIF. ", (ftnlen)214);
	errch_("#", name__, (ftnlen)1, rtrim_(name__, name_len));
	sigerr_("SPICE(BUG)", (ftnlen)10);
	chkout_("GIPOOL", (ftnlen)6);
	return 0;
    }

/*     Prepare for fetching values. */

    big = (doublereal) intmax_();
    small = (doublereal) intmin_();
    *found = TRUE_;
    k = 0;
    *n = 0;
    begin = max(*start,1);
    node = datahd;
    while(node > 0) {
	++k;
	if (k >= begin) {
	    ++(*n);
	    if (dpvals[(i__2 = node - 1) < 40000 && 0 <= i__2 ? i__2 : s_rnge(
		    "dpvals", i__2, "pool_", (ftnlen)4505)] >= small && 
		    dpvals[(i__1 = node - 1) < 40000 && 0 <= i__1 ? i__1 : 
		    s_rnge("dpvals", i__1, "pool_", (ftnlen)4505)] <= big) {
		ivals[*n - 1] = i_dnnt(&dpvals[(i__2 = node - 1) < 40000 && 0 
			<= i__2 ? i__2 : s_rnge("dpvals", i__2, "pool_", (
			ftnlen)4508)]);
	    } else {
		setmsg_("The value associated with index # of the kernel var"
			"iable # is outside the range of integers. The value "
			"stored was: # .", (ftnlen)118);
		errint_("#", &k, (ftnlen)1);
		errch_("#", name__, (ftnlen)1, rtrim_(name__, name_len));
		errdp_("#", &dpvals[(i__2 = node - 1) < 40000 && 0 <= i__2 ? 
			i__2 : s_rnge("dpvals", i__2, "pool_", (ftnlen)4520)],
			 (ftnlen)1);
		sigerr_("SPICE(INTOUTOFRANGE)", (ftnlen)20);
		chkout_("GIPOOL", (ftnlen)6);
		return 0;
	    }
	    if (*n == *room) {
		chkout_("GIPOOL", (ftnlen)6);
		return 0;
	    }
	}
	node = dppool[(i__2 = (node << 1) + 10) < 80012 && 0 <= i__2 ? i__2 : 
		s_rnge("dppool", i__2, "pool_", (ftnlen)4534)];
    }
    chkout_("GIPOOL", (ftnlen)6);
    return 0;
/* $Procedure      DTPOOL (Data for a kernel pool variable) */

L_dtpool:
/* $ Abstract */

/*     Return the data about a kernel pool variable. */

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

/*     KERNEL */

/* $ Keywords */

/*     CONSTANTS */
/*     FILES */

/* $ Declarations */

/*     CHARACTER*(*)         NAME */
/*     LOGICAL               FOUND */
/*     INTEGER               N */
/*     CHARACTER*(*)         TYPE */

/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  -------------------------------------------------- */
/*     NAME       I   Name of the variable whose value is to be returned. */
/*     FOUND      O   True if variable is in pool. */
/*     N          O   Number of values returned for NAME. */
/*     TYPE       O   Type of the variable 'C', 'N', 'X' */

/* $ Detailed_Input */

/*     NAME       is the name of the variable whose values are to be */
/*                returned. */


/* $ Detailed_Output */


/*     FOUND      is TRUE if the variable is in the pool FALSE if it */
/*                is not. */

/*     N          is the number of values associated with NAME. */
/*                If NAME is not present in the pool N will be returned */
/*                with the value 0. */

/*     TYPE       is the type of the variable associated with NAME. */

/*                    'C' if the data is character data */
/*                    'N' if the data is numeric. */
/*                    'X' if there is no variable NAME in the pool. */

/* $ Parameters */

/*     None. */

/* $ Exceptions */

/*     1) If the name requested is not in the kernel pool FOUND */
/*        will be set to FALSE, N to zero and TYPE to 'X'. */


/* $ Files */

/*     None. */

/* $ Particulars */

/*     This routine allows you to determine whether or not a kernel */
/*     pool variable is present and to determine its size and type */
/*     if it is. */


/* $ Examples */


/*     The following code fragment demonstrates how to determine the */
/*     properties of a stored kernel variable. */

/*        CALL DTPOOL ( VARNAM, FOUND, N, TYPE ) */

/*        IF ( FOUND ) THEN */

/*           WRITE (*,*) 'Properties of variable: ', VARNAME */
/*           WRITE (*,*) */

/*           WRITE (*,*) '   Size: ', N */

/*           IF ( TYPE .EQ. 'C' ) THEN */
/*              WRITE (*,*) '   Type: Character' */
/*           ELSE */
/*              WRITE (*,*) '   Type: Numeric' */
/*           END IF */

/*        ELSE */

/*           WRITE (*,*) VARNAM(1:RTRIM(VARNAM)), ' is not present.' */

/*        END IF */



/* $ Restrictions */

/*     None. */

/* $ Literature_References */

/*     None. */

/* $ Author_and_Institution */

/*     W.L. Taber  (JPL) */

/* $ Version */

/* -    SPICELIB Version 8.0.1, 22-DEC-2004 (NJB) */

/*        Corrected an in-line comment relating to finding the */
/*        head node of the conflict resolution list for NAME. */

/* -    SPICELIB Version 8.0.0, 04-JUN-1999 (WLT) */

/*        Added the entry points PCPOOL, PDPOOL and PIPOOL to allow */
/*        direct insertion of data into the kernel pool without having */
/*        to read an external file. */

/*        Added the interface LMPOOL that allows SPICE */
/*        programs to load text kernels directly from memory */
/*        instead of requiring a text file. */

/*        Added the entry point SZPOOL to return kernel pool definition */
/*        parameters. */

/*        Added the entry point DVPOOL to allow the removal of a variable */
/*        from the kernel pool. */

/*        Added the entry point GNPOOL to allow users to determine */
/*        variables that are present in the kernel pool */

/* -    SPICELIB Version 7.0.0, 20-SEP-1995 (WLT) */

/*        The implementation of the kernel pool was completely redone */
/*        to improve performance in loading and fetching data.  In */
/*        addition the pool was upgraded so that variables may be */
/*        either string or numeric valued. */

/*        The entry points GCPOOL, GDPOOL, GIPOOL and DTPOOL were added */
/*        to the routine. */

/* -& */
/* $ Index_Entries */

/*     RETURN summary information about a kernel pool variable. */

/* -& */

/*     Standard SPICE error handling. */

    if (return_()) {
	return 0;
    } else {
	chkin_("DTPOOL", (ftnlen)6);
    }

/*     Initialize the pool if necessary. */

    zzpini_(&first, &c__5003, &c__40000, &c__4000, begdat, begtxt, nmpool, 
	    dppool, chpool, namlst, datlst, &c__1000, &c__2000, watsym, 
	    watptr, watval, agents, active, notify, (ftnlen)10, (ftnlen)10, (
	    ftnlen)32, (ftnlen)32, (ftnlen)32, (ftnlen)32, (ftnlen)32);

/*     Until we find otherwise, we shall assume there is no data */
/*     for this variable. */

    *found = FALSE_;
    *n = 0;
    s_copy(type__, "X", type_len, (ftnlen)1);

/*     Compute the hash value of this name. */

    lookat = zzhash_(name__, name_len);

/*     Now see if there is a non-empty conflict resolution list for the */
/*     input string NAME.  If so, NAMLST(LOOKAT) contains the head node */
/*     of the conflict resolution list; this node is a postive value. */

    if (namlst[(i__2 = lookat - 1) < 5003 && 0 <= i__2 ? i__2 : s_rnge("naml"
	    "st", i__2, "pool_", (ftnlen)4768)] == 0) {
	chkout_("DTPOOL", (ftnlen)6);
	return 0;
    }

/*     If were are still here NAMLST(LOOKAT) is the first node of */
/*     a conflict resolution list.  See if the NAME corresposnding */
/*     to this node is the one we are looking for. */

    node = namlst[(i__2 = lookat - 1) < 5003 && 0 <= i__2 ? i__2 : s_rnge(
	    "namlst", i__2, "pool_", (ftnlen)4779)];
    succes = s_cmp(name__, pnames + (((i__2 = node - 1) < 5003 && 0 <= i__2 ? 
	    i__2 : s_rnge("pnames", i__2, "pool_", (ftnlen)4780)) << 5), 
	    name_len, (ftnlen)32) == 0;
    while(! succes) {
	node = nmpool[(i__2 = (node << 1) + 10) < 10018 && 0 <= i__2 ? i__2 : 
		s_rnge("nmpool", i__2, "pool_", (ftnlen)4784)];
	if (node < 0) {
	    chkout_("DTPOOL", (ftnlen)6);
	    return 0;
	}
	succes = s_cmp(name__, pnames + (((i__2 = node - 1) < 5003 && 0 <= 
		i__2 ? i__2 : s_rnge("pnames", i__2, "pool_", (ftnlen)4793)) 
		<< 5), name_len, (ftnlen)32) == 0;
    }

/*     If you get to this point, the variable NAME is present in the */
/*     list of names at PNAMES(NODE), ABS( DATLST(NODE) ) points to the */
/*     head of a linked list of values for this NAME. */

    datahd = datlst[(i__2 = node - 1) < 5003 && 0 <= i__2 ? i__2 : s_rnge(
	    "datlst", i__2, "pool_", (ftnlen)4802)];
    if (datahd < 0) {
	s_copy(type__, "C", type_len, (ftnlen)1);
	*found = TRUE_;
	node = -datahd;
	while(node > 0) {
	    ++(*n);
	    node = chpool[(i__2 = (node << 1) + 10) < 8012 && 0 <= i__2 ? 
		    i__2 : s_rnge("chpool", i__2, "pool_", (ftnlen)4812)];
	}
    } else if (datahd > 0) {
	s_copy(type__, "N", type_len, (ftnlen)1);
	*found = TRUE_;
	node = datahd;
	while(node > 0) {
	    ++(*n);
	    node = dppool[(i__2 = (node << 1) + 10) < 80012 && 0 <= i__2 ? 
		    i__2 : s_rnge("dppool", i__2, "pool_", (ftnlen)4823)];
	}
    } else if (datahd == 0) {
	setmsg_("This is never supposed to happen.  The requested name, '#',"
		" was found in the name list, but the pointer to the head of "
		"the data for this variable is zero. Please note your activit"
		"ies and report this error to NAIF. ", (ftnlen)214);
	errch_("#", name__, (ftnlen)1, rtrim_(name__, name_len));
	sigerr_("SPICE(BUG)", (ftnlen)10);
	chkout_("DTPOOL", (ftnlen)6);
	return 0;
    }
    chkout_("DTPOOL", (ftnlen)6);
    return 0;
/* $Procedure      PCPOOL ( Put character strings into the kernel pool ) */

L_pcpool:
/* $ Abstract */

/*     This entry point provides toolkit programmers a method for */
/*     programmatically inserting character data into the */
/*     kernel pool. */

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

/*      POOL */

/* $ Declarations */

/*     CHARACTER*(*)         NAME */
/*     INTEGER               N */
/*     CHARACTER*(*)         CVALS ( * ) */

/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  -------------------------------------------------- */
/*     NAME       I   The kernel pool name to associate with CVALS. */
/*     N          I   The number of values to insert. */
/*     CVALS      I   An array of strings to insert into the kernel pool. */

/* $ Detailed_Input */

/*     NAME       is the name of the kernel pool variable to associate */
/*                with the values supplied in the array CVALS */

/*     N          is the number of values to insert into the kernel pool. */

/*     CVALS      is an array of strings to insert into the kernel */
/*                pool. */

/* $ Detailed_Output */

/*     None. */

/* $ Parameters */

/*     None. */

/* $ Files */

/*     None. */

/* $ Exceptions */

/*     1) If NAME is already present in the kernel pool and there */
/*        is sufficient room to hold all values supplied in CVALS, */
/*        the old values associated with NAME will be overwritten. */

/*     2) If there is not sufficient room to insert a new variable */
/*        into the kernel pool and NAME is not already present in */
/*        the kernel pool, the error SPICE(KERNELPOOLFULL) is */
/*        signaled by a routine in the call tree to this routine. */

/*     3) If there is not sufficient room to insert the values associated */
/*        with NAME, the error 'SPICE(NOMOREROOM)' will be signaled. */

/* $ Particulars */

/*     This entry point provides a programmatic interface for inserting */
/*     character data into the SPICE kernel pool without reading an */
/*     external file. */

/* $ Examples */

/*     Suppose that you wish to supply default values for a program */
/*     so that it may function even in the absence of the appropriate */
/*     text kernels.  You can use the entry points PCPOOL, PDPOOL */
/*     and PIPOOL to initialize the kernel pool with suitable */
/*     values at program initialization.  The example below shows */
/*     how you might set up various kernel pool variables that might */
/*     be required by a program. */


/*        Set up the relationship between the EARTH_BODYFIXED frame */
/*        and the IAU_EARTH frame. */

/*        CALL IDENT  ( MATRIX ) */
/*        CALL PCPOOL ( 'TKFRAME_EARTH_FIXED_SPEC',     1, 'MATRIX'    ) */
/*        CALL PCPOOL ( 'TKFRAME_EARTH_FIXED_RELATIVE', 1, 'IAU_EARTH' ) */
/*        CALL PDPOOL ( 'TKFRAME_EARTH_FIXED_MATRIX',   9,  MATRIX ) */


/*        Load the IAU model for the earth's rotation and shape. */


/*        RA ( 1 ) =  0.0D0 */
/*        RA ( 2 ) = -0.641D0 */
/*        RA ( 3 ) =  0.0D0 */

/*        DEC( 1 ) = 90.0D0 */
/*        DEC( 2 ) = -0.557D0 */
/*        DEC( 3 ) =  0.0D0 */

/*        PM ( 1 ) = 190.16D0 */
/*        PM ( 2 ) = 360.9856235D0 */
/*        PM ( 3 ) =   0.0D0 */

/*        R  ( 1 ) =  6378.140D0 */
/*        R  ( 2 ) =  6378.140D0 */
/*        R  ( 3 ) =  6356.75D0 */

/*        CALL PDPOOL ( 'BODY399_POLE_RA',   3, RA  ) */
/*        CALL PDPOOL ( 'BODY399_POLE_DEC',  3, DEC ) */
/*        CALL PDPOOL ( 'BODY399_PM',        3, PM  ) */
/*        CALL PDPOOL ( 'BODY399_RADII',     3, R   ) */


/*        Set up a preliminary set of leapsecond values. */

/*        CALL PDPOOL ( 'DELTET/DELTA_T_A/, 1, 32.184D0  ) */
/*        CALL PDPOOL ( 'DELTET/K',         1,  1.657D-3 ) */
/*        CALL PDPOOL ( 'DELTET/EB',        1,  1.671D-2 ) */

/*        VALUES(1) = 6.23999600D0 */
/*        VALUES(2) = 1.99096871D-7 */

/*        CALL PDPOOL ( 'DELTET/M', 2, VALUES ) */


/*        VALUES(  1 ) = 10 */
/*        VALUES(  3 ) = 11 */
/*        VALUES(  5 ) = 12 */
/*        VALUES(  7 ) = 13 */
/*        VALUES(  9 ) = 14 */
/*        VALUES( 11 ) = 15 */
/*        VALUES( 13 ) = 16 */
/*        VALUES( 15 ) = 17 */
/*        VALUES( 17 ) = 18 */
/*        VALUES( 19 ) = 19 */
/*        VALUES( 21 ) = 20 */
/*        VALUES( 23 ) = 21 */
/*        VALUES( 25 ) = 22 */
/*        VALUES( 27 ) = 23 */
/*        VALUES( 29 ) = 24 */
/*        VALUES( 31 ) = 25 */
/*        VALUES( 33 ) = 26 */
/*        VALUES( 35 ) = 27 */
/*        VALUES( 37 ) = 28 */
/*        VALUES( 39 ) = 29 */
/*        VALUES( 41 ) = 30 */
/*        VALUES( 43 ) = 31 */

/*        CALL TPARSE ( '1972-JAN-1', VALUES(2),  ERROR ) */
/*        CALL TPARSE ( '1972-JUL-1', VALUES(4),  ERROR ) */
/*        CALL TPARSE ( '1973-JAN-1', VALUES(6),  ERROR ) */
/*        CALL TPARSE ( '1974-JAN-1', VALUES(8),  ERROR ) */
/*        CALL TPARSE ( '1975-JAN-1', VALUES(10), ERROR ) */
/*        CALL TPARSE ( '1976-JAN-1', VALUES(12), ERROR ) */
/*        CALL TPARSE ( '1977-JAN-1', VALUES(14), ERROR ) */
/*        CALL TPARSE ( '1978-JAN-1', VALUES(16), ERROR ) */
/*        CALL TPARSE ( '1979-JAN-1', VALUES(18), ERROR ) */
/*        CALL TPARSE ( '1980-JAN-1', VALUES(20), ERROR ) */
/*        CALL TPARSE ( '1981-JUL-1', VALUES(22), ERROR ) */
/*        CALL TPARSE ( '1982-JUL-1', VALUES(24), ERROR ) */
/*        CALL TPARSE ( '1983-JUL-1', VALUES(26), ERROR ) */
/*        CALL TPARSE ( '1985-JUL-1', VALUES(28), ERROR ) */
/*        CALL TPARSE ( '1988-JAN-1', VALUES(30), ERROR ) */
/*        CALL TPARSE ( '1990-JAN-1', VALUES(32), ERROR ) */
/*        CALL TPARSE ( '1991-JAN-1', VALUES(34), ERROR ) */
/*        CALL TPARSE ( '1992-JUL-1', VALUES(36), ERROR ) */
/*        CALL TPARSE ( '1993-JUL-1', VALUES(38), ERROR ) */
/*        CALL TPARSE ( '1994-JUL-1', VALUES(40), ERROR ) */
/*        CALL TPARSE ( '1996-JAN-1', VALUES(42), ERROR ) */
/*        CALL TPARSE ( '1997-JUL-1', VALUES(44), ERROR ) */

/*        CALL PDPOOL ( 'DELTET/DELTA_AT',  44, VALUES ) */


/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     W.L. Taber      (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    SPICELIB Version 8.0.0, 04-JUN-1999 (WLT) */

/*        Added the entry points PCPOOL, PDPOOL and PIPOOL to allow */
/*        direct insertion of data into the kernel pool without having */
/*        to read an external file. */

/*        Added the interface LMPOOL that allows SPICE */
/*        programs to load text kernels directly from memory instead */
/*        of requiring a text file. */

/*        Added the entry point SZPOOL to return kernel pool definition */
/*        parameters. */

/*        Added the entry point DVPOOL to allow the removal of a variable */
/*        from the kernel pool. */

/*        Added the entry point GNPOOL to allow users to determine */
/*        variables that are present in the kernel pool */

/* -& */
/* $ Index_Entries */

/*     Set the value of a character kernel pool variable */

/* -& */

/*     Standard SPICE error handling. */

    if (*n <= 0) {
	return 0;
    }
    if (return_()) {
	return 0;
    }
    chkin_("PCPOOL", (ftnlen)6);
    zzpini_(&first, &c__5003, &c__40000, &c__4000, begdat, begtxt, nmpool, 
	    dppool, chpool, namlst, datlst, &c__1000, &c__2000, watsym, 
	    watptr, watval, agents, active, notify, (ftnlen)10, (ftnlen)10, (
	    ftnlen)32, (ftnlen)32, (ftnlen)32, (ftnlen)32, (ftnlen)32);

/*     Find out where the name for this item is located */
/*     in the data tables. */

    zzgpnm_(namlst, nmpool, pnames, datlst, dppool, dpvals, chpool, chvals, 
	    name__, &gotit, &lookat, &nameat, (ftnlen)32, (ftnlen)80, 
	    name_len);
    if (failed_()) {
	chkout_("PCPOOL", (ftnlen)6);
	return 0;
    }

/*     Determine how much room is available for inserting new d.p.s */
/*     values into the kernel pool. */

    avail = lnknfn_(chpool);
    if (gotit) {

/*        If we found the specified variable in the kernel pool, we */
/*        may be able to free up some space before inserting data. */
/*        We need to take this into account when determining */
/*        the amount of free room in the pool. */

	datahd = datlst[(i__2 = nameat - 1) < 5003 && 0 <= i__2 ? i__2 : 
		s_rnge("datlst", i__2, "pool_", (ftnlen)5140)];
	if (datahd > 0) {

/*           No extra strings will be freed.  We have whatever */
/*           free space is in the CHPOOL right now. */

	} else {

/*           Find out how many items are in the current */
/*           list of strings associated with the variable. */

	    tofree = 0;
	    node = -datahd;
	    while(node > 0) {
		++tofree;
		node = chpool[(i__2 = (node << 1) + 10) < 8012 && 0 <= i__2 ? 
			i__2 : s_rnge("chpool", i__2, "pool_", (ftnlen)5157)];
	    }

/*           Add the number we will free to the amount currently */
/*           free in the dp pool. */

	    avail += tofree;
	}
    }

/*     If the AVAIL for new data is less than the number of items */
/*     to be added, we just bail out here. */

    if (avail < *n) {
	if (! gotit) {

/*           We need to perform some clean up.  We've allocated */
/*           a new name but it has nothing in it. On the other hand */
/*           if we found it don't need to do anything because we've */
/*           only read from the pool. We haven't altered anything. */
/*           But in that case we'll never get into this block of code. */

	    zzcln_(&lookat, &nameat, namlst, datlst, nmpool, chpool, dppool);
	}
	setmsg_("There is not sufficient space available in the kernel pool "
		"to store the # items associated with the name #.  There is r"
		"oom to store only # items. ", (ftnlen)146);
	errint_("#", n, (ftnlen)1);
	errch_("#", name__, (ftnlen)1, name_len);
	errint_("#", &avail, (ftnlen)1);
	sigerr_("SPICE(NOMOREROOM)", (ftnlen)17);
	chkout_("PCPOOL", (ftnlen)6);
	return 0;
    }

/*     There is room to insert the data.  Free up any required */
/*     nodes. */

    if (gotit) {

/*        We need to free the data associated with this */
/*        variable.  But first make sure there will be room */
/*        to add data. */

	datahd = datlst[(i__2 = nameat - 1) < 5003 && 0 <= i__2 ? i__2 : 
		s_rnge("datlst", i__2, "pool_", (ftnlen)5213)];
	datlst[(i__2 = nameat - 1) < 5003 && 0 <= i__2 ? i__2 : s_rnge("datl"
		"st", i__2, "pool_", (ftnlen)5214)] = 0;
	if (datahd > 0) {

/*           This variable was character type we need to */
/*           free a linked list from the character data */
/*           pool. */

	    head = datahd;
	    tail = -dppool[(i__2 = (head << 1) + 11) < 80012 && 0 <= i__2 ? 
		    i__2 : s_rnge("dppool", i__2, "pool_", (ftnlen)5224)];
	    lnkfsl_(&head, &tail, dppool);
	} else {

/*           This variable was character type. We need to */
/*           free a linked list from the numeric pool. */

	    head = -datahd;
	    tail = -chpool[(i__2 = (head << 1) + 11) < 8012 && 0 <= i__2 ? 
		    i__2 : s_rnge("chpool", i__2, "pool_", (ftnlen)5235)];
	    lnkfsl_(&head, &tail, chpool);
	}
    }

/*     We have done all of the freeing and checking that */
/*     needs to be done.  Now add the data. */

    i__2 = *n;
    for (i__ = 1; i__ <= i__2; ++i__) {

/*        We are ready to go.  Allocate a node for this data */
/*        item. First make sure there is room to do so. */

	free = lnknfn_(chpool);
	if (free <= 0) {
	    setmsg_("There is no room available for adding another character"
		    " value to the kernel pool.", (ftnlen)81);
	    sigerr_("SPICE(KERNELPOOLFULL)", (ftnlen)21);
	    chkout_("PCPOOL", (ftnlen)6);
	    return 0;
	}

/*        Allocate a node for storing this string value: */

	lnkan_(chpool, &chnode);
	if (datlst[(i__1 = nameat - 1) < 5003 && 0 <= i__1 ? i__1 : s_rnge(
		"datlst", i__1, "pool_", (ftnlen)5270)] == 0) {

/*           There was no data for this name yet.  We make */
/*           CHNODE be the head of the data list for this name. */

	    datlst[(i__1 = nameat - 1) < 5003 && 0 <= i__1 ? i__1 : s_rnge(
		    "datlst", i__1, "pool_", (ftnlen)5276)] = -chnode;
	} else {

/*           Put this node after the tail of the current list. */

	    head = -datlst[(i__1 = nameat - 1) < 5003 && 0 <= i__1 ? i__1 : 
		    s_rnge("datlst", i__1, "pool_", (ftnlen)5283)];
	    tail = -chpool[(i__1 = (head << 1) + 11) < 8012 && 0 <= i__1 ? 
		    i__1 : s_rnge("chpool", i__1, "pool_", (ftnlen)5284)];
	    lnkila_(&tail, &chnode, chpool);
	}

/*        Finally insert this data item in the data buffer */
/*        at CHNODE.  Note any quotes will be doubled so we */
/*        have to undo this affect when we store the data. */

	s_copy(chvals + ((i__1 = chnode - 1) < 4000 && 0 <= i__1 ? i__1 : 
		s_rnge("chvals", i__1, "pool_", (ftnlen)5295)) * 80, cvals + (
		i__ - 1) * cvals_len, (ftnlen)80, cvals_len);

/*        That's all for this value. It's now time to loop */
/*        back through and get the next value. */

    }

/*     One last thing, see if this variable is being watched ... */

    sygetc_(name__, watsym, watptr, watval, &nfetch, notify + 192, &got, 
	    name_len, (ftnlen)32, (ftnlen)32, (ftnlen)32);

/*     ... if it is, add its associated agents to the list of */
/*     AGENTS to be notified of a watched variable update. */

    if (got) {
	copyc_(agents, active, (ftnlen)32, (ftnlen)32);
	validc_(&c__1000, &nfetch, notify, (ftnlen)32);
	unionc_(notify, active, agents, (ftnlen)32, (ftnlen)32, (ftnlen)32);
    }
    chkout_("PCPOOL", (ftnlen)6);
    return 0;
/* $Procedure      PDPOOL ( Put d.p.'s into the kernel pool ) */

L_pdpool:
/* $ Abstract */

/*     This entry point provides toolkit programmers a method for */
/*     programmatically inserting double precision data into the */
/*     kernel pool. */

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

/*      POOL */

/* $ Declarations */

/*     CHARACTER*(*)         NAME */
/*     INTEGER               N */
/*     DOUBLE PRECISION      VALUES ( * ) */

/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  -------------------------------------------------- */
/*     NAME       I   The kernel pool name to associate with VALUES. */
/*     N          I   The number of values to insert. */
/*     VALUES     I   An array of values to insert into the kernel pool. */

/* $ Detailed_Input */

/*     NAME       is the name of the kernel pool variable to associate */
/*                with the values supplied in the array VALUES */

/*     N          is the number of values to insert into the kernel pool. */

/*     VALUES     is an array of d.p. values to insert into the kernel */
/*                pool. */

/* $ Detailed_Output */

/*     None. */

/* $ Parameters */

/*     None. */

/* $ Files */

/*     None. */

/* $ Exceptions */

/*     1) If NAME is already present in the kernel pool and there */
/*        is sufficient room to hold all values supplied in VALUES, */
/*        the old values associated with NAME will be overwritten. */

/*     2) If there is not sufficient room to insert a new variable */
/*        into the kernel pool and NAME is not already present in */
/*        the kernel pool, the error SPICE(KERNELPOOLFULL) is */
/*        signaled by a routine in the call tree to this routine. */

/*     3) If there is not sufficient room to insert the values associated */
/*        with NAME, the error 'SPICE(NOMOREROOM)' will be signaled. */

/* $ Particulars */

/*     This entry point provides a programmatic interface for inserting */
/*     data into the SPICE kernel pool without reading an external file. */

/* $ Examples */

/*     Suppose that you wish to supply default values for a program */
/*     so that it may function even in the absence of the appropriate */
/*     text kernels.  You can use the entry points PCPOOL, PDPOOL */
/*     and PIPOOL to initialize the kernel pool with suitable */
/*     values at program initialization.  The example below shows */
/*     how you might set up various kernel pool variables that might */
/*     be required by a program. */


/*        Set up the relationship between the EARTH_BODYFIXED frame */
/*        and the IAU_EARTH frame. */

/*        CALL IDENT  ( MATRIX ) */
/*        CALL PCPOOL ( 'TKFRAME_EARTH_FIXED_SPEC',     1, 'MATRIX'    ) */
/*        CALL PCPOOL ( 'TKFRAME_EARTH_FIXED_RELATIVE', 1, 'IAU_EARTH' ) */
/*        CALL PDPOOL ( 'TKFRAME_EARTH_FIXED_MATRIX',   9,  MATRIX ) */


/*        Load the IAU model for the earth's rotation and shape. */


/*        RA ( 1 ) =  0.0D0 */
/*        RA ( 2 ) = -0.641D0 */
/*        RA ( 3 ) =  0.0D0 */

/*        DEC( 1 ) = 90.0D0 */
/*        DEC( 2 ) = -0.557D0 */
/*        DEC( 3 ) =  0.0D0 */

/*        PM ( 1 ) = 190.16D0 */
/*        PM ( 2 ) = 360.9856235D0 */
/*        PM ( 3 ) =   0.0D0 */

/*        R  ( 1 ) =  6378.140D0 */
/*        R  ( 2 ) =  6378.140D0 */
/*        R  ( 3 ) =  6356.75D0 */

/*        CALL PDPOOL ( 'BODY399_POLE_RA',   3, RA  ) */
/*        CALL PDPOOL ( 'BODY399_POLE_DEC',  3, DEC ) */
/*        CALL PDPOOL ( 'BODY399_PM',        3, PM  ) */
/*        CALL PDPOOL ( 'BODY399_RADII',     3, R   ) */


/*        Set up a preliminary set of leapsecond values. */

/*        CALL PDPOOL ( 'DELTET/DELTA_T_A', 1, 32.184D0  ) */
/*        CALL PDPOOL ( 'DELTET/K',         1,  1.657D-3 ) */
/*        CALL PDPOOL ( 'DELTET/EB',        1,  1.671D-2 ) */

/*        VALUES(1) = 6.23999600D0 */
/*        VALUES(2) = 1.99096871D-7 */

/*        CALL PDPOOL ( 'DELTET/M', 2, VALUES ) */


/*        VALUES(  1 ) = 10 */
/*        VALUES(  3 ) = 11 */
/*        VALUES(  5 ) = 12 */
/*        VALUES(  7 ) = 13 */
/*        VALUES(  9 ) = 14 */
/*        VALUES( 11 ) = 15 */
/*        VALUES( 13 ) = 16 */
/*        VALUES( 15 ) = 17 */
/*        VALUES( 17 ) = 18 */
/*        VALUES( 19 ) = 19 */
/*        VALUES( 21 ) = 20 */
/*        VALUES( 23 ) = 21 */
/*        VALUES( 25 ) = 22 */
/*        VALUES( 27 ) = 23 */
/*        VALUES( 29 ) = 24 */
/*        VALUES( 31 ) = 25 */
/*        VALUES( 33 ) = 26 */
/*        VALUES( 35 ) = 27 */
/*        VALUES( 37 ) = 28 */
/*        VALUES( 39 ) = 29 */
/*        VALUES( 41 ) = 30 */
/*        VALUES( 43 ) = 31 */

/*        CALL TPARSE ( '1972-JAN-1', VALUES(2),  ERROR ) */
/*        CALL TPARSE ( '1972-JUL-1', VALUES(4),  ERROR ) */
/*        CALL TPARSE ( '1973-JAN-1', VALUES(6),  ERROR ) */
/*        CALL TPARSE ( '1974-JAN-1', VALUES(8),  ERROR ) */
/*        CALL TPARSE ( '1975-JAN-1', VALUES(10), ERROR ) */
/*        CALL TPARSE ( '1976-JAN-1', VALUES(12), ERROR ) */
/*        CALL TPARSE ( '1977-JAN-1', VALUES(14), ERROR ) */
/*        CALL TPARSE ( '1978-JAN-1', VALUES(16), ERROR ) */
/*        CALL TPARSE ( '1979-JAN-1', VALUES(18), ERROR ) */
/*        CALL TPARSE ( '1980-JAN-1', VALUES(20), ERROR ) */
/*        CALL TPARSE ( '1981-JUL-1', VALUES(22), ERROR ) */
/*        CALL TPARSE ( '1982-JUL-1', VALUES(24), ERROR ) */
/*        CALL TPARSE ( '1983-JUL-1', VALUES(26), ERROR ) */
/*        CALL TPARSE ( '1985-JUL-1', VALUES(28), ERROR ) */
/*        CALL TPARSE ( '1988-JAN-1', VALUES(30), ERROR ) */
/*        CALL TPARSE ( '1990-JAN-1', VALUES(32), ERROR ) */
/*        CALL TPARSE ( '1991-JAN-1', VALUES(34), ERROR ) */
/*        CALL TPARSE ( '1992-JUL-1', VALUES(36), ERROR ) */
/*        CALL TPARSE ( '1993-JUL-1', VALUES(38), ERROR ) */
/*        CALL TPARSE ( '1994-JUL-1', VALUES(40), ERROR ) */
/*        CALL TPARSE ( '1996-JAN-1', VALUES(42), ERROR ) */
/*        CALL TPARSE ( '1997-JUL-1', VALUES(44), ERROR ) */

/*        CALL PDPOOL ( 'DELTET/DELTA_AT',  44, VALUES ) */


/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     W.L. Taber      (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    SPICELIB Version 8.0.0, 04-JUN-1999 (WLT) */

/*        Added the entry points PCPOOL, PDPOOL and PIPOOL to allow */
/*        direct insertion of data into the kernel pool without having */
/*        to read an external file. */

/*        Added the interface LMPOOL that allows SPICE */
/*        programs to load text kernels directly from memory instead */
/*        of requiring a text file. */

/*        Added the entry point SZPOOL to return kernel pool definition */
/*        parameters. */

/*        Added the entry point DVPOOL to allow the removal of a variable */
/*        from the kernel pool. */

/*        Added the entry point GNPOOL to allow users to determine */
/*        variables that are present in the kernel pool */

/* -& */
/* $ Index_Entries */

/*     Set the value of a d.p. kernel pool variable */

/* -& */

/*     Standard SPICE error handling. */

    if (*n <= 0) {
	return 0;
    }
    if (return_()) {
	return 0;
    }
    chkin_("PDPOOL", (ftnlen)6);
    zzpini_(&first, &c__5003, &c__40000, &c__4000, begdat, begtxt, nmpool, 
	    dppool, chpool, namlst, datlst, &c__1000, &c__2000, watsym, 
	    watptr, watval, agents, active, notify, (ftnlen)10, (ftnlen)10, (
	    ftnlen)32, (ftnlen)32, (ftnlen)32, (ftnlen)32, (ftnlen)32);

/*     Find out where the name for this item is located */
/*     in the data tables. */

    zzgpnm_(namlst, nmpool, pnames, datlst, dppool, dpvals, chpool, chvals, 
	    name__, &gotit, &lookat, &nameat, (ftnlen)32, (ftnlen)80, 
	    name_len);
    if (failed_()) {
	chkout_("PDPOOL", (ftnlen)6);
	return 0;
    }

/*     Determine how much room is available for inserting new d.p.s */
/*     values into the kernel pool. */

    avail = lnknfn_(dppool);
    if (gotit) {

/*        If we found the specified variable in the kernel pool, we */
/*        may be able to free up some space before inserting data. */
/*        We need to take this into account when determining */
/*        the amount of free room in the pool. */

	datahd = datlst[(i__2 = nameat - 1) < 5003 && 0 <= i__2 ? i__2 : 
		s_rnge("datlst", i__2, "pool_", (ftnlen)5619)];
	if (datahd < 0) {

/*           No extra d.p.s will be freed.  We have whatever */
/*           free space is in the DPPOOL right now. */

	} else {

/*           Find out how many items are in the current */
/*           list of d.p. associated with the variable. */

	    tofree = 0;
	    node = datahd;
	    while(node > 0) {
		++tofree;
		node = dppool[(i__2 = (node << 1) + 10) < 80012 && 0 <= i__2 ?
			 i__2 : s_rnge("dppool", i__2, "pool_", (ftnlen)5636)]
			;
	    }

/*           Add the number we will free to the amount currently */
/*           free in the dp pool. */

	    avail += tofree;
	}
    }

/*     If the AVAIL for new data is less than the number of items */
/*     to be added, we just bail out here. */

    if (avail < *n) {
	if (! gotit) {

/*           We need to perform some clean up.  We've allocated */
/*           a new name but it has nothing in it. On the other hand */
/*           if we found it don't need to do anything because we've */
/*           only read from the pool. We haven't altered anything. */
/*           But in that case we'll never get into this block of code. */

	    zzcln_(&lookat, &nameat, namlst, datlst, nmpool, chpool, dppool);
	}
	setmsg_("There is not sufficient space available in the kernel pool "
		"to store the # items associated with the name #.  There is r"
		"oom to store only # items. ", (ftnlen)146);
	errint_("#", n, (ftnlen)1);
	errch_("#", name__, (ftnlen)1, name_len);
	errint_("#", &avail, (ftnlen)1);
	sigerr_("SPICE(NOMOREROOM)", (ftnlen)17);
	chkout_("PDPOOL", (ftnlen)6);
	return 0;
    }

/*     There is room to insert the data.  Free up any required */
/*     nodes. */

    if (gotit) {

/*        We need to free the data associated with this */
/*        variable.  But first make sure there will be room */
/*        to add data. */

	datahd = datlst[(i__2 = nameat - 1) < 5003 && 0 <= i__2 ? i__2 : 
		s_rnge("datlst", i__2, "pool_", (ftnlen)5692)];
	datlst[(i__2 = nameat - 1) < 5003 && 0 <= i__2 ? i__2 : s_rnge("datl"
		"st", i__2, "pool_", (ftnlen)5693)] = 0;
	if (datahd < 0) {

/*           This variable was character type we need to */
/*           free a linked list from the character data */
/*           pool. */

	    head = -datahd;
	    tail = -chpool[(i__2 = (head << 1) + 11) < 8012 && 0 <= i__2 ? 
		    i__2 : s_rnge("chpool", i__2, "pool_", (ftnlen)5703)];
	    lnkfsl_(&head, &tail, chpool);
	} else {

/*           This variable was numeric type. We need to */
/*           free a linked list from the numeric pool. */

	    head = datahd;
	    tail = -dppool[(i__2 = (head << 1) + 11) < 80012 && 0 <= i__2 ? 
		    i__2 : s_rnge("dppool", i__2, "pool_", (ftnlen)5714)];
	    lnkfsl_(&head, &tail, dppool);
	}
    }

/*     We have done all of the freeing and checking that */
/*     needs to be done.  Now add the data. */

    i__2 = *n;
    for (i__ = 1; i__ <= i__2; ++i__) {

/*        OK. See if there is room in */
/*        the numeric portion of the pool to store this value. */

	free = lnknfn_(dppool);
	if (free <= 0) {

/*           This branch of the code should never be exercised, */
/*           but it doesn't hurt to program in a redundant check. */

	    zzcln_(&lookat, &nameat, namlst, datlst, nmpool, chpool, dppool);
	    setmsg_("There is no room available for adding another numeric v"
		    "alue to the kernel pool.", (ftnlen)79);
	    sigerr_("SPICE(KERNELPOOLFULL)", (ftnlen)21);
	    chkout_("PDPOOL", (ftnlen)6);
	    return 0;
	}

/*        Allocate a node for storing this numeric value: */

	lnkan_(dppool, &dpnode);
	if (datlst[(i__1 = nameat - 1) < 5003 && 0 <= i__1 ? i__1 : s_rnge(
		"datlst", i__1, "pool_", (ftnlen)5755)] == 0) {

/*           There was no data for this name yet.  We make */
/*           DPNODE be the head of the data list for this name. */

	    datlst[(i__1 = nameat - 1) < 5003 && 0 <= i__1 ? i__1 : s_rnge(
		    "datlst", i__1, "pool_", (ftnlen)5761)] = dpnode;
	} else {

/*           Put this node after the tail of the current list. */

	    head = datlst[(i__1 = nameat - 1) < 5003 && 0 <= i__1 ? i__1 : 
		    s_rnge("datlst", i__1, "pool_", (ftnlen)5768)];
	    tail = -dppool[(i__1 = (head << 1) + 11) < 80012 && 0 <= i__1 ? 
		    i__1 : s_rnge("dppool", i__1, "pool_", (ftnlen)5769)];
	    lnkila_(&tail, &dpnode, dppool);
	}

/*        Finally insert this data item into the numeric buffer. */

	dpvals[(i__1 = dpnode - 1) < 40000 && 0 <= i__1 ? i__1 : s_rnge("dpv"
		"als", i__1, "pool_", (ftnlen)5778)] = values[i__ - 1];
    }

/*     One last thing, see if this variable is being watched ... */

    sygetc_(name__, watsym, watptr, watval, &nfetch, notify + 192, &got, 
	    name_len, (ftnlen)32, (ftnlen)32, (ftnlen)32);

/*     ... if it is, add its associated agents to the list of */
/*     AGENTS to be notified of a watched variable update. */

    if (got) {
	copyc_(agents, active, (ftnlen)32, (ftnlen)32);
	validc_(&c__1000, &nfetch, notify, (ftnlen)32);
	unionc_(notify, active, agents, (ftnlen)32, (ftnlen)32, (ftnlen)32);
    }
    chkout_("PDPOOL", (ftnlen)6);
    return 0;
/* $Procedure      PIPOOL ( Put integers into the kernel pool ) */

L_pipool:
/* $ Abstract */

/*     This entry point provides toolkit programmers a method for */
/*     programmatically inserting integer data into the kernel pool. */

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

/*      POOL */

/* $ Declarations */

/*     CHARACTER*(*)         NAME */
/*     INTEGER               N */
/*     INTEGER               IVALS ( * ) */

/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  -------------------------------------------------- */
/*     NAME       I   The kernel pool name to associate with IVALS. */
/*     N          I   The number of values to insert. */
/*     IVALS      I   An array of integers to insert into the pool. */

/* $ Detailed_Input */

/*     NAME       is the name of the kernel pool variable to associate */
/*                with the values supplied in the array IVALS */

/*     N          is the number of values to insert into the kernel pool. */

/*     IVALS      is an array of integers to insert into the kernel */
/*                pool. */

/* $ Detailed_Output */

/*     None. */

/* $ Parameters */

/*     None. */

/* $ Files */

/*     None. */

/* $ Exceptions */

/*     1) If NAME is already present in the kernel pool and there */
/*        is sufficient room to hold all values supplied in IVALS, */
/*        the old values associated with NAME will be overwritten. */

/*     2) If there is not sufficient room to insert a new variable */
/*        into the kernel pool and NAME is not already present in */
/*        the kernel pool, the error SPICE(KERNELPOOLFULL) is */
/*        signaled by a routine in the call tree to this routine. */

/*     3) If there is not sufficient room to insert the values associated */
/*        with NAME, the error 'SPICE(NOMOREROOM)' will be signaled. */

/* $ Particulars */

/*     This entry point provides a programmatic interface for inserting */
/*     data into the SPICE kernel pool without reading an external file. */

/* $ Examples */

/*     Suppose that you wish to supply default values for a program */
/*     so that it may function even in the absence of the appropriate */
/*     text kernels.  You can use the entry points PCPOOL, PDPOOL */
/*     and PIPOOL to initialize the kernel pool with suitable */
/*     values at program initialization.  The example below shows */
/*     how you might set up various kernel pool variables that might */
/*     be required by a program. */


/*        Set up the relationship between the EARTH_BODYFIXED frame */
/*        and the IAU_EARTH frame. */

/*        CALL IDENT ( MATRIX ) */
/*        CALL PCPOOL ( 'TKFRAME_EARTH_FIXED_SPEC',     1, 'MATRIX' ) */
/*        CALL PIPOOL ( 'TKFRAME_EARTH_FIXED_RELATIVE', 1,  10081   ) */
/*        CALL PDPOOL ( 'TKFRAME_EARTH_FIXED_MATRIX',   9,  MATRIX  ) */


/*        Load the IAU model for the earth's rotation and shape. */


/*        RA ( 1 ) =  0.0D0 */
/*        RA ( 2 ) = -0.641D0 */
/*        RA ( 3 ) =  0.0D0 */

/*        DEC( 1 ) = 90.0D0 */
/*        DEC( 2 ) = -0.557D0 */
/*        DEC( 3 ) =  0.0D0 */

/*        PM ( 1 ) = 190.16D0 */
/*        PM ( 2 ) = 360.9856235D0 */
/*        PM ( 3 ) =   0.0D0 */

/*        R  ( 1 ) =  6378.140D0 */
/*        R  ( 2 ) =  6378.140D0 */
/*        R  ( 3 ) =  6356.75D0 */

/*        CALL PDPOOL ( 'BODY399_POLE_RA',   3, RA  ) */
/*        CALL PDPOOL ( 'BODY399_POLE_DEC',  3, DEC ) */
/*        CALL PDPOOL ( 'BODY399_PM',        3, PM  ) */
/*        CALL PDPOOL ( 'BODY399_RADII',     3, R   ) */


/*        Set up a preliminary set of leapsecond values. */

/*        CALL PDPOOL ( 'DELTET/DELTA_T_A/, 1, 32.184D0  ) */
/*        CALL PDPOOL ( 'DELTET/K',         1,  1.657D-3 ) */
/*        CALL PDPOOL ( 'DELTET/EB',        1,  1.671D-2 ) */

/*        VALUES(1) = 6.23999600D0 */
/*        VALUES(2) = 1.99096871D-7 */

/*        CALL PDPOOL ( 'DELTET/M', 2, VALUES ) */


/*        VALUES(  1 ) = 10 */
/*        VALUES(  3 ) = 11 */
/*        VALUES(  5 ) = 12 */
/*        VALUES(  7 ) = 13 */
/*        VALUES(  9 ) = 14 */
/*        VALUES( 11 ) = 15 */
/*        VALUES( 13 ) = 16 */
/*        VALUES( 15 ) = 17 */
/*        VALUES( 17 ) = 18 */
/*        VALUES( 19 ) = 19 */
/*        VALUES( 21 ) = 20 */
/*        VALUES( 23 ) = 21 */
/*        VALUES( 25 ) = 22 */
/*        VALUES( 27 ) = 23 */
/*        VALUES( 29 ) = 24 */
/*        VALUES( 31 ) = 25 */
/*        VALUES( 33 ) = 26 */
/*        VALUES( 35 ) = 27 */
/*        VALUES( 37 ) = 28 */
/*        VALUES( 39 ) = 29 */
/*        VALUES( 41 ) = 30 */
/*        VALUES( 43 ) = 31 */

/*        CALL TPARSE ( '1972-JAN-1', VALUES(2),  ERROR ) */
/*        CALL TPARSE ( '1972-JUL-1', VALUES(4),  ERROR ) */
/*        CALL TPARSE ( '1973-JAN-1', VALUES(6),  ERROR ) */
/*        CALL TPARSE ( '1974-JAN-1', VALUES(8),  ERROR ) */
/*        CALL TPARSE ( '1975-JAN-1', VALUES(10), ERROR ) */
/*        CALL TPARSE ( '1976-JAN-1', VALUES(12), ERROR ) */
/*        CALL TPARSE ( '1977-JAN-1', VALUES(14), ERROR ) */
/*        CALL TPARSE ( '1978-JAN-1', VALUES(16), ERROR ) */
/*        CALL TPARSE ( '1979-JAN-1', VALUES(18), ERROR ) */
/*        CALL TPARSE ( '1980-JAN-1', VALUES(20), ERROR ) */
/*        CALL TPARSE ( '1981-JUL-1', VALUES(22), ERROR ) */
/*        CALL TPARSE ( '1982-JUL-1', VALUES(24), ERROR ) */
/*        CALL TPARSE ( '1983-JUL-1', VALUES(26), ERROR ) */
/*        CALL TPARSE ( '1985-JUL-1', VALUES(28), ERROR ) */
/*        CALL TPARSE ( '1988-JAN-1', VALUES(30), ERROR ) */
/*        CALL TPARSE ( '1990-JAN-1', VALUES(32), ERROR ) */
/*        CALL TPARSE ( '1991-JAN-1', VALUES(34), ERROR ) */
/*        CALL TPARSE ( '1992-JUL-1', VALUES(36), ERROR ) */
/*        CALL TPARSE ( '1993-JUL-1', VALUES(38), ERROR ) */
/*        CALL TPARSE ( '1994-JUL-1', VALUES(40), ERROR ) */
/*        CALL TPARSE ( '1996-JAN-1', VALUES(42), ERROR ) */
/*        CALL TPARSE ( '1997-JUL-1', VALUES(44), ERROR ) */

/*        CALL PDPOOL ( 'DELTET/DELTA_AT',  44, VALUES ) */


/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     W.L. Taber      (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    SPICELIB Version 8.0.0, 04-JUN-1999 (WLT) */

/*        Added the entry points PCPOOL, PDPOOL and PIPOOL to allow */
/*        direct insertion of data into the kernel pool without having */
/*        to read an external file. */

/*        Added the interface LMPOOL that allows SPICE */
/*        programs to load text kernels directly from memory instead */
/*        of requiring a text file. */

/*        Added the entry point SZPOOL to return kernel pool definition */
/*        parameters. */

/*        Added the entry point DVPOOL to allow the removal of a variable */
/*        from the kernel pool. */

/*        Added the entry point GNPOOL to allow users to determine */
/*        variables that are present in the kernel pool */

/* -& */
/* $ Index_Entries */

/*     Set the value of a numeric kernel pool variable */

/* -& */

/*     Standard SPICE error handling. */

    if (*n <= 0) {
	return 0;
    }
    if (return_()) {
	return 0;
    }
    chkin_("PIPOOL", (ftnlen)6);
    zzpini_(&first, &c__5003, &c__40000, &c__4000, begdat, begtxt, nmpool, 
	    dppool, chpool, namlst, datlst, &c__1000, &c__2000, watsym, 
	    watptr, watval, agents, active, notify, (ftnlen)10, (ftnlen)10, (
	    ftnlen)32, (ftnlen)32, (ftnlen)32, (ftnlen)32, (ftnlen)32);

/*     Find out where the name for this item is located */
/*     in the data tables. */

    zzgpnm_(namlst, nmpool, pnames, datlst, dppool, dpvals, chpool, chvals, 
	    name__, &gotit, &lookat, &nameat, (ftnlen)32, (ftnlen)80, 
	    name_len);
    if (failed_()) {
	chkout_("PIPOOL", (ftnlen)6);
	return 0;
    }

/*     Determine how much room is available for inserting new d.p.s */
/*     values into the kernel pool. */

    avail = lnknfn_(dppool);
    if (gotit) {

/*        If we found the specified variable in the kernel pool, we */
/*        may be able to free up some space before inserting data. */
/*        We need to take this into account when determining */
/*        the amount of free room in the pool. */

	datahd = datlst[(i__2 = nameat - 1) < 5003 && 0 <= i__2 ? i__2 : 
		s_rnge("datlst", i__2, "pool_", (ftnlen)6097)];
	if (datahd < 0) {

/*           No extra d.p.s will be freed.  We have whatever */
/*           free space is in the DPPOOL right now. */

	} else {

/*           Find out how many items are in the current */
/*           list of d.p. associated with the variable. */

	    tofree = 0;
	    node = datahd;
	    while(node > 0) {
		++tofree;
		node = dppool[(i__2 = (node << 1) + 10) < 80012 && 0 <= i__2 ?
			 i__2 : s_rnge("dppool", i__2, "pool_", (ftnlen)6114)]
			;
	    }

/*           Add the number we will free to the amount currently */
/*           free in the dp pool. */

	    avail += tofree;
	}
    }

/*     If the AVAIL for new data is less than the number of items */
/*     to be added, we just bail out here. */

    if (avail < *n) {
	if (! gotit) {

/*           We need to perform some clean up.  We've allocated */
/*           a new name but it has nothing in it. On the other hand */
/*           if we found it don't need to do anything because we've */
/*           only read from the pool. We haven't altered anything. */
/*           But in that case we'll never get into this block of code. */

	    zzcln_(&lookat, &nameat, namlst, datlst, nmpool, chpool, dppool);
	}
	setmsg_("There is not sufficient space available in the kernel pool "
		"to store the # items associated with the name #.  There is r"
		"oom to store only # items. ", (ftnlen)146);
	errint_("#", n, (ftnlen)1);
	errch_("#", name__, (ftnlen)1, name_len);
	errint_("#", &avail, (ftnlen)1);
	sigerr_("SPICE(NOMOREROOM)", (ftnlen)17);
	chkout_("PIPOOL", (ftnlen)6);
	return 0;
    }

/*     There is room to insert the data.  Free up any required */
/*     nodes. */

    if (gotit) {

/*        We need to free the data associated with this */
/*        variable.  But first make sure there will be room */
/*        to add data. */

	datahd = datlst[(i__2 = nameat - 1) < 5003 && 0 <= i__2 ? i__2 : 
		s_rnge("datlst", i__2, "pool_", (ftnlen)6169)];
	datlst[(i__2 = nameat - 1) < 5003 && 0 <= i__2 ? i__2 : s_rnge("datl"
		"st", i__2, "pool_", (ftnlen)6170)] = 0;
	if (datahd < 0) {

/*           This variable was character type we need to */
/*           free a linked list from the character data */
/*           pool. */

	    head = -datahd;
	    tail = -chpool[(i__2 = (head << 1) + 11) < 8012 && 0 <= i__2 ? 
		    i__2 : s_rnge("chpool", i__2, "pool_", (ftnlen)6180)];
	    lnkfsl_(&head, &tail, chpool);
	} else {

/*           This variable was numeric type. We need to */
/*           free a linked list from the numeric pool. */

	    head = datahd;
	    tail = -dppool[(i__2 = (head << 1) + 11) < 80012 && 0 <= i__2 ? 
		    i__2 : s_rnge("dppool", i__2, "pool_", (ftnlen)6191)];
	    lnkfsl_(&head, &tail, dppool);
	}
    }

/*     We have done all of the freeing and checking that */
/*     needs to be done.  Now add the data. */

    i__2 = *n;
    for (i__ = 1; i__ <= i__2; ++i__) {

/*        OK. See if there is room in */
/*        the numeric portion of the pool to store this value. */

	free = lnknfn_(dppool);
	if (free <= 0) {

/*           This branch of the code should never be exercised, */
/*           but it doesn't hurt to program in a redundant check. */

	    zzcln_(&lookat, &nameat, namlst, datlst, nmpool, chpool, dppool);
	    setmsg_("There is no room available for adding another numeric v"
		    "alue to the kernel pool.", (ftnlen)79);
	    sigerr_("SPICE(KERNELPOOLFULL)", (ftnlen)21);
	    chkout_("PIPOOL", (ftnlen)6);
	    return 0;
	}

/*        Allocate a node for storing this numeric value: */

	lnkan_(dppool, &dpnode);
	if (datlst[(i__1 = nameat - 1) < 5003 && 0 <= i__1 ? i__1 : s_rnge(
		"datlst", i__1, "pool_", (ftnlen)6232)] == 0) {

/*           There was no data for this name yet.  We make */
/*           DPNODE be the head of the data list for this name. */

	    datlst[(i__1 = nameat - 1) < 5003 && 0 <= i__1 ? i__1 : s_rnge(
		    "datlst", i__1, "pool_", (ftnlen)6238)] = dpnode;
	} else {

/*           Put this node after the tail of the current list. */

	    head = datlst[(i__1 = nameat - 1) < 5003 && 0 <= i__1 ? i__1 : 
		    s_rnge("datlst", i__1, "pool_", (ftnlen)6245)];
	    tail = -dppool[(i__1 = (head << 1) + 11) < 80012 && 0 <= i__1 ? 
		    i__1 : s_rnge("dppool", i__1, "pool_", (ftnlen)6246)];
	    lnkila_(&tail, &dpnode, dppool);
	}

/*        Finally insert this data item into the numeric buffer. */

	dpvals[(i__1 = dpnode - 1) < 40000 && 0 <= i__1 ? i__1 : s_rnge("dpv"
		"als", i__1, "pool_", (ftnlen)6255)] = (doublereal) ivals[i__ 
		- 1];
    }

/*     One last thing, see if this variable is being watched ... */

    sygetc_(name__, watsym, watptr, watval, &nfetch, notify + 192, &got, 
	    name_len, (ftnlen)32, (ftnlen)32, (ftnlen)32);

/*     ... if it is, add its associated agents to the list of */
/*     AGENTS to be notified of a watched variable update. */

    if (got) {
	copyc_(agents, active, (ftnlen)32, (ftnlen)32);
	validc_(&c__1000, &nfetch, notify, (ftnlen)32);
	unionc_(notify, active, agents, (ftnlen)32, (ftnlen)32, (ftnlen)32);
    }
    chkout_("PIPOOL", (ftnlen)6);
    return 0;
/* $Procedure LMPOOL ( Load variables from memory into the pool ) */

L_lmpool:
/* $ Abstract */

/*     Load the variables contained in an internal buffer into the */
/*     kernel pool. */

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

/*     KERNEL */

/* $ Keywords */

/*     CONSTANTS */
/*     FILES */

/* $ Declarations */

/*     CHARACTER*(*)         CVALS ( * ) */
/*     INTEGER               N */

/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  -------------------------------------------------- */
/*     CVALS      I   An array that contains a SPICE text kernel */
/*     N          I   The number of entries in CVALS. */

/* $ Detailed_Input */

/*     CVALS      is an array that contains lines of text that */
/*                could serve as a SPICE text kernel. */

/*     N          the number of entries in CVALS. */

/* $ Detailed_Output */

/*     None. */

/* $ Parameters */

/*     None. */

/* $ Exceptions */

/*     1) All exceptions are diagnosed by routines called by the */
/*        private routine ZZRVBF. */

/* $ Files */

/*     None. */

/* $ Particulars */

/*     This routine allows you to store a text kernel in an internal */
/*     array of your program and load this array into the kernel pool */
/*     without first storing its contents as a text kernel. */

/* $ Examples */


/*     Suppose that your application is not particularly sensitive */
/*     to the current number of leapseconds but that you would */
/*     still like to use a relatively recent leapseconds kernel */
/*     without requiring users to load a leapseconds kernel into */
/*     the program.  The example below shows how you might set up */
/*     the initialization portion of your program. */

/*        INTEGER               LNSIZE */
/*        PARAMETER           ( LNSIZE = 80 ) */

/*        CHARACTER*(LNSIZE)    TEXT ( 27 ) */

/*        TEXT(  1 ) = 'DELTET/DELTA_T_A =   32.184' */
/*        TEXT(  2 ) = 'DELTET/K         =    1.657D-3' */
/*        TEXT(  3 ) = 'DELTET/EB        =    1.671D-2' */
/*        TEXT(  4 ) = 'DELTET/M = (  6.239996D0   1.99096871D-7 )' */
/*        TEXT(  5 ) = 'DELTET/DELTA_AT  = ( 10,   @1972-JAN-1' */
/*        TEXT(  6 ) = '                     11,   @1972-JUL-1' */
/*        TEXT(  7 ) = '                     12,   @1973-JAN-1' */
/*        TEXT(  8 ) = '                     13,   @1974-JAN-1' */
/*        TEXT(  9 ) = '                     14,   @1975-JAN-1' */
/*        TEXT( 10 ) = '                     15,   @1976-JAN-1' */
/*        TEXT( 11 ) = '                     16,   @1977-JAN-1' */
/*        TEXT( 12 ) = '                     17,   @1978-JAN-1' */
/*        TEXT( 13 ) = '                     18,   @1979-JAN-1' */
/*        TEXT( 14 ) = '                     19,   @1980-JAN-1' */
/*        TEXT( 15 ) = '                     20,   @1981-JUL-1' */
/*        TEXT( 16 ) = '                     21,   @1982-JUL-1' */
/*        TEXT( 17 ) = '                     22,   @1983-JUL-1' */
/*        TEXT( 18 ) = '                     23,   @1985-JUL-1' */
/*        TEXT( 19 ) = '                     24,   @1988-JAN-1' */
/*        TEXT( 20 ) = '                     25,   @1990-JAN-1' */
/*        TEXT( 21 ) = '                     26,   @1991-JAN-1' */
/*        TEXT( 22 ) = '                     27,   @1992-JUL-1' */
/*        TEXT( 23 ) = '                     28,   @1993-JUL-1' */
/*        TEXT( 24 ) = '                     29,   @1994-JUL-1' */
/*        TEXT( 25 ) = '                     30,   @1996-JAN-1' */
/*        TEXT( 26 ) = '                     31,   @1997-JUL-1' */
/*        TEXT( 27 ) = '                     32,   @1999-JAN-1 )' */

/*        CALL LMPOOL ( TEXT, 27 ) */


/* $ Restrictions */

/*     None. */

/* $ Literature_References */

/*     None. */

/* $ Author_and_Institution */

/*     R.E. Thurman    (JPL) */
/*     I.M. Underwood  (JPL) */
/*     W.L. Taber      (JPL) */

/* $ Version */


/* -    SPICELIB Version 8.0.0, 04-JUN-1999 (WLT) */

/*        Added the entry points PCPOOL, PDPOOL and PIPOOL to allow */
/*        direct insertion of data into the kernel pool without having */
/*        to read an external file. */

/*        Added the interface LMPOOL that allows SPICE */
/*        programs to load text kernels directly from memory */
/*        instead of requiring a text file. */

/*        Added the entry point SZPOOL to return kernel pool definition */
/*        parameters. */

/*        Added the entry point DVPOOL to allow the removal of a variable */
/*        from the kernel pool. */

/*        Added the entry point GNPOOL to allow users to determine */
/*        variables that are present in the kernel pool */

/* -& */
/* $ Index_Entries */

/*     Load the kernel pool from an internal text buffer */

/* -& */

/*     Standard SPICE error handling. */

    if (return_()) {
	return 0;
    } else {
	chkin_("LMPOOL", (ftnlen)6);
    }

/*     Initialize the pool if necessary. */

    zzpini_(&first, &c__5003, &c__40000, &c__4000, begdat, begtxt, nmpool, 
	    dppool, chpool, namlst, datlst, &c__1000, &c__2000, watsym, 
	    watptr, watval, agents, active, notify, (ftnlen)10, (ftnlen)10, (
	    ftnlen)32, (ftnlen)32, (ftnlen)32, (ftnlen)32, (ftnlen)32);

/*     Read from the internal SPICE pool buffer */

    linnum = 1;
    zzrvbf_(cvals, n, &linnum, namlst, nmpool, pnames, datlst, dppool, dpvals,
	     chpool, chvals, varnam, &eof, cvals_len, (ftnlen)32, (ftnlen)80, 
	    (ftnlen)32);

/*     Read the variables in the file, one at a time. */

    while(! eof && ! failed_()) {
	if (s_cmp(varnam, " ", (ftnlen)32, (ftnlen)1) != 0) {

/*           See if this variable is being watched ... */

	    sygetc_(varnam, watsym, watptr, watval, &nfetch, notify + 192, &
		    got, (ftnlen)32, (ftnlen)32, (ftnlen)32, (ftnlen)32);

/*           ... if it is, add its associated agents to the list of */
/*           AGENTS to be notified of a watched variable update. */

	    if (got) {
		copyc_(agents, active, (ftnlen)32, (ftnlen)32);
		validc_(&c__1000, &nfetch, notify, (ftnlen)32);
		unionc_(notify, active, agents, (ftnlen)32, (ftnlen)32, (
			ftnlen)32);
	    }
	}
	zzrvbf_(cvals, n, &linnum, namlst, nmpool, pnames, datlst, dppool, 
		dpvals, chpool, chvals, varnam, &eof, cvals_len, (ftnlen)32, (
		ftnlen)80, (ftnlen)32);
    }

/*     That's it, the buffer supplied has been completely parsed */
/*     and placed into the kernel pool. */

    chkout_("LMPOOL", (ftnlen)6);
    return 0;
/* $Procedure      SZPOOL (Get size limitations of the kernel pool) */

L_szpool:
/* $ Abstract */

/*     Return the kernel pool size limitations. */

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

/*     KERNEL */

/* $ Keywords */

/*     CONSTANTS */
/*     FILES */

/* $ Declarations */

/*     CHARACTER*(*)         NAME */
/*     INTEGER               N */
/*     LOGICAL               FOUND */

/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  -------------------------------------------------- */
/*     NAME       I   Name of the parameter to be returned. */
/*     N          O   Value of parameter specified by NAME. */
/*     FOUND      O   .TRUE. if NAME is recognized. */

/* $ Detailed_Input */

/*     NAME       is the name of a kernel pool size parameter. */
/*                The following parameters may be specified. */

/*                   'MAXVAR' */
/*                   'MAXVAL' */
/*                   'MAXLIN' */
/*                   'MAXCHR' */
/*                   'MXNOTE' */
/*                   'MAXLEN' */
/*                   'MAXAGT' */

/*                See the main entry point for a description of the */
/*                meaning of these parameters.  Note that the case */
/*                of NAME is insignificant. */

/* $ Detailed_Output */

/*     N          is the value of the parameter specified by NAME. If */
/*                NAME is not one of the items specified above, N will */
/*                be returned with the value 0. */

/*     FOUND      is TRUE if the parameter is recognized FALSE if it */
/*                is not. */

/* $ Parameters */

/*     None. */

/* $ Exceptions */

/*     1) If the specified parameter is not recognized the value of N */
/*        returned will be zero and FOUND will be set to FALSE. */

/* $ Files */

/*     None. */

/* $ Particulars */

/*     This routine provides the a programmatic interface to the */
/*     parameters used to define the kernel pool.  It is not */
/*     anticipated that most kernel pool users will need to use this */
/*     routine. */

/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     None. */

/* $ Literature_References */

/*     None. */

/* $ Author_and_Institution */

/*     W.L. Taber  (JPL) */
/*     H.W. Taylor (ACT) */

/* $ Version */

/* -    SPICELIB Version 8.0.0, 04-JUN-1999 (WLT)(HWT) */

/*        Added the entry points PCPOOL, PDPOOL and PIPOOL to allow */
/*        direct insertion of data into the kernel pool without having */
/*        to read an external file. */

/*        Added the interface LMPOOL that allows SPICE */
/*        programs to load text kernels directly from memory */
/*        instead of requiring a text file. */

/*        Added the entry point SZPOOL to return kernel pool definition */
/*        parameters. */

/*        Added the entry point DVPOOL to allow the removal of a variable */
/*        from the kernel pool. */

/*        Added the entry point GNPOOL to allow users to determine */
/*        variables that are present in the kernel pool */

/* -& */
/* $ Index_Entries */

/*     return a kernel pool definition parameter */

/* -& */

/*     Standard SPICE error handling. */

    if (return_()) {
	return 0;
    }
    chkin_("SZPOOL", (ftnlen)6);
    *found = TRUE_;
    if (eqstr_(name__, "MAXVAR", name_len, (ftnlen)6)) {
	*n = 5003;
    } else if (eqstr_(name__, "MAXVAL", name_len, (ftnlen)6)) {
	*n = 40000;
    } else if (eqstr_(name__, "MAXLIN", name_len, (ftnlen)6)) {
	*n = 4000;
    } else if (eqstr_(name__, "MAXCHR", name_len, (ftnlen)6)) {
	*n = 80;
    } else if (eqstr_(name__, "MXNOTE", name_len, (ftnlen)6)) {
	*n = 2000;
    } else if (eqstr_(name__, "MAXLEN", name_len, (ftnlen)6)) {
	*n = 32;
    } else if (eqstr_(name__, "MAXAGT", name_len, (ftnlen)6)) {
	*n = 1000;
    } else {
	*n = 0;
	*found = FALSE_;
    }
    chkout_("SZPOOL", (ftnlen)6);
    return 0;
/* $Procedure     DVPOOL  ( Delete a variable from the kernel pool ) */

L_dvpool:
/* $ Abstract */

/*     Delete a variable from the kernel pool. */

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

/*     KERNEL */

/* $ Keywords */

/*     CONSTANTS */
/*     FILES */

/* $ Declarations */

/*     CHARACTER*(*)         NAME */

/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  -------------------------------------------------- */
/*     NAME       I   Name of the variable to be deleted. */

/* $ Detailed_Input */

/*     NAME       is the name of the kernel pool variable to delete. */
/*                The name and associated values are removed from the */
/*                kernel pool, freeing the occupied space. */

/*                If a watches are set on the variable designated by */
/*                NAME, the corresponding agents are placed on the list */
/*                of agents to be notified of a kernel variable update. */

/* $ Detailed_Output */

/*     None. */

/* $ Parameters */

/*     None. */

/* $ Exceptions */

/*     1) If the specified variable is not present in the kernel pool, */
/*        this routine simply returns.  No error is signaled. */

/* $ Files */

/*     None. */

/* $ Particulars */

/*     This routine enables users to selectively remove variables from */
/*     the kernel pool, as opposed to having to clear the pool and */
/*     reload it. */

/*     Note that it is not necessary to remove kernel variables in order */
/*     to simply update them; this routine should be used only when */
/*     variables are to be removed. */

/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     1) Remove triaxial radii of Jupiter from the kernel pool. */

/*           CALL DVPOOL ( 'BODY599_RADII' ) */

/* $ Literature_References */

/*     None. */

/* $ Author_and_Institution */

/*     N.J. Bachman  (JPL) */
/*     W.L. Taber    (JPL) */

/* $ Version */

/* -    SPICELIB Version 8.1.0, 22-DEC-2004 (NJB) */

/*        Bug fix:  corrected logic for determining when a */
/*        conflict resolution list is non-empty. */

/*        Corrected an in-line comment relating to finding the */
/*        head node of the conflict resolution list for NAME. */

/* -    SPICELIB Version 8.0.0, 04-JUN-1999 (NJB) (WLT) */

/*        Added the entry points PCPOOL, PDPOOL and PIPOOL to allow */
/*        direct insertion of data into the kernel pool without having */
/*        to read an external file. */

/*        Added the interface LMPOOL that allows SPICE */
/*        programs to load text kernels directly from memory */
/*        instead of requiring a text file. */

/*        Added the entry point SZPOOL to return kernel pool definition */
/*        parameters. */

/*        Added the entry point DVPOOL to allow the removal of a variable */
/*        from the kernel pool. */

/*        Added the entry point GNPOOL to allow users to determine */
/*        variables that are present in the kernel pool */

/* -& */
/* $ Index_Entries */

/*     delete a kernel pool variable */

/* -& */
/* $ Revisions */

/* -    SPICELIB Version 8.1.0, 22-DEC-2004 (NJB) */

/*        Bug fix:  corrected logic for determining when a */
/*        conflict resolution list is non-empty.  The test */

/*           IF ( NAMEAT .LT. 0 ) THEN */

/*        formerly tested the variable NODE instead of NAMEAT. */


/*        Corrected an in-line comment relating to finding the */
/*        head node of the conflict resolution list for NAME. */

/* -& */

/*     Standard SPICE error handling. */

    if (return_()) {
	return 0;
    } else {
	chkin_("DVPOOL", (ftnlen)6);
    }

/*     Initialize the kernel pool if necessary. */

    zzpini_(&first, &c__5003, &c__40000, &c__4000, begdat, begtxt, nmpool, 
	    dppool, chpool, namlst, datlst, &c__1000, &c__2000, watsym, 
	    watptr, watval, agents, active, notify, (ftnlen)10, (ftnlen)10, (
	    ftnlen)32, (ftnlen)32, (ftnlen)32, (ftnlen)32, (ftnlen)32);

/*     Locate the variable name in the hash table.  If the variable */
/*     is not present, just return. */


/*     Compute the hash value of this name. */

    lookat = zzhash_(name__, name_len);

/*     Now see if there is a non-empty conflict resolution list for the */
/*     input string NAME.  If so, NAMLST(LOOKAT) contains the head node */
/*     of the conflict resolution list; this node is a postive value. */

    if (namlst[(i__2 = lookat - 1) < 5003 && 0 <= i__2 ? i__2 : s_rnge("naml"
	    "st", i__2, "pool_", (ftnlen)6912)] == 0) {
	chkout_("DVPOOL", (ftnlen)6);
	return 0;
    }

/*     If were are still here NAMLST(LOOKAT) is the first node of */
/*     a conflict resolution list.  See if the NAME corresposnding */
/*     to this node is the one we are looking for. */

    nameat = namlst[(i__2 = lookat - 1) < 5003 && 0 <= i__2 ? i__2 : s_rnge(
	    "namlst", i__2, "pool_", (ftnlen)6923)];
    succes = s_cmp(name__, pnames + (((i__2 = nameat - 1) < 5003 && 0 <= i__2 
	    ? i__2 : s_rnge("pnames", i__2, "pool_", (ftnlen)6924)) << 5), 
	    name_len, (ftnlen)32) == 0;
    while(! succes) {
	nameat = nmpool[(i__2 = (nameat << 1) + 10) < 10018 && 0 <= i__2 ? 
		i__2 : s_rnge("nmpool", i__2, "pool_", (ftnlen)6928)];
	if (nameat < 0) {
	    chkout_("DVPOOL", (ftnlen)6);
	    return 0;
	}
	succes = s_cmp(name__, pnames + (((i__2 = nameat - 1) < 5003 && 0 <= 
		i__2 ? i__2 : s_rnge("pnames", i__2, "pool_", (ftnlen)6937)) 
		<< 5), name_len, (ftnlen)32) == 0;
    }

/*     Ok, the variable's here.  The head node of its value list is */
/*     DATLST(NAMEAT).  Delete the list pointing to the associated */
/*     values.  This list is in the numeric pool DPPOOL if the head */
/*     node is positive; otherwise the list is in the character pool */
/*     CHPOOL. */


    zzcln_(&lookat, &nameat, namlst, datlst, nmpool, chpool, dppool);

/*     For consistency with CLPOOL, blank out the PNAMES entry containing */
/*     the name of this variable.  This is a bit of a flourish since */
/*     when errors occur during the population of the kernel pool, PNAMES */
/*     is not cleaned out */

    s_copy(pnames + (((i__2 = nameat - 1) < 5003 && 0 <= i__2 ? i__2 : s_rnge(
	    "pnames", i__2, "pool_", (ftnlen)6958)) << 5), " ", (ftnlen)32, (
	    ftnlen)1);

/*     There may be agents watching the variable we just wiped out.  If */
/*     so, add these agents to the list of agents to be notified of a */
/*     watched variable update. */

    sygetc_(name__, watsym, watptr, watval, &nfetch, notify + 192, &got, 
	    name_len, (ftnlen)32, (ftnlen)32, (ftnlen)32);
    if (got) {
	copyc_(agents, active, (ftnlen)32, (ftnlen)32);
	validc_(&c__1000, &nfetch, notify, (ftnlen)32);
	unionc_(notify, active, agents, (ftnlen)32, (ftnlen)32, (ftnlen)32);
    }
    chkout_("DVPOOL", (ftnlen)6);
    return 0;
/* $Procedure      GNPOOL (Get names of kernel pool variables) */

L_gnpool:
/* $ Abstract */

/*     Return names of kernel variables matching a specified template. */

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

/*     KERNEL */

/* $ Keywords */

/*     CONSTANTS */
/*     FILES */

/* $ Declarations */

/*     CHARACTER*(*)         NAME */
/*     INTEGER               START */
/*     INTEGER               ROOM */
/*     INTEGER               N */
/*     CHARACTER*(*)         CVALS    ( * ) */
/*     LOGICAL               FOUND */

/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  -------------------------------------------------- */
/*     NAME       I   Template that names should match. */
/*     START      I   Index of first matching name to retrieve. */
/*     ROOM       I   The largest number of values to return. */
/*     N          O   Number of values returned for NAME. */
/*     CVALS      O   Kernel pool variables whose names match NAME. */
/*     FOUND      O   True if there is at least one match. */

/* $ Detailed_Input */

/*     NAME       is a MATCHI template which will be used when searching */
/*                for variable names in the kernel pool.  The characters */
/*                '*' and '%' are used for the wild string and wild */
/*                characters respectively.  For details of string */
/*                pattern matching see the header of the routine MATCHI. */


/*     START      is the index of the first variable name to return that */
/*                matches the NAME template.  The matching names are */
/*                assigned indices ranging from 1 to NVAR, where NVAR is */
/*                the number of matching names.  The index of a name does */
/*                not indicate how it compares alphabetically to another */
/*                name. */

/*                If START is less than 1, it will be treated as 1.  If */
/*                START is greater than the total number of matching */
/*                variable names, no values will be returned and N will */
/*                be set to zero.  However, FOUND will still be set to */
/*                .TRUE. */


/*     ROOM       is the maximum number of variable names that should */
/*                be returned for this template.  If ROOM is less than 1 */
/*                the error 'SPICE(BADARRAYSIZE)' will be signaled. */

/* $ Detailed_Output */

/*     N          is the number of variable names matching NAME that are */
/*                returned.  It will always be less than or equal to */
/*                ROOM. */

/*                If no variable names match NAME, N is set to zero. */


/*     CVALS      is an array of kernel pool variables whose names match */
/*                the template NAME and which have indices ranging from */
/*                START to START+N-1. */

/*                Note that in general the names returned in CVALS are */
/*                not sorted. */

/*                If no variables match NAME, no values are assigned to */
/*                the elements of CVALS. */

/*                If the length of CVALS is less than the length of the */
/*                variable names, the values returned will be truncated */
/*                on the right. To ensure that names are not truncated, */
/*                CVALS should be declared to be at least */
/*                CHARACTER*(32). */


/*     FOUND      is TRUE if the some variable name in the kernel pool */
/*                matches NAME, FALSE if it is not. */

/* $ Parameters */

/*     None. */

/* $ Exceptions */

/*     1) If the value of ROOM is less than one the error */
/*        'SPICE(BADARRAYSIZE)' is signaled. */

/*     2) If CVALS has declared length less than the size of a */
/*        name to be returned, the name will be truncated on */
/*        the right.  See MAXCHR for the maximum stored size of */
/*        string variables. */

/* $ Files */

/*     None. */

/* $ Particulars */

/*     This routine provides the user interface for retrieving the names */
/*     of kernel pool variables. This interface allows you to retrieve */
/*     the names matching a template via multiple accesses.  Under some */
/*     circumstances this alleviates the problem of having to know in */
/*     advance the maximum amount of space needed to accommodate all */
/*     matching names. */

/*     However, this method of access does come with a price. It is */
/*     always more efficient to retrieve all of the data associated with */
/*     a kernel pool variable in one call than it is to retrieve it in */
/*     sections.  The parameter MAXVAR defines the upper bound on the */
/*     number of possible matching names. */

/* $ Examples */


/*     The following code fragment demonstrates how the names of kernel */
/*     pool variables matching a template can be retrieved in pieces. */

/*     First we need some declarations. */

/*        INTEGER               ROOM */
/*        PARAMETER           ( ROOM = 3 ) */

/*        CHARACTER*(3)         INDENT */
/*        CHARACTER*(80)        CVALS  (ROOM) */
/*        CHARACTER*(8)         VARNAM */

/*        INTEGER               START */
/*        INTEGER               N */

/*        LOGICAL               FOUND */


/*     Next load the data in the file 'typical.ker' into the */
/*     kernel pool. */

/*        CALL LDPOOL ( 'typical.ker' ) */

/*     Next we shall print the names of kernel variables that match the */
/*     template 'BODY599*'. */

/*        VARNAM = 'BODY599*' */
/*        INDENT = ' ' */
/*        START  =  1 */

/*        CALL GNPOOL ( VARNAM, START, ROOM, N, CVALS, FOUND ) */

/*        IF ( .NOT. FOUND ) THEN */

/*           WRITE (*,*) 'There are no matching variables ' // */
/*       .               'in the kernel pool.' */
/*        ELSE */

/*           WRITE (*,*) 'Kernel pool variables:' */
/*           WRITE (*,*) */

/*           DO I = 1, N */
/*              WRITE (*,*) INDENT, CVALS(I) */
/*           END DO */

/*           DO WHILE ( N .EQ. ROOM ) */

/*              START = START + N */
/*              CALL GNPOOL ( VARNAM, START, ROOM, N, CVALS, FOUND ) */

/*              DO I = 1, N */
/*                 WRITE (*,*) INDENT, CVALS(I) */
/*              END DO */

/*           END DO */

/*        END IF */

/* $ Restrictions */

/*     None. */

/* $ Literature_References */

/*     None. */

/* $ Author_and_Institution */

/*     W.L. Taber  (JPL) */

/* $ Version */


/* -    SPICELIB Version 8.0.0, 04-JUN-1999 (WLT) */

/*        Added the entry points PCPOOL, PDPOOL and PIPOOL to allow */
/*        direct insertion of data into the kernel pool without having */
/*        to read an external file. */

/*        Added the interface LMPOOL that allows SPICE */
/*        programs to load text kernels directly from memory */
/*        instead of requiring a text file. */

/*        Added the entry point SZPOOL to return kernel pool definition */
/*        parameters. */

/*        Added the entry point DVPOOL to allow the removal of a variable */
/*        from the kernel pool. */

/*        Added the entry point GNPOOL to allow users to determine */
/*        variables that are present in the kernel pool */

/* -& */
/* $ Index_Entries */

/*     return names of kernel pool variables matching a template */

/* -& */

/*     Standard SPICE error handling. */

    if (return_()) {
	return 0;
    }
    chkin_("GNPOOL", (ftnlen)6);

/*     Initialize the pool if necessary. */

    zzpini_(&first, &c__5003, &c__40000, &c__4000, begdat, begtxt, nmpool, 
	    dppool, chpool, namlst, datlst, &c__1000, &c__2000, watsym, 
	    watptr, watval, agents, active, notify, (ftnlen)10, (ftnlen)10, (
	    ftnlen)32, (ftnlen)32, (ftnlen)32, (ftnlen)32, (ftnlen)32);

/*     Perform the one obvious error check first. */

    if (*room < 1) {
	setmsg_("The amount of room specified as available for output in the"
		" output array was: #.  The amount of room must be positive. ",
		 (ftnlen)119);
	errint_("#", room, (ftnlen)1);
	sigerr_("SPICE(BADARRAYSIZE)", (ftnlen)19);
	chkout_("GNPOOL", (ftnlen)6);
	return 0;
    }

/*     So far we've encountered no matching names. */

    hits = 0;
    *n = 0;
    begin = max(1,*start);
    for (k = 1; k <= 5003; ++k) {

/*        See if there is any variable associated with this hash value. */

	nnode = namlst[(i__2 = k - 1) < 5003 && 0 <= i__2 ? i__2 : s_rnge(
		"namlst", i__2, "pool_", (ftnlen)7284)];
	while(nnode > 0) {

/*           There is some name list associated with this node. See if */
/*           it the current one matches the supplied template. */

	    if (matchi_(pnames + (((i__2 = nnode - 1) < 5003 && 0 <= i__2 ? 
		    i__2 : s_rnge("pnames", i__2, "pool_", (ftnlen)7291)) << 
		    5), name__, "*", "%", (ftnlen)32, name_len, (ftnlen)1, (
		    ftnlen)1)) {

/*              We've got a match.  Record this fact and if we have */
/*              reached (or passed) the starting point, put this name */
/*              on the output list. */

		++hits;
		if (hits >= *start) {
		    if (*n < *room) {
			++(*n);
			s_copy(cvals + (*n - 1) * cvals_len, pnames + (((i__2 
				= nnode - 1) < 5003 && 0 <= i__2 ? i__2 : 
				s_rnge("pnames", i__2, "pool_", (ftnlen)7304))
				 << 5), cvals_len, (ftnlen)32);
		    }

/*                 If we've filled up the buffer, we may as well */
/*                 quit now. */

		    if (*n == *room) {
			*found = TRUE_;
			chkout_("GNPOOL", (ftnlen)6);
			return 0;
		    }
		}
	    }

/*           Get the next name for this node. */

	    nnode = nmpool[(i__2 = (nnode << 1) + 10) < 10018 && 0 <= i__2 ? 
		    i__2 : s_rnge("nmpool", i__2, "pool_", (ftnlen)7323)];
	}

/*        Advance to the next hash value. */

    }
    *found = hits > 0;
    chkout_("GNPOOL", (ftnlen)6);
    return 0;
} /* pool_ */

/* Subroutine */ int pool_(char *kernel, integer *unit, char *name__, char *
	names, integer *nnames, char *agent, integer *n, doublereal *values, 
	logical *found, logical *update, integer *start, integer *room, char *
	cvals, integer *ivals, char *type__, ftnlen kernel_len, ftnlen 
	name_len, ftnlen names_len, ftnlen agent_len, ftnlen cvals_len, 
	ftnlen type_len)
{
    return pool_0_(0, kernel, unit, name__, names, nnames, agent, n, values, 
	    found, update, start, room, cvals, ivals, type__, kernel_len, 
	    name_len, names_len, agent_len, cvals_len, type_len);
    }

/* Subroutine */ int clpool_(void)
{
    return pool_0_(1, (char *)0, (integer *)0, (char *)0, (char *)0, (integer 
	    *)0, (char *)0, (integer *)0, (doublereal *)0, (logical *)0, (
	    logical *)0, (integer *)0, (integer *)0, (char *)0, (integer *)0, 
	    (char *)0, (ftnint)0, (ftnint)0, (ftnint)0, (ftnint)0, (ftnint)0, 
	    (ftnint)0);
    }

/* Subroutine */ int ldpool_(char *kernel, ftnlen kernel_len)
{
    return pool_0_(2, kernel, (integer *)0, (char *)0, (char *)0, (integer *)
	    0, (char *)0, (integer *)0, (doublereal *)0, (logical *)0, (
	    logical *)0, (integer *)0, (integer *)0, (char *)0, (integer *)0, 
	    (char *)0, kernel_len, (ftnint)0, (ftnint)0, (ftnint)0, (ftnint)0,
	     (ftnint)0);
    }

/* Subroutine */ int rtpool_(char *name__, integer *n, doublereal *values, 
	logical *found, ftnlen name_len)
{
    return pool_0_(3, (char *)0, (integer *)0, name__, (char *)0, (integer *)
	    0, (char *)0, n, values, found, (logical *)0, (integer *)0, (
	    integer *)0, (char *)0, (integer *)0, (char *)0, (ftnint)0, 
	    name_len, (ftnint)0, (ftnint)0, (ftnint)0, (ftnint)0);
    }

/* Subroutine */ int expool_(char *name__, logical *found, ftnlen name_len)
{
    return pool_0_(4, (char *)0, (integer *)0, name__, (char *)0, (integer *)
	    0, (char *)0, (integer *)0, (doublereal *)0, found, (logical *)0, 
	    (integer *)0, (integer *)0, (char *)0, (integer *)0, (char *)0, (
	    ftnint)0, name_len, (ftnint)0, (ftnint)0, (ftnint)0, (ftnint)0);
    }

/* Subroutine */ int wrpool_(integer *unit)
{
    return pool_0_(5, (char *)0, unit, (char *)0, (char *)0, (integer *)0, (
	    char *)0, (integer *)0, (doublereal *)0, (logical *)0, (logical *)
	    0, (integer *)0, (integer *)0, (char *)0, (integer *)0, (char *)0,
	     (ftnint)0, (ftnint)0, (ftnint)0, (ftnint)0, (ftnint)0, (ftnint)0)
	    ;
    }

/* Subroutine */ int swpool_(char *agent, integer *nnames, char *names, 
	ftnlen agent_len, ftnlen names_len)
{
    return pool_0_(6, (char *)0, (integer *)0, (char *)0, names, nnames, 
	    agent, (integer *)0, (doublereal *)0, (logical *)0, (logical *)0, 
	    (integer *)0, (integer *)0, (char *)0, (integer *)0, (char *)0, (
	    ftnint)0, (ftnint)0, names_len, agent_len, (ftnint)0, (ftnint)0);
    }

/* Subroutine */ int cvpool_(char *agent, logical *update, ftnlen agent_len)
{
    return pool_0_(7, (char *)0, (integer *)0, (char *)0, (char *)0, (integer 
	    *)0, agent, (integer *)0, (doublereal *)0, (logical *)0, update, (
	    integer *)0, (integer *)0, (char *)0, (integer *)0, (char *)0, (
	    ftnint)0, (ftnint)0, (ftnint)0, agent_len, (ftnint)0, (ftnint)0);
    }

/* Subroutine */ int gcpool_(char *name__, integer *start, integer *room, 
	integer *n, char *cvals, logical *found, ftnlen name_len, ftnlen 
	cvals_len)
{
    return pool_0_(8, (char *)0, (integer *)0, name__, (char *)0, (integer *)
	    0, (char *)0, n, (doublereal *)0, found, (logical *)0, start, 
	    room, cvals, (integer *)0, (char *)0, (ftnint)0, name_len, (
	    ftnint)0, (ftnint)0, cvals_len, (ftnint)0);
    }

/* Subroutine */ int gdpool_(char *name__, integer *start, integer *room, 
	integer *n, doublereal *values, logical *found, ftnlen name_len)
{
    return pool_0_(9, (char *)0, (integer *)0, name__, (char *)0, (integer *)
	    0, (char *)0, n, values, found, (logical *)0, start, room, (char *
	    )0, (integer *)0, (char *)0, (ftnint)0, name_len, (ftnint)0, (
	    ftnint)0, (ftnint)0, (ftnint)0);
    }

/* Subroutine */ int gipool_(char *name__, integer *start, integer *room, 
	integer *n, integer *ivals, logical *found, ftnlen name_len)
{
    return pool_0_(10, (char *)0, (integer *)0, name__, (char *)0, (integer *)
	    0, (char *)0, n, (doublereal *)0, found, (logical *)0, start, 
	    room, (char *)0, ivals, (char *)0, (ftnint)0, name_len, (ftnint)0,
	     (ftnint)0, (ftnint)0, (ftnint)0);
    }

/* Subroutine */ int dtpool_(char *name__, logical *found, integer *n, char *
	type__, ftnlen name_len, ftnlen type_len)
{
    return pool_0_(11, (char *)0, (integer *)0, name__, (char *)0, (integer *)
	    0, (char *)0, n, (doublereal *)0, found, (logical *)0, (integer *)
	    0, (integer *)0, (char *)0, (integer *)0, type__, (ftnint)0, 
	    name_len, (ftnint)0, (ftnint)0, (ftnint)0, type_len);
    }

/* Subroutine */ int pcpool_(char *name__, integer *n, char *cvals, ftnlen 
	name_len, ftnlen cvals_len)
{
    return pool_0_(12, (char *)0, (integer *)0, name__, (char *)0, (integer *)
	    0, (char *)0, n, (doublereal *)0, (logical *)0, (logical *)0, (
	    integer *)0, (integer *)0, cvals, (integer *)0, (char *)0, (
	    ftnint)0, name_len, (ftnint)0, (ftnint)0, cvals_len, (ftnint)0);
    }

/* Subroutine */ int pdpool_(char *name__, integer *n, doublereal *values, 
	ftnlen name_len)
{
    return pool_0_(13, (char *)0, (integer *)0, name__, (char *)0, (integer *)
	    0, (char *)0, n, values, (logical *)0, (logical *)0, (integer *)0,
	     (integer *)0, (char *)0, (integer *)0, (char *)0, (ftnint)0, 
	    name_len, (ftnint)0, (ftnint)0, (ftnint)0, (ftnint)0);
    }

/* Subroutine */ int pipool_(char *name__, integer *n, integer *ivals, ftnlen 
	name_len)
{
    return pool_0_(14, (char *)0, (integer *)0, name__, (char *)0, (integer *)
	    0, (char *)0, n, (doublereal *)0, (logical *)0, (logical *)0, (
	    integer *)0, (integer *)0, (char *)0, ivals, (char *)0, (ftnint)0,
	     name_len, (ftnint)0, (ftnint)0, (ftnint)0, (ftnint)0);
    }

/* Subroutine */ int lmpool_(char *cvals, integer *n, ftnlen cvals_len)
{
    return pool_0_(15, (char *)0, (integer *)0, (char *)0, (char *)0, (
	    integer *)0, (char *)0, n, (doublereal *)0, (logical *)0, (
	    logical *)0, (integer *)0, (integer *)0, cvals, (integer *)0, (
	    char *)0, (ftnint)0, (ftnint)0, (ftnint)0, (ftnint)0, cvals_len, (
	    ftnint)0);
    }

/* Subroutine */ int szpool_(char *name__, integer *n, logical *found, ftnlen 
	name_len)
{
    return pool_0_(16, (char *)0, (integer *)0, name__, (char *)0, (integer *)
	    0, (char *)0, n, (doublereal *)0, found, (logical *)0, (integer *)
	    0, (integer *)0, (char *)0, (integer *)0, (char *)0, (ftnint)0, 
	    name_len, (ftnint)0, (ftnint)0, (ftnint)0, (ftnint)0);
    }

/* Subroutine */ int dvpool_(char *name__, ftnlen name_len)
{
    return pool_0_(17, (char *)0, (integer *)0, name__, (char *)0, (integer *)
	    0, (char *)0, (integer *)0, (doublereal *)0, (logical *)0, (
	    logical *)0, (integer *)0, (integer *)0, (char *)0, (integer *)0, 
	    (char *)0, (ftnint)0, name_len, (ftnint)0, (ftnint)0, (ftnint)0, (
	    ftnint)0);
    }

/* Subroutine */ int gnpool_(char *name__, integer *start, integer *room, 
	integer *n, char *cvals, logical *found, ftnlen name_len, ftnlen 
	cvals_len)
{
    return pool_0_(18, (char *)0, (integer *)0, name__, (char *)0, (integer *)
	    0, (char *)0, n, (doublereal *)0, found, (logical *)0, start, 
	    room, cvals, (integer *)0, (char *)0, (ftnint)0, name_len, (
	    ftnint)0, (ftnint)0, cvals_len, (ftnint)0);
    }

