/*

-Procedure f_set_c ( Test wrappers for set routines )

 
-Abstract
 
   Perform tests on CSPICE set wrappers.
    
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
   

   void f_set_c ( SpiceBoolean * ok )

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
      
      diff_c
      elemc_c
      elemd_c
      elemi_c
      insrtc_c
      insrtd_c
      insrti_c
      inter_c
      ordc_c
      ordd_c
      ordi_c
      removc_c
      removd_c
      removi_c
      sdiff_c
      union_c
      valid_c

-Examples
 
   None.
    
-Restrictions
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
 
-Literature_References
 
   None. 
 
-Version
 
   -tspice_c Version 2.0.0 01-NOV-2005 (NJB)

      Added new test case for insrtc_c:  verify that if the item
      to be inserted, after truncation to the set's string length,
      matches a set element, that no insertion is performed.

   -tspice_c Version 1.0.0 21-AUG-2001 (NJB)


-&
*/

{ /* Begin f_set_c */

   /*
   Prototypes 
   */

   /*
   dumpcell is a utility for debugging.  It's defined within
   this file.
   */
   void dumpcell ( SpiceChar * name, SpiceCell * cell );
   
   /*
   Constants
   */
   
   #define LNSIZE          81
   #define SHRTLN          6
   #define SHORT           5
   #define T               SPICETRUE
   #define F               SPICEFALSE
   #define NMAX            5
   #define TOKLEN          11
   #define FRNMLN          33
   
   #define CSIZE1          10
   #define CSIZE2          10
   #define CSIZE3          20
   #define CSIZE4          20

   #define DSIZE1          10
   #define DSIZE2          10
   #define DSIZE3          20
   #define DSIZE4          20

   #define ISIZE1          10
   #define ISIZE2          10
   #define ISIZE3          20
   #define ISIZE4          20


   /*
   Local variables
   */
   SPICECHAR_CELL   ( ccell1, CSIZE1,  SHRTLN );
   SPICECHAR_CELL   ( ccell2, CSIZE2,  LNSIZE );
   SPICECHAR_CELL   ( ccell3, CSIZE3,  LNSIZE );
   SPICECHAR_CELL   ( ccell4, CSIZE4,  LNSIZE );

   SPICEDOUBLE_CELL ( dcell1, DSIZE1 );
   SPICEDOUBLE_CELL ( dcell2, DSIZE2 );
   SPICEDOUBLE_CELL ( dcell3, DSIZE3 );
   SPICEDOUBLE_CELL ( dcell4, DSIZE4 );

   SPICEINT_CELL    ( icell1, ISIZE1 );
   SPICEINT_CELL    ( icell2, ISIZE2 );
   SPICEINT_CELL    ( icell3, ISIZE3 );
   SPICEINT_CELL    ( icell4, ISIZE4 );

   SpiceBoolean            bval;

   SpiceChar               cArray   [ CSIZE1 ] [ LNSIZE ];

   SpiceChar             * cPtrArr  [ CSIZE1 ] =
                           {
                              "SUN",
                              "MERCURY",
                              "VENUS",
                              "EARTH",
                              "MARS",
                              "JUPITER",
                              "SATURN",
                              "URANUS",
                              "NEPTUNE",
                              "PLUTO"
                           };


   SpiceChar             * cArrayRagged  [ CSIZE1 ] =
                           {
                              "SUN ",
                              "MERCURY  ",
                              "VENUS   ",
                              "EARTH",
                              "MARS ",
                              "JUPITER    ",
                              "SATURN ",
                              "URANUS        ",
                              "NEPTUNE ",
                              "PLUTO "
                           };

   SpiceChar               cval  [ LNSIZE ];
   SpiceChar               citem [ LNSIZE ];
   SpiceChar               label [ LNSIZE ];

   SpiceDouble             dRand  [ DSIZE1 ] = 
                           {
                              2.0, 9.0, 7.0, 5.0, 1.0, 0.0, 8.0, 3.0, 
                              4.0, 6.0
                           };

   SpiceDouble             dval;

   SpiceInt                corder [ CSIZE3 ] ;
   SpiceInt                i;
   SpiceInt                j;

   SpiceInt                iRand  [ ISIZE1 ] = 
                           {
                              2, 9, 7, 5, 1, 0, 8, 3, 4, 6
                           };

   SpiceInt                ival;

   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_set_c" );
   

   /*
   Insertion routine tests: 
   */

   
   /*
   insrti_c tests:
   */
   tcase_c ( "Test insrti_c:  assign values to an integer cell." );
 
   for ( i = 0;  i < ISIZE1;  i++ )
   {
      insrti_c ( i, &icell1 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   for ( i = 0;  i < ISIZE1;  i++ )
   {
      SPICE_CELL_GET_I ( &icell1, i, &ival );

      chcksi_c ( "ival", ival, "=", i, 0, ok );
   }

   
   tcase_c ( "Check size and cardinality of icell1 (first)." );
   
   ival = size_c ( &icell1 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "size", ival, "=", ISIZE1, 0, ok );
  
   ival = card_c ( &icell1 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "card", ival, "=", ISIZE1, 0, ok );
  


   tcase_c ( "Test insrti_c:  insert in reverse order." );

   for ( i = ISIZE1-1;  i>-1;  i-- )
   {
      insrti_c ( i, &icell2 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   for ( i = 0;  i < ISIZE1;  i++ )
   {
      SPICE_CELL_GET_I ( &icell2, i, &ival );

      chcksi_c ( "ival", ival, "=", i, 0, ok );
   }

   tcase_c ( "Test insrti_c:  insert in random order." );

   scard_c ( 0, &icell1 );

   for ( i = ISIZE1-1;  i>-1;  i-- )
   {
      insrti_c ( iRand[i], &icell2 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   for ( i = 0;  i < ISIZE1;  i++ )
   {
      SPICE_CELL_GET_I ( &icell2, i, &ival );

      chcksi_c ( "ival", ival, "=", i, 0, ok );
   }


   tcase_c ( "Test insrti_c:  insert duplicate items." );

   for ( i = ISIZE1-1;  i>-1;  i-- )
   {
      insrti_c ( i, &icell2 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   for ( i = 0;  i < ISIZE1;  i++ )
   {
      SPICE_CELL_GET_I ( &icell2, i, &ival );

      chcksi_c ( "ival", ival, "=", i, 0, ok );
   }
   
   tcase_c ( "Check size and cardinality of icell2 (first)" );
   
   ival = size_c ( &icell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "size", ival, "=", ISIZE1, 0, ok );
  
   ival = card_c ( &icell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "card", ival, "=", ISIZE1, 0, ok );


   /*
   insrti_c error cases 
   */

   tcase_c ( "Error case: insrti_c type mismatch" );

   insrti_c ( 3, &ccell2 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );


   tcase_c ( "Error case: insrti_c overflow" );

   scard_c ( ISIZE1, &icell1 );
   insrti_c ( 33, &icell1 );
   chckxc_c ( SPICETRUE, "SPICE(SETEXCESS)", ok );


   tcase_c ( "insrti_c:  input is not a set" );

   icell1.isSet = SPICEFALSE;

   insrti_c ( 1, &icell1 );
   chckxc_c ( SPICETRUE, "SPICE(NOTASET)", ok );

   icell1.isSet = SPICETRUE;



   /*
   insrtd_c tests:
   */

   tcase_c ( "Test insrtd_c:  assign values to a d.p. cell." );
 
   for ( i = 0;  i < DSIZE1;  i++ )
   {
      insrtd_c ( (SpiceDouble)i, &dcell1 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   for ( i = 0;  i < DSIZE1;  i++ )
   {
      SPICE_CELL_GET_D ( &dcell1, i, &dval );

      chcksd_c ( "dval", dval, "=", (SpiceDouble)i, 0.0, ok );
   }

   
   tcase_c ( "Check size and cardinality of dcell1 (first)." );
   
   ival = size_c ( &dcell1 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "size", ival, "=", DSIZE1, 0, ok );
  
   ival = card_c ( &dcell1 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "card", ival, "=", DSIZE1, 0, ok );
  


   tcase_c ( "Test insrtd_c:  insert in reverse order." );

   for ( i = DSIZE2-1;  i>-1;  i-- )
   {
      insrtd_c ( i, &dcell2 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   for ( i = 0;  i < DSIZE2;  i++ )
   {
      SPICE_CELL_GET_D ( &dcell2, i, &dval );

      chcksd_c ( "dval", dval, "=", (SpiceDouble)i, 0.0, ok );
   }

   tcase_c ( "Check size and cardinality of dcell2 (first)." );
   
   ival = size_c ( &dcell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "size", ival, "=", DSIZE2, 0, ok );
  
   ival = card_c ( &dcell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "card", ival, "=", DSIZE2, 0, ok );
 


   tcase_c ( "Test insrtd_c:  insert in random order." );

   scard_c ( 0, &dcell1 );

   for ( i = DSIZE1-1;  i>-1;  i-- )
   {
      insrtd_c ( dRand[i], &dcell1 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   for ( i = 0;  i < DSIZE1;  i++ )
   {
      SPICE_CELL_GET_D ( &dcell1, i, &dval );

      chcksd_c ( "dval", dval, "=", (SpiceDouble)i, 0.0, ok );
   }

   tcase_c ( "Check size and cardinality of dcell1 (second)." );
   
   ival = size_c ( &dcell1 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "size", ival, "=", DSIZE1, 0, ok );
  
   ival = card_c ( &dcell1 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "card", ival, "=", DSIZE1, 0, ok );



   tcase_c ( "Test insrtd_c:  insert duplicate items." );

   for ( i = DSIZE2-1;  i>-1;  i-- )
   {
      insrtd_c ( (SpiceDouble)i, &dcell2 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   for ( i = 0;  i < DSIZE2;  i++ )
   {
      SPICE_CELL_GET_D ( &dcell2, i, &dval );

      chcksd_c ( "dval", dval, "=", i, 0, ok );
   }
   
   tcase_c ( "Check size and cardinality of dcell2 (second)" );
   
   ival = size_c ( &dcell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "size", ival, "=", DSIZE1, 0, ok );
  
   ival = card_c ( &dcell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "card", ival, "=", DSIZE1, 0, ok );


   /*
   insrtd_c error cases 
   */

   tcase_c ( "Error case: insrtd_c type mismatch" );

   insrtd_c ( 3.0, &ccell2 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );


   tcase_c ( "Error case: insrtd_c overflow" );

   scard_c ( DSIZE1, &dcell1 );
   insrtd_c ( 33.0, &dcell1 );
   chckxc_c ( SPICETRUE, "SPICE(SETEXCESS)", ok );


   tcase_c ( "insrtd_c:  input is not a set" );

   dcell1.isSet = SPICEFALSE;

   insrtd_c ( 1, &dcell1 );
   chckxc_c ( SPICETRUE, "SPICE(NOTASET)", ok );

   dcell1.isSet = SPICETRUE;







   /*
   insrtc_c tests:
   */

   tcase_c ( "Test insrtc_c:  assign values to a character cell." );
 
   for ( i = 0;  i < CSIZE1;  i++ )
   {
      sprintf  ( cval, "%ld", i );
      insrtc_c ( cval, &ccell1 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   for ( i = 0;  i < CSIZE1;  i++ )
   {
      sprintf  ( cval, "%ld", i );

      SPICE_CELL_GET_C( &ccell1, i, LNSIZE, citem );

      chcksc_c ( "cval", citem, "=", cval, ok );
   }

   
   tcase_c ( "Check size and cardinality of ccell1 (first)." );
   
   ival = size_c ( &ccell1 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "size", ival, "=", CSIZE1, 0, ok );
  
   ival = card_c ( &ccell1 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "card", ival, "=", CSIZE1, 0, ok );
  


   tcase_c ( "Test insrtc_c:  make sure trailing characters that "
             "will be truncated are ignored when testing for equality "
             "with set elements."                                       );

   /*
   Empty the cell `cell1'. 
   */
   scard_c ( 0, &ccell1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   Insert items. 
   */
   for ( i = 0;  i < CSIZE1;  i++ )
   {
      sprintf  ( cval, "%ld", i );
      insrtc_c ( cval, &ccell1 );
      chckxc_c ( SPICEFALSE, " ", ok );

      /*
      Attempt to insert a second item that, after truncation, 
      matches the last item inserted.  This should be a no-op.
      */
      sprintf  ( cval, "%ld      yyy", i );
      insrtc_c ( cval, &ccell1 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   /*
   Check the contents of the cell. 
   */
   for ( i = 0;  i < CSIZE1;  i++ )
   {
      sprintf  ( cval, "%ld", i );

      SPICE_CELL_GET_C( &ccell1, i, LNSIZE, citem );

      chcksc_c ( "cval", citem, "=", cval, ok );
   }



   tcase_c ( "Test insrtc_c:  insert in reverse order." );

   for ( i = CSIZE2-1;  i>-1;  i-- )
   {
      sprintf  ( cval, "%ld", i );
      insrtc_c ( cval, &ccell2 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   for ( i = 0;  i < CSIZE2;  i++ )
   {
      sprintf  ( cval, "%ld", i );

      SPICE_CELL_GET_C( &ccell2, i, LNSIZE, citem );

      chcksc_c ( "cval", citem, "=", cval, ok );
   }








   tcase_c ( "Check size and cardinality of ccell2 (first)." );
   
   ival = size_c ( &ccell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "size", ival, "=", CSIZE2, 0, ok );
  
   ival = card_c ( &ccell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "card", ival, "=", CSIZE2, 0, ok );




   tcase_c ( "Test insrtc_c:  assign values to a character cell,"
             "using longer string values this time."             );
 
   scard_c ( 0, &ccell2 );

   for ( i = 0;  i < CSIZE2;  i++ )
   {
      insrtc_c ( cPtrArr[i], &ccell2 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   /*
   find the order of the elements in the cPtrArr list. 
   */
   for ( i = 0;  i < CSIZE2;  i++ )
   {
      strncpy ( cArray[i], cPtrArr[i], LNSIZE );
   }
   
   orderc_c ( LNSIZE, cArray, CSIZE2, corder );

   for ( i = 0;  i < CSIZE2;  i++ )
   {
      SPICE_CELL_GET_C( &ccell2, i, LNSIZE, citem );

      chcksc_c ( "cval", citem, "=", cPtrArr[ corder[i] ], ok );
   }

   
   tcase_c ( "Check size and cardinality of ccell2 (second)." );
   
   ival = size_c ( &ccell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "size", ival, "=", CSIZE2, 0, ok );
  
   ival = card_c ( &ccell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "card", ival, "=", CSIZE2, 0, ok );


   tcase_c ( "Insert element string MARS with trailing blanks. "
             "This should be a no-op"                           );

   insrtc_c ( "MARS   ", &ccell2 );
   chckxc_c ( SPICEFALSE, " ", ok );
  
   for ( i = 0;  i < CSIZE2;  i++ )
   {
      SPICE_CELL_GET_C( &ccell2, i, LNSIZE, citem );

      chcksc_c ( "cval", citem, "=", cPtrArr[ corder[i] ], ok );
   }



   tcase_c ( "Test insrtc_c:  assign values to a character cell,"
             "using longer string values with trailing blanks."   );
 
   scard_c ( 0, &ccell2 );

   for ( i = 0;  i < CSIZE2;  i++ )
   {
      insrtc_c ( cArrayRagged[i], &ccell2 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   /*
   find the order of the elements in the cPtrArr list. 
   */
   for ( i = 0;  i < CSIZE2;  i++ )
   {
      strncpy ( cArray[i], cPtrArr[i], LNSIZE );
   }
   
   orderc_c ( LNSIZE, cArray, CSIZE2, corder );

   for ( i = 0;  i < CSIZE2;  i++ )
   {
      SPICE_CELL_GET_C( &ccell2, i, LNSIZE, citem );

      chcksc_c ( "cval", citem, "=", cPtrArr[ corder[i] ], ok );
   }

   
   tcase_c ( "Check size and cardinality of ccell2 (third)." );
   
   ival = size_c ( &ccell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "size", ival, "=", CSIZE2, 0, ok );
  
   ival = card_c ( &ccell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "card", ival, "=", CSIZE2, 0, ok );




   /*
   insrtc_c error cases 
   */

   tcase_c ( "Error case: insrtc_c type mismatch" );

   insrtc_c ( "x", &dcell2 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );


   tcase_c ( "Error case: insrtc_c overflow" );

   scard_c ( CSIZE1, &ccell1 );
   insrtc_c ( "xx", &ccell1 );
   chckxc_c ( SPICETRUE, "SPICE(SETEXCESS)", ok );


   tcase_c ( "insrtc_c:  input is not a set" );

   ccell1.isSet = SPICEFALSE;

   insrtc_c ( "x", &ccell1 );
   chckxc_c ( SPICETRUE, "SPICE(NOTASET)", ok );

   ccell1.isSet = SPICETRUE;


   tcase_c ( "insrtc_c:  input string pointer is null" );

   scard_c  ( 0, &ccell1 );
   insrtc_c ( NULLCPTR, &ccell1 );

   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   
   /*
   removi_c tests:
   */
   tcase_c ( "Test removi_c:  remove values from an integer cell "
             "from the lowest address upward."                     );
 
   scard_c ( 0, &icell1 );

   for ( i = 0;  i < ISIZE1;  i++ )
   {
      insrti_c ( i, &icell1 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   for ( i = 0;  i < ISIZE1;  i++ )
   {
      removi_c ( i, &icell1 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   
   tcase_c ( "Check size and cardinality of icell1 (removi_c first)." );
   
   ival = size_c ( &icell1 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "size", ival, "=", ISIZE1, 0, ok );
  
   ival = card_c ( &icell1 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "card", ival, "=", 0, 0, ok );
  



   tcase_c ( "Test removi_c:  remove values from an integer cell "
             "from the highest address downward."                   );

   for ( i = ISIZE2-1;  i>-1;  i-- )
   {
      insrti_c ( i, &icell2 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   for ( i = ISIZE2-1;  i>-1;  i-- )
   {
      removi_c ( i, &icell2 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   
   tcase_c ( "Check size and cardinality of icell2 (removi_c first)." );
   
   ival = size_c ( &icell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "size", ival, "=", ISIZE1, 0, ok );
  
   ival = card_c ( &icell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "card", ival, "=", 0, 0, ok );
  



   tcase_c ( "Test insrti_c:  delete in random order." );

   scard_c ( 0, &icell2 );

   for ( i = ISIZE2-1;  i>-1;  i-- )
   {
      insrti_c ( iRand[i], &icell2 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   for ( i = ISIZE2-1;  i>-1;  i-- )
   {
      removi_c ( iRand[i], &icell2 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   tcase_c ( "Check size and cardinality of icell2 (removi_c second)." );
   
   ival = size_c ( &icell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "size", ival, "=", ISIZE1, 0, ok );
  
   ival = card_c ( &icell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "card", ival, "=", 0, 0, ok );



   tcase_c ( "Test removi_c:  attempt to remove value not present in "
             "cell."                                                  );
 
   scard_c ( 0, &icell1 );

   for ( i = 0;  i < ISIZE1;  i++ )
   {
      insrti_c ( i, &icell1 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   removi_c ( -1, &icell1 );
   chckxc_c ( SPICEFALSE, " ", ok );




   /*
   removi_c error cases 
   */

   tcase_c ( "Error case: removi_c type mismatch" );

   removi_c ( 3, &ccell2 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );


   tcase_c ( "removi_c:  input is not a set" );

   icell1.isSet = SPICEFALSE;

   removi_c ( 1, &icell1 );
   chckxc_c ( SPICETRUE, "SPICE(NOTASET)", ok );

   icell1.isSet = SPICETRUE;




   
   /*
   removd_c tests:
   */
   tcase_c ( "Test removd_c:  remove values from an integer cell "
             "from the lowest address upward."                     );
 
   scard_c ( 0, &dcell1 );

   for ( i = 0;  i < DSIZE1;  i++ )
   {
      insrtd_c ( (SpiceDouble)i, &dcell1 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   for ( i = 0;  i < DSIZE1;  i++ )
   {
      removd_c ( (SpiceDouble)i, &dcell1 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   
   tcase_c ( "Check size and cardinality of dcell1 (removd_c first)." );
   
   ival = size_c ( &dcell1 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "size", ival, "=", DSIZE1, 0, ok );
  
   ival = card_c ( &dcell1 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "card", ival, "=", 0, 0, ok );
  



   tcase_c ( "Test removd_c:  remove values from an integer cell "
             "from the highest address downward."                   );

   for ( i = DSIZE2-1;  i>-1;  i-- )
   {
      insrtd_c ( (SpiceDouble)i, &dcell2 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   for ( i = DSIZE2-1;  i>-1;  i-- )
   {
      removd_c ( (SpiceDouble)i, &dcell2 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   
   tcase_c ( "Check size and cardinality of dcell2 (removd_c first)." );
   
   ival = size_c ( &dcell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "size", ival, "=", DSIZE1, 0, ok );
  
   ival = card_c ( &dcell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "card", ival, "=", 0, 0, ok );
  



   tcase_c ( "Test insrtd_c:  delete in random order." );

   scard_c ( 0, &dcell2 );

   for ( i = DSIZE2-1;  i>-1;  i-- )
   {
      insrtd_c ( dRand[i], &dcell2 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   for ( i = DSIZE2-1;  i>-1;  i-- )
   {
      removd_c ( dRand[i], &dcell2 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   tcase_c ( "Check size and cardinality of dcell2 (removd_c second)." );
   
   ival = size_c ( &dcell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "size", ival, "=", DSIZE1, 0, ok );
  
   ival = card_c ( &dcell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "card", ival, "=", 0, 0, ok );



   tcase_c ( "Test removd_c:  attempt to remove value not present in "
             "cell."                                                  );
 
   scard_c ( 0, &dcell1 );

   for ( i = 0;  i < DSIZE1;  i++ )
   {
      insrtd_c ( (SpiceDouble)i, &dcell1 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   removd_c ( -1.0, &dcell1 );
   chckxc_c ( SPICEFALSE, " ", ok );




   /*
   removd_c error cases 
   */

   tcase_c ( "Error case: removd_c type mismatch" );

   removd_c ( 3.0, &ccell2 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );


   tcase_c ( "removd_c:  input is not a set" );

   dcell1.isSet = SPICEFALSE;

   removd_c ( 1.0, &dcell1 );
   chckxc_c ( SPICETRUE, "SPICE(NOTASET)", ok );

   dcell1.isSet = SPICETRUE;



   
   /*
   removc_c tests:
   */
   tcase_c ( "Test removc_c:  remove values from a character cell "
             "from the lowest address upward."                     );
 
   scard_c ( 0, &ccell2 );

   for ( i = 0;  i < CSIZE2;  i++ )
   {
      insrtc_c ( cPtrArr[i], &ccell2 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   for ( i = 0;  i < CSIZE2;  i++ )
   {
      removc_c ( cPtrArr[i], &ccell2 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }
   
   tcase_c ( "Check size and cardinality of ccell2 (removc_c first)." );
   
   ival = size_c ( &ccell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "size", ival, "=", CSIZE2, 0, ok );
  
   ival = card_c ( &ccell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "card", ival, "=", 0, 0, ok );
  



   tcase_c ( "Test removc_c:  remove values from a character cell "
             "from the highest address downward."                   );

   for ( i = CSIZE2-1;  i>-1;  i-- )
   {
      insrtc_c ( cArrayRagged[i], &ccell2 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }


   for ( i = CSIZE1-1;  i>-1;  i-- )
   {
      removc_c ( cArrayRagged[i], &ccell2 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }
   
   tcase_c ( "Check size and cardinality of ccell2 (removc_c second)." );
   
   ival = size_c ( &ccell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "size", ival, "=", CSIZE1, 0, ok );
  
   ival = card_c ( &ccell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "card", ival, "=", 0, 0, ok );
  


   tcase_c ( "Test removc_c:  attempt to remove value not present in "
             "cell."                                                  );
 
   scard_c ( 0, &ccell2 );

   for ( i = 0;  i < CSIZE2;  i++ )
   {
      insrtc_c ( cPtrArr[i], &ccell2 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   removc_c ( "x", &ccell2 );
   chckxc_c ( SPICEFALSE, " ", ok );




   /*
   removc_c error cases 
   */

   tcase_c ( "Error case: removc_c type mismatch" );

   removc_c ( "x", &dcell2 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );


   tcase_c ( "removc_c:  input is not a set" );
 
   ccell1.isSet = SPICEFALSE;

   removc_c ( "x", &ccell1 );
   chckxc_c ( SPICETRUE, "SPICE(NOTASET)", ok );

   ccell1.isSet = SPICETRUE;


   tcase_c ( "removc_c:  input string pointer is null" );

   scard_c  ( 0, &ccell1 );
   removc_c ( NULLCPTR, &ccell1 );

   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );



   /*
   union_c tests: 
   */
   
   /*
   Set up a second integer cell. 
   */

   tcase_c ( "Test union of integer cells" );

   scard_c ( 0, &icell2 );

   for ( i = ISIZE1;  i < ISIZE3;  i++ )
   {
      insrti_c ( i, &icell2 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   union_c ( &icell1, &icell2, &icell3 );
   chckxc_c ( SPICEFALSE, " ", ok );


   for ( i = 0;  i < ISIZE3;  i++ )
   {      
      SPICE_CELL_GET_I ( &icell3, i, &ival );

      chcksi_c ( "ival", ival, "=", i, 0, ok );
   }

   
   tcase_c ( "Check size and cardinality of integer union." );
   
   ival = size_c ( &icell3 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "size", ival, "=", ISIZE3, 0, ok );
  
   ival = card_c ( &icell3 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "card", ival, "=", ISIZE3, 0, ok );




   tcase_c ( "Test union of d.p. cells" );

   scard_c ( 0, &dcell2 );

   for ( i = DSIZE1;  i < DSIZE3;  i++ )
   {
      insrtd_c ( i, &dcell2 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   union_c ( &dcell1, &dcell2, &dcell3 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < DSIZE3;  i++ )
   {
      SPICE_CELL_GET_D ( &dcell3, i, &dval );

      chcksd_c ( "dval", dval, "=", i, 0, ok );
   }

   
   tcase_c ( "Check size and cardinality of d.p. union" );
   
   ival = size_c ( &dcell3 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "size", ival, "=", DSIZE3, 0, ok );
  
   ival = card_c ( &dcell3 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "card", ival, "=", DSIZE3, 0, ok );





   tcase_c ( "Test union of character cells" );

   scard_c ( 0, &ccell1 );

   for ( i = 0;  i < CSIZE1;  i++ )
   {
      sprintf  ( cval, "%ld", 100+i );
      insrtc_c ( cval, &ccell1 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   scard_c ( 0, &ccell2 );

   for ( i = CSIZE1;  i < CSIZE3;  i++ )
   {
      sprintf  ( cval, "%ld", 100+i );
      insrtc_c ( cval, &ccell2 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   union_c ( &ccell1, &ccell2, &ccell3 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < CSIZE3;  i++ )
   {
      sprintf  ( cval, "%ld", 100+i );

      SPICE_CELL_GET_C( &ccell3, i, LNSIZE, citem );

      chcksc_c ( "cval", citem, "=", cval, ok );
   }
   
   tcase_c ( "Check size and cardinality of char union." );
   
   ival = size_c ( &ccell3 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "size", ival, "=", CSIZE3, 0, ok );
  
   ival = card_c ( &ccell3 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "card", ival, "=", CSIZE3, 0, ok );


   /*
   Repeat the character cell test with longer strings. 
   Break up the cPtrArr list into even and odd-indexed components.
   */

   tcase_c ( "Repeat the character cell test with longer strings." );

   scard_c ( 0, &ccell2 );
   scard_c ( 0, &ccell3 );
   
   for ( i = 0;  i < CSIZE2-1;  i+=2 )
   {
      insrtc_c ( cArrayRagged[i],   &ccell2 );
      chckxc_c ( SPICEFALSE,   " ", ok );

      insrtc_c ( cArrayRagged[i+1], &ccell3 );
      chckxc_c ( SPICEFALSE,   " ", ok );
   }

   union_c ( &ccell2, &ccell3, &ccell4 );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   Note:  we expect CSIZE2 members of the combined set. 
   */
   for ( i = 0;  i < CSIZE2;  i++ )
   {
      SPICE_CELL_GET_C( &ccell4, i, LNSIZE, citem );

      sprintf ( label, "ccell4[%ld]", i );
      chcksc_c ( label, citem, "=", cPtrArr[corder[i]], ok ); 
   }
   

   tcase_c ( "Check size and cardinality of char union (ccell4)." );
   
   ival = size_c ( &ccell4 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "size", ival, "=", CSIZE4, 0, ok );
  
   ival = card_c ( &ccell4 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "card", ival, "=", CSIZE2, 0, ok );


   /*
   union_c error cases: 
   */

   tcase_c ( "union_c error case: first and third sets are integer, "
             "second is d.p."                                        );

   union_c ( &icell1, &dcell3, &icell3 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );


   tcase_c ( "union_c error case: first and second sets are character, "
             "third is d.p."                                          );

   union_c ( &ccell1, &ccell3, &dcell3 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );


   tcase_c ( "union_c:  first arg is not a set" );

   icell1.isSet = SPICEFALSE;

   union_c ( &icell1, &icell2, &icell3 );
   chckxc_c ( SPICETRUE, "SPICE(NOTASET)", ok );

   icell1.isSet = SPICETRUE;


   tcase_c ( "union_c:  second arg is not a set" );

   icell2.isSet = SPICEFALSE;

   union_c ( &icell1, &icell2, &icell3 );
   chckxc_c ( SPICETRUE, "SPICE(NOTASET)", ok );

   icell2.isSet = SPICETRUE;


   tcase_c ( "union_c:  result overflow" );

   ssize_c ( 2, &icell3 );

   union_c ( &icell1, &icell2, &icell3 );
   chckxc_c ( SPICETRUE, "SPICE(SETEXCESS)", ok );

   ssize_c ( ISIZE3, &icell3 );


   tcase_c ( "union_c:  output character set is too narrow." );

   /*
   Save the contents of ccell1. 
   */

   ssize_c ( CSIZE4, &ccell4 );

   copy_c ( &ccell1, &ccell4 );
   chckxc_c ( SPICEFALSE, " ", ok );

   union_c ( &ccell2, &ccell3, &ccell1 );
   chckxc_c ( SPICETRUE, "SPICE(ELEMENTSTOOSHORT)", ok );

   /*
   Restore the contents of ccell1. 
   */
   copy_c ( &ccell4, &ccell1 );
   chckxc_c ( SPICEFALSE, " ", ok );



   /*
   inter_c tests: 
   */
   
   tcase_c ( "Test intersection of integer cells" );

   scard_c ( 0, &icell1 );
   scard_c ( 0, &icell3 );

   for ( i = 0;  i < ISIZE1;  i++ )
   {
      insrti_c ( i, &icell1 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   for ( i = 0;  i < ISIZE3;  i++ )
   {
      insrti_c ( i, &icell3 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   inter_c ( &icell1, &icell3, &icell2 );
   chckxc_c ( SPICEFALSE, " ", ok );


   for ( i = 0;  i < ISIZE1;  i++ )
   {      
      SPICE_CELL_GET_I ( &icell1, i, &ival );

      chcksi_c ( "ival", ival, "=", i, 0, ok );
   }


   tcase_c ( "Check size and cardinality of integer intersection." );
   
   ival = size_c ( &icell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "size", ival, "=", ISIZE2, 0, ok );
  
   ival = card_c ( &icell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "card", ival, "=", ISIZE2, 0, ok );



   tcase_c ( "Test intersection of d.p. cells" );

   scard_c ( 0, &dcell1 );
   scard_c ( 0, &dcell3 );

   for ( i = 0;  i < DSIZE1;  i++ )
   {
      insrtd_c ( i, &dcell1 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   for ( i = 0;  i < DSIZE3;  i++ )
   {
      insrtd_c ( i, &dcell3 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   inter_c ( &dcell1, &dcell3, &dcell2 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < DSIZE2;  i++ )
   {
      SPICE_CELL_GET_D ( &dcell2, i, &dval );

      chcksd_c ( "dval", dval, "=", i, 0, ok );
   }

   
   tcase_c ( "Check size and cardinality of d.p. intersection" );
   
   ival = size_c ( &dcell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "size", ival, "=", DSIZE2, 0, ok );
  
   ival = card_c ( &dcell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "card", ival, "=", DSIZE2, 0, ok );




   tcase_c ( "Test intersection of character cells" );

   scard_c ( 0, &ccell1 );
   scard_c ( 0, &ccell3 );

   for ( i = 0;  i < CSIZE1;  i++ )
   {
      sprintf  ( cval, "%ld", 100+i );
      insrtc_c ( cval, &ccell1 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   scard_c ( 0, &ccell3 );

   for ( i = 0;  i < CSIZE3;  i++ )
   {
      sprintf  ( cval, "%ld", 100+i );
      insrtc_c ( cval, &ccell3 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   inter_c ( &ccell1, &ccell3, &ccell2 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < CSIZE2;  i++ )
   {
      sprintf  ( cval, "%ld", 100+i );

      SPICE_CELL_GET_C( &ccell2, i, LNSIZE, citem );

      chcksc_c ( "cval", citem, "=", cval, ok );
   }
   
   tcase_c ( "Check size and cardinality of char intersection." );
   
   ival = size_c ( &ccell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "size", ival, "=", CSIZE2, 0, ok );
  
   ival = card_c ( &ccell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "card", ival, "=", CSIZE2, 0, ok );


   /*
   Repeat the character cell test with longer strings. 
   Break up the cPtrArr list into even and odd-indexed components.
   */

   tcase_c ( "Repeat the character cell test with longer strings." );

   scard_c ( 0, &ccell2 );
   scard_c ( 0, &ccell3 );
   
   for ( i = 0;  i < CSIZE2;  i+=2 )
   {
      insrtc_c ( cArrayRagged[ corder[i] ],   &ccell2 );
      chckxc_c ( SPICEFALSE,   " ", ok );
   }

   for ( i = 0;  i < CSIZE2;  i++ )
   {
      insrtc_c ( cArrayRagged[i],   &ccell3 );
      chckxc_c ( SPICEFALSE,   " ", ok );
   }

   inter_c ( &ccell2, &ccell3, &ccell4 );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   Note:  we expect CSIZE2/2 members of the combined set. 
   */
   for ( i = 0;  i < CSIZE2/2;  i++ )
   {
      SPICE_CELL_GET_C( &ccell4, i, LNSIZE, citem );

      j = 2*i;

      sprintf ( label, "ccell4[%ld]", j );
      chcksc_c ( label, citem, "=", cPtrArr[corder[j]], ok ); 
   }
   

   tcase_c ( "Check size and cardinality of char intersection (ccell4)." );
   
   ival = size_c ( &ccell4 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "size", ival, "=", CSIZE4, 0, ok );
  
   ival = card_c ( &ccell4 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "card", ival, "=", CSIZE2/2, 0, ok );


   /*
   inter_c error cases: 
   */

   tcase_c ( "inter_c error case: first and third sets are integer, "
             "second is d.p."                                        );

   inter_c ( &icell1, &dcell3, &icell3 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );


   tcase_c ( "inter_c error case: first and second sets are character, "
             "third is d.p."                                          );

   inter_c ( &ccell1, &ccell3, &dcell3 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );


   tcase_c ( "inter_c:  first arg is not a set" );

   icell1.isSet = SPICEFALSE;

   inter_c ( &icell1, &icell2, &icell3 );
   chckxc_c ( SPICETRUE, "SPICE(NOTASET)", ok );

   icell1.isSet = SPICETRUE;


   tcase_c ( "inter_c:  second arg is not a set" );

   icell2.isSet = SPICEFALSE;

   inter_c ( &icell1, &icell2, &icell3 );
   chckxc_c ( SPICETRUE, "SPICE(NOTASET)", ok );

   icell2.isSet = SPICETRUE;


   tcase_c ( "inter_c:  result overflow" );

   ssize_c ( 2, &icell3 );

   inter_c ( &icell1, &icell2, &icell3 );
   chckxc_c ( SPICETRUE, "SPICE(SETEXCESS)", ok );

   ssize_c ( ISIZE3, &icell3 );


   tcase_c ( "inter_c:  output character set is too narrow." );

   /*
   Save the contents of ccell1. 
   */

   ssize_c ( CSIZE4, &ccell4 );

   copy_c ( &ccell1, &ccell4 );
   chckxc_c ( SPICEFALSE, " ", ok );

   inter_c ( &ccell2, &ccell3, &ccell1 );
   chckxc_c ( SPICETRUE, "SPICE(ELEMENTSTOOSHORT)", ok );

   /*
   Restore the contents of ccell1. 
   */
   copy_c ( &ccell4, &ccell1 );
   chckxc_c ( SPICEFALSE, " ", ok );






   /*
   diff_c tests: 
   */
   
   tcase_c ( "Test difference of integer cells" );

   scard_c ( 0, &icell1 );
   scard_c ( 0, &icell3 );

   for ( i = 0;  i < ISIZE1;  i++ )
   {
      insrti_c ( i, &icell1 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   for ( i = 0;  i < ISIZE3;  i++ )
   {
      insrti_c ( i, &icell3 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   diff_c ( &icell3, &icell1, &icell2 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = ISIZE1;  i < ISIZE3;  i++ )
   {      
      SPICE_CELL_GET_I ( &icell2, i-ISIZE1, &ival );

      chcksi_c ( "ival", ival, "=", i, 0, ok );
   }


   tcase_c ( "Check size and cardinality of integer difference." );
   
   ival = size_c ( &icell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "size", ival, "=", ISIZE2, 0, ok );
  
   ival = card_c ( &icell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "card", ival, "=", ISIZE3-ISIZE1, 0, ok );



   tcase_c ( "Test difference of d.p. cells" );

   scard_c ( 0, &dcell1 );
   scard_c ( 0, &dcell3 );

   for ( i = 0;  i < DSIZE1;  i++ )
   {
      insrtd_c ( i, &dcell1 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   for ( i = 0;  i < DSIZE3;  i++ )
   {
      insrtd_c ( i, &dcell3 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   diff_c ( &dcell3, &dcell1, &dcell2 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = DSIZE1;  i < DSIZE3;  i++ )
   {
      SPICE_CELL_GET_D ( &dcell2, i-DSIZE1, &dval );

      chcksd_c ( "dval", dval, "=", i, 0, ok );
   }

   
   tcase_c ( "Check size and cardinality of d.p. difference" );
   
   ival = size_c ( &dcell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "size", ival, "=", DSIZE2, 0, ok );
  
   ival = card_c ( &dcell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "card", ival, "=", DSIZE3-DSIZE1, 0, ok );




   tcase_c ( "Test difference of character cells" );

   scard_c ( 0, &ccell1 );
   scard_c ( 0, &ccell3 );

   for ( i = 0;  i < CSIZE1;  i++ )
   {
      sprintf  ( cval, "%ld", 100+i );
      insrtc_c ( cval, &ccell1 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   scard_c ( 0, &ccell3 );

   for ( i = 0;  i < CSIZE3;  i++ )
   {
      sprintf  ( cval, "%ld", 100+i );
      insrtc_c ( cval, &ccell3 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   diff_c ( &ccell3, &ccell1, &ccell2 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = CSIZE1;  i < CSIZE3;  i++ )
   {
      sprintf  ( cval, "%ld", 100+i );

      SPICE_CELL_GET_C( &ccell2, i-CSIZE1, LNSIZE, citem );

      chcksc_c ( "cval", citem, "=", cval, ok );
   }
   
   tcase_c ( "Check size and cardinality of char difference." );
   
   ival = size_c ( &ccell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "size", ival, "=", CSIZE2, 0, ok );
  
   ival = card_c ( &ccell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "card", ival, "=", CSIZE3-CSIZE1, 0, ok );

   /*
   Repeat the character cell test with longer strings. 
   Break up the cPtrArr list into even and odd-indexed components.
   */

   tcase_c ( "Repeat the character cell test with longer strings." );

   scard_c ( 0, &ccell2 );
   scard_c ( 0, &ccell3 );
   
   for ( i = 0;  i < CSIZE2/2; i++ )
   {
      insrtc_c ( cArrayRagged[ corder[i] ],   &ccell2 );
      chckxc_c ( SPICEFALSE,   " ", ok );
   }

   for ( i = 0;  i < CSIZE2;  i++ )
   {
      insrtc_c ( cArrayRagged[i],   &ccell3 );
      chckxc_c ( SPICEFALSE,   " ", ok );
   }

   diff_c ( &ccell3, &ccell2, &ccell4 );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   Note:  we expect CSIZE2/2 members of the combined set. 
   */
   for ( i = CSIZE2/2;  i < CSIZE2;  i++ )
   {
      j = i -(CSIZE2/2);

      SPICE_CELL_GET_C( &ccell4, j, LNSIZE, citem );

      sprintf ( label, "ccell4[%ld]", j );
      chcksc_c ( label, citem, "=", cPtrArr[corder[i]], ok ); 
   }
   

   tcase_c ( "Check size and cardinality of char difference (ccell4)." );
   
   ival = size_c ( &ccell4 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "size", ival, "=", CSIZE4, 0, ok );
  
   ival = card_c ( &ccell4 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "card", ival, "=", CSIZE2/2, 0, ok );


   /*
   diff_c error cases: 
   */

   tcase_c ( "diff_c error case: first and third sets are integer, "
             "second is d.p."                                        );

   diff_c ( &icell1, &dcell3, &icell3 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );


   tcase_c ( "diff_c error case: first and second sets are character, "
             "third is d.p."                                          );

   diff_c ( &ccell1, &ccell3, &dcell3 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );


   tcase_c ( "diff_c:  first arg is not a set" );

   icell1.isSet = SPICEFALSE;

   diff_c ( &icell1, &icell2, &icell3 );
   chckxc_c ( SPICETRUE, "SPICE(NOTASET)", ok );

   icell1.isSet = SPICETRUE;


   tcase_c ( "diff_c:  second arg is not a set" );

   icell2.isSet = SPICEFALSE;

   diff_c ( &icell1, &icell2, &icell3 );
   chckxc_c ( SPICETRUE, "SPICE(NOTASET)", ok );

   icell2.isSet = SPICETRUE;


   tcase_c ( "diff_c:  result overflow" );

   ssize_c ( 2, &icell3 );

   diff_c ( &icell1, &icell2, &icell3 );
   chckxc_c ( SPICETRUE, "SPICE(SETEXCESS)", ok );

   ssize_c ( ISIZE3, &icell3 );


   tcase_c ( "diff_c:  output character set is too narrow." );

   /*
   Save the contents of ccell1. 
   */

   ssize_c ( CSIZE4, &ccell4 );

   copy_c ( &ccell1, &ccell4 );
   chckxc_c ( SPICEFALSE, " ", ok );

   diff_c ( &ccell2, &ccell3, &ccell1 );
   chckxc_c ( SPICETRUE, "SPICE(ELEMENTSTOOSHORT)", ok );

   /*
   Restore the contents of ccell1. 
   */
   copy_c ( &ccell4, &ccell1 );
   chckxc_c ( SPICEFALSE, " ", ok );







   /*
   sdiff_c tests: 
   */
   
   tcase_c ( "Test symmetric difference of integer cells" );

   scard_c ( 0, &icell1 );
   scard_c ( 0, &icell3 );

   for ( i = 0;  i < ISIZE1;  i++ )
   {
      insrti_c ( i, &icell1 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   /*
   Note:  leave off element at index 0.  We want to make sure
   the wrapper can't succeed by calling the diff* routines. 

   Leave off the last element so the result will fit.
   */

   for ( i = 1;  i < ISIZE3-1;  i++ )
   {
      insrti_c ( i, &icell3 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   sdiff_c ( &icell3, &icell1, &icell2 );
   chckxc_c ( SPICEFALSE, " ", ok );

      
   /*
   Check first element of result. 
   */
   SPICE_CELL_GET_I ( &icell2, 0, &ival );
   chcksi_c ( "ival", ival, "=", 0, 0, ok );


   /*
   Check the rest. 
   */
   for ( i = ISIZE1;  i < ISIZE3-1;  i++ )
   {      
      SPICE_CELL_GET_I ( &icell2, i-ISIZE1+1, &ival );

      chcksi_c ( "ival", ival, "=", i, 0, ok );
   }


   tcase_c ( "Check size and cardinality of integer symmetric "
             "difference." );
   
   ival = size_c ( &icell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "size", ival, "=", ISIZE2, 0, ok );
  
   ival = card_c ( &icell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "card", ival, "=", ISIZE3-ISIZE1, 0, ok );



   tcase_c ( "Test symmetric difference of d.p. cells" );

   scard_c ( 0, &dcell1 );
   scard_c ( 0, &dcell3 );

   for ( i = 0;  i < DSIZE1;  i++ )
   {
      insrtd_c ( i, &dcell1 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   for ( i = 1;  i < DSIZE3-1;  i++ )
   {
      insrtd_c ( i, &dcell3 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   sdiff_c ( &dcell3, &dcell1, &dcell2 );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   Check first element of result. 
   */
   SPICE_CELL_GET_D ( &dcell2, 0, &dval );
   chcksd_c ( "dval", dval, "=", 0, 0, ok );


   /*
   Check the rest. 
   */
   for ( i = DSIZE1;  i < DSIZE3-1;  i++ )
   {
      SPICE_CELL_GET_D ( &dcell2, i-DSIZE1+1, &dval );

      chcksd_c ( "dval", dval, "=", i, 0, ok );
   }

   
   tcase_c ( "Check size and cardinality of d.p. symmetric difference" );
   
   ival = size_c ( &dcell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "size", ival, "=", DSIZE2, 0, ok );
  
   ival = card_c ( &dcell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "card", ival, "=", DSIZE3-DSIZE1, 0, ok );




   tcase_c ( "Test symmetric difference of character cells" );

   scard_c ( 0, &ccell1 );
   scard_c ( 0, &ccell3 );

   for ( i = 0;  i < CSIZE1;  i++ )
   {
      sprintf  ( cval, "%ld", 100+i );
      insrtc_c ( cval, &ccell1 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   scard_c ( 0, &ccell3 );

   for ( i = 1;  i < CSIZE3-1;  i++ )
   {
      sprintf  ( cval, "%ld", 100+i );
      insrtc_c ( cval, &ccell3 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   sdiff_c ( &ccell3, &ccell1, &ccell2 );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   Check first element of result. 
   */
   SPICE_CELL_GET_C ( &ccell2, 0, LNSIZE, cval );
   chcksc_c ( "cval", cval, "=", "100", ok );


   /*
   Check the rest. 
   */
   for ( i = CSIZE1;  i < CSIZE3-1;  i++ )
   {
      sprintf  ( cval, "%ld", 100+i );

      SPICE_CELL_GET_C( &ccell2, i-CSIZE1+1, LNSIZE, citem );

      chcksc_c ( "cval", citem, "=", cval, ok );
   }
   
   tcase_c ( "Check size and cardinality of char symmetric difference." );
   
   ival = size_c ( &ccell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "size", ival, "=", CSIZE2, 0, ok );
  
   ival = card_c ( &ccell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "card", ival, "=", CSIZE3-CSIZE1, 0, ok );

   /*
   Repeat the character cell test with longer strings. 
   Break up the cPtrArr list into even and odd-indexed components.
   */

   tcase_c ( "Repeat the character cell test with longer strings." );

   scard_c ( 0, &ccell2 );
   scard_c ( 0, &ccell3 );
   
   for ( i = 0;  i < CSIZE2/2; i++ )
   {
      insrtc_c ( cArrayRagged[ corder[i] ],   &ccell2 );
      chckxc_c ( SPICEFALSE,   " ", ok );
   }

   for ( i = 0;  i < CSIZE2;  i++ )
   {
      insrtc_c ( cArrayRagged[i],   &ccell3 );
      chckxc_c ( SPICEFALSE,   " ", ok );
   }

   sdiff_c ( &ccell3, &ccell2, &ccell4 );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   Note:  we expect CSIZE2/2 members of the combined set. 
   */
   for ( i = CSIZE2/2;  i < CSIZE2;  i++ )
   {
      j = i -(CSIZE2/2);

      SPICE_CELL_GET_C( &ccell4, j, LNSIZE, citem );

      sprintf ( label, "ccell4[%ld]", j );
      chcksc_c ( label, citem, "=", cPtrArr[corder[i]], ok ); 
   }
   

   tcase_c ( "Check size and cardinality of char symmetric "
             "difference (ccell4)."                         );
   
   ival = size_c ( &ccell4 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "size", ival, "=", CSIZE4, 0, ok );
  
   ival = card_c ( &ccell4 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "card", ival, "=", CSIZE2/2, 0, ok );


   /*
   sdiff_c error cases: 
   */

   tcase_c ( "sdiff_c error case: first and third sets are integer, "
             "second is d.p."                                        );

   sdiff_c ( &icell1, &dcell3, &icell3 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );


   tcase_c ( "sdiff_c error case: first and second sets are character, "
             "third is d.p."                                          );

   sdiff_c ( &ccell1, &ccell3, &dcell3 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );


   tcase_c ( "sdiff_c:  first arg is not a set" );

   icell1.isSet = SPICEFALSE;

   sdiff_c ( &icell1, &icell2, &icell3 );
   chckxc_c ( SPICETRUE, "SPICE(NOTASET)", ok );

   icell1.isSet = SPICETRUE;


   tcase_c ( "sdiff_c:  second arg is not a set" );

   icell2.isSet = SPICEFALSE;

   sdiff_c ( &icell1, &icell2, &icell3 );
   chckxc_c ( SPICETRUE, "SPICE(NOTASET)", ok );

   icell2.isSet = SPICETRUE;


   tcase_c ( "sdiff_c:  result overflow" );

   ssize_c ( 2, &icell3 );

   sdiff_c ( &icell1, &icell2, &icell3 );
   chckxc_c ( SPICETRUE, "SPICE(SETEXCESS)", ok );

   ssize_c ( ISIZE3, &icell3 );


   tcase_c ( "sdiff_c:  output character set is too narrow." );

   /*
   Save the contents of ccell1. 
   */

   ssize_c ( CSIZE4, &ccell4 );

   copy_c ( &ccell1, &ccell4 );
   chckxc_c ( SPICEFALSE, " ", ok );

   sdiff_c ( &ccell2, &ccell3, &ccell1 );
   chckxc_c ( SPICETRUE, "SPICE(ELEMENTSTOOSHORT)", ok );

   /*
   Restore the contents of ccell1. 
   */
   copy_c ( &ccell4, &ccell1 );
   chckxc_c ( SPICEFALSE, " ", ok );








   /*
   Test ordi_c: 
   */

   tcase_c ( "ordi_c normal case #1." );

   for ( i = 0;  i < ISIZE1;  i++ )
   {
      ival = ordi_c ( i, &icell1 );
      chckxc_c ( SPICEFALSE, " ", ok );
      chcksi_c ( "order", ival, "=", i, 0, ok );
   }
 
   tcase_c ( "ordi_c normal case #2." );

   ival = ordi_c ( -2, &icell1 );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "order", ival, "=", -1, 0, ok );


   tcase_c ( "ordi_c normal case #3." );

   ival = ordi_c ( 40, &icell1 );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "order", ival, "=", -1, 0, ok );


   /*
   ordi_c error cases: 
   */
   tcase_c ( "ordi_c:  input is not an integer cell" );

   ival = ordi_c ( -2, &dcell1 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );
   chcksi_c ( "order", ival, "=", -1, 0, ok );


   tcase_c ( "ordi_c:  input is not a set" );

   icell1.isSet = SPICEFALSE;

   ival = ordi_c ( 1, &icell1 );
   chckxc_c ( SPICETRUE, "SPICE(NOTASET)", ok );
   chcksi_c ( "order", ival, "=", -1, 0, ok );

   icell1.isSet = SPICETRUE;



   /*
   Test ordd_c: 
   */

   tcase_c ( "ordd_c normal case #1." );

   for ( i = 0;  i < DSIZE1;  i++ )
   {
      ival = ordd_c ( i, &dcell1 );
      chckxc_c ( SPICEFALSE, " ", ok );
      chcksi_c ( "order", ival, "=", i, 0, ok );
   }
 
   tcase_c ( "ordd_c normal case #2." );

   ival = ordd_c ( -2, &dcell1 );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "order", ival, "=", -1, 0, ok );


   tcase_c ( "ordd_c normal case #3." );

   ival = ordd_c ( 40, &dcell1 );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "order", ival, "=", -1, 0, ok );


   /*
   ordd_c error cases: 
   */
   tcase_c ( "ordd_c:  input is not a d.p. cell" );

   ival = ordd_c ( -2, &icell1 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );
   chcksi_c ( "order", ival, "=", -1, 0, ok );


   tcase_c ( "ordd_c:  input is not a set" );

   dcell1.isSet = SPICEFALSE;

   ival = ordd_c ( 1, &dcell1 );
   chckxc_c ( SPICETRUE, "SPICE(NOTASET)", ok );
   chcksi_c ( "order", ival, "=", -1, 0, ok );

   dcell1.isSet = SPICETRUE ;

   /*
   Test ordc_c: 
   */

   tcase_c ( "ordc_c normal case #1." );

   for ( i = 0;  i < CSIZE1;  i++ )
   {
      sprintf  ( cval, "%ld", 100+i );
      ival = ordc_c ( cval, &ccell1 );
      chckxc_c ( SPICEFALSE, " ", ok );
      chcksi_c ( "order", ival, "=", i, 0, ok );
   }
 
   tcase_c ( "ordc_c normal case #2." );

   ival = ordc_c ( "x", &ccell1 );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "order", ival, "=", -1, 0, ok );


   tcase_c ( "ordc_c normal case #3." );

   ival = ordc_c ( "200", &ccell1 );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "order", ival, "=", -1, 0, ok );


   /*
   ordc_c error cases: 
   */
   tcase_c ( "ordc_c:  input is not a character cell" );

   ival = ordc_c ( "a", &icell1 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );
   chcksi_c ( "order", ival, "=", -1, 0, ok );


   tcase_c ( "ordc_c:  input is not a set" );

   ccell1.isSet = SPICEFALSE;

   ival = ordc_c ( "1", &ccell1 );
   chckxc_c ( SPICETRUE, "SPICE(NOTASET)", ok );
   chcksi_c ( "order", ival, "=", -1, 0, ok );

   ccell1.isSet = SPICETRUE;


   tcase_c ( "ordc_c:  input string pointer is null" );

   ival = ordc_c ( NULLCPTR, &ccell1 );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );



   /*
   Test elemi_c: 
   */

   tcase_c ( "elemi_c normal case #1." );

   for ( i = 0;  i < ISIZE1;  i++ )
   {
      bval = elemi_c ( i, &icell1 );
      chckxc_c ( SPICEFALSE, " ", ok );
      chcksl_c ( "included", bval, SPICETRUE, ok );
   }
 
   tcase_c ( "elemi_c normal case #2." );

   bval = elemi_c ( -2, &icell1 );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "included", bval, SPICEFALSE, ok );


   tcase_c ( "elemi_c normal case #3." );

   bval = elemi_c ( 200, &icell1 );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "included", bval, SPICEFALSE, ok );


   /*
   elemi_c error cases: 
   */
   tcase_c ( "elemi_c:  input is not an integer cell" );

   bval = elemi_c ( -2, &dcell1 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );
   chcksl_c ( "included", bval, SPICEFALSE, ok );


   tcase_c ( "elemi_c:  input is not a set" );

   icell1.isSet = SPICEFALSE;

   bval = elemi_c ( 1, &icell1 );
   chckxc_c ( SPICETRUE, "SPICE(NOTASET)", ok );
   chcksl_c ( "included", bval, SPICEFALSE, ok );

   icell1.isSet = SPICETRUE;




   /*
   Test elemd_c: 
   */


   tcase_c ( "elemd_c normal case #1." );

   for ( i = 0;  i < DSIZE1;  i++ )
   {
      bval = elemd_c ( (SpiceDouble)i, &dcell1 );
      chckxc_c ( SPICEFALSE, " ", ok );
      chcksl_c ( "included", bval, SPICETRUE, ok );
   }
 
   tcase_c ( "elemd_c normal case #2." );

   bval = elemd_c ( -2.0, &dcell1 );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "included", bval, SPICEFALSE, ok );


   tcase_c ( "elemd_c normal case #3." );

   bval = elemd_c ( 200.0, &dcell1 );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "included", bval, SPICEFALSE, ok );


   /*
   elemd_c error cases: 
   */
   tcase_c ( "elemd_c:  input is not a d.p. cell" );

   bval = elemd_c ( -2.09, &icell1 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );
   chcksl_c ( "included", bval, SPICEFALSE, ok );


   tcase_c ( "elemd_c:  input is not a set" );

   dcell1.isSet = SPICEFALSE;

   bval = elemd_c ( 1, &dcell1 );
   chckxc_c ( SPICETRUE, "SPICE(NOTASET)", ok );
   chcksl_c ( "included", bval, SPICEFALSE, ok );

   dcell1.isSet = SPICETRUE;




   /*
   Test elemc_c: 
   */
   scard_c ( 0, &ccell2 );

   tcase_c ( "elemc_c normal case #1." );

   for ( i = 0;  i < CSIZE2;  i++ )
   {
      insrtc_c ( cPtrArr[i], &ccell2 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   for ( i = 0;  i < CSIZE2;  i++ )
   {
      bval = elemc_c ( cPtrArr[i], &ccell2 );
      chckxc_c ( SPICEFALSE, " ", ok );
      chcksl_c ( "included", bval, SPICETRUE, ok );
   }
 
   tcase_c ( "elemc_c normal case #2." );

   bval = elemc_c ( "a", &ccell2 );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "included", bval, SPICEFALSE, ok );


   tcase_c ( "elemc_c normal case #3." );

   bval = elemc_c ( "zzz", &ccell2 );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "included", bval, SPICEFALSE, ok );


   tcase_c ( "elemc_c normal case #4." );

   for ( i = 0;  i < CSIZE2;  i++ )
   {
      bval = elemc_c ( cArrayRagged[i], &ccell2 );
      chckxc_c ( SPICEFALSE, " ", ok );
      chcksl_c ( "included", bval, SPICETRUE, ok );
   }

   /*
   elemc_c error cases: 
   */
   tcase_c ( "elemc_c:  input is not a character cell" );

   bval = elemc_c ( "x", &dcell1 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );
   chcksl_c ( "included", bval, SPICEFALSE, ok );


   tcase_c ( "elemc_c:  input is not a set" );

   ccell1.isSet = SPICEFALSE;

   bval = elemc_c ( "x", &ccell1 );
   chckxc_c ( SPICETRUE, "SPICE(NOTASET)", ok );
   chcksl_c ( "included", bval, SPICEFALSE, ok );

   ccell1.isSet = SPICETRUE;


   tcase_c ( "elemc_c:  input string pointer is null" );

   bval = elemc_c ( NULLCPTR, &ccell1 );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );



   /*
   Test valid_c: 
   */

   tcase_c ( "Test valid_c:  integer case.  Append in reverse order." );


   scard_c ( 0, &icell2 );

   for ( i = ISIZE2/2;  i > 0;  i-- )
   {
      appndi_c ( i-1, &icell2 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   valid_c ( ISIZE2, ISIZE2/2, &icell2 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < ISIZE2/2;  i++ )
   {
      SPICE_CELL_GET_I ( &icell2, i, &ival );

      chcksi_c ( "ival", ival, "=", i, 0, ok );
   }


   tcase_c ( "Check size and cardinality of icell2" );
   
   ival = size_c ( &icell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "size", ival, "=", ISIZE2, 0, ok );
  
   ival = card_c ( &icell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "card", ival, "=", ISIZE2/2, 0, ok );


   tcase_c ( "Test valid_c:  d.p. case.  Append in reverse order." );


   scard_c ( 0, &dcell2 );

   for ( i = DSIZE2/2;  i > 0;  i-- )
   {
      appndd_c ( (SpiceDouble)(i-1), &dcell2 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   valid_c ( DSIZE2, DSIZE2/2, &dcell2 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < DSIZE2/2;  i++ )
   {
      SPICE_CELL_GET_D ( &dcell2, i, &dval );

      chcksd_c ( "dval", dval, "=", i, 0.0, ok );
   }


   tcase_c ( "Check size and cardinality of dcell2" );
   
   ival = size_c ( &dcell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "size", ival, "=", DSIZE2, 0, ok );
  
   ival = card_c ( &dcell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "card", ival, "=", DSIZE2/2, 0, ok );




   tcase_c ( "Test valid_c:  character case." );


   scard_c ( 0, &ccell2 );

   for ( i = CSIZE2/2;  i > 0;  i-- )
   {
      appndc_c ( cArrayRagged[ corder[i-1] ], &ccell2 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   valid_c ( CSIZE2, CSIZE2/2, &ccell2 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < CSIZE2/2;  i++ )
   {
      SPICE_CELL_GET_C ( &ccell2, i, LNSIZE, cval );

      chcksc_c ( "cval", cval, "=", cPtrArr[ corder[i] ], ok );
   }


   tcase_c ( "Check size and cardinality of ccell2" );
   
   ival = size_c ( &ccell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "size", ival, "=", CSIZE2, 0, ok );
  
   ival = card_c ( &ccell2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "card", ival, "=", CSIZE2/2, 0, ok );


   /*
   valid_c error cases: 
   */

   tcase_c ( "valid_c error case:  initial size is less than "
             "cardinality. "                                   );


   valid_c ( 1, CSIZE2/2, &ccell2 );

   chckxc_c ( SPICETRUE, "SPICE(INVALIDSIZE)", ok );



   /*
   Test set_c: 
   */

   tcase_c ( "Test set_c:  try the header examples (integer case)." );

   scard_c  ( 0, &icell1 );
   insrti_c ( 1, &icell1 );
   insrti_c ( 2, &icell1 );
   insrti_c ( 3, &icell1 );
   insrti_c ( 4, &icell1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   scard_c  ( 0, &icell2 );
   insrti_c ( 1, &icell2 );
   insrti_c ( 3, &icell2 );
   chckxc_c ( SPICEFALSE, " ", ok );

   scard_c  ( 0, &icell3 );
   insrti_c ( 1, &icell3 );
   insrti_c ( 3, &icell3 );

   scard_c  ( 0, &icell4 );
   chckxc_c ( SPICEFALSE, " ", ok );

   bval = set_c ( &icell2, "=",  &icell3  ); 
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICETRUE, ok );

   bval = set_c ( &icell1, "<>", &icell3  );  
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICETRUE, ok );

   bval = set_c ( &icell1, ">",  &icell2 );   
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICETRUE, ok );

   bval = set_c ( &icell2, "<=", &icell3  );  
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICETRUE, ok );

   bval = set_c ( &icell3, "<=", &icell2 );  
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICETRUE, ok );

   bval = set_c ( &icell1, "<=", &icell1 );   
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICETRUE, ok );

   bval = set_c ( &icell4, "<=", &icell2 );     
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICETRUE, ok );

   bval = set_c ( &icell4, "<",  &icell2 );      
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICETRUE, ok );

   bval = set_c ( &icell4, "<=", &icell4 );      
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICETRUE, ok );

   bval = set_c ( &icell1, "&",  &icell2 );      
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICETRUE, ok );

   bval = set_c ( &icell2, "&",  &icell3  );      
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICETRUE, ok );


   bval = set_c ( &icell2, "<>", &icell3 );  
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICEFALSE, ok );

   bval = set_c ( &icell1, "=",  &icell3 );     
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICEFALSE, ok );

   bval = set_c ( &icell1, "<",  &icell2 );   
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICEFALSE, ok );

   bval = set_c ( &icell2, "<",  &icell3 );   
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICEFALSE, ok );

   bval = set_c ( &icell2, ">=", &icell1 );    
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICEFALSE, ok );

   bval = set_c ( &icell1, ">",  &icell1 );    
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICEFALSE, ok );

   bval = set_c ( &icell4, ">=", &icell1 );      
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICEFALSE, ok );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICEFALSE, ok );

   bval = set_c ( &icell4, "<",  &icell4 );       
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICEFALSE, ok );

   bval = set_c ( &icell1, "~",  &icell2 );        
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICEFALSE, ok );



   tcase_c ( "Test set_c:  try the header examples (d.p. case)." );

   scard_c  ( 0,   &dcell1 );
   insrtd_c ( 1.0, &dcell1 );
   insrtd_c ( 2.0, &dcell1 );
   insrtd_c ( 3.0, &dcell1 );
   insrtd_c ( 4.0, &dcell1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   scard_c  ( 0,   &dcell2 );
   insrtd_c ( 1.0, &dcell2 );
   insrtd_c ( 3.0, &dcell2 );
   chckxc_c ( SPICEFALSE, " ", ok );

   scard_c  ( 0,   &dcell3 );
   insrtd_c ( 1.0, &dcell3 );
   insrtd_c ( 3.0, &dcell3 );

   scard_c  ( 0, &dcell4 );
   chckxc_c ( SPICEFALSE, " ", ok );

   bval = set_c ( &dcell2, "=",  &dcell3  ); 
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICETRUE, ok );

   bval = set_c ( &dcell1, "<>", &dcell3  );  
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICETRUE, ok );

   bval = set_c ( &dcell1, ">",  &dcell2 );   
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICETRUE, ok );

   bval = set_c ( &dcell2, "<=", &dcell3  );  
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICETRUE, ok );

   bval = set_c ( &dcell3, "<=", &dcell2 );  
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICETRUE, ok );

   bval = set_c ( &dcell1, "<=", &dcell1 );   
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICETRUE, ok );

   bval = set_c ( &dcell4, "<=", &dcell2 );     
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICETRUE, ok );

   bval = set_c ( &dcell4, "<",  &dcell2 );      
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICETRUE, ok );

   bval = set_c ( &dcell4, "<=", &dcell4 );      
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICETRUE, ok );

   bval = set_c ( &dcell1, "&",  &dcell2 );      
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICETRUE, ok );

   bval = set_c ( &dcell2, "&",  &dcell3  );      
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICETRUE, ok );


   bval = set_c ( &dcell2, "<>", &dcell3 );  
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICEFALSE, ok );

   bval = set_c ( &dcell1, "=",  &dcell3 );     
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICEFALSE, ok );

   bval = set_c ( &dcell1, "<",  &dcell2 );   
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICEFALSE, ok );

   bval = set_c ( &dcell2, "<",  &dcell3 );   
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICEFALSE, ok );

   bval = set_c ( &dcell2, ">=", &dcell1 );    
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICEFALSE, ok );

   bval = set_c ( &dcell1, ">",  &dcell1 );    
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICEFALSE, ok );

   bval = set_c ( &dcell4, ">=", &dcell1 );      
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICEFALSE, ok );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICEFALSE, ok );

   bval = set_c ( &dcell4, "<",  &dcell4 );       
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICEFALSE, ok );

   bval = set_c ( &dcell1, "~",  &dcell2 );        
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICEFALSE, ok );





   tcase_c ( "Test set_c:  try the header examples (character case)." );

   scard_c  ( 0,     &ccell1 );
   insrtc_c ( "1.0", &ccell1 );
   insrtc_c ( "2.0", &ccell1 );
   insrtc_c ( "3.0", &ccell1 );
   insrtc_c ( "4.0", &ccell1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   scard_c  ( 0,     &ccell2 );
   insrtc_c ( "1.0", &ccell2 );
   insrtc_c ( "3.0", &ccell2 );
   chckxc_c ( SPICEFALSE, " ", ok );

   scard_c  ( 0,     &ccell3 );
   insrtc_c ( "1.0", &ccell3 );
   insrtc_c ( "3.0", &ccell3 );

   scard_c  ( 0, &ccell4 );
   chckxc_c ( SPICEFALSE, " ", ok );

   bval = set_c ( &ccell2, "=",  &ccell3  ); 
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICETRUE, ok );

   bval = set_c ( &ccell1, "<>", &ccell3  );  
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICETRUE, ok );

   bval = set_c ( &ccell1, ">",  &ccell2 );   
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICETRUE, ok );

   bval = set_c ( &ccell2, "<=", &ccell3  );  
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICETRUE, ok );

   bval = set_c ( &ccell3, "<=", &ccell2 );  
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICETRUE, ok );

   bval = set_c ( &ccell1, "<=", &ccell1 );   
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICETRUE, ok );

   bval = set_c ( &ccell4, "<=", &ccell2 );     
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICETRUE, ok );

   bval = set_c ( &ccell4, "<",  &ccell2 );      
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICETRUE, ok );

   bval = set_c ( &ccell4, "<=", &ccell4 );      
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICETRUE, ok );

   bval = set_c ( &ccell1, "&",  &ccell2 );      
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICETRUE, ok );

   bval = set_c ( &ccell2, "&",  &ccell3  );      
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICETRUE, ok );


   bval = set_c ( &ccell2, "<>", &ccell3 );  
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICEFALSE, ok );

   bval = set_c ( &ccell1, "=",  &ccell3 );     
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICEFALSE, ok );

   bval = set_c ( &ccell1, "<",  &ccell2 );   
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICEFALSE, ok );

   bval = set_c ( &ccell2, "<",  &ccell3 );   
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICEFALSE, ok );

   bval = set_c ( &ccell2, ">=", &ccell1 );    
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICEFALSE, ok );

   bval = set_c ( &ccell1, ">",  &ccell1 );    
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICEFALSE, ok );

   bval = set_c ( &ccell4, ">=", &ccell1 );      
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICEFALSE, ok );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICEFALSE, ok );

   bval = set_c ( &ccell4, "<",  &ccell4 );       
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICEFALSE, ok );

   bval = set_c ( &ccell1, "~",  &ccell2 );        
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "set_c result", bval, SPICEFALSE, ok );

   /*
   set_c error cases: 
   */
   tcase_c  ( "Compare an integer cell to a d.p. cell." );

   set_c ( &icell1, "=", &dcell1 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );


   tcase_c  ( "Compare a character cell to a d.p. cell." );

   set_c ( &icell1, "=", &dcell1 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );


   tcase_c  ( "Compare a d.p. cell to an integer cell." );

   set_c ( &dcell1, "=", &icell1 );

   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );



   tcase_c ( "set_c:  1st input is not a set" );

   ccell1.isSet = SPICEFALSE;

   bval = set_c ( &ccell1, "=", &ccell2 );
   chckxc_c ( SPICETRUE, "SPICE(NOTASET)", ok );
   chcksl_c ( "included", bval, SPICEFALSE, ok );

   ccell1.isSet = SPICETRUE;


   tcase_c ( "set_c:  2nd input is not a set" );

   ccell2.isSet = SPICEFALSE;

   bval = set_c ( &ccell1, "=", &ccell2 );
   chckxc_c ( SPICETRUE, "SPICE(NOTASET)", ok );
   chcksl_c ( "included", bval, SPICEFALSE, ok );

   ccell2.isSet = SPICETRUE;



   tcase_c ( "set_c: invalid operator" );

   bval = set_c ( &ccell1, "!=", &ccell2 );
   chckxc_c ( SPICETRUE, "SPICE(INVALIDOPERATION)", ok );
   chcksl_c ( "included", bval, SPICEFALSE, ok );


   tcase_c ( "set_c: empty operator" );

   bval = set_c ( &ccell1, "", &ccell2 );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );
   chcksl_c ( "included", bval, SPICEFALSE, ok );

   tcase_c ( "set_c: null operator" );

   bval = set_c ( &ccell1, NULLCPTR, &ccell2 );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   chcksl_c ( "included", bval, SPICEFALSE, ok );


   /*
   Retrieve the current test status.
   */ 
   t_success_c ( ok ); 
   
   
} /* End f_set_c */



void dumpcell ( SpiceChar * name, SpiceCell * cell )
{
   SpiceInt                i;


   printf ( "\nCell: %s\n\n", name  );

   for ( i = 0;  i < card_c(cell);  i++ )
   {

      if ( cell->dtype == SPICE_DP )
      {
         printf ( "Elt[%ld] = %f\n", i, SPICE_CELL_ELEM_D(cell,i) );
      }
      else if ( cell->dtype == SPICE_INT )
      {
         printf ( "Elt[%ld] = %ld\n", i, SPICE_CELL_ELEM_I(cell,i) );
      }
      else 
      {
         printf ( "Elt[%ld] = %s\n", i, SPICE_CELL_ELEM_C(cell,i) );
      }
   }
}
