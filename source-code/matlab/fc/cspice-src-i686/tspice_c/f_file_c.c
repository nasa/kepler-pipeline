/*

-Procedure f_file_c ( Test wrappers for file-related routines )

 
-Abstract
 
   Perform tests on CSPICE wrappers for numeric functions. 
 
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
   

   void f_file_c ( SpiceBoolean * ok )

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
 
   This routine tests the wrappers for the CSPICE file I/O and other
   non-kernel-specific, file-related routines.  Covered routines are:
      
      getfat_c
      ftncls_c
      exists_c
      rdtext_c
             
-Examples
 
   None.
    
-Restrictions
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
 
-Literature_References
 
   None. 
 
-Version
 
  -tspice_c Version 2.1.0 11-JAN-2002 (EDW) (NJB)
   
      Added the TRASH macro.  
 
      Now ftncls_c is called to close the "bogus" file before
      attempting to remove the file.
      
   -tspice_c Version 2.2.0 15-OCT-1999 (NJB) 
   
      Added test case for rdtext_c.
      
   -tspice_c Version 2.1.0 21-SEP-1999 (NJB) 
   
      Now closes files before deleting them because the MS Visual C++/C
      compiler requires this (specifically, the files must be closed
      for remove() to delete them).

   -tspice_c Version 2.0.0 03-SEP-1999 (NJB)  

-&
*/

{ /* Begin f_file_c */

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
   #define SPK             "filetest.bsp"
   #define ARCLEN          25
   #define TYPLEN          25
   #define TXT             "testfile.txt"
   #define LINELN          81
   #define LINE1           "Here's a line of text"
   #define LINE2           "Here's a second line of text"
   
   /*
   Local variables
   */                
   logical                 eof;
   SpiceBoolean            bool_eof;

   integer                 unit;
      
   SpiceChar               arch         [ ARCLEN ];
   SpiceChar               bogus        [ LINELN ];
   SpiceChar               line         [ LINELN ];
   SpiceChar               explines [2] [ LINELN ] = { LINE1, LINE2 };
   SpiceChar             * linept;
   SpiceChar               type         [ TYPLEN ];

   SpiceInt                handle;
   SpiceInt                i;



   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_file_c" );
   

   
   /*
   Case 1:
   */
   tcase_c ( "Test getfat_c.  Create an SPK file; see whether " 
             "getfat_c can identify it."                      );


   tstspk_c ( SPK, SPICEFALSE, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   getfat_c ( SPK, ARCLEN, TYPLEN, arch, type );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   chcksc_c ( "architecture", arch, "=", "DAF", ok );
   chcksc_c ( "file type",    type, "=", "SPK", ok );


   /*
   Check getfat_c string error cases:
   
      1) Null filename string.
      2) Empty filename string.
      3) Null architecture string.
      4) Architecture string too short.
      5) Null type string.
      6) Type string too short.
      
   */
   getfat_c ( NULLCPTR, ARCLEN, TYPLEN, arch, type );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   getfat_c ( "", ARCLEN, TYPLEN, arch, type );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );

   getfat_c ( SPK, ARCLEN, TYPLEN, NULLCPTR, type );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   getfat_c ( SPK, 1, TYPLEN, arch, type );
   chckxc_c ( SPICETRUE, "SPICE(STRINGTOOSHORT)", ok );

   getfat_c ( SPK, ARCLEN, TYPLEN, arch, NULLCPTR );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   getfat_c ( SPK, ARCLEN, 1, arch, type );
   chckxc_c ( SPICETRUE, "SPICE(STRINGTOOSHORT)", ok );

   TRASH (SPK);
               
   /*
   Case 2:
   */
   tcase_c ( "Test ftncls_c.  Open a file using txtopn_; write 2 "
             "lines of text to the file, close the file with ftncls_c. "
             "Open the file again and read one line from it. "
             "Close the file try to read from it. Verify that eof is "
             "true or that a read error occurs."                     );

   if ( exists_c(TXT) ) 
      {  
      TRASH (TXT);
      }
   
   txtopn_ ( TXT, &unit, strlen(TXT) );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   linept = LINE1;
   
   writln_ ( linept, &unit, strlen(linept) );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   linept = "Here's a second line of text";
   
   writln_ ( linept, &unit, strlen(linept) );
   chckxc_c ( SPICEFALSE, " ", ok );

   ftncls_c ( unit );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   txtopr_ ( TXT, &unit, strlen(TXT) );
   chckxc_c ( SPICEFALSE, " ", ok );

   readln_ ( &unit, line, &eof, LINELN-1 );
   chckxc_c ( SPICEFALSE, " ", ok );


   ftncls_c ( unit );
   chckxc_c ( SPICEFALSE, " ", ok );


   readln_ ( &unit, line, &eof, LINELN-1 ); 

   if ( failed_c() )
      {
      chckxc_c ( SPICETRUE, "SPICE(FILEREADFAILED)", ok );
      }
   else
      {
      chcksl_c ( "eof", eof, SPICETRUE, ok );
      }

   /*
   The attempt to read from the non-existent file
   referred to by unit results in the creation of a 
   bogus file having name 
   
      fort.nn
      
   where nn is the unit number.
   
   Delete this.
   */

   ftncls_c ( unit );

   strcpy  ( bogus, "" );
   sprintf ( bogus, "fort.%d", (int)unit );
   
   TRASH ( bogus );
   TRASH ( TXT   );
   
   
   /*
   Case 3:
   */
   
   tcase_c ( "Test exists_c." );
   
   chcksl_c ( "exists_c(TXT)", exists_c(TXT), SPICEFALSE, ok );
   
   txtopn_ ( TXT, &unit, strlen(TXT) );

   chcksl_c ( "exists_c(TXT)", exists_c(TXT), SPICETRUE, ok );

   ftncls_c ( unit );
   
   TRASH ( TXT );


   /*
   Case 4:
   */
   tcase_c ( "Test rdtext_c.  Open a file using txtopn_; write 2 "
             "lines of text to the file, close the file with ftncls_c. "
             "Open the file again and read the lines from it. "
             "Try to read a third line. Verify that eof is true."   );


   if ( exists_c(TXT) ) 
      {  
      TRASH (TXT);
      }
   
   txtopn_ ( TXT, &unit, strlen(TXT) );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   linept = LINE1;
   
   writln_ ( linept, &unit, strlen(linept) );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   linept = LINE2;
   
   writln_ ( linept, &unit, strlen(linept) );
   chckxc_c ( SPICEFALSE, " ", ok );

   ftncls_c ( unit );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   for ( i = 0;  i < 2;  i++ )
      {
      rdtext_c ( TXT, LINELN, line, &bool_eof );
      chckxc_c ( SPICEFALSE, " ", ok );

      chcksl_c ( "bool_eof", bool_eof, SPICEFALSE, ok );
      chcksc_c ( "line",    line, "=", explines[i], ok );
      }
   
   rdtext_c ( TXT, LINELN, line, &bool_eof );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "bool_eof", bool_eof, SPICETRUE, ok );
   chcksi_c ( "line",    strlen(line), "=", 0, 0, ok );

   TRASH (TXT);
   
   
   /*
   Retrieve the current test status.
   */ 
   t_success_c ( ok ); 
   
   
} /* End f_file_c */

