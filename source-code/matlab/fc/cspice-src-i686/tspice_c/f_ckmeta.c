/* f_ckmeta.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c_b4 = -10000;
static logical c_true = TRUE_;
static integer c__0 = 0;
static integer c_n900 = -900;
static logical c_false = FALSE_;
static integer c_b28 = -10100;
static integer c_b30 = -10101;
static integer c_n10 = -10;
static integer c_b42 = -900000;
static integer c_b44 = -990000;
static integer c_n990 = -990;
static integer c__9 = 9;
static integer c__1 = 1;
static integer c_n1001 = -1001;
static integer c_n12 = -12;
static integer c__13 = 13;
static integer c_n20 = -20;
static integer c__20 = 20;
static integer c_n9 = -9;
static integer c__11 = 11;

/* $Procedure      F_CKMETA (Family of CKMETA tests) */
/* Subroutine */ int f_ckmeta__(logical *ok)
{
    /* System generated locals */
    char ch__1[16], ch__2[16];
    cllist cl__1;

    /* Builtin functions */
    integer s_wsle(cilist *);
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer do_lio(integer *, integer *, char *, ftnlen), e_wsle(void), 
	    f_clos(cllist *);

    /* Local variables */
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    integer spkid;
    extern /* Subroutine */ int topen_(char *, ftnlen);
    integer sunit;
    extern /* Subroutine */ int t_success__(logical *);
    extern /* Character */ VOID begdat_(char *, ftnlen);
    integer idcode;
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     ckmeta_(integer *, char *, integer *, ftnlen), chcksi_(char *, 
	    integer *, char *, integer *, integer *, logical *, ftnlen, 
	    ftnlen);
    integer sclkid;
    extern /* Subroutine */ int kilfil_(char *, ftnlen), ldpool_(char *, 
	    ftnlen), txtopn_(char *, integer *, ftnlen);

    /* Fortran I/O blocks */
    static cilist io___5 = { 0, 0, 0, 0, 0 };
    static cilist io___6 = { 0, 0, 0, 0, 0 };
    static cilist io___7 = { 0, 0, 0, 0, 0 };
    static cilist io___8 = { 0, 0, 0, 0, 0 };
    static cilist io___9 = { 0, 0, 0, 0, 0 };
    static cilist io___10 = { 0, 0, 0, 0, 0 };
    static cilist io___11 = { 0, 0, 0, 0, 0 };
    static cilist io___12 = { 0, 0, 0, 0, 0 };


/* $ Abstract */

/*     This routine tests the routine CKMETA. */

/*     It first checks out all listed exceptions.  It then */
/*     loads */

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

    topen_("F_CKMETA", (ftnlen)8);
    tcase_("Check to make sure that a META item other than  SPK or SCLK caus"
	    "e an error to be signalled. ", (ftnlen)92);

/*        Give IDCODE and initial value other than 0. */

    idcode = 1;
    ckmeta_(&c_b4, "IK", &idcode, (ftnlen)2);
    chckxc_(&c_true, "SPICE(UNKNOWNCKMETA)", ok, (ftnlen)20);
    chcksi_("IDCODE", &idcode, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);
    tcase_("Check that values of CKID greater than -1000 cause an idcode of "
	    "0 to be returned for both SCLK and SPK. ", (ftnlen)104);
    spkid = 1;
    sclkid = 1;
    ckmeta_(&c_n900, "SPK", &spkid, (ftnlen)3);
    ckmeta_(&c_n900, "SCLK", &sclkid, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("SPKID", &spkid, "=", &c__0, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksi_("SCLKID", &sclkid, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);
    tcase_("No kernel pool values are stored yet.  Make sure that CKID's les"
	    "s than -1000 return the correct values. ", (ftnlen)104);
    ckmeta_(&c_b28, "SPK", &spkid, (ftnlen)3);
    ckmeta_(&c_b30, "SCLK", &sclkid, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("SPKID", &spkid, "=", &c_n10, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksi_("SCLKID", &sclkid, "=", &c_n10, &c__0, ok, (ftnlen)6, (ftnlen)1);
    ckmeta_(&c_b42, "SPK", &spkid, (ftnlen)3);
    ckmeta_(&c_b44, "SCLK", &sclkid, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("SPKID", &spkid, "=", &c_n900, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksi_("SCLKID", &sclkid, "=", &c_n990, &c__0, ok, (ftnlen)6, (ftnlen)1);
    tcase_("Load the kernel pool with associated SPK and SCLK values. Make s"
	    "ure that we can retrieve them. ", (ftnlen)95);
    kilfil_("myconns.ker", (ftnlen)11);
    txtopn_("myconns.ker", &sunit, (ftnlen)11);
    io___5.ciunit = sunit;
    s_wsle(&io___5);
    begdat_(ch__2, (ftnlen)16);
    s_copy(ch__1, ch__2, (ftnlen)16, (ftnlen)16);
    do_lio(&c__9, &c__1, ch__1, (ftnlen)16);
    e_wsle();
    io___6.ciunit = sunit;
    s_wsle(&io___6);
    do_lio(&c__9, &c__1, "CK_-1001_SPK   = -12 ", (ftnlen)21);
    e_wsle();
    io___7.ciunit = sunit;
    s_wsle(&io___7);
    do_lio(&c__9, &c__1, "CK_-1001_SCLK  = 13 ", (ftnlen)20);
    e_wsle();
    io___8.ciunit = sunit;
    s_wsle(&io___8);
    do_lio(&c__9, &c__1, "CK_-10000_SPK  = -20 ", (ftnlen)21);
    e_wsle();
    io___9.ciunit = sunit;
    s_wsle(&io___9);
    do_lio(&c__9, &c__1, "CK_-10000_SCLK = 20 ", (ftnlen)20);
    e_wsle();
    io___10.ciunit = sunit;
    s_wsle(&io___10);
    do_lio(&c__9, &c__1, "CK_-900_SPK    = -9 ", (ftnlen)20);
    e_wsle();
    io___11.ciunit = sunit;
    s_wsle(&io___11);
    do_lio(&c__9, &c__1, "CK_-900_SCLK   = 11 ", (ftnlen)20);
    e_wsle();
    io___12.ciunit = sunit;
    s_wsle(&io___12);
    do_lio(&c__9, &c__1, " ", (ftnlen)1);
    e_wsle();
    cl__1.cerr = 0;
    cl__1.cunit = sunit;
    cl__1.csta = 0;
    f_clos(&cl__1);
    ldpool_("myconns.ker", (ftnlen)11);
    kilfil_("myconns.ker", (ftnlen)11);
    ckmeta_(&c_n1001, "SPK", &spkid, (ftnlen)3);
    ckmeta_(&c_n1001, "SCLK", &sclkid, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("SPKID", &spkid, "=", &c_n12, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksi_("SCLKID", &sclkid, "=", &c__13, &c__0, ok, (ftnlen)6, (ftnlen)1);
    ckmeta_(&c_b4, "SPK", &spkid, (ftnlen)3);
    ckmeta_(&c_b4, "SCLK", &sclkid, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("SPKID", &spkid, "=", &c_n20, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksi_("SCLKID", &sclkid, "=", &c__20, &c__0, ok, (ftnlen)6, (ftnlen)1);
    ckmeta_(&c_n900, "SPK", &spkid, (ftnlen)3);
    ckmeta_(&c_n900, "SCLK", &sclkid, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("SPKID", &spkid, "=", &c_n9, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksi_("SCLKID", &sclkid, "=", &c__11, &c__0, ok, (ftnlen)6, (ftnlen)1);
    tcase_("Kernel pool values are stored.  Make sure that CKID's less than "
	    "-1000 return the correct values if they aren't in the pool.", (
	    ftnlen)123);
    ckmeta_(&c_b28, "SPK", &spkid, (ftnlen)3);
    ckmeta_(&c_b30, "SCLK", &sclkid, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("SPKID", &spkid, "=", &c_n10, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksi_("SCLKID", &sclkid, "=", &c_n10, &c__0, ok, (ftnlen)6, (ftnlen)1);
    ckmeta_(&c_b42, "SPK", &spkid, (ftnlen)3);
    ckmeta_(&c_b44, "SCLK", &sclkid, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("SPKID", &spkid, "=", &c_n900, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksi_("SCLKID", &sclkid, "=", &c_n990, &c__0, ok, (ftnlen)6, (ftnlen)1);
    t_success__(ok);
    return 0;
} /* f_ckmeta__ */

