/* ison.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* $Procedure   ISON ( Determine whether a system is on or off ) */
logical ison_0_(int n__, char *system, ftnlen system_len)
{
    /* Initialized data */

    static integer nsys = 0;
    static integer ovflow = 200;

    /* System generated locals */
    integer i__1;
    logical ret_val;

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer);
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    integer i__;
    static logical state[200];
    extern integer isrchc_(char *, integer *, char *, ftnlen, ftnlen);
    static char systms[32*200];

/* $ Abstract */

/*     Test whether or not a specifie system is "on" (enabled). */

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

/*     «KEYWORD */

/* $ Declarations */
/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  -------------------------------------------------- */
/*     SYSTEM     I   The name of some system that may be on or off */
/*     ISON       O   .TRUE. if the specified system is "ON" */
/*     ISOFF      O   .TRUE  if the specified system if "OFF" */
/*     SETON      O   .TRUE. */
/*     SETOFF     O   .TRUE. */

/*     The function returns the state of the specified system. */

/* $ Detailed_Input */

/*     SYSTEM    is the name of some system.  The routine is case */
/*               sensitive for SYSTEM. */

/* $ Detailed_Output */

/*     The function returns the value TRUE if the specified system */
/*     is on.  By default all systems are regarded as being in the */
/*     "ON" state (value .TRUE. returned) unless initialized to */
/*     "OFF" by a call to SETOFF. */

/* $ Parameters */

/*     None. */

/* $ Files */

/*     None. */

/* $ Exceptions */

/*     Error free. */

/* $ Particulars */

/*     This routine is a utility routine that allows different */
/*     parts of a program to communicate the status and set the */
/*     state of some "system" of the program. */

/* $ Examples */

/*     The following illustrates how this routine and the entry points */
/*     SETON, SETOFF are used within the SPICE Test Utilities Package. */


/*     The routines TSETUP sets the status of the exception handling */
/*     checks to OFF.  This means that no calls have been made to */
/*     the checker function CHCKXC. */

/*     TSETUP */
/*     ====== */


/*        DUMMY = SETOFF ( 'CHCKXC' ) */


/*     In the routine CHCKXC,  the following call is placed to */
/*     indicate that a call to CHCKXC has been made and that */
/*     the current status of the SPICE exception handling system */
/*     has been checked. */

/*     CHCKSC */
/*     ====== */

/*        DUMMY = SETON ( 'CHCKXC' ) */


/*     Because the status of exception checking is maintained in this */
/*     way, the routines TCASE, TOPEN and TCLOSE can determine whether */
/*     the status of the SPICE exception handling system has been */
/*     checked recently.  If it has NOT been checked, these routines */
/*     perform such a check (under the assumption that NO exception is */
/*     expected) and then reset the "checking status" to unchecked */
/*     so that the next test case exercised  can test the exception */
/*     handling status if needed. */


/*     TCASE */
/*     ====== */

/*     IF ( ISOFF ( 'CHCKXC' ) ) THEN */
/*        CALL CHCKXC ( .FALSE., ' ',  OK ) */
/*        DUMMY = SETOFF( 'CHCKXC' ) */
/*     END IF */


/*     TOPEN */
/*     ====== */

/*     IF ( ISOFF ( 'CHCKXC' ) ) THEN */
/*        CALL CHCKXC ( .FALSE., ' ',  OK ) */
/*        DUMMY = SETOFF( 'CHCKXC' ) */
/*     END IF */


/*     TCLOSE */
/*     ====== */

/*     IF ( ISOFF ( 'CHCKXC' ) ) THEN */
/*        CALL CHCKXC ( .FALSE., ' ',  OK ) */
/*        DUMMY = SETOFF( 'CHCKXC' ) */
/*     END IF */



/*     off */
/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     W.L. Taber      (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    Testing Utilities Version 1.1.0, 28-DEC-2001 (NJB) */

/*        Dummy return values are now set for entry points SETON and */
/*        SETOFF.  Updated Procedure line and Abstract. */

/* -    Testing Utilities Version 1.0.0, 27-JUL-1999 (WLT) */

/* -& */
/* $ Index_Entries */

/*     Test the status of a system */

/* -& */

/*     SPICELIB Functions */

    switch(n__) {
	case 1: goto L_isoff;
	case 2: goto L_seton;
	case 3: goto L_setoff;
	}

    i__ = isrchc_(system, &nsys, systms, system_len, (ftnlen)32);
    if (i__ > 0) {
	ret_val = state[(i__1 = i__ - 1) < 200 && 0 <= i__1 ? i__1 : s_rnge(
		"state", i__1, "ison_", (ftnlen)225)];
    } else {
	ret_val = TRUE_;
    }
    return ret_val;

L_isoff:
    i__ = isrchc_(system, &nsys, systms, system_len, (ftnlen)32);
    if (i__ > 0) {
	ret_val = ! state[(i__1 = i__ - 1) < 200 && 0 <= i__1 ? i__1 : s_rnge(
		"state", i__1, "ison_", (ftnlen)239)];
    } else {
	ret_val = FALSE_;
    }
    return ret_val;

L_seton:

/*        Provide a dummy return value to satisfy various compiler */
/*        checks. */

    ret_val = TRUE_;

/*        See if we recognize this system. */

    i__ = isrchc_(system, &nsys, systms, system_len, (ftnlen)32);
    if (i__ == 0) {

/*           Nope, add it into the list. */

	if (nsys < 200) {
	    ++nsys;
	    s_copy(systms + (((i__1 = nsys - 1) < 200 && 0 <= i__1 ? i__1 : 
		    s_rnge("systms", i__1, "ison_", (ftnlen)267)) << 5), 
		    system, (ftnlen)32, system_len);
	    state[(i__1 = nsys - 1) < 200 && 0 <= i__1 ? i__1 : s_rnge("state"
		    , i__1, "ison_", (ftnlen)268)] = TRUE_;
	} else {
	    ++ovflow;
	    if (ovflow > 200) {
		ovflow = 1;
	    }
	    s_copy(systms + (((i__1 = nsys - 1) < 200 && 0 <= i__1 ? i__1 : 
		    s_rnge("systms", i__1, "ison_", (ftnlen)277)) << 5), 
		    system, (ftnlen)32, system_len);
	    state[(i__1 = nsys - 1) < 200 && 0 <= i__1 ? i__1 : s_rnge("state"
		    , i__1, "ison_", (ftnlen)278)] = TRUE_;
	}
    } else {
	state[(i__1 = i__ - 1) < 200 && 0 <= i__1 ? i__1 : s_rnge("state", 
		i__1, "ison_", (ftnlen)284)] = TRUE_;
    }
    return ret_val;

L_setoff:

/*        Provide a dummy return value to satisfy various compiler */
/*        checks. */

    ret_val = TRUE_;

/*        See if we recognize this system. */

    i__ = isrchc_(system, &nsys, systms, system_len, (ftnlen)32);
    if (i__ == 0) {

/*           Nope, add it into the list. */

	if (nsys < 200) {
	    ++nsys;
	    s_copy(systms + (((i__1 = nsys - 1) < 200 && 0 <= i__1 ? i__1 : 
		    s_rnge("systms", i__1, "ison_", (ftnlen)312)) << 5), 
		    system, (ftnlen)32, system_len);
	    state[(i__1 = nsys - 1) < 200 && 0 <= i__1 ? i__1 : s_rnge("state"
		    , i__1, "ison_", (ftnlen)313)] = FALSE_;
	} else {
	    ++ovflow;
	    if (ovflow > 200) {
		ovflow = 1;
	    }
	    s_copy(systms + (((i__1 = nsys - 1) < 200 && 0 <= i__1 ? i__1 : 
		    s_rnge("systms", i__1, "ison_", (ftnlen)322)) << 5), 
		    system, (ftnlen)32, system_len);
	    state[(i__1 = nsys - 1) < 200 && 0 <= i__1 ? i__1 : s_rnge("state"
		    , i__1, "ison_", (ftnlen)323)] = FALSE_;
	}
    } else {
	state[(i__1 = i__ - 1) < 200 && 0 <= i__1 ? i__1 : s_rnge("state", 
		i__1, "ison_", (ftnlen)329)] = FALSE_;
    }
    return ret_val;
} /* ison_ */

logical ison_(char *system, ftnlen system_len)
{
    return ison_0_(0, system, system_len);
    }

logical isoff_(char *system, ftnlen system_len)
{
    return ison_0_(1, system, system_len);
    }

logical seton_(char *system, ftnlen system_len)
{
    return ison_0_(2, system, system_len);
    }

logical setoff_(char *system, ftnlen system_len)
{
    return ison_0_(3, system, system_len);
    }

