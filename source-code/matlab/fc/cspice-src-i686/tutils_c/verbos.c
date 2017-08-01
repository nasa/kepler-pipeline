/* verbos.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* $Procedure      VERBOS ( Display detailed information to the screen) */

logical verbos_0_(int n__)
{
    /* Initialized data */

    static logical disply = FALSE_;

    /* System generated locals */
    logical ret_val;


/* $ Abstract */

/*     This routine controls whether or not detailed information is */
/*     written to the screen and log file. */

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

/*      None. */

/* $ Keywords */

/*       TESTING */

/* $ Declarations */


/* $ Brief_I/O */

/*      VARIABLE  I/O  DESCRIPTION */
/*      --------  ---  -------------------------------------------------- */
/*       The function returns TRUE if details are to be displayed. */

/* $ Detailed_Input */

/*     None. */

/* $ Detailed_Output */

/*     The function returns TRUE if detailed information should be */
/*     written to the screen and log file.  This behavior is controlled */
/*     through the two entry points VERBON and VERBOFF. */

/* $ Parameters */

/*      None. */

/* $ Files */

/*      None. */

/* $ Exceptions */

/*     Error free. */

/* $ Particulars */

/*     This routines controls the writing of detailed messages to */
/*     the screen and log file.  The default behavior is to return */
/*     the value of FALSE.  You may turn on verbose output by calling */
/*     the entry point VERBON */

/*        ONOFF = VERBON */

/*     To turn verbose messages off call the entry point VERBOFF */

/*        ONOFF = VERBOFF */

/* $ Examples */

/*     Later. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*      W.L. Taber      (JPL) */

/* $ Literature_References */

/*      None. */

/* $ Version */

/* -    Testing Utilities Version 1.0.0, 21-NOV-1994 (WLT) */


/* -& */

/* $ Index_Entries */

/*     Determine the status of verbos output. */

/* -& */
/*     Entry points */


/*     Local Variables. */

    switch(n__) {
	case 1: goto L_verbon;
	case 2: goto L_verboff;
	}

    ret_val = disply;
    return ret_val;

L_verbon:
    disply = TRUE_;
    ret_val = TRUE_;
    return ret_val;

L_verboff:
    disply = FALSE_;
    ret_val = FALSE_;
    return ret_val;
} /* verbos_ */

logical verbos_(void)
{
    return verbos_0_(0);
    }

logical verbon_(void)
{
    return verbos_0_(1);
    }

logical verboff_(void)
{
    return verbos_0_(2);
    }

