/*

-Procedure tstlsk_c ( Test Leapseconds Kernel )

-Abstract
 
  This test utility routine creates a leapsecond kernel 
  (valid as of July 1, 1997) loads the file into the 
  kernel pool, and then deletes the resulting file. 
 
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
 
   TEST UTILITIES 
 
*/
   #include "tutils_c.h"
   #include "SpiceUsr.h"
   #include "SpiceZfc.h"
   #include "SpiceZst.h"

   void tstlsk_c ( void ) 

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
 
   A leapseconds kernel is created, loaded into the kernel pool 
   and then deleted. 
 
-Exceptions
 
   Error free. 
 
-Particulars
 
   This routine creates a temporary file based on the file 
   naming pattern (see NEWFIL_1 in support for details) 
 
       lsk{0-9}{0-9}{0-9}{0-9}.tmp 
 
   The resulting file is loaded into the kernel pool and 
   then deleted. 
 
   The fact that this file is created is logged in the 
   test log file. 
 
-Examples
 
   Suppose that you are testing some portion of the toolkit 
   that requires the use of a leapseconds kernel.  This routine 
   allows you to load a leapseconds kernel without having to 
   know where a current leapsecond kernel is located on the 
   file system. 
 
      tstlsk_c 
 
-Restrictions
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
   W.L. Taber      (JPL) 
 
-Literature_References
 
   None. 
 
-Version
 
   -tutils_c Version 1.0.0, 27-JUN-1999 (NJB) (WLT)

-Index_Entries
 
   Generate and load a leapseconds kernel for testing. 
 
-&
*/

{ /* Begin tstlsk_c */


   tstlsk_();
   
   
} /* End tstlsk_c */
