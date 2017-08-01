/*

-Procedure f_wind_c ( Test wrappers for window routines )

 
-Abstract
 
   Perform tests on CSPICE window wrappers.
    
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
   #include <assert.h>
   #include "SpiceUsr.h"
   #include "SpiceZfc.h"
   #include "SpiceZmc.h"
   #include "SpiceZst.h"
   #include "tutils_c.h"
   

   void f_wind_c ( SpiceBoolean * ok )

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
 
   This routine tests the wrappers for
      
      wncomd_c
      wncond_c
      wndifd_c
      wnelmd_c
      wnexpd_c
      wnextd_c
      wnfetd_c
      wnfild_c
      wnfltd_c
      wnincd_c
      wninsd_c
      wnintd_c
      wnreld_c
      wnsumd_c
      wnunid_c
      wnvald_c
   
-Examples
 
   None.
    
-Restrictions
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
 
-Literature_References
 
   None. 
 
-Version
 
   -tspice_c Version 1.0.0 27-AUG-2002 (NJB)


-&
*/

{ /* Begin f_wind_c */

   
   /*
   Constants
   */
   
   #define LNSIZE          81
   #define SHORT           5
   #define T               SPICETRUE
   #define F               SPICEFALSE
   #define NMAX            5
   

   #define DSIZE1          10
   #define DSIZE2          30
   #define DSIZE3          2

   #define SMALLTOL      ( 1.e-12 )

   /*
   Local variables
   */

   SPICEDOUBLE_CELL ( win1,   DSIZE1 );
   SPICEDOUBLE_CELL ( win2,   DSIZE1 );
   SPICEDOUBLE_CELL ( win3,   DSIZE2 );
   SPICEDOUBLE_CELL ( win4,   DSIZE3 );
   SPICEDOUBLE_CELL ( win5,   DSIZE1 );
   SPICEDOUBLE_CELL ( win6,   DSIZE1 );

   SPICEINT_CELL    ( icell1, DSIZE1 );

   SpiceBoolean            bresult;


   SpiceDouble             avg;
   SpiceDouble             darray     [ DSIZE2 ][2];
   SpiceDouble             darray2    [ DSIZE2 ][2];
   SpiceDouble             darrayexp  [ DSIZE2 ][2];
   SpiceDouble             darrayexp2 [ DSIZE2 ][2];
   SpiceDouble             dval;
   SpiceDouble             meas;
   SpiceDouble             stddev;

   SpiceInt                i;
   SpiceInt                longest;
   SpiceInt                shortest;


   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_wind_c" );
   

   /*
   Test wninsd_c, wnfetd_c first, as these will be used to 
   build and examine windows in the subsequent tests.
   */
   
   /*
   wninsd_c, wnfetd_c tests:
   */
   tcase_c ( "Test wninsd_c:  build the window [ 1, 3 ] "
             " [ 7, 11 ]  [ 23, 27 ]"                       );
 
   darrayexp[0][0] =  1.0;
   darrayexp[0][1] =  3.0;

   darrayexp[1][0] =  7.0;
   darrayexp[1][1] = 11.0;

   darrayexp[2][0] = 23.0;
   darrayexp[2][1] = 27.0;

   for ( i = 0;  i < 3;  i++ )
   {
      wninsd_c ( darrayexp[i][0], darrayexp[i][1], &win1 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   /*
   Check the window's cardinality. 
   */
   chcksi_c ( "card_c(&win1)", card_c(&win1), "=", 6, 0, ok );

   /*
   Check the window's contents directly. 
   */
   for ( i = 0;  i < 6;  i++ )
   {
      SPICE_CELL_GET_D ( &win1, i, &dval );

      chcksd_c ( "win1", dval, "=", ((SpiceDouble *)darrayexp)[i], 0.0, ok );
   }

  
   tcase_c ( "Check the window's contents using wnfetd." );    
  

   for ( i = 0;  i < 3;  i++ )
   {
      wnfetd_c ( &win1, i, darray[i], (darray[i])+1 );
      chckxc_c ( SPICEFALSE, " ", ok );

      chckad_c ( "win1", darray[i], "=", darrayexp[i], 2, 0.0, ok );
   }



   tcase_c ( "Add [ 5,  5 ] to the window." );    


   wninsd_c ( 5.0, 5.0,  &win1 );

   darrayexp[0][0] =  1.0;
   darrayexp[0][1] =  3.0;

   darrayexp[1][0] =  5.0;
   darrayexp[1][1] =  5.0;

   darrayexp[2][0] =  7.0;
   darrayexp[2][1] = 11.0;

   darrayexp[3][0] = 23.0;
   darrayexp[3][1] = 27.0;

   for ( i = 0;  i < 4;  i++ )
   {
      wnfetd_c ( &win1, i, darray[i], (darray[i])+1 );
      chckxc_c ( SPICEFALSE, " ", ok );

      chckad_c ( "win1", darray[i], "=", darrayexp[i], 2, 0.0, ok );
   }

   /*
   Check the window's cardinality. 
   */
   chcksi_c ( "card_c(&win1)", card_c(&win1), "=", 8, 0, ok );




   tcase_c ( "Add [ 4,  8 ] to the window." );    


   wninsd_c ( 4.0, 8.0,  &win1 );

   darrayexp[0][0] =  1.0;
   darrayexp[0][1] =  3.0;

   darrayexp[1][0] =  4.0;
   darrayexp[1][1] = 11.0;

   darrayexp[2][0] = 23.0;
   darrayexp[2][1] = 27.0;

   for ( i = 0;  i < 3;  i++ )
   {
      wnfetd_c ( &win1, i, darray[i], (darray[i])+1 );
      chckxc_c ( SPICEFALSE, " ", ok );

      chckad_c ( "win1", darray[i], "=", darrayexp[i], 2, 0.0, ok );
   }
  
   /*
   Check the window's cardinality. 
   */
   chcksi_c ( "card_c(&win1)", card_c(&win1), "=", 6, 0, ok );





   tcase_c ( "Add [ 0,  30 ] to the window." );    


   wninsd_c ( 0.0, 30.0,  &win1 );

   darrayexp[0][0] =  0.0;
   darrayexp[0][1] = 30.0;

   for ( i = 0;  i < 1;  i++ )
   {
      wnfetd_c ( &win1, i, darray[i], (darray[i])+1 );
      chckxc_c ( SPICEFALSE, " ", ok );

      chckad_c ( "win1", darray[i], "=", darrayexp[i], 2, 0.0, ok );
   }
  
   /*
   Check the window's cardinality. 
   */
   chcksi_c ( "card_c(&win1)", card_c(&win1), "=", 2, 0, ok );



   tcase_c ( "wninsd_c error case:  insert into integer cell." );    

   wninsd_c ( 0.0, 30.0,  &icell1 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );


   tcase_c ( "wninsd_c error case:  bad endpoints." );    

   wninsd_c ( 31.0, 30.0,  &win1 );
   chckxc_c ( SPICETRUE, "SPICE(BADENDPOINTS)", ok );



   tcase_c ( "wninsd_c error case:  too many  endpoints." );    

   for ( i = 0;  i < DSIZE1;  i+=2 )
   {
      wninsd_c ( (SpiceDouble)i, (SpiceDouble)(i+1), &win2 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   wninsd_c ( (SpiceDouble)i+2, (SpiceDouble)(i+3), &win2 );
   chckxc_c ( SPICETRUE, "SPICE(WINDOWEXCESS)", ok );




   tcase_c ( "wnfetd_c error case:  fetch from integer cell." );    

   wnfetd_c ( &icell1, 0, darray[0], (darray[0])+1 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );


   tcase_c ( "wnfetd_c error case:  invalid interval index" );    


   wnfetd_c ( &win1, -1, darray[0], (darray[0])+1 );
   chckxc_c ( SPICETRUE, "SPICE(NOINTERVAL)", ok );



   /*
   wncomd_c tests: 
   */
   tcase_c ( "wncomd_c normal case #1." );   


   /*
   Set up the window to be complemented. 
   */ 
   darrayexp[0][0] =  1.0;
   darrayexp[0][1] =  3.0;

   darrayexp[1][0] =  7.0;
   darrayexp[1][1] = 11.0;

   darrayexp[2][0] = 23.0;
   darrayexp[2][1] = 27.0;

   scard_c ( 0, &win1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < 3;  i++ )
   {
      wninsd_c ( darrayexp[i][0], darrayexp[i][1], &win1 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   /*
   Set up the expected result window. 
   */
   darrayexp2[0][0] =  3.0;
   darrayexp2[0][1] =  7.0;

   darrayexp2[1][0] = 11.0;
   darrayexp2[1][1] = 20.0;

   scard_c ( 0, &win2 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < 2;  i++ )
   {
      wninsd_c ( darrayexp2[i][0], darrayexp2[i][1], &win2 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   /*
   Do the complement. 
   */
   wncomd_c ( 2.0, 20.0, &win1, &win2 );
   chckxc_c ( SPICEFALSE, " ", ok );
            
   for ( i = 0;  i < 2;  i++ )
   {
      wnfetd_c ( &win2, i, darray[i], (darray[i])+1 );
      chckxc_c ( SPICEFALSE, " ", ok );

      chckad_c ( "win2", darray[i], "=", darrayexp2[i], 2, 0.0, ok );
   }
  
   /*
   Check the window's cardinality. 
   */
   chcksi_c ( "card_c(&win2)", card_c(&win2), "=", 4, 0, ok );


   tcase_c ( "wncomd_c normal case #2." );   

   /*
   Set up the expected result window. 
   */
   darrayexp2[0][0] =  0.0;
   darrayexp2[0][1] =  1.0;

   darrayexp2[1][0] =  3.0;
   darrayexp2[1][1] =  7.0;

   darrayexp2[2][0] = 11.0;
   darrayexp2[2][1] = 20.0;

   darrayexp2[3][0] = 27.0;
   darrayexp2[3][1] = 100.0;


   scard_c ( 0, &win2 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < 4;  i++ )
   {
      wninsd_c ( darrayexp2[i][0], darrayexp2[i][1], &win2 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   /*
   Do the complement. 
   */
   wncomd_c ( 0.0, 100.0, &win1, &win2 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < 2;  i++ )
   {
      wnfetd_c ( &win2, i, darray[i], (darray[i])+1 );
      chckxc_c ( SPICEFALSE, " ", ok );

      chckad_c ( "win2", darray[i], "=", darrayexp2[i], 2, 0.0, ok );
   }
  
   /*
   Check the window's cardinality. 
   */
   chcksi_c ( "card_c(&win2)", card_c(&win2), "=", 8, 0, ok );



   tcase_c ( "wncomd_c error case:  operate on integer cell." );    

   wncomd_c ( 0.0, 30.0,  &icell1, &win2 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );

   tcase_c ( "wncomd_c error case:  result is integer cell." );    

   wncomd_c ( 0.0, 30.0,  &win1, &icell1 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );

   tcase_c ( "wncomd_c error case:  bad endpoints." );    

   wncomd_c ( 31.0, 30.0,  &win1, &win2 );
   chckxc_c ( SPICETRUE, "SPICE(BADENDPOINTS)", ok );


   /*
   wncond_c tests: 
   */

   tcase_c ( "wncond_c normal test #1" );

   /*
   Set up the window to be contracted. 
   */ 
   darrayexp[0][0] =  1.0;
   darrayexp[0][1] =  3.0;

   darrayexp[1][0] =  7.0;
   darrayexp[1][1] = 11.0;

   darrayexp[2][0] = 23.0;
   darrayexp[2][1] = 27.0;

   darrayexp[3][0] = 29.0;
   darrayexp[3][1] = 29.0;

   scard_c ( 0, &win1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < 4;  i++ )
   {
      wninsd_c ( darrayexp[i][0], darrayexp[i][1], &win1 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   /*
   Set up the expected result array. 
   */
   darrayexp2[0][0] =  9.0;
   darrayexp2[0][1] = 10.0;

   darrayexp2[1][0] = 25.0;
   darrayexp2[1][1] = 26.0;


   /*
   Do the contraction. 
   */
   wncond_c ( 2.0, 1.0, &win1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < 2;  i++ )
   {
      wnfetd_c ( &win1, i, darray[i], (darray[i])+1 );
      chckxc_c ( SPICEFALSE, " ", ok );

      chckad_c ( "win1", darray[i], "=", darrayexp2[i], 2, 0.0, ok );
   }
  
   /*
   Check the window's cardinality. 
   */
   chcksi_c ( "card_c(&win1)", card_c(&win1), "=", 4, 0, ok );



   tcase_c ( "wncond_c normal test #2" );

   /*
   Set up the expected result array. 
   */
   darrayexp2[0][0] =  7.0;
   darrayexp2[0][1] =  8.0;

   darrayexp2[1][0] = 23.0;
   darrayexp2[1][1] = 24.0;

   /*
   Do the contraction. 
   */
   wncond_c ( -2.0, 2.0, &win1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < 2;  i++ )
   {
      wnfetd_c ( &win1, i, darray[i], (darray[i])+1 );
      chckxc_c ( SPICEFALSE, " ", ok );

      chckad_c ( "win1", darray[i], "=", darrayexp2[i], 2, 0.0, ok );
   }
  
   /*
   Check the window's cardinality. 
   */
   chcksi_c ( "card_c(&win1)", card_c(&win1), "=", 4, 0, ok );



   tcase_c ( "wncond_c normal test #3" );

   /*
   Set up the expected result array. 
   */
   darrayexp2[0][0] =  5.0;
   darrayexp2[0][1] =  9.0;

   darrayexp2[1][0] = 21.0;
   darrayexp2[1][1] = 25.0;

   /*
   Do the contraction. 
   */
   wncond_c ( -2.0, -1.0, &win1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < 2;  i++ )
   {
      wnfetd_c ( &win1, i, darray[i], (darray[i])+1 );
      chckxc_c ( SPICEFALSE, " ", ok );

      chckad_c ( "win1", darray[i], "=", darrayexp2[i], 2, 0.0, ok );
   }
  
   /*
   Check the window's cardinality. 
   */
   chcksi_c ( "card_c(&win1)", card_c(&win1), "=", 4, 0, ok );


   tcase_c ( "wncond_c error case:  operate on integer cell." );    

   wncond_c ( 0.0, 30.0,  &icell1 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );



   /*
   wnexpd_c tests: 
   */

   tcase_c ( "wnexpd_c normal test #1" );

   /*
   Set up the window to be expanded. 
   */ 
   darrayexp[0][0] =  1.0;
   darrayexp[0][1] =  3.0;

   darrayexp[1][0] =  7.0;
   darrayexp[1][1] = 11.0;

   darrayexp[2][0] = 23.0;
   darrayexp[2][1] = 27.0;

   darrayexp[3][0] = 29.0;
   darrayexp[3][1] = 29.0;

   scard_c ( 0, &win1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < 4;  i++ )
   {
      wninsd_c ( darrayexp[i][0], darrayexp[i][1], &win1 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   /*
   Set up the expected result array. 
   */
   darrayexp2[0][0] = -1.0;
   darrayexp2[0][1] =  4.0;

   darrayexp2[1][0] =  5.0;
   darrayexp2[1][1] = 12.0;

   darrayexp2[2][0] = 21.0;
   darrayexp2[2][1] = 30.0;


   /*
   Do the expansion. 
   */
   wnexpd_c ( 2.0, 1.0, &win1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < 3;  i++ )
   {
      wnfetd_c ( &win1, i, darray[i], (darray[i])+1 );
      chckxc_c ( SPICEFALSE, " ", ok );

      chckad_c ( "win1", darray[i], "=", darrayexp2[i], 2, 0.0, ok );
   }
  
   /*
   Check the window's cardinality. 
   */
   chcksi_c ( "card_c(&win1)", card_c(&win1), "=", 6, 0, ok );



   tcase_c ( "wnexpd_c normal test #2" );

   /*
   Set up the expected result array. 
   */
   darrayexp2[0][0] =  1.0;
   darrayexp2[0][1] =  6.0;

   darrayexp2[1][0] =  7.0;
   darrayexp2[1][1] = 14.0;

   darrayexp2[2][0] = 23.0;
   darrayexp2[2][1] = 32.0;

   /*
   Do the expansion. 
   */
   wnexpd_c ( -2.0, 2.0, &win1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < 3;  i++ )
   {
      wnfetd_c ( &win1, i, darray[i], (darray[i])+1 );
      chckxc_c ( SPICEFALSE, " ", ok );

      chckad_c ( "win1", darray[i], "=", darrayexp2[i], 2, 0.0, ok );
   }
  
   /*
   Check the window's cardinality. 
   */
   chcksi_c ( "card_c(&win1)", card_c(&win1), "=", 6, 0, ok );



   tcase_c ( "wnexpd_c normal test #3" );

   /*
   Set up the expected result array. 
   */
   darrayexp2[0][0] =  3.0;
   darrayexp2[0][1] =  5.0;

   darrayexp2[1][0] =  9.0;
   darrayexp2[1][1] = 13.0;

   darrayexp2[2][0] = 25.0;
   darrayexp2[2][1] = 31.0;

   /*
   Do the contraction. 
   */
   wnexpd_c ( -2.0, -1.0, &win1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < 3;  i++ )
   {
      wnfetd_c ( &win1, i, darray[i], (darray[i])+1 );
      chckxc_c ( SPICEFALSE, " ", ok );

      chckad_c ( "win1", darray[i], "=", darrayexp2[i], 2, 0.0, ok );
   }
  
   /*
   Check the window's cardinality. 
   */
   chcksi_c ( "card_c(&win1)", card_c(&win1), "=", 6, 0, ok );


   tcase_c ( "wnexpd_c error case:  operate on integer cell." );    

   wnexpd_c ( 0.0, 30.0,  &icell1 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );



   /*
   wnunid_c tests: 
   */

   tcase_c ( "wnunid_c normal test #1" );

   /*
   Set up the windows whose union is to be computed. 
   */ 
   darray[0][0] =  1.0;
   darray[0][1] =  3.0;

   darray[1][0] =  7.0;
   darray[1][1] = 11.0;

   darray[2][0] = 23.0;
   darray[2][1] = 27.0;

   scard_c ( 0, &win1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < 3;  i++ )
   {
      wninsd_c ( darray[i][0], darray[i][1], &win1 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }


   darray2[0][0] =  2.0;
   darray2[0][1] =  6.0;

   darray2[1][0] =  8.0;
   darray2[1][1] = 10.0;

   darray2[2][0] = 16.0;
   darray2[2][1] = 18.0;

   scard_c ( 0, &win2 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < 3;  i++ )
   {
      wninsd_c ( darray2[i][0], darray2[i][1], &win2 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   /*
   Set up the expected result array. 
   */
   darrayexp[0][0] =  1.0;
   darrayexp[0][1] =  6.0;

   darrayexp[1][0] =  7.0;
   darrayexp[1][1] = 11.0;

   darrayexp[2][0] = 16.0;
   darrayexp[2][1] = 18.0;

   darrayexp[3][0] = 23.0;
   darrayexp[3][1] = 27.0;

   /*
   Do the union. 
   */
   wnunid_c ( &win1, &win2, &win3 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < 4;  i++ )
   {
      wnfetd_c ( &win3, i, darray[i], (darray[i])+1 );
      chckxc_c ( SPICEFALSE, " ", ok );

      chckad_c ( "win3", darray[i], "=", darrayexp[i], 2, 0.0, ok );
   }
  
   /*
   Check the window's cardinality. 
   */
   chcksi_c ( "card_c(&win3)", card_c(&win3), "=", 8, 0, ok );


   /*
   wnunid_c error cases: 
   */

   tcase_c ( "wnunid_c error case:  first arg is integer cell." );    

   wnunid_c ( &icell1, &win1, &win3 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );


   tcase_c ( "wnunid_c error case:  second arg is integer cell." );    

   wnunid_c ( &win1, &icell1, &win3 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );


   tcase_c ( "wnunid_c error case:  third arg is integer cell." );    

   wnunid_c ( &win1, &win2, &icell1 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );


   tcase_c ( "wnunid_c error case:  result overflow." );    

   wnunid_c ( &win1, &win2, &win4 );
   chckxc_c ( SPICETRUE, "SPICE(WINDOWEXCESS)", ok );



   /*
   wnintd_c tests: 
   */

   tcase_c ( "wnintd_c normal test #1" );

   /*
   Set up the windows whose intersection is to be computed. 
   */ 
   darray[0][0] =  1.0;
   darray[0][1] =  3.0;

   darray[1][0] =  7.0;
   darray[1][1] = 11.0;

   darray[2][0] = 23.0;
   darray[2][1] = 27.0;

   scard_c ( 0, &win1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < 3;  i++ )
   {
      wninsd_c ( darray[i][0], darray[i][1], &win1 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }


   darray2[0][0] =  2.0;
   darray2[0][1] =  4.0;

   darray2[1][0] =  8.0;
   darray2[1][1] = 10.0;

   darray2[2][0] = 16.0;
   darray2[2][1] = 18.0;

   scard_c ( 0, &win2 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < 3;  i++ )
   {
      wninsd_c ( darray2[i][0], darray2[i][1], &win2 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   /*
   Set up the expected result array. 
   */
   darrayexp[0][0] =  2.0;
   darrayexp[0][1] =  3.0;

   darrayexp[1][0] =  8.0;
   darrayexp[1][1] = 10.0;

   /*
   Do the intersection. 
   */
   wnintd_c ( &win1, &win2, &win3 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < 2;  i++ )
   {
      wnfetd_c ( &win3, i, darray[i], (darray[i])+1 );
      chckxc_c ( SPICEFALSE, " ", ok );

      chckad_c ( "win3", darray[i], "=", darrayexp[i], 2, 0.0, ok );
   }
  
   /*
   Check the window's cardinality. 
   */
   chcksi_c ( "card_c(&win3)", card_c(&win3), "=", 4, 0, ok );


   /*
   wnintd_c error cases: 
   */

   tcase_c ( "wnintd_c error case:  first arg is integer cell." );    

   wnintd_c ( &icell1, &win1, &win3 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );


   tcase_c ( "wnintd_c error case:  second arg is integer cell." );    

   wnintd_c ( &win1, &icell1, &win3 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );


   tcase_c ( "wnintd_c error case:  third arg is integer cell." );    

   wnintd_c ( &win1, &win2, &icell1 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );


   tcase_c ( "wnintd_c error case:  result overflow." );    

   wnintd_c ( &win1, &win2, &win4 );
   chckxc_c ( SPICETRUE, "SPICE(WINDOWEXCESS)", ok );




   /*
   wndifd_c tests: 
   */

   tcase_c ( "wndifd_c normal test #1" );

   /*
   Set up the windows whose intersection is to be computed. 
   */ 
   darray[0][0] =  1.0;
   darray[0][1] =  3.0;

   darray[1][0] =  7.0;
   darray[1][1] = 11.0;

   darray[2][0] = 23.0;
   darray[2][1] = 27.0;

   scard_c ( 0, &win1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < 3;  i++ )
   {
      wninsd_c ( darray[i][0], darray[i][1], &win1 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }


   darray2[0][0] =  2.0;
   darray2[0][1] =  4.0;

   darray2[1][0] =  8.0;
   darray2[1][1] = 10.0;

   darray2[2][0] = 16.0;
   darray2[2][1] = 18.0;

   scard_c ( 0, &win2 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < 3;  i++ )
   {
      wninsd_c ( darray2[i][0], darray2[i][1], &win2 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   /*
   Set up the expected result array. 
   */
   darrayexp[0][0] =  1.0;
   darrayexp[0][1] =  2.0;

   darrayexp[1][0] =  7.0;
   darrayexp[1][1] =  8.0;

   darrayexp[2][0] = 10.0;
   darrayexp[2][1] = 11.0;

   darrayexp[3][0] = 23.0;
   darrayexp[3][1] = 27.0;

   /*
   Do the intersection. 
   */
   wndifd_c ( &win1, &win2, &win3 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < 4;  i++ )
   {
      wnfetd_c ( &win3, i, darray[i], (darray[i])+1 );
      chckxc_c ( SPICEFALSE, " ", ok );

      chckad_c ( "win3", darray[i], "=", darrayexp[i], 2, 0.0, ok );
   }
  
   /*
   Check the window's cardinality. 
   */
   chcksi_c ( "card_c(&win3)", card_c(&win3), "=", 8, 0, ok );


   /*
   wndifd_c error cases: 
   */

   tcase_c ( "wndifd_c error case:  first arg is integer cell." );    

   wndifd_c ( &icell1, &win1, &win3 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );


   tcase_c ( "wndifd_c error case:  second arg is integer cell." );    

   wndifd_c ( &win1, &icell1, &win3 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );


   tcase_c ( "wndifd_c error case:  third arg is integer cell." );    

   wndifd_c ( &win1, &win2, &icell1 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );


   tcase_c ( "wndifd_c error case:  result overflow." );    

   wndifd_c ( &win1, &win2, &win4 );
   chckxc_c ( SPICETRUE, "SPICE(WINDOWEXCESS)", ok );





   /*
   wnfild_c tests: 
   */

   tcase_c ( "wnfild_c normal test #1" );

   /*
   Set up the initial window and first expected result. 
   */ 
   darray[0][0] =  1.0;
   darray[0][1] =  3.0;

   darray[1][0] =  7.0;
   darray[1][1] = 11.0;

   darray[2][0] = 23.0;
   darray[2][1] = 27.0;

   darray[3][0] = 29.0;
   darray[3][1] = 29.0;


   scard_c ( 0, &win1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < 4;  i++ )
   {
      wninsd_c ( darray[i][0], darray[i][1], &win1 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   /*
   Set up the expected result array. 
   */
   darrayexp[0][0] =  1.0;
   darrayexp[0][1] =  3.0;

   darrayexp[1][0] =  7.0;
   darrayexp[1][1] = 11.0;

   darrayexp[2][0] = 23.0;
   darrayexp[2][1] = 27.0;

   darrayexp[3][0] = 29.0;
   darrayexp[3][1] = 29.0;
 

   /*
   Fill gaps (operation #1):
   */
   wnfild_c ( 1.0, &win1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < 4;  i++ )
   {
      wnfetd_c ( &win1, i, darray[i], (darray[i])+1 );
      chckxc_c ( SPICEFALSE, " ", ok );

      chckad_c ( "win1", darray[i], "=", darrayexp[i], 2, 0.0, ok );
   }
  
   /*
   Check the window's cardinality. 
   */
   chcksi_c ( "card_c(&win1)", card_c(&win1), "=", 8, 0, ok );



   tcase_c ( "wnfild_c normal test #2" );
   /*
   Set up the expected result array. 
   */
   darrayexp[0][0] =  1.0;
   darrayexp[0][1] =  3.0;

   darrayexp[1][0] =  7.0;
   darrayexp[1][1] = 11.0;

   darrayexp[2][0] = 23.0;
   darrayexp[2][1] = 29.0;

   /*
   Fill gaps (operation #2):
   */
   wnfild_c ( 2.0, &win1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < 3;  i++ )
   {
      wnfetd_c ( &win1, i, darray[i], (darray[i])+1 );
      chckxc_c ( SPICEFALSE, " ", ok );

      chckad_c ( "win1", darray[i], "=", darrayexp[i], 2, 0.0, ok );
   }
  
   /*
   Check the window's cardinality. 
   */
   chcksi_c ( "card_c(&win1)", card_c(&win1), "=", 6, 0, ok );



   tcase_c ( "wnfild_c normal test #3" );
   /*
   The expected result array is unchanged from the previous case. 
   */

   /*
   Fill gaps (operation #3):
   */
   wnfild_c ( 3.0, &win1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < 3;  i++ )
   {
      wnfetd_c ( &win1, i, darray[i], (darray[i])+1 );
      chckxc_c ( SPICEFALSE, " ", ok );

      chckad_c ( "win1", darray[i], "=", darrayexp[i], 2, 0.0, ok );
   }
  
   /*
   Check the window's cardinality. 
   */
   chcksi_c ( "card_c(&win1)", card_c(&win1), "=", 6, 0, ok );


   tcase_c ( "wnfild_c normal test #4" );
   /*
   Set up the expected result array. 
   */
   darrayexp[0][0] =  1.0;
   darrayexp[0][1] = 29.0;

   /*
   Fill gaps (operation #3):
   */
   wnfild_c ( 12.0, &win1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < 1;  i++ )
   {
      wnfetd_c ( &win1, i, darray[i], (darray[i])+1 );
      chckxc_c ( SPICEFALSE, " ", ok );

      chckad_c ( "win1", darray[i], "=", darrayexp[i], 2, 0.0, ok );
   }
  
   /*
   Check the window's cardinality. 
   */
   chcksi_c ( "card_c(&win1)", card_c(&win1), "=", 2, 0, ok );


   tcase_c ( "wnfild_c exception test:  negative gap size" );

   /*
   Set up the initial window and expected result. 
   */ 
   darray[0][0] =  1.0;
   darray[0][1] =  3.0;

   darray[1][0] =  7.0;
   darray[1][1] = 11.0;

   darray[2][0] = 23.0;
   darray[2][1] = 27.0;

   darray[3][0] = 29.0;
   darray[3][1] = 29.0;


   scard_c ( 0, &win1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < 4;  i++ )
   {
      wninsd_c ( darray[i][0], darray[i][1], &win1 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   /*
   Set up the expected result array. 
   */
   darrayexp[0][0] =  1.0;
   darrayexp[0][1] =  3.0;

   darrayexp[1][0] =  7.0;
   darrayexp[1][1] = 11.0;

   darrayexp[2][0] = 23.0;
   darrayexp[2][1] = 27.0;

   darrayexp[3][0] = 29.0;
   darrayexp[3][1] = 29.0;
 

   /*
   Fill gaps:
   */
   wnfild_c ( -2.0, &win1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < 4;  i++ )
   {
      wnfetd_c ( &win1, i, darray[i], (darray[i])+1 );
      chckxc_c ( SPICEFALSE, " ", ok );

      chckad_c ( "win1", darray[i], "=", darrayexp[i], 2, 0.0, ok );
   }
  
   /*
   Check the window's cardinality. 
   */
   chcksi_c ( "card_c(&win1)", card_c(&win1), "=", 8, 0, ok );



   /*
   wnfild_c error cases: 
   */

   tcase_c ( "wnfild_c error case:  first window is integer cell." );    

   wnfild_c ( 5, &icell1 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );



   /*
   wnfltd_c tests: 
   */

   tcase_c ( "wnfltd_c normal test #1" );

   /*
   Set up the initial window and first expected result. 
   */ 
   darray[0][0] =  1.0;
   darray[0][1] =  3.0;

   darray[1][0] =  7.0;
   darray[1][1] = 11.0;

   darray[2][0] = 23.0;
   darray[2][1] = 27.0;

   darray[3][0] = 29.0;
   darray[3][1] = 29.0;


   scard_c ( 0, &win1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < 4;  i++ )
   {
      wninsd_c ( darray[i][0], darray[i][1], &win1 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   /*
   Set up the expected result array. 
   */
   darrayexp[0][0] =  1.0;
   darrayexp[0][1] =  3.0;

   darrayexp[1][0] =  7.0;
   darrayexp[1][1] = 11.0;

   darrayexp[2][0] = 23.0;
   darrayexp[2][1] = 27.0;
 

   /*
   Filter small intervals (operation #1):
   */
   wnfltd_c ( 0.0, &win1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < 3;  i++ )
   {
      wnfetd_c ( &win1, i, darray[i], (darray[i])+1 );
      chckxc_c ( SPICEFALSE, " ", ok );

      chckad_c ( "win1", darray[i], "=", darrayexp[i], 2, 0.0, ok );
   }
  
   /*
   Check the window's cardinality. 
   */
   chcksi_c ( "card_c(&win1)", card_c(&win1), "=", 6, 0, ok );



   tcase_c ( "wnfltd_c normal test #2" );
   /*
   Set up the expected result array. 
   */
   darrayexp[0][0] =  7.0;
   darrayexp[0][1] = 11.0;

   darrayexp[1][0] = 23.0;
   darrayexp[1][1] = 27.0;

   /*
   Filter small intervals (operation #2):
   */
   wnfltd_c ( 2.0, &win1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < 2;  i++ )
   {
      wnfetd_c ( &win1, i, darray[i], (darray[i])+1 );
      chckxc_c ( SPICEFALSE, " ", ok );

      chckad_c ( "win1", darray[i], "=", darrayexp[i], 2, 0.0, ok );
   }
  
   /*
   Check the window's cardinality. 
   */
   chcksi_c ( "card_c(&win1)", card_c(&win1), "=", 4, 0, ok );



   tcase_c ( "wnfltd_c normal test #3" );
   /*
   The expected result array is unchanged from the previous case. 
   */

   /*
   Filter small intervals (operation #3):
   */
   wnfltd_c ( 3.0, &win1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < 2;  i++ )
   {
      wnfetd_c ( &win1, i, darray[i], (darray[i])+1 );
      chckxc_c ( SPICEFALSE, " ", ok );

      chckad_c ( "win1", darray[i], "=", darrayexp[i], 2, 0.0, ok );
   }
  
   /*
   Check the window's cardinality. 
   */
   chcksi_c ( "card_c(&win1)", card_c(&win1), "=", 4, 0, ok );


   tcase_c ( "wnfltd_c exception test:  negative gap size" );

   /*
   Set up the initial window and expected result. 
   */ 
   darray[0][0] =  1.0;
   darray[0][1] =  3.0;

   darray[1][0] =  7.0;
   darray[1][1] = 11.0;

   darray[2][0] = 23.0;
   darray[2][1] = 27.0;

   darray[3][0] = 29.0;
   darray[3][1] = 29.0;


   scard_c ( 0, &win1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < 4;  i++ )
   {
      wninsd_c ( darray[i][0], darray[i][1], &win1 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   /*
   Set up the expected result array. 
   */
   darrayexp[0][0] =  1.0;
   darrayexp[0][1] =  3.0;

   darrayexp[1][0] =  7.0;
   darrayexp[1][1] = 11.0;

   darrayexp[2][0] = 23.0;
   darrayexp[2][1] = 27.0;

   darrayexp[3][0] = 29.0;
   darrayexp[3][1] = 29.0;
 

   /*
   Filter:
   */
   wnfltd_c ( -2.0, &win1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < 4;  i++ )
   {
      wnfetd_c ( &win1, i, darray[i], (darray[i])+1 );
      chckxc_c ( SPICEFALSE, " ", ok );

      chckad_c ( "win1", darray[i], "=", darrayexp[i], 2, 0.0, ok );
   }
  
   /*
   Check the window's cardinality. 
   */
   chcksi_c ( "card_c(&win1)", card_c(&win1), "=", 8, 0, ok );



   /*
   wnfltd_c error cases: 
   */

   tcase_c ( "wnfltd_c error case:  first window is integer cell." );    

   wnfltd_c ( 5, &icell1 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );




   /*
   wnincd_c tests: 
   */

   tcase_c ( "wnincd_c normal test #1" );

   /*
   Set up the initial window and first expected result. 
   */ 
   darray[0][0] =  1.0;
   darray[0][1] =  3.0;

   darray[1][0] =  7.0;
   darray[1][1] = 11.0;

   darray[2][0] = 23.0;
   darray[2][1] = 27.0;


   scard_c ( 0, &win1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < 3;  i++ )
   {
      wninsd_c ( darray[i][0], darray[i][1], &win1 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }


   /*
   Test inclusion. 
   */
   bresult = wnincd_c ( 1.0, 3.0, &win1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "bresult", bresult, SPICETRUE, ok );


   tcase_c ( "wnincd_c normal test #2" );

   bresult = wnincd_c ( 9.0, 10.0, &win1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "bresult", bresult, SPICETRUE, ok );


   tcase_c ( "wnincd_c normal test #3" );

   bresult = wnincd_c ( 0.0, 2.0, &win1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "bresult", bresult, SPICEFALSE, ok );


   tcase_c ( "wnincd_c normal test #4" );

   bresult = wnincd_c ( 13.0, 15.0, &win1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "bresult", bresult, SPICEFALSE, ok );



   tcase_c ( "wnincd_c normal test #5" );

   bresult = wnincd_c ( 29.0, 30.0, &win1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "bresult", bresult, SPICEFALSE, ok );


   /*
   wncind_c error cases: 
   */
   tcase_c ( "wnincd_c error case:  window is integer cell." );    

   wnincd_c ( 1.0, 1.0, &icell1 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );






   /*
   wnelmd_c tests: 
   */

   tcase_c ( "wnelmd_c normal test #1" );

   /*
   Set up the initial window and first expected result. 
   */ 
   darray[0][0] =  1.0;
   darray[0][1] =  3.0;

   darray[1][0] =  7.0;
   darray[1][1] = 11.0;

   darray[2][0] = 23.0;
   darray[2][1] = 27.0;


   scard_c ( 0, &win1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < 3;  i++ )
   {
      wninsd_c ( darray[i][0], darray[i][1], &win1 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }


   /*
   Test inclusion. 
   */
   bresult = wnelmd_c ( 1.0, &win1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "bresult", bresult, SPICETRUE, ok );



   tcase_c ( "wnelmd_c normal test #2" );

   bresult = wnelmd_c ( 9.0, &win1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "bresult", bresult, SPICETRUE, ok );


   tcase_c ( "wnelmd_c normal test #3" );

   bresult = wnelmd_c ( 0.0, &win1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "bresult", bresult, SPICEFALSE, ok );


   tcase_c ( "wnelmd_c normal test #4" );

   bresult = wnelmd_c ( 13.0, &win1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "bresult", bresult, SPICEFALSE, ok );


   tcase_c ( "wnelmd_c normal test #5" );

   bresult = wnelmd_c ( 29.0,  &win1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "bresult", bresult, SPICEFALSE, ok );


   /*
   wnelmd_c error cases: 
   */
   tcase_c ( "wnelmd_c error case:  window is integer cell." );    

   wnelmd_c ( 1.0, &icell1 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );





   /*
   wnextd_c tests: 
   */

   tcase_c ( "wnextd_c:  extract left endpoints." );

   /*
   Set up the initial window and first expected result. 
   */ 
   darray[0][0] =  1.0;
   darray[0][1] =  3.0;

   darray[1][0] =  7.0;
   darray[1][1] = 11.0;

   darray[2][0] = 23.0;
   darray[2][1] = 27.0;

   darray[3][0] = 29.0;
   darray[3][1] = 29.0;


   scard_c ( 0, &win1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < 4;  i++ )
   {
      wninsd_c ( darray[i][0], darray[i][1], &win1 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }


   /*
   Set up the expected result array. 
   */
   darrayexp[0][0] =  1.0;
   darrayexp[0][1] =  1.0;

   darrayexp[1][0] =  7.0;
   darrayexp[1][1] =  7.0;

   darrayexp[2][0] = 23.0;
   darrayexp[2][1] = 23.0;
 
   darrayexp[3][0] = 29.0;
   darrayexp[3][1] = 29.0;


   /*
   Extract left endpoints:
   */
   wnextd_c ( 'L', &win1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < 4;  i++ )
   {
      wnfetd_c ( &win1, i, darray[i], (darray[i])+1 );
      chckxc_c ( SPICEFALSE, " ", ok );

      chckad_c ( "win1", darray[i], "=", darrayexp[i], 2, 0.0, ok );
   }
  
   /*
   Check the window's cardinality. 
   */
   chcksi_c ( "card_c(&win1)", card_c(&win1), "=", 8, 0, ok );



   tcase_c ( "wnextd_c:  extract right endpoints." );
   /*
   Set up the initial window and expected result. 
   */ 
   darray[0][0] =  1.0;
   darray[0][1] =  3.0;

   darray[1][0] =  7.0;
   darray[1][1] = 11.0;

   darray[2][0] = 23.0;
   darray[2][1] = 27.0;

   darray[3][0] = 29.0;
   darray[3][1] = 29.0;


   scard_c ( 0, &win1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < 4;  i++ )
   {
      wninsd_c ( darray[i][0], darray[i][1], &win1 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   /*
   Set up the expected result array. 
   */
   darrayexp[0][0] =  3.0;
   darrayexp[0][1] =  3.0;

   darrayexp[1][0] = 11.0;
   darrayexp[1][1] = 11.0;

   darrayexp[2][0] = 27.0;
   darrayexp[2][1] = 27.0;
 
   darrayexp[3][0] = 29.0;
   darrayexp[3][1] = 29.0;


   /*
   Extract right endpoints:
   */
   wnextd_c ( 'r', &win1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < 4;  i++ )
   {
      wnfetd_c ( &win1, i, darray[i], (darray[i])+1 );
      chckxc_c ( SPICEFALSE, " ", ok );

      chckad_c ( "win1", darray[i], "=", darrayexp[i], 2, 0.0, ok );
   }
  
   /*
   Check the window's cardinality. 
   */
   chcksi_c ( "card_c(&win1)", card_c(&win1), "=", 8, 0, ok );



   /*
   wnextd_c error cases: 
   */
   tcase_c ( "wnextd_c error case:  window is integer cell." );    

   wnextd_c ( 'R', &icell1 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );


   tcase_c ( "wnextd_c error case:  bad side specification." );    

   wnextd_c ( 'x', &win1 );
   chckxc_c ( SPICETRUE, "SPICE(INVALIDENDPNTSPEC)", ok );





   /*
   wnreld_c tests: 
   */
   tcase_c ( "wnreld_c:  normal case #1" );

   /*
   Set up the windows.  
   */ 
   darray[0][0] =  1.0;
   darray[0][1] =  3.0;

   darray[1][0] =  7.0;
   darray[1][1] = 11.0;

   darray[2][0] = 23.0;
   darray[2][1] = 27.0;

   scard_c ( 0, &win1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < 3;  i++ )
   {
      wninsd_c ( darray[i][0], darray[i][1], &win1 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }


   darray[0][0] =  1.0;
   darray[0][1] =  2.0;

   darray[1][0] =  9.0;
   darray[1][1] =  9.0;

   darray[2][0] = 24.0;
   darray[2][1] = 27.0;

   scard_c ( 0, &win2 );
   chckxc_c ( SPICEFALSE, " ", ok );

   scard_c ( 0, &win5 );
   chckxc_c ( SPICEFALSE, " ", ok );


   for ( i = 0;  i < 3;  i++ )
   {
      wninsd_c ( darray[i][0], darray[i][1], &win2 );
      chckxc_c ( SPICEFALSE, " ", ok );
      
      wninsd_c ( darray[i][0], darray[i][1], &win5 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }


   darray[0][0] =  5.0;
   darray[0][1] = 10.0;

   darray[1][0] = 15.0;
   darray[1][1] = 25.0;

   scard_c ( 0, &win6 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < 2;  i++ )
   {
      wninsd_c ( darray[i][0], darray[i][1], &win6 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   bresult = wnreld_c ( &win2, "=",  &win5 );
   chcksl_c ( "bresult", bresult, SPICETRUE, ok );


   tcase_c ( "wnreld_c:  normal case #2" );

   bresult = wnreld_c ( &win2, "<=",  &win5 );
   chcksl_c ( "bresult", bresult, SPICETRUE, ok );

   tcase_c ( "wnreld_c:  normal case #3" );

   bresult = wnreld_c ( &win2, ">=",  &win5 );
   chcksl_c ( "bresult", bresult, SPICETRUE, ok );

   tcase_c ( "wnreld_c:  normal case #4" );

   bresult = wnreld_c ( &win2, "<>",  &win5 );
   chcksl_c ( "bresult", bresult, SPICEFALSE, ok );

   tcase_c ( "wnreld_c:  normal case #5" );

   bresult = wnreld_c ( &win2, "<",  &win5 );
   chcksl_c ( "bresult", bresult, SPICEFALSE, ok );

   tcase_c ( "wnreld_c:  normal case #6" );

   bresult = wnreld_c ( &win2, ">",  &win5 );
   chcksl_c ( "bresult", bresult, SPICEFALSE, ok );

   tcase_c ( "wnreld_c:  normal case #7" );

   bresult = wnreld_c ( &win2, "<=",  &win1 );
   chcksl_c ( "bresult", bresult, SPICETRUE, ok );

   tcase_c ( "wnreld_c:  normal case #8" );

   bresult = wnreld_c ( &win1, ">",  &win5 );
   chcksl_c ( "bresult", bresult, SPICETRUE, ok );


   tcase_c ( "wnreld_c:  normal case #9" );

   bresult = wnreld_c ( &win2, "<",  &win1 );
   chcksl_c ( "bresult", bresult, SPICETRUE, ok );


   tcase_c ( "wnreld_c:  normal case #10" );

   bresult = wnreld_c ( &win1, ">",  &win5 );
   chcksl_c ( "bresult", bresult, SPICETRUE, ok );


   tcase_c ( "wnreld_c:  normal case #11" );

   bresult = wnreld_c ( &win1, "=",  &win6 );
   chcksl_c ( "bresult", bresult, SPICEFALSE, ok );

   tcase_c ( "wnreld_c:  normal case #12" );

   bresult = wnreld_c ( &win1, "<=",  &win6 );
   chcksl_c ( "bresult", bresult, SPICEFALSE, ok );

   tcase_c ( "wnreld_c:  normal case #13" );

   bresult = wnreld_c ( &win1, ">=",  &win6 );
   chcksl_c ( "bresult", bresult, SPICEFALSE, ok );

   tcase_c ( "wnreld_c:  normal case #14" );

   bresult = wnreld_c ( &win1, "=",  &win1 );
   chcksl_c ( "bresult", bresult, SPICETRUE, ok );

   tcase_c ( "wnreld_c:  normal case #15" );

   bresult = wnreld_c ( &win1, "<=",  &win1 );
   chcksl_c ( "bresult", bresult, SPICETRUE, ok );

   tcase_c ( "wnreld_c:  normal case #16" );

   bresult = wnreld_c ( &win1, ">=",  &win1 );
   chcksl_c ( "bresult", bresult, SPICETRUE, ok );

   tcase_c ( "wnreld_c:  normal case #17" );

   bresult = wnreld_c ( &win1, "<",  &win1 );
   chcksl_c ( "bresult", bresult, SPICEFALSE, ok );

   tcase_c ( "wnreld_c:  normal case #18" );

   bresult = wnreld_c ( &win1, ">",  &win1 );
   chcksl_c ( "bresult", bresult, SPICEFALSE, ok );


   tcase_c ( "wnreld_c:  normal case #19" );

   scard_c ( 0, &win4 );

   bresult = wnreld_c ( &win4, "<",  &win1 );
   chcksl_c ( "bresult", bresult, SPICETRUE, ok );


   tcase_c ( "wnreld_c:  normal case #20" );

   scard_c ( 0, &win5 );
   bresult = wnreld_c ( &win4, "<",  &win5 );
   chcksl_c ( "bresult", bresult, SPICEFALSE, ok );

   /*
   wnreld_c error cases: 
   */
   tcase_c ( "wnreld_c error case:  first window is integer cell." );    

   wnreld_c ( &icell1, "=", &win1 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );


   tcase_c ( "wnreld_c error case:  second window is integer cell." );    

   wnreld_c ( &win1, "=", &icell1 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );

   tcase_c ( "wnreld_c error case:  invalid operator." );    

   wnreld_c ( &win1, "x", &win2 );
   chckxc_c ( SPICETRUE, "SPICE(INVALIDOPERATION)", ok );

   tcase_c ( "wnreld_c error case:  null operator string" );    

   wnreld_c ( &win1, NULLCPTR, &win2 );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   tcase_c ( "wnreld_c error case:  empty operator string" );    

   wnreld_c ( &win1, "", &win2 );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );


   /*
   wnsumd_c tests: 
   */
   tcase_c ( "wnsumd_c:  normal case #1" );

   /*
   Set up the windows.  
   */ 
   darray[0][0] =  1.0;
   darray[0][1] =  3.0;

   darray[1][0] =  7.0;
   darray[1][1] = 11.0;

   darray[2][0] = 23.0;
   darray[2][1] = 27.0;

   scard_c ( 0, &win1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < 3;  i++ )
   {
      wninsd_c ( darray[i][0], darray[i][1], &win1 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }


   darray[0][0] =  2.0;
   darray[0][1] =  2.0;

   darray[1][0] =  9.0;
   darray[1][1] =  9.0;

   darray[2][0] = 27.0;
   darray[2][1] = 27.0;

   scard_c ( 0, &win2 );
   chckxc_c ( SPICEFALSE, " ", ok );

   scard_c ( 0, &win5 );
   chckxc_c ( SPICEFALSE, " ", ok );


   for ( i = 0;  i < 3;  i++ )
   {
      wninsd_c ( darray[i][0], darray[i][1], &win2 );
      chckxc_c ( SPICEFALSE, " ", ok );
      
      wninsd_c ( darray[i][0], darray[i][1], &win5 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }


   /*
   Get the summary for win1. 
   */
   wnsumd_c ( &win1, &meas, &avg, &stddev, &shortest, &longest );
   chckxc_c ( SPICEFALSE, " ", ok );


   chcksd_c ( "measure of win1", meas,     "=", 10.0,      0.0,      ok );
   chcksd_c ( "average of win1", avg,      "~", 10.0/3,    SMALLTOL, ok );
   chcksd_c ( "std dev of win1", stddev,   "~", sqrt(8)/3, SMALLTOL, ok );
   chcksi_c ( "shortest",        shortest, "=", 0,         0,        ok );
   chcksi_c ( "longest",         longest,  "=", 2,         0,        ok );


   tcase_c ( "wnreld_c:  normal case #2" );

   wnsumd_c ( &win2, &meas, &avg, &stddev, &shortest, &longest );
   chckxc_c ( SPICEFALSE, " ", ok );


   chcksd_c ( "measure of win1", meas,     "=",  0.0,      0.0,      ok );
   chcksd_c ( "average of win1", avg,      "~",  0.0,      SMALLTOL, ok );
   chcksd_c ( "std dev of win1", stddev,   "~",  0.0,      SMALLTOL, ok );
   chcksi_c ( "shortest",        shortest, "=",  0,        0,        ok );
   chcksi_c ( "longest",         longest,  "=",  0,        0,        ok );


   /*
   wnsumd_c error cases: 
   */
   tcase_c ( "wnsumd_c error case:  window is integer cell." );    

   wnsumd_c ( &icell1, &meas, &avg, &stddev, &shortest, &longest );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );





   /*
   wnvald_c tests: 
   */
   tcase_c ( "wnvald_c:  normal case #1" );

   /*
   Set up the input array.  
   */ 
   darray[0][0] =  0.0;
   darray[0][1] =  0.0;

   darray[1][0] = 10.0;
   darray[1][1] = 12.0;

   darray[2][0] =  2.0;
   darray[2][1] =  7.0;

   darray[3][0] = 13.0;
   darray[3][1] = 15.0;

   darray[4][0] =  1.0;
   darray[4][1] =  5.0;

   darray[5][0] = 23.0;
   darray[5][1] = 29.0;

   darray[6][0] =  0.0;
   darray[6][1] =  0.0;

   darray[7][0] =  0.0;
   darray[7][1] =  0.0;

   darray[8][0] =  0.0;
   darray[8][1] =  0.0;

   darray[9][0] =  0.0;
   darray[9][1] =  0.0;

   /*
   Fill in the window data. 
   */
   memmove ( win3.data, darray, 20*sizeof(SpiceDouble) );

   /*
   Set up the expected output array. 
   */
   darrayexp[0][0] =  0.0;
   darrayexp[0][1] =  0.0;

   darrayexp[1][0] =  1.0;
   darrayexp[1][1] =  7.0;

   darrayexp[2][0] = 10.0;
   darrayexp[2][1] = 12.0;

   darrayexp[3][0] = 13.0;
   darrayexp[3][1] = 15.0;

   darrayexp[4][0] = 23.0;
   darrayexp[4][1] = 29.0;

   /*
   Validate window win3. 
   */
   wnvald_c ( 30, 20, &win3 );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   Check the resulting window. 
   */
   for ( i = 0;  i < card_c(&win3)/2;  i++ )
   {
      wnfetd_c ( &win3, i, darray[i], (darray[i])+1 );
      chckxc_c ( SPICEFALSE, " ", ok );

      chckad_c ( "win3", darray[i], "=", darrayexp[i], 2, 0.0, ok );
   }
  
   /*
   Check the window's cardinality. 
   */
   chcksi_c ( "card_c(&win3)", card_c(&win3), "=", 10, 0, ok );



   /*
   wnvlad_c error cases: 
   */
   tcase_c ( "wnvald_c error case:  window is integer cell." );    

   wnvald_c ( 30, 20, &icell1 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );


   tcase_c ( "wnvald_c error case:  odd number of endpoints." );    

   wnvald_c ( 30, 3, &win3 );
   chckxc_c ( SPICETRUE, "SPICE(UNMATCHENDPTS)", ok );


   tcase_c ( "wnvald_c error case:  number of endpoints exceeds window "
             "size."                                                    );    

   wnvald_c ( 30, 40, &win3 );
   chckxc_c ( SPICETRUE, "SPICE(WINDOWTOOSMALL)", ok );


   tcase_c ( "wnvald_c error case:  right endpoint of some interval "
             "is less than left endpoint of same interval."          );    

   SPICE_CELL_SET_D ( 5.0, 0, &win1 );
   SPICE_CELL_SET_D ( 4.0, 1, &win1 );

   wnvald_c ( 30, 2, &win1 );
   chckxc_c ( SPICETRUE, "SPICE(BADENDPOINTS)", ok );


   /*
   Retrieve the current test status.
   */ 
   t_success_c ( ok ); 
   
   
} /* End f_wind_c */




void dumpwin ( SpiceChar * name, SpiceCell * win )
{
   SpiceInt                i;


   printf ( "\nWindow: %s\n\n", name  );
   for ( i = 0;  i < card_c(win);  i++ )
   {
      printf ( "Elt[%ld] = %f\n", i, SPICE_CELL_ELEM_D(win,i) );
   }
}
