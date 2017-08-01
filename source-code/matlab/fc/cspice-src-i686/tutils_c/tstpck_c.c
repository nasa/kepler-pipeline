/*

-Procedure tstpck_c (Create a test PCK file)

-Abstract
 
   Create and if appropriate load a test PCK kernel. 
 
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
   #include <string.h>
   #include "tutils_c.h"
   #include "SpiceUsr.h"
   #include "SpiceZfc.h"
   #include "SpiceZmc.h"
   

   void tstpck_c ( ConstSpiceChar  * namepc,
                   SpiceBoolean      loadpc,
                   SpiceBoolean      keeppc ) 

/*

-Brief_I/O
 
    VARIABLE  I/O  DESCRIPTION 
    --------  ---  -------------------------------------------------- 
    namepc     I   The name of the PC-kernel to create 
    loadpc     I   Load the PC-kernel if SPICETRUE 
    keeppc     I   Keep the PC-kernel if SPICETRUE, else delete it. 
 
-Detailed_Input
 
   namepc      is the name of a PC-kernel to create and load if 
               loadpc is set to SPICETRUE.  If a PC-kernel of the same 
               name already exists it is deleted. 
 
 
   loadpc      is a logical that indicates whether or not the PCK 
               file should be loaded after it is created.  If it 
               has the value SPICETRUE the PC-kernel is loaded after 
               it is created.  Otherwise it is left un-opened. 
 
 
   keeppc      is a logical that indicates whether or not the PCK 
               file should be deleted after it is loaded.  If keeppc 
               is SPICETRUE the file is not deleted.  If keeppc is 
               SPICEFALSE the file is deleted after it is loaded.  Note 
               that unless loadsc is SPICETRUE, the PCK file is not 
               deleted by this routine.  This routine deletes the 
               PC-kernel only if it loadsc is SPICETRUE and KEEPPC is 
               SPICEFALSE. 
 
-Detailed_Output
 
   None. 
 
-Parameters
 
   None. 
 
-Files
 
-Exceptions
 
   None. 
 
-Particulars
 
   This routine creates a planetary constants file for use in 
   testing. 
 
-Examples
 
   This is intended to be used in those instances when you 
   need a well defined PC-kernel for use in testing.  By using 
   this routine you can avoid having to know in advance where 
   a PCK file is on the system where you plan to do your testing. 
 
-Restrictions
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
   W.L. Taber      (JPL) 
 
-Literature_References
 
   None. 
 
-Version
 
   -CSPICE Version 1.0.0, 27-JUN-1999 (NJB) (WLT)

-Index_Entries
 
   Create test PCK file. 
 
-&
*/

{ /* Begin tstpck_c */


   /*
   Local constants
   */
   logical                 ldpc;
   logical                 kppc;

 
   ldpc = loadpc;
   kppc = keeppc;
   
   assert( namepc          !=  NULLCPTR  );
   assert( strlen(namepc)  >   0         );  
   
   tstpck_ (  ( char    * ) namepc,
              ( logical * ) &ldpc,
              ( logical * ) &kppc,
              ( ftnlen    ) strlen(namepc)  );
 
} /* End tstpck_c */
