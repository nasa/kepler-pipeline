/*

-Procedure f_nnsp17_c ( Test selected SPK type 17 wrappers, non-native )

 
-Abstract
 
   Perform tests on CSPICE wrappers for a subset of the SPK type 17 
   routines, using non-native SPK files.
    
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
   

   void f_nnsp17_c ( SpiceBoolean * ok )

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
 
   This routine tests the wrappers for a subset of the CSPICE SPK type
   17 routines, reading from non-native SPK files.
   
   The subset is:
      
      spkw17_c
             
-Examples
 
   None.
    
-Restrictions
 
   1) This routine carries out its tests on systems having the
      BIG-IEEE or LTL-IEEE binary file format.  On other systems,
      it is effectively a no-op:  the routine returns as soon as
      the binary file format is known.
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
 
-Literature_References
 
   None. 
 
-Version
 
   -tspice_c Version 1.0.1 20-MAR-2002 (EDW) 

      Replaced remove() calls with TRASH macro.

   -tspice_c Version 1.0.0 25-NOV-2001 (NJB)

      Adapted from f_nnsp17_c
  
        Version 1.0.0 02-SEP-1999 (NJB)  

-&
*/

{ /* Begin f_nnsp17_c */

 
 
   /*
   Prototypes
   */
   void t_swbiff_c ( SpiceBoolean      isNative, 
                     ConstSpiceChar  * fname    );

   void t_supplt_c ( SpiceBoolean    * ret      );

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
   #define  SPK17          "type17.bsp"

   
   #define  SIDLEN         41

   #define  ND             2
   #define  NI             6
   #define  DSCSIZ         5
   
   /*
   Local variables
   */
   logical                 found;
   SpiceBoolean            ret;
   
   SpiceChar             * frame;
   SpiceChar             * segid;
   SpiceChar               outSegid [ SIDLEN ];


 
   SpiceDouble             a;
   SpiceDouble             argp;
   SpiceDouble             decpol;
   SpiceDouble             descr   [DSCSIZ];
   SpiceDouble             ecc;
   SpiceDouble             eqel    [9];
   SpiceDouble             et;
   SpiceDouble             first;
   SpiceDouble             fivdpd;
   SpiceDouble             gm;
   SpiceDouble             inc;
   SpiceDouble             last;
   SpiceDouble             m0;
   SpiceDouble             n;
   SpiceDouble             node;
   SpiceDouble             p;
   SpiceDouble             rapol;
   SpiceDouble             state1  [6];
   SpiceDouble             state2  [6];
   SpiceDouble             t0;
   SpiceDouble             tendpd;


   SpiceInt                begin;
   SpiceInt                body;
   SpiceInt                center;
   SpiceInt                end;
   SpiceInt                frcode;
   SpiceInt                i;
   SpiceInt                nelts;
   SpiceInt                ref;
   SpiceInt                type;



   SpiceInt                handle;




   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_nnsp17_c" );
   

   /*
   This routine is effectively a no-op for unsupported platforms.
   */
   t_supplt_c ( &ret );

   if ( ret )
   {
      t_success_c ( ok ); 
      return;
   }


   /*
   Case 1:
   */
   
   tcase_c ( "Create an SPK file containing one type 17 segment." );
 
    
   p    =      1.0e4;
   gm   = 398600.436e0;
   ecc  =      0.1e0;
   a    = p/( 1.0e0 - ecc );
   n    = sqrt ( gm / a ) / a;
   argp = 30.0e0 * rpd_c();
   node = 15.0e0 * rpd_c();
   inc  = 10.0e0 * rpd_c();
   m0   = 45.0e0 * rpd_c();
   t0   = -100000000.0e0;
   
   
   /*
   We want a rate for the node of 10 degrees/day and
   for the argument of periapse of 5 degrees/day.
   */
   fivdpd  = (  5.0e0 / 86400.0e0 ) * rpd_c();
   tendpd  = ( 10.0e0 / 86400.0e0 ) * rpd_c();

   eqel[0] = a;
   eqel[1] = ecc*sin(argp+node);
   eqel[2] = ecc*cos(argp+node);
   eqel[3] = m0 + argp + node;
   eqel[4] = tan(inc/2.0e0)*sin(node);
   eqel[5] = tan(inc/2.0e0)*cos(node);
   eqel[6] = fivdpd + tendpd;
   eqel[7] = n + fivdpd + tendpd;
   eqel[8] = tendpd;

   rapol   = 30.0 * rpd_c();
   decpol  = 60.0 * rpd_c();

   body   = -1000;
   segid  = "phoenix";
   center = 399;
   frame  = "b1950";

   first  = -1.0e9;
   last   =  1.0e9;
   et     =  0.0e0;
 
   if ( exists_c(SPK17) )
      {
      TRASH (SPK17);
      }
 
   spkopn_c ( SPK17, "type 17 test SPK", 1000, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );

   spkw17_c ( handle, body,  center, frame, first, last,
              segid,  t0,    eqel,   rapol, decpol     );
   chckxc_c ( SPICEFALSE, " ", ok );
              
   spkcls_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );
 
   
   /*
   Convert the file to non-native binary format. 
   */
   t_swbiff_c ( SPICETRUE, SPK17 );
   chckxc_c   ( SPICEFALSE, " ", ok );
 

   /*
   Case 2:
   */

   tcase_c ( "Check the descriptor of the file we just created." );
   
   
   spklef_c ( SPK17, &handle );
   
   
   spksfs_  ( &body, &et, &handle, descr, outSegid, &found, SIDLEN );
   chcksl_c ( "found", found, SPICETRUE, ok );
   
 
   /*
   Unpack the descriptor.
   */
   
   spkuds_c ( descr, 
              &body,  &center, &frcode,  &type,
              &first, &last,   &begin,   &end  );
   
   chckxc_c ( SPICEFALSE, " ", ok );
   
   nelts = end - begin + 1;
   
   chcksi_c ( "body",       body,   "=",   -1000,  0, ok );
   chcksi_c ( "center",     center, "=",     399,  0, ok );
   chcksi_c ( "frame code", frcode, "=",       2,  0, ok );
   chcksi_c ( "SPK type",   type,   "=",      17,  0, ok );
   chcksi_c ( "nelts",      nelts,  "=",      12,  0, ok );
   chcksd_c ( "start time", first,  "=",  -1.0e9,  0, ok );
   chcksd_c ( "end time",   last,   "=",   1.0e9,  0, ok );
 
 
   /*
   Case 3:
   */

   tcase_c ( "Read from the file we just created." );
   

   et = t0 - 10000.0e0;


   for ( i = 0;  i < 100;  i++ )
   {
      et    =  et + 250.0e0;

      eqncpv_ ( &et,     &t0,   eqel,  &rapol, &decpol, state1  );
      spkpvn_ ( &handle, descr, &et,   &ref,   state2,  &center );

      chcksi_c ( "center",     center, "=",     399,  0, ok );
      chcksi_c ( "frame code", frcode, "=",       2,  0, ok );
      
      chckad_c ( "state",  state1, "=",  state2, 6, 0.0, ok );
   }
             
             
   /*
   Get rid of the SPK file.
   */
   spkuef_c ( handle );
   TRASH    ( SPK17  );

          
   /*
   Retrieve the current test status.
   */ 
   t_success_c ( ok ); 
   
   
} /* End f_nnsp17_c */

