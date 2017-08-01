/* f_chgrfx.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__1 = 1;
static integer c__10013 = 10013;
static logical c_true = TRUE_;

/* $Procedure      F_CHGRFX ( Test the Change IRF exceptions ) */
/* Subroutine */ int f_chgrfx__(logical *ok)
{
    extern /* Subroutine */ int tcase_(char *, ftnlen), topen_(char *, ftnlen)
	    , t_success__(logical *), irfdef_(integer *), chckxc_(logical *, 
	    char *, logical *, ftnlen), irfrot_(integer *, integer *, 
	    doublereal *);
    doublereal rot[9]	/* was [3][3] */;

/* $ Abstract */

/*     This routine is for examining the error message returned */
/*     by IRFROT and IRFDEF */

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

/*     Local Variables */


/*     Begin every test family with an open call. */

    topen_("F_CHGRFX", (ftnlen)8);
    tcase_("Make sure an unrecognized FROM frame is properly diagnosed. ", (
	    ftnlen)60);
    irfrot_(&c__1, &c__10013, rot);
    chckxc_(&c_true, "SPICE(IRFNOTREC)", ok, (ftnlen)16);
    tcase_("Make sure an unrecognized TO frame is properly diagnosed. ", (
	    ftnlen)58);
    irfrot_(&c__10013, &c__1, rot);
    chckxc_(&c_true, "SPICE(IRFNOTREC)", ok, (ftnlen)16);
    tcase_("Make sure an unrecognized DEFAULT frame is properly diagnosed. ", 
	    (ftnlen)63);
    irfdef_(&c__10013);
    chckxc_(&c_true, "SPICE(IRFNOTREC)", ok, (ftnlen)16);
    t_success__(ok);
    return 0;
} /* f_chgrfx__ */

