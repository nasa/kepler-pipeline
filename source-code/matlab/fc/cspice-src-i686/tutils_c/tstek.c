/* tstek.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__5000 = 5000;
static integer c__100 = 100;
static integer c__20 = 20;

/* $Procedure  TSTEK ( Produce EK column entries for EK testing ) */
/* Subroutine */ int tstek_(char *file, integer *fileno, integer *mxrows, 
	logical *load, integer *handle, ftnlen file_len)
{
    /* Initialized data */

    static char tables[64*6] = "SCALAR_1                                    "
	    "                    " "SCALAR_2                                 "
	    "                       " "SCALAR_3                              "
	    "                          " "SCALAR_4                           "
	    "                             " "VECTOR_1                        "
	    "                                " "VECTOR_2                     "
	    "                                   ";

    /* System generated locals */
    integer i__1, i__2, i__3, i__4, i__5, i__6, i__7, i__8, i__9, i__10;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    static integer dims__[100], i__, p;
    extern /* Subroutine */ int eklef_(char *, integer *, ftnlen);
    static char decls[200*100];
    extern /* Subroutine */ int chkin_(char *, ftnlen), maxai_(integer *, 
	    integer *, integer *, integer *), ekcls_(integer *);
    static integer tabno;
    static char cvals[100*50000];
    static doublereal dvals[50000];
    static integer colno, segno;
    extern /* Subroutine */ int repmi_(char *, char *, integer *, char *, 
	    ftnlen, ftnlen, ftnlen), ekopn_(char *, char *, integer *, 
	    integer *, ftnlen, ftnlen);
    static integer ivals[50000], ncols;
    static doublereal tvals[50000];
    static integer nrows;
    extern /* Subroutine */ int ekaclc_(integer *, integer *, char *, char *, 
	    integer *, logical *, integer *, integer *, ftnlen, ftnlen), 
	    ekacld_(integer *, integer *, char *, doublereal *, integer *, 
	    logical *, integer *, integer *, ftnlen), ekacli_(integer *, 
	    integer *, char *, integer *, integer *, logical *, integer *, 
	    integer *, ftnlen), ekffld_(integer *, integer *, integer *), 
	    ekifld_(integer *, char *, integer *, integer *, char *, char *, 
	    integer *, integer *, ftnlen, ftnlen, ftnlen);
    static char ifname[60];
    extern /* Subroutine */ int delfil_(char *, ftnlen);
    static char cnames[32*100], fatbuf[1024*2000];
    static integer cclass[100], ncomch;
    static logical indexd[100];
    extern /* Subroutine */ int erract_(char *, char *, ftnlen, ftnlen);
    static logical nlflgs[5000];
    extern /* Subroutine */ int errdev_(char *, char *, ftnlen, ftnlen), 
	    sigerr_(char *, ftnlen);
    static integer wkindx[5000];
    static logical nullok[100];
    extern /* Subroutine */ int setmsg_(char *, ftnlen);
    static integer dtypes[100], maxstl, stlens[100], segtyp;
    extern logical exists_(char *, ftnlen);
    static integer rcptrs[5000];
    extern /* Subroutine */ int tstsch_(char *, integer *, integer *, integer 
	    *, integer *, char *, integer *, integer *, integer *, integer *, 
	    logical *, logical *, char *, ftnlen, ftnlen, ftnlen), errprt_(
	    char *, char *, ftnlen, ftnlen), errint_(char *, integer *, 
	    ftnlen), chkout_(char *, ftnlen);
    static integer entszs[5000];
    extern /* Subroutine */ int tstent_(integer *, char *, integer *, char *, 
	    integer *, integer *, integer *, char *, doublereal *, integer *, 
	    doublereal *, logical *, ftnlen, ftnlen, ftnlen), tfiles_(char *, 
	    ftnlen);
    static integer loc;

/* $ Abstract */

/*     Create EK files for testing the EK writing and reading routines. */

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

/*     UTILITY */

/* $ Declarations */
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


/*     Include Section:  EK Column Name Size */

/*        ekcnamsz.inc Version 1    17-JAN-1995 (NJB) */


/*     Size of column name, in characters. */


/*     End Include Section:  EK Column Name Size */

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


/*     Include Section:  EK General Limit Parameters */

/*        ekglimit.inc  Version 1    21-MAY-1995 (NJB) */


/*     This file contains general limits for the EK system. */

/*     MXCLSG is the maximum number of columns allowed in a segment. */
/*     This limit applies to logical tables as well, since all segments */
/*     in a logical table must have the same column definitions. */


/*     End Include Section:  EK General Limit Parameters */

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


/*     Include Section:  EK Query Limit Parameters */

/*        ekqlimit.inc  Version 3    16-NOV-1995 (NJB) */

/*           Parameter MAXCON increased to 1000. */

/*        ekqlimit.inc  Version 2    01-AUG-1995 (NJB) */

/*           Updated to support SELECT clause. */


/*        ekqlimit.inc  Version 1    07-FEB-1995 (NJB) */


/*     These limits apply to character string queries input to the */
/*     EK scanner.  This limits are part of the EK system's user */
/*     interface:  the values should be advertised in the EK required */
/*     reading document. */


/*     Maximum length of an input query:  MAXQRY.  This value is */
/*     currently set to twenty-five 80-character lines. */


/*     Maximum number of columns that may be listed in the */
/*     `order-by clause' of a query:  MAXSEL.  MAXSEL = 50. */


/*     Maximum number of tables that may be listed in the `FROM */
/*     clause' of a query: MAXTAB. */


/*     Maximum number of relational expressions that may be listed */
/*     in the `constraint clause' of a query: MAXCON. */

/*     This limit applies to a query when it is represented in */
/*     `normalized form': that is, the constraints have been */
/*     expressed as a disjunction of conjunctions of relational */
/*     expressions. The number of relational expressions in a query */
/*     that has been expanded in this fashion may be greater than */
/*     the number of relations in the query as orginally written. */
/*     For example, the expression */

/*             ( ( A LT 1 ) OR ( B GT 2 ) ) */
/*        AND */
/*             ( ( C NE 3 ) OR ( D EQ 4 ) ) */

/*     which contains 4 relational expressions, expands to the */
/*     equivalent normalized constraint */

/*             (  ( A LT 1 ) AND ( C NE 3 )  ) */
/*        OR */
/*             (  ( A LT 1 ) AND ( D EQ 4 )  ) */
/*        OR */
/*             (  ( B GT 2 ) AND ( C NE 3 )  ) */
/*        OR */
/*             (  ( B GT 2 ) AND ( D EQ 4 )  ) */

/*     which contains eight relational expressions. */



/*     MXJOIN is the maximum number of tables that can be joined. */


/*     MXJCON is the maximum number of join constraints allowed. */


/*     Maximum number of order-by columns that may be used in the */
/*     `order-by clause' of a query: MAXORD. MAXORD = 10. */


/*     Maximum number of tokens in a query: 500. Tokens are reserved */
/*     words, column names, parentheses, and values. Literal strings */
/*     and time values count as single tokens. */


/*     Maximum number of numeric tokens in a query: */


/*     Maximum total length of character tokens in a query: */


/*     Maximum length of literal string values allowed in queries: */
/*     MAXSTR. */


/*     End Include Section:  EK Query Limit Parameters */

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


/*     Include Section:  EK Table Name Size */

/*        ektnamsz.inc Version 1    17-JAN-1995 (NJB) */


/*     Size of table name, in characters. */


/*     End Include Section:  EK Table Name Size */

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


/*     Include Section:  EK Data Types */

/*        ektype.inc Version 1  27-DEC-1994 (NJB) */


/*     Within the EK system, data types of EK column contents are */
/*     represented by integer codes.  The codes and their meanings */
/*     are listed below. */

/*     Integer codes are also used within the DAS system to indicate */
/*     data types; the EK system makes no assumptions about compatibility */
/*     between the codes used here and those used in the DAS system. */


/*     Character type: */


/*     Double precision type: */


/*     Integer type: */


/*     `Time' type: */

/*     Within the EK system, time values are represented as ephemeris */
/*     seconds past J2000 (TDB), and double precision numbers are used */
/*     to store these values.  However, since time values require special */
/*     treatment both on input and output, and since the `TIME' column */
/*     has a special role in the EK specification and code, time values */
/*     are identified as a type distinct from double precision numbers. */


/*     End Include Section:  EK Data Types */

/* $ Brief_I/O */

/*     Variable  I/O  Description */
/*     --------  ---  -------------------------------------------------- */
/*     FILE       I   The name of an SPK file to create. */
/*     FILENO     I   Index of file in sequence of test EKs. */
/*     MXROWS     I   Maximum number of rows allowed in any table. */
/*     LOAD       I   Logical indicating if file should be loaded. */
/*     HANDLE     O   Handle if file is loaded by TSTEK. */

/* $ Detailed_Input */

/*     FILE           is the name of an EK file to create for use in */
/*                    software testing. */

/*                    If the file specified already exists, the existing */
/*                    file is deleted and a new one created with the same */
/*                    name in its place. */

/*     FILENO         is the ordinal position of the named EK in a */
/*                    sequence of test EKs.  FILENO will be reflected in */
/*                    the EK data, so data may be traced to their source */
/*                    EK files. */

/*     MXROWS         is the maximum number of rows allowed in any table. */
/*                    MXROWS should be at least 4000 for robust testing, */
/*                    but it may be set as small as 10 for quick tests. */

/*     LOAD           is a logical flag indicating whether or not the */
/*                    created SPK file should be loaded.  If LOAD is */
/*                    TRUE the file is loaded.  If LOAD is FALSE the */
/*                    file is not loaded by this routine. */

/* $ Detailed_Output */

/*     HANDLE         is the handle attached to the EK file if LOAD is */
/*                    .TRUE. */

/* $ Parameters */

/*     None. */

/* $ Exceptions */

/*     1) If the specified file already exists, it is deleted and */
/*        replaced by the file created by this routine. */

/*     2) All other exceptions are diagnosed by routines in the call tree */
/*        of this routine. */

/* $ Files */

/*     The column entries created by this routine are intended to */
/*     belong to a particular test EK in a sequence of test EKs.  The */
/*     index of the EK within the sequence is given by the input argument */
/*     FILENO.  The index is also reflected in the returned column */
/*     values. */

/* $ Particulars */

/*     This routine is meant to support the automatic, non-interactive */
/*     testing of the SPICELIB EK system.  TSTEK uses TSTENT to create a */
/*     predictable set of test data with which it populates a set of */
/*     binary EK files.  Data fetched from those files can be compared */
/*     with outputs obtained directly from TSTENT. */

/*     The test data produced by this routine are reasonably */
/*     comprehensive in some respects: */

/*        - Both segment types (1 and 2) are represented. */
/*        - Every column class is represented. */
/*        - Indexed and non-indexed columns are represented. */
/*        - Null and non-null column entries for each column class */
/*          are created. */
/*        - Tables are continued across multiple files. */

/*     On the other hand, the tables created by this routine are not */
/*     adequate to exhaustively test all of the logic used to write and */
/*     read EK files. */

/*     The tables created by this routine are described below. */


/*        1) Table SCALAR_1: */

/*              Segment type:  1 */

/*              Columns          Data type         Indexed?   Nulls ok? */
/*              -------          ---------         --------   --------- */
/*              TABLE_NAME       CHARACTER*(64)    No         No */
/*              FILE_NO          INTEGER           No         No */
/*              SEGMENT_NO       INTEGER           No         No */
/*              ROW_NO           INTEGER           No         No */
/*              C_COL_1          CHARACTER*(*)     No         No */
/*              D_COL_1          DOUBLE PRECISION  No         No */
/*              I_COL_1          INTEGER           No         No */
/*              T_COL_1          TIME              No         No */

/*        2) Table SCALAR_2: */

/*              Segment type:  1 */

/*              Columns          Data type         Indexed?   Nulls ok? */
/*              -------          ---------         --------   --------- */
/*              TABLE_NAME       CHARACTER*(64)    Yes        No */
/*              FILE_NO          INTEGER           Yes        No */
/*              SEGMENT_NO       INTEGER           Yes        No */
/*              ROW_NO           INTEGER           Yes        No */
/*              C_COL_1          CHARACTER*(*)     Yes        Yes */
/*              C_COL_2          CHARACTER*(*)     Yes        Yes */
/*              C_COL_3          CHARACTER*(*)     Yes        Yes */
/*              C_COL_4          CHARACTER*(12)    Yes        Yes */
/*              C_COL_5          CHARACTER*(12)    Yes        Yes */
/*              C_COL_6          CHARACTER*(12)    Yes        Yes */
/*              D_COL_1          DOUBLE PRECISION  Yes        Yes */
/*              D_COL_2          DOUBLE PRECISION  Yes        Yes */
/*              D_COL_3          DOUBLE PRECISION  Yes        Yes */
/*              I_COL_1          INTEGER           Yes        Yes */
/*              I_COL_2          INTEGER           Yes        Yes */
/*              I_COL_3          INTEGER           Yes        Yes */
/*              T_COL_1          TIME              Yes        Yes */
/*              T_COL_2          TIME              Yes        Yes */
/*              T_COL_3          TIME              Yes        Yes */


/*        3) Table SCALAR_3: */

/*              Segment type:  2 */

/*              Columns          Data type         Indexed?   Nulls ok? */
/*              -------          ---------         --------   --------- */
/*              TABLE_NAME       CHARACTER*(64)    No         No */
/*              FILE_NO          INTEGER           No         No */
/*              SEGMENT_NO       INTEGER           No         No */
/*              ROW_NO           INTEGER           No         No */
/*              C_COL_1          CHARACTER*(12)    No         No */
/*              D_COL_1          DOUBLE PRECISION  No         No */
/*              I_COL_1          INTEGER           No         No */
/*              T_COL_1          TIME              No         No */


/*        4) Table SCALAR_4: */

/*              Segment type:  2 */

/*              Columns          Data type         Indexed?   Nulls ok? */
/*              -------          ---------         --------   --------- */
/*              TABLE_NAME       CHARACTER*(64)    Yes        No */
/*              FILE_NO          INTEGER           Yes        No */
/*              SEGMENT_NO       INTEGER           Yes        No */
/*              ROW_NO           INTEGER           Yes        No */
/*              C_COL_1          CHARACTER*(12)    Yes        Yes */
/*              C_COL_2          CHARACTER*(12)    Yes        Yes */
/*              C_COL_3          CHARACTER*(12)    Yes        Yes */
/*              D_COL_1          DOUBLE PRECISION  Yes        Yes */
/*              D_COL_2          DOUBLE PRECISION  Yes        Yes */
/*              D_COL_3          DOUBLE PRECISION  Yes        Yes */
/*              I_COL_1          INTEGER           Yes        Yes */
/*              I_COL_2          INTEGER           Yes        Yes */
/*              I_COL_3          INTEGER           Yes        Yes */
/*              T_COL_1          TIME              Yes        Yes */
/*              T_COL_2          TIME              Yes        Yes */
/*              T_COL_3          TIME              Yes        Yes */

/*        5) Table VECTOR_1: */

/*              Segment type:  1 */

/*              Columns       Data type         Indexed? Nulls ok? Dim. */
/*              -------       ---------         -------- --------- ---- */
/*              TABLE_NAME    CHARACTER*(64)    Yes      No        1 */
/*              FILE_NO       INTEGER           Yes      No        1 */
/*              SEGMENT_NO    INTEGER           Yes      No        1 */
/*              ROW_NO        INTEGER           Yes      No        1 */
/*              C_COL_1       CHARACTER*(1024)  No       No        3 */
/*              C_COL_2       CHARACTER*(100)   No       No        * */
/*              D_COL_1       DOUBLE PRECISION  No       No        4 */
/*              D_COL_2       DOUBLE PRECISION  No       No        * */
/*              I_COL_1       INTEGER           No       No        5 */
/*              I_COL_2       INTEGER           No       No        * */
/*              T_COL_1       TIME              No       No        6 */
/*              T_COL_2       TIME              No       No        * */


/*        6) Table VECTOR_2: */

/*              Segment type:  1 */

/*              Columns       Data type         Indexed? Nulls ok? Dim. */
/*              -------       ---------         -------- --------- ---- */
/*              TABLE_NAME    CHARACTER*(64)    Yes      No        1 */
/*              FILE_NO       INTEGER           Yes      No        1 */
/*              SEGMENT_NO    INTEGER           Yes      No        1 */
/*              ROW_NO        INTEGER           Yes      No        1 */
/*              C_COL_1       CHARACTER*(1024)  No       Yes       3 */
/*              C_COL_2       CHARACTER*(1024)  No       Yes       5 */
/*              C_COL_3       CHARACTER*(1024)  No       Yes       * */
/*              C_COL_4       CHARACTER*(1024)  No       Yes       * */
/*              D_COL_1       DOUBLE PRECISION  No       Yes       4 */
/*              D_COL_2       DOUBLE PRECISION  No       Yes       6 */
/*              D_COL_3       DOUBLE PRECISION  No       Yes       * */
/*              D_COL_4       DOUBLE PRECISION  No       Yes       * */
/*              I_COL_1       INTEGER           No       Yes       5 */
/*              I_COL_2       INTEGER           No       Yes       7 */
/*              I_COL_3       INTEGER           No       Yes       * */
/*              I_COL_4       INTEGER           No       Yes       * */
/*              T_COL_1       TIME              No       Yes       6 */
/*              T_COL_2       TIME              No       Yes       8 */
/*              T_COL_3       TIME              No       Yes       * */
/*              T_COL_4       TIME              No       Yes       * */

/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     None. */

/* $ Literature_References */

/*     None. */

/* $ Author_and_Institution */

/*     N.J. Bachman       (JPL) */

/* $ Version */

/* -    Testing Utilities Version 1.4.0, 10-NOV-2005 (NJB) */

/*        Updated to remove non-standard use of duplicate arguments */
/*        in calls to TSTENT. */

/* -    Testing Utilities Version 1.3.0, 05-JAN-2005 (BVS) */

/*        Added SAVE statement to prevent TSPICE_C crashing */
/*        on cygwin. */

/* -    Testing Utilities Version 1.2.0, 07-SEP-2001 (NJB) */

/*        Bug fix:  call to REPMC replaced by call to REPMI. */

/* -    Testing Utilities Version 1.1.0, 28-JUL-1999 (WLT) */

/*        Added code so that the E-kernel will be registered with */
/*        the Test Utilities File Registry (FILREG).  This way */
/*        when a test family is done, the file will automatically */
/*        be deleted. */

/* -    Testing Utilities Version 1.0.0, 15-JUL-1999 (NJB) */

/* -& */
/* $ Revisions */

/* -    Testing Utilities Version 1.2.0, 07-SEP-2001 (NJB) */

/*        Bug fix:  call to REPMC replaced by call to REPMI. */

/* -& */

/*     SPICELIB functions */


/*     Local parameters */


/*     Local variables */


/*     Save ALL variables to prevent TSPICE_C crashing on cygwin. */


/*     Initial values */


/*     Use discovery check-in. */


/*     Delete the old version of the file, if it exists. */

    if (exists_(file, file_len)) {
	delfil_(file, file_len);
    }

/*     Set up the number of reserved comment characters and the internal */
/*     file name. */

    ncomch = *fileno << 10;
    s_copy(ifname, "EK TEST FILE #*", (ftnlen)60, (ftnlen)15);
    repmi_(ifname, "*", fileno, ifname, (ftnlen)60, (ftnlen)1, (ftnlen)60);

/*     Open a new E-kernel. */

    ekopn_(file, ifname, &ncomch, handle, file_len, (ftnlen)60);

/*     For each table: */

    for (tabno = 1; tabno <= 6; ++tabno) {

/*        Look up the schema for this table. */

	tstsch_(tables + (((i__1 = tabno - 1) < 6 && 0 <= i__1 ? i__1 : 
		s_rnge("tables", i__1, "tstek_", (ftnlen)441)) << 6), mxrows, 
		&segtyp, &nrows, &ncols, cnames, cclass, dtypes, stlens, 
		dims__, indexd, nullok, decls, (ftnlen)64, (ftnlen)32, (
		ftnlen)200);

/*        Make sure we're not getting more rows than we expected. */

	maxai_(stlens, &ncols, &maxstl, &loc);
	if (nrows > 5000) {
	    erract_("SET", "ABORT", (ftnlen)3, (ftnlen)5);
	    errdev_("SET", "SCREEN", (ftnlen)3, (ftnlen)6);
	    errprt_("SET", "ALL", (ftnlen)3, (ftnlen)3);
	    chkin_("TSTEK", (ftnlen)5);
	    setmsg_("Oops! Max number of rows that can be handled by this ro"
		    "utine is #; number handed back by TSTSCH is #.", (ftnlen)
		    101);
	    errint_("#", &c__5000, (ftnlen)1);
	    errint_("#", &nrows, (ftnlen)1);
	    sigerr_("SPICE(BUG)", (ftnlen)10);
	    chkout_("TSTEK", (ftnlen)5);
	} else if (nrows > 100 && maxstl > 100) {
	    erract_("SET", "ABORT", (ftnlen)3, (ftnlen)5);
	    errdev_("SET", "SCREEN", (ftnlen)3, (ftnlen)6);
	    errprt_("SET", "ALL", (ftnlen)3, (ftnlen)3);
	    chkin_("TSTEK", (ftnlen)5);
	    setmsg_("Oops! Max number of long rows that can be handled by th"
		    "is routine is #; number handed back by TSTSCH is #.", (
		    ftnlen)106);
	    errint_("#", &c__100, (ftnlen)1);
	    errint_("#", &nrows, (ftnlen)1);
	    sigerr_("SPICE(BUG)", (ftnlen)10);
	    chkout_("TSTEK", (ftnlen)5);
	}

/*        Initiate a fast load. */

	ekifld_(handle, tables + (((i__1 = tabno - 1) < 6 && 0 <= i__1 ? i__1 
		: s_rnge("tables", i__1, "tstek_", (ftnlen)487)) << 6), &
		ncols, &nrows, cnames, decls, &segno, rcptrs, (ftnlen)64, (
		ftnlen)32, (ftnlen)200);

/*        Load the columns one by one. Each column and associated */
/*        arrays must be filled in first.  Obtain data, entry sizes, */
/*        and null flags from TSTENT. */

	i__1 = ncols;
	for (colno = 1; colno <= i__1; ++colno) {

/*           Initialize the data pointer to point to the first free */
/*           slot. */

	    p = 1;
	    i__2 = nrows;
	    for (i__ = 1; i__ <= i__2; ++i__) {
		if (stlens[(i__3 = colno - 1) < 100 && 0 <= i__3 ? i__3 : 
			s_rnge("stlens", i__3, "tstek_", (ftnlen)504)] > 100) 
			{

/*                 We're dealing with some very long strings.  Use */
/*                 the fat string buffer. */

		    tstent_(fileno, tables + (((i__3 = tabno - 1) < 6 && 0 <= 
			    i__3 ? i__3 : s_rnge("tables", i__3, "tstek_", (
			    ftnlen)509)) << 6), &segno, cnames + (((i__4 = 
			    colno - 1) < 100 && 0 <= i__4 ? i__4 : s_rnge(
			    "cnames", i__4, "tstek_", (ftnlen)509)) << 5), &
			    i__, &c__20, &entszs[(i__5 = i__ - 1) < 5000 && 0 
			    <= i__5 ? i__5 : s_rnge("entszs", i__5, "tstek_", 
			    (ftnlen)509)], fatbuf + (((i__6 = p - 1) < 2000 &&
			     0 <= i__6 ? i__6 : s_rnge("fatbuf", i__6, "tste"
			    "k_", (ftnlen)509)) << 10), &dvals[(i__7 = p - 1) <
			     50000 && 0 <= i__7 ? i__7 : s_rnge("dvals", i__7,
			     "tstek_", (ftnlen)509)], &ivals[(i__8 = p - 1) < 
			    50000 && 0 <= i__8 ? i__8 : s_rnge("ivals", i__8, 
			    "tstek_", (ftnlen)509)], &tvals[(i__9 = p - 1) < 
			    50000 && 0 <= i__9 ? i__9 : s_rnge("tvals", i__9, 
			    "tstek_", (ftnlen)509)], &nlflgs[(i__10 = i__ - 1)
			     < 5000 && 0 <= i__10 ? i__10 : s_rnge("nlflgs", 
			    i__10, "tstek_", (ftnlen)509)], (ftnlen)64, (
			    ftnlen)32, (ftnlen)1024);
		} else {

/*                 Use the normal buffers. */

		    tstent_(fileno, tables + (((i__3 = tabno - 1) < 6 && 0 <= 
			    i__3 ? i__3 : s_rnge("tables", i__3, "tstek_", (
			    ftnlen)518)) << 6), &segno, cnames + (((i__4 = 
			    colno - 1) < 100 && 0 <= i__4 ? i__4 : s_rnge(
			    "cnames", i__4, "tstek_", (ftnlen)518)) << 5), &
			    i__, &c__20, &entszs[(i__5 = i__ - 1) < 5000 && 0 
			    <= i__5 ? i__5 : s_rnge("entszs", i__5, "tstek_", 
			    (ftnlen)518)], cvals + ((i__6 = p - 1) < 50000 && 
			    0 <= i__6 ? i__6 : s_rnge("cvals", i__6, "tstek_",
			     (ftnlen)518)) * 100, &dvals[(i__7 = p - 1) < 
			    50000 && 0 <= i__7 ? i__7 : s_rnge("dvals", i__7, 
			    "tstek_", (ftnlen)518)], &ivals[(i__8 = p - 1) < 
			    50000 && 0 <= i__8 ? i__8 : s_rnge("ivals", i__8, 
			    "tstek_", (ftnlen)518)], &tvals[(i__9 = p - 1) < 
			    50000 && 0 <= i__9 ? i__9 : s_rnge("tvals", i__9, 
			    "tstek_", (ftnlen)518)], &nlflgs[(i__10 = i__ - 1)
			     < 5000 && 0 <= i__10 ? i__10 : s_rnge("nlflgs", 
			    i__10, "tstek_", (ftnlen)518)], (ftnlen)64, (
			    ftnlen)32, (ftnlen)100);
		}

/*              Advance the data pointer by the number of elements in */
/*              the current entry. */

		p += entszs[(i__3 = i__ - 1) < 5000 && 0 <= i__3 ? i__3 : 
			s_rnge("entszs", i__3, "tstek_", (ftnlen)528)];
	    }

/*           The column is ready to be added.  Choose the addition */
/*           routine based on the column's data type. */

	    if (dtypes[(i__2 = colno - 1) < 100 && 0 <= i__2 ? i__2 : s_rnge(
		    "dtypes", i__2, "tstek_", (ftnlen)536)] == 1) {
		if (stlens[(i__2 = colno - 1) < 100 && 0 <= i__2 ? i__2 : 
			s_rnge("stlens", i__2, "tstek_", (ftnlen)539)] > 100) 
			{
		    ekaclc_(handle, &segno, cnames + (((i__2 = colno - 1) < 
			    100 && 0 <= i__2 ? i__2 : s_rnge("cnames", i__2, 
			    "tstek_", (ftnlen)541)) << 5), fatbuf, entszs, 
			    nlflgs, rcptrs, wkindx, (ftnlen)32, (ftnlen)1024);
		} else {
		    ekaclc_(handle, &segno, cnames + (((i__2 = colno - 1) < 
			    100 && 0 <= i__2 ? i__2 : s_rnge("cnames", i__2, 
			    "tstek_", (ftnlen)546)) << 5), cvals, entszs, 
			    nlflgs, rcptrs, wkindx, (ftnlen)32, (ftnlen)100);
		}
	    } else if (dtypes[(i__2 = colno - 1) < 100 && 0 <= i__2 ? i__2 : 
		    s_rnge("dtypes", i__2, "tstek_", (ftnlen)551)] == 2) {
		ekacld_(handle, &segno, cnames + (((i__2 = colno - 1) < 100 &&
			 0 <= i__2 ? i__2 : s_rnge("cnames", i__2, "tstek_", (
			ftnlen)553)) << 5), dvals, entszs, nlflgs, rcptrs, 
			wkindx, (ftnlen)32);
	    } else if (dtypes[(i__2 = colno - 1) < 100 && 0 <= i__2 ? i__2 : 
		    s_rnge("dtypes", i__2, "tstek_", (ftnlen)556)] == 3) {
		ekacli_(handle, &segno, cnames + (((i__2 = colno - 1) < 100 &&
			 0 <= i__2 ? i__2 : s_rnge("cnames", i__2, "tstek_", (
			ftnlen)558)) << 5), ivals, entszs, nlflgs, rcptrs, 
			wkindx, (ftnlen)32);
	    } else {

/*              The data type is TIME.  Use the DP column add routine. */

		ekacld_(handle, &segno, cnames + (((i__2 = colno - 1) < 100 &&
			 0 <= i__2 ? i__2 : s_rnge("cnames", i__2, "tstek_", (
			ftnlen)565)) << 5), tvals, entszs, nlflgs, rcptrs, 
			wkindx, (ftnlen)32);
	    }
	}

/*        Finish the fast load for this table. */

	ekffld_(handle, &segno, rcptrs);
    }

/*     Close the EK file. */

    ekcls_(handle);

/*     Load the file if commanded to do so. */

    if (*load) {
	eklef_(file, handle, file_len);
    }

/*     Register this file with the FILREG so that it can be */
/*     removed when the current test family is done with its */
/*     task. */

    tfiles_(file, file_len);
    return 0;
} /* tstek_ */

