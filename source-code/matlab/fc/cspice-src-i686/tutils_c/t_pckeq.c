/* t_pckeq.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* $Procedure      T_PCKEQ ( Text PCK equation implementation ) */
/* Subroutine */ int t_pckeq__(integer *body, doublereal *et, doublereal *ra, 
	doublereal *dec, doublereal *pm)
{
    /* System generated locals */
    doublereal d__1;

    /* Builtin functions */
    double sin(doublereal), cos(doublereal);

    /* Local variables */
    doublereal d__, n, t, w;
    extern /* Subroutine */ int chkin_(char *, ftnlen);
    doublereal a0, d0, e1, e2, e3, e4, e5, e6, e7, e8, e9, j1, j2, j3, j4, j5,
	     j6, j7, j8, m1, m2, m3, n1, n2, n3, n4, n5, n6, n7, s1, s2, s3, 
	    s4, s5, s6, s7, u1, u2, u3, u4, u5, u6, u7, u8, u9, e10, e11, e12,
	     e13, u10, u11, u12, u13, u14, u15, u16;
    extern /* Subroutine */ int sigerr_(char *, ftnlen), chkout_(char *, 
	    ftnlen), setmsg_(char *, ftnlen), errint_(char *, integer *, 
	    ftnlen);
    extern doublereal rpd_(void), spd_(void);

/* $ Abstract */

/*     This routine contains direct, in-line implementations of the 2000 */
/*     IAU report's Euler angle equations giving attitude of the sun, */
/*     planets, natural satellites, and asteroids. */

/*     This routine supports tests of the SPICELIB routines */

/*        BODEUL */
/*        BODMAT (indirectly, via call to TIPBOD) */
/*        TIPBOD */

/*     performed by the test family F_RDPCK. */

/*     Results of computations done by this routine are compared with */
/*     results of computations implemented in the above SPICELIB */
/*     routines.  This testing approach attempts to validate orientation */
/*     computations done using text PCK data by comparing their results */
/*     to those obtained via an alternate computational approach. */

/*     These tests also serve to mininize the chance of transcription */
/*     error when a new PCK version is created.  Entering the PCK */
/*     constants both in the new PCK file and in T_PCKEQ enables */
/*     double-checking of the constants. */

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

/* -    TSPICE Version 1.0.0, 10-FEB-2004 (NJB) */

/* -& */

/*     SPICELIB functions */


/*     Local variables */

    chkin_("T_PCKEQ", (ftnlen)7);
    d__ = *et / spd_();
    t = d__ / 36525.;
    if (*body == 10) {
	a0 = 286.13;
	d0 = 63.87;
	w = d__ * 14.1844 + 84.1;
    } else if (*body == 199) {
	a0 = 281.01 - t * .033;
	d0 = 61.45 - t * .005;
	w = d__ * 6.1385025 + 329.548;
    } else if (*body == 299) {
	a0 = 272.76;
	d0 = 67.16;
	w = 160.2 - d__ * 1.4813688;
    } else if (*body == 399) {
	a0 = 0. - t * .641;
	d0 = 90. - t * .557;
	w = d__ * 360.9856235 + 190.147;
    } else if (*body == 499) {
	a0 = 317.68143 - t * .1061;
	d0 = 52.8865 - t * .0609;
	w = d__ * 350.89198226 + 176.63;
    } else if (*body == 599) {
	a0 = 268.05 - t * .009;
	d0 = t * .003 + 64.49;
	w = d__ * 870.536642 + 284.95;
    } else if (*body == 699) {
	a0 = 40.589 - t * .036;
	d0 = 83.537 - t * .004;
	w = d__ * 810.7939024 + 38.9;
    } else if (*body == 799) {
	a0 = 257.311;
	d0 = -15.175;
	w = 203.81 - d__ * 501.1600928;
    } else if (*body == 899) {
	n = rpd_() * (t * 52.316 + 357.85);
	a0 = sin(n) * .7 + 299.36;
	d0 = 43.46 - cos(n) * .51;
	w = d__ * 536.3128492 + 253.18 - sin(n) * .48;
    } else if (*body == 999) {
	a0 = 313.02;
	d0 = 9.09;
	w = 236.77 - d__ * 56.3623195;
    } else if (*body == 301) {
	e1 = (125.045 - d__ * .0529921) * rpd_();
	e2 = (250.089 - d__ * .1059842) * rpd_();
	e3 = (d__ * 13.0120009 + 260.008) * rpd_();
	e4 = (d__ * 13.3407154 + 176.625) * rpd_();
	e5 = (d__ * .9856003 + 357.529) * rpd_();
	e6 = (d__ * 26.4057084 + 311.589) * rpd_();
	e7 = (d__ * 13.064993 + 134.963) * rpd_();
	e8 = (d__ * .3287146 + 276.617) * rpd_();
	e9 = (d__ * 1.7484877 + 34.226) * rpd_();
	e10 = (15.134 - d__ * .1589763) * rpd_();
	e11 = (d__ * .0036096 + 119.743) * rpd_();
	e12 = (d__ * .1643573 + 239.961) * rpd_();
	e13 = (d__ * 12.9590088 + 25.053) * rpd_();
	a0 = t * .0031 + 269.9949 - sin(e1) * 3.8787 - sin(e2) * .1204 + sin(
		e3) * .07 - sin(e4) * .0172 + sin(e6) * .0072 - sin(e10) * 
		.0052 + sin(e13) * .0043;
	d0 = t * .013 + 66.5392 + cos(e1) * 1.5419 + cos(e2) * .0239 - cos(e3)
		 * .0278 + cos(e4) * .0068 - cos(e6) * .0029 + cos(e7) * 9e-4 
		+ cos(e10) * 8e-4 - cos(e13) * 9e-4;
/* Computing 2nd power */
	d__1 = d__;
	w = d__ * 13.17635815 + 38.3213 - d__1 * d__1 * 1.4e-12 + sin(e1) * 
		3.561 + sin(e2) * .1208 - sin(e3) * .0642 + sin(e4) * .0158 + 
		sin(e5) * .0252 - sin(e6) * .0066 - sin(e7) * .0047 - sin(e8) 
		* .0046 + sin(e9) * .0028 + sin(e10) * .0052 + sin(e11) * 
		.004 + sin(e12) * .0019 - sin(e13) * .0044;
    } else if (*body / 100 == 4) {

/*        Two expressions for M2 are shown:  one with the quadradic */
/*        term, one without.  The kernel pool software cannot handle */
/*        the quadradic term; trying both of these expressions allows */
/*        the user to observe the effect of ignoring that term. */

	m1 = (169.51 - d__ * .435764) * rpd_();
/*        M2 = ( 192.93D0  + 1128.4096700D0 * D  +  8.864D0*T*T ) * RPD() */
	m2 = (d__ * 1128.40967 + 192.93) * rpd_();
	m3 = (53.47 - d__ * .018151) * rpd_();
	if (*body == 401) {
	    a0 = 317.68 - t * .108 + sin(m1) * 1.79;
	    d0 = 52.9 - t * .061 - cos(m1) * 1.08;
	    w = d__ * 1128.844585 + 35.06 + t * 8.864 * t - sin(m1) * 1.42 - 
		    sin(m2) * .78;
	} else if (*body == 402) {
	    a0 = 316.65 - t * .108 + sin(m3) * 2.98;
	    d0 = 53.52 - t * .061 - cos(m3) * 1.78;
	    w = d__ * 285.161897 + 79.41 - t * .52 * t - sin(m3) * 2.58 + cos(
		    m3) * .19;
	} else {
	    setmsg_("Body code # was not recognized.", (ftnlen)31);
	    errint_("#", body, (ftnlen)1);
	    sigerr_("SPICE(INVALIDBODYCODE)", (ftnlen)22);
	    chkout_("T_PCKEQ", (ftnlen)7);
	    return 0;
	}
    } else if (*body / 100 == 5) {
	j1 = (t * 91472.9 + 73.32) * rpd_();
	j2 = (t * 45137.2 + 24.62) * rpd_();
	j3 = (t * 4850.7 + 283.9) * rpd_();
	j4 = (t * 1191.3 + 355.8) * rpd_();
	j5 = (t * 262.1 + 119.9) * rpd_();
	j6 = (t * 64.3 + 229.8) * rpd_();
	j7 = (t * 2382.6 + 352.35) * rpd_();
	j8 = (t * 6070. + 113.35) * rpd_();
	if (*body == 501) {
	    a0 = 268.05 - t * .009 + sin(j3) * .094 + sin(j4) * .024;
	    d0 = t * .003 + 64.5 + cos(j3) * .04 + cos(j4) * .011;
	    w = d__ * 203.4889538 + 200.39 - sin(j3) * .085 - sin(j4) * .022;
	} else if (*body == 502) {
	    a0 = 268.08 - t * .009 + sin(j4) * 1.086 + sin(j5) * .06 + sin(j6)
		     * .015 + sin(j7) * .009;
	    d0 = t * .003 + 64.51 + cos(j4) * .468 + cos(j5) * .026 + cos(j6) 
		    * .007 + cos(j7) * .002;
	    w = d__ * 101.3747235 + 36.022 - sin(j4) * .98 - sin(j5) * .054 - 
		    sin(j6) * .014 - sin(j7) * .008;
	} else if (*body == 503) {
	    a0 = 268.2 - t * .009 - sin(j4) * .037 + sin(j5) * .431 + sin(j6) 
		    * .091;
	    d0 = t * .003 + 64.57 - cos(j4) * .016 + cos(j5) * .186 + cos(j6) 
		    * .039;
	    w = d__ * 50.3176081 + 44.064 + sin(j4) * .033 - sin(j5) * .389 - 
		    sin(j6) * .082;
	} else if (*body == 504) {
	    a0 = 268.72 - t * .009 - sin(j5) * .068 + sin(j6) * .59 + sin(j8) 
		    * .01;
	    d0 = t * .003 + 64.83 - cos(j5) * .029 + cos(j6) * .254 - cos(j8) 
		    * .004;
	    w = d__ * 21.5710715 + 259.51 + sin(j5) * .061 - sin(j6) * .533 - 
		    sin(j8) * .009;
	} else if (*body == 505) {
	    a0 = 268.05 - t * .009 - sin(j1) * .84 + sin(j1 * 2.) * .01;
	    d0 = t * .003 + 64.49 - cos(j1) * .36;
	    w = d__ * 722.631456 + 231.67 + sin(j1) * .76 - sin(j1 * 2.) * 
		    .01;
	} else if (*body == 514) {
	    a0 = 268.05 - t * .009 - sin(j2) * 2.11 + sin(j2 * 2.) * .04;
	    d0 = t * .003 + 64.49 - cos(j2) * .91 + cos(j2 * 2.) * .01;
	    w = d__ * 533.70041 + 8.56 + sin(j2) * 1.91 - sin(j2 * 2.) * .04;
	} else if (*body == 515) {
	    a0 = 268.05 - t * .009;
	    d0 = t * .003f + 64.49;
	    w = d__ * 1206.9986602 + 33.29;
	} else if (*body == 516) {
	    a0 = 268.05 - t * .009;
	    d0 = t * .003f + 64.49;
	    w = d__ * 1221.2547301 + 346.09;
	} else {
	    setmsg_("Body code # was not recognized.", (ftnlen)31);
	    errint_("#", body, (ftnlen)1);
	    sigerr_("SPICE(INVALIDBODYCODE)", (ftnlen)22);
	    chkout_("T_PCKEQ", (ftnlen)7);
	    return 0;
	}
    } else if (*body / 100 == 6) {
	s1 = (t * 75706.7 + 353.32) * rpd_();
	s2 = (t * 75706.7 + 28.72) * rpd_();
	s3 = (177.4 - t * 36505.5) * rpd_();
	s4 = (300. - t * 7225.9) * rpd_();
	s5 = (t * 506.2 + 316.45) * rpd_();
	s6 = (345.2 - t * 1016.3) * rpd_();
	s7 = (29.8 - t * 52.1) * rpd_();
	if (*body == 601) {
	    a0 = 40.66 - t * .036 + sin(s3) * 13.56;
	    d0 = 83.52 - t * .004 - cos(s3) * 1.53;
	    w = d__ * 381.994555 + 337.46 - sin(s3) * 13.48 - sin(s5) * 44.85;
	} else if (*body == 602) {
	    a0 = 40.66 - t * .036;
	    d0 = 83.52 - t * .004;
	    w = d__ * 262.7318996 + 2.82;
	} else if (*body == 603) {
	    a0 = 40.66 - t * .036 + sin(s4) * 9.66;
	    d0 = 83.52 - t * .004 - cos(s4) * 1.09;
	    w = d__ * 190.6979085 + 10.45 - sin(s4) * 9.6 + sin(s5) * 2.23;
	} else if (*body == 604) {
	    a0 = 40.66 - t * .036;
	    d0 = 83.52 - t * .004;
	    w = d__ * 131.5349316 + 357.;
	} else if (*body == 605) {
	    a0 = 40.38 - t * .036 + sin(s6) * 3.1;
	    d0 = 83.55 - t * .004 - cos(s6) * .35;
	    w = d__ * 79.6900478 + 235.16 - sin(s6) * 3.08;
	} else if (*body == 606) {
	    a0 = 36.41 - t * .036 + sin(s7) * 2.66;
	    d0 = 83.94 - t * .004 - cos(s7) * .3;
	    w = d__ * 22.5769768 + 189.64 - sin(s7) * 2.64;
	} else if (*body == 608) {
	    a0 = 318.16 - t * 3.949;
	    d0 = 75.03 - t * 1.143;
	    w = d__ * 4.5379572 + 350.2;
	} else if (*body == 609) {
	    a0 = 355.;
	    d0 = 68.7;
	    w = d__ * 930.833872 + 304.7;
	} else if (*body == 610) {
	    a0 = 40.58 - t * .036 - sin(s2) * 1.623 + sin(s2 * 2.) * .023;
	    d0 = 83.52 - t * .004 - cos(s2) * .183 + cos(s2 * 2.) * .001;
	    w = d__ * 518.2359876 + 58.83 + sin(s2) * 1.613 - sin(s2 * 2.) * 
		    .023;
	} else if (*body == 611) {
	    a0 = 40.58 - t * .036 - sin(s1) * 3.153 + sin(s1 * 2.) * .086;
	    d0 = 83.52 - t * .004 - cos(s1) * .356 + cos(s1 * 2.) * .005;
	    w = d__ * 518.4907239 + 293.87 + sin(s1) * 3.133 - sin(s1 * 2.) * 
		    .086;
	} else if (*body == 612) {
	    a0 = 40.85 - t * .036;
	    d0 = 83.34 - t * .004;
	    w = d__ * 131.6174056 + 245.12;
	} else if (*body == 613) {
	    a0 = 50.51 - t * .036;
	    d0 = 84.06 - t * .004;
	    w = d__ * 190.6979332 + 56.88;
	} else if (*body == 614) {
	    a0 = 36.41 - t * .036;
	    d0 = 85.04 - t * .004;
	    w = d__ * 190.6742373 + 153.51;
	} else if (*body == 615) {
	    a0 = 40.58 - t * .036;
	    d0 = 83.53 - t * .004;
	    w = d__ * 598.306 + 137.88;
	} else if (*body == 616) {
	    a0 = 40.58 - t * .036;
	    d0 = 83.53 - t * .004;
	    w = d__ * 587.289 + 296.14;
	} else if (*body == 617) {
	    a0 = 40.58 - t * .036;
	    d0 = 83.53 - t * .004;
	    w = d__ * 572.7891 + 162.92;
	} else if (*body == 618) {
	    a0 = 40.6 - t * .036;
	    d0 = 83.5 - t * .004;
	    w = d__ * 626.044 + 48.8;
	} else {
	    setmsg_("Body code # was not recognized.", (ftnlen)31);
	    errint_("#", body, (ftnlen)1);
	    sigerr_("SPICE(INVALIDBODYCODE)", (ftnlen)22);
	    chkout_("T_PCKEQ", (ftnlen)7);
	    return 0;
	}
    } else if (*body / 100 == 7) {
	u1 = (t * 54991.87 + 115.75) * rpd_();
	u2 = (t * 41887.66 + 141.69) * rpd_();
	u3 = (t * 29927.35 + 135.03) * rpd_();
	u4 = (t * 25733.59 + 61.77) * rpd_();
	u5 = (t * 24471.46 + 249.32) * rpd_();
	u6 = (t * 22278.41 + 43.86) * rpd_();
	u7 = (t * 20289.42 + 77.66) * rpd_();
	u8 = (t * 16652.76 + 157.36) * rpd_();
	u9 = (t * 12872.63 + 101.81) * rpd_();
	u10 = (t * 8061.81 + 138.64) * rpd_();
	u11 = (102.23 - t * 2024.22) * rpd_();
	u12 = (t * 2863.96 + 316.41) * rpd_();
	u13 = (304.01 - t * 51.94) * rpd_();
	u14 = (308.71 - t * 93.17) * rpd_();
	u15 = (340.82 - t * 75.32) * rpd_();
	u16 = (259.14 - t * 504.81) * rpd_();
	if (*body == 701) {
	    a0 = sin(u13) * .29 + 257.43;
	    d0 = cos(u13) * .28 - 15.1;
	    w = 156.22 - d__ * 142.8356681 + sin(u12) * .05 + sin(u13) * .08;
	} else if (*body == 702) {
	    a0 = sin(u14) * .21 + 257.43;
	    d0 = cos(u14) * .2 - 15.1;
	    w = 108.05 - d__ * 86.8688923 - sin(u12) * .09 + sin(u14) * .06;
	} else if (*body == 703) {
	    a0 = sin(u15) * .29 + 257.43;
	    d0 = cos(u15) * .28 - 15.1;
	    w = 77.74 - d__ * 41.3514316 + sin(u15) * .08;
	} else if (*body == 704) {
	    a0 = sin(u16) * .16 + 257.43;
	    d0 = cos(u16) * .16 - 15.1;
	    w = 6.77 - d__ * 26.7394932 + sin(u16) * .04;
	} else if (*body == 705) {
	    a0 = sin(u11) * 4.41 + 257.43 - sin(u11 * 2.) * .04;
	    d0 = cos(u11) * 4.25 - 15.08 - cos(u11 * 2.) * .02;
	    w = 30.7 - d__ * 254.6906892 - sin(u12) * 1.27 + sin(u12 * 2.) * 
		    .15 + sin(u11) * 1.15 - sin(u11 * 2.) * .09;
	} else if (*body == 706) {
	    a0 = 257.31 - sin(u1) * .15;
	    d0 = cos(u1) * .14 - 15.18;
	    w = 127.69 - d__ * 1074.520573 - sin(u1) * .04;
	} else if (*body == 707) {
	    a0 = 257.31 - sin(u2) * .09;
	    d0 = cos(u2) * .09 - 15.18;
	    w = 130.35 - d__ * 956.406815 - sin(u2) * .03;
	} else if (*body == 708) {
	    a0 = 257.31 - sin(u3) * .16;
	    d0 = cos(u3) * .16 - 15.18;
	    w = 105.46 - d__ * 828.391476 - sin(u3) * .04;
	} else if (*body == 709) {
	    a0 = 257.31 - sin(u4) * .04;
	    d0 = cos(u4) * .04 - 15.18;
	    w = 59.16 - d__ * 776.581632 - sin(u4) * .01;
	} else if (*body == 710) {
	    a0 = 257.31 - sin(u5) * .17;
	    d0 = cos(u5) * .16 - 15.18;
	    w = 95.08 - d__ * 760.053169 - sin(u5) * .04;
	} else if (*body == 711) {
	    a0 = 257.31 - sin(u6) * .06;
	    d0 = cos(u6) * .06 - 15.18;
	    w = 302.56 - d__ * 730.125366 - sin(u6) * .02;
	} else if (*body == 712) {
	    a0 = 257.31 - sin(u7) * .09;
	    d0 = cos(u7) * .09 - 15.18;
	    w = 25.03 - d__ * 701.486587 - sin(u7) * .02;
	} else if (*body == 713) {
	    a0 = 257.31 - sin(u8) * .29;
	    d0 = cos(u8) * .28 - 15.18;
	    w = 314.9 - d__ * 644.631126 - sin(u8) * .08;
	} else if (*body == 714) {
	    a0 = 257.31 - sin(u9) * .03;
	    d0 = cos(u9) * .03 - 15.18;
	    w = 297.46 - d__ * 577.362817 - sin(u9) * .01;
	} else if (*body == 715) {
	    a0 = 257.31 - sin(u10) * .33;
	    d0 = cos(u10) * .31 - 15.18;
	    w = 91.24 - d__ * 472.545069 - sin(u10) * .09;
	} else {
	    setmsg_("Body code # was not recognized.", (ftnlen)31);
	    errint_("#", body, (ftnlen)1);
	    sigerr_("SPICE(INVALIDBODYCODE)", (ftnlen)22);
	    chkout_("T_PCKEQ", (ftnlen)7);
	    return 0;
	}
    } else if (*body / 100 == 8) {
	n = (t * 52.316 + 357.85) * rpd_();
	n1 = (t * 62606.6 + 323.92) * rpd_();
	n2 = (t * 55064.2 + 220.51) * rpd_();
	n3 = (t * 46564.5 + 354.27) * rpd_();
	n4 = (t * 26109.4 + 75.31) * rpd_();
	n5 = (t * 14325.4 + 35.36) * rpd_();
	n6 = (t * 2824.6 + 142.61) * rpd_();
	n7 = (t * 52.316 + 177.85) * rpd_();
	if (*body == 801) {
	    a0 = 299.36 - sin(n7) * 32.35 - sin(n7 * 2.) * 6.28 - sin(n7 * 3.)
		     * 2.08 - sin(n7 * 4.) * .74 - sin(n7 * 5.) * .28 - sin(
		    n7 * 6.) * .11 - sin(n7 * 7.) * .07 - sin(n7 * 8.) * .02 
		    - sin(n7 * 9.) * .01;
	    d0 = cos(n7) * 22.55 + 41.17 + cos(n7 * 2.) * 2.1 + cos(n7 * 3.) *
		     .55 + cos(n7 * 4.) * .16 + cos(n7 * 5.) * .05 + cos(n7 * 
		    6.) * .02 + cos(n7 * 7.) * .01;
	    w = 296.53 - d__ * 61.2572637 + sin(n7) * 22.25 + sin(n7 * 2.) * 
		    6.73 + sin(n7 * 3.) * 2.05 + sin(n7 * 4.) * .74 + sin(n7 *
		     5.) * .28 + sin(n7 * 6.) * .11 + sin(n7 * 7.) * .05 + 
		    sin(n7 * 8.) * .02 + sin(n7 * 9.) * .01;
	} else if (*body == 803) {
	    a0 = sin(n) * .7 + 299.36 - sin(n1) * 6.49 + sin(n1 * 2.) * .25;
	    d0 = 43.36 - cos(n) * .51 - cos(n1) * 4.75 + cos(n1 * 2.) * .09;
	    w = d__ * 1222.8441209 + 254.06 - sin(n) * .48 + sin(n1) * 4.4 - 
		    sin(n1 * 2.) * .27;
	} else if (*body == 804) {
	    a0 = sin(n) * .7 + 299.36 - sin(n2) * .28;
	    d0 = 43.45 - cos(n) * .51 - cos(n2) * .21;
	    w = d__ * 1155.7555612 + 102.06 - sin(n) * .48 + sin(n2) * .19;
	} else if (*body == 805) {
	    a0 = sin(n) * .7 + 299.36 - sin(n3) * .09;
	    d0 = 43.45 - cos(n) * .51 - cos(n3) * .07;
	    w = d__ * 1075.7341562 + 306.51 - sin(n) * .49 + sin(n3) * .06;
	} else if (*body == 806) {
	    a0 = sin(n) * .7 + 299.36 - sin(n4) * .07;
	    d0 = 43.43 - cos(n) * .51 - cos(n4) * .05;
	    w = d__ * 839.6597686 + 258.09 - sin(n) * .48 + sin(n4) * .05;
	} else if (*body == 807) {
	    a0 = sin(n) * .7 + 299.36 - sin(n5) * .27;
	    d0 = 43.41 - cos(n) * .51 - cos(n5) * .2;
	    w = d__ * 649.053447 + 179.41 - sin(n) * .48 + sin(n5) * .19;
	} else if (*body == 808) {
	    a0 = sin(n) * .7 + 299.27 - sin(n6) * .05;
	    d0 = 42.91 - cos(n) * .51 - cos(n6) * .04;
	    w = d__ * 320.7654228 + 93.38 - sin(n) * .48 + sin(n6) * .04;
	} else {
	    setmsg_("Body code # was not recognized.", (ftnlen)31);
	    errint_("#", body, (ftnlen)1);
	    sigerr_("SPICE(INVALIDBODYCODE)", (ftnlen)22);
	    chkout_("T_PCKEQ", (ftnlen)7);
	    return 0;
	}
    } else if (*body / 100 == 9) {
	if (*body == 901) {
	    a0 = 313.02;
	    d0 = 9.09;
	    w = 56.77 - d__ * 56.3623195;
	} else {
	    setmsg_("Body code # was not recognized.", (ftnlen)31);
	    errint_("#", body, (ftnlen)1);
	    sigerr_("SPICE(INVALIDBODYCODE)", (ftnlen)22);
	    chkout_("T_PCKEQ", (ftnlen)7);
	    return 0;
	}
    } else if (*body == 2431010) {
	a0 = 348.76;
	d0 = 87.12;
	w = 265.95 - d__ * 1864.628007;
    } else if (*body == 9511010) {
	a0 = 9.47;
	d0 = 26.7;
	w = d__ * 1226.911485 + 83.67;
    } else if (*body == 2000004) {

/*        Vesta. */

	a0 = 301.;
	d0 = 41.;
	w = d__ * 1617.332776 + 292.;
    } else if (*body == 2000433) {

/*        Eros. */

	a0 = 11.35;
	d0 = 17.22;
	w = d__ * 1639.38864745 + 326.07;
    } else {
	setmsg_("Body code # was not recognized.", (ftnlen)31);
	errint_("#", body, (ftnlen)1);
	sigerr_("SPICE(INVALIDBODYCODE)", (ftnlen)22);
	chkout_("T_PCKEQ", (ftnlen)7);
	return 0;
    }
    *ra = rpd_() * a0;
    *dec = rpd_() * d0;
    *pm = rpd_() * w;
    chkout_("T_PCKEQ", (ftnlen)7);
    return 0;
} /* t_pckeq__ */

