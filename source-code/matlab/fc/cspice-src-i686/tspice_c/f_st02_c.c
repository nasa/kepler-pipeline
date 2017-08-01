/*

-Procedure f_st02_c ( Test wrappers for string routines, subset 02 )

 
-Abstract
 
   Perform tests on CSPICE "replace marker" wrappers.
    
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
   

   void f_st02_c ( SpiceBoolean * ok )

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
      
      repmi_c
      repmc_c
      repmct_c
      repmd_c
      repmf_c
      repmot_c
   
-Examples
 
   None.
    
-Restrictions
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
 
-Literature_References
 
   None. 
 
-Version
 
   -tspice_c Version 1.0.0 14-AUG-2002 (NJB)


-&
*/

{ /* Begin f_st02_c */

 
   /*
   Constants
   */
   
   #define LNSIZE          201
   #define LENOUT          LNSIZE
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
   SpiceChar             * chance = "fair";

   SpiceChar               in        [ LNSIZE ];
   SpiceChar               marker    [ LNSIZE ];
   SpiceChar               msg       [ LNSIZE ];
   SpiceChar               out       [ LNSIZE ];

   SpiceDouble             score;

   SpiceInt                l1;
   SpiceInt                l2 ;
   SpiceInt                num;



   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_st02_c" );
   

   
   
   /*
   repmi_c tests:
   */
   tcase_c ( "Test repmi_c:  case 1 from the header." );
 

   strcpy ( in, "Invalid operation value.  The value was <opcode>." );
    
   repmi_c ( in, "<opcode>", 5, LNSIZE, out );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksc_c ( "out", 
               out, 
              "=", 
              "Invalid operation value.  The value was 5.", 
               ok                                          );




   tcase_c ( "Test repmi_c:  case 2 from the header." );
 

   strcpy ( in, "Left endpoint exceeded right endpoint.  "
                "The left endpoint was:  XX.  The right "
                "endpoint was:  XX."                     );
    
   repmi_c ( in, "  XX  ", 5, LENOUT, out );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksc_c ( "out", 
               out, 
              "=", 
              "Left endpoint exceeded right endpoint.  The left " 
              "endpoint was:  5.  The right endpoint was:  XX.",
               ok                                                );




   tcase_c ( "Test repmi_c:  case 3 from the header." );
 

   strcpy ( msg, "There are & routines that have a "  
                 "& chance of meeting your needs.  "    
                 "The maximum score was &."          ); 
    
   strcpy ( marker, "&" );

   num   =  23;
   score =   4.665;

   repmi_c ( msg, marker, num, LENOUT, msg );

   chckxc_c ( SPICEFALSE, " ", ok );
 
   repmc_c ( msg, marker, chance, LENOUT, msg );
   chckxc_c ( SPICEFALSE, " ", ok );
 
   repmf_c ( msg, marker, score,  4, 'f', LENOUT, msg ); 
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksc_c ( "msg", 
               msg, 
              "=", 
              "There are 23 routines that have a fair chance of "
              "meeting your needs.  The maximum score was 4.665.",
               ok                                                  );



   tcase_c ( "repmi_c test:  input string is empty." );
   repmi_c  ( "", "<opcode>", 5, LNSIZE, out );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "strlen(out)", strlen(out), "=", 0, 0, ok );



   tcase_c ( "repmi_c test:  marker string is empty." );

   repmi_c  ( in, "", 5, LNSIZE, out );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksc_c ( "out", out, "=", in, ok );


   tcase_c ( "repmi_c test:  marker string is blank." );

   repmi_c  ( in, " ", 5, LNSIZE, out );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksc_c ( "out", out, "=", in, ok );


   tcase_c ( "repmi_c test:  output string is truncated." );

   strcpy ( in, "Invalid operation value.  The value was <opcode>." );

   repmi_c  ( in, " ", 5, SHORT, out );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksc_c ( "out", out, "=", "Inva", ok );


   tcase_c ( "repmi_c test:  output string has length 1." );

   repmi_c  ( in, " ", 5, 1, out );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "strlen(out)", strlen(out), "=", 0, 0, ok );



   /*
   Check repmi_c string error cases:
   
      1) Null string pointers.
      2) Empty input string.
      3) Null template string.
      4) Empty template string.
      
   */

   tcase_c ( "repmi_c test:  input string has null pointer" );

   repmi_c  ( NULLCPTR, "<opcode>", 5, LNSIZE, out );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );


   tcase_c ( "repmi_c test:  marker string has null pointer" );

   repmi_c  ( "x", NULLCPTR, 5, LNSIZE, out );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
    

   tcase_c ( "repmi_c test:  output string has null pointer" );

   repmi_c  ( "x", "*", 5, LNSIZE, NULLCPTR );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
    

   tcase_c ( "repmi_c test:  output string is too short" );

   repmi_c  ( "x", "*", 5, 0, out );
   chckxc_c ( SPICETRUE, "SPICE(STRINGTOOSHORT)", ok );
    




      
   /*
   repmd_c: 
   */
   tcase_c ( "Test repmd_c:  case 1 from the header." );
 

   strcpy ( in, "Invalid duration value.  The value was <duration>." );
    
   repmd_c ( in, "<duration>", 5.0E+11, 2, LNSIZE, out );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksc_c ( "out", 
               out, 
              "=", 
              "Invalid duration value.  The value was 5.0E+11.", 
               ok                                               );





   tcase_c ( "Test repmd_c:  case 2 from the header." );
 

   strcpy ( in, "Left endpoint exceeded right endpoint.  "
                "The left endpoint was:  XX.  The right "
                "endpoint was:  XX."                     );
    
   repmd_c ( in, "  XX  ", -5.2e-9, 3, LENOUT, out );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksc_c ( "out", 
               out, 
              "=", 
              "Left endpoint exceeded right endpoint.  The left " 
              "endpoint was:  -5.20E-09.  The right endpoint was:  XX.",
               ok                                                       );




   tcase_c ( "Test repmd_c:  case 3 from the header." );
 

   strcpy ( msg, "There are & routines that have a "  
                 "& chance of meeting your needs.  "    
                 "The maximum score was &."          ); 
    
   strcpy ( marker, "&" );

   num   =  23;
   score =   4.665;

   repmi_c ( msg, marker, num, LENOUT, msg );

   chckxc_c ( SPICEFALSE, " ", ok );
 
   repmc_c ( msg, marker, chance, LENOUT, msg );
   chckxc_c ( SPICEFALSE, " ", ok );
 
   repmd_c ( msg, marker, score,  4, LENOUT, msg ); 
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksc_c ( "msg", 
               msg, 
              "=", 
              "There are 23 routines that have a fair chance of "
              "meeting your needs.  The maximum score was 4.665E+00.",
               ok                                                    );



   tcase_c ( "repmd_c test:  input string is empty." );
   repmd_c  ( "", "<opcode>", 5, 3, LNSIZE, out );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "strlen(out)", strlen(out), "=", 0, 0, ok );


   tcase_c ( "repmd_c test:  marker string is empty." );

   repmd_c  ( in, "", 5, 3, LNSIZE, out );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksc_c ( "out", out, "=", in, ok );


   tcase_c ( "repmd_c test:  marker string is blank." );

   repmd_c  ( in, " ", 5, 3, LNSIZE, out );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksc_c ( "out", out, "=", in, ok );


   tcase_c ( "repmd_c test:  output string is truncated." );

   strcpy ( in, "Invalid operation value.  The value was <opcode>." );

   repmd_c  ( in, " ", 5, 3, SHORT, out );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksc_c ( "out", out, "=", "Inva", ok );


   tcase_c ( "repmd_c test:  output string has length 1." );

   repmd_c  ( in, " ", 5, 3, 1, out );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "strlen(out)", strlen(out), "=", 0, 0, ok );


   /*
   Check repmd_c string error cases:
   
      1) Null string pointers.
      2) Empty input string.
      3) Null template string.
      4) Empty template string.
      
   */

   tcase_c ( "repmd_c test:  input string has null pointer" );

   repmd_c  ( NULLCPTR, "<opcode>", 5, 3, LNSIZE, out );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );


   tcase_c ( "repmd_c test:  marker string has null pointer" );

   repmd_c  ( "x", NULLCPTR, 5, 3, LNSIZE, out );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
    

   tcase_c ( "repmd_c test:  output string has null pointer" );

   repmd_c  ( "x", "*", 5, 3, LNSIZE, NULLCPTR );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
    

   tcase_c ( "repmd_c test:  output string is too short" );

   repmd_c  ( "x", "*", 5, 3, 0, out );
   chckxc_c ( SPICETRUE, "SPICE(STRINGTOOSHORT)", ok );
    





   /*
   repmf_c: 
   */
   tcase_c ( "Test repmf_c:  case 1 from the header." );
 

   strcpy ( in, "Invalid duration value.  The value was <duration>." );
    
   repmf_c ( in, "<duration>", 5.0e3, 5,  'f', LENOUT, out );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksc_c ( "out", 
               out, 
              "=", 
              "Invalid duration value.  The value was 5000.0.", 
               ok                                               );





   tcase_c ( "Test repmf_c:  case 2 from the header." );
 

   strcpy ( in, "Left endpoint exceeded right endpoint.  "
                "The left endpoint was:  XX.  The right "
                "endpoint was:  XX."                     );
    
   repmf_c ( in, "  XX  ", -5.2e-9, 3, 'e',  LENOUT, out );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksc_c ( "out", 
               out, 
              "=", 
              "Left endpoint exceeded right endpoint.  The left " 
              "endpoint was:  -5.20E-09.  The right endpoint was:  XX.",
               ok                                                       );





   tcase_c ( "Test repmf_c:  case 3 from the header." );
 

   strcpy ( in, "Invalid quantity.  The value was # units." );
    
   repmf_c ( in, "#", 5.0e1, 3, 'f', LENOUT, in );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksc_c ( "in", 
               in, 
              "=", 
              "Invalid quantity.  The value was 50.0 units.",
               ok                                                       );



   tcase_c ( "Test repmf_c:  case 4 from the header." );
 

   strcpy ( in, "Invalid quantity.  The value was # units." );
    
   repmf_c ( in, "#", 5.0e1, 1, 'f', LENOUT, in );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksc_c ( "in", 
               in, 
              "=", 
              "Invalid quantity.  The value was 50. units.",
               ok                                                       );





   tcase_c ( "Test repmf_c:  case 5 from the header." );

   strcpy ( in, "Invalid duration value.  The value was #." );
    
   repmf_c ( in, "#", 5.0e1, 100, 'e', LENOUT, in );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksc_c ( "in", 
               in, 
              "=", 
              "Invalid duration value.  The value was "
              "5.0000000000000E+01.", 
               ok                                         );




   tcase_c ( "Test repmf_c:  case 6 from the header." );
 

   strcpy ( msg, "There are & routines that have a "  
                 "& chance of meeting your needs.  "    
                 "The maximum score was &."          ); 
    
   num    =  23;
   score  =   4.665;
   strcpy ( marker, "&" );

 

   repmi_c ( "There are & routines that have a "  
             "& chance of meeting your needs.  "    
             "The maximum score was &.", 
             marker, 
             num, 
             LENOUT,
             msg                                  );

   chckxc_c ( SPICEFALSE, " ", ok );

   repmc_c ( msg, marker, chance,        LENOUT, msg );
   chckxc_c ( SPICEFALSE, " ", ok );

   repmf_c ( msg, marker, score, 4, 'f', LENOUT, msg );
   chckxc_c ( SPICEFALSE, " ", ok );
 
   chcksc_c ( "msg", 
               msg, 
              "=", 
              "There are 23 routines that have a fair chance of "
              "meeting your needs.  The maximum score was 4.665.",
               ok                                                    );

   tcase_c ( "repmf_c test:  input string is empty." );
   repmf_c  ( "", "<opcode>", 5, 3, 'e', LNSIZE, out );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "strlen(out)", strlen(out), "=", 0, 0, ok );


   tcase_c ( "repmf_c test:  marker string is empty." );

   /*
   Make sure trailing blanks are trimmed. 
   */
   strcpy ( in, "Invalid duration value.  The value was #.     " );
   l1 = strlen(in);

   repmf_c  ( in, "", 5, 3,  'f', LNSIZE, out );
   chckxc_c ( SPICEFALSE, " ", ok );

   l2 = strlen(out);

   chcksc_c ( "out", out, "=", in, ok );

   chcksi_c ( "strlen(out)", l2, "=", l1-5, 0, ok );



   tcase_c ( "repmf_c test:  marker string is blank." );

   strcpy ( in, "Invalid duration value.  The value was #.       " );
   repmf_c  ( in, " ", 5, 3,  'E', LNSIZE, out );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksc_c ( "out", out, "=", in, ok );


   tcase_c ( "repmf_c test:  output string is truncated." );

   strcpy ( in, "Invalid operation value.  The value was <opcode>." );

   repmf_c  ( in, " ", 5, 3, 'F', SHORT, out );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksc_c ( "out", out, "=", "Inva", ok );


   tcase_c ( "repmf_c test:  output string has length 1." );

   repmf_c  ( in, " ", 5, 3,  'e', 1, out );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "strlen(out)", strlen(out), "=", 0, 0, ok );


   /*
   Check repmf_c string error cases:
   
      1) Null string pointers.
      2) Empty input string.
      3) Null template string.
      4) Empty template string.
      
   */

   tcase_c ( "repmf_c test:  input string has null pointer" );

   repmf_c  ( NULLCPTR, "<opcode>", 5, 3, 'e',  LNSIZE, out );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );



   tcase_c ( "repmf_c test:  marker string has null pointer" );

   repmf_c  ( "x", NULLCPTR, 5, 3,  'e', LNSIZE, out );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
    

   tcase_c ( "repmf_c test:  output string has null pointer" );

   repmf_c  ( "x", "*", 5, 3,  'e', LNSIZE, NULLCPTR );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
    

   tcase_c ( "repmf_c test:  output string is too short" );

   repmf_c  ( "x", "*", 5, 3,  'e', 0, out );
   chckxc_c ( SPICETRUE, "SPICE(STRINGTOOSHORT)", ok );
    
   

   /*
   repmct_c: 
   */
   tcase_c ( "Test repmct_c:  case 1 from the header." );
 

   strcpy ( in, "Invalid command.  Word # was not recognized." );
    
   repmct_c ( in, "#", 5, 'U', LENOUT, in );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksc_c ( "in", 
               in, 
              "=", 
              "Invalid command.  Word FIVE was not recognized.", 
               ok                                               );



   tcase_c ( "Test repmct_c:  case 2 from the header." );
 

   strcpy ( in, "Word XX of the XX sentence was misspelled." );
    
   repmct_c ( in, "  XX  ", 5, 'L', LENOUT, out );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksc_c ( "out", 
               out, 
              "=", 
              "Word five of the XX sentence was misspelled.",
               ok                                             );




   tcase_c ( "Test repmct_c:  case 3 from the header." );
 

   strcpy ( in, "Name:  YY.  Rank:  XX." );
    
   repmc_c  ( in,  "YY", "Moriarty", LENOUT, out );
   repmct_c ( out, "XX",  1,  'C',   LENOUT, out );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksc_c ( "our", 
               out, 
              "=", 
              "Name:  Moriarty.  Rank:  One.",
               ok                                              );



   tcase_c ( "repmct_c test:  input string is empty." );

   repmct_c  ( "", "<opcode>", 5, 'c', LNSIZE, out );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "strlen(out)", strlen(out), "=", 0, 0, ok );


   tcase_c ( "repmct_c test:  marker string is empty." );

   /*
   Make sure trailing blanks are trimmed. 
   */
   strcpy ( in, "Invalid duration value.  The value was #.     " );
   l1 = strlen(in);

   repmct_c  ( in, "", 5,  'l', LNSIZE, out );
   chckxc_c ( SPICEFALSE, " ", ok );

   l2 = strlen(out);

   chcksc_c ( "out", out, "=", in, ok );

   chcksi_c ( "strlen(out)", l2, "=", l1-5, 0, ok );



   tcase_c ( "repmct_c test:  marker string is blank." );

   strcpy ( in, "Invalid duration value.  The value was #.       " );
   repmct_c  ( in, " ", 5, 'u', LNSIZE, out );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksc_c ( "out", out, "=", in, ok );


   tcase_c ( "repmct_c test:  output string is truncated." );

   strcpy ( in, "Invalid operation value.  The value was <opcode>." );

   repmct_c  ( in, " ", 5, 'C', SHORT, out );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksc_c ( "out", out, "=", "Inva", ok );


   tcase_c ( "repmct_c test:  output string has length 1." );

   repmct_c  ( in, " ", 5, 'L', 1, out );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "strlen(out)", strlen(out), "=", 0, 0, ok );


   /*
   Check repmct_c string error cases:
   
      1) Null string pointers.
      2) Empty input string.
      3) Null template string.
      4) Empty template string.
      
   */

   tcase_c ( "repmct_c test:  input string has null pointer" );

   repmct_c  ( NULLCPTR, "<opcode>", 5, 'u',  LNSIZE, out );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );


   tcase_c ( "repmct_c test:  marker string has null pointer" );

   repmct_c  ( "x", NULLCPTR, 5, 'c', LNSIZE, out );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
    

   tcase_c ( "repmct_c test:  output string has null pointer" );

   repmct_c  ( "x", "*", 5, 'l', LNSIZE, NULLCPTR );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
    

   tcase_c ( "repmct_c test:  output string is too short" );

   repmct_c  ( "x", "*", 5,  'U', 0, out );
   chckxc_c ( SPICETRUE, "SPICE(STRINGTOOSHORT)", ok );
    
   /*
   Extra error case: invalid string case specifier. 
   */
   tcase_c ( "repmct_c test:  case specifier is not recognized." );

   repmct_c  ( "x", "*", 5,  'x', LENOUT, out );
   chckxc_c ( SPICETRUE, "SPICE(INVALIDCASE)", ok );



   /*
   repmot_c: 
   */
   tcase_c ( "Test repmot_c:  case 1 from the header." );
 

   strcpy ( in, "Invalid command.  The # word was not recognized." );
    
   repmot_c ( in, "#", 5, 'U', LENOUT, in );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksc_c ( "in", 
               in, 
              "=", 
              "Invalid command.  The FIFTH word was not recognized.", 
               ok                                               );






   tcase_c ( "Test repmot_c:  case 2 from the header." );
 

   strcpy ( in, "The XX word of the XX sentence was misspelled." );
    
   repmot_c ( in, "  XX  ", 5, 'L', LENOUT, out );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksc_c ( "out", 
               out, 
              "=", 
              "The fifth word of the XX sentence was misspelled.",
               ok                                                       );





   tcase_c ( "Test repmot_c:  case 3 from the header." );
 

   strcpy ( in, "Name:  YY.  Rank:  XX." );
    
   repmc_c  ( in,  "YY", "Moriarty", LENOUT, out );
   repmot_c ( out, "XX",  1,  'C',   LENOUT, out );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksc_c ( "our", 
               out, 
              "=", 
              "Name:  Moriarty.  Rank:  First.",
               ok                                              );



   tcase_c ( "repmot_c test:  input string is empty." );

   repmot_c  ( "", "<opcode>", 5, 'c', LNSIZE, out );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "strlen(out)", strlen(out), "=", 0, 0, ok );


   tcase_c ( "repmot_c test:  marker string is empty." );

   /*
   Make sure trailing blanks are trimmed. 
   */
   strcpy ( in, "Invalid duration value.  The value was #.     " );
   l1 = strlen(in);

   repmot_c  ( in, "", 5,  'l', LNSIZE, out );
   chckxc_c ( SPICEFALSE, " ", ok );

   l2 = strlen(out);

   chcksc_c ( "out", out, "=", in, ok );

   chcksi_c ( "strlen(out)", l2, "=", l1-5, 0, ok );



   tcase_c ( "repmot_c test:  marker string is blank." );

   strcpy ( in, "Invalid duration value.  The value was #.       " );
   repmot_c  ( in, " ", 5, 'u', LNSIZE, out );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksc_c ( "out", out, "=", in, ok );


   tcase_c ( "repmot_c test:  output string is truncated." );

   strcpy ( in, "Invalid operation value.  The value was <opcode>." );

   repmot_c  ( in, " ", 5, 'C', SHORT, out );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksc_c ( "out", out, "=", "Inva", ok );


   tcase_c ( "repmot_c test:  output string has length 1." );

   repmot_c  ( in, " ", 5, 'L', 1, out );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "strlen(out)", strlen(out), "=", 0, 0, ok );


   /*
   Check repmot_c string error cases:
   
      1) Null string pointers.
      2) Empty input string.
      3) Null template string.
      4) Empty template string.
      
   */

   tcase_c ( "repmot_c test:  input string has null pointer" );

   repmot_c  ( NULLCPTR, "<opcode>", 5, 'u',  LNSIZE, out );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );


   tcase_c ( "repmot_c test:  marker string has null pointer" );

   repmot_c  ( "x", NULLCPTR, 5, 'c', LNSIZE, out );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
    

   tcase_c ( "repmot_c test:  output string has null pointer" );

   repmot_c  ( "x", "*", 5, 'l', LNSIZE, NULLCPTR );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
    

   tcase_c ( "repmot_c test:  output string is too short" );

   repmot_c  ( "x", "*", 5,  'U', 0, out );
   chckxc_c ( SPICETRUE, "SPICE(STRINGTOOSHORT)", ok );
    
   /*
   Extra error case: invalid string case specifier. 
   */
   tcase_c ( "repmot_c test:  case specifier is not recognized." );

   repmot_c  ( "x", "*", 5,  'x', LENOUT, out );
   chckxc_c ( SPICETRUE, "SPICE(INVALIDCASE)", ok );

 
   /*
   repmc_c: 
   */
   tcase_c ( "Test repmc_c:  case 1 from the header." );
 

   strcpy ( in, "Invalid operation value.  The value was:  <#>." );
    
   repmc_c ( in, "#", "append", LENOUT, in );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksc_c ( "in", 
               in, 
              "=", 
              "Invalid operation value.  The value was:  <append>.", 
               ok                                                    );



   tcase_c ( "Test repmc_c:  case 2 from the header." );
 

   strcpy ( in, "A syntax error occurred.  The token XX was not "
                "recognized.  Did you mean to say XX?"           );
    
   repmc_c ( in, "  XX  ", "  FND  ", LENOUT, out );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksc_c ( "out", 
               out, 
              "=", 
              "A syntax error occurred.  The token FND was not "
              "recognized.  Did you mean to say XX?",
               ok                                                );


   repmc_c ( out, "  XX  ", "  found  ", LENOUT, out );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksc_c ( "out", 
               out, 
              "=", 
              "A syntax error occurred.  The token FND was not "
              "recognized.  Did you mean to say found?",
               ok                                                );



   tcase_c ( "Test repmc_c:  case 3 from the header." );
 

   repmi_c ( "There are & routines that have a "  
             "& chance of meeting your needs.  "    
             "The maximum score was &.", 
             marker, 
             num, 
             LENOUT,
             msg                                  );

   chckxc_c ( SPICEFALSE, " ", ok );


   repmc_c ( msg, marker, chance,        LENOUT, msg );
   chckxc_c ( SPICEFALSE, " ", ok );

   repmf_c ( msg, marker, score, 4, 'f', LENOUT, msg );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksc_c ( "msg", 
               msg, 
              "=", 
              "There are 23 routines that have a fair chance of "
              "meeting your needs.  The maximum score was 4.665.",
               ok                                                 );





   tcase_c ( "repmc_c test:  input string is empty." );

   repmc_c  ( "", "<opcode>", "5", LNSIZE, out );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "strlen(out)", strlen(out), "=", 0, 0, ok );


   tcase_c ( "repmc_c test:  marker string is empty." );

   /*
   Make sure trailing blanks are trimmed. 
   */
   strcpy ( in, "Invalid duration value.  The value was #.     " );
   l1 = strlen(in);

   repmc_c  ( in, "", "5", LNSIZE, out );
   chckxc_c ( SPICEFALSE, " ", ok );

   l2 = strlen(out);

   chcksc_c ( "out", out, "=", in, ok );

   chcksi_c ( "strlen(out)", l2, "=", l1-5, 0, ok );



   tcase_c ( "repmc_c test:  marker string is blank." );

   strcpy ( in, "Invalid duration value.  The value was #.       " );
   repmc_c  ( in, " ", "5", LNSIZE, out );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksc_c ( "out", out, "=", in, ok );


   tcase_c ( "repmc_c test:  output string is truncated." );

   strcpy ( in, "Invalid operation value.  The value was <opcode>." );

   repmc_c  ( in, " ", "5", SHORT, out );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksc_c ( "out", out, "=", "Inva", ok );


   tcase_c ( "repmc_c test:  output string has length 1." );

   repmc_c  ( in, " ", "5", 1, out );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "strlen(out)", strlen(out), "=", 0, 0, ok );


   /*
   Check repmc_c string error cases:
   
      1) Null string pointers.
      2) Empty input string.
      3) Null template string.
      4) Empty template string.
      
   */

   tcase_c ( "repmc_c test:  input string has null pointer" );

   repmc_c  ( NULLCPTR, "<opcode>", "x", LNSIZE, out );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );


   tcase_c ( "repmc_c test:  marker string has null pointer" );

   repmc_c  ( "x", NULLCPTR, "x", LNSIZE, out );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
    
   tcase_c ( "repmc_c test:  value string has null pointer" );

   repmc_c  ( "x", "*", NULLCPTR, LNSIZE, out );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
    

   tcase_c ( "repmc_c test:  output string has null pointer" );

   repmc_c  ( "x", "*", "x", LNSIZE, NULLCPTR );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
    

   tcase_c ( "repmc_c test:  output string is too short" );

   repmc_c  ( "x", "*", "x", 0, out );
   chckxc_c ( SPICETRUE, "SPICE(STRINGTOOSHORT)", ok );
    






   /*
   Retrieve the current test status.
   */ 
   t_success_c ( ok ); 
   
   
} /* End f_st02_c */


