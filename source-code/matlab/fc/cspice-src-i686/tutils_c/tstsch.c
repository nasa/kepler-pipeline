/* tstsch.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__1 = 1;
static integer c__0 = 0;

/* $Procedure  TSTSCH ( Produce EK table schemas for EK testing ) */
/* Subroutine */ int tstsch_(char *table, integer *mxrows, integer *segtyp, 
	integer *nrows, integer *ncols, char *cnames, integer *cclass, 
	integer *dtypes, integer *stlens, integer *dims__, logical *indexd, 
	logical *nullok, char *decls, ftnlen table_len, ftnlen cnames_len, 
	ftnlen decls_len)
{
    /* System generated locals */
    integer i__1;

    /* Builtin functions */
    integer s_cmp(char *, char *, ftnlen, ftnlen);
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    integer i__;
    extern /* Subroutine */ int chkin_(char *, ftnlen), errch_(char *, char *,
	     ftnlen, ftnlen), repmc_(char *, char *, char *, char *, ftnlen, 
	    ftnlen, ftnlen, ftnlen), repmi_(char *, char *, integer *, char *,
	     ftnlen, ftnlen, ftnlen), cleari_(integer *, integer *), sigerr_(
	    char *, ftnlen), chkout_(char *, ftnlen), setmsg_(char *, ftnlen),
	     errint_(char *, integer *, ftnlen), suffix_(char *, integer *, 
	    char *, ftnlen, ftnlen);
    extern logical return_(void);

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
/*     TABLE      I   Name of table whose schema is requested. */
/*     MXROWS     I   Maximum number of rows allowed in any table. */
/*     SEGTYP     O   Segment type used to implement table. */
/*     NROWS      O   Number of rows in table. */
/*     NCOLS      O   Number of columns in table. */
/*     CNAMES     O   Column names. */
/*     CCLASS     O   Column classes. */
/*     DTYPES     O   Column data types. */
/*     STLENS     O   String lengths for character columns. */
/*     DIMS       O   Column entry sizes. */
/*     INDEXD     O   Flags indicating whether columns are indexed. */
/*     NULLOK     O   Flags indicating whether columns allow null values. */
/*     DECLS      O   Declaration strings for columns. */

/* $ Detailed_Input */

/*     TABLE          is the name of the table whose schema is to be */
/*                    returned. */

/*     MXROWS         is the maximum number of rows allowed in any table. */
/*                    MXROWS should be at least 4000 for robust testing, */
/*                    but it may be set as small as 10 for quick tests. */
/* $ Detailed_Output */

/*     SEGTYP         is an integer indicating the segment type to be */
/*                    used to implement the specified table.  Possible */
/*                    values are 1 or 2. */

/*     NROWS          is the number of rows in the specified table. */
/*                    This is not actually a property of the schema, but */
/*                    the number of rows is selected here for uniformity. */

/*     NCOLS          is the number of columns in the specified table. */

/*     CNAMES         is an array of names of the columns in the table. */

/*     CCLASS         is an array of integer column class codes for the */
/*                    columns in the specified segment.  The class code */
/*                    of a column indicates the implementation of the */
/*                    data structure used to store the column's data. */

/*     DTYPES         is an array of integer data type codes for the */
/*                    columns.  Values may be any of CHR, DP, INT, or */
/*                    TIME.  These parameters are declared in ektype.inc. */

/*     STLENS         is an array of string lengths for the columns. */
/*                    If the Ith column has fixed-length strings, the */
/*                    Ith element of STLENS gives that length.  Variable */
/*                    string length is indicated by the value IFALSE, */
/*                    which is defined in ekbool.inc.  For non-character */
/*                    columns, the corresponding element of STLENS is 0. */

/*     DIMS           is an array of element sizes for the columns. */
/*                    If the Ith column has fixed-size entries, the */
/*                    Ith element of DIMS gives that size.  Variable */
/*                    entry size is indicated by the value IFALSE, */
/*                    which is defined in ekbool.inc. */

/*     INDEXD         is an array of logical flags indicating whether the */
/*                    corresponding columns are indexed. */

/*     NULLOK         is an array of logical flags indicating whether the */
/*                    corresponding columns allow null values. */

/*     DECLS          is an array of strings containing column */
/*                    declarations as required by EKBSEG or EKIFLD. */

/* $ Parameters */

/*     None. */

/* $ Exceptions */

/*     1) If the input table name is not recognized, the error */
/*        SPICE(NOSUCHTABLE) is signaled. */

/* $ Files */

/*     The table schemas created by this routine are intended to apply */
/*     to any test EK in a sequence of test EKs. */

/* $ Particulars */

/*     This routine is meant to support the automatic, non-interactive */
/*     testing of the SPICELIB EK system.  TSTSCH creates table schemas */
/*     for a series of tables to be used in EK testing.  The tables are */
/*     intended to be populated with data created by TSTENT, which */
/*     produces a predictable set of test data. */

/*     The table schemas created by this routine are described below. */


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

/* -    Testing Utilities Version 1.0.0, 15-JUL-1999 (NJB) */

/* -& */

/*     SPICELIB functions */


/*     Local variables */


/*     Standard SPICE error handling. */

    if (return_()) {
	return 0;
    } else {
	chkin_("TSTSCH", (ftnlen)6);
    }

/*     Check MXROWS. */

    if (*mxrows < 10) {
	setmsg_("Sorry, MXROWS was #; must be at least 10.", (ftnlen)41);
	errint_("#", mxrows, (ftnlen)1);
	sigerr_("SPICE(INVALIDCOUNT)", (ftnlen)19);
	chkout_("TSTSCH", (ftnlen)6);
	return 0;
    }

/*     The table-specific assignments follow.  Declaration strings are */
/*     built at the end, since the logic is identical for each table. */

    if (s_cmp(table, "SCALAR_1", table_len, (ftnlen)8) == 0) {
	*segtyp = 1;
	*nrows = 10;
	*ncols = 8;
	s_copy(cnames, "TABLE_NAME", cnames_len, (ftnlen)10);
	s_copy(cnames + cnames_len, "FILE_NO", cnames_len, (ftnlen)7);
	s_copy(cnames + (cnames_len << 1), "SEGMENT_NO", cnames_len, (ftnlen)
		10);
	s_copy(cnames + cnames_len * 3, "ROW_NO", cnames_len, (ftnlen)6);
	s_copy(cnames + (cnames_len << 2), "C_COL_1", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 5, "D_COL_1", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 6, "I_COL_1", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 7, "T_COL_1", cnames_len, (ftnlen)7);
	dtypes[0] = 1;
	dtypes[1] = 3;
	dtypes[2] = 3;
	dtypes[3] = 3;
	dtypes[4] = 1;
	dtypes[5] = 2;
	dtypes[6] = 3;
	dtypes[7] = 4;
	cleari_(ncols, stlens);
	stlens[0] = 64;
	stlens[4] = -1;
	i__1 = *ncols;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    dims__[i__ - 1] = 1;
	    indexd[i__ - 1] = FALSE_;
	    nullok[i__ - 1] = FALSE_;
	}
	cclass[0] = 3;
	cclass[1] = 1;
	cclass[2] = 1;
	cclass[3] = 1;
	cclass[4] = 3;
	cclass[5] = 2;
	cclass[6] = 1;
	cclass[7] = 2;
    } else if (s_cmp(table, "SCALAR_2", table_len, (ftnlen)8) == 0) {
	*segtyp = 1;
	*nrows = *mxrows;
	*ncols = 19;
	s_copy(cnames, "TABLE_NAME", cnames_len, (ftnlen)10);
	s_copy(cnames + cnames_len, "FILE_NO", cnames_len, (ftnlen)7);
	s_copy(cnames + (cnames_len << 1), "SEGMENT_NO", cnames_len, (ftnlen)
		10);
	s_copy(cnames + cnames_len * 3, "ROW_NO", cnames_len, (ftnlen)6);
	s_copy(cnames + (cnames_len << 2), "C_COL_1", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 5, "C_COL_2", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 6, "C_COL_3", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 7, "C_COL_4", cnames_len, (ftnlen)7);
	s_copy(cnames + (cnames_len << 3), "C_COL_5", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 9, "C_COL_6", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 10, "D_COL_1", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 11, "D_COL_2", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 12, "D_COL_3", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 13, "I_COL_1", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 14, "I_COL_2", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 15, "I_COL_3", cnames_len, (ftnlen)7);
	s_copy(cnames + (cnames_len << 4), "T_COL_1", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 17, "T_COL_2", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 18, "T_COL_3", cnames_len, (ftnlen)7);
	dtypes[0] = 1;
	dtypes[1] = 3;
	dtypes[2] = 3;
	dtypes[3] = 3;
	dtypes[4] = 1;
	dtypes[5] = 1;
	dtypes[6] = 1;
	dtypes[7] = 1;
	dtypes[8] = 1;
	dtypes[9] = 1;
	dtypes[10] = 2;
	dtypes[11] = 2;
	dtypes[12] = 2;
	dtypes[13] = 3;
	dtypes[14] = 3;
	dtypes[15] = 3;
	dtypes[16] = 4;
	dtypes[17] = 4;
	dtypes[18] = 4;
	cleari_(ncols, stlens);
	stlens[0] = 64;
	stlens[4] = -1;
	stlens[5] = -1;
	stlens[6] = -1;
	stlens[7] = 20;
	stlens[8] = 20;
	stlens[9] = 20;
	i__1 = *ncols;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    dims__[i__ - 1] = 1;
	    indexd[i__ - 1] = TRUE_;
	    nullok[i__ - 1] = i__ > 4;
	}
	cclass[0] = 3;
	cclass[1] = 1;
	cclass[2] = 1;
	cclass[3] = 1;
	cclass[4] = 3;
	cclass[5] = 3;
	cclass[6] = 3;
	cclass[7] = 3;
	cclass[8] = 3;
	cclass[9] = 3;
	cclass[10] = 2;
	cclass[11] = 2;
	cclass[12] = 2;
	cclass[13] = 1;
	cclass[14] = 1;
	cclass[15] = 1;
	cclass[16] = 2;
	cclass[17] = 2;
	cclass[18] = 2;
    } else if (s_cmp(table, "SCALAR_3", table_len, (ftnlen)8) == 0) {
	*segtyp = 2;
	*nrows = 10;
	*ncols = 8;
	s_copy(cnames, "TABLE_NAME", cnames_len, (ftnlen)10);
	s_copy(cnames + cnames_len, "FILE_NO", cnames_len, (ftnlen)7);
	s_copy(cnames + (cnames_len << 1), "SEGMENT_NO", cnames_len, (ftnlen)
		10);
	s_copy(cnames + cnames_len * 3, "ROW_NO", cnames_len, (ftnlen)6);
	s_copy(cnames + (cnames_len << 2), "C_COL_1", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 5, "D_COL_1", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 6, "I_COL_1", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 7, "T_COL_1", cnames_len, (ftnlen)7);
	dtypes[0] = 1;
	dtypes[1] = 3;
	dtypes[2] = 3;
	dtypes[3] = 3;
	dtypes[4] = 1;
	dtypes[5] = 2;
	dtypes[6] = 3;
	dtypes[7] = 4;
	cleari_(ncols, stlens);
	stlens[0] = 64;
	stlens[4] = 20;
	i__1 = *ncols;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    dims__[i__ - 1] = 1;
	    indexd[i__ - 1] = FALSE_;
	    nullok[i__ - 1] = FALSE_;
	}
	cclass[0] = 9;
	cclass[1] = 7;
	cclass[2] = 7;
	cclass[3] = 7;
	cclass[4] = 9;
	cclass[5] = 8;
	cclass[6] = 7;
	cclass[7] = 8;
    } else if (s_cmp(table, "SCALAR_4", table_len, (ftnlen)8) == 0) {
	*segtyp = 2;
	*nrows = *mxrows;
	*ncols = 16;
	s_copy(cnames, "TABLE_NAME", cnames_len, (ftnlen)10);
	s_copy(cnames + cnames_len, "FILE_NO", cnames_len, (ftnlen)7);
	s_copy(cnames + (cnames_len << 1), "SEGMENT_NO", cnames_len, (ftnlen)
		10);
	s_copy(cnames + cnames_len * 3, "ROW_NO", cnames_len, (ftnlen)6);
	s_copy(cnames + (cnames_len << 2), "C_COL_1", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 5, "C_COL_2", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 6, "C_COL_3", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 7, "D_COL_1", cnames_len, (ftnlen)7);
	s_copy(cnames + (cnames_len << 3), "D_COL_2", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 9, "D_COL_3", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 10, "I_COL_1", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 11, "I_COL_2", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 12, "I_COL_3", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 13, "T_COL_1", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 14, "T_COL_2", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 15, "T_COL_3", cnames_len, (ftnlen)7);
	dtypes[0] = 1;
	dtypes[1] = 3;
	dtypes[2] = 3;
	dtypes[3] = 3;
	dtypes[4] = 1;
	dtypes[5] = 1;
	dtypes[6] = 1;
	dtypes[7] = 2;
	dtypes[8] = 2;
	dtypes[9] = 2;
	dtypes[10] = 3;
	dtypes[11] = 3;
	dtypes[12] = 3;
	dtypes[13] = 4;
	dtypes[14] = 4;
	dtypes[15] = 4;
	cleari_(ncols, stlens);
	stlens[0] = 64;
	stlens[4] = 20;
	stlens[5] = 20;
	stlens[6] = 20;
	i__1 = *ncols;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    dims__[i__ - 1] = 1;
	    indexd[i__ - 1] = TRUE_;
	    nullok[i__ - 1] = i__ > 4;
	}
	cclass[0] = 9;
	cclass[1] = 7;
	cclass[2] = 7;
	cclass[3] = 7;
	cclass[4] = 9;
	cclass[5] = 9;
	cclass[6] = 9;
	cclass[7] = 8;
	cclass[8] = 8;
	cclass[9] = 8;
	cclass[10] = 7;
	cclass[11] = 7;
	cclass[12] = 7;
	cclass[13] = 8;
	cclass[14] = 8;
	cclass[15] = 8;
    } else if (s_cmp(table, "VECTOR_1", table_len, (ftnlen)8) == 0) {
	*segtyp = 1;
	*nrows = 3;
	*ncols = 12;
	s_copy(cnames, "TABLE_NAME", cnames_len, (ftnlen)10);
	s_copy(cnames + cnames_len, "FILE_NO", cnames_len, (ftnlen)7);
	s_copy(cnames + (cnames_len << 1), "SEGMENT_NO", cnames_len, (ftnlen)
		10);
	s_copy(cnames + cnames_len * 3, "ROW_NO", cnames_len, (ftnlen)6);
	s_copy(cnames + (cnames_len << 2), "C_COL_1", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 5, "C_COL_2", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 6, "D_COL_1", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 7, "D_COL_2", cnames_len, (ftnlen)7);
	s_copy(cnames + (cnames_len << 3), "I_COL_1", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 9, "I_COL_2", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 10, "T_COL_1", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 11, "T_COL_2", cnames_len, (ftnlen)7);
	dtypes[0] = 1;
	dtypes[1] = 3;
	dtypes[2] = 3;
	dtypes[3] = 3;
	dtypes[4] = 1;
	dtypes[5] = 1;
	dtypes[6] = 2;
	dtypes[7] = 2;
	dtypes[8] = 3;
	dtypes[9] = 3;
	dtypes[10] = 4;
	dtypes[11] = 4;
	cleari_(ncols, stlens);
	stlens[0] = 64;
	stlens[4] = 1024;
	stlens[5] = 100;
	dims__[0] = 1;
	dims__[1] = 1;
	dims__[2] = 1;
	dims__[3] = 1;
	dims__[4] = 3;
	dims__[5] = -1;
	dims__[6] = 4;
	dims__[7] = -1;
	dims__[8] = 5;
	dims__[9] = -1;
	dims__[10] = 6;
	dims__[11] = -1;
	i__1 = *ncols;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    indexd[i__ - 1] = FALSE_;
	    nullok[i__ - 1] = FALSE_;
	}
	cclass[0] = 3;
	cclass[1] = 1;
	cclass[2] = 1;
	cclass[3] = 1;
	cclass[4] = 6;
	cclass[5] = 6;
	cclass[6] = 5;
	cclass[7] = 5;
	cclass[8] = 4;
	cclass[9] = 4;
	cclass[10] = 5;
	cclass[11] = 5;
    } else if (s_cmp(table, "VECTOR_2", table_len, (ftnlen)8) == 0) {
	*segtyp = 1;
	*nrows = 3;
	*ncols = 20;
	s_copy(cnames, "TABLE_NAME", cnames_len, (ftnlen)10);
	s_copy(cnames + cnames_len, "FILE_NO", cnames_len, (ftnlen)7);
	s_copy(cnames + (cnames_len << 1), "SEGMENT_NO", cnames_len, (ftnlen)
		10);
	s_copy(cnames + cnames_len * 3, "ROW_NO", cnames_len, (ftnlen)6);
	s_copy(cnames + (cnames_len << 2), "C_COL_1", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 5, "C_COL_2", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 6, "C_COL_3", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 7, "C_COL_4", cnames_len, (ftnlen)7);
	s_copy(cnames + (cnames_len << 3), "D_COL_1", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 9, "D_COL_2", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 10, "D_COL_3", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 11, "D_COL_4", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 12, "I_COL_1", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 13, "I_COL_2", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 14, "I_COL_3", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 15, "I_COL_4", cnames_len, (ftnlen)7);
	s_copy(cnames + (cnames_len << 4), "T_COL_1", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 17, "T_COL_2", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 18, "T_COL_3", cnames_len, (ftnlen)7);
	s_copy(cnames + cnames_len * 19, "T_COL_4", cnames_len, (ftnlen)7);
	dtypes[0] = 1;
	dtypes[1] = 3;
	dtypes[2] = 3;
	dtypes[3] = 3;
	dtypes[4] = 1;
	dtypes[5] = 1;
	dtypes[6] = 1;
	dtypes[7] = 1;
	dtypes[8] = 2;
	dtypes[9] = 2;
	dtypes[10] = 2;
	dtypes[11] = 2;
	dtypes[12] = 3;
	dtypes[13] = 3;
	dtypes[14] = 3;
	dtypes[15] = 3;
	dtypes[16] = 4;
	dtypes[17] = 4;
	dtypes[18] = 4;
	dtypes[19] = 4;
	cleari_(ncols, stlens);
	stlens[0] = 64;
	stlens[4] = 1024;
	stlens[5] = 1024;
	stlens[6] = 1024;
	stlens[7] = 1024;
	dims__[0] = 1;
	dims__[1] = 1;
	dims__[2] = 1;
	dims__[3] = 1;
	dims__[4] = 3;
	dims__[5] = 5;
	dims__[6] = -1;
	dims__[7] = -1;
	dims__[8] = 4;
	dims__[9] = 6;
	dims__[10] = -1;
	dims__[11] = -1;
	dims__[12] = 5;
	dims__[13] = 7;
	dims__[14] = -1;
	dims__[15] = -1;
	dims__[16] = 6;
	dims__[17] = 8;
	dims__[18] = -1;
	dims__[19] = -1;
	i__1 = *ncols;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    indexd[i__ - 1] = i__ <= 4;
	    nullok[i__ - 1] = i__ > 4;
	}
	cclass[0] = 3;
	cclass[1] = 1;
	cclass[2] = 1;
	cclass[3] = 1;
	cclass[4] = 6;
	cclass[5] = 6;
	cclass[6] = 6;
	cclass[7] = 6;
	cclass[8] = 5;
	cclass[9] = 5;
	cclass[10] = 5;
	cclass[11] = 5;
	cclass[12] = 4;
	cclass[13] = 4;
	cclass[14] = 4;
	cclass[15] = 4;
	cclass[16] = 5;
	cclass[17] = 5;
	cclass[18] = 5;
	cclass[19] = 5;
    } else {
	setmsg_("Table # does not exist.", (ftnlen)23);
	errch_("#", table, (ftnlen)1, table_len);
	sigerr_("SPICE(NOSUCHTABLE)", (ftnlen)18);
	chkout_("TSTSCH", (ftnlen)6);
	return 0;
    }

/*     Build the declaration strings for the columns. */

    i__1 = *ncols;
    for (i__ = 1; i__ <= i__1; ++i__) {

/*        Fill in the data type assigment.  For string-valued columns, */
/*        this includes a string length. */

	s_copy(decls + (i__ - 1) * decls_len, "DATATYPE = ", decls_len, (
		ftnlen)11);
	if (dtypes[i__ - 1] == 1) {
	    suffix_("CHARACTER*(#)", &c__1, decls + (i__ - 1) * decls_len, (
		    ftnlen)13, decls_len);
	    if (stlens[i__ - 1] > 0) {
		repmi_(decls + (i__ - 1) * decls_len, "#", &stlens[i__ - 1], 
			decls + (i__ - 1) * decls_len, decls_len, (ftnlen)1, 
			decls_len);
	    } else {
		repmc_(decls + (i__ - 1) * decls_len, "#", "*", decls + (i__ 
			- 1) * decls_len, decls_len, (ftnlen)1, (ftnlen)1, 
			decls_len);
	    }
	} else if (dtypes[i__ - 1] == 2) {
	    suffix_("DOUBLE PRECISION", &c__1, decls + (i__ - 1) * decls_len, 
		    (ftnlen)16, decls_len);
	} else if (dtypes[i__ - 1] == 3) {
	    suffix_("INTEGER", &c__1, decls + (i__ - 1) * decls_len, (ftnlen)
		    7, decls_len);
	} else {
	    suffix_("TIME", &c__1, decls + (i__ - 1) * decls_len, (ftnlen)4, 
		    decls_len);
	}

/*        If the dimension is not 1, add a dimension */
/*        specifier. */

	if (dims__[i__ - 1] > 1) {
	    suffix_(", SIZE = #", &c__0, decls + (i__ - 1) * decls_len, (
		    ftnlen)10, decls_len);
	    repmi_(decls + (i__ - 1) * decls_len, "#", &dims__[i__ - 1], 
		    decls + (i__ - 1) * decls_len, decls_len, (ftnlen)1, 
		    decls_len);
	} else if (dims__[i__ - 1] == -1) {

/*           This column has variable dimension. */

	    suffix_(", SIZE = #", &c__0, decls + (i__ - 1) * decls_len, (
		    ftnlen)10, decls_len);
	    repmc_(decls + (i__ - 1) * decls_len, "#", "VARIABLE", decls + (
		    i__ - 1) * decls_len, decls_len, (ftnlen)1, (ftnlen)8, 
		    decls_len);
	}

/*        If the column is indexed, add an index specifier. */

	if (indexd[i__ - 1]) {
	    suffix_(", INDEXED = TRUE", &c__0, decls + (i__ - 1) * decls_len, 
		    (ftnlen)16, decls_len);
	}

/*        If the column may contain nulls, add a null value specifier. */

	if (nullok[i__ - 1]) {
	    suffix_(", NULLS_OK = TRUE", &c__0, decls + (i__ - 1) * decls_len,
		     (ftnlen)17, decls_len);
	}

/*        If the segment has type 2, the column must be a fixed count */
/*        column.  Add the fixed count specifier in this case. */

	if (*segtyp == 2) {
	    suffix_(", FIXED_COUNT = TRUE", &c__0, decls + (i__ - 1) * 
		    decls_len, (ftnlen)20, decls_len);
	}
    }
    chkout_("TSTSCH", (ftnlen)6);
    return 0;
} /* tstsch_ */

