/*

-Procedure f_ell_c ( Test wrappers for ellipse/ellsipsoid routines )

 
-Abstract
 
   Perform tests on CSPICE wrappers for the ellipse and ellipsoid 
   functions. 
 
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
   

   void f_ell_c ( SpiceBoolean * ok )

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
 
   This routine tests the ellipse and ellipsoid routines.  The
   covered set of routines is:
   
      cgv2el_c
      diags2_c
      edlimb_c
      el2cvg_c
      inedpl_c
      inelpl_c
      nearpt_c
      npedln_c
      npelpt_c
      pjelpl_c
      rquad_c
      saelgv_c
      srfint_c
      surfpt_c

                   
-Examples
 
   None.
    
-Restrictions
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
 
-Literature_References
 
   None. 
 
-Version
 
   -tspice_c Version 2.0.0 18-AUG-2000 (NJB)

       Added test cases for inelpl_c.
  
   -tspice_c Version 1.0.0 02-SEP-1999 (NJB)  

-&
*/

{ /* Begin f_ell_c */

 
   /*
   Constants
   */
   #define TIGHT_RE        1.e-14
      

   /*
   Static variables
   */
   static SpiceDouble      symmat1    [2][2] = { { 1.0,    4.0 },
                                                 { 4.0,   -5.0 } };

   static SpiceDouble      symmat2    [2][2] = { { 27.0,   5.0 },
                                                 {  5.0,   3.0 } };
  
   static SpiceDouble      symmat3    [2][2] = { { -2.0,   0.0 },
                                                 {  0.0,   4.0 } };
  
   static SpiceDouble      expDiag1   [2][2] = { {  3.0,   0.0 },
                                                 {  0.0,  -7.0 } };

   static SpiceDouble      expDiag2   [2][2] = { { 28.0,   0.0 },
                                                 {  0.0,   2.0 } };

   static SpiceDouble      expDiag3   [2][2] = { { -2.0,   0.0 },
                                                 {  0.0,   4.0 } };

   static SpiceDouble      expRotate2 [2][2] = { { 0.980580675690920,
                                                  -0.196116135138184 },
                                                 { 0.196116135138184,
                                                   0.980580675690920 } 
                                               };
                                               
   static SpiceDouble      expRotate3 [2][2] = {  { 1., 0. },
                                                  { 0., 1. }  };


   /*
   Local variables
   */
   SpiceBoolean            found;

   SpiceDouble             center     [3]; 
   SpiceDouble             diag       [2][2]; 
   SpiceDouble             dist;
   SpiceDouble             expCenter  [3]; 
   SpiceDouble             expdist;
   SpiceDouble             exppt      [3];
   SpiceDouble             exppt1     [3];
   SpiceDouble             exppt2     [3];
   SpiceDouble             expRoot1   [2]; 
   SpiceDouble             expRoot2   [2];
   SpiceDouble             expRotate1 [2][2];
   SpiceDouble             expSmajor  [3];
   SpiceDouble             expSminor  [3];
   SpiceDouble             normal     [3];
   SpiceDouble             pnear      [3];
   SpiceDouble             point      [3];
   SpiceDouble             root1      [2];
   SpiceDouble             root2      [2];
   SpiceDouble             rotate     [2][2];
   SpiceDouble             smajor     [3];
   SpiceDouble             sminor     [3];
   SpiceDouble             vec1       [3];
   SpiceDouble             vec2       [3];
   SpiceDouble             viewpt     [3];
   SpiceDouble             xpt1       [3];
   SpiceDouble             xpt2       [3];

   SpiceEllipse            ellipse;
   SpiceEllipse            ellout;
   SpiceEllipse            limb;

   SpiceInt                nxpts;

   SpicePlane              plane;



   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_ell_c" );
   

   
   
   /*
   Case 1:
   */
   tcase_c ( "Test rquad" );


   /*
                  2
   Find roots of x  + x - 1 = 0
   */
   
   rquad_c ( 1., 1., -1., root1, root2 );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   expRoot1[0] = 0.5 * (  sqrt(5.) - 1. );
   expRoot1[1] = 0.0;

   expRoot2[0] = 0.5 * ( -sqrt(5.) - 1. );
   expRoot2[1] = 0.0;

   chckad_c ( "x**2 + x - 1, root1", 
               root1,  
               "~/",  
               expRoot1,
               2,
               TIGHT_RE,
               ok               );
               
   chckad_c ( "x**2 + x - 1, root2", 
               root2,  
               "~/",  
               expRoot2,
               2,
               TIGHT_RE,
               ok               );
               

   /*
                  2
   Find roots of x  + 1 = 0
   */
      
   rquad_c ( 1., 0., 1., root1, root2 );
   chckxc_c ( SPICEFALSE, " ", ok );

   expRoot1[0] =  0.0;
   expRoot1[1] =  1.0;

   expRoot2[0] =  0.0;
   expRoot2[1] = -1.0;

   chckad_c ( "x**2 + 1, root1", 
               root1,  
               "~/",  
               expRoot1,
               2,
               TIGHT_RE,
               ok               );
               
   chckad_c ( "x**2 + 1, root2", 
               root2,  
               "~/",  
               expRoot2,
               2,
               TIGHT_RE,
               ok               );
               

   
      
   /*
                  2
   Find roots of x  + 1 = 0
   */
      
   rquad_c ( 1., 0., 1., root1, root2 );
   chckxc_c ( SPICEFALSE, " ", ok );

   expRoot1[0] =  0.0;
   expRoot1[1] =  1.0;

   expRoot2[0] =  0.0;
   expRoot2[1] = -1.0;

   chckad_c ( "x**2 + 1, root1", 
               root1,  
               "~/",  
               expRoot1,
               2,
               TIGHT_RE,
               ok               );
               
   chckad_c ( "x**2 + 1, root2", 
               root2,  
               "~/",  
               expRoot2,
               2,
               TIGHT_RE,
               ok               );
               

   /*
                   
   Find roots of x + 2 = 0
   */
      
   rquad_c ( 0., 1., 2., root1, root2 );
   chckxc_c ( SPICEFALSE, " ", ok );

   expRoot1[0] =  -2.0;
   expRoot1[1] =   0.0;

   expRoot2[0] =  -2.0;
   expRoot2[1] =   0.0;

   chckad_c ( "x + 2, root1", 
               root1,  
               "~/",  
               expRoot1,
               2,
               TIGHT_RE,
               ok               );
               
   chckad_c ( "x + 2, root2", 
               root2,  
               "~/",  
               expRoot2,
               2,
               TIGHT_RE,
               ok               );
               

   /*
   Find roots of "5 = 0"
   */
   
   rquad_c ( 0., 0., 5., root1, root2 );
   chckxc_c ( SPICETRUE, "SPICE(DEGENERATECASE)", ok );
      
   
   
   /*
   Case 2:
   */
   tcase_c ( "Test diags2_c" );
   
   /*
   Test with the first symmetric matrix.
   */
   diags2_c ( symmat1, diag, rotate );
             
   chckad_c ( "diag", 
               (SpiceDouble *)diag,  
               "~~/",  
               (SpiceDouble *)expDiag1,
               4,
               TIGHT_RE,
               ok               );
   
   
   expRotate1[0][0] =  0.4 * sqrt(5.);
   expRotate1[1][0] =  0.2 * sqrt(5.);
   expRotate1[0][1] = -0.2 * sqrt(5.);
   expRotate1[1][1] =  0.4 * sqrt(5.);
   
   chckad_c ( "rotate", 
               (SpiceDouble *)rotate,  
               "~~/",  
               (SpiceDouble *)expRotate1,
               4,
               TIGHT_RE,
               ok               );
   
   
   /*
   Test with the second symmetric matrix.
   */
   diags2_c ( symmat2, diag, rotate );
             
   chckad_c ( "diag", 
               (SpiceDouble *)diag,  
               "~~/",  
               (SpiceDouble *)expDiag2,
               4,
               TIGHT_RE,
               ok               );
   
   
   chckad_c ( "rotate", 
               (SpiceDouble *)rotate,  
               "~~/",  
               (SpiceDouble *)expRotate2,
               4,
               TIGHT_RE,
               ok               );
   

   /*
   Test with the third symmetric matrix.  This case exercises the logic
   that handles the special case of a diagonal input symmetric matrix.
   */
   diags2_c ( symmat3, diag, rotate );
             
   chckad_c ( "diag", 
               (SpiceDouble *)diag,  
               "~~/",  
               (SpiceDouble *)expDiag3,
               4,
               TIGHT_RE,
               ok               );
   
   
   chckad_c ( "rotate", 
               (SpiceDouble *)rotate,  
               "~~/",  
               (SpiceDouble *)expRotate3,
               4,
               TIGHT_RE,
               ok               );
   

   /*
   Case 3:
   */
   tcase_c ( "Test saelgv_c" );
   
   /*
   A simple case, verifiable by inspection.
   */
   
   vpack_c  ( 1.0,  1.0, 1.0, vec1 );
   vpack_c  ( 1.0, -1.0, 1.0, vec2 );
   
   vpack_c   (  sqrt(2),        0,  sqrt(2), expSmajor );
   vpack_c   (        0,  sqrt(2),        0, expSminor );
   
   saelgv_c ( vec1, vec2, smajor, sminor );
                
   chckad_c ( "smajor", 
               (SpiceDouble *)smajor,  
               "~",  
               (SpiceDouble *)expSmajor,
               3,
               TIGHT_RE,
               ok               );
                   
   chckad_c ( "sminor", 
               (SpiceDouble *)sminor,  
               "~",  
               (SpiceDouble *)expSminor,
               3,
               TIGHT_RE,
               ok               );
   
   
   /*
   Case 4:
   */
   tcase_c  ( "Test cgv2el_c and el2cgv." );
   
   /*
   Create a SpiceEllipse using the vectors from the previous
   example.
   */
   
   vpack_c ( 1, 1, 1, center );
   
   cgv2el_c ( center, smajor, sminor, &ellipse );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   chckad_c ( "center", 
               (SpiceDouble *)ellipse.center,  
               "~",  
               (SpiceDouble *)center,
               3,
               TIGHT_RE,
               ok               );
   
   chckad_c ( "smajor", 
               (SpiceDouble *)ellipse.semiMajor,  
               "~",  
               (SpiceDouble *)smajor,
               3,
               TIGHT_RE,
               ok               );  
   chckad_c ( "sminor", 
               (SpiceDouble *)ellipse.semiMinor,  
               "~",  
               (SpiceDouble *)sminor,
               3,
               TIGHT_RE,
               ok               );
   
   /*
   Case 5:
   */
   tcase_c ( "Test inedpl_c:  slice the unit sphere with the plane "
             "{z = 0}"                                              );
             
   vpack_c  ( 0.0,    0.0,  1.0,   normal );
   nvc2pl_c ( normal, 0.0,  &plane        );
   
   inedpl_c ( 1.0, 1.0, 1.0, &plane, &limb, &found );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   chcksl_c ( "inedpl found flag", found, SPICETRUE, ok );
   
   vpack_c ( 1.0,  0.0, 0.0, expSminor ); 
   vpack_c ( 0.0, -1.0, 0.0, expSmajor ); 
   vpack_c ( 0.0,  0.0, 0.0, expCenter ); 
   
      
   chckad_c ( "limb sminor", 
               (SpiceDouble *)limb.semiMinor,  
               "~",  
               (SpiceDouble *)expSminor,
               3,
               TIGHT_RE,
               ok               );

      
   chckad_c ( "limb smajor", 
               (SpiceDouble *)limb.semiMajor,  
               "~",  
               (SpiceDouble *)expSmajor,
               3,
               TIGHT_RE,
               ok               );

      
   chckad_c ( "limb center", 
               (SpiceDouble *)limb.center,  
               "~",  
               (SpiceDouble *)expCenter,
               3,
               TIGHT_RE,
               ok               );
   
   
   
   /*
   Case 6:
   */
   tcase_c ( "Test edlimb_c using a simple ellipsoid." );
   
   vpack_c ( 2.0, 0.0, 0.0, viewpt );
   
   vpack_c ( 0.0, 0.0, -1.0, expSminor ); 
   vpack_c ( 0.0, 2.0,  0.0, expSmajor ); 
   vpack_c ( 1.0, 0.0,  0.0, expCenter ); 
   
   edlimb_c ( sqrt(2.0), 2.0*sqrt(2.0), sqrt(2.0), viewpt, &limb );
   
      
   chckad_c ( "limb sminor", 
               (SpiceDouble *)limb.semiMinor,  
               "~",  
               (SpiceDouble *)expSminor,
               3,
               TIGHT_RE,
               ok               );

      
   chckad_c ( "limb smajor", 
               (SpiceDouble *)limb.semiMajor,  
               "~",  
               (SpiceDouble *)expSmajor,
               3,
               TIGHT_RE,
               ok               );

      
   chckad_c ( "limb center", 
               (SpiceDouble *)limb.center,  
               "~",  
               (SpiceDouble *)expCenter,
               3,
               TIGHT_RE,
               ok               );

      
   /*
   Case 7:
   */
   
   tcase_c ( "And now a simple test case for npelpt_c." );
   
   
   vpack_c (  1.,   2.,   3., center );
   vpack_c (  3.,   0.,   0., smajor );
   vpack_c (  0.,   2.,   0., sminor );
   vpack_c ( -4.,   2.,   1., point  );
   
   cgv2el_c ( center, smajor, sminor, &ellipse );
   
   npelpt_c ( point, &ellipse, pnear, &dist );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   vpack_c ( -2., 2., 3., exppt  );

   expdist = 2.0 * sqrt( 2.0 );
   
   chckad_c ( "near point", pnear, "~", exppt,   3, TIGHT_RE, ok );
   chcksd_c ( "dist",       dist,  "~", expdist,    TIGHT_RE, ok );



   /*
   Case 8:
   */
   
   tcase_c ( "And now a simple test case for pjelpl_c." );
   
   
   vpack_c (  0.,   0.,   3., center );
   vpack_c (  3.,   0.,   4., smajor );
   vpack_c (  0.,   2.,   4., sminor );
   
   cgv2el_c ( center, smajor, sminor, &ellipse );

   vpack_c (  0.,   0.,   1., normal );

   nvc2pl_c ( normal, 1., &plane );
   
   pjelpl_c ( &ellipse, &plane, &ellout );
   chckxc_c ( SPICEFALSE, " ", ok );

   vpack_c (  0.,   0.,   1., expCenter );
   vpack_c (  3.,   0.,   0., expSmajor );
   vpack_c (  0.,   2.,   0., expSminor );

   chckad_c ( "limb sminor", 
               (SpiceDouble *)ellout.semiMinor,  
               "~",  
               (SpiceDouble *)expSminor,
               3,
               TIGHT_RE,
               ok               );

      
   chckad_c ( "limb smajor", 
               (SpiceDouble *)ellout.semiMajor,  
               "~",  
               (SpiceDouble *)expSmajor,
               3,
               TIGHT_RE,
               ok               );

      
   chckad_c ( "limb center", 
               (SpiceDouble *)ellout.center,  
               "~",  
               (SpiceDouble *)expCenter,
               3,
               TIGHT_RE,
               ok               );

      

   /*
   Case 9:
   */
   
   tcase_c ( "Test inelpl_c, two-point intersection case." );
   
   
   vpack_c (  0.,   0.,   3., center );
   vpack_c (  4.,   0.,   0., smajor );
   vpack_c (  0.,   2.,   0., sminor );
   
   cgv2el_c ( center, smajor, sminor, &ellipse );

   vpack_c (  1.,   0.,   0., normal );

   nvc2pl_c ( normal, 2., &plane );
   
   inelpl_c ( &ellipse, &plane, &nxpts, xpt1, xpt2 );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "nxpts", nxpts, "=", 2, 0, ok );

   if ( *ok )
   {
      /*
      Construct the expected intersection points. 
      */
      vpack_c ( 2.0, -sqrt(3), 3., exppt1 );
      vpack_c ( 2.0,  sqrt(3), 3., exppt2 );

      /*
      We don't know which output intersection point is which,
      so match them up using the distances of xpt1 from either
      intersection point as a guide. 
      */
      if ( vdist_c(exppt1,xpt1) > vdist_c(exppt1,xpt2) )
      {
    /*
    We guessed wrong.  Swap the expected points. 
    */
    MOVED( exppt2, 3,  exppt  );
    MOVED( exppt1, 3,  exppt2 );
    MOVED( exppt,  3,  exppt1 );
      } 

      
      chckad_c ( "xpt1", 
       (SpiceDouble *)xpt1,  
        "~~/",  
       (SpiceDouble *)exppt1,  
       3,
       TIGHT_RE,
       ok                    );
      
      chckad_c ( "xpt2", 
       (SpiceDouble *)xpt2,  
        "~~/",  
       (SpiceDouble *)exppt2,  
       3,
       TIGHT_RE,
       ok                    );
   }       
      
   /*
   Case 10
   */
   tcase_c ( "Test inelpl_c, one-point intersection case." );
   
   
   vpack_c (  0.,   0.,   0., center );
   vpack_c (  1.,   0.,   0., smajor );
   vpack_c (  0.,   1.,   0., sminor );
   
   cgv2el_c ( center, smajor, sminor, &ellipse );

   vpack_c (  1.,   0.,   0., normal );

   nvc2pl_c ( normal, 1., &plane );
   
   inelpl_c ( &ellipse, &plane, &nxpts, xpt1, xpt2 );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "nxpts", nxpts, "=", 1, 0, ok );

   if ( *ok )
   {
      /*
      Construct the expected intersection points. 
      */
      vpack_c ( 1.0, 0.0, 0.0, exppt1 );
      vpack_c ( 1.0, 0.0, 0.0, exppt2 );

      /*
      We don't know which output intersection point is which,
      so match them up using the distances of xpt1 from either
      intersection point as a guide. 
      */
      if ( vdist_c(exppt1,xpt1) > vdist_c(exppt1,xpt2) )
      {
    /*
    We guessed wrong.  Swap the expected points. 
    */
    MOVED( exppt2, 3,  exppt  );
    MOVED( exppt1, 3,  exppt2 );
    MOVED( exppt,  3,  exppt1 );
      } 

      
      chckad_c ( "xpt1", 
       (SpiceDouble *)xpt1,  
        "~~/",  
       (SpiceDouble *)exppt1,  
       3,
       TIGHT_RE,
       ok                    );
      
      chckad_c ( "xpt2", 
       (SpiceDouble *)xpt2,  
        "~~/",  
       (SpiceDouble *)exppt2,  
       3,
       TIGHT_RE,
       ok                    );
   } 



   /*
   Case 11
   */
   tcase_c ( "Test inelpl_c, empty intersection case." );
   
   
   vpack_c (  0.,   0.,   0., center );
   vpack_c (  1.,   0.,   0., smajor );
   vpack_c (  0.,   1.,   0., sminor );
   
   cgv2el_c ( center, smajor, sminor, &ellipse );

   vpack_c (  1.,   0.,   0., normal );

   nvc2pl_c ( normal, 2., &plane );
   
   inelpl_c ( &ellipse, &plane, &nxpts, xpt1, xpt2 );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "nxpts", nxpts, "=", 0, 0, ok );

      
   /*
   Retrieve the current test status.
   */ 
   t_success_c ( ok ); 
   
   
} /* End f_ell_c */

