/* tstent.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__10 = 10;
static integer c__0 = 0;

/* $Procedure  TSTENT ( Produce EK column entries for EK testing ) */
/* Subroutine */ int tstent_(integer *fileno, char *table, integer *segno, 
	char *column, integer *rowno, integer *nmax, integer *nelts, char *
	cvals, doublereal *dvals, integer *ivals, doublereal *tvals, logical *
	isnull, ftnlen table_len, ftnlen column_len, ftnlen cvals_len)
{
    /* Initialized data */

    static logical first = TRUE_;

    /* System generated locals */
    integer i__1, i__2, i__3;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_cmp(char *, char *, ftnlen, ftnlen), s_rnge(char *, integer, 
	    char *, integer), i_len(char *, ftnlen);

    /* Local variables */
    integer dims__[100], i__, j, r__;
    char decls[200*100];
    extern /* Subroutine */ int chkin_(char *, ftnlen), errch_(char *, char *,
	     ftnlen, ftnlen), repmc_(char *, char *, char *, char *, ftnlen, 
	    ftnlen, ftnlen, ftnlen), repmi_(char *, char *, integer *, char *,
	     ftnlen, ftnlen, ftnlen);
    integer ncols;
    extern integer rtrim_(char *, ftnlen);
    integer nrows;
    char cnames[32*100];
    integer cclass[100], basval;
    extern integer isrchc_(char *, integer *, char *, ftnlen, ftnlen);
    logical indexd[100];
    integer colidx;
    extern /* Subroutine */ int sigerr_(char *, ftnlen), chkout_(char *, 
	    ftnlen), setmsg_(char *, ftnlen);
    logical nullok[100];
    integer dtypes[100], stlens[100];
    extern /* Subroutine */ int tstsch_(char *, integer *, integer *, integer 
	    *, integer *, char *, integer *, integer *, integer *, integer *, 
	    logical *, logical *, char *, ftnlen, ftnlen, ftnlen);
    integer segtyp;
    extern /* Subroutine */ int suffix_(char *, integer *, char *, ftnlen, 
	    ftnlen), prefix_(char *, integer *, char *, ftnlen, ftnlen);
    extern logical return_(void);
    static char pad[1024];
    extern logical odd_(integer *);

/* $ Abstract */

/*     Make up EK column entries for use in EK testing. */

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


/*     Include Section:  EK Boolean Enumerated Type */


/*        ekbool.inc Version 1   21-DEC-1994 (NJB) */


/*     Within the EK system, boolean values sometimes must be */
/*     represented by integer or character codes.  The codes and their */
/*     meanings are listed below. */

/*     Integer code indicating `true': */


/*     Integer code indicating `false': */


/*     Character code indicating `true': */


/*     Character code indicating `false': */


/*     End Include Section:  EK Boolean Enumerated Type */

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
/*     MAXESZ     P   Maximum number of elements in the column entry. */
/*     FILENO     I   Index of EK test file in test file sequence. */
/*     TABLE      I   EK table name. */
/*     SEGNO      I   Segment index within table in current file. */
/*     COLUMN     I   Column name. */
/*     ROWNO      I   Row index within segment. */
/*     NMAX       I   Maximum number of column entry elements to return. */
/*     NELTS      O   Number of elements in specified column entry. */
/*     CVALS      O   Values making up character column entry. */
/*     DVALS      O   Values making up d.p. column entry. */
/*     IVALS      O   Values making up integer column entry. */
/*     TVALS      O   Values making up time column entry. */
/*     ISNULL     O   Flag indicating whether entry is null. */

/* $ Detailed_Input */

/*     FILENO         is the index of in the EK test file sequence of */
/*                    the EK containing the specified column entry. */
/*                    The entries are a function of which file they're */
/*                    from. */

/*     TABLE          is the name of the EK table containing the entry. */
/*                    This routine creates a fixed set of tables, each */
/*                    having a name given by this routine.  See the */
/*                    Particulars section for the table names and */
/*                    descriptions. */

/*     SEGNO          is the index within the specified table, within */
/*                    the specified file, of the segment containing the */
/*                    entry. */

/*     COLUMN         is the name of the column containing the entry. */
/*                    Within each table, this routine creates a fixed */
/*                    set of columns, each having a name given by this */
/*                    routine.  See the Particulars section for the */
/*                    table names and descriptions. */

/*     ROWNO          is the index within the specified segment of the */
/*                    row containing the entry. */

/*     NMAX           is the maximum number of column entry elements to */
/*                    return.  This input is used for error checking. */

/* $ Detailed_Output */

/*     NELTS          is the number of elements in the specified column */
/*                    entry. */

/*     CVALS          are the character values making up the column */
/*                    entry, if the specified column has character type. */
/*                    Otherwise, CVALS is undefined. */

/*     DVALS          are the d.p values  making up the column entry, if */
/*                    the specified column has double precision type. */
/*                    Otherwise, DVALS is undefined. */

/*     IVALS          are the integer values  making up the column */
/*                    entry, if the specified column has integer type. */
/*                    Otherwise, IVALS is undefined. */

/*     TVALS          are the ET values  making up the column entry, if */
/*                    the specified column has TIME type. Otherwise, */
/*                    TVALS is undefined. */

/*     ISNULL         is a logical flag indicating whether the returned */
/*                    column entry is null. */

/* $ Parameters */

/*     MAXESZ         Maximum number of elements in the column entry. */

/* $ Exceptions */

/*     1) If the input table name is not recognized, the error */
/*        SPICE(NOSUCHTABLE) is signaled. */

/*     2) If the input column name is not recognized, the error */
/*        SPICE(NOSUCHCOLUMN) is signaled. */

/* $ Files */

/*     The column entries created by this routine are intended to */
/*     belong to a particular test EK in a sequence of test EKs.  The */
/*     index of the EK within the sequence is given by the input argument */
/*     FILENO.  The index is also reflected in the returned column */
/*     values. */

/* $ Particulars */

/*     This routine is meant to support the automatic, non-interactive */
/*     testing of the SPICELIB EK system.  TSTENT creates a predictable */
/*     set of test data with which to populate a set of binary EK files, */
/*     and against which data fetched from those files can be compared. */

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
/*              C_COL_4          CHARACTER*(20)    Yes        Yes */
/*              C_COL_5          CHARACTER*(20)    Yes        Yes */
/*              C_COL_6          CHARACTER*(20)    Yes        Yes */
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
/*              C_COL_1          CHARACTER*(20)    No         No */
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
/*              C_COL_1          CHARACTER*(20)    Yes        Yes */
/*              C_COL_2          CHARACTER*(20)    Yes        Yes */
/*              C_COL_3          CHARACTER*(20)    Yes        Yes */
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

/* -    Testing Utilities Version 1.0.0, 26-JUL-1999 (NJB) */

/* -& */

/*     SPICELIB functions */


/*     Local parameters */


/*     Local variables */


/*     Saved variables */


/*     Initial values */


/*     Standard SPICE error handling. */

    if (return_()) {
	return 0;
    } else {
	chkin_("TSTENT", (ftnlen)6);
    }
    if (first) {

/*        Initialize the pad string for long character data values. */

	for (i__ = 1; i__ <= 1024; ++i__) {
	    *(unsigned char *)&pad[i__ - 1] = 'X';
	}
	s_copy(pad + 95, " 100>", (ftnlen)5, (ftnlen)5);
	s_copy(pad + 1017, " 1024>", (ftnlen)7, (ftnlen)6);
	first = FALSE_;
    }

/*     Look up the schema for the indicated table.  This gives us */
/*     dimension information.  The value of "MXROWS" is irrelevant; */
/*     set it to the minimum allowed value. */

    tstsch_(table, &c__10, &segtyp, &nrows, &ncols, cnames, cclass, dtypes, 
	    stlens, dims__, indexd, nullok, decls, table_len, (ftnlen)32, (
	    ftnlen)200);

/*     Get the index of the requested column within the CNAMES array. */

    colidx = isrchc_(column, &ncols, cnames, column_len, (ftnlen)32);
    if (colidx == 0) {
	setmsg_("Column # does not exist in table #.", (ftnlen)35);
	errch_("#", column, (ftnlen)1, column_len);
	errch_("#", table, (ftnlen)1, table_len);
	sigerr_("SPICE(NOSUCHCOLUMN)", (ftnlen)19);
	chkout_("TSTENT", (ftnlen)6);
	return 0;
    }

/*     Factor out the boiler-plate responses.  Set values for */
/*     the TABLE_NAME, FILE_NO, SEGMENT_NO and ROW_NO columns right here. */

    if (s_cmp(table, "SCALAR_1", table_len, (ftnlen)8) == 0 || s_cmp(table, 
	    "SCALAR_2", table_len, (ftnlen)8) == 0 || s_cmp(table, "SCALAR_3",
	     table_len, (ftnlen)8) == 0 || s_cmp(table, "SCALAR_4", table_len,
	     (ftnlen)8) == 0 || s_cmp(table, "VECTOR_1", table_len, (ftnlen)8)
	     == 0 || s_cmp(table, "VECTOR_2", table_len, (ftnlen)8) == 0 || 
	    s_cmp(table, "EMPTY_1", table_len, (ftnlen)7) == 0 || s_cmp(table,
	     "EMPTY_2", table_len, (ftnlen)7) == 0) {
	if (s_cmp(column, "TABLE_NAME", column_len, (ftnlen)10) == 0) {
	    *nelts = 1;
	    s_copy(cvals, table, cvals_len, table_len);
	    *isnull = FALSE_;
	    chkout_("TSTENT", (ftnlen)6);
	    return 0;
	} else if (s_cmp(column, "FILE_NO", column_len, (ftnlen)7) == 0) {
	    *nelts = 1;
	    ivals[0] = *fileno;
	    *isnull = FALSE_;
	    chkout_("TSTENT", (ftnlen)6);
	    return 0;
	} else if (s_cmp(column, "SEGMENT_NO", column_len, (ftnlen)10) == 0) {
	    *nelts = 1;
	    ivals[0] = *segno;
	    *isnull = FALSE_;
	    chkout_("TSTENT", (ftnlen)6);
	    return 0;
	} else if (s_cmp(column, "ROW_NO", column_len, (ftnlen)6) == 0) {
	    *nelts = 1;
	    ivals[0] = *rowno;
	    *isnull = FALSE_;
	    chkout_("TSTENT", (ftnlen)6);
	    return 0;
	}
    }
    if (s_cmp(table, "SCALAR_1", table_len, (ftnlen)8) == 0) {
	basval = *segno * 1000000 + *rowno;
	if (s_cmp(column, "C_COL_1", column_len, (ftnlen)7) == 0) {
	    *nelts = 1;
	    s_copy(cvals, "SEG_#_#_ROW_#", cvals_len, (ftnlen)13);
	    repmi_(cvals, "#", segno, cvals, cvals_len, (ftnlen)1, cvals_len);
	    repmc_(cvals, "#", column, cvals, cvals_len, (ftnlen)1, 
		    column_len, cvals_len);
	    repmi_(cvals, "#", rowno, cvals, cvals_len, (ftnlen)1, cvals_len);
	    *isnull = FALSE_;
	} else if (s_cmp(column, "D_COL_1", column_len, (ftnlen)7) == 0) {
	    *nelts = 1;
	    dvals[0] = (doublereal) basval;
	    *isnull = FALSE_;
	} else if (s_cmp(column, "I_COL_1", column_len, (ftnlen)7) == 0) {
	    *nelts = 1;
	    ivals[0] = basval;
	    *isnull = FALSE_;
	} else if (s_cmp(column, "T_COL_1", column_len, (ftnlen)7) == 0) {
	    *nelts = 1;
	    tvals[0] = (doublereal) basval;
	    *isnull = FALSE_;
	} else {
	    setmsg_("Column # does not exist in table SCALAR_1.", (ftnlen)42);
	    errch_("#", column, (ftnlen)1, column_len);
	    sigerr_("SPICE(NOSUCHCOLUMN)", (ftnlen)19);
	    chkout_("TSTENT", (ftnlen)6);
	    return 0;
	}
    } else if (s_cmp(table, "SCALAR_2", table_len, (ftnlen)8) == 0) {
	basval = *segno * 1000000 + *rowno;
	if (s_cmp(column, "C_COL_1", column_len, (ftnlen)7) == 0) {
	    *nelts = 1;
	    s_copy(cvals, "SEG_#_#_ROW_#", cvals_len, (ftnlen)13);
	    repmi_(cvals, "#", segno, cvals, cvals_len, (ftnlen)1, cvals_len);
	    repmc_(cvals, "#", column, cvals, cvals_len, (ftnlen)1, 
		    column_len, cvals_len);
	    repmi_(cvals, "#", rowno, cvals, cvals_len, (ftnlen)1, cvals_len);
	    *isnull = FALSE_;
	} else if (s_cmp(column, "C_COL_2", column_len, (ftnlen)7) == 0) {
	    *nelts = 1;
	    s_copy(cvals, "SEG_#_#_ROW_#_", cvals_len, (ftnlen)14);
	    repmi_(cvals, "#", segno, cvals, cvals_len, (ftnlen)1, cvals_len);
	    repmc_(cvals, "#", column, cvals, cvals_len, (ftnlen)1, 
		    column_len, cvals_len);
	    repmi_(cvals, "#", rowno, cvals, cvals_len, (ftnlen)1, cvals_len);
	    j = *rowno % 100;
	    i__1 = j;
	    for (i__ = 1; i__ <= i__1; ++i__) {
		suffix_("X", &c__0, cvals, (ftnlen)1, cvals_len);
	    }

/*           Create two rows that are identical up through the first */
/*           32 characters.  This tests some of the logic in ZZEKJSRT. */

	    if (*rowno == 16 || *rowno == 18) {
		for (i__ = 1; i__ <= 32; ++i__) {
		    prefix_("X", &c__0, cvals, (ftnlen)1, cvals_len);
		}
	    }
	    *isnull = odd_(rowno);
	} else if (s_cmp(column, "C_COL_3", column_len, (ftnlen)7) == 0) {
	    *nelts = 1;
	    *isnull = TRUE_;
	} else if (s_cmp(column, "C_COL_4", column_len, (ftnlen)7) == 0) {
	    *nelts = 1;
	    s_copy(cvals, "SEG_#_#_ROW_#_", cvals_len, (ftnlen)14);
	    repmi_(cvals, "#", segno, cvals, cvals_len, (ftnlen)1, cvals_len);
	    repmc_(cvals, "#", column, cvals, cvals_len, (ftnlen)1, 
		    column_len, cvals_len);
	    repmi_(cvals, "#", rowno, cvals, cvals_len, (ftnlen)1, cvals_len);
	    j = *rowno % 100;
	    i__1 = j;
	    for (i__ = 1; i__ <= i__1; ++i__) {
		suffix_("X", &c__0, cvals, (ftnlen)1, cvals_len);
	    }
	    *isnull = odd_(rowno);
	} else if (s_cmp(column, "C_COL_5", column_len, (ftnlen)7) == 0) {
	    *nelts = 1;
	    s_copy(cvals, "SEG_#_#_ROW_#_", cvals_len, (ftnlen)14);
	    repmi_(cvals, "#", segno, cvals, cvals_len, (ftnlen)1, cvals_len);
	    repmc_(cvals, "#", column, cvals, cvals_len, (ftnlen)1, 
		    column_len, cvals_len);
	    repmi_(cvals, "#", rowno, cvals, cvals_len, (ftnlen)1, cvals_len);
	    *isnull = odd_(rowno);
	} else if (s_cmp(column, "C_COL_6", column_len, (ftnlen)7) == 0) {
	    *nelts = 1;
	    *isnull = TRUE_;
	} else if (s_cmp(column, "D_COL_1", column_len, (ftnlen)7) == 0) {
	    *nelts = 1;
	    dvals[0] = (doublereal) (-basval);
	    *isnull = FALSE_;
	} else if (s_cmp(column, "D_COL_2", column_len, (ftnlen)7) == 0) {
	    *nelts = 1;
	    dvals[0] = (doublereal) (-basval);
	    *isnull = odd_(rowno);
	} else if (s_cmp(column, "D_COL_3", column_len, (ftnlen)7) == 0) {
	    *nelts = 1;
	    *isnull = TRUE_;
	} else if (s_cmp(column, "I_COL_1", column_len, (ftnlen)7) == 0) {
	    *nelts = 1;
	    ivals[0] = basval;
	    *isnull = FALSE_;
	} else if (s_cmp(column, "I_COL_2", column_len, (ftnlen)7) == 0) {
	    *nelts = 1;
	    ivals[0] = -basval;
	    *isnull = odd_(rowno);
	} else if (s_cmp(column, "I_COL_3", column_len, (ftnlen)7) == 0) {
	    *nelts = 1;
	    *isnull = TRUE_;
	} else if (s_cmp(column, "T_COL_1", column_len, (ftnlen)7) == 0) {
	    *nelts = 1;
	    tvals[0] = (doublereal) (-basval);
	    *isnull = FALSE_;
	} else if (s_cmp(column, "T_COL_2", column_len, (ftnlen)7) == 0) {
	    *nelts = 1;
	    tvals[0] = (doublereal) (-basval);
	    *isnull = odd_(rowno);
	} else if (s_cmp(column, "T_COL_3", column_len, (ftnlen)7) == 0) {
	    *nelts = 1;
	    *isnull = TRUE_;
	} else {
	    setmsg_("Column # does not exist in table SCALAR_2.", (ftnlen)42);
	    errch_("#", column, (ftnlen)1, column_len);
	    sigerr_("SPICE(NOSUCHCOLUMN)", (ftnlen)19);
	    chkout_("TSTENT", (ftnlen)6);
	    return 0;
	}
    } else if (s_cmp(table, "SCALAR_3", table_len, (ftnlen)8) == 0) {
	basval = *segno * 1000000 + *rowno;
	if (s_cmp(column, "C_COL_1", column_len, (ftnlen)7) == 0) {
	    *nelts = 1;
	    s_copy(cvals, "SEG_#_#_ROW_#_", cvals_len, (ftnlen)14);
	    repmi_(cvals, "#", segno, cvals, cvals_len, (ftnlen)1, cvals_len);
	    repmc_(cvals, "#", column, cvals, cvals_len, (ftnlen)1, 
		    column_len, cvals_len);
	    repmi_(cvals, "#", rowno, cvals, cvals_len, (ftnlen)1, cvals_len);
	    *isnull = FALSE_;
	} else if (s_cmp(column, "D_COL_1", column_len, (ftnlen)7) == 0) {
	    *nelts = 1;
	    dvals[0] = (doublereal) basval;
	    *isnull = FALSE_;
	} else if (s_cmp(column, "I_COL_1", column_len, (ftnlen)7) == 0) {
	    *nelts = 1;
	    ivals[0] = basval;
	    *isnull = FALSE_;
	} else if (s_cmp(column, "T_COL_1", column_len, (ftnlen)7) == 0) {
	    *nelts = 1;
	    tvals[0] = (doublereal) basval;
	    *isnull = FALSE_;
	} else {
	    setmsg_("Column # does not exist in table SCALAR_3.", (ftnlen)42);
	    errch_("#", column, (ftnlen)1, column_len);
	    sigerr_("SPICE(NOSUCHCOLUMN)", (ftnlen)19);
	    chkout_("TSTENT", (ftnlen)6);
	    return 0;
	}
    } else if (s_cmp(table, "SCALAR_4", table_len, (ftnlen)8) == 0) {
	basval = *segno * 1000000 + *rowno;
	if (s_cmp(column, "C_COL_1", column_len, (ftnlen)7) == 0) {
	    *nelts = 1;
	    s_copy(cvals, "SEG_#_#_ROW_#_", cvals_len, (ftnlen)14);
	    repmi_(cvals, "#", segno, cvals, cvals_len, (ftnlen)1, cvals_len);
	    repmc_(cvals, "#", column, cvals, cvals_len, (ftnlen)1, 
		    column_len, cvals_len);
	    repmi_(cvals, "#", rowno, cvals, cvals_len, (ftnlen)1, cvals_len);
	    *isnull = FALSE_;
	} else if (s_cmp(column, "C_COL_2", column_len, (ftnlen)7) == 0) {
	    *nelts = 1;
	    s_copy(cvals, "SEG_#_#_ROW_#_", cvals_len, (ftnlen)14);
	    repmi_(cvals, "#", segno, cvals, cvals_len, (ftnlen)1, cvals_len);
	    repmc_(cvals, "#", column, cvals, cvals_len, (ftnlen)1, 
		    column_len, cvals_len);
	    repmi_(cvals, "#", rowno, cvals, cvals_len, (ftnlen)1, cvals_len);
	    *isnull = odd_(rowno);
	} else if (s_cmp(column, "C_COL_3", column_len, (ftnlen)7) == 0) {
	    *nelts = 1;
	    *isnull = TRUE_;
	} else if (s_cmp(column, "D_COL_1", column_len, (ftnlen)7) == 0) {
	    *nelts = 1;
	    dvals[0] = (doublereal) basval;
	    *isnull = FALSE_;
	} else if (s_cmp(column, "D_COL_2", column_len, (ftnlen)7) == 0) {
	    *nelts = 1;
	    dvals[0] = (doublereal) (-basval);
	    *isnull = FALSE_;
	} else if (s_cmp(column, "D_COL_3", column_len, (ftnlen)7) == 0) {
	    *nelts = 1;
	    *isnull = TRUE_;
	} else if (s_cmp(column, "I_COL_1", column_len, (ftnlen)7) == 0) {
	    *nelts = 1;
	    ivals[0] = basval;
	    *isnull = FALSE_;
	} else if (s_cmp(column, "I_COL_2", column_len, (ftnlen)7) == 0) {
	    *nelts = 1;
	    ivals[0] = -basval;
	    *isnull = odd_(rowno);
	} else if (s_cmp(column, "I_COL_3", column_len, (ftnlen)7) == 0) {
	    *nelts = 1;
	    *isnull = TRUE_;
	} else if (s_cmp(column, "T_COL_1", column_len, (ftnlen)7) == 0) {
	    *nelts = 1;
	    tvals[0] = (doublereal) basval;
	    *isnull = FALSE_;
	} else if (s_cmp(column, "T_COL_2", column_len, (ftnlen)7) == 0) {
	    *nelts = 1;
	    tvals[0] = (doublereal) (-basval);
	    *isnull = FALSE_;
	} else if (s_cmp(column, "T_COL_3", column_len, (ftnlen)7) == 0) {
	    *nelts = 1;
	    *isnull = TRUE_;
	} else {
	    setmsg_("Column # does not exist in table SCALAR_4.", (ftnlen)42);
	    errch_("#", column, (ftnlen)1, column_len);
	    sigerr_("SPICE(NOSUCHCOLUMN)", (ftnlen)19);
	    chkout_("TSTENT", (ftnlen)6);
	    return 0;
	}
    } else if (s_cmp(table, "VECTOR_1", table_len, (ftnlen)8) == 0) {
	basval = *segno * 1000000 + *rowno * 100;
	if (s_cmp(column, "C_COL_1", column_len, (ftnlen)7) == 0) {
	    *nelts = 3;
	    i__1 = *nelts;
	    for (i__ = 1; i__ <= i__1; ++i__) {
		s_copy(cvals + (i__ - 1) * cvals_len, "SEG_#_#_ROW_#_ELT_#_", 
			cvals_len, (ftnlen)20);
		repmi_(cvals + (i__ - 1) * cvals_len, "#", segno, cvals + (
			i__ - 1) * cvals_len, cvals_len, (ftnlen)1, cvals_len)
			;
		repmc_(cvals + (i__ - 1) * cvals_len, "#", column, cvals + (
			i__ - 1) * cvals_len, cvals_len, (ftnlen)1, 
			column_len, cvals_len);
		repmi_(cvals + (i__ - 1) * cvals_len, "#", rowno, cvals + (
			i__ - 1) * cvals_len, cvals_len, (ftnlen)1, cvals_len)
			;
		repmi_(cvals + (i__ - 1) * cvals_len, "#", &i__, cvals + (i__ 
			- 1) * cvals_len, cvals_len, (ftnlen)1, cvals_len);
		r__ = rtrim_(cvals + (i__ - 1) * cvals_len, cvals_len);
		i__2 = r__ + 2;
		i__3 = r__ + 2;
		s_copy(cvals + ((i__ - 1) * cvals_len + i__2), pad + i__3, 
			cvals_len - i__2, 1024 - i__3);
	    }
	    *isnull = FALSE_;
	} else if (s_cmp(column, "C_COL_2", column_len, (ftnlen)7) == 0) {
	    *nelts = *rowno % 10 + 1;
	    i__1 = *nelts;
	    for (i__ = 1; i__ <= i__1; ++i__) {
		s_copy(cvals + (i__ - 1) * cvals_len, "SEG_#_#_ROW_#_ELT_#_", 
			cvals_len, (ftnlen)20);
		repmi_(cvals + (i__ - 1) * cvals_len, "#", segno, cvals + (
			i__ - 1) * cvals_len, cvals_len, (ftnlen)1, cvals_len)
			;
		repmc_(cvals + (i__ - 1) * cvals_len, "#", column, cvals + (
			i__ - 1) * cvals_len, cvals_len, (ftnlen)1, 
			column_len, cvals_len);
		repmi_(cvals + (i__ - 1) * cvals_len, "#", rowno, cvals + (
			i__ - 1) * cvals_len, cvals_len, (ftnlen)1, cvals_len)
			;
		repmi_(cvals + (i__ - 1) * cvals_len, "#", &i__, cvals + (i__ 
			- 1) * cvals_len, cvals_len, (ftnlen)1, cvals_len);
		r__ = rtrim_(cvals + (i__ - 1) * cvals_len, cvals_len);
		i__2 = r__ + 2;
		i__3 = r__ + 2;
		s_copy(cvals + ((i__ - 1) * cvals_len + i__2), pad + i__3, 
			cvals_len - i__2, 1024 - i__3);
	    }
	    *isnull = FALSE_;
	} else if (s_cmp(column, "D_COL_1", column_len, (ftnlen)7) == 0) {
	    *nelts = 4;
	    i__1 = *nelts;
	    for (i__ = 1; i__ <= i__1; ++i__) {
		dvals[i__ - 1] = (doublereal) (basval + i__);
	    }
	    *isnull = FALSE_;
	} else if (s_cmp(column, "D_COL_2", column_len, (ftnlen)7) == 0) {
	    *nelts = *rowno % 11 + 1;
	    i__1 = *nelts;
	    for (i__ = 1; i__ <= i__1; ++i__) {
		dvals[i__ - 1] = (doublereal) (basval + i__);
	    }
	    *isnull = FALSE_;
	} else if (s_cmp(column, "I_COL_1", column_len, (ftnlen)7) == 0) {
	    *nelts = 5;
	    i__1 = *nelts;
	    for (i__ = 1; i__ <= i__1; ++i__) {
		ivals[i__ - 1] = basval + i__;
	    }
	    *isnull = FALSE_;
	} else if (s_cmp(column, "I_COL_2", column_len, (ftnlen)7) == 0) {
	    *nelts = *rowno % 12 + 1;
	    i__1 = *nelts;
	    for (i__ = 1; i__ <= i__1; ++i__) {
		ivals[i__ - 1] = basval + i__;
	    }
	    *isnull = FALSE_;
	} else if (s_cmp(column, "T_COL_1", column_len, (ftnlen)7) == 0) {
	    *nelts = 6;
	    i__1 = *nelts;
	    for (i__ = 1; i__ <= i__1; ++i__) {
		tvals[i__ - 1] = (doublereal) (basval + i__);
	    }
	    *isnull = FALSE_;
	} else if (s_cmp(column, "T_COL_2", column_len, (ftnlen)7) == 0) {
	    *nelts = *rowno % 11 + 1;
	    i__1 = *nelts;
	    for (i__ = 1; i__ <= i__1; ++i__) {
		tvals[i__ - 1] = (doublereal) (basval + i__);
	    }
	    *isnull = FALSE_;
	} else {
	    setmsg_("Column # does not exist in table VECTOR_1.", (ftnlen)42);
	    errch_("#", column, (ftnlen)1, column_len);
	    sigerr_("SPICE(NOSUCHCOLUMN)", (ftnlen)19);
	    chkout_("TSTENT", (ftnlen)6);
	    return 0;
	}
    } else if (s_cmp(table, "VECTOR_2", table_len, (ftnlen)8) == 0) {
	basval = *segno * 1000000 + *rowno * 100;
	if (s_cmp(column, "C_COL_1", column_len, (ftnlen)7) == 0) {
	    *nelts = 3;
	    i__1 = *nelts;
	    for (i__ = 1; i__ <= i__1; ++i__) {
		s_copy(cvals + (i__ - 1) * cvals_len, "SEG_#_#_ROW_#_ELT_#_", 
			cvals_len, (ftnlen)20);
		repmi_(cvals + (i__ - 1) * cvals_len, "#", segno, cvals + (
			i__ - 1) * cvals_len, cvals_len, (ftnlen)1, cvals_len)
			;
		repmc_(cvals + (i__ - 1) * cvals_len, "#", column, cvals + (
			i__ - 1) * cvals_len, cvals_len, (ftnlen)1, 
			column_len, cvals_len);
		repmi_(cvals + (i__ - 1) * cvals_len, "#", rowno, cvals + (
			i__ - 1) * cvals_len, cvals_len, (ftnlen)1, cvals_len)
			;
		repmi_(cvals + (i__ - 1) * cvals_len, "#", &i__, cvals + (i__ 
			- 1) * cvals_len, cvals_len, (ftnlen)1, cvals_len);
		r__ = rtrim_(cvals + (i__ - 1) * cvals_len, cvals_len);
		i__2 = r__ + 2;
		i__3 = r__ + 2;
		s_copy(cvals + ((i__ - 1) * cvals_len + i__2), pad + i__3, 
			cvals_len - i__2, 1024 - i__3);
	    }
	    *isnull = odd_(rowno);
	} else if (s_cmp(column, "C_COL_2", column_len, (ftnlen)7) == 0) {
	    *nelts = 5;
	    *isnull = TRUE_;
	} else if (s_cmp(column, "C_COL_3", column_len, (ftnlen)7) == 0) {
	    *isnull = odd_(rowno);
	    if (*isnull) {
		*nelts = 1;
	    } else {
		*nelts = *rowno % 10 + 1;
	    }
	    i__1 = *nelts;
	    for (i__ = 1; i__ <= i__1; ++i__) {
		s_copy(cvals + (i__ - 1) * cvals_len, "SEG_#_#_ROW_#_ELT_#_", 
			cvals_len, (ftnlen)20);
		repmi_(cvals + (i__ - 1) * cvals_len, "#", segno, cvals + (
			i__ - 1) * cvals_len, cvals_len, (ftnlen)1, cvals_len)
			;
		repmc_(cvals + (i__ - 1) * cvals_len, "#", column, cvals + (
			i__ - 1) * cvals_len, cvals_len, (ftnlen)1, 
			column_len, cvals_len);
		repmi_(cvals + (i__ - 1) * cvals_len, "#", rowno, cvals + (
			i__ - 1) * cvals_len, cvals_len, (ftnlen)1, cvals_len)
			;
		repmi_(cvals + (i__ - 1) * cvals_len, "#", &i__, cvals + (i__ 
			- 1) * cvals_len, cvals_len, (ftnlen)1, cvals_len);
		r__ = rtrim_(cvals + (i__ - 1) * cvals_len, cvals_len);
		i__2 = r__ + 2;
		i__3 = r__ + 2;
		s_copy(cvals + ((i__ - 1) * cvals_len + i__2), pad + i__3, 
			cvals_len - i__2, 1024 - i__3);
	    }
	} else if (s_cmp(column, "C_COL_4", column_len, (ftnlen)7) == 0) {
	    *nelts = 1;
	    *isnull = TRUE_;
	} else if (s_cmp(column, "D_COL_1", column_len, (ftnlen)7) == 0) {
	    *nelts = 4;
	    i__1 = *nelts;
	    for (i__ = 1; i__ <= i__1; ++i__) {
		dvals[i__ - 1] = (doublereal) (basval + i__);
	    }
	    *isnull = odd_(rowno);
	} else if (s_cmp(column, "D_COL_2", column_len, (ftnlen)7) == 0) {
	    *nelts = 6;
	    *isnull = TRUE_;
	} else if (s_cmp(column, "D_COL_3", column_len, (ftnlen)7) == 0) {
	    *isnull = odd_(rowno);
	    if (*isnull) {
		*nelts = 1;
	    } else {
		*nelts = *rowno % 11 + 1;
	    }
	    i__1 = *nelts;
	    for (i__ = 1; i__ <= i__1; ++i__) {
		dvals[i__ - 1] = (doublereal) (basval + i__);
	    }
	} else if (s_cmp(column, "D_COL_4", column_len, (ftnlen)7) == 0) {
	    *nelts = 1;
	    *isnull = TRUE_;
	} else if (s_cmp(column, "I_COL_1", column_len, (ftnlen)7) == 0) {
	    *nelts = 5;
	    i__1 = *nelts;
	    for (i__ = 1; i__ <= i__1; ++i__) {
		ivals[i__ - 1] = basval + i__;
	    }
	    *isnull = odd_(rowno);
	} else if (s_cmp(column, "I_COL_2", column_len, (ftnlen)7) == 0) {
	    *nelts = 7;
	    *isnull = TRUE_;
	} else if (s_cmp(column, "I_COL_3", column_len, (ftnlen)7) == 0) {
	    *isnull = odd_(rowno);
	    if (*isnull) {
		*nelts = 1;
	    } else {
		*nelts = *rowno % 12 + 1;
	    }
	    i__1 = *nelts;
	    for (i__ = 1; i__ <= i__1; ++i__) {
		ivals[i__ - 1] = basval + i__;
	    }
	} else if (s_cmp(column, "I_COL_4", column_len, (ftnlen)7) == 0) {
	    *nelts = 1;
	    *isnull = TRUE_;
	} else if (s_cmp(column, "T_COL_1", column_len, (ftnlen)7) == 0) {
	    *nelts = 6;
	    i__1 = *nelts;
	    for (i__ = 1; i__ <= i__1; ++i__) {
		tvals[i__ - 1] = (doublereal) (basval + i__);
	    }
	    *isnull = odd_(rowno);
	} else if (s_cmp(column, "T_COL_2", column_len, (ftnlen)7) == 0) {
	    *nelts = 8;
	    *isnull = TRUE_;
	} else if (s_cmp(column, "T_COL_3", column_len, (ftnlen)7) == 0) {
	    *isnull = odd_(rowno);
	    if (*isnull) {
		*nelts = 1;
	    } else {
		*nelts = *rowno % 11 + 1;
	    }
	    i__1 = *nelts;
	    for (i__ = 1; i__ <= i__1; ++i__) {
		tvals[i__ - 1] = (doublereal) (basval + i__);
	    }
	} else if (s_cmp(column, "T_COL_4", column_len, (ftnlen)7) == 0) {
	    *nelts = 1;
	    *isnull = TRUE_;
	} else {
	    setmsg_("Column # does not exist in table VECTOR_2.", (ftnlen)42);
	    errch_("#", column, (ftnlen)1, column_len);
	    sigerr_("SPICE(NOSUCHCOLUMN)", (ftnlen)19);
	    chkout_("TSTENT", (ftnlen)6);
	    return 0;
	}
    } else {
	setmsg_("Table # does not exist.", (ftnlen)23);
	errch_("#", table, (ftnlen)1, table_len);
	sigerr_("SPICE(NOSUCHTABLE)", (ftnlen)18);
	chkout_("TSTENT", (ftnlen)6);
	return 0;
    }

/*     Make some final adjustments:  for fixed-length character columns, */
/*     truncate the non-blank portion of the column entries at the */
/*     declared column string length. */

    if (dtypes[(i__1 = colidx - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge("dtypes"
	    , i__1, "tstent_", (ftnlen)1219)] == 1) {
	r__ = stlens[(i__1 = colidx - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"stlens", i__1, "tstent_", (ftnlen)1221)];
	if (r__ == -1) {
	    if (i_len(cvals, cvals_len) > 100) {
		i__1 = *nelts;
		for (i__ = 1; i__ <= i__1; ++i__) {
		    s_copy(cvals + ((i__ - 1) * cvals_len + 100), " ", 
			    cvals_len - 100, (ftnlen)1);
		}
	    }
	} else {
	    if (i_len(cvals, cvals_len) > r__) {
		i__1 = *nelts;
		for (i__ = 1; i__ <= i__1; ++i__) {
		    i__2 = r__;
		    s_copy(cvals + ((i__ - 1) * cvals_len + i__2), " ", 
			    cvals_len - i__2, (ftnlen)1);
		}
	    }
	}
    }
    chkout_("TSTENT", (ftnlen)6);
    return 0;
} /* tstent_ */

