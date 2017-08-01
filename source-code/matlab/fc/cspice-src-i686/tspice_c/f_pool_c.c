/*

-Procedure f_pool_c ( Test wrappers for POOL entry points )

 
-Abstract
 
   Perform tests on all CSPICE wrappers corresponding to entry points
   of the SPICELIB POOL umbrella routine. 
 
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
   

   void f_pool_c ( SpiceBoolean * ok )

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
 
   This routine tests the wrappers for the kernel pool interface. 
   The current set is:
 
      clpool_c
      cvpool_c
      dtpool_c
      dvpool_c
      expool_c
      gcpool_c
      gdpool_c
      gipool_c
      gnpool_c
      ldpool_c
      lmpool_c
      pcpool_c
      pdpool_c
      pipool_c
      stpool_c
      swpool_c
      szpool_c
      
   In addition, there are some higher-level kernel pool look-up routines
   that are covered here:
   
      bodfnd_c
      bodvar_c
      bodvcd_c
      bodvrd_c
 
-Examples
 
   None.
    
-Restrictions
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
   W.L. Taber      (JPL) 
 
-Literature_References
 
   None. 
 
-Version
 
   -tspice_c Version 2.0.0 24-OCT-2005 (NJB)

      Added tests for bodvcd_c.c.

   -tspice_c Version 1.7.0 06-SEP-2004 (NJB)

      Added new tests for stpool_c.c.

        - Tests for checking code for invalid string argument
          pointers and lengths

        - Tests for output string contents in normal case

        - Test for output string contents when a kernel variable
          component is blank

   -tspice_c Version 1.6.0 23-FEB-2004 (NJB)

      Added tests for bodvrd_c.

   -tspice_c Version 1.5.1 20-MAR-2002 (EDW) 

      Replaced remove() calls with TRASH macro.

   -tspice_c Version 1.5.0 17-MAR-2002 (NJB)

      Added bodfnd test for case where kernel variable is of 
      character type. 

   -tspice_c Version 1.4.0 09-JAN-2002 (NJB)

      Bug fix:  recoded test case three (gnpool_c test).
      Previous code was just plain wrong.

      Updated szpool_c test to use value from szpool_ as expected
      value.

   -tspice_c Version 1.3.0 03-SEP-1999 (NJB) (WLT)

      Added tests for bodvar_c and bodfnd_c.
      
   -tspice_c Version 1.2.0 15-JUN-1999 (NJB) (WLT)

-&
*/

{ /* Begin f_pool_c */



   void stpool_c ( ConstSpiceChar    * item,
                   SpiceInt            nth,
                   ConstSpiceChar    * contin,
                   SpiceInt            lenout,
                   SpiceChar         * string,
                   SpiceInt          * size,
                   SpiceBoolean      * found  );

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
 
   /*
   Local parameters
   */
   #define LSK            "ldpool.tls"

   #define SPK_FILE_VAR   "SPK_FILES"
   #define SPK_BUFSIZE    5
   
   #define SPK_FILE0      "this_is_the_full_path_specification_"  \
                          "of_a_file_with_a_long_name"            
                         
   #define SPK_FILE1      "this_is_the_full_path_specification_"  \
                          "of_a_second_file_with_a_very_long_"    \
                          "name" 


   #define FILSIZ          255
   #define LNSIZE          81
   #define NLINES          27
   #define KVNLEN          33
   #define BUFDIM          100
   
   #define LMPOOL_NVARS    5
   
   #define PCPOOL_DIM      10
   #define PCPOOL_VAR      "pcpool_array"
   #define PCPOOL_VAL_TMP  "pcpool_val_%ld"

   #define PDPOOL_DIM      20
   #define PDPOOL_VAR      "pdpool_array"

   #define PIPOOL_DIM      30
   #define PIPOOL_VAR      "pipool_array"

   #define ROOM            2
   
   
   

   /*
   Static variables
   */

   static SpiceChar        spkbuf[SPK_BUFSIZE][LNSIZE] =
   {  
     "SPK_FILES = ( 'this_is_the_full_path_specification_*'",     
                   "'of_a_file_with_a_long_name'",                
                   "'this_is_the_full_path_specification_*'",     
                   "'of_a_second_file_with_a_very_long_*'",       
                   "'name' )"
   };            
                     
                     


   static SpiceChar        textbuf[NLINES][LNSIZE] = 
                    {
                       "DELTET/DELTA_T_A = 32.184",
                       "DELTET/K         = 1.657D-3",
                       "DELTET/EB        = 1.671D-2",
                       "DELTET/M         = ( 6.239996 1.99096871D-7 )",
                       "DELTET/DELTA_AT  = ( 10, @1972-JAN-1",
                       "                     11, @1972-JUL-1",
                       "                     12, @1973-JAN-1",
                       "                     13, @1974-JAN-1",
                       "                     14, @1975-JAN-1",
                       "                     15, @1976-JAN-1",
                       "                     16, @1977-JAN-1",
                       "                     17, @1978-JAN-1",
                       "                     18, @1979-JAN-1",
                       "                     19, @1980-JAN-1",
                       "                     20, @1981-JUL-1",
                       "                     21, @1982-JUL-1",
                       "                     22, @1983-JUL-1",
                       "                     23, @1985-JUL-1",
                       "                     24, @1988-JAN-1",
                       "                     25, @1990-JAN-1",
                       "                     26, @1991-JAN-1",
                       "                     27, @1992-JUL-1",
                       "                     28, @1993-JUL-1",
                       "                     29, @1994-JUL-1",
                       "                     30, @1996-JAN-1",
                       "                     31, @1997-JUL-1",
                       "                     32, @1999-JAN-1 )"
                    };
                     

   SpiceChar               lmpoolNames[LMPOOL_NVARS][LNSIZE] =

                           {
                              "DELTET/DELTA_T_A",
                              "DELTET/K",
                              "DELTET/EB",
                              "DELTET/M",
                              "DELTET/DELTA_AT"
                           };


   SpiceInt                lmpoolDims[LMPOOL_NVARS] =

                           { 1, 1, 1, 2, 46 };


   /*
   Local variables
   */
   logical                 fnd;

   SpiceBoolean            found;
   SpiceBoolean            update;

   SpiceChar               cvals       [PCPOOL_DIM]  [LNSIZE];
   SpiceChar               dtype;
   SpiceChar               file        [2][FILSIZ];
   SpiceChar               kerBuffer   [BUFDIM]      [LNSIZE];
   SpiceChar               kervar      [KVNLEN];
   SpiceChar               line        [LNSIZE];
   SpiceChar               pcpool_arr  [PCPOOL_DIM]  [LNSIZE];

   SpiceDouble             dvals       [PDPOOL_DIM];
   SpiceDouble             et;
   SpiceDouble             exprad      [3];
   SpiceDouble             pdpool_arr  [PDPOOL_DIM];
   SpiceDouble             radii       [3];
   
   SpiceInt                dim;
   SpiceInt                expn;
   SpiceInt                i;
   SpiceInt                ivals       [PIPOOL_DIM];
   SpiceInt                n;
   SpiceInt                pipool_arr  [PIPOOL_DIM];
   SpiceInt                size;
   SpiceInt                start;


         
   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_pool_c" );
   
      
   /*
   Case 1:
   */
   tcase_c ( "This case tests lmpool_c; a leapseconds "
             "kernel is (effectively) loaded via lmpool_c."  );
   
   lmpool_c ( textbuf, LNSIZE, NLINES );

   /*
   If the kernel pool was loaded successfully, we should be able to
   make a call that requires leapseconds kernel data.  No error should
   be signaled.
   */
   str2et_c ( "1999 JUN 7", &et );

   chckxc_c ( SPICEFALSE, " ", ok );
   
   /*
   Check string error cases:
   
      1) Null textbuf.
      2) Insufficient-length textbuf.
      
   */
   lmpool_c ( NULLCPTR, LNSIZE, NLINES );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   
   lmpool_c ( textbuf,    1, NLINES );
   chckxc_c ( SPICETRUE, "SPICE(STRINGTOOSHORT)", ok );
   
   
   
   
   /*
   Case 2:
   */
   tcase_c ( "This case tests dtpool_c; we make sure dtpool_c "
             "returns correct info on the variables loaded in "
             "the lmpool_c test."                              );
             

   for ( i = 0;  i < LMPOOL_NVARS;  i++ )
   {
      dtpool_c ( lmpoolNames[i],  &found, &n, &dtype );
      
      chckxc_c ( SPICEFALSE, " ",           ok );
      chcksl_c ( "found", found, SPICETRUE, ok );
      
      chcksi_c ( "n", n, "=", lmpoolDims[i], 0, ok );
      
      /*
      Both the actual and expected values are automatically 
      promoted to ints.
      */
      chcksi_c ( "dtype", (unsigned char)dtype, "=", 'N', 0, ok );
   }


   /*
   Check string error cases:
   
      1) Null variable name.
      2) Empty variable name.
      
   */
   dtpool_c ( NULLCPTR,  &found, &n, &dtype );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   
   dtpool_c ( "",  &found, &n, &dtype );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );





   /*
   Case 3:
   */
   tcase_c ( "This case tests gnpool_c; we make sure gnpool_c can "
             "return a correct list of the variable names in the "
             "pool."                                                );
     
   /*
   As a first step, just make sure all the names are there.
   */
   for ( i = 0;  i < LMPOOL_NVARS;  i++ )
   {
      start = 0;

      gnpool_c ( lmpoolNames[i],
                 start,
                 1,
                 KVNLEN,
                 &n,
                 kervar,
                 &found          );

      chckxc_c ( SPICEFALSE, " ",           ok );
      chcksl_c ( "found", found, SPICETRUE, ok );

      if ( found )
      {
         chcksi_c ( "n",  n, "=",   1,   0,    ok );

         chcksc_c ( "kervar", 
                    kervar, 
                    "=", 
                    lmpoolNames[i],
                    ok              );
      }
   }
   
   /*
   Check string error cases:
   
      1) Null template.
      2) Empty template.
      3) Null output pointer.
      4) Output string length too short.
      
   */
   gnpool_c ( NULLCPTR, 1, 1, KVNLEN, &n, kervar, &found );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   
   gnpool_c ( "",       1, 1, KVNLEN, &n, kervar, &found );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );


   gnpool_c ( "*", 1, 1, KVNLEN, &n, NULLCPTR, &found );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   gnpool_c ( "*", 1, 1, 1,      &n, kervar,   &found );
   chckxc_c ( SPICETRUE, "SPICE(STRINGTOOSHORT)", ok );




   
   /*
   Case 4:
   */
   tcase_c ( "This case tests dvpool_c.  We'll delete the lmpool_c "
             "variables from the pool."                              );
            
            
   for ( i = 0;  i < LMPOOL_NVARS;  i++ )
   {
      dvpool_c ( lmpoolNames[i] );
      
      /*
      Make sure no error was signaled and that the variable is gone.
      */
      chckxc_c ( SPICEFALSE, " ", ok );
             
      dtpool_c ( lmpoolNames[i], &found, &n, &dtype );
      
      chcksl_c ( "found", found, SPICEFALSE, ok );
   }
            
            
   /*
   Check string error cases:
   
      1) Null variable name.
      2) Empty variable name.
      
   */
   dvpool_c ( NULLCPTR );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   
   dvpool_c ( "" );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );
            
            
            
            
            
   /*
   Case 5:
   */
   tcase_c ( "This case tests swpool_c and cvpool_c. We'll set a "
             "watch on all the variables from the lmpool_c test. "
             "We'll load them again and make sure their agent is "
             "notified."                                           );
             
   
   swpool_c ( "pool_agent", LMPOOL_NVARS, LNSIZE, lmpoolNames );
   chckxc_c ( SPICEFALSE, " ", ok );

   lmpool_c ( textbuf, LNSIZE, NLINES );
   
   cvpool_c ( "pool_agent", &update );
   
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "update", update, SPICETRUE, ok );
   
   
   cvpool_c ( "pool_agent", &update );
   
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "update", update, SPICEFALSE, ok );
   
  
  
   /*
   Check swpool_c string error cases:
   
      1) Null template.
      2) Empty template.
      3) Null output pointer.
      4) Output string length too short.
      
   */
   swpool_c ( NULLCPTR, LMPOOL_NVARS, LNSIZE, lmpoolNames );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   
   swpool_c ( "", LMPOOL_NVARS, LNSIZE, lmpoolNames );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );


   swpool_c ( "pool_agent", LMPOOL_NVARS, LNSIZE, NULLCPTR );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   swpool_c ( "pool_agent", LMPOOL_NVARS, 1, lmpoolNames );
   chckxc_c ( SPICETRUE, "SPICE(STRINGTOOSHORT)", ok );


   /*
   Check cvpool_c string error cases:
   
      1) Null variable name.
      2) Empty variable name.
      
   */
   cvpool_c ( NULLCPTR, &update );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   
   cvpool_c ( "", &update );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );
            

  
  
   
   /*
   Case 6:
   */
   tcase_c ( "This case tests clpool_c.  Clear the kernel pool "
             "and make sure that gnpool_c doesn't find any "
             "variables remaining in the pool."                 );
             
   clpool_c();
   chckxc_c ( SPICEFALSE, " ", ok );
   
   gnpool_c ( "*", 1, 1, KVNLEN, &n, kervar, &found );
   chcksl_c ( "found", found, SPICEFALSE, ok );
   
   
   /*
   Case 7:
   */
   tcase_c ( "This case tests pcpool_c and gcpool_c.  A variable "
             "associated with an array of strings is loaded via "
             "pcpool_c.  The values are retrieved via gcpool_c."  );
   
   
   /*
   Populate the pcpool_c array with values.
   */
   
   for ( i = 0;  i < PCPOOL_DIM;  i++ )
   {
      sprintf ( pcpool_arr[i],  PCPOOL_VAL_TMP,  i );
   }
   
   
   /*
   Insert the variable into the kernel pool.
   */
   pcpool_c ( PCPOOL_VAR, PCPOOL_DIM, LNSIZE, pcpool_arr );
   chckxc_c ( SPICEFALSE, " ", ok );
      
   
   /*
   Retrieve the variable's associated values.
   */
   gcpool_c ( PCPOOL_VAR, 0, PCPOOL_DIM, LNSIZE, &n, cvals, &found );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   /*
   Check the results.
   */
   chcksl_c ( "found", found, SPICETRUE, ok );
   chcksi_c ( "n",  n, "=",   PCPOOL_DIM,   0,    ok );

   for ( i = 0;  i < PCPOOL_DIM;  i++ )
   {
      chcksc_c ( PCPOOL_VAR, cvals[i], "=", pcpool_arr[i], ok );
   }

   
   
   
   
   /*
   Case 8:
   */
   tcase_c ( "This case tests pdpool_c and gdpool_c.  A variable "
             "associated with an array of d.p.s is loaded via "
             "pdpool_c.  The values are retrieved via gdpool_c."  );
   
   
   /*
   Populate the pdpool_c array with values.
   */
   
   for ( i = 0;  i < PDPOOL_DIM;  i++ )
   {
      pdpool_arr[i] = i;
   }
   
   
   /*
   Insert the variable into the kernel pool.
   */
   pdpool_c ( PDPOOL_VAR, PDPOOL_DIM, pdpool_arr );
   chckxc_c ( SPICEFALSE, " ", ok );
      
   
   /*
   Retrieve the variable's associated values.
   */
   gdpool_c ( PDPOOL_VAR, 0, PDPOOL_DIM, &n, dvals, &found );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   /*
   Check the results.
   */
   chcksl_c ( "found", found, SPICETRUE, ok );
   chcksi_c ( "n",  n, "=",   PDPOOL_DIM,   0,    ok );

   chckad_c ( PDPOOL_VAR,  dvals,  "=",  pdpool_arr, 
              PDPOOL_DIM,  0,      ok                  );

   
   
   
   
   
   /*
   Case 9:
   */
   tcase_c ( "This case tests pipool_c and gipool_c.  A variable "
             "associated with an array of integers is loaded via "
             "pipool_c.  The values are retrieved via gipool_c."  );
   
   
   /*
   Populate the pipool_c array with values.
   */
   
   for ( i = 0;  i < PIPOOL_DIM;  i++ )
   {
      pipool_arr[i] = i;
   }
   
   
   /*
   Insert the variable into the kernel pool.
   */
   pipool_c ( PIPOOL_VAR, PIPOOL_DIM, pipool_arr );
   chckxc_c ( SPICEFALSE, " ", ok );
      
   
   /*
   Retrieve the variable's associated values.
   */
   gipool_c ( PIPOOL_VAR, 0, PIPOOL_DIM, &n, ivals, &found );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   /*
   Check the results.
   */
   chcksl_c ( "found", found, SPICETRUE, ok );
   chcksi_c ( "n",  n, "=",   PIPOOL_DIM,   0,    ok );

   chckai_c ( PIPOOL_VAR, ivals, "=", pipool_arr, PIPOOL_DIM, ok );

   
   
   
   
   
   
   /*
   Case 10:
   */
   
   tcase_c ( "This case tests ldpool_c.  We create a new LSK and "
             "load it via ldpool_c.  Then we check that the expected "
             "kernel variables are present."   );
   
   clpool_c ();
   
   /*
   Create a kernel file.  We must prepend a "\begindata" control
   word to the kernel variable assignments in the lmpool_c text 
   buffer.
   */
   strcpy ( kerBuffer[0], "\\begindata" );
   
   for ( i = 0; i < NLINES; i ++ )
   {
      strcpy ( kerBuffer[i+1], textbuf[i] );
   }
   
   tsttxt_c ( LSK,     kerBuffer,  NLINES+1, 
              LNSIZE,  SPICEFALSE, SPICEFALSE );

   ldpool_c ( LSK );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   for ( i = 0;  i < LMPOOL_NVARS;  i++ )
   {
      dtpool_c ( lmpoolNames[i],  &found, &n, &dtype );
      
      chckxc_c ( SPICEFALSE, " ",           ok );
      chcksl_c ( "found", found, SPICETRUE, ok );
      
      chcksi_c ( "n", n, "=", lmpoolDims[i], 0, ok );
      
      /*
      Both the actual and expected values are automatically 
      promoted to ints.
      */
      chcksi_c ( "dtype", (unsigned char)dtype, "=", 'N', 0, ok );
   }

   /*
   Clean up the kernel.
   */
   TRASH ( LSK );



   
   
   /*
   Case 11:
   */
   
   tcase_c ( "Test expool_c.  Make sure one of the variables in "
             "the test LSK is found after the LSK is loaded."     );
             
   clpool_c ();
   tsttxt_c ( LSK,     kerBuffer,  NLINES+1, 
              LNSIZE,  SPICEFALSE, SPICEFALSE );
   ldpool_c ( LSK );
   
   
   expool_c ( "DELTET/DELTA_T_A",    &found );
   chckxc_c ( SPICEFALSE, " ",           ok );
   chcksl_c ( "found", found, SPICETRUE, ok );
   
   
   
   
   
   /*
   Case 12:
   */
   
   tcase_c ( "Test szpool_c.  Make sure we can retrieve the number "
             "of kernel variable names the pool can hold."          );
             
   szpool_c ( "MAXVAR",   &n,               &found);
   chckxc_c ( SPICEFALSE, " ",              ok    );
   chcksl_c ( "found",    found, SPICETRUE, ok    );

   szpool_  ( "MAXVAR",   (integer *) &expn, 
              &fnd,       (ftnlen)strlen("MAXVAR") );
   chckxc_c ( SPICEFALSE, " ",           ok        );

   chcksi_c ( "MAXVAR", n, "=", expn, 0, ok );
   
   
   
   /*
   Case 13:
   */
   
   tcase_c ( "Test stpool_c. Use lmpool_c to load into the kernel "
             "pool strings representing two very long SPK file names. "
             "Retrieve these names using stpool_c."                   ); 
   
   clpool_c ();
 
   lmpool_c ( spkbuf, LNSIZE, SPK_BUFSIZE );
 

   stpool_c ( "SPK_FILES", 0, "*", FILSIZ, file[0], &size, &found );
   
   
   chckxc_c ( SPICEFALSE, " ",           ok    );
   chcksl_c ( "found", found, SPICETRUE, ok    );
      
   chcksi_c ( "size",     size,    "=", strlen(SPK_FILE0), 0, ok );
   chcksc_c ( "file[0]",  file[0], "=", SPK_FILE0,            ok );


   stpool_c ( "SPK_FILES", 1, "*", FILSIZ, file[1], &size, &found );
   chckxc_c ( SPICEFALSE, " ",           ok    );

   chcksl_c ( "found", found, SPICETRUE, ok    );

   chcksi_c ( "size",     size,    "=", strlen(SPK_FILE1), 0, ok );
   chcksc_c ( "file[1]",  file[1], "=", SPK_FILE1,            ok );

   /*
   Check handling of a blank component.  The returned string
   should contain a single blank followed by a null. 
   */
   pcpool_c ( "BLANK_VAR", 1, 5, "    " );
   chckxc_c ( SPICEFALSE, " ", ok );

   stpool_c ( "BLANK_VAR", 0, "*", LNSIZE, line, &size, &found );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "found", found, SPICETRUE,       ok );
   chcksi_c ( "size",        size,  "=", 1, 0, ok );
   chcksc_c ( "blank line",  line, "=",  " ",  ok );


   /*
   Check stpool_c string error cases:
   
      1) Null variable name string.
      2) Empty variable name string.
      3) Null marker string.
      4) Empty marker string.
      5) Null output string.
      6) Output string too short.
      
   */
   stpool_c ( NULLCPTR, 1, "*", FILSIZ, file[1], &size, &found );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   
   stpool_c ( "",       1, "*", FILSIZ, file[1], &size, &found );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );
   

   stpool_c ( "SPK_FILES", 1, NULLCPTR, FILSIZ, file[1], &size, &found );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   
   stpool_c ( "SPK_FILES", 1, "",       FILSIZ, file[1], &size, &found );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );

   stpool_c ( "SPK_FILES", 1, "*", FILSIZ, NULLCPTR, &size, &found );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   stpool_c ( "SPK_FILES", 1, "*", 1,      file[1],  &size, &found );
   chckxc_c ( SPICETRUE, "SPICE(STRINGTOOSHORT)", ok );


   
   /*
   Case 14:
   */
   tcase_c ( "Test bodfnd_c" );
   
   /*
   First, create and load a generic PCK.
   */
   
   tstpck_c ( "bod_test.tpc", SPICETRUE, SPICEFALSE );
   
   /*
   See whether the earth's radii are present.  They should be.
   */
   found = bodfnd_c ( 399, "RADII" );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "found", found, SPICETRUE, ok );
   
   
   /*
   See whether the earth's bowels are present.  The PCK doesn't know
   of this poetic device.
   */
   found = bodfnd_c ( 399, "BOWELS" );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "found", found, SPICEFALSE, ok );
   
   /*
   Add a string value to the kernel pool.  Make sure bodfnd_c knows
   it's there. 

   Insert the variable into the kernel pool.  We've got to give the
   variable a new name---one that bodfnd can work with.
   */
   pcpool_c ( "BODY699_CHR_VAR", PCPOOL_DIM, LNSIZE, pcpool_arr );
   chckxc_c ( SPICEFALSE, " ", ok );

   found = bodfnd_c ( 699, "CHR_VAR" );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "found", found, SPICETRUE, ok );

   
   /*
   Check bodfnd_c string error cases:
   
      1) Null input string.
      2) Empty input string.
      
   */
   found = bodfnd_c ( 399, NULLCPTR );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   chcksl_c ( "found", found, SPICEFALSE, ok );
   
   found = bodfnd_c ( 399, "" );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );
   chcksl_c ( "found", found, SPICEFALSE, ok );
   
   
   
   
   /*
   Case 15:
   */
   tcase_c ( "Test bodvar_c" );
   
   /*
   Get the radii for the earth.
   */
   bodvar_c ( 399, "RADII", &dim, radii );
   
   vpack_c ( 6378.140, 6378.140, 6356.75, exprad );
   
   chckxc_c ( SPICEFALSE,     " ",               ok );
   chcksi_c ( "dim", dim,     "=", 3, 0,         ok );
   chckad_c ( "radii", radii, "=", exprad, 3, 0, ok );
   
   
   
   /*
   Check bodvar_c string error cases:
   
      1) Null input string.
      2) Empty input string.
      
   */
   bodvar_c ( 399, NULLCPTR, &dim, radii );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   bodvar_c ( 399, "", &dim, radii );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );
   

   /*
   Case 16:  
   */
   tcase_c ( "Test bodvrd_c" );
   
   /*
   Get the radii for the earth.
   */
   bodvrd_c ( "Earth", "RADII", 3, &dim, radii );
   
   vpack_c ( 6378.140, 6378.140, 6356.75, exprad );
   
   chckxc_c ( SPICEFALSE,     " ",               ok );
   chcksi_c ( "dim", dim,     "=", 3, 0,         ok );
   chckad_c ( "radii", radii, "=", exprad, 3, 0, ok );
   
   /*
   Get the radii for the earth.
   */
   bodvrd_c ( "399", "RADII", 3, &dim, radii );
   
   vpack_c ( 6378.140, 6378.140, 6356.75, exprad );
   
   chckxc_c ( SPICEFALSE,     " ",               ok );
   chcksi_c ( "dim", dim,     "=", 3, 0,         ok );
   chckad_c ( "radii", radii, "=", exprad, 3, 0, ok );
   
   
   /*
   Check bodvrd_c string error cases:
   
      1) Null input string.
      2) Empty input string.
      
   */
   bodvrd_c ( NULLCPTR, "RADII", 3, &dim, radii );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   bodvrd_c ( "", "RADII", 3, &dim, radii );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );

   bodvrd_c ( "Earth", NULLCPTR, 3, &dim, radii );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   bodvrd_c ( "Earth", "", 3, &dim, radii );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );
   

   
   /*
   Case 17:  
   */
   tcase_c ( "Test bodvcd_c" );
   
   /*
   Get the radii for the earth.
   */
   bodvcd_c ( 399, "RADII", 3, &dim, radii );
   
   vpack_c ( 6378.140, 6378.140, 6356.75, exprad );
   
   chckxc_c ( SPICEFALSE,     " ",               ok );
   chcksi_c ( "dim", dim,     "=", 3, 0,         ok );
   chckad_c ( "radii", radii, "=", exprad, 3, 0, ok );
   
   
   /*
   Check bodvrd_c string error cases:
   
      1) Null input string.
      2) Empty input string.
      
   */
   bodvcd_c ( 399, NULLCPTR, 3, &dim, radii );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   bodvcd_c ( 399, "", 3, &dim, radii );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );
   
   
   
   /*
   Leave the kernel pool clean.
   */
   clpool_c();
   
   
   /*
   Clean up remaining files.
   */
   TRASH ( LSK );
   
   /*
   Retrieve the current test status.
   */ 
   t_success_c ( ok ); 
   
   
} /* End f_pool_c */



