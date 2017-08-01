/* tstio.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__4 = 4;
static integer c__9 = 9;
static integer c__1 = 1;
static integer c__6 = 6;

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


/*     IO Manager. */

/* Subroutine */ int tstio_0_(int n__, char *line, char *name__, char *port, 
	logical *ok, logical *status, ftnlen line_len, ftnlen name_len, 
	ftnlen port_len)
{
    /* Initialized data */

    static char ports[32*4] = "LOG                             " "SCREEN    "
	    "                      " "SAVE                            " "UTIL"
	    "ITY                         ";
    static char files[127*4] = "                                            "
	    "                                                                "
	    "                   " "                                          "
	    "                                                                "
	    "                     " "                                        "
	    "                                                                "
	    "                       " "                                      "
	    "                                                                "
	    "                         ";
    static integer units[4] = { 0,6,0,0 };
    static logical active[4] = { FALSE_,TRUE_,FALSE_,FALSE_ };
    static logical open[4] = { FALSE_,TRUE_,FALSE_,FALSE_ };
    static logical suspnd[4] = { FALSE_,FALSE_,FALSE_,FALSE_ };
    static logical lkport[4] = { FALSE_,FALSE_,FALSE_,FALSE_ };

    /* System generated locals */
    integer i__1, i__2;
    cllist cl__1;

    /* Builtin functions */
    integer s_wsle(cilist *), do_lio(integer *, integer *, char *, ftnlen), 
	    e_wsle(void), s_rnge(char *, integer, char *, integer);
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer f_clos(cllist *);

    /* Local variables */
    static integer r__;
    extern /* Subroutine */ int repmc_(char *, char *, char *, char *, ftnlen,
	     ftnlen, ftnlen, ftnlen), repmi_(char *, char *, integer *, char *
	    , ftnlen, ftnlen, ftnlen);
    extern integer rtrim_(char *, ftnlen);
    static integer id;
    extern logical failed_(void);
    static integer to;
    extern integer isrchc_(char *, integer *, char *, ftnlen, ftnlen);
    static char messge[400];
    static integer iostat;
    extern /* Subroutine */ int tostdo_(char *, ftnlen), writln_(char *, 
	    integer *, ftnlen), txtopn_(char *, integer *, ftnlen), 
	    niceio_3__(char *, integer *, char *, ftnlen, ftnlen);

    /* Fortran I/O blocks */
    static cilist io___9 = { 0, 6, 0, 0, 0 };
    static cilist io___10 = { 0, 6, 0, 0, 0 };
    static cilist io___12 = { 0, 6, 0, 0, 0 };
    static cilist io___13 = { 0, 6, 0, 0, 0 };
    static cilist io___14 = { 0, 6, 0, 0, 0 };
    static cilist io___15 = { 0, 6, 0, 0, 0 };
    static cilist io___16 = { 0, 6, 0, 0, 0 };
    static cilist io___17 = { 0, 6, 0, 0, 0 };
    static cilist io___18 = { 0, 6, 0, 0, 0 };
    static cilist io___19 = { 0, 6, 0, 0, 0 };
    static cilist io___20 = { 0, 6, 0, 0, 0 };
    static cilist io___21 = { 0, 6, 0, 0, 0 };
    static cilist io___22 = { 0, 6, 0, 0, 0 };
    static cilist io___23 = { 0, 6, 0, 0, 0 };
    static cilist io___24 = { 0, 6, 0, 0, 0 };
    static cilist io___25 = { 0, 6, 0, 0, 0 };
    static cilist io___29 = { 0, 6, 0, 0, 0 };
    static cilist io___30 = { 0, 6, 0, 0, 0 };
    static cilist io___31 = { 0, 6, 0, 0, 0 };
    static cilist io___32 = { 0, 6, 0, 0, 0 };



/* $ Version */

/* -     Testing Utilities Version 1.2.0, 9-MAY-2002 (EDW) */

/*         Added the LCKOUT entry mode. Routine inhibits */
/*         all output to the specified port. Primary use */
/*         prevents tspice from printing to the screen - */
/*         a quiet mode. */

/* -     Testing Utilities Version 1.1.0, 18-JUN-1999 (WLT) */

/*         Added a RETURN before the first entry point. */

/* -     Testing Utilities Version 1.0.0, 3-NOV-1994 (WLT) */

/*         This is the configured version of the Test Utility */
/*         software as of Nov 3, 1994 */


/*     Below are the various types of output files that */
/*     might be open. */


/*     SPICELIB functions */

    /* Parameter adjustments */
    if (status) {
	}

    /* Function Body */
    switch(n__) {
	case 1: goto L_tstopn;
	case 2: goto L_tstioh;
	case 3: goto L_tstioa;
	case 4: goto L_tstgst;
	case 5: goto L_tstpst;
	case 6: goto L_tstioc;
	case 7: goto L_tstios;
	case 8: goto L_tstior;
	case 9: goto L_tstwln;
	case 10: goto L_finish;
	case 11: goto L_lckout;
	}

    return 0;

/*     Open a new port */


L_tstopn:
/* $ Version */

/* -     Testing Utilities Version 1.0.0, 3-NOV-1994 (WLT) */

/*         This is the configured version of the Test Utility */
/*         software as of Nov 3, 1994 */

    id = isrchc_(port, &c__4, ports, port_len, (ftnlen)32);
    if (id == 0) {
	s_wsle(&io___9);
	do_lio(&c__9, &c__1, "Unrecognized port: ", (ftnlen)19);
	e_wsle();
	s_wsle(&io___10);
	do_lio(&c__9, &c__1, port, port_len);
	e_wsle();
	return 0;
    }
    if (lkport[(i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge("lkport", 
	    i__1, "tstio_", (ftnlen)144)]) {
	return 0;
    }
    r__ = rtrim_(name__, name_len);
    txtopn_(name__, &units[(i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge(
	    "units", i__1, "tstio_", (ftnlen)150)], r__);
    if (failed_()) {
	open[(i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge("open", i__1, 
		"tstio_", (ftnlen)153)] = FALSE_;
	active[(i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge("active", 
		i__1, "tstio_", (ftnlen)154)] = FALSE_;
	suspnd[(i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge("suspnd", 
		i__1, "tstio_", (ftnlen)155)] = FALSE_;
	s_copy(files + ((i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge(
		"files", i__1, "tstio_", (ftnlen)156)) * 127, " ", (ftnlen)
		127, (ftnlen)1);
	return 0;
    }
    open[(i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge("open", i__1, "tst"
	    "io_", (ftnlen)160)] = TRUE_;
    active[(i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge("active", i__1, 
	    "tstio_", (ftnlen)161)] = TRUE_;
    suspnd[(i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge("suspnd", i__1, 
	    "tstio_", (ftnlen)162)] = FALSE_;
    s_copy(files + ((i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge("files", 
	    i__1, "tstio_", (ftnlen)163)) * 127, name__, (ftnlen)127, 
	    name_len);
    return 0;

/*     Inhibit outout to a port. */


L_tstioh:
/* $ Version */

/* -     Testing Utilities Version 1.0.0, 3-NOV-1994 (WLT) */

/*         This is the configured version of the Test Utility */
/*         software as of Nov 3, 1994 */

    id = isrchc_(port, &c__4, ports, port_len, (ftnlen)32);
    if (id == 0) {
	s_wsle(&io___12);
	do_lio(&c__9, &c__1, "Unrecognized port: ", (ftnlen)19);
	e_wsle();
	s_wsle(&io___13);
	do_lio(&c__9, &c__1, port, port_len);
	e_wsle();
	return 0;
    }
    active[(i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge("active", i__1, 
	    "tstio_", (ftnlen)189)] = FALSE_;
    return 0;

/*     Activate a port */


L_tstioa:
/* $ Version */

/* -     Testing Utilities Version 1.0.0, 3-NOV-1994 (WLT) */

/*         This is the configured version of the Test Utility */
/*         software as of Nov 3, 1994 */

    id = isrchc_(port, &c__4, ports, port_len, (ftnlen)32);
    if (id == 0) {
	s_wsle(&io___14);
	do_lio(&c__9, &c__1, "Unrecognized port: ", (ftnlen)19);
	e_wsle();
	s_wsle(&io___15);
	do_lio(&c__9, &c__1, port, port_len);
	e_wsle();
	return 0;
    }
    if (lkport[(i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge("lkport", 
	    i__1, "tstio_", (ftnlen)215)]) {
	return 0;
    }
    active[(i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge("active", i__1, 
	    "tstio_", (ftnlen)219)] = TRUE_;
    return 0;

/*     Get the current status of a port. */


L_tstgst:
/* $ Version */

/* -     Testing Utilities Version 1.0.0, 3-NOV-1994 (WLT) */

/*         This is the configured version of the Test Utility */
/*         software as of Nov 3, 1994 */

    id = isrchc_(port, &c__4, ports, port_len, (ftnlen)32);
    if (id == 0) {
	s_wsle(&io___16);
	do_lio(&c__9, &c__1, "Unrecognized port: ", (ftnlen)19);
	e_wsle();
	s_wsle(&io___17);
	do_lio(&c__9, &c__1, port, port_len);
	e_wsle();
	return 0;
    }
    status[0] = active[(i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge("act"
	    "ive", i__1, "tstio_", (ftnlen)247)];
    status[1] = open[(i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge("open", 
	    i__1, "tstio_", (ftnlen)248)];
    status[2] = suspnd[(i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge("sus"
	    "pnd", i__1, "tstio_", (ftnlen)249)];
    return 0;

/*     Put the status of a port. */


L_tstpst:

/* $ Version */

/* -     Testing Utilities Version 1.0.0, 3-NOV-1994 (WLT) */

/*         This is the configured version of the Test Utility */
/*         software as of Nov 3, 1994 */

    id = isrchc_(port, &c__4, ports, port_len, (ftnlen)32);
    if (id == 0) {
	s_wsle(&io___18);
	do_lio(&c__9, &c__1, "Unrecognized port: ", (ftnlen)19);
	e_wsle();
	s_wsle(&io___19);
	do_lio(&c__9, &c__1, port, port_len);
	e_wsle();
	return 0;
    }
    active[(i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge("active", i__1, 
	    "tstio_", (ftnlen)279)] = status[0];
    open[(i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge("open", i__1, "tst"
	    "io_", (ftnlen)280)] = status[1];
    suspnd[(i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge("suspnd", i__1, 
	    "tstio_", (ftnlen)281)] = status[2];
    return 0;

/*     Close a port. */


L_tstioc:

/* $ Version */

/* -     Testing Utilities Version 1.0.0, 3-NOV-1994 (WLT) */

/*         This is the configured version of the Test Utility */
/*         software as of Nov 3, 1994 */

    id = isrchc_(port, &c__4, ports, port_len, (ftnlen)32);
    if (id == 0) {
	s_wsle(&io___20);
	do_lio(&c__9, &c__1, "Unrecognized port: ", (ftnlen)19);
	e_wsle();
	s_wsle(&io___21);
	do_lio(&c__9, &c__1, port, port_len);
	e_wsle();
	return 0;
    }
    cl__1.cerr = 0;
    cl__1.cunit = units[(i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge(
	    "units", i__1, "tstio_", (ftnlen)307)];
    cl__1.csta = 0;
    f_clos(&cl__1);
    active[(i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge("active", i__1, 
	    "tstio_", (ftnlen)309)] = FALSE_;
    open[(i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge("open", i__1, "tst"
	    "io_", (ftnlen)310)] = FALSE_;
    s_copy(files + ((i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge("files", 
	    i__1, "tstio_", (ftnlen)311)) * 127, " ", (ftnlen)127, (ftnlen)1);
    suspnd[(i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge("suspnd", i__1, 
	    "tstio_", (ftnlen)312)] = FALSE_;
    return 0;

/*     Suspend a port (possibly to be reopened later) */


L_tstios:

/* $ Version */

/* -     Testing Utilities Version 1.0.0, 3-NOV-1994 (WLT) */

/*         This is the configured version of the Test Utility */
/*         software as of Nov 3, 1994 */

    id = isrchc_(port, &c__4, ports, port_len, (ftnlen)32);
    if (id == 0) {
	s_wsle(&io___22);
	do_lio(&c__9, &c__1, "Unrecognized port: ", (ftnlen)19);
	e_wsle();
	s_wsle(&io___23);
	do_lio(&c__9, &c__1, port, port_len);
	e_wsle();
	return 0;
    }
    if (lkport[(i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge("lkport", 
	    i__1, "tstio_", (ftnlen)340)]) {
	return 0;
    }

/*        close ( units(id) ) */

    open[(i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge("open", i__1, "tst"
	    "io_", (ftnlen)348)] = FALSE_;
    suspnd[(i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge("suspnd", i__1, 
	    "tstio_", (ftnlen)349)] = TRUE_;
    return 0;

/*     Reopen a suspended port. */


L_tstior:

/* $ Version */

/* -     Testing Utilities Version 1.0.0, 3-NOV-1994 (WLT) */

/*         This is the configured version of the Test Utility */
/*         software as of Nov 3, 1994 */

    id = isrchc_(port, &c__4, ports, port_len, (ftnlen)32);
    if (id == 0) {
	s_wsle(&io___24);
	do_lio(&c__9, &c__1, "Unrecognized port: ", (ftnlen)19);
	e_wsle();
	s_wsle(&io___25);
	do_lio(&c__9, &c__1, port, port_len);
	e_wsle();
	return 0;
    }
    if (lkport[(i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge("lkport", 
	    i__1, "tstio_", (ftnlen)375)]) {
	return 0;
    }
    if (! suspnd[(i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge("suspnd", 
	    i__1, "tstio_", (ftnlen)379)]) {
	*ok = FALSE_;
	return 0;
    }
    open[(i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge("open", i__1, "tst"
	    "io_", (ftnlen)384)] = TRUE_;
    suspnd[(i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge("suspnd", i__1, 
	    "tstio_", (ftnlen)385)] = FALSE_;
    *ok = TRUE_;
    return 0;

/*     Write a line to all open and active ports. */


L_tstwln:

/* $ Version */

/* -     Testing Utilities Version 1.0.0, 3-NOV-1994 (WLT) */

/*         This is the configured version of the Test Utility */
/*         software as of Nov 3, 1994 */

    for (id = 1; id <= 4; ++id) {
	if (active[(i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge("active", 
		i__1, "tstio_", (ftnlen)406)] && open[(i__2 = id - 1) < 4 && 
		0 <= i__2 ? i__2 : s_rnge("open", i__2, "tstio_", (ftnlen)406)
		]) {
	    to = units[(i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge("uni"
		    "ts", i__1, "tstio_", (ftnlen)408)];
	    writln_(line, &to, rtrim_(line, line_len));
	    if (id != 2 && failed_()) {
		r__ = rtrim_(files + ((i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 
			: s_rnge("files", i__1, "tstio_", (ftnlen)414)) * 127,
			 (ftnlen)127);
		s_copy(messge, "I was unable to write to the file #.  The va"
			"lue of IOSTAT returned was #. ", (ftnlen)400, (ftnlen)
			74);
		repmc_(messge, "#", files + ((i__1 = id - 1) < 4 && 0 <= i__1 
			? i__1 : s_rnge("files", i__1, "tstio_", (ftnlen)420))
			 * 127, messge, (ftnlen)400, (ftnlen)1, r__, (ftnlen)
			400);
		repmi_(messge, "#", &iostat, messge, (ftnlen)400, (ftnlen)1, (
			ftnlen)400);
		s_wsle(&io___29);
		e_wsle();
		niceio_3__(messge, &c__6, "LEFT 1 RIGHT 78 NEWLINE /cr", (
			ftnlen)400, (ftnlen)27);
		s_wsle(&io___30);
		e_wsle();
		cl__1.cerr = 0;
		cl__1.cunit = units[(i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 : 
			s_rnge("units", i__1, "tstio_", (ftnlen)428)];
		cl__1.csta = 0;
		f_clos(&cl__1);
		active[(i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge("act"
			"ive", i__1, "tstio_", (ftnlen)430)] = FALSE_;
		open[(i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge("open", 
			i__1, "tstio_", (ftnlen)431)] = FALSE_;
		suspnd[(i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge("sus"
			"pnd", i__1, "tstio_", (ftnlen)432)] = FALSE_;
		s_copy(files + ((i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 : 
			s_rnge("files", i__1, "tstio_", (ftnlen)433)) * 127, 
			" ", (ftnlen)127, (ftnlen)1);
	    }
	}
    }
    return 0;

/*     The final entry point handles closing files and informing the */
/*     user of the location of these files. */


L_finish:
/* $ Version */

/* -     Testing Utilities Version 1.0.0, 3-NOV-1994 (WLT) */

/*         This is the configured version of the Test Utility */
/*         software as of Nov 3, 1994 */


/*        Obtain the port ID for the SCREEN. */

    id = isrchc_("SCREEN", &c__4, ports, (ftnlen)6, (ftnlen)32);
    if (open[0]) {

/*           Output to standard out if no SCREEN lockout exists */

	if (active[(i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge("active", 
		i__1, "tstio_", (ftnlen)469)] && open[(i__2 = id - 1) < 4 && 
		0 <= i__2 ? i__2 : s_rnge("open", i__2, "tstio_", (ftnlen)469)
		]) {
	    s_copy(messge, "The log file was written to: ", (ftnlen)400, (
		    ftnlen)29);
	    tostdo_(messge, rtrim_(messge, (ftnlen)400));
	    tostdo_(files, rtrim_(files, (ftnlen)127));
	    tostdo_(" ", (ftnlen)1);
	}
	cl__1.cerr = 0;
	cl__1.cunit = units[0];
	cl__1.csta = 0;
	f_clos(&cl__1);
    }
    if (open[2]) {

/*           Output to standard out if no SCREEN lockout exists */

	if (active[(i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge("active", 
		i__1, "tstio_", (ftnlen)485)] && open[(i__2 = id - 1) < 4 && 
		0 <= i__2 ? i__2 : s_rnge("open", i__2, "tstio_", (ftnlen)485)
		]) {
	    s_copy(messge, "The list of test failures was written to: ", (
		    ftnlen)400, (ftnlen)42);
	    tostdo_(messge, rtrim_(messge, (ftnlen)400));
	    tostdo_(files + 254, rtrim_(files + 254, (ftnlen)127));
	    tostdo_(" ", (ftnlen)1);
	}
	cl__1.cerr = 0;
	cl__1.cunit = units[2];
	cl__1.csta = 0;
	f_clos(&cl__1);
    }
    return 0;

/*        Lock out a port from use. */


L_lckout:
/* $ Version */

/* -     Testing Utilities Version 1.0.0, 9-MAY-2002 (EDW) */


/*        Get the port ID. */

    id = isrchc_(port, &c__4, ports, port_len, (ftnlen)32);
    if (id == 0) {
	s_wsle(&io___31);
	do_lio(&c__9, &c__1, "Unrecognized port: ", (ftnlen)19);
	e_wsle();
	s_wsle(&io___32);
	do_lio(&c__9, &c__1, port, port_len);
	e_wsle();
	return 0;
    }

/*        Close everything. */

    active[(i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge("active", i__1, 
	    "tstio_", (ftnlen)523)] = FALSE_;
    open[(i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge("open", i__1, "tst"
	    "io_", (ftnlen)524)] = FALSE_;
    suspnd[(i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge("suspnd", i__1, 
	    "tstio_", (ftnlen)525)] = FALSE_;
    lkport[(i__1 = id - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge("lkport", i__1, 
	    "tstio_", (ftnlen)526)] = TRUE_;
    return 0;
} /* tstio_ */

/* Subroutine */ int tstio_(char *line, char *name__, char *port, logical *ok,
	 logical *status, ftnlen line_len, ftnlen name_len, ftnlen port_len)
{
    return tstio_0_(0, line, name__, port, ok, status, line_len, name_len, 
	    port_len);
    }

/* Subroutine */ int tstopn_(char *port, char *name__, ftnlen port_len, 
	ftnlen name_len)
{
    return tstio_0_(1, (char *)0, name__, port, (logical *)0, (logical *)0, (
	    ftnint)0, name_len, port_len);
    }

/* Subroutine */ int tstioh_(char *port, ftnlen port_len)
{
    return tstio_0_(2, (char *)0, (char *)0, port, (logical *)0, (logical *)0,
	     (ftnint)0, (ftnint)0, port_len);
    }

/* Subroutine */ int tstioa_(char *port, ftnlen port_len)
{
    return tstio_0_(3, (char *)0, (char *)0, port, (logical *)0, (logical *)0,
	     (ftnint)0, (ftnint)0, port_len);
    }

/* Subroutine */ int tstgst_(char *port, logical *status, ftnlen port_len)
{
    return tstio_0_(4, (char *)0, (char *)0, port, (logical *)0, status, (
	    ftnint)0, (ftnint)0, port_len);
    }

/* Subroutine */ int tstpst_(char *port, logical *status, ftnlen port_len)
{
    return tstio_0_(5, (char *)0, (char *)0, port, (logical *)0, status, (
	    ftnint)0, (ftnint)0, port_len);
    }

/* Subroutine */ int tstioc_(char *port, ftnlen port_len)
{
    return tstio_0_(6, (char *)0, (char *)0, port, (logical *)0, (logical *)0,
	     (ftnint)0, (ftnint)0, port_len);
    }

/* Subroutine */ int tstios_(char *port, ftnlen port_len)
{
    return tstio_0_(7, (char *)0, (char *)0, port, (logical *)0, (logical *)0,
	     (ftnint)0, (ftnint)0, port_len);
    }

/* Subroutine */ int tstior_(char *port, logical *ok, ftnlen port_len)
{
    return tstio_0_(8, (char *)0, (char *)0, port, ok, (logical *)0, (ftnint)
	    0, (ftnint)0, port_len);
    }

/* Subroutine */ int tstwln_(char *line, ftnlen line_len)
{
    return tstio_0_(9, line, (char *)0, (char *)0, (logical *)0, (logical *)0,
	     line_len, (ftnint)0, (ftnint)0);
    }

/* Subroutine */ int finish_(void)
{
    return tstio_0_(10, (char *)0, (char *)0, (char *)0, (logical *)0, (
	    logical *)0, (ftnint)0, (ftnint)0, (ftnint)0);
    }

/* Subroutine */ int lckout_(char *port, ftnlen port_len)
{
    return tstio_0_(11, (char *)0, (char *)0, port, (logical *)0, (logical *)
	    0, (ftnint)0, (ftnint)0, port_len);
    }

