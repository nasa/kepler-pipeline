/*
 
-Procedure tclose_c (Close testing.)
 
-Abstract
 
   Close out all  testing.
 
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
   #include <assert.h>
   #include "SpiceUsr.h"
   #include "SpiceZfc.h"
   #include "SpiceZst.h"
   #include "tutils_c.h"
 
   void tclose_c ( void )
 
/*
 
-Brief_I/O
 
    None.
 
-Detailed_Input
 
   None.
 
-Detailed_Output
 
   None.
 
-Parameters
 
    None.
 
-Files
 
    None.
 
-Exceptions
 
   Error free.
 
-Particulars
 
   This routine takes care of the problems of finishing a test
   program.  It displays a summary of all testing, closes the
   test log and failure log.  If no failures have occurred the
   file 'passage.tst' is created and filled with a brief message
   to indicate that all tests passed.
 
-Examples
 
 
   #include "SpiceUsr.h"
        .
        .
        .
   /.
   Test functions
   ./
   SpiceBoolean            t_myroutine ( void );
   SpiceBoolean            t_routine2  ( void );
 
   /.
   Local variables
   ./
   SpiceBoolean            result;
 
   /.
   Enable the testing software.
   ./
 
   tsetup_c ( "test{0-9}{0-9}{0-9}{0-9}.log", "1.0.0" )
 
   /.
   Open the first test case.
   ./
   topen_c  ( "myroutine" );
   result = t_myroutine();
 
   topen_c ( "routine2" );
   result = result && t_routine2();
 
   tclose_c();
 
 
-Restrictions
 
   None.
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
   W.L. Taber      (JPL)
 
-Literature_References
 
   None.
 
-Version
 
   -tutils_c Version 1.0.0, 12-JUN-1999 (NJB) (WLT)
 
-&
*/
 
{ /* Begin tclose_c */
 
 
 
 
   tclose_ ();
 
 
 
} /* End tclose_c */
