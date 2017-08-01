/*

-Procedure f_m002_c ( Test wrappers for matrix routines, set 2 )

 
-Abstract
 
   Perform tests on CSPICE wrappers for matrix functions, subset 2.
 
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
   

   void f_m002_c ( SpiceBoolean * ok )

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
 
   This routine tests the wrappers for a subset of the matrix routines. 
   The set is:
      
      det_c
      frame_c
      ident_c
      invert_c
      trace_c
      xpose_c
      xpose6_c
      xposeg_c
              
-Examples
 
   None.
    
-Restrictions
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
 
-Literature_References
 
   None. 
 
-Version
 
   -tspice_c Version 2.0.0 13-SEP-1999 (NJB)  

-&
*/

{ /* Begin f_m002_c */

 


   /*
   Constants
   */
   
   #define LB     -1.
   #define UB      1.
   #define NUMCAS  10000
   #define LIMIT   1.e-14


   /*
   Local macros
   */
   #define MAX3( a, b, c )    MaxVal(  MaxVal ((a),(b)),      (c)  )
   #define MAX4( a, b, c, d ) MaxVal(  MAX3   ((a),(b),(c)),  (d)  )
   
   
   /*
   Static variables
   */
   static SpiceDouble      xposegMat[2][3] =
                           {
                              { 00, 01, 02 },
                              { 10, 11, 12 }  
                           };

   static SpiceDouble      expXposegMatT[3][2] =
                           {
                              { 00, 10 },
                              { 01, 11 },
                              { 02, 12 }   
                           };


   
   /*
   Local variables
   */
   SpiceDouble             expm      [3][3];
   SpiceDouble             expm6     [6][6];
   SpiceDouble             identMat  [3][3];
   SpiceDouble             m         [3][3];
   SpiceDouble             mout      [3][3];
   SpiceDouble             m6        [6][6];
   SpiceDouble             mout6     [6][6];
   SpiceDouble             xposegMatT[3][2];
   SpiceDouble             worsta;
   SpiceDouble             worstl;
   SpiceDouble             x       [3] =  { 0., 0., 0. };
   SpiceDouble             y       [3];
   SpiceDouble             z       [3];

   SpiceInt                i;
   SpiceInt                j;
   SpiceInt                seed;






   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_m002_c" );
   

   
   
   /*
   Cases 1 and 2:
   */



      
   worsta = 0.0;
   worstl = 0.0;
   seed   = 19879871;



   for ( i = 0;  i < NUMCAS;  i++ )
   {
      /*
      Generate a frame matrix from a random vector.
      */ 
      
      /*
      Generate a random vector.
      */
      
      x[0] =  rand_c ( LB, UB );
      x[1] =  rand_c ( LB, UB );
      x[2] =  rand_c ( LB, UB );
      
      for ( j = 0;  j < 3;  j++ )
      {
         if ( x[j] == 0. ) 
         {
            x[j] = rand_c ( .1, 1. ) * dpmax_c();
         }
      }

      frame_c ( x, y, z );
      
    
      worsta = MAX4 ( worsta,
                      vdot_c(x,y), 
                      vdot_c(y,z),
                      vdot_c(z,x)  );
                      
      worstl = MAX4 ( worstl,
                      1.0 - vdot_c(x,x), 
                      1.0 - vdot_c(y,y),
                      1.0 - vdot_c(z,z)  );
         
   }
      
   tcase_c ( "Find the worst non-orthogonality measurement." );
   
   chcksd_c ( "Max inner product of basis vectors",  
              worsta,  
              "<",  
              LIMIT, 
              0.0,  
              ok                          );

   tcase_c ( "Find the worst non-unit-length measurement." );
   
   chcksd_c ( "Max deviation from unit length of basis vectors",  
              worstl,  
              "<",  
              LIMIT, 
              0.0,  
              ok                          );


   /*
   Case:  3
   */
   
   tcase_c ( "Test xposeg_c, in place and not." );
   
   xposeg_c ( xposegMat, 2, 3, xposegMatT );

   chckxc_c ( SPICEFALSE, " ", ok );
   
   chckad_c ( "xposeg_c result", 
              (SpiceDouble *)xposegMatT, 
              "~~/", 
              (SpiceDouble *)expXposegMatT,
              6,
              LIMIT,
              ok                 );
   
   
   xposeg_c ( xposegMatT, 3, 2, xposegMatT );

   chckxc_c ( SPICEFALSE, " ", ok );
   
   chckad_c ( "xposeg_c result", 
              (SpiceDouble *)xposegMatT, 
              "~~/", 
              (SpiceDouble *)xposegMat,
              6,
              LIMIT,
              ok                 );
   
   
   /*
   Case 4:
   */
   
   tcase_c ( "Test det_c." );
   
   vpack_c ( 1., 1., 1., m[0] );
   vpack_c ( 2., 2., 2., m[1] );
   vpack_c ( 3., 3., 3., m[2] );
   
   chcksd_c ( "Determinant of singular matrix", 
               det_c ( m ),
               "~",
               0.,
               LIMIT,
               ok                                );
   
   ident_c ( identMat );
   
   chcksd_c ( "Determinant of identity matrix", 
               det_c ( identMat ),
               "=",
               1.,
               0.,
               ok                                );
   
   eul2m_c (  30.,   60., -15., 3, 2, 1, m    );
   
   chcksd_c ( "Determinant of rotation matrix", 
               det_c ( m ),
               "~",
               1.,
               LIMIT,
               ok                                );
   
   /*
   Case 5:
   */
   
   tcase_c ( "Test invert_c" );
   
   
   eul2m_c (  30.,   60., -15., 3, 2, 1, m    );
   eul2m_c (  15.,  -60., -30., 1, 2, 3, expm );
   
   invert_c ( m, mout );
   
   chckxc_c ( SPICEFALSE, " ", ok );
   chckad_c ( "Inverse of rotation matrix", 
               (SpiceDouble *) mout,
               "~",
               (SpiceDouble *)expm,
               9,
               LIMIT,
               ok                                );
               
               
   /*
   Case 6:
   */
   
   tcase_c ( "Test invert_c, this time in place." );
   
   invert_c ( m, m);
   
   chckxc_c ( SPICEFALSE, " ", ok );
   chckad_c ( "Inverse of rotation matrix in place", 
               (SpiceDouble *) m,
               "~",
               (SpiceDouble *)expm,
               9,
               LIMIT,
               ok                                );


   /*
   Case 7: 
   */

   tcase_c ( "Test invert_c on a singular matrix." );
   
   /*
   Test using a singular matrix.  No error is signaled; we should get  
   the zero matrix back. 
   */
   
   vpack_c ( 1., 1., 1., m[0] );
   vscl_c  ( 2., m[0],   m[1] );
   vscl_c  ( 3., m[0],   m[2] );
   
   invert_c ( m, mout );
   
   for ( i = 0;  i < 9;  i++ )
   {
      *( (SpiceDouble *)expm + i ) = 0.;
   }
     
   chckad_c ( "Inverse of singular matrix", 
               (SpiceDouble *) mout,
               "~",
               (SpiceDouble *)expm,
               9,
               LIMIT,
               ok                                );
   
   
   /*
   Case 8:
   */
   
   tcase_c ( "Test xpose_c.  See whether it matches xpose_."  );
   
   eul2m_c  (  30.,   60., -15., 3, 2, 1, m    );

   xpose_  ( (doublereal *) m, (doublereal *)expm );
   xpose_c ( m, mout );

   chckad_c ( "Transpose of matrix, compared to xpose_ result", 
               (SpiceDouble *) mout,
               "=",
               (SpiceDouble *)expm,
               9,
               0.0,
               ok                                );

   /*
   Case 9:
   */
   
   tcase_c ( "Test xpose_c.  See whether it inverts an orthogonal "
             "matrix."                                              );
   
   eul2m_c  (  30.,   60., -15., 3, 2, 1, m    );

   invert_c ( m, expm );   
   
   xpose_c  ( m, mout );
   
   chckad_c ( "Transpose of orthogonal matrix", 
               (SpiceDouble *) mout,
               "~",
               (SpiceDouble *)expm,
               9,
               LIMIT,
               ok                                );
   
   
   /*
   Case 10: 
   */
   
   tcase_c ( "Test xpose_c in place." );
   
   xpose_c  ( m, m );
   
   chckad_c ( "Transpose of matrix in place", 
               (SpiceDouble *) m,
               "~",
               (SpiceDouble *)expm,
               9,
               LIMIT,
               ok                                );
   
   
   
   /*
   Case 11:
   */
   
   tcase_c ( "Test xpose6_c" );
   
   
   for ( i = 0;  i < 6;  i++ )
   {
      for ( j = 0;  j < 6;  j++ )
      {
         m6    [i][j] = ( 100. * i ) + j;
         expm6 [j][i] =  m6[i][j];
      }
   }
  
   xpose6_c ( m6, mout6 );
   
   chckad_c ( "Transpose of 6x6 matrix", 
               (SpiceDouble *) mout6,
               "=",
               (SpiceDouble *)expm6,
               36,
               0.,
               ok                                );
   
   /*
   Case 12:
   */
   
   tcase_c ( "Test xpose6_c in place." );
   
   /*
   Repeat, this time in place.
   */
   xpose6_c ( m6, m6 );
   
   chckad_c ( "Transpose of 6x6 matrix in place", 
               (SpiceDouble *) m6,
               "=",
               (SpiceDouble *)expm6,
               36,
               0.,
               ok                                );
   
   
   
   /*
   Case 13:
   */
   
   tcase_c ( "Test trace_c." );
   
   ident_c ( identMat );
   
   chcksd_c ( "trace ( I )", 
               trace_c(identMat),
               "=",
               3.0,
               0.0,
               ok                ); 
   
   
   /*
   Retrieve the current test status.
   */ 
   t_success_c ( ok ); 
   
   
} /* End f_m002_c */

