/* f_zzmsxf.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static integer c__36 = 36;
static doublereal c_b13 = 0.;
static integer c__6 = 6;

/* $Procedure      F_ZZMSXF ( Check the routine zzmsxf ) */
/* Subroutine */ int f_zzmsxf__(logical *ok)
{
    /* System generated locals */
    integer i__1, i__2, i__3;

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    doublereal temp[36]	/* was [6][6] */;
    extern /* Subroutine */ int mxmg_(doublereal *, doublereal *, integer *, 
	    integer *, integer *, doublereal *);
    doublereal drot1[9]	/* was [3][3] */, drot2[9]	/* was [3][3] */;
    integer i__, j, n;
    extern /* Subroutine */ int tcase_(char *, ftnlen), topen_(char *, ftnlen)
	    , t_success__(logical *), chckad_(char *, doublereal *, char *, 
	    doublereal *, integer *, doublereal *, logical *, ftnlen, ftnlen),
	     chckxc_(logical *, char *, logical *, ftnlen);
    doublereal expect[36]	/* was [6][6] */, sxform[180]	/* was [6][6][
	    5] */, output[36]	/* was [6][6] */;
    extern /* Subroutine */ int zzmsxf_(doublereal *, integer *, doublereal *)
	    ;
    doublereal rot1[9]	/* was [3][3] */, rot2[9]	/* was [3][3] */;

/* $ Abstract */

/*     This tests the private rouine ZZMSXF.  Note that we put */
/*     something that can't be the correct answer in OUTPUT in */
/*     each test case to make sure that the OUTPUT is completely */
/*     filled by ZZMSXF */
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

/* -& */

/*     Test Utility Functions */


/*     SPICELIB Functions */


/*     Local Variables */


/*     Begin every test family with an open call. */

    topen_("F_ZZMSXF", (ftnlen)8);
    tcase_("Test out the case when N = 0. We should get the 6x6 identity mat"
	    "rix in this case.", (ftnlen)81);
    for (j = 1; j <= 6; ++j) {
	for (i__ = 1; i__ <= 6; ++i__) {
	    expect[(i__1 = i__ + j * 6 - 7) < 36 && 0 <= i__1 ? i__1 : s_rnge(
		    "expect", i__1, "f_zzmsxf__", (ftnlen)82)] = (doublereal) 
		    (-((i__2 = i__ - j, abs(i__2)) - 1) / ((i__3 = i__ - j, 
		    abs(i__3)) + 1));
	    output[(i__1 = i__ + j * 6 - 7) < 36 && 0 <= i__1 ? i__1 : s_rnge(
		    "output", i__1, "f_zzmsxf__", (ftnlen)83)] = -1.;
	}
    }
    n = 0;
    zzmsxf_(sxform, &n, output);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("OUTPUT", output, "=", expect, &c__36, &c_b13, ok, (ftnlen)6, (
	    ftnlen)1);
    tcase_("Test the case when N = 1.  For this case the output should be a "
	    "copy of the input.", (ftnlen)82);
    for (j = 1; j <= 6; ++j) {
	for (i__ = 1; i__ <= 6; ++i__) {
	    output[(i__1 = i__ + j * 6 - 7) < 36 && 0 <= i__1 ? i__1 : s_rnge(
		    "output", i__1, "f_zzmsxf__", (ftnlen)98)] = -1.;
	}
    }
    for (j = 1; j <= 3; ++j) {
	for (i__ = 1; i__ <= 3; ++i__) {
	    sxform[(i__1 = i__ + (j + 6) * 6 - 43) < 180 && 0 <= i__1 ? i__1 :
		     s_rnge("sxform", i__1, "f_zzmsxf__", (ftnlen)105)] = (
		    doublereal) (j * (-((i__2 = i__ - j, abs(i__2)) - 1) / ((
		    i__3 = i__ - j, abs(i__3)) + 1)));
	    sxform[(i__1 = i__ + 3 + (j + 9) * 6 - 43) < 180 && 0 <= i__1 ? 
		    i__1 : s_rnge("sxform", i__1, "f_zzmsxf__", (ftnlen)106)] 
		    = (doublereal) (j * (-((i__2 = i__ - j, abs(i__2)) - 1) / 
		    ((i__3 = i__ - j, abs(i__3)) + 1)));
	    sxform[(i__1 = i__ + 3 + (j + 6) * 6 - 43) < 180 && 0 <= i__1 ? 
		    i__1 : s_rnge("sxform", i__1, "f_zzmsxf__", (ftnlen)107)] 
		    = (doublereal) (-((i__2 = i__ - j, abs(i__2)) - 1) / ((
		    i__3 = i__ - j, abs(i__3)) + 1));
	    sxform[(i__1 = i__ + (j + 9) * 6 - 43) < 180 && 0 <= i__1 ? i__1 :
		     s_rnge("sxform", i__1, "f_zzmsxf__", (ftnlen)108)] = 0.;
	    expect[(i__1 = i__ + j * 6 - 7) < 36 && 0 <= i__1 ? i__1 : s_rnge(
		    "expect", i__1, "f_zzmsxf__", (ftnlen)110)] = (doublereal)
		     (j * (-((i__2 = i__ - j, abs(i__2)) - 1) / ((i__3 = i__ 
		    - j, abs(i__3)) + 1)));
	    expect[(i__1 = i__ + 3 + (j + 3) * 6 - 7) < 36 && 0 <= i__1 ? 
		    i__1 : s_rnge("expect", i__1, "f_zzmsxf__", (ftnlen)111)] 
		    = (doublereal) (j * (-((i__2 = i__ - j, abs(i__2)) - 1) / 
		    ((i__3 = i__ - j, abs(i__3)) + 1)));
	    expect[(i__1 = i__ + 3 + j * 6 - 7) < 36 && 0 <= i__1 ? i__1 : 
		    s_rnge("expect", i__1, "f_zzmsxf__", (ftnlen)112)] = (
		    doublereal) (-((i__2 = i__ - j, abs(i__2)) - 1) / ((i__3 =
		     i__ - j, abs(i__3)) + 1));
	    expect[(i__1 = i__ + (j + 3) * 6 - 7) < 36 && 0 <= i__1 ? i__1 : 
		    s_rnge("expect", i__1, "f_zzmsxf__", (ftnlen)113)] = 0.;
	}
    }
    n = 1;
    zzmsxf_(sxform, &n, output);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("OUTPUT", output, "=", expect, &c__36, &c_b13, ok, (ftnlen)6, (
	    ftnlen)1);
    tcase_("N = 2, Actual product computed.", (ftnlen)31);
    for (j = 1; j <= 6; ++j) {
	for (i__ = 1; i__ <= 6; ++i__) {
	    output[(i__1 = i__ + j * 6 - 7) < 36 && 0 <= i__1 ? i__1 : s_rnge(
		    "output", i__1, "f_zzmsxf__", (ftnlen)131)] = -1.;
	}
    }
    rot1[0] = 1.;
    rot1[1] = 2.;
    rot1[2] = 3.;
    rot1[3] = 4.;
    rot1[4] = 5.;
    rot1[5] = 6.;
    rot1[6] = 7.;
    rot1[7] = 8.;
    rot1[8] = 9.;
    rot2[0] = 1.;
    rot2[1] = 2.;
    rot2[2] = 3.;
    rot2[3] = 2.;
    rot2[4] = 3.;
    rot2[5] = 1.;
    rot2[6] = 3.;
    rot2[7] = 1.;
    rot2[8] = 2.;
    drot1[0] = 1.;
    drot1[1] = 0.;
    drot1[2] = 0.;
    drot1[3] = 0.;
    drot1[4] = 1.;
    drot1[5] = 0.;
    drot1[6] = 0.;
    drot1[7] = 0.;
    drot1[8] = 1.;
    drot2[0] = 1.;
    drot2[1] = 2.;
    drot2[2] = 3.;
    drot2[3] = 2.;
    drot2[4] = 3.;
    drot2[5] = 1.;
    drot2[6] = 3.;
    drot2[7] = 1.;
    drot2[8] = 2.;
    for (j = 1; j <= 3; ++j) {
	for (i__ = 1; i__ <= 3; ++i__) {
	    sxform[(i__1 = i__ + (j + 6) * 6 - 43) < 180 && 0 <= i__1 ? i__1 :
		     s_rnge("sxform", i__1, "f_zzmsxf__", (ftnlen)189)] = 
		    rot1[(i__2 = i__ + j * 3 - 4) < 9 && 0 <= i__2 ? i__2 : 
		    s_rnge("rot1", i__2, "f_zzmsxf__", (ftnlen)189)];
	    sxform[(i__1 = i__ + 3 + (j + 9) * 6 - 43) < 180 && 0 <= i__1 ? 
		    i__1 : s_rnge("sxform", i__1, "f_zzmsxf__", (ftnlen)190)] 
		    = rot1[(i__2 = i__ + j * 3 - 4) < 9 && 0 <= i__2 ? i__2 : 
		    s_rnge("rot1", i__2, "f_zzmsxf__", (ftnlen)190)];
	    sxform[(i__1 = i__ + (j + 9) * 6 - 43) < 180 && 0 <= i__1 ? i__1 :
		     s_rnge("sxform", i__1, "f_zzmsxf__", (ftnlen)191)] = 0.;
	    sxform[(i__1 = i__ + 3 + (j + 6) * 6 - 43) < 180 && 0 <= i__1 ? 
		    i__1 : s_rnge("sxform", i__1, "f_zzmsxf__", (ftnlen)192)] 
		    = drot1[(i__2 = i__ + j * 3 - 4) < 9 && 0 <= i__2 ? i__2 :
		     s_rnge("drot1", i__2, "f_zzmsxf__", (ftnlen)192)];
	    sxform[(i__1 = i__ + (j + 12) * 6 - 43) < 180 && 0 <= i__1 ? i__1 
		    : s_rnge("sxform", i__1, "f_zzmsxf__", (ftnlen)194)] = 
		    rot2[(i__2 = i__ + j * 3 - 4) < 9 && 0 <= i__2 ? i__2 : 
		    s_rnge("rot2", i__2, "f_zzmsxf__", (ftnlen)194)];
	    sxform[(i__1 = i__ + 3 + (j + 15) * 6 - 43) < 180 && 0 <= i__1 ? 
		    i__1 : s_rnge("sxform", i__1, "f_zzmsxf__", (ftnlen)195)] 
		    = rot2[(i__2 = i__ + j * 3 - 4) < 9 && 0 <= i__2 ? i__2 : 
		    s_rnge("rot2", i__2, "f_zzmsxf__", (ftnlen)195)];
	    sxform[(i__1 = i__ + (j + 15) * 6 - 43) < 180 && 0 <= i__1 ? i__1 
		    : s_rnge("sxform", i__1, "f_zzmsxf__", (ftnlen)196)] = 0.;
	    sxform[(i__1 = i__ + 3 + (j + 12) * 6 - 43) < 180 && 0 <= i__1 ? 
		    i__1 : s_rnge("sxform", i__1, "f_zzmsxf__", (ftnlen)197)] 
		    = drot2[(i__2 = i__ + j * 3 - 4) < 9 && 0 <= i__2 ? i__2 :
		     s_rnge("drot2", i__2, "f_zzmsxf__", (ftnlen)197)];
	}
    }
    mxmg_(&sxform[36], sxform, &c__6, &c__6, &c__6, expect);
    zzmsxf_(sxform, &n, output);
    tcase_("Three matrices multiplied together", (ftnlen)34);
    for (j = 1; j <= 6; ++j) {
	for (i__ = 1; i__ <= 6; ++i__) {
	    output[(i__1 = i__ + j * 6 - 7) < 36 && 0 <= i__1 ? i__1 : s_rnge(
		    "output", i__1, "f_zzmsxf__", (ftnlen)211)] = -1.;
	}
    }
    for (j = 1; j <= 3; ++j) {
	for (i__ = 1; i__ <= 3; ++i__) {
	    sxform[(i__1 = i__ + (j + 18) * 6 - 43) < 180 && 0 <= i__1 ? i__1 
		    : s_rnge("sxform", i__1, "f_zzmsxf__", (ftnlen)218)] = 
		    rot1[(i__2 = i__ + j * 3 - 4) < 9 && 0 <= i__2 ? i__2 : 
		    s_rnge("rot1", i__2, "f_zzmsxf__", (ftnlen)218)];
	    sxform[(i__1 = i__ + 3 + (j + 21) * 6 - 43) < 180 && 0 <= i__1 ? 
		    i__1 : s_rnge("sxform", i__1, "f_zzmsxf__", (ftnlen)219)] 
		    = rot1[(i__2 = i__ + j * 3 - 4) < 9 && 0 <= i__2 ? i__2 : 
		    s_rnge("rot1", i__2, "f_zzmsxf__", (ftnlen)219)];
	    sxform[(i__1 = i__ + (j + 21) * 6 - 43) < 180 && 0 <= i__1 ? i__1 
		    : s_rnge("sxform", i__1, "f_zzmsxf__", (ftnlen)220)] = 0.;
	    sxform[(i__1 = i__ + 3 + (j + 18) * 6 - 43) < 180 && 0 <= i__1 ? 
		    i__1 : s_rnge("sxform", i__1, "f_zzmsxf__", (ftnlen)221)] 
		    = drot1[(i__2 = i__ + j * 3 - 4) < 9 && 0 <= i__2 ? i__2 :
		     s_rnge("drot1", i__2, "f_zzmsxf__", (ftnlen)221)];
	}
    }
    n = 3;
    mxmg_(&sxform[72], &sxform[36], &c__6, &c__6, &c__6, temp);
    mxmg_(temp, sxform, &c__6, &c__6, &c__6, expect);
    zzmsxf_(sxform, &n, output);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("OUTPUT", output, "=", expect, &c__36, &c_b13, ok, (ftnlen)6, (
	    ftnlen)1);
    tcase_("Four matrices multiplied together", (ftnlen)33);
    n = 4;
    for (j = 1; j <= 6; ++j) {
	for (i__ = 1; i__ <= 6; ++i__) {
	    output[(i__1 = i__ + j * 6 - 7) < 36 && 0 <= i__1 ? i__1 : s_rnge(
		    "output", i__1, "f_zzmsxf__", (ftnlen)241)] = -1.;
	}
    }
    for (j = 1; j <= 3; ++j) {
	for (i__ = 1; i__ <= 3; ++i__) {
	    sxform[(i__1 = i__ + (j + 24) * 6 - 43) < 180 && 0 <= i__1 ? i__1 
		    : s_rnge("sxform", i__1, "f_zzmsxf__", (ftnlen)248)] = 
		    rot2[(i__2 = i__ + j * 3 - 4) < 9 && 0 <= i__2 ? i__2 : 
		    s_rnge("rot2", i__2, "f_zzmsxf__", (ftnlen)248)];
	    sxform[(i__1 = i__ + 3 + (j + 27) * 6 - 43) < 180 && 0 <= i__1 ? 
		    i__1 : s_rnge("sxform", i__1, "f_zzmsxf__", (ftnlen)249)] 
		    = rot2[(i__2 = i__ + j * 3 - 4) < 9 && 0 <= i__2 ? i__2 : 
		    s_rnge("rot2", i__2, "f_zzmsxf__", (ftnlen)249)];
	    sxform[(i__1 = i__ + (j + 27) * 6 - 43) < 180 && 0 <= i__1 ? i__1 
		    : s_rnge("sxform", i__1, "f_zzmsxf__", (ftnlen)250)] = 0.;
	    sxform[(i__1 = i__ + 3 + (j + 24) * 6 - 43) < 180 && 0 <= i__1 ? 
		    i__1 : s_rnge("sxform", i__1, "f_zzmsxf__", (ftnlen)251)] 
		    = drot2[(i__2 = i__ + j * 3 - 4) < 9 && 0 <= i__2 ? i__2 :
		     s_rnge("drot2", i__2, "f_zzmsxf__", (ftnlen)251)];
	}
    }
    mxmg_(&sxform[108], &sxform[72], &c__6, &c__6, &c__6, expect);
    mxmg_(expect, &sxform[36], &c__6, &c__6, &c__6, temp);
    mxmg_(temp, sxform, &c__6, &c__6, &c__6, expect);
    zzmsxf_(sxform, &n, output);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("OUTPUT", output, "=", expect, &c__36, &c_b13, ok, (ftnlen)6, (
	    ftnlen)1);
    tcase_("Five matrices multiplied together", (ftnlen)33);
    n = 5;
    for (j = 1; j <= 6; ++j) {
	for (i__ = 1; i__ <= 6; ++i__) {
	    output[(i__1 = i__ + j * 6 - 7) < 36 && 0 <= i__1 ? i__1 : s_rnge(
		    "output", i__1, "f_zzmsxf__", (ftnlen)272)] = -1.;
	}
    }
    for (j = 1; j <= 3; ++j) {
	for (i__ = 1; i__ <= 3; ++i__) {
	    sxform[(i__1 = i__ + (j + 30) * 6 - 43) < 180 && 0 <= i__1 ? i__1 
		    : s_rnge("sxform", i__1, "f_zzmsxf__", (ftnlen)279)] = 
		    rot1[(i__2 = i__ + j * 3 - 4) < 9 && 0 <= i__2 ? i__2 : 
		    s_rnge("rot1", i__2, "f_zzmsxf__", (ftnlen)279)];
	    sxform[(i__1 = i__ + 3 + (j + 33) * 6 - 43) < 180 && 0 <= i__1 ? 
		    i__1 : s_rnge("sxform", i__1, "f_zzmsxf__", (ftnlen)280)] 
		    = rot1[(i__2 = i__ + j * 3 - 4) < 9 && 0 <= i__2 ? i__2 : 
		    s_rnge("rot1", i__2, "f_zzmsxf__", (ftnlen)280)];
	    sxform[(i__1 = i__ + (j + 33) * 6 - 43) < 180 && 0 <= i__1 ? i__1 
		    : s_rnge("sxform", i__1, "f_zzmsxf__", (ftnlen)281)] = 0.;
	    sxform[(i__1 = i__ + 3 + (j + 30) * 6 - 43) < 180 && 0 <= i__1 ? 
		    i__1 : s_rnge("sxform", i__1, "f_zzmsxf__", (ftnlen)282)] 
		    = drot1[(i__2 = i__ + j * 3 - 4) < 9 && 0 <= i__2 ? i__2 :
		     s_rnge("drot1", i__2, "f_zzmsxf__", (ftnlen)282)];
	}
    }
    mxmg_(&sxform[144], &sxform[108], &c__6, &c__6, &c__6, temp);
    mxmg_(temp, &sxform[72], &c__6, &c__6, &c__6, expect);
    mxmg_(expect, &sxform[36], &c__6, &c__6, &c__6, temp);
    mxmg_(temp, sxform, &c__6, &c__6, &c__6, expect);
    zzmsxf_(sxform, &n, output);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("OUTPUT", output, "=", expect, &c__36, &c_b13, ok, (ftnlen)6, (
	    ftnlen)1);
    t_success__(ok);
    return 0;
} /* f_zzmsxf__ */

