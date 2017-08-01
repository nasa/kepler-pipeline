/*

-Procedure f_nnsp10_c ( Test SPK type 10 routines, non-native )

 
-Abstract
 
   Perform tests on CSPICE wrappers for a subset of the SPK type 10 
   routines, using non-native files.
    
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
   

   void f_nnsp10_c ( SpiceBoolean * ok )

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
   10 routines, using non-native files.
   
   The subset is:
      
      spkw10_c
             
-Examples
 
   None.
    
-Restrictions
 
   1) This routine carries out its tests on systems having the
      BIG-IEEE or LTL-IEEE binary file format.  On other systems,
      it is effectively a no-op:  the routine returns as soon as
      the binary file format is known.
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
 
-Literature_References
 
   None. 
 
-Version
 
   -tspice_c Version 1.0.1 20-MAR-2002 (EDW) 

      Replaced remove() calls with TRASH macro.

   -tspice_c Version 1.0.0 25-NOV-2001 (NJB)

      Adapted from f_nnsp10_c  

         Version 1.1.0 15-AUG-1999 (NJB)  

-&
*/

{ /* Begin f_nnsp10_c */

 
   /*
   Prototypes
   */
   void t_swbiff_c ( SpiceBoolean      isNative, 
                     ConstSpiceChar  * fname    );

   void t_supplt_c ( SpiceBoolean    * ret      );

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
   #define  LIMIT           1.e-14
   
   #define  SPK1            "type10_1.bsp"
   #define  SPK2            "type10_2.bsp"
   #define  SPK3            "type10_3.bsp"
   
   #define  LNSIZE          81
   #define  SIDLEN          41
   #define  N_LOW           20
   #define  N_HI            2 

   #define  J2 0   
   #define  J3 1   
   #define  J4 2    
   #define  KE 3   
   #define  QO 4   
   #define  SO 5   
   #define  ER 6   
   #define  AE 7  
   
   
   /*
   Local variables
   */
   SpiceBoolean            found;
   SpiceBoolean            ret;
   logical                 fnd;
   
   SpiceChar               low2ln [N_LOW][LNSIZE];
   SpiceChar               hi2ln  [N_HI ][LNSIZE];
   SpiceChar               segid  [SIDLEN];

   SpiceDouble             arg;
   SpiceDouble             consts [ 8 ];
   SpiceDouble             dargdt;
   SpiceDouble             denom;
   SpiceDouble             descr  [ 5 ];
   SpiceDouble             dmob;
   SpiceDouble             dnut   [ 4 ];
   SpiceDouble             dwdt;
   SpiceDouble             elems  [ 100 ];
   SpiceDouble             epoch  [ 10 ];
   SpiceDouble             et;
   SpiceDouble             expst  [ 6 ];
   SpiceDouble             first;
   SpiceDouble             last;
   SpiceDouble             lt;
   SpiceDouble             m      [ 3 ][ 3 ];
   SpiceDouble             mob;
   SpiceDouble             nulon1;
   SpiceDouble             nulon2;
   SpiceDouble             nulon;
   SpiceDouble             numer;
   SpiceDouble             nuobl;

   SpiceDouble             nuobl1;
   SpiceDouble             nuobl2;
   SpiceDouble             part1  [ 6 ];
   SpiceDouble             part2  [ 6 ];
   SpiceDouble             record [ 50 ];
   SpiceDouble             state  [ 6 ];
   SpiceDouble             vel    [ 3 ];
   SpiceDouble             w;

   SpiceInt                begin;
   SpiceInt                body;
   SpiceInt                center;
   SpiceInt                end;
   SpiceInt                frame;
   SpiceInt                handle;
   SpiceInt                i;
   SpiceInt                id;
   SpiceInt                spk1;
   SpiceInt                spk2;
   SpiceInt                spk3;
   SpiceInt                type;





   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_nnsp10_c" );
   

   /*
   This routine is effectively a no-op for unsupported platforms.
   */
   t_supplt_c ( &ret );

   if ( ret )
   {
      t_success_c ( ok ); 
      return;
   }

   
   /*
   Make sure the kernel pool doesn't contain any unexpected 
   definitions.
   */
   clpool_c();
   
   /*
   Load a leapseconds kernel.  
   
   Note that the LSK is deleted after loading, so we don't have to clean
   it up later.
   */
   tcase_c  ( "Preliminaries --- load a leapseconds kernel." );
   tstlsk_c();
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   
   
   /*
   Case 2:
   */
   tcase_c ( "Test spkw10. Make sure we can create an SPK type 10 "
             "segment from a single set of two-line elements. "     );
 
   if ( exists_c(SPK1) )
      {  
      TRASH (SPK1);
      }
   
   
   /*
   We'll use the two-line elments for Topex that are
   given in the header to getelm_c.
   */
   strcpy ( low2ln[0], "1 22076u 92052a   97173.53461370 -.0"
                       "0000038  00000-0  10000-3 0   594"    );
               
   strcpy ( low2ln[1], "2 22076  66.0378 163.4372 0008359 27"
                       "8.7732  81.2337 12.80930736227550"    );

   
   getelm_c ( 1950, LNSIZE, low2ln, epoch, elems );
   chckxc_c ( SPICEFALSE, " ", ok );
   

   first  =  epoch[0] - 100.0 * spd_c();
   last   =  epoch[0] + 100.0 * spd_c();

   id     =  -122076;
   
      
   consts[ J2 ] =    1.082616e-3; 
   consts[ J3 ] =   -2.53881e-6; 
   consts[ J4 ] =   -1.65597e-6; 
   consts[ KE ] =    7.43669161e-2; 
   consts[ QO ] =  120.0; 
   consts[ SO ] =   78.0; 
   consts[ ER ] = 6378.135; 
   consts[ AE ] =    1.0; 
   
   spkopn_c ( SPK1, "SPK 10 test file", 1000, &spk1 );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   spkw10_c ( spk1,        id,      399,  "J2000",  first, last,
              "Test TOPEX",  consts,  1,    elems,    epoch       );
   chckxc_c ( SPICEFALSE, " ", ok );

   spkcls_c ( spk1 );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   /*
   Convert the file to non-native binary format. 
   */
   t_swbiff_c ( SPICETRUE, SPK1 );
   chckxc_c   ( SPICEFALSE, " ", ok );
   
   /*
   Case 3:
   */
   tcase_c ( "Make sure we can read read out of the file "
             "the data we just inserted."                  );
             
             
   et = epoch[0];
   
   spklef_c ( SPK1, &spk1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   spksfs_  ( &id, &et, &handle, descr, segid, &fnd, SIDLEN-1 );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   found = fnd;
   
   chcksl_c ( "found", found, SPICETRUE, ok );
             
   /*  
   Unpack the descriptor and make sure it has the correct data in it.
   */     
             
   spkuds_c ( descr,
              &body,  &center,  &frame,   &type,
              &first, &last,    &begin,  &end   );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   spkr10_ ( &handle, descr, &et, record );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   chckad_c ( "consts", consts, "=", record,    8,  0.0, ok ); 
   chckad_c ( "elem1",  elems,  "=", record+8,  10, 0.0, ok ); 
   chckad_c ( "elem2",  elems,  "=", record+22, 10, 0.0, ok ); 
            
   /*
   Case 4:
   */
   tcase_c ( "Make sure the record is evaluated using the "
             "routine ev2lin_."                            );


   ev2lin_ ( &et,      consts, elems, expst );
   chckxc_c ( SPICEFALSE, " ", ok );

   zzwahr_ ( elems+9, dnut                 );
   chckxc_c ( SPICEFALSE, " ", ok );

   nulon =  dnut[0]  +  ( et - elems[9] ) * dnut[2];
   nuobl =  dnut[1]  +  ( et - elems[9] ) * dnut[3];

   zzmobliq_ ( &et, &mob, &dmob );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   eul2m_c ( -mob-nuobl, -nulon, mob, 1, 3, 1, m );
   
   mtxv_c ( m, expst,   expst   );
   mtxv_c ( m, expst+3, expst+3 );

   zzeprcss_ ( &et, (SpiceDouble *)m );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   /*
   Note:  we don't transpose the matrix since it came from an f2c'd
   function and is in column-major order.
   */
   mxv_c ( m, expst, expst );
   mxv_c ( m, expst+3, expst+3 );
   
   spke10_ ( &et, record, state );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   chckad_c ( "state", state, "~/", expst, 6, LIMIT, ok );
   
   /*
   Case 5:
   */
   tcase_c ( "Make sure that spkez_c agrees with the previous "
             "computation."                                  );
   
   spkez_c ( id, et, "J2000", "NONE", 399, state, &lt );
   chckxc_c ( SPICEFALSE, " ", ok );

   chckad_c ( "state", state, "~/", expst, 6, LIMIT, ok );
   
   
   /*
   Case 6:
   */
   tcase_c ( "Construct a longer file and make sure that "
             "we get the correct states from SPKEZ. "     );

   /*
   Get rid of the old SPK file.
   */
   spkuef_c ( spk1 );
   TRASH   ( SPK1 );
   
   
   strcpy ( low2ln[  0 ],  "1 18123U 87 53  A 87324.61041692 -.0"
                           "0000023  00000-0 -75103-5 0 00675"   );
   strcpy ( low2ln[  1 ],  "2 18123  98.8296 152.0074 0014950 16"
                           "8.7820 191.3688 14.12912554 21686"   );
   strcpy ( low2ln[  2 ],  "1 18123U 87 53  A 87326.73487726  .0"
                           "0000045  00000-0  28709-4 0 00684"   );
   strcpy ( low2ln[  3 ],  "2 18123  98.8335 154.1103 0015643 16"
                           "3.5445 196.6235 14.12912902 21988"   );
   strcpy ( low2ln[  4 ],  "1 18123U 87 53  A 87331.40868801  .0"
                           "0000104  00000-0  60183-4 0 00690"   );
   strcpy ( low2ln[  5 ],  "2 18123  98.8311 158.7160 0015481 14"
                           "9.9848 210.2220 14.12914624 22644"   );
   strcpy ( low2ln[  6 ],  "1 18123U 87 53  A 87334.24129978  .0"
                           "0000086  00000-0  51111-4 0 00702"   );
   strcpy ( low2ln[  7 ],  "2 18123  98.8296 161.5054 0015372 14"
                           "2.4159 217.8089 14.12914879 23045"   );
   strcpy ( low2ln[  8 ],  "1 18123U 87 53  A 87336.93227900 -.0"
                           "0000107  00000-0 -52860-4 0 00713"   );
   strcpy ( low2ln[  9 ],  "2 18123  98.8317 164.1627 0014570 13"
                           "5.9191 224.2321 14.12910572 23425"   );
   strcpy ( low2ln[ 10 ],  "1 18123U 87 53  A 87337.28635487  .0"
                           "0000173  00000-0  10226-3 0 00726"   );
   strcpy ( low2ln[ 11 ],  "2 18123  98.8284 164.5113 0015289 13"
                           "3.5979 226.6438 14.12916140 23475"   );
   strcpy ( low2ln[ 12 ],  "1 18123U 87 53  A 87339.05673569  .0"
                           "0000079  00000-0  47069-4 0 00738"   );
   strcpy ( low2ln[ 13 ],  "2 18123  98.8288 166.2585 0015281 12"
                           "7.9985 232.2567 14.12916010 24908"   );
   strcpy ( low2ln[ 14 ],  "1 18123U 87 53  A 87345.43010859  .0"
                           "0000022  00000-0  16481-4 0 00758"   );
   strcpy ( low2ln[ 15 ],  "2 18123  98.8241 172.5226 0015362 10"
                           "9.1515 251.1323 14.12915487 24626"   );
   strcpy ( low2ln[ 16 ],  "1 18123U 87 53  A 87349.04167543  .0"
                           "0000042  00000-0  27370-4 0 00764"   );
   strcpy ( low2ln[ 17 ],  "2 18123  98.8301 176.1010 0015565 10"
                           "0.0881 260.2047 14.12916361 25138"   );


   for ( i = 0;  i < 9;  i++ )
   {
      getelm_c ( 1950, LNSIZE, low2ln+(2*i), epoch+i, elems+(10*i) );
   }
   chckxc_c ( SPICEFALSE, " ", ok );
   
   /*
   printf ( "epoch = %e\n", epoch[0] );

   for ( i = 0;  i < 90;  i++ )
   {
      printf ( "elems[%d] = %e\n", (int)i, elems[i] );
   }
   */

   first  =  epoch[0] - 0.5 * spd_c();
   last   =  epoch[8] + 0.5 * spd_c();

   id     =  -118123;

   if ( exists_c(SPK2) )
      {  
      TRASH (SPK2);
      }
   
   spkopn_c ( SPK2, "SPK 10 test file #2", 1000, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   spkw10_c ( handle,        id,      399,  "J2000",  first, last,
              "DMSP F8",     consts,  9,    elems,    epoch       );
   chckxc_c ( SPICEFALSE, " ", ok );

   spkcls_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   Convert the file to non-native binary format. 
   */
   t_swbiff_c ( SPICETRUE, SPK2 );
   chckxc_c   ( SPICEFALSE, " ", ok );
   


   et  =  0.6 * epoch[4]  +  0.4 * epoch[5];

   spklef_c ( SPK2, &spk2 );

   ev2lin_ ( &et, consts, elems+40, part1 );
   chckxc_c ( SPICEFALSE, " ", ok );
   ev2lin_ ( &et, consts, elems+50, part2 );
   chckxc_c ( SPICEFALSE, " ", ok );

   zzwahr_ ( epoch+4, dnut );
   chckxc_c ( SPICEFALSE, " ", ok );

   nulon1 =  dnut[0]  +  ( et - epoch[4] ) * dnut[2];
   nuobl1 =  dnut[1]  +  ( et - epoch[4] ) * dnut[3];

   zzwahr_ ( epoch+5, dnut );
   chckxc_c ( SPICEFALSE, " ", ok );

   nulon2 =  dnut[0]  +  ( et - epoch[5] ) * dnut[2];
   nuobl2 =  dnut[1]  +  ( et - epoch[5] ) * dnut[3];

   zzmobliq_ ( &et, &mob, &dmob );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   numer  =  et       - epoch[4];
   denom  =  epoch[5] - epoch[4];
   arg    =  numer*pi_c() / denom;
   dargdt =  pi_c()       / denom;
   
   w      =  0.5 + 0.5 * cos( arg );
   dwdt   =      - 0.5 * sin( arg ) * dargdt;

   nuobl  =  w*nuobl1 + (1.0-w)*nuobl2;
   nulon  =  w*nulon1 + (1.0-w)*nulon2;

   
   eul2m_c ( -mob-nuobl, -nulon, mob, 1, 3, 1, m );
   
   mtxv_c ( m, part1,   part1   );
   mtxv_c ( m, part1+3, part1+3 );

   mtxv_c ( m, part2,   part2   );
   mtxv_c ( m, part2+3, part2+3 );

   vlcomg_c ( 6,    w,  part1,   1.0-w,  part2,  expst   );
   vlcom_c  ( dwdt,     part1,   -dwdt,  part2,  vel     );
   vadd_c   ( vel,      expst+3,                 expst+3 );
 
   zzeprcss_ ( &et, (SpiceDouble *)m );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   /*
   Note:  we don't transpose the matrix since it came from an f2c'd
   function and is in column-major order.
   */
   mxv_c ( m, expst,   expst   );
   mxv_c ( m, expst+3, expst+3 );
   
   spkez_c  ( id, et, "J2000", "NONE", 399, state, &lt );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   chckad_c ( "state", state, "~/", expst, 6, LIMIT, ok );
   
   /*
   Case 7:
   */
   tcase_c ( "Using the same file make sure we get the "
             "correct state at one second after the beginning"
             "of the segment."                                );

   et = first + 1.0;
   ev2lin_ ( &et, consts, elems, expst );

   zzwahr_ ( elems+9,  dnut );

   nulon = dnut[0] + (et-elems[9])*dnut[2];
   nuobl = dnut[1] + (et-elems[9])*dnut[3];
 
   zzmobliq_ ( &et, &mob, &dmob );
   chckxc_c ( SPICEFALSE, " ", ok );

   eul2m_c ( -mob-nuobl, -nulon, mob, 1, 3, 1, m );

   mtxv_c ( m, expst,   expst   );
   mtxv_c ( m, expst+3, expst+3 );

   zzeprcss_ ( &et, (SpiceDouble *)m );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   /*
   Note:  we don't transpose the matrix since it came from an f2c'd
   function and is in column-major order.
   */
   mxv_c ( m, expst,   expst   );
   mxv_c ( m, expst+3, expst+3 );

   spkez_c  ( id, et, "J2000", "NONE", 399, state, &lt );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   chckad_c ( "state", state, "~/", expst, 6, LIMIT, ok );

   /*
   Case 8:
   */
   tcase_c ( "Using the same file make sure we get the "
             "correct state at one second before the end "
             "of the segment."                             );

   et = last - 1.0;
   ev2lin_ ( &et, consts, elems+80, expst );

   zzwahr_ ( elems+89,  dnut );

   nulon = dnut[0] + (et-elems[89])*dnut[2];
   nuobl = dnut[1] + (et-elems[89])*dnut[3];
 
   zzmobliq_ ( &et, &mob, &dmob );
   chckxc_c ( SPICEFALSE, " ", ok );

   eul2m_c ( -mob-nuobl, -nulon, mob, 1, 3, 1, m );

   mtxv_c ( m, expst,   expst   );
   mtxv_c ( m, expst+3, expst+3 );

   zzeprcss_ ( &et, (SpiceDouble *)m );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   /*
   Note:  we don't transpose the matrix since it came from an f2c'd
   function and is in column-major order.
   */
   mxv_c ( m, expst,   expst   );
   mxv_c ( m, expst+3, expst+3 );

   spkez_c  ( id, et, "J2000", "NONE", 399, state, &lt );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   chckad_c ( "state", state, "~/", expst, 6, LIMIT, ok );


   
   /*
   Get rid of the old SPK file.
   */
   spkuef_c ( spk2 );
   TRASH   ( SPK2 );
   
 
   /*
   Case 9:
   */
   tcase_c ( "Make sure we can perform the same "
             "experiments using a deep space satellite. " );
             
   if ( exists_c(SPK3) )
      {  
      TRASH (SPK3);
      }
   

   strcpy ( hi2ln[0], "1 24846U 97031A   97179.08162378 -.0"
                      "0000182  00000-0  00000+0 0   129"    );
                      
   strcpy ( hi2ln[1], "2 24846   4.5222  86.7012 6052628 17"
                      "8.7924 183.5048  2.04105068    52"    );
 
   getelm_c ( 1950, LNSIZE, hi2ln, epoch, elems );
 
   first = epoch[0] - 10.0*spd_c();
   last  = epoch[0] + 10.0*spd_c();

   id    = -124846;


   spkopn_c ( SPK3, "SPK 10 test file #3", 1000, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   spkw10_c ( handle,          id,      399,  "J2000",  first, last,
              "Test INTELSAT", consts,  1,    elems,    epoch       );
   chckxc_c ( SPICEFALSE, " ", ok );

   spkcls_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );


   /*
   Convert the file to non-native binary format. 
   */
   t_swbiff_c ( SPICETRUE, SPK3 );
   chckxc_c   ( SPICEFALSE, " ", ok );


   et = epoch[0];
   dpspce_  ( &et, consts, elems, state );
   dpspce_  ( &et, consts, elems, expst );
   chckxc_c ( SPICEFALSE, " ", ok );
   chckad_c ( "state", state, "~/", expst, 6, LIMIT, ok );

   zzwahr_ ( elems+9,  dnut );

   nulon = dnut[0] + (et-elems[9])*dnut[2];
   nuobl = dnut[1] + (et-elems[9])*dnut[3];
 
   zzmobliq_ ( &et, &mob, &dmob );
   chckxc_c ( SPICEFALSE, " ", ok );

   eul2m_c ( -mob-nuobl, -nulon, mob, 1, 3, 1, m );

   mtxv_c ( m, expst,   expst   );
   mtxv_c ( m, expst+3, expst+3 );

   zzeprcss_ ( &et, (SpiceDouble *)m );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   /*
   Note:  we don't transpose the matrix since it came from an f2c'd
   function and is in column-major order.
   */
   mxv_c ( m, expst,   expst   );
   mxv_c ( m, expst+3, expst+3 );

   spklef_c ( SPK3, &spk3 );
   spkez_c  ( id, et, "J2000", "NONE", 399, state, &lt );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   chckad_c ( "state", state, "~/", expst, 6, LIMIT, ok );
             
   /*
   Get rid of the old SPK file.
   */
   spkuef_c ( spk3 );
   TRASH   ( SPK3 );
             
   /*
   Retrieve the current test status.
   */ 
   t_success_c ( ok ); 
   
   
} /* End f_nnsp10_c */

