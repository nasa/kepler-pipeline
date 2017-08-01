/* t_bgodaf.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_true = TRUE_;
static logical c_false = FALSE_;
static integer c__1 = 1;
static integer c__128 = 128;

/* $Procedure T_BGODAF ( BINGO: Process DAF files to alternate BFFs ) */
/* Subroutine */ int t_bgodaf__(char *iname, char *oname, integer *obff, 
	ftnlen iname_len, ftnlen oname_len)
{
    /* System generated locals */
    integer i__1, i__2, i__3;
    cllist cl__1;

    /* Builtin functions */
    integer s_rdue(cilist *), do_uio(integer *, char *, ftnlen), e_rdue(void),
	     s_wdue(cilist *), e_wdue(void), f_clos(cllist *);

    /* Local variables */
    char crec[1024];
    integer free;
    extern /* Subroutine */ int t_dafopn__(char *, integer *, integer *, 
	    ftnlen), t_dafwdr__(integer *, integer *, integer *, integer *, 
	    doublereal *);
    integer word;
    extern /* Subroutine */ int t_dafwfr__(integer *, integer *, char *, 
	    integer *, integer *, char *, integer *, integer *, integer *, 
	    logical *, ftnlen, ftnlen);
    integer unit;
    extern /* Subroutine */ int t_dafwsr__(integer *, integer *, integer *, 
	    integer *, integer *, integer *, integer *, integer *, doublereal 
	    *), zzdafgdr_(integer *, integer *, doublereal *, logical *), 
	    zzdafgfr_(integer *, char *, integer *, integer *, char *, 
	    integer *, integer *, integer *, logical *, ftnlen, ftnlen), 
	    zzdafgsr_(integer *, integer *, integer *, integer *, doublereal *
	    , logical *), zzddhhlu_(integer *, char *, logical *, integer *, 
	    ftnlen);
    integer i__;
    extern /* Subroutine */ int chkin_(char *, ftnlen);
    doublereal dprec[128];
    integer inhan, bward, fward;
    logical found;
    integer nd;
    extern logical failed_(void);
    integer ni;
    extern /* Subroutine */ int dafcls_(integer *);
    char ifname[60];
    extern /* Subroutine */ int dafarw_(integer *, integer *, integer *), 
	    kilfil_(char *, ftnlen), dafopr_(char *, integer *, ftnlen);
    char idword[8];
    extern /* Subroutine */ int sigerr_(char *, ftnlen), chkout_(char *, 
	    ftnlen);
    integer stprec;
    extern /* Subroutine */ int setmsg_(char *, ftnlen);
    integer iostat, nxtdsc;
    extern /* Subroutine */ int errint_(char *, integer *, ftnlen);
    integer inunit__;
    extern logical return_(void);

    /* Fortran I/O blocks */
    static cilist io___14 = { 1, 0, 1, 0, 0 };
    static cilist io___16 = { 1, 0, 0, 0, 0 };
    static cilist io___21 = { 1, 0, 1, 0, 0 };
    static cilist io___22 = { 1, 0, 0, 0, 0 };


/* $ Abstract */

/*     Convert DAFs from one supported binary file format to another. */

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
/*     INAME      I   Name of source file to convert. */
/*     ONAME      I   Name of output file to create. */
/*     OBFF       I   Integer code for binary file format of ONAME. */

/* $ Detailed_Input */

/*     INAME      is the name of the DAF file to convert to an */
/*                alternate binary file format. */

/*     ONAME      is the name of the converted DAF file to create. The */
/*                file named by ONAME will be destroyed and replaced */
/*                with the converted DAF. */

/*     OBFF       is an integer code that indicates the binary file */
/*                format targeted for ONAME.  Acceptable values */
/*                are the parameters: */

/*                   BIGI3E */
/*                   LTLI3E */
/*                   VAXGFL */
/*                   VAXDFL */

/*                as defined in the include file 'zzddhman.inc'. */

/* $ Detailed_Output */

/*     None. */

/* $ Parameters */

/*     None. */

/* $ Files */

/*     This routine opens the file named by INAME for read access and */
/*     creates the file named by ONAME. */

/* $ Exceptions */

/*     1) SPICE(DAFREADFAILURE) is signaled whenever reading records */
/*        from INAME fails.  In the event such an error occurs, */
/*        ONAME is deleted. */

/*     2) SPICE(DAFWRITEFAILURE) is signaled whenever writing records */
/*        to ONAME fails.  In the event such an error occurs, ONAME */
/*        is deleted. */

/*     3) Routines in the call tree of this routine may signal errors */
/*        as a result of improper inputs or other exceptional cases. */

/* $ Particulars */

/*      This test routine allows existing test software that creates */
/*      DAFs using the high level writers to create native format */
/*      files and convert them to non-native format for testing */
/*      purposes. */

/*      As new binary file formats are added to the list of those */
/*      supported, this routine and routines it calls may require */
/*      updates. */

/* $ Examples */

/*     See some TBD test routine for usage. */

/* $ Restrictions */

/*     1) ONAME must reference a file currently not connected to */
/*        a unit.  Unpredictable behavior may result otherwise. */

/* $ Author_and_Institution */

/*     F.S. Turner     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    SPICELIB Version 1.0.0, 28-NOV-2001 (FST) */


/* -& */

/*     SPICELIB Functions */


/*     Local Variables */


/*     Standard SPICE error handling */

    if (return_()) {
	return 0;
    } else {
	chkin_("T_BGODAF", (ftnlen)8);
    }

/*     Open INAME for read access. */

    dafopr_(iname, &inhan, iname_len);

/*     Create ONAME. */

    t_dafopn__(oname, obff, &unit, oname_len);

/*     Read INAME's file record, we need everything so use the very low */
/*     level reader. */

    zzdafgfr_(&inhan, idword, &nd, &ni, ifname, &fward, &bward, &free, &found,
	     (ftnlen)8, (ftnlen)60);
    if (! found) {
	dafcls_(&inhan);
	kilfil_(oname, oname_len);
	setmsg_("Unable to find file record.", (ftnlen)27);
	sigerr_("SPICE(DAFREADFAILURE)", (ftnlen)21);
	chkout_("T_BGODAF", (ftnlen)8);
	return 0;
    }

/*     Dump the file record into ONAME.  We add the FTP string */
/*     regardless... all new toolkits create files with the FTP */
/*     string. */

    t_dafwfr__(&unit, obff, idword, &nd, &ni, ifname, &fward, &bward, &free, &
	    c_true, (ftnlen)8, (ftnlen)60);

/*     Now just copy all the records between the file record and */
/*     FWARD.  This is valid at the moment for all supported */
/*     platforms, but may need to change in the future. */

    zzddhhlu_(&inhan, "DAF", &c_false, &inunit__, (ftnlen)3);
    i__1 = fward - 1;
    for (i__ = 2; i__ <= i__1; ++i__) {
	io___14.ciunit = inunit__;
	io___14.cirec = i__;
	iostat = s_rdue(&io___14);
	if (iostat != 0) {
	    goto L100001;
	}
	iostat = do_uio(&c__1, crec, (ftnlen)1024);
	if (iostat != 0) {
	    goto L100001;
	}
	iostat = e_rdue();
L100001:
	if (iostat != 0) {
	    dafcls_(&inhan);
	    kilfil_(oname, oname_len);
	    setmsg_("Unable to read comment record, #.", (ftnlen)33);
	    errint_("#", &i__, (ftnlen)1);
	    sigerr_("SPICE(DAFREADFAILURE)", (ftnlen)21);
	    chkout_("T_BGODAF", (ftnlen)8);
	    return 0;
	}
	io___16.ciunit = unit;
	io___16.cirec = i__;
	iostat = s_wdue(&io___16);
	if (iostat != 0) {
	    goto L100002;
	}
	iostat = do_uio(&c__1, crec, (ftnlen)1024);
	if (iostat != 0) {
	    goto L100002;
	}
	iostat = e_wdue();
L100002:
	if (iostat != 0) {
	    dafcls_(&inhan);
	    kilfil_(oname, oname_len);
	    setmsg_("Unable to write comment record, #.", (ftnlen)34);
	    errint_("#", &i__, (ftnlen)1);
	    sigerr_("SPICE(DAFWRITEFAILURE)", (ftnlen)22);
	    chkout_("T_BGODAF", (ftnlen)8);
	    return 0;
	}
    }

/*     Now process the summary, name, and data records.  The record */
/*     FREE points to is the last record to be processed. */

    dafarw_(&free, &stprec, &word);
    i__ = fward;
    nxtdsc = fward;
    while(i__ < stprec) {

/*        See if the record we are currently processing is a */
/*        descriptor record. */

	if (i__ == nxtdsc) {
	    zzdafgsr_(&inhan, &i__, &nd, &ni, dprec, &found);
	    if (! found) {
		dafcls_(&inhan);
		kilfil_(oname, oname_len);
		setmsg_("Unable to read summary record, #.", (ftnlen)33);
		errint_("#", &i__, (ftnlen)1);
		sigerr_("SPICE(DAFREADFAILURE)", (ftnlen)21);
		chkout_("T_BGODAF", (ftnlen)8);
		return 0;
	    }
	    nxtdsc = (integer) dprec[0];
	    i__1 = (integer) dprec[0];
	    i__2 = (integer) dprec[1];
	    i__3 = (integer) dprec[2];
	    t_dafwsr__(&unit, &i__, obff, &nd, &ni, &i__1, &i__2, &i__3, &
		    dprec[3]);

/*           Every summary record is followed by a name record... */

	    ++i__;
	    io___21.ciunit = inunit__;
	    io___21.cirec = i__;
	    iostat = s_rdue(&io___21);
	    if (iostat != 0) {
		goto L100003;
	    }
	    iostat = do_uio(&c__1, crec, (ftnlen)1024);
	    if (iostat != 0) {
		goto L100003;
	    }
	    iostat = e_rdue();
L100003:
	    if (iostat != 0) {
		dafcls_(&inhan);
		kilfil_(oname, oname_len);
		setmsg_("Unable to read name record, #.", (ftnlen)30);
		errint_("#", &i__, (ftnlen)1);
		sigerr_("SPICE(DAFREADFAILURE)", (ftnlen)21);
		chkout_("T_BGODAF", (ftnlen)8);
		return 0;
	    }
	    io___22.ciunit = unit;
	    io___22.cirec = i__;
	    iostat = s_wdue(&io___22);
	    if (iostat != 0) {
		goto L100004;
	    }
	    iostat = do_uio(&c__1, crec, (ftnlen)1024);
	    if (iostat != 0) {
		goto L100004;
	    }
	    iostat = e_wdue();
L100004:
	    if (iostat != 0) {
		dafcls_(&inhan);
		kilfil_(oname, oname_len);
		setmsg_("Unable to write name record, #.", (ftnlen)31);
		errint_("#", &i__, (ftnlen)1);
		sigerr_("SPICE(DAFWRITEFAILURE)", (ftnlen)22);
		chkout_("T_BGODAF", (ftnlen)8);
		return 0;
	    }

/*        Otherwise we are dealing with a data record. */

	} else {
	    zzdafgdr_(&inhan, &i__, dprec, &found);
	    if (! found) {
		dafcls_(&inhan);
		kilfil_(oname, oname_len);
		setmsg_("Unable to read data record, #.", (ftnlen)30);
		errint_("#", &i__, (ftnlen)1);
		sigerr_("SPICE(DAFREADFAILURE)", (ftnlen)21);
		chkout_("T_BGODAF", (ftnlen)8);
		return 0;
	    }
	    t_dafwdr__(&unit, &i__, obff, &c__128, dprec);
	}

/*        Next record. */

	++i__;
    }

/*     Process the last data record, only translate up to (FREE-1)'s */
/*     address. */

    zzdafgdr_(&inhan, &stprec, dprec, &found);

/*     Do not worry if STPREC was not found, it is possible (but */
/*     very unlikely) that FREE points to a record that has yet */
/*     to be created. */

    if (found) {
	i__1 = word - 1;
	t_dafwdr__(&unit, &i__, obff, &i__1, dprec);
    }

/*     Clean up. */

    dafcls_(&inhan);

/*     Check FAILED() in case something has gone awry.  If it has delete */
/*     ONAME. */

    if (failed_()) {
	kilfil_(oname, oname_len);
    } else {
	cl__1.cerr = 0;
	cl__1.cunit = unit;
	cl__1.csta = 0;
	f_clos(&cl__1);
    }
    chkout_("T_BGODAF", (ftnlen)8);
    return 0;
} /* t_bgodaf__ */

