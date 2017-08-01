/*

-Procedure      q2m_c ( Quaternion to matrix )

-Abstract
 
   Find the rotation matrix corresponding to a specified unit 
   quaternion. 
 
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
 
   ROTATION 
 
-Keywords
 
   MATH 
   MATRIX 
   ROTATION 
 
*/

   #include "SpiceUsr.h"
   #include "SpiceZfc.h"
   #include "SpiceZim.h"
   #undef    q2m_c
   

   void q2m_c ( ConstSpiceDouble  q[4], 
                SpiceDouble       r[3][3] ) 
/*

-Brief_I/O
 
   Variable  I/O  Description 
   --------  ---  -------------------------------------------------- 
   q          I   A unit quaternion. 
   r          O   A rotation matrix corresponding to q. 
 
-Detailed_Input
 
   q              is a unit quaternion representing a rotation.  q 
                  is a 4-dimensional vector.  q has the property that 
 
                     || q ||  =  1. 
 
-Detailed_Output
 
   r              is a 3 by 3 rotation matrix representing the same 
                  rotation as does q.  If q represents a rotation by 
                  R radians about some axis vector a, then for any 
                  vector v, r*v yields v, rotated by R radians 
                  about a. 
 
-Parameters
 
   None. 
 
-Exceptions
 
   Error free. 
 
   1)  If q is not a unit quaternion, the output matrix r is 
       unlikely to be a rotation matrix. 
 
-Files
 
   None. 
 
-Particulars
 
   If a 4-dimensional vector q satisfies the equality 
 
      || q ||   =  1 
 
   or equivalently 
 
          2          2          2          2 
      q(0)   +   q(1)   +   q(2)   +   q(3)   =  1, 
 
   then we can always find a unit vector q and a scalar R such that 
 
      q = ( cos(R/2), sin(R/2)a(1), sin(R/2)a(2), sin(R/2)a(3) ). 
 
   We can interpret a and R as the axis and rotation angle of a 
   rotation in 3-space.  If we restrict R to the range [0, pi], 
   then R and a are uniquely determined, except if R = pi.  In this 
   special case, a and -a are both valid rotation axes. 
 
   Every rotation is represented by a unique orthogonal matrix; this 
   routine returns that unique rotation matrix corresponding to q. 
 
   The CSPICE routine m2q_c is a one-sided inverse of this routine: 
   given any rotation matrix r, the calls 
 
      m2q_c ( r, q ) 
      q2m_c ( q, r ) 
 
   leave r unchanged, except for round-off error.  However, the 
   calls 
 
      q2m_c ( q, r ) 
      m2q_c ( r, q ) 
 
   might preserve q or convert q to -q. 
 
-Examples
 
   1)  A case amenable to checking by hand calculation: 
 
          To convert the quaternion 
 
             q = ( sqrt(2)/2, 0, 0, -sqrt(2)/2 ) 
 
          to a rotation matrix, we can use the code fragment 
 
             q[0] =  sqrt(2.)/2.; 
             q[1] =  0.;
             q[2] =  0.; 
             q[3] = -sqrt(2.)/2.; 
 
             q2m_c ( q, r ); 
 
          The matrix r will be set equal to 
 
             +-              -+ 
             |  0     1    0  | 
             |                | 
             | -1     0    0  |. 
             |                | 
             |  0     0    1  | 
             +-              -+ 
 
          Why?  Well, q represents a rotation by some angle R about 
          some axis vector q, where R and a satisfy 
 
             q = ( cos(R/2), sin(R/2)a(1), sin(R/2)a(2), sin(R/2)a(3) ). 
 
          In this example, 
 
             q = ( sqrt(2)/2, 0, 0, -sqrt(2)/2 ), 
 
          so 
 
             cos(R/2) = sqrt(2)/2. 
 
          Assuming that R is in the interval [0, pi], we must have 
 
             R = pi/2, 
 
          so 
 
             sin(R/2) = sqrt(2)/2. 
 
          Since the second through fourth components of q represent 
 
             sin(r/2) * a, 
 
          it follows that 
 
             a = ( 0, 0, -1 ). 
 
          So q represents a transformation that rotates vectors by 
          pi/2 about the negative z-axis.  This is equivalent to a 
          coordinate system rotation of pi/2 about the positive 
          z-axis; and we recognize R as the matrix 
 
             [ pi/2 ] . 
                     3 
 
 
   2)  Finding a set of Euler angles that represent a rotation 
       specified by a quaternion: 
 
          Suppose our rotation r is represented by the quaternion 
          q.  To find angles tau, alpha, delta such that 
 
 
             r  =  [ tau ]  [ pi/2 - delta ]  [ alpha ] , 
                          3                 2          3 
 
          we can use the code fragment 
 
 
             q2m_c   ( q, r );
             m2eul_c ( r, 3, 2, 3, tau, delta, alpha );
 
             delta = halfpi_c() - delta; 
 
-Restrictions
 
   None. 
 
-Literature_References
 
   [1]    NAIF document 179.0, "Rotations and their Habits", by 
          W. L. Taber. 
 
-Author_and_Institution
 
   N.J. Bachman   (JPL) 
 
-Version
 
   -CSPICE Version 1.3.1, 06-FEB-2003 (EDW)

       Corrected typo error in Examples section.

   -CSPICE Version 1.3.0, 24-JUL-2001   (NJB)

       Changed protoype:  input q is now type (ConstSpiceDouble [4]).
       Implemented interface macro for casting input q to const.

   -CSPICE Version 1.2.0, 08-FEB-1998 (NJB)
   
      Removed local variables used for temporary capture of outputs.
      Removed tracing calls, since the underlying Fortran routine
      is error-free.

   -CSPICE Version 1.0.0, 25-OCT-1997 (NJB)
   
      Based on SPICELIB Version 1.0.1, 10-MAR-1992 (WLT)

-Index_Entries
 
   quaternion to matrix 
 
-&
*/

{ /* Begin q2m_c */


   /*
   Call the f2c'd version of q2m:
   */
   q2m_ ( (doublereal *) q,
          (doublereal *) r );
          
   /*
   Transpose the output matrix to put it in row-major order.
   */
   xpose_c ( r, r );
          

} /* End q2m_c */
