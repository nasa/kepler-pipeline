/* t_tstrln.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* $Procedure T_TSTRLN (Test RESLUN) */
/* Subroutine */ int t_tstrln__(integer *lun, logical *resrvd)
{
    /* System generated locals */
    integer i__1, i__2;
    olist o__1;
    cllist cl__1;
    inlist ioin__1;

    /* Builtin functions */
    integer f_inqu(inlist *), s_rnge(char *, integer, char *, integer), 
	    f_open(olist *), f_clos(cllist *);

    /* Local variables */
    logical done;
    integer i__, j;
    extern /* Subroutine */ int chkin_(char *, ftnlen);
    logical opened, lunfnd;
    extern /* Subroutine */ int fndlun_(integer *), sigerr_(char *, ftnlen), 
	    chkout_(char *, ftnlen), setmsg_(char *, ftnlen);
    integer iostat;
    extern /* Subroutine */ int errint_(char *, integer *, ftnlen);
    integer lunary[200];
    extern logical return_(void);

/* $ Abstract */

/*     Test whether LUN has been reserved. */

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

/*     TEST ROUTINE */

/* $ Declarations */
/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  -------------------------------------------------- */
/*     LUN        I   Logical unit in question */
/*     RESRVD     O   Logical indicating if LUN appears to be reserved. */
/*     MAXLUN     P   Maximum number of logical units to buffer. */

/* $ Detailed_Input */

/*     LUN        is a fortran logical unit returned by GETLUN or FNDLUN. */

/* $ Detailed_Output */

/*     RESRVD     is a logical that if set to TRUE indicates that all */
/*                logical units returned by FNDLUN did not contain LUN. */
/*                This is the best we can do.  If FALSE then LUN was */
/*                returned by FNDLUN. */

/* $ Parameters */

/*     MAXLUN     is a parameter whose value must exceed the maximum */
/*                number of distinct logical units that FNDLUN may */
/*                return for any supported platform. */

/* $ Files */

/*     None. */

/* $ Exceptions */

/*     1) SPICE(INQUIREFAILED) is signaled if the INQUIRE on LUN to */
/*        determine if a file is attached fails. */

/*     2) SPICE(LUNINUSE) is signaled if the INQUIRE on LUN indicates */
/*        a file is attached to LUN. */

/*     3) SPICE(FILEOPENFAILED) is signaled if an IOSTAT error */
/*        occurs when trying to attach a unit returned from FNDLUN */
/*        to a file. */

/*     4) If the parameter MAXLUN is not greater than the number */
/*        of distinct logical units that FNDLUN returns on this */
/*        platform, then the error SPICE(PARAMTOOSMALL) is signaled. */

/* $ Particulars */

/*     This routine checks to see if a particular logical unit has been */
/*     reserved with RESLUN. */

/* $ Examples */

/*     See F_DDHRMU for sample usage. */

/* $ Restrictions */

/*     A file may not be attached to LUN when this routine is */
/*     invoked. */

/* $ Author_and_Institution */

/*     F.S. Turner     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    TSPICE Version 1.0.0, 27-JUN-2001 (FST) */


/* -& */

/*     SPICELIB Functions */


/*     Local Parameters */


/*     Local Variables */


/*     Standard SPICE error handling. */

    if (return_()) {
	return 0;
    } else {
	chkin_("T_TSTRLN", (ftnlen)8);
    }

/*     Assume LUN is not reserved until proven otherwise. */

    *resrvd = FALSE_;

/*     INQUIRE on LUN to see if it is attached to a file. */

    ioin__1.inerr = 1;
    ioin__1.inunit = *lun;
    ioin__1.infile = 0;
    ioin__1.inex = 0;
    ioin__1.inopen = &opened;
    ioin__1.innum = 0;
    ioin__1.innamed = 0;
    ioin__1.inname = 0;
    ioin__1.inacc = 0;
    ioin__1.inseq = 0;
    ioin__1.indir = 0;
    ioin__1.infmt = 0;
    ioin__1.inform = 0;
    ioin__1.inunf = 0;
    ioin__1.inrecl = 0;
    ioin__1.innrec = 0;
    ioin__1.inblank = 0;
    iostat = f_inqu(&ioin__1);

/*     Check IOSTAT for troubles. */

    if (iostat != 0) {
	setmsg_("Attempt to perform INQUIRE on logical unit, '#', failed.  I"
		"OSTAT = #.", (ftnlen)69);
	errint_("#", lun, (ftnlen)1);
	errint_("#", &iostat, (ftnlen)1);
	sigerr_("SPICE(INQUIREFAILED)", (ftnlen)20);
	chkout_("T_TSTRLN", (ftnlen)8);
	return 0;
    }

/*     Now check to see if LUN is attached to a file. */

    if (opened) {
	setmsg_("The logical unit, '#', is currently attached to a file.  Th"
		"is routine can only verify the reserved state of units not c"
		"urrently attached to files.", (ftnlen)146);
	errint_("#", lun, (ftnlen)1);
	sigerr_("SPICE(LUNINUSE)", (ftnlen)15);
	chkout_("T_TSTRLN", (ftnlen)8);
	return 0;
    }

/*     This is a total kludge, but it will work.  We are going to */
/*     call FNDLUN until we run out of space for storing units or */
/*     we have exhausted all possible logical units. */

    lunfnd = FALSE_;
    done = FALSE_;
    i__ = 0;
    while(! done) {

/*        Increment I. */

	++i__;

/*        Fetch the next unit from FNDLUN. */

	fndlun_(&lunary[(i__1 = i__ - 1) < 200 && 0 <= i__1 ? i__1 : s_rnge(
		"lunary", i__1, "t_tstrln__", (ftnlen)217)]);

/*        Check to see if the INQUIRE buried in FNDLUN failed. */

	if (lunary[(i__1 = i__ - 1) < 200 && 0 <= i__1 ? i__1 : s_rnge("luna"
		"ry", i__1, "t_tstrln__", (ftnlen)222)] < 0) {
	    setmsg_("INQUIRE failed. IOSTAT = #.", (ftnlen)27);
	    i__2 = -lunary[(i__1 = i__ - 1) < 200 && 0 <= i__1 ? i__1 : 
		    s_rnge("lunary", i__1, "t_tstrln__", (ftnlen)224)];
	    errint_("#", &i__2, (ftnlen)1);
	    sigerr_("SPICE(INQUIREFAILED)", (ftnlen)20);
	    chkout_("T_TSTRLN", (ftnlen)8);
	    return 0;
	}

/*        Now see if LUN is LUNARY(I).  If it is stop, because */
/*        clearly LUN isn't reserved. */

	if (*lun == lunary[(i__1 = i__ - 1) < 200 && 0 <= i__1 ? i__1 : 
		s_rnge("lunary", i__1, "t_tstrln__", (ftnlen)234)]) {
	    done = TRUE_;
	    lunfnd = TRUE_;

/*        Then check to see if LUNARY(I) is 0, indicating that */
/*        FNDLUN was unable to locate a new logical unit, in */
/*        which case, we are finished. */

	} else if (lunary[(i__1 = i__ - 1) < 200 && 0 <= i__1 ? i__1 : s_rnge(
		"lunary", i__1, "t_tstrln__", (ftnlen)244)] == 0) {
	    done = TRUE_;

/*        Otherwise open a scratch file on LUNARY(I) so FNDLUN */
/*        won't return it again. */

	} else {
	    o__1.oerr = 1;
	    o__1.ounit = lunary[(i__1 = i__ - 1) < 200 && 0 <= i__1 ? i__1 : 
		    s_rnge("lunary", i__1, "t_tstrln__", (ftnlen)254)];
	    o__1.ofnm = 0;
	    o__1.orl = 100;
	    o__1.osta = "SCRATCH";
	    o__1.oacc = "DIRECT";
	    o__1.ofm = 0;
	    o__1.oblnk = 0;
	    iostat = f_open(&o__1);

/*           Check IOSTAT. */

	    if (iostat != 0) {
		setmsg_("Attempt to open scratch file failed. IOSTAT = #.", (
			ftnlen)48);
		errint_("#", &iostat, (ftnlen)1);
		sigerr_("SPICE(FILEOPENFAILED)", (ftnlen)21);
		chkout_("T_TSTRLN", (ftnlen)8);
		return 0;
	    }
	}

/*        Now see if entering the loop again will push I past */
/*        MAXLUN.  This should never happen since MAXLUN is */
/*        greater than the number of units for any platform. */

	if (i__ == 200 || lunary[(i__1 = i__ - 1) < 200 && 0 <= i__1 ? i__1 : 
		s_rnge("lunary", i__1, "t_tstrln__", (ftnlen)279)] == 0) {
	    done = TRUE_;
	}
    }

/*     Wrap up our analysis. Clean up the open units. We may need to */
/*     the file attached to the unit in LUNARY(I), but further */
/*     analysis is required. */

    i__1 = i__ - 1;
    for (j = 1; j <= i__1; ++j) {
	cl__1.cerr = 0;
	cl__1.cunit = lunary[(i__2 = j - 1) < 200 && 0 <= i__2 ? i__2 : 
		s_rnge("lunary", i__2, "t_tstrln__", (ftnlen)292)];
	cl__1.csta = 0;
	f_clos(&cl__1);
    }

/*     If we didn't find LUN in the list, then see if we exhausted */
/*     all possible logical units. */

    if (! lunfnd) {

/*        First check to see if we exhausted the available space to */
/*        store units.  If we did, signal an error to warn the */
/*        caller that the test results are inconclusive. */

	if (i__ == 200 && lunary[(i__1 = i__ - 1) < 200 && 0 <= i__1 ? i__1 : 
		s_rnge("lunary", i__1, "t_tstrln__", (ftnlen)306)] > 0) {
	    cl__1.cerr = 0;
	    cl__1.cunit = lunary[(i__1 = i__ - 1) < 200 && 0 <= i__1 ? i__1 : 
		    s_rnge("lunary", i__1, "t_tstrln__", (ftnlen)308)];
	    cl__1.csta = 0;
	    f_clos(&cl__1);
	    setmsg_("FNDLUN returned too many logical units for the test to "
		    "be conclusive.  Increase the parameter MAXLUN and recomp"
		    "ile this module.", (ftnlen)127);
	    sigerr_("SPICE(PARAMTOOSMALL)", (ftnlen)20);
	    chkout_("T_TSTRLN", (ftnlen)8);
	    return 0;
	}

/*        If we make it this far, we did not use all of the available */
/*        space to store units.  Just for safety, check to see that */
/*        LUNARY(I) is 0. */

	if (lunary[(i__1 = i__ - 1) < 200 && 0 <= i__1 ? i__1 : s_rnge("luna"
		"ry", i__1, "t_tstrln__", (ftnlen)324)] != 0) {
	    cl__1.cerr = 0;
	    cl__1.cunit = lunary[(i__1 = i__ - 1) < 200 && 0 <= i__1 ? i__1 : 
		    s_rnge("lunary", i__1, "t_tstrln__", (ftnlen)326)];
	    cl__1.csta = 0;
	    f_clos(&cl__1);

/*           This should never happen, signal SPICE(BUG) and return. */

	    setmsg_("All of the unit storage space was not exhausted, and th"
		    "e last logical unit returned by FNDLUN was not zero.  Th"
		    "is should never happen.", (ftnlen)134);
	    sigerr_("SPICE(BUG)", (ftnlen)10);
	    chkout_("T_TSTRLN", (ftnlen)8);
	    return 0;
	}

/*        All that remains is to set RESRVD to TRUE, since we have */
/*        exhausted all of the units in FNDLUN and LUN did not turn */
/*        up. */

	*resrvd = TRUE_;
    }
    chkout_("T_TSTRLN", (ftnlen)8);
    return 0;
} /* t_tstrln__ */

