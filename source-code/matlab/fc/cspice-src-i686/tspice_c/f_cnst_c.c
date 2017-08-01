/*

-Procedure f_cnst_c ( Test wrappers for constants routines )


-Abstract

   Perform tests on CSPICE wrappers for constants functions.

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

   #include <string.h>

   #include "SpiceUsr.h"
   #include "SpiceZfc.h"
   #include "SpiceZmc.h"
   #include "tutils_c.h"


   void f_cnst_c ( SpiceBoolean * ok )

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

   This routine tests the wrappers for the constants routines.
   The current set is:

      j2000_c()
      dpr_c()
      rpd_c()
      clight_c()
      spd_c()
      j2100_c()
      b1950_c()
      twopi_c()
      pi_c()
      halfpi_c()
      jyear_c()
      b1900_c()

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


{ /* Begin f_cnst_c */


   /*
   The number of single values tests currently coded and a
   comparison tolerance.
   */
   #define  Num_consts        15
   #define  TOL               1.e-09


   /*
   Local variables
   */

   SpiceInt                    i;
   SpiceChar                   test_str[20];


   /* Define a structure for single value return tests */
   struct Const
            {
             SpiceChar *        name;
             SpiceDouble        theory_val;
             SpiceDouble        exp_val;
            };



   /* Set the test values vector as a constants structure */
   struct Const   Testvals[Num_consts];

   /* Initialize the constant's test structure */

   Testvals[0].name        = "J2000_C ";
   Testvals[0].theory_val  = 2451545.000000;
   Testvals[0].exp_val     = j2000_c();

   Testvals[1].name        = "DPR_C   ";
   Testvals[1].theory_val  = 57.2957795131;
   Testvals[1].exp_val     = dpr_c();

   Testvals[2].name        = "RPD_C   ";
   Testvals[2].theory_val  = 0.0174532925199;
   Testvals[2].exp_val     = rpd_c();

   Testvals[3].name        = "CLIGHT_C";
   Testvals[3].theory_val  = 299792.458000;
   Testvals[3].exp_val     = clight_c();

   Testvals[4].name        = "SPD_C   ";
   Testvals[4].theory_val  = 86400.000000;
   Testvals[4].exp_val     = spd_c();

   Testvals[5].name        = "J2100_C ";
   Testvals[5].theory_val  = 2488070.0;
   Testvals[5].exp_val     = j2100_c();

   Testvals[6].name        = "B1950_C ";
   Testvals[6].theory_val  = 2433282.423;
   Testvals[6].exp_val     = b1950_c();

   Testvals[7].name        = "TWOPI_C ";
   Testvals[7].theory_val  = 6.283185307;
   Testvals[7].exp_val     = twopi_c();

   Testvals[8].name        = "PI_C    ";
   Testvals[8].theory_val  = 3.141592654;
   Testvals[8].exp_val     = pi_c();

   Testvals[9].name        = "HALFPI_C";
   Testvals[9].theory_val  = 1.570796327;
   Testvals[9].exp_val     = halfpi_c();

   Testvals[10].name       = "JYEAR_C ";
   Testvals[10].theory_val = 31557600.0;
   Testvals[10].exp_val    = jyear_c();

   Testvals[11].name       = "B1900_C ";
   Testvals[11].theory_val = 2415020.31352;
   Testvals[11].exp_val    = b1900_c();

   Testvals[12].name       = "J1900_C ";
   Testvals[12].theory_val = 2415020.0;
   Testvals[12].exp_val    = j1900_c();

   Testvals[13].name       = "J1950_C ";
   Testvals[13].theory_val = 2433282.5;
   Testvals[13].exp_val    = j1950_c();

   Testvals[14].name       = "TYEAR_C ";
   Testvals[14].theory_val = 31556925.9747;
   Testvals[14].exp_val    = tyear_c();

   topen_c ( "f_cnst_c" );


   /* Check each test value to within a tolerance. */
   for ( i = 0; i < Num_consts; ++i)
      {
      strcpy   ( test_str, "Test of " );
      strcat   ( test_str, Testvals[i].name );

      tcase_c  ( test_str );
      chcksd_c ( Testvals[i].name, Testvals[i].exp_val, "~/",
                 Testvals[i].theory_val, TOL, ok );
      }


   /*
   Retrieve the current test status.
   */
   t_success_c ( ok );

} /* End f_cnst_c */

