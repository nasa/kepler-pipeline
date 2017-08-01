/* f_cyip.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__25 = 25;
static logical c_false = FALSE_;
static integer c_n25 = -25;
static integer c_n5 = -5;
static integer c__0 = 0;
static logical c_true = TRUE_;
static integer c__100 = 100;
static doublereal c_b119 = 0.;
static integer c_n100 = -100;
static integer c__10 = 10;
static integer c_n10 = -10;

/* $Procedure F_CYIP ( Cycle array in place tests ) */
/* Subroutine */ int f_cyip__(logical *ok)
{
    /* System generated locals */
    integer i__1, i__2;

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer);
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    integer i__, j;
    char label[80];
    integer q, r__;
    extern /* Subroutine */ int tcase_(char *, ftnlen), movec_(char *, 
	    integer *, char *, ftnlen, ftnlen), moved_(doublereal *, integer *
	    , doublereal *), repmi_(char *, char *, integer *, char *, ftnlen,
	     ftnlen, ftnlen), movei_(integer *, integer *, integer *), topen_(
	    char *, ftnlen), t_success__(logical *);
    char c2arry[80*10];
    doublereal d2arry[100];
    integer i2arry[25];
    extern /* Subroutine */ int chckad_(char *, doublereal *, char *, 
	    doublereal *, integer *, doublereal *, logical *, ftnlen, ftnlen),
	     chckai_(char *, integer *, char *, integer *, integer *, logical 
	    *, ftnlen, ftnlen), clearc_(integer *, char *, ftnlen), cleard_(
	    integer *, doublereal *), cyclac_(char *, integer *, char *, 
	    integer *, char *, ftnlen, ftnlen, ftnlen), cleari_(integer *, 
	    integer *), cyclad_(doublereal *, integer *, char *, integer *, 
	    doublereal *, ftnlen), chcksc_(char *, char *, char *, char *, 
	    logical *, ftnlen, ftnlen, ftnlen, ftnlen), chckxc_(logical *, 
	    char *, logical *, ftnlen), cyclai_(integer *, integer *, char *, 
	    integer *, integer *, ftnlen), cyacip_(integer *, char *, integer 
	    *, char *, ftnlen, ftnlen), cyadip_(integer *, char *, integer *, 
	    doublereal *, ftnlen), cyaiip_(integer *, char *, integer *, 
	    integer *, ftnlen), rmaini_(integer *, integer *, integer *, 
	    integer *);
    char carray[80*10];
    doublereal darray[100];
    integer iarray[25];
    char xcarry[80*10];
    doublereal xdarry[100];
    integer xiarry[25];
    extern /* Subroutine */ int intstr_(integer *, char *, ftnlen);

/* $ Abstract */

/*     Exercise routines that cycle arrays in place. */

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

/*     This routine tests the in-place variants of the array */
/*     cycling routines.  The routines exercised by this family */
/*     are: */

/*        CYACIP */
/*        CYADIP */
/*        CYAIIP */

/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     N.J. Bachman     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    TSPICE Version 1.0.0, 20-OCT-2005 (NJB) */


/* -& */

/*     SPICELIB functions */


/*     Local Parameters */


/*     Local Variables */


/*     Open the test family. */

    topen_("F_CYIP", (ftnlen)6);

/* --- Case: ------------------------------------------------------ */

    tcase_("Test CYAIIP:  cycle forward.", (ftnlen)28);
    for (i__ = 1; i__ <= 25; ++i__) {
	iarray[(i__1 = i__ - 1) < 25 && 0 <= i__1 ? i__1 : s_rnge("iarray", 
		i__1, "f_cyip__", (ftnlen)165)] = i__;
    }
    for (i__ = 1; i__ <= 50; ++i__) {

/*        Use CYCLAI to find the expected result. */

	cyclai_(iarray, &c__25, "F", &i__, xiarry, (ftnlen)1);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Also cycle the array in place. */

	movei_(iarray, &c__25, i2arry);
	cyaiip_(&c__25, "F", &i__, i2arry, (ftnlen)1);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chckai_("I2ARRY", i2arry, "=", xiarry, &c__25, ok, (ftnlen)6, (ftnlen)
		1);

/*        Just to be careful, let's test CYCLAI itself.  Create */
/*        the expected result of cycling the array forward by I. */

	cleari_(&c__25, i2arry);
	for (j = 1; j <= 25; ++j) {

/*           Find the target location of the Jth element of IARRAY. */

	    i__1 = j + i__;
	    rmaini_(&i__1, &c__25, &q, &r__);
	    if (r__ == 0) {
		r__ = 25;
	    }
	    i2arry[(i__1 = r__ - 1) < 25 && 0 <= i__1 ? i__1 : s_rnge("i2arry"
		    , i__1, "f_cyip__", (ftnlen)202)] = iarray[(i__2 = j - 1) 
		    < 25 && 0 <= i__2 ? i__2 : s_rnge("iarray", i__2, "f_cyi"
		    "p__", (ftnlen)202)];
	}
	chckai_("I2ARRY", i2arry, "=", xiarry, &c__25, ok, (ftnlen)6, (ftnlen)
		1);

/*        Cycle backward by -I as well. */

	i__1 = -i__;
	cyclai_(iarray, &c__25, "B", &i__1, xiarry, (ftnlen)1);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chckai_("I2ARRY", i2arry, "=", xiarry, &c__25, ok, (ftnlen)6, (ftnlen)
		1);

/*        Cycle in the opposite direction using a negative count. */

	movei_(iarray, &c__25, i2arry);
	i__1 = -i__;
	cyaiip_(&c__25, "B", &i__1, i2arry, (ftnlen)1);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chckai_("I2ARRY", i2arry, "=", xiarry, &c__25, ok, (ftnlen)6, (ftnlen)
		1);
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("Test CYAIIP:  cycle backward.", (ftnlen)29);
    for (i__ = 1; i__ <= 50; ++i__) {

/*        Use CYCLAI to find the expected result. */

	cyclai_(iarray, &c__25, "B", &i__, xiarry, (ftnlen)1);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Also cycle the array in place. */

	movei_(iarray, &c__25, i2arry);
	cyaiip_(&c__25, "B", &i__, i2arry, (ftnlen)1);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chckai_("I2ARRY", i2arry, "=", xiarry, &c__25, ok, (ftnlen)6, (ftnlen)
		1);

/*        Just to be careful, let's test CYCLAI itself.  Create */
/*        the expected result of cycling the array backward by I. */

	cleari_(&c__25, i2arry);
	for (j = 1; j <= 25; ++j) {

/*           Find the target location of the Jth element of IARRAY. */

	    i__1 = j - i__;
	    rmaini_(&i__1, &c__25, &q, &r__);
	    if (r__ == 0) {
		r__ = 25;
	    }
	    i2arry[(i__1 = r__ - 1) < 25 && 0 <= i__1 ? i__1 : s_rnge("i2arry"
		    , i__1, "f_cyip__", (ftnlen)266)] = iarray[(i__2 = j - 1) 
		    < 25 && 0 <= i__2 ? i__2 : s_rnge("iarray", i__2, "f_cyi"
		    "p__", (ftnlen)266)];
	}
	chckai_("I2ARRY", i2arry, "=", xiarry, &c__25, ok, (ftnlen)6, (ftnlen)
		1);

/*        Cycle forward by -I as well. */

	i__1 = -i__;
	cyclai_(iarray, &c__25, "F", &i__1, xiarry, (ftnlen)1);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chckai_("I2ARRY", i2arry, "=", xiarry, &c__25, ok, (ftnlen)6, (ftnlen)
		1);

/*        Cycle in the opposite direction using a negative count. */

	movei_(iarray, &c__25, i2arry);
	i__1 = -i__;
	cyaiip_(&c__25, "F", &i__1, i2arry, (ftnlen)1);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chckai_("I2ARRY", i2arry, "=", xiarry, &c__25, ok, (ftnlen)6, (ftnlen)
		1);
    }

/* --- Case: ------------------------------------------------------ */


/*     When the array size is non-positive, the call should be */
/*     a no-op. */


/*     Use a negative size. */

    tcase_("Error case:  non-positive array size", (ftnlen)36);
    movei_(iarray, &c__25, i2arry);
    cyaiip_(&c_n25, "F", &c_n5, i2arry, (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckai_("I2ARRY", i2arry, "=", iarray, &c__25, ok, (ftnlen)6, (ftnlen)1);

/*     Use size zero. */

    movei_(iarray, &c__25, i2arry);
    cyaiip_(&c__0, "F", &c_n5, i2arry, (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckai_("I2ARRY", i2arry, "=", iarray, &c__25, ok, (ftnlen)6, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Error case:  invalid direction.", (ftnlen)31);
    cyaiip_(&c__25, "Z", &c_n5, i2arry, (ftnlen)1);
    chckxc_(&c_true, "SPICE(INVALIDDIRECTION)", ok, (ftnlen)23);

/* --- Case: ------------------------------------------------------ */

    tcase_("Test CYADIP:  cycle forward.", (ftnlen)28);
    for (i__ = 1; i__ <= 100; ++i__) {
	darray[(i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge("darray", 
		i__1, "f_cyip__", (ftnlen)343)] = (doublereal) i__;
    }
    for (i__ = 1; i__ <= 200; ++i__) {

/*        Use CYCLAD to find the expected result. */

	cyclad_(darray, &c__100, "F", &i__, xdarry, (ftnlen)1);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Also cycle the array in place. */

	moved_(darray, &c__100, d2arry);
	cyadip_(&c__100, "F", &i__, d2arry, (ftnlen)1);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chckad_("D2ARRY", d2arry, "=", xdarry, &c__100, &c_b119, ok, (ftnlen)
		6, (ftnlen)1);

/*        Just to be careful, let's test CYCLAD itself.  Create */
/*        the expected result of cycling the array forward by I. */

	cleard_(&c__100, d2arry);
	for (j = 1; j <= 100; ++j) {

/*           Find the target location of the Jth element of DARRAY. */

	    i__1 = j + i__;
	    rmaini_(&i__1, &c__100, &q, &r__);
	    if (r__ == 0) {
		r__ = 100;
	    }
	    d2arry[(i__1 = r__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge("d2ar"
		    "ry", i__1, "f_cyip__", (ftnlen)381)] = darray[(i__2 = j - 
		    1) < 100 && 0 <= i__2 ? i__2 : s_rnge("darray", i__2, 
		    "f_cyip__", (ftnlen)381)];
	}
	chckad_("D2ARRY", d2arry, "=", xdarry, &c__100, &c_b119, ok, (ftnlen)
		6, (ftnlen)1);

/*        Cycle backward by -I as well. */

	i__1 = -i__;
	cyclad_(darray, &c__100, "B", &i__1, xdarry, (ftnlen)1);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chckad_("D2ARRY", d2arry, "=", xdarry, &c__100, &c_b119, ok, (ftnlen)
		6, (ftnlen)1);

/*        Cycle in the opposite direction using a negative count. */

	moved_(darray, &c__100, d2arry);
	i__1 = -i__;
	cyadip_(&c__100, "B", &i__1, d2arry, (ftnlen)1);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chckad_("D2ARRY", d2arry, "=", xdarry, &c__100, &c_b119, ok, (ftnlen)
		6, (ftnlen)1);
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("Test CYADIP:  cycle backward.", (ftnlen)29);
    for (i__ = 1; i__ <= 200; ++i__) {

/*        Use CYCLAD to find the expected result. */

	cyclad_(darray, &c__100, "B", &i__, xdarry, (ftnlen)1);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Also cycle the array in place. */

	moved_(darray, &c__100, d2arry);
	cyadip_(&c__100, "B", &i__, d2arry, (ftnlen)1);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chckad_("D2ARRY", d2arry, "=", xdarry, &c__100, &c_b119, ok, (ftnlen)
		6, (ftnlen)1);

/*        Just to be careful, let's test CYCLAD itself.  Create */
/*        the expected result of cycling the array backward by I. */

	cleard_(&c__100, d2arry);
	for (j = 1; j <= 100; ++j) {

/*           Find the target location of the Jth element of DARRAY. */

	    i__1 = j - i__;
	    rmaini_(&i__1, &c__100, &q, &r__);
	    if (r__ == 0) {
		r__ = 100;
	    }
	    d2arry[(i__1 = r__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge("d2ar"
		    "ry", i__1, "f_cyip__", (ftnlen)445)] = darray[(i__2 = j - 
		    1) < 100 && 0 <= i__2 ? i__2 : s_rnge("darray", i__2, 
		    "f_cyip__", (ftnlen)445)];
	}
	chckad_("D2ARRY", d2arry, "=", xdarry, &c__100, &c_b119, ok, (ftnlen)
		6, (ftnlen)1);

/*        Cycle forward by -I as well. */

	i__1 = -i__;
	cyclad_(darray, &c__100, "F", &i__1, xdarry, (ftnlen)1);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chckad_("D2ARRY", d2arry, "=", xdarry, &c__100, &c_b119, ok, (ftnlen)
		6, (ftnlen)1);

/*        Cycle in the opposite direction using a negative count. */

	moved_(darray, &c__100, d2arry);
	i__1 = -i__;
	cyadip_(&c__100, "F", &i__1, d2arry, (ftnlen)1);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chckad_("D2ARRY", d2arry, "=", xdarry, &c__100, &c_b119, ok, (ftnlen)
		6, (ftnlen)1);
    }

/* --- Case: ------------------------------------------------------ */


/*     When the array size is non-positive, the call should be */
/*     a no-op. */


/*     Use a negative size. */

    tcase_("Error case:  non-positive array size", (ftnlen)36);
    moved_(darray, &c__100, d2arry);
    cyadip_(&c_n100, "F", &c_n5, d2arry, (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("D2ARRY", d2arry, "=", darray, &c__100, &c_b119, ok, (ftnlen)6, (
	    ftnlen)1);

/*     Use size zero. */

    moved_(darray, &c__100, d2arry);
    cyadip_(&c__0, "F", &c_n5, d2arry, (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("D2ARRY", d2arry, "=", darray, &c__100, &c_b119, ok, (ftnlen)6, (
	    ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Error case:  invalid direction.", (ftnlen)31);
    cyadip_(&c__100, "Z", &c_n5, d2arry, (ftnlen)1);
    chckxc_(&c_true, "SPICE(INVALIDDIRECTION)", ok, (ftnlen)23);

/* --- Case: ------------------------------------------------------ */

    tcase_("Test CYACIP:  cycle forward.", (ftnlen)28);
    for (i__ = 1; i__ <= 10; ++i__) {
	intstr_(&i__, carray + ((i__1 = i__ - 1) < 10 && 0 <= i__1 ? i__1 : 
		s_rnge("carray", i__1, "f_cyip__", (ftnlen)523)) * 80, (
		ftnlen)80);
    }
    for (i__ = 1; i__ <= 20; ++i__) {

/*        Use CYCLAC to find the expected result. */

	cyclac_(carray, &c__10, "F", &i__, xcarry, (ftnlen)80, (ftnlen)1, (
		ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Also cycle the array in place. */

	movec_(carray, &c__10, c2arry, (ftnlen)80, (ftnlen)80);
	cyacip_(&c__10, "F", &i__, c2arry, (ftnlen)1, (ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	for (j = 1; j <= 10; ++j) {
	    s_copy(label, "C2ARRY(#)", (ftnlen)80, (ftnlen)9);
	    repmi_(label, "#", &j, label, (ftnlen)80, (ftnlen)1, (ftnlen)80);
	    chcksc_(label, c2arry + ((i__1 = j - 1) < 10 && 0 <= i__1 ? i__1 :
		     s_rnge("c2arry", i__1, "f_cyip__", (ftnlen)546)) * 80, 
		    "=", xcarry + ((i__2 = j - 1) < 10 && 0 <= i__2 ? i__2 : 
		    s_rnge("xcarry", i__2, "f_cyip__", (ftnlen)546)) * 80, ok,
		     (ftnlen)80, (ftnlen)80, (ftnlen)1, (ftnlen)80);
	}

/*        Just to be careful, let's test CYCLAC itself.  Create */
/*        the expected result of cycling the array forward by I. */

	clearc_(&c__10, c2arry, (ftnlen)80);
	for (j = 1; j <= 10; ++j) {

/*           Find the target location of the Jth element of CARRAY. */

	    i__1 = j + i__;
	    rmaini_(&i__1, &c__10, &q, &r__);
	    if (r__ == 0) {
		r__ = 10;
	    }
	    s_copy(c2arry + ((i__1 = r__ - 1) < 10 && 0 <= i__1 ? i__1 : 
		    s_rnge("c2arry", i__1, "f_cyip__", (ftnlen)566)) * 80, 
		    carray + ((i__2 = j - 1) < 10 && 0 <= i__2 ? i__2 : 
		    s_rnge("carray", i__2, "f_cyip__", (ftnlen)566)) * 80, (
		    ftnlen)80, (ftnlen)80);
	}
	for (j = 1; j <= 10; ++j) {
	    s_copy(label, "C2ARRY(#)", (ftnlen)80, (ftnlen)9);
	    repmi_(label, "#", &j, label, (ftnlen)80, (ftnlen)1, (ftnlen)80);
	    chcksc_(label, c2arry + ((i__1 = j - 1) < 10 && 0 <= i__1 ? i__1 :
		     s_rnge("c2arry", i__1, "f_cyip__", (ftnlen)574)) * 80, 
		    "=", xcarry + ((i__2 = j - 1) < 10 && 0 <= i__2 ? i__2 : 
		    s_rnge("xcarry", i__2, "f_cyip__", (ftnlen)574)) * 80, ok,
		     (ftnlen)80, (ftnlen)80, (ftnlen)1, (ftnlen)80);
	}

/*        Cycle backward by -I as well. */

	i__1 = -i__;
	cyclac_(carray, &c__10, "B", &i__1, xcarry, (ftnlen)80, (ftnlen)1, (
		ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	for (j = 1; j <= 10; ++j) {
	    s_copy(label, "C2ARRY(#)", (ftnlen)80, (ftnlen)9);
	    repmi_(label, "#", &j, label, (ftnlen)80, (ftnlen)1, (ftnlen)80);
	    chcksc_(label, c2arry + ((i__1 = j - 1) < 10 && 0 <= i__1 ? i__1 :
		     s_rnge("c2arry", i__1, "f_cyip__", (ftnlen)588)) * 80, 
		    "=", xcarry + ((i__2 = j - 1) < 10 && 0 <= i__2 ? i__2 : 
		    s_rnge("xcarry", i__2, "f_cyip__", (ftnlen)588)) * 80, ok,
		     (ftnlen)80, (ftnlen)80, (ftnlen)1, (ftnlen)80);
	}

/*        Cycle in the opposite direction using a negative count. */

	movec_(carray, &c__10, c2arry, (ftnlen)80, (ftnlen)80);
	i__1 = -i__;
	cyacip_(&c__10, "B", &i__1, c2arry, (ftnlen)1, (ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	for (j = 1; j <= 10; ++j) {
	    s_copy(label, "C2ARRY(#)", (ftnlen)80, (ftnlen)9);
	    repmi_(label, "#", &j, label, (ftnlen)80, (ftnlen)1, (ftnlen)80);
	    chcksc_(label, c2arry + ((i__1 = j - 1) < 10 && 0 <= i__1 ? i__1 :
		     s_rnge("c2arry", i__1, "f_cyip__", (ftnlen)604)) * 80, 
		    "=", xcarry + ((i__2 = j - 1) < 10 && 0 <= i__2 ? i__2 : 
		    s_rnge("xcarry", i__2, "f_cyip__", (ftnlen)604)) * 80, ok,
		     (ftnlen)80, (ftnlen)80, (ftnlen)1, (ftnlen)80);
	}
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("Test CYACIP:  cycle backward.", (ftnlen)29);
    for (i__ = 1; i__ <= 20; ++i__) {

/*        Use CYCLAC to find the expected result. */

	cyclac_(carray, &c__10, "B", &i__, xcarry, (ftnlen)80, (ftnlen)1, (
		ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Also cycle the array in place. */

	movec_(carray, &c__10, c2arry, (ftnlen)80, (ftnlen)80);
	cyacip_(&c__10, "B", &i__, c2arry, (ftnlen)1, (ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	for (j = 1; j <= 10; ++j) {
	    s_copy(label, "C2ARRY(#)", (ftnlen)80, (ftnlen)9);
	    repmi_(label, "#", &j, label, (ftnlen)80, (ftnlen)1, (ftnlen)80);
	    chcksc_("C2ARRY", c2arry + ((i__1 = j - 1) < 10 && 0 <= i__1 ? 
		    i__1 : s_rnge("c2arry", i__1, "f_cyip__", (ftnlen)635)) * 
		    80, "=", xcarry + ((i__2 = j - 1) < 10 && 0 <= i__2 ? 
		    i__2 : s_rnge("xcarry", i__2, "f_cyip__", (ftnlen)635)) * 
		    80, ok, (ftnlen)6, (ftnlen)80, (ftnlen)1, (ftnlen)80);
	}

/*        Just to be careful, let's test CYCLAC itself.  Create */
/*        the expected result of cycling the array backward by I. */

	clearc_(&c__10, c2arry, (ftnlen)80);
	for (j = 1; j <= 10; ++j) {

/*           Find the target location of the Jth element of CARRAY. */

	    i__1 = j - i__;
	    rmaini_(&i__1, &c__10, &q, &r__);
	    if (r__ == 0) {
		r__ = 10;
	    }
	    s_copy(c2arry + ((i__1 = r__ - 1) < 10 && 0 <= i__1 ? i__1 : 
		    s_rnge("c2arry", i__1, "f_cyip__", (ftnlen)655)) * 80, 
		    carray + ((i__2 = j - 1) < 10 && 0 <= i__2 ? i__2 : 
		    s_rnge("carray", i__2, "f_cyip__", (ftnlen)655)) * 80, (
		    ftnlen)80, (ftnlen)80);
	}
	for (j = 1; j <= 10; ++j) {
	    s_copy(label, "C2ARRY(#)", (ftnlen)80, (ftnlen)9);
	    repmi_(label, "#", &j, label, (ftnlen)80, (ftnlen)1, (ftnlen)80);
	    chcksc_(label, c2arry + ((i__1 = j - 1) < 10 && 0 <= i__1 ? i__1 :
		     s_rnge("c2arry", i__1, "f_cyip__", (ftnlen)663)) * 80, 
		    "=", xcarry + ((i__2 = j - 1) < 10 && 0 <= i__2 ? i__2 : 
		    s_rnge("xcarry", i__2, "f_cyip__", (ftnlen)663)) * 80, ok,
		     (ftnlen)80, (ftnlen)80, (ftnlen)1, (ftnlen)80);
	}

/*        Cycle forward by -I as well. */

	i__1 = -i__;
	cyclac_(carray, &c__10, "F", &i__1, xcarry, (ftnlen)80, (ftnlen)1, (
		ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	for (j = 1; j <= 10; ++j) {
	    s_copy(label, "C2ARRY(#)", (ftnlen)80, (ftnlen)9);
	    repmi_(label, "#", &j, label, (ftnlen)80, (ftnlen)1, (ftnlen)80);
	    chcksc_(label, c2arry + ((i__1 = j - 1) < 10 && 0 <= i__1 ? i__1 :
		     s_rnge("c2arry", i__1, "f_cyip__", (ftnlen)677)) * 80, 
		    "=", xcarry + ((i__2 = j - 1) < 10 && 0 <= i__2 ? i__2 : 
		    s_rnge("xcarry", i__2, "f_cyip__", (ftnlen)677)) * 80, ok,
		     (ftnlen)80, (ftnlen)80, (ftnlen)1, (ftnlen)80);
	}

/*        Cycle in the opposite direction using a negative count. */

	movec_(carray, &c__10, c2arry, (ftnlen)80, (ftnlen)80);
	i__1 = -i__;
	cyacip_(&c__10, "F", &i__1, c2arry, (ftnlen)1, (ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	for (j = 1; j <= 10; ++j) {
	    s_copy(label, "C2ARRY(#)", (ftnlen)80, (ftnlen)9);
	    repmi_(label, "#", &j, label, (ftnlen)80, (ftnlen)1, (ftnlen)80);
	    chcksc_("C2ARRY", c2arry + ((i__1 = j - 1) < 10 && 0 <= i__1 ? 
		    i__1 : s_rnge("c2arry", i__1, "f_cyip__", (ftnlen)692)) * 
		    80, "=", xcarry + ((i__2 = j - 1) < 10 && 0 <= i__2 ? 
		    i__2 : s_rnge("xcarry", i__2, "f_cyip__", (ftnlen)692)) * 
		    80, ok, (ftnlen)6, (ftnlen)80, (ftnlen)1, (ftnlen)80);
	}
    }

/* --- Case: ------------------------------------------------------ */


/*     When the array size is non-positive, the call should be */
/*     a no-op. */


/*     Use a negative size. */

    tcase_("Error case:  non-positive array size", (ftnlen)36);
    movec_(carray, &c__10, c2arry, (ftnlen)80, (ftnlen)80);
    cyacip_(&c_n10, "F", &c_n5, c2arry, (ftnlen)1, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    for (i__ = 1; i__ <= 10; ++i__) {
	s_copy(label, "C2ARRY(#)", (ftnlen)80, (ftnlen)9);
	repmi_(label, "#", &i__, label, (ftnlen)80, (ftnlen)1, (ftnlen)80);
	chcksc_(label, c2arry + ((i__1 = i__ - 1) < 10 && 0 <= i__1 ? i__1 : 
		s_rnge("c2arry", i__1, "f_cyip__", (ftnlen)720)) * 80, "=", 
		carray + ((i__2 = i__ - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge(
		"carray", i__2, "f_cyip__", (ftnlen)720)) * 80, ok, (ftnlen)
		80, (ftnlen)80, (ftnlen)1, (ftnlen)80);
    }

/*     Use size zero. */

    movec_(carray, &c__10, c2arry, (ftnlen)80, (ftnlen)80);
    cyacip_(&c__0, "F", &c_n5, c2arry, (ftnlen)1, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    for (i__ = 1; i__ <= 10; ++i__) {
	s_copy(label, "C2ARRY(#)", (ftnlen)80, (ftnlen)9);
	repmi_(label, "#", &i__, label, (ftnlen)80, (ftnlen)1, (ftnlen)80);
	chcksc_(label, c2arry + ((i__1 = i__ - 1) < 10 && 0 <= i__1 ? i__1 : 
		s_rnge("c2arry", i__1, "f_cyip__", (ftnlen)738)) * 80, "=", 
		carray + ((i__2 = i__ - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge(
		"carray", i__2, "f_cyip__", (ftnlen)738)) * 80, ok, (ftnlen)
		80, (ftnlen)80, (ftnlen)1, (ftnlen)80);
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("Error case:  invalid direction.", (ftnlen)31);
    cyacip_(&c__10, "Z", &c_n5, c2arry, (ftnlen)1, (ftnlen)80);
    chckxc_(&c_true, "SPICE(INVALIDDIRECTION)", ok, (ftnlen)23);

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_cyip__ */

