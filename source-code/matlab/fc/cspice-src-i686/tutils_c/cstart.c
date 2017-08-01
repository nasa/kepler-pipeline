/* cstart.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__1000 = 1000;

/* $Procedure      CSTART ( Clean Start ) */
/* Subroutine */ int cstart_(void)
{
    /* System generated locals */
    integer i__1, i__2;

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    extern /* Subroutine */ int zzekscln_(void), zzbodrst_(void);
    integer i__, n;
    extern integer cardi_(integer *);
    extern /* Subroutine */ int ekuef_(integer *), ckupf_(integer *);
    integer tries;
    extern /* Subroutine */ int dafhof_(integer *), dafcls_(integer *), 
	    dashof_(integer *);
    integer handls[1006];
    extern /* Subroutine */ int dascls_(integer *), kfiles_(void), pckuof_(
	    integer *), clpool_(void), spkuef_(integer *), ssizei_(integer *, 
	    integer *);

/* $ Abstract */

/*     Clear the kernel pool and unload all SPICE binary kernels */
/*     so that the SPICE subsystems are in a "clean" state. */

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

/*     UTILITY */

/* $ Declarations */
/*     None. */
/* $ Brief_I/O */

/*     None. */

/* $ Detailed_Input */

/*     None. */

/* $ Detailed_Output */

/*     None. */

/* $ Parameters */

/*     None. */

/* $ Files */

/*     None. */

/* $ Exceptions */

/*     Error free. */

/* $ Particulars */

/*     This routine clears the SPICE kernel pool and unloads all */
/*     SPK, CK, binary PCK, an EK files.  In addition it closes any */
/*     other open DAFs or DASs. */

/*     Finally, the entry point KFILES of FILREG is called so that */
/*     all test files created by the user's test program will */
/*     automatically be removed from the user's disk. */

/* $ Examples */

/*     This routine is primarily intended as a utility for use of */
/*     the Test Utilities routine TOPEN.  See TOPEN for an example */
/*     of usage of this routine. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     N.J. Bachman    (JPL) */
/*     W.L. Taber      (JPL) */
/*     F.S. Turner     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    TESTUTIL Version 1.2.0, 26-AUG-2002 (FST) */

/* -    TESTUTIL Version 1.1.0, 14-DEC-2001 (FST) (NJB) */

/*        Increased MAXHND to 1000 to accomodate the changes to the */
/*        DAF system as a result of the handle manager integration. */

/*        Two incorrect calls to DAFHOF were replaced with the */
/*        intended calls to DASHOF. */

/* -    TESTUTIL Version 1.0.0, 27-JUL-1999 (WLT) */


/* -& */
/* $ Index_Entries */

/*     Prepare all systems for a clean start */

/* -& */

/*     Spicelib Functions */


/*     Local Variables */


/*     First, clear the kernel pool */

    clpool_();

/*     Clear the built-in body list. */

    zzbodrst_();

/*     Next unload every SPK, CK, and binary PCK file. */

    ssizei_(&c__1000, handls);
    dafhof_(handls);
    n = cardi_(handls);
    i__1 = n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	spkuef_(&handls[(i__2 = i__ + 5) < 1006 && 0 <= i__2 ? i__2 : s_rnge(
		"handls", i__2, "cstart_", (ftnlen)165)]);
	ckupf_(&handls[(i__2 = i__ + 5) < 1006 && 0 <= i__2 ? i__2 : s_rnge(
		"handls", i__2, "cstart_", (ftnlen)166)]);
	pckuof_(&handls[(i__2 = i__ + 5) < 1006 && 0 <= i__2 ? i__2 : s_rnge(
		"handls", i__2, "cstart_", (ftnlen)167)]);
    }

/*     We have probably now closed every DAF, but just in case, we */
/*     get the remaining open handles and continue closing them until */
/*     all DAFs are closed. */

    ssizei_(&c__1000, handls);
    dafhof_(handls);
    n = cardi_(handls);
    tries = 0;
    while(n > 0 && tries < 100) {
	i__1 = n;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    dafcls_(&handls[(i__2 = i__ + 5) < 1006 && 0 <= i__2 ? i__2 : 
		    s_rnge("handls", i__2, "cstart_", (ftnlen)183)]);
	}
	ssizei_(&c__1000, handls);
	dafhof_(handls);
	n = cardi_(handls);
	++tries;
    }

/*     Finally, unload any EK's or DAS's */

    dashof_(handls);
    n = cardi_(handls);
    i__1 = n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	ekuef_(&handls[(i__2 = i__ + 5) < 1006 && 0 <= i__2 ? i__2 : s_rnge(
		"handls", i__2, "cstart_", (ftnlen)201)]);
    }

/*     We have probably now closed every DAS, but just in case, we */
/*     get the remaining open HANDLS(I)s and continue closing them until */
/*     all DAS files are closed.  But first, unload the scratch file */
/*     used by the EK scratch area system. */

    zzekscln_();

/*     Ok, now clean up the other DAS files. */

    tries = 0;
    ssizei_(&c__1000, handls);
    dashof_(handls);
    n = cardi_(handls);
    while(n > 0 && tries < 100) {
	i__1 = n;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    dascls_(&handls[(i__2 = i__ + 5) < 1006 && 0 <= i__2 ? i__2 : 
		    s_rnge("handls", i__2, "cstart_", (ftnlen)222)]);
	}
	++tries;
	ssizei_(&c__1000, handls);
	dashof_(handls);
	n = cardi_(handls);
    }

/*     Wipe out all test files. */

    kfiles_();
    return 0;
} /* cstart_ */

