/* f_symtbi.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__100 = 100;
static logical c_false = FALSE_;
static integer c__10000 = 10000;
static integer c__0 = 0;
static integer c__1 = 1;
static logical c_true = TRUE_;
static integer c__101 = 101;
static integer c_n1 = -1;
static integer c__2 = 2;

/* $Procedure F_SYMTBI ( Test SPICELIB integer symbol table routines ) */
/* Subroutine */ int f_symtbi__(logical *ok)
{
    /* System generated locals */
    integer i__1, i__2, i__3, i__4, i__5;

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer);
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    static char name__[45];
    static integer size, xval;
    extern /* Subroutine */ int t_ithsym__(integer *, integer *, char *, 
	    ftnlen);
    static integer i__, j, k;
    extern integer cardc_(char *, ftnlen), cardi_(integer *);
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    static integer xcard;
    extern /* Subroutine */ int repmc_(char *, char *, char *, char *, ftnlen,
	     ftnlen, ftnlen, ftnlen);
    static logical found;
    extern /* Subroutine */ int repmi_(char *, char *, integer *, char *, 
	    ftnlen, ftnlen, ftnlen);
    static integer ivals[10000];
    static char title[500];
    static integer nvals;
    extern /* Subroutine */ int swapi_(integer *, integer *), topen_(char *, 
	    ftnlen);
    static integer start, xvals[10000];
    extern /* Subroutine */ int t_success__(logical *);
    static integer xptrs[100];
    extern /* Subroutine */ int chckai_(char *, integer *, char *, integer *, 
	    integer *, logical *, ftnlen, ftnlen);
    static integer ub;
    extern /* Subroutine */ int chcksc_(char *, char *, char *, char *, 
	    logical *, ftnlen, ftnlen, ftnlen, ftnlen), scardc_(integer *, 
	    char *, ftnlen), cleari_(integer *, integer *);
    static integer to;
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     chcksi_(char *, integer *, char *, integer *, integer *, logical 
	    *, ftnlen, ftnlen), scardi_(integer *, integer *), chcksl_(char *,
	     logical *, logical *, logical *, ftnlen), replch_(char *, char *,
	     char *, char *, ftnlen, ftnlen, ftnlen, ftnlen);
    static char newnam[45];
    extern /* Subroutine */ int sydeli_(char *, char *, integer *, integer *, 
	    ftnlen, ftnlen);
    static char xnames[45*100];
    static integer tabsiz;
    extern integer sydimi_(char *, char *, integer *, integer *, ftnlen, 
	    ftnlen);
    extern /* Subroutine */ int ssizec_(integer *, char *, ftnlen), syfeti_(
	    integer *, char *, integer *, integer *, char *, logical *, 
	    ftnlen, ftnlen), sygeti_(char *, char *, integer *, integer *, 
	    integer *, integer *, logical *, ftnlen, ftnlen), ssizei_(integer 
	    *, integer *), syenqi_(char *, integer *, char *, integer *, 
	    integer *, ftnlen, ftnlen), syreni_(char *, char *, char *, 
	    integer *, integer *, ftnlen, ftnlen, ftnlen);
    static char synams[45*106];
    extern /* Subroutine */ int syordi_(char *, char *, integer *, integer *, 
	    ftnlen, ftnlen), syseli_(char *, integer *, integer *, char *, 
	    integer *, integer *, integer *, logical *, ftnlen, ftnlen), 
	    sydupi_(char *, char *, char *, integer *, integer *, ftnlen, 
	    ftnlen, ftnlen), synthi_(char *, integer *, char *, integer *, 
	    integer *, integer *, logical *, ftnlen, ftnlen), sypshi_(char *, 
	    integer *, char *, integer *, integer *, ftnlen, ftnlen), syseti_(
	    char *, integer *, char *, integer *, integer *, ftnlen, ftnlen);
    static integer syvals[10006];
    extern /* Subroutine */ int sypopi_(char *, char *, integer *, integer *, 
	    integer *, logical *, ftnlen, ftnlen), sytrni_(char *, integer *, 
	    integer *, char *, integer *, integer *, ftnlen, ftnlen), syputi_(
	    char *, integer *, integer *, char *, integer *, integer *, 
	    ftnlen, ftnlen);
    static integer syptrs[106], val;

/* $ Abstract */

/*     Exercise the SPICELIB symbol table routines of type INTEGER. */

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

/*        SYDELI */
/*        SYDIMI */
/*        SYDUPI */
/*        SYENQI */
/*        SYFETI */
/*        SYGETI */
/*        SYNTHI */
/*        SYORDI */
/*        SYPOPI */
/*        SYPSHI */
/*        SYPUTI */
/*        SYRENI */
/*        SYSELI */
/*        SYSETI */
/*        SYTRNI */

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

    topen_("F_SYMTBI", (ftnlen)8);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYSETI test:  Populate a simple symbol table with scalar-valued "
	    "symbols.", (ftnlen)72);

/*     Initialize the symbol table. */

    ssizec_(&c__100, synams, (ftnlen)45);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    ssizei_(&c__100, syptrs);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    ssizei_(&c__10000, syvals);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    for (i__ = 1; i__ <= 100; ++i__) {

/*        Create the symbol name. */

	t_ithsym__(&i__, &c__100, name__, (ftnlen)45);
	s_copy(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbi__", (ftnlen)225)) * 45, name__, (
		ftnlen)45, (ftnlen)45);
	xptrs[(i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge("xptrs", 
		i__1, "f_symtbi__", (ftnlen)226)] = 1;
	xvals[(i__1 = i__ - 1) < 10000 && 0 <= i__1 ? i__1 : s_rnge("xvals", 
		i__1, "f_symtbi__", (ftnlen)227)] = -i__;

/*        Associate the value -I with the Ith symbol.  Add this */
/*        symbol to the table. */

	i__1 = -i__;
	syseti_(name__, &i__1, synams, syptrs, syvals, (ftnlen)45, (ftnlen)45)
		;
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
		s_rnge("synams", i__2, "f_symtbi__", (ftnlen)249)) * 45, 
		"=", xnames + ((i__3 = i__ - 1) < 100 && 0 <= i__3 ? i__3 : 
		s_rnge("xnames", i__3, "f_symtbi__", (ftnlen)249)) * 45, ok, (
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

    i__1 = cardi_(syvals);
    chcksi_("Card(SYVALS)", &i__1, "=", &c__100, &c__0, ok, (ftnlen)12, (
	    ftnlen)1);
    chckai_("SYVALS", &syvals[6], "=", xvals, &c__100, ok, (ftnlen)6, (ftnlen)
	    1);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYSETI test:  Populate a simple symbol table with scalar-valued "
	    "symbols.  Insert symbols in reverse order.", (ftnlen)106);

/*     Clear out the symbol table. */

    scardc_(&c__0, synams, (ftnlen)45);
    scardi_(&c__0, syptrs);
    scardi_(&c__0, syvals);

/*     Use the symbol names and values from the previous test. */

    for (i__ = 1; i__ <= 100; ++i__) {

/*        Let J be the index of the symbol to insert. */

	j = 101 - i__;

/*        Associate the value -J with the Jth symbol.  Add this */
/*        symbol to the table. */

	i__2 = -j;
	syseti_(xnames + ((i__1 = j - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbi__", (ftnlen)295)) * 45, &i__2, 
		synams, syptrs, syvals, (ftnlen)45, (ftnlen)45);
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
		s_rnge("synams", i__2, "f_symtbi__", (ftnlen)315)) * 45, 
		"=", xnames + ((i__3 = i__ - 1) < 100 && 0 <= i__3 ? i__3 : 
		s_rnge("xnames", i__3, "f_symtbi__", (ftnlen)315)) * 45, ok, (
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

    i__1 = cardi_(syvals);
    chcksi_("Card(SYVALS)", &i__1, "=", &c__100, &c__0, ok, (ftnlen)12, (
	    ftnlen)1);
    chckai_("SYVALS", &syvals[6], "=", xvals, &c__100, ok, (ftnlen)6, (ftnlen)
	    1);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYPUTI test:  Populate a simple symbol table with scalar-valued "
	    "symbols.", (ftnlen)72);

/*     This is essentially a reprise of the previous SYSETI test. */

    scardc_(&c__0, synams, (ftnlen)45);
    scardi_(&c__0, syptrs);
    scardi_(&c__0, syvals);
    for (i__ = 1; i__ <= 100; ++i__) {

/*        Create the symbol name. */

	t_ithsym__(&i__, &c__100, name__, (ftnlen)45);
	s_copy(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbi__", (ftnlen)356)) * 45, name__, (
		ftnlen)45, (ftnlen)45);
	xptrs[(i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge("xptrs", 
		i__1, "f_symtbi__", (ftnlen)357)] = 1;
	xvals[(i__1 = i__ - 1) < 10000 && 0 <= i__1 ? i__1 : s_rnge("xvals", 
		i__1, "f_symtbi__", (ftnlen)358)] = -i__;

/*        Associate the value -I with the Ith symbol.  Add this */
/*        symbol to the table. */

	syputi_(name__, &xvals[(i__1 = i__ - 1) < 10000 && 0 <= i__1 ? i__1 : 
		s_rnge("xvals", i__1, "f_symtbi__", (ftnlen)364)], &c__1, 
		synams, syptrs, syvals, (ftnlen)45, (ftnlen)45);
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
		s_rnge("synams", i__2, "f_symtbi__", (ftnlen)380)) * 45, 
		"=", xnames + ((i__3 = i__ - 1) < 100 && 0 <= i__3 ? i__3 : 
		s_rnge("xnames", i__3, "f_symtbi__", (ftnlen)380)) * 45, ok, (
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

    i__1 = cardi_(syvals);
    chcksi_("Card(SYVALS)", &i__1, "=", &c__100, &c__0, ok, (ftnlen)12, (
	    ftnlen)1);
    chckai_("SYVALS", &syvals[6], "=", xvals, &c__100, ok, (ftnlen)6, (ftnlen)
	    1);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYFETI test:  Fetch names from symbol table with scalar-valued s"
	    "ymbols.", (ftnlen)71);
    for (i__ = 1; i__ <= 100; ++i__) {
	s_copy(title, "Was name # found?", (ftnlen)500, (ftnlen)17);
	repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)500);
	syfeti_(&i__, synams, syptrs, syvals, name__, &found, (ftnlen)45, (
		ftnlen)45);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(title, &found, &c_true, ok, (ftnlen)500);
	s_copy(title, "Name #", (ftnlen)500, (ftnlen)6);
	repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)500);
	chcksc_(title, name__, "=", xnames + ((i__1 = i__ - 1) < 100 && 0 <= 
		i__1 ? i__1 : s_rnge("xnames", i__1, "f_symtbi__", (ftnlen)
		420)) * 45, ok, (ftnlen)500, (ftnlen)45, (ftnlen)1, (ftnlen)
		45);
    }

/*     Also look for a symbol we know isn't there. */

    i__ = 101;
    s_copy(title, "Was name # found?", (ftnlen)500, (ftnlen)17);
    repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)500);
    syfeti_(&c__101, synams, syptrs, syvals, name__, &found, (ftnlen)45, (
	    ftnlen)45);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_(title, &found, &c_false, ok, (ftnlen)500);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYGETI test:  Fetch values from symbol table with scalar-valued "
	    "symbols.", (ftnlen)72);
    for (i__ = 1; i__ <= 100; ++i__) {
	s_copy(title, "Was name # found?", (ftnlen)500, (ftnlen)17);
	repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)500);
	sygeti_(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbi__", (ftnlen)450)) * 45, synams, 
		syptrs, syvals, &nvals, &val, &found, (ftnlen)45, (ftnlen)45);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(title, &found, &c_true, ok, (ftnlen)500);
	s_copy(title, "Value of symbol #", (ftnlen)500, (ftnlen)17);
	repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)500);
	chcksi_(title, &val, "=", &xvals[(i__1 = i__ - 1) < 10000 && 0 <= 
		i__1 ? i__1 : s_rnge("xvals", i__1, "f_symtbi__", (ftnlen)459)
		], &c__0, ok, (ftnlen)500, (ftnlen)1);
    }

/*     Also look for a symbol we know isn't there. */

    s_copy(name__, "NOT_THERE", (ftnlen)45, (ftnlen)9);
    sygeti_(name__, synams, syptrs, syvals, &nvals, &val, &found, (ftnlen)45, 
	    (ftnlen)45);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    s_copy(title, "Was name # found?", (ftnlen)500, (ftnlen)17);
    repmc_(title, "#", name__, title, (ftnlen)500, (ftnlen)1, (ftnlen)45, (
	    ftnlen)500);
    chcksl_(title, &found, &c_false, ok, (ftnlen)500);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYRENI test:  Rename symbols in a simple symbol table with scala"
	    "r-valued symbols.", (ftnlen)81);
    for (i__ = 1; i__ <= 100; ++i__) {

/*        Get the name and value of the ith symbol. */

	t_ithsym__(&i__, &c__100, name__, (ftnlen)45);
	sygeti_(name__, synams, syptrs, syvals, &nvals, &xval, &found, (
		ftnlen)45, (ftnlen)45);
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

	syreni_(name__, newnam, synams, syptrs, syvals, (ftnlen)45, (ftnlen)
		45, (ftnlen)45);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Make sure the old symbol is gone. */

	sygeti_(name__, synams, syptrs, syvals, &nvals, &val, &found, (ftnlen)
		45, (ftnlen)45);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	s_copy(title, "Was name # found?", (ftnlen)500, (ftnlen)17);
	repmc_(title, "#", name__, title, (ftnlen)500, (ftnlen)1, (ftnlen)45, 
		(ftnlen)500);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(title, &found, &c_false, ok, (ftnlen)500);

/*        Get the value associated with the new name. */


/*        Get the name and value of the ith symbol. */

	sygeti_(newnam, synams, syptrs, syvals, &nvals, &val, &found, (ftnlen)
		45, (ftnlen)45);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	s_copy(title, "Was name # found?", (ftnlen)500, (ftnlen)17);
	repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)500);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(title, &found, &c_true, ok, (ftnlen)500);

/*        Check the value. */

	chcksi_("VAL", &val, "=", &xval, &c__0, ok, (ftnlen)3, (ftnlen)1);

/*        Change the name back to its original value. */

	syreni_(newnam, name__, synams, syptrs, syvals, (ftnlen)45, (ftnlen)
		45, (ftnlen)45);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("SYDELI test:  Delete symbols from symbol table with scalar-value"
	    "d symbols.", (ftnlen)74);
    for (i__ = 1; i__ <= 100; ++i__) {
	s_copy(title, "Was name # found?", (ftnlen)500, (ftnlen)17);
	repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)500);
	sydeli_(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbi__", (ftnlen)568)) * 45, synams, 
		syptrs, syvals, (ftnlen)45, (ftnlen)45);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Make sure the symbol is gone. */

	s_copy(title, "Was (deleted symbol) name # found?", (ftnlen)500, (
		ftnlen)34);
	repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)500);
	sygeti_(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbi__", (ftnlen)577)) * 45, synams, 
		syptrs, syvals, &nvals, &val, &found, (ftnlen)45, (ftnlen)45);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(title, &found, &c_false, ok, (ftnlen)500);

/*        Validate the remaining symbol table. */

	for (j = i__ + 1; j <= 100; ++j) {
	    s_copy(title, "Was (remaining symbol) name # found?", (ftnlen)500,
		     (ftnlen)36);
	    repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)
		    500);
	    sygeti_(xnames + ((i__1 = j - 1) < 100 && 0 <= i__1 ? i__1 : 
		    s_rnge("xnames", i__1, "f_symtbi__", (ftnlen)591)) * 45, 
		    synams, syptrs, syvals, &nvals, &val, &found, (ftnlen)45, 
		    (ftnlen)45);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    chcksl_(title, &found, &c_true, ok, (ftnlen)500);
	    s_copy(title, "Remaining symbol # value", (ftnlen)500, (ftnlen)24)
		    ;
	    repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)
		    500);
	    chcksi_(title, &val, "=", &xvals[(i__1 = j - 1) < 10000 && 0 <= 
		    i__1 ? i__1 : s_rnge("xvals", i__1, "f_symtbi__", (ftnlen)
		    600)], &c__0, ok, (ftnlen)500, (ftnlen)1);
	}
    }

/*     At this point, we need to work with symbol tables containing */
/*     symbols having multiple values associated with them.  We'll */
/*     build a symbol table whose nth symbol has n associated values. */


/* --- Case: ------------------------------------------------------ */

    tcase_("SYPUTI test:  Create symbol table with array-valued symbols.", (
	    ftnlen)60);
    scardc_(&c__0, synams, (ftnlen)45);
    scardi_(&c__0, syptrs);
    scardi_(&c__0, syvals);
    to = 1;
    for (i__ = 1; i__ <= 100; ++i__) {

/*        Create the symbol name. */

	t_ithsym__(&i__, &c__100, name__, (ftnlen)45);
	s_copy(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbi__", (ftnlen)631)) * 45, name__, (
		ftnlen)45, (ftnlen)45);
	xptrs[(i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge("xptrs", 
		i__1, "f_symtbi__", (ftnlen)632)] = i__;
	start = to;
	i__1 = i__;
	for (j = 1; j <= i__1; ++j) {
	    xvals[(i__2 = to - 1) < 10000 && 0 <= i__2 ? i__2 : s_rnge("xvals"
		    , i__2, "f_symtbi__", (ftnlen)637)] = i__ * -100 - j;
	    ++to;
	}

/*        Add the symbol to the table. */

	syputi_(name__, &xvals[(i__1 = start - 1) < 10000 && 0 <= i__1 ? i__1 
		: s_rnge("xvals", i__1, "f_symtbi__", (ftnlen)645)], &i__, 
		synams, syptrs, syvals, (ftnlen)45, (ftnlen)45);
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
		s_rnge("synams", i__2, "f_symtbi__", (ftnlen)662)) * 45, 
		"=", xnames + ((i__3 = i__ - 1) < 100 && 0 <= i__3 ? i__3 : 
		s_rnge("xnames", i__3, "f_symtbi__", (ftnlen)662)) * 45, ok, (
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
    i__1 = cardi_(syvals);
    chcksi_("Card(SYVALS)", &i__1, "=", &xcard, &c__0, ok, (ftnlen)12, (
	    ftnlen)1);
    chckai_("SYVALS", &syvals[6], "=", xvals, &c__100, ok, (ftnlen)6, (ftnlen)
	    1);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYPUTI test:  Populate a simple symbol table with scalar-valued "
	    "symbols.  Insert symbols in reverse order.", (ftnlen)106);

/*     Clear out the symbol table. */

    scardc_(&c__0, synams, (ftnlen)45);
    scardi_(&c__0, syptrs);
    scardi_(&c__0, syvals);
    cleari_(&c__10000, xvals);

/*     Use the symbol names and values from the previous test. */

    size = 5050;
    start = size - 99;
    for (i__ = 100; i__ >= 1; --i__) {

/*        Add the symbol to the table. */

	syputi_(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbi__", (ftnlen)711)) * 45, &xvals[(
		i__2 = start - 1) < 10000 && 0 <= i__2 ? i__2 : s_rnge("xvals"
		, i__2, "f_symtbi__", (ftnlen)711)], &i__, synams, syptrs, 
		syvals, (ftnlen)45, (ftnlen)45);
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
		s_rnge("synams", i__2, "f_symtbi__", (ftnlen)735)) * 45, 
		"=", xnames + ((i__3 = i__ - 1) < 100 && 0 <= i__3 ? i__3 : 
		s_rnge("xnames", i__3, "f_symtbi__", (ftnlen)735)) * 45, ok, (
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
    i__1 = cardi_(syvals);
    chcksi_("Card(SYVALS)", &i__1, "=", &xcard, &c__0, ok, (ftnlen)12, (
	    ftnlen)1);
    chckai_("SYVALS", &syvals[6], "=", xvals, &c__100, ok, (ftnlen)6, (ftnlen)
	    1);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYGETI test:  validate array-valued symbol table by fetching val"
	    "ues associated with each symbol.", (ftnlen)96);
    start = 1;
    for (i__ = 1; i__ <= 100; ++i__) {
	s_copy(title, "Was name # found?", (ftnlen)500, (ftnlen)17);
	repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)500);
	sygeti_(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbi__", (ftnlen)774)) * 45, synams, 
		syptrs, syvals, &nvals, ivals, &found, (ftnlen)45, (ftnlen)45)
		;
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(title, &found, &c_true, ok, (ftnlen)500);
	if (found) {
	    s_copy(title, "Values of symbol #", (ftnlen)500, (ftnlen)18);
	    repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)
		    500);
	    chckai_(title, ivals, "=", &xvals[(i__1 = start - 1) < 10000 && 0 
		    <= i__1 ? i__1 : s_rnge("xvals", i__1, "f_symtbi__", (
		    ftnlen)785)], &i__, ok, (ftnlen)500, (ftnlen)1);
	}
	start += i__;
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("SYNTHI test:  validate array-valued symbol table by fetching val"
	    "ues associated with each symbol.", (ftnlen)96);
    start = 1;
    for (i__ = 1; i__ <= 100; ++i__) {
	s_copy(title, "Was name # found?", (ftnlen)500, (ftnlen)17);
	repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)500);
	sygeti_(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbi__", (ftnlen)809)) * 45, synams, 
		syptrs, syvals, &nvals, ivals, &found, (ftnlen)45, (ftnlen)45)
		;
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(title, &found, &c_true, ok, (ftnlen)500);
	if (found) {

/*           Get the size of the current symbol. */

	    size = sydimi_(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? 
		    i__1 : s_rnge("xnames", i__1, "f_symtbi__", (ftnlen)819)) 
		    * 45, synams, syptrs, syvals, (ftnlen)45, (ftnlen)45);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    i__1 = size;
	    for (j = 1; j <= i__1; ++j) {

/*              Fetch each value. */

		s_copy(title, "Value # of symbol #", (ftnlen)500, (ftnlen)19);
		repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (
			ftnlen)500);
		repmc_(title, "#", xnames + ((i__2 = i__ - 1) < 100 && 0 <= 
			i__2 ? i__2 : s_rnge("xnames", i__2, "f_symtbi__", (
			ftnlen)828)) * 45, title, (ftnlen)500, (ftnlen)1, (
			ftnlen)45, (ftnlen)500);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		synthi_(xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 :
			 s_rnge("xnames", i__2, "f_symtbi__", (ftnlen)831)) * 
			45, &j, synams, syptrs, syvals, &val, &found, (ftnlen)
			45, (ftnlen)45);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		chcksl_(title, &found, &c_true, ok, (ftnlen)500);
		chcksi_(title, &val, "=", &xvals[(i__2 = start + j - 2) < 
			10000 && 0 <= i__2 ? i__2 : s_rnge("xvals", i__2, 
			"f_symtbi__", (ftnlen)837)], &c__0, ok, (ftnlen)500, (
			ftnlen)1);
	    }

/*           Try to fetch an element we know isn't there. */

	    j = size + 1;
	    s_copy(title, "Value # of symbol #", (ftnlen)500, (ftnlen)19);
	    repmi_(title, "#", &j, title, (ftnlen)500, (ftnlen)1, (ftnlen)500)
		    ;
	    repmc_(title, "#", xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ?
		     i__1 : s_rnge("xnames", i__1, "f_symtbi__", (ftnlen)848))
		     * 45, title, (ftnlen)500, (ftnlen)1, (ftnlen)45, (ftnlen)
		    500);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    synthi_(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : 
		    s_rnge("xnames", i__1, "f_symtbi__", (ftnlen)851)) * 45, &
		    j, synams, syptrs, syvals, &val, &found, (ftnlen)45, (
		    ftnlen)45);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    chcksl_(title, &found, &c_false, ok, (ftnlen)500);
	}
	start += i__;
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("SYENQI test:  Create symbol table with array-valued symbols.", (
	    ftnlen)60);
    scardc_(&c__0, synams, (ftnlen)45);
    scardi_(&c__0, syptrs);
    scardi_(&c__0, syvals);
    to = 1;
    for (i__ = 1; i__ <= 100; ++i__) {

/*        Create the symbol name. */

	t_ithsym__(&i__, &c__100, name__, (ftnlen)45);
	s_copy(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbi__", (ftnlen)883)) * 45, name__, (
		ftnlen)45, (ftnlen)45);
	xptrs[(i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge("xptrs", 
		i__1, "f_symtbi__", (ftnlen)884)] = i__;
	i__1 = i__;
	for (j = 1; j <= i__1; ++j) {
	    xvals[(i__2 = to - 1) < 10000 && 0 <= i__2 ? i__2 : s_rnge("xvals"
		    , i__2, "f_symtbi__", (ftnlen)888)] = i__ * -100 - j;
	    syenqi_(name__, &xvals[(i__2 = to - 1) < 10000 && 0 <= i__2 ? 
		    i__2 : s_rnge("xvals", i__2, "f_symtbi__", (ftnlen)890)], 
		    synams, syptrs, syvals, (ftnlen)45, (ftnlen)45);
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
		s_rnge("synams", i__2, "f_symtbi__", (ftnlen)911)) * 45, 
		"=", xnames + ((i__3 = i__ - 1) < 100 && 0 <= i__3 ? i__3 : 
		s_rnge("xnames", i__3, "f_symtbi__", (ftnlen)911)) * 45, ok, (
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
    i__1 = cardi_(syvals);
    chcksi_("Card(SYVALS)", &i__1, "=", &xcard, &c__0, ok, (ftnlen)12, (
	    ftnlen)1);
    chckai_("SYVALS", &syvals[6], "=", xvals, &c__100, ok, (ftnlen)6, (ftnlen)
	    1);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYPSHI test:  Create symbol table with array-valued symbols.", (
	    ftnlen)60);
    scardc_(&c__0, synams, (ftnlen)45);
    scardi_(&c__0, syptrs);
    scardi_(&c__0, syvals);
    to = 0;
    for (i__ = 1; i__ <= 100; ++i__) {

/*        Create the symbol name. */

	t_ithsym__(&i__, &c__100, name__, (ftnlen)45);
	s_copy(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbi__", (ftnlen)952)) * 45, name__, (
		ftnlen)45, (ftnlen)45);
	xptrs[(i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge("xptrs", 
		i__1, "f_symtbi__", (ftnlen)953)] = i__;
	to += i__;

/*        At the start of the loop, TO points to the element of XVALS */
/*        that will hold the last value associated with the Ith symbol. */

	for (j = i__; j >= 1; --j) {
	    xvals[(i__1 = to - 1) < 10000 && 0 <= i__1 ? i__1 : s_rnge("xvals"
		    , i__1, "f_symtbi__", (ftnlen)962)] = i__ * -100 - j;
	    sypshi_(name__, &xvals[(i__1 = to - 1) < 10000 && 0 <= i__1 ? 
		    i__1 : s_rnge("xvals", i__1, "f_symtbi__", (ftnlen)964)], 
		    synams, syptrs, syvals, (ftnlen)45, (ftnlen)45);
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
		s_rnge("synams", i__2, "f_symtbi__", (ftnlen)987)) * 45, 
		"=", xnames + ((i__3 = i__ - 1) < 100 && 0 <= i__3 ? i__3 : 
		s_rnge("xnames", i__3, "f_symtbi__", (ftnlen)987)) * 45, ok, (
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
    i__1 = cardi_(syvals);
    chcksi_("Card(SYVALS)", &i__1, "=", &xcard, &c__0, ok, (ftnlen)12, (
	    ftnlen)1);
    chckai_("SYVALS", &syvals[6], "=", xvals, &c__100, ok, (ftnlen)6, (ftnlen)
	    1);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYDUPI test:  Create symbol table with array-valued symbols.  Th"
	    "en duplicate each symbol.", (ftnlen)89);
    scardc_(&c__0, synams, (ftnlen)45);
    scardi_(&c__0, syptrs);
    scardi_(&c__0, syvals);

/*     We'll set the cardinality upper bound UB to MAXTAB/2, so */
/*     we'll have room for the duplicate symbols. */

    to = 1;
    ub = 50;
    i__1 = ub;
    for (i__ = 1; i__ <= i__1; ++i__) {

/*        Create the symbol name. */

	t_ithsym__(&i__, &ub, name__, (ftnlen)45);
	s_copy(xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 : s_rnge(
		"xnames", i__2, "f_symtbi__", (ftnlen)1035)) * 45, name__, (
		ftnlen)45, (ftnlen)45);
	xptrs[(i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 : s_rnge("xptrs", 
		i__2, "f_symtbi__", (ftnlen)1036)] = i__;
	i__2 = i__;
	for (j = 1; j <= i__2; ++j) {
	    xvals[(i__3 = to - 1) < 10000 && 0 <= i__3 ? i__3 : s_rnge("xvals"
		    , i__3, "f_symtbi__", (ftnlen)1040)] = -ub * i__ - j;
	    syenqi_(name__, &xvals[(i__3 = to - 1) < 10000 && 0 <= i__3 ? 
		    i__3 : s_rnge("xvals", i__3, "f_symtbi__", (ftnlen)1042)],
		     synams, syptrs, syvals, (ftnlen)45, (ftnlen)45);
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
		i__2 : s_rnge("xnames", i__2, "f_symtbi__", (ftnlen)1059)) * 
		45, title, (ftnlen)500, (ftnlen)1, (ftnlen)45, (ftnlen)500);
	sygeti_(xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 : s_rnge(
		"xnames", i__2, "f_symtbi__", (ftnlen)1061)) * 45, synams, 
		syptrs, syvals, &nvals, ivals, &found, (ftnlen)45, (ftnlen)45)
		;
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(title, &found, &c_true, ok, (ftnlen)500);
	if (found) {
	    s_copy(title, "Values of symbol # (0)", (ftnlen)500, (ftnlen)22);
	    repmc_(title, "#", xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ?
		     i__2 : s_rnge("xnames", i__2, "f_symtbi__", (ftnlen)1070)
		    ) * 45, title, (ftnlen)500, (ftnlen)1, (ftnlen)45, (
		    ftnlen)500);
	    chckai_(title, ivals, "=", &xvals[(i__2 = start - 1) < 10000 && 0 
		    <= i__2 ? i__2 : s_rnge("xvals", i__2, "f_symtbi__", (
		    ftnlen)1072)], &i__, ok, (ftnlen)500, (ftnlen)1);
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
	sydupi_(name__, newnam, synams, syptrs, syvals, (ftnlen)45, (ftnlen)
		45, (ftnlen)45);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Now validate the symbol table.  First make sure the original */
/*     symbols are intact. */

    start = 1;
    i__1 = ub;
    for (i__ = 1; i__ <= i__1; ++i__) {
	s_copy(title, "Was name # found? (1)", (ftnlen)500, (ftnlen)21);
	repmc_(title, "#", xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ? 
		i__2 : s_rnge("xnames", i__2, "f_symtbi__", (ftnlen)1107)) * 
		45, title, (ftnlen)500, (ftnlen)1, (ftnlen)45, (ftnlen)500);
	sygeti_(xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 : s_rnge(
		"xnames", i__2, "f_symtbi__", (ftnlen)1109)) * 45, synams, 
		syptrs, syvals, &nvals, ivals, &found, (ftnlen)45, (ftnlen)45)
		;
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(title, &found, &c_true, ok, (ftnlen)500);
	if (found) {
	    s_copy(title, "Values of symbol # (1)", (ftnlen)500, (ftnlen)22);
	    repmc_(title, "#", xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ?
		     i__2 : s_rnge("xnames", i__2, "f_symtbi__", (ftnlen)1118)
		    ) * 45, title, (ftnlen)500, (ftnlen)1, (ftnlen)45, (
		    ftnlen)500);
	    chckai_(title, ivals, "=", &xvals[(i__2 = start - 1) < 10000 && 0 
		    <= i__2 ? i__2 : s_rnge("xvals", i__2, "f_symtbi__", (
		    ftnlen)1120)], &i__, ok, (ftnlen)500, (ftnlen)1);
	}
	start += i__;
    }

/*     Now check the duplicate symbols. */

    start = 1;
    i__1 = ub;
    for (i__ = 1; i__ <= i__1; ++i__) {
	s_copy(newnam, xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 : 
		s_rnge("xnames", i__2, "f_symtbi__", (ftnlen)1135)) * 45, (
		ftnlen)45, (ftnlen)45);
	s_copy(newnam, "2_", (ftnlen)2, (ftnlen)2);
	s_copy(title, "Was name # found? (2)", (ftnlen)500, (ftnlen)21);
	repmc_(title, "#", newnam, title, (ftnlen)500, (ftnlen)1, (ftnlen)45, 
		(ftnlen)500);
	sygeti_(newnam, synams, syptrs, syvals, &nvals, ivals, &found, (
		ftnlen)45, (ftnlen)45);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(title, &found, &c_true, ok, (ftnlen)500);
	if (found) {
	    s_copy(title, "Values of symbol # (2)", (ftnlen)500, (ftnlen)22);
	    repmc_(title, "#", newnam, title, (ftnlen)500, (ftnlen)1, (ftnlen)
		    45, (ftnlen)500);
	    chckai_(title, ivals, "=", &xvals[(i__2 = start - 1) < 10000 && 0 
		    <= i__2 ? i__2 : s_rnge("xvals", i__2, "f_symtbi__", (
		    ftnlen)1152)], &i__, ok, (ftnlen)500, (ftnlen)1);
	}
	start += i__;
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("SYDUPI test:  Create symbol table with array-valued symbols.  Du"
	    "plicate these symbols.  Negate the values of the original symbol"
	    "s.  Then duplicate the duplicate the symbols, overwriting the or"
	    "iginal symbols.", (ftnlen)207);
    scardc_(&c__0, synams, (ftnlen)45);
    scardi_(&c__0, syptrs);
    scardi_(&c__0, syvals);

/*     We'll set the cardinality upper bound UB to MAXTAB/2, so */
/*     we'll have room for the duplicate symbols. */

    to = 1;
    ub = 50;
    i__1 = ub;
    for (i__ = 1; i__ <= i__1; ++i__) {

/*        Create the symbol name. */

	t_ithsym__(&i__, &ub, name__, (ftnlen)45);
	s_copy(xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 : s_rnge(
		"xnames", i__2, "f_symtbi__", (ftnlen)1187)) * 45, name__, (
		ftnlen)45, (ftnlen)45);
	xptrs[(i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 : s_rnge("xptrs", 
		i__2, "f_symtbi__", (ftnlen)1188)] = i__;
	i__2 = i__;
	for (j = 1; j <= i__2; ++j) {
	    xvals[(i__3 = to - 1) < 10000 && 0 <= i__3 ? i__3 : s_rnge("xvals"
		    , i__3, "f_symtbi__", (ftnlen)1192)] = -ub * i__ - j;
	    syenqi_(name__, &xvals[(i__3 = to - 1) < 10000 && 0 <= i__3 ? 
		    i__3 : s_rnge("xvals", i__3, "f_symtbi__", (ftnlen)1194)],
		     synams, syptrs, syvals, (ftnlen)45, (ftnlen)45);
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
	sydupi_(name__, newnam, synams, syptrs, syvals, (ftnlen)45, (ftnlen)
		45, (ftnlen)45);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Negate the values of the symbols of the original symbols. */

    i__1 = ub;
    for (i__ = 1; i__ <= i__1; ++i__) {
	sygeti_(xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 : s_rnge(
		"xnames", i__2, "f_symtbi__", (ftnlen)1226)) * 45, synams, 
		syptrs, syvals, &nvals, ivals, &found, (ftnlen)45, (ftnlen)45)
		;
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	i__2 = nvals;
	for (j = 1; j <= i__2; ++j) {
	    ivals[(i__3 = j - 1) < 10000 && 0 <= i__3 ? i__3 : s_rnge("ivals",
		     i__3, "f_symtbi__", (ftnlen)1231)] = -ivals[(i__4 = j - 
		    1) < 10000 && 0 <= i__4 ? i__4 : s_rnge("ivals", i__4, 
		    "f_symtbi__", (ftnlen)1231)];
	}
	syputi_(xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 : s_rnge(
		"xnames", i__2, "f_symtbi__", (ftnlen)1234)) * 45, ivals, &
		nvals, synams, syptrs, syvals, (ftnlen)45, (ftnlen)45);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Duplicate the duplicate symbols, overwriting the originals. */

    i__1 = ub;
    for (i__ = 1; i__ <= i__1; ++i__) {

/*        Create the symbol name. */

	t_ithsym__(&i__, &ub, name__, (ftnlen)45);
	s_copy(newnam, name__, (ftnlen)45, (ftnlen)45);
	s_copy(newnam, "2_", (ftnlen)2, (ftnlen)2);
	sydupi_(newnam, name__, synams, syptrs, syvals, (ftnlen)45, (ftnlen)
		45, (ftnlen)45);
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
	sygeti_(xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 : s_rnge(
		"xnames", i__2, "f_symtbi__", (ftnlen)1273)) * 45, synams, 
		syptrs, syvals, &nvals, ivals, &found, (ftnlen)45, (ftnlen)45)
		;
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(title, &found, &c_true, ok, (ftnlen)500);
	if (found) {
	    s_copy(title, "Values of symbol # (1)", (ftnlen)500, (ftnlen)22);
	    repmc_(title, "#", xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ?
		     i__2 : s_rnge("xnames", i__2, "f_symtbi__", (ftnlen)1282)
		    ) * 45, title, (ftnlen)500, (ftnlen)1, (ftnlen)45, (
		    ftnlen)500);
	    chckai_(title, ivals, "=", &xvals[(i__2 = start - 1) < 10000 && 0 
		    <= i__2 ? i__2 : s_rnge("xvals", i__2, "f_symtbi__", (
		    ftnlen)1284)], &i__, ok, (ftnlen)500, (ftnlen)1);
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
	sygeti_(xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 : s_rnge(
		"xnames", i__2, "f_symtbi__", (ftnlen)1302)) * 45, synams, 
		syptrs, syvals, &nvals, ivals, &found, (ftnlen)45, (ftnlen)45)
		;
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(title, &found, &c_true, ok, (ftnlen)500);
	if (found) {
	    s_copy(title, "Values of symbol # (2)", (ftnlen)500, (ftnlen)22);
	    repmc_(title, "#", newnam, title, (ftnlen)500, (ftnlen)1, (ftnlen)
		    45, (ftnlen)500);
	    chckai_(title, ivals, "=", &xvals[(i__2 = start - 1) < 10000 && 0 
		    <= i__2 ? i__2 : s_rnge("xvals", i__2, "f_symtbi__", (
		    ftnlen)1313)], &i__, ok, (ftnlen)500, (ftnlen)1);
	}
	start += i__;
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("SYORDI test:  Create symbol table with array-valued symbols; sor"
	    "t values associated with each symbol.", (ftnlen)101);
    scardc_(&c__0, synams, (ftnlen)45);
    scardi_(&c__0, syptrs);
    scardi_(&c__0, syvals);
    cleari_(&c__10000, xvals);

/*     Create the symbol table to be sorted. */

    for (i__ = 1; i__ <= 100; ++i__) {

/*        Create the symbol name. */

	t_ithsym__(&i__, &c__100, name__, (ftnlen)45);
	s_copy(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbi__", (ftnlen)1344)) * 45, name__, (
		ftnlen)45, (ftnlen)45);
	i__1 = i__;
	for (j = 1; j <= i__1; ++j) {
	    val = i__ * -100 - j;
	    syenqi_(name__, &val, synams, syptrs, syvals, (ftnlen)45, (ftnlen)
		    45);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	}
    }

/*     Sort the symbol values. */

    for (i__ = 1; i__ <= 100; ++i__) {
	syordi_(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbi__", (ftnlen)1362)) * 45, synams, 
		syptrs, syvals, (ftnlen)45, (ftnlen)45);
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
	    xvals[(i__2 = to - 1) < 10000 && 0 <= i__2 ? i__2 : s_rnge("xvals"
		    , i__2, "f_symtbi__", (ftnlen)1382)] = i__ * -100 - j;
	}
	start += i__;
    }

/*     Check the symbol table values against the value array. */

    chckai_("SYVALS", &syvals[6], "=", xvals, &c__100, ok, (ftnlen)6, (ftnlen)
	    1);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYDIMI test:  Find dimensions of symbols in symbol table with ar"
	    "ray-valued symbols.", (ftnlen)83);
    scardc_(&c__0, synams, (ftnlen)45);
    scardi_(&c__0, syptrs);
    scardi_(&c__0, syvals);
    cleari_(&c__10000, xvals);
    for (i__ = 1; i__ <= 100; ++i__) {

/*        Create the symbol name. */

	t_ithsym__(&i__, &c__100, name__, (ftnlen)45);
	s_copy(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbi__", (ftnlen)1416)) * 45, name__, (
		ftnlen)45, (ftnlen)45);
	i__1 = i__;
	for (j = 1; j <= i__1; ++j) {
	    val = i__ * -100 - j;
	    syenqi_(name__, &val, synams, syptrs, syvals, (ftnlen)45, (ftnlen)
		    45);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	}
    }
    for (i__ = 1; i__ <= 100; ++i__) {
	nvals = sydimi_(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 :
		 s_rnge("xnames", i__1, "f_symtbi__", (ftnlen)1431)) * 45, 
		synams, syptrs, syvals, (ftnlen)45, (ftnlen)45);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	s_copy(title, "Dimension of symbol #", (ftnlen)500, (ftnlen)21);
	repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)500);
	chcksi_(title, &nvals, "=", &i__, &c__0, ok, (ftnlen)500, (ftnlen)1);
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("SYPOPI test:  Pop values from symbol table with array-valued sym"
	    "bols.", (ftnlen)69);

/*     Re-create the default array-valued symbol table. */

    scardc_(&c__0, synams, (ftnlen)45);
    scardi_(&c__0, syptrs);
    scardi_(&c__0, syvals);
    for (i__ = 1; i__ <= 100; ++i__) {

/*        Create the symbol name. */

	t_ithsym__(&i__, &c__100, name__, (ftnlen)45);

/*        Set the values of the Ith symbol. */

	i__1 = i__;
	for (j = 1; j <= i__1; ++j) {
	    ivals[(i__2 = j - 1) < 10000 && 0 <= i__2 ? i__2 : s_rnge("ivals",
		     i__2, "f_symtbi__", (ftnlen)1467)] = i__ * -100 - j;
	}

/*        Insert the Ith symbol. */

	syputi_(name__, ivals, &i__, synams, syptrs, syvals, (ftnlen)45, (
		ftnlen)45);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Now test SYPOPI. */

    to = 1;
    for (i__ = 1; i__ <= 100; ++i__) {

/*        Create the symbol name. */

	t_ithsym__(&i__, &c__100, name__, (ftnlen)45);
	xptrs[(i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge("xptrs", 
		i__1, "f_symtbi__", (ftnlen)1491)] = i__;
	i__1 = i__;
	for (j = 1; j <= i__1; ++j) {

/*           Set the expected value. */

	    xvals[(i__2 = to - 1) < 10000 && 0 <= i__2 ? i__2 : s_rnge("xvals"
		    , i__2, "f_symtbi__", (ftnlen)1497)] = i__ * -100 - j;
	    sypopi_(name__, synams, syptrs, syvals, &val, &found, (ftnlen)45, 
		    (ftnlen)45);
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
		chcksi_(title, &val, "=", &xvals[(i__2 = to - 1) < 10000 && 0 
			<= i__2 ? i__2 : s_rnge("xvals", i__2, "f_symtbi__", (
			ftnlen)1515)], &c__0, ok, (ftnlen)500, (ftnlen)1);
	    }
	    ++to;
	}

/*        Try to pop a value from the now empty symbol. */

	sypopi_(name__, synams, syptrs, syvals, &val, &found, (ftnlen)45, (
		ftnlen)45);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	s_copy(title, "Was element popped from symbol #?", (ftnlen)500, (
		ftnlen)33);
	repmc_(title, "#", name__, title, (ftnlen)500, (ftnlen)1, (ftnlen)45, 
		(ftnlen)500);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(title, &found, &c_false, ok, (ftnlen)500);
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("SYTRNI test:  Transpose values from symbol table with array-valu"
	    "ed symbols.", (ftnlen)75);

/*     We'll create a small version of our array-valued symbol table. */
/*     Since we want to try all possible transpositions, there would */
/*     be an excessive number of calls to SYTRNI if we used the full */
/*     set of MAXTAB symbols. */

/*     Create the symbol table now. */

    scardc_(&c__0, synams, (ftnlen)45);
    scardi_(&c__0, syptrs);
    scardi_(&c__0, syvals);
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
	    xvals[(i__3 = to - 1) < 10000 && 0 <= i__3 ? i__3 : s_rnge("xvals"
		    , i__3, "f_symtbi__", (ftnlen)1574)] = -tabsiz * i__ - j;
	    ++to;
	}

/*        Insert the Ith symbol. */

	syputi_(name__, &xvals[(i__2 = start - 1) < 10000 && 0 <= i__2 ? i__2 
		: s_rnge("xvals", i__2, "f_symtbi__", (ftnlen)1582)], &i__, 
		synams, syptrs, syvals, (ftnlen)45, (ftnlen)45);
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
		sytrni_(name__, &j, &k, synams, syptrs, syvals, (ftnlen)45, (
			ftnlen)45);
		chckxc_(&c_false, " ", ok, (ftnlen)1);

/*              Fetch the values of the modified symbol. */

		sygeti_(name__, synams, syptrs, syvals, &nvals, ivals, &found,
			 (ftnlen)45, (ftnlen)45);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		chcksl_(title, &found, &c_true, ok, (ftnlen)500);
		if (found) {

/*                 If IVALS reflects the correct transposition, */
/*                 then we can swap elements J and K of IVALS */
/*                 to obtain the original symbol's values. */

		    if (j != k) {
			swapi_(&ivals[(i__4 = j - 1) < 10000 && 0 <= i__4 ? 
				i__4 : s_rnge("ivals", i__4, "f_symtbi__", (
				ftnlen)1629)], &ivals[(i__5 = k - 1) < 10000 
				&& 0 <= i__5 ? i__5 : s_rnge("ivals", i__5, 
				"f_symtbi__", (ftnlen)1629)]);
		    }
		    s_copy(title, "Values of symbol #:  J = #; K = #", (
			    ftnlen)500, (ftnlen)33);
		    repmc_(title, "#", name__, title, (ftnlen)500, (ftnlen)1, 
			    (ftnlen)45, (ftnlen)500);
		    repmi_(title, "#", &j, title, (ftnlen)500, (ftnlen)1, (
			    ftnlen)500);
		    repmi_(title, "#", &k, title, (ftnlen)500, (ftnlen)1, (
			    ftnlen)500);
		    chckai_(title, ivals, "=", &xvals[(i__4 = start - 1) < 
			    10000 && 0 <= i__4 ? i__4 : s_rnge("xvals", i__4, 
			    "f_symtbi__", (ftnlen)1637)], &i__, ok, (ftnlen)
			    500, (ftnlen)1);
		}

/*              Undo the transposition in the symbol table. */

		sytrni_(name__, &j, &k, synams, syptrs, syvals, (ftnlen)45, (
			ftnlen)45);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
	    }
	}

/*        Set the start index for the next symbol. */

	start += i__;
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("SYSELI test:  Extract slice of values from symbol table with arr"
	    "ay-valued symbols.", (ftnlen)82);

/*     This approach used in this test case closely parallels that */
/*     of the SYTRNI test case above. */

/*     We'll create a small version of our array-valued symbol table. */
/*     Since we want to try all possible slices, there would */
/*     be an excessive number of calls to SYTRNI if we used the full */
/*     set of MAXTAB symbols. */

/*     Create the symbol table now. */

    scardc_(&c__0, synams, (ftnlen)45);
    scardi_(&c__0, syptrs);
    scardi_(&c__0, syvals);
    cleari_(&c__10000, xvals);
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
	    xvals[(i__3 = to - 1) < 10000 && 0 <= i__3 ? i__3 : s_rnge("xvals"
		    , i__3, "f_symtbi__", (ftnlen)1701)] = -tabsiz * i__ - j;
	    ++to;
	}

/*        Insert the Ith symbol. */

	syputi_(name__, &xvals[(i__2 = start - 1) < 10000 && 0 <= i__2 ? i__2 
		: s_rnge("xvals", i__2, "f_symtbi__", (ftnlen)1709)], &i__, 
		synams, syptrs, syvals, (ftnlen)45, (ftnlen)45);
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

		syseli_(name__, &j, &k, synams, syptrs, syvals, ivals, &found,
			 (ftnlen)45, (ftnlen)45);
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
		    chckai_(title, ivals, "=", &xvals[(i__4 = start + j - 2) <
			     10000 && 0 <= i__4 ? i__4 : s_rnge("xvals", i__4,
			     "f_symtbi__", (ftnlen)1757)], &i__5, ok, (ftnlen)
			    500, (ftnlen)1);
		}
	    }
	}

/*        Set the start index for the next symbol. */

	start += i__;
    }

/*     Now for some error handling tests. */


/*     SYDELI:  No errors are detected by this routine. */

/*     SYDIMI:  No errors are detected by this routine. */


/*     SYDUPI: */

/* --- Case: ------------------------------------------------------ */

    tcase_("SYDUPI:  symbol name not present", (ftnlen)32);
    sydupi_("NOSYMBOL", "NOSYMBOL2", synams, syptrs, syvals, (ftnlen)8, (
	    ftnlen)9, (ftnlen)45);
    chckxc_(&c_true, "SPICE(NOSUCHSYMBOL)", ok, (ftnlen)19);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYDUPI:  name table overflow", (ftnlen)28);

/*     We'll create a small symbol table so we can test the handling of */
/*     overflow conditions. */

    tabsiz = 5;
    ssizec_(&tabsiz, synams, (ftnlen)45);
    i__1 = tabsiz << 1;
    ssizei_(&i__1, syptrs);
    i__1 = tabsiz << 1;
    ssizei_(&i__1, syvals);
    i__1 = tabsiz;
    for (i__ = 1; i__ <= i__1; ++i__) {
	t_ithsym__(&i__, &tabsiz, name__, (ftnlen)45);
	syseti_(name__, &i__, synams, syptrs, syvals, (ftnlen)45, (ftnlen)45);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    sydupi_(name__, "NEWNAME", synams, syptrs, syvals, (ftnlen)45, (ftnlen)7, 
	    (ftnlen)45);
    chckxc_(&c_true, "SPICE(NAMETABLEFULL)", ok, (ftnlen)20);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYDUPI:  pointer table overflow", (ftnlen)31);
    i__1 = tabsiz + 1;
    ssizec_(&i__1, synams, (ftnlen)45);
    ssizei_(&tabsiz, syptrs);
    i__1 = tabsiz + 2;
    ssizei_(&i__1, syvals);
    i__1 = tabsiz;
    for (i__ = 1; i__ <= i__1; ++i__) {
	t_ithsym__(&i__, &tabsiz, name__, (ftnlen)45);
	syseti_(name__, &i__, synams, syptrs, syvals, (ftnlen)45, (ftnlen)45);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    sydupi_(name__, "NEWNAME", synams, syptrs, syvals, (ftnlen)45, (ftnlen)7, 
	    (ftnlen)45);
    chckxc_(&c_true, "SPICE(POINTERTABLEFULL)", ok, (ftnlen)23);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYDUPI:  value table overflow", (ftnlen)29);
    i__1 = tabsiz + 1;
    ssizec_(&i__1, synams, (ftnlen)45);
    i__1 = tabsiz + 1;
    ssizei_(&i__1, syptrs);
    ssizei_(&tabsiz, syvals);
    i__1 = tabsiz;
    for (i__ = 1; i__ <= i__1; ++i__) {
	t_ithsym__(&i__, &tabsiz, name__, (ftnlen)45);
	syseti_(name__, &i__, synams, syptrs, syvals, (ftnlen)45, (ftnlen)45);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    sydupi_(name__, "NEWNAME", synams, syptrs, syvals, (ftnlen)45, (ftnlen)7, 
	    (ftnlen)45);
    chckxc_(&c_true, "SPICE(VALUETABLEFULL)", ok, (ftnlen)21);


/*     SYENQI: */

/* --- Case: ------------------------------------------------------ */

    tcase_("SYENQI:  value table overflow", (ftnlen)29);
    tabsiz = 5;
    ssizec_(&tabsiz, synams, (ftnlen)45);
    ssizei_(&tabsiz, syptrs);
    ssizei_(&tabsiz, syvals);
    i__1 = tabsiz;
    for (i__ = 1; i__ <= i__1; ++i__) {
	t_ithsym__(&i__, &tabsiz, name__, (ftnlen)45);
	syseti_(name__, &i__, synams, syptrs, syvals, (ftnlen)45, (ftnlen)45);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Enqueue a value onto the last symbol. */

    syenqi_(name__, &c_n1, synams, syptrs, syvals, (ftnlen)45, (ftnlen)45);
    chckxc_(&c_true, "SPICE(VALUETABLEFULL)", ok, (ftnlen)21);



/*     SYFETI:  No errors are detected by this routine. */

/*     SYGETI:  No errors are detected by this routine. */

/*     SYNTHI:  No errors are detected by this routine. */

/*     SYORDI:  No errors are detected by this routine. */

/*     SYPOPI:  No errors are detected by this routine. */



/*     SYPSHI: */

/* --- Case: ------------------------------------------------------ */


    tcase_("SYPSHI:  value table overflow", (ftnlen)29);
    tabsiz = 5;
    ssizec_(&tabsiz, synams, (ftnlen)45);
    ssizei_(&tabsiz, syptrs);
    ssizei_(&tabsiz, syvals);
    i__1 = tabsiz;
    for (i__ = 1; i__ <= i__1; ++i__) {
	t_ithsym__(&i__, &tabsiz, name__, (ftnlen)45);
	syseti_(name__, &i__, synams, syptrs, syvals, (ftnlen)45, (ftnlen)45);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Push a value onto the last symbol. */

    sypshi_(name__, &c_n1, synams, syptrs, syvals, (ftnlen)45, (ftnlen)45);
    chckxc_(&c_true, "SPICE(VALUETABLEFULL)", ok, (ftnlen)21);

/*     SYPUTI: */


/* --- Case: ------------------------------------------------------ */

    tcase_("SYPUTI:  name table overflow", (ftnlen)28);

/*     We'll create a small symbol table so we can test the handling of */
/*     overflow conditions. */

    tabsiz = 5;
    ssizec_(&tabsiz, synams, (ftnlen)45);
    i__1 = tabsiz << 1;
    ssizei_(&i__1, syptrs);
    i__1 = tabsiz << 1;
    ssizei_(&i__1, syvals);
    i__1 = tabsiz;
    for (i__ = 1; i__ <= i__1; ++i__) {
	t_ithsym__(&i__, &tabsiz, name__, (ftnlen)45);
	syseti_(name__, &i__, synams, syptrs, syvals, (ftnlen)45, (ftnlen)45);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    syputi_("NEWNAME", &i__, &c__1, synams, syptrs, syvals, (ftnlen)7, (
	    ftnlen)45);
    chckxc_(&c_true, "SPICE(NAMETABLEFULL)", ok, (ftnlen)20);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYPUTI:  pointer table overflow", (ftnlen)31);
    i__1 = tabsiz + 1;
    ssizec_(&i__1, synams, (ftnlen)45);
    ssizei_(&tabsiz, syptrs);
    i__1 = tabsiz + 2;
    ssizei_(&i__1, syvals);
    i__1 = tabsiz;
    for (i__ = 1; i__ <= i__1; ++i__) {
	t_ithsym__(&i__, &tabsiz, name__, (ftnlen)45);
	syseti_(name__, &i__, synams, syptrs, syvals, (ftnlen)45, (ftnlen)45);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    syputi_("NEWNAME", &i__, &c__1, synams, syptrs, syvals, (ftnlen)7, (
	    ftnlen)45);
    chckxc_(&c_true, "SPICE(POINTERTABLEFULL)", ok, (ftnlen)23);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYPUTI:  value table overflow", (ftnlen)29);
    i__1 = tabsiz + 1;
    ssizec_(&i__1, synams, (ftnlen)45);
    i__1 = tabsiz + 1;
    ssizei_(&i__1, syptrs);
    ssizei_(&tabsiz, syvals);
    i__1 = tabsiz;
    for (i__ = 1; i__ <= i__1; ++i__) {
	t_ithsym__(&i__, &tabsiz, name__, (ftnlen)45);
	syseti_(name__, &i__, synams, syptrs, syvals, (ftnlen)45, (ftnlen)45);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    syputi_("NEWNAME", &i__, &c__1, synams, syptrs, syvals, (ftnlen)7, (
	    ftnlen)45);
    chckxc_(&c_true, "SPICE(VALUETABLEFULL)", ok, (ftnlen)21);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYPUTI: invalid value count", (ftnlen)27);
    i__1 = tabsiz + 1;
    ssizec_(&i__1, synams, (ftnlen)45);
    i__1 = tabsiz + 1;
    ssizei_(&i__1, syptrs);
    i__1 = tabsiz + 1;
    ssizei_(&i__1, syvals);
    i__1 = tabsiz;
    for (i__ = 1; i__ <= i__1; ++i__) {
	t_ithsym__(&i__, &tabsiz, name__, (ftnlen)45);
	syseti_(name__, &i__, synams, syptrs, syvals, (ftnlen)45, (ftnlen)45);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    syputi_("NEWNAME", &i__, &c_n1, synams, syptrs, syvals, (ftnlen)7, (
	    ftnlen)45);
    chckxc_(&c_true, "SPICE(INVALIDARGUMENT)", ok, (ftnlen)22);

/*     SYRENI: */


/* --- Case: ------------------------------------------------------ */

    tcase_("SYRENI:  rename non-existent symbol", (ftnlen)35);
    syreni_("NONNAME", "NEWNAME", synams, syptrs, syvals, (ftnlen)7, (ftnlen)
	    7, (ftnlen)45);
    chckxc_(&c_true, "SPICE(NOSUCHSYMBOL)", ok, (ftnlen)19);


/*     SYSELI:  No errors are detected by this routine. */


/*     SYSETI: */

/* --- Case: ------------------------------------------------------ */

    tcase_("SYSETI:  name table overflow", (ftnlen)28);

/*     We'll create a small symbol table so we can test the handling of */
/*     overflow conditions. */

    tabsiz = 5;
    ssizec_(&tabsiz, synams, (ftnlen)45);
    i__1 = tabsiz << 1;
    ssizei_(&i__1, syptrs);
    i__1 = tabsiz << 1;
    ssizei_(&i__1, syvals);
    i__1 = tabsiz;
    for (i__ = 1; i__ <= i__1; ++i__) {
	t_ithsym__(&i__, &tabsiz, name__, (ftnlen)45);
	syseti_(name__, &i__, synams, syptrs, syvals, (ftnlen)45, (ftnlen)45);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    syseti_("NEWNAME", &i__, synams, syptrs, syvals, (ftnlen)7, (ftnlen)45);
    chckxc_(&c_true, "SPICE(NAMETABLEFULL)", ok, (ftnlen)20);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYSETI:  pointer table overflow", (ftnlen)31);
    i__1 = tabsiz + 1;
    ssizec_(&i__1, synams, (ftnlen)45);
    ssizei_(&tabsiz, syptrs);
    i__1 = tabsiz + 2;
    ssizei_(&i__1, syvals);
    i__1 = tabsiz;
    for (i__ = 1; i__ <= i__1; ++i__) {
	t_ithsym__(&i__, &tabsiz, name__, (ftnlen)45);
	syseti_(name__, &i__, synams, syptrs, syvals, (ftnlen)45, (ftnlen)45);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    syseti_("NEWNAME", &i__, synams, syptrs, syvals, (ftnlen)7, (ftnlen)45);
    chckxc_(&c_true, "SPICE(POINTERTABLEFULL)", ok, (ftnlen)23);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYSETI:  value table overflow", (ftnlen)29);
    i__1 = tabsiz + 1;
    ssizec_(&i__1, synams, (ftnlen)45);
    i__1 = tabsiz + 1;
    ssizei_(&i__1, syptrs);
    ssizei_(&tabsiz, syvals);
    i__1 = tabsiz;
    for (i__ = 1; i__ <= i__1; ++i__) {
	t_ithsym__(&i__, &tabsiz, name__, (ftnlen)45);
	syseti_(name__, &i__, synams, syptrs, syvals, (ftnlen)45, (ftnlen)45);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    syseti_("NEWNAME", &i__, synams, syptrs, syvals, (ftnlen)7, (ftnlen)45);
    chckxc_(&c_true, "SPICE(VALUETABLEFULL)", ok, (ftnlen)21);
/*     SYTRNI: */

/* --- Case: ------------------------------------------------------ */

    tcase_("SYTRNI:  first index < 1", (ftnlen)24);
    ssizec_(&tabsiz, synams, (ftnlen)45);
    ssizei_(&tabsiz, syptrs);
    ssizei_(&tabsiz, syvals);
    i__1 = tabsiz;
    for (i__ = 1; i__ <= i__1; ++i__) {
	t_ithsym__(&i__, &tabsiz, name__, (ftnlen)45);
	syseti_(name__, &i__, synams, syptrs, syvals, (ftnlen)45, (ftnlen)45);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	s_copy(xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 : s_rnge(
		"xnames", i__2, "f_symtbi__", (ftnlen)2177)) * 45, name__, (
		ftnlen)45, (ftnlen)45);
	xptrs[(i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 : s_rnge("xptrs", 
		i__2, "f_symtbi__", (ftnlen)2178)] = 1;
	xvals[(i__2 = i__ - 1) < 10000 && 0 <= i__2 ? i__2 : s_rnge("xvals", 
		i__2, "f_symtbi__", (ftnlen)2179)] = i__;
    }
    sytrni_(name__, &c_n1, &c__2, synams, syptrs, syvals, (ftnlen)45, (ftnlen)
	    45);
    chckxc_(&c_true, "SPICE(INVALIDINDEX)", ok, (ftnlen)19);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYTRNI:  first index > second index", (ftnlen)35);
    sytrni_(name__, &c__2, &c__1, synams, syptrs, syvals, (ftnlen)45, (ftnlen)
	    45);
    chckxc_(&c_true, "SPICE(INVALIDINDEX)", ok, (ftnlen)19);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYTRNI:  second index > symbol size", (ftnlen)35);
    i__1 = tabsiz + 1;
    sytrni_(name__, &c__1, &i__1, synams, syptrs, syvals, (ftnlen)45, (ftnlen)
	    45);
    chckxc_(&c_true, "SPICE(INVALIDINDEX)", ok, (ftnlen)19);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYTRNI:  non-error case: attempt transposition of values of non-"
	    "existent symbol.", (ftnlen)80);
    sytrni_("NONAME", &c__1, &c__1, synams, syptrs, syvals, (ftnlen)6, (
	    ftnlen)45);
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
		s_rnge("synams", i__2, "f_symtbi__", (ftnlen)2229)) * 45, 
		"=", xnames + ((i__3 = i__ - 1) < 100 && 0 <= i__3 ? i__3 : 
		s_rnge("xnames", i__3, "f_symtbi__", (ftnlen)2229)) * 45, ok, 
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

    i__1 = cardi_(syvals);
    chcksi_("Card(SYVALS)", &i__1, "=", &tabsiz, &c__0, ok, (ftnlen)12, (
	    ftnlen)1);
    chckai_("SYVALS", &syvals[6], "=", xvals, &tabsiz, ok, (ftnlen)6, (ftnlen)
	    1);

/*     That's all, folks! */


/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_symtbi__ */


/*     The utility routine T_ITHSYM creates the name of the ith */
/*     symbol.  The names created by this routine have the form */

/*        XXX...XXXnnn */

/*     where nnn is the input number N, printed with a sufficient */
/*     number of leading zeros so that all numbers in the range */
/*     1:NMAX have the same width.  The number is padded with */
/*     leading 'X' characters up to the length of the string NAME. */

/* Subroutine */ int t_ithsym__(integer *n, integer *nmax, char *name__, 
	ftnlen name_len)
{
    /* System generated locals */
    integer i__1;
    doublereal d__1;

    /* Builtin functions */
    integer i_len(char *, ftnlen);
    double d_lg10(doublereal *);
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    integer npad, slen, i__;
    extern /* Subroutine */ int dpfmt_(doublereal *, char *, char *, ftnlen, 
	    ftnlen);
    integer npict;
    extern /* Subroutine */ int rjust_(char *, char *, ftnlen, ftnlen);
    integer ndigit;
    char pictur[11];


/*     SPICELIB functions */


/*     Local parameters */


/*     Local variables */


/*     Get the length of the output name. */

    slen = i_len(name__, name_len);

/*     Determine the number of digits required. */

    d__1 = (doublereal) (*nmax);
    ndigit = (integer) d_lg10(&d__1) + 1;

/*     Create the format picture for the names. */

    s_copy(pictur, "0", (ftnlen)11, (ftnlen)1);
    npict = min(slen,ndigit);
    i__1 = npict;
    for (i__ = 2; i__ <= i__1; ++i__) {
	*(unsigned char *)&pictur[i__ - 1] = 'X';
    }
    d__1 = (doublereal) (*n);
    dpfmt_(&d__1, pictur, name__, (ftnlen)11, name_len);

/*     Add non-blank leading padding to the name. */

    npad = slen - npict;
    if (npad > 0) {
	rjust_(name__, name__, name_len, name_len);
	i__1 = npad;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    *(unsigned char *)&name__[i__ - 1] = 'X';
	}
    }
    return 0;
} /* t_ithsym__ */

