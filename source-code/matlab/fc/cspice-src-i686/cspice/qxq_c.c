/*

-Procedure qxq_c ( Quaternion times quaternion )

-Abstract
 
   Multiply two quaternions. 
    
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
   POINTING 
   ROTATION 
 
*/

   #include "SpiceUsr.h"
   #undef   qxq_c


   void qxq_c ( ConstSpiceDouble    q1   [4],
                ConstSpiceDouble    q2   [4],
                SpiceDouble         qout [4]  ) 

/*

-Brief_I/O
 
   VARIABLE  I/O  DESCRIPTION 
   --------  ---  -------------------------------------------------- 
   q1         I   First SPICE quaternion factor. 
   q2         I   Second SPICE quaternion factor. 
   qout       O   Product of `q1' and `q2'. 
 
-Detailed_Input
 
   q1             is a 4-vector representing a SPICE-style quaternion.
 
                  Note that multiple styles of quaternions are in use.
                  This routine will not work properly if the input
                  quaternions do not conform to the SPICE convention.
                  See the Particulars section for details.
 
   q2             is a second SPICE quaternion. 
 
-Detailed_Output
 
   qout           is 4-vector representing the quaternion product  
 
                     q1 * q2 
 
                  Representing q(i) as the sums of scalar (real) 
                  part s(i) and vector (imaginary) part v(i) 
                  respectively, 
 
                     q1 = s1 + v1 
                     q2 = s2 + v2 
 
                  qout has scalar part s3 defined by 
 
                     s3 = s1 * s2 - <v1, v2> 
 
                  and vector part v3 defined by 
 
                     v3 = s1 * v2  +  s2 * v1  +  v1 x v2 
 
                  where the notation < , > denotes the inner 
                  product operator and x indicates the cross 
                  product operator. 
 
-Parameters
 
   None. 
 
-Files
 
   None. 
 
-Exceptions
 
   Error free. 
 
-Particulars
 
   There are (at least) two popular "styles" of quaternions; these 
   differ in the layout of the quaternion elements, the definition 
   of the multiplication operation, and the mapping between the set 
   of unit quaternions and corresponding rotation matrices. 
 
   SPICE-style quaternions have the scalar part in the first 
   component and the vector part in the subsequent components. The 
   SPICE convention, along with the multiplication rules for SPICE 
   quaternions, are those used by William Rowan Hamilton, the 
   inventor of quaternions. 
 
   Another common quaternion style places the scalar component 
   last.  This style is often used in engineering applications. 
 
   The correspondence between SPICE quaternions and rotation 
   matrices is defined as follows:  Let R be a rotation matrix that 
   transforms vectors from a right-handed, orthogonal reference 
   frame F1 to a second right-handed, orthogonal reference frame F2. 
   If a vector V has components x, y, z in the frame F1, then V has 
   components x', y', z' in the frame F2, and R satisfies the 
   relation: 
 
      [ x' ]     [       ] [ x ] 
      | y' |  =  |   R   | | y | 
      [ z' ]     [       ] [ z ] 
 
 
   Letting Q = (q0, q1, q2, q3) be the SPICE unit quaternion 
   representing R, we have the relation 
 
           R  = 
 
      +-                                                          -+ 
      |           2    2                                           | 
      | 1 - 2 ( q2 + q3 )    2 (q1 q2 - q0 q3)   2 (q1 q3 + q0 q2) | 
      |                                                            | 
      |                                                            | 
      |                                2    2                      | 
      | 2 (q1 q2 + q0 q3)    1 - 2 ( q1 + q3 )   2 (q2 q3 - q0 q1) | 
      |                                                            | 
      |                                                            | 
      |                                                    2    2  | 
      | 2 (q1 q3 - q0 q2)    2 (q2 q3 + q0 q1)   1 - 2 ( q1 + q2 ) | 
      |                                                            | 
      +-                                                          -+ 
 
 
   To map the rotation matrix R to a unit quaternion, we start by 
   decomposing the rotation matrix as a sum of symmetric 
   and skew-symmetric parts: 
 
                                      2 
      R = [ I  +  (1-cos(theta)) OMEGA  ] + [ sin(theta) OMEGA ] 
 
                   symmetric                   skew-symmetric 
 
 
   OMEGA is a skew-symmetric matrix of the form 
 
                 +-             -+ 
                 |  0   -n3   n2 | 
                 |               | 
       OMEGA  =  |  n3   0   -n1 | 
                 |               | 
                 | -n2   n1   0  | 
                 +-             -+ 
 
   The vector N of matrix entries (n1, n2, n3) is the rotation axis 
   of R and theta is R's rotation angle.  Note that N and theta 
   are not unique. 
 
   Let 
 
      C = cos(theta/2) 
      S = sin(theta/2) 
 
   Then the unit quaternions Q corresponding to R are 
 
      Q = +/- ( C, S*n1, S*n2, S*n3 ) 
 
   The mappings between quaternions and the corresponding rotations 
   are carried out by the CSPICE routines 
 
      q2m_c {quaternion to matrix} 
      m2q_c {matrix to quaternion} 
 
   m2q_c always returns a quaternion with scalar part greater than 
   or equal to zero. 
 
-Examples
 
   1)  Let qid, qi, qj, qk be the "basis" quaternions 
 
          qid  =  ( 1, 0, 0, 0 ) 
          qi   =  ( 0, 1, 0, 0 ) 
          qj   =  ( 0, 0, 1, 0 ) 
          qk   =  ( 0, 0, 0, 1 ) 
 
       respectively.  Then the calls 
 
          qxq_c ( qi, qj, ixj );
          qxq_c ( qj, qk, jxk );
          qxq_c ( qk, qi, kxi );
 
       produce the results 
 
          ixj == qk 
          jxk == qi 
          kxi == qj 
 
       All of the calls 
 
          qxq_c ( qi, qi, qout );
          qxq_c ( qj, qj, qout );
          qxq_c ( qk, qk, qout );
 
       produce the result 
 
          qout  ==  -qid
 
       For any quaternion Q, the calls 
 
          qxq_c ( qid, q,   qout );
          qxq_c ( q,   qid, qout );
 
       produce the result 
 
          qout  ==  q 
 
 
 
   2)  Composition of rotations:  let `cmat1' and `cmat2' be two 
       C-matrices (which are rotation matrices).  Then the 
       following code fragment computes the product cmat1 * cmat2: 
 
 
          /. 
          Convert the C-matrices to quaternions. 
          ./
          m2q_c ( cmat1, q1 );
          m2q_c ( cmat2, q2 );
 
          /.
          Find the product. 
          ./ 
          qxq_c ( q1, q2, qout ); 
 
          /.
          Convert the result to a C-matrix. 
          ./ 
          q2m_c ( qout, cmat3 );
 
          /.
          Multiply `cmat1' and `cmat2' directly. 
          ./ 
          mxm_c ( cmat1, cmat2, cmat4 );
 
          /.
          Compare the results.  The difference `diff' of 
          `cmat3' and `cmat4' should be close to the zero 
          matrix. 
          ./ 
          vsubg_c ( 9, cmat3, cmat4, diff );

 
-Restrictions
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman    (JPL) 
 
-Literature_References
 
   None. 
 
-Version
 
   -CSPICE Version 1.0.0, 27-OCT-2005 (NJB)

-Index_Entries
 
   quaternion times quaternion 
   multiply quaternion by quaternion 
-&
*/

{ /* Begin qxq_c */

   /*
   Local variables
   */
   SpiceDouble             cross[3];


   /*
   This routine is error free.
   */

   /*
   Assign the scalar portion of the product `vout'. 
   */
   qout[0]  =  q1[0]*q2[0] - vdot_c( q1+1, q2+1 );

   /*
   Compute the cross product term of the vector component of
   vout.
   */
   vcrss_c ( q1+1, q2+1, cross );

   /*
   Assign the vector portion of the product `vout'. 
   */
   vlcom3_c ( q1[0],   q2+1,  
              q2[0],   q1+1,  
              1.0,     cross,   qout+1 );


} /* End qxq_c */
