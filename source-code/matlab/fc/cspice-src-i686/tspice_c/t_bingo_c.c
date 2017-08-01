/*

-Procedure  t_bingo_c ( DAF/DAS Binary to Binary Translator for Testing )

-Abstract
 
   This routine provides a C subroutine interface for the program
   bingo, which converts between IEEE and PC SPICE binary files. 
 
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
 
   UTILITY 

-Version

   -tspice_c Version 1.0.0 13-DEC-2001 (NJB)

      Created by making minor tweaks to bingo's main program. 
      Bingo was written by Scott Turner (NAIF).
 
*/

#include <stdio.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"


   void t_bingo_c ( ConstSpiceChar   * transFlag,
                    ConstSpiceChar   * inFile,
                    ConstSpiceChar   * outFile   )
/*

-Brief_I/O
 
   Variable  I/O  Description 
   --------  ---  -------------------------------------------------- 
   transFlag  I   Flag indicating translation to perform.
   inFile     I   Name of input file.
   outFile    I   Name of output file.
 
-Detailed_Input
 
   transFlag      is a character string flag indicating which 
                  translation to perform.  Values and meanings are:

                     -ieee2pc     Transform Sun/Unix IEEE format
                                  to PC IEEE format
                     -pc2ieee     Transform PC IEEE format
                                  to Sun/Unix IEEE format


   inFile         is the the name of the input file.

   outFile        is the the name of the output file.
     
-Detailed_Output
 
   None.
  
-Parameters
 
   None. 
 
-Exceptions
 
   1)  Any file access errors cause this routine to signal an error.
   
   2)  If the translation flag is invalid, the error is considered
       to be a bug. 

   3)  If the binary file format of the input file is neither PC or 
       UNIX/MAC based, then this routine signals an error after
       determining this.

   4)  In the event that information in input file is incorrect in 
       a way that prevents this routine from continuing the conversion
       process an error is signaled.

   5)  If the user supplies -ieee2pc as the translation flag and the input 
       file is in the PC binary file format, this routine signals 
       an error.  Similarly with -pc2ieee and IEEE
       input files.
  
-Files
 
   1)  The input file for conversion is expected to be a valid binary
       SPICE kernel in either the PC or IEEE format.  It is only accessed
       for reads.
   
   2)  The converted file is created by this process, and will be a
       binary file of the opposing format.
 
-Particulars

   This routine converts between PC and IEEE SPICE binary kernel
   formats.  This routine will only function properly when compiled
   on PC and IEEE machines (possibly machines of the Macintosh variety
   as well).  As a general philosophy maintained in a variety of
   places in this program: garbage in equates to garbage out.

   DAF:
   ---

   (1) This routine makes no attempt to clean up any invalid records
       that are appended to the end of a DAF file.
 
   (2) It does not clean up any other assorted garbage stored elsewhere
       in the DAF file.

   (3) If there are bytes that lie outside the normal access (read and
       write) through the NAIF DAF browsing interface, they are treated
       as was convenient in the framework of the particular module.

       (-) Records occuring before the first free address that exist
           outside of the area addressable by the doubly linked list
           are treated as standard DAF double precision data records.

       (-) Left over space at the end of descriptor records is left
           untranslated.

       (-) Records that exist after the record pointed to by the
           first free address are truncated.

   DAS:
   ---

   (1) This routine makes no attempt to clean up any invalid records
       that are appended to the end of a DAS file.

   (2) In the event that there are bytes that lie outside the normal
       access (read and write) through the NAIF DAS browsing interface,
       they are treated as was convenient in the framework of the 
       particular module.

       (-) Records occuring before the last directory record that 
           are not addressed by the DAS system cause this routine
           to signal an error.

       (-) Records that exist after the last directory record that
           are not addressed by the DAS system are truncated. 

   Any input file is assumed to be absolutely correct. The descriptor 
   and directory record pointers are extracted from the file directly
   with no attempts to validate them.  (This is what diagnostic tools
   are for after all.)  So having said that, this utility will save
   much time and diskspace if you want to convert between IEEE and PC
   SPICE kernels.

   This routine does nothing more than check the translation flag,
   determine they architecture of the input file, and invoke the 
   appropriate conversion method.  The actual workhorses are 
   das_process_file and daf_process_file.

   Note: This routine writes an exact copy of the originial file into
   a new file.  There is an important caveat.  Consider the following
   sequence of operations:

      (1) Start with an IEEE binary file on a IEEE system.
      (2) Create a text transfer file using toxfr or spacit.
      (3) FTP in ASCII the transfer file to a PC. 
      (4) FTP in binary the IEEE binary to a PC.
      (5) Use bingo to convert the IEEE binary to PC format.
      (6) Use tobin to create a PC binary from the transfer file.

   If you 'diff' the two binary files (fc /b on a PC, diff in UNIX),
   you may not find them to be exactly the same.  There are portions of
   records that may not be completely utilized by the kernel, and what
   each system places in these unused portions is somewhat system 
   dependent.  The only real way to compare these files is to compare
   transfer files.  If they agree completely, then the files are the
   same.

-Examples
 
   See usage in tspice_c.

-Restrictions
 
   1)  Any input file to be processed by t_bingo_c must be absolutely 
       correct.  The detection scheme is very fragile and any improper
       FTP transfer or other mishap may cause it to improperly detect
       the file format and invoke the wrong conversion. 
    
-Literature_References
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman   (JPL)
   F.S. Turner    (JPL)
 
-Version

   -t_bingo_c Version 1.0.0, 29-NOV-2001 (NJB) (FST)

      Adapted from bingo 

         Version 1.0.0, 20-DEC-2000 (FST)
   

-&
*/

{
   /*
   Prototypes
   */
   int t_bingo__( char      * iname, 
                  char      * oname, 
                  integer   * obff, 
                  ftnlen      iname_len, 
                  ftnlen      oname_len);   

   /*
   Local constants 
   */

   /*
   These are defined in the SPICELIB include file zzddhman.inc. 
   */
   #define BIGI3E          1
   #define LTLI3E          2

   /* 
   Local Variables 
   */   
   SpiceBoolean            ieee2pc;

   SpiceInt                biffCode;


   /*
   Check in with SPICE error handling.
   */
   chkin_c ( "t_bingo_c" );

   /*
   Set the local tranlation flag.  Make sure it's a valid choice
   first.
   */         
   if (  !(    eqstr_c( transFlag, "-ieee2pc" ) 
            || eqstr_c( transFlag, "-pc2ieee" ) )  )
   {
      setmsg_c ( "Translation flag was #." );
      errch_c  ( "#", transFlag            );
      sigerr_c ( "SPICE(BUG)"              );
      chkout_c ( "t_bingo_c"               );
      return;
   }
   
   ieee2pc = (int) eqstr_c( transFlag, "-ieee2pc" );

   if ( ieee2pc )
   {
      biffCode = LTLI3E;
   }
   else
   {
      biffCode = BIGI3E;  
   }

   /*
   Pass the translation task off to the Fortran converter. 
   */

   t_bingo__ ( ( char    * ) inFile,
               ( char    * ) outFile,
               ( integer * ) &biffCode,
               ( ftnlen    ) strlen(inFile),
               ( ftnlen    ) strlen(outFile) );

   chkout_c ( "t_bingo_c" );
   return;
}
