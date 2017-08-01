/* f_ek01.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__20 = 20;
static logical c_false = FALSE_;
static integer c__0 = 0;
static logical c_true = TRUE_;
static doublereal c_b130 = 0.;
static integer c__1 = 1;
static integer c_n9 = -9;

/* $Procedure F_EK01 ( EK test, subset 1 ) */
/* Subroutine */ int f_ek01__(logical *ok)
{
    /* Initialized data */

    static char chtyps[4*4] = "CHR " "DP  " "INT " "TIME";
    static char tables[64*6] = "SCALAR_1                                    "
	    "                    " "SCALAR_2                                 "
	    "                       " "SCALAR_3                              "
	    "                          " "SCALAR_4                           "
	    "                             " "VECTOR_1                        "
	    "                                " "VECTOR_2                     "
	    "                                   ";

    /* System generated locals */
    integer i__1, i__2, i__3, i__4, i__5;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer), s_cmp(char *, char *, 
	    ftnlen, ftnlen);

    /* Local variables */
    extern /* Subroutine */ int ekgc_(integer *, integer *, integer *, char *,
	     logical *, logical *, ftnlen), ekgd_(integer *, integer *, 
	    integer *, doublereal *, logical *, logical *), ekgi_(integer *, 
	    integer *, integer *, integer *, logical *, logical *);
    char tabs[64*100];
    integer dims__[100], nseg;
    char xmsg[1840];
    integer unit;
    extern /* Subroutine */ int scs2e_(integer *, char *, doublereal *, 
	    ftnlen), zzektcnv_(char *, doublereal *, logical *, char *, 
	    ftnlen, ftnlen);
    integer i__;
    char cdata[1024];
    doublereal ddata[20];
    integer n, idata[20];
    extern /* Subroutine */ int eklef_(char *, integer *, ftnlen);
    char decls[200*100];
    doublereal tdata[20];
    extern /* Subroutine */ int tcase_(char *, ftnlen), ekuef_(integer *), 
	    ekcls_(integer *);
    integer tabno;
    extern /* Subroutine */ int repmc_(char *, char *, char *, char *, ftnlen,
	     ftnlen, ftnlen, ftnlen);
    char cvals[1024*20];
    doublereal dvals[20];
    integer colno, segno, xbegs[100];
    logical found;
    integer ivals[20], ncols;
    extern /* Subroutine */ int ekopr_(char *, integer *, ftnlen);
    integer xends[100];
    extern /* Subroutine */ int repmi_(char *, char *, integer *, char *, 
	    ftnlen, ftnlen, ftnlen), ekops_(integer *);
    char dtype[4];
    integer nelts;
    extern /* Subroutine */ int topen_(char *, ftnlen);
    doublereal tvals[20];
    logical error;
    extern /* Subroutine */ int tstek_(char *, integer *, integer *, logical *
	    , integer *, ftnlen), ekopn_(char *, char *, integer *, integer *,
	     ftnlen, ftnlen), ekopw_(char *, integer *, ftnlen);
    logical xnull;
    integer rowno;
    char query[2000];
    integer nrows;
    extern /* Subroutine */ int t_success__(logical *), tstck3_(char *, char *
	    , logical *, logical *, logical *, integer *, ftnlen, ftnlen), 
	    chckai_(char *, integer *, char *, integer *, integer *, logical *
	    , ftnlen, ftnlen), boddef_(char *, integer *, ftnlen), str2et_(
	    char *, doublereal *, ftnlen), ekacli_(integer *, integer *, char 
	    *, integer *, integer *, logical *, integer *, integer *, ftnlen);
    doublereal et;
    integer handle;
    extern /* Subroutine */ int chcksc_(char *, char *, char *, char *, 
	    logical *, ftnlen, ftnlen, ftnlen, ftnlen), chcksd_(char *, 
	    doublereal *, char *, doublereal *, doublereal *, logical *, 
	    ftnlen, ftnlen), ekfind_(char *, integer *, logical *, char *, 
	    ftnlen, ftnlen), ekifld_(integer *, char *, integer *, integer *, 
	    char *, char *, integer *, integer *, ftnlen, ftnlen, ftnlen);
    char tabnam[64], cnames[32*100];
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen);
    extern integer eknseg_(integer *);
    integer cclass[100], fileno;
    logical indexd[100];
    extern integer lastnb_(char *, ftnlen);
    extern /* Subroutine */ int chcksi_(char *, integer *, char *, integer *, 
	    integer *, logical *, ftnlen, ftnlen);
    logical nlflgs[20];
    extern logical exists_(char *, ftnlen);
    char column[32], errmsg[1840], shrtdc[200*1], shrtnm[32*1], sscnms[32*100]
	    , sstnam[64], timstr[50], xclass[4*100], xtypes[4*100];
    integer dtypes[100];
    char sstyps[4*100];
    integer eltidx, entszs[20], nmrows, rcptrs[20], segtyp, selidx, ssdims[
	    100], sslens[100], ssncol, ssnrow, stlens[100], xpbegs[100], 
	    xpends[100], xnelts, xnrows, wkindx[20];
    logical isnull, nullok[100], ssidxd[100], ssnlok[100];
    extern /* Subroutine */ int ekssum_(integer *, integer *, char *, integer 
	    *, integer *, char *, char *, integer *, integer *, logical *, 
	    logical *, ftnlen, ftnlen, ftnlen), tstsch_(char *, integer *, 
	    integer *, integer *, integer *, char *, integer *, integer *, 
	    integer *, integer *, logical *, logical *, char *, ftnlen, 
	    ftnlen, ftnlen), chcksl_(char *, logical *, logical *, logical *, 
	    ftnlen), tstmsg_(char *, char *, ftnlen, ftnlen), tstmsi_(integer 
	    *), tstent_(integer *, char *, integer *, char *, integer *, 
	    integer *, integer *, char *, doublereal *, integer *, doublereal 
	    *, logical *, ftnlen, ftnlen, ftnlen), eknelt_(integer *, integer 
	    *, integer *), suffix_(char *, integer *, char *, ftnlen, ftnlen),
	     tstmsc_(char *, ftnlen), ekffld_(integer *, integer *, integer *)
	    , dashlu_(integer *, integer *), delfil_(char *, ftnlen);
    char msg[1840];
    extern /* Subroutine */ int ekpsel_(char *, integer *, integer *, integer 
	    *, char *, char *, char *, char *, logical *, char *, ftnlen, 
	    ftnlen, ftnlen, ftnlen, ftnlen, ftnlen), dasfnh_(char *, integer *
	    , ftnlen), tstlsk_(void), dvpool_(char *, ftnlen), unload_(char *,
	     ftnlen);
    doublereal xet;

/* $ Abstract */

/*     Exercise the SPICELIB EK routines, subset 1. */

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

/*     This routine tests the wrappers for the subset of the EK routines: */

/*        EKACLC */
/*        EKACLD */
/*        EKACLI */
/*        EKCLS */
/*        EKFFLD */
/*        EKFIND */
/*        EKGC */
/*        EKGD */
/*        EKGI */
/*        EKIFLD */
/*        EKLEF */
/*        EKNELT */
/*        EKNSEG */
/*        EKOPN */
/*        EKOPR */
/*        EKOPW */
/*        EKPSEL */
/*        EKSSUM */
/*        EKUEF */

/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     N.J. Bachman     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    TSPICE Version 1.0.0, 25-OCT-2005 (NJB) */


/* -& */

/*     SPICELIB functions */


/*     Local Parameters */


/*     Local Variables */


/*     Saved variables */


/*     Initial values */


/*     Open the test family. */

    topen_("F_EK01", (ftnlen)6);

/* --- Case: ------------------------------------------------------ */

    tcase_("Test the EK writing and fast load routines:  EKOPN, EKIFLD, EKAC"
	    "LC, EKACLD, EKACLI, EKFFLD, EKCLS.  Also test EKSSUM.  All of th"
	    "is is done by TSTEK, which is called here.", (ftnlen)170);

/*     Create an EK. */

    fileno = 1;
    tstek_("test1.ek", &fileno, &c__20, &c_false, &handle, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Test EKOPR, EKSSUM and EKNSEG.  Get segment summaries and make s"
	    "ure they're compatible with the schemas returned by TSTSCH.", (
	    ftnlen)123);

/*     Find out how many segments are in the EK.  By the specification */
/*     of TSTEK, there's one segment per table. */

    ekopr_("test1.ek", &handle, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    nseg = eknseg_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    i__1 = nseg;
    for (segno = 1; segno <= i__1; ++segno) {

/*        Start a new test case. */

	s_copy(msg, "Testing EKTNAM, EKCCNT, EKCII for segment #", (ftnlen)
		1840, (ftnlen)43);
	repmi_(msg, "#", &segno, msg, (ftnlen)1840, (ftnlen)1, (ftnlen)1840);

/* --- Case: ------------------------------------------------------ */

	tcase_(msg, (ftnlen)1840);

/*        Get the summary for this segment. */

	ekssum_(&handle, &segno, sstnam, &ssnrow, &ssncol, sscnms, sstyps, 
		ssdims, sslens, ssidxd, ssnlok, (ftnlen)64, (ftnlen)32, (
		ftnlen)4);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Compare the attributes given by the segment summary to those */
/*        returned by TSTSCH.  These are: */

/*           - table name */
/*           - column count */
/*           - row count */
/*           - column names */
/*           - column descriptors */

/*        For each column descriptor, compare the attributes: */

/*           - data type */
/*           - string length */
/*           - size */
/*           - is the column indexed? */
/*           - does the column allow null values? */


/*        Look up the schema for this table. */

	s_copy(tabnam, tables + (((i__2 = segno - 1) < 6 && 0 <= i__2 ? i__2 :
		 s_rnge("tables", i__2, "f_ek01__", (ftnlen)406)) << 6), (
		ftnlen)64, (ftnlen)64);
	tstsch_(tabnam, &c__20, &segtyp, &nrows, &ncols, cnames, cclass, 
		dtypes, stlens, dims__, indexd, nullok, decls, (ftnlen)64, (
		ftnlen)32, (ftnlen)200);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Check the table name. */

	chcksc_("SSTNAM", sstnam, "=", tabnam, ok, (ftnlen)6, (ftnlen)64, (
		ftnlen)1, (ftnlen)64);

/*        Check the row and column counts. */

	chcksi_("NROWS from EKSSUM", &ssnrow, "=", &nrows, &c__0, ok, (ftnlen)
		17, (ftnlen)1);
	chcksi_("NCOLS from EKSSUM", &ssncol, "=", &ncols, &c__0, ok, (ftnlen)
		17, (ftnlen)1);

/*        For each column in the current table, check the column's */
/*        attributes.  The attribute block index parameters are defined */
/*        in the include file ekattdsc.inc. */

	i__2 = ncols;
	for (i__ = 1; i__ <= i__2; ++i__) {

/*           Check the column name. */

	    chcksc_("Column name", sscnms + (((i__3 = i__ - 1) < 100 && 0 <= 
		    i__3 ? i__3 : s_rnge("sscnms", i__3, "f_ek01__", (ftnlen)
		    438)) << 5), "=", cnames + (((i__4 = i__ - 1) < 100 && 0 
		    <= i__4 ? i__4 : s_rnge("cnames", i__4, "f_ek01__", (
		    ftnlen)438)) << 5), ok, (ftnlen)11, (ftnlen)32, (ftnlen)1,
		     (ftnlen)32);

/*           Check the current column's data type. */

	    chcksc_("Column data type", sstyps + (((i__3 = i__ - 1) < 100 && 
		    0 <= i__3 ? i__3 : s_rnge("sstyps", i__3, "f_ek01__", (
		    ftnlen)443)) << 2), "=", chtyps + (((i__5 = dtypes[(i__4 =
		     i__ - 1) < 100 && 0 <= i__4 ? i__4 : s_rnge("dtypes", 
		    i__4, "f_ek01__", (ftnlen)443)] - 1) < 4 && 0 <= i__5 ? 
		    i__5 : s_rnge("chtyps", i__5, "f_ek01__", (ftnlen)443)) <<
		     2), ok, (ftnlen)16, (ftnlen)4, (ftnlen)1, (ftnlen)4);

/*           If the data type is character, check the string length. */

	    if (dtypes[(i__3 = i__ - 1) < 100 && 0 <= i__3 ? i__3 : s_rnge(
		    "dtypes", i__3, "f_ek01__", (ftnlen)449)] == 1) {
		chcksi_("Column string length", &sslens[(i__3 = i__ - 1) < 
			100 && 0 <= i__3 ? i__3 : s_rnge("sslens", i__3, 
			"f_ek01__", (ftnlen)451)], "=", &stlens[(i__4 = i__ - 
			1) < 100 && 0 <= i__4 ? i__4 : s_rnge("stlens", i__4, 
			"f_ek01__", (ftnlen)451)], &c__0, ok, (ftnlen)20, (
			ftnlen)1);
	    }

/*           Check the current column's entry size. */

	    chcksi_("Column entry size", &ssdims[(i__3 = i__ - 1) < 100 && 0 
		    <= i__3 ? i__3 : s_rnge("ssdims", i__3, "f_ek01__", (
		    ftnlen)458)], "=", &dims__[(i__4 = i__ - 1) < 100 && 0 <= 
		    i__4 ? i__4 : s_rnge("dims", i__4, "f_ek01__", (ftnlen)
		    458)], &c__0, ok, (ftnlen)17, (ftnlen)1);

/*           Check the current column's index flag. */

	    chcksl_("Column index flag", &ssidxd[(i__3 = i__ - 1) < 100 && 0 
		    <= i__3 ? i__3 : s_rnge("ssidxd", i__3, "f_ek01__", (
		    ftnlen)464)], &indexd[(i__4 = i__ - 1) < 100 && 0 <= i__4 
		    ? i__4 : s_rnge("indexd", i__4, "f_ek01__", (ftnlen)464)],
		     ok, (ftnlen)17);

/*           Check the current column's null ok flag. */

	    chcksl_("Column null ok flag", &ssnlok[(i__3 = i__ - 1) < 100 && 
		    0 <= i__3 ? i__3 : s_rnge("ssnlok", i__3, "f_ek01__", (
		    ftnlen)470)], &nullok[(i__4 = i__ - 1) < 100 && 0 <= i__4 
		    ? i__4 : s_rnge("nullok", i__4, "f_ek01__", (ftnlen)470)],
		     ok, (ftnlen)19);
	}

/*        We're done with the current column. */

    }

/*     We're done with the current table. */


/*     Close the EK. */

    ekcls_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */



/*     Load the EK into the query system. */

    tcase_("Ah, the nitty gritty.  Test EKFIND, ENELT, and the fetching trip"
	    "lets EKGC, EKGD, EKGI.", (ftnlen)86);
    eklef_("test1.ek", &handle, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We start off with a simple case. */

    s_copy(query, "select c_col_1, d_col_1, i_col_1, t_col_1 from scalar_2 o"
	    "rder by row_no", (ftnlen)2000, (ftnlen)71);
    ekfind_(query, &nmrows, &error, errmsg, (ftnlen)2000, (ftnlen)1840);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    tstmsg_("#", "The error message was:  #", (ftnlen)1, (ftnlen)25);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("ERROR flag", &error, &c_false, ok, (ftnlen)10);

/*     The table 'SCALAR_2' occupies the second segment of the file */
/*     designated by EK1.  Segment numbers start at 1 and increment from */
/*     there. */

    segno = 2;
    ekssum_(&handle, &segno, sstnam, &ssnrow, &ssncol, sscnms, sstyps, ssdims,
	     sslens, ssidxd, ssnlok, (ftnlen)64, (ftnlen)32, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("NMROWS", &nmrows, "=", &ssnrow, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Check the data. */

    i__1 = nmrows;
    for (rowno = 1; rowno <= i__1; ++rowno) {

/*        First, fetch and test the character data. */

	selidx = 1;
	eltidx = 1;
	tstmsg_("#", "table = SCALAR_2; selidx = 1; col = c_col_1; row = #; "
		"eltidx = 1.", (ftnlen)1, (ftnlen)65);
	tstmsi_(&rowno);

/*        Fetch the value for c_col_1 from the current row. */

	ekgc_(&selidx, &rowno, &eltidx, cdata, &isnull, &found, (ftnlen)1024);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*        Look up the expected column entry. */

	tstent_(&fileno, "SCALAR_2", &segno, "C_COL_1", &rowno, &c__20, &
		xnelts, cvals, dvals, ivals, tvals, &xnull, (ftnlen)8, (
		ftnlen)7, (ftnlen)1024);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Check the null flag returned by EKGC. */

	chcksl_("ISNULL", &isnull, &xnull, ok, (ftnlen)6);

/*        Check the number of elements in the entry. */

	eknelt_(&selidx, &rowno, &nelts);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksi_("NELTS", &nelts, "=", &xnelts, &c__0, ok, (ftnlen)5, (ftnlen)
		1);
	if (! isnull) {

/*           Check the character string returned by EKGC. */

	    chcksc_("char value from EKGC", cdata, "=", cvals, ok, (ftnlen)20,
		     (ftnlen)1024, (ftnlen)1, (ftnlen)1024);
	}

/*        Check the d.p. data next. */

	selidx = 2;
	eltidx = 1;
	tstmsg_("#", "table = SCALAR_2; selidx = 2; col = d_col_1; row = #; "
		"eltidx = 1.", (ftnlen)1, (ftnlen)65);
	tstmsi_(&rowno);

/*        Fetch the value for d_col_1 from the current row. */

	ekgd_(&selidx, &rowno, &eltidx, ddata, &isnull, &found);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*        Look up the expected column entry. */

	tstent_(&fileno, "SCALAR_2", &segno, "D_COL_1", &rowno, &c__20, &
		xnelts, cvals, dvals, ivals, tvals, &xnull, (ftnlen)8, (
		ftnlen)7, (ftnlen)1024);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Check the null flag returned by EKGD. */

	chcksl_("ISNULL", &isnull, &xnull, ok, (ftnlen)6);

/*        Check the number of elements in the entry. */

	eknelt_(&selidx, &rowno, &nelts);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksi_("NELTS", &nelts, "=", &xnelts, &c__0, ok, (ftnlen)5, (ftnlen)
		1);
	if (! isnull) {

/*           Check the d.p. value returned by EKGD. */

	    chcksd_("D.P. value from EKGD", ddata, "=", dvals, &c_b130, ok, (
		    ftnlen)20, (ftnlen)1);
	}

/*        Check the integer data. */

	selidx = 3;
	eltidx = 1;
	tstmsg_("#", "table = SCALAR_2; selidx = 3; col = i_col_1; row = #; "
		"eltidx = 1.", (ftnlen)1, (ftnlen)65);
	tstmsi_(&rowno);

/*        Fetch the value for i_col_1 from the current row. */

	ekgi_(&selidx, &rowno, &eltidx, idata, &isnull, &found);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*        Look up the expected column entry. */

	tstent_(&fileno, "SCALAR_2", &segno, "I_COL_1", &rowno, &c__20, &
		xnelts, cvals, dvals, ivals, tvals, &xnull, (ftnlen)8, (
		ftnlen)7, (ftnlen)1024);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Check the null flag returned by EKGI. */

	chcksl_("ISNULL", &isnull, &xnull, ok, (ftnlen)6);

/*        Check the number of elements in the entry. */

	eknelt_(&selidx, &rowno, &nelts);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksi_("NELTS", &nelts, "=", &xnelts, &c__0, ok, (ftnlen)5, (ftnlen)
		1);
	if (! isnull) {

/*           Check the integer value returned by EKGI. */

	    chcksi_("Integer value from EKGI", idata, "=", ivals, &c__0, ok, (
		    ftnlen)23, (ftnlen)1);
	}

/*        Check the time data. */

	selidx = 4;
	eltidx = 1;
	tstmsg_("#", "table = SCALAR_2; selidx = 4; col = t_col_1; row = #; "
		"eltidx = 1.", (ftnlen)1, (ftnlen)65);
	tstmsi_(&rowno);

/*        Fetch the value for t_col_1 from the current row. */

	ekgd_(&selidx, &rowno, &eltidx, tdata, &isnull, &found);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*        Look up the expected column entry. */

	tstent_(&fileno, "SCALAR_2", &segno, "T_COL_1", &rowno, &c__20, &
		xnelts, cvals, dvals, ivals, tvals, &xnull, (ftnlen)8, (
		ftnlen)7, (ftnlen)1024);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Check the null flag returned by EKGD. */

	chcksl_("ISNULL", &isnull, &xnull, ok, (ftnlen)6);

/*        Check the number of elements in the entry. */

	eknelt_(&selidx, &rowno, &nelts);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksi_("NELTS", &nelts, "=", &xnelts, &c__0, ok, (ftnlen)5, (ftnlen)
		1);
	if (! isnull) {

/*           Check the time value returned by EKGD. */

	    chcksd_("Time value from EKGD", ddata, "=", tvals, &c_b130, ok, (
		    ftnlen)20, (ftnlen)1);
	}
    }

/*     Now for a more comprehensive test. */


/* --- Case: ------------------------------------------------------ */

    tcase_("This time, we loop over all tables, and we  check all entries in"
	    " each table.", (ftnlen)76);
    for (tabno = 1; tabno <= 6; ++tabno) {

/*        Get the row and column count for this table. */

	segno = tabno;

/*        Get the summary for this segment. */

	ekssum_(&handle, &segno, sstnam, &ssnrow, &ssncol, sscnms, sstyps, 
		ssdims, sslens, ssidxd, ssnlok, (ftnlen)64, (ftnlen)32, (
		ftnlen)4);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Build the query string:  select all columns from the current */
/*        table. */

	s_copy(query, "SELECT", (ftnlen)2000, (ftnlen)6);
	suffix_(sscnms, &c__1, query, (ftnlen)32, (ftnlen)2000);
	i__1 = ssncol;
	for (colno = 2; colno <= i__1; ++colno) {
	    suffix_(",", &c__0, query, (ftnlen)1, (ftnlen)2000);
	    suffix_(sscnms + (((i__2 = colno - 1) < 100 && 0 <= i__2 ? i__2 : 
		    s_rnge("sscnms", i__2, "f_ek01__", (ftnlen)794)) << 5), &
		    c__1, query, (ftnlen)32, (ftnlen)2000);
	}
	suffix_("FROM", &c__1, query, (ftnlen)4, (ftnlen)2000);
	suffix_(tables + (((i__1 = tabno - 1) < 6 && 0 <= i__1 ? i__1 : 
		s_rnge("tables", i__1, "f_ek01__", (ftnlen)799)) << 6), &c__1,
		 query, (ftnlen)64, (ftnlen)2000);
	suffix_("ORDER BY ROW_NO", &c__1, query, (ftnlen)15, (ftnlen)2000);

/*        Issue the query. */

	ekfind_(query, &nmrows, &error, errmsg, (ftnlen)2000, (ftnlen)1840);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Make sure there was no query resolution error. */

	tstmsg_("#", "The error message was:  #", (ftnlen)1, (ftnlen)25);
	tstmsc_(errmsg, (ftnlen)1840);
	chcksl_("ERROR flag", &error, &c_false, ok, (ftnlen)10);

/*        Check NMROWS. */

	chcksi_("NMROWS", &nmrows, "=", &ssnrow, &c__0, ok, (ftnlen)6, (
		ftnlen)1);

/*        Check the data. */

	ncols = ssncol;
	i__1 = nmrows;
	for (rowno = 1; rowno <= i__1; ++rowno) {
	    i__2 = ncols;
	    for (selidx = 1; selidx <= i__2; ++selidx) {

/*              Get the name and data type of the current column; */
/*              process the column accordingly. */

		s_copy(column, sscnms + (((i__3 = selidx - 1) < 100 && 0 <= 
			i__3 ? i__3 : s_rnge("sscnms", i__3, "f_ek01__", (
			ftnlen)834)) << 5), (ftnlen)32, (ftnlen)32);
		s_copy(dtype, sstyps + (((i__3 = selidx - 1) < 100 && 0 <= 
			i__3 ? i__3 : s_rnge("sstyps", i__3, "f_ek01__", (
			ftnlen)836)) << 2), (ftnlen)4, (ftnlen)4);
		s_copy(msg, "#Table is #. Column is #. Row is #. Current sel"
			"ect index is #.", (ftnlen)1840, (ftnlen)62);
		repmc_(msg, "#", tables + (((i__3 = tabno - 1) < 6 && 0 <= 
			i__3 ? i__3 : s_rnge("tables", i__3, "f_ek01__", (
			ftnlen)843)) << 6), msg, (ftnlen)1840, (ftnlen)1, (
			ftnlen)64, (ftnlen)1840);
		repmc_(msg, "#", column, msg, (ftnlen)1840, (ftnlen)1, (
			ftnlen)32, (ftnlen)1840);
		repmi_(msg, "#", &rowno, msg, (ftnlen)1840, (ftnlen)1, (
			ftnlen)1840);
		repmi_(msg, "#", &selidx, msg, (ftnlen)1840, (ftnlen)1, (
			ftnlen)1840);

/* --- Case: ------------------------------------------------------ */

		tcase_(msg, (ftnlen)1840);

/*              Look up the expected column entry. */

		tstent_(&fileno, tables + (((i__3 = tabno - 1) < 6 && 0 <= 
			i__3 ? i__3 : s_rnge("tables", i__3, "f_ek01__", (
			ftnlen)856)) << 6), &segno, column, &rowno, &c__20, &
			xnelts, cvals, dvals, ivals, tvals, &xnull, (ftnlen)
			64, (ftnlen)32, (ftnlen)1024);
		chckxc_(&c_false, " ", ok, (ftnlen)1);

/*              Check the number of elements in the entry. */

		eknelt_(&selidx, &rowno, &nelts);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		chcksi_("NELTS", &nelts, "=", &xnelts, &c__0, ok, (ftnlen)5, (
			ftnlen)1);

/*              Check the data. */

		i__3 = nelts;
		for (eltidx = 1; eltidx <= i__3; ++eltidx) {
		    tstmsg_("#", "Table is #. Column is #. Row is #. Current"
			    " element index is #.", (ftnlen)1, (ftnlen)62);
		    tstmsc_(tables + (((i__4 = tabno - 1) < 6 && 0 <= i__4 ? 
			    i__4 : s_rnge("tables", i__4, "f_ek01__", (ftnlen)
			    881)) << 6), (ftnlen)64);
		    tstmsc_(column, (ftnlen)32);
		    tstmsi_(&rowno);
		    tstmsi_(&eltidx);
		    if (s_cmp(dtype, "CHR", (ftnlen)4, (ftnlen)3) == 0) {
			ekgc_(&selidx, &rowno, &eltidx, cdata, &isnull, &
				found, (ftnlen)1024);

/*                    Make sure no error was signaled. */

			chckxc_(&c_false, " ", ok, (ftnlen)1);

/*                    Make sure the element was found. */

			chcksl_("FOUND flag", &found, &c_true, ok, (ftnlen)10)
				;

/*                    Check the null flag returned by EKGC. */

			chcksl_("NULL flag", &isnull, &xnull, ok, (ftnlen)9);
			if (! isnull) {

/*                       Check the character string returned by EKGC. */

			    chcksc_("char value from EKGC", cdata, "=", cvals 
				    + (((i__4 = eltidx - 1) < 20 && 0 <= i__4 
				    ? i__4 : s_rnge("cvals", i__4, "f_ek01__",
				     (ftnlen)911)) << 10), ok, (ftnlen)20, (
				    ftnlen)1024, (ftnlen)1, (ftnlen)1024);
			}
		    } else if (s_cmp(dtype, "DP", (ftnlen)4, (ftnlen)2) == 0) 
			    {
			ekgd_(&selidx, &rowno, &eltidx, ddata, &isnull, &
				found);

/*                    Make sure no error was signaled. */

			chckxc_(&c_false, " ", ok, (ftnlen)1);

/*                    Make sure the element was found. */

			chcksl_("FOUND flag", &found, &c_true, ok, (ftnlen)10)
				;

/*                    Check the null flag returned by EKGD. */

			chcksl_("NULL flag", &isnull, &xnull, ok, (ftnlen)9);
			if (! isnull) {

/*                       Check the d.p. value returned by EKGD. */

			    chcksd_("d.p. value from EKGD", ddata, "=", &
				    dvals[(i__4 = eltidx - 1) < 20 && 0 <= 
				    i__4 ? i__4 : s_rnge("dvals", i__4, "f_e"
				    "k01__", (ftnlen)941)], &c_b130, ok, (
				    ftnlen)20, (ftnlen)1);
			}
		    } else if (s_cmp(dtype, "INT", (ftnlen)4, (ftnlen)3) == 0)
			     {
			ekgi_(&selidx, &rowno, &eltidx, idata, &isnull, &
				found);

/*                    Make sure no error was signaled. */

			chckxc_(&c_false, " ", ok, (ftnlen)1);

/*                    Make sure the element was found. */

			chcksl_("FOUND flag", &found, &c_true, ok, (ftnlen)10)
				;

/*                    Check the null flag returned by EKGI. */

			chcksl_("NULL flag", &isnull, &xnull, ok, (ftnlen)9);
			if (! isnull) {

/*                       Check the integer value returned by EKGI. */

			    chcksi_("Integer value from EKGI", idata, "=", &
				    ivals[(i__4 = eltidx - 1) < 20 && 0 <= 
				    i__4 ? i__4 : s_rnge("ivals", i__4, "f_e"
				    "k01__", (ftnlen)972)], &c__0, ok, (ftnlen)
				    23, (ftnlen)1);
			}
		    } else {

/*                    DTYPE == 'TIME' */

			ekgd_(&selidx, &rowno, &eltidx, ddata, &isnull, &
				found);

/*                    Make sure no error was signaled. */

			chckxc_(&c_false, " ", ok, (ftnlen)1);

/*                    Make sure the element was found. */

			chcksl_("FOUND flag", &found, &c_true, ok, (ftnlen)10)
				;

/*                    Check the null flag returned by EKGD. */

			chcksl_("NULL flag", &isnull, &xnull, ok, (ftnlen)9);
			if (! isnull) {

/*                       Check the time value returned by EKGD. */

			    chcksd_("Time value from EKGD", ddata, "=", &
				    tvals[(i__4 = eltidx - 1) < 20 && 0 <= 
				    i__4 ? i__4 : s_rnge("tvals", i__4, "f_e"
				    "k01__", (ftnlen)1005)], &c_b130, ok, (
				    ftnlen)20, (ftnlen)1);
			}
		    }

/*                 Done with the current element. */

		}

/*              Done with the current column. */

	    }

/*           Done with the current row. */

	}

/*        Done with the current table. */

    }

/*     We've queried each EK table and checked all data returned by */
/*     the queries. */


/* --- Case: ------------------------------------------------------ */

    tcase_("Open a scratch EK.  Write to it.  Make sure the data's there.  C"
	    "lose it.  Make sure it goes away.", (ftnlen)97);
    ekops_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    s_copy(shrtnm, "COL_1", (ftnlen)32, (ftnlen)5);
    s_copy(shrtdc, "DATATYPE = INTEGER", (ftnlen)200, (ftnlen)18);
    ekifld_(&handle, "TABLE_1", &c__1, &c__1, shrtnm, shrtdc, &segno, rcptrs, 
	    (ftnlen)7, (ftnlen)32, (ftnlen)200);
    nlflgs[0] = FALSE_;
    entszs[0] = 1;
    ivals[0] = 99;
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Add the column to the table. */

    ekacli_(&handle, &segno, "COL_1", ivals, &c__1, nlflgs, rcptrs, wkindx, (
	    ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Finish the fast load for this table. */

    ekffld_(&handle, &segno, rcptrs);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Get the summary for the table. */

    ekssum_(&handle, &segno, sstnam, &ssnrow, &ssncol, sscnms, sstyps, ssdims,
	     sslens, ssidxd, ssnlok, (ftnlen)64, (ftnlen)32, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the table and column name.  That's enough. */

    chcksc_("Table name", sstnam, "=", "TABLE_1", ok, (ftnlen)10, (ftnlen)64, 
	    (ftnlen)1, (ftnlen)7);
    chcksc_("Column name", sscnms, "=", "COL_1", ok, (ftnlen)11, (ftnlen)32, (
	    ftnlen)1, (ftnlen)5);

/*     Close this file. */

    ekcls_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Is the file still there?  Shouldn't be. */

    dashlu_(&handle, &unit);
    chckxc_(&c_true, "SPICE(DASNOSUCHHANDLE)", ok, (ftnlen)22);

/* --- Case: ------------------------------------------------------ */

    tcase_("Open an EK.  Write to it.  Make sure the data's there.  Close it"
	    ".  Open it for appending. Write some more. Make sure the data's "
	    "there.", (ftnlen)134);
    tstmsg_("#", "About to open EK file #.", (ftnlen)1, (ftnlen)24);
    tstmsc_("test2.ek", (ftnlen)8);
    if (exists_("test2.ek", (ftnlen)8)) {
	delfil_("test2.ek", (ftnlen)8);
    }
    ekopn_("test2.ek", "test2.ek", &c__0, &handle, (ftnlen)8, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    s_copy(shrtnm, "COL_1", (ftnlen)32, (ftnlen)5);
    s_copy(shrtdc, "DATATYPE = INTEGER", (ftnlen)200, (ftnlen)18);
    ekifld_(&handle, "TABLE_1", &c__1, &c__1, shrtnm, shrtdc, &segno, rcptrs, 
	    (ftnlen)7, (ftnlen)32, (ftnlen)200);
    nlflgs[0] = FALSE_;
    entszs[0] = 1;
    ivals[0] = 100;
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Add the column to the table. */

    ekacli_(&handle, &segno, "COL_1", ivals, &c__1, nlflgs, rcptrs, wkindx, (
	    ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Finish the fast load for this table. */

    ekffld_(&handle, &segno, rcptrs);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Get the summary for the table. */

    ekssum_(&handle, &segno, sstnam, &ssnrow, &ssncol, sscnms, sstyps, ssdims,
	     sslens, ssidxd, ssnlok, (ftnlen)64, (ftnlen)32, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the table and column name.  That's enough. */

    chcksc_("Table name", sstnam, "=", "TABLE_1", ok, (ftnlen)10, (ftnlen)64, 
	    (ftnlen)1, (ftnlen)7);
    chcksc_("Column name", sscnms, "=", "COL_1", ok, (ftnlen)11, (ftnlen)32, (
	    ftnlen)1, (ftnlen)5);

/*     Close this file. */

    ekcls_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Now open the file for write access and add more data. */

    tstmsg_("#", "About to open EK file # for appending.", (ftnlen)1, (ftnlen)
	    38);
    tstmsc_("test2.ek", (ftnlen)8);
    ekopw_("test2.ek", &handle, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    s_copy(shrtnm, "COL_2", (ftnlen)32, (ftnlen)5);
    s_copy(shrtdc, "DATATYPE = INTEGER", (ftnlen)200, (ftnlen)18);
    ekifld_(&handle, "TABLE_2", &c__1, &c__1, shrtnm, shrtdc, &segno, rcptrs, 
	    (ftnlen)7, (ftnlen)32, (ftnlen)200);
    nlflgs[0] = FALSE_;
    entszs[0] = 1;
    ivals[0] = 200;
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Add the column to the table. */

    ekacli_(&handle, &segno, "COL_2", ivals, &c__1, nlflgs, rcptrs, wkindx, (
	    ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Finish the fast load for this table. */

    ekffld_(&handle, &segno, rcptrs);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Close this file. */

    ekcls_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Open the file for read access. */

    ekopr_("test2.ek", &handle, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Get the summary for the table. */

    ekssum_(&handle, &segno, sstnam, &ssnrow, &ssncol, sscnms, sstyps, ssdims,
	     sslens, ssidxd, ssnlok, (ftnlen)64, (ftnlen)32, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the table and column name.  That's enough. */

    chcksc_("Table name", sstnam, "=", "TABLE_2", ok, (ftnlen)10, (ftnlen)64, 
	    (ftnlen)1, (ftnlen)7);
    chcksc_("Column name", sscnms, "=", "COL_2", ok, (ftnlen)11, (ftnlen)32, (
	    ftnlen)1, (ftnlen)5);

/*     Close this file. */

    ekcls_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);


/* --- Case: ------------------------------------------------------ */

    tcase_("Test EKPSEL.  Build a query with a complex SELECT clause; tear i"
	    "t apart with EKPSEL. Verify that EKPSEL identifies the columns' "
	    "attributes correctly.", (ftnlen)149);

/*     Get segment summary for the SCALAR_2 table. */

    eklef_("test1.ek", &handle, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    segno = 2;
    ekssum_(&handle, &segno, sstnam, &ssnrow, &ssncol, sscnms, sstyps, ssdims,
	     sslens, ssidxd, ssnlok, (ftnlen)64, (ftnlen)32, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    ncols = ssncol;

/*     Build the query string:  select all columns from the current */
/*     table.  Save the beginning and end locations of the column name */
/*     tokens. */

    s_copy(query, "SELECT", (ftnlen)2000, (ftnlen)6);
    xpbegs[0] = lastnb_(query, (ftnlen)2000) + 2;
    suffix_(sscnms, &c__1, query, (ftnlen)32, (ftnlen)2000);
    xpends[0] = lastnb_(query, (ftnlen)2000);
    i__1 = ssncol;
    for (colno = 2; colno <= i__1; ++colno) {
	suffix_(",", &c__0, query, (ftnlen)1, (ftnlen)2000);
	xpbegs[(i__2 = colno - 1) < 100 && 0 <= i__2 ? i__2 : s_rnge("xpbegs",
		 i__2, "f_ek01__", (ftnlen)1313)] = lastnb_(query, (ftnlen)
		2000) + 2;
	suffix_(sscnms + (((i__2 = colno - 1) < 100 && 0 <= i__2 ? i__2 : 
		s_rnge("sscnms", i__2, "f_ek01__", (ftnlen)1315)) << 5), &
		c__1, query, (ftnlen)32, (ftnlen)2000);
	xpends[(i__2 = colno - 1) < 100 && 0 <= i__2 ? i__2 : s_rnge("xpends",
		 i__2, "f_ek01__", (ftnlen)1317)] = lastnb_(query, (ftnlen)
		2000);
    }
    suffix_("FROM", &c__1, query, (ftnlen)4, (ftnlen)2000);
    suffix_(tables + (((i__1 = segno - 1) < 6 && 0 <= i__1 ? i__1 : s_rnge(
	    "tables", i__1, "f_ek01__", (ftnlen)1322)) << 6), &c__1, query, (
	    ftnlen)64, (ftnlen)2000);
    suffix_("ORDER BY ROW_NO", &c__1, query, (ftnlen)15, (ftnlen)2000);

/*     Analyze the query. */

    ekpsel_(query, &n, xbegs, xends, xtypes, xclass, tabs, cnames, &error, 
	    errmsg, (ftnlen)2000, (ftnlen)4, (ftnlen)4, (ftnlen)64, (ftnlen)
	    32, (ftnlen)1840);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Make sure query parsed correctly. */

    chcksl_("ERROR flag", &error, &c_false, ok, (ftnlen)10);

/*     Make sure the error message is blank. */

    chcksc_("ERROR message", errmsg, "=", " ", ok, (ftnlen)13, (ftnlen)1840, (
	    ftnlen)1, (ftnlen)1);

/*     Check the number of SELECT expressions. */

    chcksi_("number of SELECT expressions N", &n, "=", &ncols, &c__0, ok, (
	    ftnlen)30, (ftnlen)1);

/*     Check the expression bounds. */

    chckai_("XBEGS", xbegs, "=", xpbegs, &n, ok, (ftnlen)5, (ftnlen)1);
    chckai_("XENDS", xends, "=", xpends, &n, ok, (ftnlen)5, (ftnlen)1);

/*     For each selected column, check the */

/*        - Column name */
/*        - Table name */
/*        - Data type */
/*        - Expression class */

    i__1 = n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	chcksc_("Column names", cnames + (((i__2 = i__ - 1) < 100 && 0 <= 
		i__2 ? i__2 : s_rnge("cnames", i__2, "f_ek01__", (ftnlen)1368)
		) << 5), "=", sscnms + (((i__3 = i__ - 1) < 100 && 0 <= i__3 ?
		 i__3 : s_rnge("sscnms", i__3, "f_ek01__", (ftnlen)1368)) << 
		5), ok, (ftnlen)12, (ftnlen)32, (ftnlen)1, (ftnlen)32);
	chcksc_("Table names", tabs + (((i__2 = i__ - 1) < 100 && 0 <= i__2 ? 
		i__2 : s_rnge("tabs", i__2, "f_ek01__", (ftnlen)1369)) << 6), 
		"=", sstnam, ok, (ftnlen)11, (ftnlen)64, (ftnlen)1, (ftnlen)
		64);
	chcksc_("Data types", xtypes + (((i__2 = i__ - 1) < 100 && 0 <= i__2 ?
		 i__2 : s_rnge("xtypes", i__2, "f_ek01__", (ftnlen)1371)) << 
		2), "=", sstyps + (((i__3 = i__ - 1) < 100 && 0 <= i__3 ? 
		i__3 : s_rnge("sstyps", i__3, "f_ek01__", (ftnlen)1371)) << 2)
		, ok, (ftnlen)10, (ftnlen)4, (ftnlen)1, (ftnlen)4);
	chcksc_("Expression class", xclass + (((i__2 = i__ - 1) < 100 && 0 <= 
		i__2 ? i__2 : s_rnge("xclass", i__2, "f_ek01__", (ftnlen)1373)
		) << 2), "=", "COL", ok, (ftnlen)16, (ftnlen)4, (ftnlen)1, (
		ftnlen)3);
    }

/*     Unload the EK. */

    ekuef_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Test sorting:  select rows from scalar_2, ordering by c_col_2 (a"
	    "scending).", (ftnlen)74);

/*     Use EK1. */

    eklef_("test1.ek", &handle, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Create the query. */

    s_copy(query, "select c_col_2 from scalar_2 where (c_col_2 between \"SEG"
	    "_2_C_COL_2_ROW_10_\" and \"SEG_2_C_COL_2_ROW_19\" ) or c_col_2 l"
	    "ike \"X*\" order by c_col_2", (ftnlen)2000, (ftnlen)142);

/*     Issue the query. */

    ekfind_(query, &nmrows, &error, errmsg, (ftnlen)2000, (ftnlen)1840);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Make sure there was no query resolution error. */

    tstmsg_("#", "The error message was:  #", (ftnlen)1, (ftnlen)25);
    tstmsc_(errmsg, (ftnlen)1840);
    chcksl_("ERROR flag", &error, &c_false, ok, (ftnlen)10);
    if (! error) {

/*        Check NMROWS.  We expect to find 5 rows. */

	xnrows = 5;
	chcksi_("NMROWS", &nmrows, "=", &xnrows, &c__0, ok, (ftnlen)6, (
		ftnlen)1);

/*        Check the data. */

	i__1 = xnrows;
	for (rowno = 1; rowno <= i__1; ++rowno) {

/*           Look up the expected column entry. Skip  over null entries. */

	    fileno = 1;
	    segno = 2;
	    selidx = 1;
	    eltidx = 1;
	    i__2 = (rowno - 1 << 1) + 10;
	    tstent_(&fileno, "SCALAR_2", &segno, "C_COL_2", &i__2, &c__20, &
		    xnelts, cvals, dvals, ivals, tvals, &xnull, (ftnlen)8, (
		    ftnlen)7, (ftnlen)1024);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Fetch the actual column entry from the current row. */

	    ekgc_(&selidx, &rowno, &eltidx, cdata, &isnull, &found, (ftnlen)
		    1024);

/*           Make sure no error was signaled. */

	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Make sure the element was found. */

	    chcksl_("FOUND flag", &found, &c_true, ok, (ftnlen)10);

/*           Check the null flag returned by EKGC. */

	    chcksl_("ISNULL", &isnull, &xnull, ok, (ftnlen)6);
	    if (! isnull) {

/*              Check the character string returned by EKGC. */

		chcksc_("char value from EKGC", cdata, "=", cvals + (((i__2 = 
			eltidx - 1) < 20 && 0 <= i__2 ? i__2 : s_rnge("cvals",
			 i__2, "f_ek01__", (ftnlen)1478)) << 10), ok, (ftnlen)
			20, (ftnlen)1024, (ftnlen)1, (ftnlen)1024);
	    }
	}
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("Test sorting:  select rows from scalar_2, ordering by c_col_2 (d"
	    "escending).", (ftnlen)75);

/*     Do the same query, but sort in descending order. */

/*     Create the query. */

    s_copy(query, "select c_col_2 from scalar_2 where (c_col_2 between \"SEG"
	    "_2_C_COL_2_ROW_10_\" and \"SEG_2_C_COL_2_ROW_19\" ) or c_col_2 l"
	    "ike \"X*\" order by c_col_2 desc", (ftnlen)2000, (ftnlen)147);

/*     Issue the query. */

    ekfind_(query, &nmrows, &error, errmsg, (ftnlen)2000, (ftnlen)1840);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Make sure there was no query resolution error. */

    tstmsg_("#", "The error message was:  #", (ftnlen)1, (ftnlen)25);
    tstmsc_(errmsg, (ftnlen)1840);
    chcksl_("ERROR flag", &error, &c_false, ok, (ftnlen)10);
    if (! error) {

/*        Check NMROWS.  We expect to find 5 rows. */

	xnrows = 5;
	chcksi_("NMROWS", &nmrows, "=", &xnrows, &c__0, ok, (ftnlen)6, (
		ftnlen)1);

/*        Check the data. */

	i__1 = xnrows;
	for (rowno = 1; rowno <= i__1; ++rowno) {

/*           Look up the expected column entry. Skip  over null entries. */

	    fileno = 1;
	    segno = 2;
	    selidx = 1;
	    eltidx = 1;
	    i__2 = 18 - (rowno - 1 << 1);
	    tstent_(&fileno, "SCALAR_2", &segno, "C_COL_2", &i__2, &c__20, &
		    xnelts, cvals, dvals, ivals, tvals, &xnull, (ftnlen)8, (
		    ftnlen)7, (ftnlen)1024);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Fetch the actual column entry from the current row. */

	    ekgc_(&selidx, &rowno, &eltidx, cdata, &isnull, &found, (ftnlen)
		    1024);

/*           Make sure no error was signaled. */

	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Make sure the element was found. */

	    chcksl_("FOUND flag", &found, &c_true, ok, (ftnlen)10);

/*           Check the null flag returned by EKGC. */

	    chcksl_("ISNULL", &isnull, &xnull, ok, (ftnlen)6);
	    if (! isnull) {

/*              Check the character string returned by EKGC. */

		chcksc_("char value from EKGC", cdata, "=", cvals + (((i__2 = 
			eltidx - 1) < 20 && 0 <= i__2 ? i__2 : s_rnge("cvals",
			 i__2, "f_ek01__", (ftnlen)1576)) << 10), ok, (ftnlen)
			20, (ftnlen)1024, (ftnlen)1, (ftnlen)1024);
	    }
	}
    }

/*     Unload the EK. */

    ekuef_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Test EKUEF; make sure we don't accumulate DAS links when we relo"
	    "ad a file repeatedly.", (ftnlen)85);
    for (i__ = 1; i__ <= 40; ++i__) {
	eklef_("test1.ek", &handle, (ftnlen)8);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    ekuef_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    dasfnh_("test1.ek", &handle, (ftnlen)8);
    chckxc_(&c_true, "SPICE(DASNOSUCHFILE)", ok, (ftnlen)20);

/*     EK time parsing tests follow. */


/* --- Case: ------------------------------------------------------ */

    tcase_("Test ZZEKTCNV; convert SCLK string.", (ftnlen)35);

/*     Create and load a leapseconds kernel. */

    tstlsk_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Create an SCLK kernel.  The routine we use for this purpose also */
/*     creates a C-kernel, which we don't need. */

    tstck3_("SCLKtest.bc", "testsclk.tsc", &c_false, &c_true, &c_false, &
	    handle, (ftnlen)11, (ftnlen)12);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Associate the name and ID of the clock. */

    boddef_("TEST_SCLK_NAME", &c_n9, (ftnlen)14);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Convert an SCLK string to ET; make sure we get the same result */
/*     returned by SCS2E. */

    scs2e_(&c_n9, "1/315662457.1839", &xet, (ftnlen)16);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    s_copy(timstr, "# SCLK #", (ftnlen)50, (ftnlen)8);
    repmc_(timstr, "#", "TEST_SCLK_NAME", timstr, (ftnlen)50, (ftnlen)1, (
	    ftnlen)14, (ftnlen)50);
    repmc_(timstr, "#", "1/315662457.1839", timstr, (ftnlen)50, (ftnlen)1, (
	    ftnlen)16, (ftnlen)50);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Convert the time string. */

    zzektcnv_(timstr, &et, &error, errmsg, (ftnlen)50, (ftnlen)1840);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the error flag. */

    chcksl_("ERROR", &error, &c_false, ok, (ftnlen)5);

/*     Check the error message. */

    chcksc_("ERRMSG", errmsg, "=", " ", ok, (ftnlen)6, (ftnlen)1840, (ftnlen)
	    1, (ftnlen)1);

/*     Check the time. */

    chcksd_("ET", &et, "=", &xet, &c_b130, ok, (ftnlen)2, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */


/*     Now use a name that doesn't contain the substring SCLK. */

    tcase_("SCLK name doesn't contain the substring SCLK.", (ftnlen)45);
    boddef_("TEST_SCLK_NAME_2", &c_n9, (ftnlen)16);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    scs2e_(&c_n9, "1/315662457.1839", &xet, (ftnlen)16);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    s_copy(timstr, "# SCLK #", (ftnlen)50, (ftnlen)8);
    repmc_(timstr, "#", "TEST_SCLK_NAME", timstr, (ftnlen)50, (ftnlen)1, (
	    ftnlen)14, (ftnlen)50);
    repmc_(timstr, "#", "1/315662457.1839", timstr, (ftnlen)50, (ftnlen)1, (
	    ftnlen)16, (ftnlen)50);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Convert the time string. */

    zzektcnv_(timstr, &et, &error, errmsg, (ftnlen)50, (ftnlen)1840);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the error flag. */

    chcksl_("ERROR", &error, &c_false, ok, (ftnlen)5);

/*     Check the error message. */

    chcksc_("ERRMSG", errmsg, "=", " ", ok, (ftnlen)6, (ftnlen)1840, (ftnlen)
	    1, (ftnlen)1);

/*     Check the time. */

    chcksd_("ET", &et, "=", &xet, &c_b130, ok, (ftnlen)2, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */


/*     Now attempt conversion using an SCLK name that doesn't map to */
/*     an ID code. */

    tcase_("Error: SCLK does not map to ID code.", (ftnlen)36);
    s_copy(timstr, "# SCLK #", (ftnlen)50, (ftnlen)8);
    repmc_(timstr, "#", "UNDEFINED_SCLK", timstr, (ftnlen)50, (ftnlen)1, (
	    ftnlen)14, (ftnlen)50);
    repmc_(timstr, "#", "1/315662457.1839", timstr, (ftnlen)50, (ftnlen)1, (
	    ftnlen)16, (ftnlen)50);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Convert the time string. */

    zzektcnv_(timstr, &et, &error, errmsg, (ftnlen)50, (ftnlen)1840);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the error flag. */

    chcksl_("ERROR", &error, &c_true, ok, (ftnlen)5);

/*     Check the error message. */

    s_copy(xmsg, "Time conversion failed; SCLK type <#> was not recognized.", 
	    (ftnlen)1840, (ftnlen)57);
    repmc_(xmsg, "#", "UNDEFINED_SCLK", xmsg, (ftnlen)1840, (ftnlen)1, (
	    ftnlen)14, (ftnlen)1840);
    chcksc_("ERRMSG", errmsg, "=", xmsg, ok, (ftnlen)6, (ftnlen)1840, (ftnlen)
	    1, (ftnlen)1840);

/* --- Case: ------------------------------------------------------ */


/*     Now attempt conversion using an SCLK string with no clock name. */

    tcase_("Error: SCLK string lacks SCLK name.", (ftnlen)35);
    s_copy(timstr, " SCLK #", (ftnlen)50, (ftnlen)7);
    repmc_(timstr, "#", "1/315662457.1839", timstr, (ftnlen)50, (ftnlen)1, (
	    ftnlen)16, (ftnlen)50);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Convert the time string. */

    zzektcnv_(timstr, &et, &error, errmsg, (ftnlen)50, (ftnlen)1840);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the error flag. */

    chcksl_("ERROR", &error, &c_true, ok, (ftnlen)5);

/*     Check the error message. */

    s_copy(xmsg, "Time conversion failed; SCLK name was not supplied.", (
	    ftnlen)1840, (ftnlen)51);
    repmc_(xmsg, "#", "UNDEFINED_SCLK", xmsg, (ftnlen)1840, (ftnlen)1, (
	    ftnlen)14, (ftnlen)1840);
    chcksc_("ERRMSG", errmsg, "=", xmsg, ok, (ftnlen)6, (ftnlen)1840, (ftnlen)
	    1, (ftnlen)1840);

/* --- Case: ------------------------------------------------------ */


/*     Try the conversion without an SCLK kernel loaded. */

    tcase_("Error: SCLK kernel is not loaded.", (ftnlen)33);
    zzektcnv_("GLL SCLK 1/1000:00:0:0", &et, &error, errmsg, (ftnlen)22, (
	    ftnlen)1840);
    chckxc_(&c_true, "SPICE(KERNELVARNOTFOUND)", ok, (ftnlen)24);

/* --- Case: ------------------------------------------------------ */


/*     Try the conversion using a string having invalid syntax. */

    tcase_("SCLK string has invalid syntax.", (ftnlen)31);
    s_copy(timstr, "# SCLK #", (ftnlen)50, (ftnlen)8);
    repmc_(timstr, "#", "TEST_SCLK_NAME_2", timstr, (ftnlen)50, (ftnlen)1, (
	    ftnlen)16, (ftnlen)50);
    repmc_(timstr, "#", "1/2/315662457.1839", timstr, (ftnlen)50, (ftnlen)1, (
	    ftnlen)18, (ftnlen)50);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    zzektcnv_(timstr, &et, &error, errmsg, (ftnlen)50, (ftnlen)1840);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the error flag. */

    chcksl_("ERROR", &error, &c_true, ok, (ftnlen)5);

/*     The error message is going to be complex; don't attempt */
/*     to match it.  Just make sure the error message is non-blank. */

    chcksc_("ERRMSG", errmsg, "!=", " ", ok, (ftnlen)6, (ftnlen)1840, (ftnlen)
	    2, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */


/*     Try a conversion without having SCLK coefficients loaded. This is */
/*     intended to trigger an SCS2E SPICE error. */

    tcase_("SCLK coefficients are not loaded.", (ftnlen)33);
    dvpool_("SCLK01_COEFFICIENTS_9", (ftnlen)21);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    s_copy(timstr, "# SCLK #", (ftnlen)50, (ftnlen)8);
    repmc_(timstr, "#", "TEST_SCLK_NAME", timstr, (ftnlen)50, (ftnlen)1, (
	    ftnlen)14, (ftnlen)50);
    repmc_(timstr, "#", "1/315662457.1839", timstr, (ftnlen)50, (ftnlen)1, (
	    ftnlen)16, (ftnlen)50);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Convert the time string. */

    zzektcnv_(timstr, &et, &error, errmsg, (ftnlen)50, (ftnlen)1840);
    chckxc_(&c_true, "SPICE(KERNELVARNOTFOUND)", ok, (ftnlen)24);

/* --- Case: ------------------------------------------------------ */

    tcase_("Conversion using a normal UTC string.", (ftnlen)37);

/*     Create an SCLK kernel.  The routine we use for this purpose also */
/*     creates a C-kernel, which we don't need. */

    tstck3_("SCLKtest.bc", "testsclk.tsc", &c_false, &c_true, &c_false, &
	    handle, (ftnlen)11, (ftnlen)12);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Associate the name and ID of the clock. */

    boddef_("TEST_SCLK_NAME", &c_n9, (ftnlen)14);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    scs2e_(&c_n9, "1/315662457.1839", &xet, (ftnlen)16);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    s_copy(timstr, "1990 JAN 01 12:00:00", (ftnlen)50, (ftnlen)20);

/*     Convert the UTC string to ET; make sure we get the same result */
/*     returned by STR2ET. */

    str2et_(timstr, &xet, (ftnlen)50);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Convert the time string. */

    zzektcnv_(timstr, &et, &error, errmsg, (ftnlen)50, (ftnlen)1840);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the error flag. */

    chcksl_("ERROR", &error, &c_false, ok, (ftnlen)5);

/*     Check the error message. */

    chcksc_("ERRMSG", errmsg, "=", " ", ok, (ftnlen)6, (ftnlen)1840, (ftnlen)
	    1, (ftnlen)1);

/*     Check the time. */

    chcksd_("ET", &et, "=", &xet, &c_b130, ok, (ftnlen)2, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Conversion using an invalid UTC string.", (ftnlen)39);
    s_copy(timstr, "1990 JANN 01 12:00:00", (ftnlen)50, (ftnlen)21);

/*     Convert the time string. */

    zzektcnv_(timstr, &et, &error, errmsg, (ftnlen)50, (ftnlen)1840);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the error flag. */

    chcksl_("ERROR", &error, &c_true, ok, (ftnlen)5);

/*     The error message is going to be complex; don't attempt */
/*     to match it.  Just make sure the error message is non-blank. */

    chcksc_("ERRMSG", errmsg, "!=", " ", ok, (ftnlen)6, (ftnlen)1840, (ftnlen)
	    2, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */


/*     Unload the EKs.  The TSPICE system will delete the files. */

    tcase_("Unload EKs from query system.", (ftnlen)29);
    unload_("test1.ek", (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    unload_("test2.ek", (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_ek01__ */

