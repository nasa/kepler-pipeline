/*

-Procedure f_spkcov_c ( Test wrappers for SPK coverage routines )


-Abstract

   Perform tests on CSPICE wrappers for the SPK
   coverage routines.

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
   #include <string.h>
   #include <math.h>
   #include "SpiceUsr.h"
   #include "SpiceZmc.h"
   #include "tutils_c.h"
   
   void f_spkcov_c ( SpiceBoolean * ok )

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

   This test family exercises the wrappers

      spkcov_c
      spkobj_c

-Examples

   None.

-Restrictions

   None.

-Author_and_Institution

   N.J. Bachman    (JPL)

-Literature_References

   None.

-Version

   -tspice_c Version 1.0.0 04-JAN-2004 (NJB)

-&
*/

{ /* Begin f_spkcov_c */

   /*
   Local constants
   */
   #define CK              "spkcov.bc"
   #define EK              "spkcov.bes"
   #define SCLK            "spkcov.tsc"
   #define SPK             "spkcov.bsp"
   #define XFRSPK          "spkcov.xsp"

   #define DELTA            ( 1.e-6  )
   #define BIGTOL           ( 1.e-12 )
   #define MEDTOL           ( 1.e-14 )

   #define MAXCOV           10000
   #define WINSIZ           ( 2 * MAXCOV )

   #define FILSIZ           256
   #define LNSIZE           81
   #define NBOD             3
  

   /*
   Local variables
   */
   SPICEDOUBLE_CELL      ( cover,   WINSIZ );
   SPICEDOUBLE_CELL      ( xcover0, WINSIZ );
   SPICEDOUBLE_CELL      ( xcover1, WINSIZ );
   SPICEDOUBLE_CELL      ( xcover2, WINSIZ );

   SPICEINT_CELL         ( ids,     (NBOD+1) );
   SPICEINT_CELL         ( xids,    (NBOD+1) );

   static SpiceCell      * xcov     [ NBOD ] = { &xcover0,
                                                 &xcover1,
                                                 &xcover2 };
   SpiceChar               title    [ LNSIZE ];


   SpiceDouble             states   [2][6];
   SpiceDouble             first;
   SpiceDouble             last;

   static SpiceInt         body     [ NBOD ]  =  { 4, 5, 6 };

   SpiceInt                handle;
   SpiceInt                i;
   SpiceInt                j;
   static SpiceInt         nseg     [ NBOD ]  =  { 10, 20, 30 };
   SpiceInt                unit;


   /*
   Local macros 
   */




   topen_c ( "f_spkcov_c" );


   /*
   --- Case: ------------------------------------------------------
   */

   tcase_c ( "Setup:  create SPK file." );

   /*
   Create an SPK file with data for three bodies. 
   */
   spkopn_c ( SPK, SPK, 0, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );


   j = 12;
   cleard_ ( &j, (SpiceDouble *)states );


   for ( i = 0;  i < NBOD;  i++  )
   {
      for ( j = 0;  j < nseg[i];  j++  )
      {
         /*
         Create segments for body I.
         */
         if ( i == 0  )
         {
            /*
            Create nseg[0] segments, each one separated by a 1 second gap.
            */
            first = (j-1) * 11.0; 
            last  = first + 10.0; 
         } 

         else if ( i == 1 )
         {
            /*
            Create nseg[1] segments, each one separated
            by a 1 second gap.  This time, create the 
            segments in decreasing time order.
            */
            first = ( nseg[1] - j ) * 101.0;
            last  = first + 100.0;
         }

         else
         {
            /*
            i == 3 

            Create nseg[2] segments with no gaps.
            */
            first = (j-1) * 1000.0;
            last  = first + 1000.0;
         }

         /*
         Add to the expected coverage window for this body.
         */
         wninsd_c ( first, last, xcov[i] );
         chckxc_c ( SPICEFALSE, " ", ok );


         spkw08_c ( handle,  body[i],  399,    "J2000",
                    first,   last,     "TEST",  1,
                    2,       states,   first,   last-first+DELTA );
         chckxc_c ( SPICEFALSE, " ", ok );

      }

   }

   spkcls_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );



   /*
   Find the available coverage in SPK for the objects in the
   body array.

   Loop through the canned cases.
   */
   for ( i = 0;  i < NBOD;  i++  )
   {
      /*
      --- Case: ------------------------------------------------------
      */
   
      sprintf ( title, "Check coverage for body %ld", i );
      tcase_c ( title );

      /*
      In this test, we empty out cover before using it. 
      */
      scard_c  ( 0,            &cover );
      spkcov_c ( SPK, body[i], &cover );
      chckxc_c ( SPICEFALSE, " ", ok );

      /*
      Check cardinality of coverage window. 
      */
      chcksi_c ( "card_c(&cover)",   card_c(&cover),   "=",
                 card_c(xcov[i]),    0,                ok   );

      /*
      Check coverage window. 
      */

      chckad_c ( "cover", 
                 (SpiceDouble *)cover.base, 
                 "=",
                 (SpiceDouble *)( (xcov[i])->base ),
                 card_c ( &cover ), 
                 0.0,
                 ok                                  );

   }



   /*
   Find the available coverage in SPK for the objects in the
   body array.  This time, start with a non-empty coverage window.

   Loop through the canned cases.
   */
   for ( i = 0;  i < NBOD;  i++  )
   {
      /*
      --- Case: ------------------------------------------------------
      */
   
      sprintf ( title, "Check coverage for body %ld; cover "
                       "starts out non-empty.",     i       );
      tcase_c ( title );

      /*
      In this test, we put an interval into cover before using it. 
      */
      scard_c  ( 0,            &cover );
      wninsd_c ( 1.e6,  1.e7,  &cover );
      chckxc_c ( SPICEFALSE, " ", ok );

      spkcov_c ( SPK, body[i], &cover );
      chckxc_c ( SPICEFALSE, " ", ok );

      /*
      Check cardinality of coverage window. 
      */
      wninsd_c ( 1.e6,  1.e7,  xcov[i] );
      chckxc_c ( SPICEFALSE, " ", ok );

      chcksi_c ( "card_c(&cover)",   card_c(&cover),   "=",
                 card_c(xcov[i]),    0,                ok   );

      /*
      Check coverage window. 
      */
      chckad_c ( "cover", 
                 (SpiceDouble *)cover.base, 
                 "=",
                 (SpiceDouble *)( (xcov[i])->base ),
                 card_c ( &cover ), 
                 0.0,
                 ok                                  );
   }


   /*
   Error cases 
   */

   /*
   --- Case: ------------------------------------------------------
   */

   tcase_c ( "Error:  spkcov_c empty SPK name" );

   spkcov_c ( "", 1, &cover );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );


   /*
   --- Case: ------------------------------------------------------
   */

   tcase_c ( "Error:  spkcov_c null SPK name" );

   spkcov_c ( NULLCPTR, 1, &cover );

   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );


   /*
   --- Case: ------------------------------------------------------
   */

   tcase_c ( "Try to find coverage for a transfer SPK." );

   txtopn_ ( (char    *) XFRSPK, 
             (integer *) &unit, 
             (ftnlen   ) strlen(XFRSPK) );

   chckxc_c ( SPICEFALSE, " ", ok );


   dafbt_  ( (char    *) SPK,
             (integer *) &unit,
             (ftnlen   ) strlen(SPK) );

   chckxc_c ( SPICEFALSE, " ", ok );

   ftncls_c ( unit );
   chckxc_c ( SPICEFALSE, " ", ok );

   spkcov_c ( XFRSPK, 1, &cover );
   chckxc_c ( SPICETRUE, "SPICE(INVALIDFORMAT)", ok );


   /*
   --- Case: ------------------------------------------------------
   */

   tcase_c ( "Try to find coverage for a CK." );

   tstck3_c ( CK, SCLK, SPICEFALSE, SPICEFALSE, SPICEFALSE, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );

   spkcov_c ( CK, body[0], &cover );
   chckxc_c ( SPICETRUE, "SPICE(INVALIDFILETYPE)", ok );


   /*
   --- Case: ------------------------------------------------------
   */

   tcase_c ( "Try to find coverage for an EK." );

   tstek_c  ( EK, 0, 20, SPICEFALSE, &handle, ok );
   chckxc_c ( SPICEFALSE, " ", ok );

   spkcov_c ( EK, body[0], &cover );
   chckxc_c ( SPICETRUE, "SPICE(INVALIDARCHTYPE)", ok );


   
   /*
   ******************************************************
   ******************************************************
   ******************************************************
       SPKOBJ tests
   ******************************************************
   ******************************************************
   ******************************************************
   */



   /*
   --- Case: ------------------------------------------------------
   */
   tcase_c ( "Find objects in our test SPK." );

   for ( i = 0;  i < NBOD;  i++  )
   {
      insrti_c ( body[i], &xids );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   spkobj_c ( SPK, &ids );
   chckxc_c ( SPICEFALSE, " ", ok );


   /*
   Check cardinality of coverage window. 
   */
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "card_c(&ids )",   card_c(&ids),   "=",
               card_c(&xids),    0,              ok   );

   /*
   Check coverage window. 
   */

   chckai_c ( "ids", 
              (SpiceInt *)( ids.base ), 
              "=",
              (SpiceInt *)( xids.base ),
              card_c ( &ids ), 
              ok                                  );


   /*
   --- Case: ------------------------------------------------------
   */
   tcase_c ( "Find objects in our test SPK. Start with "
             "a non-empty ID set."                       );


   insrti_c ( -1.e6, &xids );

   for ( i = 0;  i < NBOD;  i++  )
   {
      insrti_c ( body[i], &xids );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   insrti_c ( -1.e6, &ids );

   spkobj_c ( SPK, &ids );
   chckxc_c ( SPICEFALSE, " ", ok );


   /*
   Check cardinality of coverage window. 
   */
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "card_c(&ids )",   card_c(&ids),   "=",
               card_c(&xids),    0,              ok   );

   /*
   Check coverage window. 
   */

   chckai_c ( "ids", 
              (SpiceInt *)( ids.base ), 
              "=",
              (SpiceInt *)( xids.base ),
              card_c ( &ids ), 
              ok                                  );



   /*
   Error cases 
   */

   /*
   --- Case: ------------------------------------------------------
   */

   tcase_c ( "Error:  spkobj_c empty SPK name" );

   spkobj_c ( "", &ids );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );


   /*
   --- Case: ------------------------------------------------------
   */

   tcase_c ( "Error:  spkobj_c null SPK name" );

   spkobj_c ( NULLCPTR, &ids );

   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );


   /*
   --- Case: ------------------------------------------------------
   */

   tcase_c ( "Try to find IDS in a transfer format SPK." );
   spkobj_c ( XFRSPK, &ids );
   chckxc_c ( SPICETRUE, "SPICE(INVALIDFORMAT)", ok ); 


   /*
   --- Case: ------------------------------------------------------
   */

   tcase_c ( "Try to find IDS in a CK." );

   tstck3_c ( CK, SCLK, SPICEFALSE, SPICEFALSE, SPICEFALSE, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );

   spkobj_c ( CK, &ids );
   chckxc_c ( SPICETRUE, "SPICE(INVALIDFILETYPE)", ok );


   /*
   --- Case: ------------------------------------------------------
   */

   tcase_c ( "Try to find IDS in an EK." );

   spkobj_c ( EK, &ids );
   chckxc_c ( SPICETRUE, "SPICE(INVALIDARCHTYPE)", ok );

   /*
   Clean up. 
   */
   remove ( SPK );
   remove ( CK  );
   remove ( EK );
   remove ( XFRSPK );

   t_success_c ( ok );
}
