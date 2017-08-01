/*

-Procedure f_extr_c ( Test wrappers for extreme value routines )

 
-Abstract
 
   Perform tests on CSPICE wrappers for the extreme value routines.
    
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
   

   void f_extr_c ( SpiceBoolean * ok )

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
 
   This routine tests the wrappers for the CSPICE extreme value
   routines.  These are routines that return the max and min d.p. and
   int values.
   
   The routines are:
      
      dpmax
      dpmax_c
      dpmin
      dpmin_c
      intmax
      intmax_c
      intmin
      intmin_c
             
-Examples
 
   None.
    
-Restrictions
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
 
-Literature_References
 
   None. 
 
-Version
 
   -tspice_c Version 1.1.0 25-FEB-2002 (NJB)
  
      Now calls chcksi_c for tests of integer values.
      Unnecessary chckxc_c calls were removed.

   -tspice_c Version 1.0.0 27-AUG-1999 (NJB)  

-&
*/

{ /* Begin f_extr_c */

 
   /*
   Constants
   */

   
   /*
   Local variables
   */
   SpiceDouble             dpval;

   SpiceInt                intval;


   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_extr_c" );
      
   
   /*
   Case 1:
   */
   tcase_c ( "Test dpmax_" );
 
   dpval = dpmax_();
   
   chcksd_c ( "dpmax_", dpval, ">", 1.0e308, 0., ok );
    
    
   /*
   Case 2:
   */
   tcase_c ( "Test dpmax_c" );
 
   dpval = dpmax_c();
   
   chcksd_c ( "dpmax_()", dpval, "=", dpmax_(), 0., ok );
    
    
   /*
   Case 3:
   */
   tcase_c ( "Test dpmin_" );
 
   dpval = dpmin_();
   
   chcksd_c ( "dpmin_", dpval, "<", -1.0e308, 0., ok );
    
    
   /*
   Case 4:
   */
   tcase_c ( "Test dpmin_c" );
 
   dpval = dpmin_c();
   
   chcksd_c ( "dpmin_c", dpval, "=", dpmin_(), 0., ok );
    
    
   
   /*
   Case 5:
   */
   tcase_c ( "Test intmax_" );
 
   intval = intmax_();
   
   chcksi_c ( "intmax_", intval, ">=", 2147483647, 0, ok );
    
    
   /*
   Case 6:
   */
   tcase_c ( "Test intmax_c" );
 
   intval = intmax_c();
   
   chcksi_c ( "intmax_()", intval, "=", intmax_(), 0, ok );
    
    
   /*
   Case 7:
   */
   tcase_c ( "Test intmin_" );
 
   intval = intmin_();
   
   chcksi_c ( "intmin_", intval, "<=", -2147483647, 0, ok );
    
    
   /*
   Case 8:
   */
   tcase_c ( "Test intmin_c" );
 
   intval = intmin_c();
   
   chcksi_c ( "intmin_c", intval, "=", intmin_(), 0, ok );
    
    
   

    
    

      
   /*
   Retrieve the current test status.
   */ 
   t_success_c ( ok ); 
   
   
} /* End f_extr_c */

