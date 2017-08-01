/*

-Procedure f_pln_c ( Test wrappers for plane routines )

 
-Abstract
 
   Perform tests on all CSPICE wrappers plane-related functions. 
 
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
   

   void f_pln_c ( SpiceBoolean * ok )

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
 
   This routine tests the wrappers for the plane routines. 
   The current set is:
      
      nvc2pl_c
      nvp2pl_c
      psv2pl_c
      pl2nvc_c
      pl2nvp_c
      pl2psv_c
        
-Examples
 
   None.
    
-Restrictions
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
 
-Literature_References
 
   None. 
 
-Version
 
   -tspice_c Version 1.0.0 12-SEP-1999 (NJB)  

-&
*/

{ /* Begin f_pln_c */

 

   /*
   Local constants
   */
   
   #define  NUMCAS         10
   #define  LIMIT          1.e-12
     
                     
   /*
   Static variables
   */
   
   static SpiceDouble      normal   [ NUMCAS ][3] =
   
                           {  {  1.0e0,       0.e0,       0.e0   },
                              {   0.e0,       1.e0,       0.e0   },
                              {   0.e0,       0.e0,       1.e0   },
                              {   1.e20,      2.e20,      3.e20  },
                              {  -1.e20,      1.e10,      1.e5   },
                              {  -1.e5,      -1.e10,      1.e20  },
                              {  -1.e10,     -1.e5,      -1.e20  },
                              {  -1.e-20,     1.e-10,    -1.e-5  },
                              {   1.e-5,     -1.e-20,    -1.e-10 },
                              {   1.e8,       1.e-8,     -1.e-8  }  };  


   static SpiceDouble      constant [ NUMCAS ] = 
   
                           { -1.e35,
                              4.e-35,
                              2.e0,
                              1.e20,
                              0.e0,
                             -1.e0,
                              1.e0,
                              1.e-10,
                              1.e-20,
                             -1.e0       };

   static SpiceDouble      zerovec [ 3 ] = { 0.,  0.,  0. };
   
   
   /*
   Local variables 
   */

   SpiceDouble             con;
   SpiceDouble             dist;
   SpiceDouble             nhat     [3];
   SpiceDouble             nmag;
   SpiceDouble             norm     [3];
   SpiceDouble             point    [3];
   SpiceDouble             sclcon;
   SpiceDouble             sep;
   SpiceDouble             v1       [3];
   SpiceDouble             v2       [3];
   
   SpiceInt                caseno;
   
   SpicePlane              plane;
   


   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_pln_c" );
   

   
   
   /*
   Cases 1--NUMCAS:
   */



   for ( caseno = 0;  caseno < NUMCAS;  caseno++ )
   {
   
   
      tcase_c ( "Pass a plane around and see if it comes back "
                "unchanged."                                    );
                 
 
 
      nvc2pl_c ( normal[caseno], constant[caseno], &plane );
      chckxc_c ( SPICEFALSE, " ", ok );

      /*
      The stored constant must be non-negative.
      */
      pl2nvc_c ( &plane, norm, &con );
      chckxc_c ( SPICEFALSE, " ", ok );

      chcksd_c ( "nvc2pl_c plane constant",  
                 con,  ">=",   0.0,  0.,  ok );


      pl2psv_c ( &plane, point, v1, v2 );
      chckxc_c ( SPICEFALSE, " ", ok );

      /*
      The returned point should be the closest one to the origin.
      Check against sclcon below.
      */
      dist = vnorm_c (point);
         

      /*
      While we've got the plane in this form, let's perturb point.
      The perturbation shouldn't be too huge compared to point, or
      we'll blow away the accuracy of point.
      */
      unorm_c ( normal[caseno], nhat, &nmag );
      
      sclcon =  constant[caseno] / nmag;

      vlcom3_c ( 1.e3 * sclcon,  v1,
                 1.e3 * sclcon,  v2,
                 1.0,            point,     point  );
                 
     
      /*
      Test dist while we're at it.
      */
      if ( dist != 0. ) 
      {

         chcksd_c ( "pl2psv_c: point distance from origin",  
                    fabs(dist),  
                    "~/",  
                    fabs(sclcon), 
                    LIMIT,  
                    ok                                    );
      }                 
 
      /*
      Ok, keep going. 
      */     
      
      psv2pl_c ( point, v1, v2, &plane );
      chckxc_c ( SPICEFALSE, " ", ok );


      /*
      The stored constant must be non-negative.
      */
      pl2nvc_c ( &plane, norm, &con );
      chckxc_c ( SPICEFALSE, " ", ok );
         

      chcksd_c ( "psv2pl_c: plane constant",  
                 con,  
                 ">=",  
                 0.0, 
                 0.0,  
                 ok                          );


      pl2nvp_c ( &plane, norm, point );
      chckxc_c ( SPICEFALSE, " ", ok );



      /*
      The returned point should be the closest one to the origin.
      Check against sclcon below.
      */
      
      dist = vnorm_c (point);
         
      if ( dist != 0. ) 
      {
         chcksd_c ( "pl2nvp_c: point distance from origin",  
                    fabs(dist),  
                    "~/",  
                    fabs(sclcon), 
                    LIMIT,  
                    ok                                    );
      }                 

      
      nvp2pl_c ( norm,   point, &plane );
      chckxc_c ( SPICEFALSE, " ", ok );

      pl2nvc_c ( &plane, norm,  &con   );
      chckxc_c ( SPICEFALSE, " ", ok );


      /*
      con must be non-negative.
      */
      chcksd_c ( "pl2nvc_c: plane constant",  
                 con,  
                 ">=",  
                 0.0, 
                 0.0,  
                 ok                          );

 
      /*
      The unit normal must be pretty close in length to 1.
      */
      chcksd_c ( "pl2nvc_c: length of normal",  
                 vnorm_c(norm),  
                 "~/",  
                 1.0,
                 LIMIT,  
                 ok                                    );
         

      /*
      Check out the relative error in the plane constant and the
      angular separation of the original and final normal vectors.
      */   
      chcksd_c ( "Final plane constant magnitude",  
                 fabs(con),  
                 "~/",  
                 fabs(sclcon),
                 LIMIT,  
                 ok                                             );
           
         

      /*
      Check the angular separation of the original and final normal
      vectors.
      */
      
      sep = vsep_c ( norm, nhat );
      
      
      if ( sep < halfpi_c() )
      {
         chcksd_c ( "Angular separation of the original and final "
                    "normal vectors",  
                    sep,  
                    "<",  
                    LIMIT, 
                    0.0,  
                    ok                          );
      }
      else
      {
         chcksd_c ( "Angular separation of the original and final "
                    "normal vectors",  
                    sep-pi_c(),  
                    "<",  
                    LIMIT, 
                    0.0,  
                    ok                          );
      }
      
   }   
   /*
   End of the first set of test cases.
   */

   
   /*
   Now for some error cases.
   */
   
   tcase_c ( "nvc2pl_c error case:  norm is the zero vector." );
   
   nvc2pl_c ( zerovec, 0., &plane );
   
   chckxc_c ( SPICETRUE, "SPICE(ZEROVECTOR)", ok );
   
   
   
   tcase_c ( "nvp2pl_c error case:  norm is the zero vector." );
   
   nvp2pl_c ( zerovec, point, &plane );
   
   chckxc_c ( SPICETRUE, "SPICE(ZEROVECTOR)", ok );
   
   
   tcase_c ( "psv2pl_c error case:  dependent spanning vectors." );

   psv2pl_c ( point, v1, v1, &plane );

   chckxc_c ( SPICETRUE, "SPICE(DEGENERATECASE)", ok );

   
   /*
   Retrieve the current test status.
   */ 
   t_success_c ( ok ); 
   
   
} /* End f_pln_c */

