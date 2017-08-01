/*

-Procedure f_inry_c ( Test inrypl_c )

 
-Abstract
 
   Perform tests on inrypl_c.
 
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
   

   void f_inry_c ( SpiceBoolean * ok )

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
 
   This routine tests the CSPICE routine inrypl_c.


   Overview of test procedure
   --------------------------

   There are three general kinds of tests applied to whack the
   candidate CSPICE function around.  The categories are:

      -- Normal (non-exceptional) test cases whose results are
         easy to check by hand.  These allow a tester to verify
         that the tested routine is at least doing reasonable-looking
         things.  (Expected results are shown for comparison.)

      -- Normal test cases based on random inputs.  These
         allow testing of a large number of cases.  Results will
         be checked as follows:

              The distance between the ray's vertex VERTEX and
              the intercept point XPT will be computed.  This
              distance will be used to scale the negative of the
              ray's unit direction vector.  The scaled vector
              will be added to XPT.  The difference between the
              resulting vector and VERTEX will be divided by
              the distance between VERTEX and XPT, and this scaled
              difference will be used a measure of the error made
              in computing the intercept point.


      -- Exceptional cases.  All of the error detection code will
         be exercised by these cases.

                 
-Examples
 
   None.
    
-Restrictions
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
 
-Literature_References
 
   None. 
 
-Version
 
   -tspice_c Version 1.0.0 29-JUL-1999 (NJB)  

-&
*/

{ /* Begin f_inry_c */

 

   /*
   Constants
   */
   #define  NBASIC         11
   #define  NRAND          500
   #define  NCASE        ( NBASIC + NRAND )
   #define  LNSIZE         81
   #define  MAXRE          1.e-11
   #define  INIT_SEED      99999
 
 
   /*
   Private macros
   */
   #define CLEARV(v)  { (v)[0] = 0.0; (v)[1] = 0.0; (v)[2] = 0.0; } 
 
   /*
   Static variables
   */


   /*
   
   Here are the data values for the basic test cases:
   

      1)
 
      Planes' normal vector:                  ( 0,   0,   1 )
      Plane constant:                           0
      Ray's vertex:                           ( 0,   0,   2 )
      Ray's direction vector:                 ( 0,   0,  -1 )
      Expected number of intercept points:      1
      Expected intercept point:               ( 0,   0,   0 )
   
   
      2)
 
      Planes' normal vector:                  ( 0,     0,     1     )
      Plane constant:                           10
      Ray's vertex:                           ( 0,     0,     20    )
      Ray's direction vector:                 ( 0,     3,    -1     )
      Expected number of intercept points:      1
      Expected intercept point:               ( 0,     30     10    )
 
   
      3)
 
      Planes' normal vector:                  ( 0,   0,   1 )
      Plane constant:                           0
      Ray's vertex:                           ( 1,   1,   0 )
      Ray's direction vector:                 ( 0,   0,  -1 )
      Expected number of intercept points:      1
      Expected intercept point:               ( 1,   1,   0 )


      4)
 
      Planes' normal vector:                  ( 0,   1,   0 )
      Plane constant:                           0
      Ray's vertex:                           ( 0,   0,   0 )
      Ray's direction vector:                 ( 1,   0,   0 )
      Expected number of intercept points:     -1 (infinite)
      Expected intercept point:               ( 0,   0,   0 )
 
      5)
 
      Planes' normal vector:                  ( 0,   0,   1 )
      Plane constant:                           0
      Ray's vertex:                           ( 1,   1,   1 )
      Ray's direction vector:                 ( 1,   0,   0 )
      Expected number of intercept points:      0
      Expected intercept point:               ( 0,   0,   0 )
 
      6)
 
      Planes' normal vector:                  ( 0,     0,       1 )
      Plane constant:                           0
      Ray's vertex:                           ( 1,     1,       1 )
      Ray's direction vector:                 ( 0,     1.e16,  -1 )
      Expected number of intercept points:      1
      Expected intercept point:               ( 1,     1.e16,   0 )
 
      7)
 
      Planes' normal vector:                  ( 0,     0,        1 )
      Plane constant:                           0
      Ray's vertex:                           ( 1,     1,        1 )
      Ray's direction vector:                 ( 0,     1.e308,  -1 )
      Expected number of intercept points:      0
      Expected intercept point:               ( 0,     0,        0 )
 
      8)
 
      Planes' normal vector:                  ( 0,     0,       1      )
      Plane constant:                           1.e306
      Ray's vertex:                           ( 1,     1,       2.e306 )
      Ray's direction vector:                 ( 0,     1000,   -1      )
      Expected number of intercept points:      0
      Expected intercept point:               ( 0,     0,       0 )
 
      9)
 
      Planes' normal vector:                  ( 0,       0,       1    )
      Plane constant:                          -1.e306
      Ray's vertex:                           ( 1.e306,  0,       0    )
      Ray's direction vector:                 ( 1,       0,      -1    )
      Expected number of intercept points:      1
      Expected intercept point:               ( 2.e306,  0,    -1.e306 )
 
      10)
 
      Planes' normal vector:                  ( 0,        0,    1      )
      Plane constant:                          -1.e-306
      Ray's vertex:                           ( 1.e-306,  0,    0      )
      Ray's direction vector:                 ( 1,        0,   -1      )
      Expected number of intercept points:      1
      Expected intercept point:               ( 2.e-306,  0,   -1.e306 )
 
      11)
 
      Planes' normal vector:                  ( 0,       0,       1    )
      Plane constant:                           1
      Ray's vertex:                           ( 0,       0,       0    )
      Ray's direction vector:                 ( 1,       0,      -1    )
      Expected number of intercept points:      0
      Expected intercept point:               ( 0,       0,       0    )
 
   */
   

   static SpiceDouble      plnorm [NBASIC][3] =
   
                           {  { 0.,   0.,   1. },
                              { 0.,   0.,   1. },
                              { 0.,   0.,   1. },
                              { 0.,   1.,   0. },
                              { 0.,   0.,   1. },
                              { 0.,   0.,   1. },
                              { 0.,   0.,   1. },
                              { 0.,   0.,   1. },
                              { 0.,   0.,   1. },
                              { 0.,   0.,   1. },
                              { 0.,   0.,   1. }  
                           };
   
   
   static SpiceDouble      plcons [NBASIC] =
   
                           {  0.,      10.,       0.,    0., 
                              0.,       0.,       0.,    1.e306,
                             -1.e306,  -1.e-306,  1.
                           };
   
   
   static SpiceDouble      vertex [NBASIC][3] = 
   
                           {  { 0.,       0.,    2.     },
                              { 0.,       0.,   20.     },
                              { 1.,       1.,    0.     },
                              { 0.,       0.,    0.     },
                              { 1.,       1.,    1.     },
                              { 1.,       1.,    1.     },
                              { 1.,       1.,    1.     },
                              { 1.,       1.,    2.e306 },
                              { 1.e306,   0.,    0.     },
                              { 1.e-306,  0.,    0.     },
                              { 0.,       0.,    0.     }
                           };
                           
                           
   static SpiceDouble      dir    [NBASIC][3] =
              
                           {  { 0.,   0.,     -1. },
                              { 0.,   3.,     -1. },
                              { 0.,   0.,     -1. },
                              { 1.,   0.,      0. },
                              { 1.,   0.,      0. },
                              { 0.,   1.e16,  -1. },
                              { 0.,   1.e308, -1. },
                              { 0.,   1.e3,   -1. },
                              { 1.,   0.,     -1. },
                              { 1.,   0.,     -1. },
                              { 1.,   0.,     -1. }
                           };
                           
                           
                           
   static SpiceInt         expno  [NBASIC] =
   
                           { 1, 1, 1, -1, 0, 1, 0, 0, 1, 1, 0
                           };

   static SpiceDouble      expxpt [NBASIC][3] = 
    
                           {  { 0.,      0.,      0.      },
                              { 0.,     30.,     10.      },
                              { 1.,      1.,      0.      },
                              { 0.,      0.,      0.      },
                              { 0.,      0.,      0.      },
                              { 1.,      1.e16,   0.      },
                              { 0.,      0.,      0.      },
                              { 0.,      0.,      0.      },
                              { 2.e306,  0.,     -1.e306  },
                              { 2.e-306, 0.,     -1.e-306 },
                              { 0.,      0.,      0.      }
                           };


   SpiceDouble             normal[3];
   SpiceDouble             cons;

 
   /*
   Local variables
   */
   
   SpiceBoolean            sepok;


   SpiceChar               line   [ LNSIZE ];

   SpiceDouble             diff   [3];
   SpiceDouble             error  [3];
   SpiceDouble             scale;
   SpiceDouble             xpt    [3];
   SpiceDouble             errv   [3];
   SpiceDouble             errd   [3];
   SpiceDouble             errn   [3];
   SpiceDouble             errc;
   SpiceDouble             d      [3];
   SpiceDouble             v      [3];
   SpiceDouble             v2     [3];
   SpiceDouble             n      [3];
   SpiceDouble             c;
   SpiceDouble             sep;
   SpiceDouble             vprj   [3];
   SpiceDouble             toobig;

   SpiceInt                nxpts;
   SpiceInt                i;
   SpiceInt                seed;

   SpicePlane              plane;
 
 






   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_inry_c" );
   

   
   
   /*
   Cases 1--NBASIC:
   */


   /*
   "We'll start out with some easy-to-check cases (11 of them)."  
   */

   for ( i = 0;  i < NBASIC;  i++ )
   {
      sprintf ( line, "Basic case %d", (int)i );
      tcase_c ( line );

      /* 
      Make a SPICELIB plane from the plane constant and normal vector.
      */
      
      nvc2pl_c ( plnorm[i], plcons[i], &plane );
      pl2nvc_c ( &plane, normal, &cons );
      
      /*
      Call the routine to be tested.
      */
      inrypl_c ( vertex[i], dir[i],  &plane, &nxpts, xpt );
      chckxc_c ( SPICEFALSE, " ", ok );
 
      chcksi_c ( "nxpts---number of intercept points",
                 nxpts,
                 "=",
                 expno[i],
                 0,
                 ok                                    );
      
      chckad_c( "xpt--intercept", xpt, "~~/", expxpt[i], 3, MAXRE, ok );
   }


 
   /*
   Now for the random cases.
   */
      
 
 
   seed = INIT_SEED;
   
   for ( i = 0;  i < NRAND;  i++ )
   {
      sprintf ( line, "Random case %d", (int)i );
      tcase_c ( line );
   
      
      /*
      Generate a random scale factor.
      */
      scale =  pow (  10.,  rani_c( -306, 306 )  );

      
      /*
      Generate a normal vector and plane constant, and from these
      a SPICELIB plane.
      */
      n[0]  =  rand_c ( -2.e0, 2.e0 );
      n[1]  =  rand_c ( -2.e0, 2.e0 );
      n[2]  =  rand_c ( -2.e0, 2.e0 );


      vhat_c ( n, n );

      c  =  rand_c ( -2.e0, 2.e0 )  *  scale;

      nvc2pl_c ( n, c, &plane );

      /*
      Now generate a random ray vertex and ray direction vector.
      */
      v[0]  =  rand_c ( -2.e0, 2.e0 );
      v[1]  =  rand_c ( -2.e0, 2.e0 );
      v[2]  =  rand_c ( -2.e0, 2.e0 );

      vscl_c ( scale, v, v );

      d[0]  =  rand_c ( -2.e0, 2.e0 );
      d[1]  =  rand_c ( -2.e0, 2.e0 );
      d[2]  =  rand_c ( -2.e0, 2.e0 );
 
      /*
      The call.
      */
      inrypl_c ( v, d, &plane, &nxpts, xpt );
      chckxc_c ( SPICEFALSE, " ", ok );
 
      /*
      We can pretty safely assume that we won't see a value of
      -1 for nxpts.  If the value is 1, we'll try to get back from
      xpt to the ray's vertex.
      */
   
      if ( nxpts == 1 )  
      {
         vsub_c  (  v,  xpt,  diff  );

         vhat_c  (  d,  d  );

         vlcom_c (  1.e0, xpt,  -vnorm_c(diff), d, v2 );

         vsub_c  (  v,  v2,  error );


         chckad_c ( "inversion error", 
                     v, "~~/", v2, 3, MAXRE, ok );

      }
      else
      {
         /*
         Check the angular separation between the ray
         and the vector from the ray's vertex to its orthogonal
         projection to the plane.
         */
         
         vprjp_c ( v,      &plane,  vprj );
         vsub_c  ( vprj,   v,       diff );

         sep    =  vsep_c ( diff, d );

         toobig = dpmax_c() / 3;


         if ( sep*dpr_c() >= 90. ) 
         {
            /*
            The ray is parallel to or points away from the plane.
            */
            sepok = SPICETRUE;
         }
         
         else if (   sep   >   atan2( toobig, vnorm_c(diff) )  ) 
         {
            /*
            It doesn't happen often, but we might have a case
            where the ray is too close to being parallel with
            the plane for an intersection to occur.
            */
            sepok = SPICETRUE;
         }
         
         else
         {
            /*
            This shouldn't happen.
            */
            sepok = SPICEFALSE;
         }

         chcksl_c ( "sepok---is angular separation of ray "
                    "and plane consistent?",
                    sepok,
                    SPICETRUE,
                    ok                                    );
      } 
   }


   /*
   Now for the exceptions.
   */
   
   /*
   Exception 1:
   */
   tcase_c ( "Exception:  ray's direction is the zero vector." );

   CLEARV ( errv );
   CLEARV ( errd );

   CLEARV ( errn );
   
   errn[2] = 1.e0;

   errc    = 0.e0;

   nvc2pl_c ( errn, errc, &plane );

   inrypl_c ( errv, errd, &plane, &nxpts, xpt );
   chckxc_c ( SPICETRUE, "SPICE(ZEROVECTOR)", ok );




   
   /*
   Exception 2:
   */
   tcase_c ( "Exception:  Ray's vertex is just too big." );
   
   CLEARV ( errv );
   errv[2] = 1.e308;

   CLEARV ( errd );
   errd[2] = -1.e0;

   CLEARV ( errn );
   errn[2] = 1.e0;

   errc = 0.e0;

   nvc2pl_c ( errn, errc, &plane );

   inrypl_c ( errv, errd, &plane, &nxpts, xpt );
   chckxc_c ( SPICETRUE, "SPICE(VECTORTOOBIG)", ok );


   /*
   Exception 3:
   */
   tcase_c ( "Exception:  Plane is too far from the origin." );

   CLEARV ( errv );
   errv[2] = 1;

   CLEARV ( errd );
   errd[2] = -1.e0;

   CLEARV ( errn );
   errn[2] = 1.e0;

   errc    = 1.e308;

   nvc2pl_c ( errn, errc, &plane );

   inrypl_c ( errv, errd, &plane, &nxpts, xpt );
   chckxc_c ( SPICETRUE, "SPICE(VECTORTOOBIG)", ok );

 


   
   /*
   Retrieve the current test status.
   */ 
   t_success_c ( ok ); 
   
   
} /* End f_inry_c */

