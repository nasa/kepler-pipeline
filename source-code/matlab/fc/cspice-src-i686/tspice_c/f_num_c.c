/*

-Procedure f_num_c ( Test wrappers for numeric routines )

 
-Abstract
 
   Perform tests on CSPICE wrappers for numeric functions. 
 
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
   

   void f_num_c ( SpiceBoolean * ok )

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
 
   This routine tests the wrappers for the CSPICE numeric routines. 
   Covered routines are:
      
      brcktd_c
      brckti_c
      
             
-Examples
 
   None.
    
-Restrictions
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
 
-Literature_References
 
   None. 
 
-Version
 
   -tspice_c Version 1.0.0 18-AUG-1999 (NJB)  

-&
*/

{ /* Begin f_num_c */

 

   
                     



         



   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_num_c" );
   

   
   
   /*
   Case 1:
   */
   tcase_c ( "Test brcktd_c" );


   chcksd_c ( "brcktd_c( -1., 0., 1. )", 
               brcktd_c( -1., 0., 1. ),  
               "=",  
               0.0,
               0.0,
               ok                      );
               

   chcksd_c ( "brcktd_c( 0., 0., 1. )", 
               brcktd_c( 0., 0., 1. ),  
               "=",  
               0.0,
               0.0,
               ok                      );
               

   chcksd_c ( "brcktd_c( 0.5, 0., 1. )", 
               brcktd_c( 0.5, 0., 1. ),  
               "=",  
               0.5,
               0.0,
               ok                      );
               

   chcksd_c ( "brcktd_c( 1., 0., 1. )", 
               brcktd_c( 1., 0., 1. ),  
               "=",  
               1.0,
               0.0,
               ok                      );
               

   chcksd_c ( "brcktd_c( 2., 0., 1. )", 
               brcktd_c( 2., 0., 1. ),  
               "=",  
               1.0,
               0.0,
               ok                      );
               


               
   /*
   Case 2:
   */
   tcase_c ( "Test brckti_c" );


   chcksi_c ( "brckti_c( -1, 0, 1 )", 
               brckti_c( -1, 0, 1 ),  
               "=",  
               0,
               0,
               ok                      );
               

   chcksi_c ( "brckti_c( 0, 0, 1 )", 
               brckti_c( 0, 0, 1 ),  
               "=",  
               0,
               0,
               ok                      );
               

   chcksi_c ( "brckti_c( 1, 0, 2 )", 
               brckti_c( 1, 0, 2 ),  
               "=",  
               1,
               0,
               ok                      );
               

   chcksi_c ( "brckti_c( 1, 0, 1 )", 
               brckti_c( 1, 0, 1 ),  
               "=",  
               1,
               0,
               ok                      );
               

   chcksi_c ( "brckti_c( 2, 0, 1 )", 
               brckti_c( 2, 0, 1 ),  
               "=",  
               1,
               0,
               ok                      );
               





   
      
   
   /*
   Retrieve the current test status.
   */ 
   t_success_c ( ok ); 
   
   
} /* End f_num_c */

