/*

-Procedure f_rot_c ( Test wrappers for rotation routines )

 
-Abstract
 
   Perform tests on all CSPICE wrappers rotation-related functions. 
 
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
   

   void f_rot_c ( SpiceBoolean * ok )

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
 
   This routine tests the wrappers for the rotation routines. 
   The current set is:
      
 
      axisar_c
      eul2m_c
      eul2xf_c
      ident_c
      isrot_c
      m2eul_c
      m2q_c
      q2m_c
      rav2xf_c
      raxisa_c
      rotate_c
      rotmat_c
      rotvec_c
      vrotv_c
      xf2eul_c
      xf2rav_c
 
-Examples
 
   None.
    
-Restrictions
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
 
-Literature_References
 
   None. 
 
-Version
 
   -tspice_c Version 1.4.0 15-OCT-1999 (NJB)  

-&
*/

{ /* Begin f_rot_c */

 

   /*
   Constants
   */
   
   #define DTOL            1.e-12
   #define NTOL            1.e-14
   
                     
   /*
   Static variables
   */
   
   
   /*
   Standard basis vectors:
   */
   static SpiceDouble      e1[3]       =  {1.0,   0.0,  0.0};
   static SpiceDouble      e2[3]       =  {0.0,   1.0,  0.0};
   static SpiceDouble      e3[3]       =  {0.0,   0.0,  1.0};
   
   static SpiceDouble      neg_e1[3]   =  {-1.0,  0.0,  0.0};
   static SpiceDouble      neg_e2[3]   =  {0.0,  -1.0,  0.0};
   static SpiceDouble      neg_e3[3]   =  {0.0,   0.0, -1.0};
   
   
   
   
   /*
   Rotation matrices for "elementary" frame rotations:  90 degrees about
   the x, y, and z axes:
   */
   static SpiceDouble      rx_90[3][3] = {
                                            { 1.0,  0.0,  0.0 },
                                            { 0.0,  0.0,  1.0 },
                                            { 0.0, -1.0,  0.0 },
                                         };
                                         
   static SpiceDouble      ry_90[3][3] = {
                                            { 0.0,  0.0, -1.0 },
                                            { 0.0,  1.0,  0.0 },
                                            { 1.0,  0.0,  0.0 },
                                         };
                                         
   static SpiceDouble      rz_90[3][3] = {
                                            { 0.0,  1.0,  0.0 },
                                            {-1.0,  0.0,  0.0 },
                                            { 0.0,  0.0,  1.0 },
                                         };


   /*
   Local variables
   */
   SpiceBoolean            unique;

   SpiceDouble             angdrv    [6];
   SpiceDouble             angle;
   SpiceDouble             angles    [3];
   SpiceDouble             av        [3];
   SpiceDouble             axis      [3];
   SpiceDouble             expangdrv [6];
   SpiceDouble             expangles [3];
   SpiceDouble             expq      [4];
   SpiceDouble             expr      [3][3];
   SpiceDouble             expv      [3];
   SpiceDouble             ident     [3][3];
   SpiceDouble             q         [4];
   SpiceDouble             r         [3][3];
   SpiceDouble             strans    [6][6];
   SpiceDouble             v         [3];
   SpiceDouble             vout      [3];

   SpiceInt                i;
   SpiceInt                j;




         



   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_rot_c" );
   

   
   
   /*
   Case 1:
   */
   tcase_c ( "Test rotate_c.  Create a matrix for a frame rotation "
             "of 90 degrees about the z axis."                      );
   
   rotate_c ( halfpi_c(), 3, r );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   chckad_c ( "r", (SpiceDouble *)r,  "~",  (SpiceDouble *)rz_90, 
               9,  1.e-14,            ok                          );
   
   
   
   /*
   Case 2:
   */
   tcase_c ( "Test rotmat_c and ident_c.  Rotate the identity matrix "
             "by 90 degrees about the y axis."                      );
   
   ident_c  ( ident );
   chckxc_c ( SPICEFALSE, " ", ok );
      
   rotmat_c ( ident, halfpi_c(), 2, r );
   
   chckad_c ( "r", (SpiceDouble *)r,  "~",  (SpiceDouble *)ry_90, 
               9,  1.e-14,            ok                          );
      
      
   
   /*
   Case 3:
   */
   tcase_c ( "Test rotvec_c.  Apply a frame rotation of 90 degrees "
             "about the x axis to the basis vector e3."             );
   
   /*
   The output vector should be the y basis vector.
   */
   
   rotvec_c ( e3, halfpi_c(), 1, v );  
   chckxc_c ( SPICEFALSE, " ", ok );
   

   chckad_c ( "v", (SpiceDouble *)v,  "~",  (SpiceDouble *)e2, 
               3,  1.e-14,            ok                      );
   
         
   
   /*
   Case 4:
   */
   tcase_c ( "Test raxisa_c.  Decompose rx_90, finding its axis "
             "and angle."                                        );
   
   
   raxisa_c ( rx_90, v, &angle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   chckad_c ( "axis", (SpiceDouble *)v,  "~",  (SpiceDouble *)neg_e1, 
               3,     1.e-14,            ok                          );
   
   
   chcksd_c ( "angle",  angle,  "~",   halfpi_c(),  1.e-14,  ok );
   
   
   /*
   Case 5:
   */
   tcase_c ( "Test raxisa_c.  Decompose a 20 degree rotation "
             "about (1,1,1), finding its axis and angle." );
   
   vpack_c ( 1., 1., 1., expv );
   
   vscl_c  ( 1./sqrt(3.), expv, expv );
   
   axisar_c ( expv, rpd_c()*20., r );
   
   raxisa_c ( r, v, &angle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   /*
   Tolerance was changed from 1.e1-4 to 1.e-13 to make this work
   on the SGI-N32_C platform.  Every other system can handle 1.e-14.
   */
   chckad_c ( "axis", (SpiceDouble *)v,  "~",  (SpiceDouble *)expv, 
               3,     1.e-13,            ok                          );
   
   angle *= dpr_c();
   
   chcksd_c ( "angle",  angle,  "~",  20. ,  1.e-13,  ok );
   
   
   
   
   /*
   Case 6:
   */
   tcase_c ( "Test axisar_c.  Build rx_90 from its axis and angle." );
   
   
   axisar_c ( neg_e1, halfpi_c(), r );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   chckad_c ( "rx_90", (SpiceDouble *)r,  "~",  (SpiceDouble *)rx_90, 
               9,       1.e-14,            ok                        );
   
   
   /*
   Case 7: 
   */
   tcase_c ( "Test q2m_c and m2q_c. Make sure q2m_c inverts the "
             "output of m2q_c, when the latter is applied to each of "
             "our elementary matrices." );
             
   m2q_c ( rx_90, q );
   q2m_c ( q,     r );
   
   chckxc_c ( SPICEFALSE, " ", ok );
   
   chckad_c ( "r", (SpiceDouble *)r,  "~",  (SpiceDouble *)rx_90, 
               9,  1.e-14,            ok                          );
   
   
   m2q_c ( ry_90, q );
   q2m_c ( q,     r );
   
   chckxc_c ( SPICEFALSE, " ", ok );
   
   chckad_c ( "r", (SpiceDouble *)r,  "~",  (SpiceDouble *)ry_90, 
               9,  1.e-14,            ok                          );
   
   
   m2q_c ( rz_90, q );
   q2m_c ( q,     r );
   
   chckxc_c ( SPICEFALSE, " ", ok );
   
   chckad_c ( "r", (SpiceDouble *)r,  "~",  (SpiceDouble *)rz_90, 
               9,  1.e-14,            ok                          );
   

   /*
   Case 8:
   */
   tcase_c ( "Test q2m_c and m2q_c. Make sure q2m_c creates the "
             "matrix rz_90 from the quaternion "
             "( sqrt(2)/2, 0, 0, -sqrt(2)/2 ). Make sure that "
             "m2q_c creates this quaternion from rz_90."           );


   expq[0] =   sqrt(2.)/2.;
   expq[1] =   0.;
   expq[2] =   0.;
   expq[3] =  -sqrt(2.)/2.;


   q2m_c ( expq, r );
   
   chckad_c ( "q2m_c output", 
              (SpiceDouble *)r,  
              "~",  
              (SpiceDouble *)rz_90, 
               9,  
               1.e-14, 
               ok                          );
   

   m2q_c ( rz_90, q );
   
   chckad_c ( "m2q_c output", 
              (SpiceDouble *)q,  
              "~",  
              (SpiceDouble *)expq, 
               4,  
               1.e-14, 
               ok                          );
   
   
   
   
   /*
   Case 9: 
   */
   tcase_c ( "Test eul2m_c and m2eul_c. Make sure m2eul inverts the "
             "output of eul2m_c for a particular non-degenerate "
             "case."                                               );
             
   
   expangles[0]  =  0.01;
   expangles[1]  =  0.03;
   expangles[2]  =  0.09;
   
   eul2m_c  ( expangles[0], expangles[1], expangles[2], 1, 2, 3, r );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   m2eul_c  ( r, 1, 2, 3, angles, angles+1, angles+2 );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   chckad_c ( "angles", 
              (SpiceDouble *)angles,  
              "~",  
              (SpiceDouble *)expangles, 
               3,  
               1.e-12, 
               ok                          );
   


   /*
   Case 10: 
   */
   tcase_c ( "Test eul2m_c and m2eul_c. Make sure m2eul_c yields "
             "the angles ( 0, 0, pi/2 ) when applied to rz_90. using "
             "a 3-1-3 axis sequence.  Make sure eul2m_c creates rz_90 "
             "from this axis and angle sequence."                    );
             
   
   expangles[0] = 0.;
   expangles[1] = 0.;
   expangles[2] = halfpi_c();
   
   m2eul_c ( rz_90, 3, 1, 3, angles, angles+1, angles+2 );
   
   chckad_c ( "m2eul_c angles", 
              (SpiceDouble *)angles,  
              "~",  
              (SpiceDouble *)expangles, 
               3,  
               1.e-12, 
               ok                          );
   

   eul2m_c ( expangles[0], expangles[1], expangles[2], 3, 1, 3, r );
   

   chckad_c ( "eul2m_c matrix", 
              (SpiceDouble *)r,  
              "~",  
              (SpiceDouble *)rz_90, 
               9,  
               1.e-14, 
               ok                          );
   
   
   
   /*
   Case 11: 
   */
   tcase_c ( "Test eul2xf_c and xf2eul_c. Make sure xf2eul_c inverts "
             "the output of eul2xf_c for a particular non-degenerate "
             "case."                                                  );
             
   
   expangdrv[0]  =   0.01;
   expangdrv[1]  =   0.03;
   expangdrv[2]  =   0.09;
   expangdrv[3]  =  -0.001;
   expangdrv[4]  =  -0.003;
   expangdrv[5]  =  -0.009;
   
   eul2xf_c  ( expangdrv, 1, 2, 3, strans );
   
   
   chckxc_c  ( SPICEFALSE, " ", ok );
   
   xf2eul_c  ( strans, 1, 2, 3, angdrv, &unique );
   
   
   chckxc_c  ( SPICEFALSE, " ", ok );
   
   chcksl_c  ( "unique", unique, SPICETRUE, ok );
   
   chckad_c ( "angles and derivatives", 
              (SpiceDouble *)angdrv,  
              "~",  
              (SpiceDouble *)expangdrv, 
               6,  
               1.e-12, 
               ok                          );
   

   /*
   Case 12: 
   */
   tcase_c ( "Test eul2xf_c and xf2eul_c. Make sure eul2xf_c "
             "maps the 3-1-3 angle sequence (0,0,pi/2) and angular "
             "rate vector (0,0,1) to a state transformation "
             "having rz_90 as its upper left block and a matrix "
             "that looks like rz_90**2 with the [2][2] element zeroed "
             "out as its lower left (derivative) block."              );
   
   
   expangdrv[0]  =   0.;
   expangdrv[1]  =   0.;
   expangdrv[2]  =   halfpi_c();
   expangdrv[3]  =   0.;
   expangdrv[4]  =   0.;
   expangdrv[5]  =   1.;
   
   
   eul2xf_c ( expangdrv, 1, 2, 3, strans );
   
   
   /*
   Capture the rotation (upper left block) portion of the state
   transformation.
   */
   for ( i = 0;  i < 3;  i++ )
   {
      for ( j = 0;  j < 3;  j++ )
      {
         r[i][j] = strans[i][j];          
      }
   }
   
   chckad_c ( "upper left block of strans", 
              (SpiceDouble *)r,  
              "~",  
              (SpiceDouble *)rz_90, 
               9,  
               1.e-14, 
               ok                          );
   
   
   
   /*
   Capture the derivative (lower left block) portion of the state
   transformation.
   */
   for ( i = 0;  i < 3;  i++ )
   {
      for ( j = 0;  j < 3;  j++ )
      {
         r[i][j] = strans[3+i][j];           
      }
   }
   
   mxm_c ( rz_90, rz_90, expr );
   
   expr[2][2] = 0.;
   
   chckad_c ( "lower left block of strans", 
              (SpiceDouble *) r,  
              "~",  
              (SpiceDouble *) expr, 
               9,  
               1.e-14, 
               ok                          );
   
   /*
   Make sure that xf2eul_c can get us back the 3-1-3 angle
   sequence 0, 0, pi/2  and the angular rate vector (0, 0, 1).
   */
   
   xf2eul_c ( strans, 3, 1, 3, angdrv, &unique );
   
   chckad_c ( "angles and rates", 
              (SpiceDouble *) angdrv,  
              "~",  
              (SpiceDouble *) expangdrv, 
               6,  
               1.e-14, 
               ok                          );
   
   chcksl_c  ( "unique", unique, SPICEFALSE, ok );
   
   
   
   
   /*
   Case 13: 
   */
   tcase_c ( "Test rav2xf_c and xf2rav_c. Make sure xf2rav_c inverts "
             "the output of rav2xf_c for three non-degenerate "
             "cases."                                                );
             
   /*
   Sub-case 1:
   */
   
   rav2xf_c ( rz_90, e1, strans );
   chckxc_c ( SPICEFALSE, " ", ok );

   xf2rav_c ( strans, r, av );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   chckad_c ( "rotation", 
              (SpiceDouble *)r,  
              "~",  
              (SpiceDouble *)rz_90, 
               9,  
               1.e-14, 
               ok                  );
   
   
   chckad_c ( "angular velocity", 
              (SpiceDouble *)av,  
              "~",  
              (SpiceDouble *)e1, 
               3,  
               1.e-14, 
               ok                  );
   
   
   /*
   Sub-case 2:
   */
   
   rav2xf_c ( rx_90, neg_e2, strans );
   chckxc_c ( SPICEFALSE, " ", ok );

   xf2rav_c ( strans, r, av );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   chckad_c ( "rotation", 
              (SpiceDouble *)r,  
              "~",  
              (SpiceDouble *)rx_90, 
               9,  
               1.e-14, 
               ok                  );
   
   
   chckad_c ( "angular velocity", 
              (SpiceDouble *)av,  
              "~",  
              (SpiceDouble *)neg_e2, 
               3,  
               1.e-14, 
               ok                  );
   
   
   /*
   Sub-case 3:
   */
   rav2xf_c ( ry_90, neg_e3, strans );
   chckxc_c ( SPICEFALSE, " ", ok );

   xf2rav_c ( strans, r, av );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   chckad_c ( "rotation", 
              (SpiceDouble *)r,  
              "~",  
              (SpiceDouble *)ry_90, 
               9,  
               1.e-14, 
               ok                  );
   
   
   chckad_c ( "angular velocity", 
              (SpiceDouble *)av,  
              "~",  
              (SpiceDouble *)neg_e3, 
               3,  
               1.e-14, 
               ok                  );
   


   /*
   Case 14: 
   */
   tcase_c ( "Test rav2xf_c and xf2rav_c.  Make sure rav2xf_c "
             "maps the matrix rz_90 and angular "
             "rate vector (0,0,1) to a state transformation "
             "having rz_90 as its upper left block and a matrix "
             "that looks like rz_90**2 with the [2][2] element zeroed "
             "out as its lower left (derivative) block."              );
   
   
   expv[0] = 0.;
   expv[1] = 0.;
   expv[2] = 1.;

   rav2xf_c ( rz_90, expv, strans );
   
   
   /*
   Capture the rotation (upper left block) portion of the state
   transformation.
   */
   for ( i = 0;  i < 3;  i++ )
   {
      for ( j = 0;  j < 3;  j++ )
      {
         r[i][j] = strans[i][j];          
      }
   }
   
   chckad_c ( "upper left block of strans", 
              (SpiceDouble *)r,  
              "~",  
              (SpiceDouble *)rz_90, 
               9,  
               1.e-14, 
               ok                          );
   
   
   /*
   Capture the derivative (lower left block) portion of the state
   transformation.
   */
   for ( i = 0;  i < 3;  i++ )
   {
      for ( j = 0;  j < 3;  j++ )
      {
         r[i][j] = strans[3+i][j];           
      }
   }
   
   mxm_c ( rz_90, rz_90, expr );
   
   expr[2][2] = 0.;
   
   chckad_c ( "lower left block of strans", 
              (SpiceDouble *) r,  
              "~",  
              (SpiceDouble *) expr, 
               9,  
               1.e-14, 
               ok                          );



   /*
   Make sure we can recover expv and rz_90 from strans using
   xf2rav_c.
   */
   
   xf2rav_c ( strans, r, v );
   
   chckad_c ( "r from xf2rav", 
              (SpiceDouble *) r,  
              "~",  
              (SpiceDouble *) rz_90, 
               9,  
               1.e-14, 
               ok                          );
   
   
   chckad_c ( "v from xf2rav", 
              (SpiceDouble *) v,  
              "~",  
              (SpiceDouble *) expv, 
               3,  
               1.e-14, 
               ok                          );
   
   

   /*
   Case 15: 
   */
   tcase_c ( "Test vrotv_c.  Make sure it inverts rotvec_c where "
             "applicable."                                        );
             

   vrotv_c   ( e1, e3,           halfpi_c(), v    );
   rotvec_c  ( v,  halfpi_c(),   3,          expv );
   
   
   chckad_c ( "v", 
              (SpiceDouble *)e1,  
              "~",  
              (SpiceDouble *)expv, 
               3,  
               1.e-14, 
               ok                  );
   

   /*
   Case 16:
   */
   tcase_c ( "Test vrotv_c header cases." );

   /*
      If axis = ( 0, 0, 1 ) and theta = pi/2 then the following results 
      for r will be obtained 

           v                           r 
      -------------             ---------------- 
      ( 1, 2, 3 )                ( -2, 1, 3 ) 
      ( 1, 0, 0 )                (  0, 1, 0 ) 
      ( 0, 1, 0 )                ( -1, 0, 0 ) 


      If axis = ( 0, 1, 0 ) and theta = pi/2 then the following results 
      for r will be obtained 

           v                           r 
      -------------             ---------------- 
      ( 1, 2, 3 )                (  3, 2, -1 ) 
      ( 1, 0, 0 )                (  0, 0, -1 ) 
      ( 0, 1, 0 )                (  0, 1,  0 ) 


      If axis = ( 1, 1, 1 ) and theta = pi/2 then the following results 
      for r will be obtained 

           v                                     r 
      -----------------------------      ----------------------------- 
      ( 1.0,     2.0,     3.0     )      ( 2.577.., 0.845.., 2.577.. ) 
      ( 2.577.., 0.845.., 2.577.. )      ( 3.0      2.0,     1.0     ) 
      ( 3.0      2.0,     1.0     )      ( 1.422.., 3.154.., 1.422.. )  
      ( 1.422.., 3.154.., 1.422.. )      ( 1.0      2.0,     3.0     ) 

   */

   vpack_c (  1.0,  2.0,  3.0, v    );
   vpack_c ( -2.0,  1.0,  3.0, expv );

   vrotv_c ( v, e3,  halfpi_c(), vout );

   chckad_c ( "vout (0)", 
              (SpiceDouble *)vout,  
              "~",  
              (SpiceDouble *)expv, 
               3,  
               1.e-14, 
               ok                  );


   vrotv_c ( e1, e3,  halfpi_c(), vout );

   chckad_c ( "vout (1)", 
              (SpiceDouble *)vout,  
              "~",  
              (SpiceDouble *)e2, 
               3,  
               1.e-14, 
               ok                  );


   vpack_c ( -1.0,  0.0,  0.0, expv );
   vrotv_c ( e2, e3,  halfpi_c(), vout );

   chckad_c ( "vout (2)", 
              (SpiceDouble *)vout,  
              "~",  
              (SpiceDouble *)expv, 
               3,  
               1.e-14, 
               ok                  );



   vpack_c (  1.0,  2.0,  3.0, v    );
   vpack_c (  3.0,  2.0, -1.0, expv );

   vrotv_c ( v, e2,  halfpi_c(), vout );

   chckad_c ( "vout (3)", 
              (SpiceDouble *)vout,  
              "~",  
              (SpiceDouble *)expv, 
               3,  
               1.e-14, 
               ok                  );



   vpack_c (  0.0,  0.0, -1.0, expv );

   vrotv_c (  e1,   e2,  halfpi_c(), vout );

   chckad_c ( "vout (4)", 
              (SpiceDouble *)vout,  
              "~",  
              (SpiceDouble *)expv, 
               3,  
               1.e-14, 
               ok                  );



   vrotv_c ( e2, e2,  halfpi_c(), vout );

   chckad_c ( "vout (5)", 
              (SpiceDouble *)vout,  
              "~",  
              (SpiceDouble *)e2, 
               3,  
               1.e-14, 
               ok                  );


   vpack_c (  1.0,    1.0,    1.0,   axis );
   vpack_c (  1.0,    2.0,    3.0,   v    );
   vpack_c (  2.577,  0.845,  2.577, expv );

   vrotv_c ( v, axis,  halfpi_c(), vout );

   chckad_c ( "vout (6)", 
              (SpiceDouble *)vout,  
              "~",  
              (SpiceDouble *)expv, 
               3,  
               1.e-2, 
               ok                  );

   vequ_c  (  vout,   v );
   vpack_c (  3.0,    2.0,    1.0,   expv );

   vrotv_c ( v, axis,  halfpi_c(), vout );

   chckad_c ( "vout (7)", 
              (SpiceDouble *)vout,  
              "~",  
              (SpiceDouble *)expv, 
               3,  
               1.e-2, 
               ok                  );

   vequ_c  (  vout,   v );
   vpack_c (  1.422,  3.154,  1.422, expv );

   vrotv_c ( v, axis,  halfpi_c(), vout );

   chckad_c ( "vout (8)", 
              (SpiceDouble *)vout,  
              "~",  
              (SpiceDouble *)expv, 
               3,  
               1.e-2, 
               ok                  );


   vpack_c (  1.0,    2.0,    3.0,   expv );
   vequ_c  (  vout,   v );

   vrotv_c ( v, axis,  halfpi_c(), vout );

   chckad_c ( "vout (6)", 
              (SpiceDouble *)vout,  
              "~",  
              (SpiceDouble *)expv, 
               3,  
               1.e-2, 
               ok                  );

   /*
   Case 17:
   */
   tcase_c ( "Test isrot_c.  Try it on the identity and a matrix "
             "obtained by perturbing the identity."                );
             
   ident_c ( ident );
   
   chcksl_c ( "isrot_c(ident, NTOL, DTOL)", 
               isrot_c(ident, NTOL, DTOL), SPICETRUE, ok );
   
   ident_c ( r );
   
   r[0][0] = 1.000001;
   
   chcksl_c ( "isrot_c(<perturbed ident>, NTOL, DTOL)", 
               isrot_c(r, NTOL, DTOL), SPICEFALSE, ok );
   
   
   /*
   Check handling of invalid tolerance values.
   */
   
   isrot_c ( r, -1., DTOL );
   chckxc_c ( SPICETRUE, "SPICE(VALUEOUTOFRANGE)", ok );
   
   
   isrot_c ( r, NTOL, -1. );
   chckxc_c ( SPICETRUE, "SPICE(VALUEOUTOFRANGE)", ok );
   
   
   /*
   Retrieve the current test status.
   */ 
   t_success_c ( ok ); 
   
   
} /* End f_rot_c */

