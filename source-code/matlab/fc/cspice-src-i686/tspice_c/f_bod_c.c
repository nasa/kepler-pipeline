/*

-Procedure f_bod_c ( Test wrappers for body name/code routines )

 
-Abstract
 
   Perform tests on CSPICE wrappers for the body name/code routines.
    
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
   

   void f_bod_c ( SpiceBoolean * ok )

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
 
   This routine tests the wrappers for the CSPICE body name/code
   mapping routines.
   
   The routines are:
     
      bodc2n_c 
      boddef_c
      bodn2c_c
      bods2c_c
                   
-Examples
 
   None.
    
-Restrictions
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
 
-Literature_References
 
   None. 
 
-Version
 
   -tspice_c Version 3.0.0 23-AUG-2004 (NJB)

     Updated to test bods2c_c.

   -tspice_c Version 2.1.0 31-AUG-2002 (BVS) 
 
       Removed error case in which Jupiter name was attempted 
       to be re-mapped as the system now supports re-mapping.

   -tspice_c Version 2.0.0 29-AUG-2001 (NJB) 
 
       Updated test case 3 to handle lower-case name returned 
       from bodc2n_c.  This reflects a change to ZZBODTRN.

   -tspice_c Version 1.0.0 27-AUG-1999 (NJB)  

-&
*/

{ /* Begin f_bod_c */

 
   /*
   Constants
   */
   #define NAMELN          33
   
   /*
   Local variables
   */
   SpiceBoolean            found;

   SpiceChar               name [ NAMELN ];

   SpiceInt                code;


   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_bod_c" );
      
   
   /*
   Case 1:
   */
   tcase_c ( "Test bodc2n_c" );
 
   bodc2n_c ( -77, NAMELN, name, &found );
   
   chckxc_c ( SPICEFALSE, " ",                          ok );
   chcksl_c ( "found",    found,     SPICETRUE,         ok );
   chcksc_c ( "GLL name", name, "=", "GALILEO ORBITER", ok );


   bodc2n_c ( -77, 3, name, &found );

   chckxc_c ( SPICEFALSE, " ",                  ok );
   chcksl_c ( "found",    found,     SPICETRUE, ok );
   chcksc_c ( "GLL name", name, "=", "GA",      ok );

   
   bodc2n_c ( -969, NAMELN, name, &found );

   chckxc_c ( SPICEFALSE, " ",                   ok );
   chcksl_c ( "found",    found,     SPICEFALSE, ok );

   
   /*
   Check bodc2n_c string error cases:
   
      1) Null input string.
      2) Output string too short.
      
   */
   bodc2n_c ( -77, NAMELN, NULLCPTR, &found );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   bodc2n_c ( -77, 1, name, &found );
   chckxc_c ( SPICETRUE, "SPICE(STRINGTOOSHORT)", ok );

   bodc2n_c ( -77, 0, name, &found );
   chckxc_c ( SPICETRUE, "SPICE(STRINGTOOSHORT)", ok );




   /*
   Case 2:
   */
   tcase_c ( "Test bodn2c_c" );
 
   bodn2c_c ( "Galileo Orbiter", &code, &found );
   
   chckxc_c ( SPICEFALSE, " ",                ok );
   chcksl_c ( "found",    found, SPICETRUE,   ok );
   chcksi_c ( "GLL code", code, "=", -77,  0, ok );


   bodn2c_c ( "Gal Orbiter", &code, &found );
   
   chckxc_c ( SPICEFALSE, " ",                ok );
   chcksl_c ( "found",    found, SPICEFALSE,  ok );


   
   /*
   Check bodn2c_c string error cases:
   
      1) Null input string.
      2) Empty input string.
      
   */
   bodn2c_c ( NULLCPTR, &code, &found );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   bodn2c_c ( "", &code, &found );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );



   /*
   Case 3:
   */
   tcase_c ( "Test boddef_c" );
 
   /*
   Map a non-existent code and name to each other.   
   */
   boddef_c ( "spud",  -69           );
   chckxc_c ( SPICEFALSE, " ",    ok );
   
   bodn2c_c ( "spud",  &code, &found );
   chckxc_c ( SPICEFALSE, " ",    ok );

   chcksl_c ( "found",     found, SPICETRUE,   ok );
   chcksi_c ( "spud code", code, "=", -69,  0, ok );

   bodc2n_c ( -69, NAMELN, name, &found );
   chckxc_c ( SPICEFALSE,  " ",                  ok );
   chcksl_c ( "found",     found,     SPICETRUE, ok );
   chcksc_c ( "spud name", name, "=", "spud",    ok );
   

   /*
   Give a synonym to an existing code.
   */
   boddef_c ( "JUP BARY", 5          );
   chckxc_c ( SPICEFALSE, " ",    ok );
   
   bodn2c_c ( "JUP BARY",  &code, &found );
   chckxc_c ( SPICEFALSE,  " ",    ok    );

   chcksl_c ( "found",         found, SPICETRUE,  ok );
   chcksi_c ( "JUP BARY code", code,  "=", 5,  0, ok );


   bodc2n_c ( 5, NAMELN, name, &found );
   chckxc_c ( SPICEFALSE,  " ",                       ok );
   chcksl_c ( "found",     found,     SPICETRUE,      ok );
   chcksc_c ( "JUP BARY name", name, "=", "JUP BARY", ok );


   bodn2c_c ( "Gal Orbiter", &code, &found );
   
   chckxc_c ( SPICEFALSE, " ",                ok );
   chcksl_c ( "found",    found, SPICEFALSE,  ok );


   
   /*
   Check boddef_c string error cases:
   
      1) Null input string.
      2) Empty input string.
      
   */
   boddef_c ( NULLCPTR, -69  );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   boddef_c ( "", -69  );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );



   /*
   Case 4:
   */
   tcase_c ( "Test bods2c_c" );
 
   bods2c_c ( "Galileo Orbiter", &code, &found );
   
   chckxc_c ( SPICEFALSE, " ",                ok );
   chcksl_c ( "found",    found, SPICETRUE,   ok );
   chcksi_c ( "GLL code", code, "=", -77,  0, ok );


   bods2c_c ( "-77", &code, &found );
   
   chckxc_c ( SPICEFALSE, " ",                ok );
   chcksl_c ( "found",    found, SPICETRUE,   ok );
   chcksi_c ( "GLL code", code, "=", -77,  0, ok );


   bods2c_c ( "1000000", &code, &found );
   
   chckxc_c ( SPICEFALSE, " ",                   ok );
   chcksl_c ( "found",    found, SPICETRUE,      ok );
   chcksi_c ( "GLL code", code, "=", 1000000, 0, ok );


   /*
   Make sure that code is unchanges when found is SPICEFALSE.
   */
   code = -999;
   bodn2c_c ( "Gal Orbiter", &code, &found );
   
   chckxc_c ( SPICEFALSE, " ",                 ok );
   chcksl_c ( "found",    found, SPICEFALSE,   ok );
   chcksi_c ( "GLL code", code, "=", -999,  0, ok );


   bodn2c_c ( "-999", &code, &found );
   
   chckxc_c ( SPICEFALSE, " ",                 ok );
   chcksl_c ( "found",    found, SPICEFALSE,   ok );
   chcksi_c ( "-999",     code, "=", -999,  0, ok );
   

   /*
   Check bods2c_c string error cases:
   
      1) Null input string.
      2) Empty input string.
      
   */
   bods2c_c ( NULLCPTR, &code, &found );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   bods2c_c ( "", &code, &found );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );


      
   /*
   Retrieve the current test status.
   */ 
   t_success_c ( ok ); 
   
   
} /* End f_bod_c */

