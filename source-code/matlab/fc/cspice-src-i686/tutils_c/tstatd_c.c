/*

-Procedure tstatd_c ( Test Attitude )

-Abstract
 
   This routine produces attitude and angular velocity values 
   that should duplicate the values for the test spacecraft 
   with ID code -10001. 
 
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
   
   #include "SpiceUsr.h"
   #include "SpiceZfc.h"
   #include "SpiceZst.h"
   #include "tutils_c.h"
   
   
   void tstatd_c ( SpiceDouble    et,
                   SpiceDouble    matrix[3][3],
                   SpiceDouble    angvel[3]    ) 

/*

-Brief_I/O
 
   VARIABLE  I/O  DESCRIPTION 
   --------  ---  -------------------------------------------------- 
   et         I   An ephemeris epoch in seconds past J2000. 
   matrix     O   A rotation from J2000 to the frame of -10001. 
   angvel     O   The angular velocity of the rotation. 
 
-Detailed_Input
 
   et          an epoch given in terms of TDB seconds past the 
               epoch of J2000. 
 
-Detailed_Output
 
   matrix      is the expected orientation of the test body -10001 
               relative to the J2000 frame. 
 
   angvel      is the expected angular velocity of the test body 
               -10001 relative to the J2000 frame. 
 
-Parameters
 
   None. 
 
-Files
 
   None. 
 
-Exceptions
 
   Error free. 
 
-Particulars
 
   This routine creates a model for the attitude and angular 
   velocity of the fictitious body -10001 used in testing SPICE 
   SPK, CK, SCLK, and IK systems. 
 
   The attitude is perfectly aligned with the Galactic axes at the 
   epoch of J2000. 
 
   The body rotates at a constant rate of 1 radian every 10 million 
   seconds.  Every 100 million seconds the axis of rotation changes. 
 
   The axes of rotation are: 
 
   From           To                Axis of rotation    Time Interval 
   ------------  ------------       ----------------    ------------- 
   -Infinity     -900,000,000       ( 1, 2, 4 )            1 
   -900,000,000  -800,000,000       ( 2, 1, 4 )            2 
   -800,000,000  -700,000,000       ( 4, 1, 2 )            3 
 
   -700,000,000  -600,000,000       ( 4, 2, 1 )            4 
   -600,000,000  -500,000,000       ( 2, 1, 4 )            5 
   -500,000,000  -400,000,000       ( 1, 4, 2 )            6 
 
   -400,000,000  -300,000,000       ( 1, 2, 3 )            7 
   -300,000,000  -200,000,000       ( 2, 3, 1 )            8 
   -200,000,000  -100,000,000       ( 3, 1, 2 )            9 
 
   -100,000,000   000,000,000       ( 3, 2, 1 )            10 
    000,000,000   100,000,000       ( 2, 1, 3 )            11 
    100,000,000   200,000,000       ( 1, 3, 2 )            12 
 
    200,000,000   300,000,000       ( 2, 3, 6 )            13 
    300,000,000   400,000,000       ( 3, 6, 2 )            14 
    400,000,000   500,000,000       ( 6, 2, 3 )            15 
 
    500,000,000   600,000,000       ( 6, 3, 2 )            16 
    600,000,000   700,000,000       ( 3, 2, 6 )            17 
    700,000,000   800,000,000       ( 2, 6, 3 )            18 
 
    800,000,000   900,000,000       ( 1, 1, 1 )            19 
    900,000,000   +Infinity         ( 0, 0, 1 )            20 
 
-Examples
 
   This routine can be used in conjunction with the routine 
   tstck3_c to perform tests on components of the CK system. 
 
-Restrictions
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
   W.L. Taber      (JPL) 
 
-Literature_References
 
   None. 
 
-Version
 
   -CSPICE Version 1.0.0, 19-JUN-1999 (NJB) (WLT)

-Index_Entries
 
   Attitude of the test body -10001  
 
-&
*/

{ /* Begin tstatd_c */


   tstatd_ (  ( doublereal * ) &et,
              ( doublereal * ) matrix,
              ( doublereal * ) angvel    ); 

   xpose_c ( matrix, matrix );
 
} /* End tstatd_c */
