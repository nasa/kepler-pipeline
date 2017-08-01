/* f_symtbd.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__100 = 100;
static logical c_false = FALSE_;
static integer c__10000 = 10000;
static integer c__0 = 0;
static doublereal c_b47 = 0.;
static integer c__1 = 1;
static logical c_true = TRUE_;
static integer c__101 = 101;
static doublereal c_b708 = -1.;
static integer c_n1 = -1;
static integer c__2 = 2;

/* $Procedure F_SYMTBD ( Test SPICELIB d.p. symbol table routines ) */
/* Subroutine */ int f_symtbd__(logical *ok)
{
    /* System generated locals */
    integer i__1, i__2, i__3, i__4, i__5;
    doublereal d__1;

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer);
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    static char name__[45];
    static doublereal xval;
    static integer size;
    extern /* Subroutine */ int t_ithsym__(integer *, integer *, char *, 
	    ftnlen);
    static integer i__, j, k;
    extern integer cardc_(char *, ftnlen), cardd_(doublereal *), cardi_(
	    integer *);
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    static integer xcard;
    extern /* Subroutine */ int repmc_(char *, char *, char *, char *, ftnlen,
	     ftnlen, ftnlen, ftnlen);
    static doublereal dvals[10000];
    static logical found;
    extern /* Subroutine */ int repmi_(char *, char *, integer *, char *, 
	    ftnlen, ftnlen, ftnlen), swapd_(doublereal *, doublereal *);
    static char title[500];
    static integer nvals;
    extern /* Subroutine */ int topen_(char *, ftnlen);
    static doublereal xvals[10000];
    static integer start;
    extern /* Subroutine */ int t_success__(logical *);
    static integer xptrs[100];
    extern /* Subroutine */ int chckad_(char *, doublereal *, char *, 
	    doublereal *, integer *, doublereal *, logical *, ftnlen, ftnlen),
	     chckai_(char *, integer *, char *, integer *, integer *, logical 
	    *, ftnlen, ftnlen);
    static integer ub;
    extern /* Subroutine */ int cleard_(integer *, doublereal *), chcksc_(
	    char *, char *, char *, char *, logical *, ftnlen, ftnlen, ftnlen,
	     ftnlen), scardc_(integer *, char *, ftnlen), scardd_(integer *, 
	    doublereal *), chcksd_(char *, doublereal *, char *, doublereal *,
	     doublereal *, logical *, ftnlen, ftnlen);
    static integer to;
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     chcksi_(char *, integer *, char *, integer *, integer *, logical 
	    *, ftnlen, ftnlen), scardi_(integer *, integer *), chcksl_(char *,
	     logical *, logical *, logical *, ftnlen), replch_(char *, char *,
	     char *, char *, ftnlen, ftnlen, ftnlen, ftnlen), sydeld_(char *, 
	    char *, integer *, doublereal *, ftnlen, ftnlen);
    static char newnam[45];
    extern integer sydimd_(char *, char *, integer *, doublereal *, ftnlen, 
	    ftnlen);
    static char xnames[45*100];
    static integer tabsiz;
    extern /* Subroutine */ int syfetd_(integer *, char *, integer *, 
	    doublereal *, char *, logical *, ftnlen, ftnlen), sygetd_(char *, 
	    char *, integer *, doublereal *, integer *, doublereal *, logical 
	    *, ftnlen, ftnlen), ssizec_(integer *, char *, ftnlen), ssized_(
	    integer *, doublereal *), syenqd_(char *, doublereal *, char *, 
	    integer *, doublereal *, ftnlen, ftnlen), syrend_(char *, char *, 
	    char *, integer *, doublereal *, ftnlen, ftnlen, ftnlen), syordd_(
	    char *, char *, integer *, doublereal *, ftnlen, ftnlen), ssizei_(
	    integer *, integer *), syseld_(char *, integer *, integer *, char 
	    *, integer *, doublereal *, doublereal *, logical *, ftnlen, 
	    ftnlen), sydupd_(char *, char *, char *, integer *, doublereal *, 
	    ftnlen, ftnlen, ftnlen), synthd_(char *, integer *, char *, 
	    integer *, doublereal *, doublereal *, logical *, ftnlen, ftnlen);
    static char synams[45*106];
    extern /* Subroutine */ int sysetd_(char *, doublereal *, char *, integer 
	    *, doublereal *, ftnlen, ftnlen), sypshd_(char *, doublereal *, 
	    char *, integer *, doublereal *, ftnlen, ftnlen), sypopd_(char *, 
	    char *, integer *, doublereal *, doublereal *, logical *, ftnlen, 
	    ftnlen);
    static doublereal syvals[10006];
    extern /* Subroutine */ int sytrnd_(char *, integer *, integer *, char *, 
	    integer *, doublereal *, ftnlen, ftnlen), syputd_(char *, 
	    doublereal *, integer *, char *, integer *, doublereal *, ftnlen, 
	    ftnlen);
    static integer syptrs[106];
    static doublereal val;

/* $ Abstract */

/*     Exercise the SPICELIB symbol table routines of type DOUBLE */
/*     PRECISION. */

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

/*        SYDELD */
/*        SYDIMD */
/*        SYDUPD */
/*        SYENQD */
/*        SYFETD */
/*        SYGETD */
/*        SYNTHD */
/*        SYORDD */
/*        SYPOPD */
/*        SYPSHD */
/*        SYPUTD */
/*        SYREND */
/*        SYSELD */
/*        SYSETD */
/*        SYTRND */

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

    topen_("F_SYMTBD", (ftnlen)8);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYSETD test:  Populate a simple symbol table with scalar-valued "
	    "symbols.", (ftnlen)72);

/*     Initialize the symbol table. */

    ssizec_(&c__100, synams, (ftnlen)45);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    ssizei_(&c__100, syptrs);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    ssized_(&c__10000, syvals);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    for (i__ = 1; i__ <= 100; ++i__) {

/*        Create the symbol name. */

	t_ithsym__(&i__, &c__100, name__, (ftnlen)45);
	s_copy(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbd__", (ftnlen)229)) * 45, name__, (
		ftnlen)45, (ftnlen)45);
	xptrs[(i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge("xptrs", 
		i__1, "f_symtbd__", (ftnlen)230)] = 1;
	xvals[(i__1 = i__ - 1) < 10000 && 0 <= i__1 ? i__1 : s_rnge("xvals", 
		i__1, "f_symtbd__", (ftnlen)231)] = (doublereal) (-i__);

/*        Associate the value -I with the Ith symbol.  Add this */
/*        symbol to the table. */

	d__1 = (doublereal) (-i__);
	sysetd_(name__, &d__1, synams, syptrs, syvals, (ftnlen)45, (ftnlen)45)
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
		s_rnge("synams", i__2, "f_symtbd__", (ftnlen)253)) * 45, 
		"=", xnames + ((i__3 = i__ - 1) < 100 && 0 <= i__3 ? i__3 : 
		s_rnge("xnames", i__3, "f_symtbd__", (ftnlen)253)) * 45, ok, (
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

    i__1 = cardd_(syvals);
    chcksi_("Card(SYVALS)", &i__1, "=", &c__100, &c__0, ok, (ftnlen)12, (
	    ftnlen)1);
    chckad_("SYVALS", &syvals[6], "=", xvals, &c__100, &c_b47, ok, (ftnlen)6, 
	    (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYSETD test:  Populate a simple symbol table with scalar-valued "
	    "symbols.  Insert symbols in reverse order.", (ftnlen)106);

/*     Clear out the symbol table. */

    scardc_(&c__0, synams, (ftnlen)45);
    scardi_(&c__0, syptrs);
    scardd_(&c__0, syvals);

/*     Use the symbol names and values from the previous test. */

    for (i__ = 1; i__ <= 100; ++i__) {

/*        Let J be the index of the symbol to insert. */

	j = 101 - i__;

/*        Associate the value -J with the Jth symbol.  Add this */
/*        symbol to the table. */

	d__1 = (doublereal) (-j);
	sysetd_(xnames + ((i__1 = j - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbd__", (ftnlen)299)) * 45, &d__1, 
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
		s_rnge("synams", i__2, "f_symtbd__", (ftnlen)319)) * 45, 
		"=", xnames + ((i__3 = i__ - 1) < 100 && 0 <= i__3 ? i__3 : 
		s_rnge("xnames", i__3, "f_symtbd__", (ftnlen)319)) * 45, ok, (
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

    i__1 = cardd_(syvals);
    chcksi_("Card(SYVALS)", &i__1, "=", &c__100, &c__0, ok, (ftnlen)12, (
	    ftnlen)1);
    chckad_("SYVALS", &syvals[6], "=", xvals, &c__100, &c_b47, ok, (ftnlen)6, 
	    (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYPUTD test:  Populate a simple symbol table with scalar-valued "
	    "symbols.", (ftnlen)72);

/*     This is essentially a reprise of the previous SYSETD test. */

    scardc_(&c__0, synams, (ftnlen)45);
    scardi_(&c__0, syptrs);
    scardd_(&c__0, syvals);
    for (i__ = 1; i__ <= 100; ++i__) {

/*        Create the symbol name. */

	t_ithsym__(&i__, &c__100, name__, (ftnlen)45);
	s_copy(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbd__", (ftnlen)360)) * 45, name__, (
		ftnlen)45, (ftnlen)45);
	xptrs[(i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge("xptrs", 
		i__1, "f_symtbd__", (ftnlen)361)] = 1;
	xvals[(i__1 = i__ - 1) < 10000 && 0 <= i__1 ? i__1 : s_rnge("xvals", 
		i__1, "f_symtbd__", (ftnlen)362)] = (doublereal) (-i__);

/*        Associate the value -I with the Ith symbol.  Add this */
/*        symbol to the table. */

	syputd_(name__, &xvals[(i__1 = i__ - 1) < 10000 && 0 <= i__1 ? i__1 : 
		s_rnge("xvals", i__1, "f_symtbd__", (ftnlen)368)], &c__1, 
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
		s_rnge("synams", i__2, "f_symtbd__", (ftnlen)384)) * 45, 
		"=", xnames + ((i__3 = i__ - 1) < 100 && 0 <= i__3 ? i__3 : 
		s_rnge("xnames", i__3, "f_symtbd__", (ftnlen)384)) * 45, ok, (
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

    i__1 = cardd_(syvals);
    chcksi_("Card(SYVALS)", &i__1, "=", &c__100, &c__0, ok, (ftnlen)12, (
	    ftnlen)1);
    chckad_("SYVALS", &syvals[6], "=", xvals, &c__100, &c_b47, ok, (ftnlen)6, 
	    (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYFETD test:  Fetch names from symbol table with scalar-valued s"
	    "ymbols.", (ftnlen)71);
    for (i__ = 1; i__ <= 100; ++i__) {
	s_copy(title, "Was name # found?", (ftnlen)500, (ftnlen)17);
	repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)500);
	syfetd_(&i__, synams, syptrs, syvals, name__, &found, (ftnlen)45, (
		ftnlen)45);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(title, &found, &c_true, ok, (ftnlen)500);
	s_copy(title, "Name #", (ftnlen)500, (ftnlen)6);
	repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)500);
	chcksc_(title, name__, "=", xnames + ((i__1 = i__ - 1) < 100 && 0 <= 
		i__1 ? i__1 : s_rnge("xnames", i__1, "f_symtbd__", (ftnlen)
		424)) * 45, ok, (ftnlen)500, (ftnlen)45, (ftnlen)1, (ftnlen)
		45);
    }

/*     Also look for a symbol we know isn't there. */

    i__ = 101;
    s_copy(title, "Was name # found?", (ftnlen)500, (ftnlen)17);
    repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)500);
    syfetd_(&c__101, synams, syptrs, syvals, name__, &found, (ftnlen)45, (
	    ftnlen)45);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_(title, &found, &c_false, ok, (ftnlen)500);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYGETD test:  Fetch values from symbol table with scalar-valued "
	    "symbols.", (ftnlen)72);
    for (i__ = 1; i__ <= 100; ++i__) {
	s_copy(title, "Was name # found?", (ftnlen)500, (ftnlen)17);
	repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)500);
	sygetd_(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbd__", (ftnlen)454)) * 45, synams, 
		syptrs, syvals, &nvals, &val, &found, (ftnlen)45, (ftnlen)45);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(title, &found, &c_true, ok, (ftnlen)500);
	s_copy(title, "Value of symbol #", (ftnlen)500, (ftnlen)17);
	repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)500);
	chcksd_(title, &val, "=", &xvals[(i__1 = i__ - 1) < 10000 && 0 <= 
		i__1 ? i__1 : s_rnge("xvals", i__1, "f_symtbd__", (ftnlen)463)
		], &c_b47, ok, (ftnlen)500, (ftnlen)1);
    }

/*     Also look for a symbol we know isn't there. */

    s_copy(name__, "NOT_THERE", (ftnlen)45, (ftnlen)9);
    sygetd_(name__, synams, syptrs, syvals, &nvals, &val, &found, (ftnlen)45, 
	    (ftnlen)45);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    s_copy(title, "Was name # found?", (ftnlen)500, (ftnlen)17);
    repmc_(title, "#", name__, title, (ftnlen)500, (ftnlen)1, (ftnlen)45, (
	    ftnlen)500);
    chcksl_(title, &found, &c_false, ok, (ftnlen)500);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYREND test:  Rename symbols in a simple symbol table with scala"
	    "r-valued symbols.", (ftnlen)81);
    for (i__ = 1; i__ <= 100; ++i__) {

/*        Get the name and value of the ith symbol. */

	t_ithsym__(&i__, &c__100, name__, (ftnlen)45);
	sygetd_(name__, synams, syptrs, syvals, &nvals, &xval, &found, (
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

	syrend_(name__, newnam, synams, syptrs, syvals, (ftnlen)45, (ftnlen)
		45, (ftnlen)45);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Make sure the old symbol is gone. */

	sygetd_(name__, synams, syptrs, syvals, &nvals, &val, &found, (ftnlen)
		45, (ftnlen)45);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	s_copy(title, "Was name # found?", (ftnlen)500, (ftnlen)17);
	repmc_(title, "#", name__, title, (ftnlen)500, (ftnlen)1, (ftnlen)45, 
		(ftnlen)500);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(title, &found, &c_false, ok, (ftnlen)500);

/*        Get the value associated with the new name. */


/*        Get the name and value of the ith symbol. */

	sygetd_(newnam, synams, syptrs, syvals, &nvals, &val, &found, (ftnlen)
		45, (ftnlen)45);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	s_copy(title, "Was name # found?", (ftnlen)500, (ftnlen)17);
	repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)500);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(title, &found, &c_true, ok, (ftnlen)500);

/*        Check the value. */

	chcksd_("VAL", &val, "=", &xval, &c_b47, ok, (ftnlen)3, (ftnlen)1);

/*        Change the name back to its original value. */

	syrend_(newnam, name__, synams, syptrs, syvals, (ftnlen)45, (ftnlen)
		45, (ftnlen)45);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("SYDELD test:  Delete symbols from symbol table with scalar-value"
	    "d symbols.", (ftnlen)74);
    for (i__ = 1; i__ <= 100; ++i__) {
	s_copy(title, "Was name # found?", (ftnlen)500, (ftnlen)17);
	repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)500);
	sydeld_(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbd__", (ftnlen)572)) * 45, synams, 
		syptrs, syvals, (ftnlen)45, (ftnlen)45);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Make sure the symbol is gone. */

	s_copy(title, "Was (deleted symbol) name # found?", (ftnlen)500, (
		ftnlen)34);
	repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)500);
	sygetd_(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbd__", (ftnlen)581)) * 45, synams, 
		syptrs, syvals, &nvals, &val, &found, (ftnlen)45, (ftnlen)45);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(title, &found, &c_false, ok, (ftnlen)500);

/*        Validate the remaining symbol table. */

	for (j = i__ + 1; j <= 100; ++j) {
	    s_copy(title, "Was (remaining symbol) name # found?", (ftnlen)500,
		     (ftnlen)36);
	    repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)
		    500);
	    sygetd_(xnames + ((i__1 = j - 1) < 100 && 0 <= i__1 ? i__1 : 
		    s_rnge("xnames", i__1, "f_symtbd__", (ftnlen)595)) * 45, 
		    synams, syptrs, syvals, &nvals, &val, &found, (ftnlen)45, 
		    (ftnlen)45);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    chcksl_(title, &found, &c_true, ok, (ftnlen)500);
	    s_copy(title, "Remaining symbol # value", (ftnlen)500, (ftnlen)24)
		    ;
	    repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)
		    500);
	    chcksd_(title, &val, "=", &xvals[(i__1 = j - 1) < 10000 && 0 <= 
		    i__1 ? i__1 : s_rnge("xvals", i__1, "f_symtbd__", (ftnlen)
		    604)], &c_b47, ok, (ftnlen)500, (ftnlen)1);
	}
    }

/*     At this point, we need to work with symbol tables containing */
/*     symbols having multiple values associated with them.  We'll */
/*     build a symbol table whose nth symbol has n associated values. */


/* --- Case: ------------------------------------------------------ */

    tcase_("SYPUTD test:  Create symbol table with array-valued symbols.", (
	    ftnlen)60);
    scardc_(&c__0, synams, (ftnlen)45);
    scardi_(&c__0, syptrs);
    scardd_(&c__0, syvals);
    to = 1;
    for (i__ = 1; i__ <= 100; ++i__) {

/*        Create the symbol name. */

	t_ithsym__(&i__, &c__100, name__, (ftnlen)45);
	s_copy(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbd__", (ftnlen)635)) * 45, name__, (
		ftnlen)45, (ftnlen)45);
	xptrs[(i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge("xptrs", 
		i__1, "f_symtbd__", (ftnlen)636)] = i__;
	start = to;
	i__1 = i__;
	for (j = 1; j <= i__1; ++j) {
	    xvals[(i__2 = to - 1) < 10000 && 0 <= i__2 ? i__2 : s_rnge("xvals"
		    , i__2, "f_symtbd__", (ftnlen)641)] = (doublereal) (i__ * 
		    -100 - j);
	    ++to;
	}

/*        Add the symbol to the table. */

	syputd_(name__, &xvals[(i__1 = start - 1) < 10000 && 0 <= i__1 ? i__1 
		: s_rnge("xvals", i__1, "f_symtbd__", (ftnlen)649)], &i__, 
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
		s_rnge("synams", i__2, "f_symtbd__", (ftnlen)666)) * 45, 
		"=", xnames + ((i__3 = i__ - 1) < 100 && 0 <= i__3 ? i__3 : 
		s_rnge("xnames", i__3, "f_symtbd__", (ftnlen)666)) * 45, ok, (
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
    i__1 = cardd_(syvals);
    chcksi_("Card(SYVALS)", &i__1, "=", &xcard, &c__0, ok, (ftnlen)12, (
	    ftnlen)1);
    chckad_("SYVALS", &syvals[6], "=", xvals, &c__100, &c_b47, ok, (ftnlen)6, 
	    (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYPUTD test:  Populate a simple symbol table with scalar-valued "
	    "symbols.  Insert symbols in reverse order.", (ftnlen)106);

/*     Clear out the symbol table. */

    scardc_(&c__0, synams, (ftnlen)45);
    scardi_(&c__0, syptrs);
    scardd_(&c__0, syvals);
    cleard_(&c__10000, xvals);

/*     Use the symbol names and values from the previous test. */

    size = 5050;
    start = size - 99;
    for (i__ = 100; i__ >= 1; --i__) {

/*        Add the symbol to the table. */

	syputd_(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbd__", (ftnlen)715)) * 45, &xvals[(
		i__2 = start - 1) < 10000 && 0 <= i__2 ? i__2 : s_rnge("xvals"
		, i__2, "f_symtbd__", (ftnlen)715)], &i__, synams, syptrs, 
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
		s_rnge("synams", i__2, "f_symtbd__", (ftnlen)739)) * 45, 
		"=", xnames + ((i__3 = i__ - 1) < 100 && 0 <= i__3 ? i__3 : 
		s_rnge("xnames", i__3, "f_symtbd__", (ftnlen)739)) * 45, ok, (
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
    i__1 = cardd_(syvals);
    chcksi_("Card(SYVALS)", &i__1, "=", &xcard, &c__0, ok, (ftnlen)12, (
	    ftnlen)1);
    chckad_("SYVALS", &syvals[6], "=", xvals, &c__100, &c_b47, ok, (ftnlen)6, 
	    (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYGETD test:  validate array-valued symbol table by fetching val"
	    "ues associated with each symbol.", (ftnlen)96);
    start = 1;
    for (i__ = 1; i__ <= 100; ++i__) {
	s_copy(title, "Was name # found?", (ftnlen)500, (ftnlen)17);
	repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)500);
	sygetd_(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbd__", (ftnlen)778)) * 45, synams, 
		syptrs, syvals, &nvals, dvals, &found, (ftnlen)45, (ftnlen)45)
		;
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(title, &found, &c_true, ok, (ftnlen)500);
	if (found) {
	    s_copy(title, "Values of symbol #", (ftnlen)500, (ftnlen)18);
	    repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)
		    500);
	    chckad_(title, dvals, "=", &xvals[(i__1 = start - 1) < 10000 && 0 
		    <= i__1 ? i__1 : s_rnge("xvals", i__1, "f_symtbd__", (
		    ftnlen)789)], &i__, &c_b47, ok, (ftnlen)500, (ftnlen)1);
	}
	start += i__;
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("SYNTHD test:  validate array-valued symbol table by fetching val"
	    "ues associated with each symbol.", (ftnlen)96);
    start = 1;
    for (i__ = 1; i__ <= 100; ++i__) {
	s_copy(title, "Was name # found?", (ftnlen)500, (ftnlen)17);
	repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)500);
	sygetd_(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbd__", (ftnlen)813)) * 45, synams, 
		syptrs, syvals, &nvals, dvals, &found, (ftnlen)45, (ftnlen)45)
		;
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(title, &found, &c_true, ok, (ftnlen)500);
	if (found) {

/*           Get the size of the current symbol. */

	    size = sydimd_(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? 
		    i__1 : s_rnge("xnames", i__1, "f_symtbd__", (ftnlen)823)) 
		    * 45, synams, syptrs, syvals, (ftnlen)45, (ftnlen)45);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    i__1 = size;
	    for (j = 1; j <= i__1; ++j) {

/*              Fetch each value. */

		s_copy(title, "Value # of symbol #", (ftnlen)500, (ftnlen)19);
		repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (
			ftnlen)500);
		repmc_(title, "#", xnames + ((i__2 = i__ - 1) < 100 && 0 <= 
			i__2 ? i__2 : s_rnge("xnames", i__2, "f_symtbd__", (
			ftnlen)832)) * 45, title, (ftnlen)500, (ftnlen)1, (
			ftnlen)45, (ftnlen)500);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		synthd_(xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 :
			 s_rnge("xnames", i__2, "f_symtbd__", (ftnlen)835)) * 
			45, &j, synams, syptrs, syvals, &val, &found, (ftnlen)
			45, (ftnlen)45);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		chcksl_(title, &found, &c_true, ok, (ftnlen)500);
		chcksd_(title, &val, "=", &xvals[(i__2 = start + j - 2) < 
			10000 && 0 <= i__2 ? i__2 : s_rnge("xvals", i__2, 
			"f_symtbd__", (ftnlen)841)], &c_b47, ok, (ftnlen)500, 
			(ftnlen)1);
	    }

/*           Try to fetch an element we know isn't there. */

	    j = size + 1;
	    s_copy(title, "Value # of symbol #", (ftnlen)500, (ftnlen)19);
	    repmi_(title, "#", &j, title, (ftnlen)500, (ftnlen)1, (ftnlen)500)
		    ;
	    repmc_(title, "#", xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ?
		     i__1 : s_rnge("xnames", i__1, "f_symtbd__", (ftnlen)853))
		     * 45, title, (ftnlen)500, (ftnlen)1, (ftnlen)45, (ftnlen)
		    500);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    synthd_(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : 
		    s_rnge("xnames", i__1, "f_symtbd__", (ftnlen)856)) * 45, &
		    j, synams, syptrs, syvals, &val, &found, (ftnlen)45, (
		    ftnlen)45);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    chcksl_(title, &found, &c_false, ok, (ftnlen)500);
	}
	start += i__;
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("SYENQD test:  Create symbol table with array-valued symbols.", (
	    ftnlen)60);
    scardc_(&c__0, synams, (ftnlen)45);
    scardi_(&c__0, syptrs);
    scardd_(&c__0, syvals);
    to = 1;
    for (i__ = 1; i__ <= 100; ++i__) {

/*        Create the symbol name. */

	t_ithsym__(&i__, &c__100, name__, (ftnlen)45);
	s_copy(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbd__", (ftnlen)888)) * 45, name__, (
		ftnlen)45, (ftnlen)45);
	xptrs[(i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge("xptrs", 
		i__1, "f_symtbd__", (ftnlen)889)] = i__;
	i__1 = i__;
	for (j = 1; j <= i__1; ++j) {
	    xvals[(i__2 = to - 1) < 10000 && 0 <= i__2 ? i__2 : s_rnge("xvals"
		    , i__2, "f_symtbd__", (ftnlen)893)] = (doublereal) (i__ * 
		    -100 - j);
	    syenqd_(name__, &xvals[(i__2 = to - 1) < 10000 && 0 <= i__2 ? 
		    i__2 : s_rnge("xvals", i__2, "f_symtbd__", (ftnlen)895)], 
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
		s_rnge("synams", i__2, "f_symtbd__", (ftnlen)916)) * 45, 
		"=", xnames + ((i__3 = i__ - 1) < 100 && 0 <= i__3 ? i__3 : 
		s_rnge("xnames", i__3, "f_symtbd__", (ftnlen)916)) * 45, ok, (
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
    i__1 = cardd_(syvals);
    chcksi_("Card(SYVALS)", &i__1, "=", &xcard, &c__0, ok, (ftnlen)12, (
	    ftnlen)1);
    chckad_("SYVALS", &syvals[6], "=", xvals, &c__100, &c_b47, ok, (ftnlen)6, 
	    (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYPSHD test:  Create symbol table with array-valued symbols.", (
	    ftnlen)60);
    scardc_(&c__0, synams, (ftnlen)45);
    scardi_(&c__0, syptrs);
    scardd_(&c__0, syvals);
    to = 0;
    for (i__ = 1; i__ <= 100; ++i__) {

/*        Create the symbol name. */

	t_ithsym__(&i__, &c__100, name__, (ftnlen)45);
	s_copy(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbd__", (ftnlen)957)) * 45, name__, (
		ftnlen)45, (ftnlen)45);
	xptrs[(i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge("xptrs", 
		i__1, "f_symtbd__", (ftnlen)958)] = i__;
	to += i__;

/*        At the start of the loop, TO points to the element of XVALS */
/*        that will hold the last value associated with the Ith symbol. */

	for (j = i__; j >= 1; --j) {
	    xvals[(i__1 = to - 1) < 10000 && 0 <= i__1 ? i__1 : s_rnge("xvals"
		    , i__1, "f_symtbd__", (ftnlen)967)] = (doublereal) (i__ * 
		    -100 - j);
	    sypshd_(name__, &xvals[(i__1 = to - 1) < 10000 && 0 <= i__1 ? 
		    i__1 : s_rnge("xvals", i__1, "f_symtbd__", (ftnlen)969)], 
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
		s_rnge("synams", i__2, "f_symtbd__", (ftnlen)992)) * 45, 
		"=", xnames + ((i__3 = i__ - 1) < 100 && 0 <= i__3 ? i__3 : 
		s_rnge("xnames", i__3, "f_symtbd__", (ftnlen)992)) * 45, ok, (
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
    i__1 = cardd_(syvals);
    chcksi_("Card(SYVALS)", &i__1, "=", &xcard, &c__0, ok, (ftnlen)12, (
	    ftnlen)1);
    chckad_("SYVALS", &syvals[6], "=", xvals, &c__100, &c_b47, ok, (ftnlen)6, 
	    (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYDUPD test:  Create symbol table with array-valued symbols.  Th"
	    "en duplicate each symbol.", (ftnlen)89);
    scardc_(&c__0, synams, (ftnlen)45);
    scardi_(&c__0, syptrs);
    scardd_(&c__0, syvals);

/*     We'll set the cardinality upper bound UB to MAXTAB/2, so */
/*     we'll have room for the duplicate symbols. */

    to = 1;
    ub = 50;
    i__1 = ub;
    for (i__ = 1; i__ <= i__1; ++i__) {

/*        Create the symbol name. */

	t_ithsym__(&i__, &ub, name__, (ftnlen)45);
	s_copy(xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 : s_rnge(
		"xnames", i__2, "f_symtbd__", (ftnlen)1040)) * 45, name__, (
		ftnlen)45, (ftnlen)45);
	xptrs[(i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 : s_rnge("xptrs", 
		i__2, "f_symtbd__", (ftnlen)1041)] = i__;
	i__2 = i__;
	for (j = 1; j <= i__2; ++j) {
	    xvals[(i__3 = to - 1) < 10000 && 0 <= i__3 ? i__3 : s_rnge("xvals"
		    , i__3, "f_symtbd__", (ftnlen)1045)] = (doublereal) (-ub *
		     i__ - j);
	    syenqd_(name__, &xvals[(i__3 = to - 1) < 10000 && 0 <= i__3 ? 
		    i__3 : s_rnge("xvals", i__3, "f_symtbd__", (ftnlen)1047)],
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
		i__2 : s_rnge("xnames", i__2, "f_symtbd__", (ftnlen)1064)) * 
		45, title, (ftnlen)500, (ftnlen)1, (ftnlen)45, (ftnlen)500);
	sygetd_(xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 : s_rnge(
		"xnames", i__2, "f_symtbd__", (ftnlen)1066)) * 45, synams, 
		syptrs, syvals, &nvals, dvals, &found, (ftnlen)45, (ftnlen)45)
		;
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(title, &found, &c_true, ok, (ftnlen)500);
	if (found) {
	    s_copy(title, "Values of symbol # (0)", (ftnlen)500, (ftnlen)22);
	    repmc_(title, "#", xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ?
		     i__2 : s_rnge("xnames", i__2, "f_symtbd__", (ftnlen)1075)
		    ) * 45, title, (ftnlen)500, (ftnlen)1, (ftnlen)45, (
		    ftnlen)500);
	    chckad_(title, dvals, "=", &xvals[(i__2 = start - 1) < 10000 && 0 
		    <= i__2 ? i__2 : s_rnge("xvals", i__2, "f_symtbd__", (
		    ftnlen)1077)], &i__, &c_b47, ok, (ftnlen)500, (ftnlen)1);
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
	sydupd_(name__, newnam, synams, syptrs, syvals, (ftnlen)45, (ftnlen)
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
		i__2 : s_rnge("xnames", i__2, "f_symtbd__", (ftnlen)1112)) * 
		45, title, (ftnlen)500, (ftnlen)1, (ftnlen)45, (ftnlen)500);
	sygetd_(xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 : s_rnge(
		"xnames", i__2, "f_symtbd__", (ftnlen)1114)) * 45, synams, 
		syptrs, syvals, &nvals, dvals, &found, (ftnlen)45, (ftnlen)45)
		;
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(title, &found, &c_true, ok, (ftnlen)500);
	if (found) {
	    s_copy(title, "Values of symbol # (1)", (ftnlen)500, (ftnlen)22);
	    repmc_(title, "#", xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ?
		     i__2 : s_rnge("xnames", i__2, "f_symtbd__", (ftnlen)1123)
		    ) * 45, title, (ftnlen)500, (ftnlen)1, (ftnlen)45, (
		    ftnlen)500);
	    chckad_(title, dvals, "=", &xvals[(i__2 = start - 1) < 10000 && 0 
		    <= i__2 ? i__2 : s_rnge("xvals", i__2, "f_symtbd__", (
		    ftnlen)1125)], &i__, &c_b47, ok, (ftnlen)500, (ftnlen)1);
	}
	start += i__;
    }

/*     Now check the duplicate symbols. */

    start = 1;
    i__1 = ub;
    for (i__ = 1; i__ <= i__1; ++i__) {
	s_copy(newnam, xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 : 
		s_rnge("xnames", i__2, "f_symtbd__", (ftnlen)1140)) * 45, (
		ftnlen)45, (ftnlen)45);
	s_copy(newnam, "2_", (ftnlen)2, (ftnlen)2);
	s_copy(title, "Was name # found? (2)", (ftnlen)500, (ftnlen)21);
	repmc_(title, "#", newnam, title, (ftnlen)500, (ftnlen)1, (ftnlen)45, 
		(ftnlen)500);
	sygetd_(newnam, synams, syptrs, syvals, &nvals, dvals, &found, (
		ftnlen)45, (ftnlen)45);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(title, &found, &c_true, ok, (ftnlen)500);
	if (found) {
	    s_copy(title, "Values of symbol # (2)", (ftnlen)500, (ftnlen)22);
	    repmc_(title, "#", newnam, title, (ftnlen)500, (ftnlen)1, (ftnlen)
		    45, (ftnlen)500);
	    chckad_(title, dvals, "=", &xvals[(i__2 = start - 1) < 10000 && 0 
		    <= i__2 ? i__2 : s_rnge("xvals", i__2, "f_symtbd__", (
		    ftnlen)1157)], &i__, &c_b47, ok, (ftnlen)500, (ftnlen)1);
	}
	start += i__;
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("SYDUPD test:  Create symbol table with array-valued symbols.  Du"
	    "plicate these symbols.  Negate the values of the original symbol"
	    "s.  Then duplicate the duplicate the symbols, overwriting the or"
	    "iginal symbols.", (ftnlen)207);
    scardc_(&c__0, synams, (ftnlen)45);
    scardi_(&c__0, syptrs);
    scardd_(&c__0, syvals);

/*     We'll set the cardinality upper bound UB to MAXTAB/2, so */
/*     we'll have room for the duplicate symbols. */

    to = 1;
    ub = 50;
    i__1 = ub;
    for (i__ = 1; i__ <= i__1; ++i__) {

/*        Create the symbol name. */

	t_ithsym__(&i__, &ub, name__, (ftnlen)45);
	s_copy(xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 : s_rnge(
		"xnames", i__2, "f_symtbd__", (ftnlen)1192)) * 45, name__, (
		ftnlen)45, (ftnlen)45);
	xptrs[(i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 : s_rnge("xptrs", 
		i__2, "f_symtbd__", (ftnlen)1193)] = i__;
	i__2 = i__;
	for (j = 1; j <= i__2; ++j) {
	    xvals[(i__3 = to - 1) < 10000 && 0 <= i__3 ? i__3 : s_rnge("xvals"
		    , i__3, "f_symtbd__", (ftnlen)1197)] = (doublereal) (-ub *
		     i__ - j);
	    syenqd_(name__, &xvals[(i__3 = to - 1) < 10000 && 0 <= i__3 ? 
		    i__3 : s_rnge("xvals", i__3, "f_symtbd__", (ftnlen)1199)],
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
	sydupd_(name__, newnam, synams, syptrs, syvals, (ftnlen)45, (ftnlen)
		45, (ftnlen)45);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Negate the values of the symbols of the original symbols. */

    i__1 = ub;
    for (i__ = 1; i__ <= i__1; ++i__) {
	sygetd_(xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 : s_rnge(
		"xnames", i__2, "f_symtbd__", (ftnlen)1231)) * 45, synams, 
		syptrs, syvals, &nvals, dvals, &found, (ftnlen)45, (ftnlen)45)
		;
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	i__2 = nvals;
	for (j = 1; j <= i__2; ++j) {
	    dvals[(i__3 = j - 1) < 10000 && 0 <= i__3 ? i__3 : s_rnge("dvals",
		     i__3, "f_symtbd__", (ftnlen)1236)] = -dvals[(i__4 = j - 
		    1) < 10000 && 0 <= i__4 ? i__4 : s_rnge("dvals", i__4, 
		    "f_symtbd__", (ftnlen)1236)];
	}
	syputd_(xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 : s_rnge(
		"xnames", i__2, "f_symtbd__", (ftnlen)1239)) * 45, dvals, &
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
	sydupd_(newnam, name__, synams, syptrs, syvals, (ftnlen)45, (ftnlen)
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
	sygetd_(xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 : s_rnge(
		"xnames", i__2, "f_symtbd__", (ftnlen)1278)) * 45, synams, 
		syptrs, syvals, &nvals, dvals, &found, (ftnlen)45, (ftnlen)45)
		;
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(title, &found, &c_true, ok, (ftnlen)500);
	if (found) {
	    s_copy(title, "Values of symbol # (1)", (ftnlen)500, (ftnlen)22);
	    repmc_(title, "#", xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ?
		     i__2 : s_rnge("xnames", i__2, "f_symtbd__", (ftnlen)1287)
		    ) * 45, title, (ftnlen)500, (ftnlen)1, (ftnlen)45, (
		    ftnlen)500);
	    chckad_(title, dvals, "=", &xvals[(i__2 = start - 1) < 10000 && 0 
		    <= i__2 ? i__2 : s_rnge("xvals", i__2, "f_symtbd__", (
		    ftnlen)1289)], &i__, &c_b47, ok, (ftnlen)500, (ftnlen)1);
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
	sygetd_(xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 : s_rnge(
		"xnames", i__2, "f_symtbd__", (ftnlen)1307)) * 45, synams, 
		syptrs, syvals, &nvals, dvals, &found, (ftnlen)45, (ftnlen)45)
		;
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(title, &found, &c_true, ok, (ftnlen)500);
	if (found) {
	    s_copy(title, "Values of symbol # (2)", (ftnlen)500, (ftnlen)22);
	    repmc_(title, "#", newnam, title, (ftnlen)500, (ftnlen)1, (ftnlen)
		    45, (ftnlen)500);
	    chckad_(title, dvals, "=", &xvals[(i__2 = start - 1) < 10000 && 0 
		    <= i__2 ? i__2 : s_rnge("xvals", i__2, "f_symtbd__", (
		    ftnlen)1318)], &i__, &c_b47, ok, (ftnlen)500, (ftnlen)1);
	}
	start += i__;
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("SYORDD test:  Create symbol table with array-valued symbols; sor"
	    "t values associated with each symbol.", (ftnlen)101);
    scardc_(&c__0, synams, (ftnlen)45);
    scardi_(&c__0, syptrs);
    scardd_(&c__0, syvals);
    cleard_(&c__10000, xvals);

/*     Create the symbol table to be sorted. */

    for (i__ = 1; i__ <= 100; ++i__) {

/*        Create the symbol name. */

	t_ithsym__(&i__, &c__100, name__, (ftnlen)45);
	s_copy(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbd__", (ftnlen)1349)) * 45, name__, (
		ftnlen)45, (ftnlen)45);
	i__1 = i__;
	for (j = 1; j <= i__1; ++j) {
	    val = (doublereal) (i__ * -100 - j);
	    syenqd_(name__, &val, synams, syptrs, syvals, (ftnlen)45, (ftnlen)
		    45);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	}
    }

/*     Sort the symbol values. */

    for (i__ = 1; i__ <= 100; ++i__) {
	syordd_(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbd__", (ftnlen)1367)) * 45, synams, 
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
		    , i__2, "f_symtbd__", (ftnlen)1387)] = (doublereal) (i__ *
		     -100 - j);
	}
	start += i__;
    }

/*     Check the symbol table values against the value array. */

    chckad_("SYVALS", &syvals[6], "=", xvals, &c__100, &c_b47, ok, (ftnlen)6, 
	    (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYDIMD test:  Find dimensions of symbols in symbol table with ar"
	    "ray-valued symbols.", (ftnlen)83);
    scardc_(&c__0, synams, (ftnlen)45);
    scardi_(&c__0, syptrs);
    scardd_(&c__0, syvals);
    cleard_(&c__10000, xvals);
    for (i__ = 1; i__ <= 100; ++i__) {

/*        Create the symbol name. */

	t_ithsym__(&i__, &c__100, name__, (ftnlen)45);
	s_copy(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"xnames", i__1, "f_symtbd__", (ftnlen)1421)) * 45, name__, (
		ftnlen)45, (ftnlen)45);
	i__1 = i__;
	for (j = 1; j <= i__1; ++j) {
	    val = (doublereal) (i__ * -100 - j);
	    syenqd_(name__, &val, synams, syptrs, syvals, (ftnlen)45, (ftnlen)
		    45);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	}
    }
    for (i__ = 1; i__ <= 100; ++i__) {
	nvals = sydimd_(xnames + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 :
		 s_rnge("xnames", i__1, "f_symtbd__", (ftnlen)1436)) * 45, 
		synams, syptrs, syvals, (ftnlen)45, (ftnlen)45);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	s_copy(title, "Dimension of symbol #", (ftnlen)500, (ftnlen)21);
	repmi_(title, "#", &i__, title, (ftnlen)500, (ftnlen)1, (ftnlen)500);
	chcksi_(title, &nvals, "=", &i__, &c__0, ok, (ftnlen)500, (ftnlen)1);
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("SYPOPD test:  Pop values from symbol table with array-valued sym"
	    "bols.", (ftnlen)69);

/*     Re-create the default array-valued symbol table. */

    scardc_(&c__0, synams, (ftnlen)45);
    scardi_(&c__0, syptrs);
    scardd_(&c__0, syvals);
    for (i__ = 1; i__ <= 100; ++i__) {

/*        Create the symbol name. */

	t_ithsym__(&i__, &c__100, name__, (ftnlen)45);

/*        Set the values of the Ith symbol. */

	i__1 = i__;
	for (j = 1; j <= i__1; ++j) {
	    dvals[(i__2 = j - 1) < 10000 && 0 <= i__2 ? i__2 : s_rnge("dvals",
		     i__2, "f_symtbd__", (ftnlen)1472)] = (doublereal) (i__ * 
		    -100 - j);
	}

/*        Insert the Ith symbol. */

	syputd_(name__, dvals, &i__, synams, syptrs, syvals, (ftnlen)45, (
		ftnlen)45);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Now test SYPOPD. */

    to = 1;
    for (i__ = 1; i__ <= 100; ++i__) {

/*        Create the symbol name. */

	t_ithsym__(&i__, &c__100, name__, (ftnlen)45);
	xptrs[(i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge("xptrs", 
		i__1, "f_symtbd__", (ftnlen)1496)] = i__;
	i__1 = i__;
	for (j = 1; j <= i__1; ++j) {

/*           Set the expected value. */

	    xvals[(i__2 = to - 1) < 10000 && 0 <= i__2 ? i__2 : s_rnge("xvals"
		    , i__2, "f_symtbd__", (ftnlen)1502)] = (doublereal) (i__ *
		     -100 - j);
	    sypopd_(name__, synams, syptrs, syvals, &val, &found, (ftnlen)45, 
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
		chcksd_(title, &val, "=", &xvals[(i__2 = to - 1) < 10000 && 0 
			<= i__2 ? i__2 : s_rnge("xvals", i__2, "f_symtbd__", (
			ftnlen)1520)], &c_b47, ok, (ftnlen)500, (ftnlen)1);
	    }
	    ++to;
	}

/*        Try to pop a value from the now empty symbol. */

	sypopd_(name__, synams, syptrs, syvals, &val, &found, (ftnlen)45, (
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

    tcase_("SYTRND test:  Transpose values from symbol table with array-valu"
	    "ed symbols.", (ftnlen)75);

/*     We'll create a small version of our array-valued symbol table. */
/*     Since we want to try all possible transpositions, there would */
/*     be an excessive number of calls to SYTRND if we used the full */
/*     set of MAXTAB symbols. */

/*     Create the symbol table now. */

    scardc_(&c__0, synams, (ftnlen)45);
    scardi_(&c__0, syptrs);
    scardd_(&c__0, syvals);
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
		    , i__3, "f_symtbd__", (ftnlen)1579)] = (doublereal) (
		    -tabsiz * i__ - j);
	    ++to;
	}

/*        Insert the Ith symbol. */

	syputd_(name__, &xvals[(i__2 = start - 1) < 10000 && 0 <= i__2 ? i__2 
		: s_rnge("xvals", i__2, "f_symtbd__", (ftnlen)1587)], &i__, 
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
		sytrnd_(name__, &j, &k, synams, syptrs, syvals, (ftnlen)45, (
			ftnlen)45);
		chckxc_(&c_false, " ", ok, (ftnlen)1);

/*              Fetch the values of the modified symbol. */

		sygetd_(name__, synams, syptrs, syvals, &nvals, dvals, &found,
			 (ftnlen)45, (ftnlen)45);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		chcksl_(title, &found, &c_true, ok, (ftnlen)500);
		if (found) {

/*                 If DVALS reflects the correct transposition, */
/*                 then we can swap elements J and K of DVALS */
/*                 to obtain the original symbol's values. */

		    if (j != k) {
			swapd_(&dvals[(i__4 = j - 1) < 10000 && 0 <= i__4 ? 
				i__4 : s_rnge("dvals", i__4, "f_symtbd__", (
				ftnlen)1634)], &dvals[(i__5 = k - 1) < 10000 
				&& 0 <= i__5 ? i__5 : s_rnge("dvals", i__5, 
				"f_symtbd__", (ftnlen)1634)]);
		    }
		    s_copy(title, "Values of symbol #:  J = #; K = #", (
			    ftnlen)500, (ftnlen)33);
		    repmc_(title, "#", name__, title, (ftnlen)500, (ftnlen)1, 
			    (ftnlen)45, (ftnlen)500);
		    repmi_(title, "#", &j, title, (ftnlen)500, (ftnlen)1, (
			    ftnlen)500);
		    repmi_(title, "#", &k, title, (ftnlen)500, (ftnlen)1, (
			    ftnlen)500);
		    chckad_(title, dvals, "=", &xvals[(i__4 = start - 1) < 
			    10000 && 0 <= i__4 ? i__4 : s_rnge("xvals", i__4, 
			    "f_symtbd__", (ftnlen)1642)], &i__, &c_b47, ok, (
			    ftnlen)500, (ftnlen)1);
		}

/*              Undo the transposition in the symbol table. */

		sytrnd_(name__, &j, &k, synams, syptrs, syvals, (ftnlen)45, (
			ftnlen)45);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
	    }
	}

/*        Set the start index for the next symbol. */

	start += i__;
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("SYSELD test:  Extract slice of values from symbol table with arr"
	    "ay-valued symbols.", (ftnlen)82);

/*     This approach used in this test case closely parallels that */
/*     of the SYTRND test case above. */

/*     We'll create a small version of our array-valued symbol table. */
/*     Since we want to try all possible slices, there would */
/*     be an excessive number of calls to SYTRND if we used the full */
/*     set of MAXTAB symbols. */

/*     Create the symbol table now. */

    scardc_(&c__0, synams, (ftnlen)45);
    scardi_(&c__0, syptrs);
    scardd_(&c__0, syvals);
    cleard_(&c__10000, xvals);
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
		    , i__3, "f_symtbd__", (ftnlen)1707)] = (doublereal) (
		    -tabsiz * i__ - j);
	    ++to;
	}

/*        Insert the Ith symbol. */

	syputd_(name__, &xvals[(i__2 = start - 1) < 10000 && 0 <= i__2 ? i__2 
		: s_rnge("xvals", i__2, "f_symtbd__", (ftnlen)1715)], &i__, 
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

		syseld_(name__, &j, &k, synams, syptrs, syvals, dvals, &found,
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
		    chckad_(title, dvals, "=", &xvals[(i__4 = start + j - 2) <
			     10000 && 0 <= i__4 ? i__4 : s_rnge("xvals", i__4,
			     "f_symtbd__", (ftnlen)1763)], &i__5, &c_b47, ok, 
			    (ftnlen)500, (ftnlen)1);
		}
	    }
	}

/*        Set the start index for the next symbol. */

	start += i__;
    }

/*     Now for some error handling tests. */


/*     SYDELD:  No errors are detected by this routine. */

/*     SYDIMD:  No errors are detected by this routine. */


/*     SYDUPD: */

/* --- Case: ------------------------------------------------------ */

    tcase_("SYDUPD:  symbol name not present", (ftnlen)32);
    sydupd_("NOSYMBOL", "NOSYMBOL2", synams, syptrs, syvals, (ftnlen)8, (
	    ftnlen)9, (ftnlen)45);
    chckxc_(&c_true, "SPICE(NOSUCHSYMBOL)", ok, (ftnlen)19);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYDUPD:  name table overflow", (ftnlen)28);

/*     We'll create a small symbol table so we can test the handling of */
/*     overflow conditions. */

    tabsiz = 5;
    ssizec_(&tabsiz, synams, (ftnlen)45);
    i__1 = tabsiz << 1;
    ssizei_(&i__1, syptrs);
    i__1 = tabsiz << 1;
    ssized_(&i__1, syvals);
    i__1 = tabsiz;
    for (i__ = 1; i__ <= i__1; ++i__) {
	t_ithsym__(&i__, &tabsiz, name__, (ftnlen)45);
	d__1 = (doublereal) i__;
	sysetd_(name__, &d__1, synams, syptrs, syvals, (ftnlen)45, (ftnlen)45)
		;
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    sydupd_(name__, "NEWNAME", synams, syptrs, syvals, (ftnlen)45, (ftnlen)7, 
	    (ftnlen)45);
    chckxc_(&c_true, "SPICE(NAMETABLEFULL)", ok, (ftnlen)20);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYDUPD:  pointer table overflow", (ftnlen)31);
    i__1 = tabsiz + 1;
    ssizec_(&i__1, synams, (ftnlen)45);
    ssizei_(&tabsiz, syptrs);
    i__1 = tabsiz + 2;
    ssized_(&i__1, syvals);
    i__1 = tabsiz;
    for (i__ = 1; i__ <= i__1; ++i__) {
	t_ithsym__(&i__, &tabsiz, name__, (ftnlen)45);
	d__1 = (doublereal) i__;
	sysetd_(name__, &d__1, synams, syptrs, syvals, (ftnlen)45, (ftnlen)45)
		;
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    sydupd_(name__, "NEWNAME", synams, syptrs, syvals, (ftnlen)45, (ftnlen)7, 
	    (ftnlen)45);
    chckxc_(&c_true, "SPICE(POINTERTABLEFULL)", ok, (ftnlen)23);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYDUPD:  value table overflow", (ftnlen)29);
    i__1 = tabsiz + 1;
    ssizec_(&i__1, synams, (ftnlen)45);
    i__1 = tabsiz + 1;
    ssizei_(&i__1, syptrs);
    ssized_(&tabsiz, syvals);
    i__1 = tabsiz;
    for (i__ = 1; i__ <= i__1; ++i__) {
	t_ithsym__(&i__, &tabsiz, name__, (ftnlen)45);
	d__1 = (doublereal) i__;
	sysetd_(name__, &d__1, synams, syptrs, syvals, (ftnlen)45, (ftnlen)45)
		;
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    sydupd_(name__, "NEWNAME", synams, syptrs, syvals, (ftnlen)45, (ftnlen)7, 
	    (ftnlen)45);
    chckxc_(&c_true, "SPICE(VALUETABLEFULL)", ok, (ftnlen)21);


/*     SYENQD: */

/* --- Case: ------------------------------------------------------ */

    tcase_("SYENQD:  value table overflow", (ftnlen)29);
    tabsiz = 5;
    ssizec_(&tabsiz, synams, (ftnlen)45);
    ssizei_(&tabsiz, syptrs);
    ssized_(&tabsiz, syvals);
    i__1 = tabsiz;
    for (i__ = 1; i__ <= i__1; ++i__) {
	t_ithsym__(&i__, &tabsiz, name__, (ftnlen)45);
	d__1 = (doublereal) i__;
	sysetd_(name__, &d__1, synams, syptrs, syvals, (ftnlen)45, (ftnlen)45)
		;
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Enqueue a value onto the last symbol. */

    syenqd_(name__, &c_b708, synams, syptrs, syvals, (ftnlen)45, (ftnlen)45);
    chckxc_(&c_true, "SPICE(VALUETABLEFULL)", ok, (ftnlen)21);



/*     SYFETD:  No errors are detected by this routine. */

/*     SYGETD:  No errors are detected by this routine. */

/*     SYNTHD:  No errors are detected by this routine. */

/*     SYORDD:  No errors are detected by this routine. */

/*     SYPOPD:  No errors are detected by this routine. */



/*     SYPSHD: */

/* --- Case: ------------------------------------------------------ */


    tcase_("SYPSHD:  value table overflow", (ftnlen)29);
    tabsiz = 5;
    ssizec_(&tabsiz, synams, (ftnlen)45);
    ssizei_(&tabsiz, syptrs);
    ssized_(&tabsiz, syvals);
    i__1 = tabsiz;
    for (i__ = 1; i__ <= i__1; ++i__) {
	t_ithsym__(&i__, &tabsiz, name__, (ftnlen)45);
	d__1 = (doublereal) i__;
	sysetd_(name__, &d__1, synams, syptrs, syvals, (ftnlen)45, (ftnlen)45)
		;
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Push a value onto the last symbol. */

    sypshd_(name__, &c_b708, synams, syptrs, syvals, (ftnlen)45, (ftnlen)45);
    chckxc_(&c_true, "SPICE(VALUETABLEFULL)", ok, (ftnlen)21);

/*     SYPUTD: */


/* --- Case: ------------------------------------------------------ */

    tcase_("SYPUTD:  name table overflow", (ftnlen)28);

/*     We'll create a small symbol table so we can test the handling of */
/*     overflow conditions. */

    tabsiz = 5;
    ssizec_(&tabsiz, synams, (ftnlen)45);
    i__1 = tabsiz << 1;
    ssizei_(&i__1, syptrs);
    i__1 = tabsiz << 1;
    ssized_(&i__1, syvals);
    i__1 = tabsiz;
    for (i__ = 1; i__ <= i__1; ++i__) {
	t_ithsym__(&i__, &tabsiz, name__, (ftnlen)45);
	d__1 = (doublereal) i__;
	sysetd_(name__, &d__1, synams, syptrs, syvals, (ftnlen)45, (ftnlen)45)
		;
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    d__1 = (doublereal) i__;
    syputd_("NEWNAME", &d__1, &c__1, synams, syptrs, syvals, (ftnlen)7, (
	    ftnlen)45);
    chckxc_(&c_true, "SPICE(NAMETABLEFULL)", ok, (ftnlen)20);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYPUTD:  pointer table overflow", (ftnlen)31);
    i__1 = tabsiz + 1;
    ssizec_(&i__1, synams, (ftnlen)45);
    ssizei_(&tabsiz, syptrs);
    i__1 = tabsiz + 2;
    ssized_(&i__1, syvals);
    i__1 = tabsiz;
    for (i__ = 1; i__ <= i__1; ++i__) {
	t_ithsym__(&i__, &tabsiz, name__, (ftnlen)45);
	d__1 = (doublereal) i__;
	sysetd_(name__, &d__1, synams, syptrs, syvals, (ftnlen)45, (ftnlen)45)
		;
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    d__1 = (doublereal) i__;
    syputd_("NEWNAME", &d__1, &c__1, synams, syptrs, syvals, (ftnlen)7, (
	    ftnlen)45);
    chckxc_(&c_true, "SPICE(POINTERTABLEFULL)", ok, (ftnlen)23);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYPUTD:  value table overflow", (ftnlen)29);
    i__1 = tabsiz + 1;
    ssizec_(&i__1, synams, (ftnlen)45);
    i__1 = tabsiz + 1;
    ssizei_(&i__1, syptrs);
    ssized_(&tabsiz, syvals);
    i__1 = tabsiz;
    for (i__ = 1; i__ <= i__1; ++i__) {
	t_ithsym__(&i__, &tabsiz, name__, (ftnlen)45);
	d__1 = (doublereal) i__;
	sysetd_(name__, &d__1, synams, syptrs, syvals, (ftnlen)45, (ftnlen)45)
		;
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    d__1 = (doublereal) i__;
    syputd_("NEWNAME", &d__1, &c__1, synams, syptrs, syvals, (ftnlen)7, (
	    ftnlen)45);
    chckxc_(&c_true, "SPICE(VALUETABLEFULL)", ok, (ftnlen)21);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYPUTD: invalid value count", (ftnlen)27);
    i__1 = tabsiz + 1;
    ssizec_(&i__1, synams, (ftnlen)45);
    i__1 = tabsiz + 1;
    ssizei_(&i__1, syptrs);
    i__1 = tabsiz + 1;
    ssized_(&i__1, syvals);
    i__1 = tabsiz;
    for (i__ = 1; i__ <= i__1; ++i__) {
	t_ithsym__(&i__, &tabsiz, name__, (ftnlen)45);
	d__1 = (doublereal) i__;
	sysetd_(name__, &d__1, synams, syptrs, syvals, (ftnlen)45, (ftnlen)45)
		;
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    d__1 = (doublereal) i__;
    syputd_("NEWNAME", &d__1, &c_n1, synams, syptrs, syvals, (ftnlen)7, (
	    ftnlen)45);
    chckxc_(&c_true, "SPICE(INVALIDARGUMENT)", ok, (ftnlen)22);

/*     SYREND: */


/* --- Case: ------------------------------------------------------ */

    tcase_("SYREND:  rename non-existent symbol", (ftnlen)35);
    syrend_("NONNAME", "NEWNAME", synams, syptrs, syvals, (ftnlen)7, (ftnlen)
	    7, (ftnlen)45);
    chckxc_(&c_true, "SPICE(NOSUCHSYMBOL)", ok, (ftnlen)19);


/*     SYSELD:  No errors are detected by this routine. */


/*     SYSETD: */

/* --- Case: ------------------------------------------------------ */

    tcase_("SYSETD:  name table overflow", (ftnlen)28);

/*     We'll create a small symbol table so we can test the handling of */
/*     overflow conditions. */

    tabsiz = 5;
    ssizec_(&tabsiz, synams, (ftnlen)45);
    i__1 = tabsiz << 1;
    ssizei_(&i__1, syptrs);
    i__1 = tabsiz << 1;
    ssized_(&i__1, syvals);
    i__1 = tabsiz;
    for (i__ = 1; i__ <= i__1; ++i__) {
	t_ithsym__(&i__, &tabsiz, name__, (ftnlen)45);
	d__1 = (doublereal) i__;
	sysetd_(name__, &d__1, synams, syptrs, syvals, (ftnlen)45, (ftnlen)45)
		;
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    d__1 = (doublereal) i__;
    sysetd_("NEWNAME", &d__1, synams, syptrs, syvals, (ftnlen)7, (ftnlen)45);
    chckxc_(&c_true, "SPICE(NAMETABLEFULL)", ok, (ftnlen)20);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYSETD:  pointer table overflow", (ftnlen)31);
    i__1 = tabsiz + 1;
    ssizec_(&i__1, synams, (ftnlen)45);
    ssizei_(&tabsiz, syptrs);
    i__1 = tabsiz + 2;
    ssized_(&i__1, syvals);
    i__1 = tabsiz;
    for (i__ = 1; i__ <= i__1; ++i__) {
	t_ithsym__(&i__, &tabsiz, name__, (ftnlen)45);
	d__1 = (doublereal) i__;
	sysetd_(name__, &d__1, synams, syptrs, syvals, (ftnlen)45, (ftnlen)45)
		;
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    d__1 = (doublereal) i__;
    sysetd_("NEWNAME", &d__1, synams, syptrs, syvals, (ftnlen)7, (ftnlen)45);
    chckxc_(&c_true, "SPICE(POINTERTABLEFULL)", ok, (ftnlen)23);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYSETD:  value table overflow", (ftnlen)29);
    i__1 = tabsiz + 1;
    ssizec_(&i__1, synams, (ftnlen)45);
    i__1 = tabsiz + 1;
    ssizei_(&i__1, syptrs);
    ssized_(&tabsiz, syvals);
    i__1 = tabsiz;
    for (i__ = 1; i__ <= i__1; ++i__) {
	t_ithsym__(&i__, &tabsiz, name__, (ftnlen)45);
	d__1 = (doublereal) i__;
	sysetd_(name__, &d__1, synams, syptrs, syvals, (ftnlen)45, (ftnlen)45)
		;
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    d__1 = (doublereal) i__;
    sysetd_("NEWNAME", &d__1, synams, syptrs, syvals, (ftnlen)7, (ftnlen)45);
    chckxc_(&c_true, "SPICE(VALUETABLEFULL)", ok, (ftnlen)21);
/*     SYTRND: */

/* --- Case: ------------------------------------------------------ */

    tcase_("SYTRND:  first index < 1", (ftnlen)24);
    ssizec_(&tabsiz, synams, (ftnlen)45);
    ssizei_(&tabsiz, syptrs);
    ssized_(&tabsiz, syvals);
    i__1 = tabsiz;
    for (i__ = 1; i__ <= i__1; ++i__) {
	t_ithsym__(&i__, &tabsiz, name__, (ftnlen)45);
	d__1 = (doublereal) i__;
	sysetd_(name__, &d__1, synams, syptrs, syvals, (ftnlen)45, (ftnlen)45)
		;
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	s_copy(xnames + ((i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 : s_rnge(
		"xnames", i__2, "f_symtbd__", (ftnlen)2184)) * 45, name__, (
		ftnlen)45, (ftnlen)45);
	xptrs[(i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 : s_rnge("xptrs", 
		i__2, "f_symtbd__", (ftnlen)2185)] = 1;
	xvals[(i__2 = i__ - 1) < 10000 && 0 <= i__2 ? i__2 : s_rnge("xvals", 
		i__2, "f_symtbd__", (ftnlen)2186)] = (doublereal) i__;
    }
    sytrnd_(name__, &c_n1, &c__2, synams, syptrs, syvals, (ftnlen)45, (ftnlen)
	    45);
    chckxc_(&c_true, "SPICE(INVALIDINDEX)", ok, (ftnlen)19);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYTRND:  first index > second index", (ftnlen)35);
    sytrnd_(name__, &c__2, &c__1, synams, syptrs, syvals, (ftnlen)45, (ftnlen)
	    45);
    chckxc_(&c_true, "SPICE(INVALIDINDEX)", ok, (ftnlen)19);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYTRND:  second index > symbol size", (ftnlen)35);
    i__1 = tabsiz + 1;
    sytrnd_(name__, &c__1, &i__1, synams, syptrs, syvals, (ftnlen)45, (ftnlen)
	    45);
    chckxc_(&c_true, "SPICE(INVALIDINDEX)", ok, (ftnlen)19);

/* --- Case: ------------------------------------------------------ */

    tcase_("SYTRND:  non-error case: attempt transposition of values of non-"
	    "existent symbol.", (ftnlen)80);
    sytrnd_("NONAME", &c__1, &c__1, synams, syptrs, syvals, (ftnlen)6, (
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
		s_rnge("synams", i__2, "f_symtbd__", (ftnlen)2236)) * 45, 
		"=", xnames + ((i__3 = i__ - 1) < 100 && 0 <= i__3 ? i__3 : 
		s_rnge("xnames", i__3, "f_symtbd__", (ftnlen)2236)) * 45, ok, 
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

    i__1 = cardd_(syvals);
    chcksi_("Card(SYVALS)", &i__1, "=", &tabsiz, &c__0, ok, (ftnlen)12, (
	    ftnlen)1);
    chckad_("SYVALS", &syvals[6], "=", xvals, &tabsiz, &c_b47, ok, (ftnlen)6, 
	    (ftnlen)1);

/*     That's all, folks! */


/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_symtbd__ */

