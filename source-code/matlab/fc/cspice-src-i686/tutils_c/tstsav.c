/* tstsav.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* $Procedure      TSTSAV ( Save test info ) */

/* Subroutine */ int tstsav_0_(int n__, char *env, char *versn, char *time, 
	ftnlen env_len, ftnlen versn_len, ftnlen time_len)
{
    /* Initialized data */

    static char myver[80] = "                                               "
	    "                                 ";
    static char myenv[80] = "                                               "
	    "                                 ";
    static char mytime[80] = "                                              "
	    "                                  ";
    static char myfile[255] = "                                             "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                  ";

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);


/* $ Abstract */

/*     Keep the global test information available for other parts */
/*     of the test system */

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
/*      ENV       I/O   is the environment in which the test is performed */
/*      VERSN     I/O   is the version of the test program */
/*      TIME      I/O   is the date-time timestamp for the test program. */

/* $ Detailed_Input */

/*     ENV        is the environment in which the test is performed. */

/*     VERSN      is the version of the test program being executed. */

/*     TIME       is the time at which the program begain. */

/* $ Detailed_Output */

/*     ENV        is the environment in which the test is performed. */

/*     VERSN      is the version of the test program being executed. */

/*     TIME       is the time at which the program begain. */

/* $ Parameters */

/*      None. */

/* $ Files */

/*      None. */

/* $ Exceptions */

/*     Error free. */

/* $ Particulars */

/*     This is simply a storage routine to allow various portions of */
/*     the test program to retrieve the various global attributes */
/*     of a test program. */

/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*      W.L. Taber      (JPL) */

/* $ Literature_References */

/*      None. */

/* $ Version */

/* -    Testing Utilities Version 1.0.0, 4-NOV-1994 (WLT) */


/* -& */
    switch(n__) {
	case 1: goto L_tstget;
	case 2: goto L_tstslf;
	case 3: goto L_tstglf;
	}

    s_copy(myenv, env, (ftnlen)80, env_len);
    s_copy(myver, versn, (ftnlen)80, versn_len);
    s_copy(mytime, time, (ftnlen)80, time_len);
    return 0;

/*     The entry point below fetches the saved values of ENV, VERSN, */
/*     and TIME. */


L_tstget:
    s_copy(env, myenv, env_len, (ftnlen)80);
    s_copy(versn, myver, versn_len, (ftnlen)80);
    s_copy(time, mytime, time_len, (ftnlen)80);
    return 0;

/*     This entry point allows you to save the name of the test log file. */


L_tstslf:
    s_copy(myfile, env, (ftnlen)255, env_len);
    return 0;

/*     This entry point allows you to retrieve the name of the test log */
/*     file. */


L_tstglf:
    s_copy(env, myfile, env_len, (ftnlen)255);
    return 0;
} /* tstsav_ */

/* Subroutine */ int tstsav_(char *env, char *versn, char *time, ftnlen 
	env_len, ftnlen versn_len, ftnlen time_len)
{
    return tstsav_0_(0, env, versn, time, env_len, versn_len, time_len);
    }

/* Subroutine */ int tstget_(char *env, char *versn, char *time, ftnlen 
	env_len, ftnlen versn_len, ftnlen time_len)
{
    return tstsav_0_(1, env, versn, time, env_len, versn_len, time_len);
    }

/* Subroutine */ int tstslf_(char *env, ftnlen env_len)
{
    return tstsav_0_(2, env, (char *)0, (char *)0, env_len, (ftnint)0, (
	    ftnint)0);
    }

/* Subroutine */ int tstglf_(char *env, ftnlen env_len)
{
    return tstsav_0_(3, env, (char *)0, (char *)0, env_len, (ftnint)0, (
	    ftnint)0);
    }

