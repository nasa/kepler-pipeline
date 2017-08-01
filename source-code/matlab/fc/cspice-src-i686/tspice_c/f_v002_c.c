/*

-Procedure f_v002_c ( Test wrappers for vector routines, subset 2 )

 
-Abstract
 
   Perform tests on CSPICE wrappers for the first subset of array 
   functions. 
 
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
   

   void f_v002_c ( SpiceBoolean * ok )

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
 
   This routine tests the wrappers for a subset of the vector routines. 
   The subset is:
      
      vpack_c
      vupack_c
      vdot_c
      vhat_c
      vhatg_c
      vsclg_c
      twovec_c
             
-Examples
 
   None.
    
-Restrictions
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
 
-Literature_References
 
   None. 
 
-Version
 
   -tspice_c Version 2.0.0 30-AUG-1999 (NJB)  

-&
*/

{ /* Begin f_v002_c */

 
   /*
   Constants
   */
   #define   N_SUM_CASES   6
   #define   SUM_ASIZE     5
   #define   TIGHT_TOL     1.e-14

   /*
   Static variables
   */
   static SpiceDouble      a = 1.;
   static SpiceDouble      b = 2.;
   static SpiceDouble      c = 3.;
   
   static SpiceDouble      vpacked[3] = { 1., 2., 3. };

   /*
   Local variables
   */
   SpiceDouble             dot;
   SpiceDouble             expm    [3][3];
   SpiceDouble             expv    [3];
   SpiceDouble             expvg   [6];
   SpiceDouble             m       [3][3];
   SpiceDouble             v       [3];
   SpiceDouble             v2      [3];
   SpiceDouble             vg      [6];
   SpiceDouble             vg2     [6];
   
   SpiceInt                i;



   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_v002_c" );
   

   
   
   /*
   Case 1:
   */
   tcase_c ( "Test vpack_c" );

   vpack_c ( a, b, c, v );
   
   chckad_c ( "packed vector", 
               v,  
               "=",  
               vpacked,
               3,
               0.0,
               ok               );
               
   
      
   
   /*
   Case 2:
   */
   tcase_c ( "Test vupack_c" );

   vupack_c ( vpacked, v, v+1, v+2 );
   
   chckad_c ( "unpacked vector elements", 
               v,  
               "=",  
               vpacked,
               3,
               0.0,
               ok               );
               
   
   /*
   Case 3:
   */
   
   tcase_c ( "Test vdot_c" );
   
   vpack_c ( 1., 2., 3., v  );
   vpack_c ( 2., 3., 4., v2 );
   
   dot = vdot_c ( v, v2 );
   
   chcksd_c ( "dot product", dot, "=", 20.0, 0, ok );
      
      
   /*
   Case 4:
   */
   
   tcase_c ( "Test vhat_c" );
   
   vpack_c ( 3., 4., 12., v  );
   
   vequ_c  ( v,            expv );
   vscl_c  ( 1./13., expv, expv );
   
   vhat_c  ( v, v2 );
   
   chckad_c ( "unit vector", v2, "~", expv, 3, TIGHT_TOL, ok );
      
      
   vpack_c ( 0., 0., 0., v  );
   
   vequ_c  ( v, expv );
   
   vhat_c  ( v, v2 );
   
   chckad_c ( "unit vector", v2, "~", expv, 3, TIGHT_TOL, ok );
      
      
      
   /*
   Case 5:
   */

   tcase_c ( "Test vsclg_c" );
   
   for ( i = 0;  i < 6;  i++ )
   {
      vg   [i]  =  i;
      expvg[i]  =  3 * vg[i];
   }     
      
   vsclg_c ( 3., vg, 6, vg2 );
   
   chckad_c ( "scaled 6-vector", vg2, "~", expvg, 6, TIGHT_TOL, ok );
   
   
   
   /*
   Case 6:
   */
   
   tcase_c ( "Test twovec_c" );
   
   
   /*
   Simple case:  permute standard basis vectors.
   */
   vpack_c ( 1., 0., 0., v  );
   vpack_c ( 0., 1., 0., v2 );

   twovec_c ( v, 3,  v2, 1, m );
   
   vpack_c ( 0., 1., 0., expm[0] );
   vpack_c ( 0., 0., 1., expm[1] );
   vpack_c ( 1., 0., 0., expm[2] );

   chckad_c ( "trans matrix", 
              (SpiceDouble *)m, 
              "~", 
              (SpiceDouble *)expm, 
              9, 
              TIGHT_TOL, 
              ok                     );
   

   /*
   Slightly fancier:  rotate standard basis by pi/4 around the z-axis.
   */
   vpack_c ( 0., 0., 2., v  );
   vpack_c ( 1., 1., 1., v2 );
   
   twovec_c ( v, 3,  v2,  2, m );
   
   
   vpack_c ( 1., -1., 0., expm[0] );
   vscl_c  ( 1./sqrt(2),  expm[0], expm[0] );
   
   vpack_c ( 1.,  1., 0., expm[1] );
   vscl_c  ( 1./sqrt(2),  expm[1], expm[1] );
   
   vpack_c ( 0.,  0., 1.,          expm[2] );

   chckad_c ( "trans matrix", 
              (SpiceDouble *)m, 
              "~", 
              (SpiceDouble *)expm, 
              9, 
              TIGHT_TOL, 
              ok                     );
   
   
   /*
   Case 7:
   */
   
   tcase_c ( "Test vhatg_c." );
   
   
   for ( i = 0;  i < 6;  i++ )
   {
      vg[i] = i+1;
   }  
   
   
   vhatg_c ( vg, 6, vg2 );
   
   vsclg_c ( 1.0/sqrt(91.), vg, 6, expvg ); 
   
   chckad_c ( "unitized (1,2,3,4,5,6)",
              vg2,
              "~",
              expvg,
              6,
              TIGHT_TOL,
              ok                         );                
   
   
   /*
   Retrieve the current test status.
   */ 
   t_success_c ( ok ); 
   
   
} /* End f_v002_c */

