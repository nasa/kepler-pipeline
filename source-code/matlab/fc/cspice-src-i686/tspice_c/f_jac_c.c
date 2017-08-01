/*

-Procedure f_jac_c ( Test wrappers for Jacobian routines )


-Abstract

   Perform tests on CSPICE wrappers for the Jacobian---coordinate 
   transformation derivative---functions.

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
   #include "SpiceUsr.h"
   #include "SpiceZmc.h"
   #include "tutils_c.h"
   
   void f_jac_c ( SpiceBoolean * ok )

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

   This routine tests the wrappers for the Jacobian routines.
   The current set is:

      dcyldr_c
      dgeodr_c
      dlatdr_c
      dpgrdr_c
      drdcyl_c
      drdgeo_c
      drdlat_c
      drdpgr_c
      drdsph_c
      dsphdr_c
      invort_c

-Examples

   None.

-Restrictions

   None.

-Author_and_Institution

   N.J. Bachman    (JPL)

-Literature_References

   None.

-Version

   -tspice_c Version 2.0.0 26-DEC-2004 (NJB)

       Added tests for

          dpgrdr_c
          drdpgr_c

   -tspice_c Version 1.0.0 28-DEC-2001 (NJB)

-&
*/

{ /* Begin f_jac_c */

   /*
   Local constants
   */
   #define PCK              "f_jac.tpc" 

   #define BIGTOL           ( 1.e-12 )
   #define MEDTOL           ( 1.e-14 )

   /* 
   The Clark radius and flattening factor for Earth:
   */
   #define CLARKR            6378.2064
   #define CLARKF           ( 1.0 / 294.9787 )

   /*
   Local variables
   */


   SpiceDouble             a;
   SpiceDouble             a2;
   SpiceDouble             alt;
   SpiceDouble             b;
   SpiceDouble             b2;
   SpiceDouble             cla;
   SpiceDouble             clo;
   SpiceDouble             cmat    [3][3];
   SpiceDouble             cmat2   [3][3];
   SpiceDouble             colat;
   SpiceDouble             zc;
   SpiceDouble             zc2;
   SpiceDouble             dzc;
   SpiceDouble             f;
   SpiceDouble             invmat  [3][3];
   SpiceDouble             jacobi  [3][3];
   SpiceDouble             jacobiI [3][3];
   SpiceDouble             lat;
   SpiceDouble             lon;
   SpiceDouble             r;
   SpiceDouble             radii   [3];
   SpiceDouble             re;
   SpiceDouble             rectan  [3] ;
   SpiceDouble             rp;
   SpiceDouble             sla;
   SpiceDouble             slo;
   SpiceDouble             v       [3];
   SpiceDouble             x;
   SpiceDouble             y;
   SpiceDouble             xinvmat [3][3];
   SpiceDouble             xjacobi [3][3];
   SpiceDouble             z;

   SpiceInt                i;
   SpiceInt                n;


   /*
   Local macros 
   */


   /*
   Macros for d(R)/d(LAT) and d(LAT)/d(R): 

      x = r * cos(lat) * cos(lon)
      y = r * cos(lat) * sin(lon)
      z = r * sin(lat)

   */
   #define DRDLAT( r, lon, lat, jacobi )                              \
                                                                      \
      jacobi[0][0] =         cos(lon) * cos(lat);                     \
      jacobi[0][1] =    -r * sin(lon) * cos(lat);                     \
      jacobi[0][2] =    -r * cos(lon) * sin(lat);                     \
                                                                      \
      jacobi[1][0] =         sin(lon) * cos(lat);                     \
      jacobi[1][1] =     r * cos(lon) * cos(lat);                     \
      jacobi[1][2] =    -r * sin(lon) * sin(lat);                     \
                                                                      \
      jacobi[2][0] =                    sin(lat);                     \
      jacobi[2][1] =                         0.0;                     \
      jacobi[2][2] =     r *            cos(lat); 


   #define DLATDR( x, y, z, jacobi )                                  \
                                                                      \
      vpack_c  ( x, y,   z,    v        );                            \
      reclat_c ( v, &r,  &lon, &lat     );                            \
      DRDLAT   ( r, lon, lat,  jacobiI  );                            \
      invort_c ( jacobiI,      jacobi   );


   /*
   Macros for d(R)/d(SPH) and d(SPH)/d(R): 

      x = r * sin(colat) * cos(lon) 
      y = r * sin(colat) * sin(lon) 
      z = r * cos(colat)

   */
   #define DRDSPH( r, colat, lon, jacobi )                            \
                                                                      \
      jacobi[0][0] =         sin(colat) * cos(lon);                   \
      jacobi[0][1] =     r * cos(colat) * cos(lon);                   \
      jacobi[0][2] =    -r * sin(colat) * sin(lon);                   \
                                                                      \
      jacobi[1][0] =         sin(colat) * sin(lon);                   \
      jacobi[1][1] =     r * cos(colat) * sin(lon);                   \
      jacobi[1][2] =     r * sin(colat) * cos(lon);                   \
                                                                      \
      jacobi[2][0] =         cos(colat);                              \
      jacobi[2][1] =    -r * sin(colat);                              \
      jacobi[2][2] =                           0.0;                   


   #define DSPHDR( x, y, z, jacobi )                                  \
                                                                      \
      vpack_c  ( x, y,     z,      v       );                         \
      recsph_c ( v, &r,    &colat, &lon    );                         \
      DRDSPH   ( r, colat, lon,    jacobiI );                         \
      invort_c ( jacobiI,          jacobi  );
  




   /*
   Macros for d(R)/d(CYL) and d(CYL)/d(R): 

      x = r cos(lon) 
      y = r sin(lon) 
      z = z

   */
   #define DRDCYL( r, lon, z, jacobi )                                \
                                                                      \
      jacobi[0][0] =                      cos(lon);                   \
      jacobi[0][1] =                -r *  sin(lon);                   \
      jacobi[0][2] =                           0.0;                   \
                                                                      \
      jacobi[1][0] =                      sin(lon);                   \
      jacobi[1][1] =                 r *  cos(lon);                   \
      jacobi[1][2] =                           0.0;                   \
                                                                      \
      jacobi[2][0] =                           0.0;                   \
      jacobi[2][1] =                           0.0;                   \
      jacobi[2][2] =                           1.0;


   #define DCYLDR( x, y, z, jacobi )                                  \
                                                                      \
      vpack_c  ( x, y,     z,      v       );                         \
      reccyl_c ( v, &r,    &lon,   &z      );                         \
      DRDCYL   ( r, lon,   z,      jacobiI );                         \
      invort_c ( jacobiI,          jacobi  );
  



   /*
   Macros for d(R)/d(GEO) and d(GEO)/d(R): 

      This transformation is a wee bit more involved than the others
      we've dealt with above, so we include the derivation of our
      Jacobian formula below.  The first step is to express the
      rectangular coordinates of the input point in terms of 
      geodetic coordinates.
 
      We let A and B be the semi-major axes of the ellipse formed
      by slicing the oblate spheroid of interest by a plane containing
      the z-axis.  We let P0 be the point on the surface of the 
      spheroid closest to the input point, and we let r0 and z0
      be the distance of P0 from the z-axis and the height of P0 
      relative to the x-y plane, respectively.

      The outward normal at P0 has the direction

           2*r0    2*z0
         ( ---- ,  ---- )                                           (1)
             2       2
            A       B

      so we have
                       2
                      A  z0
         tan(lat) =   -----                                         (2)
                       2
                      B  r0

      or equivalently

          4   2   2           4   2    2
         A  z0 cos (lat)  =  B  r0  sin (lat)                       (3)


      The equation of the ellipse itself is 

           2       2
         r0      z0
        ----  + ---- = 1                                            (4)
          2       2
         A       B

      or

          2   2     2   2    2 2
         B  r0  +  A  z0  = A B                                     (5)

      Multiplying this equation by 

          2   2
         B sin (lat)


      yields

          4   2    2          2  2   2    2         2 4   2
         B  r0  sin (lat) +  A  B  z0  sin (lat) = A B sin (lat)    (6)


      or, substituting the LHS of (3),

          4   2    2          2 2  2    2         2  4    2
         A  z0  cos (lat) +  A B z0  sin (lat) = A  B  sin (lat)    (7)


      which may be re-written as 

           2    2   2           2   2           4   2
         z0  ( A cos (lat)  +  B sin (lat) ) = B sin (lat)          (8)

      
      To make this mess look simpler, we'll give the name 

         ZC


      to the positive square root of the coefficient of
      
           2
         z0


      Then (8) becomes

                   4   2
           2      B sin (lat)                                       (9)
         z0   =   -----------
                       2
                     ZC
      

      Since z0 has the same sign as sin(lat), we have

                 2
                B sin(lat)
         z0  =  ----------                                          (10)
                   ZC
                 
      
      Now, to find r0, we re-write (4) as 

                             2
           2      2        z0
         r0  =  A  ( 1 -  ---- )                                    (11)
                            2
                           B

      which, using (9), becomes

                          2    2
           2     2       B  sin (lat)
         r0  =  A ( 1 -  ------------  )                            (12)
                               2
                             ZC

      Using the definition of ZC, we can express (12) as

                  4    2
           2     A  cos (lat)
         r0  =   ------------                                       (13)
                       2
                     ZC


      or, since r0 is non-negative,
                     
                  2    
                 A  cos (lat)
         r0  =   ------------                                       (14)
                     ZC
 

      Having z0 and r0, it's easy to obtain the cylindrical 
      coordinates r and z of the input point:

         r = r0 + alt * cos(lat)                                    (15)

         z = z0 + alt * sin(lat)                                    (16)

      
      At long last, we can write down our rectangular coordinates:

                             2
                            A  
         x =  cos(lon) * ( ---- + alt ) * cos(lat)                  (17)
                            ZC

                             2
                            A  
         y =  sin(lon) * ( ---- + alt ) * cos(lat)                  (18)
                            ZC

                             2
                            B  
         z =             ( ---- + alt ) * sin(lat)                  (19)
                            ZC
      

   */

   
   #define DRDGEO( lon, lat, alt, re, f, jacobi )                       \
                                                                        \
      a   = re;                                                         \
      a2  = a*a;                                                        \
      b   = a * (1.0-f);                                                \
      b2  = b*b;                                                        \
      sla = sin(lat);                                                   \
      cla = cos(lat);                                                   \
      slo = sin(lon);                                                   \
      clo = cos(lon);                                                   \
      zc  = sqrt ( a2*cla*cla + b2*sla*sla );                           \
      zc2 = zc*zc;                                                      \
      dzc = sla*cla*(b2 - a2) / zc;                                     \
                                                                        \
                                                                        \
      jacobi[0][0] = -slo * ( (a2/zc) + alt ) * cla;                    \
                                                                        \
      jacobi[0][1] =  clo * ( (-a2*dzc/zc2)*cla - sla*(alt + a2/zc) );  \
                                                                        \
      jacobi[0][2] =  clo * cla;                                        \
                                                                        \
                                                                        \
      jacobi[1][0] =  clo * ( (a2/zc) + alt ) * cla;                    \
                                                                        \
      jacobi[1][1] =  slo * ( (-a2*dzc/zc2)*cla - sla*(alt + a2/zc) );  \
                                                                        \
      jacobi[1][2] =  slo * cla;                                        \
                                                                        \
                                                                        \
      jacobi[2][0] =   0.0;                                             \
                                                                        \
      jacobi[2][1] =   (-dzc*b2/zc2)*sla + (alt + b2/zc)*cla;           \
                                                                        \
      jacobi[2][2] =   sla;




   #define DGEODR( x, y, z, re, f, jacobi )                             \
                                                                        \
      vpack_c  ( x,   y,   z,   v                   );                  \
      recgeo_c ( v,   re,  f,   &lon, &lat, &alt    );                  \
      DRDGEO   ( lon, lat, alt, re,   f,    jacobiI );                  \
      invort_c ( jacobiI,                   jacobi  );
  



   topen_c ( "f_jac_c" );

   /*
   Case 1: 
   */
   tcase_c  ( "invort_c test.  Compare results against invert_c." );

   /*
   Create a matrix having orthogonal columns of different lengths. 
   */
   eul2m_c ( 12.0*rpd_c(), 35.0*rpd_c(), -20*rpd_c(), 3, 2, 3, cmat );
   chckxc_c ( SPICEFALSE, " ", ok );

   xpose_c ( cmat, cmat );
 
   vscl_c  ( 5,     cmat[0], cmat[0] );
   vscl_c  ( 0.1,   cmat[1], cmat[1] );
   vscl_c  ( 6.e10, cmat[2], cmat[2] );
   
   xpose_c ( cmat, cmat );

   /*
   Invert this matrix using invort_c and invert_c. 
   */   
   invort_c ( cmat, invmat  );
   chckxc_c ( SPICEFALSE, " ", ok );

   invert_c ( cmat, xinvmat );
   chckxc_c ( SPICEFALSE, " ", ok );

   chckad_c ( "invmat (absolute error)", 
              (SpiceDouble *)invmat, 
              "~", 
              (SpiceDouble *)xinvmat, 
              9, 
              MEDTOL, 
              ok                     );

   chckad_c ( "invmat (relative error)", 
              (SpiceDouble *)invmat, 
              "~/", 
              (SpiceDouble *)xinvmat, 
              9, 
              MEDTOL, 
              ok                     );

   /*
   Case 2: 
   */
   tcase_c  ( "invort_c test.  Zero-length column." );

   MOVED ( cmat, 9, cmat2 );

   cmat2[0][1] = 0.0;
   cmat2[1][1] = 0.0;
   cmat2[2][1] = 0.0;
   
   invort_c ( cmat2, xinvmat );
   chckxc_c ( SPICETRUE, "SPICE(ZEROLENGTHCOLUMN)", ok );



   /*
   Case 3: 
   */
   tcase_c  ( "drdlat_c test.  Compare results from alternate"
              "computations."                                  );

   r   =   3.0;
   lon =  44.0 * rpd_c();
   lat = -12.0 * rpd_c();

   drdlat_c ( r, lon, lat, jacobi );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   printf ( "jacobi  = %25.17f %25.17f %25.17f\n"
            "          %25.17f %25.17f %25.17f\n"
            "          %25.17f %25.17f %25.17f\n",
            jacobi[0][0], jacobi[0][1], jacobi[0][2], 
            jacobi[1][0], jacobi[1][1], jacobi[1][2], 
            jacobi[2][0], jacobi[2][1], jacobi[2][2] );
   */

   DRDLAT (  r, lon, lat, xjacobi );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*   
   printf ( "xjacobi = %25.17f %25.17f %25.17f\n"
            "          %25.17f %25.17f %25.17f\n"
            "          %25.17f %25.17f %25.17f\n",
            xjacobi[0][0], xjacobi[0][1], xjacobi[0][2], 
            xjacobi[1][0], xjacobi[1][1], xjacobi[1][2], 
            xjacobi[2][0], xjacobi[2][1], xjacobi[2][2] );
   */

   chckad_c ( "jacobi (absolute error)", 
              (SpiceDouble *)jacobi, 
              "~", 
              (SpiceDouble *)xjacobi, 
              9, 
              MEDTOL, 
              ok                     );

   chckad_c ( "jacobi (relative error)", 
              (SpiceDouble *)jacobi, 
              "~/", 
              (SpiceDouble *)xjacobi, 
              9, 
              MEDTOL, 
              ok                     );


   /*
   Case 4: 
   */
   tcase_c  ( "dlatdr_c test.  Compare results from alternate"
              "computations."                                  );

   chckxc_c ( SPICEFALSE, " ", ok );
   latrec_c ( r, lon, lat, v );

   dlatdr_c ( v[0], v[1], v[2], jacobi  );
   chckxc_c ( SPICEFALSE, " ", ok );

   DLATDR   ( v[0], v[1], v[2], xjacobi );
   chckxc_c ( SPICEFALSE, " ", ok );


   chckad_c ( "jacobi (absolute error)", 
              (SpiceDouble *)jacobi, 
              "~", 
              (SpiceDouble *)xjacobi, 
              9, 
              MEDTOL, 
              ok                     );

   chckad_c ( "jacobi (relative error)", 
              (SpiceDouble *)jacobi, 
              "~/", 
              (SpiceDouble *)xjacobi, 
              9, 
              MEDTOL, 
              ok                     );


   /*
   Case 5: 
   */
   tcase_c  ( "dlatdr_c test.  Point on z-axis." );


   dlatdr_c ( 0.0,  0.0, v[2], jacobi  );
   chckxc_c ( SPICETRUE, "SPICE(POINTONZAXIS)", ok );



   /*
   Case 6: 
   */
   tcase_c  ( "drdsph_c test.  Compare results from alternate"
              "computations."                                  );

   r     =   3.0;
   lon   =  44.0 * rpd_c();
   colat =  12.0 * rpd_c();

   drdsph_c ( r, colat, lon, jacobi );
   chckxc_c ( SPICEFALSE, " ", ok );


   DRDSPH (  r, colat, lon, xjacobi );
   chckxc_c ( SPICEFALSE, " ", ok );


   chckad_c ( "jacobi (absolute error)", 
              (SpiceDouble *)jacobi, 
              "~", 
              (SpiceDouble *)xjacobi, 
              9, 
              MEDTOL, 
              ok                     );

   chckad_c ( "jacobi (relative error)", 
              (SpiceDouble *)jacobi, 
              "~/", 
              (SpiceDouble *)xjacobi, 
              9, 
              MEDTOL, 
              ok                     );

   /*
   Case 7: 
   */
   tcase_c  ( "dsphdr_c test.  Compare results from alternate"
              "computations."                                  );

   chckxc_c ( SPICEFALSE, " ", ok );
   sphrec_c ( r, halfpi_c()-lat, lon, v );

   dsphdr_c ( v[0], v[1], v[2], jacobi  );
   chckxc_c ( SPICEFALSE, " ", ok );

   DSPHDR   ( v[0], v[1], v[2], xjacobi );
   chckxc_c ( SPICEFALSE, " ", ok );


   chckad_c ( "jacobi (absolute error)", 
              (SpiceDouble *)jacobi, 
              "~", 
              (SpiceDouble *)xjacobi, 
              9, 
              MEDTOL, 
              ok                     );

   chckad_c ( "jacobi (relative error)", 
              (SpiceDouble *)jacobi, 
              "~/", 
              (SpiceDouble *)xjacobi, 
              9, 
              MEDTOL, 
              ok                     );


   /*
   Case 8: 
   */
   tcase_c  ( "dsphdr_c test.  Point on z-axis." );


   dsphdr_c ( 0.0,  0.0, v[2], jacobi  );
   chckxc_c ( SPICETRUE, "SPICE(POINTONZAXIS)", ok );



   /*
   Case 9: 
   */
   tcase_c  ( "drdcyl_c test.  Compare results from alternate"
              "computations."                                  );

   r     =   3.0;
   lon   =  44.0 * rpd_c();
   z     =  12.0;

   drdcyl_c ( r, lon, z, jacobi );
   chckxc_c ( SPICEFALSE, " ", ok );


   DRDCYL (  r, lon, z, xjacobi );
   chckxc_c ( SPICEFALSE, " ", ok );


   chckad_c ( "jacobi (absolute error)", 
              (SpiceDouble *)jacobi, 
              "~", 
              (SpiceDouble *)xjacobi, 
              9, 
              MEDTOL, 
              ok                     );

   chckad_c ( "jacobi (relative error)", 
              (SpiceDouble *)jacobi, 
              "~/", 
              (SpiceDouble *)xjacobi, 
              9, 
              MEDTOL, 
              ok                     );

   /*
   Case 10: 
   */
   tcase_c  ( "dcyldr_c test.  Compare results from alternate"
              "computations."                                  );

   chckxc_c ( SPICEFALSE, " ", ok );
   cylrec_c ( r, lon, z, v );

   dcyldr_c ( v[0], v[1], v[2], jacobi  );
   chckxc_c ( SPICEFALSE, " ", ok );

   DCYLDR   ( v[0], v[1], v[2], xjacobi );
   chckxc_c ( SPICEFALSE, " ", ok );


   chckad_c ( "jacobi (absolute error)", 
              (SpiceDouble *)jacobi, 
              "~", 
              (SpiceDouble *)xjacobi, 
              9, 
              MEDTOL, 
              ok                     );

   chckad_c ( "jacobi (relative error)", 
              (SpiceDouble *)jacobi, 
              "~/", 
              (SpiceDouble *)xjacobi, 
              9, 
              MEDTOL, 
              ok                     );


   /*
   Case 11: 
   */
   tcase_c  ( "dcyldr_c test.  Point on z-axis." );


   dcyldr_c ( 0.0,  0.0, v[2], jacobi  );
   chckxc_c ( SPICETRUE, "SPICE(POINTONZAXIS)", ok );





   /*
   Case 12: 
   */
   tcase_c  ( "drdgeo_c test.  Compare results from alternate"
              "computations."                                  );

   
   lon   =  44.0 * rpd_c();
   lat   = -12.0 * rpd_c();
   alt   =   3.0;
   re    =  10.0;
   f     =   0.2;

   drdgeo_c ( lon, lat, alt, re, f, jacobi );
   chckxc_c ( SPICEFALSE, " ", ok );


   DRDGEO (  lon, lat, alt, re, f, xjacobi );
   chckxc_c ( SPICEFALSE, " ", ok );


   chckad_c ( "jacobi (absolute error)", 
              (SpiceDouble *)jacobi, 
              "~", 
              (SpiceDouble *)xjacobi, 
              9, 
              MEDTOL, 
              ok                     );

   chckad_c ( "jacobi (relative error)", 
              (SpiceDouble *)jacobi, 
              "~/", 
              (SpiceDouble *)xjacobi, 
              9, 
              MEDTOL, 
              ok                     );

   /*
   Repeat with a negative flattening factor. 
   */
 
   f     =   -0.5;

   drdgeo_c ( lon, lat, alt, re, f, jacobi );
   chckxc_c ( SPICEFALSE, " ", ok );


   DRDGEO (  lon, lat, alt, re, f, xjacobi );
   chckxc_c ( SPICEFALSE, " ", ok );


   chckad_c ( "jacobi (absolute error)", 
              (SpiceDouble *)jacobi, 
              "~", 
              (SpiceDouble *)xjacobi, 
              9, 
              MEDTOL, 
              ok                     );

   chckad_c ( "jacobi (relative error)", 
              (SpiceDouble *)jacobi, 
              "~/", 
              (SpiceDouble *)xjacobi, 
              9, 
              MEDTOL, 
              ok                     );
 


   /*
   Case 13: 
   */
   tcase_c  ( "drdgeo_c test. Flattening factor >= 1."  );

   f = 1.0;

   drdgeo_c ( lon, lat, alt, re, f, jacobi );
   chckxc_c ( SPICETRUE, "SPICE(VALUEOUTOFRANGE)", ok );

   f = 2.0;

   drdgeo_c ( lon, lat, alt, re, f, jacobi );
   chckxc_c ( SPICETRUE, "SPICE(VALUEOUTOFRANGE)", ok );


   /*
   Case 14: 
   */
   tcase_c  ( "drdgeo_c test. Invalid equatorial radius"  );

   f  = 0.2;
   re = 0.0;

   drdgeo_c ( lon, lat, alt, re, f, jacobi );
   chckxc_c ( SPICETRUE, "SPICE(BADRADIUS)", ok );

   re = -1.0;

   drdgeo_c ( lon, lat, alt, re, f, jacobi );
   chckxc_c ( SPICETRUE, "SPICE(BADRADIUS)", ok );


   /*
   Case 15: 
   */
   tcase_c  ( "dgeodr_c test.  Compare results from alternate"
              "computations."  ); 

   /*
   We're using a negative flattening factor here. 
   */
   re = 10.0;
   f =  -0.5;

   chckxc_c ( SPICEFALSE, " ", ok );
   georec_c ( lat, lon, alt, re, f, v );

   dgeodr_c ( v[0], v[1], v[2], re, f, jacobi  );
   chckxc_c ( SPICEFALSE, " ", ok );

   DGEODR   ( v[0], v[1], v[2], re, f, xjacobi );
   chckxc_c ( SPICEFALSE, " ", ok );


   chckad_c ( "jacobi (absolute error)", 
              (SpiceDouble *)jacobi, 
              "~", 
              (SpiceDouble *)xjacobi, 
              9, 
              MEDTOL, 
              ok                     );

   chckad_c ( "jacobi (relative error)", 
              (SpiceDouble *)jacobi, 
              "~/", 
              (SpiceDouble *)xjacobi, 
              9, 
              MEDTOL, 
              ok                     );

   /*
   Go back to a positive flattening factor.
   */                               
   f     =   0.2;

   chckxc_c ( SPICEFALSE, " ", ok );
   georec_c ( lat, lon, alt, re, f, v );

   dgeodr_c ( v[0], v[1], v[2], re, f, jacobi  );
   chckxc_c ( SPICEFALSE, " ", ok );

   DGEODR   ( v[0], v[1], v[2], re, f, xjacobi );
   chckxc_c ( SPICEFALSE, " ", ok );


   chckad_c ( "jacobi (absolute error)", 
              (SpiceDouble *)jacobi, 
              "~", 
              (SpiceDouble *)xjacobi, 
              9, 
              MEDTOL, 
              ok                     );

   chckad_c ( "jacobi (relative error)", 
              (SpiceDouble *)jacobi, 
              "~/", 
              (SpiceDouble *)xjacobi, 
              9, 
              MEDTOL, 
              ok                     );



   /*
   Case 16: 
   */
   tcase_c  ( "dgeodr_c test.  Point on z-axis." );


   dgeodr_c ( 0.0,  0.0, v[2], re, f, jacobi  );
   chckxc_c ( SPICETRUE, "SPICE(POINTONZAXIS)", ok );



   /*
   Case 17: 
   */
   tcase_c  ( "dgeodr_c test. Flattening factor >= 1."  );

   f = 1.0;

   dgeodr_c ( v[0], v[1], v[2], re, f, jacobi );
   chckxc_c ( SPICETRUE, "SPICE(VALUEOUTOFRANGE)", ok );

   f = 2.0;

   dgeodr_c ( v[0], v[1], v[2], re, f, jacobi );
   chckxc_c ( SPICETRUE, "SPICE(VALUEOUTOFRANGE)", ok );


   /*
   Case 18: 
   */
   tcase_c  ( "dgeodr_c test. Invalid equatorial radius"  );

   f  = 0.2;
   re = 0.0;

   dgeodr_c ( v[0], v[1], v[2], re, f, jacobi );
   chckxc_c ( SPICETRUE, "SPICE(BADRADIUS)", ok );

   re = -1.0;

   dgeodr_c ( v[0], v[1], v[2], re, f, jacobi );
   chckxc_c ( SPICETRUE, "SPICE(BADRADIUS)", ok );


   /*
   ----- Case -------------------------------------------------------
   */

   tcase_c  ( "drdpgr_c test. Compare against drdgeo_c for Mars."  );

   tstpck_c ( PCK, SPICETRUE, SPICEFALSE );
   chckxc_c ( SPICEFALSE, " ", ok );

   lon =  90.0  * rpd_c();
   lat =  45.0  * rpd_c();
   alt =   3.e2;
   
   bodvrd_c ( "Mars", "RADII", 3, &n, radii );

   re  =   radii[0];
   rp  =   radii[2]; 
   f   =   ( re - rp ) / re;

   drdpgr_c ( "Mars",  lon, lat, alt, re, f, jacobi  );
   chckxc_c ( SPICEFALSE, " ", ok );

   drdgeo_c (         -lon, lat, alt, re, f, xjacobi );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   Adjust the partials with respect to longitude in xjacobi.
   */
   for ( i = 0;  i < 3;  i++ )
   {
      xjacobi[i][0] *= -1.0;
   }

   chckad_c ( "jacobi (absolute error)", 
              (SpiceDouble *)jacobi, 
              "~", 
              (SpiceDouble *)xjacobi, 
              9, 
              MEDTOL, 
              ok                     );

   /*
   ----- Case -------------------------------------------------------
   */
   tcase_c  ( "drdpgr_c test.  Error case:  body is null."  );

   drdpgr_c ( NULLCPTR,  lon, lat, alt, re, f, jacobi  );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   /*
   ----- Case -------------------------------------------------------
   */
   tcase_c  ( "drdpgr_c test.  Error case:  body is empty."  );

   drdpgr_c ( "",  lon, lat, alt, re, f, jacobi  );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );


   /*
   ----- Case -------------------------------------------------------
   */
   tcase_c  ( "dpgrdr_c test. Compare against dgeodr_c for Mars."  );
   

   /*
   First generate rectangular coordinates.
   */
   pgrrec_c ( "Mars", lon, lat, alt, re, f, rectan );
   chckxc_c ( SPICEFALSE, " ", ok );

   x = rectan[0];
   y = rectan[1];
   z = rectan[2];

   dpgrdr_c ( "Mars",  x, y, z, re, f, jacobi  );
   chckxc_c ( SPICEFALSE, " ", ok );

   dgeodr_c (          x, y, z, re, f, xjacobi  );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   Adjust the gradient of longitude in xjacobi.
   */
   for ( i = 0;  i < 3;  i++ )
   {
      xjacobi[0][i] *= -1.0;
   }

   chckad_c ( "jacobi (absolute error)", 
              (SpiceDouble *)jacobi, 
              "~", 
              (SpiceDouble *)xjacobi, 
              9, 
              MEDTOL, 
              ok                     );

   /*
   ----- Case -------------------------------------------------------
   */
   tcase_c  ( "dpgrdr_c test.  Error case:  body is null."  );

   dpgrdr_c ( NULLCPTR, x, y, z,  re, f, jacobi  );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   /*
   ----- Case -------------------------------------------------------
   */
   tcase_c  ( "dpgrdr_c test.  Error case:  body is empty."  );

   dpgrdr_c ( "",  x, y, z, re, f, jacobi  );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );


   /*
   Retrieve the current test status.
   */
   t_success_c ( ok );

} /* End f_jac_c */

