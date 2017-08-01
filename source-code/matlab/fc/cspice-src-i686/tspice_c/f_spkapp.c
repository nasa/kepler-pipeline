/* f_spkapp.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_true = TRUE_;
static logical c_false = FALSE_;
static integer c__399 = 399;
static integer c__499 = 499;
static integer c__6 = 6;
static doublereal c_b40 = 1e-12;
static integer c__799 = 799;
static doublereal c_b94 = 1e-10;
static doublereal c_b97 = 1e-7;
static doublereal c_b148 = 1e-8;
static integer c__3 = 3;
static doublereal c_b167 = 1e-14;

/* $Procedure      F_SPKAPP ( Family of tests for SPKAPP) */
/* Subroutine */ int f_spkapp__(logical *ok)
{
    /* System generated locals */
    doublereal d__1;

    /* Local variables */
    doublereal sobs[6];
    extern /* Subroutine */ int spkapp_o__(integer *, doublereal *, char *, 
	    doublereal *, char *, doublereal *, doublereal *, ftnlen, ftnlen),
	     tcase_(char *, ftnlen);
    doublereal state[6];
    extern /* Subroutine */ int topen_(char *, ftnlen);
    char error[80];
    extern doublereal vnorm_(doublereal *);
    extern /* Subroutine */ int t_success__(logical *);
    doublereal state2[6];
    extern /* Subroutine */ int chckad_(char *, doublereal *, char *, 
	    doublereal *, integer *, doublereal *, logical *, ftnlen, ftnlen);
    doublereal et;
    extern /* Subroutine */ int chcksd_(char *, doublereal *, char *, 
	    doublereal *, doublereal *, logical *, ftnlen, ftnlen);
    doublereal lt;
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen);
    extern doublereal clight_(void);
    extern /* Subroutine */ int kilfil_(char *, ftnlen);
    integer spkhan;
    doublereal estate[6];
    extern /* Subroutine */ int spkgeo_(integer *, doublereal *, char *, 
	    integer *, doublereal *, doublereal *, ftnlen), stlabx_(
	    doublereal *, doublereal *, doublereal *), tparse_(char *, 
	    doublereal *, char *, ftnlen, ftnlen), spkapp_(integer *, 
	    doublereal *, char *, doublereal *, char *, doublereal *, 
	    doublereal *, ftnlen, ftnlen), spkuef_(integer *), spkssb_(
	    integer *, doublereal *, char *, doublereal *, ftnlen), vminug_(
	    doublereal *, integer *, doublereal *), tstpck_(char *, logical *,
	     logical *, ftnlen), tstspk_(char *, logical *, integer *, ftnlen)
	    ;
    doublereal elt;

/* $ Abstract */

/*     This routine tests the various pathways in SPKAPP. */


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

/* -    Version 2.0.0 13-DEC-2001 (NJB) */

/* -    Version 1.0.0  (WLT) */

/* -& */

/*     Test Utility Functions */


/*     SPICELIB Functions */


/*     Local Variables */


/*     Begin every test family with an open call. */

    topen_("F_SPKAPP", (ftnlen)8);
    kilfil_("test_pck.ker", (ftnlen)12);
    tstpck_("test_pck.ker", &c_true, &c_false, (ftnlen)12);
    tstspk_("test_spk.bsp", &c_true, &spkhan, (ftnlen)12);
    tparse_("1 JAN 1995", &et, error, (ftnlen)10, (ftnlen)80);
    tcase_("Make sure unrecognized aberration corrections are handle as exce"
	    "ptions. ", (ftnlen)72);
    spkssb_(&c__399, &et, "J2000", sobs, (ftnlen)5);
    spkapp_(&c__499, &et, "J2000", sobs, "LTIME", state, &lt, (ftnlen)5, (
	    ftnlen)5);
    chckxc_(&c_true, "SPICE(SPKINVALIDOPTION)", ok, (ftnlen)23);
    tcase_("Make sure that non-inertial frames are detected and diagnosed as"
	    " unacceptable. ", (ftnlen)79);
    spkssb_(&c__399, &et, "IAU_EARTH", sobs, (ftnlen)9);
    spkapp_(&c__499, &et, "IAU_EARTH", sobs, "NONE", state, &lt, (ftnlen)9, (
	    ftnlen)4);
    chckxc_(&c_true, "SPICE(BADFRAME)", ok, (ftnlen)15);
    tcase_("Compare SPKAPP and SPKGEO when no corrections are requested ", (
	    ftnlen)60);
    spkgeo_(&c__499, &et, "DE-125", &c__399, estate, &elt, (ftnlen)6);
    spkssb_(&c__399, &et, "DE-125", sobs, (ftnlen)6);
    spkapp_(&c__499, &et, "DE-125", sobs, "NONE", state, &lt, (ftnlen)6, (
	    ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("STATE", state, "~/", estate, &c__6, &c_b40, ok, (ftnlen)5, (
	    ftnlen)2);
    chcksd_("LT", &lt, "~/", &elt, &c_b40, ok, (ftnlen)2, (ftnlen)2);
    tcase_("Compare SPKAPP and SPKAPP_O ( the old version ) when light time "
	    "only is requested. ", (ftnlen)83);
    spkssb_(&c__399, &et, "DE-125", sobs, (ftnlen)6);
    spkapp_(&c__499, &et, "DE-125", sobs, "LT", state, &lt, (ftnlen)6, (
	    ftnlen)2);
    spkapp_o__(&c__499, &et, "DE-125", sobs, "LT", estate, &elt, (ftnlen)6, (
	    ftnlen)2);
    elt = vnorm_(estate) / clight_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("STATE", state, "~/", estate, &c__6, &c_b40, ok, (ftnlen)5, (
	    ftnlen)2);
    chcksd_("LT", &lt, "~/", &elt, &c_b40, ok, (ftnlen)2, (ftnlen)2);
    tcase_("Compare SPKAPP and SPKAPP_O when light time plus stellar aberrat"
	    "ion corrections are applied. ", (ftnlen)93);
    spkssb_(&c__399, &et, "DE-125", sobs, (ftnlen)6);
    spkapp_(&c__499, &et, "DE-125", sobs, "LT+S", state, &lt, (ftnlen)6, (
	    ftnlen)4);
    spkapp_o__(&c__499, &et, "DE-125", sobs, "LT+S", estate, &elt, (ftnlen)6, 
	    (ftnlen)4);
    elt = vnorm_(estate) / clight_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("STATE", state, "~/", estate, &c__6, &c_b40, ok, (ftnlen)5, (
	    ftnlen)2);
    chcksd_("LT", &lt, "~/", &elt, &c_b40, ok, (ftnlen)2, (ftnlen)2);
    tcase_("Examine the differences in LT and STATES for when simple light t"
	    "ime corrections are applied versus converged light time correcti"
	    "ons. ", (ftnlen)133);
    spkssb_(&c__399, &et, "DE-125", sobs, (ftnlen)6);
    spkapp_(&c__799, &et, "DE-125", sobs, "LT", state, &lt, (ftnlen)6, (
	    ftnlen)2);
    spkapp_(&c__799, &et, "DE-125", sobs, "CN", estate, &elt, (ftnlen)6, (
	    ftnlen)2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("STATE", state, "~/", estate, &c__6, &c_b94, ok, (ftnlen)5, (
	    ftnlen)2);
    chcksd_("LT", &lt, "~", &elt, &c_b97, ok, (ftnlen)2, (ftnlen)1);
    tcase_("Repeat for the transmission case.", (ftnlen)33);
    spkssb_(&c__399, &et, "DE-125", sobs, (ftnlen)6);
    spkapp_(&c__799, &et, "DE-125", sobs, "XLT", state, &lt, (ftnlen)6, (
	    ftnlen)3);
    spkapp_(&c__799, &et, "DE-125", sobs, "XCN", estate, &elt, (ftnlen)6, (
	    ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("STATE", state, "~/", estate, &c__6, &c_b94, ok, (ftnlen)5, (
	    ftnlen)2);
    chcksd_("LT", &lt, "~", &elt, &c_b97, ok, (ftnlen)2, (ftnlen)1);
    tcase_("Repeat, using blanks and mixed case for REF, where REF is inerti"
	    "al", (ftnlen)66);
    spkssb_(&c__399, &et, "DE-125", sobs, (ftnlen)6);
    spkapp_(&c__799, &et, " d E- 125 ", sobs, "XLT", state, &lt, (ftnlen)10, (
	    ftnlen)3);
    spkapp_(&c__799, &et, "DE-125", sobs, "XCN", estate, &elt, (ftnlen)6, (
	    ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("STATE", state, "~/", estate, &c__6, &c_b94, ok, (ftnlen)5, (
	    ftnlen)2);
    chcksd_("LT", &lt, "~", &elt, &c_b97, ok, (ftnlen)2, (ftnlen)1);
    tcase_("Test transmit light time:  make sure XLT corrections gives negat"
	    "ive of position obtained when target observer vector is computed"
	    " using at ET+LT using LT correction.", (ftnlen)164);
    spkssb_(&c__399, &et, "DE-125", sobs, (ftnlen)6);
    spkapp_(&c__799, &et, "DE-125", sobs, "XLT", estate, &elt, (ftnlen)6, (
	    ftnlen)3);
    d__1 = et + elt;
    spkssb_(&c__799, &d__1, "DE-125", sobs, (ftnlen)6);
    d__1 = et + elt;
    spkapp_(&c__399, &d__1, "DE-125", sobs, "LT", state, &lt, (ftnlen)6, (
	    ftnlen)2);
    vminug_(state, &c__6, state2);
    chcksd_("LT", &lt, "~/", &elt, &c_b148, ok, (ftnlen)2, (ftnlen)2);
    chckad_("STATE", state2, "~~/", estate, &c__3, &c_b148, ok, (ftnlen)5, (
	    ftnlen)3);
    tcase_("Test transmit light time:  make sure XCN corrections gives negat"
	    "ive of position obtained when target observer vector is computed"
	    " using at ET+LT using CN correction.", (ftnlen)164);
    spkssb_(&c__399, &et, "DE-125", sobs, (ftnlen)6);
    spkapp_(&c__799, &et, "DE-125", sobs, "XCN", estate, &elt, (ftnlen)6, (
	    ftnlen)3);
    d__1 = et + elt;
    spkssb_(&c__799, &d__1, "DE-125", sobs, (ftnlen)6);
    d__1 = et + elt;
    spkapp_(&c__399, &d__1, "DE-125", sobs, "CN", state, &lt, (ftnlen)6, (
	    ftnlen)2);
    vminug_(state, &c__6, state2);
    chcksd_("LT", &lt, "~/", &elt, &c_b167, ok, (ftnlen)2, (ftnlen)2);
    chckad_("STATE", state2, "~~/", estate, &c__3, &c_b167, ok, (ftnlen)5, (
	    ftnlen)3);
    tcase_("Repeat, using mixed case and white space in flag.", (ftnlen)49);
    spkssb_(&c__399, &et, "de-125", sobs, (ftnlen)6);
    spkapp_(&c__799, &et, "DE-125", sobs, " Xc N", estate, &elt, (ftnlen)6, (
	    ftnlen)5);
    d__1 = et + elt;
    spkssb_(&c__799, &d__1, "DE-125", sobs, (ftnlen)6);
    d__1 = et + elt;
    spkapp_(&c__399, &d__1, "DE-125", sobs, "C n", state, &lt, (ftnlen)6, (
	    ftnlen)3);
    vminug_(state, &c__6, state2);
    chcksd_("LT", &lt, "~/", &elt, &c_b167, ok, (ftnlen)2, (ftnlen)2);
    chckad_("STATE", state2, "~~/", estate, &c__3, &c_b167, ok, (ftnlen)5, (
	    ftnlen)3);
    tcase_("Test transmit stellar aberration:  make sure correction is same "
	    "as that obtained by using LT only and then applying STLABX. ", (
	    ftnlen)124);
    spkssb_(&c__399, &et, "DE-125", sobs, (ftnlen)6);
    spkapp_(&c__799, &et, "DE-125", sobs, "XLT+S", estate, &elt, (ftnlen)6, (
	    ftnlen)5);
    spkapp_(&c__799, &et, "DE-125", sobs, "XLT", state, &lt, (ftnlen)6, (
	    ftnlen)3);
    stlabx_(state, &sobs[3], state2);
    chcksd_("LT", &lt, "~/", &elt, &c_b167, ok, (ftnlen)2, (ftnlen)2);
    chckad_("STATE", state2, "~~/", estate, &c__3, &c_b167, ok, (ftnlen)5, (
	    ftnlen)3);
    tcase_("Repeat, using mixed case and white space in flag.", (ftnlen)49);
    spkssb_(&c__399, &et, "DE-125", sobs, (ftnlen)6);
    spkapp_(&c__799, &et, "DE-125", sobs, " X lT+ s", estate, &elt, (ftnlen)6,
	     (ftnlen)8);
    spkapp_(&c__799, &et, "DE-125", sobs, "XlT", state, &lt, (ftnlen)6, (
	    ftnlen)3);
    stlabx_(state, &sobs[3], state2);
    chcksd_("LT", &lt, "~/", &elt, &c_b167, ok, (ftnlen)2, (ftnlen)2);
    chckad_("STATE", state2, "~~/", estate, &c__3, &c_b167, ok, (ftnlen)5, (
	    ftnlen)3);
    tcase_("Test \"CN\" transmit stellar aberration:  make sure correction i"
	    "s same as that obtained by using CN only and then applying STLAB"
	    "X. ", (ftnlen)129);
    spkssb_(&c__399, &et, "DE-125", sobs, (ftnlen)6);
    spkapp_(&c__799, &et, "DE-125", sobs, "XCN+S", estate, &elt, (ftnlen)6, (
	    ftnlen)5);
    spkapp_(&c__799, &et, "DE-125", sobs, "XCN", state, &lt, (ftnlen)6, (
	    ftnlen)3);
    stlabx_(state, &sobs[3], state2);
    chcksd_("LT", &lt, "~/", &elt, &c_b167, ok, (ftnlen)2, (ftnlen)2);
    chckad_("STATE", state2, "~~/", estate, &c__3, &c_b167, ok, (ftnlen)5, (
	    ftnlen)3);

/*     That's all folks. */

    spkuef_(&spkhan);
    kilfil_("test_spk.bsp", (ftnlen)12);
    t_success__(ok);
    return 0;
} /* f_spkapp__ */

