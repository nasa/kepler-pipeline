/*

-Procedure f_ck05_c ( Test wrappers for CK type 5 routines )

 
-Abstract
 
   Perform tests on CSPICE wrappers for CK type 5 functions.
 
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
   

   void f_ck05_c ( SpiceBoolean * ok )

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
 
   This routine tests the CK type 5 wrappers. 
   The set is:
      
      ck05_c

   The rest of the CK type 5 routines are tested indirectly.
           
-Examples
 
   None.
    
-Restrictions
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
 
-Literature_References
 
   None. 
 
-Version

   -tspice_c Version 1.2.0 05-JAN-2005 (NJB)

       Updated to use dafopw_c instead of dafopw_.

   -tspice_c Version 1.1.0 11-FEB-2003 (NJB)

       Some error messages contstructed using repmot_c had
       invalid arguments; these were corrected. 

       The utility routine chkSubset used the wrong name
       in its check in and check out calls; this was
       corrected.       

       Bug fix:  corrected call which passed the variable
       avf by value instead of reference.

   -tspice_c Version 1.0.0 06-SEP-2002 (NJB)

 
-&
*/

{ /* Begin f_ck05_c */

   /*
   Prototypes: 
   */
   void chkSubset ( SpiceInt              inst,
                    SpiceDouble           sclkdp,
                    SpiceDouble           expCmat[3][3],
                    SpiceDouble           expAv[3],
                    SpiceCK05Subtype      subtyp,
                    SpiceDouble           rate,
                    SpiceDouble         * epochs,
                    void                * expPackets,
                    SpiceInt              lb,
                    SpiceInt              ub,
                    SpiceBoolean        * ok           );



   void chkPntArray ( SpiceInt              inst,
                      SpiceInt              index0,
                      SpiceInt              indexMax,
                      SpiceDouble           step,
                      SpiceCK05Subtype      subtyp,
                      SpiceDouble         * epochs,
                      SpiceDouble           tol,
                      void                * expPackets,
                      SpiceBoolean        * ok         );

   /*
   Local macros
   */
   
   #define TRASH(file)     if ( remove(file) !=0 )                         \
                           printf ("***Unable to remove %s\n\n", file ); 


   /*
   Constants
   */
   /*   #define BIG_N           11000 */

   #define BIG_CTR         5
   #define BIG_DEG         3
   #define BIG_ID          -10000
   #define BIG_N           400
   #define BIG_STEP        10.0
   #define C05PS0          8
   #define C05PS1          4
   #define C05PS2          14
   #define C05PS3          7
   #define CHBDEG          2
   #define CK01           "test01.bc"
   #define CK05_1         "test05_1.bc"
   #define CK05_ALT       "test05_alt.bc"
   #define CK05_BIG       "test05_big.bc"
   #define CK05_BIG_GAP   "test05_big_gap.bc"
   #define CK05_CUBE      "test05_cube.bc"
   #define CK05_GAP       "test05_gap.bc"
   #define CK05_SMALL     "test05_small.bc"
   #define CK05_TOL       "test05_tol.bc"
   #define DSCSIZ          5
   #define LNSIZE          81
   #define LOOSE_RE        1.e-3
   #define MED_MX          1.e-12
   #define MED_N           300
   #define NUMCAS          10
   #define N_DISCRETE      9
   #define N_RECORDS       4
   #define POLY_DEG        3
   #define REF1            "J2000"
   #define SIDLEN          41
   #define SMALL_N         20
   #define TIGHT_MX        1.e-14
   #define TIGHT_RE        1.e-14
   #define TINY_N          10
   #define UTC1            "1999 jul 1"
   #define VERY_LOOSE_RE   0.1
   
   /*
   Static variables
   */    
   


                              

   /*
   Packets for testing ckw05_c:
   */




   
   /*
   Local variables
   */
   logical                 avf;

   SpiceBoolean            avflag;
   SpiceBoolean            found;

   SpiceChar               expRef   [ LNSIZE ];
   SpiceChar               label    [ LNSIZE ];
   SpiceChar               segid    [ SIDLEN ];

   /*   
   static SpiceDouble      bigHermiteList  [ BIG_N ][12];

   static SpiceDouble      bigLagrangeList [ BIG_N ][6];
   */
   /*
   SpiceDouble             bigEpochList    [ BIG_N ];
   */
   SpiceDouble             epochList       [ BIG_N ];
   SpiceDouble             startList       [ BIG_N ];
   SpiceDouble             medAvvs         [ BIG_N ][3];
   SpiceDouble             bigStartList    [ BIG_N ];

   SpiceDouble             angle;

   SpiceDouble             av[3];
   SpiceDouble             endTag;
   SpiceDouble             expAv[3];
   SpiceDouble             avrate;
   SpiceDouble             cmat[3][3];

   SpiceDouble             clkout;
   SpiceDouble             descr    [5];
   SpiceDouble             dq       [4];
   /*
   SpiceDouble             expAv    [3];
   */
   /*
   SpiceDouble             expPacket[14];
   */
   SpiceDouble             q[4];
   SpiceDouble             qav[4];
   SpiceDouble             rate;
   SpiceDouble             record   [16];

   SpiceDouble             scale_big;
   SpiceDouble             scale_small;
   SpiceDouble             sclkdp;


   /*
   SpiceDouble             step;
   */
   SpiceDouble             tol;

   SpiceDouble             type2LinPackets[ BIG_N ][ C05PS2 ];

   SpiceDouble             type0Packets[ BIG_N ][ C05PS0 ];
   SpiceDouble             type1Packets[ BIG_N ][ C05PS1 ];
   SpiceDouble             type2Packets[ BIG_N ][ C05PS2 ];
   SpiceDouble             type3Packets[ BIG_N ][ C05PS3 ];

   SpiceDouble             type0Packets_alt[ SMALL_N ][ C05PS0 ];
   SpiceDouble             type1Packets_alt[ SMALL_N ][ C05PS1 ];
   SpiceDouble             type2Packets_alt[ SMALL_N ][ C05PS2 ];
   SpiceDouble             type3Packets_alt[ SMALL_N ][ C05PS3 ];

   SpiceDouble             z [3] = { 0.0, 0.0, 1.0 };

   SpiceInt                degree;
   SpiceInt                endidx;
   SpiceInt                expInst[4] = { -41000, -41001, -41002, -41003 };
   SpiceInt                handle;
   SpiceInt                i;
   SpiceInt                j;
   SpiceInt                n;
   /*
   SpiceInt                newh;
   */
   /*
   SpiceInt                nints;
   */

   SpiceBoolean            fnd ;



   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_ck05_c" );

   
   /*
   Create and load a leapseconds kernel.
   */
   tstlsk_c ();
   chckxc_c ( SPICEFALSE, " ", ok );
   

   /*
   Define some CK data sets for use in testing.  First set:  a 
   sequence of rotations about the z-axis.  The C-matrix starts
   out as the identity.  The ith attitude is obtained by 
   rotating about the z-axis by i microradians relative to the (i-1)st
   attitude.

   The ith epoch is simply i.
   */
   angle       = 0.0;
   scale_small = 1.e-9;

   for ( i = 0;  i < BIG_N;  i++ )
   {
      angle  -=  i * scale_small;

      axisar_c ( z, angle, cmat );

      m2q_c ( cmat, type1Packets[i] );

      epochList[i] = i;
   }

   

   /*
   Create a set of type 3 packets.  For these, we need angular 
   velocity.
   */

   for ( i = 0;  i < BIG_N;  i++ )
   {
      avrate  =  i * scale_small;

      vscl_c ( avrate, z, av );

      MOVED( type1Packets[i], 4,  type3Packets[i]      );
      MOVED( av,              3, (type3Packets[i]) + 4 );

   }
 

   /*
   Create a set of type 0 packets.  Use the angular velocities
   we created for the series of type 3 packets; derive
   quaternion derivatives from the quaternions and angular 
   velocities.
   */

   for ( i = 0;  i < BIG_N;  i++ )
   {
       /*
       Capture the quaternion and a.v. from the ith packet
       in the type 3 packet array. We embed the a.v. vector
       in the last 3 components of the quaternion qav.
       */
       MOVED(  type3Packets[i],       4,  q     );
       MOVED( (type3Packets[i]) + 4,  3,  qav+1 );
       qav[0] = 0.0;                     

       /*
       Since we know from the discussion in QDQ2AV that 

                       *
          AV =   -2 * Q  * DQ

       we have

          DQ = -1/2 * Q  * AV

       */

       qxq_ ( q, qav, dq );

       vsclg_c ( -0.5, dq, 4, dq );

       MOVED( type3Packets[i], 4,   type0Packets[i]       );
       MOVED( dq,              4,  (type0Packets[i]) + 4  );


       /*
       if ( i < SMALL_N )
       {
       printf ( "\n\nf_ck05_c subtype 0 packet %ld: \n\n"
               "q = %f %f %f %f \n\n\n", 
                i,
                type0Packets[i][0], 
                type0Packets[i][1], 
                type0Packets[i][2], 
                type0Packets[i][3]  ); }
       */
   }
 

   /*
   Create a set of type 2 packets.  Use quaternion and quaternion
   derivatives from our collection of type 0 packets.  Use the
   angular velocities from our collection of type 3 packets.

   */

   for ( i = 0;  i < BIG_N;  i++ )
   {
       /*
       Capture the quaternion and a.v. from the ith packet
       in the type 3 packet array. We embed the a.v. vector
       in the last 3 components of the quaternion qav.
       */
       MOVED(  type0Packets[i],       4,  type2Packets[i]       );
       MOVED( (type0Packets[i]) + 4,  4, (type2Packets[i]) + 4  );
       MOVED( (type3Packets[i]) + 4,  3, (type2Packets[i]) + 8  );
 
       /*
       Scale the angular velocity by 1.0e-6 to obtain (bogus)
       angular acceleration. 
       */
       vscl_c ( 1.0e-12,  (type2Packets[i]) + 8,  (type2Packets[i]) + 11  );
   }
 

   /*
   ckw05 tests:
   */
   
   
   avflag  = SPICETRUE;
   strcpy ( expRef, "J2000" );
   rate    = 1000.0;
   
   
   /*
   Create a segment identifier.
   */
   strcpy ( segid, "CK type 05 test segment" );
   
   
   /*
   Open a new CK file.
   */
   
   if ( exists_c(CK05_1) )
   {
      TRASH (CK05_1);
   }
   
   ckopn_c ( CK05_1, "Type 05 CK internal file name.", 4, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   /*
   ckw05_c error cases follow.

   Most errors are detected in the underlying SPICELIB code.
   */
   tcase_c ( "ckw05_c test: write to invalid handle." );


   ckw05_c ( 0,
             C05TP1,
             POLY_DEG,
             epochList[0],
             epochList[MED_N-1], 
             expInst[1],
             "J2000",
             avflag,
             "CK05 subtype 1 segment 1",
             MED_N, 
             epochList,
             type1Packets,
             rate,
             1,
             epochList  );

   chckxc_c ( SPICETRUE, "SPICE(DAFNOSUCHHANDLE)", ok );




   tcase_c ( "ckw05_c test: segment ID too long." );


   ckw05_c ( handle,
             C05TP1,
             POLY_DEG,
             epochList[0],
             epochList[MED_N-1], 
             expInst[1],
             "J2000",
             avflag,
             "CK05 subtype 1 segment 1 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
             MED_N, 
             epochList,
             type1Packets,
             rate,
             1,
             epochList  );

   chckxc_c ( SPICETRUE, "SPICE(SEGIDTOOLONG)", ok );
  

  
   tcase_c ( "ckw05_c test: non-printable chars in seg ID" );

   segid[0] = (char)7;
   segid[1] = NULLCHAR;

   ckw05_c ( handle,
             C05TP1,
             POLY_DEG,
             epochList[0],
             epochList[MED_N-1], 
             expInst[1],
             "J2000",
             avflag,
             segid,
             MED_N, 
             epochList,
             type1Packets,
             rate,
             1,
             epochList  );

   chckxc_c ( SPICETRUE, "SPICE(NONPRINTABLECHARS)", ok );


  
   tcase_c ( "ckw05_c test: first SCLK epoch is negative" );

   strcpy ( segid, "CK05 subtype 1 segment 1" );

   epochList[0] = -1.0;

   ckw05_c ( handle,
             C05TP1,
             POLY_DEG,
             epochList[0],
             epochList[MED_N-1], 
             expInst[1],
             "J2000",
             avflag,
             segid,
             MED_N, 
             epochList,
             type1Packets,
             rate,
             1,
             epochList  );

   chckxc_c ( SPICETRUE, "SPICE(INVALIDSCLKTIME)", ok );

   epochList[0] = 0.0;




   tcase_c ( "ckw05_c test: SCLK times out of order" );

   strcpy ( segid, "CK05 subtype 1 segment 1" );

   epochList[3] = 1.0;

   ckw05_c ( handle,
             C05TP1,
             POLY_DEG,
             epochList[0],
             epochList[MED_N-1], 
             expInst[1],
             "J2000",
             avflag,
             segid,
             MED_N, 
             epochList,
             type1Packets,
             rate,
             1,
             epochList  );

   chckxc_c ( SPICETRUE, "SPICE(TIMESOUTOFORDER)", ok );

   epochList[3] = 3.0;



   tcase_c ( "ckw05_c test:  unrecognized frame" );


   ckw05_c ( handle,
             C05TP1,
             POLY_DEG,
             epochList[0],
             epochList[MED_N-1], 
             expInst[1],
             "spam",
             avflag,
             segid,
             MED_N, 
             epochList,
             type1Packets,
             rate,
             1,
             epochList  );

   chckxc_c ( SPICETRUE, "SPICE(INVALIDREFFRAME)", ok );




   tcase_c ( "ckw05_c test:  too few packets" );

   ckw05_c ( handle,
             C05TP1,
             POLY_DEG,
             epochList[0],
             epochList[MED_N-1], 
             expInst[1],
             "J2000",
             avflag,
             segid,
             0, 
             epochList,
             type1Packets,
             rate,
             1,
             epochList  );

   chckxc_c ( SPICETRUE, "SPICE(TOOFEWPACKETS)", ok );



   tcase_c ( "ckw05_c test:  too few interpolation intervals" );


   ckw05_c ( handle,
             C05TP1,
             POLY_DEG,
             epochList[0],
             epochList[MED_N-1], 
             expInst[1],
             "J2000",
             avflag,
             segid,
             MED_N, 
             epochList,
             type1Packets,
             rate,
             0,
             epochList  );

   chckxc_c ( SPICETRUE, "SPICE(INVALIDNUMINTS)", ok );



   tcase_c ( "ckw05_c test:  interpolation interval start times "
             "out of order."                                      );

   startList[0] = epochList[1];
   startList[1] = epochList[0];

   ckw05_c ( handle,
             C05TP1,
             POLY_DEG,
             epochList[0],
             epochList[MED_N-1], 
             expInst[1],
             "J2000",
             avflag,
             segid,
             MED_N, 
             epochList,
             type1Packets,
             rate,
             2,
             startList  );

   chckxc_c ( SPICETRUE, "SPICE(TIMESOUTOFORDER)", ok );



   tcase_c ( "ckw05_c test: interval start time is not a time tag." );

   startList[0] = 0.5;
   startList[1] = 1.0;

   ckw05_c ( handle,
             C05TP1,
             POLY_DEG,
             epochList[0],
             epochList[MED_N-1], 
             expInst[1],
             "J2000",
             avflag,
             segid,
             MED_N, 
             epochList,
             type1Packets,
             rate,
             2,
             startList  );

   chckxc_c ( SPICETRUE, "SPICE(INVALIDSTARTTIME)", ok );



   tcase_c ( "ckw05_c test: non-unit quaternion." );

   MOVED ( type1Packets[0], 4, q );

   type1Packets[0][0] = 10;

   ckw05_c ( handle,
             C05TP1,
             POLY_DEG,
             epochList[0],
             epochList[MED_N-1], 
             expInst[1],
             "J2000",
             avflag,
             segid,
             MED_N, 
             epochList,
             type1Packets,
             rate,
             1,
             epochList  );

   chckxc_c ( SPICETRUE, "SPICE(NONUNITQUATERNION)", ok );

   MOVED ( q, 4, type1Packets[0] );



   tcase_c ( "ckw05_c test: even interpolation degree." );


   ckw05_c ( handle,
             C05TP1,
             2,
             epochList[0],
             epochList[MED_N-1], 
             expInst[1],
             "J2000",
             avflag,
             segid,
             MED_N, 
             epochList,
             type1Packets,
             rate,
             1,
             epochList  );

   chckxc_c ( SPICETRUE, "SPICE(INVALIDDEGREE)", ok );



   tcase_c ( "ckw05_c test: invalid subtype code" );

   /*
   Since the subtype argument is an enumerated type in CSPICE,
   ckw05_c doesn't signal this error.  To exercise the error
   handling, we must call ckw05_ directly. 
   */
   
   i      =    -17;
   degree =      7;
   avf    =      1;
   n      =  MED_N;


   ckw05_  ( (integer    * ) &handle,
             (integer    * ) &i,
             (integer    * ) &degree,
             (doublereal * ) &(epochList[0]),
             (doublereal * ) &(epochList[MED_N-1]), 
             (integer    * ) &expInst[1],
             (char       * ) "J2000",
             (logical    * ) &avf,
             (char       * ) segid,
             (integer    * ) &n, 
             (doublereal * ) epochList,
             (doublereal * ) type1Packets,
             (doublereal * ) &rate,
             (integer    * ) &n, 
             (doublereal * ) epochList, 
             (ftnlen       ) 5,
             (ftnlen       ) strlen(segid)         );


   chckxc_c ( SPICETRUE, "SPICE(NOTSUPPORTED)", ok );



   tcase_c ( "ckw05_c test: interpolation degree 0" );


   ckw05_c ( handle,
             C05TP1,
             0,
             epochList[0],
             epochList[MED_N-1], 
             expInst[1],
             "J2000",
             avflag,
             segid,
             MED_N, 
             epochList,
             type1Packets,
             rate,
             1,
             epochList  );

   chckxc_c ( SPICETRUE, "SPICE(INVALIDDEGREE)", ok );


   tcase_c ( "ckw05_c test: interpolation degree -1" );


   ckw05_c ( handle,
             C05TP1,
             -1,
             epochList[0],
             epochList[MED_N-1], 
             expInst[1],
             "J2000",
             avflag,
             segid,
             MED_N, 
             epochList,
             type1Packets,
             rate,
             1,
             epochList  );

   chckxc_c ( SPICETRUE, "SPICE(INVALIDDEGREE)", ok );


   tcase_c ( "ckw05_c test: interpolation degree 17" );


   ckw05_c ( handle,
             C05TP1,
             17,
             epochList[0],
             epochList[MED_N-1], 
             expInst[1],
             "J2000",
             avflag,
             segid,
             MED_N, 
             epochList,
             type1Packets,
             rate,
             1,
             epochList  );

   chckxc_c ( SPICETRUE, "SPICE(INVALIDDEGREE)", ok );



   tcase_c ( "ckw05_c test: descriptor bounds out of order" );


   ckw05_c ( handle,
             C05TP1,
             POLY_DEG,
             epochList[MED_N-1], 
             epochList[0],
             expInst[1],
             "J2000",
             avflag,
             segid,
             MED_N, 
             epochList,
             type1Packets,
             rate,
             1,
             epochList  );

   chckxc_c ( SPICETRUE, "SPICE(BADDESCRTIMES)", ok );



   tcase_c ( "ckw05_c test: null segment ID" );


   ckw05_c ( handle,
             C05TP1,
             POLY_DEG,
             epochList[0],
             epochList[MED_N-1], 
             expInst[1],
             "J2000",
             avflag,
             NULLCPTR,
             MED_N, 
             epochList,
             type1Packets,
             rate,
             1,
             epochList  );

   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );



   tcase_c ( "ckw05_c test: empty segment ID" );


   ckw05_c ( handle,
             C05TP1,
             POLY_DEG,
             epochList[0],
             epochList[MED_N-1], 
             expInst[1],
             "J2000",
             avflag,
             "",
             MED_N, 
             epochList,
             type1Packets,
             rate,
             1,
             epochList  );

   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );



   tcase_c ( "ckw05_c test: null frame name" );


   ckw05_c ( handle,
             C05TP1,
             POLY_DEG,
             epochList[0],
             epochList[MED_N-1], 
             expInst[1],
             NULLCPTR,
             avflag,
             segid,
             MED_N, 
             epochList,
             type1Packets,
             rate,
             1,
             epochList  );

   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );



   tcase_c ( "ckw05_c test: empty frame name" );


   ckw05_c ( handle,
             C05TP1,
             POLY_DEG,
             epochList[0],
             epochList[MED_N-1], 
             expInst[1],
             "",
             avflag,
             segid,
             MED_N, 
             epochList,
             type1Packets,
             rate,
             1,
             epochList  );

   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );



   tcase_c ( "ckw05_c test: zero clock rate" );


   ckw05_c ( handle,
             C05TP1,
             POLY_DEG,
             epochList[0],
             epochList[MED_N-1], 
             expInst[1],
             "J2000",
             avflag,
             segid,
             MED_N, 
             epochList,
             type1Packets,
             0.0,
             1,
             epochList  );

   chckxc_c ( SPICETRUE, "SPICE(INVALIDVALUE)", ok );


   tcase_c ( "ckw05_c test: segment start time exceeds all time tags." );


   ckw05_c ( handle,
             C05TP1,
             POLY_DEG,
             epochList[MED_N-1] + 1, 
             epochList[MED_N-1] + 2, 
             expInst[1],
             "J2000",
             avflag,
             segid,
             MED_N, 
             epochList,
             type1Packets,
             rate,
             1,
             epochList  );

   chckxc_c ( SPICETRUE, "SPICE(EMPTYSEGMENT)", ok );
 

   tcase_c ( "ckw05_c test: no time tags between segment start time "
             "and segment end time."                                 );


   ckw05_c ( handle,
             C05TP1,
             POLY_DEG,
             epochList[0] + .001, 
             epochList[0] + .002, 
             expInst[1],
             "J2000",
             avflag,
             segid,
             MED_N, 
             epochList,
             type1Packets,
             rate,
             1,
             epochList  );

   chckxc_c ( SPICETRUE, "SPICE(EMPTYSEGMENT)", ok );



   /*
   That's it for the ckw05_c error tests. 
   */


   /*
   First normal test:  create a type 5 CK containing one
   subtype 1 segment. 
   */

   tcase_c ( "First normal test:  create a subtype 1 segment." );

   ckw05_c ( handle,
             C05TP1,
             POLY_DEG,
             epochList[0],
             epochList[MED_N-1], 
             expInst[1],
             "J2000",
             avflag,
             segid,
             MED_N, 
             epochList,
             type1Packets,
             rate,
             1,
             epochList  );

   chckxc_c ( SPICEFALSE, " ", ok );

   ckcls_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );



   /*
   Create a new CK file, this time containing segments with gaps. 
   Create a segment of each subtype.
   */
  
   if ( exists_c(CK05_GAP) )
   {
      TRASH (CK05_GAP);
   }

   ckopn_c ( CK05_GAP, " ", 0, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < MED_N;  i++ )
   {
      epochList[i] = i; 
   }

   for ( i = 0;  i < MED_N;  i+=2 )
   {
      bigStartList[i/2] = epochList[i]; 
   }


   tcase_c ( "ckw05_c normal test:  create a subtype 0  segment with "
             "a gap following each odd-indexed time tag."            );

   degree = 15;

   ckw05_c ( handle,
             C05TP0,
             degree,
             epochList[0],
             epochList[MED_N-1], 
             expInst[0],
             "J2000",
             avflag,
             segid,
             MED_N, 
             epochList,
             type0Packets,
             rate,
             MED_N/2,
             bigStartList  );

   chckxc_c ( SPICEFALSE, " ", ok );

   tcase_c ( "ckw05_c normal test:  create a subtype 1 segment with "
             "a gap following each odd-indexed time tag."            );

   ckw05_c ( handle,
             C05TP1,
             degree,
             epochList[0],
             epochList[MED_N-1], 
             expInst[1],
             "J2000",
             avflag,
             segid,
             MED_N, 
             epochList,
             type1Packets,
             rate,
             MED_N/2,
             bigStartList  );

   chckxc_c ( SPICEFALSE, " ", ok );



   tcase_c ( "ckw05_c normal test:  create a subtype 2  segment with "
             "a gap following each odd-indexed time tag."            );


   ckw05_c ( handle,
             C05TP2,
             degree,
             epochList[0],
             epochList[MED_N-1], 
             expInst[2],
             "J2000",
             avflag,
             segid,
             MED_N, 
             epochList,
             type2Packets,
             rate,
             MED_N/2,
             bigStartList  );
 
   chckxc_c ( SPICEFALSE, " ", ok );

   tcase_c ( "ckw05_c normal test:  create a subtype 3  segment with "
             "a gap following each odd-indexed time tag."            );


   ckw05_c ( handle,
             C05TP3,
             degree,
             epochList[0],
             epochList[MED_N-1], 
             expInst[3],
             "J2000",
             avflag,
             segid,
             MED_N, 
             epochList,
             type3Packets,
             rate,
             MED_N/2,
             bigStartList  );

   chckxc_c ( SPICEFALSE, " ", ok );

   ckcls_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );


   furnsh_c ( CK05_GAP );

   tcase_c ( "Try request times within gaps in segment of subtype 0 in "
             "CK file CK05_GAP."                                       );

   tol = 0.0;

   for ( i = 0;  i < MED_N;  i += 2 )
   {
      ckgpav_c ( expInst[0],  epochList[i] + 1.5,  tol,       "J2000", 
                 cmat,        av,                  &clkout,   &found   );
 
      chckxc_c ( SPICEFALSE, " ", ok );
     
      chcksl_c ( "found", found, SPICEFALSE, ok );
   }

   unload_c ( CK05_GAP );


   
   /*
   cknr05_ tests: 
   */

   tcase_c ( "cknr05_ test:  get number of records from segment." );

   dafopr_c ( CK05_1, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );

   dafbfs_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );

   daffna_c ( &found );
   chckxc_c ( SPICEFALSE, " ", ok );

   dafgs_c  ( descr  );
   chckxc_c ( SPICEFALSE, " ", ok );

   cknr05_ ( (integer    * ) &handle,
             (doublereal * ) descr, 
             (integer    * ) &n      );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "nrec", n, "=", MED_N, 0, ok );


   /*
   cknr05_c error tests: 
   */
   tcase_c ( "cknr05_ error test:  invalid handle." );

   i = -17;

   cknr05_ ( (integer    * ) &i,
             (doublereal * ) descr, 
             (integer    * ) &n      );

   chckxc_c ( SPICETRUE, "SPICE(HANDLENOTFOUND)", ok );



   tcase_c ( "cknr05_ error test:  try to access a type 1 segment." );
   /*
   Write a type 1 segment to the file.
   */

   dafcls_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );

   dafopw_c ( CK05_1, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );

   ckw01_c ( handle,
             epochList[0],
             epochList[MED_N-1], 
             expInst[0],
             "J2000",
             avflag,
             segid,
             MED_N, 
             epochList,
             type1Packets,
             medAvvs           );
      
   chckxc_c ( SPICEFALSE, " ", ok );

   dafcls_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );

   dafopr_c ( CK05_1, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );

   dafbfs_c ( handle );
   daffna_c ( &found );
   daffna_c ( &found );
   dafgs_c  ( descr  );
   chckxc_c ( SPICEFALSE, " ", ok );

   cknr05_ ( (integer    * ) &handle,
             (doublereal * ) descr, 
             (integer    * ) &n      );

   chckxc_c ( SPICETRUE, "SPICE(CKWRONGDATATYPE)", ok );

   dafcls_c ( handle );





   /*
   ckgr05_ tests: 
   */
   tcase_c ( "ckgr05_ normal test:  read all packets from the "
             "first (subtype 0) segment of the file CK05_GAP."   );

   dafopr_c ( CK05_GAP, &handle );
   dafbfs_c ( handle );
   daffna_c ( &found );
   dafgs_c  ( descr  );

   cknr05_ ( (integer    * ) &handle,
             (doublereal * ) descr, 
             (integer    * ) &n      );

   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < n;  i++ )
   {
      j = i + 1;

      ckgr05_ ( (integer    * ) &handle,
                (doublereal * ) descr, 
                (integer    * ) &j,
                (doublereal * ) record   );

      chckxc_c ( SPICEFALSE, " ", ok );

      
      chcksd_c ( "time tag", 
                  record[0], "=", epochList[i],  0.0, ok );
      
      chcksi_c ( "subtype", 
                  (SpiceInt)record[1], "=", C05TP0,  0, ok );

      chckad_c ( "subtype 0 packet",     
                  record+2,  "=",  type0Packets [i], C05PS0, 0.0, ok );
   }


   tcase_c ( "ckgr05_ normal test:  read all packets from the "
             "2nd (subtype 1) segment of the file CK05_GAP."   );

   daffna_c ( &found );
   dafgs_c  ( descr  );

   cknr05_ ( (integer    * ) &handle,
             (doublereal * ) descr, 
             (integer    * ) &n      );

   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < n;  i++ )
   {
      j = i + 1;

      ckgr05_ ( (integer    * ) &handle,
                (doublereal * ) descr, 
                (integer    * ) &j,
                (doublereal * ) record   );

      chckxc_c ( SPICEFALSE, " ", ok );

      
      chcksd_c ( "time tag", 
                  record[0], "=", epochList[i],  0.0, ok );
      
      chcksi_c ( "subtype", 
                  (SpiceInt)record[1], "=", C05TP1,  0, ok );

      chckad_c ( "subtype 1 packet",     
                  record+2,  "=",  type1Packets [i], C05PS1, 0.0, ok );
   }



   tcase_c ( "ckgr05_ normal test:  read all packets from the "
             "3rd (subtype 2) segment of the file CK05_GAP."   );

   daffna_c ( &found );
   dafgs_c  ( descr  );

   cknr05_ ( (integer    * ) &handle,
             (doublereal * ) descr, 
             (integer    * ) &n      );

   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < n;  i++ )
   {
      j = i + 1;

      ckgr05_ ( (integer    * ) &handle,
                (doublereal * ) descr, 
                (integer    * ) &j,
                (doublereal * ) record   );

      chckxc_c ( SPICEFALSE, " ", ok );

      
      chcksd_c ( "time tag", 
                  record[0], "=", epochList[i],  0.0, ok );
      
      chcksi_c ( "subtype", 
                  (SpiceInt)record[1], "=", C05TP2,  0, ok );

      chckad_c ( "subtype 2 packet",     
                  record+2,  "=",  type2Packets [i], C05PS2, 0.0, ok );
   }



   tcase_c ( "ckgr05_ normal test:  read all packets from the "
             "4th (subtype 3) segment of the file CK05_GAP."   );

   daffna_c ( &found );
   dafgs_c  ( descr  );

   cknr05_ ( (integer    * ) &handle,
             (doublereal * ) descr, 
             (integer    * ) &n      );

   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < n;  i++ )
   {
      j = i + 1;

      ckgr05_ ( (integer    * ) &handle,
                (doublereal * ) descr, 
                (integer    * ) &j,
                (doublereal * ) record   );

      chckxc_c ( SPICEFALSE, " ", ok );

      
      chcksd_c ( "time tag", 
                  record[0], "=", epochList[i],  0.0, ok );
      
      chcksi_c ( "subtype", 
                  (SpiceInt)record[1], "=", C05TP3,  0, ok );

      chckad_c ( "subtype 3 packet",     
                  record+2,  "=",  type3Packets [i], C05PS3, 0.0, ok );
   }





   dafcls_c ( handle );

   /*
   ckgr05_ error cases: 
   */
   tcase_c ( "ckgr05_ error test:  try to access a type 1 segment." );
   
   dafopr_c ( CK05_1, &handle );
   dafbfs_c ( handle );
   daffna_c ( &found );
   daffna_c ( &found );
   dafgs_c  ( descr  );
   chckxc_c ( SPICEFALSE, " ", ok );

   ckgr05_ ( (integer    * ) &handle,
             (doublereal * ) descr, 
             (integer    * ) &n,
             (doublereal * ) record      );

   chckxc_c ( SPICETRUE, "SPICE(CKWRONGDATATYPE)", ok );



   tcase_c ( "ckgr05_ error test:  negative record index." );

   dafbfs_c ( handle );
   daffna_c ( &found );
   dafgs_c  ( descr  );
   chckxc_c ( SPICEFALSE, " ", ok );

   i = -17;

   ckgr05_ ( (integer    * ) &handle,
             (doublereal * ) descr, 
             (integer    * ) &i,
             (doublereal * ) record      );

   chckxc_c ( SPICETRUE, "SPICE(CKNONEXISTREC)", ok );


   tcase_c ( "ckgr05_ error test:  record index too large." );

   i = 2 * BIG_N;

   ckgr05_ ( (integer    * ) &handle,
             (doublereal * ) descr, 
             (integer    * ) &i,
             (doublereal * ) record      );

   chckxc_c ( SPICETRUE, "SPICE(CKNONEXISTREC)", ok );


   tcase_c ( "ckgr05_ error test:  bad handle." );

   i = 0;

   ckgr05_ ( (integer    * ) &i,
             (doublereal * ) descr, 
             (integer    * ) &n,
             (doublereal * ) record      );

   chckxc_c ( SPICETRUE, "SPICE(HANDLENOTFOUND)", ok );


   dafcls_c ( handle );





   /*
   ckr05_c, cke05_c tests: 
   */

   /*
   Create a small file containing segments of all four subtypes.
   The segment size is small enough so there are no directories.
   These segments have no gaps.  The polynomial order will be 3.

   We'll use these files to ensure that we can pick up the 
   correct window of pointing to feed to the evaluator.  

   These tests also exercise the lookup logic for the case of
   having no pointing directories.

   The small segment size gives us manageable error output, if 
   we have any.
   */


   tcase_c ( "ckw05_c normal test:  create file CK05_SMALL."   );

  
   if ( exists_c(CK05_SMALL) )
   {
      TRASH (CK05_SMALL);
   }

   ckopn_c ( CK05_SMALL, " ", 0, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < SMALL_N;  i++ )
   {
      epochList[i] = i; 
   }

   bigStartList[0] = epochList[0];
   

   degree = 7;

   ckw05_c ( handle,
             C05TP0,
             degree,
             epochList[0],
             epochList[SMALL_N-1], 
             expInst[0],
             "J2000",
             avflag,
             segid,
             SMALL_N, 
             epochList,
             type0Packets,
             rate,
             1,
             bigStartList  );

   chckxc_c ( SPICEFALSE, " ", ok );

   degree = 3;

   ckw05_c ( handle,
             C05TP1,
             degree,
             epochList[0],
             epochList[SMALL_N-1], 
             expInst[1],
             "J2000",
             avflag,
             segid,
             SMALL_N, 
             epochList,
             type1Packets,
             rate,
             1,
             bigStartList  );

   chckxc_c ( SPICEFALSE, " ", ok );

   degree = 15;

   ckw05_c ( handle,
             C05TP2,
             degree,
             epochList[0],
             epochList[SMALL_N-1], 
             expInst[2],
             "J2000",
             avflag,
             segid,
             SMALL_N, 
             epochList,
             type2Packets,
             rate,
             1,
             bigStartList  );

   degree = 11;

   ckw05_c ( handle,
             C05TP3,
             degree,
             epochList[0],
             epochList[SMALL_N-1], 
             expInst[3],
             "J2000",
             avflag,
             segid,
             SMALL_N, 
             epochList,
             type3Packets,
             rate,
             1,
             bigStartList  );


   ckcls_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );


   /*
   Now we'll use the CK user-level readers to look up pointing. 
   */   
   furnsh_c ( CK05_SMALL );
   chckxc_c ( SPICEFALSE, " ", ok );


   /*
   We repeat all tests in this group, just to check whether there
   are any lingering side effects of the first set of calls.
   */

   for ( j = 0;  j < 2;  j++ )
   {

      tcase_c ( "Recover pointing from segment of subtype 0 in "
                "CK file CK05_SMALL."                            );

      
      tol = 0.0;

      chkPntArray ( expInst[0], 0,   SMALL_N,      1.0, C05TP0, 
                    epochList,  tol, type0Packets, ok           );
 

      tcase_c ( "Recover pointing from segment of subtype 1 in "
                "CK file CK05_SMALL."                            );


      chkPntArray ( expInst[1], 0,   SMALL_N,      1.0, C05TP1, 
                    epochList,  tol, type1Packets, ok           );
      

      tcase_c ( "Recover pointing from segment of subtype 2 in "
                "CK file CK05_SMALL."                            );

      chkPntArray ( expInst[2], 0,   SMALL_N,      1.0, C05TP2, 
                    epochList,  tol, type2Packets, ok           );
      


      tcase_c ( "Recover pointing from segment of subtype 3 in "
                "CK file CK05_SMALL."                            );

      chkPntArray ( expInst[3], 0,   SMALL_N,      1.0, C05TP3, 
                    epochList,  tol, type3Packets, ok           );

   }

   /*
   Check reduction of order at the segment boundaries.  Use
   the subtype 3 segment, which has an associated window size of 12.
   */

   /*
   First check reduction of order for request times in the 
   first six intervals. 
   */
   for ( i = 0;  i < 6;  i++ )
   {
      strcpy ( label, "Reduction of order: subtype 3, degree 11, "
                      "epoch is in the * interval."                );

      repmot_c ( label, "*", i+1, 'L', LNSIZE, label );

      tcase_c ( label );


      sclkdp = epochList[i] + 0.5;

      ckgpav_c ( expInst[3],  sclkdp,  tol,       "J2000", 
                 cmat,        av,      &clkout,   &found   );

      chckxc_c ( SPICEFALSE, " ", ok );

      chcksl_c ( "found", found, SPICETRUE, ok );

      if ( found )
      {
         chcksd_c ( "clkout", clkout, "=", sclkdp, 0.0, ok );

         chkSubset ( expInst[3], 
                     sclkdp,
                     cmat,
                     av,
                     C05TP3,
                     rate,
                     epochList,
                     type3Packets,
                     0,
                     6+i,
                     ok                  );
      }
   }

   /*
   Now check reduction of order for request times in the 
   last six intervals. 
   */
   for ( i = 0;  i < 6;  i++ )
   {
      strcpy ( label, "Reduction of order: subtype 3, degree 11, "
                      "epoch is in the * interval."                );

      repmot_c ( label, "*", SMALL_N - 1 - i, 'L', LNSIZE, label );

      tcase_c ( label );


      sclkdp = epochList[ SMALL_N - 1 - i ] - 0.5;

      ckgpav_c ( expInst[3],  sclkdp,  tol,       "J2000", 
                 cmat,        av,      &clkout,   &found   );

      chckxc_c ( SPICEFALSE, " ", ok );

      chcksl_c ( "found", found, SPICETRUE, ok );

      if ( found )
      {
         chcksd_c ( "clkout", clkout, "=", sclkdp, 0.0, ok );
         
         chkSubset ( expInst[3], 
                     sclkdp,
                     cmat,
                     av,
                     C05TP3,
                     rate,
                     epochList,
                     type3Packets,
                     SMALL_N -1 -6 -i ,
                     SMALL_N -1,
                     ok                  );
      } 
   }
  

   unload_c ( CK05_SMALL );



 

   /*
   Gap tests: 
   */

   /*
   Load CK05_GAP.  Repeat the tests we did on the large CK.  Use
   tolerance zero; make sure we can recover data values at the
   epochs where pointing is present.
   */
   furnsh_c ( CK05_GAP );
   chckxc_c ( SPICEFALSE, " ", ok );


   tcase_c ( "Recover pointing from segment of subtype 0 in "
             "CK file CK05_GAP."                            );

   tol       = 0.0;
   scale_big = scale_small;

   for ( i = 0;  i < MED_N;  i++ )
   {
      ckgpav_c ( expInst[0],  epochList[i],  tol,       "J2000", 
                 cmat,        av,            &clkout,   &found   );
 
      chckxc_c ( SPICEFALSE, " ", ok );
     
      chcksl_c ( "found", found, SPICETRUE, ok );

      /*
      Check the pointing:  convert the C-matrix to a quaternion
      and compare the quaternion to the orginal pointing. 
      */

      if ( found )
      {
          chcksd_c ( "clkout", clkout, "=", epochList[i], 0.0,  ok );

          m2q_c ( cmat, q );

          sprintf ( label, "subtype 0 packet: quaternion no. %ld", i );

          chckad_c ( label, q,  "~",  type0Packets [i], 4, TIGHT_MX, ok );

          /*
          Check the angular velocity:  the quaternion derivative stored
          in the type 0 packets was converted from the corresponding
          angular velocity vector in the subtype 3 packet list.
          */

          sprintf ( label, "subtype 0 packet: a.v. no. %ld", i );

          /*
          Scale a.v. from radians/second to radians/tick for comparison. 
          */
          vscl_c ( rate, av, av );

          chckad_c ( label, av,  "~",  (type3Packets[i])+4, 3, MED_MX, ok );
      }
      
   }

   

   tcase_c ( "Try request times within gaps in segment of subtype 0 in "
             "CK file CK05_GAP."                                       );


   tol = 0.0;

   for ( i = 0;  i < MED_N;  i += 2 )

   {
      ckgpav_c ( expInst[0],  epochList[i] + 1.5,  tol,       "J2000", 
                 cmat,        av,                  &clkout,   &fnd   );
 
      chckxc_c ( SPICEFALSE, " ", ok );
     
      chcksl_c ( "found", fnd, SPICEFALSE, ok );
   }



   unload_c ( CK05_GAP );




   /*
   Tolerance tests:
   */


   /*
   Demonstrate correct handling of tolerance values.

   Create a file with two segments:

     - One in which the descriptor bounds lie outside of the
       time tag range. 

     - One in which the descriptor bounds lie inside of the
       time tag range. 

   Both segments have a gap in the interior of their respective
   coverage intervals.
   */

   
   tcase_c ( "ckr05_normal test:  create file CK05_TOL."   );

  
   if ( exists_c(CK05_TOL) )
   {
      TRASH (CK05_TOL);
   }

   ckopn_c ( CK05_TOL, " ", 0, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );

   startList[0] =  0.0;
   startList[1] = 10.0;

   
   degree = 15;

   ckw05_c ( handle,
             C05TP0,
             degree,
             epochList[0] - 2.0,
             epochList[SMALL_N-1] + 2.0, 
             expInst[0],
             "J2000",
             avflag,
             segid,
             SMALL_N, 
             epochList,
             type0Packets,
             rate,
             2,
             startList  );

   chckxc_c ( SPICEFALSE, " ", ok );

   
   degree = 3;

   ckw05_c ( handle,
             C05TP1,
             degree,
             epochList[0] + 2.0,
             epochList[SMALL_N-1] - 2.0, 
             expInst[1],
             "J2000",
             avflag,
             segid,
             SMALL_N, 
             epochList,
             type1Packets,
             rate,
             2,
             startList  );

   chckxc_c ( SPICEFALSE, " ", ok );

   
   degree = 15;

   ckw05_c ( handle,
             C05TP3,
             degree,
             epochList[0],
             epochList[TINY_N-1], 
             expInst[3],
             "J2000",
             avflag,
             segid,
             TINY_N, 
             epochList,
             type3Packets,
             rate,
             1,
             startList  );

   chckxc_c ( SPICEFALSE, " ", ok );


   ckcls_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );

   
   furnsh_c ( CK05_TOL );
   chckxc_c ( SPICEFALSE, " ", ok );
  



   tcase_c ( "ckr05_normal test:  TOL == 0, request time "
             "lies in central gap."                        );

   tol = 0.0;

   ckgpav_c ( expInst[0],  epochList[9] + 0.5,  tol,       "J2000", 
              cmat,        av,                  &clkout,   &fnd   );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "fnd", fnd, SPICEFALSE, ok );



   tcase_c ( "ckr05_normal test:  TOL == 0.3, request time "
             "lies in central gap."                        );

   tol = 0.3;

   ckgpav_c ( expInst[0],  epochList[9] + 0.5,  tol,       "J2000", 
              cmat,        av,                  &clkout,   &fnd   );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "fnd", fnd, SPICEFALSE, ok );


   /*
   Repeat the following test to make sure the saved interval
   descriptor variables are correct. 
  */
   for ( i = 0;  i < 2;  i++ )
   {
      tcase_c ( "ckr05_normal test:  TOL == 0.4, request time "
                "lies in the left third of the central gap."      );

      tol    = 0.5;
      sclkdp = epochList[9] + 0.25;

      ckgpav_c ( expInst[0],  sclkdp,  tol,       "J2000", 
                 cmat,        av,      &clkout,   &fnd   );

      chckxc_c ( SPICEFALSE, " ", ok );

      chcksl_c ( "fnd", fnd, SPICETRUE, ok );

      chcksd_c ( "clkout", clkout, "=", epochList[9], 0.0, ok );
   }


   /*
   Repeat the following test to make sure the saved interval
   descriptor variables are correct. 
  */
   for ( i = 0;  i < 2;  i++ )
   {
      tcase_c ( "ckr05_normal test:  TOL == 0.4, request time "
                "lies in the right third of the central gap."      );

      tol    = 0.5;
      sclkdp = epochList[9] + 0.75;

      ckgpav_c ( expInst[0],  sclkdp,  tol,       "J2000", 
                 cmat,        av,      &clkout,   &fnd   );

      chckxc_c ( SPICEFALSE, " ", ok );

      chcksl_c ( "fnd", fnd, SPICETRUE, ok );

      chcksd_c ( "clkout", clkout, "=", epochList[10], 0.0, ok );
   }


   tcase_c ( "ckr05_normal test:  TOL == 0.4, request time "
             "lies in the first interval."                  );

   tol    = 0.5;
   sclkdp = epochList[0] + 0.75;

   ckgpav_c ( expInst[0],  sclkdp,  tol,       "J2000", 
              cmat,        av,      &clkout,   &fnd   );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "fnd", fnd, SPICETRUE, ok );

   chcksd_c ( "clkout", clkout, "=", sclkdp, 0.0, ok );







   tcase_c ( "ckr05_normal test:  TOL == 0, request time "
             "precedes segment start time by 1 tick.  "  
             "Segment bounds are outside range of pointing time tags."  );

   tol = 0.0;

   ckgpav_c ( expInst[0],  epochList[0] - 3.0,  tol,       "J2000", 
              cmat,        av,                  &clkout,   &fnd   );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "fnd", fnd, SPICEFALSE, ok );




   tcase_c ( "ckr05_normal test:  TOL == 0, request time "
             "exceeds segment end time by 1 tick. "        
             "Segment bounds are outside range of pointing time tags."  );


   ckgpav_c ( expInst[0],  epochList[SMALL_N-1] + 3.0,  tol,       "J2000", 
              cmat,        av,                          &clkout,   &fnd   );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "fnd", fnd, SPICEFALSE, ok );




   tcase_c ( "ckr05_normal test:  TOL == 1, request time "
             "precedes segment start time by 1 tick.  "  
             "Segment bounds are outside range of pointing time tags."  );


   tol = 1.0;

   ckgpav_c ( expInst[0],  epochList[0] - 3.0,  tol,       "J2000", 
              cmat,        av,                  &clkout,   &fnd   );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "fnd", fnd, SPICEFALSE, ok );



   tcase_c ( "ckr05_normal test:  TOL == 1, request time "
             "exceeds segment end time by 1 tick. "        
             "Segment bounds are outside range of pointing time tags."  );


   ckgpav_c ( expInst[0],  epochList[SMALL_N-1] + 3.0,  tol,       "J2000", 
              cmat,        av,                          &clkout,   &fnd   );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "fnd", fnd, SPICEFALSE, ok );



   tcase_c ( "ckr05_normal test:  TOL == 3, request time "
             "precedes segment start time by 1 tick.  "  
             "Segment bounds are outside range of pointing time tags."  );

   tol = 3.0;

   ckgpav_c ( expInst[0],  epochList[0] - 3.0,  tol,       "J2000", 
              cmat,        av,                  &clkout,   &fnd   );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "fnd", fnd, SPICETRUE, ok );

   if ( fnd )
   {
       chcksd_c ( "clkout", clkout, "=", epochList[0], 0.0,  ok );

       m2q_c ( cmat, q );

       sprintf ( label, "subtype 0 packet: quaternion no. %ld", i );

       chckad_c ( label, q,  "~",  type0Packets [0], 4, TIGHT_MX, ok );

       /*
       Check the angular velocity:  the quaternion derivative stored
       in the type 0 packets was converted from the corresponding
       angular velocity vector in the subtype 3 packet list.
       */

       sprintf ( label, "subtype 0 packet: a.v. no. %ld", i );

       /*
       Scale a.v. from radians/second to radians/tick for comparison. 
       */
       vscl_c ( rate, av, av );

       chckad_c ( label, av,  "~",  (type3Packets[0])+4, 3, MED_MX, ok );
   }


   tcase_c ( "ckr05_normal test:  TOL == 3, request time "
             "exceeds segment end time by 1 tick. "        
             "Segment bounds are outside range of pointing time tags."  );

 
   ckgpav_c ( expInst[0],  epochList[SMALL_N-1] + 3.0,  tol,       "J2000", 
              cmat,        av,                          &clkout,   &fnd   );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "fnd", fnd, SPICETRUE, ok );

   if ( fnd )
   {
       chcksd_c ( "clkout",  clkout, "=", epochList[SMALL_N-1], 0.0, ok );

       m2q_c ( cmat, q );

       sprintf ( label, "subtype 0 packet: quaternion no. %ld", i );

       j = SMALL_N - 1;

       chckad_c ( label, q,  "~",  type0Packets [j], 4, TIGHT_MX, ok );

       /*
       Check the angular velocity:  the quaternion derivative stored
       in the type 0 packets was converted from the corresponding
       angular velocity vector in the subtype 3 packet list.
       */

       sprintf ( label, "subtype 0 packet: a.v. no. %ld", i );

       /*
       Scale a.v. from radians/second to radians/tick for comparison. 
       */
       vscl_c ( rate, av, av );

       chckad_c ( label, av,  "~",  (type3Packets[j])+4, 3, MED_MX, ok );
   }




   tcase_c ( "ckr05_normal test:  TOL == 0.5, request time "
             "precedes first time tag by 1 tick.  "  
             "Segment bounds are outside range of pointing time tags."  );

   tol = 0.5;

   ckgpav_c ( expInst[0],  epochList[0] - 1.0,  tol,       "J2000", 
              cmat,        av,                  &clkout,   &fnd   );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "fnd", fnd, SPICEFALSE, ok );




   tcase_c ( "ckr05_normal test:  TOL == 0.5, request time "
             "exceeds last time tag by 1 tick. "        
             "Segment bounds are outside range of pointing time tags."  );

 
   ckgpav_c ( expInst[0],  epochList[SMALL_N-1] + 1.0,  tol,       "J2000", 
              cmat,        av,                          &clkout,   &fnd   );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "fnd", fnd, SPICEFALSE, ok );



   tcase_c ( "ckr05_normal test:  TOL == 1.0, request time "
             "precedes first time tag by 1 tick.  "  
             "Segment bounds are outside range of pointing time tags."  );

   tol = 1.0;

   ckgpav_c ( expInst[0],  epochList[0] - 1.0,  tol,       "J2000", 
              cmat,        av,                  &clkout,   &fnd   );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "fnd", fnd, SPICETRUE, ok );

   if ( fnd )
   {
       chcksd_c ( "clkout", clkout, "=", epochList[0], 0.0, ok );


       m2q_c ( cmat, q );


       sprintf ( label, "subtype 0 packet: quaternion no. %ld", i );

       chckad_c ( label, q,  "~",  type0Packets [0], 4, TIGHT_MX, ok );

       /*
       Check the angular velocity:  the quaternion derivative stored
       in the type 0 packets was converted from the corresponding
       angular velocity vector in the subtype 3 packet list.
       */

       sprintf ( label, "subtype 0 packet: a.v. no. %ld", i );

       /*
       Scale a.v. from radians/second to radians/tick for comparison. 
       */
       vscl_c ( rate, av, av );

       chckad_c ( label, av,  "~",  (type3Packets[0])+4, 3, MED_MX, ok );
   }




   tcase_c ( "ckr05_normal test:  TOL == 1.0, request time "
             "exceeds last time tag by 1 tick. "        
             "Segment bounds are outside range of pointing time tags."  );

 
   ckgpav_c ( expInst[0],  epochList[SMALL_N-1] + 1.0,  tol,       "J2000", 
              cmat,        av,                          &clkout,   &fnd   );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "fnd", fnd, SPICETRUE, ok );

   if ( fnd )
   {
       chcksd_c ( "clkout", clkout, "=", epochList[SMALL_N-1], 0.0,  ok );

       m2q_c ( cmat, q );


       sprintf ( label, "subtype 0 packet: quaternion no. %ld", i );

       chckad_c ( label, q,  "~",  type1Packets[SMALL_N-1], 4, TIGHT_MX, 
                  ok );
   
       /*
       Check the angular velocity:  the quaternion derivative stored
       in the type 0 packets was converted from the corresponding
       angular velocity vector in the subtype 3 packet list.
       */

       sprintf ( label, "subtype 0 packet: a.v. no. %ld", i );

       /*
       Scale a.v. from radians/second to radians/tick for comparison. 
       */
       vscl_c ( rate, av, av );

       chckad_c ( label, av,  "~",  (type3Packets[SMALL_N-1])+4, 
                  3, MED_MX, ok );
   }





   /*
   Now we'll work with the second segment.  For this segment,
   the segment bounds are inside the range of time tags.
   */

   tcase_c ( "ckr05_normal test:  TOL == 0, request time "
             "precedes first time tag by 1 tick.  "  
             "Segment bounds are inside range of pointing time tags."  );

   tol = 0.0;

   ckgpav_c ( expInst[1],  epochList[0] - 1.0,  tol,       "J2000", 
              cmat,        av,                  &clkout,   &fnd   );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "fnd", fnd, SPICEFALSE, ok );




   tcase_c ( "ckr05_normal test:  TOL == 0, request time "
             "exceeds last time tag by 1 tick. "        
             "Segment bounds are inside range of pointing time tags."  );


   ckgpav_c ( expInst[1],  epochList[SMALL_N-1] + 1.0,  tol,       "J2000", 
              cmat,        av,                          &clkout,   &fnd   );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "fnd", fnd, SPICEFALSE, ok );




   tcase_c ( "ckr05_normal test:  TOL == 1, request time "
             "precedes first time tag by 1 tick.  "  
             "Segment bounds are inside range of pointing time tags."  );


   tol = 1.0;

   ckgpav_c ( expInst[1],  epochList[0] - 1.0,  tol,       "J2000", 
              cmat,        av,                  &clkout,   &fnd   );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "fnd", fnd, SPICEFALSE, ok );



   tcase_c ( "ckr05_normal test:  TOL == 1, request time "
             "exceeds last time tag by 1 tick. "        
             "Segment bounds are inside range of pointing time tags."  );


   ckgpav_c ( expInst[1],  epochList[SMALL_N-1] + 1.0,  tol,       "J2000", 
              cmat,        av,                          &clkout,   &fnd   );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "fnd", fnd, SPICEFALSE, ok );



   tcase_c ( "ckr05_normal test:  TOL == 3, request time "
             "precedes first time tag by 1 tick.  "  
             "Segment bounds are inside range of pointing time tags."  );

   tol = 3.0;

   ckgpav_c ( expInst[1],  epochList[0] - 1.0,  tol,       "J2000", 
              cmat,        av,                  &clkout,   &fnd   );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "fnd", fnd, SPICETRUE, ok );

   if ( found )
   {
       chcksd_c ( "clkout", clkout, "=", epochList[2], 0.0,  ok );

       m2q_c ( cmat, q );


       sprintf ( label, "subtype 1 packet: quaternion no. %ld", i );

       chckad_c ( label, q,  "~",  type1Packets [2], 4, TIGHT_MX, ok );
   }



   tcase_c ( "ckr05_normal test:  TOL == 3, request time "
             "exceeds last time tag by 1 tick. "        
             "Segment bounds are inside range of pointing time tags."  );

 
   ckgpav_c ( expInst[1],  epochList[SMALL_N-1] + 1.0,  tol,       "J2000", 
              cmat,        av,                          &clkout,   &fnd   );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "fnd", fnd, SPICETRUE, ok );

   if ( found )
   {
       chcksd_c ( "clkout", clkout, "=", epochList[SMALL_N-3], 0.0,  ok );

       m2q_c ( cmat, q );


       sprintf ( label, "subtype 1 packet: quaternion no. %ld", i );

       chckad_c ( label, q,  "~",  type1Packets[SMALL_N-3], 4, TIGHT_MX, 
                  ok );
   }



   tcase_c ( "ckr05_normal test:  TOL == 0.5, request time "
             "precedes segment start by 1 tick.  "  
             "Segment bounds are inside range of pointing time tags."  );

   tol = 0.5;

   ckgpav_c ( expInst[1],  epochList[2] - 1.0,  tol,       "J2000", 
              cmat,        av,                  &clkout,   &fnd   );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "fnd", fnd, SPICEFALSE, ok );



   tcase_c ( "ckr05_normal test:  TOL == 0.5, request time "
             "exceeds segment end by 1 tick. "        
             "Segment bounds are inside range of pointing time tags."  );

 
   ckgpav_c ( expInst[0],  epochList[SMALL_N-1] + 1.0,  tol,       "J2000", 
              cmat,        av,                          &clkout,   &fnd   );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "fnd", fnd, SPICEFALSE, ok );



   tcase_c ( "ckr05_normal test:  TOL == 1.0, request time "
             "precedes segment start by 1 tick.  "  
             "Segment bounds are inside range of pointing time tags."  );

   tol = 1.0;

   ckgpav_c ( expInst[1],  epochList[2] - 1.0,  tol,       "J2000", 
              cmat,        av,                  &clkout,   &fnd   );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "fnd", fnd, SPICETRUE, ok );

   if ( fnd )
   {
       chcksd_c ( "clkout", clkout, "=", epochList[2], 0.0,  ok );

       m2q_c ( cmat, q );


       sprintf ( label, "subtype 1 packet: quaternion no. %ld", i );

       chckad_c ( label, q,  "~",  type1Packets[2], 4, TIGHT_MX, 
                  ok );
   }



   tcase_c ( "ckr05_normal test:  TOL == 1.0, request time "
             "exceeds segment end by 1 tick. "        
             "Segment bounds are inside range of pointing time tags."  );

 
   ckgpav_c ( expInst[1],  epochList[SMALL_N-3] + 1.0,  tol,       "J2000", 
              cmat,        av,                          &clkout,   &fnd   );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "fnd", fnd, SPICETRUE, ok );

   if ( fnd )
   {
       chcksd_c ( "clkout", clkout, "=", epochList[SMALL_N-3], 0.0,  ok );

       m2q_c ( cmat, q );


       sprintf ( label, "subtype 1 packet: quaternion no. %ld", i );

       chckad_c ( label, q,  "~",  type1Packets[SMALL_N-3], 4, TIGHT_MX, 
                  ok );
   }



   /*
   Check reduction of order at the interpolation interval boundaries.  Use
   the first segment, which has an associated window size of 8.
   */

   /*
   First check reduction of order for request times in the 
   first four intervals. 
   */
   for ( i = 0;  i < 4;  i++ )
   {
      strcpy ( label, "Reduction of order: subtype 0, degree 15, "
                      "epoch is in the * interval."                );

      repmot_c ( label, "*", i+1, 'L', LNSIZE, label );

      tcase_c ( label );


      sclkdp = epochList[i] + 0.5;

      ckgpav_c ( expInst[0],  sclkdp,  tol,       "J2000", 
                 cmat,        av,      &clkout,   &found   );

      chckxc_c ( SPICEFALSE, " ", ok );

      chcksl_c ( "found", found, SPICETRUE, ok );

      if ( found )
      {
         chcksd_c ( "clkout", clkout, "=", sclkdp, 0.0, ok );

         chkSubset ( expInst[0], 
                     sclkdp,
                     cmat,
                     av,
                     C05TP0,
                     rate,
                     epochList,
                     type0Packets,
                     0,
                     4+i,
                     ok                  );
      }
   }

   /*
   Now check reduction of order for request times in the 
   last four intervals preceding the gap. 
   */
   for ( i = 0;  i < 4;  i++ )
   {
      strcpy ( label, "Reduction of order: subtype 3, degree 11, "
                      "epoch is in the * interval."                );

      endidx = 9;
      endTag = epochList[endidx];

      repmot_c ( label, "*", endidx - i, 'L', LNSIZE, label );

      tcase_c ( label );


      sclkdp = epochList[ endidx - i ] - 0.5;

      ckgpav_c ( expInst[0],  sclkdp,  tol,       "J2000", 
                 cmat,        av,      &clkout,   &found   );

      chckxc_c ( SPICEFALSE, " ", ok );

      chcksl_c ( "found", found, SPICETRUE, ok );

      if ( found )
      {
         chcksd_c ( "clkout", clkout, "=", sclkdp, 0.0, ok );
         
         chkSubset ( expInst[0], 
                     sclkdp,
                     cmat,
                     av,
                     C05TP0,
                     rate,
                     epochList,
                     type0Packets,
                     endidx -4 -i ,
                     endidx,
                     ok                  );
      } 
   }
  

   /*
   Now check reduction of order for lookups in the third segment,
   where the segment contains fewer pointing instances than are
   nominally required by the polynomial degree.
   */
   for ( i = 0;  i < 8;  i++ )
   {
      strcpy ( label, "Reduction of order: subtype 3, degree 15, "
                      "epoch is in the * interval."                );

      repmot_c ( label, "*", i+1, 'L', LNSIZE, label );

      tcase_c ( label );


      sclkdp = epochList[i] + 0.5;

      ckgpav_c ( expInst[3],  sclkdp,  tol,       "J2000", 
                 cmat,        av,      &clkout,   &found   );

      chckxc_c ( SPICEFALSE, " ", ok );

      chcksl_c ( "found", found, SPICETRUE, ok );

      if ( found )
      {
         chcksd_c ( "clkout", clkout, "=", sclkdp, 0.0, ok );

         j = mini_c ( 2, 8+i, TINY_N-1 );

         chkSubset ( expInst[3], 
                     sclkdp,
                     cmat,
                     av,
                     C05TP3,
                     rate,
                     epochList,
                     type3Packets,
                     0,
                     j,
                     ok                  );
      }
   }


   for ( i = 0;  i < 8;  i++ )
   {
      strcpy ( label, "Reduction of order: subtype 3, degree 15, "
                      "epoch is in the * interval."                );

      endidx = TINY_N - 1;
      endTag = epochList[endidx];

      repmot_c ( label, "*", endidx - i, 'L', LNSIZE, label );

      tcase_c ( label );


      sclkdp = epochList[ endidx - i ] - 0.5;

      ckgpav_c ( expInst[3],  sclkdp,  tol,       "J2000", 
                 cmat,        av,      &clkout,   &found   );

      chckxc_c ( SPICEFALSE, " ", ok );

      chcksl_c ( "found", found, SPICETRUE, ok );

      if ( found )
      {
         chcksd_c ( "clkout", clkout, "=", sclkdp, 0.0, ok );
         
         j = maxi_c ( 2, endidx-8-i, 0 );

         chkSubset ( expInst[3], 
                     sclkdp,
                     cmat,
                     av,
                     C05TP3,
                     rate,
                     epochList,
                     type3Packets,
                     j,
                     endidx,
                     ok                  );
      } 
   }
  

   unload_c ( CK05_TOL );















   tcase_c ( "ckw05_c normal test:  create file CK05_BIG."   );

  
   if ( exists_c(CK05_BIG) )
   {
      TRASH (CK05_BIG);
   }

   ckopn_c ( CK05_BIG, " ", 0, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < BIG_N;  i++ )
   {
      epochList[i] = i; 
   }

   bigStartList[0] = epochList[0];
   

   degree = 7;

   ckw05_c ( handle,
             C05TP0,
             degree,
             epochList[0],
             epochList[BIG_N-1], 
             expInst[0],
             "J2000",
             avflag,
             segid,
             BIG_N, 
             epochList,
             type0Packets,
             rate,
             1,
             bigStartList  );

   chckxc_c ( SPICEFALSE, " ", ok );

   degree = 3;

   ckw05_c ( handle,
             C05TP1,
             degree,
             epochList[0],
             epochList[BIG_N-1], 
             expInst[1],
             "J2000",
             avflag,
             segid,
             BIG_N, 
             epochList,
             type1Packets,
             rate,
             1,
             bigStartList  );

   chckxc_c ( SPICEFALSE, " ", ok );

   degree = 15;

   ckw05_c ( handle,
             C05TP2,
             degree,
             epochList[0],
             epochList[BIG_N-1], 
             expInst[2],
             "J2000",
             avflag,
             segid,
             BIG_N, 
             epochList,
             type2Packets,
             rate,
             1,
             bigStartList  );

   degree = 11;

   ckw05_c ( handle,
             C05TP3,
             degree,
             epochList[0],
             epochList[BIG_N-1], 
             expInst[3],
             "J2000",
             avflag,
             segid,
             BIG_N, 
             epochList,
             type3Packets,
             rate,
             1,
             bigStartList  );


   ckcls_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );


   /*
   Now we'll use the CK user-level readers to look up pointing. 
   */   
   furnsh_c ( CK05_BIG );
   chckxc_c ( SPICEFALSE, " ", ok );


   for ( j = 0;  j < 2;  j++ )
   {

      tcase_c ( "Recover pointing from segment of subtype 0 in "
                "CK file CK05_BIG."                            );

      
      tol = 0.0;

      chkPntArray ( expInst[0], 0,   BIG_N,      1.0, C05TP0, 
                    epochList,  tol, type0Packets, ok           );
 

      tcase_c ( "Recover pointing from segment of subtype 1 in "
                "CK file CK05_BIG."                            );


      chkPntArray ( expInst[1], 0,   BIG_N,      1.0, C05TP1, 
                    epochList,  tol, type1Packets, ok           );
      

      tcase_c ( "Recover pointing from segment of subtype 2 in "
                "CK file CK05_BIG."                            );

      chkPntArray ( expInst[2], 0,   BIG_N,      1.0, C05TP2, 
                    epochList,  tol, type2Packets, ok           );
      


      tcase_c ( "Recover pointing from segment of subtype 3 in "
                "CK file CK05_BIG."                            );

      chkPntArray ( expInst[3], 0,   BIG_N,      1.0, C05TP3, 
                    epochList,  tol, type3Packets, ok           );

   }



   unload_c ( CK05_BIG );




 
   /*
   Gap test:  in order to test the logic concerned with reading
   buffers of start time directories, we need an example with
   enough start time directories so that multiple buffering
   operations are needed.

   We'll create a large file with one subtype 3 segment.  The
   interpolation intervals will simply be the singleton sets
   containing the pointing time tags themselves.
   */

   tcase_c ( "ckw05_c normal test:  create file CK05_BIG_GAP."   );

  
   if ( exists_c(CK05_BIG_GAP) )
   {
      TRASH (CK05_BIG_GAP);
   }

   ckopn_c ( CK05_BIG_GAP, " ", 0, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < BIG_N;  i++ )
   {
      epochList   [i] = i; 
      bigStartList[i] = epochList[i];
   }
   
   degree = 3;

   ckw05_c ( handle,
             C05TP3,
             degree,
             epochList[0],
             epochList[BIG_N-1], 
             expInst[3],
             "J2000",
             avflag,
             segid,
             BIG_N, 
             epochList,
             type3Packets,
             rate,
             BIG_N,
             bigStartList  );

   chckxc_c ( SPICEFALSE, " ", ok );

   ckcls_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );





   tcase_c ( "Recover pointing from segment of subtype 3 in "
             "CK file CK05_BIG_GAP."                            );

   furnsh_c ( CK05_BIG_GAP );

   tol = 0.0;


   chkPntArray ( expInst[3], 0,   BIG_N,      1.0, C05TP3, 
                 epochList,  tol, type3Packets, ok           );




   tcase_c ( "Try request times within gaps in segment of subtype 3 in "
             "CK file CK05_BIG_GAP."                                    );


   tol = 0.0;

   for ( i = 0;  i < BIG_N;  i += 2 )

   {
      ckgpav_c ( expInst[3],  epochList[i] + 0.5,  tol,       "J2000", 
                 cmat,        av,                  &clkout,   &fnd   );
 
      chckxc_c ( SPICEFALSE, " ", ok );
     
      chcksl_c ( "found", fnd, SPICEFALSE, ok );
   }

   unload_c ( CK05_BIG_GAP );




   /*
   Evaluator checks:  make sure that alternation of sign of quaternions
   or quaternion derivatives is handled correctly.

   We construct a version of CK05_SMALL that has alternating-sign
   quaternions and quaternion derivatives.  The pointing and
   a.v. found should match those from CK05_SMALL.
   */

   tcase_c ( "ckw05_c normal test:  create file CK05_ALT."   );

  
   if ( exists_c(CK05_ALT) )
   {
      TRASH (CK05_ALT);
   }

   ckopn_c ( CK05_ALT, " ", 0, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < SMALL_N;  i++ )
   {
      epochList[i] = i; 
   }

   for ( i = 1;  i < SMALL_N;  i+=2 )
   {
      vminug_c ( type0Packets[i], C05PS0, type0Packets_alt[i] ); 
      vminug_c ( type1Packets[i], C05PS1, type1Packets_alt[i] ); 

      /*
      For type 2, just negate the quaternion and quaternion
      derivative data; leave the a.v. and a.v. derivatives alone. 
      */
      vminug_c ( type2Packets[i], 8, type2Packets_alt[i] ); 

      /*
      For type 3 packets, just negate the quaternion data;
      leave the a.v. alone.
      */
      vminug_c ( type3Packets[i], 4, type3Packets_alt[i] ); 
   }


   bigStartList[0] = epochList[0];
   

   degree = 7;

   ckw05_c ( handle,
             C05TP0,
             degree,
             epochList[0],
             epochList[SMALL_N-1], 
             expInst[0],
             "J2000",
             avflag,
             segid,
             SMALL_N, 
             epochList,
             type0Packets,
             rate,
             1,
             bigStartList  );

   chckxc_c ( SPICEFALSE, " ", ok );

   degree = 3;

   ckw05_c ( handle,
             C05TP1,
             degree,
             epochList[0],
             epochList[SMALL_N-1], 
             expInst[1],
             "J2000",
             avflag,
             segid,
             SMALL_N, 
             epochList,
             type1Packets,
             rate,
             1,
             bigStartList  );

   chckxc_c ( SPICEFALSE, " ", ok );

   degree = 15;

   ckw05_c ( handle,
             C05TP2,
             degree,
             epochList[0],
             epochList[SMALL_N-1], 
             expInst[2],
             "J2000",
             avflag,
             segid,
             SMALL_N, 
             epochList,
             type2Packets,
             rate,
             1,
             bigStartList  );

   degree = 11;

   ckw05_c ( handle,
             C05TP3,
             degree,
             epochList[0],
             epochList[SMALL_N-1], 
             expInst[3],
             "J2000",
             avflag,
             segid,
             SMALL_N, 
             epochList,
             type3Packets,
             rate,
             1,
             bigStartList  );


   ckcls_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );


   /*
   Now we'll use the CK user-level readers to look up pointing. 
   */   
   furnsh_c ( CK05_ALT );
   chckxc_c ( SPICEFALSE, " ", ok );


   /*
   We repeat all tests in this group, just to check whether there
   are any lingering side effects of the first set of calls.
   */

   for ( j = 0;  j < 2;  j++ )
   {

      tcase_c ( "Recover pointing from segment of subtype 0 in "
                "CK file CK05_ALT."                            );

      
      tol = 0.0;

      chkPntArray ( expInst[0], 0,   SMALL_N,      1.0, C05TP0, 
                    epochList,  tol, type0Packets, ok           );
 

      tcase_c ( "Recover pointing from segment of subtype 1 in "
                "CK file CK05_ALT."                            );


      chkPntArray ( expInst[1], 0,   SMALL_N,      1.0, C05TP1, 
                    epochList,  tol, type1Packets, ok           );
      

      tcase_c ( "Recover pointing from segment of subtype 2 in "
                "CK file CK05_ALT."                            );

      chkPntArray ( expInst[2], 0,   SMALL_N,      1.0, C05TP2, 
                    epochList,  tol, type2Packets, ok           );
      


      tcase_c ( "Recover pointing from segment of subtype 3 in "
                "CK file CK05_ALT."                            );

      chkPntArray ( expInst[3], 0,   SMALL_N,      1.0, C05TP3, 
                    epochList,  tol, type3Packets, ok           );



      tcase_c ( "Recover pointing from segment of subtype 0 in "
                "CK file CK05_ALT."                            );

 
   }
   unload_c ( CK05_ALT );


   /*
   Perform a test to verify correct centering of window on 
   request time:  create a type 2 segment with angular velocity
   that increases linearly and zero angular acceleration.

   Use cubic interpolation.

   The angular velocity at the midpoint of each interval will 
   simply be the average of the angular velocities at the 
   neighboring epochs.  The rate of each component will be 1.5 *
   the corresponding vertical step.

   */

   /*
   Create a set of type 2 packets.  Use quaternion and quaternion
   derivatives from our collection of type 0 packets.  Use the
   angular velocities from our collection of type 3 packets.

   */

   for ( i = 0;  i < BIG_N;  i++ )
   {
       /*
       Capture the quaternion and a.v. from the ith packet
       in the type 3 packet array. We embed the a.v. vector
       in the last 3 components of the quaternion qav.
       */
       MOVED(  type0Packets[i],       4,  type2LinPackets[i]       );
       MOVED( (type0Packets[i]) + 4,  4, (type2LinPackets[i]) + 4  );

       type2LinPackets[i][ 8] =         i;
       type2LinPackets[i][ 9] =  10.0 * i;
       type2LinPackets[i][10] = 100.0 * i;

       type2LinPackets[i][11] =   0.0;
       type2LinPackets[i][12] =   0.0;
       type2LinPackets[i][13] =   0.0;
   }
 

   tcase_c ( "ckw05_c normal test:  create file CK05_CUBE."   );

  
   if ( exists_c(CK05_CUBE) )
   {
      TRASH (CK05_CUBE);
   }

   ckopn_c ( CK05_CUBE, " ", 0, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < BIG_N;  i++ )
   {
      epochList[i] = i; 
   }

   bigStartList[0] = epochList[0];
   

   degree = 3;

   ckw05_c ( handle,
             C05TP2,
             degree,
             epochList[0],
             epochList[BIG_N-1], 
             expInst[2],
             "J2000",
             avflag,
             segid,
             BIG_N, 
             epochList,
             type2LinPackets,
             rate,
             1,
             bigStartList  );

   chckxc_c ( SPICEFALSE, " ", ok );


   ckcls_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );


   tcase_c ( "Subtype 2 interpolation test:  look up pointing at "
             "the midpoints between the time tags of the first "
             "segment."                                          );
 
   furnsh_c ( CK05_CUBE );
   chckxc_c ( SPICEFALSE, " ", ok );

   tol = 0.0;

   for ( i = 0;  i < BIG_N-1;  i++ )

      /*   for ( i = 0;  i < BIG_N-1;  i += step ) */
   {
      ckgpav_c ( expInst[2],  epochList[i] + 0.5,  tol,       "J2000", 
                 cmat,        av,                  &clkout,   &found   );

      chckxc_c ( SPICEFALSE, " ", ok );
     
      chcksl_c ( "found", found, SPICETRUE, ok );

      if ( found )
      {
         /*
         Check angular velocity. 
         */
         expAv[0] =         i + 0.5;
         expAv[1] =  10 * ( i + 0.5 );
         expAv[2] = 100 * ( i + 0.5 );

         sprintf ( label, 
                   "subtype %ld packet: a.v. no. %ld", 
                   (SpiceInt) C05TP2, i                );

         vscl_c ( rate, av, av );

         chckad_c ( label, av,  "~/",  expAv, 3, TIGHT_RE, ok );

      }

   }
   unload_c ( CK05_CUBE );




   
   /*
   Clean up any remaining files. 
   */
   TRASH ( CK05_1       );
   TRASH ( CK05_ALT     );
   TRASH ( CK05_BIG     ); 
   TRASH ( CK05_BIG_GAP ); 
   TRASH ( CK05_CUBE    ); 
   TRASH ( CK05_GAP     );
   TRASH ( CK05_SMALL   );
   TRASH ( CK05_TOL     ); 


   /*
   Retrieve the current test status.
   */ 
   t_success_c ( ok );    
   
} /* End f_ck05_c */






   /*
   Utility functions: 
   */


/*
   chkSubset verifies that a given quaternion and
   angular velocity were derived from a particular
   range of packets.  This function is used to test
   reduction of order near segment or interpolation
   interval boundaries.
*/
void chkSubset ( SpiceInt              inst,
                 SpiceDouble           sclkdp,
                 SpiceDouble           expCmat[3][3],
                 SpiceDouble           expAv[3],
                 SpiceCK05Subtype      subtyp,
                 SpiceDouble           rate,
                 SpiceDouble         * epochs,
                 void                * expPackets,
                 SpiceInt              lb,
                 SpiceInt              ub,
                 SpiceBoolean        * ok           )

{

   /*
   Local constants 
   */
   #define MAXREC          200
   
   #define C05PS0          8
   #define C05PS1          4
   #define C05PS2          14
   #define C05PS3          7
   
   /*
   Local variables 
   */

   logical                 needav;

   SpiceDouble             av     [3];
   SpiceDouble             cmat   [3][3];
   SpiceDouble             clkout;

   SpiceDouble             record[MAXREC];
   SpiceDouble         ( * type0Packets ) [C05PS0];
   SpiceDouble         ( * type1Packets ) [C05PS1];
   SpiceDouble         ( * type2Packets ) [C05PS2];
   SpiceDouble         ( * type3Packets ) [C05PS3];

   SpiceInt                i;
   SpiceInt                j;
   SpiceInt                k;

   SpiceInt                n;
   SpiceInt                packsz;


   chkin_c ( "chkSubset" );

   if ( subtyp == C05TP0 )
   {
      type0Packets = expPackets;
      packsz       = C05PS0;
   }

   else if ( subtyp == C05TP1 )
   {
      type1Packets = expPackets;
      packsz       = C05PS1;
   }

   else if ( subtyp == C05TP2 )
   {
      type2Packets = expPackets;
      packsz       = C05PS2;
   }

   else
   {
      type3Packets = expPackets;
      packsz       = C05PS3;
   }


   /*
   Construct a type 5 record from the indicated range of packets.
   */
   /*
   printf ( "sclkdp = %e \n", sclkdp );
   */
   n         = ub - lb + 1;

   /*
   printf ( "lb = %ld,  ub = %ld, n = %ld  \n", lb, ub, n  );
   */

   record[0] = sclkdp;
   record[1] = (SpiceDouble) subtyp;
   record[2] = (SpiceDouble) n;
   record[3] = rate;

   for ( i = lb;  i <= ub;  i++ )
   {
      j = 4 + (i-lb)*packsz;


      if ( subtyp == C05TP0 )
      {
         MOVED( type0Packets[i], packsz, record+j );
      }

      else if ( subtyp == C05TP1 )
      {
         MOVED( type1Packets[i], packsz, record+j );
      }

      else if ( subtyp == C05TP2 )
      {
         MOVED( type2Packets[i], packsz, record+j );
      }

      else
      {
         MOVED( type3Packets[i], packsz, record+j );

         /* 
         for ( k = 0; k < packsz; k++ )
         {
            printf ( "packet[%ld] = %e \n", k, type3Packets[i][k] );
         }
         */
      }

   }


   j = 4 + n*packsz;

   for ( i = lb;  i <= ub;  i++ )
   {
      /*
      printf ( "assigning %e to record[%ld] \n", epochs[i-lb], j  );
      */
      record[j] = epochs[i];
      j++;
   }
   

   /*
   printf ( "record =  \n" );
   */
   k = 4 + n*(packsz+1);

   /*
   for ( i = 0;  i < k;  i++ )
   {
      printf ( "record[%ld] = %e\n", i, record[i] );
   }
   */

   /*
   All right then, see what the type 5 evaluator cooks up.
   */

   needav = 1;

   cke05_ ( &needav, record, (SpiceDouble*)cmat, (SpiceDouble*)av, &clkout );

   /*
   We just called an f2c'd routine; convert the matrix to C-style. 
   */
   xpose_c ( cmat, cmat );
  
   chckxc_c ( SPICEFALSE, " ", ok );


   chckad_c ( "cmat",  (SpiceDouble*)cmat,  "~", 
                       (SpiceDouble*)expCmat,  9, TIGHT_MX, ok );

   chckad_c ( "av",    (SpiceDouble*)av,    "~", 
                       (SpiceDouble*)expAv,    3, TIGHT_MX, ok );

   /*
   printf ( "av    = %e %e %e \n", av[0], av[1], av[2]  );
   printf ( "expAv = %e %e %e \n", expAv[0], expAv[1], expAv[2]  );
   */
   chkout_c ( "chkSubset" );
}




void chkPntArray ( SpiceInt              inst,
                   SpiceInt              index0,
                   SpiceInt              indexMax,
                   SpiceDouble           step,
                   SpiceCK05Subtype      subtyp,
                   SpiceDouble         * epochs,
                   SpiceDouble           tol,
                   void                * expPackets,
                   SpiceBoolean        * ok         )
{


   /*
   Local constants 
   */
   #define C05PS0          8
   #define C05PS1          4
   #define C05PS2          14
   #define C05PS3          7
   #define RATE            1000.0

   /*
   Local variables 
   */
   SpiceBoolean            found;
   SpiceBoolean            found2;

   SpiceChar               label [LNSIZE];

   SpiceDouble             av  [3];
   SpiceDouble             av2 [3];
   SpiceDouble             dq  [4];
   SpiceDouble             qav [4];
   SpiceDouble             clkout;
   SpiceDouble             clkout2;

   SpiceDouble             cmat [3][3];
   SpiceDouble             cmat2[3][3];
   SpiceDouble             mag;
   SpiceDouble             q   [4];
   SpiceDouble             sep;
   SpiceDouble         ( * type0Packets ) [C05PS0];
   SpiceDouble         ( * type1Packets ) [C05PS1];
   SpiceDouble         ( * type2Packets ) [C05PS2];
   SpiceDouble         ( * type3Packets ) [C05PS3];
   SpiceDouble             scale_small;


   static SpiceDouble      z[3] = { 0.0, 0.0, 1.0 };

   SpiceInt                i;


   chkin_c ( "chkPntArray" );

   for ( i = index0;  i < indexMax;  i += step )
   {

      /*
      Always look up pointing twice; make sure we have a 
      match.
      */
      ckgpav_c ( inst,    epochs[i],  tol,       "J2000", 
                 cmat,    av,         &clkout,   &found   );

      chckxc_c ( SPICEFALSE, " ", ok );
     
      chcksl_c ( "found", found, SPICETRUE, ok );


      ckgpav_c ( inst,    epochs[i],  tol,       "J2000", 
                 cmat2,   av2,        &clkout2,   &found2  );

      chckxc_c ( SPICEFALSE, " ", ok );
     
      chcksl_c ( "found2", found2, SPICETRUE, ok );

      chcksd_c ( "clkout", clkout,  "=",  clkout2,    0.0, ok );
      chckad_c ( "av",     av,      "=",  av2,     3, 0.0, ok );

      chckad_c ( "cmat",   (SpiceDouble *)cmat,    "=",  
                           (SpiceDouble *)cmat2,   9, 0.0, ok );

      if ( found )
      {
         m2q_c ( cmat, q );

         chcksd_c ( "clkout", clkout,  "=",  epochs[i], TIGHT_MX, ok );

         if ( subtyp == C05TP0 )
         {
            sprintf ( label, 
                      "subtype %ld packet: quaternion no. %ld", 
                      (SpiceInt) subtyp,
                      i                                        );
            type0Packets = expPackets;

            chckad_c ( label, q,  "~",  type0Packets [i], 4, TIGHT_MX, ok );

            /*
            We embed the a.v. vector in the last 3 components of the 
            quaternion qav.
            */ 
            vscl_c ( RATE, av, av );
            MOVED( av,  3,  qav+1 );
            qav[0] = 0.0;                     

            /*
            Since we know from the discussion in QDQ2AV that 

                            *
               AV =   -2 * Q  * DQ

            we have

               DQ = -1/2 * Q  * AV

            */

            qxq_ ( q, qav, dq );

            vsclg_c ( -0.5, dq, 4, dq );

            sprintf ( label, 
                      "subtype %ld packet: d.q. no. %ld", 
                      (SpiceInt) subtyp,
                      i                                        );

            chckad_c ( label, dq, "~", type0Packets[i]+4, 4, TIGHT_MX, ok );

         }


         else if ( subtyp == C05TP1 )
         {
            /*
            >>> This type 1 check depends on the polynomial degree being 3. 
            */

            sprintf ( label, 
                      "subtype %ld packet: quaternion no. %ld", 
                      (SpiceInt) subtyp,
                      i                                        );

            type1Packets = expPackets;

            chckad_c ( label, q,  "~",  type1Packets [i], 4, TIGHT_MX, ok );

            /*
            Check the angular velocity by making sure the vector has
            angular separation zero relative to the z-axis.  The magnitude
            of the vector corresponding to the ith pointing instance should
            be  (i+0.5)*scale_small radians/tick.
            */

            sprintf ( label, "subtype 1 packet: a.v. ang sep from "
                             "z-axis.  Instance no. %ld", i           );

            /*
            Scale a.v. from radians/second to radians/tick for comparison. 
            */
            vscl_c ( RATE, av, av );


            sep = vsep_c  ( av, z );
            mag = vnorm_c ( av );

            chcksd_c ( label, sep,  "~", 0.0, TIGHT_MX, ok );

            sprintf ( label, "subtype 1 packet: a.v. magnitude "
                             "Instance no. %ld",  i                );

            scale_small = 1.e-9;

            chcksd_c ( label, mag,  "~", (i+0.5)*scale_small, TIGHT_MX, ok );

         }

         else if ( subtyp == C05TP2 )
         {
            type2Packets = expPackets;

            sprintf ( label, "subtype 2 packet: quaternion no. %ld", i );

            chckad_c ( label, q,  "~",  type2Packets [i], 4, TIGHT_MX, ok );

            /*
            Check the angular velocity:  the quaternion derivative stored
            in the type 2 packets was converted from the corresponding
            angular velocity vector in the subtype 3 packet list.
            */

            sprintf ( label, "subtype 2 packet: a.v. no. %ld", i );

            /*
            Scale a.v. from radians/second to radians/tick for comparison. 
            */
            vscl_c ( RATE, av, av );


            chckad_c ( label, av,  "~",  (type2Packets[i])+8, 3, TIGHT_MX,
                       ok );

         }

         else if ( subtyp == C05TP3 )
         {
            type3Packets = expPackets;

            sprintf ( label, "subtype 3 packet: quaternion no. %ld", i );

            chckad_c ( label, q,  "~",  type3Packets [i], 4, TIGHT_MX, ok );

            sprintf ( label, "subtype 3 packet: a.v. no. %ld", i );

            /*
            Scale a.v. from radians/second to radians/tick for comparison. 
            */
            vscl_c ( RATE, av, av );


            chckad_c ( label, av,  "~",  (type3Packets[i])+4, 3, TIGHT_MX, 
                       ok );

         }

         else
         {
            setmsg_c ( "Unrecognized subtype code # seen." );
            errint_c ( "#",  (SpiceInt)subtyp              );
            sigerr_c ( "SPICE(BUG)"                        );
            chkout_c ( "chkPntArray"                       );
         }


      }
      
      /*
      If pointing was found, we checked it. 
      */
   }
   /*
   All epochs have been checked. 
   */
  
   chkout_c ( "chkPntArray" );

}
