/* f_insert.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__100 = 100;
static logical c_false = FALSE_;
static integer c__0 = 0;
static logical c_true = TRUE_;
static integer c__200 = 200;
static doublereal c_b95 = 0.;
static integer c__301 = 301;
static integer c__300 = 300;

/* $Procedure F_INSERT ( SPICE set insertion tests ) */
/* Subroutine */ int f_insert__(logical *ok)
{
    /* System generated locals */
    integer i__1, i__2, i__3;
    doublereal d__1;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    integer card;
    char cset[30*306];
    doublereal dset[206];
    integer iset[106];
    extern /* Subroutine */ int t_ithsym__(integer *, integer *, char *, 
	    ftnlen);
    integer i__;
    extern integer cardc_(char *, ftnlen), cardd_(doublereal *);
    integer n;
    extern integer cardi_(integer *);
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    char cvals[30*301], title[240];
    extern /* Subroutine */ int topen_(char *, ftnlen), t_success__(logical *)
	    , chckac_(char *, char *, char *, char *, integer *, logical *, 
	    ftnlen, ftnlen, ftnlen, ftnlen), chckad_(char *, doublereal *, 
	    char *, doublereal *, integer *, doublereal *, logical *, ftnlen, 
	    ftnlen), chckai_(char *, integer *, char *, integer *, integer *, 
	    logical *, ftnlen, ftnlen), chckxc_(logical *, char *, logical *, 
	    ftnlen), chcksi_(char *, integer *, char *, integer *, integer *, 
	    logical *, ftnlen, ftnlen);
    char xitemc[30*300];
    doublereal xitemd[200];
    char lnvals[80*300];
    integer xitemi[100];
    extern /* Subroutine */ int ssized_(integer *, doublereal *), ssizec_(
	    integer *, char *, ftnlen), insrtd_(doublereal *, doublereal *), 
	    suffix_(char *, integer *, char *, ftnlen, ftnlen), ssizei_(
	    integer *, integer *), insrtc_(char *, char *, ftnlen, ftnlen), 
	    insrti_(integer *, integer *);

/* $ Abstract */

/*     Exercise SPICELIB set insertion routines. */

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

/*     This routine tests the SPICELIB set insertion routines: */

/*        INSRTC */
/*        INSRTD */
/*        INSRTI */

/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     N.J. Bachman     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    TSPICE Version 1.0.0, 09-NOV-2005 (NJB) */


/* -& */

/*     SPICELIB functions */


/*     Local Parameters */


/*     Local Variables */


/*     Saved values */


/*     Initial values */


/*     Open the test family. */

    topen_("F_INSERT", (ftnlen)8);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "INSRTI test:  insert distinct elements in order.", (ftnlen)
	    240, (ftnlen)48);
    tcase_(title, (ftnlen)240);
    ssizei_(&c__100, iset);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    card = 100;
    i__1 = card;
    for (i__ = 1; i__ <= i__1; ++i__) {
	insrti_(&i__, iset);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	xitemi[(i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 : s_rnge("xitemi", 
		i__2, "f_insert__", (ftnlen)191)] = i__;
    }
    n = cardi_(iset);
    chcksi_("N", &n, "=", &card, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckai_("ITEMS", &iset[6], "=", xitemi, &n, ok, (ftnlen)5, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "INSRTI test:  insert non-distinct elements in order.", (
	    ftnlen)240, (ftnlen)52);
    tcase_(title, (ftnlen)240);
    ssizei_(&c__100, iset);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    card = 100;
    i__1 = card;
    for (i__ = 1; i__ <= i__1; ++i__) {
	insrti_(&i__, iset);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	insrti_(&i__, iset);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	xitemi[(i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 : s_rnge("xitemi", 
		i__2, "f_insert__", (ftnlen)221)] = i__;
    }
    n = cardi_(iset);
    chcksi_("N", &n, "=", &card, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckai_("ITEMS", &iset[6], "=", xitemi, &n, ok, (ftnlen)5, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "INSRTI test:  insert distinct elements in reverse order.", 
	    (ftnlen)240, (ftnlen)56);
    tcase_(title, (ftnlen)240);
    ssizei_(&c__100, iset);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    card = 100;
    for (i__ = card; i__ >= 1; --i__) {
	insrti_(&i__, iset);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	xitemi[(i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge("xitemi", 
		i__1, "f_insert__", (ftnlen)250)] = i__;
    }
    n = cardi_(iset);
    chcksi_("N", &n, "=", &card, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckai_("ITEMS", &iset[6], "=", xitemi, &n, ok, (ftnlen)5, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "INSRTI test:  insert non-distinct elements in reverse ord"
	    "er.", (ftnlen)240, (ftnlen)60);
    tcase_(title, (ftnlen)240);
    ssizei_(&c__100, iset);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    card = 100;
    for (i__ = card; i__ >= 1; --i__) {
	insrti_(&i__, iset);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	insrti_(&i__, iset);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	xitemi[(i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge("xitemi", 
		i__1, "f_insert__", (ftnlen)283)] = i__;
    }
    n = cardi_(iset);
    chcksi_("N", &n, "=", &card, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckai_("ITEMS", &iset[6], "=", xitemi, &n, ok, (ftnlen)5, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "INSRTI test:  insert non-distinct elements in non-sequent"
	    "ial order.", (ftnlen)240, (ftnlen)67);
    tcase_(title, (ftnlen)240);
    ssizei_(&c__100, iset);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    card = 100;
    i__1 = card;
    for (i__ = 1; i__ <= i__1; ++i__) {
	i__2 = card + 1 - i__;
	insrti_(&i__2, iset);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	insrti_(&i__, iset);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	xitemi[(i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 : s_rnge("xitemi", 
		i__2, "f_insert__", (ftnlen)315)] = i__;
    }
    n = cardi_(iset);
    chcksi_("N", &n, "=", &card, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckai_("ITEMS", &iset[6], "=", xitemi, &n, ok, (ftnlen)5, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("INSRTI error case:  set overflow.", (ftnlen)33);
    ssizei_(&c__100, iset);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    card = 100;
    i__1 = card;
    for (i__ = 1; i__ <= i__1; ++i__) {
	insrti_(&i__, iset);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    i__1 = card + 1;
    insrti_(&i__1, iset);
    chckxc_(&c_true, "SPICE(SETEXCESS)", ok, (ftnlen)16);
/* ************************************************************* */


/*     INSRTD tests follow. */


/* ************************************************************* */

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "INSRTD test:  insert distinct elements in order.", (ftnlen)
	    240, (ftnlen)48);
    tcase_(title, (ftnlen)240);
    ssized_(&c__200, dset);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    card = 200;
    i__1 = card;
    for (i__ = 1; i__ <= i__1; ++i__) {
	d__1 = (doublereal) i__;
	insrtd_(&d__1, dset);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	xitemd[(i__2 = i__ - 1) < 200 && 0 <= i__2 ? i__2 : s_rnge("xitemd", 
		i__2, "f_insert__", (ftnlen)373)] = (doublereal) i__;
    }
    n = cardd_(dset);
    chcksi_("N", &n, "=", &card, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckad_("ITEMS", &dset[6], "=", xitemd, &n, &c_b95, ok, (ftnlen)5, (
	    ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "INSRTD test:  insert non-distinct elements in order.", (
	    ftnlen)240, (ftnlen)52);
    tcase_(title, (ftnlen)240);
    ssized_(&c__200, dset);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    card = 200;
    i__1 = card;
    for (i__ = 1; i__ <= i__1; ++i__) {
	d__1 = (doublereal) i__;
	insrtd_(&d__1, dset);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	d__1 = (doublereal) i__;
	insrtd_(&d__1, dset);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	xitemd[(i__2 = i__ - 1) < 200 && 0 <= i__2 ? i__2 : s_rnge("xitemd", 
		i__2, "f_insert__", (ftnlen)403)] = (doublereal) i__;
    }
    n = cardd_(dset);
    chcksi_("N", &n, "=", &card, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckad_("ITEMS", &dset[6], "=", xitemd, &n, &c_b95, ok, (ftnlen)5, (
	    ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "INSRTD test:  insert distinct elements in reverse order.", 
	    (ftnlen)240, (ftnlen)56);
    tcase_(title, (ftnlen)240);
    ssized_(&c__200, dset);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    card = 200;
    for (i__ = card; i__ >= 1; --i__) {
	d__1 = (doublereal) i__;
	insrtd_(&d__1, dset);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	xitemd[(i__1 = i__ - 1) < 200 && 0 <= i__1 ? i__1 : s_rnge("xitemd", 
		i__1, "f_insert__", (ftnlen)432)] = (doublereal) i__;
    }
    n = cardd_(dset);
    chcksi_("N", &n, "=", &card, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckad_("ITEMS", &dset[6], "=", xitemd, &n, &c_b95, ok, (ftnlen)5, (
	    ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "INSRTD test:  insert non-distinct elements in reverse ord"
	    "er.", (ftnlen)240, (ftnlen)60);
    tcase_(title, (ftnlen)240);
    ssized_(&c__200, dset);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    card = 200;
    for (i__ = card; i__ >= 1; --i__) {
	d__1 = (doublereal) i__;
	insrtd_(&d__1, dset);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	d__1 = (doublereal) i__;
	insrtd_(&d__1, dset);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	xitemd[(i__1 = i__ - 1) < 200 && 0 <= i__1 ? i__1 : s_rnge("xitemd", 
		i__1, "f_insert__", (ftnlen)465)] = (doublereal) i__;
    }
    n = cardd_(dset);
    chcksi_("N", &n, "=", &card, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckad_("ITEMS", &dset[6], "=", xitemd, &n, &c_b95, ok, (ftnlen)5, (
	    ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "INSRTD test:  insert non-distinct elements in non-sequent"
	    "ial order.", (ftnlen)240, (ftnlen)67);
    tcase_(title, (ftnlen)240);
    ssized_(&c__200, dset);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    card = 200;
    i__1 = card;
    for (i__ = 1; i__ <= i__1; ++i__) {
	d__1 = (doublereal) (card + 1 - i__);
	insrtd_(&d__1, dset);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	d__1 = (doublereal) i__;
	insrtd_(&d__1, dset);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	xitemd[(i__2 = i__ - 1) < 200 && 0 <= i__2 ? i__2 : s_rnge("xitemd", 
		i__2, "f_insert__", (ftnlen)497)] = (doublereal) i__;
    }
    n = cardd_(dset);
    chcksi_("N", &n, "=", &card, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckad_("ITEMS", &dset[6], "=", xitemd, &n, &c_b95, ok, (ftnlen)5, (
	    ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("INSRTD error case:  set overflow.", (ftnlen)33);
    ssized_(&c__200, dset);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    card = 200;
    i__1 = card;
    for (i__ = 1; i__ <= i__1; ++i__) {
	d__1 = (doublereal) i__;
	insrtd_(&d__1, dset);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    d__1 = (doublereal) (card + 1);
    insrtd_(&d__1, dset);
    chckxc_(&c_true, "SPICE(SETEXCESS)", ok, (ftnlen)16);
/* ************************************************************* */


/*     INSRTC tests follow. */


/* ************************************************************* */

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "INSRTC test:  insert distinct elements in order.", (ftnlen)
	    240, (ftnlen)48);
    tcase_(title, (ftnlen)240);

/*     Create an array of character set values to be used in place */
/*     of the numeric values used in the preceding tests. */

    for (i__ = 1; i__ <= 300; ++i__) {

/*        See the description of T_ITHSYM at the bottom of this file. */

	t_ithsym__(&i__, &c__301, cvals + ((i__1 = i__ - 1) < 301 && 0 <= 
		i__1 ? i__1 : s_rnge("cvals", i__1, "f_insert__", (ftnlen)554)
		) * 30, (ftnlen)30);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        For each element of CVALS, create a longer string that agrees */
/*        with the first ITMWID characters of the element. */

	s_copy(lnvals + ((i__1 = i__ - 1) < 300 && 0 <= i__1 ? i__1 : s_rnge(
		"lnvals", i__1, "f_insert__", (ftnlen)560)) * 80, cvals + ((
		i__2 = i__ - 1) < 301 && 0 <= i__2 ? i__2 : s_rnge("cvals", 
		i__2, "f_insert__", (ftnlen)560)) * 30, (ftnlen)80, (ftnlen)
		30);
	suffix_("YYY", &c__0, lnvals + ((i__1 = i__ - 1) < 300 && 0 <= i__1 ? 
		i__1 : s_rnge("lnvals", i__1, "f_insert__", (ftnlen)562)) * 
		80, (ftnlen)3, (ftnlen)80);
    }

/*     Create one extra element of CVALS, which will be used later. */

    t_ithsym__(&c__301, &c__301, cvals + 9000, (ftnlen)30);
    ssizec_(&c__300, cset, (ftnlen)30);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    card = 300;
    i__1 = card;
    for (i__ = 1; i__ <= i__1; ++i__) {
	insrtc_(cvals + ((i__2 = i__ - 1) < 301 && 0 <= i__2 ? i__2 : s_rnge(
		"cvals", i__2, "f_insert__", (ftnlen)579)) * 30, cset, (
		ftnlen)30, (ftnlen)30);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	s_copy(xitemc + ((i__2 = i__ - 1) < 300 && 0 <= i__2 ? i__2 : s_rnge(
		"xitemc", i__2, "f_insert__", (ftnlen)582)) * 30, cvals + ((
		i__3 = i__ - 1) < 301 && 0 <= i__3 ? i__3 : s_rnge("cvals", 
		i__3, "f_insert__", (ftnlen)582)) * 30, (ftnlen)30, (ftnlen)
		30);
    }
    n = cardc_(cset, (ftnlen)30);
    chcksi_("N", &n, "=", &card, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckac_("ITEMS", cset + 180, "=", xitemc, &n, ok, (ftnlen)5, (ftnlen)30, (
	    ftnlen)1, (ftnlen)30);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "INSRTC test:  insert non-distinct elements in order.", (
	    ftnlen)240, (ftnlen)52);
    tcase_(title, (ftnlen)240);
    ssizec_(&c__300, cset, (ftnlen)30);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    card = 300;
    i__1 = card;
    for (i__ = 1; i__ <= i__1; ++i__) {
	insrtc_(cvals + ((i__2 = i__ - 1) < 301 && 0 <= i__2 ? i__2 : s_rnge(
		"cvals", i__2, "f_insert__", (ftnlen)606)) * 30, cset, (
		ftnlen)30, (ftnlen)30);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	insrtc_(cvals + ((i__2 = i__ - 1) < 301 && 0 <= i__2 ? i__2 : s_rnge(
		"cvals", i__2, "f_insert__", (ftnlen)609)) * 30, cset, (
		ftnlen)30, (ftnlen)30);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	s_copy(xitemc + ((i__2 = i__ - 1) < 300 && 0 <= i__2 ? i__2 : s_rnge(
		"xitemc", i__2, "f_insert__", (ftnlen)612)) * 30, cvals + ((
		i__3 = i__ - 1) < 301 && 0 <= i__3 ? i__3 : s_rnge("cvals", 
		i__3, "f_insert__", (ftnlen)612)) * 30, (ftnlen)30, (ftnlen)
		30);
    }
    n = cardc_(cset, (ftnlen)30);
    chcksi_("N", &n, "=", &card, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckac_("ITEMS", cset + 180, "=", xitemc, &n, ok, (ftnlen)5, (ftnlen)30, (
	    ftnlen)1, (ftnlen)30);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "INSRTC test:  insert non-distinct elements in order. This"
	    " time use duplicate elements that disagree with the set elements"
	    " only at positions past the string length of the set.", (ftnlen)
	    240, (ftnlen)174);
    tcase_(title, (ftnlen)240);
    ssizec_(&c__300, cset, (ftnlen)30);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    card = 300;
    i__1 = card;
    for (i__ = 1; i__ <= i__1; ++i__) {
	insrtc_(cvals + ((i__2 = i__ - 1) < 301 && 0 <= i__2 ? i__2 : s_rnge(
		"cvals", i__2, "f_insert__", (ftnlen)640)) * 30, cset, (
		ftnlen)30, (ftnlen)30);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	insrtc_(lnvals + ((i__2 = i__ - 1) < 300 && 0 <= i__2 ? i__2 : s_rnge(
		"lnvals", i__2, "f_insert__", (ftnlen)643)) * 80, cset, (
		ftnlen)80, (ftnlen)30);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	s_copy(xitemc + ((i__2 = i__ - 1) < 300 && 0 <= i__2 ? i__2 : s_rnge(
		"xitemc", i__2, "f_insert__", (ftnlen)646)) * 30, cvals + ((
		i__3 = i__ - 1) < 301 && 0 <= i__3 ? i__3 : s_rnge("cvals", 
		i__3, "f_insert__", (ftnlen)646)) * 30, (ftnlen)30, (ftnlen)
		30);
    }
    n = cardc_(cset, (ftnlen)30);
    chcksi_("N", &n, "=", &card, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckac_("ITEMS", cset + 180, "=", xitemc, &n, ok, (ftnlen)5, (ftnlen)30, (
	    ftnlen)1, (ftnlen)30);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "INSRTC test:  insert distinct elements in reverse order.", 
	    (ftnlen)240, (ftnlen)56);
    tcase_(title, (ftnlen)240);
    ssizec_(&c__300, cset, (ftnlen)30);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    card = 300;
    for (i__ = card; i__ >= 1; --i__) {
	insrtc_(cvals + ((i__1 = i__ - 1) < 301 && 0 <= i__1 ? i__1 : s_rnge(
		"cvals", i__1, "f_insert__", (ftnlen)672)) * 30, cset, (
		ftnlen)30, (ftnlen)30);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	s_copy(xitemc + ((i__1 = i__ - 1) < 300 && 0 <= i__1 ? i__1 : s_rnge(
		"xitemc", i__1, "f_insert__", (ftnlen)675)) * 30, cvals + ((
		i__2 = i__ - 1) < 301 && 0 <= i__2 ? i__2 : s_rnge("cvals", 
		i__2, "f_insert__", (ftnlen)675)) * 30, (ftnlen)30, (ftnlen)
		30);
    }
    n = cardc_(cset, (ftnlen)30);
    chcksi_("N", &n, "=", &card, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckac_("ITEMS", cset + 180, "=", xitemc, &n, ok, (ftnlen)5, (ftnlen)30, (
	    ftnlen)1, (ftnlen)30);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "INSRTC test:  insert non-distinct elements in reverse ord"
	    "er. This time use duplicate elements that disagree with the set "
	    "elements only at positions past the string length of the set.", (
	    ftnlen)240, (ftnlen)182);
    tcase_(title, (ftnlen)240);
    ssizec_(&c__300, cset, (ftnlen)30);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    card = 300;
    for (i__ = card; i__ >= 1; --i__) {
	insrtc_(cvals + ((i__1 = i__ - 1) < 301 && 0 <= i__1 ? i__1 : s_rnge(
		"cvals", i__1, "f_insert__", (ftnlen)705)) * 30, cset, (
		ftnlen)30, (ftnlen)30);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	insrtc_(lnvals + ((i__1 = i__ - 1) < 300 && 0 <= i__1 ? i__1 : s_rnge(
		"lnvals", i__1, "f_insert__", (ftnlen)708)) * 80, cset, (
		ftnlen)80, (ftnlen)30);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	s_copy(xitemc + ((i__1 = i__ - 1) < 300 && 0 <= i__1 ? i__1 : s_rnge(
		"xitemc", i__1, "f_insert__", (ftnlen)711)) * 30, cvals + ((
		i__2 = i__ - 1) < 301 && 0 <= i__2 ? i__2 : s_rnge("cvals", 
		i__2, "f_insert__", (ftnlen)711)) * 30, (ftnlen)30, (ftnlen)
		30);
    }
    n = cardc_(cset, (ftnlen)30);
    chcksi_("N", &n, "=", &card, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckac_("ITEMS", cset + 180, "=", xitemc, &n, ok, (ftnlen)5, (ftnlen)30, (
	    ftnlen)1, (ftnlen)30);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "INSRTC test:  insert non-distinct elements in non-sequent"
	    "ial order.", (ftnlen)240, (ftnlen)67);
    tcase_(title, (ftnlen)240);
    ssizec_(&c__300, cset, (ftnlen)30);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    card = 300;
    i__1 = card;
    for (i__ = 1; i__ <= i__1; ++i__) {
	insrtc_(cvals + ((i__2 = card + 1 - i__ - 1) < 301 && 0 <= i__2 ? 
		i__2 : s_rnge("cvals", i__2, "f_insert__", (ftnlen)737)) * 30,
		 cset, (ftnlen)30, (ftnlen)30);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	insrtc_(cvals + ((i__2 = i__ - 1) < 301 && 0 <= i__2 ? i__2 : s_rnge(
		"cvals", i__2, "f_insert__", (ftnlen)740)) * 30, cset, (
		ftnlen)30, (ftnlen)30);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	s_copy(xitemc + ((i__2 = i__ - 1) < 300 && 0 <= i__2 ? i__2 : s_rnge(
		"xitemc", i__2, "f_insert__", (ftnlen)743)) * 30, cvals + ((
		i__3 = i__ - 1) < 301 && 0 <= i__3 ? i__3 : s_rnge("cvals", 
		i__3, "f_insert__", (ftnlen)743)) * 30, (ftnlen)30, (ftnlen)
		30);
    }
    n = cardc_(cset, (ftnlen)30);
    chcksi_("N", &n, "=", &card, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckac_("ITEMS", cset + 180, "=", xitemc, &n, ok, (ftnlen)5, (ftnlen)30, (
	    ftnlen)1, (ftnlen)30);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "INSRTC test:  insert non-distinct elements in non-sequent"
	    "ial order. This time use duplicate elements that disagree with t"
	    "he set elements only at positions past the string length of the "
	    "set.", (ftnlen)240, (ftnlen)189);
    tcase_(title, (ftnlen)240);
    ssizec_(&c__300, cset, (ftnlen)30);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    card = 300;
    i__1 = card;
    for (i__ = 1; i__ <= i__1; ++i__) {
	insrtc_(cvals + ((i__2 = card + 1 - i__ - 1) < 301 && 0 <= i__2 ? 
		i__2 : s_rnge("cvals", i__2, "f_insert__", (ftnlen)772)) * 30,
		 cset, (ftnlen)30, (ftnlen)30);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	insrtc_(lnvals + ((i__2 = i__ - 1) < 300 && 0 <= i__2 ? i__2 : s_rnge(
		"lnvals", i__2, "f_insert__", (ftnlen)775)) * 80, cset, (
		ftnlen)80, (ftnlen)30);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	s_copy(xitemc + ((i__2 = i__ - 1) < 300 && 0 <= i__2 ? i__2 : s_rnge(
		"xitemc", i__2, "f_insert__", (ftnlen)778)) * 30, cvals + ((
		i__3 = i__ - 1) < 301 && 0 <= i__3 ? i__3 : s_rnge("cvals", 
		i__3, "f_insert__", (ftnlen)778)) * 30, (ftnlen)30, (ftnlen)
		30);
    }
    n = cardc_(cset, (ftnlen)30);
    chcksi_("N", &n, "=", &card, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckac_("ITEMS", cset + 180, "=", xitemc, &n, ok, (ftnlen)5, (ftnlen)30, (
	    ftnlen)1, (ftnlen)30);

/* --- Case: ------------------------------------------------------ */

    tcase_("INSRTC error case:  set overflow.", (ftnlen)33);
    ssizec_(&c__300, cset, (ftnlen)30);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    card = 300;
    i__1 = card;
    for (i__ = 1; i__ <= i__1; ++i__) {
	insrtc_(cvals + ((i__2 = i__ - 1) < 301 && 0 <= i__2 ? i__2 : s_rnge(
		"cvals", i__2, "f_insert__", (ftnlen)802)) * 30, cset, (
		ftnlen)30, (ftnlen)30);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    insrtc_(cvals + ((i__1 = card) < 301 && 0 <= i__1 ? i__1 : s_rnge("cvals",
	     i__1, "f_insert__", (ftnlen)807)) * 30, cset, (ftnlen)30, (
	    ftnlen)30);
    chckxc_(&c_true, "SPICE(SETEXCESS)", ok, (ftnlen)16);

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_insert__ */

