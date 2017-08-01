/* f_sgmeta.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__2 = 2;
static integer c__6 = 6;
static integer c__3 = 3;
static integer c__17 = 17;
static integer c__1 = 1;
static integer c__19 = 19;
static integer c__5 = 5;
static logical c_false = FALSE_;
static logical c_true = TRUE_;
static integer c__0 = 0;
static integer c__18 = 18;
static integer c__16 = 16;
static doublereal c_b85 = 0.;
static integer c__8 = 8;
static integer c__11 = 11;
static integer c__13 = 13;
static integer c__4 = 4;
static integer c__7 = 7;
static integer c__9 = 9;
static integer c__10 = 10;
static integer c__12 = 12;
static integer c__14 = 14;
static integer c__15 = 15;

/* $Procedure F_SGMETA ( SGMETA Test Family ) */
/* Subroutine */ int f_sgmeta__(logical *ok)
{
    /* System generated locals */
    integer i__1;

    /* Local variables */
    integer i__;
    extern /* Subroutine */ int dafgs_(doublereal *);
    integer cases[3];
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    doublereal descr[6];
    extern /* Subroutine */ int dafus_(doublereal *, integer *, integer *, 
	    doublereal *, integer *);
    logical found;
    integer value;
    extern /* Subroutine */ int topen_(char *, ftnlen);
    integer handl1, handl2, handl3, handl4, handl5;
    extern /* Subroutine */ int t_success__(logical *);
    doublereal value1;
    integer dafadd;
    doublereal dc[2];
    integer ic[6];
    extern /* Subroutine */ int daffna_(logical *), daffpa_(logical *), 
	    dafbfs_(integer *), dafwda_(integer *, integer *, integer *, 
	    doublereal *), chckxc_(logical *, char *, logical *, ftnlen), 
	    chcksi_(char *, integer *, char *, integer *, integer *, logical *
	    , ftnlen, ftnlen), sgctdf_(char *, integer *, integer *, 
	    doublereal *, integer *, integer *, integer *, ftnlen), kilfil_(
	    char *, ftnlen), sgmeta_(integer *, doublereal *, integer *, 
	    integer *);

/* $ Abstract */

/*    Test family to exercise the logic and code in the SGMETA routine. */

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

/*     TEST FAMILY */

/* $ Declarations */
/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  -------------------------------------------------- */
/*     OK         O   logical indicating test status. */

/* $ Detailed_Input */

/*     None. */

/* $ Detailed_Output */

/*     OK         is a logical that indicates the test status to the */
/*                caller. */

/* $ Parameters */

/*     None. */

/* $ Files */

/*     None. */

/* $ Exceptions */

/*     This routine does not generate any errors.  Routines in its call */
/*     tree may generate errors that are either intentional and trapped */
/*     or unintentional and need reporting.  The test family utilities */
/*     manage this. */

/* $ Particulars */

/*     This routine exercises SGMETA's logic and its possible error */
/*     conditions. */

/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     F.S. Turner     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    F_SGMETA Version 1.0.0, 16-JUN-1999 (FST) */


/* -& */

/*     Local Parameters */


/* $ Abstract */

/*     Parameter declarations for the generic segments subroutines. */

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

/*      DAF Required Reading */

/* $ Keywords */

/*       GENERIC SEGMENTS */

/* $ Particulars */

/*     This include file contains the parameters used by the generic */
/*     segments subroutines, SGxxxx. A generic segment is a */
/*     generalization of a DAF array which places a particular structure */
/*     on the data contained in the array, as described below. */

/*     This file defines the mnemonics that are used for the index types */
/*     allowed in generic segments as well as mnemonics for the meta data */
/*     items which are used to describe a generic segment. */

/*     A DAF generic segment contains several logical data partitions: */

/*        1) A partition for constant values to be associated with each */
/*           data packet in the segment. */

/*        2) A partition for the data packets. */

/*        3) A partition for reference values. */

/*        4) A partition for a packet directory, if the segment contains */
/*           variable sized packets. */

/*        5) A partition for a reference value directory. */

/*        6) A reserved partition that is not currently used. This */
/*           partition is only for the use of the NAIF group at the Jet */
/*           Propulsion Laboratory (JPL). */

/*        7) A partition for the meta data which describes the locations */
/*           and sizes of other partitions as well as providing some */
/*           additional descriptive information about the generic */
/*           segment. */

/*                 +============================+ */
/*                 |         Constants          | */
/*                 +============================+ */
/*                 |          Packet 1          | */
/*                 |----------------------------| */
/*                 |          Packet 2          | */
/*                 |----------------------------| */
/*                 |              .             | */
/*                 |              .             | */
/*                 |              .             | */
/*                 |----------------------------| */
/*                 |          Packet N          | */
/*                 +============================+ */
/*                 |      Reference Values      | */
/*                 +============================+ */
/*                 |      Packet Directory      | */
/*                 +============================+ */
/*                 |    Reference  Directory    | */
/*                 +============================+ */
/*                 |       Reserved  Area       | */
/*                 +============================+ */
/*                 |     Segment Meta Data      | */
/*                 +----------------------------+ */

/*     Only the placement of the meta data at the end of a generic */
/*     segment is required. The other data partitions may occur in any */
/*     order in the generic segment because the meta data will contain */
/*     pointers to their appropriate locations within the generic */
/*     segment. */

/*     The meta data for a generic segment should only be obtained */
/*     through use of the subroutine SGMETA. The meta data should not be */
/*     written through any mechanism other than the ending of a generic */
/*     segment begun by SGBWFS or SGBWVS using SGWES. */

/* $ Restrictions */

/*     1) If new reference index types are added, the new type(s) should */
/*        be defined to be the consecutive integer(s) after the last */
/*        defined reference index type used. In this way a value for */
/*        the maximum allowed index type may be maintained. This value */
/*        must also be updated if new reference index types are added. */

/*     2) If new meta data items are needed, mnemonics for them must be */
/*        added to the end of the current list of mnemonics and before */
/*        the NMETA mnemonic. In this way compatibility with files having */
/*        a different, but smaller, number of meta data items may be */
/*        maintained. See the description and example below. */

/* $ Author_and_Institution */

/*     N.J. Bachman      (JPL) */
/*     K.R. Gehringer    (JPL) */
/*     W.L. Taber        (JPL) */
/*     F.S. Turner       (JPL) */

/* $ Literature_References */

/*     Generic Segments Required Reading. */
/*     DAF Required Reading. */

/* $ Version */

/* -    SPICELIB Version 1.1.1, 28-JAN-2004 (NJB) */

/*        Header update: equations for comptutations of packet indices */
/*        for the cases of index types 0 and 1 were corrected. */

/* -    SPICELIB Version 1.1.0, 25-09-98 (FST) */

/*        Added parameter MNMETA, the minimum number of meta data items */
/*        that must be present in a generic DAF segment. */

/* -    SPICELIB Version 1.0.0, 04-03-95 (KRG) (WLT) */

/* -& */

/*     Mnemonics for the type of reference value index. */

/*     Two forms of indexing are provided: */

/*        1) An implicit form of indexing based on using two values, a */
/*           starting value, which will have an index of 1, and a step */
/*           size between reference values, which are used to compute an */
/*           index and a reference value associated with a specified key */
/*           value. See the descriptions of the implicit types below for */
/*           the particular formula used in each case. */

/*        2) An explicit form of indexing based on a reference value for */
/*           each data packet. */


/*     Reference Index Type 0 */
/*     ---------------------- */

/*     Implied index. The index and reference value of a data packet */
/*     associated with a specified key value are computed from the two */
/*     generic segment reference values using the formula below. The two */
/*     generic segment reference values, REF(1) and REF(2), represent, */
/*     respectively, a starting value and a step size between reference */
/*     values. The index of the data packet associated with a key value */
/*     of VALUE is given by: */

/*                          /    VALUE - REF(1)    \ */
/*        INDEX = 1  +  INT | -------------------- | */
/*                          \        REF(2)        / */

/*     and the reference value associated with VALUE is given by: */

/*        REFVAL = REF(1) + DBLE (INDEX-1) * REF(2) */


/*     Reference Index Type 1 */
/*     ---------------------- */

/*     Implied index. The index and reference value of a data packet */
/*     associated with a specified key value are computed from the two */
/*     generic segment reference values using the formula below. The two */
/*     generic segment reference values, REF(1) and REF(2), represent, */
/*     respectively, a starting value and a step size between reference */
/*     values. The index of the data packet associated with a key value */
/*     of VALUE is given by: */

/*                          /          VALUE - REF(1)    \ */
/*        INDEX = 1  +  INT | 0.5 + -------------------- | */
/*                          \              REF(2)        / */


/*     and the reference value associated with VALUE is given by: */

/*        REFVAL = REF(1) + DBLE (INDEX-1) * REF(2) */

/*     We get the larger index in the event that VALUE is halfway between */
/*     X(I) and X(I+1), where X(I) = BUFFER(1) + DBLE (I-1) * REFDAT(2). */


/*     Reference Index Type 2 */
/*     ---------------------- */

/*     Explicit index. In this case the number of packets must equal the */
/*     number of reference values. The index of the packet associated */
/*     with a key value of VALUE is the index of the last reference item */
/*     that is strictly less than VALUE. The reference values must be in */
/*     ascending order, REF(I) < REF(I+1). */


/*     Reference Index Type 3 */
/*     ---------------------- */

/*     Explicit index. In this case the number of packets must equal the */
/*     number of reference values. The index of the packet associated */
/*     with a key value of VALUE is the index of the last reference item */
/*     that is less than or equal to VALUE. The reference values must be */
/*     in ascending order, REF(I) < REF(I+1). */


/*     Reference Index Type 4 */
/*     ---------------------- */

/*     Explicit index. In this case the number of packets must equal the */
/*     number of reference values. The index of the packet associated */
/*     with a key value of VALUE is the index of the reference item */
/*     that is closest to the value of VALUE. In the event of a "tie" */
/*     the larger index is selected. The reference values must be in */
/*     ascending order, REF(I) < REF(I+1). */


/*     These parameters define the valid range for the index types. An */
/*     index type code, MYTYPE, for a generic segment must satisfy the */
/*     relation MNIDXT <= MYTYPE <= MXIDXT. */


/*     The following meta data items will appear in all generic segments. */
/*     Other meta data items may be added if a need arises. */

/*       1)  CONBAS  Base Address of the constants in a generic segment. */

/*       2)  NCON    Number of constants in a generic segment. */

/*       3)  RDRBAS  Base Address of the reference directory for a */
/*                   generic segment. */

/*       4)  NRDR    Number of items in the reference directory of a */
/*                   generic segment. */

/*       5)  RDRTYP  Type of the reference directory 0, 1, 2 ... for a */
/*                   generic segment. */

/*       6)  REFBAS  Base Address of the reference items for a generic */
/*                   segment. */

/*       7)  NREF    Number of reference items in a generic segment. */

/*       8)  PDRBAS  Base Address of the Packet Directory for a generic */
/*                   segment. */

/*       9)  NPDR    Number of items in the Packet Directory of a generic */
/*                   segment. */

/*      10)  PDRTYP  Type of the packet directory 0, 1, ... for a generic */
/*                   segment. */

/*      11)  PKTBAS  Base Address of the Packets for a generic segment. */

/*      12)  NPKT    Number of Packets in a generic segment. */

/*      13)  RSVBAS  Base Address of the Reserved Area in a generic */
/*                   segment. */

/*      14)  NRSV    Number of items in the reserved area of a generic */
/*                   segment. */

/*      15)  PKTSZ   Size of the packets for a segment with fixed width */
/*                   data packets or the size of the largest packet for a */
/*                   segment with variable width data packets. */

/*      16)  PKTOFF  Offset of the packet data from the start of a packet */
/*                   record. Each data packet is placed into a packet */
/*                   record which may have some bookkeeping information */
/*                   prepended to the data for use by the generic */
/*                   segments software. */

/*      17)  NMETA   Number of meta data items in a generic segment. */

/*     Meta Data Item  1 */
/*     ----------------- */


/*     Meta Data Item  2 */
/*     ----------------- */


/*     Meta Data Item  3 */
/*     ----------------- */


/*     Meta Data Item  4 */
/*     ----------------- */


/*     Meta Data Item  5 */
/*     ----------------- */


/*     Meta Data Item  6 */
/*     ----------------- */


/*     Meta Data Item  7 */
/*     ----------------- */


/*     Meta Data Item  8 */
/*     ----------------- */


/*     Meta Data Item  9 */
/*     ----------------- */


/*     Meta Data Item 10 */
/*     ----------------- */


/*     Meta Data Item 11 */
/*     ----------------- */


/*     Meta Data Item 12 */
/*     ----------------- */


/*     Meta Data Item 13 */
/*     ----------------- */


/*     Meta Data Item 14 */
/*     ----------------- */


/*     Meta Data Item 15 */
/*     ----------------- */


/*     Meta Data Item 16 */
/*     ----------------- */


/*     If new meta data items are to be added to this list, they should */
/*     be added above this comment block as described below. */

/*        INTEGER               NEW1 */
/*        PARAMETER           ( NEW1   = PKTOFF + 1 ) */

/*        INTEGER               NEW2 */
/*        PARAMETER           ( NEW2   = NEW1   + 1 ) */

/*        INTEGER               NEWEST */
/*        PARAMETER           ( NEWEST = NEW2   + 1 ) */

/*     and then the value of NMETA must be changed as well to be: */

/*        INTEGER               NMETA */
/*        PARAMETER           ( NMETA  = NEWEST + 1 ) */

/*     Meta Data Item 17 */
/*     ----------------- */


/*     Maximum number of meta data items. This is always set equal to */
/*     NMETA. */


/*     Minimum number of meta data items that must be present in a DAF */
/*     generic segment.  This number is to remain fixed even if more */
/*     meta data items are added for compatibility with old DAF files. */


/*     Local Variables */


/*     Start the test family with an open call. */

    topen_("F_SGMETA", (ftnlen)8);
    tcase_("Generic segment test DAF file creation", (ftnlen)38);

/*     Create the first test DAF file. */

    cases[0] = 14;
    cases[1] = 15;
    cases[2] = 17;
    value1 = 1.;

/*     The first file will contain the segments we'll use to test */
/*     the undersized meta data case, and the two nominal cases. */

    sgctdf_("sample1a.daf", &c__2, &c__6, &value1, cases, &c__3, &handl1, (
	    ftnlen)12);

/*     The second file will contain one segment of size 17.  We will */
/*     use it to verify that the meta data sequence SGMETA is extracting */
/*     is correct. */

    sgctdf_("sample2a.daf", &c__2, &c__6, &value1, &c__17, &c__1, &handl2, (
	    ftnlen)12);

/*     The third file will be used to check the alignment in the */
/*     case where the number of meta data items exceeds MXMETA. */

    sgctdf_("sample3a.daf", &c__2, &c__6, &value1, &c__19, &c__1, &handl3, (
	    ftnlen)12);

/*     This fourth and fifth file will be used to exercise the odd and */
/*     even NI extraction code respectively. */

    cases[0] = 17;
    cases[1] = 17;
    sgctdf_("sample4a.daf", &c__2, &c__5, &value1, cases, &c__2, &handl4, (
	    ftnlen)12);
    sgctdf_("sample5a.daf", &c__2, &c__6, &value1, cases, &c__2, &handl5, (
	    ftnlen)12);

/*     No exceptions should be signaled. Check to make certain. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Test Case: */

/*        Since the first segment in the sample1a.daf is undersized by */
/*        meta data standards MNMETA, investigate SGMETA's capabilities */
/*        for signaling this error. */

    tcase_("Check insufficient meta data error", (ftnlen)34);
    dafbfs_(&handl1);
    daffna_(&found);
    dafgs_(descr);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    sgmeta_(&handl1, descr, &c__17, &value);
    chckxc_(&c_true, "SPICE(INVALIDMETADATA)", ok, (ftnlen)22);

/*     Test Case: */

/*        Now force the unbuffered error where the requested meta data */
/*        is out of scope, first the negative mnemonic. */

    tcase_("Unbuffered, non-positive mnemonic request", (ftnlen)41);
    daffna_(&found);
    dafgs_(descr);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    sgmeta_(&handl1, descr, &c__0, &value);
    chckxc_(&c_true, "SPICE(UNKNOWNMETAITEM)", ok, (ftnlen)22);

/*     Test Case: */

/*        Now force the same unbuffered error where the requested meta */
/*        data is out of scope, because mnemonic exceeds MXMETA. */

/*     First we need to make certain we end up with the unbuffered */
/*     case again.  To force this, request data from another segment. */

    tcase_("Unbuffered, in excess of MXMETA mnemonic request", (ftnlen)48);
    daffna_(&found);
    dafgs_(descr);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    sgmeta_(&handl1, descr, &c__17, &value);

/*     Make certain an exception has not been signaled. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Now seek back, re-extract the descriptor. */

    daffpa_(&found);
    dafgs_(descr);
    sgmeta_(&handl1, descr, &c__18, &value);
    chckxc_(&c_true, "SPICE(UNKNOWNMETAITEM)", ok, (ftnlen)22);

/*     Test Case: */

/*        Now we want to repeat the tests for the buffered case. */
/*        First buffered, non-positive mnemonics. */

    tcase_("Buffered, non-positive mnemonic request", (ftnlen)39);
    sgmeta_(&handl1, descr, &c__0, &value);
    chckxc_(&c_true, "SPICE(UNKNOWNMETAITEM)", ok, (ftnlen)22);

/*     Test Case: */

/*        And the mnemonics in excess of MXMETA. */

    tcase_("Buffered, in excess of MXMETA mnemonic request", (ftnlen)46);
    sgmeta_(&handl1, descr, &c__18, &value);
    chckxc_(&c_true, "SPICE(UNKNOWNMETAITEM)", ok, (ftnlen)22);

/*     Test Case: */

/*        Now we need to verify that SGMETA is extracting the proper */
/*        information from the file. */

    tcase_("Nominal meta data sequence alignment test", (ftnlen)41);
    dafbfs_(&handl2);
    daffna_(&found);
    dafgs_(descr);
    dafus_(descr, &c__2, &c__6, dc, ic);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the first meta data item, CONBAS.  It should return the */
/*     start address of the segment, since a value of 1 was placed */
/*     into the array. */

    sgmeta_(&handl2, descr, &c__1, &value);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("CONBAS", &value, "=", &ic[4], &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Now check the last meta data item before NMETA. */

    sgmeta_(&handl2, descr, &c__16, &value);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("PKTOFF", &value, "=", &c__1, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Finally check NMETA. */

    sgmeta_(&handl2, descr, &c__17, &value);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("NMETA", &value, "=", &c__17, &c__0, ok, (ftnlen)5, (ftnlen)1);

/*     Test Case: */

/*        Now we need to test alignment in the case where the number of */
/*        meta data items exceeds MXMETA.  We want to be certain that */
/*        SGMETA is capable of reading the meta data it is aware of. */

    tcase_("Extra meta data sequence alignment", (ftnlen)34);
    dafbfs_(&handl3);
    daffna_(&found);
    dafgs_(descr);
    dafus_(descr, &c__2, &c__6, dc, ic);

/*     Zero out the extra meta data components of which we are unaware. */
/*     Remember the segment looks like this: */

/*         _________ */
/*        |         |  IC(5)                Known META items, except */
/*        |         |                       NMETA, which comes at the */
/*        |_________|  IC(5) + MXMETA - 1   end of the segment. */
/*            ... */
/*         _________ */
/*        |_________|  IC(6)                NMETA */



    i__1 = ic[5] - 1;
    for (i__ = ic[4] + 16; i__ <= i__1; ++i__) {
	dafwda_(&handl3, &i__, &i__, &c_b85);
    }
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the first meta data item, CONBAS.  It should return the */
/*     start address of the segment, since a value of 1 was placed */
/*     into the array. */

    sgmeta_(&handl3, descr, &c__1, &value);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("CONBAS", &value, "=", &ic[4], &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Now check the last meta data item before NMETA. */

    sgmeta_(&handl3, descr, &c__16, &value);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("PKTOFF", &value, "=", &c__1, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Finally check NMETA. */

    sgmeta_(&handl3, descr, &c__17, &value);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("NMETA", &value, "=", &c__17, &c__0, ok, (ftnlen)5, (ftnlen)1);

/*     Test Case: */

/*        Check to see whether the segment address decomposition code */
/*        works properly for the unbuffered, even case. */

    tcase_("Unbuffered even NI, segment address decomposition", (ftnlen)49);
    dafbfs_(&handl5);
    daffna_(&found);
    dafgs_(descr);
    sgmeta_(&handl5, descr, &c__17, &value);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("NMETA", &value, "=", &c__17, &c__0, ok, (ftnlen)5, (ftnlen)1);

/*     Test Case: */

/*        Now check the buffered segment address decomposition code */
/*        for the even case. */

    tcase_("Buffered even NI, segment address decomposition", (ftnlen)47);
    daffna_(&found);
    dafgs_(descr);
    sgmeta_(&handl5, descr, &c__17, &value);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("NMETA", &value, "=", &c__17, &c__0, ok, (ftnlen)5, (ftnlen)1);

/*     Test Case: */

/*        Check the unbuffered odd segment address decomposition code. */

    tcase_("Unbuffered odd, segment address decomposition", (ftnlen)45);
    dafbfs_(&handl4);
    daffna_(&found);
    dafgs_(descr);
    sgmeta_(&handl4, descr, &c__17, &value);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("NMETA", &value, "=", &c__17, &c__0, ok, (ftnlen)5, (ftnlen)1);

/*     Test Case: */

/*        Now check the buffered odd segment address decomposition code. */

    daffna_(&found);
    dafgs_(descr);
    sgmeta_(&handl4, descr, &c__17, &value);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("NMETA", &value, "=", &c__17, &c__0, ok, (ftnlen)5, (ftnlen)1);
    dafus_(descr, &c__2, &c__6, dc, ic);
    dafadd = ic[3];

/*     Now check each of the meta data entries for correctness. */

    tcase_("CONBAS - value check", (ftnlen)20);
    sgmeta_(&handl4, descr, &c__1, &value);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("CONBAS", &value, "=", &dafadd, &c__0, ok, (ftnlen)6, (ftnlen)1);
    tcase_("REFBAS - value check", (ftnlen)20);
    sgmeta_(&handl4, descr, &c__6, &value);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("REFBAS", &value, "=", &dafadd, &c__0, ok, (ftnlen)6, (ftnlen)1);
    tcase_("RDRBAS - value check", (ftnlen)20);
    sgmeta_(&handl4, descr, &c__3, &value);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("RDRBAS", &value, "=", &dafadd, &c__0, ok, (ftnlen)6, (ftnlen)1);
    tcase_("PDRBAS - value check", (ftnlen)20);
    sgmeta_(&handl4, descr, &c__8, &value);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("PDRBAS", &value, "=", &dafadd, &c__0, ok, (ftnlen)6, (ftnlen)1);
    tcase_("PKTBAS - value check", (ftnlen)20);
    sgmeta_(&handl4, descr, &c__11, &value);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("PKTBAS", &value, "=", &dafadd, &c__0, ok, (ftnlen)6, (ftnlen)1);
    tcase_("RSVBAS - value check", (ftnlen)20);
    sgmeta_(&handl4, descr, &c__13, &value);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("RSVBAS", &value, "=", &dafadd, &c__0, ok, (ftnlen)6, (ftnlen)1);
    tcase_("NCON - value check", (ftnlen)18);
    sgmeta_(&handl4, descr, &c__2, &value);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    i__1 = (integer) value1;
    chcksi_("NCON", &value, "=", &i__1, &c__0, ok, (ftnlen)4, (ftnlen)1);
    tcase_("NRDR - value check", (ftnlen)18);
    sgmeta_(&handl4, descr, &c__4, &value);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    i__1 = (integer) value1;
    chcksi_("NRDR", &value, "=", &i__1, &c__0, ok, (ftnlen)4, (ftnlen)1);
    tcase_("RDRTYP - value check", (ftnlen)20);
    sgmeta_(&handl4, descr, &c__5, &value);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    i__1 = (integer) value1;
    chcksi_("RDRTYP", &value, "=", &i__1, &c__0, ok, (ftnlen)6, (ftnlen)1);
    tcase_("NREF - value check", (ftnlen)18);
    sgmeta_(&handl4, descr, &c__7, &value);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    i__1 = (integer) value1;
    chcksi_("NREF", &value, "=", &i__1, &c__0, ok, (ftnlen)4, (ftnlen)1);
    tcase_("NPDR - value check", (ftnlen)18);
    sgmeta_(&handl4, descr, &c__9, &value);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    i__1 = (integer) value1;
    chcksi_("NPDR", &value, "=", &i__1, &c__0, ok, (ftnlen)4, (ftnlen)1);
    tcase_("PDRTYP - value check", (ftnlen)20);
    sgmeta_(&handl4, descr, &c__10, &value);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    i__1 = (integer) value1;
    chcksi_("PDRTYP", &value, "=", &i__1, &c__0, ok, (ftnlen)6, (ftnlen)1);
    tcase_("NPKT - value check", (ftnlen)18);
    sgmeta_(&handl4, descr, &c__12, &value);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    i__1 = (integer) value1;
    chcksi_("NPKT", &value, "=", &i__1, &c__0, ok, (ftnlen)4, (ftnlen)1);
    tcase_("NRSV - value check", (ftnlen)18);
    sgmeta_(&handl4, descr, &c__14, &value);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    i__1 = (integer) value1;
    chcksi_("NRSV", &value, "=", &i__1, &c__0, ok, (ftnlen)4, (ftnlen)1);
    tcase_("PKTSZ - value check", (ftnlen)19);
    sgmeta_(&handl4, descr, &c__15, &value);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    i__1 = (integer) value1;
    chcksi_("PKTSZ", &value, "=", &i__1, &c__0, ok, (ftnlen)5, (ftnlen)1);
    tcase_("PKTOFF - value check", (ftnlen)20);
    sgmeta_(&handl4, descr, &c__16, &value);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    i__1 = (integer) value1;
    chcksi_("PKTOFF", &value, "=", &i__1, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Close out the test family. */

    t_success__(ok);

/*     Destroy the sample files. */

    kilfil_("sample1a.daf", (ftnlen)12);
    kilfil_("sample2a.daf", (ftnlen)12);
    kilfil_("sample3a.daf", (ftnlen)12);
    kilfil_("sample4a.daf", (ftnlen)12);
    kilfil_("sample5a.daf", (ftnlen)12);
    return 0;
} /* f_sgmeta__ */

