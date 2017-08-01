/*

-Procedure f_spk_c ( Test wrappers for SPK routines )

 
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
   

   void f_spk_c ( SpiceBoolean * ok )

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
 
   This routine tests the wrappers for the SPK wrappers. 
   The set is:
      
      spkapo_c
      spkapp_c
      spkez_c
      spkezr_c
      spkgeo_c
      spkgps_c
      spklef_c
      spkopa_c
      spkopn_c
      spkpds_c
      spkpos_c
      spkssb_c
      spksub_c
      spkuds_c
      spkuef_c
      spkw02_c
      spkw03_c
      spkw05_c
      spkw08_c
      spkw09_c
      spkw10_c
      spkw12_c
      spkw13_c
      spk14a_c
      spk14b_c
      spk14e_c
      
   The associated routines are included:
   
      prop2b_c
      stelab_c
      ltime_c
      
              
-Examples
 
   None.
    
-Restrictions
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
 
-Literature_References
 
   None. 
 
-Version

   -tspice_c Version 2.1.1 07-NOV-2001 (EDW) (NJB)

       Corrected a logic bug; this routine closed
       and deleted the SPK13SUB file at end of run,
       but did not unload the file from the handle
       manager system. This state caused the Mac Codewarrior
       tspice to fail when accessing SPK files during
       the SPKBSR test family.

       The correction consists of replacing the spkcls_c
       for the SPK13SUB handle with a call to spkuef_c.

   -tspice_c Version 2.1.0 01-FEB-2001 (EDW)
   
      Removed explicit close for SPK1 test file created
      for the tspice run. tclose_c closes and deletes
      all SPK test files at the tspice end-of-run.
      
      Added the TRASH macro.
 
   -tspice_c Version 2.0.0 22-MAR-2000 (NJB)
   
      Added tests for types 12 and 13.  

   -tspice_c Version 1.0.0 02-SEP-1999 (NJB)  

-&
*/

{ /* Begin f_spk_c */

   /*
   Local macros
   */
   #define T(n, theta)     ( cos( n*acos( MinVal(1.,MaxVal(-1.,theta)) ) ) )
   
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
   #define BIG_N           1000
   #define BIG_ID          -10000
   #define BIG_CTR         5
   #define BIG_DEG         3
   #define BIG_STEP        10.0
   #define CHBDEG          2
   #define LNSIZE          81
   #define SIDLEN          61
   #define SPK1            "test1.bsp"
   #define SPK2            "test2.bsp"
   #define SPK3            "test3.bsp"
   #define SPK5            "test5.bsp"
   #define SPK5SUB         "test5sub.bsp"
   #define SPK8            "test8.bsp"
   #define SPK9            "test9.bsp"
   #define SPK9SUB         "test9sub.bsp"
   #define SPK12           "test12.bsp"
   #define SPK12BIG        "test12big.bsp"
   #define SPK12SUB        "test12sub.bsp"
   #define SPK13           "test13.bsp"
   #define SPK13BIG        "test13big.bsp"
   #define SPK13SUB        "test13sub.bsp"
   #define SPK14           "test14.bsp"
   #define REF1            "J2000"
   #define NUMCAS          10
   #define TIGHT_RE        1.e-14
   #define LOOSE_RE        1.e-3
   #define VERY_LOOSE_RE   0.1
   #define UTC1            "1999 jul 1"
   #define N_DISCRETE      9
   #define N_RECORDS       4
   #define GM_SUN          132712440023.310
   #define POLY_DEG        3
   
   /*
   Static variables
   */    
   
   /*
   The following state vectors are from de405s.bsp. They're for the
   UTC epoch 1999 July 1 00:00:00.  Approximate light times were
   obtained by dividing distance by c.
   */
   static SpiceDouble      earthSunGeo [6] =
                           {
                              23171841.660,
                             -137908150.483,
                             -59790964.759,
                              28.946,
                              4.054,
                              1.759
                           };
                           
   static SpiceDouble      earthSunGeoLT = 507.30867946318;
   

   static SpiceDouble      earthSunLT [6] =
                           {
                              23157154.182,
                              -137910199.678,
                              -59791853.752,
                              28.946,
                              4.052,
                              1.758
                           };

   static SpiceDouble      earthSunLTLT = 507.30858140200;


   static SpiceDouble      earthSunLTS [6] =
                           {
                              23157155.813,
                              -137910199.435,
                              -59791853.683,
                              28.946,
                              4.052,
                              1.758
                           };

   static SpiceChar        LTs[3][5] = 
                           {
                              "none",
                              "LT",
                              "LT+S"
                           };

   static SpiceChar        ltPhrases[3][LNSIZE] = 
                           {
                              "geometric",
                              "LT-corrected",
                              "LT+S_corrected"
                           };

   /*
   Note:  this is *supposed* to be the same as LT only, since the 
   range from which it was derived is the same.
   */
   static SpiceDouble      earthSunLTSLT = 507.30858140200;



   /*
   Cheby coefficients for testing spkw02_c.
   */
   static SpiceDouble      ChebyCoeffs02[N_RECORDS][3][CHBDEG+1] =
                           {
                              {
                                 { 1.0101, 1.0102, 1.0103 },
                                 { 1.0201, 1.0202, 1.0203 },
                                 { 1.0301, 1.0302, 1.0303 }   
                              },
                              
                              {
                                 { 2.0101, 2.0102, 2.0103 },
                                 { 2.0201, 2.0202, 2.0203 },
                                 { 2.0301, 2.0302, 2.0303 }
                              },
                              
                              {
                                 { 3.0101, 3.0102, 3.0103 },
                                 { 3.0201, 3.0202, 3.0203 },
                                 { 3.0301, 3.0302, 3.0303 }
                              },
                              
                              {
                                 { 4.0101, 4.0102, 4.0103 },
                                 { 4.0201, 4.0202, 4.0203 },
                                 { 4.0301, 4.0302, 4.0303 }
                              } 
                           };
                              


   /*
   Cheby coefficients for testing spkw03_c.
   */
   static SpiceDouble      ChebyCoeffs03[N_RECORDS][6][CHBDEG+1] =
                           {
                              {
                                 { 1.0101, 1.0102, 1.0103 },
                                 { 1.0201, 1.0202, 1.0203 },
                                 { 1.0301, 1.0302, 1.0303 },
                                 { 1.0401, 1.0402, 1.0403 },
                                 { 1.0501, 1.0502, 1.0503 },
                                 { 1.0601, 1.0602, 1.0603 }
                              },
                              
                              {
                                 { 2.0101, 2.0102, 2.0103 },
                                 { 2.0201, 2.0202, 2.0203 },
                                 { 2.0301, 2.0302, 2.0303 },
                                 { 2.0401, 2.0402, 2.0403 },
                                 { 2.0501, 2.0502, 2.0503 },
                                 { 2.0601, 2.0602, 2.0603 }
                              },
                              
                              {
                                 { 3.0101, 3.0102, 3.0103 },
                                 { 3.0201, 3.0202, 3.0203 },
                                 { 3.0301, 3.0302, 3.0303 },
                                 { 3.0401, 3.0402, 3.0403 },
                                 { 3.0501, 3.0502, 3.0503 },
                                 { 3.0601, 3.0602, 3.0603 }
                              },
                              
                              {
                                 { 4.0101, 4.0102, 4.0103 },
                                 { 4.0201, 4.0202, 4.0203 },
                                 { 4.0301, 4.0302, 4.0303 },
                                 { 4.0401, 4.0402, 4.0403 },
                                 { 4.0501, 4.0502, 4.0503 },
                                 { 4.0601, 4.0602, 4.0603 }
                              }
                           };
                              

   /*
   Cheby coefficient and interval records for testing spk14(b,a,e)_c.
   */
   static SpiceDouble      ChebyRecords14[N_RECORDS][2+6*(CHBDEG+1)] =
                           {
                              {
                                   150.0,
                                   50.0,
                                   1.0101, 1.0102, 1.0103,
                                   1.0201, 1.0202, 1.0203,
                                   1.0301, 1.0302, 1.0303,
                                   1.0401, 1.0402, 1.0403,
                                   1.0501, 1.0502, 1.0503,
                                   1.0601, 1.0602, 1.0603 
                              },
                              
                              {
                                   250.0,
                                   50.0,
                                   2.0101, 2.0102, 2.0103,
                                   2.0201, 2.0202, 2.0203,
                                   2.0301, 2.0302, 2.0303,
                                   2.0401, 2.0402, 2.0403,
                                   2.0501, 2.0502, 2.0503,
                                   2.0601, 2.0602, 2.0603
                              },
                              
                              {
                                   350.0,
                                   50.0,
                                   3.0101, 3.0102, 3.0103,
                                   3.0201, 3.0202, 3.0203,
                                   3.0301, 3.0302, 3.0303,
                                   3.0401, 3.0402, 3.0403,
                                   3.0501, 3.0502, 3.0503,
                                   3.0601, 3.0602, 3.0603  
                              },
                              
                              {
                                   450.0,
                                   50.0,
                                   4.0101, 4.0102, 4.0103,
                                   4.0201, 4.0202, 4.0203,
                                   4.0301, 4.0302, 4.0303,
                                   4.0401, 4.0402, 4.0403,
                                   4.0501, 4.0502, 4.0503,
                                   4.0601, 4.0602, 4.0603  
                              }
                           };
                              

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
   SpiceChar               title    [ LNSIZE ];
   SpiceChar               segid    [ SIDLEN ];

   
   static SpiceDouble      bigStateList[ BIG_N ][6];
   SpiceDouble             bigEpochList[ BIG_N ];

   SpiceDouble             descr    [5];
   SpiceDouble             elapsd;
   SpiceDouble             et;
   SpiceDouble             ettarg;
   SpiceDouble             expLt;
   SpiceDouble             expPos   [3];
   SpiceDouble             expState [6];
   SpiceDouble             first;
   SpiceDouble             intlen;
   SpiceDouble             last;
   SpiceDouble             lt;
   SpiceDouble             midpt;
   SpiceDouble             mu;
   SpiceDouble             obsState [6];
   SpiceDouble             obsvel   [3];
   SpiceDouble             pvinit   [6];
   SpiceDouble             r;
   SpiceDouble             radius;
   SpiceDouble             speed;
   SpiceDouble             state    [6];
   SpiceDouble             step;
   SpiceDouble             t;
   SpiceDouble             theta;
   SpiceDouble             trgpos   [3];


   SpiceInt                begin;
   SpiceInt                body;
   SpiceInt                center;
   SpiceInt                end;
   SpiceInt                expBody;
   SpiceInt                expCenter;
   SpiceInt                expFrcode;
   SpiceInt                frcode;
   SpiceInt                handle;
   SpiceInt                i;
   SpiceInt                j;
   SpiceInt                k;
   SpiceInt                newh;
   SpiceInt                type;




   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_spk_c" );
   
   /*
   Create and load a leapseconds kernel.
   */
   tstlsk_c ();
   
   /*
   Create a test spk file.  Don't load it yet.
   */
   if ( exists_c(SPK1) )
      {
      TRASH (SPK1);
      }

   tstspk_c ( SPK1, SPICEFALSE, &handle );
   
   
   /*
   Case 1:
   */
   
   tcase_c ( "Load the SPK file." );
   
   spklef_c ( SPK1, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   /*
   Case 2:
   */
   
   tcase_c ( "Test spkezr_c.  Get the geometric state of the "
             "earth relative to the sun."               );
             
   str2et_c ( UTC1, &et );
       
   spkezr_c ( "earth", et, REF1, "none", "sun", state, &lt );
   chckxc_c ( SPICEFALSE, " ", ok );


   chckad_c( "spkezr_c geometric position", 
              state, 
              "~~/", 
              earthSunGeo, 
              3, 
              LOOSE_RE, 
              ok                        );

   chckad_c( "spkezr_c geometric velocity", 
              state+3, 
              "~~/", 
              earthSunGeo+3, 
              3, 
              LOOSE_RE, 
              ok                        );

   chcksd_c ( "spkezr_c geometric light time",  
              lt,  
              "~/",  
              earthSunGeoLT, 
              LOOSE_RE,  
              ok                          );
   /*
   Case 3:
   */
   
   tcase_c ( "Test spkezr_c.  Get the LT-corrected state of the "
             "earth relative to the sun."               );
             
   spkezr_c ( "earth", et, REF1, "lt", "sun", state, &lt );
   chckxc_c ( SPICEFALSE, " ", ok );


   chckad_c( "spkezr_c LT-corrected position", 
              state, 
              "~~/", 
              earthSunLT, 
              3, 
              LOOSE_RE, 
              ok                        );

   chckad_c( "spkezr_c LT-corrected velocity", 
              state+3, 
              "~~/", 
              earthSunLT+3, 
              3, 
              LOOSE_RE, 
              ok                        );

   chcksd_c ( "spkezr_c LT-corrected light time",  
              lt,  
              "~/",  
              earthSunLTLT, 
              LOOSE_RE,  
              ok                          );



   /*
   Case 4:
   */
   
   tcase_c ( "Test spkezr_c.  Get the LTS-corrected state of the "
             "earth relative to the sun."               );
             
   spkezr_c ( "earth", et, REF1, "lt+s", "sun", state, &lt );
   chckxc_c ( SPICEFALSE, " ", ok );


   chckad_c( "spkezr_c LTS-corrected position", 
              state, 
              "~~/", 
              earthSunLTS, 
              3, 
              LOOSE_RE, 
              ok                        );

   chckad_c( "spkezr_c LTS-corrected velocity", 
              state+3, 
              "~~/", 
              earthSunLTS+3, 
              3, 
              LOOSE_RE, 
              ok                        );

   chcksd_c ( "spkezr_c LTS-corrected light time",  
              lt,  
              "~/",  
              earthSunLTSLT, 
              LOOSE_RE,  
              ok                          );



   /*
   Case 5:
   */
   tcase_c ( "Test spkez_c.  Compare to spkezr_c." );
   
   
   for ( i = 0;  i < 3;  i++ )
   {
   
      spkezr_c ( "earth", et, REF1, LTs[i], "sun", expState, &expLt );
      chckxc_c ( SPICEFALSE, " ", ok );
   
      spkez_c  ( 399,     et, REF1, LTs[i], 10,    state,    &lt );
      chckxc_c ( SPICEFALSE, " ", ok );
   
      
      sprintf ( title, "spkez_c %s position", ltPhrases[i] );
      
      chckad_c( title, state, "~~/", expState, 3, TIGHT_RE, ok );
   
   
      sprintf ( title, "spkez_c %s velocity", ltPhrases[i] );
      
      chckad_c( title, state+3, "~~/", expState+3, 3, TIGHT_RE, ok );
   
   
      sprintf ( title, "spkez_c %s light time", ltPhrases[i] );
      
      chcksd_c( title,  lt,   "~/",  expLt,  TIGHT_RE,  ok );
   }
   

   

   /*
   Case 6:
   */
   tcase_c ( "Test spkgeo_c.  Compare to spkezr_c." );
   
   
   spkezr_c ( "earth", et, REF1, LTs[0], "sun", expState, &expLt );
   chckxc_c ( SPICEFALSE, " ", ok );

   spkgeo_c  ( 399,     et, REF1,         10,    state,    &lt );
   chckxc_c ( SPICEFALSE, " ", ok );

   
   sprintf ( title, "spkez_c %s position", ltPhrases[0] );
   
   chckad_c( title, state, "~~/", expState, 3, TIGHT_RE, ok );


   sprintf ( title, "spkez_c %s velocity", ltPhrases[0] );
   
   chckad_c( title, state+3, "~~/", expState+3, 3, TIGHT_RE, ok );


   sprintf ( title, "spkez_c %s light time", ltPhrases[0] );
   
   chcksd_c( title,  lt,   "~/",  expLt,  TIGHT_RE,  ok );
   

   
   

   /*
   Case 7:
   */
   tcase_c ( "Test spkssb_c.  Compare to spkez_c." );
   
   
   spkez_c  ( 399, et, REF1, LTs[0], 0, expState, &expLt );
   chckxc_c ( SPICEFALSE, " ", ok );

   spkssb_c  ( 399,     et, REF1,       state );
   chckxc_c ( SPICEFALSE, " ", ok );

   
   sprintf ( title, "spkssb_c %s position", ltPhrases[0] );
   
   chckad_c( title, state, "~~/", expState, 3, TIGHT_RE, ok );


   sprintf ( title, "spkssb_c %s velocity", ltPhrases[0] );
   
   chckad_c( title, state+3, "~~/", expState+3, 3, TIGHT_RE, ok );

   

   /*
   Case 8:
   */
   
   
   tcase_c ( "Test spkapp_c.  Compare to spkez_c." );
   
   
   spkez_c  ( 399, et, REF1, LTs[0], 10, expState, &expLt );
   chckxc_c ( SPICEFALSE, " ", ok );

   spkssb_c ( 10,  et, REF1, obsState );
   spkapp_c ( 399, et, REF1, obsState, LTs[0], state, &lt );
   chckxc_c ( SPICEFALSE, " ", ok );

   
   sprintf ( title, "spkapp_c %s position", ltPhrases[0] );
   
   chckad_c( title, state, "~~/", expState, 3, TIGHT_RE, ok );


   sprintf ( title, "spkapp_c %s velocity", ltPhrases[0] );
   
   chckad_c( title, state+3, "~~/", expState+3, 3, TIGHT_RE, ok );


   sprintf ( title, "spkapp_c %s light time", ltPhrases[0] );
   
   chcksd_c( title,  lt,   "~/",  expLt,  TIGHT_RE,  ok );
   
   
   /*
   Case 9:
   */
   tcase_c ( "Test spkpos_c.  Compare to spkezr_c." );
   
   
   for ( i = 0;  i < 3;  i++ )
      {
      spkezr_c ( "earth", et, REF1, LTs[i], "sun", expState, &expLt );
      chckxc_c ( SPICEFALSE, " ", ok );
   
      spkpos_c ( "earth", et, REF1, LTs[i], "sun", state,    &lt );
      chckxc_c ( SPICEFALSE, " ", ok );
   
      
      sprintf ( title, "spkpos_c %s position", ltPhrases[i] );
      
      chckad_c( title, state, "~~/", expState, 3, TIGHT_RE, ok );
   
   
      sprintf ( title, "spkpos_c %s light time", ltPhrases[i] );
      
      chcksd_c( title,  lt,   "~/",  expLt,  TIGHT_RE,  ok );
      }
   


   /*
   Case 10:
   */
   tcase_c ( "Test spkezp_c.  Compare to spkpos_c." );
   
   
   for ( i = 0;  i < 3;  i++ )
   {
   
      spkpos_c ( "earth", et, REF1, LTs[i], "sun", expState, &expLt );
      chckxc_c ( SPICEFALSE, " ", ok );
   
      spkezp_c ( 399,     et, REF1, LTs[i], 10,    state,    &lt );
      chckxc_c ( SPICEFALSE, " ", ok );
   
      
      sprintf ( title, "spkezp_c %s position", ltPhrases[i] );
      
      chckad_c( title, state, "~~/", expState, 3, TIGHT_RE, ok );
   
   
      sprintf ( title, "spkezp_c %s light time", ltPhrases[i] );
      
      chcksd_c( title,  lt,   "~/",  expLt,  TIGHT_RE,  ok );
   }


   /*
   Case 11:
   */
   tcase_c ( "Test spkgps_c.  Compare to spkpos_c." );
   
   
   spkpos_c ( "earth", et, REF1, LTs[0], "sun", expState, &expLt );
   chckxc_c ( SPICEFALSE, " ", ok );

   spkgps_c ( 399,     et, REF1,         10,    state,    &lt );
   chckxc_c ( SPICEFALSE, " ", ok );

   
   sprintf ( title, "spkgps_c %s position", ltPhrases[0] );
   
   chckad_c( title, state, "~~/", expState, 3, TIGHT_RE, ok );


   sprintf ( title, "spkgps_c %s light time", ltPhrases[0] );
   
   chcksd_c( title,  lt,   "~/",  expLt,  TIGHT_RE,  ok );



   /*
   Case 12:
   */
   tcase_c ( "Test spkapo_c.  Compare to spkezp_c." );
   

   for ( i = 0;  i < 3;  i++ )
   {
   
      spkezp_c ( 399, et, REF1, LTs[0], 10, expState, &expLt );
      chckxc_c ( SPICEFALSE, " ", ok );
   
      spkssb_c ( 10,  et, REF1, obsState );
      spkapo_c ( 399, et, REF1, obsState, LTs[0], state, &lt );
      chckxc_c ( SPICEFALSE, " ", ok );
   
      
      sprintf ( title, "spkapo_c %s position", ltPhrases[i] );
      
      chckad_c( title, state, "~~/", expState, 3, TIGHT_RE, ok );
   
   
      sprintf ( title, "spkapo_c %s light time", ltPhrases[i] );
      
      chcksd_c( title,  lt,   "~/",  expLt,  TIGHT_RE,  ok );
   }



   /*
   Case 13:
   */
   
   tcase_c ( "Test stelab_c.  Apply stellar aberration correction "
             "to a state corrected for light time only.  Compare "
             "to LT+S corrected state from spkez_c."               );


   spkezp_c ( 10, et, REF1, "LT+S", 399, expPos, &expLt );
   chckxc_c ( SPICEFALSE, " ", ok );

   spkezp_c ( 10, et, REF1, "LT",   399, trgpos, &lt );
   chckxc_c ( SPICEFALSE, " ", ok );

   spkssb_c ( 399, et, REF1, state );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   vequ_c   ( state+3, obsvel );
   
   stelab_c ( trgpos, obsvel, state );
   chckxc_c ( SPICEFALSE, " ", ok );


   chckad_c ( "position from stelab_c",
              state,
              "~/",
              expPos,
              3,
              TIGHT_RE,
              ok                    );
              

   /*
   Close SPK1.
   */
   spkuef_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );




   /*
   Case: 14
   */
   tcase_c ( "Test spkw02_c." );
   
   
   expBody   = 3;
   expCenter = 10;
   strcpy ( expRef, "J2000" );
   
   
   /*
   Create a segment identifier.
   */
   strcpy ( segid, "SPK type 2 test segment" );
   
   
   /*
   Open a new SPK file.
   */
   
   if ( exists_c(SPK2) )
      {
      TRASH (SPK2);
      }
   
   spkopn_c ( SPK2, "Type 2 SPK internal file name.", 4, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   /*
   Create a type 2 segment.
   */
   
   intlen = discreteEpochs[1]-discreteEpochs[0];
   
   spkw02_c ( handle,
              expBody,
              expCenter,
              expRef,
              discreteEpochs[0],
              discreteEpochs[N_RECORDS], 
              segid,
              intlen,
              N_RECORDS,
              CHBDEG,
              ChebyCoeffs02,
              discreteEpochs[0]              );

   chckxc_c ( SPICEFALSE, " ", ok );
              
         
   /*
   Close the SPK file.
   */
   spkcls_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   /*
   Load the SPK file.
   */ 
   spklef_c ( SPK2, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   /*
   Look up states for each epoch in our list.  Compare.
   */
   
   for ( i = 0;  i < N_RECORDS; i++ )
   {
      radius = 0.5 * intlen;
      midpt  = discreteEpochs[i] + radius;

      et     =  midpt +  (0.5*radius);
      
      spkgeo_c ( expBody, et, expRef, expCenter,
                 state,   &lt                                  ); 
      chckxc_c ( SPICEFALSE, " ", ok );
      
                
      /*
      Evaluate the position manually.
      */ 
      theta = ( et - midpt ) / radius;
      
      for ( j = 0; j < 3; j++ )
      {
         expState[j] = 0.;
         
         for ( k = 0; k <= CHBDEG; k++ )
         {
            expState[j] += ( ChebyCoeffs02[i][j][k] * T( k, theta ) );
         }
      } 
      
      
      chckad_c ( "<type 2 position>", 
                 state,
                 "~",
                 expState,
                 3,
                 TIGHT_RE,
                 ok                );
   }
   
   spkuef_c ( handle );
   
   
   
   
   /*
   Case: 15
   */
   tcase_c ( "Test spkw03_c." );
   
   
   
   expBody   = 3;
   expCenter = 10;
   strcpy ( expRef, "J2000" );
   
   
   /*
   Create a segment identifier.
   */
   strcpy ( segid, "SPK type 3 test segment" );
   
   
   /*
   Open a new SPK file.
   */
   
   if ( exists_c(SPK3) )
      {
      TRASH (SPK3);
      }
   
   spkopn_c ( SPK3, "Type 3 SPK internal file name.", 4, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   /*
   Create a type 3 segment.
   */
   
   intlen = discreteEpochs[1]-discreteEpochs[0];
   
   spkw03_c ( handle,
              expBody,
              expCenter,
              expRef,
              discreteEpochs[0],
              discreteEpochs[N_RECORDS], 
              segid,
              intlen,
              N_RECORDS,
              CHBDEG,
              ChebyCoeffs03,
              discreteEpochs[0]              );

   chckxc_c ( SPICEFALSE, " ", ok );
              
         
   /*
   Close the SPK file.
   */
   spkcls_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   /*
   Load the SPK file.
   */ 
   spklef_c ( SPK3, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   /*
   Look up states for each epoch in our list.  Compare.
   */
   
   for ( i = 0;  i < N_RECORDS; i++ )
   {
      radius = 0.5 * intlen;
      midpt  = discreteEpochs[i] + radius;

      et     =  midpt +  (0.5*radius);
      
      spkgeo_c ( expBody, et, expRef, expCenter,
                 state,   &lt                                  ); 
      chckxc_c ( SPICEFALSE, " ", ok );
                      
      /*
      Evaluate the state manually.
      */        
      theta = ( et - midpt ) / radius;
      
      for ( j = 0; j < 6; j++ )
      {
         expState[j] = 0.;
         
         for ( k = 0; k <= CHBDEG; k++ )
         {
            expState[j] += ( ChebyCoeffs03[i][j][k] * T( k, theta ) );
         }
      } 
      
      
      chckad_c ( "<type 3 state>", 
                 state,
                 "~",
                 expState,
                 6,
                 TIGHT_RE,
                 ok                );
   }
   
   spkuef_c ( handle );
   
   
   




   /*
   Case 16:
   */
   tcase_c ( "Test spkw05_c.  Also test spkopn_c and spkcls_c." );
   
   
   
   expBody   = 3;
   expCenter = 10;
   strcpy ( expRef, "J2000" );
   
   
   /*
   Create a segment identifier.
   */
   strcpy ( segid, "SPK type 5 test segment" );
   
   
   /*
   Open a new SPK file.
   */
   
   if ( exists_c(SPK5) )
   {
      TRASH (SPK5);
   }
   
   spkopn_c ( SPK5, "Type 5 SPK internal file name.", 4, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   /*
   Create a type 5 segment.
   */
   spkw05_c ( handle,
              expBody,
              expCenter,
              expRef,
              discreteEpochs[0],
              discreteEpochs[N_DISCRETE-1], 
              segid,
              GM_SUN,
              N_DISCRETE,
              discreteStates,
              discreteEpochs             );

   chckxc_c ( SPICEFALSE, " ", ok );
              
         
   /*
   Close the SPK file.
   */
   spkcls_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   /*
   Load the SPK file.
   */ 
   spklef_c ( SPK5, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   /*
   Look up states for each epoch in our list.  Compare.
   */
   
   for ( i = 0;  i < N_DISCRETE; i++ )
   {
      spkgeo_c ( expBody, discreteEpochs[i], expRef, expCenter,
                 state,   &lt                                  ); 
      chckxc_c ( SPICEFALSE, " ", ok );
      
      chckad_c ( "type 5 state", 
                 state,
                 "=",
                 discreteStates[i],
                 6,
                 TIGHT_RE,
                 ok                );
   }
   
   spkuef_c ( handle );


   
   /*
   Case 17:
   */
   tcase_c ( "Test spkw08_c." );
   
   
   
   
   expBody   = 3;
   expCenter = 10;
   strcpy ( expRef, "J2000" );
   
   
   /*
   Create a segment identifier.
   */
   strcpy ( segid, "SPK type 8 test segment" );
   
   
   /*
   Open a new SPK file.
   */
   
   if ( exists_c(SPK8) )
      {
      TRASH (SPK8);
      }
   
   spkopn_c ( SPK8, "Type 8 SPK internal file name.", 4, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   step = discreteEpochs[1] - discreteEpochs[0];
   
   /*
   Create a type 8 segment.
   */
   spkw08_c ( handle,
              expBody,
              expCenter,
              expRef,
              discreteEpochs[0],
              discreteEpochs[N_DISCRETE-1], 
              segid,
              POLY_DEG,
              N_DISCRETE,
              discreteStates,
              discreteEpochs[0],
              step                        );

   chckxc_c ( SPICEFALSE, " ", ok );
              
         
   /*
   Close the SPK file.
   */
   spkcls_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   /*
   Load the SPK file.
   */ 
   spklef_c ( SPK8, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   /*
   Look up states for each epoch in our list.  Compare.
   */
   
   for ( i = 0;  i < N_DISCRETE; i++ )
   {
      spkgeo_c ( expBody, discreteEpochs[i], expRef, expCenter,
                 state,   &lt                                  ); 
      chckxc_c ( SPICEFALSE, " ", ok );
      
      chckad_c ( "type 8 state", 
                 state,
                 "=",
                 discreteStates[i],
                 6,
                 TIGHT_RE,
                 ok                );
   }
   
   spkuef_c ( handle );



   /*
   Case 18:
   */
   tcase_c ( "Test spkw09_c." );
   
   
   
   
   expBody   = 3;
   expCenter = 10;
   strcpy ( expRef, "J2000" );
   
   
   /*
   Create a segment identifier.
   */
   strcpy ( segid, "SPK type 9 test segment" );
   
   
   /*
   Open a new SPK file.
   */
   
   if ( exists_c(SPK9) )
      {
      TRASH (SPK9);
      }
   
   spkopn_c ( SPK9, "Type 9 SPK internal file name.", 4, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   step = discreteEpochs[1] - discreteEpochs[0];
   
   /*
   Create a type 9 segment.
   */
   spkw09_c ( handle,
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
   
   
   /*
   Load the SPK file.
   */ 
   spklef_c ( SPK9, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   /*
   Look up states for each epoch in our list.  Compare.
   */
   
   for ( i = 0;  i < N_DISCRETE; i++ )
   {
      spkgeo_c ( expBody, discreteEpochs[i], expRef, expCenter,
                 state,   &lt                                  ); 
      chckxc_c ( SPICEFALSE, " ", ok );
      
      chckad_c ( "type 9 state", 
                 state,
                 "=",
                 discreteStates[i],
                 6,
                 TIGHT_RE,
                 ok                );
   }
   
   spkuef_c ( handle );
   
   

   
   /*
   Case 19:
   */
   tcase_c ( "Test spkw12_c." );
   
   
   
   
   expBody   = 3;
   expCenter = 10;
   strcpy ( expRef, "J2000" );
   
   
   /*
   Create a segment identifier.
   */
   strcpy ( segid, "SPK type 12 test segment" );
   
   
   /*
   Open a new SPK file.
   */
   
   if ( exists_c(SPK12) )
      {
      TRASH (SPK12);
      }
   
   spkopn_c ( SPK12, "Type 12 SPK internal file name.", 4, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
 
 
 
 
   /*
   Test the type 12 segment writer's error handling.  Most errors
   are detected in the underlying SPICELIB code.
   */
   spkw12_c ( handle,
              expBody,
              expCenter,
              "SPUD",
              discreteEpochs[0],
              discreteEpochs[N_DISCRETE-1], 
              segid,
              POLY_DEG,
              N_DISCRETE,
              discreteStates,
              discreteEpochs[0],
              step                        );

   chckxc_c ( SPICETRUE, "SPICE(INVALIDREFFRAME)", ok );
              
              
   spkw12_c ( handle,
              expBody,
              expCenter,
              expRef,
              discreteEpochs[0],
              discreteEpochs[N_DISCRETE-1], 
              "X                                                    X",
              POLY_DEG,
              N_DISCRETE,
              discreteStates,
              discreteEpochs[0],
              step                        );

   chckxc_c ( SPICETRUE, "SPICE(SEGIDTOOLONG)", ok );
              

   segid[0] = (char)7;
   
   spkw12_c ( handle,
              expBody,
              expCenter,
              expRef,
              discreteEpochs[0],
              discreteEpochs[N_DISCRETE-1], 
              segid,
              POLY_DEG,
              N_DISCRETE,
              discreteStates,
              discreteEpochs[0],
              step                        );

   chckxc_c ( SPICETRUE, "SPICE(NONPRINTABLECHARS)", ok );
              
   strcpy ( segid, "SPK type 12 test segment" );
              
              
   spkw12_c ( handle,
              expBody,
              expCenter,
              expRef,
              discreteEpochs[0],
              discreteEpochs[N_DISCRETE-1], 
              segid,
              -1,
              N_DISCRETE,
              discreteStates,
              discreteEpochs[0],
              step                        );

   chckxc_c ( SPICETRUE, "SPICE(INVALIDDEGREE)", ok );


   spkw12_c ( handle,
              expBody,
              expCenter,
              expRef,
              discreteEpochs[0],
              discreteEpochs[N_DISCRETE-1], 
              segid,
              99,
              N_DISCRETE,
              discreteStates,
              discreteEpochs[0],
              step                        );

   chckxc_c ( SPICETRUE, "SPICE(INVALIDDEGREE)", ok );


   spkw12_c ( handle,
              expBody,
              expCenter,
              expRef,
              discreteEpochs[0],
              discreteEpochs[N_DISCRETE-1], 
              segid,
              4,
              N_DISCRETE,
              discreteStates,
              discreteEpochs[0],
              step                        );

   chckxc_c ( SPICETRUE, "SPICE(INVALIDDEGREE)", ok );


   spkw12_c ( handle,
              expBody,
              expCenter,
              expRef,
              discreteEpochs[0],
              discreteEpochs[N_DISCRETE-1], 
              segid,
              POLY_DEG,
              1,
              discreteStates,
              discreteEpochs[0],
              step                        );

   chckxc_c ( SPICETRUE, "SPICE(TOOFEWSTATES)", ok );



   spkw12_c ( handle,
              expBody,
              expCenter,
              expRef,
              discreteEpochs[N_DISCRETE-1], 
              discreteEpochs[0],
              segid,
              POLY_DEG,
              N_DISCRETE,
              discreteStates,
              discreteEpochs[0],
              step                        );

   chckxc_c ( SPICETRUE, "SPICE(BADDESCRTIMES)", ok );


   spkw12_c ( handle,
              expBody,
              expCenter,
              expRef,
              discreteEpochs[0],
              discreteEpochs[N_DISCRETE-1], 
              segid,
              POLY_DEG,
              N_DISCRETE,
              discreteStates,
              discreteEpochs[0],
              -1.                        );

   chckxc_c ( SPICETRUE, "SPICE(INVALIDSTEPSIZE)", ok );


   spkw12_c ( handle,
              expBody,
              expCenter,
              expRef,
              discreteEpochs[0],
              discreteEpochs[N_DISCRETE-1], 
              segid,
              POLY_DEG,
              N_DISCRETE,
              discreteStates,
              discreteEpochs[0] + 1.0,
              step                       );

   chckxc_c ( SPICETRUE, "SPICE(BADDESCRTIMES)", ok );


   spkw12_c ( handle,
              expBody,
              expCenter,
              expRef,
              discreteEpochs[0],
              discreteEpochs[N_DISCRETE-1], 
              segid,
              POLY_DEG,
              N_DISCRETE,
              discreteStates,
              discreteEpochs[0] + 1.0,
              step                       );

   chckxc_c ( SPICETRUE, "SPICE(BADDESCRTIMES)", ok );



   /*
   Check string error handling within the spkw12_c wrapper.
   
      1) Null frame name.
      2) Empty frame name.
      3) Null segment identifier.
      4) Empty segment identifier.
      
   */
   spkw12_c ( handle,
              expBody,
              expCenter,
              (SpiceChar *)0,
              discreteEpochs[0],
              discreteEpochs[N_DISCRETE-1], 
              segid,
              POLY_DEG,
              N_DISCRETE,
              discreteStates,
              discreteEpochs[0],
              step                       );

   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   
   spkw12_c ( handle,
              expBody,
              expCenter,
              "",
              discreteEpochs[0],
              discreteEpochs[N_DISCRETE-1], 
              segid,
              POLY_DEG,
              N_DISCRETE,
              discreteStates,
              discreteEpochs[0] + 1.0,
              step                       );

   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );
            

   spkw12_c ( handle,
              expBody,
              expCenter,
              expRef,
              discreteEpochs[0],
              discreteEpochs[N_DISCRETE-1], 
              (SpiceChar *)0,
              POLY_DEG,
              N_DISCRETE,
              discreteStates,
              discreteEpochs[0],
              step                       );

   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   
   spkw12_c ( handle,
              expBody,
              expCenter,
              expRef,
              discreteEpochs[0],
              discreteEpochs[N_DISCRETE-1], 
              "",
              POLY_DEG,
              N_DISCRETE,
              discreteStates,
              discreteEpochs[0] + 1.0,
              step                       );

   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );
            




   /*
   That's it for the error cases.  We're finally ready to create a
   real segment.
   */            
   
   step = discreteEpochs[1] - discreteEpochs[0];
 
   
   /*
   Create a type 12 segment.
   */
   spkw12_c ( handle,
              expBody,
              expCenter,
              expRef,
              discreteEpochs[0],
              discreteEpochs[N_DISCRETE-1], 
              segid,
              POLY_DEG,
              N_DISCRETE,
              discreteStates,
              discreteEpochs[0],
              step                        );

   chckxc_c ( SPICEFALSE, " ", ok );
              
         
   /*
   Close the SPK file.
   */
   spkcls_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   /*
   Load the SPK file.
   */ 
   spklef_c ( SPK12, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   /*
   Look up states for each epoch in our list.  Compare.
   */
   
   for ( i = 0;  i < N_DISCRETE; i++ )
   {
      spkgeo_c ( expBody, discreteEpochs[i], expRef, expCenter,
                 state,   &lt                                  ); 
      chckxc_c ( SPICEFALSE, " ", ok );
      
      
      chckad_c ( "type 12 state", 
                 state,
                 "=",
                 discreteStates[i],
                 6,
                 TIGHT_RE,
                 ok                );
   }
   
   spkuef_c ( handle );





   /*
   Case:  20
   */
   tcase_c ( "Test spkw12_c.  Create a large segment with multiple "
             "directories."                                         );
             

   /*
   Create the state and epoch values we'll use.  We're going to set
   all velocities to zero to create a rounded stair-step sort of 
   pattern in the position components.  This will ensure that the
   correct states cannot be obtained without selecting the correct
   window of states in the reader.
   */
   
   for ( i = 0;  i < BIG_N; i++ )
   {
      for ( j = 0;  j < 3;  j++ )
      {
         bigStateList[i][j  ] = (SpiceDouble) ( BIG_STEP*i + j );
         bigStateList[i][j+3] = 0.0;
      }
   
      bigEpochList[i] = (SpiceDouble) ( 10 * i );
   }


   /*
   Open a new type 12 SPK file.
   */
   
   if ( exists_c(SPK12BIG) )
      {
      TRASH (SPK12BIG);
      }
   
   spkopn_c ( SPK12BIG, "Type 12 SPK internal file name.", 0, &handle );
   
   spkw12_c ( handle,
              BIG_ID,
              BIG_CTR,
              expRef,
              bigEpochList[0],
              bigEpochList[BIG_N-1], 
              segid,
              BIG_DEG,
              BIG_N,
              bigStateList,
              bigEpochList[0],
              BIG_STEP                );

   chckxc_c ( SPICEFALSE, " ", ok );
              
   spkcls_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   

   
   /*
   Load the SPK file.
   */ 
   spklef_c ( SPK12BIG, &handle );
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
      Set up the expected state vector.  The derivative 1.5 was
      obtained by differentiating the cubic -2x**3 +3x**2 at x = 0.5;
      this cubic has the same shape (but smaller scale) as the cubic
      that actually fits the state data. 
      */
      
      MOVED ( bigStateList[i], 6, expState );
      
      for ( j = 0;  j < 3; j++ )
      {
         expState[j  ]  +=   BIG_STEP / 2;
         expState[j+3]   =   1.5;
      }
      
      chckad_c ( "type 12 state", 
                 state,
                 "=",
                 expState,
                 6,
                 TIGHT_RE,
                 ok                );
   }
   
   spkuef_c ( handle );



   
   
   /*
   Case 21:
   */
   tcase_c ( "Test spkw13_c." );
   
   
   
   
   expBody   = 3;
   expCenter = 10;
   strcpy ( expRef, "J2000" );
   
   
   /*
   Create a segment identifier.
   */
   strcpy ( segid, "SPK type 13 test segment" );
   
   
   /*
   Open a new SPK file.
   */
   
   if ( exists_c(SPK13) )
      {
      TRASH (SPK13);
      }
   
   spkopn_c ( SPK13, "Type 13 SPK internal file name.", 4, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
 
   /*
   Test the type 13 segment writer's error handling.  Most errors
   are detected in the underlying SPICELIB code.
   */
   spkw13_c ( handle,
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
              
              
   spkw13_c ( handle,
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
              

   segid[0] = (char)7;
   
   spkw13_c ( handle,
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
              
   strcpy ( segid, "SPK type 13 test segment" );
              
              
   spkw13_c ( handle,
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


   spkw13_c ( handle,
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


   spkw13_c ( handle,
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


   spkw13_c ( handle,
              expBody,
              expCenter,
              expRef,
              discreteEpochs[0],
              discreteEpochs[N_DISCRETE-1], 
              segid,
              POLY_DEG,
              1,
              discreteStates,
              discreteEpochs              );

   chckxc_c ( SPICETRUE, "SPICE(TOOFEWSTATES)", ok );



   spkw13_c ( handle,
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



   et                 = discreteEpochs[3]; 
   discreteEpochs[3]  = discreteEpochs[2];
   discreteEpochs[2]  = et;
   
   spkw13_c ( handle,
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
   


   spkw13_c ( handle,
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


   spkw13_c ( handle,
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
   Check string error handling within the spkw13_c wrapper.
   
      1) Null frame name.
      2) Empty frame name.
      3) Null segment identifier.
      4) Empty segment identifier.
      
   */
   spkw13_c ( handle,
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
   
   spkw13_c ( handle,
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
            

   spkw13_c ( handle,
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
   
   spkw13_c ( handle,
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
   
   
   
   
   
   
   step = discreteEpochs[1] - discreteEpochs[0];
   
   /*
   Create a type 13 segment.
   */
   spkw13_c ( handle,
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
   
   
   /*
   Load the SPK file.
   */ 
   spklef_c ( SPK13, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   /*
   Look up states for each epoch in our list.  Compare.
   */
   
   for ( i = 0;  i < N_DISCRETE; i++ )
   {
      spkgeo_c ( expBody, discreteEpochs[i], expRef, expCenter,
                 state,   &lt                                  ); 
      chckxc_c ( SPICEFALSE, " ", ok );
      
      
      chckad_c ( "type 13 state", 
                 state,
                 "=",
                 discreteStates[i],
                 6,
                 TIGHT_RE,
                 ok                );
   }
   
   spkuef_c ( handle );
   
   





   /*
   Case:  22
   */
   tcase_c ( "Test spkw13_c.  Create a large segment with multiple "
             "directories."                                         );
             

   /*
   Create the state and epoch values we'll use.  We're going to set
   all velocities to zero to create a rounded stair-step sort of 
   pattern in the position components.  This will ensure that the
   correct states cannot be obtained without selecting the correct
   window of states in the reader.
   */
   
   for ( i = 0;  i < BIG_N; i++ )
   {
      for ( j = 0;  j < 3;  j++ )
      {
         bigStateList[i][j  ] = (SpiceDouble) ( BIG_STEP*i + j );
         bigStateList[i][j+3] = 0.0;
      }
   
      bigEpochList[i] = (SpiceDouble) ( 10 * i );
   }


   /*
   Open a new type 13 SPK file.
   */
   
   if ( exists_c(SPK13BIG) )
      {
      TRASH (SPK13BIG);
      }
   
   spkopn_c ( SPK13BIG, "Type 13 SPK internal file name.", 0, &handle );
   
   spkw13_c ( handle,
              BIG_ID,
              BIG_CTR,
              expRef,
              bigEpochList[0],
              bigEpochList[BIG_N-1], 
              segid,
              BIG_DEG,
              BIG_N,
              bigStateList,
              bigEpochList          );

   chckxc_c ( SPICEFALSE, " ", ok );
              
   spkcls_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   

   
   /*
   Load the SPK file.
   */ 
   spklef_c ( SPK13BIG, &handle );
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
      Set up the expected state vector.  The derivative 1.5 was
      obtained by differentiating the cubic -2x**3 +3x**2 at x = 0.5;
      this cubic has the same shape (but smaller scale) as the cubic
      that actually fits the state data. 
      */
      
      MOVED ( bigStateList[i], 6, expState );
      
      for ( j = 0;  j < 3; j++ )
      {
         expState[j  ]  +=   BIG_STEP / 2;
         expState[j+3]   =   1.5;
      }
      
      chckad_c ( "type 13 state", 
                 state,
                 "=",
                 expState,
                 6,
                 TIGHT_RE,
                 ok                );
   }
   
   spkuef_c ( handle );







   /*
   Case: 23
   */
   tcase_c ( "Test spk14b_c, spk14a_c, spk14c_c." );
   
    
   expBody   = 3;
   expCenter = 10;
   strcpy ( expRef, "J2000" );
   
   
   /*
   Create a segment identifier.
   */
   strcpy ( segid, "SPK type 14 test segment" );
   
   
   /*
   Open a new SPK file.
   */
   
   if ( exists_c(SPK14) )
      {
      TRASH (SPK14);
      }
   
   spkopn_c ( SPK14, "Type 14 SPK internal file name.", 4, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   /*
   Create a type 14 segment.
   */
   
   intlen = discreteEpochs[1]-discreteEpochs[0];
   
   spk14b_c ( handle,
              segid,
              expBody,
              expCenter,
              expRef,
              discreteEpochs[0],
              discreteEpochs[N_RECORDS], 
              CHBDEG                     );
   chckxc_c ( SPICEFALSE, " ", ok );
              
   
   /*
   Add the data.
   */
   
   spk14a_c ( handle,           
              N_RECORDS,
              ChebyRecords14,
              discreteEpochs );

   chckxc_c ( SPICEFALSE, " ", ok );
              


   /*
   End the segment.
   */
   spk14e_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
    
         
   /*
   Close the SPK file.
   */
   spkcls_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   /*
   Load the SPK file.
   */ 
   spklef_c ( SPK14, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   /*
   Look up states for each epoch in our list.  Compare.
   */
   
   for ( i = 0;  i < N_RECORDS; i++ )
   {
      radius = 0.5 * intlen;
      midpt  = discreteEpochs[i] + radius;

      et     =  midpt +  (0.5*radius);
      
      spkgeo_c ( expBody, et, expRef, expCenter,
                 state,   &lt                                  ); 
      chckxc_c ( SPICEFALSE, " ", ok );
                      
      /*
      Evaluate the state manually.  The states should actually be 
      identical to those from the type 3 test case.
      */        
      theta = ( et - midpt ) / radius;
      
      for ( j = 0; j < 6; j++ )
      {
         expState[j] = 0.;
         
         for ( k = 0; k <= CHBDEG; k++ )
         {
            expState[j] += ( ChebyCoeffs03[i][j][k] * T( k, theta ) );
         }
      } 
      
      
      chckad_c ( "<type 14 state>", 
                 state,
                 "~",
                 expState,
                 6,
                 TIGHT_RE,
                 ok                );
   }
   
   spkuef_c ( handle );
   


   /*
   Case:  24
   */
   
   /*
   ***
   */
   tcase_c ( "Test prop2b_c.  Use a circular orbit to keep things "
             "simple."                                              );
             
             
   /*
   In circular two-body motion, the orbital speed s is sqrt(mu/r),
   where mu is the central mass.  After tau/2 = pi*r/s seconds, the
   state should be the negative of the original state.
   */ 
   
   mu     =  1.e10;
   r      =  1.e08;
   speed  =  sqrt( mu / r );
   t      =  pi_c()  *  r  /  speed;
   
   vpack_c ( 0.,   r     /sqrt(2.),   r    /sqrt(2.),   pvinit   );
   vpack_c ( 0.,   -speed/sqrt(2.),   speed/sqrt(2.),   pvinit+3 );

   prop2b_c ( mu, pvinit, t, state );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   vminug_c ( pvinit, 6, expState );
   
   chckad_c ( "state propagated by prop2b_c",
              state,
              "~/",
              expState,
              6,
              LOOSE_RE,
              ok                             );
   
   

   /*
   Case:  25
   */
   
   tcase_c ( "Check ltime_c." );
   
   spklef_c ( SPK1, &handle );
   
   spkezr_c ( "earth", et, REF1, "CN", "sun", expState, &expLt );
   chckxc_c ( SPICEFALSE, " ", ok );

   ltime_c ( et, 10, "<-", 399, &ettarg, &elapsd );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   chcksd_c ( "emission time", ettarg, "~/", et-expLt, TIGHT_RE, ok );
   chcksd_c ( "travel time",   elapsd, "~/", expLt,    TIGHT_RE, ok );



   /*
   Case:  26
   */
   
   tcase_c ( "Check spkpds_c and spkuds_c." );
   
   
   /*
   Create a descriptor for a segment.
   */
   
   spkpds_c ( expBody, 
              expCenter, 
              expRef, 
              5, 
              discreteEpochs[0],
              discreteEpochs[N_DISCRETE-1], 
              descr                       );
    
   chckxc_c ( SPICEFALSE, " ", ok );
   
   namfrm_ ( expRef, &expFrcode, strlen(expRef) );
   
   
   /*
   Unpack the descriptor.
   */
   
   spkuds_c ( descr, 
              &body,  &center, &frcode,  &type,
              &first, &last,   &begin,   &end  );
   
   
   chckxc_c ( SPICEFALSE, " ", ok );
   
   i = N_DISCRETE-1;
   
   chcksi_c ( "body",       body,   "=", expBody,           0, ok );
   chcksi_c ( "center",     center, "=", expCenter,         0, ok );
   chcksi_c ( "frame code", frcode, "=", expFrcode,         0, ok );
   chcksi_c ( "SPK type",   type,   "=", 5,                 0, ok );
   chcksd_c ( "start time", first,  "=", discreteEpochs[0], 0, ok );
   chcksd_c ( "end time",   last,   "=", discreteEpochs[i], 0, ok );


   /*
   Case:  27
   */
   
   tcase_c ( "Check spkopa_c.  Append a second segment to SPK5." );
   

   
   expBody   = 399;
   expCenter = 10;
   strcpy ( expRef, "J2000" );
   
   
   /*
   Create a segment identifier.
   */
   strcpy ( segid, "SPK type 5 test segment #2" );
   
   
   /*
   Open the SPK file SPK5 for appending.
   */
   
   spkopa_c ( SPK5, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   /*
   Create a type 5 segment.
   */
   spkw05_c ( handle,
              expBody,
              expCenter,
              expRef,
              discreteEpochs[0],
              discreteEpochs[N_DISCRETE-1], 
              segid,
              GM_SUN,
              N_DISCRETE,
              discreteStates,
              discreteEpochs             );

   chckxc_c ( SPICEFALSE, " ", ok );
              
         
   /*
   Close the SPK file.
   */
   spkcls_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   /*
   Load the SPK file.
   */ 
   spklef_c ( SPK5, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   /*
   Look up states for each epoch in our list.  Compare.
   */
   
   for ( i = 0;  i < N_DISCRETE; i++ )
   {
      spkgeo_c ( expBody, discreteEpochs[i], expRef, expCenter,
                 state,   &lt                                  ); 
      chckxc_c ( SPICEFALSE, " ", ok );
      
      
      chckad_c ( "type 5 state", 
                 state,
                 "=",
                 discreteStates[i],
                 6,
                 TIGHT_RE,
                 ok                );
   }
   
   spkuef_c ( handle );



   /*
   Case:  28
   */
   
   tcase_c ( "Check spksub_c.  Subset SPK5 to produce a file that " 
             "spans the time range from discreteEpochs[1] through "
             "discreteEpochs[N_DISCRETE-2]."                        );
   

   dafopr_c ( SPK5,    &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   if ( exists_c(SPK5SUB) )
      {
      TRASH ( SPK5SUB );
      }
   
   spkopn_c ( SPK5SUB, "Type 5 subset test file", 0, &newh   );
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



   /*
   Load the subsetted SPK file.
   */ 
   spklef_c ( SPK5SUB, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   /*
   Look up earth and earth-moon barycenter states for each epoch in our
   list.  Compare.
   */
   
   for ( i = 1;  i < N_DISCRETE-1; i++ )
   {
      spkgeo_c ( 3, discreteEpochs[i], expRef, expCenter,
                 state,   &lt                                  ); 
      chckxc_c ( SPICEFALSE, " ", ok );
      
      chckad_c ( "type 5 state", 
                 state,
                 "=",
                 discreteStates[i],
                 6,
                 TIGHT_RE,
                 ok                );
                 
      spkgeo_c ( 399, discreteEpochs[i], expRef, expCenter,
                 state,   &lt                                  ); 
      chckxc_c ( SPICEFALSE, " ", ok );
      
      
      chckad_c ( "type 5 state", 
                 state,
                 "=",
                 discreteStates[i],
                 6,
                 TIGHT_RE,
                 ok                );
   }
   

   /*
   Check the descriptor bounds in the new file.
   */
      
   dafbfs_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   daffna_c ( &found );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   while ( found )
   {
      dafgs_c ( descr );
      chckxc_c ( SPICEFALSE, " ", ok );
   
      spkuds_c ( descr, 
                 &body,  &center, &frcode,  &type,
                 &first, &last,   &begin,   &end  );
                 
      j = N_DISCRETE - 2;
      
      chcksd_c ( "start time", first, "=", discreteEpochs[1], 0.0, ok); 
      chcksd_c ( "end time",   last,  "=", discreteEpochs[j], 0.0, ok); 
      
      daffna_c ( &found );
      chckxc_c ( SPICEFALSE, " ", ok );
   }
   
   spkuef_c ( handle );




   /*
   Case:  29
   */
   
   tcase_c ( "Check SPKS12.  Subset SPK12 to produce a file that " 
             "spans the time range from discreteEpochs[1] through "
             "discreteEpochs[N_DISCRETE-2]."                        );
   

   dafopr_c ( SPK12,    &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   if ( exists_c(SPK12SUB) )
      {
      TRASH ( SPK12SUB );
      }
   
   spkopn_c ( SPK12SUB, "Type 12 subset test file", 0, &newh   );
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



   /*
   Load the subsetted SPK file.
   */ 
   spklef_c ( SPK12SUB, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   /*
   Look up earth and earth-moon barycenter states for each epoch in our
   list.  Compare.
   */
   
   for ( i = 1;  i < N_DISCRETE-1; i++ )
   {
      spkgeo_c ( 3, discreteEpochs[i], "J2000", 10,
                 state,   &lt                                  ); 
      chckxc_c ( SPICEFALSE, " ", ok );
      
      chckad_c ( "type 12 state", 
                 state,
                 "=",
                 discreteStates[i],
                 6,
                 TIGHT_RE,
                 ok                );
   }
   

   /*
   Check the descriptor bounds in the new file.
   */
      
   dafbfs_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   daffna_c ( &found );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   while ( found )
   {
      dafgs_c ( descr );
      chckxc_c ( SPICEFALSE, " ", ok );
   
      spkuds_c ( descr, 
                 &body,  &center, &frcode,  &type,
                 &first, &last,   &begin,   &end  );
                 
      j = N_DISCRETE - 2;
      
      chcksd_c ( "start time", first, "=", discreteEpochs[1], 0.0, ok); 
      chcksd_c ( "end time",   last,  "=", discreteEpochs[j], 0.0, ok); 
      
      daffna_c ( &found );
      chckxc_c ( SPICEFALSE, " ", ok );
   }
   
   spkuef_c ( handle );

   


   /*
   Case:  30
   */
   
   tcase_c ( "Check SPKS13.  Subset SPK13 to produce a file that " 
             "spans the time range from discreteEpochs[1] through "
             "discreteEpochs[N_DISCRETE-2]."                        );
   

   dafopr_c ( SPK13,    &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   if ( exists_c(SPK13SUB) )
      {
      TRASH ( SPK13SUB );
      }
   
   spkopn_c ( SPK13SUB, "Type 13 subset test file", 0, &newh   );
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



   /*
   Load the subsetted SPK file.
   */ 
   spklef_c ( SPK13SUB, &handle );
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
            
      chckad_c ( "type 13 state", 
                 state,
                 "=",
                 discreteStates[i],
                 6,
                 TIGHT_RE,
                 ok                );
                 
      }
   
   /* Unload the file so we can delete. */
   spkuef_c ( handle );



   
   
   /*
   Clean up the SPK files we've created. tspice_c deletes SPK1
   and end-of-run, no need for an explicit delete (which might not work).
   */
   TRASH ( SPK2     );
   TRASH ( SPK3     );
   TRASH ( SPK5     );  
   TRASH ( SPK5SUB  );
   TRASH ( SPK8     );
   TRASH ( SPK9     );
   TRASH ( SPK12    );
   TRASH ( SPK12BIG ); 
   TRASH ( SPK12SUB ); 
   TRASH ( SPK13    );
   TRASH ( SPK13BIG );
   TRASH ( SPK13SUB );
   TRASH ( SPK14    );
   
   
   
   /*
   Retrieve the current test status.
   */ 
   t_success_c ( ok ); 
   
   
} /* End f_spk_c */
