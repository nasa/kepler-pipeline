/*

-Procedure stelab_c     ( Stellar Aberration )

-Abstract
 
    Correct the apparent position of an object for stellar 
    aberration. 
 
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
 
    EPHEMERIS 
 
*/

   #include "SpiceUsr.h"
   #include "SpiceZfc.h"
   #undef    stelab_c
   
 
   void stelab_c ( ConstSpiceDouble   pobj[3],
                   ConstSpiceDouble   vobs[3],
                   SpiceDouble        appobj[3] ) 
/*

-Brief_I/O
 
    VARIABLE  I/O  DESCRIPTION 
    --------  ---  -------------------------------------------------- 
    pobj       I   Position of an object with respect to the 
                   observer. 
    vobs       I   Velocity of the observer with respect to the 
                   Solar System barycenter. 
    appobj     O   Apparent position of the object with respect to 
                   the observer, corrected for stellar aberration. 
 
-Detailed_Input
 
    pobj        is the position (x, y, z, km) of an object with 
                respect to the observer, possibly corrected for 
                light time. 
 
    vobs        is the velocity (dx/dt, dy/dt, dz/dt, km/sec) 
                of the observer with respect to the Solar System 
                barycenter. 
 
-Detailed_Output
 
    appobj      is the apparent position of the object relative 
                to the observer, corrected for stellar aberration. 
 
                appobj may overwrite pobj. 
 
-Parameters
 
   None. 
 
-Particulars
 
    Let r be the vector from the observer to the object, and v be 
        -                                                    - 
    the velocity of the observer with respect to the Solar System 
    barycenter. Let w be the angle between them. The aberration 
    angle phi is given by 
 
         sin(phi) = v sin(w) / c 
 
    Let h be the vector given by the cross product 
        - 
 
          h = r X v 
          -   -   - 
 
    Rotate r by phi radians about h to obtain the apparent position 
           -                      - 
    of the object. 
 
-Examples
 
    In the following example, stelab_c is used to correct the position 
    of a target body for stellar aberration. 
 
       /.
       (Previous subroutine calls have loaded the SPK file and 
       the leapseconds kernel file.) 
       ./
      
       /.
       Get the state of the observer with respect to the solar 
       system barycenter. 
       ./
       spkssb_c ( idobs,  et, "J2000", sobs ); 
 
       /.
       Get the light-time corrected state of the target body as 
       seen by the observer. 
       ./
       spkapp_c ( idtarg, et, "J2000",  sobs,  "LT", starg, &lt ); 
 
       /.
       Apply the correction for stellar aberration to the 
       light-time corrected state of the target body. 
       ./
       stelab_c ( starg, starg+3, starg ) 
 
 
    Note that this example is somewhat contrived. The correction 
    flag "LT+S" could have been used (in place of "LT") to do the 
    correction automatically in spkapp_c. 
 
-Restrictions
 
    None. 
 
-Exceptions
 
   1) If the velocity of the observer is greater than or equal 
      to the speed of light, the error SPICE(VALUEOUTOFRANGE) 
      is signalled. 
 
-Files
 
    None. 
 
-Author_and_Institution
 
    N.J. Bachman    (JPL)
    H.A. Neilan     (JPL) 
    W.L. Taber      (JPL) 
    I.M. Underwood  (JPL) 
 
-Literature_References
 
    1) W.M. Owen, Jr., JPL IOM #314.8-524, "The Treatment of 
       Aberration in Optical Navigation", 8 February 1985. 
 
-Version
 
   -CSPICE Version 1.0.0, 22-OCT-1998 (NJB)

      Based on SPICELIB Version 1.0.2, 10-MAR-1992 (WLT)
   
-Index_Entries
 
   stellar aberration 
 
-&
*/

{ /* Begin stelab_c */

   /*
   Participate in error tracing.
   */
   chkin_c ( "stelab_c" );


   /*
   Call the f2c'd routine.
   */
   stelab_ ( ( doublereal * ) pobj,
             ( doublereal * ) vobs,
             ( doublereal * ) appobj );


   chkout_c ( "stelab_c" );

} /* End stelab_c */
