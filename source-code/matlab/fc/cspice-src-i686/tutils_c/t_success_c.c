 
/*
 
-Procedure t_success_c ( test success )
 
-Abstract
 
   Indicate whether all test cases since set up via t_begin_ have
   passed.
 
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
   #include "SpiceZfc.h"
   #include "SpiceUsr.h"
   #include "tutils_c.h"
 
   void t_success_c ( SpiceBoolean *ok )
 
 
/*
 
-Brief_I/O
 
   VARIABLE  I/O  DESCRIPTION
   --------  ---  --------------------------------------------------
   ok         O   Status flag.
 
-Detailed_Input
 
   None.
 
-Detailed_Output
 
   ok             is a logical flag which indicates whether all tests
                  set up via t_begin_ have passed.
 
-Parameters
 
   None.
 
-Files
 
   None.
 
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
   W.L. Taber       (JPL)
 
-Literature_References
 
   None.
 
-Version
 
   -tutils_c Version 1.0.0, 12-JUN-1999 (NJB) (WLT)
 
-Index_Entries
 
   Initializing a test case.
 
-&
*/
 
{ /* Begin t_success_c */
 
 
   /*
   Local variables
   */
   logical                shonuff;
 
 
 
 
   t_success__ ( ( logical * ) &shonuff );
 
 
   *ok = shonuff;
 
 
 
} /* End t_success_c */
