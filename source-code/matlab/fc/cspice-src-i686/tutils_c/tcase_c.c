/*
 
-Procedure tcase_c (Test Case)
 
-Abstract
 
   Set the title for the next test case and log the success of
   the last test case if it passed and logging of individual
   test case success is enabled.
 
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
 
   void tcase_c ( ConstSpiceChar * title )
 
/*
 
-Brief_I/O
 
   VARIABLE  I/O  DESCRIPTION
   --------  ---  --------------------------------------------------
   title      I   The title of this test case.
 
-Detailed_Input
 
   title       is the title of a test case.  It should have no
               more than 32 characters.  If it does characters
               beyond the thirty second character are ignored.
 
-Detailed_Output
 
   None.
 
-Parameters
 
   None.
 
-Files
 
   If test case success logging is enabled, the previous test
   case success is logged to SCREEN and the log file.
 
-Exceptions
 
   Error free.
 
-Particulars
 
   This is the user interface routine for initializing test cases.
 
-Examples
 
   Later.
 
-Restrictions
 
   None.
 
-Author_and_Institution
 
   N.J. Bachman     (JPL)
   W.L. Taber      (JPL)
 
-Literature_References
 
   None.
 
-Version
 
   -tutils_c Version 1.0.0, 12-JUN-1999 (NJB) (WLT)
 
-Index_Entries
 
   Initializing a test case.
 
-&
*/
 
{ /* Begin tcase_c */
 
 
 
   /*
   Do NOT participate in error tracing; it confuses the underlying code.
   */
 
 
   assert ( title          !=  NULLCPTR );
   assert ( strlen(title)  >   0        );
 
 
   tcase_ ( ( char   * ) title,
            ( ftnlen   ) strlen(title) );
 
 
 
} /* End tcase_c */
