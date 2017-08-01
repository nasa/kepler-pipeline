/*

-Procedure f_das01_c ( Test wrappers for DAS routines, subset 1 )

 
-Abstract
 
   Perform tests on CSPICE wrappers for a subset of the DAS 
   routines.
    
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
   

   void f_das01_c ( SpiceBoolean * ok )

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
 
   This routine tests the wrappers for a subset of the CSPICE DAS
   routines. 
   
   The subset is:
      
      dasac_c
      dasec_c

-Examples
 
   None.
    
-Restrictions
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
 
-Literature_References
 
   None. 
 
-Version
 
   -tspice_c Version 1.1.0 02-MAR-2003 (NJB)  

       Added separate tcase_c calls for error cases.

   -tspice_c Version 1.0.0 25-FEB-2003 (NJB)  

-&
*/

{ /* Begin f_das01_c */

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
   #define EK1             "test1.ek"
   #define MAXROW          20
   #define MAXBUF          100
   #define LNSIZE          101

   /*
   Local variables
   */
   SpiceBoolean            done;

   SpiceChar               buffer  [MAXBUF][LNSIZE];
   SpiceChar               buffer2 [MAXBUF][LNSIZE];
   SpiceChar               label   [LNSIZE];


   SpiceInt                fileno;
   SpiceInt                handle;
   SpiceInt                i;
   SpiceInt                n;

   void                  * ptr;



   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_das01_c" );
   
   /*
   Fill the comment buffer. 
   */
   for ( i = 0;  i < MAXBUF;  i++ )
   {
      sprintf ( buffer[i], 
                "This is line %3ld of the text buffer----"
                "--------------------------------------->",
                i                                            );
   }       



   tcase_c ( "Create a test EK as a sample DAS file." );
   fileno = 0;
  
   tstek_c  ( EK1, fileno, MAXROW, SPICEFALSE, &handle, ok );
   chckxc_c ( SPICEFALSE, " ", ok );





   tcase_c ( "Add the buffer contents to the comment area of the EK." );

   ekopw_c ( EK1, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );

   dasac_c ( handle, MAXBUF, LNSIZE, buffer );
   chckxc_c ( SPICEFALSE, " ", ok );

   ekcls_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );





   tcase_c ( "Extract the buffer contents from the comment area "
             "of the EK."                                        );

   ekopr_c ( EK1, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );

   dasec_c ( handle, MAXBUF, LNSIZE, &n, buffer2, &done );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "buffer count", n, "=", MAXBUF, 0, ok );

   chcksl_c ( "done", done, SPICETRUE, ok );
   
   for ( i = 0;  i < MAXBUF;  i++ )
   {
      sprintf ( label, "buffer line #%ld", i );

      chcksc_c ( label, buffer2[i], "=",  buffer[i], ok );
   }       




   tcase_c ( "Extract the buffer contents from the comment area "
             "of the EK, but this time do it in two chunks."      );

   for ( i = 0;  i < MAXBUF;  i++ )
   {
      sprintf ( buffer2[i], "%s", "" );
   }       

   dasec_c ( handle, MAXBUF/2, LNSIZE, &n, buffer2, &done );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "buffer count (0)", n, "=", MAXBUF/2, 0, ok );

   chcksl_c ( "done (0)", done, SPICEFALSE, ok );
   
   ptr = buffer2[MAXBUF/2];

   dasec_c ( handle, MAXBUF/2, LNSIZE, &n, ptr, &done );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "done (1)", done, SPICETRUE, ok );

   chcksi_c ( "buffer count (1)", n, "=", MAXBUF/2, 0, ok );
   for ( i = 0;  i < MAXBUF;  i++ )
   {
      sprintf ( label, "buffer line #%ld", i );

      chcksc_c ( label, buffer2[i], "=",  buffer[i], ok );
   }       

   tcase_c ( "Repeat the previous test to make sure dasec_c has "
             "been re-initialized when the last comments were read."  );


   for ( i = 0;  i < MAXBUF;  i++ )
   {
      sprintf ( buffer2[i], "%s", "" );
   }       

   dasec_c ( handle, MAXBUF/2, LNSIZE, &n, buffer2, &done );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "buffer count (0)", n, "=", MAXBUF/2, 0, ok );

   chcksl_c ( "done (0)", done, SPICEFALSE, ok );
   
   ptr = buffer2[MAXBUF/2];

   dasec_c ( handle, MAXBUF/2, LNSIZE, &n, ptr, &done );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "done (1)", done, SPICETRUE, ok );

   chcksi_c ( "buffer count (1)", n, "=", MAXBUF/2, 0, ok );
   for ( i = 0;  i < MAXBUF;  i++ )
   {
      sprintf ( label, "buffer line #%ld", i );

      chcksc_c ( label, buffer2[i], "=",  buffer[i], ok );
   }       


   /*
   dasac_c error checks: 
   */
   tcase_c ( "Set up for dasac_c error checks." );

   ekcls_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );

   ekopw_c ( EK1, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );


   tcase_c ( "Negative buffer size." );

   dasac_c ( handle, -1, LNSIZE, buffer );
   chckxc_c ( SPICETRUE, "SPICE(INVALIDARGUMENT)", ok );


   tcase_c ( "Null buffer pointer." );

   dasac_c ( handle, MAXBUF, LNSIZE, NULLCPTR );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );


   tcase_c ( "String length 1." );

   dasac_c ( handle, MAXBUF, 1, buffer );
   chckxc_c ( SPICETRUE, "SPICE(STRINGTOOSHORT)", ok );


   tcase_c ( "Non-printing character in buffer." );
   buffer[0][0] = 1;

   dasac_c ( handle, MAXBUF, LNSIZE, buffer );
   chckxc_c ( SPICETRUE, "SPICE(ILLEGALCHARACTER)", ok );

   buffer[0][0] = (SpiceChar)'T';

   /*
   dasec_c error checks: 
   */
   tcase_c ( "Set up for dasac_c error checks." );
   ekcls_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );

   ekopr_c ( EK1, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );


   tcase_c ( "Negative buffer size." );

   dasec_c ( handle, -1, LNSIZE, &n, buffer2, &done );
   chckxc_c ( SPICETRUE, "SPICE(INVALIDARGUMENT)", ok );


   tcase_c ( "Null buffer pointer." );

   dasec_c ( handle, MAXBUF, LNSIZE, &n, NULLCPTR, &done );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );


   tcase_c ( "String length 1." );

   dasec_c ( handle, MAXBUF, 1, &n, buffer2, &done );
   chckxc_c ( SPICETRUE, "SPICE(STRINGTOOSHORT)", ok );


   tcase_c ( "Comment line too long." );

   dasec_c ( handle, MAXBUF, 10, &n, buffer2, &done );
   chckxc_c ( SPICETRUE, "SPICE(COMMENTTOOLONG)", ok );


   /*
   Get rid of the EK file.
   */

   ekcls_c ( handle );

   TRASH   ( EK1 );
   
   

   
   /*
   Retrieve the current test status.
   */ 
   t_success_c ( ok ); 
   
   
} /* End f_das01_c */

