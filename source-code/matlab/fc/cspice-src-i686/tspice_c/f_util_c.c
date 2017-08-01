/*

-Procedure f_util_c ( Test wrappers for utility functions )

 
-Abstract
 
   Perform tests on CSPICE wrappers for utility functions. 
 
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
   #include "SpiceZst.h"
   #include "tutils_c.h"
   

   void f_util_c ( SpiceBoolean * ok )

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
 
   This routine tests the wrappers for the CSPICE utility routines.
   These are utilities that don't fit into other specific categories
   such as "string manipulation."  The current set of functions is:
      
      convrt_c
      tkvrsn_c
      
             
-Examples
 
   None.
    
-Restrictions
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
 
-Literature_References
 
   None. 
 
-Version
 
   -tspice_c Version 1.1.0 23-OCT-2001 (NJB)

      Added const qualification to local variable version for 
      compatibility with the updated prototype of tkvrsn_c.
  
   -tspice_c Version 1.0.0 29-AUG-1999 (NJB)  

-&
*/

{ /* Begin f_util_c */

   /*
   Constants
   */
   #define TIGHT_TOL       1.e-14
   
   #define VERLEN          30
   
   /*
   Local variables
   */              
   SpiceChar               expver  [ VERLEN ];
   ConstSpiceChar        * version; 
   SpiceChar               fortver [ VERLEN ];
  
   SpiceDouble             y;

         



   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_util_c" );
   

   
   
   /*
   Case 1:
   */
   tcase_c ( "Test convrt_c." );

   convrt_c ( pi_c(),   "radians",  "degrees",  &y );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksd_c ( "180 degrees", y, "~", 180.0, TIGHT_TOL, ok );


   /*
   Check getfat_c string error cases:
   
      1) Null input unit string.
      2) Empty input unit string.
      3) Null output unit string.
      4) Empty output unit string.
      
   */
   convrt_c ( pi_c(),   NULLCPTR,  "degrees",  &y );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   convrt_c ( pi_c(),   "",        "degrees",  &y );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );

   convrt_c ( pi_c(),   "radians",  NULLCPTR,  &y );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   convrt_c ( pi_c(),   "radians",  "",        &y );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );


   
   /*
   Case 2:
   */
   
   tcase_c ( "Test tkvrsn_c.  Make sure the version starts with "
             "CSPICE_ and ends with the SPICELIB version."       );
             
   
   tkvrsn_ ( ( char    * ) "TOOLKIT", 
             ( char    * ) fortver,
             ( ftnlen    ) 7,
             ( ftnlen    ) VERLEN-1  );
   
   F2C_ConvertStr ( VERLEN,  fortver );
             
   strcpy ( expver, "CSPICE_" );
   strcat ( expver, fortver   );
         
   version  =   tkvrsn_c ( "TOOLKIT" );   
   chckxc_c ( SPICEFALSE,  " ",  ok );
   
   chcksc_c ( "version", version, "=", expver, ok );
             
   
             
             
   
   /*
   Retrieve the current test status.
   */ 
   t_success_c ( ok ); 
   
   
} /* End f_util_c */

