/* exesys.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* $Procedure   EXESYS  ( Execute system command ) */
/* Subroutine */ int exesys_(char *cmd, ftnlen cmd_len)
{
    extern /* Subroutine */ int chkin_(char *, ftnlen), errch_(char *, char *,
	     ftnlen, ftnlen);
    extern integer rtrim_(char *, ftnlen);
    extern /* Subroutine */ int sigerr_(char *, ftnlen), chkout_(char *, 
	    ftnlen), setmsg_(char *, ftnlen), errint_(char *, integer *, 
	    ftnlen);
    extern logical return_(void);
    integer status;
    extern integer system_(char *, ftnlen);

/* $ Abstract */

/*     Execute an operating system command. */

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
/* $ Brief_I/O */

/*     Variable  I/O  Description */
/*     --------  ---  -------------------------------------------------- */
/*     CMD        I   Command to be executed. */

/* $ Detailed_Input */

/*     CMD            is a character string containing a command */
/*                    recognized by the command line interpreter of */
/*                    the operating system.  The significance of case */
/*                    in CMD is system-dependent.  Trailing white space */
/*                    is not significant. */

/* $ Detailed_Output */

/*     None.   See $Particulars for a description of the action of this */
/*     routine. */

/* $ Parameters */

/*     None. */

/* $ Exceptions */

/*     1)  If the input command is not executed successfully, and if */
/*         this routine is able to detect the failure, the error */
/*         SPICE(SYSTEMCALLFAILED) is signalled. */

/* $ Files */

/*     None. */

/* $ Particulars */

/*     Most popular operating systems provide a Fortran-callable */
/*     interface that allows a program to execute an operating system */
/*     command by passing the command, in the form of a string, to the */
/*     operating system's command interpreter. This routine encapulates */
/*     most of the system-dependent code required to execute operating */
/*     system commands in this manner.  The input commands are of course */
/*     system-dependent. */

/*     Side effects of this routine vary from system to system. */
/*     See $Restrictions for more information. */

/*     Error checking capabilities also vary from system to system; this */
/*     routine does the best it can to diagnose errors resulting from */
/*     the attempt to execute the input command. */


/*     Building programs that use this routine */
/*     --------------------------------------- */

/*     ALPHA-OSF1 */

/*        Computer:         ALPHA */
/*        Operating System: OSF1 V3.2 */
/*        Fortran:          DEC FORTRAN V3.5-053 */

/*        No special actions are required for compiling or linking in */
/*        this environment. */

/*     VAX: */

/*        Computer:         VAX 11/780 */
/*        Operating System: VAX VMS 5.3 */
/*        Fortran:          VAX FORTRAN 5.5 */

/*        No special actions are required for compiling or linking in */
/*        this environment. */


/*     SUN */

/*        Computer:         Sun SPARCstation 2 */
/*        Operating System: Sun OS 4.1.2 */
/*        Fortran:          Sun FORTRAN 1.3.1 */

/*        No special actions are required for compiling or linking in */
/*        this environment. */


/*     PC-MS */

/*        Computer:         PC */
/*        Operating System: Microsoft DOS 5.00 */
/*        Fortran:          Microsoft Powerstation Fortran V1.0 */

/*        No special actions are required for compiling or linking in */
/*        this environment. */


/*     HP */

/*        Computer:         HP 715/50 */
/*        Operating System: HP-UX 9.01 */
/*        Fortran:          HP-UX.09.00.24 */
/*                          HP-UX FORTRAN/9000 */
/*                             Series 700 B2408A.09.00 */
/*                             Series 800 B2409B.09.00 */

/*        Compile this routine using the +U77 option. */
/*        Link using the +U77 option. */


/*     NEXT */

/*        Computer:         NeXT */
/*        Operating System: NeXtStep 3.0, 3.2 */
/*        Fortran:          Absoft Fortran V3.2 */
/*        NEXT (NeXT 3.0, Absoft Fortran 3.2): */

/*        Link using -lU77 to include the Unix system library. */


/* $ Examples */

/*     1)  Unix:  copy the file spud.dat to the file spam.dat.  Test */
/*         whether the copy command was executed successfully. */

/*         For safety, we recommend appending a null character to the */
/*         command. */

/*            CALL EXESYS (  'cp spud.dat spam.dat'//CHAR(O)  ) */

/*            IF ( FAILED() ) THEN */

/*               [process error condition] */

/*            END IF */


/*     2)  VMS:  same action as in example (1): */

/*            CALL EXESYS ( 'COPY  SPUD.DAT;  SPAM.DAT;' ) */

/*            IF ( FAILED() ) THEN */

/*               [process error condition] */

/*            END IF */

/* $ Restrictions */

/*     1)  This routine should be used with caution; executing a system */
/*         command from within your program may have surprising side */
/*         effects.  For example, the Sun Fortran Reference Manual [1] */
/*         gives this warning: */

/*               *System* flushes all open files.  For output files, */
/*               the buffer is flushed to the actual file.  For input */
/*               files, the position of the pointer is unpredictable. */

/*     2)  Under Sun Fortran */

/*            -- The shell used to execute the command is determined by */
/*               the environment variable SHELL. */

/*            -- The command string cannot exceed 1024 characters in */
/*               length. */

/* $ Literature_References */

/*     None. */

/* $ Author_and_Institution */

/*     N.J. Bachman   (JPL) */

/* $ Version */

/* -    Beta Version 2.4.0, 26-OCT-2005 (BVS) */

/*        Updated for SUN-SOLARIS-64BIT-GCC_C. */

/* -    Beta Version 2.3.0, 03-JAN-2005 (BVS) */

/*        Updated for PC-CYGWIN_C. */

/* -    Beta Version 2.2.0, 03-JAN-2005 (BVS) */

/*        Updated for PC-CYGWIN. */

/* -    Beta Version 2.1.5, 17-JUL-2002 (BVS) */

/*        Added MAC-OSX environments. */

/* -    Beta Version 2.1.4, 08-OCT-1999 (WLT) */

/*        The environment lines were expanded so that the supported */
/*        environments are now explicitely given.  New */
/*        environments are WIN-NT */

/* -    Beta Version 2.1.3, 22-SEP-1999 (NJB) */

/*        CSPICE and PC-LINUX environment lines were added.  Some */
/*        typos were corrected. */

/* -    Beta Version 2.1.2, 28-JUL-1999 (WLT) */

/*        The environment lines were expanded so that the supported */
/*        environments are now explicitly given.  New */
/*        environments are PC-DIGITAL, SGI-O32 and SGI-N32. */

/* -    Beta Version 2.1.1, 18-MAR-1999 (WLT) */

/*        The environment lines were expanded so that the supported */
/*        environments are now explicitly given.  Previously, */
/*        environments such as SUN-SUNOS and SUN-SOLARIS were implied */
/*        by the environment label SUN. */

/* -    Beta Version 2.1.0, 12-AUG-1996 (WLT) */

/*        Added the DEC-OSF1 environment. */

/* -    Beta Version 2.0.0, 16-JUN-1995 (WLT)(HAN) */

/*        Master version of machine dependent collections. */
/*        Copyright notice added. */

/* -    Beta Version 1.0.0, 16-AUG-1994 (NJB) */

/* -& */
/* $ Index_Entries */

/*     execute an operating system command */

/* -& */

/*     SPICELIB functions */


/*        Computer:         Sun SPARCstation 2 */
/*        Operating System: Sun OS 4.1.2 */
/*        Fortran:          Sun FORTRAN 1.3.1 */

/*        Computer:         ALPHA */
/*        Operating System: OSF1 V3.2 */
/*        Fortran:          DEC FORTRAN V3.5-053 */


/*     System functions */


/*     Local variables */


/*     Standard SPICE error handling. */

    if (return_()) {
	return 0;
    } else {
	chkin_("EXESYS", (ftnlen)6);
    }

/*        Computer:         Sun SPARCstation 2 */
/*        Operating System: Sun OS 4.1.2 */
/*        Fortran:          Sun FORTRAN 1.3.1 */

    status = system_(cmd, rtrim_(cmd, cmd_len));
    if (status != 0) {

/*        Uh, we've got a problem. */

	setmsg_("Sun Fortran routine \"system\" returned code # in response "
		"to command #.", (ftnlen)70);
	errint_("#", &status, (ftnlen)1);
	errch_("#", cmd, (ftnlen)1, cmd_len);
	sigerr_("SPICE(SYSTEMCALLFAILED)", (ftnlen)23);
	chkout_("EXESYS", (ftnlen)6);
	return 0;
    }
    chkout_("EXESYS", (ftnlen)6);
    return 0;
} /* exesys_ */

