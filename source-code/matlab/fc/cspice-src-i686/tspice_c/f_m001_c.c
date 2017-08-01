/*

-Procedure f_m001_c ( Test wrappers for matrix routines )


-Abstract

   Perform tests on CSPICE wrappers for matrix functions.

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
   #include <math.h>
   #include <stdio.h>
   #include "SpiceUsr.h"
   #include "SpiceZfc.h"
   #include "SpiceZmc.h"
   #include "tutils_c.h"


   void f_m001_c ( SpiceBoolean * ok )

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
   maticies.  The current set is:

      mequ_c
      mequg_c
      mxmt_c
      mxmtg_c
      mxm_c
      mxmg_c
      mtxm_c
      mtxmg_c
      mxv_c
      mxvg_c
      mtxv_c
      mtxvg_c
      vtmv_c
      vtmvg_c

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

{ /* Begin f_m001_c */

    #define  TOL               1.e-11

   /*
   Local non-degenerate(!), constants, randomly selected
   */

   static SpiceDouble      vec1   [3] =
                           {11., 12.,  13.};

   static SpiceDouble      vec2   [3] =
                           {10., 25.,  90. };

   static SpiceDouble      vec3   [4] =
                           { 3.,  5., -14.,  2.};

   static SpiceDouble      vec4   [4] =
                           { 9.,  2., -11.,  3.};

   static SpiceDouble      vec5   [3] =
                           {-7.,  3., -0.7 };


   static SpiceDouble      mat1   [3][3] =
                           { { 16.371  ,  -11.6, 22.0   },
                             { 1131.842, 0.3684, 30.006 },
                             { 87.0    ,  170.5, 1.1    } };

   static SpiceDouble      mat2   [4][4] =
                           { {   176.53,   97.69,    4.701, -5.0051},
                             { -45.8135, 3.14159,  186.282,  1836.0},
                             {     12.7,   10.01, -.004518,     2.2},
                             {   -8.333,   101.5,     -0.1,   6.410} };


   static SpiceDouble      mat3   [3][4] =
                           { {  52.1,  -18.46,  428.62,     2.3 },
                             { 10.47,  32.549, -93.182,  0.03612},
                             {  40.9, -77.214,   8.306, 0.000499} };

   static SpiceDouble      mat4   [3][3] =
                           { { 11.  ,  -101.39, 45.32   },
                             { 1.006,   -404.1, -17.302 },
                             { -9.  ,  9263.92, -73.635 } };


   SpiceDouble             vtmv;
   SpiceDouble             vtmvg;
   SpiceDouble             vtest3 [3];
   SpiceDouble             vtest4 [4];
   SpiceDouble             vout3  [3];
   SpiceDouble             vout4  [4];
   SpiceDouble             mout3  [3][3];
   SpiceDouble             mout4  [4][4];
   SpiceDouble             mout34 [3][4];
   SpiceDouble             mout43 [4][3];
   SpiceDouble             mtest3 [3][3];
   SpiceDouble             mtest34[3][4];
   SpiceDouble             mtest43[4][3];



   topen_c ( "f_m001_c" );


   /*-mequ_c */
   tcase_c ( "Pure matrix operation tests - mequ_c." );
   mequ_c   ( mat1, mout3 );
   chckad_c ( "mout3/mequ_c",
              (SpiceDouble *) mout3, "=", (SpiceDouble *) mat1,
              9, TOL, ok                                       );


   /*-mequg_c */
   tcase_c ( "Pure matrix operation tests - mequg_c." );
   mequg_c  ( mat2, 4, 4, mout4 );
   chckad_c ( "mout4/mequg_c",
              (SpiceDouble *) mout4, "=", (SpiceDouble *) mat2,
              16, TOL, ok                                      );



   /*-mxmt_c */
   tcase_c ( "Pure matrix operation tests - mxmt_c." );
   mxmt_c (mat1, mat4, mout3);
   mtest3[0][0] =  2353.245;
   mtest3[0][1] =  4323.385226;
   mtest3[0][2] = -109228.781;
   mtest3[1][0] =  13772.781844;
   mtest3[1][1] =  470.5988;
   mtest3[1][2] = -8983.241682;
   mtest3[2][0] = -16280.143;
   mtest3[2][1] = -68830.5602;
   mtest3[2][2] =  1.5786343615e06;
   chckad_c ( "mout3/mxmt_c",
              (SpiceDouble *) mout3, "~/", (SpiceDouble *) mtest3,
              9, TOL, ok                                        );


   /*-mxmtg_c */
   tcase_c ( "Pure matrix operation tests - mxmtg_c." );
   mxmtg_c ( mat2, mat3, 4, 4, 3, mout43 );
   mtest43[0][0] =  9397.28649;
   mtest43[0][1] =  4589.75154379;
   mtest43[0][2] = -283.914651545;
   mtest43[1][0] =  81622.1137386;
   mtest43[1][1] = -17669.2247361;
   mtest43[1][2] = -568.17242426;
   mtest43[2][0] =  480.00889484;
   mtest43[2][1] =  459.284950276;
   mtest43[2][2] = -253.518568708;
   mtest43[3][0] = -2335.9583;
   mtest43[3][1] =  3226.0267192;
   mtest43[3][2] = -8178.86810141;
   chckad_c ( "mout43/mxmtg_c",
              (SpiceDouble *) mout43, "~/", (SpiceDouble *) mtest43,
              12, TOL, ok                                          );



   /*-mxm_c */
   tcase_c ( "Pure matrix operation tests - mxm_c." );
   mxm_c  (mat1, mat4, mout3);
   mtest3[0][0] = -29.5886;
   mtest3[0][1] =  206833.94431;
   mtest3[0][2] = -677.33308;
   mtest3[1][0] =  12180.5786104;
   mtest3[1][1] =  163066.8527;
   mtest3[1][2] =  49079.2135732;
   mtest3[2][0] =  1118.623;
   mtest3[2][1] = -67529.668;
   mtest3[2][2] =  911.8505;
   chckad_c ( "mout3/mxm_c",
              (SpiceDouble *) mout3, "~/", (SpiceDouble *) mtest3,
              9, TOL, ok                                      );


   /*-mxmg_c */
   tcase_c ( "Pure matrix operation tests - mxmg_c." );
   mxmg_c ( mat3, mat2, 3, 4, 4, mout34 );
   mtest34[0][0] =  15467.23831;
   mtest34[0][1] =  9555.5914486;
   mtest34[0][2] = -3196.01012516;
   mtest34[0][3] = -33195.61871;
   mtest34[1][0] = -826.62689946;
   mtest34[1][1] =  195.98427291;
   mtest34[1][2] =  6112.92967228;
   mtest34[1][3] =  59502.7917322;
   mtest34[2][0] =  10863.0026308;
   mtest34[2][1] =  3836.13997824;
   mtest34[2][2] = -14191.3450244;
   mtest34[2][3] = -141951.336191;
   chckad_c ( "mout34/mxmg_c",
              (SpiceDouble *) mout34, "~/", (SpiceDouble *) mtest34,
              12, TOL, ok                                          );



   /*-mtxm_c */
   tcase_c ( "Pure matrix operation tests - mtxm_c." );
   mtxm_c (mat1, mat4, mout3);
   mtest3[0][0] =  535.714052;
   mtest3[0][1] =  346923.83211;
   mtest3[0][2] = -25247.441564;
   mtest3[1][0] = -1661.7293896;
   mtest3[1][1] =  1.58052561356e06;
   mtest3[1][2] = -13086.8535568;
   mtest3[2][0] =  262.286036;
   mtest3[2][1] = -4165.6926;
   mtest3[2][2] =  396.877688;
   chckad_c ( "mout3/mtxm_c",
              (SpiceDouble *) mout3, "~/", (SpiceDouble *) mtest3,
              9, TOL, ok                                      );


   /*-mtxmg_c */
   tcase_c ( "Pure matrix operation tests - mtxmg_c." );
   mtxmg_c ( mat3, mat4, 4, 3, 3, mout43 );
   mtest43[0][0] =  215.53282;
   mtest43[0][1] =  369380.982;
   mtest43[0][2] = -831.65144;
   mtest43[1][0] =  524.610294;
   mtest43[1][1] = -726585.71038;
   mtest43[1][2] =  4285.882892;
   mtest43[2][0] =  4546.324908;
   mtest43[2][1] =  71143.18392;
   mtest43[2][2] =  20425.681054;
   mtest43[3][0] =  25.33184572;
   mtest43[3][1] = -243.17039592;
   mtest43[3][2] =  103.574307895;
   chckad_c ( "mout34/mtxmg_c",
              (SpiceDouble *) mout43, "~/", (SpiceDouble *) mtest43,
              12, TOL, ok                                          );



   /*-mxv_c */
   tcase_c ( "Vector-matrix operation tests - mxv_c." );
   mxv_c (mat1, vec1, vout3);
   vtest3[0] = 326.881;
   vtest3[1] = 12844.7608;
   vtest3[2] = 3017.3;
   chckad_c ( "vout3/mxv_c", vout3, "~/", vtest3, 3, TOL, ok );


   /*-mxvg_c */
   tcase_c ( "Vector-matrix operation tests - mxvg_c." );
   mxvg_c ( mat2, vec4, 4, 4, vout4);
   vtest4[0] = 1717.4237;
   vtest4[1] = 3052.85968;
   vtest4[2] = 140.969698;
   vtest4[3] = 148.333;
   chckad_c ( "vout4/mxv_c", vout4, "~/", vtest4, 4, TOL, ok );



   /*-mtxv_c */
   tcase_c ( "Vector-matrix operation tests - mtxv_c." );
   mtxv_c (mat1, vec1, vout3);
   vtest3[0] = 14893.185;
   vtest3[1] = 2093.3208;
   vtest3[2] = 616.372;
   chckad_c ( "vout3/mtxv_c", vout3, "~/", vtest3, 3, TOL, ok );


   /*-mtxvg_c */
   tcase_c ( "Vector-matrix operation tests - mtxvg_c." );
   mtxvg_c ( mat2, vec4, 4, 4, vout4);
   vtest4[0] = 1332.444;
   vtest4[1] = 1079.88318;
   vtest4[2] = 414.622698;
   vtest4[3] = 3621.9841;
   chckad_c ( "vout4/mtxvg_c", vout4, "~/", vtest4, 4, TOL, ok );



   /*-vtmv */
   tcase_c ( "Vector-matrix operation tests - vtmv_c." );
   vtmv = vtmv_c ( vec1, mat1, vec2 );
   chcksd_c ( "vtmv/vtmv_c", vtmv, "~/", 256738.35, TOL, ok );


   /*-vtmvg_c */
   tcase_c ( "Vector-matrix operation tests - vtmvg_c (1)." );
   vtmvg = vtmvg_c ( vec3, mat2, vec4, 4, 4 );
   chcksd_c ( "(1)vtmvg/vtmvg_c", vtmvg, "~/", 18739.659728, TOL, ok );

   tcase_c ( "Vector-matrix operation tests - vtmvg_c (2)." );
   vtmvg = vtmvg_c ( vec5, mat3, vec4, 3, 4 );
   chcksd_c ( "(2)vtmvg/vtmvg_c", vtmvg, "~/", 33399.2798321, TOL, ok );



   /*
   Retrieve the current test status.
   */
   t_success_c ( ok );


} /* End f_m001_c */

