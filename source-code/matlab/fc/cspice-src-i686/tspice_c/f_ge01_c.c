/*

-Procedure f_ge01_c ( Test wrappers for geometry routines, subset 1 )

 
-Abstract
 
   Perform tests on CSPICE wrappers for a subset of the geometry 
   routines.
    
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
   

   void f_ge01_c ( SpiceBoolean * ok )

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
 
   This routine tests the wrappers for a subset of the CSPICE geometry
   routines. 
   
   The subset is:
      
      illum_c
      nearpt_c
      nplnpt_c
      subpt_c
      subsol_c
      surfnm_c
      surfpt_c
      srfrec_c
      srfxpt_c
             
-Examples
 
   None.
    
-Restrictions
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
 
-Literature_References
 
   None. 
 
-Version
 
   -tspice_c Version 5.0.0 31-OCT-2005 (NJB) 

       Added tests to exercise 

          srfrec_c

   -tspice_c Version 4.0.0 23-JUL-2004 (NJB) 

       Added tests to exercise ID code handling in

          illum_c
          srfxpt_c
          subpt_c
          subsol_c

   -tspice_c Version 3.0.0 24-FEB-2004 (NJB) 

       Added tests to exercise srfxpt_c.

   -tspice_c Version 2.0.0 28-NOV-2002 (NJB) 

       Added a more robust set of tests for surfpt_c; these
       are intended to exercise the underlying f2c'd routine, 
       not just test the wrapper.

       Removed or modified comments that included case numbers,
       since these are a maintenance problem.
       
   -tspice_c Version 1.0.1 20-MAR-2002 (EDW) 

       Replaced remove() calls with TRASH macro.

   -tspice_c Version 1.0.0 03-SEP-1999 (NJB)  

-&
*/

{ /* Begin f_ge01_c */

   /*
   Local macros
   */
   #define TRASH(file)     if ( remove(file) !=0 )                        \
                              {                                           \
                              setmsg_c ( "Unable to delete file #." );    \
                              errch_c  ( "#", file );                     \
                              sigerr_c ( "TSPICE(DELETEFAILED)"  );       \
                              }                                           \
                           chckxc_c ( SPICEFALSE, " ", ok );

   /*
   Constants
   */
   #define ERRLEN          321
   #define SPK             "geomtest.bsp"
   
   #define UTC             "1999 Jan 1"
   #define LOOSE_TOL       1.e-7
   #define MED_TOL         1.e-11
   #define TIGHT_TOL       1.e-12
   #define VTIGHT_TOL      1.e-14
   
   /*
   Local variables
   */
   SpiceBoolean            found;

   SpiceDouble             a;
   SpiceDouble             alt;
   SpiceDouble             b;
   SpiceDouble             c;
   SpiceDouble             dist;
   SpiceDouble             dvec     [3];
   SpiceDouble             emissn;
   SpiceDouble             et;
   SpiceDouble             exppnt   [3];
   SpiceDouble             expnrm   [3];
   SpiceDouble             f;
   SpiceDouble             lat;
   SpiceDouble             lindir   [3];
   SpiceDouble             linpt    [3];
   SpiceDouble             lon;
   SpiceDouble             lt;
   SpiceDouble             normal   [3];
   SpiceDouble             obspos   [3];
   SpiceDouble             phase;
   SpiceDouble             pnear    [3];
   SpiceDouble             point    [3];
   SpiceDouble             rad;
   SpiceDouble             radii    [3];
   SpiceDouble             re;
   SpiceDouble             rp;
   SpiceDouble             solar;
   SpiceDouble             spoint   [3];
   SpiceDouble             sunAlt;
   SpiceDouble             sunLat;
   SpiceDouble             sunLon;
   SpiceDouble             sunRad;
   SpiceDouble             sunState [6];
   SpiceDouble             trgepc;
   SpiceDouble             u        [3];
   SpiceDouble             xlat;
   SpiceDouble             xlon;
   SpiceDouble             xrad;
   SpiceDouble             xspoint  [3];
   SpiceDouble             zerovec  [3]  = { 0.0,  0.0,  0.0};


   SpiceInt                handle;
   SpiceInt                dim;





   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_ge01_c" );
   

   
   /*
   Make sure the kernel pool doesn't contain any unexpected 
   definitions.
   */
   clpool_c();
   
   /*
   Load a leapseconds kernel.  
   
   Note that the LSK is deleted after loading, so we don't have to clean
   it up later.
   */
   tstlsk_c();
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   /*
   Create and load a PCK file. Delete the file afterwards.
   */
   tstpck_c ( "test.pck", SPICETRUE, SPICEFALSE );
   
   
   /*
   Load an SPK file as well.
   */
   tstspk_c ( SPK, SPICETRUE, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   /*
   subpt_c tests:
   */
   tcase_c ( "Test subpt_c.  Find the sub-solar point of the sun "
             "on the Earth using the INTERCEPT definition."       );
 
 
   str2et_c ( UTC, &et );
   
   subpt_c  ( "INTERCEPT", "earth", et, "NONE", "sun", spoint, &alt );
   chckxc_c ( SPICEFALSE, " ", ok );

   reclat_c ( spoint, &rad, &lon, &lat );

   /*
   Get the state of the sun in Earth bodyfixed coordinates at et.
   */
   spkgeo_c ( 10, et, "IAU_EARTH", 399, sunState, &lt );
   chckxc_c ( SPICEFALSE, " ", ok );

   reclat_c ( sunState, &sunRad, &sunLon, &sunLat );

   /*
   Make sure the directional coordinates match up.
   */
   chcksd_c ( "Sub point lon", lon, "~", sunLon, TIGHT_TOL, ok );
   chcksd_c ( "Sub point lat", lat, "~", sunLat, TIGHT_TOL, ok );
  
  

   tcase_c ( "Test subpt_c.  Find the sub-solar point of the sun "
             "on the Earth using the NEARPOINT definition."       );
 
 
   str2et_c ( UTC, &et );
   
   subpt_c  ( "NEARPOINT", "399", et, "NONE", "10", spoint, &alt );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   We'll need the radii of the earth.
   */
   bodvar_c ( 399, "RADII", &dim, radii );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   re = radii[0];
   rp = radii[2];
   
   f  =  ( re - rp ) / re;
   
   recgeo_c ( spoint, re, f, &lon, &lat, &alt );

   /*
   Get the state of the sun in Earth bodyfixed coordinates at et.
   */
   spkgeo_c ( 10, et, "IAU_EARTH", 399, sunState, &lt );
   chckxc_c ( SPICEFALSE, " ", ok );

   recgeo_c ( sunState, re, f, &sunLon, &sunLat, &sunAlt );


   /*
   Make sure the directional coordinates match up.
   */
   chcksd_c ( "Sub point lon", lon, "~", sunLon, TIGHT_TOL, ok );
   chcksd_c ( "Sub point lat", lat, "~", sunLat, TIGHT_TOL, ok );
  



   tcase_c ( "Test subpt_c string error checking." );
 
   /*
   Check string error cases:
   
      1) Null variable name.
      2) Empty variable name.
      
   */

   subpt_c  ( NULLCPTR, "earth", et, "NONE", "sun", spoint, &alt );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   
   subpt_c  ( "", "earth", et, "NONE", "sun", spoint, &alt );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );
            
   subpt_c  ( "NEARPOINT", NULLCPTR, et, "NONE", "sun", spoint, &alt );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   subpt_c  ( "NEARPOINT", "", et, "NONE", "sun", spoint, &alt );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );

   subpt_c  ( "NEARPOINT", "earth", et, NULLCPTR, "sun", spoint, &alt );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   subpt_c  ( "NEARPOINT", "earth", et, "", "sun", spoint, &alt );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );

   subpt_c  ( "NEARPOINT", "earth", et, "NONE", NULLCPTR, spoint, &alt);
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   subpt_c  ( "NEARPOINT", "earth", et, "NONE", "", spoint, &alt);
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );




   /*
   illum_c tests:
   */
   tcase_c ( "Test illum_c.  Find the illumination angles on the "
             "earth as seen from the moon, evaluated at the "
             "sub-moon point (NEARPOINT method)."                );
 
 
   subpt_c  ( "NEARPOINT", "earth", et, "NONE", "moon", spoint, &alt );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   illum_c ( "earth", et,      "NONE",  "moon",  
             spoint,  &phase,  &solar,  &emissn );
   chckxc_c ( SPICEFALSE, " ", ok );
  
  
   /*
   We should have an emission angle of zero.
   */
   chcksd_c ( "Emission angle", emissn, "~", 0.0, TIGHT_TOL, ok );
   
   /*
   The phase angle should match the solar incidence angle.
   */
   chcksd_c ( "Phase angle", phase, "~", solar, TIGHT_TOL, ok );
   


   /*
   Repeat test using integer codes to represent target and
   observer. 
   */
   tcase_c ( "Repeat tests with integer codes." );
 
 
   subpt_c  ( "NEARPOINT", "399", et, "NONE", "301", spoint, &alt );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   illum_c ( "399", et,      "NONE",  "301",  
             spoint,  &phase,  &solar,  &emissn );
   chckxc_c ( SPICEFALSE, " ", ok );
  
  
   /*
   We should have an emission angle of zero.
   */
   chcksd_c ( "Emission angle", emissn, "~", 0.0, TIGHT_TOL, ok );
   
   /*
   The phase angle should match the solar incidence angle.
   */
   chcksd_c ( "Phase angle", phase, "~", solar, TIGHT_TOL, ok );
   


   tcase_c ( "Test illum_c string error checking." );
 
   /*
   Check string error cases:
   
      1) Null variable name.
      2) Empty variable name.
      
   */

   illum_c  ( "earth",   et,      "NONE",  "sun", 
              spoint,    &phase,  &solar,  &emissn );
              
   illum_c  ( NULLCPTR,  et,      "NONE",  "sun", 
              spoint,    &phase,  &solar,  &emissn );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   
   illum_c  ( "",  et,      "NONE",  "sun", 
              spoint,    &phase,  &solar,  &emissn );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );
            


   illum_c  ( "earth",   et,      NULLCPTR,  "sun", 
              spoint,    &phase,  &solar,    &emissn );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   illum_c  ( "earth",   et,      "",        "sun", 
              spoint,    &phase,  &solar,    &emissn );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );


   illum_c  ( "earth",   et,      "NONE",  NULLCPTR, 
              spoint,    &phase,  &solar,  &emissn  );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   

   illum_c  ( "earth",   et,      "NONE",  "", 
              spoint,    &phase,  &solar,  &emissn  );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );


   
   /*
   nplnpt tests:
   */

   tcase_c ( "Test nplnpt_c." );
   
   
   vpack_c (  1.0,  2.0,  3.0, linpt  );
   vpack_c (  0.0,  1.0,  1.0, lindir );
   vpack_c ( -6.0,  9.0, 10.0, point  );
      
   nplnpt_c ( linpt, lindir, point, pnear, &dist );
   chckxc_c ( SPICEFALSE, " ", ok );

   vpack_c ( 1.0, 9.0, 10.0, exppnt );
   
   chckad_c ( "near point", pnear, "~", exppnt, 3, TIGHT_TOL, ok );
   chcksd_c ( "distance",   dist,  "~", 7.0,       TIGHT_TOL, ok );
   

   /*
   Check handling of a zero direction vector.
   */
   
   vpack_c ( 0., 0., 0., lindir );
   nplnpt_c ( linpt, lindir, point, pnear, &dist );
   chckxc_c ( SPICETRUE, "SPICE(ZEROVECTOR)", ok );

   
   /*
   nearpt_c tests:
   */
   
   tcase_c ( "Test nearpt_c." );
   
   /*
   Define the radii of an ellipsoid.
   */
   
   a  =  1.0;
   b  =  2.0;
   c  =  3.0;

   
   /*
   Look at a point on each axis, outside the ellipsoid.
   */
   
   vpack_c  ( 2.,  0.,  0.,  point  );
   vpack_c  ( 1.,  0.,  0.,  exppnt );
   
   nearpt_c ( point, a, b, c, pnear, &alt );
   
   chckxc_c ( SPICEFALSE, " ", ok );
   chckad_c ( "Near point on x axis", 
              pnear,
              "~",
              exppnt,
              3,
              TIGHT_TOL,
              ok                    );
   
   chcksd_c ( "alt", alt, "~", 1.0, TIGHT_TOL, ok );
   
   
   
   vpack_c  ( 0.,  3.,  0.,  point  );
   vpack_c  ( 0.,  2.,  0.,  exppnt );
   
   nearpt_c ( point, a, b, c, pnear, &alt );
   
   chckxc_c ( SPICEFALSE, " ", ok );
   chckad_c ( "Near point on x axis", 
              pnear,
              "~",
              exppnt,
              3,
              TIGHT_TOL,
              ok                    );
   
   chcksd_c ( "alt", alt, "~", 1.0, TIGHT_TOL, ok );
   
   
   
   
   vpack_c  ( 0.,  0.,  -5.,  point  );
   vpack_c  ( 0.,  0.,  -3.,  exppnt );
   
   nearpt_c ( point, a, b, c, pnear, &alt );
   
   chckxc_c ( SPICEFALSE, " ", ok );
   chckad_c ( "Near point on x axis", 
              pnear,
              "~",
              exppnt,
              3,
              TIGHT_TOL,
              ok                    );
   
   chcksd_c ( "alt", alt, "~", 2.0, TIGHT_TOL, ok );
   
   
   
   /*
   surfpt_c tests:
   */
   
   /*
   Define the radii of an ellipsoid.
   */
   
   a  =  1.0;
   b  =  2.0;
   c  =  3.0;

   
   /*
   Look at a point on each axis, outside the ellipsoid.  Use the
   ellipsoid from the nearpt_c tests.
   */

   tcase_c ( "Test surfpt_c. View point is on +x axis, ray "
             "points in the -x direction."                   );
   
   vpack_c (  2.0, 0.0, 0.0, point  );
   vpack_c (  1.,  0.,  0.,  exppnt );
   vpack_c ( -5.0, 0.0, 0.0, u      );
   
   surfpt_c ( point, u, a, b, c, spoint, &found );
   
   chckxc_c ( SPICEFALSE, " ",           ok );
   chcksl_c ( "found", found, SPICETRUE, ok );
   chckad_c ( "Intercept point", 
              spoint,
              "~",
              exppnt,
              3,
              TIGHT_TOL,
              ok                    );

   
   tcase_c ( "Test surfpt_c. View point is above +x axis, ray "
             "points in the -x direction. View point height "
             "is half z semi-axis length."                     );
   
   vpack_c (  2.0,              0.0,  c/2,   point  );
   vpack_c (  a*sqrt(3.0)/2.,   0.0,  c/2,   exppnt );
   vpack_c ( -1.0e-1,            0.0,  0.0,   u      );
   
   surfpt_c ( point, u, a, b, c, spoint, &found );
   
   chckxc_c ( SPICEFALSE, " ",           ok );
   chcksl_c ( "found", found, SPICETRUE, ok );
   chckad_c ( "Intercept point", 
              spoint,
              "~",
              exppnt,
              3,
              TIGHT_TOL,
              ok                    );



   tcase_c ( "Test surfpt_c. View point is above +x axis, ray "
             "points in the +x direction. View point height "
             "is half z semi-axis length."                     );
   
   vpack_c (  2.0,              0.0,  c/2,   point  );
   vpack_c (  a*sqrt(3.0)/2.,   0.0,  c/2,   exppnt );
   vpack_c ( 1.0e-1,            0.0,  0.0,   u      );
   
   surfpt_c ( point, u, a, b, c, spoint, &found );
   
   chckxc_c ( SPICEFALSE, " ",            ok );
   chcksl_c ( "found", found, SPICEFALSE, ok );
   chckad_c ( "Intercept point", 
              spoint,
              "~",
              zerovec,
              3,
              TIGHT_TOL,
              ok                    );

   

   tcase_c ( "Test surfpt_c. View point is above +x axis, ray "
             "points in the -x direction. View point height "
             "is equal to the z semi-axis length."              );
   
   vpack_c (  2.0,   0.0,  c,     point  );
   vpack_c (  0.0,   0.0,  c,     exppnt );
   vpack_c ( -1.0,   0.0,  0.0,   u      );
   
   surfpt_c ( point, u, a, b, c, spoint, &found );
   
   chckxc_c ( SPICEFALSE, " ",           ok );
   chcksl_c ( "found", found, SPICETRUE, ok );
   chckad_c ( "Intercept point", 
              spoint,
              "~",
              exppnt,
              3,
              TIGHT_TOL,
              ok                    );

   
   tcase_c ( "Test surfpt_c. View point is above +x axis, ray "
             "points in the -x direction. View point height "
             "is greater than z semi-axis length."                 );
   
   vpack_c (  2.0,  0.0,  c*2,   point  );
   vpack_c (  1.,   0.,   c*2.,  exppnt );
   vpack_c ( -1.0,  0.0,  0.0,   u      );
   
   surfpt_c ( point, u, a, b, c, spoint, &found );
   
   chckxc_c ( SPICEFALSE, " ",           ok );
   chcksl_c ( "found", found, SPICEFALSE, ok );
   chckad_c ( "Intercept point", 
              spoint,
              "~",
              zerovec,
              3,
              TIGHT_TOL,
              ok                    );

 



  
   tcase_c ( "Test surfpt_c. View point is on +y axis, ray "
             "points in the -y direction."                   );

   vpack_c (  0.0,  3.0, 0.0, point  );
   vpack_c (  0.,   2.,  0.,  exppnt );
   vpack_c (  0.0, -4.0, 0.0, u      );
   
   surfpt_c ( point, u, a, b, c, spoint, &found );
   
   chckxc_c ( SPICEFALSE, " ",           ok );
   chcksl_c ( "found", found, SPICETRUE, ok );
   chckad_c ( "Intercept point", 
              spoint,
              "~",
              exppnt,
              3,
              TIGHT_TOL,
              ok                    );
   

   tcase_c ( "Test surfpt_c. View point is above +y axis, ray "
             "points in the -y direction. View point height "
             "is half z semi-axis length."                     );
   
   vpack_c (  0.0,                4.0,   c/2,   point  );
   vpack_c (  0.0,    b*sqrt(3.0)/2.0,   c/2,   exppnt );
   vpack_c (  0.0,            -1.0e-1,   0.0,   u      );
   
   surfpt_c ( point, u, a, b, c, spoint, &found );
   
   chckxc_c ( SPICEFALSE, " ",           ok );
   chcksl_c ( "found", found, SPICETRUE, ok );
   chckad_c ( "Intercept point", 
              spoint,
              "~",
              exppnt,
              3,
              TIGHT_TOL,
              ok                    );



   tcase_c ( "Test surfpt_c. View point is above +y axis, ray "
             "points in the +y direction. View point height "
             "is half z semi-axis length."                     );
   
   vpack_c (  0.0,                4.0,   c/2,   point  );
   vpack_c (  0.0,    b*sqrt(3.0)/2.0,   c/2,   exppnt );
   vpack_c (  0.0,             1.0e-1,   0.0,   u      );
   
   surfpt_c ( point, u, a, b, c, spoint, &found );
   
   chckxc_c ( SPICEFALSE, " ",            ok );
   chcksl_c ( "found", found, SPICEFALSE, ok );
   chckad_c ( "Intercept point", 
              spoint,
              "~",
              zerovec,
              3,
              TIGHT_TOL,
              ok                    );



   
   tcase_c ( "Test surfpt_c. View point is above +y axis, ray "
             "points in the -y direction. View point height "
             "is equal to the z semi-axis length."              );
   
   vpack_c (  0.0,   4.0,  c,     point  );
   vpack_c (  0.0,   0.0,  c,     exppnt );
   vpack_c (  0.0,  -1.0,  0.0,   u      );
   
   surfpt_c ( point, u, a, b, c, spoint, &found );
   
   chckxc_c ( SPICEFALSE, " ",           ok );
   chcksl_c ( "found", found, SPICETRUE, ok );
   chckad_c ( "Intercept point", 
              spoint,
              "~",
              exppnt,
              3,
              TIGHT_TOL,
              ok                    );

   
   tcase_c ( "Test surfpt_c. View point is above +y axis, ray "
             "points in the -y direction. View point height "
             "is greater than z semi-axis length."                 );
   
   vpack_c (  0.0,  4.0,  c*2,   point  );
   vpack_c (  1.,   0.,   c*2.,  exppnt );
   vpack_c (  0.0, -1.0,  0.0,   u      );
   
   surfpt_c ( point, u, a, b, c, spoint, &found );
   
   chckxc_c ( SPICEFALSE, " ",           ok );
   chcksl_c ( "found", found, SPICEFALSE, ok );
   chckad_c ( "Intercept point", 
              spoint,
              "~",
              zerovec,
              3,
              TIGHT_TOL,
              ok                    );



  
   tcase_c ( "Test surfpt_c. View point is on +z axis, ray "
             "points in the -z direction."                   );
   
   vpack_c (  0.0,  0.0,  5.0, point );
   vpack_c  ( 0.,   0.,   3.,  exppnt );
   vpack_c (  0.0,  0.0, -2.0, u     );
   
   surfpt_c ( point, u, a, b, c, spoint, &found );
   
   chckxc_c ( SPICEFALSE, " ",           ok );
   chcksl_c ( "found", found, SPICETRUE, ok );
   chckad_c ( "Intercept point", 
              spoint,
              "~",
              exppnt,
              3,
              TIGHT_TOL,
              ok                    );
   


   tcase_c ( "Test surfpt_c. View point is above the ellipsoid, ray "
             "points in the -z direction. View point x component "
             "is half x semi-axis length."                     );
   
   vpack_c (  a/2,    0.0,      2*c,               point  );
   vpack_c (  a/2,    0.0,      c*sqrt(3.0)/2.0,   exppnt );
   vpack_c (  0.0,    0.0,     -1.0e-1,            u      );
   
   surfpt_c ( point, u, a, b, c, spoint, &found );
   
   chckxc_c ( SPICEFALSE, " ",           ok );
   chcksl_c ( "found", found, SPICETRUE, ok );
   chckad_c ( "Intercept point", 
              spoint,
              "~",
              exppnt,
              3,
              TIGHT_TOL,
              ok                    );



   tcase_c ( "Test surfpt_c. View point is above the ellipsoid, ray "
             "points in the +z direction. View point x component "
             "is half z semi-axis length."                     );
   
   vpack_c (  a/2,                0.0,     2*c,   point  );
   vpack_c (  0.0,    b*sqrt(3.0)/2.0,     2*c,   exppnt );
   vpack_c (  0.0,                0.0,   1.0e-1,  u      );
   
   surfpt_c ( point, u, a, b, c, spoint, &found );
   
   chckxc_c ( SPICEFALSE, " ",            ok );
   chcksl_c ( "found", found, SPICEFALSE, ok );
   chckad_c ( "Intercept point", 
              spoint,
              "~",
              zerovec,
              3,
              TIGHT_TOL,
              ok                    );



   
   tcase_c ( "Test surfpt_c. View point is above the ellipsoid, ray "
             "points in the -z direction. View point x component "
             "is equal to the x semi-axis length."                 );
   
   vpack_c (  a,    0.0,  2*c,   point  );
   vpack_c (  a,    0.0,  0.0,   exppnt );
   vpack_c (  0.0,  0.0, -1.0,   u      );
   
   surfpt_c ( point, u, a, b, c, spoint, &found );
   
   chckxc_c ( SPICEFALSE, " ",           ok );
   chcksl_c ( "found", found, SPICETRUE, ok );
   chckad_c ( "Intercept point", 
              spoint,
              "~",
              exppnt,
              3,
              TIGHT_TOL,
              ok                    );

   
   tcase_c ( "Test surfpt_c. View point is above the ellipoid, ray "
             "points in the -z direction. View point x component "
             "is greater than x semi-axis length."                 );
   
   vpack_c (  2*a,  0.0,   2*c,   point  );
   vpack_c (  1.,   0.,    c*2.,  exppnt );
   vpack_c (  0.0,  0.0,  -1.0,   u      );
   
   surfpt_c ( point, u, a, b, c, spoint, &found );
   
   chckxc_c ( SPICEFALSE, " ",           ok );
   chcksl_c ( "found", found, SPICEFALSE, ok );
   chckad_c ( "Intercept point", 
              spoint,
              "~",
              zerovec,
              3,
              TIGHT_TOL,
              ok                    );



   /*
   Cases where view point is inside the ellipsoid: 
   */

   tcase_c ( "Test surfpt_c. View point is on +x axis, ray "
             "points in the +x direction."                   );
   
   vpack_c (  a/2, 0.0, 0.0, point  );
   vpack_c (  a,   0.0, 0.0, exppnt );
   vpack_c (  5.0, 0.0, 0.0, u      );
   
   surfpt_c ( point, u, a, b, c, spoint, &found );
   
   chckxc_c ( SPICEFALSE, " ",           ok );
   chcksl_c ( "found", found, SPICETRUE, ok );
   chckad_c ( "Intercept point", 
              spoint,
              "~",
              exppnt,
              3,
              TIGHT_TOL,
              ok                    );


   tcase_c ( "Test surfpt_c. View point is on +x axis, ray "
             "points in the -x direction."                   );
   
   vpack_c (  a/2, 0.0, 0.0, point  );
   vpack_c (  -a,  0.0, 0.0, exppnt );
   vpack_c ( -5.0, 0.0, 0.0, u      );
   
   surfpt_c ( point, u, a, b, c, spoint, &found );
   
   chckxc_c ( SPICEFALSE, " ",           ok );
   chcksl_c ( "found", found, SPICETRUE, ok );
   chckad_c ( "Intercept point", 
              spoint,
              "~",
              exppnt,
              3,
              TIGHT_TOL,
              ok                    );

   
   tcase_c ( "Test surfpt_c. View point is above +x axis, ray "
             "points in the +x direction. View point height "
             "is half z semi-axis length."                     );
   
   vpack_c (  a/2,              0.0,  c/2,   point  );
   vpack_c (  a*sqrt(3.0)/2.,   0.0,  c/2,   exppnt );
   vpack_c (  1.0e-1,           0.0,  0.0,   u      );
   
   surfpt_c ( point, u, a, b, c, spoint, &found );
   
   chckxc_c ( SPICEFALSE, " ",           ok );
   chcksl_c ( "found", found, SPICETRUE, ok );
   chckad_c ( "Intercept point", 
              spoint,
              "~",
              exppnt,
              3,
              TIGHT_TOL,
              ok                    );



   tcase_c ( "Test surfpt_c. View point is above +x axis, ray "
             "points in the -x direction. View point height "
             "is half z semi-axis length."                     );
   
   vpack_c (  a/2,              0.0,  c/2,   point  );
   vpack_c ( -a*sqrt(3.0)/2.,   0.0,  c/2,   exppnt );
   vpack_c ( -1.0e-1,           0.0,  0.0,   u      );
   
   surfpt_c ( point, u, a, b, c, spoint, &found );
   
   chckxc_c ( SPICEFALSE, " ",            ok );
   chcksl_c ( "found", found, SPICETRUE, ok );
   chckad_c ( "Intercept point", 
              spoint,
              "~",
              exppnt,
              3,
              TIGHT_TOL,
              ok                    );

  

   /*
   surfpt_c error cases: 
   */

   surfpt_c ( point, u,  0.0,   b,     c,   spoint, &found );
   chckxc_c ( SPICETRUE, "SPICE(BADAXISLENGTH)", ok );

   surfpt_c ( point, u, -1.0,   b,     c,   spoint, &found );
   chckxc_c ( SPICETRUE, "SPICE(BADAXISLENGTH)", ok );

   surfpt_c ( point, u,    a,   0.0,   c,   spoint, &found );
   chckxc_c ( SPICETRUE, "SPICE(BADAXISLENGTH)", ok );

   surfpt_c ( point, u,    a,  -1.0,   c,   spoint, &found );
   chckxc_c ( SPICETRUE, "SPICE(BADAXISLENGTH)", ok );
   
   surfpt_c ( point, u,    a,   b,     0.0, spoint, &found );
   chckxc_c ( SPICETRUE, "SPICE(BADAXISLENGTH)", ok );
   
   surfpt_c ( point, u,    a,   b,    -1.0, spoint, &found );
   chckxc_c ( SPICETRUE, "SPICE(BADAXISLENGTH)", ok );


   vpack_c  ( 0.0, 0.0, 0.0, u );
   surfpt_c ( point, u,    a,   b,  c, spoint, &found );
   chckxc_c ( SPICETRUE, "SPICE(ZEROVECTOR)", ok );




   /*
   surfnm tests:
   */
   
   tcase_c ( "Test surfnm_c." );


   /*
   Use the ellipsoid from the previous tests.
   */
   
   vpack_c (  0.,   0.,   3.,  point  );
   vpack_c (  0.,   0.,   1.,  expnrm );
   
   surfnm_c ( a, b, c, point, normal );
   
   chckxc_c ( SPICEFALSE, " ", ok );
   chckad_c ( "Normal at +Z extreme pt.", 
              normal,
              "~",
              expnrm,
              3,
              TIGHT_TOL,
              ok                    );
   


   /*
   subsol_c tests:
   */
   tcase_c ( "Test subsol_c.  Find the sub-solar point of the sun "
             "on the Earth using the NEARPOINT definition."       );
 
 
   str2et_c ( UTC, &et );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   subsol_c ( "NEARPOINT", "earth", et, "NONE", "sun", spoint  );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   subpt_c  ( "NEARPOINT", "earth", et, "NONE", "sun", exppnt, &alt );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   Make sure the surface points match up.
   */
   chckad_c ( "Geometric sub solar point", 
              spoint, 
              "~~/", 
              exppnt, 
              3,
              TIGHT_TOL, 
              ok                         );
  


   tcase_c ( "Repeat test using integer ID codes." );
 
 
   str2et_c ( UTC, &et );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   subsol_c ( "NEARPOINT", "399", et, "NONE", "10", spoint  );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   subpt_c  ( "NEARPOINT", "399", et, "NONE", "10", exppnt, &alt );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   Make sure the surface points match up.
   */
   chckad_c ( "Geometric sub solar point", 
              spoint, 
              "~~/", 
              exppnt, 
              3,
              TIGHT_TOL, 
              ok                         );
  

   tcase_c ( "Test subsol_c.  Find the sub-solar point of the sun "
             "on the Earth using the INTERCEPT definition."       );
 
 
   str2et_c ( UTC, &et );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   subsol_c ( "INTERCEPT", "earth", et, "NONE", "sun", spoint  );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   subpt_c  ( "INTERCEPT", "earth", et, "NONE", "sun", exppnt, &alt );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   Make sure the surface points match up.
   */
   chckad_c ( "Geometric sub solar point", 
              spoint, 
              "~~/", 
              exppnt, 
              3,
              TIGHT_TOL, 
              ok                         );
  


   tcase_c ( "Test subsol_c:  make sure the solar incidence angle "
             "at the sub-solar point on the moon as seen from the "
             "earth is zero. Use LT+S correction. Near point method." );


   subsol_c ( "near point", "moon", et, "LT+S", "earth", spoint  );
   chckxc_c ( SPICEFALSE, " ", ok );



   illum_c ( "moon",  et,      "LT+S",  "earth",  
             spoint,  &phase,  &solar,  &emissn );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksd_c ( "solar incidence angle", solar, "~", 0.0, TIGHT_TOL, ok );
   
   
   

   tcase_c ( "Test subsol_c:  make sure the solar incidence angle "
             "at the sub-solar point on the moon as seen from the "
             "earth is zero. Use LT+S correction. Intercept method." );


   subsol_c ( "intercept", "moon", et, "LT+S", "earth", spoint  );
   chckxc_c ( SPICEFALSE, " ", ok );



   illum_c ( "moon",  et,      "LT+S",  "earth",  
             spoint,  &phase,  &solar,  &emissn );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksd_c ( "solar incidence angle", solar, "~", 0.0, TIGHT_TOL, ok );
   
   
   

   tcase_c ( "Test subsol_c string error checking." );
 
   /*
   Check string error cases:
   
      1) Null variable name.
      2) Empty variable name.
      
   */

   subsol_c ( NULLCPTR, "earth", et, "NONE", "sun", spoint );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   
   subsol_c ( "", "earth", et, "NONE", "sun", spoint );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );
            
   subsol_c ( "NEARPOINT", NULLCPTR, et, "NONE", "sun", spoint );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   subsol_c ( "NEARPOINT", "", et, "NONE", "sun", spoint );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );

   subsol_c ( "NEARPOINT", "earth", et, NULLCPTR, "sun", spoint );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   subsol_c ( "NEARPOINT", "earth", et, "", "sun", spoint );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );

   subsol_c ( "NEARPOINT", "earth", et, "NONE", NULLCPTR, spoint );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   subsol_c ( "NEARPOINT", "earth", et, "NONE", "", spoint );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );




   /*
   srfxpt_c tests:
   */
   tcase_c ( "Test srfxpt_c.  Find the sub-solar point of the sun "
             "on the Earth. Compare to subpt_c using the INTERCEPT "
             "definition."                                           );
 
 
   str2et_c ( UTC, &et );
   
   subpt_c  ( "INTERCEPT", "earth", et, "NONE", "sun", xspoint, &alt );
   chckxc_c ( SPICEFALSE, " ", ok );

   reclat_c ( xspoint, &sunRad, &sunLon, &sunLat );


   /*
   Re-compute using srfxpt_c. 
   */
   spkpos_c ( "earth", et, "J2000", "NONE", "sun", dvec, &lt );
   chckxc_c ( SPICEFALSE, " ", ok );

   srfxpt_c ( "Ellipsoid",
              "Earth",  et,    "NONE",  "Sun",  "J2000", dvec,
              spoint,   &dist, &trgepc, obspos, &found         );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "found", found, SPICETRUE, ok );

   if ( found  )
   {
      reclat_c ( spoint, &rad, &lon, &lat );

      /*
      Make sure the directional coordinates match up.
      */
      chcksd_c ( "surf xpoint lon", lon, "~", sunLon, MED_TOL,  ok );
      chcksd_c ( "surf xpoint lat", lat, "~", sunLat, MED_TOL, ok );

      chcksd_c ( "trgepc", trgepc, "~", et, TIGHT_TOL, ok );
      chcksd_c ( "dist",   dist,   "~", vdist_c(obspos,spoint), 
                                        TIGHT_TOL, ok );

      /*
      Check the intercept point error in terms of offset magnitude.
      ( "~~" is the symbol for L2 comparison used by chckad_c.)
      */
      chckad_c ( "spoint", spoint, "~~", xspoint, 3, LOOSE_TOL, ok );
   }

   /*
   Re-compute using integer ID codes.
   */
   spkpos_c ( "399", et, "J2000", "NONE", "10", dvec, &lt );
   chckxc_c ( SPICEFALSE, " ", ok );

   srfxpt_c ( "Ellipsoid",
              "399",    et,    "NONE",  "10",  "J2000", dvec,
              spoint,   &dist, &trgepc, obspos, &found         );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "found", found, SPICETRUE, ok );

   if ( found  )
   {
      reclat_c ( spoint, &rad, &lon, &lat );

      /*
      Make sure the directional coordinates match up.
      */
      chcksd_c ( "surf xpoint lon", lon, "~", sunLon, MED_TOL,  ok );
      chcksd_c ( "surf xpoint lat", lat, "~", sunLat, MED_TOL, ok );

      chcksd_c ( "trgepc", trgepc, "~", et, TIGHT_TOL, ok );
      chcksd_c ( "dist",   dist,   "~", vdist_c(obspos,spoint), 
                                        TIGHT_TOL, ok );

      /*
      Check the intercept point error in terms of offset magnitude.
      ( "~~" is the symbol for L2 comparison used by chckad_c.)
      */
      chckad_c ( "spoint", spoint, "~~", xspoint, 3, LOOSE_TOL, ok );
   }


   tcase_c ( "Test srfxpt_c string error checking." );
 
   /*
   Check string error cases:
   
      1) Null variable name.
      2) Empty variable name.
      
   */

   srfxpt_c ( NULLCPTR,
              "Earth",  et,    "NONE",  "Sun",  "J2000", dvec,
              spoint,   &dist, &trgepc, obspos, &found         );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   srfxpt_c ( "",
              "Earth",  et,    "NONE",  "Sun",  "J2000", dvec,
              spoint,   &dist, &trgepc, obspos, &found         );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );


   srfxpt_c ( "Ellipsoid",
              NULLCPTR,  et,    "NONE",  "Sun",  "J2000", dvec,
              spoint,   &dist, &trgepc, obspos, &found         );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   srfxpt_c ( "Ellipsoid",
              "",  et,    "NONE",  "Sun",  "J2000", dvec,
              spoint,   &dist, &trgepc, obspos, &found         );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );


   srfxpt_c ( "Ellipsoid",
              "Earth",  et,    NULLCPTR,  "Sun",  "J2000", dvec,
              spoint,   &dist, &trgepc, obspos, &found         );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   srfxpt_c ( "Ellipsoid",
              "Earth",  et,    "",  "Sun",  "J2000", dvec,
              spoint,   &dist, &trgepc, obspos, &found         );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );


   srfxpt_c ( "Ellipsoid",
              "Earth",  et,    "NONE",  NULLCPTR,  "J2000", dvec,
              spoint,   &dist, &trgepc, obspos, &found         );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   srfxpt_c ( "Ellipsoid",
              "Earth",  et,    "NONE",  "",  "J2000", dvec,
              spoint,   &dist, &trgepc, obspos, &found         );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );


   srfxpt_c ( "Ellipsoid",
              "Earth",  et,    "NONE",  "Sun",  NULLCPTR, dvec,
              spoint,   &dist, &trgepc, obspos, &found         );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   srfxpt_c ( "Ellipsoid",
              "Earth",  et,    "NONE",  "Sun",  "", dvec,
              spoint,   &dist, &trgepc, obspos, &found         );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );



   /*
   srfrec_c tests:
   */
   
   tcase_c ( "Find surface point on earth forr known lat/lon; recover "
             "lat/lon from surface point."                            );

   xlon   =  100.0;
   xlat   =   35.0;

   srfrec_c ( 399, xlon*rpd_c(), xlat*rpd_c(), spoint );
   chckxc_c ( SPICEFALSE, " ", ok );

   reclat_c ( spoint, &rad, &lon, &lat );

   /*
   Check recovered lon/lat:
   */
   chcksd_c ( "lat", lat*dpr_c(), "~", xlat, TIGHT_TOL, ok );
   chcksd_c ( "lon", lon*dpr_c(), "~", xlon, TIGHT_TOL, ok );

   /*
   Just a sanity check for the radius. 
   */
   xrad = 6371.079089;
   chcksd_c ( "rad", rad, "~/", xrad, LOOSE_TOL, ok );


   /*
   srfrec_ error cases: 
   */
   tcase_c ( "srfrec error case:  no radii in kernel pool." );

   /*
   Grab body radii so they can be restored later. 
   */
   bodvrd_c ( "earth", "RADII", 3, &dim, radii );
   chckxc_c ( SPICEFALSE, " ", ok );


   dvpool_c ( "BODY399_RADII" );
   chckxc_c ( SPICEFALSE, " ", ok );

   srfrec_c ( 399, xlon*rpd_c(), xlat*rpd_c(), spoint );
   chckxc_c ( SPICETRUE, "SPICE(KERNELVARNOTFOUND)", ok );
   
   /*
   Restore radii, in case future test cases require them. 
   */
   pdpool_c (  "BODY399_RADII", 3, radii );
   chckxc_c ( SPICEFALSE, " ", ok );



   /*
   Get rid of the SPK file.
   */
   spkuef_c ( handle );
   TRASH   ( SPK    );
   
   

   
   /*
   Retrieve the current test status.
   */ 
   t_success_c ( ok ); 
   
   
} /* End f_ge01_c */

