/* f_dascud.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static integer c__3 = 3;
static integer c__1 = 1;
static integer c__256 = 256;
static integer c__2 = 2;
static integer c__255 = 255;
static integer c__896 = 896;
static integer c__768 = 768;
static integer c__384 = 384;
static integer c__127 = 127;
static integer c__448 = 448;
static integer c__192 = 192;
static integer c__1023 = 1023;
static integer c__3584 = 3584;
static integer c__3072 = 3072;
static integer c__1536 = 1536;
static integer c__0 = 0;

/* $Procedure      F_DASCUD ( DASCUD routine tests ) */
/* Subroutine */ int f_dascud__(logical *ok)
{
    /* Initialized data */

    static integer rngmax[3] = { 4,6,8 };
    static integer rngmin[3] = { 3,5,7 };
    static integer sizes[3] = { 1024,128,256 };

    /* System generated locals */
    integer i__1, i__2, i__3, i__4, i__5;

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    integer nadd, free, fsum[14], clrec[256];
    extern /* Subroutine */ int chkfs_(integer *, integer *, logical *);
    integer ncomc;
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    integer recno, ncomr, dtype;
    extern /* Subroutine */ int topen_(char *, ftnlen);
    integer xfsum[14];
    extern /* Subroutine */ int t_success__(logical *), cleari_(integer *, 
	    integer *), chkcds_(integer *, integer *, logical *), chckxc_(
	    logical *, char *, logical *, ftnlen), dascud_(integer *, integer 
	    *, integer *);
    integer dscloc;
    extern /* Subroutine */ int packfs_(integer *, integer *, integer *, 
	    integer *, integer *, integer *, integer *, integer *, integer *),
	     dashfs_(integer *, integer *, integer *, integer *, integer *, 
	    integer *, integer *, integer *, integer *);
    integer scrhan, lastla[3], xclrec[256];
    extern /* Subroutine */ int dasrri_(integer *, integer *, integer *, 
	    integer *, integer *);
    integer lastrc[3];
    extern /* Subroutine */ int dasops_(integer *);
    integer lastwd[3], nresvc, prvclr, nresvr, prvtyp;

/* $ Abstract */

/*     This routine tests the SPICELIB routine */

/*        DASCUD */

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

/* $ Particulars */

/*     This routine tests some of the more complex aspects of the SPICE */
/*     DAS subsystem.  The DAS Required Reading and thorough */
/*     knowledge of the DAS routines are prerequisites for understanding */
/*     this test family. */

/*     This file contains source code for the following utility */
/*     routines: */

/*        PACKFS */
/*        CHKFS */
/*        CHKCDR */


/* $ Version */

/* -    SPICELIB Version 1.0.0, 22-FEB-2003 (NJB) */

/* -& */

/*     Test Utility Functions */


/*     SPICELIB Functions */


/*     Local Parameters */


/*     Words per data record, for each data type: */


/*     DAS type codes: */


/*     Directory pointer locations (backward and forward): */


/*     Directory address range locations */


/*     Location of first type descriptor */


/*     DAS file summary size: */


/*     Local Variables */


/*     Saved variables */


/*     Initial values */


/*     Begin every test family with an open call. */

    topen_("F_DASCUD", (ftnlen)8);

/*     Our approach to testing will be to create a scratch DAS */
/*     file by successive additions, such that the set of states */
/*     of the scratch DAS' file summary and directory contents span the */
/*     range of possibilities handled by DASCUD.  For each data addition */
/*     case, we'll verify that the addition results in the expected */
/*     update of the cluster directory structure and the file summary. */

/*     We don't actually write data to the files in these tests; we */
/*     simply update metadata to indicate where the data would be if */
/*     they were there.  Below, when we say we're "adding data" to */
/*     the file, we're lying to DASCUD.  But as long as the free */
/*     record pointer FREE is updated correctly, the DAS system is */
/*     none the wiser. */

    tcase_("Tell DASCUD we're adding one integer datum.to an empty file.", (
	    ftnlen)60);
    dasops_(&scrhan);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Update the file.  Note that the file update is generally made */
/*     to buffered records; these records might not be written to */
/*     the physical file. */

    dascud_(&scrhan, &c__3, &c__1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Set up the expected file summary.  Note that the first cluster */
/*     record should follow the file record, reserved records, and */
/*     comment records.  The last integer logical address is 1. */
/*     The cluster record containing a descriptor for the last */
/*     integer cluster is the only cluster record.  The first */
/*     data record follows the cluster directory.  The first free */
/*     record follows the data record. */

    nresvr = 0;
    ncomr = 0;
    nresvc = 0;
    ncomc = 0;
    free = nresvr + 1 + ncomr + 3;
    lastla[0] = 0;
    lastla[1] = 0;
    lastla[2] = 1;
    lastrc[0] = 0;
    lastrc[1] = 0;
    lastrc[2] = nresvr + 1 + ncomr + 1;
    lastwd[0] = 0;
    lastwd[1] = 0;
    lastwd[2] = 10;
    packfs_(&nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, lastwd, 
	    xfsum);

/*     Look up the file summary, pack into a summary array, and compare. */

    dashfs_(&scrhan, &nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, 
	    lastwd);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    packfs_(&nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, lastwd, 
	    fsum);
    chkfs_(fsum, xfsum, ok);

/*     Set up the expected first cluster record. */

    cleari_(&c__256, xclrec);
    xclrec[0] = 0;
    xclrec[1] = 0;
    xclrec[2] = 0;
    xclrec[3] = 0;
    xclrec[4] = 0;
    xclrec[5] = 0;
    xclrec[6] = 1;
    xclrec[7] = 1;
    xclrec[8] = 3;
    xclrec[9] = 1;

/*     Read the cluster record and compare. */

    recno = nresvr + 1 + ncomr + 1;
    dasrri_(&scrhan, &recno, &c__1, &c__256, clrec);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chkcds_(clrec, xclrec, ok);
    tcase_("Add one d.p. datum to the file.", (ftnlen)31);

/*     Update the file. */

    dascud_(&scrhan, &c__2, &c__1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Set up the expected file summary. */

    ++free;
    lastla[1] = 1;
    lastrc[1] = nresvr + 1 + ncomr + 1;
    lastwd[1] = 11;
    packfs_(&nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, lastwd, 
	    xfsum);

/*     Look up the file summary, pack into a summary array, and compare. */

    dashfs_(&scrhan, &nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, 
	    lastwd);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    packfs_(&nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, lastwd, 
	    fsum);
    chkfs_(fsum, xfsum, ok);

/*     Set up the expected first cluster record. */

    xclrec[4] = 1;
    xclrec[5] = 1;
    xclrec[10] = -1;

/*     Read the cluster record and compare. */

    recno = nresvr + 1 + ncomr + 1;
    dasrri_(&scrhan, &recno, &c__1, &c__256, clrec);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chkcds_(clrec, xclrec, ok);
    tcase_("Add one character datum to the file.", (ftnlen)36);

/*     Update the file. */

    dascud_(&scrhan, &c__1, &c__1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Set up the expected file summary. */

    ++free;
    lastla[0] = 1;
    lastrc[0] = nresvr + 1 + ncomr + 1;
    lastwd[0] = 12;
    packfs_(&nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, lastwd, 
	    xfsum);

/*     Look up the file summary, pack into a summary array, and compare. */

    dashfs_(&scrhan, &nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, 
	    lastwd);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    packfs_(&nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, lastwd, 
	    fsum);
    chkfs_(fsum, xfsum, ok);

/*     Set up the expected first cluster record. */

    xclrec[2] = 1;
    xclrec[3] = 1;
    xclrec[11] = -1;

/*     Read the cluster record and compare. */

    recno = nresvr + 1 + ncomr + 1;
    dasrri_(&scrhan, &recno, &c__1, &c__256, clrec);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chkcds_(clrec, xclrec, ok);
    tcase_("Add data to fill up the first integer data record.", (ftnlen)50);

/*     Update the file. */

    dascud_(&scrhan, &c__3, &c__255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Set up the expected file summary. */


/*     Note:  FREE is unchanged. */

    lastla[2] = 256;
    packfs_(&nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, lastwd, 
	    xfsum);

/*     Look up the file summary, pack into a summary array, and compare. */

    dashfs_(&scrhan, &nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, 
	    lastwd);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    packfs_(&nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, lastwd, 
	    fsum);
    chkfs_(fsum, xfsum, ok);

/*     Set up the expected first cluster record. */

    xclrec[7] = 256;

/*     Read the cluster record and compare. */

    recno = nresvr + 1 + ncomr + 1;
    dasrri_(&scrhan, &recno, &c__1, &c__256, clrec);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chkcds_(clrec, xclrec, ok);
    tcase_("Add data to fill up 3 1/2 new integer data records.  This create"
	    "s a second integer cluster.", (ftnlen)91);

/*     Update the file. */

    dascud_(&scrhan, &c__3, &c__896);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Set up the expected file summary. */

    free += 4;
    lastla[2] += 896;
    lastwd[2] = 13;
    packfs_(&nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, lastwd, 
	    xfsum);

/*     Look up the file summary, pack into a summary array, and compare. */

    dashfs_(&scrhan, &nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, 
	    lastwd);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    packfs_(&nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, lastwd, 
	    fsum);
    chkfs_(fsum, xfsum, ok);

/*     Set up the expected first cluster record. */

    xclrec[7] += 896;
    xclrec[12] = -4;

/*     Read the cluster record and compare. */

    recno = nresvr + 1 + ncomr + 1;
    dasrri_(&scrhan, &recno, &c__1, &c__256, clrec);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chkcds_(clrec, xclrec, ok);
    tcase_("Add data to fill up 3 new integer data records. This extends the"
	    " second integer cluster.", (ftnlen)88);

/*     Update the file. */

    dascud_(&scrhan, &c__3, &c__768);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Set up the expected file summary. */

    free += 3;
    lastla[2] += 768;
    packfs_(&nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, lastwd, 
	    xfsum);

/*     Look up the file summary, pack into a summary array, and compare. */

    dashfs_(&scrhan, &nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, 
	    lastwd);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    packfs_(&nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, lastwd, 
	    fsum);
    chkfs_(fsum, xfsum, ok);

/*     Set up the expected first cluster record. */

    xclrec[7] += 768;
    xclrec[12] = -7;

/*     Read the cluster record and compare. */

    recno = nresvr + 1 + ncomr + 1;
    dasrri_(&scrhan, &recno, &c__1, &c__256, clrec);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chkcds_(clrec, xclrec, ok);
    tcase_("Add data to fill up 1 1/2 new integer data records. This extends"
	    " the second integer cluster.", (ftnlen)92);

/*     Update the file. */

    dascud_(&scrhan, &c__3, &c__384);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Set up the expected file summary. */


/*     Recall the last integer data record is half full.  We only need */
/*     one new integer data record. */

    ++free;
    lastla[2] += 384;
    packfs_(&nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, lastwd, 
	    xfsum);

/*     Look up the file summary, pack into a summary array, and compare. */

    dashfs_(&scrhan, &nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, 
	    lastwd);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    packfs_(&nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, lastwd, 
	    fsum);
    chkfs_(fsum, xfsum, ok);

/*     Set up the expected first cluster record. */

    xclrec[7] += 384;
    xclrec[12] = -8;

/*     Read the cluster record and compare. */

    recno = nresvr + 1 + ncomr + 1;
    dasrri_(&scrhan, &recno, &c__1, &c__256, clrec);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chkcds_(clrec, xclrec, ok);

/*     We're now going to repeat the integer data additions for */
/*     the double precision and character cases. */

    tcase_("Add data to fill up the first d.p. data record.", (ftnlen)47);

/*     Update the file. */

    dascud_(&scrhan, &c__2, &c__127);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Set up the expected file summary. */


/*     Note:  FREE is unchanged. */

    lastla[1] = 128;
    packfs_(&nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, lastwd, 
	    xfsum);

/*     Look up the file summary, pack into a summary array, and compare. */

    dashfs_(&scrhan, &nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, 
	    lastwd);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    packfs_(&nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, lastwd, 
	    fsum);
    chkfs_(fsum, xfsum, ok);

/*     Set up the expected first cluster record. */

    xclrec[5] = 128;

/*     Read the cluster record and compare. */

    recno = nresvr + 1 + ncomr + 1;
    dasrri_(&scrhan, &recno, &c__1, &c__256, clrec);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chkcds_(clrec, xclrec, ok);
    tcase_("Add data to fill up 3 1/2 new d.p. data records.  This creates a"
	    " second d.p. cluster.", (ftnlen)85);

/*     Update the file. */

    dascud_(&scrhan, &c__2, &c__448);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Set up the expected file summary. */

    free += 4;
    lastla[1] += 448;
    lastwd[1] = 14;
    packfs_(&nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, lastwd, 
	    xfsum);

/*     Look up the file summary, pack into a summary array, and compare. */

    dashfs_(&scrhan, &nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, 
	    lastwd);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    packfs_(&nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, lastwd, 
	    fsum);
    chkfs_(fsum, xfsum, ok);

/*     Set up the expected first cluster record. */

    xclrec[5] += 448;
    xclrec[6] = 1;
    xclrec[13] = -4;

/*     Read the cluster record and compare. */

    recno = nresvr + 1 + ncomr + 1;
    dasrri_(&scrhan, &recno, &c__1, &c__256, clrec);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chkcds_(clrec, xclrec, ok);
    tcase_("Add data to fill up 3 new d.p. data records. This extends the se"
	    "cond d.p. cluster.", (ftnlen)82);

/*     Update the file. */

    dascud_(&scrhan, &c__2, &c__384);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Set up the expected file summary. */

    free += 3;
    lastla[1] += 384;
    packfs_(&nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, lastwd, 
	    xfsum);

/*     Look up the file summary, pack into a summary array, and compare. */

    dashfs_(&scrhan, &nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, 
	    lastwd);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    packfs_(&nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, lastwd, 
	    fsum);
    chkfs_(fsum, xfsum, ok);

/*     Set up the expected first cluster record. */

    xclrec[5] += 384;
    xclrec[13] = -7;

/*     Read the cluster record and compare. */

    recno = nresvr + 1 + ncomr + 1;
    dasrri_(&scrhan, &recno, &c__1, &c__256, clrec);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chkcds_(clrec, xclrec, ok);
    tcase_("Add data to fill up 1 1/2 new d.p. data records. This extends th"
	    "e second d.p. cluster.", (ftnlen)86);

/*     Update the file. */

    dascud_(&scrhan, &c__2, &c__192);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Set up the expected file summary. */


/*     Recall the last d.p. data record is half full.  We only need */
/*     one new d.p. data record. */

    ++free;
    lastla[1] += 192;
    packfs_(&nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, lastwd, 
	    xfsum);

/*     Look up the file summary, pack into a summary array, and compare. */

    dashfs_(&scrhan, &nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, 
	    lastwd);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    packfs_(&nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, lastwd, 
	    fsum);
    chkfs_(fsum, xfsum, ok);

/*     Set up the expected first cluster record. */

    xclrec[5] += 192;
    xclrec[13] = -8;

/*     Read the cluster record and compare. */

    recno = nresvr + 1 + ncomr + 1;
    dasrri_(&scrhan, &recno, &c__1, &c__256, clrec);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chkcds_(clrec, xclrec, ok);
    tcase_("Add data to fill up the first char data record.", (ftnlen)47);

/*     Update the file. */

    dascud_(&scrhan, &c__1, &c__1023);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Set up the expected file summary. */


/*     Note:  FREE is unchanged. */

    lastla[0] = 1024;
    packfs_(&nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, lastwd, 
	    xfsum);

/*     Look up the file summary, pack into a summary array, and compare. */

    dashfs_(&scrhan, &nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, 
	    lastwd);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    packfs_(&nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, lastwd, 
	    fsum);
    chkfs_(fsum, xfsum, ok);

/*     Set up the expected first cluster record. */

    xclrec[3] = 1024;

/*     Read the cluster record and compare. */

    recno = nresvr + 1 + ncomr + 1;
    dasrri_(&scrhan, &recno, &c__1, &c__256, clrec);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chkcds_(clrec, xclrec, ok);
    tcase_("Add data to fill up 3 1/2 new char data records.  This creates a"
	    " second char cluster.", (ftnlen)85);

/*     Update the file. */

    dascud_(&scrhan, &c__1, &c__3584);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Set up the expected file summary. */

    free += 4;
    lastla[0] += 3584;
    lastwd[0] = 15;
    packfs_(&nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, lastwd, 
	    xfsum);

/*     Look up the file summary, pack into a summary array, and compare. */

    dashfs_(&scrhan, &nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, 
	    lastwd);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    packfs_(&nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, lastwd, 
	    fsum);
    chkfs_(fsum, xfsum, ok);

/*     Set up the expected first cluster record. */

    xclrec[3] += 3584;
    xclrec[14] = -4;

/*     Read the cluster record and compare. */

    recno = nresvr + 1 + ncomr + 1;
    dasrri_(&scrhan, &recno, &c__1, &c__256, clrec);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chkcds_(clrec, xclrec, ok);
    tcase_("Add data to fill up 3 new char data records. This extends the se"
	    "cond char cluster.", (ftnlen)82);

/*     Update the file. */

    dascud_(&scrhan, &c__1, &c__3072);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Set up the expected file summary. */

    free += 3;
    lastla[0] += 3072;
    packfs_(&nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, lastwd, 
	    xfsum);

/*     Look up the file summary, pack into a summary array, and compare. */

    dashfs_(&scrhan, &nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, 
	    lastwd);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    packfs_(&nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, lastwd, 
	    fsum);
    chkfs_(fsum, xfsum, ok);

/*     Set up the expected first cluster record. */

    xclrec[3] += 3072;
    xclrec[14] = -7;

/*     Read the cluster record and compare. */

    recno = nresvr + 1 + ncomr + 1;
    dasrri_(&scrhan, &recno, &c__1, &c__256, clrec);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chkcds_(clrec, xclrec, ok);
    tcase_("Add data to fill up 1 1/2 new char data records. This extends th"
	    "e second char cluster.", (ftnlen)86);

/*     Update the file. */

    dascud_(&scrhan, &c__1, &c__1536);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Set up the expected file summary. */


/*     Recall the last char data record is half full.  We only need */
/*     one new char data record. */

    ++free;
    lastla[0] += 1536;
    packfs_(&nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, lastwd, 
	    xfsum);

/*     Look up the file summary, pack into a summary array, and compare. */

    dashfs_(&scrhan, &nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, 
	    lastwd);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    packfs_(&nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, lastwd, 
	    fsum);
    chkfs_(fsum, xfsum, ok);

/*     Set up the expected first cluster record. */

    xclrec[3] += 1536;
    xclrec[14] = -8;

/*     Read the cluster record and compare. */

    recno = nresvr + 1 + ncomr + 1;
    dasrri_(&scrhan, &recno, &c__1, &c__256, clrec);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chkcds_(clrec, xclrec, ok);
    tcase_("Now add data, cycling types as we go, so as to fill in the first"
	    " cluster directory.  We'll add one record of d.p. data, then one"
	    " of int data, and so on.", (ftnlen)152);

/*     Update the file. */

    dscloc = 16;
    prvtyp = 1;
    while(dscloc <= 256) {

/*        Find the successor of PRVTYP using the cycling ordering */

/*           1 -> 2 -> 3 -> 1 */

	dtype = prvtyp % 3 + 1;
	dascud_(&scrhan, &dtype, &sizes[(i__1 = dtype - 1) < 3 && 0 <= i__1 ? 
		i__1 : s_rnge("sizes", i__1, "f_dascud__", (ftnlen)1065)]);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Set up the expected file summary. */

/*        Recall the last DTYPE data record is full.  We need one new, */
/*        non-contiguous data record of this type. */

	++free;
	lastla[(i__1 = dtype - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge("lastla", 
		i__1, "f_dascud__", (ftnlen)1075)] = lastla[(i__2 = dtype - 1)
		 < 3 && 0 <= i__2 ? i__2 : s_rnge("lastla", i__2, "f_dascud__"
		, (ftnlen)1075)] + sizes[(i__3 = dtype - 1) < 3 && 0 <= i__3 ?
		 i__3 : s_rnge("sizes", i__3, "f_dascud__", (ftnlen)1075)];
	lastwd[(i__1 = dtype - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge("lastwd", 
		i__1, "f_dascud__", (ftnlen)1076)] = lastwd[(i__2 = prvtyp - 
		1) < 3 && 0 <= i__2 ? i__2 : s_rnge("lastwd", i__2, "f_dascu"
		"d__", (ftnlen)1076)] + 1;

/*        Set up the expected first cluster record. */

	xclrec[(i__2 = rngmax[(i__1 = dtype - 1) < 3 && 0 <= i__1 ? i__1 : 
		s_rnge("rngmax", i__1, "f_dascud__", (ftnlen)1082)] - 1) < 
		256 && 0 <= i__2 ? i__2 : s_rnge("xclrec", i__2, "f_dascud__",
		 (ftnlen)1082)] = xclrec[(i__4 = rngmax[(i__3 = dtype - 1) < 
		3 && 0 <= i__3 ? i__3 : s_rnge("rngmax", i__3, "f_dascud__", (
		ftnlen)1082)] - 1) < 256 && 0 <= i__4 ? i__4 : s_rnge("xclrec"
		, i__4, "f_dascud__", (ftnlen)1082)] + sizes[(i__5 = dtype - 
		1) < 3 && 0 <= i__5 ? i__5 : s_rnge("sizes", i__5, "f_dascud"
		"__", (ftnlen)1082)];
	xclrec[(i__1 = dscloc - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("xclrec"
		, i__1, "f_dascud__", (ftnlen)1084)] = 1;
	prvtyp = dtype;
	++dscloc;
	if (dscloc % 10 == 0) {

/*           Read the cluster record and compare. */

	    dasrri_(&scrhan, &recno, &c__1, &c__256, clrec);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    chkcds_(clrec, xclrec, ok);
	}
    }

/*     We will have allocated a new, empty record for the next cluster */
/*     directory, so increment FREE. */

    ++free;

/*     Now check the file summary. */

    packfs_(&nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, lastwd, 
	    xfsum);

/*     Look up the file summary, pack into a summary array, and */
/*     compare. */

    dashfs_(&scrhan, &nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, 
	    lastwd);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    packfs_(&nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, lastwd, 
	    fsum);
    chkfs_(fsum, xfsum, ok);

/*     The forward pointer of the cluster directory record will point to */
/*     the newly allocated cluster directory record. */

    xclrec[1] = free - 1;

/*     Read the cluster record and compare. */

    recno = nresvr + 1 + ncomr + 1;
    dasrri_(&scrhan, &recno, &c__1, &c__256, clrec);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chkcds_(clrec, xclrec, ok);
    prvclr = recno;
    tcase_("Add another set of data that fills in an entire cluster director"
	    "y.  This time we'll alternate between integer and d.p. data.  We"
	    "'ll leave the last (INT) cluster half full.", (ftnlen)171);
    recno = free - 1;
    dscloc = 10;
    prvtyp = 2;

/*     Check the empty cluster directory. */

    cleari_(&c__256, xclrec);
    xclrec[0] = prvclr;
    xclrec[1] = 0;

/*     Read the cluster record and compare. */

    dasrri_(&scrhan, &recno, &c__1, &c__256, clrec);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chkcds_(clrec, xclrec, ok);

/*     Initialize the the rest of the expected cluster directory. */

    xclrec[(i__1 = rngmin[0] - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("xclrec",
	     i__1, "f_dascud__", (ftnlen)1176)] = 0;
    xclrec[(i__1 = rngmin[1] - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("xclrec",
	     i__1, "f_dascud__", (ftnlen)1177)] = 0;
    xclrec[(i__1 = rngmin[2] - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("xclrec",
	     i__1, "f_dascud__", (ftnlen)1178)] = 0;
    xclrec[(i__1 = rngmax[0] - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("xclrec",
	     i__1, "f_dascud__", (ftnlen)1180)] = 0;
    xclrec[(i__1 = rngmax[1] - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("xclrec",
	     i__1, "f_dascud__", (ftnlen)1181)] = 0;
    xclrec[(i__1 = rngmax[2] - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("xclrec",
	     i__1, "f_dascud__", (ftnlen)1182)] = 0;
    xclrec[8] = 3;
    while(dscloc <= 256) {

/*        Find the successor of PRVTYP using the cycling ordering */

/*           1 -> 2 -> 3 -> 1 */

	dtype = prvtyp % 3 + 1;

/*        Skip over the character type. */

	if (dtype == 1) {
	    dtype = dtype % 3 + 1;
	}
	if (dscloc < 256) {
	    nadd = sizes[(i__1 = dtype - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge(
		    "sizes", i__1, "f_dascud__", (ftnlen)1205)];
	} else {
	    nadd = sizes[(i__1 = dtype - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge(
		    "sizes", i__1, "f_dascud__", (ftnlen)1207)] / 2;
	}
	dascud_(&scrhan, &dtype, &nadd);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Set up the expected file summary. */

/*        Recall the last DTYPE data record is full.  We need one new, */
/*        non-contiguous data record of this type. */

	if (dscloc < 256) {
	    ++free;
	} else {

/*           When we fill in the last cluster directory entry, we'll */
/*           allocate another empty directory. */

	    free += 2;
	    prvclr = free - 1;
	}
	lastla[(i__1 = dtype - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge("lastla", 
		i__1, "f_dascud__", (ftnlen)1234)] = lastla[(i__2 = dtype - 1)
		 < 3 && 0 <= i__2 ? i__2 : s_rnge("lastla", i__2, "f_dascud__"
		, (ftnlen)1234)] + nadd;
	lastrc[(i__1 = dtype - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge("lastrc", 
		i__1, "f_dascud__", (ftnlen)1235)] = recno;
	lastwd[(i__1 = dtype - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge("lastwd", 
		i__1, "f_dascud__", (ftnlen)1236)] = dscloc;

/*        Now check the file summary. */

	packfs_(&nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, 
		lastwd, xfsum);

/*        Look up the file summary, pack into a summary array, and */
/*        compare. */

	dashfs_(&scrhan, &nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, 
		lastrc, lastwd);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	packfs_(&nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, 
		lastwd, fsum);
	chkfs_(fsum, xfsum, ok);

/*        Set up the expected  cluster record. */

	if (xclrec[(i__2 = rngmax[(i__1 = dtype - 1) < 3 && 0 <= i__1 ? i__1 :
		 s_rnge("rngmax", i__1, "f_dascud__", (ftnlen)1262)] - 1) < 
		256 && 0 <= i__2 ? i__2 : s_rnge("xclrec", i__2, "f_dascud__",
		 (ftnlen)1262)] == 0) {

/*           The range for this data type is initially set at 0:0. */
/*           We've already updated LASTLA(DTYPE). */

	    xclrec[(i__2 = rngmax[(i__1 = dtype - 1) < 3 && 0 <= i__1 ? i__1 :
		     s_rnge("rngmax", i__1, "f_dascud__", (ftnlen)1267)] - 1) 
		    < 256 && 0 <= i__2 ? i__2 : s_rnge("xclrec", i__2, "f_da"
		    "scud__", (ftnlen)1267)] = lastla[(i__3 = dtype - 1) < 3 &&
		     0 <= i__3 ? i__3 : s_rnge("lastla", i__3, "f_dascud__", (
		    ftnlen)1267)];
	    xclrec[(i__2 = rngmin[(i__1 = dtype - 1) < 3 && 0 <= i__1 ? i__1 :
		     s_rnge("rngmin", i__1, "f_dascud__", (ftnlen)1269)] - 1) 
		    < 256 && 0 <= i__2 ? i__2 : s_rnge("xclrec", i__2, "f_da"
		    "scud__", (ftnlen)1269)] = lastla[(i__3 = dtype - 1) < 3 &&
		     0 <= i__3 ? i__3 : s_rnge("lastla", i__3, "f_dascud__", (
		    ftnlen)1269)] - nadd + 1;
	} else {
	    xclrec[(i__2 = rngmax[(i__1 = dtype - 1) < 3 && 0 <= i__1 ? i__1 :
		     s_rnge("rngmax", i__1, "f_dascud__", (ftnlen)1272)] - 1) 
		    < 256 && 0 <= i__2 ? i__2 : s_rnge("xclrec", i__2, "f_da"
		    "scud__", (ftnlen)1272)] = xclrec[(i__4 = rngmax[(i__3 = 
		    dtype - 1) < 3 && 0 <= i__3 ? i__3 : s_rnge("rngmax", 
		    i__3, "f_dascud__", (ftnlen)1272)] - 1) < 256 && 0 <= 
		    i__4 ? i__4 : s_rnge("xclrec", i__4, "f_dascud__", (
		    ftnlen)1272)] + nadd;
	}
	if (dtype == xclrec[8]) {
	    xclrec[(i__1 = dscloc - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge(
		    "xclrec", i__1, "f_dascud__", (ftnlen)1276)] = 1;
	} else {
	    xclrec[(i__1 = dscloc - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge(
		    "xclrec", i__1, "f_dascud__", (ftnlen)1278)] = -1;
	}
	prvtyp = dtype;
	++dscloc;
	if (dscloc % 10 == 0) {

/*           Read the cluster record and compare. */

	    dasrri_(&scrhan, &recno, &c__1, &c__256, clrec);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    chkcds_(clrec, xclrec, ok);
	}
    }

/*     Now check the file summary. */

    packfs_(&nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, lastwd, 
	    xfsum);

/*     Look up the file summary, pack into a summary array, and */
/*     compare. */

    dashfs_(&scrhan, &nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, 
	    lastwd);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    packfs_(&nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, lastwd, 
	    fsum);
    chkfs_(fsum, xfsum, ok);

/*     The forward pointer of the cluster directory record will point to */
/*     the newly allocated cluster directory record. */

    xclrec[1] = free - 1;
/*     Read the cluster record and compare. */

    dasrri_(&scrhan, &recno, &c__1, &c__256, clrec);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chkcds_(clrec, xclrec, ok);
    prvclr = recno;
    tcase_("Add another set of data that fills in an entire cluster director"
	    "y.  This time we'll alternate between integer and character data"
	    ".  We'll leave the last (CHAR) cluster half full.", (ftnlen)177);
    recno = free - 1;
    dscloc = 10;
    prvtyp = 3;

/*     Check the empty cluster directory. */

    cleari_(&c__256, xclrec);
    xclrec[0] = prvclr;
    xclrec[1] = 0;

/*     Read the cluster record and compare. */

    dasrri_(&scrhan, &recno, &c__1, &c__256, clrec);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chkcds_(clrec, xclrec, ok);

/*     Initialize the expected cluster directory. */

    cleari_(&c__256, xclrec);
    xclrec[0] = prvclr;
    xclrec[1] = 0;
    xclrec[(i__1 = rngmin[0] - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("xclrec",
	     i__1, "f_dascud__", (ftnlen)1371)] = 0;
    xclrec[(i__1 = rngmin[1] - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("xclrec",
	     i__1, "f_dascud__", (ftnlen)1372)] = 0;
    xclrec[(i__1 = rngmin[2] - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("xclrec",
	     i__1, "f_dascud__", (ftnlen)1373)] = 0;
    xclrec[(i__1 = rngmax[0] - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("xclrec",
	     i__1, "f_dascud__", (ftnlen)1375)] = 0;
    xclrec[(i__1 = rngmax[1] - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("xclrec",
	     i__1, "f_dascud__", (ftnlen)1376)] = 0;
    xclrec[(i__1 = rngmax[2] - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("xclrec",
	     i__1, "f_dascud__", (ftnlen)1377)] = 0;
    xclrec[8] = 1;
    while(dscloc <= 256) {

/*        Find the successor of PRVTYP using the cycling ordering */

/*           1 -> 2 -> 3 -> 1 */

	dtype = prvtyp % 3 + 1;

/*        Skip over the d.p. type. */

	if (dtype == 2) {
	    dtype = dtype % 3 + 1;
	}
	if (dscloc < 256) {
	    nadd = sizes[(i__1 = dtype - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge(
		    "sizes", i__1, "f_dascud__", (ftnlen)1400)];
	} else {
	    nadd = sizes[(i__1 = dtype - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge(
		    "sizes", i__1, "f_dascud__", (ftnlen)1402)] / 2;
	}
	dascud_(&scrhan, &dtype, &nadd);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Set up the expected file summary. */

/*        Recall the last DTYPE data record is full.  We need one new, */
/*        non-contiguous data record of this type. */

	if (dscloc < 256) {
	    ++free;
	} else {

/*           When we fill in the last cluster directory entry, we'll */
/*           allocate another empty directory. */

	    free += 2;
	    prvclr = free - 1;
	}
	lastla[(i__1 = dtype - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge("lastla", 
		i__1, "f_dascud__", (ftnlen)1429)] = lastla[(i__2 = dtype - 1)
		 < 3 && 0 <= i__2 ? i__2 : s_rnge("lastla", i__2, "f_dascud__"
		, (ftnlen)1429)] + nadd;
	lastrc[(i__1 = dtype - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge("lastrc", 
		i__1, "f_dascud__", (ftnlen)1430)] = recno;
	lastwd[(i__1 = dtype - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge("lastwd", 
		i__1, "f_dascud__", (ftnlen)1431)] = dscloc;

/*        Now check the file summary. */

	packfs_(&nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, 
		lastwd, xfsum);

/*        Look up the file summary, pack into a summary array, and */
/*        compare. */

	dashfs_(&scrhan, &nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, 
		lastrc, lastwd);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	packfs_(&nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, 
		lastwd, fsum);
	chkfs_(fsum, xfsum, ok);

/*        Set up the expected  cluster record. */

	if (xclrec[(i__2 = rngmax[(i__1 = dtype - 1) < 3 && 0 <= i__1 ? i__1 :
		 s_rnge("rngmax", i__1, "f_dascud__", (ftnlen)1457)] - 1) < 
		256 && 0 <= i__2 ? i__2 : s_rnge("xclrec", i__2, "f_dascud__",
		 (ftnlen)1457)] == 0) {

/*           The range for this data type is initially set at 0:0. */
/*           We've already updated LASTLA(DTYPE). */

	    xclrec[(i__2 = rngmax[(i__1 = dtype - 1) < 3 && 0 <= i__1 ? i__1 :
		     s_rnge("rngmax", i__1, "f_dascud__", (ftnlen)1462)] - 1) 
		    < 256 && 0 <= i__2 ? i__2 : s_rnge("xclrec", i__2, "f_da"
		    "scud__", (ftnlen)1462)] = lastla[(i__3 = dtype - 1) < 3 &&
		     0 <= i__3 ? i__3 : s_rnge("lastla", i__3, "f_dascud__", (
		    ftnlen)1462)];
	    if (dtype == 1) {
		xclrec[(i__2 = rngmin[(i__1 = dtype - 1) < 3 && 0 <= i__1 ? 
			i__1 : s_rnge("rngmin", i__1, "f_dascud__", (ftnlen)
			1465)] - 1) < 256 && 0 <= i__2 ? i__2 : s_rnge("xclr"
			"ec", i__2, "f_dascud__", (ftnlen)1465)] = lastla[(
			i__3 = dtype - 1) < 3 && 0 <= i__3 ? i__3 : s_rnge(
			"lastla", i__3, "f_dascud__", (ftnlen)1465)] - nadd + 
			1;
	    } else {

/*              In the integer case, we'll start by filling in the */
/*              last half of that empty data record which is in the */
/*              last integer cluster belonging to the previous cluster */
/*              directory.  So the minimum integer logical address */
/*              belonging to this cluster directory will be NWI/2 */
/*              larger than it would be if the previous integer */
/*              record were full. */

		xclrec[(i__2 = rngmin[(i__1 = dtype - 1) < 3 && 0 <= i__1 ? 
			i__1 : s_rnge("rngmin", i__1, "f_dascud__", (ftnlen)
			1476)] - 1) < 256 && 0 <= i__2 ? i__2 : s_rnge("xclr"
			"ec", i__2, "f_dascud__", (ftnlen)1476)] = lastla[(
			i__3 = dtype - 1) < 3 && 0 <= i__3 ? i__3 : s_rnge(
			"lastla", i__3, "f_dascud__", (ftnlen)1476)] - nadd + 
			129;
	    }
	} else {
	    xclrec[(i__2 = rngmax[(i__1 = dtype - 1) < 3 && 0 <= i__1 ? i__1 :
		     s_rnge("rngmax", i__1, "f_dascud__", (ftnlen)1481)] - 1) 
		    < 256 && 0 <= i__2 ? i__2 : s_rnge("xclrec", i__2, "f_da"
		    "scud__", (ftnlen)1481)] = xclrec[(i__4 = rngmax[(i__3 = 
		    dtype - 1) < 3 && 0 <= i__3 ? i__3 : s_rnge("rngmax", 
		    i__3, "f_dascud__", (ftnlen)1481)] - 1) < 256 && 0 <= 
		    i__4 ? i__4 : s_rnge("xclrec", i__4, "f_dascud__", (
		    ftnlen)1481)] + nadd;
	}
	if (dtype == xclrec[8]) {
	    xclrec[(i__1 = dscloc - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge(
		    "xclrec", i__1, "f_dascud__", (ftnlen)1485)] = 1;
	} else {
	    xclrec[(i__1 = dscloc - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge(
		    "xclrec", i__1, "f_dascud__", (ftnlen)1487)] = -1;
	}
	prvtyp = dtype;
	++dscloc;
	if (dscloc % 10 == 0) {

/*           Read the cluster record and compare. */

	    dasrri_(&scrhan, &recno, &c__1, &c__256, clrec);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    chkcds_(clrec, xclrec, ok);
	}
    }

/*     Now check the file summary. */

    packfs_(&nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, lastwd, 
	    xfsum);

/*     Look up the file summary, pack into a summary array, and */
/*     compare. */

    dashfs_(&scrhan, &nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, 
	    lastwd);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    packfs_(&nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, lastwd, 
	    fsum);
    chkfs_(fsum, xfsum, ok);

/*     The forward pointer of the cluster directory record will point to */
/*     the newly allocated cluster directory record. */

    xclrec[1] = prvclr;
/*     Read the cluster record and compare. */

    dasrri_(&scrhan, &recno, &c__1, &c__256, clrec);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chkcds_(clrec, xclrec, ok);
    prvclr = recno;
    tcase_("Add another set of data that fills in an entire cluster director"
	    "y.  This time we'll alternate between d.p. and character data.  "
	    "We'll leave the last(DP) cluster half full.", (ftnlen)171);
    recno = free - 1;
    dscloc = 10;
    prvtyp = 1;

/*     Check the empty cluster directory. */

    cleari_(&c__256, xclrec);
    xclrec[0] = prvclr;
    xclrec[1] = 0;

/*     Read the cluster record and compare. */

    dasrri_(&scrhan, &recno, &c__1, &c__256, clrec);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chkcds_(clrec, xclrec, ok);

/*     Initialize the expected cluster directory. */

    cleari_(&c__256, xclrec);
    xclrec[0] = prvclr;
    xclrec[1] = 0;
    xclrec[(i__1 = rngmin[0] - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("xclrec",
	     i__1, "f_dascud__", (ftnlen)1580)] = 0;
    xclrec[(i__1 = rngmin[1] - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("xclrec",
	     i__1, "f_dascud__", (ftnlen)1581)] = 0;
    xclrec[(i__1 = rngmin[2] - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("xclrec",
	     i__1, "f_dascud__", (ftnlen)1582)] = 0;
    xclrec[(i__1 = rngmax[0] - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("xclrec",
	     i__1, "f_dascud__", (ftnlen)1584)] = 0;
    xclrec[(i__1 = rngmax[1] - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("xclrec",
	     i__1, "f_dascud__", (ftnlen)1585)] = 0;
    xclrec[(i__1 = rngmax[2] - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("xclrec",
	     i__1, "f_dascud__", (ftnlen)1586)] = 0;
    xclrec[8] = 2;
    while(dscloc <= 256) {

/*        Find the successor of PRVTYP using the cycling ordering */

/*           1 -> 2 -> 3 -> 1 */

	dtype = prvtyp % 3 + 1;

/*        Skip over the integer type. */

	if (dtype == 3) {
	    dtype = dtype % 3 + 1;
	}
	if (dscloc < 256) {
	    nadd = sizes[(i__1 = dtype - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge(
		    "sizes", i__1, "f_dascud__", (ftnlen)1609)];
	} else {
	    nadd = sizes[(i__1 = dtype - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge(
		    "sizes", i__1, "f_dascud__", (ftnlen)1611)] / 2;
	}
	dascud_(&scrhan, &dtype, &nadd);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Set up the expected file summary. */

/*        Recall the last DTYPE data record is full.  We need one new, */
/*        non-contiguous data record of this type. */

	if (dscloc < 256) {
	    ++free;
	} else {

/*           When we fill in the last cluster directory entry, we'll */
/*           allocate another empty directory. */

	    free += 2;
	    prvclr = free - 1;
	}
	lastla[(i__1 = dtype - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge("lastla", 
		i__1, "f_dascud__", (ftnlen)1638)] = lastla[(i__2 = dtype - 1)
		 < 3 && 0 <= i__2 ? i__2 : s_rnge("lastla", i__2, "f_dascud__"
		, (ftnlen)1638)] + nadd;
	lastrc[(i__1 = dtype - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge("lastrc", 
		i__1, "f_dascud__", (ftnlen)1639)] = recno;
	lastwd[(i__1 = dtype - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge("lastwd", 
		i__1, "f_dascud__", (ftnlen)1640)] = dscloc;

/*        Now check the file summary. */

	packfs_(&nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, 
		lastwd, xfsum);

/*        Look up the file summary, pack into a summary array, and */
/*        compare. */

	dashfs_(&scrhan, &nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, 
		lastrc, lastwd);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	packfs_(&nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, 
		lastwd, fsum);
	chkfs_(fsum, xfsum, ok);

/*        Set up the expected  cluster record. */

	if (xclrec[(i__2 = rngmax[(i__1 = dtype - 1) < 3 && 0 <= i__1 ? i__1 :
		 s_rnge("rngmax", i__1, "f_dascud__", (ftnlen)1666)] - 1) < 
		256 && 0 <= i__2 ? i__2 : s_rnge("xclrec", i__2, "f_dascud__",
		 (ftnlen)1666)] == 0) {

/*           The range for this data type is initially set at 0:0. */
/*           We've already updated LASTLA(DTYPE). */

	    xclrec[(i__2 = rngmax[(i__1 = dtype - 1) < 3 && 0 <= i__1 ? i__1 :
		     s_rnge("rngmax", i__1, "f_dascud__", (ftnlen)1671)] - 1) 
		    < 256 && 0 <= i__2 ? i__2 : s_rnge("xclrec", i__2, "f_da"
		    "scud__", (ftnlen)1671)] = lastla[(i__3 = dtype - 1) < 3 &&
		     0 <= i__3 ? i__3 : s_rnge("lastla", i__3, "f_dascud__", (
		    ftnlen)1671)];
	    if (dtype == 2) {
		xclrec[(i__2 = rngmin[(i__1 = dtype - 1) < 3 && 0 <= i__1 ? 
			i__1 : s_rnge("rngmin", i__1, "f_dascud__", (ftnlen)
			1674)] - 1) < 256 && 0 <= i__2 ? i__2 : s_rnge("xclr"
			"ec", i__2, "f_dascud__", (ftnlen)1674)] = lastla[(
			i__3 = dtype - 1) < 3 && 0 <= i__3 ? i__3 : s_rnge(
			"lastla", i__3, "f_dascud__", (ftnlen)1674)] - nadd + 
			1;
	    } else {

/*              In the character case, we'll start by filling in the */
/*              last half of that empty data record which is in the */
/*              last character cluster belonging to the previous cluster */
/*              directory.  So the minimum character logical address */
/*              belonging to this cluster directory will be NWC/2 */
/*              larger than it would be if the previous character */
/*              record were full. */

		xclrec[(i__2 = rngmin[(i__1 = dtype - 1) < 3 && 0 <= i__1 ? 
			i__1 : s_rnge("rngmin", i__1, "f_dascud__", (ftnlen)
			1685)] - 1) < 256 && 0 <= i__2 ? i__2 : s_rnge("xclr"
			"ec", i__2, "f_dascud__", (ftnlen)1685)] = lastla[(
			i__3 = dtype - 1) < 3 && 0 <= i__3 ? i__3 : s_rnge(
			"lastla", i__3, "f_dascud__", (ftnlen)1685)] - nadd + 
			513;
	    }
	} else {
	    xclrec[(i__2 = rngmax[(i__1 = dtype - 1) < 3 && 0 <= i__1 ? i__1 :
		     s_rnge("rngmax", i__1, "f_dascud__", (ftnlen)1690)] - 1) 
		    < 256 && 0 <= i__2 ? i__2 : s_rnge("xclrec", i__2, "f_da"
		    "scud__", (ftnlen)1690)] = xclrec[(i__4 = rngmax[(i__3 = 
		    dtype - 1) < 3 && 0 <= i__3 ? i__3 : s_rnge("rngmax", 
		    i__3, "f_dascud__", (ftnlen)1690)] - 1) < 256 && 0 <= 
		    i__4 ? i__4 : s_rnge("xclrec", i__4, "f_dascud__", (
		    ftnlen)1690)] + nadd;
	}
	if (dtype == xclrec[8]) {
	    xclrec[(i__1 = dscloc - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge(
		    "xclrec", i__1, "f_dascud__", (ftnlen)1694)] = 1;
	} else {
	    xclrec[(i__1 = dscloc - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge(
		    "xclrec", i__1, "f_dascud__", (ftnlen)1696)] = -1;
	}
	prvtyp = dtype;
	++dscloc;
	if (dscloc % 10 == 0) {

/*           Read the cluster record and compare. */

	    dasrri_(&scrhan, &recno, &c__1, &c__256, clrec);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    chkcds_(clrec, xclrec, ok);
	}
    }

/*     Now check the file summary. */

    packfs_(&nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, lastwd, 
	    xfsum);

/*     Look up the file summary, pack into a summary array, and */
/*     compare. */

    dashfs_(&scrhan, &nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, 
	    lastwd);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    packfs_(&nresvr, &nresvc, &ncomr, &ncomc, &free, lastla, lastrc, lastwd, 
	    fsum);
    chkfs_(fsum, xfsum, ok);

/*     The forward pointer of the cluster directory record will point to */
/*     the newly allocated cluster directory record. */

    xclrec[1] = prvclr;
/*     Read the cluster record and compare. */

    dasrri_(&scrhan, &recno, &c__1, &c__256, clrec);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chkcds_(clrec, xclrec, ok);
    prvclr = recno;
    t_success__(ok);
    return 0;
} /* f_dascud__ */


/*     PACKFS is a utility subroutine which packs DAS file summary */
/*     information into an integer array. */

/* Subroutine */ int packfs_(integer *nresvr, integer *nresvc, integer *ncomr,
	 integer *ncomc, integer *free, integer *lastla, integer *lastrc, 
	integer *lastwd, integer *fsum)
{
    extern /* Subroutine */ int movei_(integer *, integer *, integer *);

    fsum[0] = *nresvr;
    fsum[1] = *nresvc;
    fsum[2] = *ncomr;
    fsum[3] = *ncomc;
    fsum[4] = *free;
    movei_(lastla, &c__3, &fsum[5]);
    movei_(lastrc, &c__3, &fsum[8]);
    movei_(lastwd, &c__3, &fsum[11]);
    return 0;
} /* packfs_ */


/*     CHKFS is a utility subroutine which compares a DAS file summary */
/*     to an expected summary.  Both summaries are packed into integer */
/*     arrays. */

/* Subroutine */ int chkfs_(integer *fsum, integer *xfsum, logical *ok)
{
    extern /* Subroutine */ int chcksi_(char *, integer *, char *, integer *, 
	    integer *, logical *, ftnlen, ftnlen);

    chcksi_("NRESVR", fsum, "=", xfsum, &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksi_("NRESVC", &fsum[1], "=", &xfsum[1], &c__0, ok, (ftnlen)6, (ftnlen)
	    1);
    chcksi_("NCOMR", &fsum[2], "=", &xfsum[2], &c__0, ok, (ftnlen)5, (ftnlen)
	    1);
    chcksi_("NCOMC", &fsum[3], "=", &xfsum[3], &c__0, ok, (ftnlen)5, (ftnlen)
	    1);
    chcksi_("FREE", &fsum[4], "=", &xfsum[4], &c__0, ok, (ftnlen)4, (ftnlen)1)
	    ;
    chcksi_("LASTLA(1) (CHAR)", &fsum[5], "=", &xfsum[5], &c__0, ok, (ftnlen)
	    16, (ftnlen)1);
    chcksi_("LASTLA(2) (DP)", &fsum[6], "=", &xfsum[6], &c__0, ok, (ftnlen)14,
	     (ftnlen)1);
    chcksi_("LASTLA(3) (INT)", &fsum[7], "=", &xfsum[7], &c__0, ok, (ftnlen)
	    15, (ftnlen)1);
    chcksi_("LASTRC(1) (CHAR)", &fsum[8], "=", &xfsum[8], &c__0, ok, (ftnlen)
	    16, (ftnlen)1);
    chcksi_("LASTRC(2) (DP)", &fsum[9], "=", &xfsum[9], &c__0, ok, (ftnlen)14,
	     (ftnlen)1);
    chcksi_("LASTRC(3) (INT)", &fsum[10], "=", &xfsum[10], &c__0, ok, (ftnlen)
	    15, (ftnlen)1);
    chcksi_("LASTWD(1) (CHAR)", &fsum[11], "=", &xfsum[11], &c__0, ok, (
	    ftnlen)16, (ftnlen)1);
    chcksi_("LASTWD(2) (DP)", &fsum[12], "=", &xfsum[12], &c__0, ok, (ftnlen)
	    14, (ftnlen)1);
    chcksi_("LASTWD(3) (INT)", &fsum[13], "=", &xfsum[13], &c__0, ok, (ftnlen)
	    15, (ftnlen)1);
    return 0;
} /* chkfs_ */


/*     CHKCDS is a utility subroutine which compares a DAS cluster */
/*     directory record to an expected cluster directory record. */

/* Subroutine */ int chkcds_(integer *cdrec, integer *xcdrec, logical *ok)
{
    /* System generated locals */
    integer i__1;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    integer i__;
    char title[80];
    extern /* Subroutine */ int chcksi_(char *, integer *, char *, integer *, 
	    integer *, logical *, ftnlen, ftnlen), repmot_(char *, char *, 
	    integer *, char *, char *, ftnlen, ftnlen, ftnlen, ftnlen);


/*     Local parameters */


/*     Local variables */

    chcksi_("BWD ptr", cdrec, "=", xcdrec, &c__0, ok, (ftnlen)7, (ftnlen)1);
    chcksi_("FWD ptr", &cdrec[1], "=", &xcdrec[1], &c__0, ok, (ftnlen)7, (
	    ftnlen)1);
    chcksi_("Min CHAR addr", &cdrec[2], "=", &xcdrec[2], &c__0, ok, (ftnlen)
	    13, (ftnlen)1);
    chcksi_("Max CHAR addr", &cdrec[3], "=", &xcdrec[3], &c__0, ok, (ftnlen)
	    13, (ftnlen)1);
    chcksi_("Min DP addr", &cdrec[4], "=", &xcdrec[4], &c__0, ok, (ftnlen)11, 
	    (ftnlen)1);
    chcksi_("Max DP addr", &cdrec[5], "=", &xcdrec[5], &c__0, ok, (ftnlen)11, 
	    (ftnlen)1);
    chcksi_("Min INT addr", &cdrec[6], "=", &xcdrec[6], &c__0, ok, (ftnlen)12,
	     (ftnlen)1);
    chcksi_("Max INT addr", &cdrec[7], "=", &xcdrec[7], &c__0, ok, (ftnlen)12,
	     (ftnlen)1);
    chcksi_("1st type", &cdrec[8], "=", &xcdrec[8], &c__0, ok, (ftnlen)8, (
	    ftnlen)1);
    chcksi_("1st count", &cdrec[9], "=", &xcdrec[9], &c__0, ok, (ftnlen)9, (
	    ftnlen)1);
    for (i__ = 11; i__ <= 256; ++i__) {
	s_copy(title, "the # cluster count", (ftnlen)80, (ftnlen)19);
	i__1 = i__ - 9;
	repmot_(title, "#", &i__1, "L", title, (ftnlen)80, (ftnlen)1, (ftnlen)
		1, (ftnlen)80);
	chcksi_(title, &cdrec[i__ - 1], "=", &xcdrec[i__ - 1], &c__0, ok, (
		ftnlen)80, (ftnlen)1);
    }
    return 0;
} /* chkcds_ */

