/*
 
-Procedure topen_c (Open a family of tests)
 
-Abstract
 
   Open a collection of tests
 
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
 
   void topen_c ( ConstSpiceChar * name )
 
/*
 
-Brief_I/O
 
   VARIABLE  I/O  DESCRIPTION
   --------  ---  --------------------------------------------------
   name       I   The name of a family of tests.
 
-Detailed_Input
 
   name        is the name of some collection of tests that are
               to be performed.  Often this is simply the name
               of a subroutine that is to be tested.
 
               name should be no more than 32 characters in length.
 
               Longer names will be truncacted to 32 characters by
               the testing utilities.
 
-Detailed_Output
 
   None.
 
-Parameters
 
   None.
 
-Files
 
   None.
 
-Exceptions
 
   Error free.
 
-Particulars
 
   This routine establishes a new test family.   It acts by
   side effect, setting up the various test utilities that need
   to be initialized before beginning a series of tests. It logs
   that this task has been accomplished.
 
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
 
   N.J. Bachamn     (JPL)
   W.L. Taber       (JPL)
 
-Literature_References
 
   None.
 
-Version
 
   -tutils_c Version 1.0.0, 12-JUN-1999 (NJB) (WLT)
 
 
-&
*/
 
{ /* Begin topen_c */
 
 
 
 
   /*
   Do NOT participate in error tracing; it confuses the underlying code.
   */
 
 
   assert ( name          !=  NULLCPTR );
   assert ( strlen(name)  >   0        );
 
 
   topen_ (  ( char   * ) name,
             ( ftnlen   ) strlen(name)  );
 
 
} /* End topen_c */
