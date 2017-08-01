/*

-Procedure f_cc02_c ( Test wrappers for coordinate routines )


-Abstract

   Perform tests on CSPICE wrappers for coordinate conversion functions.

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
   #include "SpiceZmc.h"
   #include "tutils_c.h"

   void f_cc02_c ( SpiceBoolean * ok )

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

   This routine tests the wrappers for the coordinate routines.
   The current set is:

      georec_c
      pgrrec_c
      radrec_c
      recgeo_c
      recpgr_c
      recrad_c

-Examples

   None.

-Restrictions

   None.

-Author_and_Institution

   N.J. Bachman   (JPL)
   E.D. Wright    (JPL)

-Literature_References

   None.

-Version

   -tspice_c Version 2.0.0 26-DEC-2004 (NJB)

       Added tests for recpgr_c, pgrrec_c.
   
   -tspice_c Version 1.0.0 22-JUL-1999 (EDW)

-&
*/

{ /* Begin f_cc02_c */

   #define  TOL               1.e-10


   /*
   Local constants and variables.
   */

   SpiceDouble                rad2;
   SpiceDouble                lng2;
   SpiceDouble                lat2;
   SpiceDouble                ra2;
   SpiceDouble                dec2;
   SpiceDouble                vtest3 [3];
   SpiceDouble                vout3  [3];

   static SpiceDouble         rad  = 10.;
   static SpiceDouble         ra   = 6.08319;
   static SpiceDouble         dec  = 0.3;
   static SpiceDouble         lng1 = 0.78539816339745;
   static SpiceDouble         lat1 = 1.5388811178587;
   static SpiceDouble         rad1 = -6355.5612364097;


   static SpiceDouble         vec1   [3] =
                              { 11.,  -12.,  13.};

   static SpiceDouble         vec2   [3] =
                              { 0.0,  1.0,  1.0 };

   /* The Clark radius and flattening factor for Earth */

   static SpiceDouble         clarkr = 6378.2064;
   static SpiceDouble         clarkf = 1.0 / 294.9787;


   topen_c ( "f_cc02_c" );


   /*-recrad_c */
   tcase_c  ( "Coord conversion tests - recrad_c." );
   recrad_c ( vec1, &rad2, &ra2, &dec2 );
   chcksd_c ( "rad2/recrad_c", rad2, "~/", 20.832666656,  TOL, ok );
   chcksd_c ( "ra2/recrad_c" , ra2 , "~/", 5.4543362484,  TOL, ok );
   chcksd_c ( "dec2/recrad_c", dec2, "~/", 0.67387671844, TOL, ok );


   /*-radrec_c */
   tcase_c  ( "Coord conversion tests - radrec_c." );
   radrec_c ( rad, ra, dec, vout3 );
   vtest3[0] = 9.3629425425;
   vtest3[1] =-1.8979166712;
   vtest3[2] = 2.9552020666;
   chckad_c ( "vout3/radrec_c", vout3, "~/", vtest3, 3, TOL, ok );



   /*-recgeo_c */
   tcase_c  ( "Coord conversion tests - recgeo_c." );
   recgeo_c ( vec2, clarkr, clarkf, &lng2, &lat2, &rad2 );
   chcksd_c ( "lng2/recgeo_c", lng2, "~/",    halfpi_c(), TOL, ok );
   chcksd_c ( "lat2/recgeo_c", lat2, "~/",  1.5482306905, TOL, ok );
   chcksd_c ( "rad2/recgeo_c", rad2, "~/", -6355.5725182, TOL, ok );


   /*-georec_c */
   tcase_c  ( "Coord conversion tests - georec_c." );
   georec_c ( lng1, lat1, rad1, clarkr, clarkf, vout3 );
   vtest3[0] = 1.0;
   vtest3[1] = 1.0;
   vtest3[2] = 1.0;
   chckad_c ( "vout3/georec_c", vout3, "~/", vtest3, 3, TOL, ok );


   /*-recpgr_c */
   tcase_c  ( "Coord conversion tests - recpgr_c." );
   recpgr_c ( "Earth", vec2, clarkr, clarkf, &lng2, &lat2, &rad2 );
   chcksd_c ( "lng2/recpgr_c", lng2, "~/",    halfpi_c(), TOL, ok );
   chcksd_c ( "lat2/recpgr_c", lat2, "~/",  1.5482306905, TOL, ok );
   chcksd_c ( "rad2/recpgr_c", rad2, "~/", -6355.5725182, TOL, ok );

   tcase_c  ( "Null pointer case - recpgr_c." );
   recpgr_c ( NULLCPTR, vec2, clarkr, clarkf, &lng2, &lat2, &rad2 );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   tcase_c  ( "Empty string case - recpgr_c." );
   recpgr_c ( "", vec2, clarkr, clarkf, &lng2, &lat2, &rad2 );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );


   /*-pgrrec_c */
   tcase_c  ( "Coord conversion tests - pgrrec_c." );
   pgrrec_c ( "Earth", lng1, lat1, rad1, clarkr, clarkf, vout3 );
   vtest3[0] = 1.0;
   vtest3[1] = 1.0;
   vtest3[2] = 1.0;
   chckad_c ( "vout3/pgrrec_c", vout3, "~/", vtest3, 3, TOL, ok );

   tcase_c  ( "Null pointer case - pgrrec_c." );
   pgrrec_c ( NULLCPTR, lng1, lat1, rad1, clarkr, clarkf, vout3 );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   tcase_c  ( "Empty string case - pgrrec_c." );
   pgrrec_c ( "", lng1, lat1, rad1, clarkr, clarkf, vout3 );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );

   /*
   Retrieve the current test status.
   */
   t_success_c ( ok );

} /* End f_cc02_c */

