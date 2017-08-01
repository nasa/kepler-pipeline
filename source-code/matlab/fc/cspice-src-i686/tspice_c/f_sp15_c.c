/*

-Procedure f_sp15_c ( Test wrappers for selected SPK type 15 routines )

 
-Abstract
 
   Perform tests on CSPICE wrappers for a subset of the SPK type 15 
   routines.
    
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
   

   void f_sp15_c ( SpiceBoolean * ok )

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
   15 routines. 
   
   The subset is:
      
      spkw15_c
             
-Examples
 
   None.
    
-Restrictions
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
 
-Literature_References
 
   None. 
 
-Version
 
   -tspice_c Version 1.1.1 20-MAR-2002 (EDW) 

      Replaced remove() calls with TRASH macro.

   -tspice_c Version 1.1.0 15-SEP-1999 (NJB)  

      ecc, gm, and radius given initial values to make HP compiler
      happy.

   -tspice_c Version 1.0.0 02-SEP-1999 (NJB)  

-&
*/

{ /* Begin f_sp15_c */

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
   #define  SPK1           "type15_1.bsp"

   
   #define  SIDLEN         41

   #define  ND             2
   #define  NI             6
   #define  DSCSIZ         5
   
   /*
   Local variables
   */
   logical                 found;
   
   SpiceChar             * frame;
   SpiceChar             * segid;
   SpiceChar               outSegid [ SIDLEN ];


   SpiceDouble             descr  [DSCSIZ];
   SpiceDouble             dps    [ND];
   SpiceDouble             ecc    = 0.0;
   SpiceDouble             epoch;
   SpiceDouble             et;
   SpiceDouble             first;
   SpiceDouble             gm     =   1.e10;
   SpiceDouble             j2;
   SpiceDouble             j2flg;
   SpiceDouble             last;
   SpiceDouble             myrec  [16];
   SpiceDouble             p;
   SpiceDouble             pa     [3];
   SpiceDouble             pv     [3];
   SpiceDouble             radius = 5000.;
   SpiceDouble             record [20];
   SpiceDouble             tp     [3];

   static SpiceInt         c__17 = 17;
   static SpiceInt         c__ND = 2;
   static SpiceInt         c__NI = 6;
   
   SpiceInt                nums   [NI];
   SpiceInt                body;
   SpiceInt                center;
   SpiceInt                handle;
   SpiceInt                i;
   SpiceInt                type;





   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_sp15_c" );
   

   /*
   Case 1:
   */
   
   tcase_c ( "The semi-latus rectum is supposed to be positive. " 
             "Start out at zero and then set it to something "
             "reasonable."                                       );
   
   /*
   Make sure the kernel pool doesn't contain any unexpected 
   definitions.
   */
   clpool_c();
   
   /*
   Open a new SPK file.
   */
   spkopn_c ( SPK1, "SPK type 15 test file", 0, &handle );
   
   
   /*
   Set up a bunch of initial values.
   */ 
   
   body   = -1000;
   center = 399;
   frame  = "J2000";
   first  = 0.0;
   last   = 100000.0;
   segid  = " ";
   epoch  = 1000.0;
   j2flg  = 0.0;
   j2     = 1.082616e-3;


   for ( i = 0;  i < 20;  i++ )
   {
      record[i] = 1.0;
   };
 

 
   p = 0.0;
   
     
   spkw15_c ( handle, body,  center, frame,  first, last,
              segid,  epoch, tp,     pa,     p,     ecc,
              j2flg,  pv,    gm,     j2,     radius      );
   
   chckxc_c ( SPICETRUE, "SPICE(BADLATUSRECTUM)", ok );
  
   p = 10000.0;
   
   
   
   /*
   Case 2:
   */
   tcase_c ( "Eccentricity Exception" );

   /*
   Negative eccentricities should produce exceptions.  After
   checking that this is so set the eccentricity to something
   yielding a periodic orbit.
   */

   ecc = -1.0;
   
   spkw15_c ( handle, body,  center, frame,  first, last,
              segid,  epoch, tp,     pa,     p,     ecc,
              j2flg,  pv,    gm,     j2,     radius      );
   
   chckxc_c ( SPICETRUE, "SPICE(BADECCENTRICITY)", ok );

   ecc = 0.1;
 
 
   /*
   Case 3:
   */
   tcase_c ( "central mass exception --- mass 0" );
   
   
   /*
   The central mass must be positive.  Zero or less should
   trigger an exception. Try zero and -1.  After that we
   use the mass of the earth.
   */

   gm = 0.0;
   
   spkw15_c ( handle, body,  center, frame,  first, last,
              segid,  epoch, tp,     pa,     p,     ecc,
              j2flg,  pv,    gm,     j2,     radius      );
   
   chckxc_c ( SPICETRUE, "SPICE(NONPOSITIVEMASS)", ok );
   
 
   gm = -1.0;
   
   spkw15_c ( handle, body,  center, frame,  first, last,
              segid,  epoch, tp,     pa,     p,     ecc,
              j2flg,  pv,    gm,     j2,     radius      );
   
   chckxc_c ( SPICETRUE, "SPICE(NONPOSITIVEMASS)", ok );
   
   gm =  398600.447703261138;
   

   /*
   Case 4:
   */
   
   tcase_c ( "Trajectory Pole Exception" );
   
   /*
   Only a zero trajectory pole can produce a problem.  By
   construction we already have one.
   */
   
   tp[0] = 0.0;
   tp[1] = 0.0;
   tp[2] = 0.0;

   spkw15_c ( handle, body,  center, frame,  first, last,
              segid,  epoch, tp,     pa,     p,     ecc,
              j2flg,  pv,    gm,     j2,     radius      );
   
   chckxc_c ( SPICETRUE, "SPICE(BADVECTOR)", ok );
   
   /*
   Set the trajectory pole to 45 degree inclination.
   */
   tp[0] = 0.0;
   tp[1] = cos ( pi_c()/6 );
   tp[2] = sin ( pi_c()/6 );
 
   
   
   /*
   Case 5:
   */
   tcase_c ( "Periapsis Vector Exception" );
   
   /*
   Only a zero periapsis vector yields an exception.  We
   already have this by construction.  After testing make
   a periapsis vector that is orthogonal to the trajectory
   pole vector.
   */
 
   pa[0] = 0.0;
   pa[1] = 0.0;
   pa[2] = 0.0;

   spkw15_c ( handle, body,  center, frame,  first, last,
              segid,  epoch, tp,     pa,     p,     ecc,
              j2flg,  pv,    gm,     j2,     radius      );
   
   chckxc_c ( SPICETRUE, "SPICE(BADVECTOR)", ok );
   
   pa[0] = 0.0;
   pa[1] = sin ( pi_c()/6 );
   pa[2] = cos ( pi_c()/6 );
 
 
   /*
   Case 6:
   */
 
   /*
   Only a zero central body pole vector can yield an exception.
   We have such a situation by construction.  After checking
   this, align the pole with the Z axis.
   */
   
   tcase_c ( "Pole Vector Exception" );
   
   pv[0] = 0.0;
   pv[1] = 0.0;
   pv[2] = 0.0;

   spkw15_c ( handle, body,  center, frame,  first, last,
              segid,  epoch, tp,     pa,     p,     ecc,
              j2flg,  pv,    gm,     j2,     radius      );
   
   chckxc_c ( SPICETRUE, "SPICE(BADVECTOR)", ok );

   pv[2] = 1.0;
   
   /*
   Case 7:
   */
   
   /*
   Any radius less than zero should trigger an exception.  After
   checking, set the equatorial radius to that of the earth.
   */
   tcase_c ( "Equatorial Radius Exception" );
   
   radius = -1.0;
   
   spkw15_c ( handle, body,  center, frame,  first, last,
              segid,  epoch, tp,     pa,     p,     ecc,
              j2flg,  pv,    gm,     j2,     radius      );
   
   chckxc_c ( SPICETRUE, "SPICE(BADRADIUS)", ok );
   
   radius = 6378.184;
   
   
   
   /*
   Case 8:
   */
   
   /*
   If the periapse is not nearly perpepndicular to the
   trajectory pole, we should get an exception.  Create
   a vector that isn't perpendicular to the trajectory pole
   by messing up the sign on the z-component.
   */
   
   tcase_c ( "Bad Initial Conditions" );

   
   pa[0] = 0.0;
   pa[1] = 1.0;
   pa[2] = 0.0;

   spkw15_c ( handle, body,  center, frame,  first, last,
              segid,  epoch, tp,     pa,     p,     ecc,
              j2flg,  pv,    gm,     j2,     radius      );
   
   chckxc_c ( SPICETRUE, "SPICE(BADINITSTATE)", ok );

   pa[0] =  0.0;
   pa[1] =  sin ( pi_c()/6 );
   pa[2] = -cos ( pi_c()/6 );
   
   
   /*
   Case 9:
   */ 
   
   tcase_c ( "Segment Identifier too long" );

   segid = "This is a very, very, very long segment identifier ";
   
   spkw15_c ( handle, body,  center, frame,  first, last,
              segid,  epoch, tp,     pa,     p,     ecc,
              j2flg,  pv,    gm,     j2,     radius      );
   
   chckxc_c ( SPICETRUE, "SPICE(SEGIDTOOLONG)", ok );
   
   
   
   /*
   Case 10:
   */
   
   tcase_c ( "Non-Printing Characters Exception" );
   
   
   segid = "This is a \n test segment.";
   
   spkw15_c ( handle, body,  center, frame,  first, last,
              segid,  epoch, tp,     pa,     p,     ecc,
              j2flg,  pv,    gm,     j2,     radius      );
   
   chckxc_c ( SPICETRUE, "SPICE(NONPRINTABLECHARS)", ok );
   
   segid = "Test segment";
   
   
   /*
   That takes care of all noted excpetions in  SPKW15.
   Write a legitimate segment and close the SPK file.
   */
   

   /*
   Case 11:
   */
   
   tcase_c ( "Writing a type 15 segment." );
   
   if ( exists_c(SPK1) )
      {  
      dafcls_c ( handle );
      TRASH   ( SPK1   );
      }
   
   spkopn_c ( SPK1, "SPK type 15 test file", 0, &handle );


   myrec[ 0] = epoch;

   myrec[ 1] = tp[0];
   myrec[ 2] = tp[1];
   myrec[ 3] = tp[2];

   myrec[ 4] = pa[0];
   myrec[ 5] = pa[1];
   myrec[ 6] = pa[2];
   myrec[ 7] = p;
   myrec[ 8] = ecc;

   myrec[ 9] = j2flg;

   myrec[10] = pv[0];
   myrec[11] = pv[1];
   myrec[12] = pv[2];
   myrec[13] = gm;
   myrec[14] = j2;
   myrec[15] = radius;

   first     = 1000.0;
   last      = 100000.0;

   spkw15_c ( handle, body,  center, frame,  first, last,
              segid,  epoch, tp,     pa,     p,     ecc,
              j2flg,  pv,    gm,     j2,     radius      );
   
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   
   /*
   In addition we write a bogus segment with the wrong amount
   of data in it and call it type 15.
   */
   first     = -100000.0;
   last      =   -1000.0;
   type      =        15;
   
   spkpds_c ( body, center, frame, type, first, last, descr );
 
   segid = "bogus segment";
   dafbna_  ( &handle, descr, segid, strlen(segid) );
   dafada_  ( record, &c__17 );
   dafena_  ();
   dafcls_c ( handle );
 
   chckxc_c ( SPICEFALSE, " ", ok );


   /*
   Case 12:
   */
   
   /*
   Corrupt the descriptor in the type component of the segment
   and make sure that SPKR15 properly diagnoses the problem.
   */
   tcase_c ( "SPKR15 bad type exception." );

   et = 2000.0;
   
   spklef_c ( SPK1,  &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   spksfs_  ( &body, &et, &handle, descr, outSegid, &found, SIDLEN );
   chcksl_c ( "found", found, SPICETRUE, ok );
 
   if ( ok )
   { 
      dafus_c ( descr, ND,    NI,     dps, nums );
      nums[3] = 14;
      dafps_  (       &c__ND, &c__NI, dps, nums, descr );
      
      spkr15_ ( &handle, descr, &et, record );
      chckxc_c ( SPICETRUE, "SPICE(WRONGSPKTYPE)", ok );
   }
   
   
   
   
   /*
   Case 13:
   */
   
   /*
   Recall that the second segment we wrote had too much data.
   and had time bounds from -100000 to -1000.  We find that
   segment next and make sure that the badly formed segment
   is handled properly.
   */
 
   tcase_c ( "SPKR15 bad segment exception." );
 
   et = -2000.0;
   
   spksfs_  ( &body, &et, &handle, descr, outSegid, &found, SIDLEN );
   chcksl_c ( "found", found, SPICETRUE, ok );
 
   if ( ok )
   {
      spkr15_ ( &handle, descr, &et, record );
      chckxc_c ( SPICETRUE, "SPICE(MALFORMEDSEGMENT)", ok );
   }  
   
   
   
   /*
   Case 14:
   */
   tcase_c ( "SPKR15 checking segment values." );
 
   et = 2000.0;
   
   spksfs_  ( &body, &et, &handle, descr, outSegid, &found, SIDLEN );
   chcksl_c ( "found", found, SPICETRUE, ok );
 
   if ( ok )
   {
      spkr15_  ( &handle, descr, &et, record );
      chckxc_c ( SPICEFALSE, " ", ok );
      chckad_c ( "record", record, "=", myrec, 16, 1.e-14, ok );
   }  

             
   /*
   Get rid of the old SPK file.
   */
   spkuef_c ( handle );
   TRASH    ( SPK1   );
             
   /*
   Retrieve the current test status.
   */ 
   t_success_c ( ok ); 
   
   
} /* End f_sp15_c */

