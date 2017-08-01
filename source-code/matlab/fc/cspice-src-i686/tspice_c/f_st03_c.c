/*

-Procedure f_st03_c ( Test wrappers for string routines, subset 03 )

 
-Abstract
 
   Perform tests on CSPICE character and string position wrappers.
    
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
   #include "tutils_c.h"
   

   void f_st03_c ( SpiceBoolean * ok )

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
      
      cpos_c
      cposr_c
      ncpos_c
      ncposr_c
      pos_c
      posr_c
   
-Examples
 
   None.
    
-Restrictions
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
 
-Literature_References
 
   None. 
 
-Version
 
   -tspice_c Version 1.0.0 15-AUG-2002 (NJB)


-&
*/

{ /* Begin f_st03_c */

 
   /*
   Constants
   */
   
   #define LNSIZE          81
   #define SHORT           5
   
   
   /*
   Local variables
   */
   SpiceChar               string    [ LNSIZE ];
   SpiceChar               chars     [ LNSIZE ];

   SpiceInt                retval;


   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_st03_c" );
   

   
   
   /*
   cpos_c tests:
   */
   strcpy ( string, "BOB, JOHN, TED, AND MARTIN...." );


   tcase_c ( "Test cpos_c:  normal case 1 from the header." );
 
   retval = cpos_c( string, " ,",    0  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 3, 0, ok );


   tcase_c ( "Test cpos_c:  normal case 2 from the header." );
 
   retval = cpos_c( string, " ,",    4  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 4, 0, ok );


   tcase_c ( "Test cpos_c:  normal case 3 from the header." );
 
   retval = cpos_c( string, " ,",    5  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 9, 0, ok );


   tcase_c ( "Test cpos_c:  normal case 4 from the header." );
 
   retval = cpos_c( string, " ,",    10  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 10, 0, ok );


   tcase_c ( "Test cpos_c:  normal case 5 from the header." );
 
   retval = cpos_c( string, " ,",    11  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 14, 0, ok );


   tcase_c ( "Test cpos_c:  normal case 6 from the header." );
 
   retval = cpos_c( string, " ,",    15  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 15, 0, ok );



   tcase_c ( "Test cpos_c:  normal case 7 from the header." );
 
   retval = cpos_c( string, " ,",    16  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 19, 0, ok );


   tcase_c ( "Test cpos_c:  normal case 8 from the header." );
 
   retval = cpos_c( string, " ,",    20  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", -1, 0, ok );


   /*
   start out of bounds cases: 
   */
   tcase_c ( "Test cpos_c:  out-of-bounds case 1 from the header." );
 
   retval = cpos_c( string, " ,",    -112  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 3, 0, ok );


   tcase_c ( "Test cpos_c:  out-of-bounds case 2 from the header." );
 
   retval = cpos_c( string, " ,",    -1  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 3, 0, ok );


   tcase_c ( "Test cpos_c:  out-of-bounds case 3 from the header." );
 
   retval = cpos_c( string, " ,",   1230  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", -1, 0, ok );


 
   /*
   Check cpos_c string error cases:
   
      1) Null string pointers.
      2) Empty input string.
      3) Null template string.
      4) Empty template string.
      
   */

   
   tcase_c ( "cpos_c test:  search string has null pointer" );
 
   retval = cpos_c( NULLCPTR, " ,",   -1  );

   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   chcksi_c ( "retval", retval, "=", -1, 0, ok );


   tcase_c ( "cpos_c test:  character list has null pointer" );
 
   retval = cpos_c( string, NULLCPTR,   -1  );

   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   chcksi_c ( "retval", retval, "=", -1, 0, ok );


   tcase_c ( "cpos_c test:  search string is empty." );
 
   retval = cpos_c( "", " ,",   -1  );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", -1, 0, ok );



   tcase_c ( "cpos_c test:  character list is empty." );
 
   retval = cpos_c( string, "",   -1  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", -1, 0, ok );








   /*
   cposr_c tests:
   */
   strcpy ( string, "BOB, JOHN, TED, AND MARTIN    " );


   tcase_c ( "Test cposr_c:  normal case 1 from the header." );
 
   retval = cposr_c( string, " ,",    29  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 29, 0, ok );


   tcase_c ( "Test cposr_c:  normal case 2 from the header." );
 
   retval = cposr_c( string, " ,",    28  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 28, 0, ok );


   tcase_c ( "Test cposr_c:  normal case 3 from the header." );
 
   retval = cposr_c( string, " ,",    27  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 27, 0, ok );


   tcase_c ( "Test cposr_c:  normal case 4 from the header." );
 
   retval = cposr_c( string, " ,",    26  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 26, 0, ok );


   tcase_c ( "Test cposr_c:  normal case 5 from the header." );
 
   retval = cposr_c( string, " ,",    25  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 19, 0, ok );


   tcase_c ( "Test cposr_c:  normal case 6 from the header." );
 
   retval = cposr_c( string, " ,",    18  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 15, 0, ok );



   tcase_c ( "Test cposr_c:  normal case 7 from the header." );
 
   retval = cposr_c( string, " ,",    14  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 14, 0, ok );


   tcase_c ( "Test cposr_c:  normal case 8 from the header." );
 
   retval = cposr_c( string, " ,",    13  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 10, 0, ok );


   tcase_c ( "Test cposr_c:  normal case 9 from the header." );
 
   retval = cposr_c( string, " ,",    9  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 9, 0, ok );

   tcase_c ( "Test cposr_c:  normal case 10 from the header." );
 
   retval = cposr_c( string, " ,",    8  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 4, 0, ok );

   tcase_c ( "Test cposr_c:  normal case 11 from the header." );
 
   retval = cposr_c( string, " ,",    3  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 3, 0, ok );

   tcase_c ( "Test cposr_c:  normal case 12 from the header." );
 
   retval = cposr_c( string, " ,",    2  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", -1, 0, ok );


   /*
   start out of bounds cases: 
   */
   tcase_c ( "Test cposr_c:  out-of-bounds case 1 from the header." );
 
   retval = cposr_c( string, " ,",    230  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 29, 0, ok );


   tcase_c ( "Test cposr_c:  out-of-bounds case 2 from the header." );
 
   retval = cposr_c( string, " ,",   30  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 29, 0, ok );


   tcase_c ( "Test cposr_c:  out-of-bounds case 3 from the header." );
 
   retval = cposr_c( string, " ,",   -1  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", -1, 0, ok );


 
   tcase_c ( "Test cposr_c:  out-of-bounds case 4 from the header." );
 
   retval = cposr_c( string, " ,",   -10  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", -1, 0, ok );



   /*
   Check cposr_c string error cases:
   
      1) Null string pointers.
      2) Empty input string.
      3) Null template string.
      4) Empty template string.
      
   */

   
   tcase_c ( "cposr_c test:  search string has null pointer" );
 
   retval = cposr_c( NULLCPTR, " ,",   -1  );

   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   chcksi_c ( "retval", retval, "=", -1, 0, ok );


   tcase_c ( "cposr_c test:  character list has null pointer" );
 
   retval = cposr_c( string, NULLCPTR,   -1  );

   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   chcksi_c ( "retval", retval, "=", -1, 0, ok );


   tcase_c ( "cposr_c test:  search string is empty." );
 
   retval = cposr_c( "", " ,",   -1  );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", -1, 0, ok );



   tcase_c ( "cposr_c test:  character list is empty." );
 
   retval = cposr_c( string, "",   -1  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", -1, 0, ok );



   
   
   /*
   ncpos_c tests:
   */
   strcpy ( string, "BOB, JOHN, TED, AND MARTIN...." );
   strcpy ( chars,  "ABCDEFGHIJKLMNOPQRSTUVWXYZ"     );

   tcase_c ( "Test ncpos_c:  normal case 1 from the header." );
 
   retval = ncpos_c( string, chars,    0  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 3, 0, ok );


   tcase_c ( "Test ncpos_c:  normal case 2 from the header." );
 
   retval = ncpos_c( string, chars,    4  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 4, 0, ok );


   tcase_c ( "Test ncpos_c:  normal case 3 from the header." );
 
   retval = ncpos_c( string, chars,    5  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 9, 0, ok );


   tcase_c ( "Test ncpos_c:  normal case 4 from the header." );
 
   retval = ncpos_c( string, chars,    10  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 10, 0, ok );


   tcase_c ( "Test ncpos_c:  normal case 5 from the header." );
 
   retval = ncpos_c( string, chars,    11  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 14, 0, ok );


   tcase_c ( "Test ncpos_c:  normal case 6 from the header." );
 
   retval = ncpos_c( string, chars,    15  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 15, 0, ok );



   tcase_c ( "Test ncpos_c:  normal case 7 from the header." );
 
   retval = ncpos_c( string, chars,    16  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 19, 0, ok );


   tcase_c ( "Test ncpos_c:  normal case 8 from the header." );
 
   retval = ncpos_c( string, chars,    20  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 26, 0, ok );


   tcase_c ( "Test ncpos_c:  normal case 9 from the header." );
 
   retval = ncpos_c( string, chars,    27  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 27, 0, ok );


   tcase_c ( "Test ncpos_c:  normal case 10 from the header." );
 
   retval = ncpos_c( string, chars,    28  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 28, 0, ok );


   tcase_c ( "Test ncpos_c:  normal case 11 from the header." );
 
   retval = ncpos_c( string, chars,    29  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 29, 0, ok );




   /*
   start out of bounds cases: 
   */
   tcase_c ( "Test ncpos_c:  out-of-bounds case 1 from the header." );
 
   retval = ncpos_c( string, chars,    -12  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 3, 0, ok );


   tcase_c ( "Test ncpos_c:  out-of-bounds case 2 from the header." );
 
   retval = ncpos_c( string, chars,    -1  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 3, 0, ok );


   tcase_c ( "Test ncpos_c:  out-of-bounds case 3 from the header." );
 
   retval = ncpos_c( string, chars,   30  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", -1, 0, ok );


   tcase_c ( "Test ncpos_c:  out-of-bounds case 4 from the header." );
 
   retval = ncpos_c( string, chars,   122  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", -1, 0, ok );


 
   /*
   Check ncpos_c string error cases:
   
      1) Null string pointers.
      2) Empty input string.
      3) Null template string.
      4) Empty template string.
      
   */

   
   tcase_c ( "ncpos_c test:  search string has null pointer" );
 
   retval = ncpos_c( NULLCPTR, chars,   -1  );

   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   chcksi_c ( "retval", retval, "=", -1, 0, ok );


   tcase_c ( "ncpos_c test:  character list has null pointer" );
 
   retval = ncpos_c( string, NULLCPTR,   -1  );

   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   chcksi_c ( "retval", retval, "=", -1, 0, ok );


   tcase_c ( "ncpos_c test:  search string is empty." );
 
   retval = ncpos_c( "", chars,   -1  );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", -1, 0, ok );


   tcase_c ( "ncpos_c test:  character list is empty." );
 
   retval = ncpos_c( string, "",   -1  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", -1, 0, ok );





   /*
   ncposr_c tests:
   */
   strcpy ( string, "BOB, JOHN, TED, AND MARTIN    " );
   strcpy ( chars,  "ABCDEFGHIJKLMNOPQRSTUVWXYZ"     );


   tcase_c ( "Test ncposr_c:  normal case 1 from the header." );
 
   retval = ncposr_c( string, chars,    29  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 29, 0, ok );


   tcase_c ( "Test ncposr_c:  normal case 2 from the header." );
 
   retval = ncposr_c( string, chars,    28  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 28, 0, ok );


   tcase_c ( "Test ncposr_c:  normal case 3 from the header." );
 
   retval = ncposr_c( string, chars,    27  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 27, 0, ok );


   tcase_c ( "Test ncposr_c:  normal case 4 from the header." );
 
   retval = ncposr_c( string, chars,    26  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 26, 0, ok );


   tcase_c ( "Test ncposr_c:  normal case 5 from the header." );
 
   retval = ncposr_c( string, chars,    25  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 19, 0, ok );


   tcase_c ( "Test ncposr_c:  normal case 6 from the header." );
 
   retval = ncposr_c( string, chars,    18  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 15, 0, ok );



   tcase_c ( "Test ncposr_c:  normal case 7 from the header." );
 
   retval = ncposr_c( string, chars,    14  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 14, 0, ok );


   tcase_c ( "Test ncposr_c:  normal case 8 from the header." );
 
   retval = ncposr_c( string, chars,    13  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 10, 0, ok );


   tcase_c ( "Test ncposr_c:  normal case 9 from the header." );
 
   retval = ncposr_c( string, chars,    9  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 9, 0, ok );

   tcase_c ( "Test ncposr_c:  normal case 10 from the header." );
 
   retval = ncposr_c( string, chars,    8  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 4, 0, ok );

   tcase_c ( "Test ncposr_c:  normal case 11 from the header." );
 
   retval = ncposr_c( string, chars,    3  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 3, 0, ok );

   tcase_c ( "Test ncposr_c:  normal case 12 from the header." );
 
   retval = ncposr_c( string, chars,    2  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", -1, 0, ok );


   /*
   start out of bounds cases: 
   */
   tcase_c ( "Test ncposr_c:  out-of-bounds case 1 from the header." );
 
   retval = ncposr_c( string, chars,   -1  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", -1, 0, ok );


   tcase_c ( "Test ncposr_c:  out-of-bounds case 2 from the header." );
 
   retval = ncposr_c( string, chars,    -5  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", -1, 0, ok );


   tcase_c ( "Test ncposr_c:  out-of-bounds case 3 from the header." );
 
   retval = ncposr_c( string, chars,   30  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 29, 0, ok );

 
   tcase_c ( "Test ncposr_c:  out-of-bounds case 4 from the header." );
 
   retval = ncposr_c( string, chars,   122 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 29, 0, ok );



   /*
   Check ncposr_c string error cases:
   
      1) Null string pointers.
      2) Empty input string.
      3) Null template string.
      4) Empty template string.
      
   */

   
   tcase_c ( "ncposr_c test:  search string has null pointer" );
 
   retval = ncposr_c( NULLCPTR, chars,   -1  );

   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   chcksi_c ( "retval", retval, "=", -1, 0, ok );


   tcase_c ( "ncposr_c test:  character list has null pointer" );
 
   retval = ncposr_c( string, NULLCPTR,   -1  );

   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   chcksi_c ( "retval", retval, "=", -1, 0, ok );


   tcase_c ( "ncposr_c test:  search string is empty." );
 
   retval = ncposr_c( "", chars,   -1  );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", -1, 0, ok );



   tcase_c ( "ncposr_c test:  character list is empty." );
 
   retval = ncposr_c( string, "",   -1  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", -1, 0, ok );






   /*
   pos_c tests:
   */
   strcpy ( string, "AN ANT AND AN ELEPHANT        "  );


   tcase_c ( "Test pos_c:  normal case 1 from the header." );
 
   retval = pos_c( string, "AN",    0  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 0, 0, ok );


   tcase_c ( "Test pos_c:  normal case 2 from the header." );
 
   retval = pos_c( string, "AN",    2  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 3, 0, ok );


   tcase_c ( "Test pos_c:  normal case 3 from the header." );
 
   retval = pos_c( string, "AN",    5  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 7, 0, ok );


   tcase_c ( "Test pos_c:  normal case 4 from the header." );
 
   retval = pos_c( string, "AN",    9  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 11, 0, ok );


   tcase_c ( "Test pos_c:  normal case 5 from the header." );
 
   retval = pos_c( string, "AN",    13 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 19, 0, ok );


   tcase_c ( "Test pos_c:  normal case 6 from the header." );
 
   retval = pos_c( string, "AN",    21  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", -1, 0, ok );



   /*
   start out of bounds cases: 
   */
   tcase_c ( "Test pos_c:  out-of-bounds case 1 from the header." );
 
   retval = pos_c( string, "AN",   -6  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 0, 0, ok );


   tcase_c ( "Test pos_c:  out-of-bounds case 2 from the header." );
 
   retval = pos_c( string, "AN",    -1  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 0, 0, ok );


   tcase_c ( "Test pos_c:  out-of-bounds case 3 from the header." );
 
   retval = pos_c( string, "AN",   30  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", -1, 0, ok );

 
   tcase_c ( "Test pos_c:  out-of-bounds case 4 from the header." );
 
   retval = pos_c( string, "AN",   43 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", -1, 0, ok );


   /*
   "Significance of spaces" cases: 
   */
   tcase_c ( "Test pos_c:  spaces case 1 from the header." );
 
   retval = pos_c( string, "AN",   0  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 0, 0, ok );


   tcase_c ( "Test pos_c:  spaces case 2 from the header." );
 
   retval = pos_c( string, " AN",   0  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 2, 0, ok );


   tcase_c ( "Test pos_c:  spaces case 3 from the header." );
 
   retval = pos_c( string, " AN ",   0  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 10, 0, ok );


   tcase_c ( "Test pos_c:  spaces case 4 from the header." );
 
   retval = pos_c( string, " AN  ",   0  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", -1, 0, ok );



   /*
   Check pos_c string error cases:
   
      1) Null string pointers.
      2) Empty input string.
      3) Null template string.
      4) Empty template string.
      
   */

   
   tcase_c ( "pos_c test:  search string has null pointer" );
 
   retval = pos_c( NULLCPTR, chars,   -1  );

   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   chcksi_c ( "retval", retval, "=", -1, 0, ok );


   tcase_c ( "pos_c test:  character list has null pointer" );
 
   retval = pos_c( string, NULLCPTR,   -1  );

   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   chcksi_c ( "retval", retval, "=", -1, 0, ok );


   tcase_c ( "pos_c test:  search string is empty." );
 
   retval = pos_c( "", chars,   -1  );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", -1, 0, ok );



   tcase_c ( "pos_c test:  character list is empty." );
 
   retval = pos_c( string, "",   -1  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", -1, 0, ok );





   /*
   posr_c tests:
   */
   strcpy ( string, "AN ANT AND AN ELEPHANT        "  );


   tcase_c ( "Test posr_c:  normal case 1 from the header." );
 
   retval = posr_c( string, "AN",    29  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 19, 0, ok );


   tcase_c ( "Test posr_c:  normal case 2 from the header." );
 
   retval = posr_c( string, "AN",    18  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 11, 0, ok );


   tcase_c ( "Test posr_c:  normal case 3 from the header." );
 
   retval = posr_c( string, "AN",    10  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 7, 0, ok );


   tcase_c ( "Test posr_c:  normal case 4 from the header." );
 
   retval = posr_c( string, "AN",    6  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 3, 0, ok );


   tcase_c ( "Test posr_c:  normal case 5 from the header." );
 
   retval = posr_c( string, "AN",    2 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 0, 0, ok );




   /*
   start out of bounds cases: 
   */
   tcase_c ( "Test posr_c:  out-of-bounds case 1 from the header." );
 
   retval = posr_c( string, "AN",   -6  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", -1, 0, ok );


   tcase_c ( "Test posr_c:  out-of-bounds case 2 from the header." );
 
   retval = posr_c( string, "AN",    -1  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", -1, 0, ok );


   tcase_c ( "Test posr_c:  out-of-bounds case 3 from the header." );
 
   retval = posr_c( string, "AN",   30  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 19, 0, ok );

 
   tcase_c ( "Test posr_c:  out-of-bounds case 4 from the header." );
 
   retval = posr_c( string, "AN",   43 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 19, 0, ok );


   /*
   "Significance of spaces" cases: 
   */
   tcase_c ( "Test posr_c:  spaces case 1 from the header." );
 
   retval = posr_c( string, "AN",   29  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 19, 0, ok );


   tcase_c ( "Test posr_c:  spaces case 2 from the header." );
 
   retval = posr_c( string, " AN",   29  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 10, 0, ok );


   tcase_c ( "Test posr_c:  spaces case 3 from the header." );
 
   retval = posr_c( string, " AN ",   29  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", 10, 0, ok );


   tcase_c ( "Test posr_c:  spaces case 4 from the header." );
 
   retval = posr_c( string, " AN ",   9  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", -1, 0, ok );


   tcase_c ( "Test posr_c:  spaces case 5 from the header." );
 
   retval = posr_c( string, " AN  ",  29 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", -1, 0, ok );



   /*
   Check posr_c string error cases:
   
      1) Null string pointers.
      2) Empty input string.
      3) Null template string.
      4) Empty template string.
      
   */

   
   tcase_c ( "posr_c test:  search string has null pointer" );
 
   retval = posr_c( NULLCPTR, chars,   -1  );

   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   chcksi_c ( "retval", retval, "=", -1, 0, ok );


   tcase_c ( "posr_c test:  character list has null pointer" );
 
   retval = posr_c( string, NULLCPTR,   -1  );

   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   chcksi_c ( "retval", retval, "=", -1, 0, ok );


   tcase_c ( "posr_c test:  search string is empty." );
 
   retval = posr_c( "", chars,   -1  );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", -1, 0, ok );



   tcase_c ( "posr_c test:  character list is empty." );
 
   retval = posr_c( string, "",   -1  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "retval", retval, "=", -1, 0, ok );





   /*
   Retrieve the current test status.
   */ 
   t_success_c ( ok ); 
   
   
} /* End f_st03_c */


