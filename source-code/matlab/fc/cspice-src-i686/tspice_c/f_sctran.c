/* f_sctran.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c_n77 = -77;
static logical c_false = FALSE_;
static logical c_true = TRUE_;
static integer c_b13 = -77777;
static integer c__0 = 0;
static integer c_n82 = -82;

/* $Procedure      F_SCTRAN ( Test SCLK name/ID translation ) */
/* Subroutine */ int f_sctran__(logical *ok)
{
    char name__[80];
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    logical found;
    extern /* Subroutine */ int topen_(char *, ftnlen), t_success__(logical *)
	    , scid2n_(integer *, char *, logical *, ftnlen), scn2id_(char *, 
	    integer *, logical *, ftnlen);
    integer id;
    extern /* Subroutine */ int chcksc_(char *, char *, char *, char *, 
	    logical *, ftnlen, ftnlen, ftnlen, ftnlen), chckxc_(logical *, 
	    char *, logical *, ftnlen), chcksi_(char *, integer *, char *, 
	    integer *, integer *, logical *, ftnlen, ftnlen), chcksl_(char *, 
	    logical *, logical *, logical *, ftnlen);

/* $ Abstract */

/*     This routine tests the routines SCN2ID and SCID2N. */

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

/* -    TSPICE Version 1.0.0, 02-MAR-2000 (NJB) */

/* -& */

/*     Test Utility Functions */


/*     SPICELIB Functions */


/*     Local Parameters */


/*     Local Variables */


/*     Begin every test family with an open call. */

    topen_("F_SCTRAN", (ftnlen)8);
    tcase_("Map ID -77 to clock string.", (ftnlen)27);
    scid2n_(&c_n77, name__, &found, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "GALILEO ORBITER SCLK", ok, (ftnlen)4, (
	    ftnlen)80, (ftnlen)1, (ftnlen)20);
    tcase_("Map ID -77777 to clock string.  No string should be found.", (
	    ftnlen)58);
    scid2n_(&c_b13, name__, &found, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    tcase_("Map clock string 'GALILEO ORBITER SCLK' to ID -77 .", (ftnlen)51);
    scn2id_("GALILEO ORBITER SCLK", &id, &found, (ftnlen)20);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("ID", &id, "=", &c_n77, &c__0, ok, (ftnlen)2, (ftnlen)1);
    tcase_("Map clock string 'galileo orbiter sclk' to ID -77 .", (ftnlen)51);
    scn2id_("galileo orbiter sclk", &id, &found, (ftnlen)20);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("ID", &id, "=", &c_n77, &c__0, ok, (ftnlen)2, (ftnlen)1);
    tcase_("Map clock string '  gAlileo orbIter  sclk' to ID -77 .", (ftnlen)
	    54);
    scn2id_("  gAlileo orbIter  sclk", &id, &found, (ftnlen)23);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("ID", &id, "=", &c_n77, &c__0, ok, (ftnlen)2, (ftnlen)1);
    tcase_("Map clock string '  CAS sclk' to ID -82 .", (ftnlen)41);
    scn2id_("  CAS sclk", &id, &found, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("ID", &id, "=", &c_n82, &c__0, ok, (ftnlen)2, (ftnlen)1);
    tcase_("Map 'XYXYX' to clock ID.  No ID should be found.", (ftnlen)48);
    scn2id_("XYXYX", &id, &found, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    t_success__(ok);
    return 0;
} /* f_sctran__ */

