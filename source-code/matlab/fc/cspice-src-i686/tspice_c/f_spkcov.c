/* f_spkcov.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__0 = 0;
static logical c_false = FALSE_;
static integer c__1000 = 1000;
static integer c__12 = 12;
static integer c__399 = 399;
static integer c__1 = 1;
static integer c__2 = 2;
static doublereal c_b47 = 0.;
static doublereal c_b56 = 1e6;
static doublereal c_b57 = 1e7;
static logical c_true = TRUE_;
static integer c__20 = 20;
static integer c__3 = 3;
static integer c__4 = 4;
static integer c_b134 = -1000000;

/* $Procedure      F_SPKCOV ( SPKCOV tests ) */
/* Subroutine */ int f_spkcov__(logical *ok)
{
    /* Initialized data */

    static integer body[3] = { 4,5,6 };
    static integer nseg[3] = { 10,20,30 };

    /* System generated locals */
    integer i__1, i__2, i__3;
    doublereal d__1;
    cllist cl__1;

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer);
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer f_clos(cllist *);

    /* Local variables */
    doublereal last;
    integer xids[10], i__, j;
    extern integer cardd_(doublereal *);
    extern /* Subroutine */ int dafbt_(char *, integer *, ftnlen);
    extern integer cardi_(integer *);
    extern /* Subroutine */ int tcase_(char *, ftnlen), repmi_(char *, char *,
	     integer *, char *, ftnlen, ftnlen, ftnlen);
    doublereal cover[1006];
    char title[80];
    extern /* Subroutine */ int topen_(char *, ftnlen);
    doublereal first;
    extern /* Subroutine */ int tstek_(char *, integer *, integer *, logical *
	    , integer *, ftnlen), spkw08_(integer *, integer *, integer *, 
	    char *, doublereal *, doublereal *, char *, integer *, integer *, 
	    doublereal *, doublereal *, doublereal *, ftnlen, ftnlen);
    integer xunit;
    extern /* Subroutine */ int t_success__(logical *), tstck3_(char *, char *
	    , logical *, logical *, logical *, integer *, ftnlen, ftnlen), 
	    chckad_(char *, doublereal *, char *, doublereal *, integer *, 
	    doublereal *, logical *, ftnlen, ftnlen), chckai_(char *, integer 
	    *, char *, integer *, integer *, logical *, ftnlen, ftnlen);
    integer handle;
    extern /* Subroutine */ int cleard_(integer *, doublereal *), delfil_(
	    char *, ftnlen), scardd_(integer *, doublereal *), chckxc_(
	    logical *, char *, logical *, ftnlen), chcksi_(char *, integer *, 
	    char *, integer *, integer *, logical *, ftnlen, ftnlen), spkobj_(
	    char *, integer *, ftnlen), spkcls_(integer *), ssized_(integer *,
	     doublereal *), wninsd_(doublereal *, doublereal *, doublereal *);
    doublereal states[12]	/* was [6][2] */;
    extern /* Subroutine */ int spkcov_(char *, integer *, doublereal *, 
	    ftnlen);
    doublereal xcover[3018]	/* was [1006][3] */;
    extern /* Subroutine */ int ssizei_(integer *, integer *), insrti_(
	    integer *, integer *), spkopn_(char *, char *, integer *, integer 
	    *, ftnlen, ftnlen), txtopn_(char *, integer *, ftnlen);
    integer ids[10];

/* $ Abstract */

/*     This routine tests the SPICELIB routines */

/*        SPKCOV */
/*        SPKOBJ */

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

/* -    TSPICE Version 1.0.0, 30-DEC-2004 (NJB) */

/* -& */

/*     SPICELIB functions */


/*     Local parameters */


/*     Local variables */


/*     Saved variables */


/*     Initial values */


/*     Begin every test family with an open call. */

    topen_("F_SPKCOV", (ftnlen)8);

/* --- Case: ------------------------------------------------------ */

    tcase_("Setup:  create SPK file.", (ftnlen)24);

/*     Create an SPK file with data for three bodies. */

    spkopn_("spkcov.bsp", "spkcov.bsp", &c__0, &handle, (ftnlen)10, (ftnlen)
	    10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Initialize the expected coverage windows. */

    for (i__ = 1; i__ <= 3; ++i__) {
	ssized_(&c__1000, &xcover[(i__1 = i__ * 1006 - 1006) < 3018 && 0 <= 
		i__1 ? i__1 : s_rnge("xcover", i__1, "f_spkcov__", (ftnlen)
		144)]);
    }
    cleard_(&c__12, states);
    for (i__ = 1; i__ <= 3; ++i__) {
	i__2 = nseg[(i__1 = i__ - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge("nseg", 
		i__1, "f_spkcov__", (ftnlen)151)];
	for (j = 1; j <= i__2; ++j) {

/*           Create segments for body I. */

	    if (i__ == 1) {

/*              Create NSEG(1) segments, each one separated */
/*              by a 1 second gap. */

		first = (j - 1) * 11.;
		last = first + 10.;
	    } else if (i__ == 2) {

/*              Create NSEG(2) segments, each one separated */
/*              by a 1 second gap.  This time, create the */
/*              segments in decreasing time order. */

		first = (nseg[1] - j) * 101.;
		last = first + 100.;
	    } else {

/*              I equals 3. */

/*              Create NSEG(3) segments with no gaps. */

		first = (j - 1) * 1e3;
		last = first + 1e3;
	    }

/*           Add to the expected coverage window for this body. */

	    wninsd_(&first, &last, &xcover[(i__1 = i__ * 1006 - 1006) < 3018 
		    && 0 <= i__1 ? i__1 : s_rnge("xcover", i__1, "f_spkcov__",
		     (ftnlen)186)]);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    d__1 = last - first + 1e-6;
	    spkw08_(&handle, &body[(i__1 = i__ - 1) < 3 && 0 <= i__1 ? i__1 : 
		    s_rnge("body", i__1, "f_spkcov__", (ftnlen)190)], &c__399,
		     "J2000", &first, &last, "TEST", &c__1, &c__2, states, &
		    first, &d__1, (ftnlen)5, (ftnlen)4);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	}
    }
    spkcls_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Loop through the canned cases. */

    for (i__ = 1; i__ <= 3; ++i__) {

/* --- Case: ------------------------------------------------------ */

	s_copy(title, "Check coverage for body #.", (ftnlen)80, (ftnlen)26);
	repmi_(title, "#", &i__, title, (ftnlen)80, (ftnlen)1, (ftnlen)80);
	tcase_(title, (ftnlen)80);
	ssized_(&c__1000, cover);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	spkcov_("spkcov.bsp", &body[(i__2 = i__ - 1) < 3 && 0 <= i__2 ? i__2 :
		 s_rnge("body", i__2, "f_spkcov__", (ftnlen)219)], cover, (
		ftnlen)10);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Check cardinality of coverage window. */

	i__1 = cardd_(cover);
	i__3 = cardd_(&xcover[(i__2 = i__ * 1006 - 1006) < 3018 && 0 <= i__2 ?
		 i__2 : s_rnge("xcover", i__2, "f_spkcov__", (ftnlen)225)]);
	chcksi_("CARDD(COVER)", &i__1, "=", &i__3, &c__0, ok, (ftnlen)12, (
		ftnlen)1);

/*        Check coverage window. */

	i__1 = cardd_(cover);
	chckad_("COVER", &cover[6], "=", &xcover[(i__2 = i__ * 1006 - 1000) < 
		3018 && 0 <= i__2 ? i__2 : s_rnge("xcover", i__2, "f_spkcov__"
		, (ftnlen)232)], &i__1, &c_b47, ok, (ftnlen)5, (ftnlen)1);
    }

/*     Loop through the canned cases.  This time, use a coverage */
/*     window that already contains data. */

    scardd_(&c__0, cover);
    for (i__ = 1; i__ <= 3; ++i__) {

/* --- Case: ------------------------------------------------------ */

	s_copy(title, "Check coverage for body #; COVER starts out non-empty."
		, (ftnlen)80, (ftnlen)54);
	repmi_(title, "#", &i__, title, (ftnlen)80, (ftnlen)1, (ftnlen)80);
	tcase_(title, (ftnlen)80);
	ssized_(&c__1000, cover);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	wninsd_(&c_b56, &c_b57, cover);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	spkcov_("spkcov.bsp", &body[(i__2 = i__ - 1) < 3 && 0 <= i__2 ? i__2 :
		 s_rnge("body", i__2, "f_spkcov__", (ftnlen)262)], cover, (
		ftnlen)10);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Check cardinality of coverage window. */

	wninsd_(&c_b56, &c_b57, &xcover[(i__2 = i__ * 1006 - 1006) < 3018 && 
		0 <= i__2 ? i__2 : s_rnge("xcover", i__2, "f_spkcov__", (
		ftnlen)268)]);
	i__1 = cardd_(cover);
	i__3 = cardd_(&xcover[(i__2 = i__ * 1006 - 1006) < 3018 && 0 <= i__2 ?
		 i__2 : s_rnge("xcover", i__2, "f_spkcov__", (ftnlen)270)]);
	chcksi_("CARDD(COVER)", &i__1, "=", &i__3, &c__0, ok, (ftnlen)12, (
		ftnlen)1);

/*        Check coverage window. */

	i__1 = cardd_(cover);
	chckad_("COVER", &cover[6], "=", &xcover[(i__2 = i__ * 1006 - 1000) < 
		3018 && 0 <= i__2 ? i__2 : s_rnge("xcover", i__2, "f_spkcov__"
		, (ftnlen)277)], &i__1, &c_b47, ok, (ftnlen)5, (ftnlen)1);
    }

/*     Error cases: */


/* --- Case: ------------------------------------------------------ */

    tcase_("Try to find coverage for a transfer SPK.", (ftnlen)40);
    txtopn_("spkcov.xsp", &xunit, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    dafbt_("spkcov.bsp", &xunit, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    cl__1.cerr = 0;
    cl__1.cunit = xunit;
    cl__1.csta = 0;
    f_clos(&cl__1);
    spkcov_("spkcov.xsp", body, cover, (ftnlen)10);
    chckxc_(&c_true, "SPICE(INVALIDFORMAT)", ok, (ftnlen)20);

/* --- Case: ------------------------------------------------------ */

    tcase_("Try to find coverage for a CK.", (ftnlen)30);
    tstck3_("spkcov.bc", "spkcov.tsc", &c_false, &c_false, &c_false, &handle, 
	    (ftnlen)9, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    spkcov_("spkcov.bc", body, cover, (ftnlen)9);
    chckxc_(&c_true, "SPICE(INVALIDFILETYPE)", ok, (ftnlen)22);

/* --- Case: ------------------------------------------------------ */

    tcase_("Try to find coverage for an EK.", (ftnlen)31);
    tstek_("spkcov.bes", &c__1, &c__20, &c_false, &handle, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    spkcov_("spkcov.bes", body, cover, (ftnlen)10);
    chckxc_(&c_true, "SPICE(INVALIDARCHTYPE)", ok, (ftnlen)22);
/* ****************************************************** */
/* ****************************************************** */
/* ****************************************************** */
/*     SPKOBJ tests */
/* ****************************************************** */
/* ****************************************************** */
/* ****************************************************** */

/* --- Case: ------------------------------------------------------ */

    tcase_("Find objects in our test SPK.", (ftnlen)29);
    ssizei_(&c__3, ids);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    ssizei_(&c__3, xids);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    for (i__ = 1; i__ <= 3; ++i__) {
	insrti_(&body[(i__2 = i__ - 1) < 3 && 0 <= i__2 ? i__2 : s_rnge("body"
		, i__2, "f_spkcov__", (ftnlen)352)], xids);
    }
    spkobj_("spkcov.bsp", ids, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check cardinality of object set. */

    i__2 = cardi_(ids);
    i__1 = cardi_(xids);
    chcksi_("CARDI(IDS)", &i__2, "=", &i__1, &c__0, ok, (ftnlen)10, (ftnlen)1)
	    ;

/*     Check object set. */

    i__2 = cardi_(xids);
    chckai_("IDS", &ids[6], "=", &xids[6], &i__2, ok, (ftnlen)3, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Find objects in our test SPK.  Start with non-empty ID set.", (
	    ftnlen)59);
    ssizei_(&c__4, ids);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    ssizei_(&c__4, xids);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    insrti_(&c_b134, xids);
    for (i__ = 1; i__ <= 3; ++i__) {
	insrti_(&body[(i__2 = i__ - 1) < 3 && 0 <= i__2 ? i__2 : s_rnge("body"
		, i__2, "f_spkcov__", (ftnlen)387)], xids);
    }
    insrti_(&c_b134, ids);
    spkobj_("spkcov.bsp", ids, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check cardinality of object set. */

    i__2 = cardi_(ids);
    i__1 = cardi_(xids);
    chcksi_("CARDI(IDS)", &i__2, "=", &i__1, &c__0, ok, (ftnlen)10, (ftnlen)1)
	    ;

/*     Check object set. */

    i__2 = cardi_(xids);
    chckai_("IDS", &ids[6], "=", &xids[6], &i__2, ok, (ftnlen)3, (ftnlen)1);

/*     Error cases: */


/* --- Case: ------------------------------------------------------ */

    tcase_("Try to find objects for a transfer SPK.", (ftnlen)39);

/*     Initialize the IDS set. */

    ssizei_(&c__3, ids);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    spkobj_("spkcov.xsp", ids, (ftnlen)10);
    chckxc_(&c_true, "SPICE(INVALIDFORMAT)", ok, (ftnlen)20);

/* --- Case: ------------------------------------------------------ */

    tcase_("Try to find objects for a CK.", (ftnlen)29);
    spkobj_("spkcov.bc", ids, (ftnlen)9);
    chckxc_(&c_true, "SPICE(INVALIDFILETYPE)", ok, (ftnlen)22);

/* --- Case: ------------------------------------------------------ */

    tcase_("Try to find objects for an EK.", (ftnlen)30);
    spkobj_("spkcov.bes", ids, (ftnlen)10);
    chckxc_(&c_true, "SPICE(INVALIDARCHTYPE)", ok, (ftnlen)22);

/*     Clean up. */

    delfil_("spkcov.bsp", (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    delfil_("spkcov.xsp", (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    delfil_("spkcov.bc", (ftnlen)9);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    delfil_("spkcov.bes", (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_success__(ok);
    return 0;
} /* f_spkcov__ */

