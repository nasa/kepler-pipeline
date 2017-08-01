/* f_ls.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_true = TRUE_;
static logical c_false = FALSE_;
static doublereal c_b36 = .005;

/* $Procedure      F_LS ( Test solar longitude routines ) */
/* Subroutine */ int f_ls__(logical *ok)
{
    /* Initialized data */

    static char abcorr[15*3] = "NONE           " "LT             " "LT+S    "
	    "       ";

    /* System generated locals */
    integer i__1;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    integer i__, j;
    extern /* Subroutine */ int etcal_(doublereal *, char *, ftnlen);
    doublereal range;
    extern /* Subroutine */ int tcase_(char *, ftnlen), repmc_(char *, char *,
	     char *, char *, ftnlen, ftnlen, ftnlen, ftnlen);
    extern doublereal jyear_(void), lspcn_(char *, doublereal *, char *, 
	    ftnlen, ftnlen);
    char title[80];
    extern /* Subroutine */ int topen_(char *, ftnlen), t_success__(logical *)
	    ;
    doublereal ra, et;
    integer handle;
    doublereal ls, lt;
    extern /* Subroutine */ int recrad_(doublereal *, doublereal *, 
	    doublereal *, doublereal *), chcksd_(char *, doublereal *, char *,
	     doublereal *, doublereal *, logical *, ftnlen, ftnlen), chckxc_(
	    logical *, char *, logical *, ftnlen), delfil_(char *, ftnlen), 
	    spkuef_(integer *);
    doublereal sstate[6];
    extern /* Subroutine */ int tstpck_(char *, logical *, logical *, ftnlen),
	     spkezr_(char *, doublereal *, char *, char *, char *, doublereal 
	    *, doublereal *, ftnlen, ftnlen, ftnlen, ftnlen);
    char timstr[40];
    extern /* Subroutine */ int tstlsk_(void), tstspk_(char *, logical *, 
	    integer *, ftnlen);
    doublereal dec;

/* $ Abstract */

/*     This routine tests the SPICELIB routine */

/*        LSPCN */

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

/* $ Version */

/* -    TSPICE Version 1.0.0, 07-JAN-2005 (NJB) */

/* -& */

/*     SPICELIB functions */


/*     Local parameters */


/*     Local variables */


/*     Saved variables */


/*     Initial values */


/*     Begin every test family with an open call. */

    topen_("F_LS", (ftnlen)4);

/* --- Case: ------------------------------------------------------ */

    tcase_("Setup:  create and load kernels.", (ftnlen)32);

/*     Create, load, and delete a PCK, an SPK and an LSK. */

    tstpck_("f_ls.tpc", &c_true, &c_false, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    tstspk_("f_ls.bsp", &c_true, &handle, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    tstlsk_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Test for all aberration corrections. */

    for (i__ = 1; i__ <= 3; ++i__) {

/*        For a variety of times of year, find the RA of */
/*        the earth-sun vector in the ECLIPJ2000 frame. */

	for (j = 1; j <= 100; ++j) {

/* --- Case: ------------------------------------------------------ */

	    et = (j - 1) * jyear_() / 100;
	    s_copy(title, "ET = #; ABCORR = #", (ftnlen)80, (ftnlen)18);
	    etcal_(&et, timstr, (ftnlen)40);
	    repmc_(title, "#", timstr, title, (ftnlen)80, (ftnlen)1, (ftnlen)
		    40, (ftnlen)80);
	    repmc_(title, "#", abcorr + ((i__1 = i__ - 1) < 3 && 0 <= i__1 ? 
		    i__1 : s_rnge("abcorr", i__1, "f_ls__", (ftnlen)150)) * 
		    15, title, (ftnlen)80, (ftnlen)1, (ftnlen)15, (ftnlen)80);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    tcase_(title, (ftnlen)80);
	    spkezr_("SUN", &et, "ECLIPJ2000", abcorr + ((i__1 = i__ - 1) < 3 
		    && 0 <= i__1 ? i__1 : s_rnge("abcorr", i__1, "f_ls__", (
		    ftnlen)154)) * 15, "EARTH", sstate, &lt, (ftnlen)3, (
		    ftnlen)10, (ftnlen)15, (ftnlen)5);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    recrad_(sstate, &range, &ra, &dec);

/*           Find Ls. */

	    ls = lspcn_("EARTH", &et, abcorr + ((i__1 = i__ - 1) < 3 && 0 <= 
		    i__1 ? i__1 : s_rnge("abcorr", i__1, "f_ls__", (ftnlen)
		    163)) * 15, (ftnlen)5, (ftnlen)15);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    chcksd_("LS", &ls, "~", &ra, &c_b36, ok, (ftnlen)2, (ftnlen)1);
	}
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("Clean up: delete SPK file.", (ftnlen)26);

/*     Get rid of the SPK file.  First unload using the routine */
/*     corresponding to the loader called by TSTSPK. */

    spkuef_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    delfil_("f_ls.bsp", (ftnlen)8);
    t_success__(ok);
    return 0;
} /* f_ls__ */

