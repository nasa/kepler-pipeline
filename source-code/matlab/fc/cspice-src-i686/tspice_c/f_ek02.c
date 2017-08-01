/* f_ek02.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static integer c__0 = 0;
static integer c__6 = 6;
static integer c__1 = 1;
static integer c__2 = 2;
static integer c__3 = 3;
static integer c__4 = 4;
static doublereal c_b126 = 0.;

/* $Procedure F_EK02 ( EK tests, subset 2 ) */
/* Subroutine */ int f_ek02__(logical *ok)
{
    /* System generated locals */
    integer i__1, i__2, i__3;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    integer i__, j;
    char label[80];
    extern /* Subroutine */ int tcase_(char *, ftnlen), ekcls_(integer *);
    integer recno;
    char cvals[80*10];
    doublereal dvals[10];
    integer segno;
    extern /* Subroutine */ int ekopn_(char *, char *, integer *, integer *, 
	    ftnlen, ftnlen), repmi_(char *, char *, integer *, char *, ftnlen,
	     ftnlen, ftnlen);
    integer ivals[10];
    extern /* Subroutine */ int ekopr_(char *, integer *, ftnlen);
    integer nvals;
    extern /* Subroutine */ int topen_(char *, ftnlen), ekopw_(char *, 
	    integer *, ftnlen);
    logical xnull;
    extern /* Subroutine */ int t_success__(logical *), ekacec_(integer *, 
	    integer *, integer *, char *, integer *, char *, logical *, 
	    ftnlen, ftnlen), ekaced_(integer *, integer *, integer *, char *, 
	    integer *, doublereal *, logical *, ftnlen), chckad_(char *, 
	    doublereal *, char *, doublereal *, integer *, doublereal *, 
	    logical *, ftnlen, ftnlen), ekacei_(integer *, integer *, integer 
	    *, char *, integer *, integer *, logical *, ftnlen), chckai_(char 
	    *, integer *, char *, integer *, integer *, logical *, ftnlen, 
	    ftnlen);
    integer handle;
    char cdecls[200*100];
    extern /* Subroutine */ int delfil_(char *, ftnlen), ekbseg_(integer *, 
	    char *, integer *, char *, char *, integer *, ftnlen, ftnlen, 
	    ftnlen), ekuced_(integer *, integer *, integer *, char *, integer 
	    *, doublereal *, logical *, ftnlen), chckxc_(logical *, char *, 
	    logical *, ftnlen), ekucei_(integer *, integer *, integer *, char 
	    *, integer *, integer *, logical *, ftnlen);
    char cnames[32*100];
    extern /* Subroutine */ int ekdelr_(integer *, integer *, integer *), 
	    ekucec_(integer *, integer *, integer *, char *, integer *, char *
	    , logical *, ftnlen, ftnlen), ekrcei_(integer *, integer *, 
	    integer *, char *, integer *, integer *, logical *, ftnlen), 
	    chcksl_(char *, logical *, logical *, logical *, ftnlen), chcksi_(
	    char *, integer *, char *, integer *, integer *, logical *, 
	    ftnlen, ftnlen), ekrced_(integer *, integer *, integer *, char *, 
	    integer *, doublereal *, logical *, ftnlen), chcksd_(char *, 
	    doublereal *, char *, doublereal *, doublereal *, logical *, 
	    ftnlen, ftnlen), ekrcec_(integer *, integer *, integer *, char *, 
	    integer *, char *, logical *, ftnlen, ftnlen), chcksc_(char *, 
	    char *, char *, char *, logical *, ftnlen, ftnlen, ftnlen, ftnlen)
	    , ekappr_(integer *, integer *, integer *), unload_(char *, 
	    ftnlen);
    char xcvals[80*10];
    extern logical exists_(char *, ftnlen);
    doublereal xdvals[10];
    integer xivals[10];
    logical isnull;
    extern /* Subroutine */ int tstlsk_(void), intstr_(integer *, char *, 
	    ftnlen), ekinsr_(integer *, integer *, integer *), suffix_(char *,
	     integer *, char *, ftnlen, ftnlen);
    char msg[240];

/* $ Abstract */

/*     Exercise the SPICELIB EK routines, subset 2. */

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

/*     TEST FAMILY */

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


/*     Include Section:  EK Column Attribute Descriptor Parameters */

/*        ekattdsc.inc Version 1    23-AUG-1995 (NJB) */


/*     This include file declares parameters used in EK column */
/*     attribute descriptors.  Column attribute descriptors are */
/*     a simplified version of column descriptors:  attribute */
/*     descriptors describe attributes of a column but do not contain */
/*     addresses or pointers. */


/*     Size of column attribute descriptor */


/*     Indices of various pieces of attribute descriptors: */


/*     ATTSIZ is the index of the column's class code.  (We use the */
/*     word `class' to distinguish this item from the column's data */
/*     type.) */


/*     ATTTYP is the index of the column's data type code (CHR, INT, DP, */
/*     or TIME).  The type is actually implied by the class, but it */
/*     will frequently be convenient to look up the type directly. */



/*     ATTLEN is the index of the column's string length value, if the */
/*     column has character type.  A value of IFALSE in this element of */
/*     the descriptor indicates that the strings have variable length. */


/*     ATTSIZ is the index of the column's element size value.  This */
/*     descriptor element is meaningful for columns with fixed-size */
/*     entries.  For variable-sized columns, this value is IFALSE. */


/*     ATTIDX is the location of a flag that indicates whether the column */
/*     is indexed.  The flag takes the value ITRUE if the column is */
/*     indexed and otherwise takes the value IFALSE. */


/*     ATTNFL is the index of a flag indicating whether nulls are */
/*     permitted in the column.  The value at location NFLIDX is */
/*     ITRUE if nulls are permitted and IFALSE otherwise. */


/*     End Include Section:  EK Column Attribute Descriptor Parameters */

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


/*     Include File:  SPICELIB Error Handling Parameters */

/*        errhnd.inc  Version 2    18-JUN-1997 (WLT) */

/*           The size of the long error message was */
/*           reduced from 25*80 to 23*80 so that it */
/*           will be accepted by the Microsoft Power Station */
/*           FORTRAN compiler which has an upper bound */
/*           of 1900 for the length of a character string. */

/*        errhnd.inc  Version 1    29-JUL-1997 (NJB) */



/*     Maximum length of the long error message: */


/*     Maximum length of the short error message: */


/*     End Include File:  SPICELIB Error Handling Parameters */

/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  -------------------------------------------------- */
/*     OK         O   logical indicating test status. */

/* $ Detailed_Input */

/*     None. */

/* $ Detailed_Output */

/*     OK         is a logical that indicates the test status to the */
/*                caller. */

/* $ Parameters */

/*     None. */

/* $ Files */

/*     None. */

/* $ Exceptions */

/*     This routine does not generate any errors. Routines in its */
/*     call tree may generate errors that are either intentional and */
/*     trapped or unintentional and need reporting.  The test family */
/*     utilities manage this. */

/* $ Particulars */

/*     This routine tests the wrappers for a subset of the EK routines: */

/*        EKAPPR */
/*        EKACEC */
/*        EKACED */
/*        EKACEI */
/*        EKBSEG */
/*        EKDELR */
/*        EKINSR */
/*        EKRCEC */
/*        EKRCED */
/*        EKRCEI */
/*        EKUCEC */
/*        EKUCED */
/*        EKUCEI */

/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     N.J. Bachman     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    TSPICE Version 1.0.0, 14-SEP-2005 (NJB) */


/* -& */

/*     SPICELIB functions */


/*     Local Parameters */


/*     Local Variables */


/*     Open the test family. */

    topen_("F_EK02", (ftnlen)6);

/* --- Case: ------------------------------------------------------ */

    tcase_("Create a new EK using the record-oriented writing routines.", (
	    ftnlen)59);

/*     Load a leapseconds kernel for UTC/ET conversion. */

    tstlsk_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Open a new EK file. For simplicity, we will not reserve any space */
/*     for the comment area, so the number of reserved comment */
/*     characters is zero. The constant IFNAME is the internal file */
/*     name. */

    if (exists_("test1.ek", (ftnlen)8)) {
	delfil_("test1.ek", (ftnlen)8);
    }

/*     Create an EK. */

    ekopn_("test1.ek", "Test EK", &c__0, &handle, (ftnlen)8, (ftnlen)7);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Set up the table and column names and declarations for the first */
/*     segment.  We'll index all of the scalar columns. */

    s_copy(cnames, "INT_COL_1", (ftnlen)32, (ftnlen)9);
    s_copy(cdecls, "DATATYPE = INTEGER, INDEXED  = TRUE, NULLS_OK = TRUE", (
	    ftnlen)200, (ftnlen)52);
    s_copy(cnames + 32, "DP_COL_1", (ftnlen)32, (ftnlen)8);
    s_copy(cdecls + 200, "DATATYPE = DOUBLE PRECISION, INDEXED  = TRUE, NULL"
	    "S_OK = TRUE", (ftnlen)200, (ftnlen)61);
    s_copy(cnames + 64, "CHR_COL_1", (ftnlen)32, (ftnlen)9);
    s_copy(cdecls + 400, "DATATYPE = CHARACTER*(*), INDEXED  = TRUE, NULLS_O"
	    "K = TRUE", (ftnlen)200, (ftnlen)58);
    s_copy(cnames + 96, "INT_COL_2", (ftnlen)32, (ftnlen)9);
    s_copy(cdecls + 600, "DATATYPE = INTEGER, SIZE     = VARIABLE, NULLS_OK "
	    "= TRUE", (ftnlen)200, (ftnlen)56);
    s_copy(cnames + 128, "DP_COL_2", (ftnlen)32, (ftnlen)8);
    s_copy(cdecls + 800, "DATATYPE = DOUBLE PRECISION, SIZE     = VARIABLE, "
	    "NULLS_OK = TRUE", (ftnlen)200, (ftnlen)65);
    s_copy(cnames + 160, "CHR_COL_2", (ftnlen)32, (ftnlen)9);
    s_copy(cdecls + 1000, "DATATYPE = CHARACTER*(80), SIZE     = VARIABLE, N"
	    "ULLS_OK = TRUE", (ftnlen)200, (ftnlen)63);

/*     Start the segment. */

    ekbseg_(&handle, "TEST_DATA", &c__6, cnames, cdecls, &segno, (ftnlen)9, (
	    ftnlen)32, (ftnlen)200);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Load values into the columns. */

    for (i__ = 0; i__ <= 99; ++i__) {

/*        Append an empty record to the segment. */

	ekappr_(&handle, &segno, &recno);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Add an integer column entry. */

	ivals[0] = i__;
	isnull = i__ == 1;
	ekacei_(&handle, &segno, &recno, cnames, &c__1, ivals, &isnull, (
		ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Add a d.p. column entry. */

	dvals[0] = (doublereal) i__;
	isnull = i__ == 1;
	ekaced_(&handle, &segno, &recno, cnames + 32, &c__1, dvals, &isnull, (
		ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Add a character column entry. */

	intstr_(&i__, cvals, (ftnlen)80);
	isnull = i__ == 1;
	ekacec_(&handle, &segno, &recno, cnames + 64, &c__1, cvals, &isnull, (
		ftnlen)32, (ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Array-valued columns follow. */

	ivals[0] = i__ * 10;
	ivals[1] = i__ * 10 + 1;
	isnull = i__ == 1;
	ekacei_(&handle, &segno, &recno, cnames + 96, &c__2, ivals, &isnull, (
		ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	dvals[0] = (doublereal) (i__ * 10);
	dvals[1] = (doublereal) (i__ * 10 + 1);
	dvals[2] = (doublereal) (i__ * 10 + 1);
	isnull = i__ == 1;
	ekaced_(&handle, &segno, &recno, cnames + 128, &c__3, dvals, &isnull, 
		(ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	i__1 = i__ * 10;
	intstr_(&i__1, cvals, (ftnlen)80);
	i__1 = i__ * 10 + 1;
	intstr_(&i__1, cvals + 80, (ftnlen)80);
	i__1 = i__ * 10 + 2;
	intstr_(&i__1, cvals + 160, (ftnlen)80);
	i__1 = i__ * 10 + 3;
	intstr_(&i__1, cvals + 240, (ftnlen)80);
	isnull = i__ == 1;
	ekacec_(&handle, &segno, &recno, cnames + 160, &c__4, cvals, &isnull, 
		(ftnlen)32, (ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     End the file. */

    ekcls_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Update the EK: knock out the odd-numbered records.", (ftnlen)50);

/*     Open the file for write access. */

    ekopw_("test1.ek", &handle, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Knock out all of the records containing even numbers. */

    segno = 1;
    for (recno = 1; recno <= 50; ++recno) {
	ekdelr_(&handle, &segno, &recno);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("Replace the missing records with records containing the negative"
	    "s of the original values.", (ftnlen)89);
    for (i__ = 0; i__ <= 99; i__ += 2) {
	recno = i__ + 1;

/*        Insert a record at index RECNO. */

	ekinsr_(&handle, &segno, &recno);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Add a scalar integer column entry. */

	ivals[0] = -i__;
	isnull = i__ == 1;
	ekacei_(&handle, &segno, &recno, cnames, &c__1, ivals, &isnull, (
		ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Add a d.p. column entry. */

	dvals[0] = (doublereal) (-i__);
	isnull = i__ == 1;
	ekaced_(&handle, &segno, &recno, cnames + 32, &c__1, dvals, &isnull, (
		ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Add a character column entry. */

	i__1 = -i__;
	intstr_(&i__1, cvals, (ftnlen)80);
	isnull = i__ == 1;
	ekacec_(&handle, &segno, &recno, cnames + 64, &c__1, cvals, &isnull, (
		ftnlen)32, (ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Array-valued columns follow. */

	ivals[0] = -(i__ * 10);
	ivals[1] = -(i__ * 10 + 1);
	isnull = i__ == 1;
	ekacei_(&handle, &segno, &recno, cnames + 96, &c__2, ivals, &isnull, (
		ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	dvals[0] = (doublereal) (-(i__ * 10));
	dvals[1] = (doublereal) (-(i__ * 10 + 1));
	dvals[2] = (doublereal) (-(i__ * 10 + 1));
	isnull = i__ == 1;
	ekaced_(&handle, &segno, &recno, cnames + 128, &c__3, dvals, &isnull, 
		(ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	i__1 = -(i__ * 10);
	intstr_(&i__1, cvals, (ftnlen)80);
	i__1 = -(i__ * 10 + 1);
	intstr_(&i__1, cvals + 80, (ftnlen)80);
	i__1 = -(i__ * 10 + 2);
	intstr_(&i__1, cvals + 160, (ftnlen)80);
	i__1 = -(i__ * 10 + 3);
	intstr_(&i__1, cvals + 240, (ftnlen)80);
	isnull = i__ == 1;
	ekacec_(&handle, &segno, &recno, cnames + 160, &c__4, cvals, &isnull, 
		(ftnlen)32, (ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("Negate the values in the even-numbered records using the update "
	    "routines.", (ftnlen)73);
    for (i__ = 1; i__ <= 99; i__ += 2) {
	recno = i__ + 1;

/*        Update the scalar integer column entry. */

	ivals[0] = -i__;
	isnull = i__ == 1;
	ekucei_(&handle, &segno, &recno, cnames, &c__1, ivals, &isnull, (
		ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Update the d.p. column entry. */

	dvals[0] = (doublereal) (-i__);
	isnull = i__ == 1;
	ekuced_(&handle, &segno, &recno, cnames + 32, &c__1, dvals, &isnull, (
		ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Update the character column entry. */

	i__1 = -i__;
	intstr_(&i__1, cvals, (ftnlen)80);
	isnull = i__ == 1;
	ekucec_(&handle, &segno, &recno, cnames + 64, &c__1, cvals, &isnull, (
		ftnlen)32, (ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Array-valued columns follow. */

	ivals[0] = -(i__ * 10);
	ivals[1] = -(i__ * 10 + 1);
	isnull = i__ == 1;
	ekucei_(&handle, &segno, &recno, cnames + 96, &c__2, ivals, &isnull, (
		ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	dvals[0] = (doublereal) (-(i__ * 10));
	dvals[1] = (doublereal) (-(i__ * 10 + 1));
	dvals[2] = (doublereal) (-(i__ * 10 + 1));
	isnull = i__ == 1;
	ekuced_(&handle, &segno, &recno, cnames + 128, &c__3, dvals, &isnull, 
		(ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	i__1 = -(i__ * 10);
	intstr_(&i__1, cvals, (ftnlen)80);
	i__1 = -(i__ * 10 + 1);
	intstr_(&i__1, cvals + 80, (ftnlen)80);
	i__1 = -(i__ * 10 + 2);
	intstr_(&i__1, cvals + 160, (ftnlen)80);
	i__1 = -(i__ * 10 + 3);
	intstr_(&i__1, cvals + 240, (ftnlen)80);
	isnull = i__ == 1;
	ekucec_(&handle, &segno, &recno, cnames + 160, &c__4, cvals, &isnull, 
		(ftnlen)32, (ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     End the file. */

    ekcls_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */


/*     Open the file for read access; check the values we've written. */

    tcase_("Opening the file for read access; checking values using the EK l"
	    "ow-level readers.", (ftnlen)81);
    ekopr_("test1.ek", &handle, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    for (i__ = 0; i__ <= 99; ++i__) {

/* --- Case: ------------------------------------------------------ */

	recno = i__ + 1;
	s_copy(msg, "Checking row number #.", (ftnlen)240, (ftnlen)22);
	repmi_(msg, "#", &recno, msg, (ftnlen)240, (ftnlen)1, (ftnlen)240);
	tcase_(msg, (ftnlen)240);
	xivals[0] = -i__;
	xnull = i__ == 1;

/*        Check the scalar integer column entry. */

	ekrcei_(&handle, &segno, &recno, cnames, &nvals, ivals, &isnull, (
		ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("Null flag", &isnull, &xnull, ok, (ftnlen)9);
	chcksi_("NVALS", &nvals, "=", &c__1, &c__0, ok, (ftnlen)5, (ftnlen)1);
	if (! isnull) {
	    s_copy(label, "Column", (ftnlen)80, (ftnlen)6);
	    suffix_(cnames, &c__1, label, (ftnlen)32, (ftnlen)80);
	    chcksi_(label, ivals, "=", xivals, &c__0, ok, (ftnlen)80, (ftnlen)
		    1);
	}

/*        Check the d.p. column entry. */

	xdvals[0] = (doublereal) (-i__);
	xnull = i__ == 1;
	ekrced_(&handle, &segno, &recno, cnames + 32, &nvals, dvals, &isnull, 
		(ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("Null flag", &isnull, &xnull, ok, (ftnlen)9);
	chcksi_("NVALS", &nvals, "=", &c__1, &c__0, ok, (ftnlen)5, (ftnlen)1);
	if (! isnull) {
	    s_copy(label, "Column", (ftnlen)80, (ftnlen)6);
	    suffix_(cnames + 32, &c__1, label, (ftnlen)32, (ftnlen)80);
	    chcksd_(label, dvals, "=", xdvals, &c_b126, ok, (ftnlen)80, (
		    ftnlen)1);
	}

/*        Check the character column entry. */

	i__1 = -i__;
	intstr_(&i__1, xcvals, (ftnlen)80);
	xnull = i__ == 1;
	ekrcec_(&handle, &segno, &recno, cnames + 64, &nvals, cvals, &isnull, 
		(ftnlen)32, (ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("Null flag", &isnull, &xnull, ok, (ftnlen)9);
	chcksi_("NVALS", &nvals, "=", &c__1, &c__0, ok, (ftnlen)5, (ftnlen)1);
	if (! isnull) {
	    s_copy(label, "Column", (ftnlen)80, (ftnlen)6);
	    suffix_(cnames + 64, &c__1, label, (ftnlen)32, (ftnlen)80);
	    chcksc_(label, cvals, "=", xcvals, ok, (ftnlen)80, (ftnlen)80, (
		    ftnlen)1, (ftnlen)80);
	}

/*        Array-valued columns follow. */

	xivals[0] = -(i__ * 10);
	xivals[1] = -(i__ * 10 + 1);
	xnull = i__ == 1;
	ekrcei_(&handle, &segno, &recno, cnames + 96, &nvals, ivals, &isnull, 
		(ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	if (isnull) {
	    chcksi_("NVALS", &nvals, "=", &c__1, &c__0, ok, (ftnlen)5, (
		    ftnlen)1);
	} else {
	    chcksi_("NVALS", &nvals, "=", &c__2, &c__0, ok, (ftnlen)5, (
		    ftnlen)1);
	    s_copy(label, "Column", (ftnlen)80, (ftnlen)6);
	    suffix_(cnames + 96, &c__1, label, (ftnlen)32, (ftnlen)80);
	    chckai_(label, ivals, "=", xivals, &c__2, ok, (ftnlen)80, (ftnlen)
		    1);
	}
	xdvals[0] = (doublereal) (-(i__ * 10));
	xdvals[1] = (doublereal) (-(i__ * 10 + 1));
	xdvals[2] = (doublereal) (-(i__ * 10 + 1));
	xnull = i__ == 1;
	ekrced_(&handle, &segno, &recno, cnames + 128, &nvals, dvals, &isnull,
		 (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	if (isnull) {
	    chcksi_("NVALS", &nvals, "=", &c__1, &c__0, ok, (ftnlen)5, (
		    ftnlen)1);
	} else {
	    chcksi_("NVALS", &nvals, "=", &c__3, &c__0, ok, (ftnlen)5, (
		    ftnlen)1);
	    s_copy(label, "Column", (ftnlen)80, (ftnlen)6);
	    suffix_(cnames + 128, &c__1, label, (ftnlen)32, (ftnlen)80);
	    chckad_(label, dvals, "=", xdvals, &c__3, &c_b126, ok, (ftnlen)80,
		     (ftnlen)1);
	}
	i__1 = -(i__ * 10);
	intstr_(&i__1, xcvals, (ftnlen)80);
	i__1 = -(i__ * 10 + 1);
	intstr_(&i__1, xcvals + 80, (ftnlen)80);
	i__1 = -(i__ * 10 + 2);
	intstr_(&i__1, xcvals + 160, (ftnlen)80);
	i__1 = -(i__ * 10 + 3);
	intstr_(&i__1, xcvals + 240, (ftnlen)80);
	xnull = i__ == 1;
	ekrcec_(&handle, &segno, &recno, cnames + 160, &nvals, cvals, &isnull,
		 (ftnlen)32, (ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	if (isnull) {
	    chcksi_("NVALS", &nvals, "=", &c__1, &c__0, ok, (ftnlen)5, (
		    ftnlen)1);
	} else {
	    chcksi_("NVALS", &nvals, "=", &c__4, &c__0, ok, (ftnlen)5, (
		    ftnlen)1);
	    s_copy(label, "Column", (ftnlen)80, (ftnlen)6);
	    suffix_(cnames + 160, &c__1, label, (ftnlen)32, (ftnlen)80);
	    i__1 = nvals;
	    for (j = 1; j <= i__1; ++j) {
		chcksc_(label, cvals + ((i__2 = j - 1) < 10 && 0 <= i__2 ? 
			i__2 : s_rnge("cvals", i__2, "f_ek02__", (ftnlen)739))
			 * 80, "=", xcvals + ((i__3 = j - 1) < 10 && 0 <= 
			i__3 ? i__3 : s_rnge("xcvals", i__3, "f_ek02__", (
			ftnlen)739)) * 80, ok, (ftnlen)80, (ftnlen)80, (
			ftnlen)1, (ftnlen)80);
	    }
	}
    }

/*     End the file. */

    ekcls_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
/*     Unload the EK.  The TSPICE system will delete the file. */

    tcase_("Unload EK from query system.", (ftnlen)28);
    unload_("test1.ek", (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_ek02__ */

