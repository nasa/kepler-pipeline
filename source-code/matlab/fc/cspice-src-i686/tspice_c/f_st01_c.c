/*

-Procedure f_st01_c ( Test wrappers for string routines, subset 01 )

 
-Abstract
 
   Perform tests on CSPICE wrappers for a subset of the string routines.
    
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
   

   void f_st01_c ( SpiceBoolean * ok )

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
 
   This routine tests the wrappers for a subset of the CSPICE string
   routines. 
   
   The subset is:
 
      
      eqstr_c
      frmnam_c
      iswhsp_c
      kxtrct_c
      lastnb_c
      lcase_c
      lparse_c
      lparsm_c
      lparss_c
      matchi_c
      matchw_c
      namfrm_c
      prsdp_c
      prsint_c
      ucase_c
      
-Examples
 
   None.
    
-Restrictions
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
 
-Literature_References
 
   None. 
 
-Version
 
   -tspice_c Version 3.0.0 18-AUG-2001 (NJB)

       Added tests for

          lparsm_c
          lparss_c
          kxtrct_c

   -tspice_c Version 2.0.0 13-AUG-2001 (NJB)

       Added tests for frmnam_c, namfrm_c.
  
   -tspice_c Version 2.0.0 25-MAR-2000 (NJB)  

       Added tests for lparse_c.
       
   -tspice_c Version 1.0.0 27-AUG-1999 (NJB)  

-&
*/

{ /* Begin f_st01_c */

 
   /*
   Constants
   */
   
   #define LNSIZE          81
   #define SHORT           5
   #define N_EQSTR         12
   #define T               SPICETRUE
   #define F               SPICEFALSE
   #define NMAX            5
   #define TOKLEN          11
   #define FRNMLN          33
   
   
   /*
   Local variables
   */
   SPICECHAR_CELL        ( tokset,   NMAX, TOKLEN );
   SPICECHAR_CELL        ( shortset, NMAX, 6      );
   SPICEINT_CELL         ( intset,   NMAX         );


   SpiceBoolean            eqexp    [ N_EQSTR ];
   SpiceBoolean            found;
   SpiceBoolean            iswhite;
   SpiceBoolean            match;

   SpiceChar               items    [ NMAX ] [ TOKLEN ];
   SpiceChar               frname   [ FRNMLN ];
   SpiceChar               keywrd   [ TOKLEN ];
   SpiceChar               outstr   [ LNSIZE ];
   SpiceChar               string   [ LNSIZE ];
   SpiceChar               substr   [ LNSIZE ];
   SpiceChar             * s1       [ N_EQSTR ];
   SpiceChar             * s2       [ N_EQSTR ];
   SpiceChar               terms    [ NMAX ] [ TOKLEN ];

   SpiceDouble             dpval;

   SpiceInt                frcode;
   SpiceInt                i;
   SpiceInt                intval;
   SpiceInt                last;
   SpiceInt                n;
   SpiceInt                nterms;






   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_st01_c" );
   

   
   
   /*
   matchi_c tests:
   */
   tcase_c ( "Test matchi_c" );
 
    
   found = matchi_c ( "cat", "*A%", '*', '%' );
   
   chckxc_c ( SPICEFALSE, " ",              ok );
   chcksl_c ( "found",    found, SPICETRUE, ok );
    
    
   found = matchi_c ( "dog", "*A%", '*', '%' );
   
   chckxc_c ( SPICEFALSE, " ",               ok );
   chcksl_c ( "found",    found, SPICEFALSE, ok );
    

   /*
   Check matchi_c string error cases:
   
      1) Null input string.
      2) Empty input string.
      3) Null template string.
      4) Empty template string.
      
   */
   matchi_c ( NULLCPTR, "*A%", '*', '%' );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   matchi_c ( "", "*A%", '*', '%' );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );
    
    
   matchi_c ( "cat", NULLCPTR, '*', '%' );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   matchi_c ( "cat", "",  '*', '%' );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );
    
       
      
   
   /*
   matchw_c tests:
   */
   tcase_c ( "Test matchw_c" );
 
    
   found = matchw_c ( "CAT", "*A%", '*', '%' );
   
   chckxc_c ( SPICEFALSE, " ",              ok );
   chcksl_c ( "found",    found, SPICETRUE, ok );
    
    
   found = matchw_c ( "cat", "*A%", '*', '%' );
   
   chckxc_c ( SPICEFALSE, " ",               ok );
   chcksl_c ( "found",    found, SPICEFALSE, ok );
    

   /*
   Check matchw_c string error cases:
   
      1) Null input string.
      2) Empty input string.
      3) Null template string.
      4) Empty template string.
      
   */
   matchw_c ( NULLCPTR, "*A%", '*', '%' );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   matchw_c ( "", "*A%", '*', '%' );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );
    
    
   matchw_c ( "cat", NULLCPTR, '*', '%' );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   matchw_c ( "cat", "",  '*', '%' );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );
    
    
    
   /*
   cmprss_c tests:
   */
   tcase_c ( "Test cmprss_c." );    
      
      
   cmprss_c ( ' ', 0, "  spud", LNSIZE, outstr );
   
   chckxc_c ( SPICEFALSE, " ",                          ok );
   chcksc_c ( "compressed string", outstr, "=", "spud", ok );


   cmprss_c ( ' ', 0, "spud  ", LNSIZE, outstr );
   
   chckxc_c ( SPICEFALSE, " ",                          ok );
   chcksc_c ( "compressed string", outstr, "=", "spud", ok );


   cmprss_c ( ' ', 0, "  s p u d  ", LNSIZE, outstr );
   
   chckxc_c ( SPICEFALSE, " ",                          ok );
   chcksc_c ( "compressed string", outstr, "=", "spud", ok );


   cmprss_c ( ' ', 1, "  s p u d  ", SHORT, outstr );
   
   chckxc_c ( SPICEFALSE, " ",                          ok );
   chcksc_c ( "compressed string", outstr, "=", " s p", ok );


   cmprss_c ( ',', 2, ",,,,s,,p,ud,,,", LNSIZE, outstr );
   
   chckxc_c ( SPICEFALSE, " ",                                 ok );
   chcksc_c ( "compressed string", outstr, "=", ",,s,,p,ud,,", ok );


   cmprss_c ( ' ', 0, "  ", LNSIZE, outstr );
   
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "length of compressed string", 
               strlen(outstr),  "=",  0, 0, ok );


   cmprss_c ( ',', 0, "", LNSIZE, outstr );
   
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "length of compressed string", 
               strlen(outstr),  "=",  0, 0, ok );


   /*
   Check cmprss_c string error cases:
   
      1) Null input string.
      2) Null output string.
      3) Output string too short.
      
   */
   cmprss_c ( ' ', 0, NULLCPTR, LNSIZE, outstr );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   cmprss_c ( ',', 2, ",,,", LNSIZE, NULLCPTR );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   cmprss_c ( ',', 2, ",,,", 0, outstr );
   chckxc_c ( SPICETRUE, "SPICE(STRINGTOOSHORT)", ok );



   /*
   ucase_c tests:
   */
   tcase_c ( "Test ucase_c." );    

   ucase_c  ( "UPPER CASE STRING", LNSIZE, outstr );
   chcksc_c ( "outstr", outstr, "=", "UPPER CASE STRING", ok );


   ucase_c  ( "lower case string", LNSIZE, outstr );
   chcksc_c ( "outstr", outstr, "=", "LOWER CASE STRING", ok );


   ucase_c  ( "MIXED case string", LNSIZE, outstr );
   chcksc_c ( "outstr", outstr, "=", "MIXED CASE STRING", ok );


   ucase_c  ( "String that's going to get truncated", 4, outstr );
   chcksc_c ( "outstr", outstr, "=", "STR", ok );


   /*
   Check ucase_c string error cases:
   
      1) Null input string.
      2) Null output string.
      3) Output string too short.
      
   */
   ucase_c ( NULLCPTR, LNSIZE, outstr );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   ucase_c ( "lower case string", LNSIZE, NULLCPTR );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   ucase_c ( "lower case string", 1, outstr );
   chckxc_c ( SPICETRUE, "SPICE(STRINGTOOSHORT)", ok );




      
   /*
   lcase_c tests:
   */
   tcase_c ( "Test lcase_c." );    

   lcase_c  ( "UPPER CASE STRING", LNSIZE, outstr );
   chcksc_c ( "outstr", outstr, "=", "upper case string", ok );


   lcase_c  ( "lower case string", LNSIZE, outstr );
   chcksc_c ( "outstr", outstr, "=", "lower case string", ok );


   lcase_c  ( "MIXED case string", LNSIZE, outstr );
   chcksc_c ( "outstr", outstr, "=", "mixed case string", ok );


   lcase_c  ( "String that's going to get truncated", 4, outstr );
   chcksc_c ( "outstr", outstr, "=", "str", ok );
   
   
   /*
   Check lcase_c string error cases:
   
      1) Null input string.
      2) Null output string.
      3) Output string too short.
      
   */
   lcase_c ( NULLCPTR, LNSIZE, outstr );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   lcase_c ( "lower case string", LNSIZE, NULLCPTR );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   lcase_c ( "lower case string", 1, outstr );
   chckxc_c ( SPICETRUE, "SPICE(STRINGTOOSHORT)", ok );



   /*
   prsint_c tests:
   */
   tcase_c ( "Test prsint_c" );
   

   prsint_c ( "-69", &intval );
   
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "intval", intval, "=", -69, 0, ok );
   
   /*
   Check prsint_c string error cases:
   
      1) Null input string.
      2) Input string empty.
      
   */
   prsint_c ( NULLCPTR, &intval );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   prsint_c ( "", &intval );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );

   

      
   /*
   prsdp_c tests:
   */
   tcase_c ( "Test prsdp_c" );
   

   prsdp_c ( "-69", &dpval );
   
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksd_c ( "dpval", dpval, "=", -69.0, 0, ok );
   
   /*
   Check prsdp_c string error cases:
   
      1) Null input string.
      2) Input string empty.
      
   */
   prsdp_c ( NULLCPTR, &dpval );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   prsdp_c ( "", &dpval );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );

   

   /*
   iswhsp_c tests:
   */
   tcase_c ( "Test iswhsp_c" );
   

   iswhite = iswhsp_c ( "not a white space string" );
   
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "iswhite", iswhite, SPICEFALSE, ok );
   
   
   iswhite = iswhsp_c ( " " );
   
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "iswhite", iswhite, SPICETRUE, ok );
   
   
   iswhite = iswhsp_c ( "" );
   
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "iswhite", iswhite, SPICETRUE, ok );
   
   
   iswhite = iswhsp_c ( "\f" );
   
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "iswhite", iswhite, SPICETRUE, ok );
   
   
   iswhite = iswhsp_c ( "\f\n\r\t\v" );
   
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "iswhite", iswhite, SPICETRUE, ok );
   
   
   /*
   Check iswhsp_c string error case:
   
      1) Null input string.
      
   */
   iswhite = iswhsp_c ( NULLCPTR );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   chcksl_c ( "iswhite", iswhite, SPICEFALSE, ok );




   /*
   lastnb_c tests:
   */
   tcase_c ( "Test lastnb_c" );
   

   last = lastnb_c ( "one two" );
   
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "last", last, "=", 6, 0, ok );


   last = lastnb_c ( "one two  " );
   
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "last", last, "=", 6, 0, ok );



   last = lastnb_c ( " " );
   
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "last", last, "=", -1, 0, ok );



   last = lastnb_c ( "" );
   
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "last", last, "=", -1, 0, ok );




   /*
   Check lastnb_c string error case:
   
      1) Null input string.
      
   */
   last = lastnb_c ( NULLCPTR );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   chcksi_c ( "last", last, "=", -1, 0, ok );


   /*
   eqstr_c tests:
   */
   
   tcase_c ( "test eqstr_c" );

   /*
   The following are "normal" cases.
   */

   s1[ 0] = "spud!";       s2[ 0] = "spud!";       eqexp[ 0] = T;
   s1[ 1] = "     ";       s2[ 1] = " ";           eqexp[ 1] = T;
   s1[ 2] = " S P U D ";   s2[ 2] = "spud";        eqexp[ 2] = T;
   s1[ 3] = "spud";        s2[ 3] = " S P U D ";   eqexp[ 3] = T;
   s1[ 4] = " S P U D";    s2[ 4] = "spud";        eqexp[ 4] = T;
   s1[ 5] = "spud";        s2[ 5] = " S P U D";    eqexp[ 5] = T;
   s1[ 6] = " S P U D ";   s2[ 6] = "spud ";       eqexp[ 6] = T;
   s1[ 7] = "spud ";       s2[ 7] = " S P U D ";   eqexp[ 7] = T;
   s1[ 8] = "s";           s2[ 8] = "S";           eqexp[ 8] = T;
   s1[ 9] = "s";           s2[ 9] = "t";           eqexp[ 9] = F;
   s1[10] = "spud s p am"; s2[10] = "spud";        eqexp[10] = F;
   s1[11] = "spud";        s2[11] = "spud s p am"; eqexp[11] = F;   
 

   for ( i = 0;  i < N_EQSTR;  i++ )
   {
      match = eqstr_c ( s1[i], s2[i] );
      
      chckxc_c ( SPICEFALSE, " ", ok );
      chcksl_c ( "match", match, eqexp[i], ok );
   }


   /*
   Suppose both input strings are empty...
   */
   match = eqstr_c ( "", "" );
   
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "match", match, SPICETRUE, ok );

      
   /*
   Suppose exactly one input string is empty.
   */
   match = eqstr_c ( "", "spud" );
   
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "match", match, SPICEFALSE, ok );

      
   match = eqstr_c ( "", "spud" );
   
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "match", match, SPICEFALSE, ok );



   /*
   Check eqstr_c string error cases:
   
      1) First input string is null.
      2) Second input string is null.
      
   */
   match = eqstr_c ( NULLCPTR, "spud" );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   chcksl_c ( "match", match, SPICEFALSE, ok );


   match = eqstr_c ( "spud", NULLCPTR );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   chcksl_c ( "match", match, SPICEFALSE, ok );




   /*
   lparse_c tests:
   */
   tcase_c ( "test lparse_c" );

   
   /*
   Case of nmax = 0:
   */
   lparse_c ( NULLCPTR, " ", 0, 0, &n, items );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "n", n, "=", 0, 0, ok );


   /*
   Null pointer errors:
   */
   lparse_c ( NULLCPTR, " ", 1, TOKLEN, &n, (void *)items );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   
   lparse_c ( "a, b", NULLCPTR, 1, TOKLEN, &n, (void *)items );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   
   lparse_c ( "a, b", ",", 1, TOKLEN, &n, (void *)0 );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   
   
   /*
   Delimiter string empty:
   */
   lparse_c ( "a, b", "", 1, TOKLEN, &n, (void *)items );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );
   

   /*
   Output string too short:
   */
   lparse_c ( "a, b", ",", 1, 1, &n, (void *)items );
   chckxc_c ( SPICETRUE, "SPICE(STRINGTOOSHORT)", ok );
   

   /*
   Input string empty (not an error):
   */
   lparse_c ( "", ",", 1, TOKLEN, &n, (void *)items );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "n", n, "=", 1, 0, ok );
   assert   ( strlen(items[0]) == 0 );
   
      
   /*
   Input string blank (not an error):
   */
   lparse_c ( " ", ",", 1, TOKLEN, &n, (void *)items );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "n", n, "=", 1, 0, ok );
   assert   ( strlen(items[0]) == 0 );
   
      
   /*
   Normal case "a, b, c":
   */
   lparse_c ( "a, b, c", ",", 3, TOKLEN, &n, (void *)items );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "n", n, "=", 3, 0, ok );
   
   chcksc_c ( "item 0", items[0], "=", "a", ok );
   chcksc_c ( "item 1", items[1], "=", "b", ok );
   chcksc_c ( "item 2", items[2], "=", "c", ok );

   
      
   /*
   Normal case "a, ,c":
   */
   lparse_c ( "a, , c", ",", 3, TOKLEN, &n, (void *)items );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "n", n, "=", 3, 0, ok );
   
   chcksc_c ( "item 0", items[0], "=", "a", ok );
   assert   ( strlen(items[1]) == 0 );
   chcksc_c ( "item 2", items[2], "=", "c", ok );

   
   /*
   Normal case "spud, spam", TOKLEN = 4:
   */
   lparse_c ( "spud, spam", ",", 1, 4, &n, (void *)items );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "n", n, "=", 1, 0, ok );
   
   chcksc_c ( "item 0", items[0], "=", "spu", ok );
   
   
      
   /*
   Normal case "spud, spam":
   */
   lparse_c ( "spud, spam", ",", 2, TOKLEN, &n, (void *)items );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "n", n, "=", 2, 0, ok );
   
   chcksc_c ( "item 0", items[0], "=", "spud", ok );
   chcksc_c ( "item 1", items[1], "=", "spam", ok );
   
   
      
   /*
   Normal case ",,":
   */
   lparse_c ( ",,", ",", 3, TOKLEN, &n, (void *)items );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "n", n, "=", 3, 0, ok );
   
   assert   ( strlen(items[0]) == 0 );
   assert   ( strlen(items[1]) == 0 );
   assert   ( strlen(items[2]) == 0 );




   /*
   lparsm_c tests:
   */
   tcase_c ( "test lparsm_c" );

   
   /*
   Case of nmax = 0:
   */
   lparsm_c ( NULLCPTR, " ", 0, TOKLEN, &n, items );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "n", n, "=", 0, 0, ok );


   /*
   Null pointer errors:
   */
   lparsm_c ( NULLCPTR, " ", 1, TOKLEN, &n, (void *)items );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   
   lparsm_c ( "a, b", NULLCPTR, 1, TOKLEN, &n, (void *)items );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   
   lparsm_c ( "a, b", ",", 1, TOKLEN, &n, (void *)0 );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   
   
   /*
   Delimiter string empty:
   */
   lparsm_c ( "a, b", "", 1, TOKLEN, &n, (void *)items );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );
   

   /*
   Output string too short:
   */
   lparsm_c ( "a, b", ",", 1, 1, &n, (void *)items );
   chckxc_c ( SPICETRUE, "SPICE(STRINGTOOSHORT)", ok );
   

   /*
   Input string empty (not an error):
   */
   lparsm_c ( "", ",", 1, TOKLEN, &n, (void *)items );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "n", n, "=", 1, 0, ok );
   assert   ( strlen(items[0]) == 0 );
   
      
   /*
   Input string blank (not an error):
   */
   lparsm_c ( " ", ",", 1, TOKLEN, &n, (void *)items );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "n", n, "=", 1, 0, ok );
   assert   ( strlen(items[0]) == 0 );
         
   /*
   Normal cases:
   */
   tcase_c  ( "lparsm_c normal case:  list = 'a, b, c' " );

   lparsm_c ( "a, b, c", ",", 3, TOKLEN, &n, (void *)items );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "n", n, "=", 3, 0, ok );
   
   chcksc_c ( "item 0", items[0], "=", "a", ok );
   chcksc_c ( "item 1", items[1], "=", "b", ok );
   chcksc_c ( "item 2", items[2], "=", "c", ok );



   tcase_c  ( "lparsm_c normal case:  list = 'a, b  c' " );

   lparsm_c ( "a, b  c", ", ", 3, TOKLEN, &n, (void *)items );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "n", n, "=", 3, 0, ok );
   
   chcksc_c ( "item 0", items[0], "=", "a", ok );
   chcksc_c ( "item 1", items[1], "=", "b", ok );
   chcksc_c ( "item 2", items[2], "=", "c", ok );


   tcase_c  ( "lparsm_c normal case:  list = 'a, b  c+d' " );

   lparsm_c ( "a, b  c+d", ", +", 4, TOKLEN, &n, (void *)items );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "n", n, "=", 4, 0, ok );
   
   chcksc_c ( "item 0", items[0], "=", "a", ok );
   chcksc_c ( "item 1", items[1], "=", "b", ok );
   chcksc_c ( "item 2", items[2], "=", "c", ok );
   chcksc_c ( "item 3", items[3], "=", "d", ok );
   
      
   /*
   Normal case "a, ,c":
   */
   lparsm_c ( "a, , c", ",", 3, TOKLEN, &n, (void *)items );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "n", n, "=", 3, 0, ok );
   
   chcksc_c ( "item 0", items[0], "=", "a", ok );
   assert   ( strlen(items[1]) == 0 );
   chcksc_c ( "item 2", items[2], "=", "c", ok );

   
   /*
   Normal case "spud, spam", TOKLEN = 4:
   */
   lparsm_c ( "spud, spam", ",", 1, 4, &n, (void *)items );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "n", n, "=", 1, 0, ok );
   
   chcksc_c ( "item 0", items[0], "=", "spu", ok );
   
   
      
   /*
   Normal case "spud  spam":
   */
   lparsm_c ( "spud spam", " ", 2, TOKLEN, &n, (void *)items );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "n", n, "=", 2, 0, ok );
   
   chcksc_c ( "item 0", items[0], "=", "spud", ok );
   chcksc_c ( "item 1", items[1], "=", "spam", ok );
   
   
      
   /*
   Normal case ",,":
   */
   lparsm_c ( ",,", ",", 3, TOKLEN, &n, (void *)items );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "n", n, "=", 3, 0, ok );
   
   assert   ( strlen(items[0]) == 0 );
   assert   ( strlen(items[1]) == 0 );
   assert   ( strlen(items[2]) == 0 );





   /*
   lparss_c tests:
   */
   tcase_c ( "test lparss_c: error cases" );


   /*
   Set type mismatch: 
   */
   tcase_c ( "test lparss_c: set type mismatch" );
   lparss_c ( "a, b", ",", &intset );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );


   /*
   Null pointer errors:
   */
   tcase_c ( "test lparss_c: null list pointer" );
   lparss_c ( NULLCPTR, " ",  &tokset );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   
   tcase_c ( "test lparss_c: null delims pointer" );
   lparss_c ( "a, b", NULLCPTR, &tokset );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
  
   
   /*
   Delimiter string empty:
   */
   tcase_c ( "test lparss_c: empty delims string" );
   lparss_c ( "a, b", "", &tokset );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );
   
   

   /*
   Input string empty (not an error):
   */
   lparss_c ( "", ",", &tokset );
   chckxc_c ( SPICEFALSE, " ", ok );

   n = card_c(&tokset);
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "card_c(&set)", n, "=", 1, 0, ok );
   
      
   /*
   Input string blank (not an error):
   */
   lparss_c ( " ", ",", &tokset );
   chckxc_c ( SPICEFALSE, " ", ok );

   n = card_c(&tokset);
   chckxc_c ( SPICEFALSE, " ", ok );

         
   /*
   Normal cases:
   */
   tcase_c  ( "lparss_c normal case:  list = 'a, b, c' " );

   lparss_c ( "a, b, c", ",", &tokset );
   chckxc_c ( SPICEFALSE, " ", ok );

   n = card_c(&tokset);
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "n", n, "=", 3, 0, ok );
   
   chcksc_c ( "item 0", SPICE_CELL_ELEM_C(&tokset,0), "=", "a", ok );
   chcksc_c ( "item 1", SPICE_CELL_ELEM_C(&tokset,1), "=", "b", ok );
   chcksc_c ( "item 2", SPICE_CELL_ELEM_C(&tokset,2), "=", "c", ok );


   tcase_c  ( "lparss_c normal case:  list = 'a, b  c' " );

   lparss_c ( "a, b  c", ", ", &tokset );
   chckxc_c ( SPICEFALSE, " ", ok );

   n = card_c(&tokset);
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "n", n, "=", 3, 0, ok );
   
   chcksc_c ( "item 0", SPICE_CELL_ELEM_C(&tokset,0), "=", "a", ok );
   chcksc_c ( "item 1", SPICE_CELL_ELEM_C(&tokset,1), "=", "b", ok );
   chcksc_c ( "item 2", SPICE_CELL_ELEM_C(&tokset,2), "=", "c", ok );



   tcase_c  ( "lparss_c normal case:  list = 'a, b  c+d' " );

   lparss_c ( "a, b  c+d", ", +", &tokset );
   chckxc_c ( SPICEFALSE, " ", ok );

   n = card_c(&tokset);
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "n", n, "=", 4, 0, ok );
   
   chcksc_c ( "item 0", SPICE_CELL_ELEM_C(&tokset,0), "=", "a", ok );
   chcksc_c ( "item 1", SPICE_CELL_ELEM_C(&tokset,1), "=", "b", ok );
   chcksc_c ( "item 2", SPICE_CELL_ELEM_C(&tokset,2), "=", "c", ok );
   chcksc_c ( "item 3", SPICE_CELL_ELEM_C(&tokset,3), "=", "d", ok );
   
      
   /*
   Normal case "a, ,c":
   */
   tcase_c  ( "lparss_c normal case:  list = 'a, ,c' " );
   lparss_c ( "a, , c", ",", &tokset );
   chckxc_c ( SPICEFALSE, " ", ok );

   n = card_c(&tokset);
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "n", n, "=", 3, 0, ok );

   assert   ( strlen( SPICE_CELL_ELEM_C(&tokset,0) ) == 0 );
   
   chcksc_c ( "item 0", SPICE_CELL_ELEM_C(&tokset,1), "=", "a", ok );

   chcksc_c ( "item 2", SPICE_CELL_ELEM_C(&tokset,2), "=", "c", ok );
   

   /*
   Normal case "spud, spam", TOKLEN = 4:
   */
   tcase_c  ( "lparss_c normal case:  list = 'silliest, spam' " );
   lparss_c ( "silliest, spam", ",", &shortset );
   chckxc_c ( SPICEFALSE, " ", ok );

   n = card_c(&shortset);
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "n", n, "=", 2, 0, ok );
   
   chcksc_c ( "item 2", SPICE_CELL_ELEM_C(&shortset,0), "=", "silli", ok );
   
   
      
   /*
   Normal case "spud  spam":
   */
   tcase_c  ( "lparss_c normal case:  list = 'spud spam' " );
   lparss_c ( "spud spam", " ", &tokset );
   chckxc_c ( SPICEFALSE, " ", ok );

   n = card_c(&tokset);
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "n", n, "=", 2, 0, ok );
   
   chcksc_c ( "item 0", SPICE_CELL_ELEM_C(&tokset,0), "=", "spam", ok );
   chcksc_c ( "item 0", SPICE_CELL_ELEM_C(&tokset,1), "=", "spud", ok );
   
         
   /*
   Normal case ",,":
   */
   tcase_c  ( "lparss_c normal case:  list = ',,' " );
   lparss_c ( ",,", ",", &tokset );
   chckxc_c ( SPICEFALSE, " ", ok );

   n = card_c(&tokset);
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "n", n, "=", 1, 0, ok );
   
   assert   ( strlen( SPICE_CELL_ELEM_C(&tokset,0) )  == 0 );
 





   /*
   namfrm_c and frmnam_c tests:
   */
   tcase_c ( "test namfrm_c and frmnam_c" );

   
   /*
   Normal case:  get the code for IAU_EARTH, then convert back: 
   */
   namfrm_c ( "IAU_EARTH", &frcode );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "Code for IAU_EARTH", frcode, "=", 10013, 0, ok );
   

   frmnam_c ( frcode, FRNMLN, frname );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksc_c ( "frname for code 10013", frname, "=", "IAU_EARTH", ok );

   /*
   Unrecognized frame name, unrecognized frame code: 
   */
   namfrm_c ( "XXX", &frcode );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "Code for unrecognized name", frcode, "=", 0, 0, ok );

   frmnam_c ( -987654321, FRNMLN, frname );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "Name length for unrecognized code", 
              strlen(frname), 
              "=", 
              0,
              0,
              ok                                 );

   /*
   Output string truncated on right: 
   */
   namfrm_c ( "IAU_EARTH", &frcode );
   chckxc_c ( SPICEFALSE, " ", ok );
   frmnam_c ( frcode, 4, frname );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksc_c ( "Truncated name for code 10013", frname, "=", "IAU", ok );


   /*
   Null pointer errors:
   */
   namfrm_c ( (char *)0, &frcode );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   frmnam_c ( 1, FRNMLN, (char *)0 );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   /*
   Input string has length 0: 
   */
   namfrm_c ( "", &frcode );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );

   /*
   Output string has length 1: 
   */
   frmnam_c ( 1, 1, frname );
   chckxc_c ( SPICETRUE, "SPICE(STRINGTOOSHORT)", ok );

   /*
   Output string has length 0: 
   */
   frmnam_c ( 1, 1, frname );
   chckxc_c ( SPICETRUE, "SPICE(STRINGTOOSHORT)", ok );


   /*
   namfrm_c and frmnam_c tests:
   */
   tcase_c ( "test namfrm_c and frmnam_c" );

   
   /*
   Normal case:  get the code for IAU_EARTH, then convert back: 
   */
   namfrm_c ( "IAU_EARTH", &frcode );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "Code for IAU_EARTH", frcode, "=", 10013, 0, ok );
   

   frmnam_c ( frcode, FRNMLN, frname );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksc_c ( "frname for code 10013", frname, "=", "IAU_EARTH", ok );

   /*
   Unrecognized frame name, unrecognized frame code: 
   */
   namfrm_c ( "XXX", &frcode );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "Code for unrecognized name", frcode, "=", 0, 0, ok );

   frmnam_c ( -987654321, FRNMLN, frname );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "Name length for unrecognized code", 
              strlen(frname), 
              "=", 
              0,
              0,
              ok                                 );

   /*
   Output string truncated on right: 
   */
   namfrm_c ( "IAU_EARTH", &frcode );
   chckxc_c ( SPICEFALSE, " ", ok );
   frmnam_c ( frcode, 4, frname );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksc_c ( "Truncated name for code 10013", frname, "=", "IAU", ok );


   /*
   Null pointer errors:
   */
   namfrm_c ( (char *)0, &frcode );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   frmnam_c ( 1, FRNMLN, (char *)0 );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   /*
   Input string has length 0: 
   */
   namfrm_c ( "", &frcode );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );

   /*
   Output string has length 1: 
   */
   frmnam_c ( 1, 1, frname );
   chckxc_c ( SPICETRUE, "SPICE(STRINGTOOSHORT)", ok );

   /*
   Output string has length 0: 
   */
   frmnam_c ( 1, 1, frname );
   chckxc_c ( SPICETRUE, "SPICE(STRINGTOOSHORT)", ok );







   /*
   kxtrct_c tests:
   */
   tcase_c ( "test kxtrct_c: normal test #1 from header." );

   strcpy ( string,   "FROM 1 October 1984 12:00:00 TO 1 January 1987" );

   strcpy ( keywrd,   "TO" );

   strcpy ( terms[0], "FROM" );
   strcpy ( terms[1], "TO" );
   strcpy ( terms[2], "BEGINNING" );
   strcpy ( terms[3], "ENDING"    );

   nterms = 4;

   kxtrct_c ( keywrd, TOKLEN, terms,  nterms, 
              LNSIZE, LNSIZE, string, &found, substr  );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "found", found, SPICETRUE, ok );

   chcksc_c ( "string", string, "=", "FROM 1 October 1984 12:00:00", ok );

   chcksc_c ( "substr", substr, "=", "1 January 1987", ok );




   tcase_c ( "test kxtrct_c: normal test #2 from header." );

   strcpy ( string,   "FROM 1 October 1984 12:00:00 TO 1 January 1987" );

   strcpy ( keywrd,   "FROM" );

   strcpy ( terms[0], "FROM" );
   strcpy ( terms[1], "TO" );
   strcpy ( terms[2], "BEGINNING" );
   strcpy ( terms[3], "ENDING"    );

   nterms = 4;

   kxtrct_c ( keywrd, TOKLEN, terms,  nterms, 
              LNSIZE, LNSIZE, string, &found, substr  );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "found", found, SPICETRUE, ok );

   chcksc_c ( "string", string, "=", " TO 1 January 1987", ok );

   chcksc_c ( "substr", substr, "=", "1 October 1984 12:00:00", ok );





   tcase_c ( "test kxtrct_c: normal test #3 from header." );

   strcpy ( string,   "ADDRESS: 4800 OAK GROVE DRIVE PHONE: 354-4321 " );

   strcpy ( keywrd,   "ADDRESS:" );

   strcpy ( terms[0], "ADDRESS:" );
   strcpy ( terms[1], "PHONE:"   );
   strcpy ( terms[2], "NAME:"    );

   nterms = 3;

   kxtrct_c ( keywrd, TOKLEN, terms,  nterms, 
              LNSIZE, LNSIZE, string, &found, substr  );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "found", found, SPICETRUE, ok );

   chcksc_c ( "string", string, "=", " PHONE: 354-4321", ok );

   chcksc_c ( "substr", substr, "=", "4800 OAK GROVE DRIVE", ok );



   tcase_c ( "test kxtrct_c: normal test #4 from header." );

   strcpy ( string,   "ADDRESS: 4800 OAK GROVE DRIVE PHONE: 354-4321 " );

   strcpy ( keywrd,   "NAME:" );

   strcpy ( terms[0], "ADDRESS:" );
   strcpy ( terms[1], "PHONE:"   );
   strcpy ( terms[2], "NAME:"    );

   nterms = 3;

   kxtrct_c ( keywrd, TOKLEN, terms,  nterms, 
              LNSIZE, LNSIZE, string, &found, substr  );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "found", found, SPICEFALSE, ok );

   chcksc_c ( "string", string, "=", 
              "ADDRESS: 4800 OAK GROVE DRIVE PHONE: 354-4321", ok );

   assert   ( strlen(substr) == 0 );


   /*
   Error cases: 
   */

   tcase_c ( "test kxtrct_c: null keyword pointer." );
   
   kxtrct_c ( NULLCPTR, TOKLEN, terms,  nterms, 
              LNSIZE,   LNSIZE, string, &found, substr  );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );


   tcase_c ( "test kxtrct_c: null terms pointer." );
   kxtrct_c ( keywrd,   TOKLEN, NULLCPTR,  nterms, 
              LNSIZE,   LNSIZE, string,    &found, substr  );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   
   tcase_c ( "test kxtrct_c: null string pointer." );
   kxtrct_c ( keywrd,   TOKLEN, terms,     nterms, 
              LNSIZE,   LNSIZE, NULLCPTR,  &found, substr  );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );


   tcase_c ( "test kxtrct_c: null substring pointer." );
   kxtrct_c ( keywrd,   TOKLEN, terms,   nterms, 
              LNSIZE,   LNSIZE, string,  &found, NULLCPTR );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );


   /*
   Other string errors: 
   */   
   tcase_c ( "test kxtrct_c: keyword string empty." );
   
   kxtrct_c ( "",       TOKLEN, terms,   nterms, 
              LNSIZE,   LNSIZE, string,  &found, substr );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );
   
   tcase_c ( "test kxtrct_c: terms string too short." );
   kxtrct_c ( keywrd,   1,       terms,   nterms, 
              LNSIZE,   TOKLEN,  string,  &found, substr );
   chckxc_c ( SPICETRUE, "SPICE(STRINGTOOSHORT)", ok );
   
   tcase_c ( "test kxtrct_c: string too short." );
   kxtrct_c ( keywrd,   TOKLEN,  terms,   nterms, 
              1,        TOKLEN, string,  &found, substr );
   chckxc_c ( SPICETRUE, "SPICE(STRINGTOOSHORT)", ok );

   tcase_c ( "test kxtrct_c: substring too short." );
   kxtrct_c ( keywrd,   TOKLEN,  terms,   nterms, 
              LNSIZE,   1,       string,  &found, substr );
   chckxc_c ( SPICETRUE, "SPICE(STRINGTOOSHORT)", ok );


   /*
   Retrieve the current test status.
   */ 
   t_success_c ( ok ); 
   
   
} /* End f_st01_c */



