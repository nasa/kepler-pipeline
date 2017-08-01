/*

-Procedure f_nnpool_c ( Test non-native text kernel reader )

 
-Abstract
 
   Perform tests on to confirm non-native text kernel read/parse capability. 
 
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
   #include <stdio.h>
   #include "SpiceUsr.h"
   #include "SpiceZfc.h"
   #include "SpiceZmc.h"
   #include "tutils_c.h"

   void f_nnpool_c ( SpiceBoolean * ok )

/*

-Brief_I/O

   VARIABLE  I/O  DESCRIPTION 
   --------  ---  -------------------------------------------------- 
   ok         O   SPICETRUE if the test passes, SPICEFALSE otherwise.
   
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

   Implemented for N59.

-Examples
 
   None.
    
-Restrictions
 
   None. 
 
-Author_and_Institution
 
   E.D. Wright    (JPL)
 
-Literature_References
 
   None. 
 
-Version
 
   -tspice_c Version 1.0.0 04-OCT-2005 (EDW)

-&
*/
   { /* Begin f_nnpool_c */

   /*
   Local macros
   */
   #define TRASH(file)     if ( remove(file) !=0 )                        \
                              {                                           \
                              setmsg_c ( "Unable to delete file #." );    \
                              errch_c  ( "#", file );                     \
                              sigerr_c ( "TSPICE(DELETEFAILED)"  );       \
                              }                                           \
                           chckxc_c ( SPICEFALSE, " ", ok );

   #define VEC_SIZE         4
   #define STR_LENGTH       25

   /*
   Local variables
   */

   FILE    * ker_file;
   
   char    * CRkernel   = "CR.ker";
   char    * LFkernel   = "LF.ker";
   char    * CRLFkernel = "CRLF.ker";
   
   char    * tags[] = { "\\begindata", "\\begintext" };

   
   char    * line[] = { " TEST_INT = 186282"          , 
                        " TEST_DP  = 186282.397"      , 
                        " TEST_CH  = \'Light Speed\'" };

   char    * line1[] = { " TEST_INT1 = ( 186282,"     ,
                        "              314159,"       ,
                        "              27183,"        , 
                        "              69315 )"        ,
                        " TEST_DP1  = ( 186282.397",
                                       "  3.14159",
                                       "  2.7183",
                                       "  0.69315 )"      ,
                        " TEST_CH1  = ( \'Light Speed\'",
                                      "  \'PI\'"        ,
                                      "  \'EXP(1)\'"    ,
                                      "  \'LN(2)\' )"
                                      };

   SpiceInt       expint[] = { 186282    ,  314159, 27183 , 69315   };
   SpiceDouble    expdp[]  = { 186282.397, 3.14159, 2.7183, 0.69315 };
   SpiceChar    * expch[]  = { "Light Speed", "PI", "EXP(1)", "LN(2)" };


   SpiceInt      ivals[5];
   SpiceDouble   dvals[5];
   SpiceChar     cvals[5][STR_LENGTH];

   SpiceInt      n;
   SpiceBoolean  found;

   int           i;
         
   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_nnpool_c" );
   

   /*
   Case 1:
   */
   tcase_c ( "This case tests CRLF text kernels - scalar"  );

   clpool_c();
   chckxc_c ( SPICEFALSE, " ", ok );

   memset( ivals, 0, 5 * sizeof(SpiceInt)    );
   memset( dvals, 0, 5 * sizeof(SpiceDouble) );
   memset( cvals, 0, STR_LENGTH * sizeof(SpiceChar)  );

   /*
   Carriage returns + line feeds 
   */
   ker_file = fopen( CRLFkernel, "w" );

   fprintf( ker_file, "%s\015\012", tags[0] );

   for( i=0; i<3; i++ )
      {   
      fprintf( ker_file, "%s\015\012", line[i] );
      }

   for( i=0; i<12; i++ )
      {
      fprintf( ker_file, "%s\015\012", line1[i] );
      }


   fprintf( ker_file, "%s\015\012", tags[1] );

   fclose( ker_file );

   furnsh_c( CRLFkernel );
   chckxc_c ( SPICEFALSE, " ", ok );


   /*
   Retrieve the variable's associated values.
   */
   gipool_c ( "TEST_INT", 0, 1, &n, ivals, &found );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   Check the results.
   */
   chcksl_c ( "found", found, SPICETRUE, ok );
   chcksi_c ( "n",  n, "=",   1,   0,    ok );
   chcksi_c ( "TEST_INT", ivals[0], "=", 186282, 0, ok );


   gdpool_c ( "TEST_DP", 0, 1, &n, dvals, &found );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   Check the results.
   */
   chcksl_c ( "found", found, SPICETRUE, ok );
   chcksi_c ( "n",  n, "=",   1,   0,    ok );
   chcksd_c ( "TEST_DP", dvals[0], "=", 186282.397, 0, ok );


   gcpool_c ( "TEST_CH", 0, 1, STR_LENGTH, &n, cvals, &found );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   Check the results.
   */
   chcksl_c ( "found", found, SPICETRUE, ok );
   chcksi_c ( "n",  n, "=",  1,   0,    ok );
   chcksc_c ( "TEST_CH", cvals[0], "=", "Light Speed", ok );



   tcase_c ( "This case tests CRLF text kernels - vector"  );

   /*
   Vectors
   */

   gipool_c ( "TEST_INT1", 0, VEC_SIZE, &n, ivals, &found );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   Check the results.
   */
   chcksl_c ( "found", found, SPICETRUE, ok );
   chcksi_c ( "n",  n, "=",   VEC_SIZE,   0,    ok );

   chckai_c ( "TEST_INT1", ivals, "=", expint, VEC_SIZE, ok );


   gdpool_c ( "TEST_DP1", 0, VEC_SIZE, &n, dvals, &found );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   Check the results.
   */
   chcksl_c ( "found", found, SPICETRUE, ok );
   chcksi_c ( "n",  n, "=",   VEC_SIZE,   0,    ok );
   chckad_c ( "TEST_DP1", dvals, "=", expdp, VEC_SIZE, 0.0, ok );


   gcpool_c ( "TEST_CH1", 0, VEC_SIZE, STR_LENGTH, &n, cvals, &found );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   Check the results.
   */
   chcksl_c ( "found", found, SPICETRUE, ok );
   chcksi_c ( "n",  n, "=",   VEC_SIZE,   0,    ok );
   for( i=0; i<VEC_SIZE; i++ )
      {
      chcksc_c ( "TEST_CH", cvals[i], "=", expch[i], ok );
      }



   /*
   Case 2:
   */
   tcase_c ( "This case tests CR text kernels"  );

   clpool_c();
   chckxc_c ( SPICEFALSE, " ", ok );

   memset( ivals, 0, 5 * sizeof(SpiceInt)    );
   memset( dvals, 0, 5 * sizeof(SpiceDouble) );
   memset( cvals, 0, STR_LENGTH * sizeof(SpiceChar)  );

   /*
   Carriage returns
   */
   ker_file = fopen( CRkernel, "w" );

   fprintf( ker_file, "%s\015", tags[0] );
   
   fprintf( ker_file, "%s\015", line[0] );
   fprintf( ker_file, "%s\015", line[1] );
   fprintf( ker_file, "%s\015", line[2] );

   for( i=0; i<12; i++ )
      {
      fprintf( ker_file, "%s\015", line1[i] );
      }

   fprintf( ker_file, "%s\015", tags[1] );

   fclose( ker_file );

   furnsh_c( CRkernel );
   chckxc_c ( SPICEFALSE, " ", ok );
   

   /*
   Retrieve the variable's associated values.
   */
   gipool_c ( "TEST_INT", 0, 1, &n, ivals, &found );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   Check the results.
   */
   chcksl_c ( "found", found, SPICETRUE, ok );
   chcksi_c ( "n",  n, "=",   1,   0,    ok );
   chcksi_c ( "TEST_INT", ivals[0], "=", 186282, 0, ok );


   gdpool_c ( "TEST_DP", 0, 1, &n, dvals, &found );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   Check the results.
   */
   chcksl_c ( "found", found, SPICETRUE, ok );
   chcksi_c ( "n",  n, "=",   1,   0,    ok );
   chcksd_c ( "TEST_DP", dvals[0], "=", 186282.397, 0, ok );


   gcpool_c ( "TEST_CH", 0, 1, STR_LENGTH, &n, cvals, &found );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   Check the results.
   */
   chcksl_c ( "found", found, SPICETRUE, ok );
   chcksi_c ( "n",  n, "=",  1,   0,    ok );
   chcksc_c ( "TEST_CH", cvals[0], "=", "Light Speed", ok );


   tcase_c ( "This case tests CR text kernels - vector"  );

   /*
   Vectors
   */
   gipool_c ( "TEST_INT1", 0, VEC_SIZE, &n, ivals, &found );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   Check the results.
   */
   chcksl_c ( "found", found, SPICETRUE, ok );
   chcksi_c ( "n",  n, "=",   VEC_SIZE,   0,    ok );
   chckai_c ( "TEST_INT1", ivals, "=", expint, VEC_SIZE, ok );


   gdpool_c ( "TEST_DP1", 0, VEC_SIZE, &n, dvals, &found );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   Check the results.
   */
   chcksl_c ( "found", found, SPICETRUE, ok );
   chcksi_c ( "n",  n, "=",   VEC_SIZE,   0,    ok );
   chckad_c ( "TEST_DP1", dvals, "=", expdp, VEC_SIZE, 0.0, ok );


   gcpool_c ( "TEST_CH1", 0, VEC_SIZE, STR_LENGTH, &n, cvals, &found );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   Check the results.
   */
   chcksl_c ( "found", found, SPICETRUE, ok );
   chcksi_c ( "n",  n, "=",   VEC_SIZE,   0,    ok );
   for( i=0; i<VEC_SIZE; i++ )
      {
      chcksc_c ( "TEST_CH", cvals[i], "=", expch[i], ok );
      }




   /*
   Case 3:
   */
   tcase_c ( "This case tests LF text kernels"  );

   clpool_c();
   chckxc_c ( SPICEFALSE, " ", ok );

   memset( ivals, 0, 5 * sizeof(SpiceInt)    );
   memset( dvals, 0, 5 * sizeof(SpiceDouble) );
   memset( cvals, 0, STR_LENGTH * sizeof(SpiceChar)  );

   /*
   Line feed
   */
   ker_file = fopen( LFkernel, "w" );

   fprintf( ker_file, "%s\012", tags[0] );
   
   fprintf( ker_file, "%s\012", line[0] );
   fprintf( ker_file, "%s\012", line[1] );
   fprintf( ker_file, "%s\012", line[2] );

   for( i=0; i<12; i++ )
      {
      fprintf( ker_file, "%s\012", line1[i] );
      }
      
   fprintf( ker_file, "%s\012", tags[1] );

   fclose( ker_file );

   furnsh_c( LFkernel );
   chckxc_c ( SPICEFALSE, " ", ok );



   /*
   Retrieve the variable's associated values.
   */
   gipool_c ( "TEST_INT", 0, 1, &n, ivals, &found );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   Check the results.
   */
   chcksl_c ( "found", found, SPICETRUE, ok );
   chcksi_c ( "n",  n, "=",   1,   0,    ok );
   chcksi_c ( "TEST_INT", ivals[0], "=", 186282, 0, ok );


   gdpool_c ( "TEST_DP", 0, 1, &n, dvals, &found );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   Check the results.
   */
   chcksl_c ( "found", found, SPICETRUE, ok );
   chcksi_c ( "n",  n, "=",   1,   0,    ok );
   chcksd_c ( "TEST_DP", dvals[0], "=", 186282.397, 0, ok );


   gcpool_c ( "TEST_CH", 0, 1, STR_LENGTH, &n, cvals, &found );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   Check the results.
   */
   chcksl_c ( "found", found, SPICETRUE, ok );
   chcksi_c ( "n",  n, "=",  1,   0,    ok );
   chcksc_c ( "TEST_CH", cvals[0], "=", "Light Speed", ok );



   tcase_c ( "This case tests LF text kernels - vector"  );

   /*
   Vectors
   */
   gipool_c ( "TEST_INT1", 0, VEC_SIZE, &n, ivals, &found );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   Check the results.
   */
   chcksl_c ( "found", found, SPICETRUE, ok );
   chcksi_c ( "n",  n, "=",   VEC_SIZE,   0,    ok );
   chckai_c ( "TEST_INT1", ivals, "=", expint, VEC_SIZE, ok );


   gdpool_c ( "TEST_DP1", 0, VEC_SIZE, &n, dvals, &found );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   Check the results.
   */
   chcksl_c ( "found", found, SPICETRUE, ok );
   chcksi_c ( "n",  n, "=",   VEC_SIZE,   0,    ok );
   chckad_c ( "TEST_DP1", dvals, "=", expdp, VEC_SIZE, 0.0, ok );


   gcpool_c ( "TEST_CH1", 0, VEC_SIZE, STR_LENGTH, &n, cvals, &found );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   Check the results.
   */
   chcksl_c ( "found", found, SPICETRUE, ok );
   chcksi_c ( "n",  n, "=",   VEC_SIZE,   0,    ok );
   for( i=0; i<VEC_SIZE; i++ )
      {
      chcksc_c ( "TEST_CH", cvals[i], "=", expch[i], ok );
      }





   /*
   Leave the kernel pool clean.
   */
   clpool_c();
   
   
   /*
   Clean up remaining files.
   */
   TRASH ( CRLFkernel );
   TRASH ( CRkernel  );
   TRASH ( LFkernel   );

   /*
   Retrieve the current test status.
   */ 
   t_success_c ( ok ); 
   
   } /* End f_pool_c */



