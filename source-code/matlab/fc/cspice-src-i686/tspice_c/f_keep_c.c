/*

-Procedure f_keep_c ( Test wrappers for KEEPER entry points )

 
-Abstract
 
   Perform tests on CSPICE wrappers for entry points of KEEPER. 
 
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
   #include "SpiceZst.h"
   #include "SpiceZmc.h"
   #include "tutils_c.h"
   

   void f_keep_c ( SpiceBoolean * ok )

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
 
   This routine tests the wrappers for the entry points of the 
   SPICELIB umbrella routine KEEPER.  Covered routines are:
      
      furnsh_c
      kdata_c
      kinfo_c
      ktotal_c
      unload_c
             
-Examples
 
   None.
    
-Restrictions
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
 
-Literature_References
 
   None. 
 
-Version

   -tspice_c Version 3.0.2 20-MAR-2002 (EDW) 

      Replaced remove() calls with TRASH macro.

   -tspice_c Version 3.0.1 13-DEC-2001 (EDW)  

      Discovered this test family did not unload all
      kernels generated during test run.

      Added call to unload META kernel. By doing so,
      unload removes all test family specific kernels
      from the kernel pool. Removed the now superfluous
      unload( SPK ) call.

   -tspice_c Version 3.0.0 12-SEP-1999 (NJB)  

-&
*/

{ /* Begin f_keep_c */

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
   Constants
   */
   #define CK              "keeptest.bc"
   #define FILEN           256
   #define LINELN          81
   #define META            "meta.ker"
   #define NMETA           6
   #define SCLK            "keeptest.tsc"
   #define SPK             "keeptest.bsp"
   #define SRCLEN          LINELN
   #define TYPLEN          11
   
   /*
   Local variables
   */  
   SpiceBoolean            found;
              
   SpiceChar               file        [ FILEN  ];
   SpiceChar               files    [3][ FILEN  ] = { SPK, CK, SCLK };


   SpiceChar               metatxt  [NMETA][ LINELN ] = 
                           {
                               "\\begindata",
                               " ",
                               "KERNELS_TO_LOAD =  ( 'keeptest.bsp',",
                               "                     'keeptest.bc',",
                               "                     'keeptest.tsc' )",
                               "\\begintext"
                           };

   SpiceChar               type        [ TYPLEN ];
   
   SpiceChar               types    [3][ TYPLEN ] = 
   
                           { "SPK", "CK", "TEXT" };
                           
                           
   SpiceChar               source      [ SRCLEN ];

   SpiceInt                ckhan;
   SpiceInt                count;
   SpiceInt                handle;
   SpiceInt                i;
   SpiceInt                unit;
         



   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_keep_c" );
   

   
   
   /*
   Case 1:
   */
   tcase_c ( "Test furnsh_c.  Create and load an SPK file " 
             "and a type 3 CK."                            );


   tstspk_c ( SPK, SPICEFALSE, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   tstck3_c ( CK, SCLK, SPICEFALSE, SPICEFALSE, SPICETRUE, &ckhan );
   chckxc_c ( SPICEFALSE, " ", ok );


   furnsh_c ( SPK );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   furnsh_c ( CK );
   chckxc_c ( SPICEFALSE, " ", ok );
      
   
   /*
   Check furnsh_c string error cases:
   
      1) Null filename string.
      2) Empty filename string.      
   */
   
   furnsh_c ( NULLCPTR );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   furnsh_c ( "" );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );



   /*
   Case 2:
   */
   tcase_c ( "Test ktotal_c. Find out how many kernels are loaded." );

   ktotal_c ( "All", &count );
   chckxc_c ( SPICEFALSE, " ", ok );
               
   /*
   There should be two kernels loaded.
   */
   chcksi_c ( "count", count, "=", 2, 0, ok );
   
   
   /*
   Check ktotal_c string error cases:
   
      1) Null file spec string.
      2) Empty file spec string.      
   */
   
   ktotal_c ( NULLCPTR, &count );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   ktotal_c ( "", &count );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );



   /*
   Case 3:
   */
   tcase_c ( "Test kdata_c. Get kernel info by index." );

   
   
   for ( i = 0;  i < count;  i++ )
   {
      kdata_c ( i,     "all",  FILEN,   TYPLEN,   SRCLEN,  
                file,  type,   source,  &handle,  &found );
               
      chckxc_c ( SPICEFALSE, " ", ok );
      
      chcksl_c ( "found", found, SPICETRUE, ok );
   
      chcksc_c ( "file",  file, "=", files[i], ok );
      chcksc_c ( "type",  type, "=", types[i], ok );
      
      chcksi_c ( "strlen(source)",  strlen(source), "=", 0, 0, ok );
      
      /*
      Check the handle by mapping it back to the file name.
      */
      
      dafhfn_ ( &handle, file, FILEN-1 );
      F2C_ConvertStr ( FILEN, file );
      chcksc_c ( "file",  file, "=", files[i], ok );
   }
   
   
   /*
   Check kdata_c string error cases:
   
      1) Null file spec string.
      2) Empty file spec string.
      3) Null file name string.
      4) File name string too short.
      5) Null type string.
      6) Type string too short.
      7) Null source string.
      8) Source string too short.
      
   */

   kdata_c ( 0,     NULLCPTR,  FILEN,   TYPLEN,   SRCLEN,  
             file,  type,      source,  &handle,  &found );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   kdata_c ( 0,     "",        FILEN,   TYPLEN,   SRCLEN,  
             file,  type,      source,  &handle,  &found );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );

   
   kdata_c ( 0,          "All",     FILEN,   TYPLEN,   SRCLEN,  
             NULLCPTR,   type,      source,  &handle,  &found );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   
   kdata_c ( 0,          "All",     1,       TYPLEN,   SRCLEN,  
             file,       type,      source,  &handle,  &found );
   chckxc_c ( SPICETRUE, "SPICE(STRINGTOOSHORT)", ok );

   
   kdata_c ( 0,          "All",     FILEN,   TYPLEN,   SRCLEN,  
             file,       NULLCPTR,  source,  &handle,  &found );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   kdata_c ( 0,          "All",     FILEN,   1,        SRCLEN,  
             file,       type,      source,  &handle,  &found );
   chckxc_c ( SPICETRUE, "SPICE(STRINGTOOSHORT)", ok );

   
   kdata_c ( 0,          "All",     FILEN,     TYPLEN,   SRCLEN,  
             file,       type,      NULLCPTR,  &handle,  &found );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   kdata_c ( 0,          "All",     FILEN,   TYPLEN,   1,  
             file,       type,      source,  &handle,  &found );
   chckxc_c ( SPICETRUE, "SPICE(STRINGTOOSHORT)", ok );

   
   
   /*
   Case 4:
   */
   tcase_c ( "Test kinfo_c. Get kernel info by kernel name." );

   
   
   for ( i = 0;  i < count;  i++ )
   {
      chckxc_c ( SPICEFALSE, " ", ok );

      kinfo_c ( files[i],  TYPLEN,   SRCLEN,  
                type,      source,  &handle,  &found );
                
      chckxc_c ( SPICEFALSE, " ", ok );
      
      chcksl_c ( "found", found, SPICETRUE, ok );
   
      chcksc_c ( "type",  type, "=", types[i], ok );
      
      chcksi_c ( "strlen(source)",  strlen(source), "=", 0, 0, ok );
      
      /*
      Check the handle by mapping it back to the file name.
      */
      
      dafhfn_ ( &handle, file, FILEN-1 );
      F2C_ConvertStr ( FILEN, file );
      chcksc_c ( "file",  file, "=", files[i], ok );
   }
   
   
   /*
   Check kinfo_c string error cases:
   
      1) Null file name string.
      2) Empty file name string.
      3) Null type string.
      4) Type string too short.
      5) Null source string.
      6) Source string too short.
      
   */

   kinfo_c ( NULLCPTR,  TYPLEN,   SRCLEN,  
             type,      source,  &handle,  &found );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   kinfo_c ( "",        TYPLEN,   SRCLEN,  
             type,      source,  &handle,  &found );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );

   
   kinfo_c ( SPK,        TYPLEN,   SRCLEN,  
             NULLCPTR,   source,  &handle,  &found );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   
   kinfo_c ( SPK,        1,       SRCLEN,  
             type,       source,  &handle,  &found );
   chckxc_c ( SPICETRUE, "SPICE(STRINGTOOSHORT)", ok );

   
   kinfo_c ( SPK,        TYPLEN,    SRCLEN,  
             type,       NULLCPTR,  &handle,  &found );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   kinfo_c ( SPK,        TYPLEN,    1,  
            type,        source,  &handle,  &found );
   chckxc_c ( SPICETRUE, "SPICE(STRINGTOOSHORT)", ok );

      
   
   
   /*
   Case 5:
   */
   tcase_c ( "Test unload_c.  Unload the kernels; make sure the "
             "count becomes zero."                                );

   
   unload_c ( SPK );
   chckxc_c ( SPICEFALSE, " ", ok );
 
   ktotal_c ( "All", &count );
   chckxc_c ( SPICEFALSE, " ", ok );
               
   /*
   There should be one kernel loaded.
   */
   chcksi_c ( "count", count, "=", 1, 0, ok );
   
 
   unload_c ( CK );
   chckxc_c ( SPICEFALSE, " ", ok );
 
   ktotal_c ( "All", &count );
   chckxc_c ( SPICEFALSE, " ", ok );
               
   /*
   There should be zero kernels loaded.
   */
   chcksi_c ( "count", count, "=", 0, 0, ok );
   
   /*
   Check unload_c string error cases:
   
      1) Null filename string.
      2) Empty filename string.      
   */
   
   unload_c ( NULLCPTR );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   unload_c ( "" );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );



   /*
   Case 6:
   */
   tcase_c ( "Test kdata_c and kinfo_c in the meta-kernel case. " 
             "Make sure the kernel `source' is correctly identified." );


   /*
   Create a new meta-kernel.  The contents will be:
   
   
      \begindata
      
      KERNELS_TO_LOAD =  ( 'keeptest.bsp',
                           'keeptest.bc',
                           'keeptest.tsc' )
      
      
   */
   
   if ( exists_c(META) )
      {
      TRASH ( META );
      }

   txtopn_  ( META, &unit, strlen(META) );
   chckxc_c ( SPICEFALSE, " ", ok );
 
   for ( i = 0;  i < NMETA;  i++ )
      {
      writln_ (  metatxt[i], &unit, strlen(metatxt[i]) );
      chckxc_c ( SPICEFALSE, " ", ok );
      }
   
   ftncls_c ( unit );
   chckxc_c ( SPICEFALSE, " ", ok );
 
   /*
   Ok, see if furnsh_c likes our artistic efforts.
   */
   furnsh_c ( META );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   /*
   There should be one SPK loaded.
   */
   ktotal_c ( "SPK", &count );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "SPK count", count, "=", 1, 0, ok );
      
               
   /*
   There should be one CK loaded.
   */
   ktotal_c ( "CK", &count );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "CK count", count, "=", 1, 0, ok );
      
               
   /*
   There should be one text kernel loaded.
   */
   ktotal_c ( "text", &count );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "Text kernel count", count, "=", 1, 0, ok );
      
               
   /*
   There should be one (meta) kernel loaded.
   */
   ktotal_c ( "META", &count );
   chcksi_c ( "Meta kernel count", count, "=", 1, 0, ok );
   
   
   
   /*
   Now repeat test case 3, this time checking the source string.
   */
   
   ktotal_c ( "SPK CK Text", &count );
   chcksi_c ( "Loaded kernel count", count, "=", 3, 0, ok );
   
   for ( i = 0;  i < count;  i++ )
   {
      kdata_c ( i,     "SPK CK Text",  FILEN,   TYPLEN,   SRCLEN,  
                file,  type,   source,  &handle,  &found );
                
      chckxc_c ( SPICEFALSE, " ", ok );
      
      chcksl_c ( "found", found, SPICETRUE, ok );
   
      chcksc_c ( "file",  file, "=", files[i], ok );
      chcksc_c ( "type",  type, "=", types[i], ok );
      
      chcksc_c ( "source",  source, "=", META, ok );
      
      /*
      Check the handle by mapping it back to the file name.
      */
      
      if (  eqstr_c (type, "SPK") || eqstr_c (type, "CK")  )
      {
         dafhfn_ ( &handle, file, FILEN-1 );
         F2C_ConvertStr ( FILEN, file );
         chcksc_c ( "file",  file, "=", files[i], ok );
      }
   }
   
   
   /*
   Now repeat test case 4, this time checking the source string.
   */
   
   for ( i = 0;  i < 2;  i++ )
   {
      chckxc_c ( SPICEFALSE, " ", ok );

      kinfo_c ( files[i],  TYPLEN,   SRCLEN,  
                type,      source,  &handle,  &found );
                
      chckxc_c ( SPICEFALSE, " ", ok );
      
      chcksl_c ( "found", found, SPICETRUE, ok );
   
      chcksc_c ( "type",  type, "=", types[i], ok );
      
      chcksc_c ( "source",  source, "=", META, ok );
      
      /*
      Check the handle by mapping it back to the file name.
      */
      
      if (  eqstr_c (type, "SPK") || eqstr_c (type, "CK")  )
      {
         dafhfn_ ( &handle, file, FILEN-1 );
         F2C_ConvertStr ( FILEN, file );
         chcksc_c ( "file",  file, "=", files[i], ok );
      }
   }


   /*
   Clean up the files we created.
   */
   
   unload_c ( META );
   chckxc_c ( SPICEFALSE, " ", ok );

   TRASH ( CK   );
   TRASH ( SPK  );
   TRASH ( SCLK );
   TRASH ( META );
   
   
   /*
   Retrieve the current test status.
   */ 
   t_success_c ( ok ); 
   
   
} /* End f_keep_c */

