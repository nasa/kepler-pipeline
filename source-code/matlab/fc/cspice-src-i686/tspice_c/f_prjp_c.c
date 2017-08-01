/*
 
-Procedure f_prjp_c ( Test wrappers for plane projection routines )
 
 
-Abstract
 
   Perform tests on CSPICE wrappers for plane projection functions.
 
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
 
 
   void f_prjp_c ( SpiceBoolean * ok )
 
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
 
   This routine tests the wrappers for the plane projection routines.
   The current set is:
 
      vprjp_c
      vprjpi_c
 
-Examples
 
   None.
 
-Restrictions
 
   None.
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
 
-Literature_References
 
   None.
 
-Version
 
   -tspice_c Version 1.0.0 25-JUN-1999 (NJB)
 
-&
*/
 
{ /* Begin f_prjp_c */
 
 
 
   /*
   Local constants
   */
 
   #define  NSIMPL       4
   #define  NUMCAS       200
   #define  NUMSCL       5
   #define  TOL          1.e-12
 
 
   /*
   Static variables
   */
 
 
 
   static SpiceDouble      c1     = 10.;
   static SpiceDouble      c2     = 20.;
   static SpiceDouble      c3     =  1.;
 
 
   static SpiceDouble      smpnm1 [ NSIMPL ][3] =
 
                           {  { 0.e0, 0.e0, 1.e0 },
                              { 0.e0, 0.e0, 1.e0 },
                              { 0.e0, 0.e0, 1.e0 },
                              { 0.e0, 0.e0, 1.e0 }  };
 
   static SpiceDouble      smpc1  [ NSIMPL ] =
 
                           { 0., 0., 0., 0. };
 
 
   static SpiceDouble      smpnm2 [ NSIMPL ][3] =
 
                           {  { 0.e0,  0.e0,  1.e0 },
                              { 0.e0, -1.e0,  1.e0 },
                              { 0.e0, -1.e0,  0.e0 },
                              { 0.e0, -1.e8,  1.e0 }  };
 
   static SpiceDouble      smpc2  [ NSIMPL ] =
 
                           { 1., 0., 0., 0. };
 
 
 
   static SpiceDouble      smpprj [ NSIMPL ][3] =
 
                           {  { 0.e0, 1.e0,   0.e0 },
                              { 0.e0, 1.e0,   0.e0 },
                              { 0.e0, 1.e0,   0.e0 },
                              { 0.e0, 1.e305, 0.e0 }  };
 
 
   static SpiceDouble      expinv [ NSIMPL ][3] =
 
                           {  {   0.e0,   1.e0,   1.e0 },
                              {   0.e0,   1.e0,   1.e0 },
                              {  -1.e0,  -2.e0,  -3.e0 },
                              {  -4.e0,  -5.e0,  -6.e0 }  };
 
   static SpiceBoolean     expfnd [ NSIMPL ] =
                           {
                              SPICETRUE,
                              SPICETRUE,
                              SPICEFALSE,
                              SPICEFALSE,
                           };
 
  
 
 
   /*
   Local variables
   */
 
   SpiceBoolean            found;
 
   SpiceDouble             crit;
   SpiceDouble             norm1  [ 3 ];
   SpiceDouble             const1;
   SpiceDouble             norm2  [ 3 ];
   SpiceDouble             const2;
   SpiceDouble             prj    [ 3 ];
   SpiceDouble             invprj [ 3 ];
   SpiceDouble             point  [ 3 ];
   SpiceDouble             scale;
   SpiceDouble             v1     [ 3 ];
   SpiceDouble             v2     [ 3 ];
   SpiceDouble             prj2   [ 3 ];
 
   SpiceInt                i;
   SpiceInt                j;
 
   SpicePlane              plane1;
   SpicePlane              plane2;
 
 
 
 
 
 
 
   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_prjp_c" );
 
 
   /*
   Cases 1--NSIMPL:
   */
 
   for ( i = 0;  i < NSIMPL;  i++ )
   {
      tcase_c ( "A simple case whose correct result can be determined "
                "by inspection."                                      );
 
      nvc2pl_c ( smpnm1[i], smpc1[i], &plane1 );
      nvc2pl_c ( smpnm2[i], smpc2[i], &plane2 );
 
      if ( !expfnd[i] )
      {
         /*
         This is a singular case.
 
         Set the output vector to something recognizable, so we can
         make sure it's unchanged when no inverse is found.
         */
 
         MOVED ( expinv[i], 3, invprj );
      }
 
      vprjpi_c ( smpprj[i], &plane1, &plane2, invprj, &found );
      chckxc_c ( SPICEFALSE, " ", ok );
 
      chcksl_c ( "found", found, expfnd[i], ok );
 
      chckad_c ( "invprj", invprj, "~/", expinv[i], 3, 1.e-14, ok );
   }
 
 
   /*
   Cases 1--NUMCAS:
   */
 
 
 
   /*
   A series of random cases.
   */
 
   for ( i = 0;  i < NUMCAS;  i++ )
   {
      tcase_c ( "Test vprjp_c and vprjpi_c using random planes." );
 
      /*
      Random planes.
      */
 
      scale   =  pow (  10.0,  rand_c (  -30.0,  30.0 )  );
 
      const1  =  scale   *     rand_c ( -100.0, 100.0 );
      const2  =  scale   *     rand_c ( -100.0, 100.0 );
 
      for ( j = 0;  j < 3;  j++ )
      {
         norm1[j]  =  rand_c ( -100., 100. );
         norm2[j]  =  rand_c ( -100., 100. );
      }
 
      vhat_c ( norm1, norm1 );
      vhat_c ( norm2, norm2 );
 
      nvc2pl_c ( norm1, const1, &plane1 );
      nvc2pl_c ( norm1, const2, &plane2 );
 
      /*
      Find a point in the projection plane.    Make up a new
      point; this one will be the projection point.
      */
 
      pl2psv_c ( &plane1, point, v1, v2 );
 
      vlcom3_c ( c1*scale, v1, c2*scale, v2, c3, point, prj );
 
      pl2psv_c ( &plane1, point, v1, v2 );
 
 
      /*
      Find the inverse projection of prj.  If it is found,
      project it back to plane1 and see how close to the original
      point we get.
      */
 
      vprjpi_c ( prj, &plane1, &plane2, invprj, &found );
      chckxc_c ( SPICEFALSE, " ", ok );
 
 
      if ( !found )
      {
 
         tstmsg_c ( "#",
                    "Inverse projection not found. "
                    "Normal of first plane is (#, #, #). "
                    "Constant of first plane is # "
                    "Normal of second plane is (#, #, #). "
                    "Constant of second plane is # "
                    "Inner product of the normal vectors is #" );
 
         tstmsd_c ( norm1[0] );
         tstmsd_c ( norm1[1] );
         tstmsd_c ( norm1[2] );
         tstmsd_c ( const1   );
         tstmsd_c ( norm2[0] );
         tstmsd_c ( norm2[1] );
         tstmsd_c ( norm2[2] );
         tstmsd_c ( const2   );
         tstmsd_c (  vdot_c(norm1, norm2)   );
 
         chcksl_c ( "found", found, SPICETRUE, ok );
 
      }
 
      else
      {
 
         vprjp_c ( invprj, &plane1, prj2 );
         chckxc_c ( SPICEFALSE, " ", ok );
 
         crit = vdist_c ( prj2, prj ) / scale;
 
         if ( fabs(crit) > TOL )
         {
            tstmsg_c ( "#",
                       "Projection comparison failed. "
                       "Normal of first plane is (#, #, #). "
                       "Constant of first plane is # "
                       "Normal of second plane is (#, #, #). "
                       "Constant of second plane is # "
                       "Inner product of the normal vectors is # "
                       "Scaled distance between original point "
                       "and final point is #."                   );
 
            tstmsd_c ( norm1[0] );
            tstmsd_c ( norm1[1] );
            tstmsd_c ( norm1[2] );
            tstmsd_c ( const1   );
            tstmsd_c ( norm2[0] );
            tstmsd_c ( norm2[1] );
            tstmsd_c ( norm2[2] );
            tstmsd_c ( const2   );
            tstmsd_c (  vdot_c(norm1, norm2)   );
            tstmsd_c (  crit    );
 
            chcksd_c ( "scaled distance between prj and prj2",
                       fabs(crit),
                       "<=",
                       TOL,
                       0.0,
                       ok                                    );
         }
      }
   }
 
 
 
 
   /*
   Retrieve the current test status.
   */
   t_success_c ( ok );
 
 
} /* End f_prjp_c */
 
