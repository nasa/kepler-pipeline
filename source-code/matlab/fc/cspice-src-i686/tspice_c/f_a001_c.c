/*

-Procedure f_a001_c ( Test wrappers for array routines, subset 1 )

 
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
   

   void f_a001_c ( SpiceBoolean * ok )

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
 
   This routine tests the wrappers for a subset of the array routines. 
   The subset is:
      
      maxd_c
      maxi_c
      mind_c
      mini_c
      moved_c
      sumad_c
      sumai_c
      vpack_c
      vupack_c
       
-Examples
 
   None.
    
-Restrictions
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
 
-Literature_References
 
   None. 
 
-Version
 
   -tspice_c Version 1.0.0 30-AUG-1999 (NJB)  

-&
*/

{ /* Begin f_a001_c */

 

   /*
   Constants
   */
   #define ASIZE           5

                     
   /*
   Local variables
   */
   SpiceDouble             fromArray [ ASIZE ] = { 0., 1., 2., 3., 4.};
   SpiceDouble             expArray  [ ASIZE ] = { 0., 1., 2., 3., 4.};
   SpiceDouble             toArray   [ ASIZE ];

   SpiceInt                siArray   [ ASIZE ] = { 1, 2, 3 };

   SpiceInt                n;
     



   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_a001_c" );
   
   
   /*
   Case 1:
   */
   tcase_c ( "Test mind_c" );


   chcksd_c ( "mind_c( 0 )", 
               mind_c( 0 ),  
               "=",  
               0.0,
               0.0,
               ok               );
               

   chcksd_c ( "mind_c( 1, -1. )", 
               mind_c( 1, -1. ),  
               "=",  
               -1.0,
               0.0,
               ok               );
               


   chcksd_c ( "mind_c( 2, 2., -1. )", 
               mind_c( 2, 2., -1. ),  
               "=",  
               -1.0,
               0.0,
               ok               );
               

   chcksd_c ( "mind_c( 2, 1.,  2. )", 
               mind_c( 2, 1.,  2. ),  
               "=",  
               1.0,
               0.0,
               ok               );
               

   chcksd_c ( "mind_c( 4, 1., 3., -4., 2.)", 
               mind_c( 4, 1., 3., -4., 2.),  
               "=",  
              -4.0,
               0.0,
               ok               );
               

   chcksd_c ( "mind_c( 4, 1., 3., -4., -8. )", 
               mind_c( 4, 1., 3., -4., -8. ),  
               "=",  
              -8.0,
               0.0,
               ok               );
               


   
   /*
   Case 2:
   */
   tcase_c ( "Test mini_c" );


   chcksi_c ( "mini_c( 0 )", 
               mini_c( 0 ),  
               "=",  
               0,
               0,
               ok               );
               

   chcksi_c ( "mini_c( 1, -1 )", 
               mini_c( 1, -1 ),  
               "=",  
               -1,
               0,
               ok               );
               


   chcksi_c ( "mini_c( 2, 2, -1 )", 
               mini_c( 2, 2, -1 ),  
               "=",  
               -1,
               0,
               ok               );
               

   chcksi_c ( "mini_c( 2, 1,  2 )", 
               mini_c( 2, 1,  2 ),  
               "=",  
               1,
               0,
               ok               );
               

   chcksi_c ( "mini_c( 4, 1, 3, -4, 2)", 
               mini_c( 4, 1, 3, -4, 2),  
               "=",  
              -4,
               0,
               ok               );
               

   chcksi_c ( "mini_c( 4, 1, 3, -4, -8 )", 
               mini_c( 4, 1, 3, -4, -8 ),  
               "=",  
              -8,
               0,
               ok               );
               



   /*
   Case 3:
   */
   tcase_c ( "Test maxd_c" );


   chcksd_c ( "maxd_c( 0 )", 
               maxd_c( 0 ),  
               "=",  
               0.0,
               0.0,
               ok               );
               

   chcksd_c ( "maxd_c( 1, -1. )", 
               maxd_c( 1, -1. ),  
               "=",  
               -1.0,
               0.0,
               ok               );
               


   chcksd_c ( "maxd_c( 2, 2., -1. )", 
               maxd_c( 2, 2., -1. ),  
               "=",  
               2.0,
               0.0,
               ok               );
               

   chcksd_c ( "maxd_c( 2, 1.,  2. )", 
               maxd_c( 2, 1.,  2. ),  
               "=",  
               2.0,
               0.0,
               ok               );
               

   chcksd_c ( "maxd_c( 4, 1., 3., -4., 2.)", 
               maxd_c( 4, 1., 3., -4., 2.),  
               "=",  
               3.0,
               0.0,
               ok               );
               

   chcksd_c ( "maxd_c( 4, 1., 3., -4., -8. )", 
               maxd_c( 4, 1., 3., -4., -8. ),  
               "=",  
               3.0,
               0.0,
               ok               );
               


   
   /*
   Case 4:
   */
   tcase_c ( "Test maxi_c" );


   chcksi_c ( "maxi_c( 0 )", 
               maxi_c( 0 ),  
               "=",  
               0,
               0,
               ok               );
               

   chcksi_c ( "maxi_c( 1, -1 )", 
               maxi_c( 1, -1 ),  
               "=",  
               -1,
               0,
               ok               );
               


   chcksi_c ( "maxi_c( 2, 2, -1 )", 
               maxi_c( 2, 2, -1 ),  
               "=",  
               2,
               0,
               ok               );
               

   chcksi_c ( "maxi_c( 2, 1,  2 )", 
               maxi_c( 2, 1,  2 ),  
               "=",  
               2,
               0,
               ok               );
               

   chcksi_c ( "maxi_c( 4, 1, 3, -4, 2)", 
               maxi_c( 4, 1, 3, -4, 2),  
               "=",  
               3,
               0,
               ok               );
               

   chcksi_c ( "maxi_c( 4, 1, 3, -4, -8 )", 
               maxi_c( 4, 1, 3, -4, -8 ),  
               "=",  
               3,
               0,
               ok               );
               



   /*
   Case 5:
   */
   
   tcase_c ( "Test moved_; normal case." );
   
   n = ASIZE;
   moved_ ( fromArray, &n, toArray );
   chckad_c ( "toArray", toArray, "=", expArray, ASIZE, 0., ok );
      
 
   tcase_c ( "Test moved_; number to move is 0.  Does memmove work?" );
   vsclg_c ( -1., fromArray, ASIZE, fromArray );
      
   n = 0;
   moved_ ( fromArray, &n, toArray );
   chckad_c ( "toArray", toArray, "=", expArray, ASIZE, 0., ok );
      
   
   tcase_c ( "Test moved_; number to move is -1.  Does memmove work?" );
      
   n = -1;
   moved_ ( fromArray, &n, toArray );
   chckad_c ( "toArray", toArray, "=", expArray, ASIZE, 0., ok );
 
   
   /*
   Case 6:
   */
   
   tcase_c ( "Test sumai_c." );
   
   chcksi_c ( "sumai_c ( 1, 2, 3 )",
               sumai_c ( siArray, 3 ),
               "=",
               6,
               0,
               ok                     );
               
               
               
   /*
   Case 7:
   */
   
   tcase_c ( "Test sumad_c." );
   
   chcksd_c ( "sumad_c ( 0., 1., 2., 3., 4. )",
               sumad_c ( expArray, 5 ),
               "=",
               10.0,
               0,
               ok                     );
               
               
               
               
               
               
   
   
   /*
   Retrieve the current test status.
   */ 
   t_success_c ( ok ); 
   
   
} /* End f_a001_c */

