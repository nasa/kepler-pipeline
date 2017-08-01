/* f_ckcov.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static integer c__0 = 0;
static integer c__10000 = 10000;
static integer c__1 = 1;
static integer c__14 = 14;
static integer c__4 = 4;
static integer c__3 = 3;
static doublereal c_b393 = 1e6;
static doublereal c_b394 = 1e7;
static doublereal c_b404 = 0.;
static logical c_true = TRUE_;
static doublereal c_b541 = 1.;
static doublereal c_b731 = -1.;
static integer c__20 = 20;
static integer c__5 = 5;
static integer c__6 = 6;
static integer c_b807 = -1000000;

/* $Procedure      F_CKCOV ( CKCOV tests ) */
/* Subroutine */ int f_ckcov__(logical *ok)
{
    /* Initialized data */

    static integer inst[5] = { -1000,-2000,-3000,-4000,-5000 };
    static integer nseg[5] = { 3,3,4,4,4 };
    static integer nr[5] = { 4,99,199,299,399 };
    static integer ivln[5] = { 4,3,7,9,20 };
    static doublereal tikper[5] = { 2.,4.,8.,16.,32. };
    static doublereal z__[3] = { 0.,0.,1. };

    /* System generated locals */
    integer i__1, i__2, i__3, i__4, i__5;
    doublereal d__1;
    cllist cl__1;

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer);
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer f_clos(cllist *);

    /* Local variables */
    doublereal cmat[9]	/* was [3][3] */;
    extern /* Subroutine */ int ckw01_(integer *, doublereal *, doublereal *, 
	    integer *, char *, logical *, char *, integer *, doublereal *, 
	    doublereal *, doublereal *, ftnlen, ftnlen), ckw02_(integer *, 
	    doublereal *, doublereal *, integer *, char *, char *, integer *, 
	    doublereal *, doublereal *, doublereal *, doublereal *, 
	    doublereal *, ftnlen, ftnlen);
    integer nrec;
    extern /* Subroutine */ int ckw03_(integer *, doublereal *, doublereal *, 
	    integer *, char *, logical *, char *, integer *, doublereal *, 
	    doublereal *, doublereal *, integer *, doublereal *, ftnlen, 
	    ftnlen);
    doublereal ends[400];
    extern /* Subroutine */ int ckw05_(integer *, integer *, integer *, 
	    doublereal *, doublereal *, integer *, char *, logical *, char *, 
	    integer *, doublereal *, doublereal *, doublereal *, integer *, 
	    doublereal *, ftnlen, ftnlen);
    doublereal rate, last;
    integer xids[12];
    extern /* Subroutine */ int vscl_(doublereal *, doublereal *, doublereal *
	    );
    doublereal avvs[1200]	/* was [3][400] */, pkts[5600], t3end;
    extern /* Subroutine */ int sct2e_(integer *, doublereal *, doublereal *);
    integer i__, j, k, l;
    extern integer cardd_(doublereal *);
    integer m;
    extern /* Subroutine */ int dafbt_(char *, integer *, ftnlen);
    extern integer cardi_(integer *);
    doublereal angle;
    integer clkid[5];
    extern /* Subroutine */ int ckobj_(char *, integer *, ftnlen);
    char segid[40];
    extern /* Subroutine */ int ckw04b_(integer *, doublereal *, integer *, 
	    char *, logical *, char *, ftnlen, ftnlen), ckw04a_(integer *, 
	    integer *, integer *, doublereal *, doublereal *), ckw04e_(
	    integer *, doublereal *), tcase_(char *, ftnlen), ckcls_(integer *
	    ), ckcov_(char *, integer *, logical *, char *, doublereal *, 
	    char *, doublereal *, ftnlen, ftnlen, ftnlen), repmc_(char *, 
	    char *, char *, char *, ftnlen, ftnlen, ftnlen, ftnlen), ckopn_(
	    char *, char *, integer *, integer *, ftnlen, ftnlen), moved_(
	    doublereal *, integer *, doublereal *), repmi_(char *, char *, 
	    integer *, char *, ftnlen, ftnlen, ftnlen);
    doublereal cover[10006], rates[400];
    extern /* Subroutine */ int copyd_(doublereal *, doublereal *);
    char title[240];
    logical useav;
    integer dtype;
    extern /* Subroutine */ int topen_(char *, ftnlen);
    doublereal first;
    extern /* Subroutine */ int tstek_(char *, integer *, integer *, logical *
	    , integer *, ftnlen);
    doublereal quats[1600]	/* was [4][400] */;
    integer xunit;
    extern /* Subroutine */ int t_success__(logical *);
    doublereal dc[2];
    extern /* Subroutine */ int chckad_(char *, doublereal *, char *, 
	    doublereal *, integer *, doublereal *, logical *, ftnlen, ftnlen),
	     chckai_(char *, integer *, char *, integer *, integer *, logical 
	    *, ftnlen, ftnlen);
    doublereal et;
    integer degree, handle;
    extern /* Subroutine */ int cleard_(integer *, doublereal *), dafcls_(
	    integer *), scardd_(integer *, doublereal *), delfil_(char *, 
	    ftnlen), chckxc_(logical *, char *, logical *, ftnlen), chcksi_(
	    char *, integer *, char *, integer *, integer *, logical *, 
	    ftnlen, ftnlen);
    doublereal packet[14], epochs[400];
    integer defsiz;
    extern /* Subroutine */ int axisar_(doublereal *, doublereal *, 
	    doublereal *), sigerr_(char *, ftnlen);
    char deftxt[80*15];
    doublereal xavseg[50030]	/* was [10006][5] */, xcvseg[50030]	/* 
	    was [10006][5] */;
    extern /* Subroutine */ int lmpool_(char *, integer *, ftnlen);
    char cvstat[80];
    doublereal insets[2];
    extern /* Subroutine */ int ssized_(integer *, doublereal *);
    doublereal xavint[50030]	/* was [10006][5] */, xcvint[50030]	/* 
	    was [10006][5] */;
    integer nintvl;
    doublereal tmpwin[10006];
    integer nstart;
    doublereal starts[400];
    extern /* Subroutine */ int m2q_(doublereal *, doublereal *), wninsd_(
	    doublereal *, doublereal *, doublereal *), setmsg_(char *, ftnlen)
	    ;
    integer pktsiz;
    extern /* Subroutine */ int tstlsk_(void);
    integer subtyp;
    extern /* Subroutine */ int errint_(char *, integer *, ftnlen), wnexpd_(
	    doublereal *, doublereal *, doublereal *), tstspk_(char *, 
	    logical *, integer *, ftnlen), ssizei_(integer *, integer *), 
	    insrti_(integer *, integer *), txtopn_(char *, integer *, ftnlen);
    extern logical odd_(integer *);
    integer ids[12];
    doublereal tol;

/* $ Abstract */

/*     Declare parameters specific to CK type 05. */

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

/*     CK */

/* $ Keywords */

/*     CK */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     N.J. Bachman      (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    SPICELIB Version 1.0.0, 20-AUG-2002 (NJB) */

/* -& */

/*     CK type 5 subtype codes: */


/*     Subtype 0:  Hermite interpolation, 8-element packets. Quaternion */
/*                 and quaternion derivatives only, no angular velocity */
/*                 vector provided. Quaternion elements are listed */
/*                 first, followed by derivatives. Angular velocity is */
/*                 derived from the quaternions and quaternion */
/*                 derivatives. */


/*     Subtype 1:  Lagrange interpolation, 4-element packets. Quaternion */
/*                 only. Angular velocity is derived by differentiating */
/*                 the interpolating polynomials. */


/*     Subtype 2:  Hermite interpolation, 14-element packets. */
/*                 Quaternion and angular angular velocity vector, as */
/*                 well as derivatives of each, are provided. The */
/*                 quaternion comes first, then quaternion derivatives, */
/*                 then angular velocity and its derivatives. */


/*     Subtype 3:  Lagrange interpolation, 7-element packets. Quaternion */
/*                 and angular velocity vector provided.  The quaternion */
/*                 comes first. */


/*     Packet sizes associated with the various subtypes: */


/*     End of file ck05.inc. */

/* $ Abstract */

/*     This routine tests the SPICELIB routines */

/*        CKCOV */
/*        CKOBJ */

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

/* $ Version */

/* -    TSPICE Version 1.0.0, 07-JAN-2005 (NJB) */

/* -& */

/*     SPICELIB functions */

/* $ Abstract */

/*     Declarations of the CK data type specific and general CK low */
/*     level routine parameters. */

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

/*     CK.REQ */

/* $ Keywords */

/*     CK */

/* $ Restrictions */

/*     1) If new CK types are added, the size of the record passed */
/*        between CKRxx and CKExx must be registered as separate */
/*        parameter. If this size will be greater than current value */
/*        of the CKMRSZ parameter (which specifies the maximum record */
/*        size for the record buffer used inside CKPFS) then it should */
/*        be assigned to CKMRSZ as a new value. */

/* $ Author_and_Institution */

/*     N.J. Bachman      (JPL) */
/*     B.V. Semenov      (JPL) */

/* $ Literature_References */

/*     CK Required Reading. */

/* $ Version */

/* -    SPICELIB Version 2.0.0, 19-AUG-2002 (NJB) */

/*        Updated to support CK type 5. */

/* -    SPICELIB Version 1.0.0, 05-APR-1999 (BVS) */

/* -& */

/*     Number of quaternion components and number of quaternion and */
/*     angular rate components together. */


/*     CK Type 1 parameters: */

/*     CK1DTP   CK data type 1 ID; */

/*     CK1RSZ   maximum size of a record passed between CKR01 */
/*              and CKE01. */


/*     CK Type 2 parameters: */

/*     CK2DTP   CK data type 2 ID; */

/*     CK2RSZ   maximum size of a record passed between CKR02 */
/*              and CKE02. */


/*     CK Type 3 parameters: */

/*     CK3DTP   CK data type 3 ID; */

/*     CK3RSZ   maximum size of a record passed between CKR03 */
/*              and CKE03. */


/*     CK Type 4 parameters: */

/*     CK4DTP   CK data type 4 ID; */

/*     CK4PCD   parameter defining integer to DP packing schema that */
/*              is applied when seven number integer array containing */
/*              polynomial degrees for quaternion and angular rate */
/*              components packed into a single DP number stored in */
/*              actual CK records in a file; the value of must not be */
/*              changed or compatibility with existing type 4 CK files */
/*              will be lost. */

/*     CK4MXD   maximum Chebychev polynomial degree allowed in type 4 */
/*              records; the value of this parameter must never exceed */
/*              value of the CK4PCD; */

/*     CK4SFT   number of additional DPs, which are not polynomial */
/*              coefficients, located at the beginning of a type 4 */
/*              CK record that passed between routines CKR04 and CKE04; */

/*     CK4RSZ   maximum size of type 4 CK record passed between CKR04 */
/*              and CKE04; CK4RSZ is computed as follows: */

/*                 CK4RSZ = ( CK4MXD + 1 ) * QAVSIZ + CK4SFT */


/*     CK Type 5 parameters: */


/*     CK5DTP   CK data type 5 ID; */

/*     CK5MXD   maximum polynomial degree allowed in type 5 */
/*              records. */

/*     CK5MET   number of additional DPs, which are not polynomial */
/*              coefficients, located at the beginning of a type 5 */
/*              CK record that passed between routines CKR05 and CKE05; */

/*     CK5MXP   maximum packet size for any subtype.  Subtype 2 */
/*              has the greatest packet size, since these packets */
/*              contain a quaternion, its derivative, an angular */
/*              velocity vector, and its derivative.  See ck05.inc */
/*              for a description of the subtypes. */

/*     CK5RSZ   maximum size of type 5 CK record passed between CKR05 */
/*              and CKE05; CK5RSZ is computed as follows: */

/*                 CK5RSZ = ( CK5MXD + 1 ) * CK5MXP + CK5MET */



/*     Maximum record size that can be handled by CKPFS. This value */
/*     must be set to the maximum of all CKxRSZ parameters (currently */
/*     CK4RSZ.) */


/*     Local parameters */


/*     MAXPKT is the size of the largest CK type 5 subtype's packet. */


/*     Local variables */


/*     Saved variables */


/*     Initial values */


/*     Begin every test family with an open call. */

    topen_("F_CKCOV", (ftnlen)7);

/* --- Case: ------------------------------------------------------ */

    tcase_("Setup:  create and load SCLK definitions for each instrument.", (
	    ftnlen)61);
    for (i__ = 1; i__ <= 5; ++i__) {
	clkid[(i__1 = i__ - 1) < 5 && 0 <= i__1 ? i__1 : s_rnge("clkid", i__1,
		 "f_ckcov__", (ftnlen)201)] = inst[(i__2 = i__ - 1) < 5 && 0 
		<= i__2 ? i__2 : s_rnge("inst", i__2, "f_ckcov__", (ftnlen)
		201)] / 1000;
	s_copy(deftxt, "SCLK_KERNEL_ID         = ( @03-JAN-2005/02:03 )", (
		ftnlen)80, (ftnlen)47);
	s_copy(deftxt + 80, "SCLK_DATA_TYPE_#       = ( 1 )", (ftnlen)80, (
		ftnlen)30);
	s_copy(deftxt + 160, "SCLK01_TIME_SYSTEM_#   = ( 2 )", (ftnlen)80, (
		ftnlen)30);
	s_copy(deftxt + 240, "SCLK01_N_FIELDS_#      = ( 2 )", (ftnlen)80, (
		ftnlen)30);
	s_copy(deftxt + 320, "SCLK01_MODULI_#        = ( 4294967296 256 )", (
		ftnlen)80, (ftnlen)43);
	s_copy(deftxt + 400, "SCLK01_OFFSETS_#       = ( 0          0   )", (
		ftnlen)80, (ftnlen)43);
	s_copy(deftxt + 480, "SCLK01_OUTPUT_DELIM_#  = ( 1 )", (ftnlen)80, (
		ftnlen)30);
	s_copy(deftxt + 560, "SCLK_PARTITION_START_# = ( 0 )", (ftnlen)80, (
		ftnlen)30);
	s_copy(deftxt + 640, "SCLK_PARTITION_END_#   = ( 1.0995116277750E+12"
		" )", (ftnlen)80, (ftnlen)48);
	s_copy(deftxt + 720, "SCLK01_COEFFICIENTS_#  = ( 0  0  1 )", (ftnlen)
		80, (ftnlen)36);
	defsiz = 10;
	i__1 = defsiz;
	for (j = 1; j <= i__1; ++j) {
	    i__5 = -clkid[(i__3 = i__ - 1) < 5 && 0 <= i__3 ? i__3 : s_rnge(
		    "clkid", i__3, "f_ckcov__", (ftnlen)217)];
	    repmi_(deftxt + ((i__2 = j - 1) < 15 && 0 <= i__2 ? i__2 : s_rnge(
		    "deftxt", i__2, "f_ckcov__", (ftnlen)217)) * 80, "#", &
		    i__5, deftxt + ((i__4 = j - 1) < 15 && 0 <= i__4 ? i__4 : 
		    s_rnge("deftxt", i__4, "f_ckcov__", (ftnlen)217)) * 80, (
		    ftnlen)80, (ftnlen)1, (ftnlen)80);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	}
	lmpool_(deftxt, &defsiz, (ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     We'll need a leapseconds kernel too. */

    tstlsk_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Setup:  create CK file.", (ftnlen)23);

/*     Create a CK file with data for five objects. */

    ckopn_("ckcov.bc", "ckcov.bc", &c__0, &handle, (ftnlen)8, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Initialize the expected coverage windows. */

    for (i__ = 1; i__ <= 5; ++i__) {
	ssized_(&c__10000, &xavseg[(i__1 = i__ * 10006 - 10006) < 50030 && 0 
		<= i__1 ? i__1 : s_rnge("xavseg", i__1, "f_ckcov__", (ftnlen)
		250)]);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	ssized_(&c__10000, &xavint[(i__1 = i__ * 10006 - 10006) < 50030 && 0 
		<= i__1 ? i__1 : s_rnge("xavint", i__1, "f_ckcov__", (ftnlen)
		253)]);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	ssized_(&c__10000, &xcvseg[(i__1 = i__ * 10006 - 10006) < 50030 && 0 
		<= i__1 ? i__1 : s_rnge("xcvseg", i__1, "f_ckcov__", (ftnlen)
		256)]);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	ssized_(&c__10000, &xcvint[(i__1 = i__ * 10006 - 10006) < 50030 && 0 
		<= i__1 ? i__1 : s_rnge("xcvint", i__1, "f_ckcov__", (ftnlen)
		259)]);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    ssized_(&c__10000, tmpwin);

/*     Initializations to make compilers happy. */

    first = 0.;
    last = 0.;
    t3end = 0.;

/*     For each instrument, we'll create a sequence of segments. Because */
/*     we have CKCOV code (in some cases, the code resides in supporting */
/*     utilities) unique to each data type, we'll create segments of all */
/*     data types:  all of the segments for the Ith instrument will of */
/*     data type I.  Characteristics of the segments such as presence of */
/*     angular velocity, spacing of epochs and interpolation intervals, */
/*     spacing of segments, and time ordering of segments relative to */
/*     each other will vary. */

    for (i__ = 1; i__ <= 5; ++i__) {
	i__2 = nseg[(i__1 = i__ - 1) < 5 && 0 <= i__1 ? i__1 : s_rnge("nseg", 
		i__1, "f_ckcov__", (ftnlen)285)];
	for (j = 1; j <= i__2; ++j) {

/*           Create segments for instrument I.  All segments for */
/*           instrument I will use data type I. */

	    dtype = i__;

/*           Set the number of records in the Jth segment for instrument */
/*           I. */

	    nrec = nr[(i__1 = j - 1) < 5 && 0 <= i__1 ? i__1 : s_rnge("nr", 
		    i__1, "f_ckcov__", (ftnlen)296)];

/*           Set the number of pointing records per interpolation */
/*           interval for instrument I. */

	    nintvl = ivln[(i__1 = j - 1) < 5 && 0 <= i__1 ? i__1 : s_rnge(
		    "ivln", i__1, "f_ckcov__", (ftnlen)302)];

/*           The flag USEAV indicates how the angular velocity flag */
/*           will be set.  Odd-indexed segments get angular velocity. */

	    useav = odd_(&j);

/*           Proceed to create the Jth segment for instrument I. */
/*           The following code is data-type dependent. */

	    if (i__ == 1) {

/*              This is the CK type 1 case. */

/*              The segments we create will be separated by a 3 tick gap. */
/*              Records will be 3*J ticks apart. */

/*              Set segment start and epochs. */

		if (j == 1) {
		    first = 0.;
		} else {

/*                 LAST is left over from the previous J-loop iteration. */

		    first = last + 3.;
		}

/*              Set EPOCHS, QUATS, and AVVS. */

/*              Pointing data are not relevant for these tests, */
/*              but having distinct entries could be helpful for */
/*              debugging.  The Kth entry will be a frame rotation */
/*              by K milliradians about the Z-axis. */

		i__1 = nrec;
		for (k = 1; k <= i__1; ++k) {

/*                 As stated above, records will be 3*J ticks apart. */

		    epochs[(i__3 = k - 1) < 400 && 0 <= i__3 ? i__3 : s_rnge(
			    "epochs", i__3, "f_ckcov__", (ftnlen)343)] = 
			    first + (doublereal) (j * 3 * (k - 1));
/*                 The angle required by AXISAR is the negative of */
/*                 the frame rotation angle. */

		    angle = -(k * .001);
		    axisar_(z__, &angle, cmat);
		    chckxc_(&c_false, " ", ok, (ftnlen)1);
		    m2q_(cmat, &quats[(i__3 = (k << 2) - 4) < 1600 && 0 <= 
			    i__3 ? i__3 : s_rnge("quats", i__3, "f_ckcov__", (
			    ftnlen)353)]);
		    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*                 Set angular velocity to be consistent with */
/*                 the rotation data.  Remember angular velocity */
/*                 units are radians/sec, so we must multiply */
/*                 radians/tick by ticks/second for instrument I. */

		    d__1 = tikper[(i__3 = i__ - 1) < 5 && 0 <= i__3 ? i__3 : 
			    s_rnge("tikper", i__3, "f_ckcov__", (ftnlen)362)] 
			    * angle / (j * 3);
		    vscl_(&d__1, z__, &avvs[(i__4 = k * 3 - 3) < 1200 && 0 <= 
			    i__4 ? i__4 : s_rnge("avvs", i__4, "f_ckcov__", (
			    ftnlen)362)]);
		}

/*              Set segment end time. */

		last = epochs[(i__1 = nrec - 1) < 400 && 0 <= i__1 ? i__1 : 
			s_rnge("epochs", i__1, "f_ckcov__", (ftnlen)369)];

/*              Add the segment's coverage interval to our segment-level */
/*              expected coverage window for the Ith instrument. */

		wninsd_(&first, &last, &xcvseg[(i__1 = i__ * 10006 - 10006) < 
			50030 && 0 <= i__1 ? i__1 : s_rnge("xcvseg", i__1, 
			"f_ckcov__", (ftnlen)375)]);
		chckxc_(&c_false, " ", ok, (ftnlen)1);

/*              If we're providing angular velocity for this segment, */
/*              then this segment contributes to the coverage window */
/*              for the angular-velocity only segments at the interval */
/*              level. */

		if (useav) {
		    wninsd_(&first, &last, &xavseg[(i__1 = i__ * 10006 - 
			    10006) < 50030 && 0 <= i__1 ? i__1 : s_rnge("xav"
			    "seg", i__1, "f_ckcov__", (ftnlen)385)]);
		    chckxc_(&c_false, " ", ok, (ftnlen)1);
		}

/*              The singleton intervals defined by the pointing epochs */
/*              act as interpolation intervals for type 1 segments. */
/*              Add the interpolation intervals to our interval-level */
/*              expected coverage window for the Ith instrument. */

		i__1 = nrec;
		for (k = 1; k <= i__1; ++k) {
		    wninsd_(&epochs[(i__3 = k - 1) < 400 && 0 <= i__3 ? i__3 :
			     s_rnge("epochs", i__3, "f_ckcov__", (ftnlen)396)]
			    , &epochs[(i__4 = k - 1) < 400 && 0 <= i__4 ? 
			    i__4 : s_rnge("epochs", i__4, "f_ckcov__", (
			    ftnlen)396)], &xcvint[(i__5 = i__ * 10006 - 10006)
			     < 50030 && 0 <= i__5 ? i__5 : s_rnge("xcvint", 
			    i__5, "f_ckcov__", (ftnlen)396)]);
		    chckxc_(&c_false, " ", ok, (ftnlen)1);
		}

/*              If we're providing angular velocity for this segment, */
/*              then this segment contributes to the coverage window */
/*              for the angular-velocity only segments at the interval */
/*              level. */

		if (useav) {
		    i__1 = nrec;
		    for (k = 1; k <= i__1; ++k) {
			wninsd_(&epochs[(i__3 = k - 1) < 400 && 0 <= i__3 ? 
				i__3 : s_rnge("epochs", i__3, "f_ckcov__", (
				ftnlen)410)], &epochs[(i__4 = k - 1) < 400 && 
				0 <= i__4 ? i__4 : s_rnge("epochs", i__4, 
				"f_ckcov__", (ftnlen)410)], &xavint[(i__5 = 
				i__ * 10006 - 10006) < 50030 && 0 <= i__5 ? 
				i__5 : s_rnge("xavint", i__5, "f_ckcov__", (
				ftnlen)410)]);
			chckxc_(&c_false, " ", ok, (ftnlen)1);
		    }
		}

/*              Create segment ID. */

		s_copy(segid, "Segment # for instrument #.", (ftnlen)40, (
			ftnlen)27);
		repmi_(segid, "#", &j, segid, (ftnlen)40, (ftnlen)1, (ftnlen)
			40);
		repmi_(segid, "#", &i__, segid, (ftnlen)40, (ftnlen)1, (
			ftnlen)40);
		chckxc_(&c_false, " ", ok, (ftnlen)1);

/*              Write the current segment to our CK. */

		ckw01_(&handle, &first, &last, &inst[(i__1 = i__ - 1) < 5 && 
			0 <= i__1 ? i__1 : s_rnge("inst", i__1, "f_ckcov__", (
			ftnlen)431)], "J2000", &useav, segid, &nrec, epochs, 
			quats, avvs, (ftnlen)5, (ftnlen)40);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
	    } else if (i__ == 2) {

/*              This is the CK type 2 case. */

/*              For type 2, angular velocity is present by definition. */

		useav = TRUE_;

/*              We're going to copy the data for the type 1 case, but */
/*              here, the segments we create will abut each other. */
/*              Records will be 2*J ticks apart. */

/*              Set segment start and epochs. */

		if (j == 1) {
		    first = 0.;
		} else {

/*                 LAST is left over from the previous J-loop iteration. */

		    first = last;
		}

/*              Set EPOCHS, QUATS, and AVVS. */

/*              Pointing data are not relevant for these tests, */
/*              but having distinct entries could be helpful for */
/*              debugging.  The Kth entry will be a frame rotation */
/*              by K milliradians about the Z-axis. */

		i__1 = nrec;
		for (k = 1; k <= i__1; ++k) {

/*                 As stated above, records will be 2*J ticks apart. */

		    epochs[(i__3 = k - 1) < 400 && 0 <= i__3 ? i__3 : s_rnge(
			    "epochs", i__3, "f_ckcov__", (ftnlen)474)] = 
			    first + (doublereal) ((k - 1) * j << 1);

/*                 Each interpolation interval will be 1 tick long. */

		    ends[(i__3 = k - 1) < 400 && 0 <= i__3 ? i__3 : s_rnge(
			    "ends", i__3, "f_ckcov__", (ftnlen)479)] = epochs[
			    (i__4 = k - 1) < 400 && 0 <= i__4 ? i__4 : s_rnge(
			    "epochs", i__4, "f_ckcov__", (ftnlen)479)] + 1.;
/*                 The angle required by AXISAR is the negative of */
/*                 the frame rotation angle. */

		    angle = -(k * .001);
		    axisar_(z__, &angle, cmat);
		    chckxc_(&c_false, " ", ok, (ftnlen)1);
		    m2q_(cmat, &quats[(i__3 = (k << 2) - 4) < 1600 && 0 <= 
			    i__3 ? i__3 : s_rnge("quats", i__3, "f_ckcov__", (
			    ftnlen)490)]);
		    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*                 Set angular velocity to be consistent with */
/*                 the rotation data.  Remember angular velocity */
/*                 units are radians/sec, so we must multiply */
/*                 radians/tick by ticks/second for instrument I. */

		    d__1 = tikper[(i__3 = i__ - 1) < 5 && 0 <= i__3 ? i__3 : 
			    s_rnge("tikper", i__3, "f_ckcov__", (ftnlen)499)] 
			    * angle / (j << 1);
		    vscl_(&d__1, z__, &avvs[(i__4 = k * 3 - 3) < 1200 && 0 <= 
			    i__4 ? i__4 : s_rnge("avvs", i__4, "f_ckcov__", (
			    ftnlen)499)]);

/*                 Set the clock rate in seconds per tick for the */
/*                 Kth interpolation interval. */

		    rates[(i__3 = k - 1) < 400 && 0 <= i__3 ? i__3 : s_rnge(
			    "rates", i__3, "f_ckcov__", (ftnlen)505)] = 1. / 
			    tikper[(i__4 = i__ - 1) < 5 && 0 <= i__4 ? i__4 : 
			    s_rnge("tikper", i__4, "f_ckcov__", (ftnlen)505)];
		}

/*              Set segment end time.  Note that this is the end of */
/*              the last interpolation interval. */

		last = ends[(i__1 = nrec - 1) < 400 && 0 <= i__1 ? i__1 : 
			s_rnge("ends", i__1, "f_ckcov__", (ftnlen)513)];

/*              Add the segment's coverage interval to our segment-level */
/*              expected coverage window for the Ith instrument. */

		wninsd_(&first, &last, &xcvseg[(i__1 = i__ * 10006 - 10006) < 
			50030 && 0 <= i__1 ? i__1 : s_rnge("xcvseg", i__1, 
			"f_ckcov__", (ftnlen)519)]);
		chckxc_(&c_false, " ", ok, (ftnlen)1);

/*              Since we're providing angular velocity for this segment, */
/*              then this segment contributes to the coverage window */
/*              for the angular-velocity only segments at the interval */
/*              level. */

		wninsd_(&first, &last, &xavseg[(i__1 = i__ * 10006 - 10006) < 
			50030 && 0 <= i__1 ? i__1 : s_rnge("xavseg", i__1, 
			"f_ckcov__", (ftnlen)528)]);
		chckxc_(&c_false, " ", ok, (ftnlen)1);

/*              Add the interpolation intervals to our interval-level */
/*              expected coverage window for the Ith instrument. */

		i__1 = nrec;
		for (k = 1; k <= i__1; ++k) {
		    wninsd_(&epochs[(i__3 = k - 1) < 400 && 0 <= i__3 ? i__3 :
			     s_rnge("epochs", i__3, "f_ckcov__", (ftnlen)536)]
			    , &ends[(i__4 = k - 1) < 400 && 0 <= i__4 ? i__4 :
			     s_rnge("ends", i__4, "f_ckcov__", (ftnlen)536)], 
			    &xcvint[(i__5 = i__ * 10006 - 10006) < 50030 && 0 
			    <= i__5 ? i__5 : s_rnge("xcvint", i__5, "f_ckcov"
			    "__", (ftnlen)536)]);
		    wninsd_(&epochs[(i__3 = k - 1) < 400 && 0 <= i__3 ? i__3 :
			     s_rnge("epochs", i__3, "f_ckcov__", (ftnlen)537)]
			    , &ends[(i__4 = k - 1) < 400 && 0 <= i__4 ? i__4 :
			     s_rnge("ends", i__4, "f_ckcov__", (ftnlen)537)], 
			    &xavint[(i__5 = i__ * 10006 - 10006) < 50030 && 0 
			    <= i__5 ? i__5 : s_rnge("xavint", i__5, "f_ckcov"
			    "__", (ftnlen)537)]);
		}

/*              Create segment ID. */

		s_copy(segid, "Segment # for instrument #.", (ftnlen)40, (
			ftnlen)27);
		repmi_(segid, "#", &j, segid, (ftnlen)40, (ftnlen)1, (ftnlen)
			40);
		repmi_(segid, "#", &i__, segid, (ftnlen)40, (ftnlen)1, (
			ftnlen)40);
		chckxc_(&c_false, " ", ok, (ftnlen)1);

/*              Write the current segment to our CK. */

		ckw02_(&handle, &first, &last, &inst[(i__1 = i__ - 1) < 5 && 
			0 <= i__1 ? i__1 : s_rnge("inst", i__1, "f_ckcov__", (
			ftnlen)552)], "J2000", segid, &nrec, epochs, ends, 
			quats, avvs, rates, (ftnlen)5, (ftnlen)40);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
	    } else if (i__ == 3) {

/*              This is the CK type 3 case. */

/*              The segments we create will be separated by a 3 tick gap. */
/*              Records will be J ticks apart. */

/*              Set segment start and epochs. */

		if (j == 1) {
		    first = 0.;
		} else {

/*                 LAST is left over from the previous J-loop iteration. */

		    first = last + 3.;
		}

/*              Set EPOCHS, QUATS, and AVVS. */

/*              Pointing data are not relevant for these tests, */
/*              but having distinct entries could be helpful for */
/*              debugging.  The Kth entry will be a frame rotation */
/*              by K milliradians about the Z-axis. */

		i__1 = nrec;
		for (k = 1; k <= i__1; ++k) {

/*                 As stated above, records will be J ticks apart. */

		    epochs[(i__3 = k - 1) < 400 && 0 <= i__3 ? i__3 : s_rnge(
			    "epochs", i__3, "f_ckcov__", (ftnlen)589)] = 
			    first + (doublereal) ((k - 1) * j);
/*                 The angle required by AXISAR is the negative of */
/*                 the frame rotation angle. */

		    angle = -(k * .001);
		    axisar_(z__, &angle, cmat);
		    chckxc_(&c_false, " ", ok, (ftnlen)1);
		    m2q_(cmat, &quats[(i__3 = (k << 2) - 4) < 1600 && 0 <= 
			    i__3 ? i__3 : s_rnge("quats", i__3, "f_ckcov__", (
			    ftnlen)599)]);
		    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*                 Set angular velocity to be consistent with */
/*                 the rotation data.  Remember angular velocity */
/*                 units are radians/sec, so we must multiply */
/*                 radians/tick by ticks/second for instrument I. */

		    d__1 = tikper[(i__3 = i__ - 1) < 5 && 0 <= i__3 ? i__3 : 
			    s_rnge("tikper", i__3, "f_ckcov__", (ftnlen)608)] 
			    * angle / j;
		    vscl_(&d__1, z__, &avvs[(i__4 = k * 3 - 3) < 1200 && 0 <= 
			    i__4 ? i__4 : s_rnge("avvs", i__4, "f_ckcov__", (
			    ftnlen)608)]);
		}

/*              Set segment end time. */

		last = epochs[(i__1 = nrec - 1) < 400 && 0 <= i__1 ? i__1 : 
			s_rnge("epochs", i__1, "f_ckcov__", (ftnlen)615)];

/*              Add the segment's coverage interval to our segment-level */
/*              expected coverage window for the Ith instrument. */

		wninsd_(&first, &last, &xcvseg[(i__1 = i__ * 10006 - 10006) < 
			50030 && 0 <= i__1 ? i__1 : s_rnge("xcvseg", i__1, 
			"f_ckcov__", (ftnlen)621)]);
		chckxc_(&c_false, " ", ok, (ftnlen)1);

/*              If we're providing angular velocity for this segment, */
/*              then this segment contributes to the coverage window */
/*              for the angular-velocity only segments at the interval */
/*              level. */

		if (useav) {
		    wninsd_(&first, &last, &xavseg[(i__1 = i__ * 10006 - 
			    10006) < 50030 && 0 <= i__1 ? i__1 : s_rnge("xav"
			    "seg", i__1, "f_ckcov__", (ftnlen)631)]);
		    chckxc_(&c_false, " ", ok, (ftnlen)1);
		}

/*              Set the interval start times.  The first epoch */
/*              is always the start of an interpolation interval */
/*              in these tests.  Each interval has length NINTVL */
/*              records. */

		l = 0;
		i__1 = nrec;
		i__3 = nintvl + 1;
		for (k = 1; i__3 < 0 ? k >= i__1 : k <= i__1; k += i__3) {

/*                 Increment the interpolation interval; set the */
/*                 start time. */

		    ++l;
		    starts[(i__4 = l - 1) < 400 && 0 <= i__4 ? i__4 : s_rnge(
			    "starts", i__4, "f_ckcov__", (ftnlen)650)] = 
			    epochs[(i__5 = k - 1) < 400 && 0 <= i__5 ? i__5 : 
			    s_rnge("epochs", i__5, "f_ckcov__", (ftnlen)650)];

/*                 Keep track of the interval end times. */

		    if (l > 1) {

/*                    Record the end time of the previous interval. */

			ends[(i__4 = l - 2) < 400 && 0 <= i__4 ? i__4 : 
				s_rnge("ends", i__4, "f_ckcov__", (ftnlen)659)
				] = epochs[(i__5 = k - 2) < 400 && 0 <= i__5 ?
				 i__5 : s_rnge("epochs", i__5, "f_ckcov__", (
				ftnlen)659)];
		    }
		}

/*              Set the interpolation interval count. */

		nstart = l;

/*              The end time of the last interval is (in this test) */
/*              always the last epoch. */

		ends[(i__3 = nstart - 1) < 400 && 0 <= i__3 ? i__3 : s_rnge(
			"ends", i__3, "f_ckcov__", (ftnlen)674)] = epochs[(
			i__1 = nrec - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge(
			"epochs", i__1, "f_ckcov__", (ftnlen)674)];

/*              Add the interpolation intervals to our interval-level */
/*              expected coverage window for the Ith instrument. */

		i__3 = nstart;
		for (k = 1; k <= i__3; ++k) {
		    wninsd_(&starts[(i__1 = k - 1) < 400 && 0 <= i__1 ? i__1 :
			     s_rnge("starts", i__1, "f_ckcov__", (ftnlen)681)]
			    , &ends[(i__4 = k - 1) < 400 && 0 <= i__4 ? i__4 :
			     s_rnge("ends", i__4, "f_ckcov__", (ftnlen)681)], 
			    &xcvint[(i__5 = i__ * 10006 - 10006) < 50030 && 0 
			    <= i__5 ? i__5 : s_rnge("xcvint", i__5, "f_ckcov"
			    "__", (ftnlen)681)]);
		}

/*              If we're providing angular velocity for this segment, */
/*              then this segment contributes to the coverage window */
/*              for the angular-velocity only segments at the interval */
/*              level. */

		if (useav) {
		    i__3 = nstart;
		    for (k = 1; k <= i__3; ++k) {
			wninsd_(&starts[(i__1 = k - 1) < 400 && 0 <= i__1 ? 
				i__1 : s_rnge("starts", i__1, "f_ckcov__", (
				ftnlen)694)], &ends[(i__4 = k - 1) < 400 && 0 
				<= i__4 ? i__4 : s_rnge("ends", i__4, "f_ckc"
				"ov__", (ftnlen)694)], &xavint[(i__5 = i__ * 
				10006 - 10006) < 50030 && 0 <= i__5 ? i__5 : 
				s_rnge("xavint", i__5, "f_ckcov__", (ftnlen)
				694)]);
			chckxc_(&c_false, " ", ok, (ftnlen)1);
		    }
		}

/*              Create segment ID. */

		s_copy(segid, "Segment # for instrument #.", (ftnlen)40, (
			ftnlen)27);
		repmi_(segid, "#", &j, segid, (ftnlen)40, (ftnlen)1, (ftnlen)
			40);
		repmi_(segid, "#", &i__, segid, (ftnlen)40, (ftnlen)1, (
			ftnlen)40);
		chckxc_(&c_false, " ", ok, (ftnlen)1);

/*              Write the current segment to our CK. */

		ckw03_(&handle, &first, &last, &inst[(i__3 = i__ - 1) < 5 && 
			0 <= i__3 ? i__3 : s_rnge("inst", i__3, "f_ckcov__", (
			ftnlen)715)], "J2000", &useav, segid, &nrec, epochs, 
			quats, avvs, &nstart, starts, (ftnlen)5, (ftnlen)40);
		chckxc_(&c_false, " ", ok, (ftnlen)1);

/*              If this is the last type 3 segment, save the end */
/*              time of the segment. */

		if (j == nseg[2]) {
		    t3end = last;
		}



	    } else if (i__ == 4) {

/*              This is the CK type 4 case. */

/*              The segments we create will be separated by a 3 tick gap. */
/*              Records will be J ticks apart. */

/*              Set segment start and epochs. */

		if (j == 1) {
		    first = 0.;
		} else {

/*                 LAST is left over from the previous J-loop iteration. */

		    first = last + 3.;
		}

/*              Create segment ID. */

		s_copy(segid, "Segment # for instrument #.", (ftnlen)40, (
			ftnlen)27);
		repmi_(segid, "#", &j, segid, (ftnlen)40, (ftnlen)1, (ftnlen)
			40);
		repmi_(segid, "#", &i__, segid, (ftnlen)40, (ftnlen)1, (
			ftnlen)40);
		chckxc_(&c_false, " ", ok, (ftnlen)1);

/*              Begin the segment. */

		ckw04b_(&handle, &first, &inst[(i__3 = i__ - 1) < 5 && 0 <= 
			i__3 ? i__3 : s_rnge("inst", i__3, "f_ckcov__", (
			ftnlen)762)], "J2000", &useav, segid, (ftnlen)5, (
			ftnlen)40);
		chckxc_(&c_false, " ", ok, (ftnlen)1);

/*              Define the start epochs for the packets. */

		i__3 = nrec;
		for (k = 1; k <= i__3; ++k) {

/*                 Packet starts will be 1000*J ticks apart. */

		    epochs[(i__1 = k - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge(
			    "epochs", i__1, "f_ckcov__", (ftnlen)773)] = 
			    first + (doublereal) ((k - 1) * j * 1000);
		}

/*              The segment end time matches the end time of the last */
/*              packet. */

		last = epochs[(i__3 = nrec - 1) < 400 && 0 <= i__3 ? i__3 : 
			s_rnge("epochs", i__3, "f_ckcov__", (ftnlen)781)];

/*              Define the data packets for the current segment; */
/*              add each one to the segment. */

		i__3 = nrec;
		for (k = 1; k <= i__3; ++k) {

/*                 Fill in the current packet.  The packet structure */
/*                 is as follows: */

/*                   ---------------------------------------------------- */
/*                   | The midpoint of the approximation interval       | */
/*                   ---------------------------------------------------- */
/*                   | The radius of the approximation interval         | */
/*                   ---------------------------------------------------- */
/*                   | Number of coefficients for q0                    | */
/*                   ---------------------------------------------------- */
/*                   | Number of coefficients for q1                    | */
/*                   ---------------------------------------------------- */
/*                   | Number of coefficients for q2                    | */
/*                   ---------------------------------------------------- */
/*                   | Number of coefficients for q3                    | */
/*                   ---------------------------------------------------- */
/*                   | Number of coefficients for AV1                   | */
/*                   ---------------------------------------------------- */
/*                   | Number of coefficients for AV2                   | */
/*                   ---------------------------------------------------- */
/*                   | Number of coefficients for AV3                   | */
/*                   ---------------------------------------------------- */
/*                   | q0 Cheby coefficients                            | */
/*                   ---------------------------------------------------- */
/*                   | q1 Cheby coefficients                            | */
/*                   ---------------------------------------------------- */
/*                   | q2 Cheby coefficients                            | */
/*                   ---------------------------------------------------- */
/*                   | q3 Cheby coefficients                            | */
/*                   ---------------------------------------------------- */
/*                   | AV1 Cheby coefficients (optional)                | */
/*                   ---------------------------------------------------- */
/*                   | AV2 Cheby coefficients (optional)                | */
/*                   ---------------------------------------------------- */
/*                   | AV3 Cheby coefficients (optional)                | */
/*                   ---------------------------------------------------- */

/*                 The interval radius will be 499 ticks.  This will */
/*                 put the intervals two ticks apart. */

/*                 The interval midpoint will be at the start time */
/*                 plus 499 ticks. */

		    pkts[0] = epochs[(i__1 = k - 1) < 400 && 0 <= i__1 ? i__1 
			    : s_rnge("epochs", i__1, "f_ckcov__", (ftnlen)832)
			    ] + 499.;
		    pkts[1] = 499.;

/*                 Our quaternions will be constant. */

		    pkts[2] = 1.;
		    pkts[3] = 1.;
		    pkts[4] = 1.;
		    pkts[5] = 1.;

/*                 Angular velocity will be constant at 0. */

		    pkts[6] = 1.;
		    pkts[7] = 1.;
		    pkts[8] = 1.;

/*                 Cheby coefficients for the quaternion elements: */

		    pkts[9] = 1.;
		    pkts[10] = 2.;
		    pkts[11] = 3.;
		    pkts[12] = 4.;

/*                 Cheby coefficients for the angular velocity elements: */

		    pkts[13] = 0.;
		    pkts[14] = 0.;
		    pkts[15] = 0.;

/*                 The packet size depends on whether we're using */
/*                 angular velocity in this segment. */

		    if (useav) {
			pktsiz = 16;
		    } else {
			pktsiz = 13;
		    }

/*                 Add the current packet. */

		    ckw04a_(&handle, &c__1, &pktsiz, pkts, &epochs[(i__1 = k 
			    - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge("epochs", 
			    i__1, "f_ckcov__", (ftnlen)874)]);
		    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*                 Add the interpolation interval to our interval-level */
/*                 expected coverage window for the Ith instrument. */

		    d__1 = epochs[(i__4 = k - 1) < 400 && 0 <= i__4 ? i__4 : 
			    s_rnge("epochs", i__4, "f_ckcov__", (ftnlen)881)] 
			    + pkts[1] * 2;
		    wninsd_(&epochs[(i__1 = k - 1) < 400 && 0 <= i__1 ? i__1 :
			     s_rnge("epochs", i__1, "f_ckcov__", (ftnlen)881)]
			    , &d__1, &xcvint[(i__5 = i__ * 10006 - 10006) < 
			    50030 && 0 <= i__5 ? i__5 : s_rnge("xcvint", i__5,
			     "f_ckcov__", (ftnlen)881)]);
		    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*                 If we're providing angular velocity for this segment, */
/*                 then this segment contributes to the coverage window */
/*                 for the angular-velocity only segments at the interval */
/*                 level. */

		    if (useav) {
			d__1 = epochs[(i__4 = k - 1) < 400 && 0 <= i__4 ? 
				i__4 : s_rnge("epochs", i__4, "f_ckcov__", (
				ftnlen)894)] + pkts[1] * 2;
			wninsd_(&epochs[(i__1 = k - 1) < 400 && 0 <= i__1 ? 
				i__1 : s_rnge("epochs", i__1, "f_ckcov__", (
				ftnlen)894)], &d__1, &xavint[(i__5 = i__ * 
				10006 - 10006) < 50030 && 0 <= i__5 ? i__5 : 
				s_rnge("xavint", i__5, "f_ckcov__", (ftnlen)
				894)]);
			chckxc_(&c_false, " ", ok, (ftnlen)1);
		    }
		}

/*              End the segment. */

		ckw04e_(&handle, &last);
		chckxc_(&c_false, " ", ok, (ftnlen)1);

/*              Add the segment's coverage interval to our segment-level */
/*              expected coverage window for the Ith instrument. */

		wninsd_(&first, &last, &xcvseg[(i__3 = i__ * 10006 - 10006) < 
			50030 && 0 <= i__3 ? i__3 : s_rnge("xcvseg", i__3, 
			"f_ckcov__", (ftnlen)914)]);
		chckxc_(&c_false, " ", ok, (ftnlen)1);

/*              If we're providing angular velocity for this segment, */
/*              then this segment contributes to the coverage window */
/*              for the angular-velocity only segments at the interval */
/*              level. */

		if (useav) {
		    wninsd_(&first, &last, &xavseg[(i__3 = i__ * 10006 - 
			    10006) < 50030 && 0 <= i__3 ? i__3 : s_rnge("xav"
			    "seg", i__3, "f_ckcov__", (ftnlen)924)]);
		    chckxc_(&c_false, " ", ok, (ftnlen)1);
		}
	    } else if (i__ == 5) {

/*              This is the CK type 5 case. */

/*              Set type 5 subtype.  We expect NSEG(5) == 4. */

		if (nseg[4] != 4) {
		    setmsg_("Test cases for CK type 5 segments use a differe"
			    "nt type 5 subtype for each segment.  The Ith seg"
			    "ment is mapped to subtype I-1.  Subtype numbers "
			    "range from 0 to 3. NSEG(5) was expected to be 4 "
			    "but was #.", (ftnlen)201);
		    errint_("#", &nseg[4], (ftnlen)1);
		    sigerr_("SPICE(BUG)", (ftnlen)10);
		    chckxc_(&c_false, " ", ok, (ftnlen)1);
		}
		subtyp = j - 1;

/*              Set packet size. */

		if (subtyp == 0) {
		    pktsiz = 8;
		} else if (subtyp == 1) {
		    pktsiz = 4;
		} else if (subtyp == 2) {
		    pktsiz = 14;
		} else if (subtyp == 3) {
		    pktsiz = 7;
		}
/*              We'll mimic the construction of the type 3 segments, */
/*              but we'll put the segments in reverse time order */
/*              relative to each other. */

/*              T3END is supposed to have been initialized before */
/*              we get here. */


/*              We'll use M as a complementary index with respect to */
/*              J and NSEG(I): */

		m = nseg[(i__3 = i__ - 1) < 5 && 0 <= i__3 ? i__3 : s_rnge(
			"nseg", i__3, "f_ckcov__", (ftnlen)979)] + 1 - j;

/*              We must set NREC and USEAV specially for this */
/*              "backward" segment order. */

		nrec = nr[(i__3 = m - 1) < 5 && 0 <= i__3 ? i__3 : s_rnge(
			"nr", i__3, "f_ckcov__", (ftnlen)985)];
		useav = odd_(&m);

/*              Set segment bounds insets:  except for the short */
/*              segment, the segment bounds will be *inside* the */
/*              coverage of the interpolation intervals. */

		if (nrec < 99) {
		    insets[0] = 0.;
		    insets[1] = 0.;
		} else {
		    insets[0] = (doublereal) (m * 3);
		    insets[1] = (doublereal) (m * 5);
		}

/*              So M will start at NSEG(I) and count down to 1. */

/*              The segments we create will be separated by a 3 tick gap. */
/*              Records will be M ticks apart. */

/*              Set segment end and epochs. */

		if (m == nseg[(i__3 = i__ - 1) < 5 && 0 <= i__3 ? i__3 : 
			s_rnge("nseg", i__3, "f_ckcov__", (ftnlen)1009)]) {
		    last = t3end;
		} else {

/*                 FIRST is left over from the previous M-loop iteration. */

		    last = first - 3.;
		}

/*              Set EPOCHS, QUATS, and AVVS. */

/*              Pointing data are not relevant for these tests, */
/*              but having distinct entries could be helpful for */
/*              debugging.  The Kth entry will be a frame rotation */
/*              by K milliradians about the Z-axis. */

		for (k = nrec; k >= 1; --k) {

/*                 As stated above, records will be M ticks apart. */

		    epochs[(i__3 = k - 1) < 400 && 0 <= i__3 ? i__3 : s_rnge(
			    "epochs", i__3, "f_ckcov__", (ftnlen)1030)] = 
			    last - (doublereal) (m * (nrec - k));
/*                 The angle required by AXISAR is the negative of */
/*                 the frame rotation angle. */

		    angle = -(k * .001);
		    axisar_(z__, &angle, cmat);
		    chckxc_(&c_false, " ", ok, (ftnlen)1);
		    m2q_(cmat, &quats[(i__3 = (k << 2) - 4) < 1600 && 0 <= 
			    i__3 ? i__3 : s_rnge("quats", i__3, "f_ckcov__", (
			    ftnlen)1041)]);
		    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*                 Set angular velocity to be consistent with */
/*                 the rotation data.  Remember angular velocity */
/*                 units are radians/sec, so we must multiply */
/*                 radians/tick by ticks/second for instrument I. */

		    d__1 = tikper[(i__3 = i__ - 1) < 5 && 0 <= i__3 ? i__3 : 
			    s_rnge("tikper", i__3, "f_ckcov__", (ftnlen)1050)]
			     * angle / m;
		    vscl_(&d__1, z__, &avvs[(i__1 = k * 3 - 3) < 1200 && 0 <= 
			    i__1 ? i__1 : s_rnge("avvs", i__1, "f_ckcov__", (
			    ftnlen)1050)]);

/*                 Set packet contents. */

		    cleard_(&c__14, packet);
		    if (subtyp == 0) {

/*                    Packets contain quaternions and quaternion */
/*                    derivatives.  We'll set the derivatives to zero. */

			moved_(&quats[(i__3 = (k << 2) - 4) < 1600 && 0 <= 
				i__3 ? i__3 : s_rnge("quats", i__3, "f_ckcov"
				"__", (ftnlen)1062)], &c__4, packet);
		    } else if (subtyp == 1) {

/*                    Packets contain quaternions only. */

			moved_(&quats[(i__3 = (k << 2) - 4) < 1600 && 0 <= 
				i__3 ? i__3 : s_rnge("quats", i__3, "f_ckcov"
				"__", (ftnlen)1068)], &c__4, packet);
		    } else if (subtyp == 2) {

/*                    Packets contain quaternions, quaternion */
/*                    derivatives, angular velocity, and angular */
/*                    velocity derivatives.  We'll set the derivatives */
/*                    to zero (even though this makes the angular */
/*                    velocity and quaternion derivatives */
/*                    incompatible---subtype 2 is meant to handle */
/*                    this). */

			moved_(&quats[(i__3 = (k << 2) - 4) < 1600 && 0 <= 
				i__3 ? i__3 : s_rnge("quats", i__3, "f_ckcov"
				"__", (ftnlen)1080)], &c__4, packet);
			moved_(&avvs[(i__3 = k * 3 - 3) < 1200 && 0 <= i__3 ? 
				i__3 : s_rnge("avvs", i__3, "f_ckcov__", (
				ftnlen)1081)], &c__3, &packet[8]);
		    } else if (subtyp == 3) {

/*                    Packets contain quaternions and angular velocity. */

			moved_(&quats[(i__3 = (k << 2) - 4) < 1600 && 0 <= 
				i__3 ? i__3 : s_rnge("quats", i__3, "f_ckcov"
				"__", (ftnlen)1088)], &c__4, packet);
			moved_(&avvs[(i__3 = k * 3 - 3) < 1200 && 0 <= i__3 ? 
				i__3 : s_rnge("avvs", i__3, "f_ckcov__", (
				ftnlen)1089)], &c__3, &packet[4]);
		    }

/*                 Insert packet into packet array. */

		    l = (k - 1) * pktsiz + 1;
		    moved_(packet, &pktsiz, &pkts[(i__3 = l - 1) < 5600 && 0 
			    <= i__3 ? i__3 : s_rnge("pkts", i__3, "f_ckcov__",
			     (ftnlen)1098)]);
		}

/*              Set segment start time. */

		first = epochs[0];

/*              Add the segment's coverage interval to our segment-level */
/*              expected coverage window for the Ith instrument. */

		dc[0] = first + insets[0];
		dc[1] = last - insets[1];
		wninsd_(dc, &dc[1], &xcvseg[(i__3 = i__ * 10006 - 10006) < 
			50030 && 0 <= i__3 ? i__3 : s_rnge("xcvseg", i__3, 
			"f_ckcov__", (ftnlen)1114)]);
		chckxc_(&c_false, " ", ok, (ftnlen)1);

/*              If we're providing angular velocity for this segment, */
/*              then this segment contributes to the coverage window */
/*              for the angular-velocity only segments at the interval */
/*              level. */

		if (useav) {
		    wninsd_(dc, &dc[1], &xavseg[(i__3 = i__ * 10006 - 10006) <
			     50030 && 0 <= i__3 ? i__3 : s_rnge("xavseg", 
			    i__3, "f_ckcov__", (ftnlen)1124)]);
		    chckxc_(&c_false, " ", ok, (ftnlen)1);
		}

/*              Set the interval start times.  The first epoch */
/*              is always the start of an interpolation interval */
/*              in these tests.  Each interval has length NINTVL */
/*              records. */

		l = 0;
		i__3 = nrec;
		i__1 = nintvl + 1;
		for (k = 1; i__1 < 0 ? k >= i__3 : k <= i__3; k += i__1) {

/*                 Increment the interpolation interval; set the */
/*                 start time. */

		    ++l;
		    starts[(i__4 = l - 1) < 400 && 0 <= i__4 ? i__4 : s_rnge(
			    "starts", i__4, "f_ckcov__", (ftnlen)1143)] = 
			    epochs[(i__5 = k - 1) < 400 && 0 <= i__5 ? i__5 : 
			    s_rnge("epochs", i__5, "f_ckcov__", (ftnlen)1143)]
			    ;

/*                 Keep track of the interval end times. */

		    if (l > 1) {

/*                    Record the end time of the previous interval. */

			ends[(i__4 = l - 2) < 400 && 0 <= i__4 ? i__4 : 
				s_rnge("ends", i__4, "f_ckcov__", (ftnlen)
				1152)] = epochs[(i__5 = k - 2) < 400 && 0 <= 
				i__5 ? i__5 : s_rnge("epochs", i__5, "f_ckco"
				"v__", (ftnlen)1152)];
		    }
		}

/*              Set the interpolation interval count. */

		nstart = l;

/*              The end time of the last interval is (in this test) */
/*              always the last epoch. */

		ends[(i__1 = nstart - 1) < 400 && 0 <= i__1 ? i__1 : s_rnge(
			"ends", i__1, "f_ckcov__", (ftnlen)1167)] = epochs[(
			i__3 = nrec - 1) < 400 && 0 <= i__3 ? i__3 : s_rnge(
			"epochs", i__3, "f_ckcov__", (ftnlen)1167)];

/*              Add the interpolation intervals to our interval-level */
/*              expected coverage window for the Ith instrument. */

		i__1 = nstart;
		for (k = 1; k <= i__1; ++k) {

/*                 Adjust the interpolation intervals to account for */
/*                 the segment boundaries. */

/* Computing MAX */
		    d__1 = starts[(i__4 = k - 1) < 400 && 0 <= i__4 ? i__4 : 
			    s_rnge("starts", i__4, "f_ckcov__", (ftnlen)1178)]
			    ;
		    starts[(i__3 = k - 1) < 400 && 0 <= i__3 ? i__3 : s_rnge(
			    "starts", i__3, "f_ckcov__", (ftnlen)1178)] = max(
			    d__1,dc[0]);
/* Computing MIN */
		    d__1 = ends[(i__4 = k - 1) < 400 && 0 <= i__4 ? i__4 : 
			    s_rnge("ends", i__4, "f_ckcov__", (ftnlen)1179)];
		    ends[(i__3 = k - 1) < 400 && 0 <= i__3 ? i__3 : s_rnge(
			    "ends", i__3, "f_ckcov__", (ftnlen)1179)] = min(
			    d__1,dc[1]);
		    if (starts[(i__3 = k - 1) < 400 && 0 <= i__3 ? i__3 : 
			    s_rnge("starts", i__3, "f_ckcov__", (ftnlen)1181)]
			     <= ends[(i__4 = k - 1) < 400 && 0 <= i__4 ? i__4 
			    : s_rnge("ends", i__4, "f_ckcov__", (ftnlen)1181)]
			    ) {
			wninsd_(&starts[(i__3 = k - 1) < 400 && 0 <= i__3 ? 
				i__3 : s_rnge("starts", i__3, "f_ckcov__", (
				ftnlen)1182)], &ends[(i__4 = k - 1) < 400 && 
				0 <= i__4 ? i__4 : s_rnge("ends", i__4, "f_c"
				"kcov__", (ftnlen)1182)], &xcvint[(i__5 = i__ *
				 10006 - 10006) < 50030 && 0 <= i__5 ? i__5 : 
				s_rnge("xcvint", i__5, "f_ckcov__", (ftnlen)
				1182)]);
		    }
		}

/*              If we're providing angular velocity for this segment, */
/*              then this segment contributes to the coverage window */
/*              for the angular-velocity only segments at the interval */
/*              level. */

		if (useav) {
		    i__1 = nstart;
		    for (k = 1; k <= i__1; ++k) {

/*                    The interpolation intervals have already been */
/*                    adjusted to account for the segment boundaries. */

			if (starts[(i__3 = k - 1) < 400 && 0 <= i__3 ? i__3 : 
				s_rnge("starts", i__3, "f_ckcov__", (ftnlen)
				1200)] <= ends[(i__4 = k - 1) < 400 && 0 <= 
				i__4 ? i__4 : s_rnge("ends", i__4, "f_ckcov__"
				, (ftnlen)1200)]) {
			    wninsd_(&starts[(i__3 = k - 1) < 400 && 0 <= i__3 
				    ? i__3 : s_rnge("starts", i__3, "f_ckcov"
				    "__", (ftnlen)1202)], &ends[(i__4 = k - 1) 
				    < 400 && 0 <= i__4 ? i__4 : s_rnge("ends",
				     i__4, "f_ckcov__", (ftnlen)1202)], &
				    xavint[(i__5 = i__ * 10006 - 10006) < 
				    50030 && 0 <= i__5 ? i__5 : s_rnge("xavi"
				    "nt", i__5, "f_ckcov__", (ftnlen)1202)]);
			    chckxc_(&c_false, " ", ok, (ftnlen)1);
			}
		    }
		}

/*              Create segment ID. */

		s_copy(segid, "Segment # for instrument #.", (ftnlen)40, (
			ftnlen)27);
		repmi_(segid, "#", &j, segid, (ftnlen)40, (ftnlen)1, (ftnlen)
			40);
		repmi_(segid, "#", &i__, segid, (ftnlen)40, (ftnlen)1, (
			ftnlen)40);
		chckxc_(&c_false, " ", ok, (ftnlen)1);

/*              Write the current segment to our CK.  All interpolating */
/*              polynomials will be cubic. */

		degree = 3;
		rate = 1. / tikper[(i__1 = i__ - 1) < 5 && 0 <= i__1 ? i__1 : 
			s_rnge("tikper", i__1, "f_ckcov__", (ftnlen)1228)];
		ckw05_(&handle, &subtyp, &degree, dc, &dc[1], &inst[(i__1 = 
			i__ - 1) < 5 && 0 <= i__1 ? i__1 : s_rnge("inst", 
			i__1, "f_ckcov__", (ftnlen)1230)], "J2000", &useav, 
			segid, &nrec, epochs, pkts, &rate, &nstart, starts, (
			ftnlen)5, (ftnlen)40);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
	    } else {

/*              Oops. */

		sigerr_("SPICE(BUG)", (ftnlen)10);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
	    }
	}
    }
    ckcls_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call DAFCLS as a last resort, since CKCLS may fail to */
/*     close the file. */

    dafcls_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
/* ****************************************************** */
/* ****************************************************** */
/* ****************************************************** */
/*     CKCOV tests */
/* ****************************************************** */
/* ****************************************************** */
/* ****************************************************** */

/*     We've written the CK.  It's time to check out CKCOV. */


/*     Check actual vs expected coverage as we vary the input */
/*     arguments to CKCOV. */


/*     Each test we do will be performed with both an empty */
/*     and non-empty input coverage window. */

    for (l = 1; l <= 2; ++l) {

/*        We'll start out by testing the coverage summary at the */
/*        segment level. */

	if (l == 1) {

/*           We'll set COVER to be empty on input to CKCOV. */

	    scardd_(&c__0, cover);
	    s_copy(cvstat, "empty", (ftnlen)80, (ftnlen)5);
	} else {
	    s_copy(cvstat, "non-empty", (ftnlen)80, (ftnlen)9);
	}
	for (i__ = 1; i__ <= 5; ++i__) {

/* --- Case: ------------------------------------------------------ */

	    s_copy(title, "Check segment-level coverage for instrument #; CO"
		    "VER starts out #. Angular velocity not needed. TOL = 0.D"
		    "0.", (ftnlen)240, (ftnlen)107);
	    repmi_(title, "#", &i__, title, (ftnlen)240, (ftnlen)1, (ftnlen)
		    240);
	    repmc_(title, "#", cvstat, title, (ftnlen)240, (ftnlen)1, (ftnlen)
		    80, (ftnlen)240);
	    tcase_(title, (ftnlen)240);

/*           Initialize COVER. */

	    ssized_(&c__10000, cover);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Make a copy of the expected window. */

	    copyd_(&xcvseg[(i__2 = i__ * 10006 - 10006) < 50030 && 0 <= i__2 ?
		     i__2 : s_rnge("xcvseg", i__2, "f_ckcov__", (ftnlen)1323)]
		    , tmpwin);
	    if (l == 2) {

/*              Insert an interval into COVER.  This same interval */
/*              must be added to each window containing expected */
/*              coverage. */

		wninsd_(&c_b393, &c_b394, cover);
		chckxc_(&c_false, " ", ok, (ftnlen)1);

/*              The same interval is expected to appear in the output. */

		wninsd_(&c_b393, &c_b394, tmpwin);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
	    }
	    ckcov_("ckcov.bc", &inst[(i__2 = i__ - 1) < 5 && 0 <= i__2 ? i__2 
		    : s_rnge("inst", i__2, "f_ckcov__", (ftnlen)1343)], &
		    c_false, "SEGMENT", &c_b404, "SCLK", cover, (ftnlen)8, (
		    ftnlen)7, (ftnlen)4);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Check cardinality of coverage window. */

	    i__2 = cardd_(cover);
	    i__1 = cardd_(tmpwin);
	    chcksi_("CARDD(COVER)", &i__2, "=", &i__1, &c__0, ok, (ftnlen)12, 
		    (ftnlen)1);

/*           Check coverage window. */

	    i__2 = cardd_(cover);
	    chckad_("COVER", &cover[6], "=", &tmpwin[6], &i__2, &c_b404, ok, (
		    ftnlen)5, (ftnlen)1);
	}

/* --- Case: ------------------------------------------------------ */

	for (i__ = 1; i__ <= 5; ++i__) {
	    s_copy(title, "INST: #;  LEVEL: SEGMENT;  NEEDAV: TRUE; TIMSYS: "
		    "SCLK; TOL: 0.D0; COVER starts out #.", (ftnlen)240, (
		    ftnlen)85);
	    repmi_(title, "#", &i__, title, (ftnlen)240, (ftnlen)1, (ftnlen)
		    240);
	    repmc_(title, "#", cvstat, title, (ftnlen)240, (ftnlen)1, (ftnlen)
		    80, (ftnlen)240);
	    tcase_(title, (ftnlen)240);

/*           Initialize COVER. */

	    ssized_(&c__10000, cover);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Make a copy of the expected window. */

	    copyd_(&xavseg[(i__2 = i__ * 10006 - 10006) < 50030 && 0 <= i__2 ?
		     i__2 : s_rnge("xavseg", i__2, "f_ckcov__", (ftnlen)1385)]
		    , tmpwin);
	    if (l == 2) {

/*              Insert an interval into COVER.  This same interval */
/*              must be added to each window containing expected */
/*              coverage. */

		wninsd_(&c_b393, &c_b394, cover);
		chckxc_(&c_false, " ", ok, (ftnlen)1);

/*              The same interval is expected to appear in the output. */

		wninsd_(&c_b393, &c_b394, tmpwin);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
	    }
	    ckcov_("ckcov.bc", &inst[(i__2 = i__ - 1) < 5 && 0 <= i__2 ? i__2 
		    : s_rnge("inst", i__2, "f_ckcov__", (ftnlen)1404)], &
		    c_true, "SEGMENT", &c_b404, "SCLK", cover, (ftnlen)8, (
		    ftnlen)7, (ftnlen)4);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Check cardinality of coverage window. */

	    i__2 = cardd_(cover);
	    i__1 = cardd_(tmpwin);
	    chcksi_("CARDD(COVER)", &i__2, "=", &i__1, &c__0, ok, (ftnlen)12, 
		    (ftnlen)1);

/*           Check coverage window. */

	    i__2 = cardd_(cover);
	    chckad_("COVER", &cover[6], "=", &tmpwin[6], &i__2, &c_b404, ok, (
		    ftnlen)5, (ftnlen)1);
	}

/* --- Case: ------------------------------------------------------ */

	for (i__ = 1; i__ <= 5; ++i__) {
	    s_copy(title, "INST: #;  LEVEL: SEGMENT;  NEEDAV: FALSE; TIMSYS:"
		    " SCLK; TOL: 1.D0; COVER starts out #.", (ftnlen)240, (
		    ftnlen)86);
	    repmi_(title, "#", &i__, title, (ftnlen)240, (ftnlen)1, (ftnlen)
		    240);
	    repmc_(title, "#", cvstat, title, (ftnlen)240, (ftnlen)1, (ftnlen)
		    80, (ftnlen)240);
	    tcase_(title, (ftnlen)240);

/*           Initialize COVER. */

	    ssized_(&c__10000, cover);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Adjust our expected result window by TOL. */

	    copyd_(&xcvseg[(i__2 = i__ * 10006 - 10006) < 50030 && 0 <= i__2 ?
		     i__2 : s_rnge("xcvseg", i__2, "f_ckcov__", (ftnlen)1448)]
		    , tmpwin);
	    tol = 1.;
	    wnexpd_(&tol, &tol, tmpwin);

/*           Make sure the window doesn't start with a negative tick */
/*           value. */

	    tmpwin[6] = max(tmpwin[6],0.);
	    if (l == 2) {

/*              Insert an interval into COVER.  This same interval */
/*              must be added to each window containing expected */
/*              coverage. */

		wninsd_(&c_b393, &c_b394, cover);
		chckxc_(&c_false, " ", ok, (ftnlen)1);

/*              The same interval is expected to appear in the output. */

		wninsd_(&c_b393, &c_b394, tmpwin);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
	    }
	    ckcov_("ckcov.bc", &inst[(i__2 = i__ - 1) < 5 && 0 <= i__2 ? i__2 
		    : s_rnge("inst", i__2, "f_ckcov__", (ftnlen)1478)], &
		    c_false, "SEGMENT", &tol, "SCLK", cover, (ftnlen)8, (
		    ftnlen)7, (ftnlen)4);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Check cardinality of coverage window. */

	    i__2 = cardd_(cover);
	    i__1 = cardd_(tmpwin);
	    chcksi_("CARDD(COVER)", &i__2, "=", &i__1, &c__0, ok, (ftnlen)12, 
		    (ftnlen)1);

/*           Check coverage window. */

	    i__2 = cardd_(cover);
	    chckad_("COVER", &cover[6], "=", &tmpwin[6], &i__2, &c_b404, ok, (
		    ftnlen)5, (ftnlen)1);
	}
	for (i__ = 1; i__ <= 5; ++i__) {

/* --- Case: ------------------------------------------------------ */

	    s_copy(title, "INST: #;  LEVEL: SEGMENT;  NEEDAV: FALSE; TIMSYS:"
		    " TDB; TOL: 0.D0; COVER: #.", (ftnlen)240, (ftnlen)75);
	    repmi_(title, "#", &i__, title, (ftnlen)240, (ftnlen)1, (ftnlen)
		    240);
	    repmc_(title, "#", cvstat, title, (ftnlen)240, (ftnlen)1, (ftnlen)
		    80, (ftnlen)240);
	    tcase_(title, (ftnlen)240);

/*           Initialize COVER. */

	    ssized_(&c__10000, cover);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Make a copy of the expected window. */

	    copyd_(&xcvseg[(i__2 = i__ * 10006 - 10006) < 50030 && 0 <= i__2 ?
		     i__2 : s_rnge("xcvseg", i__2, "f_ckcov__", (ftnlen)1521)]
		    , tmpwin);

/*           Convert the expected window to TDB. */

	    i__2 = cardd_(tmpwin);
	    for (j = 1; j <= i__2; ++j) {
		sct2e_(&clkid[(i__1 = i__ - 1) < 5 && 0 <= i__1 ? i__1 : 
			s_rnge("clkid", i__1, "f_ckcov__", (ftnlen)1528)], &
			tmpwin[(i__3 = j + 5) < 10006 && 0 <= i__3 ? i__3 : 
			s_rnge("tmpwin", i__3, "f_ckcov__", (ftnlen)1528)], &
			et);
		tmpwin[(i__1 = j + 5) < 10006 && 0 <= i__1 ? i__1 : s_rnge(
			"tmpwin", i__1, "f_ckcov__", (ftnlen)1529)] = et;
		chckxc_(&c_false, " ", ok, (ftnlen)1);
	    }
	    if (l == 2) {

/*              Insert an interval into COVER.  This same interval */
/*              must be added to each window containing expected */
/*              coverage. */

		wninsd_(&c_b393, &c_b394, cover);
		chckxc_(&c_false, " ", ok, (ftnlen)1);

/*              The same interval is expected to appear in the output. */

		wninsd_(&c_b393, &c_b394, tmpwin);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
	    }
	    ckcov_("ckcov.bc", &inst[(i__2 = i__ - 1) < 5 && 0 <= i__2 ? i__2 
		    : s_rnge("inst", i__2, "f_ckcov__", (ftnlen)1553)], &
		    c_false, "SEGMENT", &c_b404, "TDB", cover, (ftnlen)8, (
		    ftnlen)7, (ftnlen)3);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Check cardinality of coverage window. */

	    i__2 = cardd_(cover);
	    i__1 = cardd_(tmpwin);
	    chcksi_("CARDD(COVER)", &i__2, "=", &i__1, &c__0, ok, (ftnlen)12, 
		    (ftnlen)1);

/*           Check coverage window. */

	    i__2 = cardd_(tmpwin);
	    chckad_("COVER", &cover[6], "=", &tmpwin[6], &i__2, &c_b404, ok, (
		    ftnlen)5, (ftnlen)1);
	}
	for (i__ = 1; i__ <= 5; ++i__) {

/* --- Case: ------------------------------------------------------ */

	    s_copy(title, "INST: #;  LEVEL: SEGMENT;  NEEDAV: FALSE; TIMSYS:"
		    " TDB; TOL: 1.D0; COVER: #.", (ftnlen)240, (ftnlen)75);
	    repmi_(title, "#", &i__, title, (ftnlen)240, (ftnlen)1, (ftnlen)
		    240);
	    repmc_(title, "#", cvstat, title, (ftnlen)240, (ftnlen)1, (ftnlen)
		    80, (ftnlen)240);
	    tcase_(title, (ftnlen)240);

/*           Initialize COVER. */

	    ssized_(&c__10000, cover);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Adjust our expected result window by TOL. */

	    copyd_(&xcvseg[(i__2 = i__ * 10006 - 10006) < 50030 && 0 <= i__2 ?
		     i__2 : s_rnge("xcvseg", i__2, "f_ckcov__", (ftnlen)1598)]
		    , tmpwin);
	    tol = 1.;
	    wnexpd_(&tol, &tol, tmpwin);

/*           Make sure the window doesn't start with a negative tick */
/*           value. */

	    tmpwin[6] = max(tmpwin[6],0.);

/*           Convert the expected window to TDB. */

	    i__2 = cardd_(tmpwin);
	    for (j = 1; j <= i__2; ++j) {
		sct2e_(&clkid[(i__1 = i__ - 1) < 5 && 0 <= i__1 ? i__1 : 
			s_rnge("clkid", i__1, "f_ckcov__", (ftnlen)1615)], &
			tmpwin[(i__3 = j + 5) < 10006 && 0 <= i__3 ? i__3 : 
			s_rnge("tmpwin", i__3, "f_ckcov__", (ftnlen)1615)], &
			et);
		tmpwin[(i__1 = j + 5) < 10006 && 0 <= i__1 ? i__1 : s_rnge(
			"tmpwin", i__1, "f_ckcov__", (ftnlen)1616)] = et;
	    }
	    if (l == 2) {

/*              Insert an interval into COVER.  This same interval */
/*              must be added to each window containing expected */
/*              coverage. */

		wninsd_(&c_b393, &c_b394, cover);
		chckxc_(&c_false, " ", ok, (ftnlen)1);

/*              The same interval is expected to appear in the output. */

		wninsd_(&c_b393, &c_b394, tmpwin);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
	    }
	    ckcov_("ckcov.bc", &inst[(i__2 = i__ - 1) < 5 && 0 <= i__2 ? i__2 
		    : s_rnge("inst", i__2, "f_ckcov__", (ftnlen)1638)], &
		    c_false, "SEGMENT", &c_b541, "TDB", cover, (ftnlen)8, (
		    ftnlen)7, (ftnlen)3);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Check cardinality of coverage window. */

	    i__2 = cardd_(cover);
	    i__1 = cardd_(tmpwin);
	    chcksi_("CARDD(COVER)", &i__2, "=", &i__1, &c__0, ok, (ftnlen)12, 
		    (ftnlen)1);

/*           Check coverage window. */

	    i__2 = cardd_(tmpwin);
	    chckad_("COVER", &cover[6], "=", &tmpwin[6], &i__2, &c_b404, ok, (
		    ftnlen)5, (ftnlen)1);
	}

/*        INTERVAL level tests: */


/*        Now we'll repeat the previous tests, but this time the */
/*        coverage will be summarized at the interval level. */

	for (i__ = 1; i__ <= 5; ++i__) {

/* --- Case: ------------------------------------------------------ */

	    s_copy(title, "INST: #;  LEVEL: INTERVAL;  NEEDAV: FALSE; TIMSYS"
		    ": SCLK TOL: 0.D0; COVER: #.", (ftnlen)240, (ftnlen)76);
	    repmi_(title, "#", &i__, title, (ftnlen)240, (ftnlen)1, (ftnlen)
		    240);
	    repmc_(title, "#", cvstat, title, (ftnlen)240, (ftnlen)1, (ftnlen)
		    80, (ftnlen)240);
	    tcase_(title, (ftnlen)240);

/*           Initialize COVER. */

	    ssized_(&c__10000, cover);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Make a copy of the expected window. */

	    copyd_(&xcvint[(i__2 = i__ * 10006 - 10006) < 50030 && 0 <= i__2 ?
		     i__2 : s_rnge("xcvint", i__2, "f_ckcov__", (ftnlen)1687)]
		    , tmpwin);
	    if (l == 2) {

/*              Insert an interval into COVER.  This same interval */
/*              must be added to each window containing expected */
/*              coverage. */

		wninsd_(&c_b393, &c_b394, cover);
		chckxc_(&c_false, " ", ok, (ftnlen)1);

/*              The same interval is expected to appear in the output. */

		wninsd_(&c_b393, &c_b394, tmpwin);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
	    }
	    ckcov_("ckcov.bc", &inst[(i__2 = i__ - 1) < 5 && 0 <= i__2 ? i__2 
		    : s_rnge("inst", i__2, "f_ckcov__", (ftnlen)1706)], &
		    c_false, "INTERVAL", &c_b404, "SCLK", cover, (ftnlen)8, (
		    ftnlen)8, (ftnlen)4);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Check cardinality of coverage window. */

	    i__2 = cardd_(cover);
	    i__1 = cardd_(tmpwin);
	    chcksi_("CARDD(COVER)", &i__2, "=", &i__1, &c__0, ok, (ftnlen)12, 
		    (ftnlen)1);

/*           Check coverage window. */

	    i__2 = cardd_(cover);
	    chckad_("COVER", &cover[6], "=", &tmpwin[6], &i__2, &c_b404, ok, (
		    ftnlen)5, (ftnlen)1);
	}

/* --- Case: ------------------------------------------------------ */

	for (i__ = 1; i__ <= 5; ++i__) {
	    s_copy(title, "INST: #;  LEVEL: INTERVAL;  NEEDAV: TRUE; TIMSYS:"
		    " SCLK TOL: 0.D0; COVER: #.", (ftnlen)240, (ftnlen)75);
	    repmi_(title, "#", &i__, title, (ftnlen)240, (ftnlen)1, (ftnlen)
		    240);
	    repmc_(title, "#", cvstat, title, (ftnlen)240, (ftnlen)1, (ftnlen)
		    80, (ftnlen)240);
	    tcase_(title, (ftnlen)240);

/*           Initialize COVER. */

	    ssized_(&c__10000, cover);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Make a copy of the expected window. */

	    copyd_(&xavint[(i__2 = i__ * 10006 - 10006) < 50030 && 0 <= i__2 ?
		     i__2 : s_rnge("xavint", i__2, "f_ckcov__", (ftnlen)1749)]
		    , tmpwin);
	    if (l == 2) {

/*              Insert an interval into COVER.  This same interval */
/*              must be added to each window containing expected */
/*              coverage. */

		wninsd_(&c_b393, &c_b394, cover);
		chckxc_(&c_false, " ", ok, (ftnlen)1);

/*              The same interval is expected to appear in the output. */

		wninsd_(&c_b393, &c_b394, tmpwin);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
	    }
	    ckcov_("ckcov.bc", &inst[(i__2 = i__ - 1) < 5 && 0 <= i__2 ? i__2 
		    : s_rnge("inst", i__2, "f_ckcov__", (ftnlen)1768)], &
		    c_true, "INTERVAL", &c_b404, "SCLK", cover, (ftnlen)8, (
		    ftnlen)8, (ftnlen)4);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Check cardinality of coverage window. */

	    i__2 = cardd_(cover);
	    i__1 = cardd_(tmpwin);
	    chcksi_("CARDD(COVER)", &i__2, "=", &i__1, &c__0, ok, (ftnlen)12, 
		    (ftnlen)1);

/*           Check coverage window. */

	    i__2 = cardd_(cover);
	    chckad_("COVER", &cover[6], "=", &tmpwin[6], &i__2, &c_b404, ok, (
		    ftnlen)5, (ftnlen)1);
	}

/* --- Case: ------------------------------------------------------ */

	for (i__ = 1; i__ <= 5; ++i__) {
	    s_copy(title, "INST: #;  LEVEL: INTERVAL;  NEEDAV: FALSE; TIMSYS"
		    ": SCLK TOL: 1.D0; COVER: #.", (ftnlen)240, (ftnlen)76);
	    repmi_(title, "#", &i__, title, (ftnlen)240, (ftnlen)1, (ftnlen)
		    240);
	    repmc_(title, "#", cvstat, title, (ftnlen)240, (ftnlen)1, (ftnlen)
		    80, (ftnlen)240);
	    tcase_(title, (ftnlen)240);

/*           Initialize COVER. */

	    ssized_(&c__10000, cover);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Adjust our expected result window by TOL. */

	    copyd_(&xcvint[(i__2 = i__ * 10006 - 10006) < 50030 && 0 <= i__2 ?
		     i__2 : s_rnge("xcvint", i__2, "f_ckcov__", (ftnlen)1811)]
		    , tmpwin);
	    tol = 1.;
	    wnexpd_(&tol, &tol, tmpwin);

/*           Make sure the window doesn't start with a negative tick */
/*           value. */

	    tmpwin[6] = max(tmpwin[6],0.);
	    if (l == 2) {

/*              Insert an interval into COVER.  This same interval */
/*              must be added to each window containing expected */
/*              coverage. */

		wninsd_(&c_b393, &c_b394, cover);
		chckxc_(&c_false, " ", ok, (ftnlen)1);

/*              The same interval is expected to appear in the output. */

		wninsd_(&c_b393, &c_b394, tmpwin);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
	    }
	    ckcov_("ckcov.bc", &inst[(i__2 = i__ - 1) < 5 && 0 <= i__2 ? i__2 
		    : s_rnge("inst", i__2, "f_ckcov__", (ftnlen)1841)], &
		    c_false, "INTERVAL", &tol, "SCLK", cover, (ftnlen)8, (
		    ftnlen)8, (ftnlen)4);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Check cardinality of coverage window. */

	    i__2 = cardd_(cover);
	    i__1 = cardd_(tmpwin);
	    chcksi_("CARDD(COVER)", &i__2, "=", &i__1, &c__0, ok, (ftnlen)12, 
		    (ftnlen)1);

/*           Check coverage window. */

	    i__2 = cardd_(cover);
	    chckad_("COVER", &cover[6], "=", &tmpwin[6], &i__2, &c_b404, ok, (
		    ftnlen)5, (ftnlen)1);
	}
	for (i__ = 1; i__ <= 5; ++i__) {

/* --- Case: ------------------------------------------------------ */

	    s_copy(title, "INST: #;  LEVEL: INTERVAL  NEEDAV: FALSE; TIMSYS:"
		    " TDB; TOL: 0.D0; COVER: #.", (ftnlen)240, (ftnlen)75);
	    repmi_(title, "#", &i__, title, (ftnlen)240, (ftnlen)1, (ftnlen)
		    240);
	    repmc_(title, "#", cvstat, title, (ftnlen)240, (ftnlen)1, (ftnlen)
		    80, (ftnlen)240);
	    tcase_(title, (ftnlen)240);

/*           Initialize COVER. */

	    ssized_(&c__10000, cover);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Make a copy of the expected window. */

	    copyd_(&xcvint[(i__2 = i__ * 10006 - 10006) < 50030 && 0 <= i__2 ?
		     i__2 : s_rnge("xcvint", i__2, "f_ckcov__", (ftnlen)1885)]
		    , tmpwin);

/*           Convert the expected window to TDB. */

	    i__2 = cardd_(tmpwin);
	    for (j = 1; j <= i__2; ++j) {
		sct2e_(&clkid[(i__1 = i__ - 1) < 5 && 0 <= i__1 ? i__1 : 
			s_rnge("clkid", i__1, "f_ckcov__", (ftnlen)1892)], &
			tmpwin[(i__3 = j + 5) < 10006 && 0 <= i__3 ? i__3 : 
			s_rnge("tmpwin", i__3, "f_ckcov__", (ftnlen)1892)], &
			et);
		tmpwin[(i__1 = j + 5) < 10006 && 0 <= i__1 ? i__1 : s_rnge(
			"tmpwin", i__1, "f_ckcov__", (ftnlen)1893)] = et;
	    }
	    if (l == 2) {

/*              Insert an interval into COVER.  This same interval */
/*              must be added to each window containing expected */
/*              coverage. */

		wninsd_(&c_b393, &c_b394, cover);
		chckxc_(&c_false, " ", ok, (ftnlen)1);

/*              The same interval is expected to appear in the output. */

		wninsd_(&c_b393, &c_b394, tmpwin);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
	    }
	    ckcov_("ckcov.bc", &inst[(i__2 = i__ - 1) < 5 && 0 <= i__2 ? i__2 
		    : s_rnge("inst", i__2, "f_ckcov__", (ftnlen)1915)], &
		    c_false, "INTERVAL", &c_b404, "TDB", cover, (ftnlen)8, (
		    ftnlen)8, (ftnlen)3);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Check cardinality of coverage window. */

	    i__2 = cardd_(cover);
	    i__1 = cardd_(tmpwin);
	    chcksi_("CARDD(COVER)", &i__2, "=", &i__1, &c__0, ok, (ftnlen)12, 
		    (ftnlen)1);

/*           Check coverage window. */

	    i__2 = cardd_(tmpwin);
	    chckad_("COVER", &cover[6], "=", &tmpwin[6], &i__2, &c_b404, ok, (
		    ftnlen)5, (ftnlen)1);
	}
	for (i__ = 1; i__ <= 5; ++i__) {

/* --- Case: ------------------------------------------------------ */

	    s_copy(title, "INST: #;  LEVEL: INTERVAL  NEEDAV: FALSE; TIMSYS:"
		    " TDB; TOL: 1.D0; COVER: #.", (ftnlen)240, (ftnlen)75);
	    repmi_(title, "#", &i__, title, (ftnlen)240, (ftnlen)1, (ftnlen)
		    240);
	    repmc_(title, "#", cvstat, title, (ftnlen)240, (ftnlen)1, (ftnlen)
		    80, (ftnlen)240);
	    tcase_(title, (ftnlen)240);

/*           Initialize COVER. */

	    ssized_(&c__10000, cover);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Adjust our expected result window by TOL. */

	    copyd_(&xcvint[(i__2 = i__ * 10006 - 10006) < 50030 && 0 <= i__2 ?
		     i__2 : s_rnge("xcvint", i__2, "f_ckcov__", (ftnlen)1958)]
		    , tmpwin);
	    tol = 1.;
	    wnexpd_(&tol, &tol, tmpwin);

/*           Make sure the window doesn't start with a negative tick */
/*           value. */

	    tmpwin[6] = max(tmpwin[6],0.);

/*           Convert the expected window to TDB. */

	    i__2 = cardd_(tmpwin);
	    for (j = 1; j <= i__2; ++j) {
		sct2e_(&clkid[(i__1 = i__ - 1) < 5 && 0 <= i__1 ? i__1 : 
			s_rnge("clkid", i__1, "f_ckcov__", (ftnlen)1975)], &
			tmpwin[(i__3 = j + 5) < 10006 && 0 <= i__3 ? i__3 : 
			s_rnge("tmpwin", i__3, "f_ckcov__", (ftnlen)1975)], &
			et);
		tmpwin[(i__1 = j + 5) < 10006 && 0 <= i__1 ? i__1 : s_rnge(
			"tmpwin", i__1, "f_ckcov__", (ftnlen)1976)] = et;
	    }
	    if (l == 2) {

/*              Insert an interval into COVER.  This same interval */
/*              must be added to each window containing expected */
/*              coverage. */

		wninsd_(&c_b393, &c_b394, cover);
		chckxc_(&c_false, " ", ok, (ftnlen)1);

/*              The same interval is expected to appear in the output. */

		wninsd_(&c_b393, &c_b394, tmpwin);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
	    }
	    ckcov_("ckcov.bc", &inst[(i__2 = i__ - 1) < 5 && 0 <= i__2 ? i__2 
		    : s_rnge("inst", i__2, "f_ckcov__", (ftnlen)1998)], &
		    c_false, "INTERVAL", &c_b541, "TDB", cover, (ftnlen)8, (
		    ftnlen)8, (ftnlen)3);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Check cardinality of coverage window. */

	    i__2 = cardd_(cover);
	    i__1 = cardd_(tmpwin);
	    chcksi_("CARDD(COVER)", &i__2, "=", &i__1, &c__0, ok, (ftnlen)12, 
		    (ftnlen)1);

/*           Check coverage window. */

	    i__2 = cardd_(tmpwin);
	    chckad_("COVER", &cover[6], "=", &tmpwin[6], &i__2, &c_b404, ok, (
		    ftnlen)5, (ftnlen)1);
	}
    }

/*     Error cases: */


/* --- Case: ------------------------------------------------------ */

    tcase_("Try to find coverage using time system UTC.", (ftnlen)43);
    ckcov_("ckcov.bc", &inst[1], &c_false, "SEGMENT", &c_b404, "UTC", cover, (
	    ftnlen)8, (ftnlen)7, (ftnlen)3);
    chckxc_(&c_true, "SPICE(NOTSUPPORTED)", ok, (ftnlen)19);

/* --- Case: ------------------------------------------------------ */

    tcase_("Try to find coverage using negative tolerance.", (ftnlen)46);
    ckcov_("ckcov.bc", &inst[1], &c_false, "SEGMENT", &c_b731, "TDB", cover, (
	    ftnlen)8, (ftnlen)7, (ftnlen)3);
    chckxc_(&c_true, "SPICE(VALUEOUTOFRANGE)", ok, (ftnlen)22);

/* --- Case: ------------------------------------------------------ */

    tcase_("Try to find coverage using level \"file\".", (ftnlen)40);
    ckcov_("ckcov.bc", &inst[1], &c_false, "FILE", &c_b404, "TDB", cover, (
	    ftnlen)8, (ftnlen)4, (ftnlen)3);
    chckxc_(&c_true, "SPICE(INVALIDOPTION)", ok, (ftnlen)20);

/* --- Case: ------------------------------------------------------ */

    tcase_("Try to find coverage for a transfer CK.", (ftnlen)39);
    txtopn_("ckcov.xc", &xunit, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    dafbt_("ckcov.bc", &xunit, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    cl__1.cerr = 0;
    cl__1.cunit = xunit;
    cl__1.csta = 0;
    f_clos(&cl__1);
    ckcov_("ckcov.xc", inst, &c_false, "SEGMENT", &c_b404, "SCLK", cover, (
	    ftnlen)8, (ftnlen)7, (ftnlen)4);
    chckxc_(&c_true, "SPICE(INVALIDFORMAT)", ok, (ftnlen)20);

/* --- Case: ------------------------------------------------------ */

    tcase_("Try to find coverage for an SPK.", (ftnlen)32);
    tstspk_("ckcov.bsp", &c_false, &handle, (ftnlen)9);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    ckcov_("ckcov.bsp", inst, &c_false, "SEGMENT", &c_b404, "SCLK", cover, (
	    ftnlen)9, (ftnlen)7, (ftnlen)4);
    chckxc_(&c_true, "SPICE(INVALIDFILETYPE)", ok, (ftnlen)22);

/* --- Case: ------------------------------------------------------ */

    tcase_("Try to find coverage for an EK.", (ftnlen)31);
    tstek_("ckcov.bes", &c__1, &c__20, &c_false, &handle, (ftnlen)9);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    ckcov_("ckcov.bes", inst, &c_false, "SEGMENT", &c_b404, "SCLK", cover, (
	    ftnlen)9, (ftnlen)7, (ftnlen)4);
    chckxc_(&c_true, "SPICE(INVALIDARCHTYPE)", ok, (ftnlen)22);
/* ****************************************************** */
/* ****************************************************** */
/* ****************************************************** */
/*     CKOBJ tests */
/* ****************************************************** */
/* ****************************************************** */
/* ****************************************************** */

/* --- Case: ------------------------------------------------------ */

    tcase_("Find objects in our test CK.", (ftnlen)28);
    ssizei_(&c__5, ids);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    ssizei_(&c__5, xids);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    for (i__ = 1; i__ <= 5; ++i__) {
	insrti_(&inst[(i__2 = i__ - 1) < 5 && 0 <= i__2 ? i__2 : s_rnge("inst"
		, i__2, "f_ckcov__", (ftnlen)2127)], xids);
    }
    ckobj_("ckcov.bc", ids, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check cardinality of object set. */

    i__2 = cardi_(ids);
    i__1 = cardi_(xids);
    chcksi_("CARDI(IDS)", &i__2, "=", &i__1, &c__0, ok, (ftnlen)10, (ftnlen)1)
	    ;

/*     Check object set. */

    i__2 = cardi_(xids);
    chckai_("IDS", &ids[6], "=", &xids[6], &i__2, ok, (ftnlen)3, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Find objects in our test CK.  Start with non-empty ID set.", (
	    ftnlen)58);
    ssizei_(&c__6, ids);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    ssizei_(&c__6, xids);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    insrti_(&c_b807, xids);
    for (i__ = 1; i__ <= 5; ++i__) {
	insrti_(&inst[(i__2 = i__ - 1) < 5 && 0 <= i__2 ? i__2 : s_rnge("inst"
		, i__2, "f_ckcov__", (ftnlen)2162)], xids);
    }
    insrti_(&c_b807, ids);
    ckobj_("ckcov.bc", ids, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check cardinality of object set. */

    i__2 = cardi_(ids);
    i__1 = cardi_(xids);
    chcksi_("CARDI(IDS)", &i__2, "=", &i__1, &c__0, ok, (ftnlen)10, (ftnlen)1)
	    ;

/*     Check object set. */

    i__2 = cardi_(xids);
    chckai_("IDS", &ids[6], "=", &xids[6], &i__2, ok, (ftnlen)3, (ftnlen)1);

/*     Error cases: */


/* --- Case: ------------------------------------------------------ */

    tcase_("Try to find objects for a transfer CK.", (ftnlen)38);

/*     Initialize the IDS set. */

    ssizei_(&c__5, ids);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    ckobj_("ckcov.xc", ids, (ftnlen)8);
    chckxc_(&c_true, "SPICE(INVALIDFORMAT)", ok, (ftnlen)20);

/* --- Case: ------------------------------------------------------ */

    tcase_("Try to find objects for an SPK.", (ftnlen)31);
    ckobj_("ckcov.bsp", ids, (ftnlen)9);
    chckxc_(&c_true, "SPICE(INVALIDFILETYPE)", ok, (ftnlen)22);

/* --- Case: ------------------------------------------------------ */

    tcase_("Try to find objects for an EK.", (ftnlen)30);
    ckobj_("ckcov.bes", ids, (ftnlen)9);
    chckxc_(&c_true, "SPICE(INVALIDARCHTYPE)", ok, (ftnlen)22);

/*     Clean up. */

    delfil_("ckcov.bc", (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    delfil_("ckcov.xc", (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    delfil_("ckcov.bsp", (ftnlen)9);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    delfil_("ckcov.bes", (ftnlen)9);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_success__(ok);
    return 0;
} /* f_ckcov__ */

