/*

-Procedure f_quat_c ( Quaternion routine tests )

 
-Abstract
 
   This family tests the CSPICE quaternion routines.
 
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
   #include <stdio.h>
   #include "SpiceUsr.h"
   #include "SpiceZfc.h"
   #include "SpiceZmc.h"
   #include "tutils_c.h"
   

   void f_quat_c ( SpiceBoolean * ok )

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
 
   This routine tests the CSPICE quaternion wrappers.  These are:

      qdq2av_c
      qxq_c
       
-Examples
 
   None.
    
-Restrictions
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
 
-Literature_References
 
   None. 
 
-Version
 
   -tspice_c Version 1.0.0 31-OCT-2005 (NJB)

-&
*/

{ /* Begin f_quat_c */



   /*
   Local parameters
   */
   #define  TIGHT          ( 1.e-14 )
   #define  MEDIUM         ( 1.e-12 )

   /*
   Static variables
   */
   static SpiceDouble      qid    [4] = {  1.0, 0.0, 0.0, 0.0 };
   static SpiceDouble      qidneg [4] = { -1.0, 0.0, 0.0, 0.0 };
   static SpiceDouble      qi     [4] = {  0.0, 1.0, 0.0, 0.0 };
   static SpiceDouble      qj     [4] = {  0.0, 0.0, 1.0, 0.0 };
   static SpiceDouble      qk     [4] = {  0.0, 0.0, 0.0, 1.0 };

   /*
   Local variables
   */
   SpiceDouble             angle  [3];
   SpiceDouble             av     [3];
   SpiceDouble             avx    [3];
   SpiceDouble             dm     [3][3];
   SpiceDouble             dq     [4];
   SpiceDouble             expav  [3];
   SpiceDouble             m1     [3][3];
   SpiceDouble             m2     [3][3];
   SpiceDouble             mexp   [3][3];
   SpiceDouble             mout   [3][3];
   SpiceDouble             q      [4];
   SpiceDouble             q1     [4];
   SpiceDouble             q2     [4];
   SpiceDouble             qav    [4];
   SpiceDouble             qexp   [4];
   SpiceDouble             qout   [4];
   SpiceDouble             xtrans [6][6];

   SpiceInt                i;

         
   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_quat_c" );
   
      
   /*
   --- Case: ------------------------------------------------------
   */
   tcase_c ( "qxq_c test:  Check compliance with "
             "Hamilton's rules.  Test QI x QJ."  );

   qxq_c ( qi, qj, qout );
   chckad_c ( "i*j", qout, "~", qk, 4, TIGHT, ok );

      
   /*
   --- Case: ------------------------------------------------------
   */
   tcase_c ( "qxq_c test:  Check compliance with "
             "Hamilton's rules.  Test QJ x QK."  );

   qxq_c ( qj, qk, qout );
   chckad_c ( "j*k", qout, "~", qi, 4, TIGHT, ok );

      
   /*
   --- Case: ------------------------------------------------------
   */
   tcase_c ( "qxq_c test:  Check compliance with "
             "Hamilton's rules.  Test QK x QI."  );

   qxq_c ( qk, qi, qout );
   chckad_c ( "k*i", qout, "~", qj, 4, TIGHT, ok );

      
   /*
   --- Case: ------------------------------------------------------
   */
   tcase_c ( "qxq_c test:  Check compliance with "
             "Hamilton's rules.  Test QI x QI."  );

   qxq_c ( qi, qi, qout );
   chckad_c ( "k*i", qout, "~", qidneg, 4, TIGHT, ok );

      
   /*
   --- Case: ------------------------------------------------------
   */
   tcase_c ( "qxq_c test:  Check compliance with "
             "Hamilton's rules.  Test QJ x QJ."  );

   qxq_c ( qj, qj, qout );
   chckad_c ( "j*j", qout, "~", qidneg, 4, TIGHT, ok );


   /*
   --- Case: ------------------------------------------------------
   */
   tcase_c ( "qxq_c test:  Check compliance with "
             "Hamilton's rules.  Test QK x QK."  );

   qxq_c ( qk, qk, qout );
   chckad_c ( "k*k", qout, "~", qidneg, 4, TIGHT, ok );

      
   /*
   --- Case: ------------------------------------------------------
   */
   tcase_c ( "qxq_c test:  Check right-multiplication by the identity." );

   qexp[0] = 1.0;
   qexp[1] = 2.0;
   qexp[2] = 3.0;
   qexp[3] = 4.0;
         
   qxq_c ( qexp, qid, qout );
   chckad_c ( "qexp * 1", qout, "~", qexp, 4, TIGHT, ok );

      
   /*
   --- Case: ------------------------------------------------------
   */
   tcase_c ( "qxq_c test:  Check left-multiplication by the identity." );

   qexp[0] = 1.0;
   qexp[1] = 2.0;
   qexp[2] = 3.0;
   qexp[3] = 4.0;
         
   qxq_c ( qid, qexp, qout );
   chckad_c ( "1 * qexp", qout, "~", qexp, 4, TIGHT, ok );

      
   /*
   --- Case: ------------------------------------------------------
   */
   tcase_c ( "Multiply two rotations via quaternion multiplication."  );

   eul2m_c ( rpd_c() *   20,    rpd_c() * 10,  rpd_c() * 70,
             3,                 1,             3,               m1 );

   eul2m_c ( rpd_c() * (-20),   rpd_c() * 30,  rpd_c() * (-10),
             3,                 1,             3,               m2 );

   m2q_c ( m1, q1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   m2q_c ( m2, q2 );
   chckxc_c ( SPICEFALSE, " ", ok );

   qxq_c ( q1, q2, qout );
   q2m_c ( qout,   mout );
  
   mxm_c ( m1, m2, mexp );

   chckad_c ( "mout", (SpiceDouble *)mout, "~", 
                      (SpiceDouble *)mexp, 9, MEDIUM, ok );


   /*
   qdq2av_c tests follow. 
   */

   /*
   --- Case: ------------------------------------------------------
   */
   tcase_c ( "Produce quaternion and derivative from Euler "
             "angles and a.v.  Recover a.v. from qdq2av_c; "
             "compare to original a.v. "                    );

 
   /*
   Start with a known rotation and angular velocity.  Find
   the quaternion and quaternion derivative.  The latter is
   computed from
 
                         *
          AV  =   -2  * Q  * DQ
 
          DQ  =  -1/2 * Q  * AV


   */
   angle[0] =  -20.0 * rpd_c();
   angle[1] =   50.0 * rpd_c();
   angle[2] =  -60.0 * rpd_c();

   eul2m_c ( angle[2], angle[1], angle[0], 3, 1, 3, m1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   m2q_c ( m1, q );

   /*
   Choose an angular velocity vector.  
   */
   expav[0] = 1.0;
   expav[1] = 2.0;
   expav[2] = 3.0;

   /*
   Form the quaternion derivative.
   */
   qav[0]  =  0.0;
   vequ_c ( expav, qav+1 );

   qxq_c ( q, qav, dq );

   vsclg_c ( -0.5, dq, 4, dq );

   /*
   Recover angular velocity from `q' and `dq' using qdq2av_c.
   */
   qdq2av_c ( q, dq, av );

   /*
   Do a consistency check against the orginal a.v.  This is
   an intermediate check; it demonstrates invertability but
   not corrrectness of our formulas.
   */
   chckad_c ( "av from q and dq", av, "~", expav, 3, MEDIUM, ok );


   /*
   --- Case: ------------------------------------------------------
   */
   tcase_c ( "Map a quaternion and derivative to angular "
             "velocity via a transformation matrix and "
             "xf2rav_c.  Compare to result from qdq2av_c." );

   /*
   Now we'll obtain the angular velocity from `q' and
   `dq' by an alternate method.

   Convert `q' back to a rotation matrix.
   */
   q2m_c ( q, m1 );

   /*
   Convert `q' and `dq' to a rotation derivative matrix.  This
   somewhat messy procedure is based on differentiating the
   formula for deriving a rotation from a quaternion, then
   substituting components of `q' and `dq' into the derivative
   formula.
   */

   dm[0][0]  =  -4.0  * (   q[2]*dq[2]  +  q[3]*dq[3]  );

   dm[0][1]  =   2.0  * (   q[1]*dq[2]  +  q[2]*dq[1]
                          - q[0]*dq[3]  -  q[3]*dq[0]  );

   dm[0][2]  =   2.0  * (   q[1]*dq[3]  +  q[3]*dq[1]
                          + q[0]*dq[2]  +  q[2]*dq[0]  );

   dm[1][0]  =   2.0  * (   q[1]*dq[2]  +  q[2]*dq[1]
                          + q[0]*dq[3]  +  q[3]*dq[0]  );

   dm[1][1]  =  -4.0  * (   q[1]*dq[1]  +  q[3]*dq[3]  );

   dm[1][2]  =   2.0  * (   q[2]*dq[3]  +  q[3]*dq[2]
                          - q[0]*dq[1]  -  q[1]*dq[0]  );

   dm[2][0]  =   2.0  * (   q[3]*dq[1]  +  q[1]*dq[3]
                          - q[0]*dq[2]  -  q[2]*dq[0]  );

   dm[2][1]  =   2.0  * (   q[2]*dq[3]  +  q[3]*dq[2]
                          + q[0]*dq[1]  +  q[1]*dq[0]  );

   dm[2][2]  =  -4.0  * (   q[1]*dq[1]  +  q[2]*dq[2]  );

   /*
   Form the state transformation matrix corresponding to `m'
   and `dm'.
   */

   /*
   Upper left block: 
   */
   for ( i = 0;  i < 3;  i++ )
   {
      vequ_c ( m1[i], xtrans[i] );
   }
   
   /*
   Upper right block: 
   */
   for ( i = 0;  i < 3;  i++ )
   {
      vpack_c ( 0.0, 0.0, 0.0, xtrans[i]+3 );
   }

   /*
   Lower left block: 
   */
   for ( i = 0;  i < 3;  i++ )
   {
      vequ_c ( dm[i], xtrans[3+i] );
   }

   /*
   Lower right block: 
   */
   for ( i = 0;  i < 3;  i++ )
   {
      vequ_c ( m1[i], xtrans[3+i]+3  );
   }

   /*
   Now use xf2rav_c to produce the expected angular velocity.
   */
   xf2rav_c ( xtrans, mout, avx );

   chckad_c ( "av from q and dq", av, "~", avx, 3, MEDIUM, ok );


   /*
   Retrieve the currendt test status.
   */  
   t_success_c ( ok ); 
   
   
} /* End f_quat_c */



