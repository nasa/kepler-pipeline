/*

-Procedure f_pck_c ( Test wrappers for PCK routines )

 
-Abstract
 
   Perform tests on all CSPICE wrappers for PCK functions. 
 
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
   

   void f_pck_c ( SpiceBoolean * ok )

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
 
   This routine tests the wrappers for the rotation routines. 
   The current set is:
      
      sxform_c
      pxform_c
      tipbod_c
      tisbod_c
      pcklof_c
      pckuof_c
       
-Examples
 
   None.
    
-Restrictions
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
 
-Literature_References
 
   None. 
 
-Version
 
   -tspice_c Version 1.3.1 20-MAR-2002 (EDW) 

      Replaced remove() calls with TRASH macro.

   -tspice_c Version 1.3.0 25-JUN-1999 (NJB)  

-&
*/

{ /* Begin f_pck_c */

 
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
   #define TXTPCK          "test.pck"
   #define SPK             "test.spk"
   #define UTC             "2000 Jan 1 12:00"
                     
   /*
   Static variables
   */
   static SpiceDouble      e1        [3] = { 1.0, 0.0, 0.0 };
   static SpiceDouble      e3        [3] = { 0.0, 0.0, 1.0 };

   /*
   Local variables
   */
   SpiceDouble             av        [3];
   SpiceDouble             expav     [3];
   SpiceDouble             expptrans [3][3];
   SpiceDouble             expstrans [6][6];
   SpiceDouble             lt;
   SpiceDouble             pm        [2];
   SpiceDouble             proj      [3];
   SpiceDouble             ptrans    [3][3];
   SpiceDouble             r         [3][3];
   SpiceDouble             state     [6];
   SpiceDouble             strans    [6][6];

   SpiceInt                pckhan;
   SpiceInt                spkhan;
   SpiceInt                n;


   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_pck_c" );
   

   
   /*
   Create a text PCK file and load it.  Delete it after loading it.
   */
   tstpck_c ( TXTPCK, SPICETRUE, SPICEFALSE );

   /*
   Create a text SPK file but do not load it.  
   */
   tstspk_c ( SPK, SPICEFALSE, &spkhan );

   
   /*
   Case 1:
   */
    
   tcase_c ( "Test pcklof_c and pckuof_c." );
   
   /*
   Load a binary PCK.  Perspicacious readers will notice that the file 
   is actually an SPK file.  The binary PCK loader is rather obtuse and 
   will not notice.
   */
   pcklof_c ( SPK, &pckhan );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   Check pcklof_c string error cases:
   
      1) Null PCK string.
      2) Empty PCK string.
      
   */
   pcklof_c ( NULLCPTR, &pckhan );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   
   pcklof_c ( "", &pckhan );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );
            
   /*
   Ok, that's enough of this charade.
   */ 
   
   pckuof_c ( pckhan );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   
   /*
   Case 2:
   */
   tcase_c  ( "Test sxform_c.  Get the state transformation for "
              "J2000 to the earth-fixed frame at the J2000 epoch." );
   
   sxform_c ( "J2000", "IAU_EARTH", 0.0, strans );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   Get the corresponding rotation and angular velocity.

   Check the angular velocity:  make sure it agrees with that
   obtained by looking up the prime meridian rate from the kernel
   pool.  The rate from the pool must be converted from degrees/day
   to radians/sec.
   */
   
   xf2rav_c ( strans, r, av );
   
   bodvar_c ( 399, "PM", &n, pm );
   
   expav[0]  =  0.;
   expav[1]  =  0.;
   expav[2]  =  pm[1] * rpd_c() / spd_c();
   
   chckad_c ( "Earth a.v.", av,  "~",  expav,  3,  1.e-10, ok );
   
   
   /*
   Make sure the earth's x axis points pretty much at the sun.
   Get the earth-sun state in earth body-fixed coordinates; find
   the angular separation of the x-y projection of the sun's
   position and the x-axis.
   */
   
   spklef_c ( SPK, &spkhan );

   spkezr_c ( "sun", 0.0, "IAU_EARTH", "NONE", "earth", state, &lt );
   chckxc_c ( SPICEFALSE, " ", ok );

   vperp_c ( state, e3, proj );
   
   chcksd_c ( "earth-sun ang sep",  
              vsep_c( e1, proj),  
              "~",   
              0.0,  
              5.e-2,  
              ok                   );
   

   /*
   Check sxform_c string error cases:
   
      1) Null from string.
      2) Empty from string.
      3) Null to string.
      4) Empty to string.
      
   */
   sxform_c ( NULLCPTR, "IAU_EARTH", 0.0, strans );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   
   sxform_c ( "", "IAU_EARTH", 0.0, strans );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );
            
   sxform_c ( "J2000", NULLCPTR, 0.0, strans );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   
   sxform_c ( "J2000", "", 0.0, strans );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );
            




   /*
   Case 3:
   */
   
   tcase_c ( "Test tisbod.  Apply to the earth at J2000; compare with "
             "sxform_c results."                                      );
             

   sxform_c ( "J2000", "IAU_EARTH", 0.0, expstrans );
   tisbod_c ( "J2000", 399,         0.0, strans    );
   chckxc_c ( SPICEFALSE, " ", ok );

   chckad_c ( "tsipm", 
              (SpiceDouble *) strans,  
              "~",  
              (SpiceDouble *) expstrans,  
              36,  
              1.e-14, 
              ok                        );



   /*
   Case 4:
   */
   
   tcase_c ( "Test tipbod.  Apply to the earth at J2000; compare with "
             "sxform_c results."                                      );
             

   sxform_c ( "J2000", "IAU_EARTH", 0.0, expstrans );
   xf2rav_c ( expstrans, r, av );
   
   tipbod_c ( "J2000", 399,         0.0, ptrans    );
   chckxc_c ( SPICEFALSE, " ", ok );

   chckad_c ( "tipm", 
              (SpiceDouble *)ptrans,  
              "~",  
              (SpiceDouble *)r,  
              9,  
              1.e-14, 
              ok                     );



   /*
   Case 5:
   */
   
   tcase_c ( "Test pxform.  Apply to the earth at J2000; compare with "
             "tipbod results."                                        );
             

   pxform_c ( "J2000", "IAU_EARTH", 0.0, ptrans );
   
   tipbod_c ( "J2000", 399,         0.0, expptrans );
   chckxc_c ( SPICEFALSE, " ", ok );

   chckad_c ( "tipm", 
              (SpiceDouble *)ptrans,  
              "~",  
              (SpiceDouble *)expptrans,  
              9,  
              1.e-14, 
              ok                     );


   /*
   Check pxform_c string error cases:
   
      1) Null from string.
      2) Empty from string.
      3) Null to string.
      4) Empty to string.
      
   */
   pxform_c ( NULLCPTR, "IAU_EARTH", 0.0, ptrans );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   
   pxform_c ( "", "IAU_EARTH", 0.0, ptrans );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );
            
   pxform_c ( "J2000", NULLCPTR, 0.0, ptrans );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   
   pxform_c ( "J2000", "", 0.0, ptrans );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );
            
     
   /*
   Clean up:  get rid of the SPK file.
   */
   
   spkuef_c ( spkhan );
   TRASH    ( SPK    );
     
   
   /*
   Retrieve the current test status.
   */ 
   t_success_c ( ok ); 
   
   
} /* End f_pck_c */

