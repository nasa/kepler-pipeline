/* shoerr.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* $Procedure      SHOERR ( Show Errors ) */
/* Subroutine */ int shoerr_(void)
{
    extern /* Subroutine */ int errdev_(char *, char *, ftnlen, ftnlen);

/* $ Abstract */

/*     This routine sets the error handling within a test case so */
/*     that error messages are sent to the screen.  When the */
/*     test case ends, messages are once again sent to 'NULL' */

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

/*     TESTING */

/* $ Declarations */
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

/*     This routine allows you to cause error messages issued through */
/*     the SPICE exception handling system to be sent to the screen */
/*     instead of being blocked from output by the Test Utilities */
/*     library. */

/*     However, this effect lasts only for the duration of a single */
/*     test case.  Once a new test case or family is specified */
/*     by a call to TCASE or TOPEN, error messages will once again */
/*     be prohibited from being displayed on the terminal window. */

/*     This routine is primarily useful in the debugging stages of */
/*     a test case or test family. */

/* $ Examples */

/*     Suppose that you are creating a test case within a family of */
/*     test cases and wish to have all text associated with an */
/*     exception that may arise within the scope of a test case */
/*     to be sent to standard output.  Simply set up your */
/*     test case in this way. */

/*        CALL TCASE ( 'Name of the test case.' ) */
/*        CALL SHOERR */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     W.L. Taber      (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    Test Utilities Version 1.0.0, 27-JUL-1999 (WLT) */


/* -& */
    errdev_("SET", "SCREEN", (ftnlen)3, (ftnlen)6);
    return 0;
} /* shoerr_ */

