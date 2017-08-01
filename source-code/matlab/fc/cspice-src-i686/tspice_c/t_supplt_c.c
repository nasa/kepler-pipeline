/*

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

*/


   #include "SpiceUsr.h"
   #include "SpiceZfc.h"
   #include "SpiceZst.h"

   void t_supplt_c ( SpiceBoolean * ret )
{
   /*
   Local constants 
   */
   #define TEMP_KERNEL     "makenn.bin"
   #define BIFF_KEY        "FILE_FORMAT"
   #define BIG_IEEE        "BIG-IEEE"
   #define LTL_IEEE        "LTL-IEEE"
   #define BIFF_LEN         33

   /*
   Local variables 
   */
   SpiceChar               biff [ BIFF_LEN ];


   chkin_c ( "t_supplt_c" );

   /*
   Set default value of ret. 
   */
   *ret = SPICETRUE;


   /*
   Find out what type of binary file format we have. 
   */
   zzplatfm_ (  ( char * ) BIFF_KEY,
                ( char * ) biff,  
                ( ftnlen ) strlen(BIFF_KEY),  
                ( ftnlen ) BIFF_LEN         );

   F2C_ConvertStr ( BIFF_LEN, biff );


   if ( failed_c() )
   { 
      chkout_c ( "t_supplt_c" );
      return;
   }

   /*
   Set ret according to whether the biff is supported. 
   */
   *ret =  (  ! (    eqstr_c( biff, BIG_IEEE ) 
                  || eqstr_c( biff, LTL_IEEE ) )  );

   chkout_c ( "t_supplt_c" );
   return;
}
