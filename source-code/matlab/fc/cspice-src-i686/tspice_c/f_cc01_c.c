/*

-Procedure f_cc01_c ( Test wrappers for coordinate routines )


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
   #include "tutils_c.h"

   void f_cc01_c ( SpiceBoolean * ok )

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

      cyllat_c
      cylrec_c
      cylsph_c
      latsph_c
      latcyl_c
      latrec_c
      reccyl_c
      recsph_c
      reclat_c
      sphrec_c
      sphcyl_c   
      sphlat_c

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

{ /* Begin f_cc01_c */

   #define  TOL               1.e-10


   /*
   Local constants and variables.
   */

   SpiceDouble                rad2;
   SpiceDouble                lng2;
   SpiceDouble                lat2;
   SpiceDouble                z2;
   SpiceDouble                vtest3 [3];
   SpiceDouble                vout3  [3];

   static SpiceDouble         rad = 10.;
   static SpiceDouble         lng = 0.2;
   static SpiceDouble         lat = 0.3;
   static SpiceDouble         z   = 2.2;

   static SpiceDouble         vec1   [3] =
                              { 11.,  12.,  13.};

   static SpiceDouble         null3   [3] =
                              { 0.,  0.,  0.};

   topen_c ( "f_cc01_c" );


   /*-cyllat_c */
   tcase_c ( "Coordinate conversion tests - cyllat_c." );
   cyllat_c ( rad, lng, z, &rad2, &lng2, &lat2 );
   chcksd_c ( "rad2/cyllat_c", rad2, "~/", 10.239140589, TOL, ok );
   chcksd_c ( "lat2/cyllat_c", lat2, "~/", 0.21655030498, TOL, ok );
   chcksd_c ( "lng2/cyllat_c", lng2, "~/", 0.2      , TOL, ok );


   /*-cylrec_c */
   tcase_c ( "Coord conversion tests - cylrec_c." );
   cylrec_c ( rad, lng, z, vout3 );
   vtest3[0] = 9.8006657784;
   vtest3[1] = 1.9866933080;
   vtest3[2] = 2.2;
   chckad_c ( "vout3/cylrec", vout3, "~/", vtest3, 3, TOL, ok );


   /*-cylsph_c */
   tcase_c ( "Coord conversion tests - cylsph_c." );
   cylsph_c ( rad, lng, z, &rad2, &lat2, &lng2 );
   chcksd_c ( "rad2/cylsph_c", rad2, "~/", 10.239140589, TOL, ok );
   chcksd_c ( "lat2/cylsph_c", lat2, "~/", 1.3542460218, TOL, ok );
   chcksd_c ( "lng2/cylsph_c", lng2, "~/", 0.2 , TOL, ok );



   /*-latsph_c */
   tcase_c  ( "Coord conversion tests - latsph_c." );
   latsph_c (  rad, lng, lat, &rad2, &lat2, &lng2 );
   chcksd_c ( "rad2/latsph_c", rad2, "~/", 10.         , TOL, ok );
   chcksd_c ( "lat2/latsph_c", lat2, "~/", 1.2707963268, TOL, ok );
   chcksd_c ( "lng2/latsph_c", lng2, "~/", 0.2         , TOL, ok );


   /*-latcyl_c */
   tcase_c  ( "Coord conversion tests - latcyl_c." );
   latcyl_c ( rad, lng, lat, &rad2, &lng2, &z2 );
   chcksd_c ( "rad2/latcyl_c", rad2, "~/", 9.5533648912, TOL, ok );
   chcksd_c ( "z2/latcyl_c"  , z2  , "~/", 2.9552020666, TOL, ok );
   chcksd_c ( "lng2/latcyl_c", lng2, "~/", 0.2     , TOL, ok );


   /*-latrec_c */
   tcase_c  ( "Coord conversion tests - latrec_c." );
   latrec_c ( rad, lng, lat, vout3 );
   vtest3[0] = 9.3629336358;
   vtest3[1] = 1.8979606098;
   vtest3[2] = 2.9552020666;
   chckad_c ( "vout3/latrec", vout3, "~/", vtest3, 3, TOL, ok );



   /*-reccyl_c */
   tcase_c  ( "Coord conversion tests - reccyl_c (1)." );
   reccyl_c ( vec1, &rad2, &lng2, &z2  );
   chcksd_c ( "rad2/reccyl_c", rad2, "~/", 16.278820596, TOL, ok );
   chcksd_c ( "z2/reccyl_c" ,    z2, "~/", 13.          , TOL, ok );
   chcksd_c ( "lng2/reccyl_c", lng2, "~/", 0.82884905879, TOL, ok );

   tcase_c  ( "Coord conversion tests - reccyl_c (2)." );
   reccyl_c (  null3, &rad2, &lng2, &z2  );
   chcksd_c ( "rad2/reccyl_c", rad2, "=", 0., TOL, ok );
   chcksd_c ( "z2/reccyl_c" ,    z2, "=", 0., TOL, ok );
   chcksd_c ( "lng2/reccyl_c", lng2, "=", 0., TOL, ok );


   /*-recsph_c */
   tcase_c  ( "Coord conversion tests - recsph_c (1)." );
   recsph_c ( vec1, &rad2, &lat2, &lng2 );
   chcksd_c ( "rad2/recsph_c", rad2, "~/", 20.832666656,  TOL, ok );
   chcksd_c ( "lat2/recsph_c", lat2, "~/", 0.89691960835, TOL, ok );
   chcksd_c ( "lng2/recsph_c", lng2, "~/", 0.82884905879, TOL, ok );

   tcase_c  ( "Coord conversion tests - recsph_c (2)." );
   recsph_c ( null3, &rad2, &lat2, &lng2 );
   chcksd_c ( "rad2/recsph_c", rad2, "=", 0., TOL, ok );
   chcksd_c ( "lat2/recsph_c", lat2, "=", 0., TOL, ok );
   chcksd_c ( "lng2/recsph_c", lng2, "=", 0., TOL, ok );



   /*-reclat_c */
   tcase_c  ( "Coord conversion tests - reclat_c (1)." );
   reclat_c ( vec1, &rad2, &lng2, &lat2 );
   chcksd_c ( "rad2/reclat_c", rad2, "~/", 20.832666656,  TOL, ok );
   chcksd_c ( "lat2/reclat_c", lat2, "~/", 0.67387671844, TOL, ok );
   chcksd_c ( "lng2/reclat_c", lng2, "~/", 0.82884905879, TOL, ok );

   tcase_c  ( "Coord conversion tests - reclat_c (2)." );
   reclat_c (  null3, &rad2, &lng2, &lat2 );
   chcksd_c ( "rad2/reclat_c", rad2, "=", 0., TOL, ok );
   chcksd_c ( "lat2/reclat_c", lat2, "=", 0., TOL, ok );
   chcksd_c ( "lng2/reclat_c", lng2, "=", 0., TOL, ok );



   /*-sphrec_c */
   tcase_c  ( "Coord conversion tests - sphrec_c." );
   sphrec_c ( rad, lat, lng, vout3 );
   vtest3[0] = 2.8962947762;
   vtest3[1] = 0.58710801693;
   vtest3[2] = 9.5533648913;
   chckad_c ( "vout3/sphrec_c", vout3, "~/", vtest3, 3, TOL, ok );


   /*-sphcyl_c */
   tcase_c  ( "Coord conversion tests - sphcyl_c." );
   sphcyl_c ( rad, lat, lng, &rad2, &lat2, &z2 );
   chcksd_c ( "rad2/sphcyl_c", rad2, "~/", 2.9552020666, TOL, ok );
   chcksd_c ( "z2/sphcyl_c"  ,   z2, "~/", 9.5533648913, TOL, ok );
   chcksd_c ( "lat2/sphcyl_c", lat2, "~/", 0.2         , TOL, ok );


   /*-sphlat_c */
   tcase_c  ( "Coord conversion tests - sphlat_c." );
   sphlat_c ( rad, lat, lng, &rad2, &lng2, &lat2 );
   chcksd_c ( "rad2/sphlat_c", rad2, "~/", 10.0         , TOL, ok );
   chcksd_c ( "lng2/sphlat_c", lng2, "~/", 0.2          , TOL, ok );
   chcksd_c ( "lat2/sphlat_c", lat2, "~/", 1.2707963268 , TOL, ok );



   /*
   Retrieve the current test status.
   */
   t_success_c ( ok );

} /* End f_cc01_c */

