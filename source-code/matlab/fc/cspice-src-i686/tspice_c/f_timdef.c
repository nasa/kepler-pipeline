/* f_timdef.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static logical c_true = TRUE_;

/* $Procedure      F_TIMDEF ( Family of tests for TIMDEF ) */
/* Subroutine */ int f_timdef__(logical *ok)
{
    /* System generated locals */
    integer i__1;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    char zone[16];
    integer i__;
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    char value[16];
    extern /* Subroutine */ int topen_(char *, ftnlen);
    char zones[16*8];
    extern /* Subroutine */ int t_success__(logical *), chcksc_(char *, char *
	    , char *, char *, logical *, ftnlen, ftnlen, ftnlen, ftnlen);
    char calndr[16];
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     timdef_(char *, char *, char *, ftnlen, ftnlen, ftnlen);
    char expect[16*8], system[16];

/* $ Abstract */

/*     This routine exercises the routine TIMDEF to make sure */
/*     that all advertised inputs are accepted and that */
/*     unadvertised inputs are rejected. */

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

/*     Local Variables */


/*     Begin every test family with an open call. */

    topen_("F_TIMDEF", (ftnlen)8);
    tcase_("Check that the default values are SYSTEM = 'UTC', ZONE = ' ' and"
	    " CALENDAR = 'GREGORIAN' ", (ftnlen)88);
    timdef_("get", "system", value, (ftnlen)3, (ftnlen)6, (ftnlen)16);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("VALUE", value, "=", "UTC", ok, (ftnlen)5, (ftnlen)16, (ftnlen)1, 
	    (ftnlen)3);
    timdef_("get", "zone", value, (ftnlen)3, (ftnlen)4, (ftnlen)16);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("VALUE", value, "=", " ", ok, (ftnlen)5, (ftnlen)16, (ftnlen)1, (
	    ftnlen)1);
    timdef_("get", "calendar", value, (ftnlen)3, (ftnlen)8, (ftnlen)16);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("VALUE", value, "=", "GREGORIAN", ok, (ftnlen)5, (ftnlen)16, (
	    ftnlen)1, (ftnlen)9);
    tcase_("Make sure we can set and get SYSTEM UTC, TDT, TDB Make sure Cale"
	    "ndar is not affected and that ZONE returns a blank. ", (ftnlen)
	    116);
    timdef_("set", "system", "tdb", (ftnlen)3, (ftnlen)6, (ftnlen)3);
    timdef_("get", "system", system, (ftnlen)3, (ftnlen)6, (ftnlen)16);
    timdef_("get", "zone", zone, (ftnlen)3, (ftnlen)4, (ftnlen)16);
    timdef_("get", "calendar", calndr, (ftnlen)3, (ftnlen)8, (ftnlen)16);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("SYSTEM", system, "=", "TDB", ok, (ftnlen)6, (ftnlen)16, (ftnlen)
	    1, (ftnlen)3);
    chcksc_("CALNDR", calndr, "=", "GREGORIAN", ok, (ftnlen)6, (ftnlen)16, (
	    ftnlen)1, (ftnlen)9);
    chcksc_("ZONE", zone, "=", " ", ok, (ftnlen)4, (ftnlen)16, (ftnlen)1, (
	    ftnlen)1);
    timdef_("set", "system", "tdt", (ftnlen)3, (ftnlen)6, (ftnlen)3);
    timdef_("get", "system", system, (ftnlen)3, (ftnlen)6, (ftnlen)16);
    timdef_("get", "zone", zone, (ftnlen)3, (ftnlen)4, (ftnlen)16);
    timdef_("get", "calendar", calndr, (ftnlen)3, (ftnlen)8, (ftnlen)16);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("SYSTEM", system, "=", "TDT", ok, (ftnlen)6, (ftnlen)16, (ftnlen)
	    1, (ftnlen)3);
    chcksc_("CALNDR", calndr, "=", "GREGORIAN", ok, (ftnlen)6, (ftnlen)16, (
	    ftnlen)1, (ftnlen)9);
    chcksc_("ZONE", zone, "=", " ", ok, (ftnlen)4, (ftnlen)16, (ftnlen)1, (
	    ftnlen)1);
    timdef_("set", "system", "utc", (ftnlen)3, (ftnlen)6, (ftnlen)3);
    timdef_("get", "system", system, (ftnlen)3, (ftnlen)6, (ftnlen)16);
    timdef_("get", "zone", zone, (ftnlen)3, (ftnlen)4, (ftnlen)16);
    timdef_("get", "calendar", calndr, (ftnlen)3, (ftnlen)8, (ftnlen)16);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("SYSTEM", system, "=", "UTC", ok, (ftnlen)6, (ftnlen)16, (ftnlen)
	    1, (ftnlen)3);
    chcksc_("CALNDR", calndr, "=", "GREGORIAN", ok, (ftnlen)6, (ftnlen)16, (
	    ftnlen)1, (ftnlen)9);
    chcksc_("ZONE", zone, "=", " ", ok, (ftnlen)4, (ftnlen)16, (ftnlen)1, (
	    ftnlen)1);
    tcase_("Make sure we can set and get CALENDAR MIXED, JULIAN, GREGORIAN M"
	    "ake sure that system and zone are not affected. ", (ftnlen)112);
    timdef_("set", "calendar", "Mixed", (ftnlen)3, (ftnlen)8, (ftnlen)5);
    timdef_("get", "system", system, (ftnlen)3, (ftnlen)6, (ftnlen)16);
    timdef_("get", "zone", zone, (ftnlen)3, (ftnlen)4, (ftnlen)16);
    timdef_("get", "calendar", calndr, (ftnlen)3, (ftnlen)8, (ftnlen)16);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("SYSTEM", system, "=", "UTC", ok, (ftnlen)6, (ftnlen)16, (ftnlen)
	    1, (ftnlen)3);
    chcksc_("CALNDR", calndr, "=", "MIXED", ok, (ftnlen)6, (ftnlen)16, (
	    ftnlen)1, (ftnlen)5);
    chcksc_("ZONE", zone, "=", " ", ok, (ftnlen)4, (ftnlen)16, (ftnlen)1, (
	    ftnlen)1);
    timdef_("set", "calendar", "Julian", (ftnlen)3, (ftnlen)8, (ftnlen)6);
    timdef_("get", "system", system, (ftnlen)3, (ftnlen)6, (ftnlen)16);
    timdef_("get", "zone", zone, (ftnlen)3, (ftnlen)4, (ftnlen)16);
    timdef_("get", "calendar", calndr, (ftnlen)3, (ftnlen)8, (ftnlen)16);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("SYSTEM", system, "=", "UTC", ok, (ftnlen)6, (ftnlen)16, (ftnlen)
	    1, (ftnlen)3);
    chcksc_("CALNDR", calndr, "=", "JULIAN", ok, (ftnlen)6, (ftnlen)16, (
	    ftnlen)1, (ftnlen)6);
    chcksc_("ZONE", zone, "=", " ", ok, (ftnlen)4, (ftnlen)16, (ftnlen)1, (
	    ftnlen)1);
    timdef_("set", "calendar", "Gregorian", (ftnlen)3, (ftnlen)8, (ftnlen)9);
    timdef_("get", "system", system, (ftnlen)3, (ftnlen)6, (ftnlen)16);
    timdef_("get", "zone", zone, (ftnlen)3, (ftnlen)4, (ftnlen)16);
    timdef_("get", "calendar", calndr, (ftnlen)3, (ftnlen)8, (ftnlen)16);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("SYSTEM", system, "=", "UTC", ok, (ftnlen)6, (ftnlen)16, (ftnlen)
	    1, (ftnlen)3);
    chcksc_("CALNDR", calndr, "=", "GREGORIAN", ok, (ftnlen)6, (ftnlen)16, (
	    ftnlen)1, (ftnlen)9);
    chcksc_("ZONE", zone, "=", " ", ok, (ftnlen)4, (ftnlen)16, (ftnlen)1, (
	    ftnlen)1);
    tcase_("Make sure we can set and get all of the U.S. time zones. Also ch"
	    "eck that the CALENDAR is not affected and that SYSTEM returns a "
	    "blank. ", (ftnlen)135);
    s_copy(zones, "est", (ftnlen)16, (ftnlen)3);
    s_copy(zones + 16, "edt", (ftnlen)16, (ftnlen)3);
    s_copy(zones + 32, "cst", (ftnlen)16, (ftnlen)3);
    s_copy(zones + 48, "cdt", (ftnlen)16, (ftnlen)3);
    s_copy(zones + 64, "mst", (ftnlen)16, (ftnlen)3);
    s_copy(zones + 80, "mdt", (ftnlen)16, (ftnlen)3);
    s_copy(zones + 96, "pst", (ftnlen)16, (ftnlen)3);
    s_copy(zones + 112, "pdt", (ftnlen)16, (ftnlen)3);
    s_copy(expect, "UTC-5", (ftnlen)16, (ftnlen)5);
    s_copy(expect + 16, "UTC-4", (ftnlen)16, (ftnlen)5);
    s_copy(expect + 32, "UTC-6", (ftnlen)16, (ftnlen)5);
    s_copy(expect + 48, "UTC-5", (ftnlen)16, (ftnlen)5);
    s_copy(expect + 64, "UTC-7", (ftnlen)16, (ftnlen)5);
    s_copy(expect + 80, "UTC-6", (ftnlen)16, (ftnlen)5);
    s_copy(expect + 96, "UTC-8", (ftnlen)16, (ftnlen)5);
    s_copy(expect + 112, "UTC-7", (ftnlen)16, (ftnlen)5);
    for (i__ = 1; i__ <= 8; ++i__) {
	timdef_("set", "zone", zones + (((i__1 = i__ - 1) < 8 && 0 <= i__1 ? 
		i__1 : s_rnge("zones", i__1, "f_timdef__", (ftnlen)187)) << 4)
		, (ftnlen)3, (ftnlen)4, (ftnlen)16);
	timdef_("get", "system", system, (ftnlen)3, (ftnlen)6, (ftnlen)16);
	timdef_("get", "zone", zone, (ftnlen)3, (ftnlen)4, (ftnlen)16);
	timdef_("get", "calendar", calndr, (ftnlen)3, (ftnlen)8, (ftnlen)16);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksc_("SYSTEM", system, "=", " ", ok, (ftnlen)6, (ftnlen)16, (
		ftnlen)1, (ftnlen)1);
	chcksc_("CALNDR", calndr, "=", "GREGORIAN", ok, (ftnlen)6, (ftnlen)16,
		 (ftnlen)1, (ftnlen)9);
	chcksc_("ZONE", zone, "=", expect + (((i__1 = i__ - 1) < 8 && 0 <= 
		i__1 ? i__1 : s_rnge("expect", i__1, "f_timdef__", (ftnlen)
		195)) << 4), ok, (ftnlen)4, (ftnlen)16, (ftnlen)1, (ftnlen)16)
		;
    }
    tcase_("Make sure we can set and get several non-U.S. time zones. ", (
	    ftnlen)58);
    timdef_("set", "zone", "utc+3:19", (ftnlen)3, (ftnlen)4, (ftnlen)8);
    timdef_("get", "system", system, (ftnlen)3, (ftnlen)6, (ftnlen)16);
    timdef_("get", "zone", zone, (ftnlen)3, (ftnlen)4, (ftnlen)16);
    timdef_("get", "calendar", calndr, (ftnlen)3, (ftnlen)8, (ftnlen)16);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("SYSTEM", system, "=", " ", ok, (ftnlen)6, (ftnlen)16, (ftnlen)1, 
	    (ftnlen)1);
    chcksc_("CALNDR", calndr, "=", "GREGORIAN", ok, (ftnlen)6, (ftnlen)16, (
	    ftnlen)1, (ftnlen)9);
    chcksc_("ZONE", zone, "=", "UTC+3:19", ok, (ftnlen)4, (ftnlen)16, (ftnlen)
	    1, (ftnlen)8);
    timdef_("set", "zone", "utc-4:27", (ftnlen)3, (ftnlen)4, (ftnlen)8);
    timdef_("get", "system", system, (ftnlen)3, (ftnlen)6, (ftnlen)16);
    timdef_("get", "zone", zone, (ftnlen)3, (ftnlen)4, (ftnlen)16);
    timdef_("get", "calendar", calndr, (ftnlen)3, (ftnlen)8, (ftnlen)16);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("SYSTEM", system, "=", " ", ok, (ftnlen)6, (ftnlen)16, (ftnlen)1, 
	    (ftnlen)1);
    chcksc_("CALNDR", calndr, "=", "GREGORIAN", ok, (ftnlen)6, (ftnlen)16, (
	    ftnlen)1, (ftnlen)9);
    chcksc_("ZONE", zone, "=", "UTC-4:27", ok, (ftnlen)4, (ftnlen)16, (ftnlen)
	    1, (ftnlen)8);
    tcase_("Make sure that unrecognized ACTIONS trigger an error. ", (ftnlen)
	    54);
    timdef_("put", "zone", "pdt", (ftnlen)3, (ftnlen)4, (ftnlen)3);
    chckxc_(&c_true, "SPICE(BADACTION)", ok, (ftnlen)16);
    tcase_("Make sure that unrecognized ITEMS trigger an error. SET case", (
	    ftnlen)60);
    timdef_("set", "zone", "utc-4:27", (ftnlen)3, (ftnlen)4, (ftnlen)8);
    timdef_("get", "system", system, (ftnlen)3, (ftnlen)6, (ftnlen)16);
    timdef_("get", "zone", zone, (ftnlen)3, (ftnlen)4, (ftnlen)16);
    timdef_("get", "calendar", calndr, (ftnlen)3, (ftnlen)8, (ftnlen)16);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("SYSTEM", system, "=", " ", ok, (ftnlen)6, (ftnlen)16, (ftnlen)1, 
	    (ftnlen)1);
    chcksc_("CALNDR", calndr, "=", "GREGORIAN", ok, (ftnlen)6, (ftnlen)16, (
	    ftnlen)1, (ftnlen)9);
    chcksc_("ZONE", zone, "=", "UTC-4:27", ok, (ftnlen)4, (ftnlen)16, (ftnlen)
	    1, (ftnlen)8);
    timdef_("set", "year", "1950", (ftnlen)3, (ftnlen)4, (ftnlen)4);
    chckxc_(&c_true, "SPICE(BADTIMEITEM)", ok, (ftnlen)18);
    tcase_("Make sure that unrecognized ITEMS trigger an error. GET case", (
	    ftnlen)60);
    timdef_("set", "zone", "utc-4:27", (ftnlen)3, (ftnlen)4, (ftnlen)8);
    timdef_("get", "system", system, (ftnlen)3, (ftnlen)6, (ftnlen)16);
    timdef_("get", "zone", zone, (ftnlen)3, (ftnlen)4, (ftnlen)16);
    timdef_("get", "calendar", calndr, (ftnlen)3, (ftnlen)8, (ftnlen)16);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("SYSTEM", system, "=", " ", ok, (ftnlen)6, (ftnlen)16, (ftnlen)1, 
	    (ftnlen)1);
    chcksc_("CALNDR", calndr, "=", "GREGORIAN", ok, (ftnlen)6, (ftnlen)16, (
	    ftnlen)1, (ftnlen)9);
    chcksc_("ZONE", zone, "=", "UTC-4:27", ok, (ftnlen)4, (ftnlen)16, (ftnlen)
	    1, (ftnlen)8);
    timdef_("GET", "year", value, (ftnlen)3, (ftnlen)4, (ftnlen)16);
    chckxc_(&c_true, "SPICE(BADTIMEITEM)", ok, (ftnlen)18);
    tcase_("Make sure that unrecongized time zones trigger an error. SET cas"
	    "e ", (ftnlen)66);
    timdef_("set", "ZONE", "GMT", (ftnlen)3, (ftnlen)4, (ftnlen)3);
    chckxc_(&c_true, "SPICE(BADDEFAULTVALUE)", ok, (ftnlen)22);
    tcase_("Make sure that unrecognized calendars trigger and error. ", (
	    ftnlen)57);
    timdef_("set", "CALENDAR", "MUSLIM", (ftnlen)3, (ftnlen)8, (ftnlen)6);
    chckxc_(&c_true, "SPICE(BADDEFAULTVALUE)", ok, (ftnlen)22);
    tcase_("Make sure that unrecognized systems trigger an error. ", (ftnlen)
	    54);
    timdef_("set", "SYSTEM", "GMT", (ftnlen)3, (ftnlen)6, (ftnlen)3);
    chckxc_(&c_true, "SPICE(BADDEFAULTVALUE)", ok, (ftnlen)22);

/*     Reset the defaults */

    timdef_("SET", "SYSTEM", "UTC", (ftnlen)3, (ftnlen)6, (ftnlen)3);
    timdef_("SET", "CALENDAR", "GREGORIAN", (ftnlen)3, (ftnlen)8, (ftnlen)9);
    t_success__(ok);
    return 0;
} /* f_timdef__ */

