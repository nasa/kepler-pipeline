/*

-Procedure f_errh_c ( Test wrappers for error handling routines )

 
-Abstract
 
   Perform tests on CSPICE wrappers for the error handling routines.
    
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
   

   void f_errh_c ( SpiceBoolean * ok )

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
 
   This routine tests the wrappers for a subset of the error
   handling routines. 
   
   The subset is:
      
      erract_c
      errch_c
      errdev_c
      errdp_c
      errint_c
      errprt_c
      getmsg_c
      reset_c
      return_c
      setmsg_c
      sigerr_c
      
      
-Examples
 
   None.
    
-Restrictions
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
 
-Literature_References
 
   None. 
 
-Version
 
   -tspice_c Version 3.0.0 24-JUN-2003 (NJB) 

      Added test cases in which invalid operation flags are passed to
      erract_c, errdev_c, and errprt_c.

   -tspice_c Version 2.0.0 28-AUG-1999 (NJB) 
   
      Added tests for all functions other than getmsg_c.
       
   -tspice_c Version 1.0.0 22-JUL-1999 (NJB)  

-&
*/

{ /* Begin f_errh_c */

 
   /*
   Constants
   */
   #define ACTLEN          25
   #define DEVLEN          256
   #define LSTLEN          81
   #define MSGLEN          ( (23*80) + 1 )
   #define SMSLEN          26
   #define LONGMSG         "This is the long error message."
   #define SHRTMSG         "Short error message."
     

   /*
   Local variables
   */
   SpiceBoolean            status;
   SpiceBoolean            rstatus;

   SpiceChar               actstr [ ACTLEN ];
   SpiceChar               devstr [ DEVLEN ];
   SpiceChar               lmsg   [ MSGLEN ];
   SpiceChar               msg    [ MSGLEN ];
   SpiceChar               msgstr [ LSTLEN ];
   SpiceChar               smsg   [ SMSLEN ];
   SpiceChar               svact  [ ACTLEN ];
   SpiceChar               svdev  [ DEVLEN ];
   SpiceChar               svmsg  [ LSTLEN ];


   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_errh_c" );
   

      
      

   
      
   /*
   Case 1:  
   */
   
   tcase_c ( "Test errdev_c" );

   /*
   Obtain and save the current error handling attributes.
   */
   erract_c ( "get", ACTLEN, svact );
   errdev_c ( "get", DEVLEN, svdev );
   errprt_c ( "get", LSTLEN, svmsg );
   chckxc_c ( SPICEFALSE, " ", ok  );  
      
   errdev_c ( "SET", DEVLEN, "SCREEN" );
   chckxc_c ( SPICEFALSE, " ", ok  );  

   errdev_c ( "get", DEVLEN, devstr );
   chckxc_c ( SPICEFALSE, " ", ok  );  
   chcksc_c ( "stored error device string", devstr, "=", "SCREEN", ok );
   
   /*
   Restore previous error device.
   */
   errdev_c ( "set", DEVLEN, svdev );
   chckxc_c ( SPICEFALSE, " ", ok  );  

   /*
   Try invalid operation request. 
   */
   errdev_c ( "xxx", ACTLEN, svact );
   chckxc_c ( SPICETRUE, "SPICE(INVALIDOPERATION)", ok  );  


   /*
   Case 2:  
   */
   
   tcase_c ( "Test erract_c" );
 
   erract_c ( "set", ACTLEN, "ABORT" );
   chckxc_c ( SPICEFALSE, " ", ok  );  

   erract_c ( "get", ACTLEN, actstr );
   chckxc_c ( SPICEFALSE, " ", ok  );  

   chcksc_c ( "stored error action string", actstr, "=", "ABORT", ok );
   
   /*
   Restore previous error action.
   */
   erract_c ( "set", ACTLEN, svact );
   chckxc_c ( SPICEFALSE, " ", ok  );  
   
   /*
   Try invalid operation request. 
   */
   erract_c ( "xxx", ACTLEN, svact );
   chckxc_c ( SPICETRUE, "SPICE(INVALIDOPERATION)", ok  );  
  

   /*
   Case 3:  
   */
   
   tcase_c ( "Test errprt_c" );
 
   errprt_c ( "set", LSTLEN, "NONE, SHORT" );
   chckxc_c ( SPICEFALSE, " ", ok  );  

   errprt_c ( "get", LSTLEN, msgstr );
   chckxc_c ( SPICEFALSE, " ", ok  );  

   chcksc_c ( "enabled error message list", msgstr, "=", "SHORT", ok );
   
   errprt_c ( "set", 
              LSTLEN, 
              "NONE, DEFAULT, TRACEBACK, EXPLAIN, LONG, SHORT" );
   chckxc_c ( SPICEFALSE, " ", ok  );  

   errprt_c ( "get", LSTLEN, msgstr );
   chckxc_c ( SPICEFALSE, " ", ok  );  

   chcksc_c ( "enabled error message list", msgstr, 
              "=", 
              "SHORT, LONG, EXPLAIN, TRACEBACK, DEFAULT", ok );
   
   /*
   Restore previous error message selection.
   */
   errprt_c ( "set", LSTLEN, svmsg );
   chckxc_c ( SPICEFALSE, " ", ok  );  
   
   /*
   Try invalid operation request. 
   */
   errprt_c ( "xxx", ACTLEN, svact );
   chckxc_c ( SPICETRUE, "SPICE(INVALIDOPERATION)", ok  );  
   
   
   /*
   Case 4:
   */
   
   tcase_c ( "Test sigerr_c " );
   
   /*
   Make sure sigerr_c signals an error; check the short message.
   */
   sigerr_c ( SHRTMSG );
   chckxc_c ( SPICETRUE, SHRTMSG, ok );


   /*
   Case 5:
   */
   
   tcase_c ( "Test failed_c " );
   

   status  = failed_c();
   chcksl_c ( "failed_c value", status, SPICEFALSE, ok );

   /*
   Make sure failed_c gets set.
   */
   sigerr_c ( SHRTMSG );
   
   status  = failed_c();
   
   chckxc_c ( SPICETRUE, SHRTMSG, ok );
   chcksl_c ( "failed_c value", status, SPICETRUE, ok );


   /*
   Case 6:
   */

   tcase_c ( "Test return_c " );
   
   /*
   Make sure return_c gets set in "return" mode but not otherwise.
   */
   
   erract_c ( "set", ACTLEN, "report" );
   sigerr_c ( SHRTMSG );
   
   status  = return_c();
   
   chckxc_c ( SPICETRUE, SHRTMSG, ok );
   chcksl_c ( "return_c value", status, SPICEFALSE, ok );



   erract_c ( "set", ACTLEN, "return" );
   sigerr_c ( SHRTMSG );
   
   status  = return_c();
   
   chckxc_c ( SPICETRUE, SHRTMSG, ok );
   chcksl_c ( "return_c value", status, SPICETRUE, ok );


   /*
   Case 7:
   */
   tcase_c ( "Test setmsg_c and getmsg_c; signal an error; "
             "retrieve messages."                             );

   setmsg_c ( LONGMSG );  
   sigerr_c ( SHRTMSG );
   
   getmsg_c ( "SHORT", MSGLEN, msg );
   
   chcksc_c ( "short error message", msg, "=", SHRTMSG, ok );

   getmsg_c ( "long", MSGLEN, msg );

   chcksc_c ( "long error message",  msg, "=", LONGMSG, ok );



   /*
   Case 8:
   */

   tcase_c ( "Test reset_c " );
   
   /*
   Make sure reset_c clears the error status and the error messages.
   */
   
   erract_c ( "set", ACTLEN, "return" );
   
   setmsg_c ( LONGMSG );  
   sigerr_c ( SHRTMSG );
   
   reset_c();

   status  = failed_c();
   rstatus = return_c();
   
   getmsg_c ( "SHORT", SMSLEN, smsg );
   getmsg_c ( "long",  MSGLEN, lmsg );
   
   
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   chcksi_c ( "short error message length", 
               strlen(smsg), 
               "=", 
               0, 
               0,
               ok );


   chcksi_c ( "long error message length",  
               strlen(lmsg), 
               "=", 
               0, 
               0,
               ok );
               

   chcksl_c ( "failed_c value", status, SPICEFALSE, ok );
   chcksl_c ( "return_c value", status, SPICEFALSE, ok );
   


   /*
   Case 9:
   */

   tcase_c ( "Test errch_c, errdp_c, errint_c" );
   
   
   erract_c ( "set", ACTLEN, "return" );
   
   setmsg_c ( "Integer value: #; D.P. value: #; Char value: #." ); 
   errint_c ( "#", 1                                            );
   errdp_c  ( "#", 2.                                           );
   errch_c  ( "#", "three"                                      );
    
   sigerr_c ( SHRTMSG );


   getmsg_c ( "long",  MSGLEN, lmsg );

   chckxc_c ( SPICETRUE, SHRTMSG, ok );

   chcksc_c ( "long error message", 
              lmsg,
              "=",
              "Integer value: 1; D.P. value: 2.0000000000000E+00; "
              "Char value: three.",
              ok                                                      );




   /*
   Restore previous error settings.
   */
   errdev_c ( "set", DEVLEN, svdev );
   chckxc_c ( SPICEFALSE, " ", ok  );  
   
   erract_c ( "set", ACTLEN, svact );
   chckxc_c ( SPICEFALSE, " ", ok  );  
   
   errprt_c ( "set", LSTLEN, svmsg );
   chckxc_c ( SPICEFALSE, " ", ok  );  


   /*
   Retrieve the current test status.
   */ 
   t_success_c ( ok ); 
   
   
} /* End f_errh_c */

