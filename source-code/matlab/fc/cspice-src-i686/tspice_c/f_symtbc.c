/* f_symtbc.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__10000 = 10000;
static integer c__100 = 100;
static logical c_false = FALSE_;
static integer c__0 = 0;
static integer c__1 = 1;
static logical c_true = TRUE_;
static integer c__101 = 101;
static integer c_n1 = -1;
static integer c__2 = 2;

/* $Procedure F_SYMTBC ( Test SPICELIB character symbol table routines ) */
/* Subroutine */ int f_symtbc__(logical *ok)
{
    /* System generated locals */
    integer i__1, i__2, i__3, i__4, i__5;

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer);
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    static char name__[45], xval[50];
    static integer size;
    static char nivs[50*10000];
    extern /* Subroutine */ int t_ithsym__(integer *, integer *, char *, 
	    ftnlen);
    static integer i__, j, k;
    extern integer cardc_(char *, ftnlen), cardi_(integer *);
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    static integer xcard;
    extern /* Subroutine */ int repmc_(char *, char *, char *, char *, ftnlen,
	     ftnlen, ftnlen, ftnlen);
    static char cvals[50*10000];
    static logical found;
    extern /* Subroutine */ int repmi_(char *, char *, integer *, char *, 
	    ftnlen, ftnlen, ftnlen), swapc_(char *, char *, ftnlen, ftnlen);
    static char title[500];
    static integer nvals;
    extern /* Subroutine */ int topen_(char *, ftnlen);
    static char xvals[50*10000];
    static integer start;
    extern /* Subroutine */ int t_success__(logical *);
    static integer xptrs[100];
    extern /* Subroutine */ int chckac_(char *, char *, char *, char *, 
	    integer *, logical *, ftnlen, ftnlen, ftnlen, ftnlen), chckai_(
	    char *, integer *, char *, integer *, integer *, logical *, 
	    ftnlen, ftnlen);
    static integer ub;
    extern /* Subroutine */ int clearc_(integer *, char *, ftnlen), chcksc_(
	    char *, char *, char *, char *, logical *, ftnlen, ftnlen, ftnlen,
	     ftnlen), scardc_(integer *, char *, ftnlen);
    static integer to;
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     chcksi_(char *, integer *, char *, integer *, integer *, logical 
	    *, ftnlen, ftnlen), scardi_(integer *, integer *), chcksl_(char *,
	     logical *, logical *, logical *, ftnlen), replch_(char *, char *,
	     char *, char *, ftnlen, ftnlen, ftnlen, ftnlen), sydelc_(char *, 
	    char *, integer *, char *, ftnlen, ftnlen, ftnlen);
    static char newnam[45];
    extern integer sydimc_(char *, char *, integer *, char *, ftnlen, ftnlen, 
	    ftnlen);
    static char xnames[45*100];
    static integer tabsiz;
    extern /* Subroutine */ int syfetc_(integer *, char *, integer *, char *, 
	    char *, logical *, ftnlen, ftnlen, ftnlen), sygetc_(char *, char *
	    , integer *, char *, integer *, char *, logical *, ftnlen, ftnlen,
	     ftnlen, ftnlen), prefix_(char *, integer *, char *, ftnlen, 
	    ftnlen), ssizec_(integer *, char *, ftnlen), syenqc_(char *, char 
	    *, char *, integer *, char *, ftnlen, ftnlen, ftnlen, ftnlen), 
	    syrenc_(char *, char *, char *, integer *, char *, ftnlen, ftnlen,
	     ftnlen, ftnlen), syordc_(char *, char *, integer *, char *, 
	    ftnlen, ftnlen, ftnlen), syselc_(char *, integer *, integer *, 
	    char *, integer *, char *, char *, logical *, ftnlen, ftnlen, 
	    ftnlen, ftnlen), ssizei_(integer *, integer *), sydupc_(char *, 
	    char *, char *, integer *, char *, ftnlen, ftnlen, ftnlen, ftnlen)
	    , synthc_(char *, integer *, char *, integer *, char *, char *, 
	    logical *, ftnlen, ftnlen, ftnlen, ftnlen), sypshc_(char *, char *
	    , char *, integer *, char *, ftnlen, ftnlen, ftnlen, ftnlen);
    static char synams[45*106];
    extern /* Subroutine */ int sysetc_(char *, char *, char *, integer *, 
	    char *, ftnlen, ftnlen, ftnlen, ftnlen), sypopc_(char *, char *, 
	    integer *, char *, char *, logical *, ftnlen, ftnlen, ftnlen, 
	    ftnlen);
    static char syvals[50*10006];
    extern /* Subroutine */ int sytrnc_(char *, integer *, integer *, char *, 
	    integer *, char *, ftnlen, ftnlen, ftnlen), syputc_(char *, char *
	    , integer *, char *, integer *, char *, ftnlen, ftnlen, ftnlen, 
	    ftnlen);
    static integer syptrs[106];
    static char val[50], ivs[50*10000];

/* $ Abstract */

/*     Exercise the SPICELIB symbol table routines of type */
/*     CHARACTER. */

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

/*     SYMBOL */

/* $ Keywords */

/*     TEST FAMILY */

/* $ Declarations */
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

/*     This routine tests the SPICELIB symbol table routines */

/*        SYDELC */
/*        SYDIMC */
/*        SYDUPC */
/*        SYENQC */
/*        SYFETC */
/*        SYGETC */
/*        SYNTHC */
/*        SYORDC */
/*        SYPOPC */
/*        SYPSHC */
/*        SYPUTC */
/*        SYRENC */
/*        SYSELC */
/*        SYSETC */
/*        SYTRNC */

/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     N.J. Bachman     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    TSPICE Version 1.0.0, 01-NOV-2005 (NJB) */


/* -& */

/*     SPICELIB functions */


/*     Local Parameters */


/*     Local Variables */


/*     Saved values */

/*     To avoid memory problems under cygwin, save everything. */


/*     Initial values */


/*     ********************************************************* */
/*     Note:  the order of the test cases is significant in that */
/*     some cases depend on results from other cases.  Take care */
/*     to preserve side effects when modifying this code! */
/*     ********************************************************* */


/*     Open the test family. */

    topen_("F_SYMTBC", (ftnlen)8);

/* --- Case: ------------------------------------------------------ */

    tcase_("Setup:  create arrays of values that take the place of the numer"
	    "ic values used in tests for the integer and d.p. symbol table ro"
	    "utines.", (ftnlen)135);

/*     We use the symbol name creation utility to create the values. */


/*     The array IVS contains values that replace integers.  Note */
/*     that these values are *not* integers in string form. */

    for (i__ = 1; i__ <= 10000; ++i__) {
	t_ithsym__(&i__, &c__10000, ivs + ((i__1 = i__ - 1) < 10000 && 0 <= 
		i__1 ? i__1 : s_rnge("ivs", i__1, "f_symtbc__", (ftnlen)223)) 
		* 50, (ftnlen)50);
    }

/*     The array NIVS contains values whose order is the reverse of */
/*     the order of the elements of IVS. */

    for (i__ = 1; i__ <= 10000; ++i__) {
	j = 10001 - i__;
	s_copy(nivs + ((i__1 = i__ - 1) < 10000 && 0 <= i__1 ? i__1 : s_rnge(
		"nivs", i__1, "f_symtbc__", (ftnlen)235)) * 50, ivs + ((i__2 =
		 j - 1) < 10000 && 0 <= i__2 ? i__2 : s_rnge("ivs", i__2, 
		"f_symtbc__", (ftnlen)235)) * 50, (ftnlen)50, (ftnlen)50);
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("SYSETC test:  Populate a simple symbol table with scalar-valued "
	    "symbols.", (ftnlen)72);

/*     Initialize the symbol table. */

    ssizec_(&c__100, synams, (ftnlen)45);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    ssizei_(&c__100, syptrs);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    ssizec_(&c__10000, syvals, (ftnlen)50);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    for (i__ = 1; i__ <= 100; ++i__) {

/*        Create the symbol name. */

	t_ithsym__(&i__, &c__100, name__, (ftnlen)45);
	s_copy(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbc__", (ftnlen)265)) * 45, name__, (
		ftnlen)45, (ftnlen)45);
	xptrs[(i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge("xptrs", 
		i__1, "f_symtbc__", (ftnlen)266)] = 1;
	s_copy(xvals + ((i__1 = i__ - 1) < 10000 && 0 <= i__1 ? i__1 : s_rnge(
		"xvals", i__1, "f_symtbc__", (ftnlen)267)) * 50, nivs + ((
		i__2 = i__ - 1) < 10000 && 0 <= i__2 ? i__2 : s_rnge("nivs", 
		i__2, "f_symtbc__", (ftnlen)267)) * 50, (ftnlen)50, (ftnlen)
		50);

/*        Associate the value NIVS(I) with the Ith symbol.  Add this */
/*        symbol to the table. */

	sysetc_(name__, nivs + ((i__1 = i__ - 1) < 10000 && 0 <= i__1 ? i__1 :
		 s_rnge("nivs", i__1, "f_symtbc__", (ftnlen)273)) * 50, 
		synams, syptrs, syvals, (ftnlen)45, (ftnlen)50, (ftnlen)45, (
		ftnlen)50);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Check the structure of the cells we've populated. */

/*     The symbol name cell first: */

    i__1 = cardc_(synams, (ftnlen)45);
    chcksi_("Card(SYNAMS)", &i__1, "=", &c__100, &c__0, ok, (ftnlen)12, (
	    ftnlen)1);
    i__1 = cardc_(synams, (ftnlen)45);
    for (i__ = 1; i__ <= i__1; ++i__) {
	s_copy(title, "Name #", (ftnlen)500, (ftnlen)6);
	repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)500);
	chcksc_(title, synams + ((i__2 = i__ + 5) < 106 && 0 <= i__2 ? i__2 : 
		s_rnge("synams", i__2, "f_symtbc__", (ftnlen)289)) * 45, 
		"=", xnames + ((i__3 = i__ - 1) < 100 && 0 <= i__3 ? i__3 : 
		s_rnge("xnames", i__3, "f_symtbc__", (ftnlen)289)) * 45, ok, (
		ftnlen)500, (ftnlen)45, (ftnlen)1, (ftnlen)45);
    }

/*     Then the "pointer" cell.  The pointers are actually element */
/*     counts. */

    i__1 = cardi_(syptrs);
    chcksi_("Card(SYPTRS)", &i__1, "=", &c__100, &c__0, ok, (ftnlen)12, (
	    ftnlen)1);
    chckai_("SYPTRS", &syptrs[6], "=", xptrs, &c__100, ok, (ftnlen)6, (ftnlen)
	    1);

/*     Then the value cell. */

    i__1 = cardc_(syvals, (ftnlen)50);
    chcksi_("Card(SYVALS)", &i__1, "=", &c__100, &c__0, ok, (ftnlen)12, (
	    ftnlen)1);
    chckac_("SYVALS", syvals + 300, "=", xvals, &c__100, ok, (ftnlen)6, (
	    ftnlen)50, (ftnlen)1, (ftnlen)50);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYSETC test:  Populate a simple symbol table with scalar-valued "
	    "symbols.  Insert symbols in reverse order.", (ftnlen)106);

/*     Clear out the symbol table. */

    scardc_(&c__0, synams, (ftnlen)45);
    scardi_(&c__0, syptrs);
    scardc_(&c__0, syvals, (ftnlen)50);

/*     Use the symbol names and values from the previous test. */

    for (i__ = 1; i__ <= 100; ++i__) {

/*        Let J be the index of the symbol to insert. */

	j = 101 - i__;

/*        Associate the value NIVS(J) with the Jth symbol.  Add this */
/*        symbol to the table. */

	sysetc_(xnames + ((i__1 = j - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbc__", (ftnlen)335)) * 45, nivs + ((
		i__2 = j - 1) < 10000 && 0 <= i__2 ? i__2 : s_rnge("nivs", 
		i__2, "f_symtbc__", (ftnlen)335)) * 50, synams, syptrs, 
		syvals, (ftnlen)45, (ftnlen)50, (ftnlen)45, (ftnlen)50);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     We should end up with the same symbol table as in the */
/*     previous test case. */


/*     Check the structure of the cells we've populated. */

/*     The symbol name cell first: */

    i__1 = cardc_(synams, (ftnlen)45);
    chcksi_("Card(SYNAMS)", &i__1, "=", &c__100, &c__0, ok, (ftnlen)12, (
	    ftnlen)1);
    i__1 = cardc_(synams, (ftnlen)45);
    for (i__ = 1; i__ <= i__1; ++i__) {
	s_copy(title, "Name #", (ftnlen)500, (ftnlen)6);
	repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)500);
	chcksc_(title, synams + ((i__2 = i__ + 5) < 106 && 0 <= i__2 ? i__2 : 
		s_rnge("synams", i__2, "f_symtbc__", (ftnlen)355)) * 45, 
		"=", xnames + ((i__3 = i__ - 1) < 100 && 0 <= i__3 ? i__3 : 
		s_rnge("xnames", i__3, "f_symtbc__", (ftnlen)355)) * 45, ok, (
		ftnlen)500, (ftnlen)45, (ftnlen)1, (ftnlen)45);
    }

/*     Then the "pointer" cell.  The pointers are actually element */
/*     counts. */

    i__1 = cardi_(syptrs);
    chcksi_("Card(SYPTRS)", &i__1, "=", &c__100, &c__0, ok, (ftnlen)12, (
	    ftnlen)1);
    chckai_("SYPTRS", &syptrs[6], "=", xptrs, &c__100, ok, (ftnlen)6, (ftnlen)
	    1);

/*     Then the value cell. */

    i__1 = cardc_(syvals, (ftnlen)50);
    chcksi_("Card(SYVALS)", &i__1, "=", &c__100, &c__0, ok, (ftnlen)12, (
	    ftnlen)1);
    chckac_("SYVALS", syvals + 300, "=", xvals, &c__100, ok, (ftnlen)6, (
	    ftnlen)50, (ftnlen)1, (ftnlen)50);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYPUTC test:  Populate a simple symbol table with scalar-valued "
	    "symbols.", (ftnlen)72);

/*     This is essentially a reprise of the previous SYSETC test. */

    scardc_(&c__0, synams, (ftnlen)45);
    scardi_(&c__0, syptrs);
    scardc_(&c__0, syvals, (ftnlen)50);
    for (i__ = 1; i__ <= 100; ++i__) {

/*        Create the symbol name. */

	t_ithsym__(&i__, &c__100, name__, (ftnlen)45);
	s_copy(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbc__", (ftnlen)396)) * 45, name__, (
		ftnlen)45, (ftnlen)45);
	xptrs[(i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge("xptrs", 
		i__1, "f_symtbc__", (ftnlen)397)] = 1;
	s_copy(xvals + ((i__1 = i__ - 1) < 10000 && 0 <= i__1 ? i__1 : s_rnge(
		"xvals", i__1, "f_symtbc__", (ftnlen)398)) * 50, nivs + ((
		i__2 = i__ - 1) < 10000 && 0 <= i__2 ? i__2 : s_rnge("nivs", 
		i__2, "f_symtbc__", (ftnlen)398)) * 50, (ftnlen)50, (ftnlen)
		50);

/*        Associate the value NIVS(I) with the Ith symbol.  Add this */
/*        symbol to the table. */

	syputc_(name__, xvals + ((i__1 = i__ - 1) < 10000 && 0 <= i__1 ? i__1 
		: s_rnge("xvals", i__1, "f_symtbc__", (ftnlen)404)) * 50, &
		c__1, synams, syptrs, syvals, (ftnlen)45, (ftnlen)50, (ftnlen)
		45, (ftnlen)50);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Check the structure of the cells we've populated. */

/*     The symbol name cell first: */

    i__1 = cardc_(synams, (ftnlen)45);
    chcksi_("Card(SYNAMS)", &i__1, "=", &c__100, &c__0, ok, (ftnlen)12, (
	    ftnlen)1);
    i__1 = cardc_(synams, (ftnlen)45);
    for (i__ = 1; i__ <= i__1; ++i__) {
	s_copy(title, "Name #", (ftnlen)500, (ftnlen)6);
	repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)500);
	chcksc_(title, synams + ((i__2 = i__ + 5) < 106 && 0 <= i__2 ? i__2 : 
		s_rnge("synams", i__2, "f_symtbc__", (ftnlen)420)) * 45, 
		"=", xnames + ((i__3 = i__ - 1) < 100 && 0 <= i__3 ? i__3 : 
		s_rnge("xnames", i__3, "f_symtbc__", (ftnlen)420)) * 45, ok, (
		ftnlen)500, (ftnlen)45, (ftnlen)1, (ftnlen)45);
    }

/*     Then the "pointer" cell.  The pointers are actually element */
/*     counts. */

    i__1 = cardi_(syptrs);
    chcksi_("Card(SYPTRS)", &i__1, "=", &c__100, &c__0, ok, (ftnlen)12, (
	    ftnlen)1);
    chckai_("SYPTRS", &syptrs[6], "=", xptrs, &c__100, ok, (ftnlen)6, (ftnlen)
	    1);

/*     Then the value cell. */

    i__1 = cardc_(syvals, (ftnlen)50);
    chcksi_("Card(SYVALS)", &i__1, "=", &c__100, &c__0, ok, (ftnlen)12, (
	    ftnlen)1);
    chckac_("SYVALS", syvals + 300, "=", xvals, &c__100, ok, (ftnlen)6, (
	    ftnlen)50, (ftnlen)1, (ftnlen)50);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYFETC test:  Fetch names from symbol table with scalar-valued s"
	    "ymbols.", (ftnlen)71);
    for (i__ = 1; i__ <= 100; ++i__) {
	s_copy(title, "Was name # found?", (ftnlen)500, (ftnlen)17);
	repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)500);
	syfetc_(&i__, synams, syptrs, syvals, name__, &found, (ftnlen)45, (
		ftnlen)50, (ftnlen)45);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(title, &found, &c_true, ok, (ftnlen)500);
	s_copy(title, "Name #", (ftnlen)500, (ftnlen)6);
	repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)500);
	chcksc_(title, name__, "=", xnames + ((i__1 = i__ - 1) < 100 && 0 <= 
		i__1 ? i__1 : s_rnge("xnames", i__1, "f_symtbc__", (ftnlen)
		460)) * 45, ok, (ftnlen)500, (ftnlen)45, (ftnlen)1, (ftnlen)
		45);
    }

/*     Also look for a symbol we know isn't there. */

    i__ = 101;
    s_copy(title, "Was name # found?", (ftnlen)500, (ftnlen)17);
    repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)500);
    syfetc_(&c__101, synams, syptrs, syvals, name__, &found, (ftnlen)45, (
	    ftnlen)50, (ftnlen)45);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_(title, &found, &c_false, ok, (ftnlen)500);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYGETC test:  Fetch values from symbol table with scalar-valued "
	    "symbols.", (ftnlen)72);
    for (i__ = 1; i__ <= 100; ++i__) {
	s_copy(title, "Was name # found?", (ftnlen)500, (ftnlen)17);
	repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)500);
	sygetc_(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbc__", (ftnlen)490)) * 45, synams, 
		syptrs, syvals, &nvals, val, &found, (ftnlen)45, (ftnlen)45, (
		ftnlen)50, (ftnlen)50);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(title, &found, &c_true, ok, (ftnlen)500);
	s_copy(title, "Value of symbol #", (ftnlen)500, (ftnlen)17);
	repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)500);
	chcksc_(title, val, "=", xvals + ((i__1 = i__ - 1) < 10000 && 0 <= 
		i__1 ? i__1 : s_rnge("xvals", i__1, "f_symtbc__", (ftnlen)499)
		) * 50, ok, (ftnlen)500, (ftnlen)50, (ftnlen)1, (ftnlen)50);
    }

/*     Also look for a symbol we know isn't there. */

    s_copy(name__, "NOT_THERE", (ftnlen)45, (ftnlen)9);
    sygetc_(name__, synams, syptrs, syvals, &nvals, val, &found, (ftnlen)45, (
	    ftnlen)45, (ftnlen)50, (ftnlen)50);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    s_copy(title, "Was name # found?", (ftnlen)500, (ftnlen)17);
    repmc_(title, "#", name__, title, (ftnlen)500, (ftnlen)1, (ftnlen)45, (
	    ftnlen)500);
    chcksl_(title, &found, &c_false, ok, (ftnlen)500);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYRENC test:  Rename symbols in a simple symbol table with scala"
	    "r-valued symbols.", (ftnlen)81);
    for (i__ = 1; i__ <= 100; ++i__) {

/*        Get the name and value of the ith symbol. */

	t_ithsym__(&i__, &c__100, name__, (ftnlen)45);
	sygetc_(name__, synams, syptrs, syvals, &nvals, xval, &found, (ftnlen)
		45, (ftnlen)45, (ftnlen)50, (ftnlen)50);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	s_copy(title, "Was name # found?", (ftnlen)500, (ftnlen)17);
	repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)500);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(title, &found, &c_true, ok, (ftnlen)500);

/*        Create the replacement name: */

	replch_(name__, "X", "Y", newnam, (ftnlen)45, (ftnlen)1, (ftnlen)1, (
		ftnlen)45);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Change the name of the symbol. */

	syrenc_(name__, newnam, synams, syptrs, syvals, (ftnlen)45, (ftnlen)
		45, (ftnlen)45, (ftnlen)50);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Make sure the old symbol is gone. */

	sygetc_(name__, synams, syptrs, syvals, &nvals, val, &found, (ftnlen)
		45, (ftnlen)45, (ftnlen)50, (ftnlen)50);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	s_copy(title, "Was name # found?", (ftnlen)500, (ftnlen)17);
	repmc_(title, "#", name__, title, (ftnlen)500, (ftnlen)1, (ftnlen)45, 
		(ftnlen)500);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(title, &found, &c_false, ok, (ftnlen)500);

/*        Get the value associated with the new name. */


/*        Get the name and value of the ith symbol. */

	sygetc_(newnam, synams, syptrs, syvals, &nvals, val, &found, (ftnlen)
		45, (ftnlen)45, (ftnlen)50, (ftnlen)50);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	s_copy(title, "Was name # found?", (ftnlen)500, (ftnlen)17);
	repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)500);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(title, &found, &c_true, ok, (ftnlen)500);

/*        Check the value. */

	chcksc_("VAL", val, "=", xval, ok, (ftnlen)3, (ftnlen)50, (ftnlen)1, (
		ftnlen)50);

/*        Change the name back to its original value. */

	syrenc_(newnam, name__, synams, syptrs, syvals, (ftnlen)45, (ftnlen)
		45, (ftnlen)45, (ftnlen)50);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("SYDELC test:  Delete symbols from symbol table with scalar-value"
	    "d symbols.", (ftnlen)74);
    for (i__ = 1; i__ <= 100; ++i__) {
	s_copy(title, "Was name # found?", (ftnlen)500, (ftnlen)17);
	repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)500);
	sydelc_(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbc__", (ftnlen)608)) * 45, synams, 
		syptrs, syvals, (ftnlen)45, (ftnlen)45, (ftnlen)50);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Make sure the symbol is gone. */

	s_copy(title, "Was (deleted symbol) name # found?", (ftnlen)500, (
		ftnlen)34);
	repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)500);
	sygetc_(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbc__", (ftnlen)617)) * 45, synams, 
		syptrs, syvals, &nvals, val, &found, (ftnlen)45, (ftnlen)45, (
		ftnlen)50, (ftnlen)50);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(title, &found, &c_false, ok, (ftnlen)500);

/*        Validate the remaining symbol table. */

	for (j = i__ + 1; j <= 100; ++j) {
	    s_copy(title, "Was (remaining symbol) name # found?", (ftnlen)500,
		     (ftnlen)36);
	    repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)
		    500);
	    sygetc_(xnames + ((i__1 = j - 1) < 100 && 0 <= i__1 ? i__1 : 
		    s_rnge("xnames", i__1, "f_symtbc__", (ftnlen)631)) * 45, 
		    synams, syptrs, syvals, &nvals, val, &found, (ftnlen)45, (
		    ftnlen)45, (ftnlen)50, (ftnlen)50);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    chcksl_(title, &found, &c_true, ok, (ftnlen)500);
	    s_copy(title, "Remaining symbol # value", (ftnlen)500, (ftnlen)24)
		    ;
	    repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)
		    500);
	    chcksc_(title, val, "=", xvals + ((i__1 = j - 1) < 10000 && 0 <= 
		    i__1 ? i__1 : s_rnge("xvals", i__1, "f_symtbc__", (ftnlen)
		    640)) * 50, ok, (ftnlen)500, (ftnlen)50, (ftnlen)1, (
		    ftnlen)50);
	}
    }

/*     At this point, we need to work with symbol tables containing */
/*     symbols having multiple values associated with them.  We'll */
/*     build a symbol table whose nth symbol has n associated values. */


/* --- Case: ------------------------------------------------------ */

    tcase_("SYPUTC test:  Create symbol table with array-valued symbols.", (
	    ftnlen)60);
    scardc_(&c__0, synams, (ftnlen)45);
    scardi_(&c__0, syptrs);
    scardc_(&c__0, syvals, (ftnlen)50);
    to = 1;
    for (i__ = 1; i__ <= 100; ++i__) {

/*        Create the symbol name. */

	t_ithsym__(&i__, &c__100, name__, (ftnlen)45);
	s_copy(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbc__", (ftnlen)671)) * 45, name__, (
		ftnlen)45, (ftnlen)45);
	xptrs[(i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge("xptrs", 
		i__1, "f_symtbc__", (ftnlen)672)] = i__;
	start = to;
	i__1 = i__;
	for (j = 1; j <= i__1; ++j) {
	    s_copy(xvals + ((i__2 = to - 1) < 10000 && 0 <= i__2 ? i__2 : 
		    s_rnge("xvals", i__2, "f_symtbc__", (ftnlen)677)) * 50, 
		    ivs + ((i__3 = to - 1) < 10000 && 0 <= i__3 ? i__3 : 
		    s_rnge("ivs", i__3, "f_symtbc__", (ftnlen)677)) * 50, (
		    ftnlen)50, (ftnlen)50);
	    ++to;
	}

/*        Add the symbol to the table. */

	syputc_(name__, xvals + ((i__1 = start - 1) < 10000 && 0 <= i__1 ? 
		i__1 : s_rnge("xvals", i__1, "f_symtbc__", (ftnlen)685)) * 50,
		 &i__, synams, syptrs, syvals, (ftnlen)45, (ftnlen)50, (
		ftnlen)45, (ftnlen)50);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Check the structure of the cells we've populated. */

/*     The symbol name cell first: */

    i__1 = cardc_(synams, (ftnlen)45);
    chcksi_("Card(SYNAMS)", &i__1, "=", &c__100, &c__0, ok, (ftnlen)12, (
	    ftnlen)1);
    i__1 = cardc_(synams, (ftnlen)45);
    for (i__ = 1; i__ <= i__1; ++i__) {
	s_copy(title, "Name #", (ftnlen)500, (ftnlen)6);
	repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)500);
	chcksc_(title, synams + ((i__2 = i__ + 5) < 106 && 0 <= i__2 ? i__2 : 
		s_rnge("synams", i__2, "f_symtbc__", (ftnlen)702)) * 45, 
		"=", xnames + ((i__3 = i__ - 1) < 100 && 0 <= i__3 ? i__3 : 
		s_rnge("xnames", i__3, "f_symtbc__", (ftnlen)702)) * 45, ok, (
		ftnlen)500, (ftnlen)45, (ftnlen)1, (ftnlen)45);
    }

/*     Then the "pointer" cell.  The pointers are actually element */
/*     counts. */

    i__1 = cardi_(syptrs);
    chcksi_("Card(SYPTRS)", &i__1, "=", &c__100, &c__0, ok, (ftnlen)12, (
	    ftnlen)1);
    chckai_("SYPTRS", &syptrs[6], "=", xptrs, &c__100, ok, (ftnlen)6, (ftnlen)
	    1);

/*     Then the value cell. */

    xcard = 5050;
    i__1 = cardc_(syvals, (ftnlen)50);
    chcksi_("Card(SYVALS)", &i__1, "=", &xcard, &c__0, ok, (ftnlen)12, (
	    ftnlen)1);
    chckac_("SYVALS", syvals + 300, "=", xvals, &c__100, ok, (ftnlen)6, (
	    ftnlen)50, (ftnlen)1, (ftnlen)50);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYPUTC test:  Populate a simple symbol table with scalar-valued "
	    "symbols.  Insert symbols in reverse order.", (ftnlen)106);

/*     Clear out the symbol table. */

    scardc_(&c__0, synams, (ftnlen)45);
    scardi_(&c__0, syptrs);
    scardc_(&c__0, syvals, (ftnlen)50);
    clearc_(&c__10000, xvals, (ftnlen)50);

/*     Use the symbol names and values from the previous test. */

    size = 5050;
    start = size - 99;
    for (i__ = 100; i__ >= 1; --i__) {

/*        Add the symbol to the table. */

	syputc_(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbc__", (ftnlen)751)) * 45, xvals + ((
		i__2 = start - 1) < 10000 && 0 <= i__2 ? i__2 : s_rnge("xvals"
		, i__2, "f_symtbc__", (ftnlen)751)) * 50, &i__, synams, 
		syptrs, syvals, (ftnlen)45, (ftnlen)50, (ftnlen)45, (ftnlen)
		50);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	start -= i__ - 1;
    }

/*     We should end up with the same symbol table as in the */
/*     previous test case. */


/*     Check the structure of the cells we've populated. */

/*     The symbol name cell first: */

    i__1 = cardc_(synams, (ftnlen)45);
    chcksi_("Card(SYNAMS)", &i__1, "=", &c__100, &c__0, ok, (ftnlen)12, (
	    ftnlen)1);
    i__1 = cardc_(synams, (ftnlen)45);
    for (i__ = 1; i__ <= i__1; ++i__) {
	s_copy(title, "Name #", (ftnlen)500, (ftnlen)6);
	repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)500);
	chcksc_(title, synams + ((i__2 = i__ + 5) < 106 && 0 <= i__2 ? i__2 : 
		s_rnge("synams", i__2, "f_symtbc__", (ftnlen)775)) * 45, 
		"=", xnames + ((i__3 = i__ - 1) < 100 && 0 <= i__3 ? i__3 : 
		s_rnge("xnames", i__3, "f_symtbc__", (ftnlen)775)) * 45, ok, (
		ftnlen)500, (ftnlen)45, (ftnlen)1, (ftnlen)45);
    }

/*     Then the "pointer" cell.  The pointers are actually element */
/*     counts. */

    i__1 = cardi_(syptrs);
    chcksi_("Card(SYPTRS)", &i__1, "=", &c__100, &c__0, ok, (ftnlen)12, (
	    ftnlen)1);
    chckai_("SYPTRS", &syptrs[6], "=", xptrs, &c__100, ok, (ftnlen)6, (ftnlen)
	    1);

/*     Then the value cell. */

    xcard = 5050;
    i__1 = cardc_(syvals, (ftnlen)50);
    chcksi_("Card(SYVALS)", &i__1, "=", &xcard, &c__0, ok, (ftnlen)12, (
	    ftnlen)1);
    chckac_("SYVALS", syvals + 300, "=", xvals, &c__100, ok, (ftnlen)6, (
	    ftnlen)50, (ftnlen)1, (ftnlen)50);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYGETC test:  validate array-valued symbol table by fetching val"
	    "ues associated with each symbol.", (ftnlen)96);
    start = 1;
    for (i__ = 1; i__ <= 100; ++i__) {
	s_copy(title, "Was name # found?", (ftnlen)500, (ftnlen)17);
	repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)500);
	sygetc_(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbc__", (ftnlen)814)) * 45, synams, 
		syptrs, syvals, &nvals, cvals, &found, (ftnlen)45, (ftnlen)45,
		 (ftnlen)50, (ftnlen)50);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(title, &found, &c_true, ok, (ftnlen)500);
	if (found) {
	    s_copy(title, "Values of symbol #", (ftnlen)500, (ftnlen)18);
	    repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)
		    500);
	    chckac_(title, cvals, "=", xvals + ((i__1 = start - 1) < 10000 && 
		    0 <= i__1 ? i__1 : s_rnge("xvals", i__1, "f_symtbc__", (
		    ftnlen)825)) * 50, &i__, ok, (ftnlen)500, (ftnlen)50, (
		    ftnlen)1, (ftnlen)50);
	}
	start += i__;
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("SYNTHC test:  validate array-valued symbol table by fetching val"
	    "ues associated with each symbol.", (ftnlen)96);
    start = 1;
    for (i__ = 1; i__ <= 100; ++i__) {
	s_copy(title, "Was name # found?", (ftnlen)500, (ftnlen)17);
	repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)500);
	sygetc_(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbc__", (ftnlen)849)) * 45, synams, 
		syptrs, syvals, &nvals, cvals, &found, (ftnlen)45, (ftnlen)45,
		 (ftnlen)50, (ftnlen)50);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(title, &found, &c_true, ok, (ftnlen)500);
	if (found) {

/*           Get the size of the current symbol. */

	    size = sydimc_(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? 
		    i__1 : s_rnge("xnames", i__1, "f_symtbc__", (ftnlen)859)) 
		    * 45, synams, syptrs, syvals, (ftnlen)45, (ftnlen)45, (
		    ftnlen)50);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    i__1 = size;
	    for (j = 1; j <= i__1; ++j) {

/*              Fetch each value. */

		s_copy(title, "Value # of symbol #", (ftnlen)500, (ftnlen)19);
		repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (
			ftnlen)500);
		repmc_(title, "#", xnames + ((i__2 = i__ - 1) < 100 && 0 <= 
			i__2 ? i__2 : s_rnge("xnames", i__2, "f_symtbc__", (
			ftnlen)868)) * 45, title, (ftnlen)500, (ftnlen)1, (
			ftnlen)45, (ftnlen)500);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		synthc_(xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 :
			 s_rnge("xnames", i__2, "f_symtbc__", (ftnlen)871)) * 
			45, &j, synams, syptrs, syvals, val, &found, (ftnlen)
			45, (ftnlen)45, (ftnlen)50, (ftnlen)50);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		chcksl_(title, &found, &c_true, ok, (ftnlen)500);
		chcksc_(title, val, "=", xvals + ((i__2 = start + j - 2) < 
			10000 && 0 <= i__2 ? i__2 : s_rnge("xvals", i__2, 
			"f_symtbc__", (ftnlen)877)) * 50, ok, (ftnlen)500, (
			ftnlen)50, (ftnlen)1, (ftnlen)50);
	    }

/*           Try to fetch an element we know isn't there. */

	    j = size + 1;
	    s_copy(title, "Value # of symbol #", (ftnlen)500, (ftnlen)19);
	    repmi_(title, "#", &j, title, (ftnlen)500, (ftnlen)1, (ftnlen)500)
		    ;
	    repmc_(title, "#", xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ?
		     i__1 : s_rnge("xnames", i__1, "f_symtbc__", (ftnlen)889))
		     * 45, title, (ftnlen)500, (ftnlen)1, (ftnlen)45, (ftnlen)
		    500);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    synthc_(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : 
		    s_rnge("xnames", i__1, "f_symtbc__", (ftnlen)892)) * 45, &
		    j, synams, syptrs, syvals, val, &found, (ftnlen)45, (
		    ftnlen)45, (ftnlen)50, (ftnlen)50);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    chcksl_(title, &found, &c_false, ok, (ftnlen)500);
	}
	start += i__;
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("SYENQC test:  Create symbol table with array-valued symbols.", (
	    ftnlen)60);
    scardc_(&c__0, synams, (ftnlen)45);
    scardi_(&c__0, syptrs);
    scardc_(&c__0, syvals, (ftnlen)50);
    to = 1;
    for (i__ = 1; i__ <= 100; ++i__) {

/*        Create the symbol name. */

	t_ithsym__(&i__, &c__100, name__, (ftnlen)45);
	s_copy(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbc__", (ftnlen)924)) * 45, name__, (
		ftnlen)45, (ftnlen)45);
	xptrs[(i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge("xptrs", 
		i__1, "f_symtbc__", (ftnlen)925)] = i__;
	i__1 = i__;
	for (j = 1; j <= i__1; ++j) {
	    s_copy(xvals + ((i__2 = to - 1) < 10000 && 0 <= i__2 ? i__2 : 
		    s_rnge("xvals", i__2, "f_symtbc__", (ftnlen)929)) * 50, 
		    ivs + ((i__3 = to - 1) < 10000 && 0 <= i__3 ? i__3 : 
		    s_rnge("ivs", i__3, "f_symtbc__", (ftnlen)929)) * 50, (
		    ftnlen)50, (ftnlen)50);
	    syenqc_(name__, xvals + ((i__2 = to - 1) < 10000 && 0 <= i__2 ? 
		    i__2 : s_rnge("xvals", i__2, "f_symtbc__", (ftnlen)931)) *
		     50, synams, syptrs, syvals, (ftnlen)45, (ftnlen)50, (
		    ftnlen)45, (ftnlen)50);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    ++to;
	}
    }

/*     Check the structure of the cells we've populated. */

/*     The symbol name cell first: */

    i__1 = cardc_(synams, (ftnlen)45);
    chcksi_("Card(SYNAMS)", &i__1, "=", &c__100, &c__0, ok, (ftnlen)12, (
	    ftnlen)1);
    i__1 = cardc_(synams, (ftnlen)45);
    for (i__ = 1; i__ <= i__1; ++i__) {
	s_copy(title, "Name #", (ftnlen)500, (ftnlen)6);
	repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)500);
	chcksc_(title, synams + ((i__2 = i__ + 5) < 106 && 0 <= i__2 ? i__2 : 
		s_rnge("synams", i__2, "f_symtbc__", (ftnlen)952)) * 45, 
		"=", xnames + ((i__3 = i__ - 1) < 100 && 0 <= i__3 ? i__3 : 
		s_rnge("xnames", i__3, "f_symtbc__", (ftnlen)952)) * 45, ok, (
		ftnlen)500, (ftnlen)45, (ftnlen)1, (ftnlen)45);
    }

/*     Then the "pointer" cell.  The pointers are actually element */
/*     counts. */

    i__1 = cardi_(syptrs);
    chcksi_("Card(SYPTRS)", &i__1, "=", &c__100, &c__0, ok, (ftnlen)12, (
	    ftnlen)1);
    chckai_("SYPTRS", &syptrs[6], "=", xptrs, &c__100, ok, (ftnlen)6, (ftnlen)
	    1);

/*     Then the value cell. */

    xcard = 5050;
    i__1 = cardc_(syvals, (ftnlen)50);
    chcksi_("Card(SYVALS)", &i__1, "=", &xcard, &c__0, ok, (ftnlen)12, (
	    ftnlen)1);
    chckac_("SYVALS", syvals + 300, "=", xvals, &c__100, ok, (ftnlen)6, (
	    ftnlen)50, (ftnlen)1, (ftnlen)50);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYPSHC test:  Create symbol table with array-valued symbols.", (
	    ftnlen)60);
    scardc_(&c__0, synams, (ftnlen)45);
    scardi_(&c__0, syptrs);
    scardc_(&c__0, syvals, (ftnlen)50);
    to = 0;
    for (i__ = 1; i__ <= 100; ++i__) {

/*        Create the symbol name. */

	t_ithsym__(&i__, &c__100, name__, (ftnlen)45);
	s_copy(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbc__", (ftnlen)993)) * 45, name__, (
		ftnlen)45, (ftnlen)45);
	xptrs[(i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge("xptrs", 
		i__1, "f_symtbc__", (ftnlen)994)] = i__;
	to += i__;

/*        At the start of the loop, TO points to the element of XVALS */
/*        that will hold the last value associated with the Ith symbol. */

	for (j = i__; j >= 1; --j) {
	    s_copy(xvals + ((i__1 = to - 1) < 10000 && 0 <= i__1 ? i__1 : 
		    s_rnge("xvals", i__1, "f_symtbc__", (ftnlen)1003)) * 50, 
		    ivs + ((i__2 = to - 1) < 10000 && 0 <= i__2 ? i__2 : 
		    s_rnge("ivs", i__2, "f_symtbc__", (ftnlen)1003)) * 50, (
		    ftnlen)50, (ftnlen)50);
	    sypshc_(name__, xvals + ((i__1 = to - 1) < 10000 && 0 <= i__1 ? 
		    i__1 : s_rnge("xvals", i__1, "f_symtbc__", (ftnlen)1005)) 
		    * 50, synams, syptrs, syvals, (ftnlen)45, (ftnlen)50, (
		    ftnlen)45, (ftnlen)50);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    --to;
	}
	to += i__;
    }

/*     Check the structure of the cells we've populated. */

/*     The symbol name cell first: */

    i__1 = cardc_(synams, (ftnlen)45);
    chcksi_("Card(SYNAMS)", &i__1, "=", &c__100, &c__0, ok, (ftnlen)12, (
	    ftnlen)1);
    i__1 = cardc_(synams, (ftnlen)45);
    for (i__ = 1; i__ <= i__1; ++i__) {
	s_copy(title, "Name #", (ftnlen)500, (ftnlen)6);
	repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)500);
	chcksc_(title, synams + ((i__2 = i__ + 5) < 106 && 0 <= i__2 ? i__2 : 
		s_rnge("synams", i__2, "f_symtbc__", (ftnlen)1028)) * 45, 
		"=", xnames + ((i__3 = i__ - 1) < 100 && 0 <= i__3 ? i__3 : 
		s_rnge("xnames", i__3, "f_symtbc__", (ftnlen)1028)) * 45, ok, 
		(ftnlen)500, (ftnlen)45, (ftnlen)1, (ftnlen)45);
    }

/*     Then the "pointer" cell.  The pointers are actually element */
/*     counts. */

    i__1 = cardi_(syptrs);
    chcksi_("Card(SYPTRS)", &i__1, "=", &c__100, &c__0, ok, (ftnlen)12, (
	    ftnlen)1);
    chckai_("SYPTRS", &syptrs[6], "=", xptrs, &c__100, ok, (ftnlen)6, (ftnlen)
	    1);

/*     Then the value cell. */

    xcard = 5050;
    i__1 = cardc_(syvals, (ftnlen)50);
    chcksi_("Card(SYVALS)", &i__1, "=", &xcard, &c__0, ok, (ftnlen)12, (
	    ftnlen)1);
    chckac_("SYVALS", syvals + 300, "=", xvals, &c__100, ok, (ftnlen)6, (
	    ftnlen)50, (ftnlen)1, (ftnlen)50);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYDUPC test:  Create symbol table with array-valued symbols.  Th"
	    "en duplicate each symbol.", (ftnlen)89);
    scardc_(&c__0, synams, (ftnlen)45);
    scardi_(&c__0, syptrs);
    scardc_(&c__0, syvals, (ftnlen)50);

/*     We'll set the cardinality upper bound UB to MAXTAB/2, so */
/*     we'll have room for the duplicate symbols. */

    to = 1;
    ub = 50;
    i__1 = ub;
    for (i__ = 1; i__ <= i__1; ++i__) {

/*        Create the symbol name. */

	t_ithsym__(&i__, &ub, name__, (ftnlen)45);
	s_copy(xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 : s_rnge(
		"xnames", i__2, "f_symtbc__", (ftnlen)1076)) * 45, name__, (
		ftnlen)45, (ftnlen)45);
	xptrs[(i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 : s_rnge("xptrs", 
		i__2, "f_symtbc__", (ftnlen)1077)] = i__;
	i__2 = i__;
	for (j = 1; j <= i__2; ++j) {
	    s_copy(xvals + ((i__3 = to - 1) < 10000 && 0 <= i__3 ? i__3 : 
		    s_rnge("xvals", i__3, "f_symtbc__", (ftnlen)1081)) * 50, 
		    ivs + ((i__4 = to - 1) < 10000 && 0 <= i__4 ? i__4 : 
		    s_rnge("ivs", i__4, "f_symtbc__", (ftnlen)1081)) * 50, (
		    ftnlen)50, (ftnlen)50);
	    syenqc_(name__, xvals + ((i__3 = to - 1) < 10000 && 0 <= i__3 ? 
		    i__3 : s_rnge("xvals", i__3, "f_symtbc__", (ftnlen)1083)) 
		    * 50, synams, syptrs, syvals, (ftnlen)45, (ftnlen)50, (
		    ftnlen)45, (ftnlen)50);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    ++to;
	}
    }

/*     Validate the symbol table at this stage. */

    start = 1;
    i__1 = ub;
    for (i__ = 1; i__ <= i__1; ++i__) {
	s_copy(title, "Was name # found? (0)", (ftnlen)500, (ftnlen)21);
	repmc_(title, "#", xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ? 
		i__2 : s_rnge("xnames", i__2, "f_symtbc__", (ftnlen)1100)) * 
		45, title, (ftnlen)500, (ftnlen)1, (ftnlen)45, (ftnlen)500);
	sygetc_(xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 : s_rnge(
		"xnames", i__2, "f_symtbc__", (ftnlen)1102)) * 45, synams, 
		syptrs, syvals, &nvals, cvals, &found, (ftnlen)45, (ftnlen)45,
		 (ftnlen)50, (ftnlen)50);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(title, &found, &c_true, ok, (ftnlen)500);
	if (found) {
	    s_copy(title, "Values of symbol # (0)", (ftnlen)500, (ftnlen)22);
	    repmc_(title, "#", xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ?
		     i__2 : s_rnge("xnames", i__2, "f_symtbc__", (ftnlen)1111)
		    ) * 45, title, (ftnlen)500, (ftnlen)1, (ftnlen)45, (
		    ftnlen)500);
	    chckac_(title, cvals, "=", xvals + ((i__2 = start - 1) < 10000 && 
		    0 <= i__2 ? i__2 : s_rnge("xvals", i__2, "f_symtbc__", (
		    ftnlen)1113)) * 50, &i__, ok, (ftnlen)500, (ftnlen)50, (
		    ftnlen)1, (ftnlen)50);
	}
	start += i__;
    }

/*     Look up each symbol; add to the symbol table a duplicate symbol */
/*     with a new name. */

    i__1 = ub;
    for (i__ = 1; i__ <= i__1; ++i__) {

/*        Create the symbol name. */

	t_ithsym__(&i__, &ub, name__, (ftnlen)45);
	s_copy(newnam, name__, (ftnlen)45, (ftnlen)45);
	s_copy(newnam, "2_", (ftnlen)2, (ftnlen)2);
	sydupc_(name__, newnam, synams, syptrs, syvals, (ftnlen)45, (ftnlen)
		45, (ftnlen)45, (ftnlen)50);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Now validate the symbol table.  First make sure the original */
/*     symbols are intact. */

    start = 1;
    i__1 = ub;
    for (i__ = 1; i__ <= i__1; ++i__) {
	s_copy(title, "Was name # found? (1)", (ftnlen)500, (ftnlen)21);
	repmc_(title, "#", xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ? 
		i__2 : s_rnge("xnames", i__2, "f_symtbc__", (ftnlen)1148)) * 
		45, title, (ftnlen)500, (ftnlen)1, (ftnlen)45, (ftnlen)500);
	sygetc_(xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 : s_rnge(
		"xnames", i__2, "f_symtbc__", (ftnlen)1150)) * 45, synams, 
		syptrs, syvals, &nvals, cvals, &found, (ftnlen)45, (ftnlen)45,
		 (ftnlen)50, (ftnlen)50);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(title, &found, &c_true, ok, (ftnlen)500);
	if (found) {
	    s_copy(title, "Values of symbol # (1)", (ftnlen)500, (ftnlen)22);
	    repmc_(title, "#", xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ?
		     i__2 : s_rnge("xnames", i__2, "f_symtbc__", (ftnlen)1159)
		    ) * 45, title, (ftnlen)500, (ftnlen)1, (ftnlen)45, (
		    ftnlen)500);
	    chckac_(title, cvals, "=", xvals + ((i__2 = start - 1) < 10000 && 
		    0 <= i__2 ? i__2 : s_rnge("xvals", i__2, "f_symtbc__", (
		    ftnlen)1161)) * 50, &i__, ok, (ftnlen)500, (ftnlen)50, (
		    ftnlen)1, (ftnlen)50);
	}
	start += i__;
    }

/*     Now check the duplicate symbols. */

    start = 1;
    i__1 = ub;
    for (i__ = 1; i__ <= i__1; ++i__) {
	s_copy(newnam, xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 : 
		s_rnge("xnames", i__2, "f_symtbc__", (ftnlen)1176)) * 45, (
		ftnlen)45, (ftnlen)45);
	s_copy(newnam, "2_", (ftnlen)2, (ftnlen)2);
	s_copy(title, "Was name # found? (2)", (ftnlen)500, (ftnlen)21);
	repmc_(title, "#", newnam, title, (ftnlen)500, (ftnlen)1, (ftnlen)45, 
		(ftnlen)500);
	sygetc_(newnam, synams, syptrs, syvals, &nvals, cvals, &found, (
		ftnlen)45, (ftnlen)45, (ftnlen)50, (ftnlen)50);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(title, &found, &c_true, ok, (ftnlen)500);
	if (found) {
	    s_copy(title, "Values of symbol # (2)", (ftnlen)500, (ftnlen)22);
	    repmc_(title, "#", newnam, title, (ftnlen)500, (ftnlen)1, (ftnlen)
		    45, (ftnlen)500);
	    chckac_(title, cvals, "=", xvals + ((i__2 = start - 1) < 10000 && 
		    0 <= i__2 ? i__2 : s_rnge("xvals", i__2, "f_symtbc__", (
		    ftnlen)1193)) * 50, &i__, ok, (ftnlen)500, (ftnlen)50, (
		    ftnlen)1, (ftnlen)50);
	}
	start += i__;
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("SYDUPC test:  Create symbol table with array-valued symbols.  Du"
	    "plicate these symbols.  Negate the values of the original symbol"
	    "s.  Then duplicate the duplicate the symbols, overwriting the or"
	    "iginal symbols.", (ftnlen)207);
    scardc_(&c__0, synams, (ftnlen)45);
    scardi_(&c__0, syptrs);
    scardc_(&c__0, syvals, (ftnlen)50);

/*     We'll set the cardinality upper bound UB to MAXTAB/2, so */
/*     we'll have room for the duplicate symbols. */

    to = 1;
    ub = 50;
    i__1 = ub;
    for (i__ = 1; i__ <= i__1; ++i__) {

/*        Create the symbol name. */

	t_ithsym__(&i__, &ub, name__, (ftnlen)45);
	s_copy(xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 : s_rnge(
		"xnames", i__2, "f_symtbc__", (ftnlen)1228)) * 45, name__, (
		ftnlen)45, (ftnlen)45);
	xptrs[(i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 : s_rnge("xptrs", 
		i__2, "f_symtbc__", (ftnlen)1229)] = i__;
	i__2 = i__;
	for (j = 1; j <= i__2; ++j) {
	    s_copy(xvals + ((i__3 = to - 1) < 10000 && 0 <= i__3 ? i__3 : 
		    s_rnge("xvals", i__3, "f_symtbc__", (ftnlen)1233)) * 50, 
		    ivs + ((i__4 = to - 1) < 10000 && 0 <= i__4 ? i__4 : 
		    s_rnge("ivs", i__4, "f_symtbc__", (ftnlen)1233)) * 50, (
		    ftnlen)50, (ftnlen)50);
	    syenqc_(name__, xvals + ((i__3 = to - 1) < 10000 && 0 <= i__3 ? 
		    i__3 : s_rnge("xvals", i__3, "f_symtbc__", (ftnlen)1235)) 
		    * 50, synams, syptrs, syvals, (ftnlen)45, (ftnlen)50, (
		    ftnlen)45, (ftnlen)50);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    ++to;
	}
    }

/*     Look up each symbol; add to the symbol table a duplicate symbol */
/*     with a new name. */

    i__1 = ub;
    for (i__ = 1; i__ <= i__1; ++i__) {

/*        Create the symbol name. */

	t_ithsym__(&i__, &ub, name__, (ftnlen)45);
	s_copy(newnam, name__, (ftnlen)45, (ftnlen)45);
	s_copy(newnam, "2_", (ftnlen)2, (ftnlen)2);
	sydupc_(name__, newnam, synams, syptrs, syvals, (ftnlen)45, (ftnlen)
		45, (ftnlen)45, (ftnlen)50);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     "Negate" the values of original symbols. */

    i__1 = ub;
    for (i__ = 1; i__ <= i__1; ++i__) {
	sygetc_(xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 : s_rnge(
		"xnames", i__2, "f_symtbc__", (ftnlen)1267)) * 45, synams, 
		syptrs, syvals, &nvals, cvals, &found, (ftnlen)45, (ftnlen)45,
		 (ftnlen)50, (ftnlen)50);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	i__2 = nvals;
	for (j = 1; j <= i__2; ++j) {
	    prefix_("-", &c__0, cvals + ((i__3 = j - 1) < 10000 && 0 <= i__3 ?
		     i__3 : s_rnge("cvals", i__3, "f_symtbc__", (ftnlen)1272))
		     * 50, (ftnlen)1, (ftnlen)50);
	}
	syputc_(xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 : s_rnge(
		"xnames", i__2, "f_symtbc__", (ftnlen)1275)) * 45, cvals, &
		nvals, synams, syptrs, syvals, (ftnlen)45, (ftnlen)50, (
		ftnlen)45, (ftnlen)50);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Duplicate the duplicate symbols, overwriting the originals. */

    i__1 = ub;
    for (i__ = 1; i__ <= i__1; ++i__) {

/*        Create the symbol name. */

	t_ithsym__(&i__, &ub, name__, (ftnlen)45);
	s_copy(newnam, name__, (ftnlen)45, (ftnlen)45);
	s_copy(newnam, "2_", (ftnlen)2, (ftnlen)2);
	sydupc_(newnam, name__, synams, syptrs, syvals, (ftnlen)45, (ftnlen)
		45, (ftnlen)45, (ftnlen)50);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Now validate the symbol table.  First make sure the */
/*     first set of duplicate symbols is intact. */

    start = 1;
    i__1 = ub;
    for (i__ = 1; i__ <= i__1; ++i__) {
	t_ithsym__(&i__, &ub, name__, (ftnlen)45);
	s_copy(newnam, name__, (ftnlen)45, (ftnlen)45);
	s_copy(newnam, "2_", (ftnlen)2, (ftnlen)2);
	s_copy(title, "Was name # found? (1)", (ftnlen)500, (ftnlen)21);
	repmc_(title, "#", newnam, title, (ftnlen)500, (ftnlen)1, (ftnlen)45, 
		(ftnlen)500);
	sygetc_(xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 : s_rnge(
		"xnames", i__2, "f_symtbc__", (ftnlen)1314)) * 45, synams, 
		syptrs, syvals, &nvals, cvals, &found, (ftnlen)45, (ftnlen)45,
		 (ftnlen)50, (ftnlen)50);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(title, &found, &c_true, ok, (ftnlen)500);
	if (found) {
	    s_copy(title, "Values of symbol # (1)", (ftnlen)500, (ftnlen)22);
	    repmc_(title, "#", xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ?
		     i__2 : s_rnge("xnames", i__2, "f_symtbc__", (ftnlen)1323)
		    ) * 45, title, (ftnlen)500, (ftnlen)1, (ftnlen)45, (
		    ftnlen)500);
	    chckac_(title, cvals, "=", xvals + ((i__2 = start - 1) < 10000 && 
		    0 <= i__2 ? i__2 : s_rnge("xvals", i__2, "f_symtbc__", (
		    ftnlen)1325)) * 50, &i__, ok, (ftnlen)500, (ftnlen)50, (
		    ftnlen)1, (ftnlen)50);
	}
	start += i__;
    }

/*     Now check the duplicated duplicate symbols. */

    start = 1;
    i__1 = ub;
    for (i__ = 1; i__ <= i__1; ++i__) {
	s_copy(title, "Was name # found? (2)", (ftnlen)500, (ftnlen)21);
	repmc_(title, "#", name__, title, (ftnlen)500, (ftnlen)1, (ftnlen)45, 
		(ftnlen)500);
	sygetc_(xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 : s_rnge(
		"xnames", i__2, "f_symtbc__", (ftnlen)1343)) * 45, synams, 
		syptrs, syvals, &nvals, cvals, &found, (ftnlen)45, (ftnlen)45,
		 (ftnlen)50, (ftnlen)50);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(title, &found, &c_true, ok, (ftnlen)500);
	if (found) {
	    s_copy(title, "Values of symbol # (2)", (ftnlen)500, (ftnlen)22);
	    repmc_(title, "#", newnam, title, (ftnlen)500, (ftnlen)1, (ftnlen)
		    45, (ftnlen)500);
	    chckac_(title, cvals, "=", xvals + ((i__2 = start - 1) < 10000 && 
		    0 <= i__2 ? i__2 : s_rnge("xvals", i__2, "f_symtbc__", (
		    ftnlen)1354)) * 50, &i__, ok, (ftnlen)500, (ftnlen)50, (
		    ftnlen)1, (ftnlen)50);
	}
	start += i__;
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("SYORDC test:  Create symbol table with array-valued symbols; sor"
	    "t values associated with each symbol.", (ftnlen)101);
    scardc_(&c__0, synams, (ftnlen)45);
    scardi_(&c__0, syptrs);
    scardc_(&c__0, syvals, (ftnlen)50);
    clearc_(&c__10000, xvals, (ftnlen)50);

/*     Create the symbol table to be sorted. */

    to = 1;
    for (i__ = 1; i__ <= 100; ++i__) {

/*        Create the symbol name. */

	t_ithsym__(&i__, &c__100, name__, (ftnlen)45);
	s_copy(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbc__", (ftnlen)1387)) * 45, name__, (
		ftnlen)45, (ftnlen)45);
	i__1 = i__;
	for (j = 1; j <= i__1; ++j) {
	    s_copy(val, ivs + ((i__2 = to - 1) < 10000 && 0 <= i__2 ? i__2 : 
		    s_rnge("ivs", i__2, "f_symtbc__", (ftnlen)1391)) * 50, (
		    ftnlen)50, (ftnlen)50);
	    syenqc_(name__, val, synams, syptrs, syvals, (ftnlen)45, (ftnlen)
		    50, (ftnlen)45, (ftnlen)50);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    ++to;
	}
    }

/*     Sort the symbol values. */

    for (i__ = 1; i__ <= 100; ++i__) {
	syordc_(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbc__", (ftnlen)1407)) * 45, synams, 
		syptrs, syvals, (ftnlen)45, (ftnlen)45, (ftnlen)50);
    }

/*     Now we must validate the ordered symbol table.  Create */
/*     an array containing the expected values in the table. */

    start = 1;
    for (i__ = 1; i__ <= 100; ++i__) {
	i__1 = i__;
	for (j = 1; j <= i__1; ++j) {

/*           Fill in the values for the Ith symbol in the */
/*           opposite order from that in which they were inserted */
/*           into the symbol table. */

	    to = start + i__ - j;
	    s_copy(xvals + ((i__2 = to - 1) < 10000 && 0 <= i__2 ? i__2 : 
		    s_rnge("xvals", i__2, "f_symtbc__", (ftnlen)1427)) * 50, 
		    ivs + ((i__3 = to - 1) < 10000 && 0 <= i__3 ? i__3 : 
		    s_rnge("ivs", i__3, "f_symtbc__", (ftnlen)1427)) * 50, (
		    ftnlen)50, (ftnlen)50);
	}
	start += i__;
    }

/*     Check the symbol table values against the value array. */

    chckac_("SYVALS", syvals + 300, "=", xvals, &c__100, ok, (ftnlen)6, (
	    ftnlen)50, (ftnlen)1, (ftnlen)50);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYDIMC test:  Find dimensions of symbols in symbol table with ar"
	    "ray-valued symbols.", (ftnlen)83);
    scardc_(&c__0, synams, (ftnlen)45);
    scardi_(&c__0, syptrs);
    scardc_(&c__0, syvals, (ftnlen)50);
    clearc_(&c__10000, xvals, (ftnlen)50);
    for (i__ = 1; i__ <= 100; ++i__) {

/*        Create the symbol name. */

	t_ithsym__(&i__, &c__100, name__, (ftnlen)45);
	s_copy(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbc__", (ftnlen)1461)) * 45, name__, (
		ftnlen)45, (ftnlen)45);
	i__1 = i__;
	for (j = 1; j <= i__1; ++j) {
	    s_copy(val, ivs + ((i__2 = to - 1) < 10000 && 0 <= i__2 ? i__2 : 
		    s_rnge("ivs", i__2, "f_symtbc__", (ftnlen)1465)) * 50, (
		    ftnlen)50, (ftnlen)50);
	    syenqc_(name__, val, synams, syptrs, syvals, (ftnlen)45, (ftnlen)
		    50, (ftnlen)45, (ftnlen)50);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	}
    }
    for (i__ = 1; i__ <= 100; ++i__) {
	nvals = sydimc_(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 :
		 s_rnge("xnames", i__1, "f_symtbc__", (ftnlen)1476)) * 45, 
		synams, syptrs, syvals, (ftnlen)45, (ftnlen)45, (ftnlen)50);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	s_copy(title, "Dimension of symbol #", (ftnlen)500, (ftnlen)21);
	repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)500);
	chcksi_(title, &nvals, "=", &i__, &c__0, ok, (ftnlen)500, (ftnlen)1);
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("SYPOPC test:  Pop values from symbol table with array-valued sym"
	    "bols.", (ftnlen)69);

/*     Re-create the default array-valued symbol table. */

    scardc_(&c__0, synams, (ftnlen)45);
    scardi_(&c__0, syptrs);
    scardc_(&c__0, syvals, (ftnlen)50);
    to = 1;
    for (i__ = 1; i__ <= 100; ++i__) {

/*        Create the symbol name. */

	t_ithsym__(&i__, &c__100, name__, (ftnlen)45);

/*        Set the values of the Ith symbol. */

	i__1 = i__;
	for (j = 1; j <= i__1; ++j) {
	    s_copy(cvals + ((i__2 = j - 1) < 10000 && 0 <= i__2 ? i__2 : 
		    s_rnge("cvals", i__2, "f_symtbc__", (ftnlen)1513)) * 50, 
		    ivs + ((i__3 = to - 1) < 10000 && 0 <= i__3 ? i__3 : 
		    s_rnge("ivs", i__3, "f_symtbc__", (ftnlen)1513)) * 50, (
		    ftnlen)50, (ftnlen)50);
	    ++to;
	}

/*        Insert the Ith symbol. */

	syputc_(name__, cvals, &i__, synams, syptrs, syvals, (ftnlen)45, (
		ftnlen)50, (ftnlen)45, (ftnlen)50);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Now test SYPOPC. */

    to = 1;
    for (i__ = 1; i__ <= 100; ++i__) {

/*        Create the symbol name. */

	t_ithsym__(&i__, &c__100, name__, (ftnlen)45);
	xptrs[(i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge("xptrs", 
		i__1, "f_symtbc__", (ftnlen)1538)] = i__;
	i__1 = i__;
	for (j = 1; j <= i__1; ++j) {

/*           Set the expected value. */

	    s_copy(xvals + ((i__2 = to - 1) < 10000 && 0 <= i__2 ? i__2 : 
		    s_rnge("xvals", i__2, "f_symtbc__", (ftnlen)1544)) * 50, 
		    ivs + ((i__3 = to - 1) < 10000 && 0 <= i__3 ? i__3 : 
		    s_rnge("ivs", i__3, "f_symtbc__", (ftnlen)1544)) * 50, (
		    ftnlen)50, (ftnlen)50);
	    sypopc_(name__, synams, syptrs, syvals, val, &found, (ftnlen)45, (
		    ftnlen)45, (ftnlen)50, (ftnlen)50);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    s_copy(title, "Was value # of symbol name # found?", (ftnlen)500, 
		    (ftnlen)35);
	    repmi_(title, "#", &j, title, (ftnlen)500, (ftnlen)1, (ftnlen)500)
		    ;
	    repmc_(title, "#", name__, title, (ftnlen)500, (ftnlen)1, (ftnlen)
		    45, (ftnlen)500);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    chcksl_(title, &found, &c_true, ok, (ftnlen)500);
	    if (found) {
		s_copy(title, "Symbol #: popped value at index #", (ftnlen)
			500, (ftnlen)33);
		repmc_(title, "#", name__, title, (ftnlen)500, (ftnlen)1, (
			ftnlen)45, (ftnlen)500);
		repmi_(title, "#", &j, title, (ftnlen)500, (ftnlen)1, (ftnlen)
			500);
		chcksc_(title, val, "=", xvals + ((i__2 = to - 1) < 10000 && 
			0 <= i__2 ? i__2 : s_rnge("xvals", i__2, "f_symtbc__",
			 (ftnlen)1562)) * 50, ok, (ftnlen)500, (ftnlen)50, (
			ftnlen)1, (ftnlen)50);
	    }
	    ++to;
	}

/*        Try to pop a value from the now empty symbol. */

	sypopc_(name__, synams, syptrs, syvals, val, &found, (ftnlen)45, (
		ftnlen)45, (ftnlen)50, (ftnlen)50);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	s_copy(title, "Was element popped from symbol #?", (ftnlen)500, (
		ftnlen)33);
	repmc_(title, "#", name__, title, (ftnlen)500, (ftnlen)1, (ftnlen)45, 
		(ftnlen)500);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(title, &found, &c_false, ok, (ftnlen)500);
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("SYTRNC test:  Transpose values from symbol table with array-valu"
	    "ed symbols.", (ftnlen)75);

/*     We'll create a small version of our array-valued symbol table. */
/*     Since we want to try all possible transpositions, there would */
/*     be an excessive number of calls to SYTRNC if we used the full */
/*     set of MAXTAB symbols. */

/*     Create the symbol table now. */

    scardc_(&c__0, synams, (ftnlen)45);
    scardi_(&c__0, syptrs);
    scardc_(&c__0, syvals, (ftnlen)50);
    tabsiz = 5;
    to = 1;
    i__1 = tabsiz;
    for (i__ = 1; i__ <= i__1; ++i__) {

/*        Create the symbol name. */

	t_ithsym__(&i__, &tabsiz, name__, (ftnlen)45);

/*        Set the values of the Ith symbol. */

	start = to;
	i__2 = i__;
	for (j = 1; j <= i__2; ++j) {
	    s_copy(xvals + ((i__3 = to - 1) < 10000 && 0 <= i__3 ? i__3 : 
		    s_rnge("xvals", i__3, "f_symtbc__", (ftnlen)1621)) * 50, 
		    ivs + ((i__4 = to - 1) < 10000 && 0 <= i__4 ? i__4 : 
		    s_rnge("ivs", i__4, "f_symtbc__", (ftnlen)1621)) * 50, (
		    ftnlen)50, (ftnlen)50);
	    ++to;
	}

/*        Insert the Ith symbol. */

	syputc_(name__, xvals + ((i__2 = start - 1) < 10000 && 0 <= i__2 ? 
		i__2 : s_rnge("xvals", i__2, "f_symtbc__", (ftnlen)1629)) * 
		50, &i__, synams, syptrs, syvals, (ftnlen)45, (ftnlen)50, (
		ftnlen)45, (ftnlen)50);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Now try the transpositions. */

    start = 1;
    i__1 = tabsiz;
    for (i__ = 1; i__ <= i__1; ++i__) {
	size = i__;

/*        Try every possible transposition of the elements of the Ith */
/*        symbol, including those where the indices of the transposed */
/*        elements are not distinct. */

	t_ithsym__(&i__, &tabsiz, name__, (ftnlen)45);

/*        Transpose elements J and K of the Ith symbol, for all */
/*        applicable J, K. */

	i__2 = size;
	for (j = 1; j <= i__2; ++j) {
	    i__3 = size;
	    for (k = 1; k <= i__3; ++k) {
		sytrnc_(name__, &j, &k, synams, syptrs, syvals, (ftnlen)45, (
			ftnlen)45, (ftnlen)50);
		chckxc_(&c_false, " ", ok, (ftnlen)1);

/*              Fetch the values of the modified symbol. */

		sygetc_(name__, synams, syptrs, syvals, &nvals, cvals, &found,
			 (ftnlen)45, (ftnlen)45, (ftnlen)50, (ftnlen)50);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		chcksl_(title, &found, &c_true, ok, (ftnlen)500);
		if (found) {

/*                 If CVALS reflects the correct transposition, */
/*                 then we can swap elements J and K of CVALS */
/*                 to obtain the original symbol's values. */

		    if (j != k) {
			swapc_(cvals + ((i__4 = j - 1) < 10000 && 0 <= i__4 ? 
				i__4 : s_rnge("cvals", i__4, "f_symtbc__", (
				ftnlen)1676)) * 50, cvals + ((i__5 = k - 1) < 
				10000 && 0 <= i__5 ? i__5 : s_rnge("cvals", 
				i__5, "f_symtbc__", (ftnlen)1676)) * 50, (
				ftnlen)50, (ftnlen)50);
		    }
		    s_copy(title, "Values of symbol #:  J = #; K = #", (
			    ftnlen)500, (ftnlen)33);
		    repmc_(title, "#", name__, title, (ftnlen)500, (ftnlen)1, 
			    (ftnlen)45, (ftnlen)500);
		    repmi_(title, "#", &j, title, (ftnlen)500, (ftnlen)1, (
			    ftnlen)500);
		    repmi_(title, "#", &k, title, (ftnlen)500, (ftnlen)1, (
			    ftnlen)500);
		    chckac_(title, cvals, "=", xvals + ((i__4 = start - 1) < 
			    10000 && 0 <= i__4 ? i__4 : s_rnge("xvals", i__4, 
			    "f_symtbc__", (ftnlen)1684)) * 50, &i__, ok, (
			    ftnlen)500, (ftnlen)50, (ftnlen)1, (ftnlen)50);
		}

/*              Undo the transposition in the symbol table. */

		sytrnc_(name__, &j, &k, synams, syptrs, syvals, (ftnlen)45, (
			ftnlen)45, (ftnlen)50);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
	    }
	}

/*        Set the start index for the next symbol. */

	start += i__;
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("SYSELC test:  Extract slice of values from symbol table with arr"
	    "ay-valued symbols.", (ftnlen)82);

/*     This approach used in this test case closely parallels that */
/*     of the SYTRNC test case above. */

/*     We'll create a small version of our array-valued symbol table. */
/*     Since we want to try all possible slices, there would */
/*     be an excessive number of calls to SYTRNC if we used the full */
/*     set of MAXTAB symbols. */

/*     Create the symbol table now. */

    scardc_(&c__0, synams, (ftnlen)45);
    scardi_(&c__0, syptrs);
    scardc_(&c__0, syvals, (ftnlen)50);
    clearc_(&c__10000, xvals, (ftnlen)50);
    tabsiz = 5;
    to = 1;
    i__1 = tabsiz;
    for (i__ = 1; i__ <= i__1; ++i__) {

/*        Create the symbol name. */

	t_ithsym__(&i__, &tabsiz, name__, (ftnlen)45);

/*        Set the values of the Ith symbol. */

	start = to;
	i__2 = i__;
	for (j = 1; j <= i__2; ++j) {
	    s_copy(xvals + ((i__3 = to - 1) < 10000 && 0 <= i__3 ? i__3 : 
		    s_rnge("xvals", i__3, "f_symtbc__", (ftnlen)1749)) * 50, 
		    ivs + ((i__4 = to - 1) < 10000 && 0 <= i__4 ? i__4 : 
		    s_rnge("ivs", i__4, "f_symtbc__", (ftnlen)1749)) * 50, (
		    ftnlen)50, (ftnlen)50);
	    ++to;
	}

/*        Insert the Ith symbol. */

	syputc_(name__, xvals + ((i__2 = start - 1) < 10000 && 0 <= i__2 ? 
		i__2 : s_rnge("xvals", i__2, "f_symtbc__", (ftnlen)1757)) * 
		50, &i__, synams, syptrs, syvals, (ftnlen)45, (ftnlen)50, (
		ftnlen)45, (ftnlen)50);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Now try the slice extractions. */

    start = 1;
    i__1 = tabsiz;
    for (i__ = 1; i__ <= i__1; ++i__) {
	size = i__;

/*        Try every possible slice of the elements of the Ith */
/*        symbol, including those where the endpoint indices of the */
/*        slice are not distinct. */

	t_ithsym__(&i__, &tabsiz, name__, (ftnlen)45);

/*        Extrace the slice ranging from elements J to K of the Ith */
/*        symbol, for all applicable J, K. */

	i__2 = size;
	for (j = 1; j <= i__2; ++j) {
	    i__3 = size;
	    for (k = 1; k <= i__3; ++k) {

/*              Fetch the slice from J to K.  We expect to find a */
/*              result only if K >= J. */

		syselc_(name__, &j, &k, synams, syptrs, syvals, cvals, &found,
			 (ftnlen)45, (ftnlen)45, (ftnlen)50, (ftnlen)50);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		if (k >= j) {
		    chcksl_(title, &found, &c_true, ok, (ftnlen)500);
		} else {
		    chcksl_(title, &found, &c_false, ok, (ftnlen)500);
		}
		if (found) {
		    s_copy(title, "Slice #(#:#)", (ftnlen)500, (ftnlen)12);
		    repmc_(title, "#", name__, title, (ftnlen)500, (ftnlen)1, 
			    (ftnlen)45, (ftnlen)500);
		    repmi_(title, "#", &j, title, (ftnlen)500, (ftnlen)1, (
			    ftnlen)500);
		    repmi_(title, "#", &k, title, (ftnlen)500, (ftnlen)1, (
			    ftnlen)500);
		    i__5 = k - j + 1;
		    chckac_(title, cvals, "=", xvals + ((i__4 = start + j - 2)
			     < 10000 && 0 <= i__4 ? i__4 : s_rnge("xvals", 
			    i__4, "f_symtbc__", (ftnlen)1805)) * 50, &i__5, 
			    ok, (ftnlen)500, (ftnlen)50, (ftnlen)1, (ftnlen)
			    50);
		}
	    }
	}

/*        Set the start index for the next symbol. */

	start += i__;
    }

/*     Now for some error handling tests. */


/*     SYDELC:  No errors are detected by this routine. */

/*     SYDIMC:  No errors are detected by this routine. */


/*     SYDUPC: */

/* --- Case: ------------------------------------------------------ */

    tcase_("SYDUPC:  symbol name not present", (ftnlen)32);
    sydupc_("NOSYMBOL", "NOSYMBOL2", synams, syptrs, syvals, (ftnlen)8, (
	    ftnlen)9, (ftnlen)45, (ftnlen)50);
    chckxc_(&c_true, "SPICE(NOSUCHSYMBOL)", ok, (ftnlen)19);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYDUPC:  name table overflow", (ftnlen)28);

/*     We'll create a small symbol table so we can test the handling of */
/*     overflow conditions. */

    tabsiz = 5;
    ssizec_(&tabsiz, synams, (ftnlen)45);
    i__1 = tabsiz << 1;
    ssizei_(&i__1, syptrs);
    i__1 = tabsiz << 1;
    ssizec_(&i__1, syvals, (ftnlen)50);
    i__1 = tabsiz;
    for (i__ = 1; i__ <= i__1; ++i__) {
	t_ithsym__(&i__, &tabsiz, name__, (ftnlen)45);
	sysetc_(name__, ivs + ((i__2 = i__ - 1) < 10000 && 0 <= i__2 ? i__2 : 
		s_rnge("ivs", i__2, "f_symtbc__", (ftnlen)1864)) * 50, synams,
		 syptrs, syvals, (ftnlen)45, (ftnlen)50, (ftnlen)45, (ftnlen)
		50);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    sydupc_(name__, "NEWNAME", synams, syptrs, syvals, (ftnlen)45, (ftnlen)7, 
	    (ftnlen)45, (ftnlen)50);
    chckxc_(&c_true, "SPICE(NAMETABLEFULL)", ok, (ftnlen)20);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYDUPC:  pointer table overflow", (ftnlen)31);
    i__1 = tabsiz + 1;
    ssizec_(&i__1, synams, (ftnlen)45);
    ssizei_(&tabsiz, syptrs);
    i__1 = tabsiz + 2;
    ssizec_(&i__1, syvals, (ftnlen)50);
    i__1 = tabsiz;
    for (i__ = 1; i__ <= i__1; ++i__) {
	t_ithsym__(&i__, &tabsiz, name__, (ftnlen)45);
	sysetc_(name__, ivs + ((i__2 = i__ - 1) < 10000 && 0 <= i__2 ? i__2 : 
		s_rnge("ivs", i__2, "f_symtbc__", (ftnlen)1887)) * 50, synams,
		 syptrs, syvals, (ftnlen)45, (ftnlen)50, (ftnlen)45, (ftnlen)
		50);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    sydupc_(name__, "NEWNAME", synams, syptrs, syvals, (ftnlen)45, (ftnlen)7, 
	    (ftnlen)45, (ftnlen)50);
    chckxc_(&c_true, "SPICE(POINTERTABLEFULL)", ok, (ftnlen)23);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYDUPC:  value table overflow", (ftnlen)29);
    i__1 = tabsiz + 1;
    ssizec_(&i__1, synams, (ftnlen)45);
    i__1 = tabsiz + 1;
    ssizei_(&i__1, syptrs);
    ssizec_(&tabsiz, syvals, (ftnlen)50);
    i__1 = tabsiz;
    for (i__ = 1; i__ <= i__1; ++i__) {
	t_ithsym__(&i__, &tabsiz, name__, (ftnlen)45);
	sysetc_(name__, ivs + ((i__2 = i__ - 1) < 10000 && 0 <= i__2 ? i__2 : 
		s_rnge("ivs", i__2, "f_symtbc__", (ftnlen)1911)) * 50, synams,
		 syptrs, syvals, (ftnlen)45, (ftnlen)50, (ftnlen)45, (ftnlen)
		50);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    sydupc_(name__, "NEWNAME", synams, syptrs, syvals, (ftnlen)45, (ftnlen)7, 
	    (ftnlen)45, (ftnlen)50);
    chckxc_(&c_true, "SPICE(VALUETABLEFULL)", ok, (ftnlen)21);


/*     SYENQC: */

/* --- Case: ------------------------------------------------------ */

    tcase_("SYENQC:  value table overflow", (ftnlen)29);
    tabsiz = 5;
    ssizec_(&tabsiz, synams, (ftnlen)45);
    ssizei_(&tabsiz, syptrs);
    ssizec_(&tabsiz, syvals, (ftnlen)50);
    i__1 = tabsiz;
    for (i__ = 1; i__ <= i__1; ++i__) {
	t_ithsym__(&i__, &tabsiz, name__, (ftnlen)45);
	sysetc_(name__, ivs + ((i__2 = i__ - 1) < 10000 && 0 <= i__2 ? i__2 : 
		s_rnge("ivs", i__2, "f_symtbc__", (ftnlen)1940)) * 50, synams,
		 syptrs, syvals, (ftnlen)45, (ftnlen)50, (ftnlen)45, (ftnlen)
		50);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Enqueue a value onto the last symbol. */

    syenqc_(name__, nivs, synams, syptrs, syvals, (ftnlen)45, (ftnlen)50, (
	    ftnlen)45, (ftnlen)50);
    chckxc_(&c_true, "SPICE(VALUETABLEFULL)", ok, (ftnlen)21);



/*     SYFETC:  No errors are detected by this routine. */

/*     SYGETC:  No errors are detected by this routine. */

/*     SYNTHC:  No errors are detected by this routine. */

/*     SYORDC:  No errors are detected by this routine. */

/*     SYPOPC:  No errors are detected by this routine. */



/*     SYPSHC: */

/* --- Case: ------------------------------------------------------ */


    tcase_("SYPSHC:  value table overflow", (ftnlen)29);
    tabsiz = 5;
    ssizec_(&tabsiz, synams, (ftnlen)45);
    ssizei_(&tabsiz, syptrs);
    ssizec_(&tabsiz, syvals, (ftnlen)50);
    i__1 = tabsiz;
    for (i__ = 1; i__ <= i__1; ++i__) {
	t_ithsym__(&i__, &tabsiz, name__, (ftnlen)45);
	sysetc_(name__, ivs + ((i__2 = i__ - 1) < 10000 && 0 <= i__2 ? i__2 : 
		s_rnge("ivs", i__2, "f_symtbc__", (ftnlen)1986)) * 50, synams,
		 syptrs, syvals, (ftnlen)45, (ftnlen)50, (ftnlen)45, (ftnlen)
		50);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Push a value onto the last symbol. */

    sypshc_(name__, nivs + ((i__1 = i__ - 1) < 10000 && 0 <= i__1 ? i__1 : 
	    s_rnge("nivs", i__1, "f_symtbc__", (ftnlen)1994)) * 50, synams, 
	    syptrs, syvals, (ftnlen)45, (ftnlen)50, (ftnlen)45, (ftnlen)50);
    chckxc_(&c_true, "SPICE(VALUETABLEFULL)", ok, (ftnlen)21);

/*     SYPUTC: */


/* --- Case: ------------------------------------------------------ */

    tcase_("SYPUTC:  name table overflow", (ftnlen)28);

/*     We'll create a small symbol table so we can test the handling of */
/*     overflow conditions. */

    tabsiz = 5;
    ssizec_(&tabsiz, synams, (ftnlen)45);
    i__1 = tabsiz << 1;
    ssizei_(&i__1, syptrs);
    i__1 = tabsiz << 1;
    ssizec_(&i__1, syvals, (ftnlen)50);
    i__1 = tabsiz;
    for (i__ = 1; i__ <= i__1; ++i__) {
	t_ithsym__(&i__, &tabsiz, name__, (ftnlen)45);
	sysetc_(name__, ivs + ((i__2 = i__ - 1) < 10000 && 0 <= i__2 ? i__2 : 
		s_rnge("ivs", i__2, "f_symtbc__", (ftnlen)2024)) * 50, synams,
		 syptrs, syvals, (ftnlen)45, (ftnlen)50, (ftnlen)45, (ftnlen)
		50);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    syputc_("NEWNAME", ivs + ((i__1 = i__ - 1) < 10000 && 0 <= i__1 ? i__1 : 
	    s_rnge("ivs", i__1, "f_symtbc__", (ftnlen)2030)) * 50, &c__1, 
	    synams, syptrs, syvals, (ftnlen)7, (ftnlen)50, (ftnlen)45, (
	    ftnlen)50);
    chckxc_(&c_true, "SPICE(NAMETABLEFULL)", ok, (ftnlen)20);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYPUTC:  pointer table overflow", (ftnlen)31);
    i__1 = tabsiz + 1;
    ssizec_(&i__1, synams, (ftnlen)45);
    ssizei_(&tabsiz, syptrs);
    i__1 = tabsiz + 2;
    ssizec_(&i__1, syvals, (ftnlen)50);
    i__1 = tabsiz;
    for (i__ = 1; i__ <= i__1; ++i__) {
	t_ithsym__(&i__, &tabsiz, name__, (ftnlen)45);
	sysetc_(name__, ivs + ((i__2 = i__ - 1) < 10000 && 0 <= i__2 ? i__2 : 
		s_rnge("ivs", i__2, "f_symtbc__", (ftnlen)2048)) * 50, synams,
		 syptrs, syvals, (ftnlen)45, (ftnlen)50, (ftnlen)45, (ftnlen)
		50);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    syputc_("NEWNAME", ivs + ((i__1 = i__ - 1) < 10000 && 0 <= i__1 ? i__1 : 
	    s_rnge("ivs", i__1, "f_symtbc__", (ftnlen)2053)) * 50, &c__1, 
	    synams, syptrs, syvals, (ftnlen)7, (ftnlen)50, (ftnlen)45, (
	    ftnlen)50);
    chckxc_(&c_true, "SPICE(POINTERTABLEFULL)", ok, (ftnlen)23);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYPUTC:  value table overflow", (ftnlen)29);
    i__1 = tabsiz + 1;
    ssizec_(&i__1, synams, (ftnlen)45);
    i__1 = tabsiz + 1;
    ssizei_(&i__1, syptrs);
    ssizec_(&tabsiz, syvals, (ftnlen)50);
    i__1 = tabsiz;
    for (i__ = 1; i__ <= i__1; ++i__) {
	t_ithsym__(&i__, &tabsiz, name__, (ftnlen)45);
	sysetc_(name__, ivs + ((i__2 = i__ - 1) < 10000 && 0 <= i__2 ? i__2 : 
		s_rnge("ivs", i__2, "f_symtbc__", (ftnlen)2072)) * 50, synams,
		 syptrs, syvals, (ftnlen)45, (ftnlen)50, (ftnlen)45, (ftnlen)
		50);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    syputc_("NEWNAME", ivs + ((i__1 = i__ - 1) < 10000 && 0 <= i__1 ? i__1 : 
	    s_rnge("ivs", i__1, "f_symtbc__", (ftnlen)2077)) * 50, &c__1, 
	    synams, syptrs, syvals, (ftnlen)7, (ftnlen)50, (ftnlen)45, (
	    ftnlen)50);
    chckxc_(&c_true, "SPICE(VALUETABLEFULL)", ok, (ftnlen)21);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYPUTC: invalid value count", (ftnlen)27);
    i__1 = tabsiz + 1;
    ssizec_(&i__1, synams, (ftnlen)45);
    i__1 = tabsiz + 1;
    ssizei_(&i__1, syptrs);
    i__1 = tabsiz + 1;
    ssizec_(&i__1, syvals, (ftnlen)50);
    i__1 = tabsiz;
    for (i__ = 1; i__ <= i__1; ++i__) {
	t_ithsym__(&i__, &tabsiz, name__, (ftnlen)45);
	sysetc_(name__, ivs + ((i__2 = i__ - 1) < 10000 && 0 <= i__2 ? i__2 : 
		s_rnge("ivs", i__2, "f_symtbc__", (ftnlen)2098)) * 50, synams,
		 syptrs, syvals, (ftnlen)45, (ftnlen)50, (ftnlen)45, (ftnlen)
		50);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    syputc_("NEWNAME", ivs + ((i__1 = i__ - 1) < 10000 && 0 <= i__1 ? i__1 : 
	    s_rnge("ivs", i__1, "f_symtbc__", (ftnlen)2103)) * 50, &c_n1, 
	    synams, syptrs, syvals, (ftnlen)7, (ftnlen)50, (ftnlen)45, (
	    ftnlen)50);
    chckxc_(&c_true, "SPICE(INVALIDARGUMENT)", ok, (ftnlen)22);

/*     SYRENC: */


/* --- Case: ------------------------------------------------------ */

    tcase_("SYRENC:  rename non-existent symbol", (ftnlen)35);
    syrenc_("NONNAME", "NEWNAME", synams, syptrs, syvals, (ftnlen)7, (ftnlen)
	    7, (ftnlen)45, (ftnlen)50);
    chckxc_(&c_true, "SPICE(NOSUCHSYMBOL)", ok, (ftnlen)19);


/*     SYSELC:  No errors are detected by this routine. */


/*     SYSETC: */

/* --- Case: ------------------------------------------------------ */

    tcase_("SYSETC:  name table overflow", (ftnlen)28);

/*     We'll create a small symbol table so we can test the handling of */
/*     overflow conditions. */

    tabsiz = 5;
    ssizec_(&tabsiz, synams, (ftnlen)45);
    i__1 = tabsiz << 1;
    ssizei_(&i__1, syptrs);
    i__1 = tabsiz << 1;
    ssizec_(&i__1, syvals, (ftnlen)50);
    i__1 = tabsiz;
    for (i__ = 1; i__ <= i__1; ++i__) {
	t_ithsym__(&i__, &tabsiz, name__, (ftnlen)45);
	sysetc_(name__, ivs + ((i__2 = i__ - 1) < 10000 && 0 <= i__2 ? i__2 : 
		s_rnge("ivs", i__2, "f_symtbc__", (ftnlen)2148)) * 50, synams,
		 syptrs, syvals, (ftnlen)45, (ftnlen)50, (ftnlen)45, (ftnlen)
		50);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    sysetc_("NEWNAME", ivs + ((i__1 = i__ - 1) < 10000 && 0 <= i__1 ? i__1 : 
	    s_rnge("ivs", i__1, "f_symtbc__", (ftnlen)2154)) * 50, synams, 
	    syptrs, syvals, (ftnlen)7, (ftnlen)50, (ftnlen)45, (ftnlen)50);
    chckxc_(&c_true, "SPICE(NAMETABLEFULL)", ok, (ftnlen)20);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYSETC:  pointer table overflow", (ftnlen)31);
    i__1 = tabsiz + 1;
    ssizec_(&i__1, synams, (ftnlen)45);
    ssizei_(&tabsiz, syptrs);
    i__1 = tabsiz + 2;
    ssizec_(&i__1, syvals, (ftnlen)50);
    i__1 = tabsiz;
    for (i__ = 1; i__ <= i__1; ++i__) {
	t_ithsym__(&i__, &tabsiz, name__, (ftnlen)45);
	sysetc_(name__, ivs + ((i__2 = i__ - 1) < 10000 && 0 <= i__2 ? i__2 : 
		s_rnge("ivs", i__2, "f_symtbc__", (ftnlen)2172)) * 50, synams,
		 syptrs, syvals, (ftnlen)45, (ftnlen)50, (ftnlen)45, (ftnlen)
		50);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    sysetc_("NEWNAME", ivs + ((i__1 = i__ - 1) < 10000 && 0 <= i__1 ? i__1 : 
	    s_rnge("ivs", i__1, "f_symtbc__", (ftnlen)2177)) * 50, synams, 
	    syptrs, syvals, (ftnlen)7, (ftnlen)50, (ftnlen)45, (ftnlen)50);
    chckxc_(&c_true, "SPICE(POINTERTABLEFULL)", ok, (ftnlen)23);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYSETC:  value table overflow", (ftnlen)29);
    i__1 = tabsiz + 1;
    ssizec_(&i__1, synams, (ftnlen)45);
    i__1 = tabsiz + 1;
    ssizei_(&i__1, syptrs);
    ssizec_(&tabsiz, syvals, (ftnlen)50);
    i__1 = tabsiz;
    for (i__ = 1; i__ <= i__1; ++i__) {
	t_ithsym__(&i__, &tabsiz, name__, (ftnlen)45);
	sysetc_(name__, ivs + ((i__2 = i__ - 1) < 10000 && 0 <= i__2 ? i__2 : 
		s_rnge("ivs", i__2, "f_symtbc__", (ftnlen)2196)) * 50, synams,
		 syptrs, syvals, (ftnlen)45, (ftnlen)50, (ftnlen)45, (ftnlen)
		50);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    sysetc_("NEWNAME", ivs + ((i__1 = i__ - 1) < 10000 && 0 <= i__1 ? i__1 : 
	    s_rnge("ivs", i__1, "f_symtbc__", (ftnlen)2201)) * 50, synams, 
	    syptrs, syvals, (ftnlen)7, (ftnlen)50, (ftnlen)45, (ftnlen)50);
    chckxc_(&c_true, "SPICE(VALUETABLEFULL)", ok, (ftnlen)21);
/*     SYTRNC: */

/* --- Case: ------------------------------------------------------ */

    tcase_("SYTRNC:  first index < 1", (ftnlen)24);
    ssizec_(&tabsiz, synams, (ftnlen)45);
    ssizei_(&tabsiz, syptrs);
    ssizec_(&tabsiz, syvals, (ftnlen)50);
    i__1 = tabsiz;
    for (i__ = 1; i__ <= i__1; ++i__) {
	t_ithsym__(&i__, &tabsiz, name__, (ftnlen)45);
	sysetc_(name__, ivs + ((i__2 = i__ - 1) < 10000 && 0 <= i__2 ? i__2 : 
		s_rnge("ivs", i__2, "f_symtbc__", (ftnlen)2222)) * 50, synams,
		 syptrs, syvals, (ftnlen)45, (ftnlen)50, (ftnlen)45, (ftnlen)
		50);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	s_copy(xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 : s_rnge(
		"xnames", i__2, "f_symtbc__", (ftnlen)2225)) * 45, name__, (
		ftnlen)45, (ftnlen)45);
	xptrs[(i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 : s_rnge("xptrs", 
		i__2, "f_symtbc__", (ftnlen)2226)] = 1;
	s_copy(xvals + ((i__2 = i__ - 1) < 10000 && 0 <= i__2 ? i__2 : s_rnge(
		"xvals", i__2, "f_symtbc__", (ftnlen)2227)) * 50, ivs + ((
		i__3 = i__ - 1) < 10000 && 0 <= i__3 ? i__3 : s_rnge("ivs", 
		i__3, "f_symtbc__", (ftnlen)2227)) * 50, (ftnlen)50, (ftnlen)
		50);
    }
    sytrnc_(name__, &c_n1, &c__2, synams, syptrs, syvals, (ftnlen)45, (ftnlen)
	    45, (ftnlen)50);
    chckxc_(&c_true, "SPICE(INVALIDINDEX)", ok, (ftnlen)19);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYTRNC:  first index > second index", (ftnlen)35);
    sytrnc_(name__, &c__2, &c__1, synams, syptrs, syvals, (ftnlen)45, (ftnlen)
	    45, (ftnlen)50);
    chckxc_(&c_true, "SPICE(INVALIDINDEX)", ok, (ftnlen)19);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYTRNC:  second index > symbol size", (ftnlen)35);
    i__1 = tabsiz + 1;
    sytrnc_(name__, &c__1, &i__1, synams, syptrs, syvals, (ftnlen)45, (ftnlen)
	    45, (ftnlen)50);
    chckxc_(&c_true, "SPICE(INVALIDINDEX)", ok, (ftnlen)19);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYTRNC:  non-error case: attempt transposition of values of non-"
	    "existent symbol.", (ftnlen)80);
    sytrnc_("NONAME", &c__1, &c__1, synams, syptrs, syvals, (ftnlen)6, (
	    ftnlen)45, (ftnlen)50);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Make sure the symbol table wasn't touched. */

/*     Check the structure of the cells we've populated. */

/*     The symbol name cell first: */

    i__1 = cardc_(synams, (ftnlen)45);
    chcksi_("Card(SYNAMS)", &i__1, "=", &tabsiz, &c__0, ok, (ftnlen)12, (
	    ftnlen)1);
    i__1 = cardc_(synams, (ftnlen)45);
    for (i__ = 1; i__ <= i__1; ++i__) {
	s_copy(title, "Name #", (ftnlen)500, (ftnlen)6);
	repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)500);
	chcksc_(title, synams + ((i__2 = i__ + 5) < 106 && 0 <= i__2 ? i__2 : 
		s_rnge("synams", i__2, "f_symtbc__", (ftnlen)2277)) * 45, 
		"=", xnames + ((i__3 = i__ - 1) < 100 && 0 <= i__3 ? i__3 : 
		s_rnge("xnames", i__3, "f_symtbc__", (ftnlen)2277)) * 45, ok, 
		(ftnlen)500, (ftnlen)45, (ftnlen)1, (ftnlen)45);
    }

/*     Then the "pointer" cell.  The pointers are actually element */
/*     counts. */

    i__1 = cardi_(syptrs);
    chcksi_("Card(SYPTRS)", &i__1, "=", &tabsiz, &c__0, ok, (ftnlen)12, (
	    ftnlen)1);
    chckai_("SYPTRS", &syptrs[6], "=", xptrs, &tabsiz, ok, (ftnlen)6, (ftnlen)
	    1);

/*     Then the value cell. */

    i__1 = cardc_(syvals, (ftnlen)50);
    chcksi_("Card(SYVALS)", &i__1, "=", &tabsiz, &c__0, ok, (ftnlen)12, (
	    ftnlen)1);
    chckac_("SYVALS", syvals + 300, "=", xvals, &tabsiz, ok, (ftnlen)6, (
	    ftnlen)50, (ftnlen)1, (ftnlen)50);

/*     That's all, folks! */


/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_symtbc__ */

