/* f_locati.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__10 = 10;
static logical c_false = FALSE_;
static integer c__0 = 0;
static logical c_true = TRUE_;

/* $Procedure      F_LOCATI ( Family of tests for LOCATI ) */
/* Subroutine */ int f_locati__(logical *ok)
{
    /* System generated locals */
    integer i__1;

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    integer head, tail, idsz, pool1[32]	/* was [2][16] */, pool2[32]	/* 
	    was [2][16] */, list1[10]	/* was [1][10] */, list2[20]	/* 
	    was [2][10] */, list3[30]	/* was [3][10] */, pool3[32]	/* 
	    was [2][16] */, i__, j;
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    extern integer lnkhl_(integer *, integer *), lnktl_(integer *, integer *);
    extern /* Subroutine */ int topen_(char *, ftnlen), t_success__(logical *)
	    , chckai_(char *, integer *, char *, integer *, integer *, 
	    logical *, ftnlen, ftnlen);
    integer at;
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     chcksi_(char *, integer *, char *, integer *, integer *, logical 
	    *, ftnlen, ftnlen), chcksl_(char *, logical *, logical *, logical 
	    *, ftnlen), locati_(integer *, integer *, integer *, integer *, 
	    integer *, logical *), lnkini_(integer *, integer *);
    integer id1, id2[2], id3[3];
    logical presnt;

/* $ Abstract */

/*     This routine exercises the utility routine LOCATI. */

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

/* -& */

/*     SPICELIB Functions */


/*     Local Variables */


/*     Begin every test family with an open call. */

    topen_("F_LOCATI", (ftnlen)8);
    lnkini_(&c__10, pool1);
    lnkini_(&c__10, pool2);
    lnkini_(&c__10, pool3);
    tcase_("Make sure that the node returned by LOCATI is always the head of"
	    " a list. 1-D case", (ftnlen)81);
    idsz = 1;
    for (i__ = 1; i__ <= 10; ++i__) {
	j = i__;
	id1 = i__;
	locati_(&id1, &idsz, list1, pool1, &at, &presnt);
	head = lnkhl_(&at, pool1);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("PRESNT", &presnt, &c_false, ok, (ftnlen)6);
	chcksi_("AT", &at, "=", &j, &c__0, ok, (ftnlen)2, (ftnlen)1);
	chcksi_("HEAD", &head, "=", &at, &c__0, ok, (ftnlen)4, (ftnlen)1);
	chcksi_("LIST1", &list1[(i__1 = at - 1) < 10 && 0 <= i__1 ? i__1 : 
		s_rnge("list1", i__1, "f_locati__", (ftnlen)103)], "=", &id1, 
		&c__0, ok, (ftnlen)5, (ftnlen)1);
    }

/*        Make sure that a new ID can be added when the LIST is */
/*        full. */

    id1 = 12;
    tail = lnktl_(&at, pool1);
    locati_(&id1, &idsz, list1, pool1, &at, &presnt);
    head = lnkhl_(&at, pool1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("PRESNT", &presnt, &c_false, ok, (ftnlen)6);
    chcksi_("HEAD", &head, "=", &at, &c__0, ok, (ftnlen)4, (ftnlen)1);
    chcksi_("TAIL", &tail, "=", &head, &c__0, ok, (ftnlen)4, (ftnlen)1);
    chcksi_("LIST1", &list1[(i__1 = at - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge(
	    "list1", i__1, "f_locati__", (ftnlen)122)], "=", &id1, &c__0, ok, 
	    (ftnlen)5, (ftnlen)1);

/*        Make sure that we can find and ID that is in the list. */

    id1 = 5;
    locati_(&id1, &idsz, list1, pool1, &at, &presnt);
    chcksi_("HEAD", &head, "!=", &at, &c__0, ok, (ftnlen)4, (ftnlen)2);
    head = lnkhl_(&at, pool1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("PRESNT", &presnt, &c_true, ok, (ftnlen)6);
    chcksi_("HEAD", &head, "=", &at, &c__0, ok, (ftnlen)4, (ftnlen)1);
    chcksi_("LIST1", &list1[(i__1 = at - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge(
	    "list1", i__1, "f_locati__", (ftnlen)137)], "=", &id1, &c__0, ok, 
	    (ftnlen)5, (ftnlen)1);
    locati_(&id1, &idsz, list1, pool1, &at, &presnt);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("PRESNT", &presnt, &c_true, ok, (ftnlen)6);
    chcksi_("HEAD", &head, "=", &at, &c__0, ok, (ftnlen)4, (ftnlen)1);
    chcksi_("LIST1", &list1[(i__1 = at - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge(
	    "list1", i__1, "f_locati__", (ftnlen)147)], "=", &id1, &c__0, ok, 
	    (ftnlen)5, (ftnlen)1);
    tcase_("Make sure that the node returned by LOCATI is always the head of"
	    " a list. 2-D case", (ftnlen)81);
    idsz = 2;
    for (i__ = 1; i__ <= 10; ++i__) {
	j = i__;
	id2[0] = i__;
	id2[1] = i__;
	locati_(id2, &idsz, list2, pool2, &at, &presnt);
	head = lnkhl_(&at, pool2);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("PRESNT", &presnt, &c_false, ok, (ftnlen)6);
	chcksi_("AT", &at, "=", &j, &c__0, ok, (ftnlen)2, (ftnlen)1);
	chcksi_("HEAD", &head, "=", &at, &c__0, ok, (ftnlen)4, (ftnlen)1);
	chckai_("LIST2", &list2[(i__1 = (at << 1) - 2) < 20 && 0 <= i__1 ? 
		i__1 : s_rnge("list2", i__1, "f_locati__", (ftnlen)169)], 
		"=", id2, &idsz, ok, (ftnlen)5, (ftnlen)1);
    }

/*        Make sure that a new ID can be added when the LIST is */
/*        full. */

    id2[0] = 12;
    id2[1] = 12;
    tail = lnktl_(&at, pool2);
    locati_(id2, &idsz, list2, pool2, &at, &presnt);
    head = lnkhl_(&at, pool2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("PRESNT", &presnt, &c_false, ok, (ftnlen)6);
    chcksi_("HEAD", &head, "=", &at, &c__0, ok, (ftnlen)4, (ftnlen)1);
    chcksi_("TAIL", &tail, "=", &head, &c__0, ok, (ftnlen)4, (ftnlen)1);
    chckai_("LIST2", &list2[(i__1 = (at << 1) - 2) < 20 && 0 <= i__1 ? i__1 : 
	    s_rnge("list2", i__1, "f_locati__", (ftnlen)190)], "=", id2, &
	    idsz, ok, (ftnlen)5, (ftnlen)1);

/*        Make sure that we can find and ID that is in the list. */

    id2[0] = 5;
    id2[1] = 5;
    locati_(id2, &idsz, list2, pool2, &at, &presnt);
    chcksi_("HEAD", &head, "!=", &at, &c__0, ok, (ftnlen)4, (ftnlen)2);
    head = lnkhl_(&at, pool2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("PRESNT", &presnt, &c_true, ok, (ftnlen)6);
    chcksi_("HEAD", &head, "=", &at, &c__0, ok, (ftnlen)4, (ftnlen)1);
    chckai_("LIST2", &list2[(i__1 = (at << 1) - 2) < 20 && 0 <= i__1 ? i__1 : 
	    s_rnge("list2", i__1, "f_locati__", (ftnlen)208)], "=", id2, &
	    idsz, ok, (ftnlen)5, (ftnlen)1);
    locati_(id2, &idsz, list2, pool2, &at, &presnt);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("PRESNT", &presnt, &c_true, ok, (ftnlen)6);
    chcksi_("HEAD", &head, "=", &at, &c__0, ok, (ftnlen)4, (ftnlen)1);
    chckai_("LIST2", &list2[(i__1 = (at << 1) - 2) < 20 && 0 <= i__1 ? i__1 : 
	    s_rnge("list2", i__1, "f_locati__", (ftnlen)217)], "=", id2, &
	    idsz, ok, (ftnlen)5, (ftnlen)1);
    tcase_("Make sure that the node returned by LOCATI is always the head of"
	    " a list. 3-D case", (ftnlen)81);
    idsz = 3;
    for (i__ = 1; i__ <= 10; ++i__) {
	j = i__;
	id3[0] = i__;
	id3[1] = i__;
	id3[2] = i__;
	locati_(id3, &idsz, list3, pool3, &at, &presnt);
	head = lnkhl_(&at, pool3);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("PRESNT", &presnt, &c_false, ok, (ftnlen)6);
	chcksi_("AT", &at, "=", &j, &c__0, ok, (ftnlen)2, (ftnlen)1);
	chcksi_("HEAD", &head, "=", &at, &c__0, ok, (ftnlen)4, (ftnlen)1);
	chckai_("LIST3", &list3[(i__1 = at * 3 - 3) < 30 && 0 <= i__1 ? i__1 :
		 s_rnge("list3", i__1, "f_locati__", (ftnlen)242)], "=", id3, 
		&idsz, ok, (ftnlen)5, (ftnlen)1);
    }

/*        Make sure that a new ID can be added when the LIST is */
/*        full. */

    id3[0] = 12;
    id3[1] = 12;
    id3[2] = 12;
    tail = lnktl_(&at, pool3);
    locati_(id3, &idsz, list3, pool3, &at, &presnt);
    head = lnkhl_(&at, pool3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("PRESNT", &presnt, &c_false, ok, (ftnlen)6);
    chcksi_("HEAD", &head, "=", &at, &c__0, ok, (ftnlen)4, (ftnlen)1);
    chcksi_("TAIL", &tail, "=", &head, &c__0, ok, (ftnlen)4, (ftnlen)1);
    chckai_("LIST3", &list3[(i__1 = at * 3 - 3) < 30 && 0 <= i__1 ? i__1 : 
	    s_rnge("list3", i__1, "f_locati__", (ftnlen)264)], "=", id3, &
	    idsz, ok, (ftnlen)5, (ftnlen)1);

/*        Make sure that we can find and ID that is in the list. */

    id3[0] = 5;
    id3[1] = 5;
    id3[2] = 5;
    locati_(id3, &idsz, list3, pool3, &at, &presnt);
    chcksi_("HEAD", &head, "!=", &at, &c__0, ok, (ftnlen)4, (ftnlen)2);
    head = lnkhl_(&at, pool3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("PRESNT", &presnt, &c_true, ok, (ftnlen)6);
    chcksi_("HEAD", &head, "=", &at, &c__0, ok, (ftnlen)4, (ftnlen)1);
    chckai_("LIST3", &list3[(i__1 = at * 3 - 3) < 30 && 0 <= i__1 ? i__1 : 
	    s_rnge("list3", i__1, "f_locati__", (ftnlen)282)], "=", id3, &
	    idsz, ok, (ftnlen)5, (ftnlen)1);
    locati_(id3, &idsz, list3, pool3, &at, &presnt);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("PRESNT", &presnt, &c_true, ok, (ftnlen)6);
    chcksi_("HEAD", &head, "=", &at, &c__0, ok, (ftnlen)4, (ftnlen)1);
    chckai_("LIST3", &list3[(i__1 = at * 3 - 3) < 30 && 0 <= i__1 ? i__1 : 
	    s_rnge("list3", i__1, "f_locati__", (ftnlen)292)], "=", id3, &
	    idsz, ok, (ftnlen)5, (ftnlen)1);
    t_success__(ok);
    return 0;
} /* f_locati__ */

