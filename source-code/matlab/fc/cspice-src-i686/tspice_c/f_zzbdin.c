/* f_zzbdin.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__3 = 3;
static logical c_false = FALSE_;
static integer c__0 = 0;
static integer c__8 = 8;
static integer c__4 = 4;

/* $Procedure F_ZZBDIN ( Body Name/Code Initialization Test Family ) */
/* Subroutine */ int f_zzbdin__(logical *ok)
{
    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    extern /* Subroutine */ int zzbodini_(char *, char *, integer *, integer *
	    , integer *, integer *, integer *, ftnlen, ftnlen);
    integer codes[10];
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    char names[36*10];
    integer nocds;
    extern /* Subroutine */ int topen_(char *, ftnlen), t_success__(logical *)
	    , chckai_(char *, integer *, char *, integer *, integer *, 
	    logical *, ftnlen, ftnlen), chckxc_(logical *, char *, logical *, 
	    ftnlen), chcksi_(char *, integer *, char *, integer *, integer *, 
	    logical *, ftnlen, ftnlen);
    integer cmpocd[10], ordcod[10], cmponm[10];
    char nornam[36*10];
    integer ordnom[10];

/* $ Abstract */

/*     Test family to exercise the logic and code in the body name-code */
/*     processing software. */

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
/* $ Abstract */

/*     This include file lists the parameter collection */
/*     defining the number of SPICE ID -> NAME mappings. */

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

/*     naif_ids.req */

/* $ Keywords */

/*     Body mappings. */

/* $ Author_and_Institution */

/*     E.D. Wright (JPL) */

/* $ Version */

/*     SPICELIB 1.0.0 Tue Nov 15 13:59:42 2005 (EDW) */


/*     A script generates this file. Do not edit by hand. */
/*     Edit the creation script to modify the contents of */
/*     ZZBODTRN.INC. */


/*     Maximum size of a NAME string */


/*     Count of default SPICE mapping assignments. */

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

/*     This routine exercise the conformance of the body name-code */
/*     initialization routine, ZZBODINI, to the intended/designed */
/*     behavior. */

/*     We need not perform any stress tests here, as F_BODCOD */
/*     attempts to provide these sorts of tests from higher level */
/*     interfaces. */

/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     F.S. Turner     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    TSPICE Version 1.0.0, 26-AUG-2002 (FST) */


/* -& */

/*     Local Variables */


/*     Open the test family. */

    topen_("F_ZZBDIN", (ftnlen)8);

/* --- Case: ------------------------------------------------------ */

    tcase_("Nominal Behavior -- Simple Test", (ftnlen)31);
    s_copy(names, "A", (ftnlen)36, (ftnlen)1);
    s_copy(nornam, "A", (ftnlen)36, (ftnlen)1);
    codes[0] = 1000;
    s_copy(names + 36, "B", (ftnlen)36, (ftnlen)1);
    s_copy(nornam + 36, "B", (ftnlen)36, (ftnlen)1);
    codes[1] = 1001;
    s_copy(names + 72, "C", (ftnlen)36, (ftnlen)1);
    s_copy(nornam + 72, "C", (ftnlen)36, (ftnlen)1);
    codes[2] = 1002;

/*     Build the comparison order vectors. */

    cmponm[0] = 1;
    cmponm[1] = 2;
    cmponm[2] = 3;
    cmpocd[0] = 1;
    cmpocd[1] = 2;
    cmpocd[2] = 3;

/*     Toss this at ZZBODINI and see what drops out. */

    zzbodini_(names, nornam, codes, &c__3, ordnom, ordcod, &nocds, (ftnlen)36,
	     (ftnlen)36);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("NOCDS", &nocds, "=", &c__3, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chckai_("ORDNOM", ordnom, "=", cmponm, &c__3, ok, (ftnlen)6, (ftnlen)1);
    chckai_("ORDCOD", ordcod, "=", cmpocd, &nocds, ok, (ftnlen)6, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Nominal Behavior -- Modified Order Vector Test", (ftnlen)46);
    s_copy(names, "A", (ftnlen)36, (ftnlen)1);
    s_copy(names + 36, "B", (ftnlen)36, (ftnlen)1);
    s_copy(names + 72, "C", (ftnlen)36, (ftnlen)1);
    s_copy(names + 108, "D", (ftnlen)36, (ftnlen)1);
    s_copy(names + 144, "E", (ftnlen)36, (ftnlen)1);
    s_copy(names + 180, "F", (ftnlen)36, (ftnlen)1);
    s_copy(names + 216, "G", (ftnlen)36, (ftnlen)1);
    s_copy(names + 252, "H", (ftnlen)36, (ftnlen)1);
    s_copy(nornam, "A", (ftnlen)36, (ftnlen)1);
    s_copy(nornam + 36, "B", (ftnlen)36, (ftnlen)1);
    s_copy(nornam + 72, "C", (ftnlen)36, (ftnlen)1);
    s_copy(nornam + 108, "D", (ftnlen)36, (ftnlen)1);
    s_copy(nornam + 144, "E", (ftnlen)36, (ftnlen)1);
    s_copy(nornam + 180, "F", (ftnlen)36, (ftnlen)1);
    s_copy(nornam + 216, "G", (ftnlen)36, (ftnlen)1);
    s_copy(nornam + 252, "H", (ftnlen)36, (ftnlen)1);
    codes[0] = 1000;
    codes[1] = 1000;
    codes[2] = 1000;
    codes[3] = 1001;
    codes[4] = 1002;
    codes[5] = 1000;
    codes[6] = 1003;
    codes[7] = 1000;

/*     Build the comparison order vectors. */

    cmponm[0] = 1;
    cmponm[1] = 2;
    cmponm[2] = 3;
    cmponm[3] = 4;
    cmponm[4] = 5;
    cmponm[5] = 6;
    cmponm[6] = 7;
    cmponm[7] = 8;
    cmpocd[0] = 8;
    cmpocd[1] = 4;
    cmpocd[2] = 5;
    cmpocd[3] = 7;

/*     Toss this at ZZBODINI and see what drops out. */

    zzbodini_(names, nornam, codes, &c__8, ordnom, ordcod, &nocds, (ftnlen)36,
	     (ftnlen)36);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("NOCDS", &nocds, "=", &c__4, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chckai_("ORDNOM", ordnom, "=", cmponm, &c__8, ok, (ftnlen)6, (ftnlen)1);
    chckai_("ORDCOD", ordcod, "=", cmpocd, &nocds, ok, (ftnlen)6, (ftnlen)1);

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_zzbdin__ */

