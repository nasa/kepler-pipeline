/*
 
-Procedure chckxc_c ( Check exceptions )
 
 
-Abstract
 
   Check whether an expected short error message was signaled.
 
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
   #include "SpiceZmc.h"
   #include "tutils_c.h"
 
 
   void chckxc_c ( SpiceBoolean       except,
                   ConstSpiceChar   * shmsg,
                   SpiceBoolean     * ok     )
 
/*
 
-Brief_I/O
 
   VARIABLE  I/O  DESCRIPTION
   --------  ---  --------------------------------------------------
   except     I   Logical indicating if an exception should exist.
   shmsg      I   The short error string associated with exception.
   ok         O   SPICETRUE if the test passes, SPICEFALSE otherwise.
 
-Detailed_Input
 
   except      is a logical that indicates whether or not an
               exception should have occurred.  If except is
               SPICETRUE an exception is expected. Otherwise no
               exception is expected.
 
   shmsg       is the short error message that is associated
               with an exception.  shmsg will be used only if
               except is SPICETRUE.  Otherwise it is ignored as no
               exception is expected.
 
-Detailed_Output
 
   ok         if the check exception condition is successful then
              ok is given the value SPICETRUE.  Otherwise ok is given
              the value SPICEFALSE and a diagnostic message is sent to
              the test logger.
 
-Parameters
 
   None.
 
-Files
 
   The result of a failure is automatically logged in the testing
   log file and failure file.  Success is logged only if verbose
   testing has been enabled.
 
-Exceptions
 
   Error free.
 
-Particulars
 
   This routine checks that exceptions handling has the expected
   status.
 
-Examples
 
   Suppose that you have just made a call to a subroutine that
   you wish to test (call the routine spud) and you would like
   to test the handling of some exception.  Using
   this routine you can automatically have the test result logged
   in via the testing utitities.
 
      spud     (  input,  output );
      chckxc_c (  expect, SPICE(ERRORMESSAGE), &ok );
 
-Restrictions
 
   None.
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
   W.L. Taber      (JPL)
 
-Literature_References
 
   None.
 
-Version
 
   -tutils_c Version 1.0.0 12-JUN-1999 (NJB) (WLT)
 
-&
*/
 
{ /* Begin chckxc_c */
 
 
 
   /*
   Local variables
   */
   logical                 shonuff;
 
 
 
 
   assert ( shmsg          !=  NULLCPTR );
   assert ( strlen(shmsg)  >   0        );
 
   chckxc_  ( ( logical  * ) &except,
              ( char     * ) shmsg,
              ( logical  * ) &shonuff,
              ( ftnlen     ) strlen(shmsg) ) ;
 
   *ok = shonuff;
 
 
 
} /* End chckxc_c */
