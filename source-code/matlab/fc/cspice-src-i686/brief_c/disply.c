/* disply.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__1 = 1;
static integer c__20000 = 20000;

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

/*     Display the summary information. */

/* Subroutine */ int disply_(char *fmtpic, logical *tdsp, logical *gdsp, 
	logical *obnam, integer *objlis, char *winsym, integer *winptr, 
	doublereal *winval, ftnlen fmtpic_len, ftnlen winsym_len)
{
    /* System generated locals */
    integer i__1, i__2, i__3, i__4;

    /* Builtin functions */
    integer s_cmp(char *, char *, ftnlen, ftnlen);
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    static char name__[64];
    static logical same;
    static char line[132];
    static integer nobj, objn[2], sobj, size;
    static char rest[132];
    static integer b, e, i__, j;
    extern integer cardc_(char *, ftnlen);
    static integer s;
    extern /* Subroutine */ int etcal_(doublereal *, char *, ftnlen);
    static char names[64*20006];
    static logical found, group;
    extern integer rtrim_(char *, ftnlen);
    static integer n1, n2;
    static char p1[8], p2[8];
    static integer start;
    static char header[132*2], wd[8];
    extern integer objact_(integer *);
    extern /* Subroutine */ int maknam_(integer *, integer *, logical *, char 
	    *, ftnlen), appndc_(char *, char *, ftnlen, ftnlen);
    static integer object[3], remain;
    extern /* Subroutine */ int objget_(integer *, integer *, integer *), 
	    objrem_(integer *, integer *), rmaini_(integer *, integer *, 
	    integer *, integer *), objnth_(integer *, integer *, integer *, 
	    logical *);
    static integer npline;
    extern /* Subroutine */ int prname_(integer *, integer *, char *, char *, 
	    char *, integer *, char *, ftnlen, ftnlen, ftnlen, ftnlen);
    static doublereal filwin[1006];
    static integer nlines, objtmp[2];
    extern integer touchi_(integer *);
    static integer widest;
    extern integer objsiz_(integer *);
    extern /* Subroutine */ int objnxt_(integer *, integer *, integer *, 
	    logical *), sygetd_(char *, char *, integer *, doublereal *, 
	    integer *, doublereal *, logical *, ftnlen, ftnlen), nextwd_(char 
	    *, char *, char *, ftnlen, ftnlen, ftnlen);
    static integer ngroup;
    extern /* Subroutine */ int ssizec_(integer *, char *, ftnlen);
    static doublereal lstwin[1006];
    extern /* Subroutine */ int writit_(char *, ftnlen);
    static logical fnd;
    static integer obj[2];

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

/*     The Version is stored as a string. */


/*     MAXUSE is the maximum number of bodies that can be explicitely */
/*     specified on the command line for brief summaries. */


/*     The longest command line that can be accomodated is */
/*     given by CMDSIZ */


/*     The maximum number of bodies that can be summarized is stored */
/*     in the parameter MAXBOD */


/*     The average number of intervals per body */


/*     The largest expected window */


/*     Functions. */


/*     Parameters */


/*     Local Variables. */


/*     SPICELIB Calls */


/*     Saved variables */

/*     The SAVE statement that appears here causes f2c to create */
/*     local variables with static duration.  This enables the CSPICE */
/*     version of brief to run under cygwin. */

    group = ! (*tdsp) || *gdsp;

/*     First take apart the format picture to see what */
/*     the various components are. */

    nextwd_(fmtpic, p1, rest, fmtpic_len, (ftnlen)8, (ftnlen)132);
    nextwd_(rest, wd, rest, (ftnlen)132, (ftnlen)8, (ftnlen)132);
    nextwd_(rest, p2, rest, (ftnlen)132, (ftnlen)8, (ftnlen)132);
    size = 1;
    if (s_cmp(p2, " ", (ftnlen)8, (ftnlen)1) != 0) {
	size = 3;
    }

/*     Find out the width of the widest name. */

    nobj = objact_(objlis);
    sobj = objsiz_(objlis);

/*     If we don't have any objects to display then */
/*     we just return. */

    if (nobj == 0) {
	return 0;
    }
    objnth_(objlis, &c__1, obj, &found);
    widest = 0;
    while(found) {
	objget_(obj, objlis, object);
	objnxt_(obj, objlis, objn, &found);
	prname_(object, &sobj, p1, wd, p2, &size, name__, (ftnlen)8, (ftnlen)
		8, (ftnlen)8, (ftnlen)64);
/* Computing MAX */
	i__1 = widest, i__2 = rtrim_(name__, (ftnlen)64);
	widest = max(i__1,i__2);
	obj[0] = objn[0];
	obj[1] = objn[1];
    }

/*     Are we going to group by window?  If not, this is pretty */
/*     easy.  Just display stuff. */

    if (*tdsp && ! (*gdsp)) {
	s = widest + 3;
	e = s + 32;
	s_copy(line, "Bodies", (ftnlen)132, (ftnlen)6);
	s_copy(line + (s - 1), "Start of Interval (ET)", 132 - (s - 1), (
		ftnlen)22);
	s_copy(line + (e - 1), "End of Interval (ET) ", 132 - (e - 1), (
		ftnlen)21);
	writit_(line, (ftnlen)132);
	s_copy(line, "-------", (ftnlen)132, (ftnlen)7);
	s_copy(line + (s - 1), "-----------------------------", 132 - (s - 1),
		 (ftnlen)29);
	s_copy(line + (e - 1), "-----------------------------", 132 - (e - 1),
		 (ftnlen)29);
	writit_(line, (ftnlen)132);
	objnth_(objlis, &c__1, obj, &found);
	n1 = 0;
	while(found) {
	    s_copy(line, " ", (ftnlen)132, (ftnlen)1);
	    objget_(obj, objlis, object);
	    prname_(object, &sobj, p1, wd, p2, &size, line, (ftnlen)8, (
		    ftnlen)8, (ftnlen)8, (ftnlen)132);
	    maknam_(object, &sobj, obnam, name__, (ftnlen)64);
	    sygetd_(name__, winsym, winptr, winval, &n2, &filwin[6], &found, (
		    ftnlen)64, winsym_len);
	    if (n2 == n1) {
		same = TRUE_;
		i__ = 1;
		while(same && i__ <= n1) {
		    same = filwin[(i__1 = i__ + 5) < 1006 && 0 <= i__1 ? i__1 
			    : s_rnge("filwin", i__1, "disply_", (ftnlen)214)] 
			    == lstwin[(i__2 = i__ + 5) < 1006 && 0 <= i__2 ? 
			    i__2 : s_rnge("lstwin", i__2, "disply_", (ftnlen)
			    214)];
		    ++i__;
		}
	    } else {
		same = FALSE_;
	    }
	    if (! same) {
		i__1 = n2;
		for (i__ = 1; i__ <= i__1; i__ += 2) {
		    etcal_(&filwin[(i__2 = i__ + 5) < 1006 && 0 <= i__2 ? 
			    i__2 : s_rnge("filwin", i__2, "disply_", (ftnlen)
			    226)], line + (s - 1), 132 - (s - 1));
		    etcal_(&filwin[(i__2 = i__ + 6) < 1006 && 0 <= i__2 ? 
			    i__2 : s_rnge("filwin", i__2, "disply_", (ftnlen)
			    227)], line + (e - 1), 132 - (e - 1));
		    writit_(line, (ftnlen)132);
		    s_copy(line, " ", (ftnlen)132, (ftnlen)1);
		    lstwin[(i__2 = i__ + 5) < 1006 && 0 <= i__2 ? i__2 : 
			    s_rnge("lstwin", i__2, "disply_", (ftnlen)230)] = 
			    filwin[(i__3 = i__ + 5) < 1006 && 0 <= i__3 ? 
			    i__3 : s_rnge("filwin", i__3, "disply_", (ftnlen)
			    230)];
		    lstwin[(i__2 = i__ + 6) < 1006 && 0 <= i__2 ? i__2 : 
			    s_rnge("lstwin", i__2, "disply_", (ftnlen)231)] = 
			    filwin[(i__3 = i__ + 6) < 1006 && 0 <= i__3 ? 
			    i__3 : s_rnge("filwin", i__3, "disply_", (ftnlen)
			    231)];
		    n1 = n2;
		}
	    } else {
		i__1 = s + 11;
		s_copy(line + i__1, "Same coverage as previous object ", 132 
			- i__1, (ftnlen)33);
		writit_(line, (ftnlen)132);
	    }
	    objnxt_(obj, objlis, objtmp, &found);
	    obj[0] = touchi_(objtmp);
	    obj[1] = touchi_(&objtmp[1]);
	}
    } else if (*tdsp && *gdsp) {
	s = widest + 3;
	e = s + 32;
	s_copy(line, "Bodies", (ftnlen)132, (ftnlen)6);
	s_copy(line + (s - 1), "Start of Interval (ET)", 132 - (s - 1), (
		ftnlen)22);
	s_copy(line + (e - 1), "End of Interval (ET) ", 132 - (e - 1), (
		ftnlen)21);
	writit_(line, (ftnlen)132);
	s_copy(line, "-------", (ftnlen)132, (ftnlen)7);
	s_copy(line + (s - 1), "-----------------------------", 132 - (s - 1),
		 (ftnlen)29);
	s_copy(line + (e - 1), "-----------------------------", 132 - (e - 1),
		 (ftnlen)29);
	writit_(line, (ftnlen)132);
	objnth_(objlis, &c__1, obj, &found);
	while(found) {
	    s_copy(line, " ", (ftnlen)132, (ftnlen)1);
	    objget_(obj, objlis, object);
	    prname_(object, &sobj, p1, wd, p2, &size, line, (ftnlen)8, (
		    ftnlen)8, (ftnlen)8, (ftnlen)132);
	    maknam_(object, &sobj, obnam, name__, (ftnlen)64);
	    sygetd_(name__, winsym, winptr, winval, &n1, &filwin[6], &found, (
		    ftnlen)64, winsym_len);
	    i__1 = n1;
	    for (i__ = 1; i__ <= i__1; i__ += 2) {
		etcal_(&filwin[(i__2 = i__ + 5) < 1006 && 0 <= i__2 ? i__2 : 
			s_rnge("filwin", i__2, "disply_", (ftnlen)281)], line 
			+ (s - 1), 132 - (s - 1));
		etcal_(&filwin[(i__2 = i__ + 6) < 1006 && 0 <= i__2 ? i__2 : 
			s_rnge("filwin", i__2, "disply_", (ftnlen)282)], line 
			+ (e - 1), 132 - (e - 1));
		writit_(line, (ftnlen)132);
		s_copy(line, " ", (ftnlen)132, (ftnlen)1);
		lstwin[(i__2 = i__ + 5) < 1006 && 0 <= i__2 ? i__2 : s_rnge(
			"lstwin", i__2, "disply_", (ftnlen)285)] = filwin[(
			i__3 = i__ + 5) < 1006 && 0 <= i__3 ? i__3 : s_rnge(
			"filwin", i__3, "disply_", (ftnlen)285)];
		lstwin[(i__2 = i__ + 6) < 1006 && 0 <= i__2 ? i__2 : s_rnge(
			"lstwin", i__2, "disply_", (ftnlen)286)] = filwin[(
			i__3 = i__ + 6) < 1006 && 0 <= i__3 ? i__3 : s_rnge(
			"filwin", i__3, "disply_", (ftnlen)286)];
	    }
	    objnxt_(obj, objlis, objn, &fnd);
	    objrem_(obj, objlis);
	    obj[0] = objn[0];
	    obj[1] = objn[1];
	    while(fnd) {
		s_copy(line, " ", (ftnlen)132, (ftnlen)1);
		objget_(obj, objlis, object);
		prname_(object, &sobj, p1, wd, p2, &size, line, (ftnlen)8, (
			ftnlen)8, (ftnlen)8, (ftnlen)132);
		maknam_(object, &sobj, obnam, name__, (ftnlen)64);
		sygetd_(name__, winsym, winptr, winval, &n2, &filwin[6], &
			found, (ftnlen)64, winsym_len);
		if (n2 == n1) {
		    same = TRUE_;
		    i__ = 1;
		    while(same && i__ <= n1) {
			same = filwin[(i__1 = i__ + 5) < 1006 && 0 <= i__1 ? 
				i__1 : s_rnge("filwin", i__1, "disply_", (
				ftnlen)309)] == lstwin[(i__2 = i__ + 5) < 
				1006 && 0 <= i__2 ? i__2 : s_rnge("lstwin", 
				i__2, "disply_", (ftnlen)309)];
			++i__;
		    }
		} else {
		    same = FALSE_;
		}
		if (same) {
		    i__1 = s + 11;
		    s_copy(line + i__1, "Same coverage as previous object ", 
			    132 - i__1, (ftnlen)33);
		    writit_(line, (ftnlen)132);
		}
		objnxt_(obj, objlis, objn, &fnd);
		if (same) {
		    objrem_(obj, objlis);
		}
		obj[0] = objn[0];
		obj[1] = objn[1];
	    }
	    objnth_(objlis, &c__1, obj, &found);
	}
    } else {
	objnth_(objlis, &c__1, obj, &found);
	while(found) {
	    ssizec_(&c__20000, names, (ftnlen)64);
	    objget_(obj, objlis, object);
	    prname_(object, &sobj, p1, wd, p2, &size, name__, (ftnlen)8, (
		    ftnlen)8, (ftnlen)8, (ftnlen)64);
	    appndc_(name__, names, (ftnlen)64, (ftnlen)64);

/*           Look up the window associated with this object. */

	    maknam_(object, &sobj, obnam, name__, (ftnlen)64);
	    sygetd_(name__, winsym, winptr, winval, &n1, &lstwin[6], &fnd, (
		    ftnlen)64, winsym_len);

/*           Fetch the next object. */

	    objnxt_(obj, objlis, objn, &fnd);
	    objrem_(obj, objlis);
	    obj[0] = objn[0];
	    obj[1] = objn[1];
	    while(fnd) {
		objget_(obj, objlis, object);
		maknam_(object, &sobj, obnam, name__, (ftnlen)64);
		sygetd_(name__, winsym, winptr, winval, &n2, &filwin[6], &fnd,
			 (ftnlen)64, winsym_len);

/*              See if this window is the same as the current */
/*              window under considerations. */

		if (n1 == n2) {
		    same = TRUE_;
		    i__ = 1;
		    while(same && i__ <= n1) {
			same = filwin[(i__1 = i__ + 5) < 1006 && 0 <= i__1 ? 
				i__1 : s_rnge("filwin", i__1, "disply_", (
				ftnlen)384)] == lstwin[(i__2 = i__ + 5) < 
				1006 && 0 <= i__2 ? i__2 : s_rnge("lstwin", 
				i__2, "disply_", (ftnlen)384)];
			++i__;
		    }
		} else {
		    same = FALSE_;
		}
		objnxt_(obj, objlis, objn, &fnd);
		if (same) {
		    objrem_(obj, objlis);
		    prname_(object, &sobj, p1, wd, p2, &size, name__, (ftnlen)
			    8, (ftnlen)8, (ftnlen)8, (ftnlen)64);
		    appndc_(name__, names, (ftnlen)64, (ftnlen)64);
		}
		obj[0] = objn[0];
		obj[1] = objn[1];
	    }
	    ngroup = cardc_(names, (ftnlen)64);
	    if (ngroup == 1) {
		s_copy(line, "Body: ", (ftnlen)132, (ftnlen)6);
		start = 7;
	    } else {
		s_copy(line, "Bodies: ", (ftnlen)132, (ftnlen)8);
		start = 9;
	    }
	    npline = (80 - widest - start) / (widest + 2) + 1;
	    rmaini_(&ngroup, &npline, &nlines, &remain);
	    if (remain != 0) {
		++nlines;
	    }
	    i__1 = nlines;
	    for (j = 1; j <= i__1; ++j) {
		b = start;
		i__2 = ngroup;
		i__3 = nlines;
		for (i__ = j; i__3 < 0 ? i__ >= i__2 : i__ <= i__2; i__ += 
			i__3) {
		    s_copy(line + (b - 1), names + (((i__4 = i__ + 5) < 20006 
			    && 0 <= i__4 ? i__4 : s_rnge("names", i__4, "dis"
			    "ply_", (ftnlen)427)) << 6), 132 - (b - 1), (
			    ftnlen)64);
		    b = b + widest + 2;
		}
		writit_(line, (ftnlen)132);
		s_copy(line, " ", (ftnlen)132, (ftnlen)1);
	    }
	    s_copy(header, " ", (ftnlen)132, (ftnlen)1);
	    s_copy(header + 132, " ", (ftnlen)132, (ftnlen)1);
	    s_copy(header + (start - 1), "Start of Interval (ET)            "
		    "  End of Interval (ET)", 132 - (start - 1), (ftnlen)56);
	    s_copy(header + (start + 131), "--------------------------------"
		    "    --------------------------------", 132 - (start - 1), 
		    (ftnlen)68);
	    s = start;
	    e = start + 36;
	    writit_(header, (ftnlen)132);
	    writit_(header + 132, (ftnlen)132);
	    i__1 = n1;
	    for (i__ = 1; i__ <= i__1; i__ += 2) {
		s_copy(line, " ", (ftnlen)132, (ftnlen)1);
		etcal_(&lstwin[(i__3 = i__ + 5) < 1006 && 0 <= i__3 ? i__3 : 
			s_rnge("lstwin", i__3, "disply_", (ftnlen)453)], line 
			+ (s - 1), 132 - (s - 1));
		etcal_(&lstwin[(i__3 = i__ + 6) < 1006 && 0 <= i__3 ? i__3 : 
			s_rnge("lstwin", i__3, "disply_", (ftnlen)454)], line 
			+ (e - 1), 132 - (e - 1));
		writit_(line, (ftnlen)132);
	    }
	    writit_(" ", (ftnlen)1);
	    objnth_(objlis, &c__1, obj, &found);
	}
    }
    return 0;
} /* disply_ */

