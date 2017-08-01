/* tstopl.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__9 = 9;
static integer c__1 = 1;
static integer c__2 = 2;
static logical c_false = FALSE_;

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

/* Subroutine */ int tstopl_(char *lognam, char *versn, ftnlen lognam_len, 
	ftnlen versn_len)
{
    /* Builtin functions */
    integer s_wsle(cilist *), e_wsle(void), do_lio(integer *, integer *, char 
	    *, ftnlen);
    /* Subroutine */ int s_stop(char *, ftnlen), s_copy(char *, char *, 
	    ftnlen, ftnlen);

    /* Local variables */
    static char time[32], attr[32*2];
    static integer n;
    extern logical failed_(void);
    static char logfil[255];
    extern /* Subroutine */ int curtim_(char *, ftnlen), tstfil_(char *, char 
	    *, char *, ftnlen, ftnlen, ftnlen), pltfrm_(integer *, integer *, 
	    char *, ftnlen), suffix_(char *, integer *, char *, ftnlen, 
	    ftnlen), tstlog_(char *, logical *, ftnlen), tstsav_(char *, char 
	    *, char *, ftnlen, ftnlen, ftnlen), tkvrsn_(char *, char *, 
	    ftnlen, ftnlen);
    static char env[80*2], tkv[32];

    /* Fortran I/O blocks */
    static cilist io___2 = { 0, 6, 0, 0, 0 };
    static cilist io___3 = { 0, 6, 0, 0, 0 };
    static cilist io___4 = { 0, 6, 0, 0, 0 };



/* $ Version */

/* -     Test Utilities Version 1.1.0, 12-MAY-1998 (WLT) */

/*         Added output of the toolkit version to the logfile. */

/* -     Command Loop Configured Version 1.0.0, 3-MAY-1994 (WLT) */

/*         This is the configured version of the Command Loop */
/*         software as of May 4, 1994 */


/*     This routine opens the log file that will be used for loging */
/*     commands.  It should only be called once.  If a log file */
/*     cannot be opened, the routine stop. */


/*     Empty out the internal error buffers. */

    tstfil_(lognam, "LOG", logfil, lognam_len, (ftnlen)3, (ftnlen)255);
    if (failed_()) {
	s_wsle(&io___2);
	e_wsle();
	s_wsle(&io___3);
	do_lio(&c__9, &c__1, "A log file cannot be opened.", (ftnlen)28);
	e_wsle();
	s_wsle(&io___4);
	e_wsle();
	s_stop("", (ftnlen)0);
    }

/*     Fetch the current time and the current platform information. */

    curtim_(time, (ftnlen)32);
    pltfrm_(&c__2, &n, attr, (ftnlen)32);
    tkvrsn_("TOOLKIT", tkv, (ftnlen)7, (ftnlen)32);
    s_copy(env, "--", (ftnlen)80, (ftnlen)2);
    s_copy(env + 80, "--", (ftnlen)80, (ftnlen)2);
    suffix_(attr, &c__1, env, (ftnlen)32, (ftnlen)80);
    suffix_("--", &c__1, env, (ftnlen)2, (ftnlen)80);
    suffix_(attr + 32, &c__1, env + 80, (ftnlen)32, (ftnlen)80);
    suffix_("--", &c__1, env + 80, (ftnlen)2, (ftnlen)80);
    tstlog_(env, &c_false, (ftnlen)80);
    tstlog_(env + 80, &c_false, (ftnlen)80);
    tstlog_(versn, &c_false, versn_len);
    tstlog_(tkv, &c_false, (ftnlen)32);
    tstlog_(time, &c_false, (ftnlen)32);

/*     Save the Environment, Version and Time so that it may be used */
/*     in an error or pass log. */

    tstsav_(env, versn, time, (ftnlen)80, versn_len, (ftnlen)32);
    return 0;
} /* tstopl_ */

