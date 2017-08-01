/*

-Procedure tsttxt_c (Create a test text file.)

-Abstract
 
   Create and if appropriate load a test NAIF text kernel. 
 
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
   #include <stdlib.h>
   #include <assert.h>
   #include "tutils_c.h"
   #include "SpiceUsr.h"
   #include "SpiceZfc.h"
   #include "SpiceZst.h"
   #include "SpiceZmc.h"
   
   

   void tsttxt_c ( ConstSpiceChar    * namtxt,
                   void              * txt,
                   SpiceInt            nlines,
                   SpiceInt            lenvals,
                   SpiceBoolean        load,
                   SpiceBoolean        keep     ) 

/*

-Brief_I/O
 
   VARIABLE  I/O  DESCRIPTION 
   --------  ---  -------------------------------------------------- 
   namtxt     I   The name of the NAIF text kernel to create.
   txt        I   An array of lines of text to be stored in a file. 
   nlines     I   The number of lines of text. 
   lenvals    I   Length of lines in text array.
   load       I   Load the text kernel if SPICETRUE. 
   keep       I   Keep the text kernel if SPICETRUE, else delete it. 
 
-Detailed_Input
 
   namtxt      is the name of a text file to create and load (via
               ldpool_) if load is set to SPICETRUE.  If a file of the
               same name already exists it is deleted.
 
   txt         is an array of character strings that will make up the
               text in the file to be created.  txt should be declared
               as shown:
               
                  SpiceChar   txt[nlines][lenvals]
                  
 
   nlines      is the number of lines of text supplied via LINES. 
 
   lenvals     is the common length of the strings in the array txt.
               The terminating null is included in the count.
               
   load        is a logical that indicates whether or not the text file
               should be loaded after it is created.  If it has the
               value TRUE the loaded is loaded after it is created.
               Otherwise it is left un-opened.
 
   keep        is a logical that indicates whether or not the text file
               should be deleted after it is loaded.  If keep is
               SPICETRUE the file is not deleted.  If keep is
               SPICEFALSE, the file is deleted after it is loaded. NOTE
               that unless load is SPICETRUE, the text file is not
               deleted by this routine.  This routine deletes the text
               file only if load is SPICETRUE and KEEP is SPICEFALSE.
 
-Detailed_Output
 
   None. 
 
-Parameters
 
   None. 
 
-Files

   See Detailed Input and Particulars.
 
-Exceptions
 
   None. 
 
-Particulars
 
   This routine creates a text file to be used during testing and 
   will at the users discretion load this text file into the 
   kernel pool and delete the file after loading it. 
 
-Examples
 
   This is intended to be used in those instances when you 
   need a text kernel for use during testing but do not want 
   to require that a file be present on the platform where you 
   are performing the testing.  By using this routine you can 
   imbed the test file in your test program, create it when it 
   is needed and delete it when you are through using it. 
 
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
 
   Create test CK and SCLK files. 
 
-&
*/

{ /* Begin tsttxt_c */


   /*
   Local variables
   */

   SpiceChar            ** strptrs;
   SpiceChar             * fTxtArr;

   SpiceInt                fTxtLen;
   SpiceInt                i;





   /*
   Check input pointers and string lengths.
   */
   assert( namtxt          !=  NULLCPTR  );
   assert( strlen(namtxt)  >   0         );
   
   assert( txt             !=  (void *)0 );
   assert( lenvals         >   1         );
   

   /*
   We're going to need a Fortran style array of strings to pass to 
   the f2c'd routine lmpool_.  We can create such an array using
   dynamically allocated memory by calling C2F_CreateStrArr.  But first,
   we'll need an array of character pointers, each one pointing to a
   string in the input txt array.
   */

   strptrs = (SpiceChar **) malloc( (size_t) nlines 
                                           * sizeof(SpiceChar *) );

   if ( strptrs == 0 )
   {
      setmsg_c ( "Failure on malloc call to create pointer array "
                 "for string values."                              );
      sigerr_c ( "SPICE(MALLOCFAILED)"                             );
      chkout_c ( "lmpool_c"                                        );
      return;
   }

   /*
   Getting this far means we succeeded in allocating our character
   pointer array.  Assign the pointers.
   */
   
   for ( i = 0;  i < nlines;  i++ )
   {
      strptrs[i] =  ( (SpiceChar *) txt )  +  i * lenvals;
   }

   /*
   Create a Fortran-style string array.
   */
   C2F_CreateStrArr (   nlines, 
                      ( ConstSpiceChar ** ) strptrs, 
                       &fTxtLen, 
                       &fTxtArr                      );

   if ( failed_c() )
   {
      free ( strptrs );
      return;
   }


   /*
   Call the f2c'd routine.
   */
   tsttxt_ (  ( char       * ) namtxt,
              ( char       * ) fTxtArr,
              ( integer    * ) &nlines,
              ( logical    * ) &load,
              ( logical    * ) &keep,
              ( ftnlen       ) strlen(namtxt),
              ( ftnlen       ) fTxtLen        );


   /*
   Free the dynamically allocated arrays.
   */
   free ( fTxtArr );
   free ( strptrs );

 
} /* End tsttxt_c */

