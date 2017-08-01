/*

-Procedure f_spk18_c ( Test wrappers for SPK routines )

 
-Abstract
 
   Perform tests on CSPICE wrappers for SPK functions.
 
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
   

   void f_spk18_c ( SpiceBoolean * ok )

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
 
   This routine tests the wrappers for the SPK type 18 wrappers. 
   The set is:
      
      spkw18_c

           
-Examples
 
   None.
    
-Restrictions
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
 
-Literature_References
 
   None. 
 
-Version

   -tspice_c Version 1.0.0 26-AUG-2002 (NJB)

 
-&
*/

{ /* Begin f_spk18_c */

   /*
   Local macros
   */
   
   #define TRASH(file)     if ( remove(file) !=0 )                         \
                           printf ("***Unable to remove %s\n\n", file ); 


   /*
   Constants
   */
   #define BIG_N           1000
   #define BIG_ID          -10000
   #define BIG_CTR         5
   #define BIG_DEG         3
   #define BIG_STEP        10.0
   #define CHBDEG          2
   #define LNSIZE          81
   #define SPK18_0         "test18_0.bsp"
   #define SPK18_1         "test18_1.bsp"
   #define SPK18BIG0       "test18big0.bsp"
   #define SPK18BIG1       "test18big1.bsp"
   #define SPK18SUB0       "test18sub0.bsp"
   #define SPK18SUB1       "test18sub1.bsp"
   #define REF1            "J2000"
   #define NUMCAS          10
   #define TIGHT_RE        1.e-14
   #define LOOSE_RE        1.e-3
   #define VERY_LOOSE_RE   0.1
   #define UTC1            "1999 jul 1"
   #define N_DISCRETE      9
   #define N_RECORDS       4
   #define POLY_DEG        3
   #define SIDLEN          41
   
   /*
   Static variables
   */    
   


                              

   /*
   States for testing spkw05_c, spkw08_c, spkw09_c, spkw12_c, and 
   spkw13_c:
   */
   
   static SpiceDouble      discreteEpochs[N_DISCRETE] =
                           {
                              100., 200., 300., 400., 500., 
                              600., 700., 800., 900.       
                           };
                           
   static SpiceDouble      discreteStates[N_DISCRETE][6] =
                           {
                              { 101., 201., 301., 401., 501., 601. },
                              { 102., 202., 302., 402., 502., 602. },
                              { 103., 203., 303., 403., 503., 603. },
                              { 104., 204., 304., 404., 504., 604. },
                              { 105., 205., 305., 405., 505., 605. },
                              { 106., 206., 306., 406., 506., 606. },
                              { 107., 207., 307., 407., 507., 607. },
                              { 108., 208., 308., 408., 508., 608. },
                              { 109., 209., 309., 409., 509., 609. },
                           };
   
   /*
   Local variables
   */
   SpiceBoolean            found;

   SpiceChar               expRef   [ LNSIZE ];
   SpiceChar               segid    [ SIDLEN ];

   
   static SpiceDouble      bigHermiteList  [ BIG_N ][12];
   static SpiceDouble      bigLagrangeList [ BIG_N ][6];
   SpiceDouble             bigEpochList    [ BIG_N ];

   SpiceDouble             descr    [5];
   SpiceDouble             discretePackets [N_DISCRETE][12];
   SpiceDouble             et;
   SpiceDouble             expPacket[12];
   SpiceDouble             expState [6];
   SpiceDouble             lt;
   SpiceDouble             state    [6];
   SpiceDouble             step;


   SpiceInt                expBody;
   SpiceInt                expCenter;
   SpiceInt                handle;
   SpiceInt                i;
   SpiceInt                j;
   SpiceInt                newh;




   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_spk18_c" );
   
   /*
   Create and load a leapseconds kernel.
   */
   tstlsk_c ();
   


   /*
   spkw18 tests:
   */
   
   tcase_c ( "Test spkw18_c:  invalid reference frame." );
   
   
   
   expBody   = 3;
   expCenter = 10;
   strcpy ( expRef, "J2000" );
   
   
   /*
   Create a segment identifier.
   */
   strcpy ( segid, "SPK type 18 test segment" );
   
   
   /*
   Open a new SPK file.
   */
   
   if ( exists_c(SPK18_1) )
   {
      TRASH (SPK18_1);
   }
   
   spkopn_c ( SPK18_1, "Type 18 SPK internal file name.", 4, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
 
   /*
   Test the type 18 segment writer's error handling.  Most errors
   are detected in the underlying SPICELIB code.
   */
   spkw18_c ( handle,
              S18TP1,
              expBody,
              expCenter,
              "SPUD",
              discreteEpochs[0],
              discreteEpochs[N_DISCRETE-1], 
              segid,
              POLY_DEG,
              N_DISCRETE,
              discreteStates,
              discreteEpochs              );

   chckxc_c ( SPICETRUE, "SPICE(INVALIDREFFRAME)", ok );
              

              
   tcase_c ( "Test spkw18_c:  segment ID too long." );

   spkw18_c ( handle,
              S18TP1,
              expBody,
              expCenter,
              expRef,
              discreteEpochs[0],
              discreteEpochs[N_DISCRETE-1], 
              "X                                                    X",
              POLY_DEG,
              N_DISCRETE,
              discreteStates,
              discreteEpochs              );

   chckxc_c ( SPICETRUE, "SPICE(SEGIDTOOLONG)", ok );
              

   tcase_c ( "Test spkw18_c:  invalid segment ID character present." );

   segid[0] = (char)7;
   
   spkw18_c ( handle,
              S18TP1,
              expBody,
              expCenter,
              expRef,
              discreteEpochs[0],
              discreteEpochs[N_DISCRETE-1], 
              segid,
              POLY_DEG,
              N_DISCRETE,
              discreteStates,
              discreteEpochs              );

   chckxc_c ( SPICETRUE, "SPICE(NONPRINTABLECHARS)", ok );
              
   strcpy ( segid, "SPK type 18 test segment" );
              
              
   tcase_c ( "Test spkw18_c:  invalid degree (-1)." );

   spkw18_c ( handle,
              S18TP1,
              expBody,
              expCenter,
              expRef,
              discreteEpochs[0],
              discreteEpochs[N_DISCRETE-1], 
              segid,
              -1,
              N_DISCRETE,
              discreteStates,
              discreteEpochs              );

   chckxc_c ( SPICETRUE, "SPICE(INVALIDDEGREE)", ok );



   tcase_c ( "Test spkw18_c:  invalid degree (99)." );

   spkw18_c ( handle,
              S18TP1,
              expBody,
              expCenter,
              expRef,
              discreteEpochs[0],
              discreteEpochs[N_DISCRETE-1], 
              segid,
              99,
              N_DISCRETE,
              discreteStates,
              discreteEpochs              );

   chckxc_c ( SPICETRUE, "SPICE(INVALIDDEGREE)", ok );


   tcase_c ( "Test spkw18_c:  invalid (even) degree (4)." );

   spkw18_c ( handle,
              S18TP1,
              expBody,
              expCenter,
              expRef,
              discreteEpochs[0],
              discreteEpochs[N_DISCRETE-1], 
              segid,
              4,
              N_DISCRETE,
              discreteStates,
              discreteEpochs              );

   chckxc_c ( SPICETRUE, "SPICE(INVALIDDEGREE)", ok );


   tcase_c ( "Test spkw18_c:  too few states." );

   spkw18_c ( handle,
              S18TP1,
              expBody,
              expCenter,
              expRef,
              discreteEpochs[0],
              discreteEpochs[N_DISCRETE-1], 
              segid,
              POLY_DEG,
              0,
              discreteStates,
              discreteEpochs              );

   chckxc_c ( SPICETRUE, "SPICE(TOOFEWSTATES)", ok );



   tcase_c ( "Test spkw18_c:  descriptor times out of order." );
   spkw18_c ( handle,
              S18TP1,
              expBody,
              expCenter,
              expRef,
              discreteEpochs[N_DISCRETE-1], 
              discreteEpochs[0],
              segid,
              POLY_DEG,
              N_DISCRETE,
              discreteStates,
              discreteEpochs              );

   chckxc_c ( SPICETRUE, "SPICE(BADDESCRTIMES)", ok );




   tcase_c ( "Test spkw18_c:  packet epochs out of order." );

   et                 = discreteEpochs[3]; 
   discreteEpochs[3]  = discreteEpochs[2];
   discreteEpochs[2]  = et;
   
   spkw18_c ( handle,
              S18TP1,
              expBody,
              expCenter,
              expRef,
              discreteEpochs[0],
              discreteEpochs[N_DISCRETE-1], 
              segid,
              POLY_DEG,
              N_DISCRETE,
              discreteStates,
              discreteEpochs              );

   chckxc_c ( SPICETRUE, "SPICE(TIMESOUTOFORDER)", ok );

   et                 = discreteEpochs[3]; 
   discreteEpochs[3]  = discreteEpochs[2];
   discreteEpochs[2]  = et;
   

   tcase_c ( "Test spkw18_c: descriptor start before first data epoch." );

   spkw18_c ( handle,
              S18TP1,
              expBody,
              expCenter,
              expRef,
              discreteEpochs[0] - 1.0,
              discreteEpochs[N_DISCRETE-1], 
              segid,
              POLY_DEG,
              N_DISCRETE,
              discreteStates,
              discreteEpochs              );

   chckxc_c ( SPICETRUE, "SPICE(BADDESCRTIMES)", ok );



   tcase_c ( "Test spkw18_c: descriptor end after last data epoch." );

   spkw18_c ( handle,
              S18TP1,
              expBody,
              expCenter,
              expRef,
              discreteEpochs[0],
              discreteEpochs[N_DISCRETE-1]  +  1.0, 
              segid,
              POLY_DEG,
              N_DISCRETE,
              discreteStates,
              discreteEpochs              );

   chckxc_c ( SPICETRUE, "SPICE(BADDESCRTIMES)", ok );



   /*
   Check string error handling within the spkw18_c wrapper.
   
      1) Null frame name.
      2) Empty frame name.
      3) Null segment identifier.
      4) Empty segment identifier.
      
   */
   tcase_c ( "Test spkw18_c: null frame name pointer" );
   spkw18_c ( handle,
              S18TP1,
              expBody,
              expCenter,
              (SpiceChar *)0,
              discreteEpochs[0],
              discreteEpochs[N_DISCRETE-1], 
              segid,
              POLY_DEG,
              N_DISCRETE,
              discreteStates,
              discreteEpochs              );

   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   

   tcase_c ( "Test spkw18_c: empty frame name string." );
   spkw18_c ( handle,
              S18TP1,
              expBody,
              expCenter,
              "",
              discreteEpochs[0],
              discreteEpochs[N_DISCRETE-1], 
              segid,
              POLY_DEG,
              N_DISCRETE,
              discreteStates,
              discreteEpochs              );

   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );
            

   tcase_c ( "Test spkw18_c: null segment ID string pointer." );
   spkw18_c ( handle,
              S18TP1,
              expBody,
              expCenter,
              expRef,
              discreteEpochs[0],
              discreteEpochs[N_DISCRETE-1], 
              (SpiceChar *)0,
              POLY_DEG,
              N_DISCRETE,
              discreteStates,
              discreteEpochs              );

   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );


   
   tcase_c ( "Test spkw18_c: empty segment ID string." );
   spkw18_c ( handle,
              S18TP1,
              expBody,
              expCenter,
              expRef,
              discreteEpochs[0],
              discreteEpochs[N_DISCRETE-1], 
              "",
              POLY_DEG,
              N_DISCRETE,
              discreteStates,
              discreteEpochs              );

   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );
            




   /*
   That's it for the error cases.  We're finally ready to create a
   real segment.
   */            
   
   
  
   tcase_c ( "Test spkw18_c: write a subtype S18TP1 type 18 segment." );
   
   
   step = discreteEpochs[1] - discreteEpochs[0];
   
   /*
   Create a type 18 segment.
   */
   spkw18_c ( handle,
              S18TP1,
              expBody,
              expCenter,
              expRef,
              discreteEpochs[0],
              discreteEpochs[N_DISCRETE-1], 
              segid,
              POLY_DEG,
              N_DISCRETE,
              discreteStates,
              discreteEpochs              );

   chckxc_c ( SPICEFALSE, " ", ok );
              
         
   /*
   Close the SPK file.
   */
   spkcls_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   

   tcase_c ( "Test spkw18_c: read from a subtype S18TP1 type 18 segment." );
   
   /*
   Load the SPK file.
   */ 
   spklef_c ( SPK18_1, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   /*
   Look up states for each epoch in our list.  Compare.
   */
   
   for ( i = 0;  i < N_DISCRETE; i++ )
   {
      spkgeo_c ( expBody, discreteEpochs[i], expRef, expCenter,
                 state,   &lt                                  ); 
      chckxc_c ( SPICEFALSE, " ", ok );
      
      
      chckad_c ( "type 18 state", 
                 state,
                 "=",
                 discreteStates[i],
                 6,
                 TIGHT_RE,
                 ok                );
   }
   
   spkuef_c ( handle );
   


   tcase_c ( "Test spkw18_c.  Create a large segment with multiple "
             "directories.  Subtype is S18TP1"                       );

   /*
   Create the state and epoch values we'll use.  We're going to set
   all velocities to zero to create a rounded stair-step sort of 
   pattern in the position components.  This will ensure that the
   correct states cannot be obtained without selecting the correct
   window of states in the reader.
   */
   
   for ( i = 0;  i < BIG_N; i++ )
   {
      for ( j = 0;  j < 6;  j++ )
      {
         bigLagrangeList[i][j] = (SpiceDouble) ( BIG_STEP*i + j );
      }
   
      bigEpochList[i] = (SpiceDouble) ( 10 * i );
   }


   /*
   Open a new type 18 SPK file.
   */
   
   if ( exists_c(SPK18BIG1) )
   {
      TRASH (SPK18BIG1);
   }
   
   spkopn_c ( SPK18BIG1, "Type 18 SPK internal file name.", 0, &handle );
   
   spkw18_c ( handle,
              S18TP1,
              BIG_ID,
              BIG_CTR,
              expRef,
              bigEpochList[0],
              bigEpochList[BIG_N-1], 
              segid,
              BIG_DEG,
              BIG_N,
              bigLagrangeList,
              bigEpochList          );

   chckxc_c ( SPICEFALSE, " ", ok );
              
   spkcls_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   

   tcase_c ( "Test spkr18_c, spke18_c.  Read from a large segment "
             "with multiple directories.  Subtype is S18TP1"       );
   
   /*
   Load the SPK file.
   */ 
   spklef_c ( SPK18BIG1, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   /*
   Look up states for each midpoint of adjacent epochs in our list.
   Compare.
   */
   
   for ( i = 0;  i < BIG_N-1; i++ )
   {
      spkgeo_c ( BIG_ID, 
                 bigEpochList[i] + (BIG_STEP/2), 
                 expRef, 
                 BIG_CTR,
                 state,   
                 &lt                             ); 
                 
      chckxc_c ( SPICEFALSE, " ", ok );
      
      
      /*
      Set up the expected state vector. 
      */
            
      MOVED ( bigLagrangeList[i], 6, expState );
      
      for ( j = 0;  j < 6; j++ )
      {
         expState[j]  +=   BIG_STEP / 2;
      }
           
      chckad_c ( "type 18 state", 
                 state,
                 "~",
                 expState,
                 6,
                 TIGHT_RE,
                 ok                );
   }
   
   spkuef_c ( handle );



   
   
   tcase_c ( "Test spkw18_c: write a subtype S18TP0 type 18 segment." );
   
   /*
   Open a new SPK file.
   */
   
   if ( exists_c(SPK18_0) )
   {
      TRASH (SPK18_0);
   }
   
   spkopn_c ( SPK18_0, "Type 18 SPK internal file name.", 4, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );

   
   step = discreteEpochs[1] - discreteEpochs[0];
   
   for ( i = 0;  i < N_DISCRETE;  i++ )
   {
      MOVED ( discreteStates[i], 6, discretePackets[i] );

      vsclg_c ( 10.0, discretePackets[i], 6, &(discretePackets[i][6]) );
   }


   /*
   Create a type 18 segment.
   */
   spkw18_c ( handle,
              S18TP0,
              expBody,
              expCenter,
              expRef,
              discreteEpochs[0],
              discreteEpochs[N_DISCRETE-1], 
              segid,
              POLY_DEG,
              N_DISCRETE,
              discretePackets,
              discreteEpochs              );

   chckxc_c ( SPICEFALSE, " ", ok );
              
         
   /*
   Close the SPK file.
   */
   spkcls_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   

   tcase_c ( "Test spkw18_c: read from a subtype S18TP0 type 18 segment." );
   
   /*
   Load the SPK file.
   */ 
   spklef_c ( SPK18_0, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   /*
   Look up states for each epoch in our list.  Compare.
   */
   
   for ( i = 0;  i < N_DISCRETE; i++ )
   {
      spkgeo_c ( expBody, discreteEpochs[i], expRef, expCenter,
                 state,   &lt                                  ); 
      chckxc_c ( SPICEFALSE, " ", ok );
      
      MOVED  ( discreteStates[i], 3, expState   );
      vscl_c ( 10.0,   expState,     expState+3 );

      chckad_c ( "type 18 state", 
                 state,
                 "=",
                 expState,
                 6,
                 TIGHT_RE,
                 ok                );
   }
   
   spkuef_c ( handle );
   


   tcase_c ( "Test spkw18_c.  Create a large segment with multiple "
             "directories.  Subtype is S18TP0."                       );

   /*
   Create the state and epoch values we'll use.  We're going to set
   all position derivatives to zero to create a rounded stair-step sort of 
   pattern in the position components.  This will ensure that the
   correct states cannot be obtained without selecting the correct
   window of states in the reader.

   For velocity and acceleration, we'll use the same idea, but
   we'll scale the values to distinguish them.
   */
   
   for ( i = 0;  i < BIG_N; i++ )
   {
      for ( j = 0;  j < 3;  j++ )
      {
         bigHermiteList[i][j  ] = (SpiceDouble) ( BIG_STEP*i + j );
         bigHermiteList[i][j+3] = 0.0;
      }
   
      for ( j = 6;  j < 9;  j++ )
      {
         bigHermiteList[i][j  ] = 1.e6 * (SpiceDouble) ( BIG_STEP*i + j );
         bigHermiteList[i][j+3] = 0.0;
      }

      bigEpochList[i] = (SpiceDouble) ( 10 * i );
   }


   /*
   Open a new type 18 SPK file.
   */
   
   if ( exists_c(SPK18BIG0) )
   {
      TRASH (SPK18BIG0);
   }
   
   spkopn_c ( SPK18BIG0, "Type 18 SPK internal file name.", 0, &handle );
   
   spkw18_c ( handle,
              S18TP0,
              BIG_ID,
              BIG_CTR,
              expRef,
              bigEpochList[0],
              bigEpochList[BIG_N-1], 
              segid,
              BIG_DEG,
              BIG_N,
              bigHermiteList,
              bigEpochList          );

   chckxc_c ( SPICEFALSE, " ", ok );
              
   spkcls_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   


   tcase_c ( "Test spkr18_c, spke18_c.  Read from a large segment "
             "with multiple directories.  Subtype is S18TP0"       );
   
   /*
   Load the SPK file.
   */ 
   spklef_c ( SPK18BIG0,  &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   /*
   Look up states for each midpoint of adjacent epochs in our list.
   Compare.
   */
   
   for ( i = 0;  i < BIG_N-1; i++ )
   {
      spkgeo_c ( BIG_ID, 
                 bigEpochList[i] + (BIG_STEP/2), 
                 expRef, 
                 BIG_CTR,
                 state,   
                 &lt                             ); 
                 
      chckxc_c ( SPICEFALSE, " ", ok );
      

      MOVED ( bigHermiteList[i], 12, expPacket );
      
      MOVED ( expPacket,   3, expState   );
      MOVED ( expPacket+6, 3, expState+3 );
            
      for ( j = 0;  j < 3; j++ )
      {
         expState[j  ]  +=          BIG_STEP / 2;
         expState[j+3]  +=   1.e6 * BIG_STEP / 2;   
      }
      
      chckad_c ( "type 18 state", 
                 state,
                 "~/",
                 expState,
                 6,
                 TIGHT_RE,
                 ok                );
      
      chckad_c ( "type 18 state", 
                 state,
                 "=",
                 expState,
                 6,
                 TIGHT_RE,
                 ok                );
   }
   
   spkuef_c ( handle );


 
   /*
   Test spks18:
   */
   
   tcase_c ( "Test SPKS18.  Subset SPK18_1 to produce a file that " 
             "spans the time range from discreteEpochs[1] through "
             "discreteEpochs[N_DISCRETE-2].  Subtype is S18TP1."   );
   

   dafopr_c ( SPK18_1,    &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   if ( exists_c(SPK18SUB1) )
   {
      TRASH ( SPK18SUB1 );
   }
   
   spkopn_c ( SPK18SUB1, "Type 18 subset test file", 0, &newh   );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   /*
   Loop over the old file, writing the abbreviated version of each 
   segment to the new file as we go.
   */
      
   dafbfs_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   daffna_c ( &found );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   while ( found )
      {
      dafgs_c ( descr );
      chckxc_c ( SPICEFALSE, " ", ok );
      
      dafgn_c ( SIDLEN, segid );
      chckxc_c ( SPICEFALSE, " ", ok );
      
      spksub_c ( handle, 
                 descr, 
                 segid, 
                 discreteEpochs[1],
                 discreteEpochs[N_DISCRETE-2],
                 newh                          );
      chckxc_c ( SPICEFALSE, " ", ok );
   
      daffna_c ( &found );
      chckxc_c ( SPICEFALSE, " ", ok );
      }
   
   spkcls_c ( newh );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   spkcls_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );


   
   tcase_c ( "Check SPKS18.  Read from a file that " 
             "spans the time range from discreteEpochs[1] through "
             "discreteEpochs[N_DISCRETE-2]."                        );
   

   /*
   Load the subsetted SPK file.
   */ 
   spklef_c ( SPK18SUB1, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   /*
   Look up earth and earth-moon barycenter states for each epoch in our
   list.  Compare.
   */
   
   for ( i = 1;  i < N_DISCRETE-1; i++ )
      {
      spkgeo_c ( 3, discreteEpochs[i], "J2000", 10,
                 state,   &lt                      ); 
      chckxc_c ( SPICEFALSE, " ", ok );
            
      chckad_c ( "type 18 state", 
                 state,
                 "=",
                 discreteStates[i],
                 6,
                 TIGHT_RE,
                 ok                );
      }

  
   spkuef_c ( handle );


 

  
   tcase_c ( "Test SPKS18.  Subset SPK18_0 to produce a file that " 
             "spans the time range from discreteEpochs[1] through "
             "discreteEpochs[N_DISCRETE-2].  Subtype is S18TP0."   );
   

   dafopr_c ( SPK18_0,    &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   if ( exists_c(SPK18SUB0) )
   {
      TRASH ( SPK18SUB0 );
   }
   
   spkopn_c ( SPK18SUB0, "Type 18 subset test file", 0, &newh   );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   /*
   Loop over the old file, writing the abbreviated version of each 
   segment to the new file as we go.
   */
      
   dafbfs_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   daffna_c ( &found );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   while ( found )
      {
      dafgs_c ( descr );
      chckxc_c ( SPICEFALSE, " ", ok );
      
      dafgn_c ( SIDLEN, segid );
      chckxc_c ( SPICEFALSE, " ", ok );
      
      spksub_c ( handle, 
                 descr, 
                 segid, 
                 discreteEpochs[1],
                 discreteEpochs[N_DISCRETE-2],
                 newh                          );
      chckxc_c ( SPICEFALSE, " ", ok );
   
      daffna_c ( &found );
      chckxc_c ( SPICEFALSE, " ", ok );
      }
   
   spkcls_c ( newh );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   spkcls_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );


   
   tcase_c ( "Check SPKS18.  Read from a subtype S18TP0 file that " 
             "spans the time range from discreteEpochs[1] through "
             "discreteEpochs[N_DISCRETE-2]."                        );
   

   /*
   Load the subsetted SPK file.
   */ 
   spklef_c ( SPK18SUB0, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   /*
   Look up earth and earth-moon barycenter states for each epoch in our
   list.  Compare.
   */
   
   for ( i = 1;  i < N_DISCRETE-1; i++ )
      {
      spkgeo_c ( 3, discreteEpochs[i], "J2000", 10,
                 state,   &lt                      ); 
      chckxc_c ( SPICEFALSE, " ", ok );
            
      MOVED  ( discreteStates[i], 3, expState   );
      vscl_c ( 10.0,   expState,     expState+3 );

      chckad_c ( "type 18 state", 
                 state,
                 "=",
                 expState,
                 6,
                 TIGHT_RE,
                 ok                );
      }

   spkuef_c ( handle );

  
 
   
 

  
   /*
   Clean up the SPK files we've created. 
   */
   TRASH ( SPK18_0   );
   TRASH ( SPK18_1   );
   TRASH ( SPK18BIG0 );
   TRASH ( SPK18BIG1 );
   TRASH ( SPK18SUB0 );
   TRASH ( SPK18SUB1 );
   
   
   /*
   Retrieve the current test status.
   */ 
   t_success_c ( ok );    
   
} /* End f_spk18_c */
