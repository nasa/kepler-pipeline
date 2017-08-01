/*

-Procedure tstck3_c (Create a test CK of type 3 and SCLK file)

-Abstract
 
   Create and if appropriate load a test type 03 C-kernel and 
   associated S-clock kernel file. 
 
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
   #include "SpiceUsr.h"
   #include "SpiceZfc.h"
   #include "SpiceZmc.h"
   #include "tutils_c.h"
  

   void tstck3_c ( ConstSpiceChar    * cknm,
                   ConstSpiceChar    * sclknm,
                   SpiceBoolean        loadck,
                   SpiceBoolean        loadsc,
                   SpiceBoolean        keepsc,
                   SpiceInt          * handle  ) 

/*

-Brief_I/O
 
   VARIABLE  I/O  DESCRIPTION 
   --------  ---  -------------------------------------------------- 
   cknm       I   The name of the C-kernel to create.
   sclknm     I   The name of the S-clock kernel to create. 
   loadck     I   Load the C-kernel if SPICETRUE.
   loadsc     I   Load the S-clock kernel if SPICETRUE.
   keepsc     I   Keep the S-clock kernel if SPICETRUE, else delete it. 
   handle     O   Handle of the c-kernel if it is loaded. 
 
-Detailed_Input
 
   cknm        is the name of a C-kernel to create and load if 
               loadck is set to SPICETRUE.  If a C-kernel of the same 
               name already exists it is deleted. 
 
   sclknm      is the name of an S-clock Kernel to create and load 
               if loadsc is set to SPICETRUE.  If an S-clock kernel of 
               the same name already exists, delete the existing 
               kernel before creating this one. 
 
   loadck      is a logical that indicates whether or not the CK 
               file should be loaded after it is created.  If it 
               has the value SPICETRUE the C-kernel is loaded after 
               it is created.  Otherwise it is left un-opened. 
 
   loadsc      is a logical that indicates whether or not the SCLK 
               file should be loaded into the kernel pool.  If it 
               has the value SPICETRUE the SCLK file is loaded, 
               otherwise it is left un-opened. 
 
   keepsc      is a logical that indicates whether or not the SCLK file
               should be deleted after it is loaded.  If keepsc is
               SPICETRUE the file is not deleted.  If keepsc is
               SPICEFALSE, the file is deleted after it is loaded.
               Note that unless loadsc is SPICETRUE, the SCLK file is
               not deleted by this routine.  This routine deletes the
               SCLK kernel only if it loadsc is SPICETRUE and keepsc is
               SPICEFALSE.
 
-Detailed_Output
 
   handle      is the handle attached to the created C-kernel if 
               the kernel is loaded because loadck has a value of 
               SPICETRUE.  Otherwise the value of handle has no meaning. 
 
-Parameters
 
   None. 
 
-Files
 
   This routine creates two files a C-kernel with a three type 03 
   segments and an associated SCLK kernel that contains all of the 
   connection information about the CK file and its associated 
   ephemeris and S-clock.  See Particulars for more details.
   
-Exceptions
 
   None. 
 
-Particulars
 
   This routine creates two files. 
 
      1) A C-kernel for the fictional objects with ID codes -9999, 
        -10000, and -10001 
    
      2) A SCLK kernel to be associated with the C-kernel. 
 
   The C-kernel contains a single segment for each of the 
   fictional objects.  These segments give continuous attitude 
   over the time interval 
   
      from 1980 JAN 1, 00:00:00.000 (ET) 
      to   2011 SEP 9, 01:46:40.000 (ET)
    
   (a span of exactly 1 billion seconds). 
 
 
   The frames of the objects are 
 
      Object    Frame 
      -------   -------- 
      -9999     Galactic 
      -10000    FK5 
      -10001    J2000 
 
   All three objects rotate  at a rate of 1 radian per 10 million 
   seconds. The axis of rotation changes every 100 million seconds. 
 
   At various epochs the axes of the objects are exactly aligned 
   with their associated reference frame. 
 
      Object     Aligned with reference frame at epoch 
      ------     ------------------------------------- 
      -9999      Epoch of the J2000 frame 
      -10000     Epoch of J2000 
      -10001     Epoch of J2000 
 
   At the moment when the frames are aligned. The are rotating 
   around the direction (2, 1, 3) in their associated frames. 
 
   The C-kernel contains 606 attitude instances. 
 
   The attitude and angular velocity produced by the CK software 
   should very nearly duplicate the results returned by the test 
   routine tstatd_c. 
 
   More specifically suppose we set up the arrays: 
 
      ID[0]     = -9999 
      ID[1]     = -10000 
      ID[2]     = -10001 
 
 
      FRAME[0]  = "GALACTIC" 
      FRAME[1]  = "FK4" 
      FRAME[2]  = "J2000" 
 
 
   Then the two methods of getting ROT and AV below should 
   produce results that agree to nearly roundoff. 
 
      Method 1. 
    
         #include "SpiceUsr.h"
              .
              .
              .
         sce2c_c  ( -9, et, &tick ); 
         ckgpav_c ( id[i], tick, 0.0, frame[i], rot, av, out, &fnd ); 
    
      Method 2. 
    
         #include "SpiceUsr.h"
         #include "tutils_c.h"
              .
              .
              .
         tstatd_c ( et, rot, av ); 
    
 
-Examples
 
   This is intended to be used in those instances when you 
   need a well defined C-kernel whose attitude can be accurately 
   predicted in advance. 
 
   The routine tstatd_c returns the continuous attitude and angular 
   velocity of the C-kernel for all time.  As such it provides 
   a convenient method for testing the CK software for an individual 
   segment. 
 
-Restrictions
 
   None. 
 
-Author_and_Institution
   
   N.J. Bachman    (JPL)
   W.L. Taber      (JPL) 
 
-Literature_References
 
   None. 
 
-Version
 
   -CSPICE Version 1.0.0, 14-JUN-1999 (NJB) (WLT)

-Index_Entries
 
   Create test CK and SCLK files. 
 
-&
*/

{ /* Begin tstck3_c */


   /*
   Local variables
   */
   logical                 ldck;
   logical                 ldsc;
   logical                 kpsc;
 
 
   assert ( cknm            !=  NULLCPTR );
   assert ( strlen(cknm)    >   0        );
   assert ( sclknm          !=  NULLCPTR );
   assert ( strlen(sclknm)  >   0        );

   ldck = loadck;
   ldsc = loadsc;
   kpsc = keepsc;
   
   tstck3_ (  ( char     * ) cknm,
              ( char     * ) sclknm,
              ( logical  * ) &ldck,
              ( logical  * ) &ldsc,
              ( logical  * ) &kpsc,
              ( integer  * ) handle,
              ( ftnlen     ) strlen(cknm), 
              ( ftnlen     ) strlen(sclknm)  ); 


} /* End tstck3_c */
