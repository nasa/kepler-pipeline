/* natspk.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static doublereal c_b4 = 8.;
static doublereal c_b5 = .66666666666666663;
static doublereal c_b6 = 2.;
static doublereal c_b7 = 3.;
static integer c__6 = 6;
static integer c__1000 = 1000;
static integer c__10 = 10;
static integer c__1 = 1;
static doublereal c_b14 = 0.;
static integer c__2000 = 2000;
static integer c__12 = 12;
static integer c__0 = 0;
static integer c__2 = 2;

/* $Procedure NATSPK ( Create an SPK file for Nat's solar system ) */
/* Subroutine */ int natspk_(char *file, logical *load, integer *handle, 
	ftnlen file_len)
{
    /* Initialized data */

    static doublereal xvec[3] = { 1.,0.,0. };
    static doublereal yvec[3] = { 0.,1.,0. };
    static doublereal zvec[3] = { 0.,0.,1. };

    /* System generated locals */
    doublereal d__1;

    /* Builtin functions */
    double pow_dd(doublereal *, doublereal *);
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    doublereal last;
    extern /* Subroutine */ int vscl_(doublereal *, doublereal *, doublereal *
	    );
    doublereal arada, aradb;
    char segid[40];
    extern /* Subroutine */ int chkin_(char *, ftnlen);
    doublereal rbeta, aprog;
    extern doublereal jyear_(void);
    extern /* Subroutine */ int moved_(doublereal *, integer *, doublereal *);
    doublereal first;
    extern /* Subroutine */ int spkw05_(integer *, integer *, integer *, char 
	    *, doublereal *, doublereal *, char *, doublereal *, integer *, 
	    doublereal *, doublereal *, ftnlen, ftnlen), spkw08_(integer *, 
	    integer *, integer *, char *, doublereal *, doublereal *, char *, 
	    integer *, integer *, doublereal *, doublereal *, doublereal *, 
	    ftnlen, ftnlen);
    extern integer rtrim_(char *, ftnlen);
    extern doublereal twopi_(void);
    doublereal sunst[12]	/* was [6][2] */;
    extern /* Subroutine */ int vrotv_(doublereal *, doublereal *, doublereal 
	    *, doublereal *);
    doublereal omegaa, omegab;
    extern /* Subroutine */ int cleard_(integer *, doublereal *), dafcls_(
	    integer *);
    doublereal speeda, mu, speedb, ralpha, deltao;
    extern doublereal clight_(void);
    extern /* Subroutine */ int kilfil_(char *, ftnlen);
    integer myhand;
    doublereal statea[6], stateb[6];
    extern /* Subroutine */ int spklef_(char *, integer *, ftnlen), tfiles_(
	    char *, ftnlen), chkout_(char *, ftnlen), spcopn_(char *, char *, 
	    integer *, ftnlen, ftnlen);
    doublereal tstate[6], n323;

/* $ Abstract */

/*     Create an SPK file for Nat's solar system. */

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

/*      None. */

/* $ Keywords */

/*       TESTING */
/*       SPK */

/* $ Declarations */
/* $ Brief_I/O */

/*      VARIABLE  I/O  DESCRIPTION */
/*      --------  ---  -------------------------------------------------- */
/*      FILE       I   The name of an SPK file to create. */
/*      LOAD       I   Logical indicating if file should be loaded. */
/*      HANDLE     O   Handle if file is loaded by NATSPK. */

/* $ Detailed_Input */

/*     FILE        is the name of an SPK file to create for use in */
/*                 software testing. */

/*                 If the file specified already exists, the existing */
/*                 file is deleted and a new one created with the */
/*                 same name in its place. */

/*                 See Files for a description of the SPK file. */


/*     LOAD        is a logical flag indicating whether or not the */
/*                 created SPK file should be loaded.  If LOAD is TRUE */
/*                 the file is loaded.  If LOAD is FALSE the file is */
/*                 not loaded by this routine. */

/* $ Detailed_Output */

/*     HANDLE      is the handle attached to the SPK file if LOAD is */
/*                 true. */

/* $ Parameters */

/*      None. */

/* $ Exceptions */

/*     1) If the specified file already exists, it is deleted and */
/*        replaced by the file created by this routine. */

/*     2) All other exceptions are diagnosed by routines in the call tree */
/*        of this routine. */

/*     Since this routine is normally used within the TSPICE system, */
/*     it's up the the caller to call CHCKXC to catch errors signaled by */
/*     this routine. */

/* $ Files */

/*     This SPK file represents a contrived "solar system" containing a */
/*     "sun" and two planets, ALPHA and BETA.  The sun has zero offset */
/*     from the solar system barycenter. Both planets orbit the sun with */
/*     circular two-body motion.  BETA orbits closer to the sun than */
/*     ALPHA.  When the radii of BETA and ALPHA are set appropriately, */
/*     BETA occults ALPHA as seen from the center of the sun at regular */
/*     intervals: */

/*        With */

/*          aberration correction NONE */

/*        Occultation starts:        2000 JAN 1 12:00:00 TDB */
/*                                   and recurs every 24 hours */

/*        Occultation ends:          2000 JAN 1 12:10:00 TDB */
/*                                   and recurs every 24 hours */

/*        With */

/*          aberration correction LT */

/*        Occultation starts:        2000 JAN 1 12:00:01 TDB */
/*                                   and recurs every 24 hours */

/*        Occultation ends:          2000 JAN 1 12:10:01 TDB */
/*                                   and recurs every 24 hours */

/*     At the J2000 epoch, the vector from the center of the */
/*     sun to the center of body ALPHA lies on the +X axis of */
/*     the J2000 frame. */

/*     The default time range covered by the file is approximately */

/*        1899 DEC 31 12:00:00 TDB */
/*        2100 DEC 31 12:00:00 TDB */


/*     The following parameters control the behavior of this */
/*     solar system: */

/*        N1:       Occultation duration, seconds */
/*        N2:       Ratio of angular size of alpha to that of beta */
/*        N3:       Ratio of angular velocity of beta to that of alpha */
/*        N4:       Time between occultations, seconds */
/*        BASELT:   Offset of occultation time with LT correction, */
/*                  seconds. */

/*     If these parameters are changed, the radii of ALPHA and */
/*     BETA must be re-computed. */

/*     Below we derive the constants needed to create the ephemeris */
/*     for the planets, as well as their radii. */

/*     Relationships between angular velocities, orbital radii: */


/*        OMEGA       = N  * OMEGA         (definition) */
/*             beta      3        alpha */


/*        N4 is time between occultations: */

/*        ( OMEGA     - OMEGA     ) * N4  =  2 * Pi */
/*               beta        alpha */


/*        OMEGA                   =  2 * Pi /  ( N4 * ( N3 - 1 ) ) */
/*             alpha */


/*                 2                      2                 2 */
/*        ACC  =  V  / R          =  OMEGA  * R    =  GM / R */
/*           i     i    i                 i    i            i */


/*                                           3   1/2 */
/*        OMEGA                   =  ( GM / R  ) */
/*             i                             i */

/*                                                   3/2 */
/*        OMEGA     / OMEGA       = ( R      / R    )     =  N */
/*             beta        alpha       alpha    beta          3 */


/*                  2/3 */
/*        R      = N     *  R */
/*         alpha    3        beta */


/*        OMEGA      =  OMEGA     -  OMEGA       (definition) */
/*             delta         beta         alpha */


/*     Central GM: */

/*                  2 */
/*        GM = OMEGA       / R */
/*                  alpha     alpha */


/*     Light time correction---relationship between orbital radius and */
/*     time offset of occultation when light time correction is used: */


/*        THETA   = -LT  * OMEGA */
/*             i       i        i */

/*        GAMMA   = THETA  + OMEGA  * BASELT */
/*             i         i        i */

/*        GAMMA      = GAMMA       => */
/*             alpha        beta */

/*        OMEGA     ( BASELT - LT     ) = OMEGA    ( BASELT - LT    ) => */
/*             alpha             alpha         beta             beta */


/*        BASELT - R     /c  =  N * ( BASELT - R    /c ) => */
/*                  alpha        3              beta */


/*                  2/3 */
/*        BASELT - N    * R    /c  =  N * ( BASELT - R    /c ) => */
/*                  3      beta        3              beta */

/*                             2/3 */
/*        ( R    / c ) ( N  - N   )   =  BASELT * ( N  - 1 ) => */
/*           beta         3    3                     3 */

/*                                                    2/3 */
/*        R     =  c * BASELT * ( N  - 1 ) / ( N   - N    ) */
/*         beta                    3            3     3 */


/*     Ratio of angular sizes of Alpha and Beta: */

/*        N2 = ARAD     / ARAD         (definition) */
/*                 alpha      beta */


/*     Occultation duration: */

/*        N1 = duration (definition) */


/*     Angular movement of beta past alpha during occultation, definition */
/*     of angular size of beta: */

/*        PROG = N1 * OMEGA */
/*                         delta */

/*        From start to finish of occultation, beta moves past alpha */
/*        by the angular diameter of alpha plus 2*the angular radius */
/*        of beta: */

/*        PROG      = 2 * ( ARAD      + ARAD    ) */
/*                              alpha       beta */

/*                  = 2 * ARAD     ( 1 + N2 )   => */
/*                            beta */

/*        ARAD      = N1 * OMEGA      / ( 2 * (1 + N2) ) */
/*            beta              delta */


/*     Radii of alpha, beta: */

/*        RAD  =  R  * sin ( ARAD ) */
/*           i     i             i */


/* $ Particulars */

/*     This routine creates the SPK file described above in the header */
/*     section Files. The radii of the planets must be those provided by */
/*     the PCK created by NATPCK. */

/*     If file designated by the input argument FILE already exists, */
/*     it is deleted prior to the creation of the SPK file. */

/* $ Examples */

/*     The normal way to use this routine is shown below. */

/*     CALL NATSPK ( 'nat.bsp', .TRUE., HANDLE  ) */
/*     CALL NATPCK ( 'nat.tpc', .TRUE., .FALSE. ) */

/*        [perform some tests and computations] */

/*     CALL SPKUEF ( HANDLE ) */
/*     CALL KILFIL ( 'nat.bsp' ) */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*      N.J. Bachman    (JPL) */

/* $ Literature_References */

/*      None. */

/* $ Version */

/* -    Test Utilities 1.1.0, 10-NOV-2005 (NJB) */

/*        Updated to remove non-standard use of duplicate */
/*        arguments in VROTV calls. */

/* -    Test Utilities 1.0.0, 29-SEP-2004 (NJB) */

/* -& */
/* $ Index_Entries */

/*     Create a "Nat's solar system" SPK file */

/* -& */

/*     SPICELIB functions */


/*     Local parameters */


/*     The current (2004/09/29) values of the parameters imply */

/*        Radius of ALPHA = 0.36624698766937712D+05 km */
/*        Radius of BETA  = 0.22891526271046937D+04 km */


/*     Local variables */


/*     Declarations for RADA and RADB are needed if the lines of code */
/*     computing these items are un-commented. */

/*      DOUBLE PRECISION      RADA */
/*      DOUBLE PRECISION      RADB */


/*     Saved variables */


/*     Initial values */

    chkin_("NATSPK", (ftnlen)6);

/*     Wipe out any existing file with the target name.  Then open */
/*     a new SPC file for writing. */

    kilfil_(file, file_len);
    spcopn_(file, "TestUtilitySPK", &myhand, file_len, (ftnlen)14);

/*     Now just construct the state information needed to create */
/*     segments for objects ALPHA and BETA. */

/*     Define the distances RBETA and RALPHA.  RBETA is the distance */
/*     light travels in */


/*        BASELT * ( 1 - N3 ) / ( N3**(2/3) - N3 ) */

/*     seconds. */

/*     RALPHA is */

/*          (2/3) */
/*        N       * RBETA */
/*         3 */


/*     This power of */

/*        N */
/*         3 */

/*     comes up a lot, so we allocate a variable for it. */


    n323 = pow_dd(&c_b4, &c_b5);
    rbeta = clight_() * 1. * -7 / (n323 - 8);
    ralpha = n323 * rbeta;

/*     Set the angular rates of bodies alpha and beta. */

    omegaa = twopi_() / 604800.;
    omegab = omegaa * 8;

/*     Get the differential angular velocity. */

    deltao = omegab - omegaa;

/*     Set the central GM value. */

    mu = pow_dd(&omegaa, &c_b6) * pow_dd(&ralpha, &c_b7);

/*     Set the angular radii of bodies ALPHA and BETA.  We want */
/*     the occultation to last N1 seconds.  If the angular */
/*     size of ALPHA is N2 times the angular size of BETA, then */
/*     BETA must make angular progress of (N2+1) * the angular */
/*     size of beta, relative to ALPHA, in N1 seconds. */

    aprog = deltao * 600;
    aradb = aprog / 5 / 2;
    arada = aradb * 4;

/*     Set the radii of ALPHA and BETA.  These lines of code can be */
/*     used to reconstitute the radius values; however they're not */
/*     needed in this routine. */

/*      RADA  = RALPHA * SIN(ARADA) */
/*      RADB  = RBETA  * SIN(ARADB) */

/*     Set the initial positions.  We start by making both objects */
/*     line up on the +X axis at J2000 TDB.  Later, we'll rotate */
/*     body BETA to make an occultation start at this epoch. */

    vscl_(&ralpha, xvec, statea);
    vscl_(&rbeta, xvec, stateb);

/*     Set the initial velocities.  Both objects are traveling in the */
/*     +y direction at J2000 TDB. */

    speeda = ralpha * omegaa;
    speedb = rbeta * omegab;
    vscl_(&speeda, yvec, &statea[3]);
    vscl_(&speedb, yvec, &stateb[3]);

/*     Now rotate the state of BETA by -(ARADA+ARADB) about +Z to make */
/*     objects ALPHA and BETA appear to be tangent at the current */
/*     epoch, as seen from the origin. */

    d__1 = -(arada + aradb);
    vrotv_(stateb, zvec, &d__1, tstate);
    d__1 = -(arada + aradb);
    vrotv_(&stateb[3], zvec, &d__1, &tstate[3]);
    moved_(tstate, &c__6, stateb);
    first = jyear_() * -100.;
    last = jyear_() * 100.;
    s_copy(segid, "Outer object alpha", (ftnlen)40, (ftnlen)18);
    spkw05_(&myhand, &c__1000, &c__10, "J2000", &first, &last, segid, &mu, &
	    c__1, statea, &c_b14, (ftnlen)5, (ftnlen)40);
    s_copy(segid, "Inner object beta", (ftnlen)40, (ftnlen)17);
    spkw05_(&myhand, &c__2000, &c__10, "J2000", &first, &last, segid, &mu, &
	    c__1, stateb, &c_b14, (ftnlen)5, (ftnlen)40);

/*     Create a type 8 segment for the sun. */

    s_copy(segid, "Motionless sun at SSB", (ftnlen)40, (ftnlen)21);
    cleard_(&c__12, sunst);
    d__1 = last - first;
    spkw08_(&myhand, &c__10, &c__0, "J2000", &first, &last, segid, &c__1, &
	    c__2, sunst, &first, &d__1, (ftnlen)5, (ftnlen)40);

/*     Close the SPK file. */

    dafcls_(&myhand);

/*     If the user wants this file loaded, now is the time to do it. */

    if (*load) {
	spklef_(file, handle, rtrim_(file, file_len));
    }

/*     Register this file with FILREG so it will automatically be */
/*     removed when a new test family is initialized. */

    tfiles_(file, file_len);
    chkout_("NATSPK", (ftnlen)6);
    return 0;
} /* natspk_ */

