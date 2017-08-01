/*

-Procedure f_st04_c ( Test wrappers for string routines, subset 04 )

 
-Abstract
 
   Perform tests on CSPICE lexer wrappers.
    
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
   

   void f_st04_c ( SpiceBoolean * ok )

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
      
      lx4dec_c
      lx4num_c
      lx4sgn_c
      lx4uns_c
      lx4qstr_c
      parsqs_c
   
-Examples
 
   None.
    
-Restrictions
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
 
-Literature_References
 
   None. 
 
-Version
 
   -tspice_c Version 1.0.0 19-AUG-2002 (NJB)


-&
*/

{ /* Begin f_st04_c */

 
   /*
   Constants
   */
   
   #define LNSIZE          81
   #define SHORT           5
   
   
   /*
   Local variables
   */
   SpiceChar               string    [ LNSIZE ];

   SpiceInt                last ;
   SpiceInt                nchars;


   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_st04_c" );
   

   
   
   /*
   lx4dec_c tests:
   */
   tcase_c ( "Test lx4dec_c:  normal case: string = '43.1' " );

   strcpy ( string, "43.1" );

   lx4dec_c ( string, 0, &last, &nchars  );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "last",   last,   "=", 3, 0, ok );
   chcksi_c ( "nchars", nchars, "=", 4, 0, ok );


   tcase_c ( "Test lx4dec_c:  normal case: string = '-43.1' start = 0. " );

   strcpy ( string, "-43.1" );

   lx4dec_c ( string, 0, &last, &nchars  );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "last",   last,   "=", 4, 0, ok );
   chcksi_c ( "nchars", nchars, "=", 5, 0, ok );
 
   /*
   Check lx4dec_c string exception cases:
   
      1) Null string pointers.
      2) Empty input string.
      3) first beyond end of string.
      4) Lexeme doesn't start with a decimal number.
   */

   
   tcase_c ( "lx4dec_c test:  string has null pointer" );
 
   
   lx4dec_c( NULLCPTR, 0, &last, &nchars  );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );


   tcase_c ( "lx4dec_c test:  search string is empty." );
 
   lx4dec_c( "", 0, &last, &nchars  );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "last",   last,   "=", -1, 0, ok );
   chcksi_c ( "nchars", nchars, "=",  0, 0, ok );


   tcase_c ( "lx4dec_c test:  first beyond end of string." );

   lx4dec_c ( string, 40, &last, &nchars  );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "last",   last,   "=",  39, 0, ok );
   chcksi_c ( "nchars", nchars, "=",  0,  0, ok );


   tcase_c ( "lx4dec_c test:  first before start of string." );

   lx4dec_c ( string, -1, &last, &nchars  );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "last",   last,   "=", -2, 0, ok );
   chcksi_c ( "nchars", nchars, "=",  0, 0, ok );


   tcase_c ( "lx4dec_c test: lexeme doesn't start with a decimal number." );

   lx4dec_c ( "x43.1", 0, &last, &nchars  );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "last",   last,   "=", -1, 0, ok );
   chcksi_c ( "nchars", nchars, "=",  0, 0, ok );




   
   /*
   lx4num_c tests:
   */
   tcase_c ( "Test lx4num_c:  normal case: string = '43.1' " );

   strcpy ( string, "43.1" );

   lx4num_c ( string, 0, &last, &nchars  );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "last",   last,   "=", 3, 0, ok );
   chcksi_c ( "nchars", nchars, "=", 4, 0, ok );


   tcase_c ( "Test lx4num_c:  normal case: string = '-43.1' start = 0. " );

   strcpy ( string, "-43.1" );

   lx4num_c ( string, 0, &last, &nchars  );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "last",   last,   "=", 4, 0, ok );
   chcksi_c ( "nchars", nchars, "=", 5, 0, ok );
 
   /*
   Check lx4num_c string exception cases:
   
      1) Null string pointers.
      2) Empty input string.
      3) first beyond end of string.
      4) Lexeme doesn't start with a decimal number.
   */

   
   tcase_c ( "lx4num_c test:  string has null pointer" );
 
   
   lx4num_c( NULLCPTR, 0, &last, &nchars  );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );


   tcase_c ( "lx4num_c test:  search string is empty." );
 
   lx4num_c( "", 0, &last, &nchars  );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "last",   last,   "=", -1, 0, ok );
   chcksi_c ( "nchars", nchars, "=",  0, 0, ok );


   tcase_c ( "lx4num_c test:  first beyond end of string." );

   lx4num_c ( string, 40, &last, &nchars  );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "last",   last,   "=",  39, 0, ok );
   chcksi_c ( "nchars", nchars, "=",  0,  0, ok );


   tcase_c ( "lx4num_c test:  first before start of string." );

   lx4num_c ( string, -1, &last, &nchars  );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "last",   last,   "=", -2, 0, ok );
   chcksi_c ( "nchars", nchars, "=",  0, 0, ok );


   tcase_c ( "lx4num_c test: lexeme doesn't start with a number." );

   lx4num_c ( "x43.1", 0, &last, &nchars  );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "last",   last,   "=", -1, 0, ok );
   chcksi_c ( "nchars", nchars, "=",  0, 0, ok );




   
   /*
   lx4sgn_c tests:
   */
   tcase_c ( "Test lx4sgn_c:  normal case: string = '4310' " );

   strcpy ( string, "4310" );

   lx4sgn_c ( string, 0, &last, &nchars  );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "last",   last,   "=", 3, 0, ok );
   chcksi_c ( "nchars", nchars, "=", 4, 0, ok );


   tcase_c ( "Test lx4sgn_c:  normal case: string = '-4310' start = 0. " );

   strcpy ( string, "-4310" );

   lx4sgn_c ( string, 0, &last, &nchars  );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "last",   last,   "=", 4, 0, ok );
   chcksi_c ( "nchars", nchars, "=", 5, 0, ok );
 
   /*
   Check lx4sgn_c string exception cases:
   
      1) Null string pointers.
      2) Empty input string.
      3) first beyond end of string.
      4) Lexeme doesn't start with a decimal number.
   */

   
   tcase_c ( "lx4sgn_c test:  string has null pointer" );
 
   
   lx4sgn_c( NULLCPTR, 0, &last, &nchars  );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );


   tcase_c ( "lx4sgn_c test:  search string is empty." );
 
   lx4sgn_c( "", 0, &last, &nchars  );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "last",   last,   "=", -1, 0, ok );
   chcksi_c ( "nchars", nchars, "=",  0, 0, ok );


   tcase_c ( "lx4sgn_c test:  first beyond end of string." );

   lx4sgn_c ( string, 40, &last, &nchars  );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "last",   last,   "=",  39, 0, ok );
   chcksi_c ( "nchars", nchars, "=",  0,  0, ok );


   tcase_c ( "lx4sgn_c test:  first before start of string." );

   lx4sgn_c ( string, -1, &last, &nchars  );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "last",   last,   "=", -2, 0, ok );
   chcksi_c ( "nchars", nchars, "=",  0, 0, ok );


   tcase_c ( "lx4sgn_c test: lexeme doesn't start with a signed integer." );

   lx4sgn_c ( ".4310", 0, &last, &nchars  );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "last",   last,   "=", -1, 0, ok );
   chcksi_c ( "nchars", nchars, "=",  0, 0, ok );





   /*
   lx4uns_c tests:
   */
   tcase_c ( "Test lx4uns_c:  normal case: string = '4310' " );

   strcpy ( string, "4310" );

   lx4uns_c ( string, 0, &last, &nchars  );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "last",   last,   "=", 3, 0, ok );
   chcksi_c ( "nchars", nchars, "=", 4, 0, ok );


   tcase_c ( "Test lx4uns_c:  normal case: string = '-4310' start = 0. " );

   strcpy ( string, "-4310" );

   lx4uns_c ( string, 0, &last, &nchars  );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "last",   last,   "=", -1, 0, ok );
   chcksi_c ( "nchars", nchars, "=",  0, 0, ok );
 
   /*
   Check lx4uns_c string exception cases:
   
      1) Null string pointers.
      2) Empty input string.
      3) first beyond end of string.
      4) Lexeme doesn't start with a decimal number.
   */

   
   tcase_c ( "lx4uns_c test:  string has null pointer" );
 
   
   lx4uns_c( NULLCPTR, 0, &last, &nchars  );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );


   tcase_c ( "lx4uns_c test:  search string is empty." );
 
   lx4uns_c( "", 0, &last, &nchars  );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "last",   last,   "=", -1, 0, ok );
   chcksi_c ( "nchars", nchars, "=",  0, 0, ok );


   tcase_c ( "lx4uns_c test:  first beyond end of string." );

   lx4uns_c ( string, 40, &last, &nchars  );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "last",   last,   "=",  39, 0, ok );
   chcksi_c ( "nchars", nchars, "=",  0,  0, ok );


   tcase_c ( "lx4uns_c test:  first before start of string." );

   lx4uns_c ( string, -1, &last, &nchars  );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "last",   last,   "=", -2, 0, ok );
   chcksi_c ( "nchars", nchars, "=",  0, 0, ok );


   tcase_c ( "lx4uns_c test: lexeme doesn't start with an "
             "unsigned integer."                           );

   lx4uns_c ( ".4310", 0, &last, &nchars  );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "last",   last,   "=", -1, 0, ok );
   chcksi_c ( "nchars", nchars, "=",  0, 0, ok );







   /*
   lxqstr_c tests:
   */
   tcase_c ( "Test lxqstr_c:  normal case #1 from header:" );

   strcpy ( string, "The \"SPICE\" system ");

   lxqstr_c ( string, '\"', 4, &last, &nchars  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "last",   last,   "=", 10, 0, ok );
   chcksi_c ( "nchars", nchars, "=",  7, 0, ok );


   tcase_c ( "Test lxqstr_c:  normal case #2 from header:" );

   strcpy ( string, "The \"SPICE\" system ");

   lxqstr_c ( string, '\"', 0, &last, &nchars  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "last",   last,   "=", -1, 0, ok );
   chcksi_c ( "nchars", nchars, "=",  0, 0, ok );
 

   tcase_c ( "Test lxqstr_c:  normal case #3 from header:" );

   strcpy ( string, "The \"SPICE\" system ");

   lxqstr_c ( string, '\'', 4, &last, &nchars  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "last",   last,   "=",  3, 0, ok );
   chcksi_c ( "nchars", nchars, "=",  0, 0, ok );


   tcase_c ( "Test lxqstr_c:  normal case #4 from header:" );

   strcpy ( string, "The \"\"\"SPICE\"\" system ");

   lxqstr_c ( string, '\"', 4, &last, &nchars  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "last",   last,   "=",  12, 0, ok );
   chcksi_c ( "nchars", nchars, "=",   9, 0, ok );


   tcase_c ( "Test lxqstr_c:  normal case #5 from header:" );

   strcpy ( string, "The \"\"\"SPICE\"\" system ");

   lxqstr_c ( string, '\"', 4, &last, &nchars  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "last",   last,   "=",  12, 0, ok );
   chcksi_c ( "nchars", nchars, "=",   9, 0, ok );


   tcase_c ( "Test lxqstr_c:  normal case #6 from header:" );

   strcpy ( string, "The &&&SPICE system ");

   lxqstr_c ( string, '&', 4, &last, &nchars  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "last",   last,   "=",   5, 0, ok );
   chcksi_c ( "nchars", nchars, "=",   2, 0, ok );


   tcase_c ( "Test lxqstr_c:  normal case #7 from header:" );

   strcpy ( string, "' '");

   lxqstr_c ( string, '\'', 0, &last, &nchars  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "last",   last,   "=",   2, 0, ok );
   chcksi_c ( "nchars", nchars, "=",   3, 0, ok );


   tcase_c ( "Test lxqstr_c:  normal case #8 from header:" );

   strcpy ( string, "''");

   lxqstr_c ( string, '\'', 0, &last, &nchars  );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "last",   last,   "=",   1, 0, ok );
   chcksi_c ( "nchars", nchars, "=",   2, 0, ok );


  /*
   Check lxqstr_c string exception cases:
   
      1) Null string pointers.
      2) Empty input string.
      3) first beyond end of string.
      4) Lexeme doesn't start with a decimal number.
   */

   
   tcase_c ( "lxqstr_c test:  string has null pointer" );
 
   
   lxqstr_c( NULLCPTR, '\"', 0, &last, &nchars  );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );


   tcase_c ( "lxqstr_c test:  search string is empty." );
 
   lxqstr_c( "",  '\"', 0, &last, &nchars  );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "last",   last,   "=", -1, 0, ok );
   chcksi_c ( "nchars", nchars, "=",  0, 0, ok );


   tcase_c ( "lxqstr_c test:  first beyond end of string." );

   lxqstr_c ( string,  '\"', 40, &last, &nchars  );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "last",   last,   "=",  39, 0, ok );
   chcksi_c ( "nchars", nchars, "=",  0,  0, ok );


   tcase_c ( "lxqstr_c test:  first before start of string." );

   lxqstr_c ( string,  '\"', -1, &last, &nchars  );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "last",   last,   "=", -2, 0, ok );
   chcksi_c ( "nchars", nchars, "=",  0, 0, ok );


   tcase_c ( "lxqstr_c test: lexeme doesn't start with an "
             "unsigned integer."                           );

   lxqstr_c ( ".4310",  '\"', 0, &last, &nchars  );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "last",   last,   "=", -1, 0, ok );
   chcksi_c ( "nchars", nchars, "=",  0, 0, ok );







   /*
   Retrieve the current test status.
   */ 
   t_success_c ( ok ); 
   
   
} /* End f_st04_c */


