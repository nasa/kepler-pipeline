/*

-Procedure f_nnck_c ( Test wrappers for CK routines, non-native )

 
-Abstract
 
   Perform tests on CSPICE wrappers for the CK functions, reading from
   non-native files. 
 
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
   

   void f_nnck_c ( SpiceBoolean * ok )

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
 
   This routine tests the wrappers for the CSPICE CK routines, 
   reading from non-native files.  The wrappers
   are:
   
      ckcls_c
      ckgp_c
      ckgpav_c
      cklpf_c
      ckopn_c
      ckupf_c
      ckw01_c
      ckw02_c
      ckw03_c
             
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

      Adapted from f_ck_c   
      
         Version 1.1.0 21-SEP-1999 (NJB)     
-&
*/

{ /* Begin f_nnck_c */


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
   #define  CK1            "type1.bc"
   #define  CK2            "type2.bc"
   #define  CK3            "type3.bc"
   #define  FILEN          255
   #define  IFNAME         "Test CK created by f_nnck_c"
   #define  INST1          -77701
   #define  INST2          -77702
   #define  INST3          -77703
   #define  MAXREC         201
   #define  NCOMCH         10
   #define  REF            "J2000"
   #define  REFLEN         10
   #define  SC             -777
   #define  SECPERTICK     0.001
   #define  SEGID1         "Test type 1 test CK"
   #define  SEGID2         "Test type 2 test CK"
   #define  SEGID3         "Test type 3 test CK"
   #define  SIDLEN         40
   #define  SPACING        10.0
   #define  TIGHT_MX       1.e-14
                     
   /*
   Local variables
   */

   SpiceBoolean            avflag;
   SpiceBoolean            found;
   SpiceBoolean            ret;

   SpiceDouble             av        [3];
   SpiceDouble             begtim;
   SpiceDouble             clkout;
   SpiceDouble             cmat      [3][3];
   SpiceDouble             delta;
   SpiceDouble             endtim;
   SpiceDouble             epoch;
   SpiceDouble             expavvs   [MAXREC][3];
   SpiceDouble             expcmat   [3][3];
   SpiceDouble             expcmats  [MAXREC][3][3];
   SpiceDouble             quats     [MAXREC][4];
   SpiceDouble             rates     [MAXREC];
   SpiceDouble             rmat      [3][3];
   SpiceDouble             sclkdp    [MAXREC];
   SpiceDouble             spinRate;
   SpiceDouble             starts    [MAXREC];
   SpiceDouble             stops     [MAXREC];
   SpiceDouble             theta;

   SpiceInt                handle;
   SpiceInt                i;
   SpiceInt                nprec;
   SpiceInt                numint;


      



   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_nnck_c" );
   

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
   tcase_c ( "Test ckw01_c.  Create a file with one type 1 segment." );



   /*
   Open a new kernel.
   */
   
   if ( exists_c (CK1) )
      {
      TRASH ( CK1 );
      }
   
   ckopn_c ( CK1, IFNAME, NCOMCH, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   /*
   Create the pointing information to go in the C-kernel segment.

      1) Number of pointing instances returned
      2) Array of SCLK times
      3) Array of C-matrices
      4) Array of angular velocity vectors
      
      
   We will create a series of pointing instances that represent
   a structure initially aligned with the J2000 frame, and which is
   rotating about the J2000 z-axis.  The first pointing instance is
   at tick 1000.  There will be one pointing instance per 10-tick
   interval.  The angular velocity will start out at one 
   microradian/tick and will increment by one microradian/tick every
   10 ticks.
      
   The angular velocity values imply a conversion factor of .001 second
   per tick.  The variable spinRate will be in units of radians/tick.
   Note that angular velocity vectors have units of radians/second.
   */
   
   nprec       =  MAXREC;
   
   sclkdp[0]   =  1000.0;
   theta       =  0.0;
   spinRate    =  1.e-6;
   ident_c ( expcmats[0] );
   m2q_c   ( expcmats[0],   quats[0] );
   vpack_c ( 0.,  0.,  spinRate / SECPERTICK, expavvs[0] );
   
   
   for ( i = 1;  i < nprec;  i++ )
   {
      sclkdp[i]  =   sclkdp[i-1] + SPACING;
   
      theta      +=  spinRate * SPACING;
   
      rotmat_c ( expcmats[i-1], theta, 3, expcmats[i] );
   
      m2q_c (    expcmats[i],   quats[i] );
   
      spinRate   =  1.e-6 * ( i + 1 );
   
      vpack_c ( 0.,  0.,  spinRate / SECPERTICK, expavvs[i] );
   }
      
 
   /*
   Enter the information to go in the segment descriptor.
    
   
   This segment contains angular velocity.
   */
   avflag = SPICETRUE;


   /*
   Set the segment boundaries equal to the first and last
   time in the segment.
   */
   begtim = sclkdp[      0];
   endtim = sclkdp[nprec-1];


   /*
   That is all the information that we need. Write the segment.
   */
   ckw01_c ( handle, 
             begtim, 
             endtim, 
             INST1,     
             REF, 
             avflag,
             SEGID1,  
             nprec,  
             sclkdp, 
             quats, 
             expavvs );
   
   chckxc_c ( SPICEFALSE, " ", ok );


   /*
   Close the file.
   */
   
   ckcls_c  ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );
  
 
   /*
   Convert to a non-native file. 
   */
   t_swbiff_c ( SPICETRUE, CK1 );
   chckxc_c   ( SPICEFALSE, " ", ok );


   /*
   Case 2:
   */
   tcase_c ( "Test ckw01_c.  Read and check the type 1 file. "
             "This also tests ckgpav_c and ckgp_c."            );


   
   cklpf_c  ( CK1, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );

   
   for ( i = 0;  i < nprec;  i++ )
   {
   
      ckgpav_c ( INST1, sclkdp[i], 0., REF, cmat, av, &clkout, &found ); 
   
      chckxc_c ( SPICEFALSE, " ", ok );
      
      chcksl_c ( "found", found, SPICETRUE, ok );
      
      chcksd_c ( "clkout", clkout, "~", sclkdp  [i],    TIGHT_MX, ok );
      chckad_c ( "av",     av,     "~", expavvs [i], 3, TIGHT_MX, ok );

      chckad_c ( "cmat",   
                 (SpiceDouble *) cmat,   
                 "~", 
                 (SpiceDouble *) expcmats[i], 
                 9, 
                 TIGHT_MX, 
                 ok                           );
   }

   
   for ( i = 0;  i < nprec;  i++ )
   {
   
      ckgp_c   ( INST1, sclkdp[i], 0.0, REF, cmat, &clkout, &found ); 
   
      chckxc_c ( SPICEFALSE, " ", ok );
      
      chcksl_c ( "found", found, SPICETRUE, ok );
      
      chcksd_c ( "clkout", clkout, "~",  sclkdp[i], TIGHT_MX, ok );

      chckad_c ( "cmat",   
                 (SpiceDouble *) cmat,   
                 "~", 
                 (SpiceDouble *) expcmats[i], 
                 9, 
                 TIGHT_MX, 
                 ok                           );
   }

   
   /*
   Case 3:
   */

   tcase_c ( "Test ckupf_c.  Unload CK1 and try to do a lookup." );
   
   ckupf_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   ckgpav_c ( INST1, sclkdp[0], 0.0, REF, cmat, av, &clkout, &found ); 
   chckxc_c ( SPICETRUE, "SPICE(NOLOADEDFILES)", ok );
  
  
  
   /*
   Case 4:
   */

   tcase_c ( "Test ckw02_c.  Create a file with one type 2 segment." );
  

   if ( exists_c (CK2) )
      {
      TRASH ( CK2 );
      }
   
   ckopn_c ( CK2, IFNAME, NCOMCH, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   /*
   Create arrays of interval start and stop times.  The interval 
   associated with each quaternion will start at the epoch of
   the quaternion and will extend 0.8 * SPACING forward in time,
   leaving small gaps between the intervals.

   Pointing and angular velocity data, as well as time tags, are copied 
   from the type 1 test cases.   
   */
   
   for ( i = 0;  i < nprec;  i++ )
   {
      starts[i] = sclkdp[i];
      stops[i]  = sclkdp[i] + ( 0.8 * SPACING );
   }


   /*
   Fill in the clock rates array.
   */
   for ( i = 0;  i < nprec;  i++ )
   {
      rates[i] = SECPERTICK;
   }

   /*
   Set the segment boundaries equal to the first and last
   time in the segment.
   */
   begtim = starts[      0];
   endtim = stops [nprec-1];


   /*
   That is all the information that we need. Write the segment.
   */
   ckw02_c ( handle, 
             begtim, 
             endtim, 
             INST2,     
             REF, 
             SEGID2,  
             nprec,  
             starts, 
             stops, 
             quats, 
             expavvs, 
             rates    );
             
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   Close the file.
   */
   ckcls_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );
 
 
   /*
   Convert to a non-native file. 
   */
   t_swbiff_c ( SPICETRUE, CK2 );
   chckxc_c   ( SPICEFALSE, " ", ok );



   /*
   Case 5:
   */
   tcase_c ( "Test ckw02_c.  Read the file we created." );

   
   cklpf_c  ( CK2, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );

   
   for ( i = 0;  i < nprec;  i++ )
   {
   
      ckgpav_c ( INST2, sclkdp[i], 0., REF, cmat, av, &clkout, &found ); 
   
      chckxc_c ( SPICEFALSE, " ", ok );
      
      chcksl_c ( "found", found, SPICETRUE, ok );
      
      chcksd_c ( "clkout", clkout, "~", sclkdp  [i],    TIGHT_MX, ok );
      chckad_c ( "av",     av,     "~", expavvs [i], 3, TIGHT_MX, ok );

      chckad_c ( "cmat",   
                 (SpiceDouble *) cmat,   
                 "~", 
                 (SpiceDouble *) expcmats[i], 
                 9, 
                 TIGHT_MX, 
                 ok                           );
   }
    

   /*
   Case 6:
   */ 
   tcase_c ( "Test ckw02_c.  Read the file we created, this time "
             "making use of the interpolation capability."         );

   
   delta = SPACING / 2.0;
   
   for ( i = 0;  i < nprec;  i++ )
   {
      epoch = sclkdp[i] + delta;
      
      ckgpav_c ( INST2, epoch, 0., REF, cmat, av, &clkout, &found ); 
   
      chckxc_c ( SPICEFALSE, " ", ok );
      
      chcksl_c ( "found", found, SPICETRUE, ok );
      
      chcksd_c ( "clkout", clkout, "~", epoch,          TIGHT_MX, ok );
      chckad_c ( "av",     av,     "~", expavvs [i], 3, TIGHT_MX, ok );

      /*
      Adjust the expected C-matrix for sclkdp[i] to account for 
      the rotation for a duration of delta ticks.  The resulting
      matrix is expcmat.
      */
      
      theta = vnorm_c( expavvs[i] ) * SECPERTICK * delta;
      
      axisar_c ( expavvs[i],  theta, rmat    );
      mxmt_c   ( expcmats[i], rmat,  expcmat );
      
      chckad_c ( "cmat",   
                 (SpiceDouble *) cmat,   
                 "~", 
                 (SpiceDouble *) expcmat, 
                 9, 
                 TIGHT_MX, 
                 ok                           );
   }
    

   
   
   /*
   Case 7:
   */
   
   tcase_c ( "Make sure ckgpav_c and ckgp_c report `no pointing found' "
             "where there is none."                                   );
   
   epoch = sclkdp[0] + 0.9*SPACING;
   
   ckgpav_c ( INST2, epoch, 0., REF, cmat, av, &clkout, &found ); 

   chckxc_c ( SPICEFALSE, " ", ok );
   
   chcksl_c ( "found", found, SPICEFALSE, ok );

   ckgp_c   ( INST2, epoch, 0., REF, cmat, &clkout, &found ); 

   chckxc_c ( SPICEFALSE, " ", ok );
   
   chcksl_c ( "found", found, SPICEFALSE, ok );


   /*
   Unload the type 2 file.
   */
   ckupf_c ( handle );



   /*
   Case 8:
   */


   tcase_c ( "Test ckw03_c.  Create a file with one type 3 segment." );
  

   if ( exists_c (CK3) )
      {
      TRASH ( CK3 );
      }
   
   ckopn_c ( CK3, IFNAME, NCOMCH, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   /*
   Create an array of interval start and stop times.  The intervals 
   will range from the epoch of the (2*i)th quaternion to the (2*i+2)nd
   one. 

   Pointing and angular velocity data, as well as time tags, are copied 
   from the type 1 test cases.   
   */
   
   numint = nprec/2;
   
   for ( i = 0;  i < numint;  i++ )
   {
      starts[i] = sclkdp[2*i];
   }


   /*
   Set the segment boundaries equal to the first and last
   time in the segment.
   */
   begtim = sclkdp[      0];
   endtim = sclkdp[nprec-1];


   /*
   That is all the information that we need. Write the segment.
   */
   ckw03_c ( handle, 
             begtim, 
             endtim, 
             INST3,     
             REF, 
             avflag,
             SEGID3,  
             nprec,  
             sclkdp, 
             quats, 
             expavvs, 
             numint,
             starts    );

   chckxc_c ( SPICEFALSE, " ", ok );


   /*
   Close the file.
   */
   ckcls_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   

 
   /*
   Convert to a non-native file. 
   */
   t_swbiff_c ( SPICETRUE, CK3 );
   chckxc_c   ( SPICEFALSE, " ", ok );



   /*
   Case 9:
   */ 
   tcase_c ( "Test ckw03_c.  Read the file we created." );

   
   cklpf_c  ( CK3, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );

   
   for ( i = 0;  i < nprec;  i++ )
   {
   
      ckgpav_c ( INST3, sclkdp[i], 0., REF, cmat, av, &clkout, &found ); 
   
      chckxc_c ( SPICEFALSE, " ", ok );
      
      chcksl_c ( "found", found, SPICETRUE, ok );
      
      chcksd_c ( "clkout", clkout, "~", sclkdp  [i],    TIGHT_MX, ok );
      chckad_c ( "av",     av,     "~", expavvs [i], 3, TIGHT_MX, ok );

      chckad_c ( "cmat",   
                 (SpiceDouble *) cmat,   
                 "~", 
                 (SpiceDouble *) expcmats[i], 
                 9, 
                 TIGHT_MX, 
                 ok                           );
   }
    

   ckupf_c ( handle );


   /*
   Remove the files we created.
   */
 
   TRASH ( CK1 );
   TRASH ( CK2 );
   TRASH ( CK3 );
 
   
   /*
   Retrieve the current test status.
   */ 
   t_success_c ( ok ); 
   
   
} /* End f_nnck_c */

