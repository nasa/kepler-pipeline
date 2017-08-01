/*

-Procedure m2q_c ( Matrix to quaternion )

-Abstract

   Find a unit quaternion corresponding to a specified rotation
   matrix.

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
   #include "SpiceZmc.h"
   #undef    m2q_c


   void m2q_c (  ConstSpiceDouble  r[3][3],
                 SpiceDouble       q[4]     )
/*

-Brief_I/O

   Variable  I/O  Description
   --------  ---  --------------------------------------------------
   r          I   A rotation matrix.
   q          O   A unit quaternion representing r.

-Detailed_Input

   r              is a rotation matrix.

-Detailed_Output

   q              is a unit quaternion representing r.  q is a
                  4-dimensional vector.  If r rotates vectors by an
                  angle of R radians about a unit vector a, where
                  R is in [0, pi], then if h = R/2,

                     q = ( cos(h), sin(h)a ,  sin(h)a ,  sin(h)a ).
                                          1          2          3

                  The restriction that R must be in the range [0, pi]
                  determines the output quaternion q uniquely
                  except when R = pi; in this special case, both of
                  the quaternions

                     q = ( 0,  a ,  a ,  a  )
                                1    2    3
                  and

                     q = ( 0, -a , -a , -a  )
                                1    2    3

                 are possible outputs, if a is a choice of rotation
                 axis for r.

-Parameters

   None.

-Exceptions

   1)   If r is not a rotation matrix, the error SPICE(NOTAROTATION)
        is signalled.

-Files

   None.

-Particulars

   A unit quaternion is a 4-dimensional vector for which the sum of
   the squares of the components is 1.  Unit quaternions can be used
   to represent rotations in the following way:  Given a rotation
   angle R in [0, pi] and a unit vector a that acts as a rotation
   axis, we define the quaternion q by

      q = ( cos(R/2), sin(R/2)a , sin(R/2)a , sin(R/2)a ).
                               1           2           3

   As mentioned in Detailed_Output, our restriction on the range of
   R determines q uniquely, except when R = pi.

   The CSPICE routine q2m_c is an one-sided inverse of this routine:
   given any rotation matrix r, the calls

      m2q_c ( r, q );
      q2m_c ( q, r );

   leave r unchanged, except for round-off error.  However, the
   calls

      q2m_c ( q, r );
      m2q_c ( r, q );

   might preserve q or convert q to -q.

-Examples

   1)  A case amenable to checking by hand calculation:

          To convert the rotation matrix

                   +-              -+
                   |  0     1    0  |
                   |                |
             r  =  | -1     0    0  |
                   |                |
                   |  0     0    1  |
                   +-              -+

          also represented as

             [ pi/2 ]
                     3

          to a quaternion, we can use the code fragment

             rotate_c (  halfpi_c(),  3,  r  );
             m2q_c    (  r,               q  );

          m2q_c will return q as

             ( sqrt(2)/2, 0, 0, -sqrt(2)/2 ).

          Why?  Well, r is a coordinate transformation that
          rotates vectors by -pi/2 radians about the axis vector

             a  = ( 0, 0, 1 ),

          so our definition of q,

             q = ( cos(R/2), sin(R/2)a , sin(R/2)a , sin(R/2)a  ),
                                      1           2           3

          implies that in this case,

             q =  ( cos(-pi/4),  0,  0,   sin(-pi/4) )

               =  ( sqrt(2)/2,   0,  0,  -sqrt(2)/2  ).


   2)  Finding a quaternion that represents a rotation specified by
       a set of Euler angles:

          Suppose our original rotation R is the product

             [ tau ]  [ pi/2 - delta ]  [ alpha ] .
                    3                 2          3

          The code fragment

             eul2m_c  ( tau,   halfpi_c() - delta,   alpha,
                        3,     2,                    3,      r );

             m2q_c    ( r, q );

          yields a quaternion q that represents r.

-Restrictions

   None.

-Literature_References

   NAIF document 179.0, "Rotations and their Habits", by
   W. L. Taber.

-Author_and_Institution

   N.J. Bachman   (JPL)

-Version

   -CSPICE Version 1.1.0, 21-OCT-1998 (NJB)

       Made input matrix const.

   -CSPICE Version 1.0.1, 13-FEB-1998 (EDW)

       Minor corrections to header.

   -CSPICE Version 1.0.0, 08-FEB-1998 (NJB)

       Based on SPICELIB Version 1.0.1, 10-MAR-1992 (WLT)

-Index_Entries

   matrix to quaternion

-&
*/

{ /* Begin m2q_c */

   /*
   Local variables
   */
   SpiceDouble             loc_r[3][3];


   /*
   Participate in error tracing.
   */
   chkin_c ( "m2q_c" );


   /*
   Transpose the input matrix to put it in column-major order.
   */
   xpose_c ( r, loc_r );


   /*
   Call the f2c'd version of m2q:
   */
   m2q_ ( (doublereal *) loc_r,
          (doublereal *) q      );


   chkout_c ( "m2q_c" );


} /* End m2q_c */
