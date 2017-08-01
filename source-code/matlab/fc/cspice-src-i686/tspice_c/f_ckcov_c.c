/*

-Procedure f_ckcov_c ( Test wrappers for CK coverage routines )


-Abstract

   Perform tests on CSPICE wrappers for the CK  
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
   
   void f_ckcov_c ( SpiceBoolean * ok )

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

      ckcov_c
      ckobj_c

-Examples

   None.

-Restrictions

   None.

-Author_and_Institution

   N.J. Bachman    (JPL)

-Literature_References

   None.

-Version

   -tspice_c Version 1.0.0 04-JAN-2005 (NJB)

-&
*/

{ /* Begin f_ckcov_c */

   /*
   Local macros 
   */


   /*
   Local constants
   */
   #define CK              "ckcov.bc"
   #define EK              "ckcov.bes"
   #define SPK             "ckcov.bsp"
   #define XFRCK           "ckcov.xc"

   #define DELTA            ( 1.e-6  )


   #define FILSIZ           256
   #define LNSIZE           81
   #define LONGLN           241
   #define MAXCOV           2000
   #define MAXDEF           15 
   #define MAXREC           200
   #define NBOD             3
   #define NINS             5
   #define NRCASE           3
   #define SIDLEN           41
   #define WINSIZ           ( 2 * MAXCOV )

   /*
   These parameters are from the SPICELIB include file ck05.inc:
   */
   #define C05PS0           8
   #define C05PS1           4
   #define C05PS2           14
   #define C05PS3           7

   #define MAXPKT           C05PS2


   /*
   Local variables
   */

   /*
   Local static variables
   */

   SPICEDOUBLE_CELL      ( cover,   WINSIZ );
   SPICEDOUBLE_CELL      ( tmpwin,  WINSIZ );

   SPICEDOUBLE_CELL      ( xavint0, WINSIZ );
   SPICEDOUBLE_CELL      ( xavint1, WINSIZ );
   SPICEDOUBLE_CELL      ( xavint2, WINSIZ );
   SPICEDOUBLE_CELL      ( xavint3, WINSIZ );
   SPICEDOUBLE_CELL      ( xavint4, WINSIZ );

   SPICEDOUBLE_CELL      ( xavseg0, WINSIZ );
   SPICEDOUBLE_CELL      ( xavseg1, WINSIZ );
   SPICEDOUBLE_CELL      ( xavseg2, WINSIZ );
   SPICEDOUBLE_CELL      ( xavseg3, WINSIZ );
   SPICEDOUBLE_CELL      ( xavseg4, WINSIZ );

   SPICEDOUBLE_CELL      ( xcvint0, WINSIZ );
   SPICEDOUBLE_CELL      ( xcvint1, WINSIZ );
   SPICEDOUBLE_CELL      ( xcvint2, WINSIZ );
   SPICEDOUBLE_CELL      ( xcvint3, WINSIZ );
   SPICEDOUBLE_CELL      ( xcvint4, WINSIZ );

   SPICEDOUBLE_CELL      ( xcvseg0, WINSIZ );
   SPICEDOUBLE_CELL      ( xcvseg1, WINSIZ );
   SPICEDOUBLE_CELL      ( xcvseg2, WINSIZ );
   SPICEDOUBLE_CELL      ( xcvseg3, WINSIZ );
   SPICEDOUBLE_CELL      ( xcvseg4, WINSIZ );

   SPICEINT_CELL         ( ids,     (NINS+1) );
   SPICEINT_CELL         ( xids,    (NINS+1) );


   /*
   The following arrays of pointers to cells play the roles
   of the arrays of cells

       XAVINT
       XAVSEG
       XCVINT
       XCVSEG

   in 

       F_CKCOV
   */

   static SpiceCell      * xavint [ NINS ] =
                           {
                              &xavint0, &xavint1, &xavint2, 
                              &xavint3, &xavint4
                           };
   
   static SpiceCell      * xavseg [ NINS ] =
                           {
                              &xavseg0, &xavseg1, &xavseg2, 
                              &xavseg3, &xavseg4
                           };

   static SpiceCell      * xcvint [ NINS ] =
                           {
                              &xcvint0, &xcvint1, &xcvint2, 
                              &xcvint3, &xcvint4
                           };
   
   static SpiceCell      * xcvseg [ NINS ] =
                           {
                              &xcvseg0, &xcvseg1, &xcvseg2, 
                              &xcvseg3, &xcvseg4
                           };


   static SpiceDouble      z [ 3 ] =
                           {
                              0.0,  0.0,  1.0
                           };


   static SpiceInt         inst [ NINS ] =
                           {
                              -1000, -2000, -3000, -4000, -5000
                           };


   static SpiceInt         nseg   [ NINS ] =
                           {
                              3,    3,     4,     4,     4
                           };

   static SpiceInt         nr     [ NRCASE ] =
                           {
                              4,    99,    199
                           };

   static SpiceInt         ivln   [ NRCASE ] =
                           {
                              4,    3,     7 
                           };

   static SpiceInt         pksize [ 4 ] =
                           {
                              C05PS0, C05PS1, C05PS2, C05PS3
                           };

   static SpiceInt         tikper [ NINS ] =
                           {
                              2,    4,     8,    16,    32
                           };

   /*
   Automatic local variables
   */
   SpiceBoolean            useav;

   SpiceChar               cvstat   [ LNSIZE ];
   SpiceChar               deftxt   [ MAXDEF ][ LNSIZE ];
   SpiceChar               segid    [ SIDLEN ];
   SpiceChar               title    [ LONGLN ];


   SpiceDouble             angle;
   SpiceDouble             avvs     [ MAXREC ][3];
   SpiceDouble             cmat     [ 3 ][ 3 ];
   SpiceDouble             dval;
   SpiceDouble             ends     [ MAXREC ];
   SpiceDouble             epochs   [ MAXREC ];
   SpiceDouble             et;
   SpiceDouble             first;
   SpiceDouble             last;
   SpiceDouble             packet   [ MAXPKT ];
   SpiceDouble             pkts     [ MAXREC * MAXPKT ];
   SpiceDouble             quats    [ MAXREC ] [4];
   SpiceDouble             rate;
   SpiceDouble             rates    [ MAXREC ];
   SpiceDouble             starts   [ MAXREC ];
   SpiceDouble             t3end;
   SpiceDouble             tol;

   SpiceInt                clkid    [ NINS ];
   SpiceInt                defsiz;
   SpiceInt                degree;
   SpiceInt                dtype;
   SpiceInt                handle;
   SpiceInt                i;
   SpiceInt                j;
   SpiceInt                k;
   SpiceInt                l;
   SpiceInt                m;
   SpiceInt                nintvl;
   SpiceInt                nrec;
   SpiceInt                nstart;
   SpiceInt                pktsiz;
   SpiceInt                subtyp;
   SpiceInt                xunit;






   topen_c ( "f_ckcov_c" );


   /*
   --- Case: ------------------------------------------------------
   */

   tcase_c ( "Setup: create and load SCLK definitions "
             "for each instrument."                     );

   for ( i = 0;  i < NINS;  i++  )
   {
      clkid[i] = inst[i] / 1000;

      strcpy( deftxt[0], "SCLK_KERNEL_ID         = ( @03-JAN-2005/02:03 )" );
      strcpy( deftxt[1], "SCLK_DATA_TYPE_#       = ( 1 )" );
      strcpy( deftxt[2], "SCLK01_TIME_SYSTEM_#   = ( 2 )" );
      strcpy( deftxt[3], "SCLK01_N_FIELDS_#      = ( 2 )" );
      strcpy( deftxt[4], "SCLK01_MODULI_#        = ( 4294967296 256 )" );
      strcpy( deftxt[5], "SCLK01_OFFSETS_#       = ( 0          0   )" );
      strcpy( deftxt[6], "SCLK01_OUTPUT_DELIM_#  = ( 1 )" );
      strcpy( deftxt[7], "SCLK_PARTITION_START_# = ( 0 )" );
      strcpy( deftxt[8], "SCLK_PARTITION_END_#   = ( 1.0995116277750E+12 )" );
      strcpy( deftxt[9], "SCLK01_COEFFICIENTS_#  = ( 0  0  1 )" );

      defsiz = 10;

      for ( j = 0;  j < defsiz;  j++  )
      {
         repmi_c  ( deftxt[j], "#", -clkid[i], LNSIZE, deftxt[j] );
         chckxc_c ( SPICEFALSE, " ", ok );       
      }

      lmpool_c ( deftxt, LNSIZE, defsiz );
      chckxc_c ( SPICEFALSE, " ", ok );  
   }

   /*
   We'll need a leapseconds kernel too.
   */
   tstlsk_c();
   chckxc_c ( SPICEFALSE, " ", ok );     


   /*
   --- Case: ------------------------------------------------------
   */

   tcase_c ( "Setup: create CK file." );


   /*
   Create a CK file with data for five objects.
   */
   ckopn_c ( CK, CK, 0, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   Initializations to make compilers happy.
   */
   first = 0.0;
   last  = 0.0;
   t3end = 0.0;

   /*
   For each instrument, we'll create a sequence of segments. Because
   we have CKCOV code (in some cases, the code resides in supporting
   utilities) unique to each data type, we'll create segments of all
   data types:  all of the segments for the Ith instrument will of
   data type I+1.  Characteristics of the segments such as presence of
   angular velocity, spacing of epochs and interpolation intervals,
   spacing of segments, and time ordering of segments relative to
   each other will vary.
   */
 
   for ( i = 0;  i < NINS;  i++  )
   {
      for ( j = 0;  j < nseg[i];  j++  )
      {
         /*
         Create segments for instrument i.  All segments for
         instrument i will use data type i+1.
         */
         dtype = i+1;
         
         /*
         The number of records in the jth segment for instrument
         I will cycle through the values of nr.
         */
         k     =  j % 3;
         nrec  =  nr [ k ];

         /*
         The number of pointing records per interpolation interval
         cycles through the values of ivln ( "Interval length" ).
         */
         nintvl = ivln [ k ];

         /*
         The flag useav indicates how the angular velocity flag
         will be set.  Even-indexed segments get angular velocity.
         */
         useav = even_ ( &j );

         /*
         Proceed to create the jth segment for instrument i.
         The following code is data-type dependent. 
         */
         if ( dtype == 1 )
         {
            /*
            This is the CK type 1 case.

            The segments we create will be separated by a 3 tick gap.
            Records will be 3*(j+1) ticks apart.

            Set segment start and epochs.
            */
            if ( j == 0  )
            {
               first = 0.0; 
            }
            else
            {
               /*
               last is left over from the previous j-loop iteration.
               */
               first = last + 3.0;
            }

            /*
            Set epochs, quats, and avvs.

            Pointing data are not relevant for these tests,
            but having distinct entries could be helpful for
            debugging.  The kth entry will be a frame rotation
            by k+1 milliradians about the Z-axis.
            */
            for ( k = 0;  k < nrec;  k++  )
            {
               /*
               As stated above, records will be 3*(j+1) ticks apart.
               */
               epochs[k] =  first + ( 3.0 * (j+1) * (k+1) );

               /*
               The angle required by axisar_c is the negative of
               the frame rotation angle.
               */
               angle  =  - ( (k+1) * 1.e-3 );

               axisar_c ( z, angle, cmat );
               chckxc_c ( SPICEFALSE, " ", ok );

               m2q_c    ( cmat, quats[k] );
               chckxc_c ( SPICEFALSE, " ", ok );

               /*
               Set angular velocity to be consistent with
               the rotation data.  Remember angular velocity
               units are radians/sec, so we must multiply
               radians/tick by ticks/second for instrument i.
               */
               vscl_c ( tikper[i] * angle / (3*(j+1)),  z,  avvs[k] );
            }

            /*
            Set segment end time.
            */
            last = epochs[nrec-1];

            /*
            Add the segment's coverage interval to our segment-level
            expected coverage window for the Ith instrument.
            */
            wninsd_c ( first, last, xcvseg[i] );
            chckxc_c ( SPICEFALSE, " ", ok );

            /*
            If we're providing angular velocity for this segment,
            then this segment contributes to the coverage window
            for the angular-velocity only segments at the interval
            level.
            */
            if ( useav )
            {
               wninsd_c ( first, last, xavseg[i] ); 
               chckxc_c ( SPICEFALSE, " ", ok );
            }

            /*
            The singleton intervals defined by the pointing epochs
            act as interpolation intervals for type 1 segments.
            Add the interpolation intervals to our interval-level
            expected coverage window for the Ith instrument.
            */
            for ( k = 0;  k < nrec;  k++  )
            {
               wninsd_c ( epochs[k],  epochs[k],  xcvint[i] );
               chckxc_c ( SPICEFALSE, " ", ok );
            }


            /*
            If we're providing angular velocity for this segment,
            then this segment contributes to the coverage window
            for the angular-velocity only segments at the interval
            level.
            */
            if ( useav )
            {
               for ( k = 0;  k < nrec;  k++  )
               {
                  wninsd_c ( epochs[k],  epochs[k],  xavint[i] );
                  chckxc_c ( SPICEFALSE, " ", ok );
               }
            }

            /*
            Create segment ID.
            */
            strcpy   ( segid , "Segment # for instrument #." );

            repmi_c  ( segid, "#", j, SIDLEN, segid );
            repmi_c  ( segid, "#", i, SIDLEN, segid );
            chckxc_c ( SPICEFALSE, " ", ok );


            /*
            Write the current segment to our CK.
            */
            ckw01_c ( handle,    first,  last,   inst[i],
                      "J2000",   useav,  segid,  nrec, 
                      epochs,    quats,  avvs            );

            chckxc_c ( SPICEFALSE, " ", ok );

         }

         else if ( dtype == 2 )
         {
            /*
            This is the CK type 2 case.

            For type 2, angular velocity is present by definition.
            */
            useav = SPICETRUE;

            /*
            We're going to copy the data for the type 1 case, but
            here, the segments we create will abut each other.
            Records will be 2*J ticks apart.

            Set segment start and epochs.
            */
            if ( j == 0 )
            {
               first = 0.0;
            }
            else
            {
               /*
               last is left over from the previous j-loop iteration.
               */
               first = last;    
            }


            /*
            Set epochs, quats, and avvs.

            Pointing data are not relevant for these tests,
            but having distinct entries could be helpful for
            debugging.  The Kth entry will be a frame rotation
            by K milliradians about the Z-axis.
            */
            for ( k = 0;  k < nrec;  k++ )
            {
               /*
               As stated above, records will be 2*(j+1) ticks apart.
               */
               epochs[k] =  first + ( k * (j+1) * 2.0 );

               /*
               Each interpolation interval will be 1 tick long.
               */
               ends[k]   =  epochs[k] + 1.0;


               /*
               The angle required by axisar_c is the negative of
               the frame rotation angle.
               */
               angle  =  - ( (k+1) * 1.e-3 );

               axisar_c ( z, angle, cmat );
               chckxc_c ( SPICEFALSE, " ", ok );

               m2q_c    ( cmat, quats[k] );
               chckxc_c ( SPICEFALSE, " ", ok );

               /*
               Set angular velocity to be consistent with
               the rotation data.  Remember angular velocity
               units are radians/sec, so we must multiply
               radians/tick by ticks/second for instrument I.
               */
               vscl_c ( tikper[i] * angle /(2*(j+1)), z, avvs[k] );

               /*
               Set the clock rate in seconds per tick for the
               Kth interpolation interval.
               */
               rates[k] =  1.0 / tikper[i];

            }

            /*
            Set segment end time.  Note that this is the end of
            the last interpolation interval.
            */
            last = ends[nrec-1];

            /*
            Add the segment's coverage interval to our segment-level
            expected coverage window for the Ith instrument.
            */
            wninsd_c ( first, last, xcvseg[i] );
            chckxc_c ( SPICEFALSE, " ", ok );

            /*
            Since we're providing angular velocity for this segment,
            then this segment contributes to the coverage window
            for the angular-velocity only segments at the interval
            level.
            */
            wninsd_c ( first, last, xavseg[i] );
            chckxc_c ( SPICEFALSE, " ", ok );

            /*
            Add the interpolation intervals to our interval-level
            expected coverage windows for the ith instrument.
            */
            for ( k = 0;  k < nrec;  k++  )
            {
               wninsd_c ( epochs[k],  ends[k],  xcvint[i] );
               wninsd_c ( epochs[k],  ends[k],  xavint[i] );
               chckxc_c ( SPICEFALSE, " ", ok );
            }

            /*
            Create segment ID.
            */
            strcpy   ( segid , "Segment # for instrument #." );

            repmi_c  ( segid, "#", j, SIDLEN, segid );
            repmi_c  ( segid, "#", i, SIDLEN, segid );
            chckxc_c ( SPICEFALSE, " ", ok );


            /*
            Write the current segment to our CK.
            */
            ckw02_c ( handle,   first,  last,  inst[i],
                      "J2000",  segid,  nrec,  epochs,
                      ends,     quats,  avvs,  rates   );

            chckxc_c ( SPICEFALSE, " ", ok );
           
         }
         else if ( dtype == 3 )
         {
            /*
            This is the CK type 3 case.

            The segments we create will be separated by a 3 tick gap.
            Records will be (j+1) ticks apart.

            Set segment start and epochs.
            */
            if ( j == 0 )
            {
               first = 0.0;
            }
            else
            {
               /*
               last is left over from the previous j-loop iteration.
               */
               first = last + 3.0;
            }

            /*
            Set epochs, quats, and avvs.

            Pointing data are not relevant for these tests,
            but having distinct entries could be helpful for
            debugging.  The Kth entry will be a frame rotation
            by K milliradians about the Z-axis.
            */
            for ( k = 0;  k < nrec;  k++ )
            {
               /*
               As stated above, records will be j+1 ticks apart.
               */
               epochs[k] =  first  +  k * (j+1);

               /*
               The angle required by axisar_c is the negative of
               the frame rotation angle.
               */
               angle  =  - ( (k+1) * 1.e-3 );

               axisar_c ( z, angle, cmat );
               chckxc_c ( SPICEFALSE, " ", ok );

               m2q_c    ( cmat, quats[k] );
               chckxc_c ( SPICEFALSE, " ", ok );

               /*
               Set angular velocity to be consistent with
               the rotation data.  Remember angular velocity
               units are radians/sec, so we must multiply
               radians/tick by ticks/second for instrument i.
               */
               vscl_c ( tikper[i] * angle / (j+1),  z,  avvs[k] );
            }

            /*
            Set segment end time.
            */
            last = epochs[nrec-1];

            /*
            Add the segment's coverage interval to our segment-level
            expected coverage window for the Ith instrument.
            */
            wninsd_c ( first, last, xcvseg[i] );
            chckxc_c ( SPICEFALSE, " ", ok );

            /*
            If we're providing angular velocity for this segment,
            then this segment contributes to the coverage window
            for the angular-velocity only segments at the interval
            level.
            */
            if ( useav )
            {
               wninsd_c ( first, last, xavseg[i] ); 
               chckxc_c ( SPICEFALSE, " ", ok );
            }

            /*
            Set the interval start times.  The first epoch
            is always the start of an interpolation interval
            in these tests.  Each interval has length nintvl
            records.
            */

            for ( k = 0,  l = 0;   k < nrec;   k += nintvl+1,  l++ )
            {
               /*
               Set the start time.
               */
               starts[l] = epochs[k];

               /*
               Keep track of the interval end times.
               */
               if ( l > 0 ) 
               {
                  /*
                  Record the end time of the previous interval.
                  */
                  ends[l-1] = epochs[k-1];
               }
            }

            /*
            Set the interpolation interval count.
            */
            nstart = l;

            /*
            The end time of the last interval is (in this test)
            always the last epoch.
            */
            ends[nstart-1] = epochs[nrec-1];

            /*
            Add the interpolation intervals to our interval-level
            expected coverage window for the Ith instrument.
            */
            for ( k = 0;  k < nstart;  k++ )
            {
               wninsd_c ( starts[k], ends[k], xcvint[i] );
               chckxc_c ( SPICEFALSE, " ", ok );
            }

            /*
            If we're providing angular velocity for this segment,
            then this segment contributes to the coverage window
            for the angular-velocity only segments at the interval
            level.
            */
            if ( useav )
            {
               for ( k = 0;  k < nstart;  k++ )
               {
                  wninsd_c ( starts[k], ends[k], xavint[i] );
                  chckxc_c ( SPICEFALSE, " ", ok );
               }
            }

            /*
            Create segment ID.
            */
            strcpy   ( segid , "Segment # for instrument #." );

            repmi_c  ( segid, "#", j, SIDLEN, segid );
            repmi_c  ( segid, "#", i, SIDLEN, segid );
            chckxc_c ( SPICEFALSE, " ", ok );

            /*
            Write the current segment to our CK.
            */
            ckw03_c ( handle,   first,  last,   inst[i],        
                      "J2000",  useav,  segid,  nrec,            
                      epochs,   quats,  avvs,   nstart,  starts );

            chckxc_c ( SPICEFALSE, " ", ok );


            /*
            If this is the last type 3 segment, save the end
            time of the segment.
            */
            if ( j == nseg[3]-1 ) 
            {
               t3end = last;
            }

         }

         else if ( dtype == 4 )
         {
            /*
            This is the CK type 4 case.

            The segments we create will be separated by a 3 tick gap.
            Records will be (j+1) ticks apart.

            Set segment start and epochs.
            */
            if ( j == 0 )
            {
               first = 0.0;
            }
            else
            {
               /*
               last is left over from the previous j-loop iteration.
               */
               first = last + 3.0;
            }

            /*
            Create segment ID.
            */
            strcpy   ( segid , "Segment # for instrument #." );

            repmi_c  ( segid, "#", j, SIDLEN, segid );
            repmi_c  ( segid, "#", i, SIDLEN, segid );
            chckxc_c ( SPICEFALSE, " ", ok );

            /*
            Begin the segment.
            */
            ckw04b_ ( ( integer    * ) &handle,
                      ( doublereal * ) &first,
                      ( integer    * ) inst+i,
                      ( char       * ) "J2000",
                      ( logical    * ) &useav,
                      ( char       * ) segid,
                      ( ftnlen       ) strlen ( "J2000" ),
                      ( ftnlen       ) strlen ( segid   )  );

            chckxc_c ( SPICEFALSE, " ", ok );

            /*
            Define the start epochs for the packets.
            */
            for ( k = 0;  k < nrec;  k++ )
            {
               /*
               Packet starts will be 1000*(j+1) ticks apart.
               */
               epochs[k] =  first  +  k * (j+1) * 1000;
            }

            /*
            The segment end time matches the end time of the last
            packet.
            */
            last = epochs[nrec-1];

            /*
            Define the data packets for the current segment;
            add each one to the segment.
            */
            for ( k = 0;  k < nrec;  k++ )
            {
               /*
               Fill in the current packet.  The packet structure
               is as follows:

                 ----------------------------------------------------
                 | The midpoint of the approximation interval       |
                 ----------------------------------------------------
                 | The radius of the approximation interval         |
                 ----------------------------------------------------
                 | Number of coefficients for q0                    |
                 ----------------------------------------------------
                 | Number of coefficients for q1                    |
                 ----------------------------------------------------
                 | Number of coefficients for q2                    |
                 ----------------------------------------------------
                 | Number of coefficients for q3                    |
                 ----------------------------------------------------
                 | Number of coefficients for AV1                   |
                 ----------------------------------------------------
                 | Number of coefficients for AV2                   |
                 ----------------------------------------------------
                 | Number of coefficients for AV3                   |
                 ----------------------------------------------------
                 | q0 Cheby coefficients                            |
                 ----------------------------------------------------
                 | q1 Cheby coefficients                            |
                 ----------------------------------------------------
                 | q2 Cheby coefficients                            |
                 ----------------------------------------------------
                 | q3 Cheby coefficients                            |
                 ----------------------------------------------------
                 | AV1 Cheby coefficients (optional)                |
                 ----------------------------------------------------
                 | AV2 Cheby coefficients (optional)                |
                 ----------------------------------------------------
                 | AV3 Cheby coefficients (optional)                |
                 ----------------------------------------------------

               The interval radius will be 499 ticks.  This will
               put the intervals two ticks apart.

               The interval midpoint will be at the start time
               plus 499 ticks.
               */
               pkts[0] = 499.0 + epochs[k];
               pkts[1] = 499.0;

               /*
               Our quaternions will be constant.
               */
               pkts[2] = 1;
               pkts[3] = 1;
               pkts[4] = 1;
               pkts[5] = 1;

               /*
               Angular velocity will be constant at 0.
               */
               pkts[6] = 1;
               pkts[7] = 1;
               pkts[8] = 1;

               /*
               Cheby coefficients for the quaternion elements:
               */
               pkts[9 ] = 1.0;
               pkts[10] = 2.0;
               pkts[11] = 3.0;
               pkts[12] = 4.0;

               /*
               Cheby coefficients for the angular velocity elements:
               */
               pkts[13] = 0.0;
               pkts[14] = 0.0;
               pkts[15] = 0.0;

               /*
               The packet size depends on whether we're using
               angular velocity in this segment.
               */
               if ( useav )
               {
                  pktsiz = 16;
               }
               else
               {
                  pktsiz = 13;
               }

               /*
               Add the current packet.
               */
               l = 1;

               ckw04a_ ( ( integer    * ) &handle,
                         ( integer    * ) &l,
                         ( integer    * ) &pktsiz,
                         ( doublereal * ) pkts,
                         ( doublereal * ) epochs+k  );

               chckxc_c ( SPICEFALSE, " ", ok );

               /*
               Add the interpolation interval to our interval-level
               expected coverage window for the Ith instrument.
               */
               wninsd_c ( epochs[k], epochs[k]+2*pkts[1], xcvint[i] );
               chckxc_c ( SPICEFALSE, " ", ok );

               /*
               If we're providing angular velocity for this segment,
               then this segment contributes to the coverage window
               for the angular-velocity only segments at the interval
               level.
               */
               if ( useav )
               {
                  wninsd_c ( epochs[k], epochs[k]+2*pkts[1], xavint[i] );
                  chckxc_c ( SPICEFALSE, " ", ok );
               }
            }

            /*
            End the segment.
            */
            ckw04e_ ( &handle, &last );
            chckxc_c ( SPICEFALSE, " ", ok );

            /*
            Add the segment's coverage interval to our segment-level
            expected coverage window for the Ith instrument.
            */
            wninsd_c ( first, last, xcvseg[i] );
            chckxc_c ( SPICEFALSE, " ", ok );

            /*
            If we're providing angular velocity for this segment,
            then this segment contributes to the coverage window
            for the angular-velocity only segments at the interval
            level.
            */
            if ( useav )
            {
               wninsd_c ( first, last, xavseg[i] );
               chckxc_c ( SPICEFALSE, " ", ok );
            }       
         }

         else if ( dtype == 5 )
         {
            /*
            This is the CK type 5 case.

            Set type 5 subtype.  We expect nseg[4] == 4.
            */
            if ( nseg[4] != 4 )
            {
               setmsg_c ( "Test cases for CK type 5 segments " 
                          "use a different type 5 subtype for "
                          "each segment.  The Ith segment is "
                          "mapped to subtype I.  Subtype "  
                          "numbers range from 0 to 3. nseg[4] "
                          "was expected to be 4 but was #."    );
               errint_c ( "#", nseg[4]                         );
               sigerr_c ( "SPICE(BUG)"                         );
               chckxc_c ( SPICEFALSE, " ", ok                  );
            }

            subtyp = j;

            /*
            Set packet size.
            */
            pktsiz = pksize[subtyp];


            /*
            We'll mimic the construction of the type 3 segments,
            but we'll put the segments in reverse time order
            relative to each other.

            t3end is supposed to have been initialized before
            we get here.

            We'll use m as a complementary index with respect to
            j and nseg[i]:
            */
            m  =  nseg[i] - 1 - j;

            /*
            We must set nrec and useav specially for this
            "backward" segment order.
            */
            k      =  m % 3;

            nrec   =  nr [k];

            useav  =  even_ ( &m );

            /*
            So m will start at nseg[i]-1 and count down to 0.

            The segments we create will be separated by a 3 tick gap.
            Records will be m+1 ticks apart.

            Set segment end and epochs.
            */
            if ( m == nseg[i] )
            {
               last = t3end;
            }
            else
            {
               /*
               first is left over from the previous m-loop iteration.
               */
               last = first - 3.0;
            }

            /*
            Set epochs, quats, and avvs.

            Pointing data are not relevant for these tests,
            but having distinct entries could be helpful for
            debugging.  The kth entry will be a frame rotation
            by k+1 milliradians about the Z-axis.
            */
            for ( k = nrec-1;  k > -1;  k-- )
            {
               /*
               As stated above, records will be m+1 ticks apart.
               */
               epochs[k] =  last -   (m+1) * ( nrec - 1 - k );


               /*
               The angle required by axisar_c is the negative of
               the frame rotation angle.
               */
               angle  =  - ( (k+1) * 1.e-3 );

               axisar_c ( z, angle, cmat );
               chckxc_c ( SPICEFALSE, " ", ok );

               m2q_c    ( cmat, quats[k] );
               chckxc_c ( SPICEFALSE, " ", ok );

               /*
               Set angular velocity to be consistent with
               the rotation data.  Remember angular velocity
               units are radians/sec, so we must multiply
               radians/tick by ticks/second for instrument i.
               */
               vscl_c ( tikper[i] * angle / (m+1),  z,  avvs[k] );
               chckxc_c ( SPICEFALSE, " ", ok );


               /*
               Set packet contents.
               */
               l = MAXPKT;

               cleard_ ( (integer    *) &l,  
                         (doublereal *) &packet  );

               if ( subtyp == 0 )
               {
                  /*
                  Packets contain quaternions and quaternion
                  derivatives.  We've already set the derivatives to zero.
                  */              
                  MOVED ( quats[k], 4, packet );
               }

               else if ( subtyp == 1 )
               {
                  /*
                  Packets contain quaternions only.
                  */
                  MOVED ( quats[k], 4, packet );
               }

               else if ( subtyp == 2 )
               {
                  /*
                  Packets contain quaternions, quaternion derivatives,
                  angular velocity, and angular velocity derivatives.
                  We've already set the derivatives to zero (even
                  though this makes the angular velocity and quaternion
                  derivatives incompatible---subtype 2 is meant to
                  handle this).
                  */
                  MOVED ( quats[k], 4, packet   );
                  MOVED ( avvs [k], 3, packet+8 );
               }

               else if ( subtyp == 3 )
               {
                  /*
                  Packets contain quaternions and angular velocity.
                  */
                  MOVED ( quats[k], 4, packet   );
                  MOVED ( avvs [k], 3, packet+4 );
               }

               /*
               Insert packet into packet array.
               */
               l  =  k * pktsiz;

               MOVED ( packet, pktsiz, pkts+l );
            }

            /*
            Set segment start time.
            */
            first = epochs[0];

            /*
            Add the segment's coverage interval to our segment-level
            expected coverage window for the Ith instrument.
            */
            wninsd_c ( first, last, xcvseg[i] );
            chckxc_c ( SPICEFALSE, " ", ok );

            /*
            If we're providing angular velocity for this segment,
            then this segment contributes to the coverage window
            for the angular-velocity only segments at the interval
            level.
            */
            if ( useav ) 
            {
               wninsd_c ( first, last, xavseg[i] );
               chckxc_c ( SPICEFALSE, " ", ok );
            }

            /*
            Set the interval start times.  The first epoch
            is always the start of an interpolation interval
            in these tests.  Each interval has length NINTVL
            records.
            */

            for ( k = 0,  l = 0;   k < nrec;   k += nintvl+1,  l++ )
            {
               /*
               Set the start time.
               */
               starts[l] = epochs[k];

               /*
               Keep track of the interval end times.
               */
               if ( l > 0 ) 
               {
                  /*
                  Record the end time of the previous interval.
                  */
                  ends[l-1] = epochs[k-1];
               }
            }

            /*
            Set the interpolation interval count.
            */
            nstart = l;

            /*
            The end time of the last interval is (in this test)
            always the last epoch.
            */
            ends[nstart-1] = epochs[nrec-1];

            /*
            Add the interpolation intervals to our interval-level
            expected coverage window for the Ith instrument.
            */
            for ( k = 0;  k < nstart;  k++ )
            {
               wninsd_c ( starts[k], ends[k], xcvint[i] );
               chckxc_c ( SPICEFALSE, " ", ok );
            }

            /*
            If we're providing angular velocity for this segment,
            then this segment contributes to the coverage window
            for the angular-velocity only segments at the interval
            level.
            */
            if ( useav )
            {
               for ( k = 0;  k < nstart;  k++ )
               {
                  wninsd_c ( starts[k], ends[k], xavint[i] );
                  chckxc_c ( SPICEFALSE, " ", ok );
               }
            }

            /*
            Create segment ID.
            */
            strcpy   ( segid , "Segment # for instrument #." );

            repmi_c  ( segid, "#", j, SIDLEN, segid );
            repmi_c  ( segid, "#", i, SIDLEN, segid );
            chckxc_c ( SPICEFALSE, " ", ok );


            /*
            Write the current segment to our CK.  All interpolating
            polynomials will be cubic.
            */
            degree = 3;
            rate   = 1.0 / tikper[i];

            ckw05_c ( handle,   subtyp,   degree, first,  last,   
                      inst[i],  "J2000",  useav,  segid,  nrec, 
                      epochs,   pkts,     rate,   nstart, starts );
         }
         else
         {
            /*
            Oops.
            */
            sigerr_c ( "spice(bug)" );

            chckxc_c ( SPICEFALSE, " ", ok );
         }


      }

   }

   ckcls_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );




 
   /*
   ******************************************************
   ******************************************************
   ******************************************************
       ckcov_c tests
   ******************************************************
   ******************************************************
   ******************************************************
   */


   /*
   We've written the CK.  It's time to check out CKCOV.


   Check actual vs expected coverage as we vary the input
   arguments to CKCOV.


   Each test we do will be performed with both an empty
   and non-empty input coverage window.
   */
   for ( l = 0;  l < 2;  l++ )
   {
      /*
      We'll start out by testing the coverage summary at the
      segment level.
      */
      if ( l == 0 )
      {
         /*
         We'll set cover to be empty on input to ckcov_c.
         */
         scard_c ( 0, &cover );

         strcpy ( cvstat, "empty"  );
      }
      else
      {
         strcpy ( cvstat, "non-empty"  );
      }

      for ( i = 0;  i < NINS;  i++ )
      {

         /*
         --- Case: ------------------------------------------------------
         */

         sprintf ( title,
                   "Check segment-level "                       
                   "coverage for instrument %ld; COVER starts "    
                   "out %s. Angular velocity not needed. "       
                   "TOL = 0.D0.",
                   i,
                   cvstat                                    );

         tcase_c ( title );


         /*
         Initialize COVER.
         */
         scard_c ( 0,  &cover );
         chckxc_c ( SPICEFALSE, " ", ok );

         /*
         Make a copy of the expected window.
         */
         copy_c ( xcvseg[i],  &tmpwin );

         if ( l == 1  )
         {
            /*
            Insert an interval into COVER.  This same interval
            must be added to each window containing expected
            coverage.
            */
            wninsd_c ( 1.e6, 1.e7, &cover );
            chckxc_c ( SPICEFALSE, " ", ok );

            /*
            The same interval is expected to appear in the output.
            */
            wninsd_c ( 1.e6, 1.e7, &tmpwin );
            chckxc_c ( SPICEFALSE, " ", ok );
         }


         ckcov_c ( CK,   inst[i],  SPICEFALSE, "segment",
                   0.0,  "sclk",   &cover                );
         chckxc_c ( SPICEFALSE, " ", ok );


         /*
         Check cardinality of coverage window.
         */
         chcksi_c ( "card_c(&cover)", card_c(&cover), 
                    "=",              card_c(&tmpwin),  0,  ok  );
                   
         /*
         Check coverage window.
         */
         chckad_c ( "cover",  cover.data, 
                    "=",      tmpwin.data,  card_c(&cover),  0,  ok  );
      }

   

      for ( i = 0;  i < NINS;  i++ )
      {

         /*
         --- Case: ------------------------------------------------------
         */

         sprintf ( title,
                   "INST: %ld;  LEVEL: SEGMENT;  NEEDAV: TRUE; "
                   "TIMSYS: SCLK; TOL: 0.D0; COVER starts out %s",
                   i,
                   cvstat                                        );

         tcase_c ( title );


         /*
         Initialize COVER.
         */
         scard_c ( 0,  &cover );
         chckxc_c ( SPICEFALSE, " ", ok );

         /*
         Make a copy of the expected window.
         */
         copy_c ( xavseg[i],  &tmpwin );

         if ( l == 1  )
         {
            /*
            Insert an interval into COVER.  This same interval
            must be added to each window containing expected
            coverage.
            */
            wninsd_c ( 1.e6, 1.e7, &cover );
            chckxc_c ( SPICEFALSE, " ", ok );

            /*
            The same interval is expected to appear in the output.
            */
            wninsd_c ( 1.e6, 1.e7, &tmpwin );
            chckxc_c ( SPICEFALSE, " ", ok );
         }


         ckcov_c ( CK,   inst[i],  SPICETRUE, "segment",
                   0.0,  "sclk",   &cover                );
         chckxc_c ( SPICEFALSE, " ", ok );


         /*
         Check cardinality of coverage window.
         */
         chcksi_c ( "card_c(&cover)", card_c(&cover), 
                    "=",              card_c(&tmpwin),  0,  ok  );
                   
         /*
         Check coverage window.
         */
         chckad_c ( "cover",  cover.data, 
                    "=",      tmpwin.data,  card_c(&cover),  0,  ok  );
      }
   



      for ( i = 0;  i < NINS;  i++ )
      {

         /*
         --- Case: ------------------------------------------------------
         */

         sprintf ( title,
                   "INST: %ld;  LEVEL: SEGMENT;  NEEDAV: FALSE; "
                   "TIMSYS: SCLK; TOL: 1.D0; COVER starts out %s",
                   i,
                   cvstat                                        );

         tcase_c ( title );


         /*
         Initialize COVER.
         */
         scard_c ( 0,  &cover );
         chckxc_c ( SPICEFALSE, " ", ok );

         /*
         Adjust our expected result window by tol.
         */
         copy_c ( xcvseg[i],  &tmpwin );

         tol = 1.0;

         wnexpd_c ( tol, tol, &tmpwin );

         /*
         Make sure the window doesn't start with a negative tick
         value.  Set the first element of tmpwin to the maximum
         of this element and 0.
         */
         dval  = maxd_c ( 2,  0.0,  SPICE_CELL_ELEM_D(&tmpwin, 0 ) );

         SPICE_CELL_SET_D ( dval, 0, &tmpwin );


         if ( l == 1  )
         {
            /*
            Insert an interval into COVER.  This same interval
            must be added to each window containing expected
            coverage.
            */
            wninsd_c ( 1.e6, 1.e7, &cover );
            chckxc_c ( SPICEFALSE, " ", ok );

            /*
            The same interval is expected to appear in the output.
            */
            wninsd_c ( 1.e6, 1.e7, &tmpwin );
            chckxc_c ( SPICEFALSE, " ", ok );
         }


         ckcov_c ( CK,   inst[i],  SPICEFALSE, "segment",
                   tol,  "sclk",   &cover                );
         chckxc_c ( SPICEFALSE, " ", ok );


         /*
         Check cardinality of coverage window.
         */
         chcksi_c ( "card_c(&cover)", card_c(&cover), 
                    "=",              card_c(&tmpwin),  0,  ok  );
                   
         /*
         Check coverage window.
         */
         chckad_c ( "cover",  cover.data, 
                    "=",      tmpwin.data,  card_c(&cover),  0,  ok  );
      }



      for ( i = 0;  i < NINS;  i++ )
      {

         /*
         --- Case: ------------------------------------------------------
         */

         sprintf ( title,
                   "INST: %ld;  LEVEL: SEGMENT;  NEEDAV: FALSE; "
                   "TIMSYS: TDB; TOL: 0.D0; COVER starts out %s",
                   i,
                   cvstat                                        );

         tcase_c ( title );


         /*
         Initialize COVER.
         */
         scard_c ( 0,  &cover );
         chckxc_c ( SPICEFALSE, " ", ok );

         /*
         Make a copy of the expected window.
         */
         copy_c ( xcvseg[i],  &tmpwin );

 
         /*
         Convert the expected window to TDB.
         */
         for ( j = 0;  j < card_c(&tmpwin);   j++ )
         {
            /*
            Convert the jth element of the tmpwin data array to TDB.
            */
            sct2e_c ( clkid[i],  SPICE_CELL_ELEM_D(&tmpwin,j), &et );

            SPICE_CELL_SET_D ( et, j, &tmpwin );          

            chckxc_c ( SPICEFALSE, " ", ok );
         }

         if ( l == 1  )
         {
            /*
            Insert an interval into COVER.  This same interval
            must be added to each window containing expected
            coverage.
            */
            wninsd_c ( 1.e6, 1.e7, &cover );
            chckxc_c ( SPICEFALSE, " ", ok );

            /*
            The same interval is expected to appear in the output.
            */
            wninsd_c ( 1.e6, 1.e7, &tmpwin );
            chckxc_c ( SPICEFALSE, " ", ok );
         }


         ckcov_c ( CK,   inst[i],  SPICEFALSE, "segment",
                   0.0,  "tdb",    &cover                );
         chckxc_c ( SPICEFALSE, " ", ok );


         /*
         Check cardinality of coverage window.
         */
         chcksi_c ( "card_c(&cover)", card_c(&cover), 
                    "=",              card_c(&tmpwin),  0,  ok  );
                   
         /*
         Check coverage window.
         */
         chckad_c ( "cover",  cover.data, 
                    "=",      tmpwin.data,  card_c(&cover),  0,  ok  );
      }


      for ( i = 0;  i < NINS;  i++ )
      {

         /*
         --- Case: ------------------------------------------------------
         */

         sprintf ( title,
                   "INST: %ld;  LEVEL: SEGMENT;  NEEDAV: FALSE; "
                   "TIMSYS: TDB; TOL: 1.D0; COVER starts out %s",
                   i,
                   cvstat                                        );

         tcase_c ( title );


         /*
         Initialize COVER.
         */
         scard_c ( 0,  &cover );
         chckxc_c ( SPICEFALSE, " ", ok );

         /*
         Adjust our expected result window by tol.
         */
         copy_c ( xcvseg[i],  &tmpwin );

         tol = 1.0;

         wnexpd_c ( tol, tol, &tmpwin );

         /*
         Make sure the window doesn't start with a negative tick
         value.  Set the first element of tmpwin to the maximum
         of this element and 0.
         */
         dval  = maxd_c ( 2,  0.0,  SPICE_CELL_ELEM_D(&tmpwin, 0 ) );

         SPICE_CELL_SET_D ( dval, 0, &tmpwin );

         /*
         Convert the expected window to TDB.
         */
         for ( j = 0;  j < card_c(&tmpwin);   j++ )
         {
            /*
            Convert the jth element of the tmpwin data array to TDB.
            */
            sct2e_c ( clkid[i],  SPICE_CELL_ELEM_D(&tmpwin,j), &et );

            SPICE_CELL_SET_D ( et, j, &tmpwin );          

            chckxc_c ( SPICEFALSE, " ", ok );
         }

         if ( l == 1  )
         {
            /*
            Insert an interval into COVER.  This same interval
            must be added to each window containing expected
            coverage.
            */
            wninsd_c ( 1.e6, 1.e7, &cover );
            chckxc_c ( SPICEFALSE, " ", ok );

            /*
            The same interval is expected to appear in the output.
            */
            wninsd_c ( 1.e6, 1.e7, &tmpwin );
            chckxc_c ( SPICEFALSE, " ", ok );
         }


         ckcov_c ( CK,   inst[i],  SPICEFALSE, "segment",
                   tol,  "tdb",    &cover                );
         chckxc_c ( SPICEFALSE, " ", ok );


         /*
         Check cardinality of coverage window.
         */
         chcksi_c ( "card_c(&cover)", card_c(&cover), 
                    "=",              card_c(&tmpwin),  0,  ok  );
                   
         /*
         Check coverage window.
         */
         chckad_c ( "cover",  cover.data, 
                    "=",      tmpwin.data,  card_c(&cover),  0,  ok  );
      }

 
      /*
      INTERVAL level tests:


      Now we'll repeat the previous tests, but this time the
      coverage will be summarized at the interval level.
      */


      for ( i = 0;  i < NINS;  i++ )
      {

         /*
         --- Case: ------------------------------------------------------
         */

         sprintf ( title,
                   "Check interval-level "                       
                   "coverage for instrument %ld; COVER starts "    
                   "out %s. Angular velocity not needed. "       
                   "TOL = 0.D0.",
                   i,
                   cvstat                                    );

         tcase_c ( title );


         /*
         Initialize COVER.
         */
         scard_c ( 0,  &cover );
         chckxc_c ( SPICEFALSE, " ", ok );

         /*
         Make a copy of the expected window.
         */
         copy_c ( xcvint[i],  &tmpwin );

         if ( l == 1  )
         {
            /*
            Insert an interval into COVER.  This same interval
            must be added to each window containing expected
            coverage.
            */
            wninsd_c ( 1.e6, 1.e7, &cover );
            chckxc_c ( SPICEFALSE, " ", ok );

            /*
            The same interval is expected to appear in the output.
            */
            wninsd_c ( 1.e6, 1.e7, &tmpwin );
            chckxc_c ( SPICEFALSE, " ", ok );
         }


         ckcov_c ( CK,   inst[i],  SPICEFALSE, "interval",
                   0.0,  "sclk",   &cover                );
         chckxc_c ( SPICEFALSE, " ", ok );


         /*
         Check cardinality of coverage window.
         */
         chcksi_c ( "card_c(&cover)", card_c(&cover), 
                    "=",              card_c(&tmpwin),  0,  ok  );
                   
         /*
         Check coverage window.
         */
         chckad_c ( "cover",  cover.data, 
                    "=",      tmpwin.data,  card_c(&cover),  0,  ok  );
      }

   

      for ( i = 0;  i < NINS;  i++ )
      {

         /*
         --- Case: ------------------------------------------------------
         */

         sprintf ( title,
                   "INST: %ld;  LEVEL: INTERVAL;  NEEDAV: TRUE; "
                   "TIMSYS: SCLK; TOL: 0.D0; COVER starts out %s",
                   i,
                   cvstat                                        );

         tcase_c ( title );


         /*
         Initialize COVER.
         */
         scard_c ( 0,  &cover );
         chckxc_c ( SPICEFALSE, " ", ok );

         /*
         Make a copy of the expected window.
         */
         copy_c ( xavint[i],  &tmpwin );

         if ( l == 1  )
         {
            /*
            Insert an interval into COVER.  This same interval
            must be added to each window containing expected
            coverage.
            */
            wninsd_c ( 1.e6, 1.e7, &cover );
            chckxc_c ( SPICEFALSE, " ", ok );

            /*
            The same interval is expected to appear in the output.
            */
            wninsd_c ( 1.e6, 1.e7, &tmpwin );
            chckxc_c ( SPICEFALSE, " ", ok );
         }


         ckcov_c ( CK,   inst[i],  SPICETRUE, "interval",
                   0.0,  "sclk",   &cover                );
         chckxc_c ( SPICEFALSE, " ", ok );


         /*
         Check cardinality of coverage window.
         */
         chcksi_c ( "card_c(&cover)", card_c(&cover), 
                    "=",              card_c(&tmpwin),  0,  ok  );
                   
         /*
         Check coverage window.
         */
         chckad_c ( "cover",  cover.data, 
                    "=",      tmpwin.data,  card_c(&cover),  0,  ok  );
      }
   



      for ( i = 0;  i < NINS;  i++ )
      {

         /*
         --- Case: ------------------------------------------------------
         */

         sprintf ( title,
                   "INST: %ld;  LEVEL: INTERVAL;  NEEDAV: FALSE; "
                   "TIMSYS: SCLK; TOL: 1.D0; COVER starts out %s",
                   i,
                   cvstat                                        );

         tcase_c ( title );


         /*
         Initialize COVER.
         */
         scard_c ( 0,  &cover );
         chckxc_c ( SPICEFALSE, " ", ok );

         /*
         Adjust our expected result window by tol.
         */
         copy_c ( xcvint[i],  &tmpwin );

         tol = 1.0;

         wnexpd_c ( tol, tol, &tmpwin );

         /*
         Make sure the window doesn't start with a negative tick
         value.  Set the first element of tmpwin to the maximum
         of this element and 0.
         */
         dval  = maxd_c ( 2,  0.0,  SPICE_CELL_ELEM_D(&tmpwin, 0 ) );

         SPICE_CELL_SET_D ( dval, 0, &tmpwin );


         if ( l == 1  )
         {
            /*
            Insert an interval into COVER.  This same interval
            must be added to each window containing expected
            coverage.
            */
            wninsd_c ( 1.e6, 1.e7, &cover );
            chckxc_c ( SPICEFALSE, " ", ok );

            /*
            The same interval is expected to appear in the output.
            */
            wninsd_c ( 1.e6, 1.e7, &tmpwin );
            chckxc_c ( SPICEFALSE, " ", ok );
         }


         ckcov_c ( CK,   inst[i],  SPICEFALSE, "interval",
                   tol,  "sclk",   &cover                );
         chckxc_c ( SPICEFALSE, " ", ok );


         /*
         Check cardinality of coverage window.
         */
         chcksi_c ( "card_c(&cover)", card_c(&cover), 
                    "=",              card_c(&tmpwin),  0,  ok  );
                   
         /*
         Check coverage window.
         */
         chckad_c ( "cover",  cover.data, 
                    "=",      tmpwin.data,  card_c(&cover),  0,  ok  );
      }



      for ( i = 0;  i < NINS;  i++ )
      {

         /*
         --- Case: ------------------------------------------------------
         */

         sprintf ( title,
                   "INST: %ld;  LEVEL: INTERVAL;  NEEDAV: FALSE; "
                   "TIMSYS: TDB; TOL: 0.D0; COVER starts out %s",
                   i,
                   cvstat                                        );

         tcase_c ( title );


         /*
         Initialize COVER.
         */
         scard_c ( 0,  &cover );
         chckxc_c ( SPICEFALSE, " ", ok );

         /*
         Make a copy of the expected window.
         */
         copy_c ( xcvint[i],  &tmpwin );

 
         /*
         Convert the expected window to TDB.
         */
         for ( j = 0;  j < card_c(&tmpwin);   j++ )
         {
            /*
            Convert the jth element of the tmpwin data array to TDB.
            */
            sct2e_c ( clkid[i],  SPICE_CELL_ELEM_D(&tmpwin,j), &et );

            SPICE_CELL_SET_D ( et, j, &tmpwin );          

            chckxc_c ( SPICEFALSE, " ", ok );
         }

         if ( l == 1  )
         {
            /*
            Insert an interval into COVER.  This same interval
            must be added to each window containing expected
            coverage.
            */
            wninsd_c ( 1.e6, 1.e7, &cover );
            chckxc_c ( SPICEFALSE, " ", ok );

            /*
            The same interval is expected to appear in the output.
            */
            wninsd_c ( 1.e6, 1.e7, &tmpwin );
            chckxc_c ( SPICEFALSE, " ", ok );
         }


         ckcov_c ( CK,   inst[i],  SPICEFALSE, "interval",
                   0.0,  "tdb",    &cover                );
         chckxc_c ( SPICEFALSE, " ", ok );


         /*
         Check cardinality of coverage window.
         */
         chcksi_c ( "card_c(&cover)", card_c(&cover), 
                    "=",              card_c(&tmpwin),  0,  ok  );
                   
         /*
         Check coverage window.
         */
         chckad_c ( "cover",  cover.data, 
                    "=",      tmpwin.data,  card_c(&cover),  0,  ok  );
      }


      for ( i = 0;  i < NINS;  i++ )
      {

         /*
         --- Case: ------------------------------------------------------
         */

         sprintf ( title,
                   "INST: %ld;  LEVEL: INTERVAL;  NEEDAV: FALSE; "
                   "TIMSYS: TDB; TOL: 1.D0; COVER starts out %s",
                   i,
                   cvstat                                        );

         tcase_c ( title );


         /*
         Initialize COVER.
         */
         scard_c ( 0,  &cover );
         chckxc_c ( SPICEFALSE, " ", ok );

         /*
         Adjust our expected result window by tol.
         */
         copy_c ( xcvint[i],  &tmpwin );

         tol = 1.0;

         wnexpd_c ( tol, tol, &tmpwin );

         /*
         Make sure the window doesn't start with a negative tick
         value.  Set the first element of tmpwin to the maximum
         of this element and 0.
         */
         dval  = maxd_c ( 2,  0.0,  SPICE_CELL_ELEM_D(&tmpwin, 0 ) );

         SPICE_CELL_SET_D ( dval, 0, &tmpwin );

         /*
         Convert the expected window to TDB.
         */
         for ( j = 0;  j < card_c(&tmpwin);   j++ )
         {
            /*
            Convert the jth element of the tmpwin data array to TDB.
            */
            sct2e_c ( clkid[i],  SPICE_CELL_ELEM_D(&tmpwin,j), &et );

            SPICE_CELL_SET_D ( et, j, &tmpwin );          

            chckxc_c ( SPICEFALSE, " ", ok );
         }

         if ( l == 1  )
         {
            /*
            Insert an interval into COVER.  This same interval
            must be added to each window containing expected
            coverage.
            */
            wninsd_c ( 1.e6, 1.e7, &cover );
            chckxc_c ( SPICEFALSE, " ", ok );

            /*
            The same interval is expected to appear in the output.
            */
            wninsd_c ( 1.e6, 1.e7, &tmpwin );
            chckxc_c ( SPICEFALSE, " ", ok );
         }


         ckcov_c ( CK,   inst[i],  SPICEFALSE, "interval",
                   tol,  "tdb",    &cover                );
         chckxc_c ( SPICEFALSE, " ", ok );


         /*
         Check cardinality of coverage window.
         */
         chcksi_c ( "card_c(&cover)", card_c(&cover), 
                    "=",              card_c(&tmpwin),  0,  ok  );
                   
         /*
         Check coverage window.
         */
         chckad_c ( "cover",  cover.data, 
                    "=",      tmpwin.data,  card_c(&cover),  0,  ok  );
      }



   }


   /*
   Error cases 
   */





   /*
   --- Case: ------------------------------------------------------
   */

   tcase_c ( "Error:  ckcov_c empty CK name" );

   ckcov_c  ( "", 1, SPICEFALSE, "SEGMENT", 0.0, "SCLK", &cover );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );


   /*
   --- Case: ------------------------------------------------------
   */

   tcase_c ( "Error:  ckcov_c null CK name" );

   ckcov_c  ( NULLCPTR, 1, SPICEFALSE, "SEGMENT", 0.0, "SCLK", &cover );

   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );


   /*
   --- Case: ------------------------------------------------------
   */

   tcase_c ( "Error:  ckcov_c empty `level'" );

   ckcov_c  ( CK, 1, SPICEFALSE, "", 0.0, "SCLK", &cover );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );


   /*
   --- Case: ------------------------------------------------------
   */

   tcase_c ( "Error:  ckcov_c null `level'" );

   ckcov_c  ( NULLCPTR, 1, SPICEFALSE, NULLCPTR, 0.0, "SCLK", &cover );

   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );


   /*
   --- Case: ------------------------------------------------------
   */

   tcase_c ( "Error:  ckcov_c empty `timsys'" );

   ckcov_c  ( CK, 1, SPICEFALSE, "SEGMENT", 0.0, "", &cover );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );


   /*
   --- Case: ------------------------------------------------------
   */

   tcase_c ( "Error:  ckcov_c null `timsys'" );

   ckcov_c  ( NULLCPTR, 1, SPICEFALSE, "segment", 0.0, NULLCPTR, &cover );

   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );


   /*
   --- Case: ------------------------------------------------------
   */

   tcase_c ( "Error: Try to find coverage using time system UTC." );

   ckcov_c  ( CK, 1, SPICEFALSE, "segment", 0.0, "UTC", &cover );

   chckxc_c ( SPICETRUE, "SPICE(NOTSUPPORTED)", ok );


   /*
   --- Case: ------------------------------------------------------
   */

   tcase_c ( "Error: Try to find coverage using negative tolerance." );

   ckcov_c  ( CK, 1, SPICEFALSE, "segment", -1.0, "sclk", &cover );

   chckxc_c ( SPICETRUE, "SPICE(VALUEOUTOFRANGE)", ok );



   /*
   --- Case: ------------------------------------------------------
   */

   tcase_c ( "Error: Try to find coverage using level 'file'." );

   ckcov_c  ( CK, 1, SPICEFALSE, "file", 0.0, "sclk", &cover );

   chckxc_c ( SPICETRUE, "SPICE(INVALIDOPTION)", ok );



   /*
   --- Case: ------------------------------------------------------
   */

   tcase_c ( "Try to find coverage for a transfer CK." );

   txtopn_ ( (char    *) XFRCK, 
             (integer *) &xunit, 
             (ftnlen   ) strlen(XFRCK) );

   chckxc_c ( SPICEFALSE, " ", ok );


   dafbt_  ( (char    *) CK,
             (integer *) &xunit,
             (ftnlen   ) strlen(CK) );

   chckxc_c ( SPICEFALSE, " ", ok );

   ftncls_c ( xunit );
   chckxc_c ( SPICEFALSE, " ", ok );

   ckcov_c  ( XFRCK, 1, SPICEFALSE, "SEGMENT", 0.0, "SCLK", &cover );
   chckxc_c ( SPICETRUE, "SPICE(INVALIDFORMAT)", ok );


   /*
   --- Case: ------------------------------------------------------
   */

   tcase_c ( "Try to find coverage for an SPK." );

   tstspk_c ( SPK, SPICEFALSE, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );

   ckcov_c  ( SPK, 1, SPICEFALSE, "SEGMENT", 0.0, "SCLK", &cover );
   chckxc_c ( SPICETRUE, "SPICE(INVALIDFILETYPE)", ok );


   /*
   --- Case: ------------------------------------------------------
   */

   tcase_c ( "Try to find coverage for an EK." );

   tstek_c  ( EK, 0, 20, SPICEFALSE, &handle, ok );
   chckxc_c ( SPICEFALSE, " ", ok );

   ckcov_c  ( EK, 1, SPICEFALSE, "SEGMENT", 0.0, "SCLK", &cover );
   chckxc_c ( SPICETRUE, "SPICE(INVALIDARCHTYPE)", ok );


   
   /*
   ******************************************************
   ******************************************************
   ******************************************************
       CKOBJ tests
   ******************************************************
   ******************************************************
   ******************************************************
   */



   /*
   --- Case: ------------------------------------------------------
   */
   tcase_c ( "Find objects in our test CK." );

   for ( i = 0;  i < NINS;  i++  )
   {
      insrti_c ( inst[i], &xids );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   ckobj_c ( CK, &ids );
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
   tcase_c ( "Find objects in our test CK. Start with "
             "a non-empty ID set."                       );


   insrti_c ( -1.e6, &xids );

   for ( i = 0;  i < NINS;  i++  )
   {
      insrti_c ( inst[i], &xids );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   insrti_c ( -1.e6, &ids );

   ckobj_c ( CK, &ids );
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

   tcase_c ( "Error:  ckobj_c empty CK name" );

   ckobj_c ( "", &ids );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );


   /*
   --- Case: ------------------------------------------------------
   */

   tcase_c  ( "Error:  ckobj_c null CK name" );

   ckobj_c  ( NULLCPTR, &ids );

   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );


   /*
   --- Case: ------------------------------------------------------
   */

   tcase_c  ( "Try to find IDS in a transfer format CK." );
   ckobj_c  ( XFRCK, &ids );
   chckxc_c ( SPICETRUE, "SPICE(INVALIDFORMAT)", ok ); 


   /*
   --- Case: ------------------------------------------------------
   */

   tcase_c ( "Try to find IDS in an SPK." );

   ckobj_c  ( SPK, &ids );
   chckxc_c ( SPICETRUE, "SPICE(INVALIDFILETYPE)", ok );


   /*
   --- Case: ------------------------------------------------------
   */

   tcase_c ( "Try to find IDS in an EK." );

   ckobj_c  ( EK, &ids );
   chckxc_c ( SPICETRUE, "SPICE(INVALIDARCHTYPE)", ok );

   /*
   Clean up. 
   */
   remove ( SPK   );
   remove ( CK    );
   remove ( EK    );
   remove ( XFRCK );

   t_success_c ( ok );
}
