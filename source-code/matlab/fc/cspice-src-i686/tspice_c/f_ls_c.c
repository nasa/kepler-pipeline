/*

-Procedure f_ls_c ( Test wrappers solar longitude routines )


-Abstract

   Perform tests on CSPICE wrappers for the Ls routine(s).

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
   #include "SpiceZmc.h"
   #include "tutils_c.h"
   
   void f_ls_c ( SpiceBoolean * ok )

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

   This routine tests the wrappers for the solar longitude routines.
   The current set is:

      lspcn_c

-Examples

   None.

-Restrictions

   None.

-Author_and_Institution

   N.J. Bachman    (JPL)

-Literature_References

   None.

-Version

   -tspice_c Version 1.0.0 07-JAN-2005 (NJB)

-&
*/

{ /* Begin f_ls_c */

   /*
   Local constants
   */
   #define PCK              "f_ls.tpc" 
   #define SPK              "f_ls.bsp" 
   #define LOOSE            ( 5.e-3 )
   #define LNSIZE           81
   #define NCASE            100
   #define NCORR            3
   #define CORLEN           16
   #define TIMLEN           41


   /*
   Static local variables
   */
   static SpiceChar        abcorr [ NCORR ][ CORLEN ] = 
                           {
                              "NONE", "LT", "LT+S"
                           };


   /*
   Automatic local variables 
   */
   SpiceChar               timstr [ TIMLEN ];
   SpiceChar               title  [ LNSIZE ];

   SpiceDouble             dec;
   SpiceDouble             et;
   SpiceDouble             ls;
   SpiceDouble             lt;
   SpiceDouble             ra;
   SpiceDouble             range;
   SpiceDouble             sstate[6];

   SpiceInt                handle;
   SpiceInt                i;
   SpiceInt                j;


   topen_c ( "f_ls_c" );

   /*
--- Case: ------------------------------------------------------  
   */
   tcase_c  ( "Setup:  create and load kernels." );

   tstpck_c ( PCK, SPICETRUE, SPICEFALSE );
   chckxc_c ( SPICEFALSE, " ", ok );

   tstspk_c ( SPK, SPICETRUE, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );

   tstlsk_c();
   chckxc_c ( SPICEFALSE, " ", ok );


   /*
   Test for all aberration corrections.
   */   

   for ( i = 0;  i < NCORR;  i++  )
   {
      /*
      For a variety of times of year, find the RA of
      the earth-sun vector in the ECLIPJ2000 frame. 
      */
      for ( j = 0;  j < NCASE;  j++  )
      {
            /*
         --- Case: ------------------------------------------------------  
            */

         et  =  j  * jyear_c() / NCASE;

         etcal_c  ( et, TIMLEN, timstr );
         chckxc_c ( SPICEFALSE, " ", ok );

         sprintf  ( title, "ET = %s; ABCORR = %s", timstr, abcorr[i] );

         tcase_c  ( title );

         spkezr_c ( "SUN",      et,       "ECLIPJ2000",  
                    abcorr[i],  "earth",  sstate,       &lt );
         chckxc_c ( SPICEFALSE, " ", ok );
 
         recrad_c ( sstate, &range, &ra, &dec );
         chckxc_c ( SPICEFALSE, " ", ok );

         /*            
         Find Ls.
         */
         ls = lspcn_c  ( "earth", et, abcorr[i] );
         chckxc_c ( SPICEFALSE, " ", ok );

         chcksd_c ( "Ls",  ls, "~", ra, LOOSE, ok );
      }
      
   }

   /*
   Error cases:
   */

      /*
   --- Case: ------------------------------------------------------  
      */

   tcase_c ( "Null pointer error" );

   ls = lspcn_c  ( NULLCPTR, et, abcorr[i] );

   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

      /*
   --- Case: ------------------------------------------------------  
      */

   tcase_c ( "Empty string error" );

   ls = lspcn_c  ( "", et, abcorr[i] );

   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );

   /*
   Retrieve the current test status.
   */
   t_success_c ( ok );

} /* End f_jac_c */

