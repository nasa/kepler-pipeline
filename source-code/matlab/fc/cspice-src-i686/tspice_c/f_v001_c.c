/*

-Procedure f_v001_c ( Test wrappers for vector routines )


-Abstract

   Perform tests on CSPICE wrappers for vector functions.

-Disclaimer

   THIS SOFTWARE AND ANY RELATED MATERIALS WERE CREATED BY THE
   CALIFORNIA INSTITUTE OF TECHNOLOGY (CALTECH) UNDER A U.S.
   GOVERNMENT CONTRACT WITH THE NATIONAL AERONAUTICS AND SPACE
   ADMINISTRATION (NASA). THE SOFTWARE IS TECHNOLOGY AND SOFTWARE
   PUBLICLY AVAILABLE UNDER U.S. EXPORT LAWS AND IS PROVIDED "AS-IS"
   TO THE RECIPIENT WITHOUT WARRANTY OF ANY KIND, INCLUDING ANY
   WARRANTIES OF PERFORMANCE OR MERCHANTABILITY OR FITNESS FOR A
   PARTICULAR USE OR PURPOSE (AS SET FORTH IN UNITED STATES UCC
   SECTIONS 2312-2313) OR FOR ANY PURPOSE WHATSOEVER, FOR THE
   SOFTWARE AND RELATED MATERIALS, HOWEVER USED.

   IN NO EVENT SHALL CALTECH, ITS JET PROPULSION LABORATORY, OR NASA
   BE LIABLE FOR ANY DAMAGES AND/OR COSTS, INCLUDING, BUT NOT
   LIMITED TO, INCIDENTAL OR CONSEQUENTIAL DAMAGES OF ANY KIND,
   INCLUDING ECONOMIC DAMAGE OR INJURY TO PROPERTY AND LOST PROFITS,
   REGARDLESS OF WHETHER CALTECH, JPL, OR NASA BE ADVISED, HAVE
   REASON TO KNOW, OR, IN FACT, SHALL KNOW OF THE POSSIBILITY.

   RECIPIENT BEARS ALL RISK RELATING TO QUALITY AND PERFORMANCE OF
   THE SOFTWARE AND ANY RELATED MATERIALS, AND AGREES TO INDEMNIFY
   CALTECH AND NASA FOR ALL THIRD-PARTY CLAIMS RESULTING FROM THE
   ACTIONS OF RECIPIENT IN THE USE OF THE SOFTWARE.

-Required_Reading

   None.

-Keywords

   TESTING

*/
   #include "SpiceUsr.h"
   #include "tutils_c.h"

   void f_v001_c ( SpiceBoolean * ok )

/*

-Brief_I/O

   VARIABLE  I/O  DESCRIPTION
   --------  ---  --------------------------------------------------
   ok         O   SPICETRUE if the test passes, SPICEFALSE otherwise..

-Detailed_Input

   None.

-Detailed_Output

   ok         if all tests pass.  Otherwise ok is given the value
              SPICEFALSE and a diagnostic message is sent to the test
              logger.

-Parameters

   None.

-Files

   None.

-Exceptions

   Error free.

-Particulars

   This routine tests the wrappers for the routines which act on
   vectors.  The current set is:

      vzero_c
      vzerog_c
      vequ_c
      vequg_c
      vdist_c
      vdistg_c
      vadd_c
      vaddg_c
      vsub_c
      vsubg_c
      vminus_c
      vminusg_c
      vdotg_c
      vcrss_c
      ucrss_c
      unorm_c
      unormg_c
      vnorm_c
      vnormg_c
      vlcom_c
      vlcom3_c
      vlcomg_c
      vscl_c
      vproj_c
      vperp_c
      vrel_c
      vrelg_c
      vsep_c
      vsepg_c
      dvdot_c
      dvhat_c

-Examples

   None.

-Restrictions

   None.

-Author_and_Institution

   E.D. Wright    (JPL)

-Literature_References

   None.

-Version

   -tspice_c Version 1.0.0 22-JUL-1999 (EDW)

-&
*/

{ /* Begin f_v001_c */

    #define  TOL               1.e-09

   /*
   Local constants, randomly selected.
   */

   static SpiceDouble      vec1   [3] =
                           {11., 12.,  13.};

   static SpiceDouble      vec2   [6] =
                           {10., 25.,  90., -5., 0.56, 12.3};

   static SpiceDouble      vec3   [3] =
                           {10., 25.,  90. };

   static SpiceDouble      vec4   [4] =
                           { 3.,  5., -14.,  2.};

   static SpiceDouble      vec5   [4] =
                           { 9.,  2., -11.,  3.};

   static SpiceDouble      vec6   [3] =
                           {-7.,  3., -0.7 };

   static SpiceDouble      vec7    [6] =
                           {34., -12.3, 14.73, 45.1, -8., -16.2 };

   static SpiceDouble      null3  [3] =
                           { 0.,  0.,  0. };

   static SpiceDouble      x3   [3] =
                           {1., 0.,  0. };

   static SpiceDouble      z3   [3] =
                           {0., 0.,  1. };

   static SpiceDouble      null4  [4] =
                           { 0.,  0.,  0.,  0.};

   static SpiceDouble      x5   [5] =
                           {1., 0., 0., 0., 0. };

   static SpiceDouble      z5   [5] =
                           {0., 0., 1., 0., 0. };


   SpiceDouble             diff1;
   SpiceDouble             diff2;
   SpiceDouble             dv;
   SpiceDouble             dot;
   SpiceDouble             vdist;
   SpiceDouble             vdistg;
   SpiceDouble             vsep;
   SpiceDouble             vsepg;
   SpiceDouble             rad;
   SpiceDouble             vout3  [3];
   SpiceDouble             vout6  [6];
   SpiceDouble             vtest3 [3];
   SpiceDouble             vtest6 [6];


   topen_c ( "f_v001_c" );


   /*--vzero_c */
   tcase_c ( "Vector operation tests - vzero_c (1)." );
   chcksl_c ( "T-null3/vzero_c", vzero_c ( null3 ), SPICETRUE,  ok );

   tcase_c ( "Vector operation tests - vzero_c (2)." );
   chcksl_c ( "F-vec1/vzero_c",  vzero_c ( vec1  ), SPICEFALSE, ok );


   /*--vzerog_c */
   tcase_c ( "Vector operation tests - vzerog_c (1)." );
   chcksl_c ( "T-null4/vzerog_c", vzerog_c( null4, 4), SPICETRUE,ok );

   tcase_c ( "Vector operation tests - vzerog_c (2)." );
   chcksl_c ( "F-vec4/vzerog_c",  vzerog_c( vec4, 4 ), SPICEFALSE, ok );

   tcase_c ( "Vector operation tests - vzerog_c (3)." );
   chcksl_c ( "F-baddim/vzerog_c", vzerog_c( null4, 0), SPICEFALSE,ok );



   /*--vequ_c */
   tcase_c  ( "Vector operation tests - vequ_c." );
   vequ_c   ( vec1, vout3 );
   chckad_c ( "vout3/vequ_c", vout3, "=", vec1, 3, TOL, ok );


   /*--vequg_c */
   tcase_c  ( "Vector operation tests - vequg_c (1)." );
   vequg_c  ( vec7, 6, vout6 );
   chckad_c ( "vout6/vequg_c", vout6, "=", vec7, 6, TOL, ok );

   /* ... deliberate error. */
   tcase_c  ( "Vector operation tests - vequg_c (2)." );
   vequg_c  ( vec7, 0, vout6 );
   chckxc_c ( SPICETRUE, "BADDIMENSION", ok);



   /*--vdist_c */
   tcase_c ( "Vector operation tests - vdist_c." );
   vdist = vdist_c( vec1, vec3 );
   chcksd_c ( "vdist/vdist_c", vdist, "~/", 78.09609465, TOL, ok );


   /*--vdistg_c */
   tcase_c ( "Vector operation tests - vdistg_c (1)." );
   vdistg = vdistg_c ( vec2, vec7, 6 );
   chcksd_c ( "vdistg/vdistg_c", vdistg, "~/", 105.0161725, TOL, ok );

   /* ... deliberate error. */
   tcase_c ( "Vector operation tests - vdistg_c (2)." );
   vdistg = vdistg_c ( vec2, vec7, 0 );
   chcksd_c ( "vdistg/vdistg_c", vdistg, "=", 0., TOL, ok );



   /*--vadd_c */
   tcase_c ( "Vector operation tests - vadd_c." );
   vadd_c ( vec3, vec6, vout3 );
   vtest3[0] =  3.0;
   vtest3[1] = 28.0;
   vtest3[2] = 89.3;
   chckad_c ( "vout3/vadd_c", vout3, "~/", vtest3, 3, TOL, ok );


   /*--vaddg_c */
   tcase_c ( "Vector operation tests - vaddg_c." );
   vaddg_c ( vec2, vec7, 6, vout6 );
   vtest6[0] =  44.0;
   vtest6[1] =  12.7;
   vtest6[2] = 104.73;
   vtest6[3] = 40.1;
   vtest6[4] = -7.44;
   vtest6[5] = -3.9;
   chckad_c ( "vout6/vaddg_c", vout6, "~/", vtest6, 6, TOL, ok );



   /*--vsub_c */
   tcase_c ( "Vector operation tests - vsub_c." );
   vsub_c ( vec3, vec6, vout3 );
   vtest3[0] = 17.0;
   vtest3[1] = 22.0;
   vtest3[2] = 90.7;
   chckad_c ( "vout3/vsub_c", vout3, "~/", vtest3, 3, TOL, ok );


   /*--vsubg_c */
   tcase_c ( "Vector operation tests - vsubg_c." );
   vsubg_c ( vec2, vec7, 6, vout6 );
   vtest6[0] = -24.0;
   vtest6[1] =  37.3;
   vtest6[2] =  75.27;
   vtest6[3] = -50.1;
   vtest6[4] =   8.56;
   vtest6[5] =  28.5;
   chckad_c ( "vout6/vsubg_c", vout6, "=", vtest6, 6, TOL, ok );



   /*--vminus_c */
   tcase_c ( "Vector operation tests - vminus_c." );
   vminus_c( vec1, vout3 );
   vtest3[0] = -vec1[0];
   vtest3[1] = -vec1[1];
   vtest3[2] = -vec1[2];
   chckad_c ( "vout3/vminus_c", vout3, "=", vtest3, 3, TOL, ok );


   /*--vminug_c */
   tcase_c ( "Vector operation tests - vminug_c." );
   vminug_c( vec7, 6, vout6 );
   vtest6[0] = -vec7[0];
   vtest6[1] = -vec7[1];
   vtest6[2] = -vec7[2];
   vtest6[3] = -vec7[3];
   vtest6[4] = -vec7[4];
   vtest6[5] = -vec7[5];
   chckad_c ( "vout6/vminug_c", vout6, "=", vtest6, 6, TOL, ok );



   /*--vdotg_c */
   tcase_c ( "Vector operation tests - vdotg_c (1)." );
   dot = vdotg_c( vec4, vec5, 4 );
   chcksd_c ( "dot/vdotg_c", dot, "=", 197.0, TOL, ok );

   /* ... deliberate error. */
   tcase_c ( "Vector operation tests - vdotg_c (2)." );
   dot = vdotg_c( vec4, vec5, 0 );
   chckxc_c ( SPICETRUE, "BADDIMENSION", ok);



   /*--vcrss_c */
   tcase_c ( "Vector operation tests - vcrss_c." );
   vcrss_c ( vec3, vec6, vout3 );
   vtest3[0] = -287.5;
   vtest3[1] = -623.0;
   vtest3[2] =  205.0;
   chckad_c ( "vout3/vcrss_c", vout3, "=", vtest3, 3, TOL, ok );



   /*--ucrss_c */
   tcase_c ( "Vector operation tests - ucrss_c (1)." );
   ucrss_c ( vec3, vec6, vout3 );
   vtest3[0] = -0.4014759185;
   vtest3[1] = -0.86998086;
   vtest3[2] =  0.2862697854;
   chckad_c ( "vout3/ucrss_c", vout3, "~/", vtest3, 3, TOL, ok );



   /*--unorm_c */
   tcase_c ( "Vector operation tests - unorm_c." );
   unorm_c ( vec3, vout3, &rad );
   vtest3[0] = 0.1064492591;
   vtest3[1] = 0.2661231477;
   vtest3[2] = 0.9580433317;
   chcksd_c ( "rad/unorm_c",   rad,   "~/", 93.94147114, TOL, ok );
   chckad_c ( "vout3/unorm_c", vout3, "~/", vtest3, 3, TOL, ok );



   /*--unormg_c */
   tcase_c ( "Vector operation tests - unormg_c (1)." );
   unormg_c ( vec2, 6, vout6, &rad );
   vtest6[0] =  0.1053998658;
   vtest6[1] =  0.2634996645;
   vtest6[2] =  0.9485987922;
   vtest6[3] = -0.0526999329;
   vtest6[4] =  0.005902392485;
   vtest6[5] =  0.1296418349;
   chcksd_c ( "rad/unormg_c",   rad,   "~/", 94.87678114, TOL, ok );
   chckad_c ( "vout6/unormg_c", vout6, "~/", vtest6, 6, TOL, ok );

   /* ... deliberate error. */
   tcase_c ( "Vector operation tests - unormg_c (2)." );
   unormg_c ( vec2, 0, vout6, &rad );
   chckxc_c ( SPICETRUE, "BADDIMENSION", ok);



   /*--vnorm_c */
   tcase_c ( "Vector operation tests - vnorm_c." );
   rad = vnorm_c( vec3 );
   chcksd_c ( "rad/vnorm_c", rad, "~/", 93.94147114, TOL, ok );


   /*--vnormg_c */
   tcase_c ( "Vector operation tests - vnormg_c (1)." );
   rad = vnormg_c( vec2, 6 );
   chcksd_c ( "rad/vnormg_c", rad, "~/", 94.87678114, TOL, ok );

   /* ... deliberate error. */
   tcase_c ( "Vector operation tests - vnormg_c (2)." );
   rad = vnormg_c( vec2, 0 );
   chckxc_c ( SPICETRUE, "BADDIMENSION", ok);



   /*--vlcom_c */
   tcase_c ( "Vector operation tests - vlcom_c." );
   vlcom_c ( 3.615, vec3, -29.632, vec6, vout3 );
   vtest3[0] = 243.574;
   vtest3[1] = 1.479;
   vtest3[2] = 346.0924;
   chckad_c ( "vout3/vlcom_c", vout3, "~/", vtest3, 3, TOL, ok );


   /*--vlcom3_c */
   tcase_c ( "Vector operation tests - vlcom3_c." );
   vlcom3_c ( 3.615, vec3, -29.632, vec6, 5.55, vec1, vout3 );
   vtest3[0] = 304.624;
   vtest3[1] = 68.079;
   vtest3[2] = 418.2424;
   chckad_c ( "vout3/vlcom3_c", vout3, "~/", vtest3, 3, TOL, ok );


   /*--vlcomg_c */
   tcase_c ( "Vector operation tests - vlcomg_c." );
   vlcomg_c ( 6, 34.6, vec2, -88.432, vec7, vout6 );
   vtest6[0] = -2660.688;
   vtest6[1] =  1952.7136;
   vtest6[2] =  1811.39664;
   vtest6[3] = -4161.2832;
   vtest6[4] =   726.832;
   vtest6[5] =  1858.1784;
   chckad_c ( "vout6/vlcomg_c", vout6, "~/", vtest6, 6, TOL, ok );



   /*--vscl_c */
   tcase_c ( "Vector operation tests - vscl_c." );
   vscl_c ( -11.5, vec3, vout3 );
   vtest3[0] = -115.0;
   vtest3[1] = -287.5;
   vtest3[2] = -1035.0;
   chckad_c ( "vout3/vscl_c", vout3, "~/", vtest3, 3, TOL, ok );



   /*--vproj_c */
   tcase_c ( "Vector operation tests - vproj_c." );
   vproj_c ( vec1, vec6, vout3 );
   vtest3[0] =  5.995896734;
   vtest3[1] = -2.569670029;
   vtest3[2] =  0.5995896734;
   chckad_c ( "vout3/vproj_c", vout3, "~/", vtest3, 3, TOL, ok );



   /*--vperp_c */
   tcase_c ( "Vector operation tests - vperp_c." );
   vperp_c ( vec3, vec6, vout3 );
   vtest3[0] =  3.058642503;
   vtest3[1] =  27.9748675;
   vtest3[2] =  89.30586425;
   chckad_c ( "vout3/vperp_c", vout3, "~/", vtest3, 3, TOL, ok );



   /*--vrel_c */
   tcase_c ( "Vector operation tests - vrel_c (1)." );
   diff1 = vrel_c ( vec1, vec6 );
   chcksd_c ( "diff1/vrel_c", diff1, "~/", 1.168608215, TOL, ok );

   tcase_c ( "Vector operation tests - vrel_c (2)." );
   diff1 = vrel_c ( vec1, vec1 );
   chcksl_c ( "T-diff1/vrel_c", ( diff1 == 0.), SPICETRUE, ok );


   /*--vrelg_c */
   tcase_c ( "Vector operation tests - vrelg_c (1)." );
   diff2 = vrelg_c ( vec2, vec7, 6);
   chcksd_c ( "diff2/vrelg_c", diff2, "~/", 1.10686905, TOL, ok );

   tcase_c ( "Vector operation tests - vrelg_c (2)." );
   diff2 = vrelg_c ( vec2, vec2, 6 );
   chcksl_c ( "T-diff2/vrelg_c", ( diff2 == 0.), SPICETRUE, ok );



   /*--vsep_c */
   tcase_c ( "Vector operation tests - vsep_c (1)." );
   vsep = vsep_c ( vec3, vec6 );
   chcksd_c ( "vsep/vsep_c", vsep, "~/", 1.65161332, TOL, ok );

   tcase_c ( "Vector operation tests - vsep_c (2)." );
   vsep = vsep_c ( null3, vec6 );
   chcksd_c ( "vsep/vsep_c", vsep, "=", 0., TOL, ok );

   tcase_c ( "Vector operation tests - vsep_c (3)." );
   vsep = vsep_c ( x3, z3 );
   chcksd_c ( "vsep/vsep_c", vsep, "~/", halfpi_c(), TOL, ok );

   tcase_c ( "Vector operation tests - vsep_c (4)." );
   vsep = vsep_c ( null3, vec6 );
   chcksd_c ( "vsep/vsep_c", vsep, "=", 0., TOL, ok );


   /*--vsepg_c */
   tcase_c ( "Vector operation tests - vsepg_c (1)." );
   vsepg = vsepg_c ( vec2, vec7, 6 );
   chcksd_c ( "vsepg/vsepg_c", vsepg, "~/", 1.413049631, TOL, ok );

   tcase_c ( "Vector operation tests - vsepg_c (2)." );
   vsepg = vsepg_c ( null4, vec5, 4 );
   chcksd_c ( "vsepg/vsepg_c", vsepg, "=", 0., TOL, ok );

   tcase_c ( "Vector operation tests - vsepg_c (3)." );
   vsepg = vsepg_c ( x5, z5, 5 );
   chcksd_c ( "vsepg/vsepg_c", vsepg, "~/", halfpi_c(), TOL, ok );

   /* ... deliberate error. */
   tcase_c ( "Vector operation tests - vsepg_c (4)." );
   vsepg = vsepg_c ( null4, vec5, 0 );
   chckxc_c ( SPICETRUE, "BADDIMENSION", ok);



   /*--dvdot */
   tcase_c ( "Vector operation tests - dvdot_c." );
   dv    = dvdot_c( vec2, vec7 );
   chcksd_c ( "dv/dvdot_c", dv, "~/", -1202.709, TOL, ok );



   /*--dvhat_c */
   tcase_c ( "Vector operation tests - dvhat_c." );
   dvhat_c ( vec7, vout6 );
   vtest6[0] =  0.8708612719;
   vtest6[1] = -0.3150468719;
   vtest6[2] =  0.3772878393;
   vtest6[3] =  0.3592059698;
   vtest6[4] =  0.0830438329;
   vtest6[5] = -0.7597803006;
   chckad_c ( "vout6/dvhat_c", vout6, "~/", vtest6, 6, TOL, ok );


   /*
   Retrieve the current test status.
   */
   t_success_c ( ok );

} /* End f_v001_c */

