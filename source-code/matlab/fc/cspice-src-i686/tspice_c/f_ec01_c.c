/*

-Procedure f_ec01_c ( Test wrappers for elements routines )


-Abstract

   Perform tests on CSPICE wrappers for elements conversion functions.

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

   #include "SpiceUsr.h"
   #include "tutils_c.h"

   void f_ec01_c ( SpiceBoolean * ok )

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

   This routine tests the wrappers for orbit elements conversion
   routines.   The current set is:

      oscelts_c
      conics_c

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

{ /* Begin f_ec01_c */

   #define  TOL               1.e-10


   /*
   Local constants and variables.
   */

   SpiceDouble                      vtest8  [8];
   SpiceDouble                      vout8   [8];
   SpiceDouble                      vout6   [6];

   static SpiceDouble               mu = 398600.1;
   static SpiceDouble               et = -83241202.9223976;


   /* An abritrary Geosynch vehicle, TDRS 4, J2000 */

   static SpiceDouble               state  [6] =
           { -36048.15231483, -21884.39544710,  336.39689817,
              1.59510580    , -2.62787910    , -0.01687365  };


   topen_c ( "f_ec01_c" );


   /*-oscelt_c */
   tcase_c ( "Elements conversion tests - oscelt_c" );
   vtest8[0] = 42160.755416;
   vtest8[1] = 1.3892359522e-004;
   vtest8[2] = 9.6830217480e-003;
   vtest8[3] = 1.5136684133;
   vtest8[4] = 5.4966592305;
   vtest8[5] = 2.9599931171;
   vtest8[6] = et;
   vtest8[7] = mu;
   oscelt_c ( state, et, mu, vout8 );
   chckad_c ( "vout8/oscelt_c", vout8, "~/", vtest8, 8, TOL, ok );


   /*
   conics_c should reverse the action of oscelt, so we'll use
   the oscelt_c output as conics_c input.
   */

   /*-conics_c */
   tcase_c ("Elements conversion tests - conics_c" );
   conics_c ( vout8, et, vout6 );
   chckad_c ( "vout6/conics_c", vout6, "~/", state, 6, TOL, ok );



   /*
   Retrieve the current test status.
   */
   t_success_c ( ok );

} /* End f_ec01_c */


