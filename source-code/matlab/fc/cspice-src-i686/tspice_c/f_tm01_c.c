/*

-Procedure f_tm01_c ( Test wrappers for time routines, subset 1 )

 
-Abstract
 
   Perform tests on CSPICE wrappers for a subset of the time system 
   routines.
    
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
   

   void f_tm01_c ( SpiceBoolean * ok )

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
 
   This routine tests the wrappers for a subset of the CSPICE time
   system routines. 
   
   The subset is:
      
      deltet_c
      et2utc_c
      et2lst_c
      etcal_c
      str2et_c
      timdef_c
      timout_c
      tparse_c
      tpictr_c
      tsetyr_c
      unitim_c
      utc2et_c
       
-Examples
 
   None.
    
-Restrictions
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
 
-Literature_References
 
   None. 
 
-Version

   -tspice_c Version 3.0.0 01-AUG-2003 (NJB)

      Updated to test deltet_c.

   -tspice_c Version 2.0.0 02-SEP-2002 (NJB)

      Updated to test et2lst_c.

   -tspice_c Version 1.1.0 13-DEC-2001 (EDW)

      Reset the time system's assumed default year
      range for two digit century determination to
      that as defined in the SPICE library with
      a tsetyr_c( 1969 ) call.
      
      The SPICE system's current default range is
      1969 to 2068.

   -tspice_c Version 1.0.0 24-JUL-1999 (NJB)  

-&
*/

{ /* Begin f_tm01_c */

 
   /*
   Local macros
   */
   
   #define TRASH(file)     if ( remove(file) !=0 )                         \
                           printf ("***Unable to remove %s\n\n", file ); 
   /*
   Constants
   */
   #define ERRLEN          321
   #define ITEMLEN         25
   #define LOOSE_TOL       0.01
   #define PICLEN          81
   #define TAI_OFFSET      32.184
   #define TDB_1999        "1999 JAN 01 12:00:00.000 (TDB)"
   #define TDB_1999_IN     "1999 JAN 01 12:00:00.000  TDB"
   #define TDB_J2000       "2000 JAN 01 12:00:00.000 (TDB)"
   #define TIGHT_TOL       1.e-14
   #define VTIGHT_TOL      1.e-15
   #define MED_TOL         1.e-8
   #define TIMLEN          60
   #define UTC_1999        "1999 JAN 01 12:00:00.000"
   #define UTC_J2000       "2000 JAN 01 12:00:00.000"
   
   /*
   Local variables
   */
   SpiceBoolean            found;
   SpiceBoolean            parseOk;

   SpiceChar               ampm   [ TIMLEN ];
   SpiceChar               dtype;
   SpiceChar               errmsg [ ERRLEN ];
   SpiceChar               etStr  [ TIMLEN ];
   SpiceChar               inStr  [ TIMLEN ];
   SpiceChar               outStr [ TIMLEN ];
   SpiceChar               pictur [ PICLEN ];
   SpiceChar               time   [ TIMLEN ];
   SpiceChar             * type;
   SpiceChar               utcStr [ TIMLEN ];

   SpiceDouble             delta;
   SpiceDouble             et2;
   SpiceDouble             et;
   SpiceDouble             expDelta;
   SpiceDouble             formalTime;
   SpiceDouble             lon;
   SpiceDouble             tdt2000;
   SpiceDouble             tdt;
   SpiceDouble             u2000;
   SpiceDouble             utcsec;


   SpiceInt                dim;
   SpiceInt                handle;
   SpiceInt                hr;
   SpiceInt                mn;
   SpiceInt                nLeaps;
   SpiceInt                sc;





   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_tm01_c" );
   

   
   /*
   Make sure the kernel pool doesn't contain any unexpected 
   definitions.
   */
   clpool_c();
   
   /*
   Load a leapseconds kernel.  Find out how many leapseconds we have.
   
   Note that the LSK is deleted after loading, so we don't have to clean
   it up later.
   */
   tstlsk_c();
   chckxc_c ( SPICEFALSE, " ", ok );
   
   dtpool_c ( "DELTET/DELTA_AT", &found, &dim, &dtype );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "found", found, SPICETRUE, ok );
   
   nLeaps = 9 + dim/2;
   
   /*
   Case 1:
   */
   tcase_c ( "Test utc2et_c and et2utc_c.  Make sure these are "
             "inverses of each other."                           );
 
 
   utc2et_c ( UTC_J2000,             &u2000 );
   chckxc_c ( SPICEFALSE, " ", ok );

   et2utc_c ( u2000, "C", 3, TIMLEN, utcStr );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksc_c ( "UTC string",  utcStr,  "=",  UTC_J2000, ok );


   /*
   Case 2:
   */
   tcase_c ( "Test str2et_c; make sure it agrees with utc2et_c." );
      
   str2et_c ( UTC_J2000,             &et );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   chcksd_c ( "str2et_c output", et, "~", u2000, TIGHT_TOL, ok );
  
  
   /*
   Case 3:
   */
   tcase_c ( "Test tparse_c.  Compare with str2et_c, with the latter "
             "converting a TDB string to ET seconds past J2000."     );
             
   str2et_c ( TDB_J2000, &et         );
   chckxc_c ( SPICEFALSE, " ", ok );

   tparse_c ( UTC_J2000, ERRLEN, &formalTime, errmsg );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "errmsg is empty", (strlen(errmsg) == 0), SPICETRUE, ok );

   chcksd_c ( "tparse output", formalTime, "~", et, TIGHT_TOL, ok );


   /*
   Case 4:
   */
   tcase_c ( "Test unitim_c.  Convert UTC_J2000 to TDT; compare to "
             "value obtained from tparse_c with leapseconds and the "
             "TAI offset added on."                                );


   str2et_c ( UTC_J2000, &et );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   tdt2000 = unitim_c ( et, "TDB", "TDT" );
   chckxc_c ( SPICEFALSE, " ", ok );
      
   tparse_c ( UTC_J2000, ERRLEN, &formalTime, errmsg );
   chckxc_c ( SPICEFALSE, " ", ok );
      
   chcksl_c ( "errmsg is empty", (strlen(errmsg) == 0), SPICETRUE, ok );

   tdt = formalTime + TAI_OFFSET + nLeaps;
   
   chcksd_c ( "unitim output", tdt2000, "~", tdt, TIGHT_TOL, ok );

   
   /*
   Case 5:
   */
   tcase_c ( "Test etcal_c.  Invert value obtained from tparse_c." );

   tparse_c ( UTC_1999, ERRLEN, &et, errmsg );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "errmsg is empty", (strlen(errmsg) == 0), SPICETRUE, ok );
   
   etcal_c  ( et, TIMLEN, etStr );  
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksc_c ( "ET string",  etStr,  "=",  UTC_1999, ok );


   /*
   Case 6:
   */
   tcase_c ( "Test tpictr_c.  Produce an expected picture from a "
             "given calendar string."                              );


   /*
   This example comes straight from the header of tpictr_c.
   */

   tpictr_c ( "10:23 P.M. PDT January 03, 1993",
               PICLEN, ERRLEN, pictur, &parseOk, errmsg );
               
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "parse statusflag", parseOk, SPICETRUE, ok );
   
   chcksl_c ( "errmsg is empty", (strlen(errmsg) == 0), SPICETRUE, ok );
   
   chcksc_c ( "Time format picture",  
              pictur,  
              "=",  
              "AP:MN AMPM PDT Month DD, YYYY ::UTC-7", ok );      


   /*
   Case 7:
   */
   tcase_c ( "Test timout_c.  Use the picture and date string from "
             "the tpictr_c example."                                 );

   strcpy ( inStr,  "10:23 P.M. PDT January 03, 1993"       );
   strcpy ( pictur, "AP:MN AMPM PDT Month DD, YYYY ::UTC-7" );
   
   str2et_c ( inStr, &et );
   chckxc_c ( SPICEFALSE, " ", ok );

   
   timout_c ( et, pictur, TIMLEN, outStr );
              
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksc_c ( "formatted time string", outStr, "=", inStr, ok );      



   /*
   Case 8:
   */
   tcase_c ( "Test timdef_c.  Set the default calendar to Julian, "
             "the verify that the change has been made by fetching "
             "the default."                                         );


   timdef_c ( "GET", "CALENDAR", ITEMLEN,  outStr  );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksc_c ( "Default calendar", outStr, "=", "GREGORIAN", ok );      
   
   
   timdef_c ( "SET", "CALENDAR", ITEMLEN, "Julian" );
   chckxc_c ( SPICEFALSE, " ", ok );

   timdef_c ( "GET", "CALENDAR", ITEMLEN,  outStr  );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksc_c ( "Default calendar", outStr, "=", "JULIAN", ok );      

   timdef_c ( "SET", "CALENDAR", ITEMLEN, "GREGORIAN" );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   /*
   Case 9:
   */
   tcase_c ( "Test tsetyr_c.  Set the default range to 2100--2199" );
   
   tsetyr_c ( 2100 );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   str2et_c ( "99 jan 1", &et );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   str2et_c ( "2199 jan 1", &et2 );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   chcksd_c ( "ET from 2-digit year.", et, "~", et2, TIGHT_TOL, ok ); 

   /*
   Return the default range to the library default value.
   */
   tsetyr_c ( 1969 );

   /*
   Case 10: 
   */
   tcase_c ( "Test et2lst_c."  );


   /*
   Load a PCK file and planetary SPK. 
   */
   tstpck_c ( "test.pck", SPICETRUE, SPICETRUE );
   chckxc_c ( SPICEFALSE, " ", ok );

   tstspk_c ( "test.spk", SPICETRUE, &handle );

   str2et_c ( "2002 sep 2 00:00:00", &et );
   chckxc_c ( SPICEFALSE, " ", ok );

   lon  = 326.17 * rpd_c();
   type = "PLANETOCENTRIC";
 
   et2lst_c ( et,  499,  lon, "PLANETOCENTRIC", TIMLEN, TIMLEN,
              &hr, &mn,  &sc, time,             ampm            );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "Hour",   hr,    "=", 22, 0, ok ); 
   chcksi_c ( "Min",    mn,    "=", 55, 0, ok ); 
   chcksi_c ( "Sec",    sc,    "=", 27, 0, ok ); 
   chcksc_c ( "time",   time,  "=", "22:55:27",       ok ); 
   chcksc_c ( "ampm",   ampm,  "=", "10:55:27 P.M.",  ok ); 

   /*
   Error cases: 
   */

   /*
   Null pointers: 
   */
   et2lst_c ( et,  499,  lon, NULLCPTR, TIMLEN, TIMLEN,
              &hr, &mn,  &sc, time,     ampm            );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   et2lst_c ( et,  499,  lon, "PLANETOCENTRIC", TIMLEN,   TIMLEN,
              &hr, &mn,  &sc, NULLCPTR,         ampm             );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   et2lst_c ( et,  499,  lon, "PLANETOCENTRIC", TIMLEN,   TIMLEN,
              &hr, &mn,  &sc, time,             NULLCPTR         );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   
   /*
   Empty coordinate type string:
   */
   et2lst_c ( et,  499,  lon, "",    TIMLEN, TIMLEN,
              &hr, &mn,  &sc, time,  ampm            );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );


   /*
   Output strings too short: 
   */
   et2lst_c ( et,  499,  lon, "PLANETOCENTRIC", 1,       TIMLEN,
              &hr, &mn,  &sc, time,             ampm             );
   chckxc_c ( SPICETRUE, "SPICE(STRINGTOOSHORT)", ok );

   et2lst_c ( et,  499,  lon, "PLANETOCENTRIC", TIMLEN,  1,
              &hr, &mn,  &sc, time,             ampm             );
   chckxc_c ( SPICETRUE, "SPICE(STRINGTOOSHORT)", ok );


   unload_c ( "test.spk" );
   TRASH ( "test.spk" ); 


   /*
   Case 11:
   */
   tcase_c ( "Test deltet_c.  Compare against ET-UTC derived "
             "from st2et_c."                                  );

   str2et_c ( UTC_1999, &et );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   /*
   To obtain UTC seconds past J2000, we lie to str2et_c and claim
   the input is already TDB. 
   */
   str2et_c ( TDB_1999_IN, &utcsec );
   chckxc_c ( SPICEFALSE, " ", ok  );

   expDelta = et - utcsec;

   deltet_c ( utcsec, "UTC", &delta );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksd_c ( "delta", delta, "~", expDelta, MED_TOL, ok );

   /*
   Now obtain delta using a TDB input time. Make sure we get identical
   results vs those obtained from a UTC input time.
   */
   deltet_c ( utcsec, "UTC", &expDelta );
   chckxc_c ( SPICEFALSE, " ", ok );

   deltet_c ( et, "ET", &delta );
   chckxc_c ( SPICEFALSE, " ", ok );
  
   chcksd_c ( "ET delta vs UTC delta", delta, "=", expDelta, 0.0, ok );
   
   /*
   Check relative error when ET is computed directly vs when deltet_c
   is used. 
   */
   chcksd_c ( "utcsec + delta", utcsec + delta, "~/", 
               et, VTIGHT_TOL, ok );


   /*
   Error cases: 
   */

   /*
   Null pointer: 
   */
   deltet_c ( utcsec, NULLCPTR, &expDelta );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   /*
   Empty string:
   */
   deltet_c ( utcsec, "", &expDelta );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );



   /*
   Retrieve the current test status.
   */ 
   t_success_c ( ok ); 
   
   
} /* End f_tm01_c */

