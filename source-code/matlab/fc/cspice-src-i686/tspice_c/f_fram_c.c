/*

-Procedure f_fram_c ( Test wrappers for frame routines )

 
-Abstract
 
   Perform tests on CSPICE wrappers for the frame system routines.
    
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
   

   void f_fram_c ( SpiceBoolean * ok )

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
 
   This routine tests the wrappers for a subset of the CSPICE frame
   system routines. 
   
   The subset is:
      
      frinfo_c
      cidfrm_c
      cnmfrm_c
       
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

{ /* Begin f_fram_c */

 
   /*
   Constants
   */
   #define FRNMLN          50
   #define PCK_CLASS       2
   #define ITRF93_CENT     399
   #define ITRF93_CLSSID   3000
   
   
   /*
   Local variables
   */

   SpiceBoolean            found;
   
   SpiceChar               frname [ FRNMLN ];

   SpiceInt                cent;
   SpiceInt                clssid;
   SpiceInt                frclss;
   SpiceInt                frcode;


   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_fram_c" );
   

   
   /*
   Make sure the kernel pool doesn't contain any unexpected 
   definitions.
   */
   
   clpool_c();
   
   
   /*
   Case 1:
   */
   tcase_c ( "Test frinfo_c; look up characteristics of ITRF93." );
 
                   
   namfrm_ ( "ITRF93", &frcode, 6 );
   
   frinfo_c ( frcode, &cent, &frclss, &clssid, &found );
   
   chckxc_c ( SPICEFALSE, " ", ok );
  
   chcksl_c ( "found", found, SPICETRUE, ok );
  
   chcksi_c ( "center",      cent,   "=", ITRF93_CENT,   0, ok );
   chcksi_c ( "frame class", frclss, "=", PCK_CLASS,     0, ok );
   chcksi_c ( "class ID",    clssid, "=", ITRF93_CLSSID, 0, ok );
   
  


   /*
   Case 2:
   */
   tcase_c ( "Test cidfrm_c; look up frame associated with the "
             "earth."                                            );
      
   cidfrm_c ( 399, FRNMLN, &frcode, frname, &found );
   
   chckxc_c ( SPICEFALSE, " ", ok );
  
   chcksl_c ( "found", found, SPICETRUE, ok );
  
   chcksi_c ( "frame code",  frcode, "=",  10013,      0, ok );
   chcksc_c ( "frame name",  frname, "=", "IAU_EARTH",    ok );
   
      
      
   /*
   Case 3:
   */
   tcase_c ( "Test cnmfrm_c; look up frame associated with the "
             "earth."                                            );
      
   cnmfrm_c ( "earth", FRNMLN, &frcode, frname, &found );
   
   chckxc_c ( SPICEFALSE, " ", ok );
  
   chcksl_c ( "found", found, SPICETRUE, ok );
  
   chcksi_c ( "frame code",  frcode, "=",  10013,      0, ok );
   chcksc_c ( "frame name",  frname, "=", "IAU_EARTH",    ok );
   
      
      
   /*
   Retrieve the current test status.
   */ 
   t_success_c ( ok ); 
   
   
} /* End f_fram_c */

