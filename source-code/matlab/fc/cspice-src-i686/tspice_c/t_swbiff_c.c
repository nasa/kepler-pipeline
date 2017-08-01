/*

-Procedure t_swbiff_c ( Switch binary file format of DAF or DAS file )

-Abstract
 
   Convert a native DAF or DAS file to a non-native version of
   the same file, or vice versa.
 
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
   #include <stdio.h>
   #include "SpiceUsr.h"
   #include "SpiceZfc.h"
   #include "SpiceZst.h"

   void t_swbiff_c ( SpiceBoolean      isNative,
                     ConstSpiceChar  * fname    ) 

/*

-Brief_I/O
 
   VARIABLE  I/O  DESCRIPTION 
   --------  ---  -------------------------------------------------- 
   isNative   I   Flag indicating whether input file has native BIFF.
   fname      I   Name of DAF or DAS file to be converted.
 
-Detailed_Input
 
   isNative       is a boolean flag indicating whether the file
                  designated by fname conforms to the native 
                  binary file format (BIFF) on input.

   fname          is the name of the DAF or DAS file whose binary
                  file format is to be switched.  If the file
                  starts out in native binary file format, it will
                  be converted to a file in a non-native format. 
                  Specifically, if the native format is BIG-IEEE,
                  the file will be converted to LTL-IEEE.

                  If the file starts out in a non-native format, the
                  file will be converted to native format:  if the
                  input file has BIG-IEEE format and the native format
                  is LTL-IEEE, the file will be converted to LTL-IEEE
                  format, and vice versa.

                  This routine does not examine the input file to 
                  determine its binary format; instead it relies on 
                  the input flag isNative to indicate the format.
                    
                  The output file resulting from the conversion 
                  will overwrite the input file.   
 
-Detailed_Output
 
   None.  See Particulars for a description of the output file.
 
-Parameters
 
   None. 
 
-Exceptions
 
   1) If the native binary file format as indicated by zzplatfm_
      is not one of 

         BIG-IEEE
         LTL-IEEE

      the error SPICE(BADBINARYFORMAT) is signaled.  No tranlation
      is done.

   2) See t_bingo_c and its supporting routines for information 
      concerning errors detected in the conversion process.

   3) If the temporary file created by this routine---effectively
      the output created by running bingo on the input file---
      cannot be renamed, the error SPICE(RENAMEFAILED)  is 
      signaled.
 
-Files
 
   See Particulars.

-Particulars
 
   This routine effectively does an in-place conversion of a 
   native big-endian IEEE DAF or DAS file to a little-endian 
   IEEE file, or vice versa.  

   Systems that don't use one of these two native binary file 
   formats are not supported.
 
-Examples
 
   See the tspice_c test family f_nnspk_c for an example.
 
-Restrictions
 
   This routine is intended for use only within the tspice_c test
   program.
 
   The caller should call chckxc_c after calling this routine.

-Author_and_Institution
 
   N.J. Bachman    (JPL) 
 
-Literature_References
 
   None. 
 
-Version
 
   -CSPICE Version 1.0.0, 29-NOV-2001 (NJB)

-&
*/

{ /* Begin t_swbiff_c */

   /*
   Prototypes 
   */
   void t_bingo_c ( ConstSpiceChar   * transFlag,
                    ConstSpiceChar   * inFile,
                    ConstSpiceChar   * outFile   );


   /*
   Local constants 
   */
   #define TEMP_KERNEL     "swbiff.bin"
   #define BIFF_KEY        "FILE_FORMAT"
   #define BIG_IEEE        "BIG-IEEE"
   #define LTL_IEEE        "LTL-IEEE"
   #define BIFF_LEN         33
   #define BIG2LTL         "-ieee2pc"
   #define LTL2BIG         "-pc2ieee"

   /*
   Local variables 
   */
   SpiceChar               nativeBIFF [ BIFF_LEN ];
   SpiceChar             * transFlag;

   SpiceInt                status;



   chkin_c ( "t_swbiff_c" );

   /*
   Find out what type of binary file format we have. 
   */
   zzplatfm_ (  ( char * ) BIFF_KEY,
                ( char * ) nativeBIFF,  
                ( ftnlen ) strlen(BIFF_KEY),  
                ( ftnlen ) BIFF_LEN         );

   F2C_ConvertStr ( BIFF_LEN, nativeBIFF );


   if ( failed_c() )
   { 
      chkout_c ( "t_swbiff_c" );
      return;
   }

   if (  eqstr_c( nativeBIFF, BIG_IEEE )  )
   {
      /*
      If the input file is native, the conversion is to LTL-IEEE
      format.  If the input file is non-native, the conversion is
      to BIG-IEEE format.
      */
      if ( isNative )
      {
         transFlag = BIG2LTL;
      }
      else
      {
         transFlag = LTL2BIG;
      }
 
   }
   else if ( eqstr_c( nativeBIFF, LTL_IEEE )  )
   {
      if ( isNative )
      {
         transFlag = LTL2BIG;
      }
      else
      {
         transFlag = BIG2LTL;
      }
   }
   else
   {
      /*
      We're dealing with an unsupported platform. 
      */
      setmsg_c ( "This routine does not work on plaforms using "
                 "the # binary file format."                     );
      errch_c  ( "#",  nativeBIFF                                );
      sigerr_c ( "SPICE(BADBINARYFORMAT)"                        );
   }
     
   if ( failed_c() )
   { 
      chkout_c ( "t_swbiff_c" );
      return;
   }


   /*      
   Convert the input file to a temporary file in the alternate binary
   file format.
   */
   t_bingo_c ( transFlag, fname, TEMP_KERNEL );

   if ( failed_c() )
   { 
      chkout_c ( "t_swbiff_c" );
      return;
   }

   /*
   Overwrite the input file with this file by renaming the temp file.
   */
   if ( exists_c(fname) )
   {
      status = remove ( fname );

      if ( status )
      {
         setmsg_c ( "Attempt to remove file # by routine "
                    "t_swbiff_c failed with status #."     );
         errch_c  ( "#",  fname                            );
         errint_c ( "#",  status                           );
         sigerr_c ( "SPICE(REMOVEFAILED)"                  );
         chkout_c ( "t_swbiff_c"                           );
         return;
      }
   }

   status = (SpiceInt) rename ( TEMP_KERNEL, fname );

   if ( status )
   {
      setmsg_c ( "Attempt to rename file <#> to <#> by "
                 "routine t_swbiff_c failed with status #." );
      errch_c  ( "#",  TEMP_KERNEL                          );
      errch_c  ( "#",  fname                                );
      errint_c ( "#",  status                               );
      sigerr_c ( "SPICE(RENAMEFAILED)"                      );
      chkout_c ( "t_swbiff_c" );
      return;
   }

   chkout_c ( "t_swbiff_c" );
   return;

} /* End t_swbiff_c */
