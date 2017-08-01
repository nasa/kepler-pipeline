/*

-Procedure f_sort_c ( Test wrappers for sorting and searching routines )

 
-Abstract
 
   Perform tests on CSPICE wrappers for the SPICELIB sorting and 
   searching functions. 
 
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


   #include <stdlib.h>
   #include <math.h>
   #include <stdio.h>
   #include "SpiceUsr.h"
   #include "SpiceZfc.h"
   #include "SpiceZmc.h"
   #include "tutils_c.h"


   void f_sort_c ( SpiceBoolean * ok )

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
 
   This routine tests the wrappers for the CSPICE sorting
   and searching routines.

-Examples
 
   None.
    
-Restrictions
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
 
-Literature_References
 
   None. 
 
-Version
 
   -tspice_c Version 1.0.0 11-JUL-2002 (NJB) 
   
-&

*/

{ /* Begin f_sort_c */

 


   


   /*
   Constants
   */
   #define LNSIZE          81
   #define NSCI            5         
   #define NISRCH          4         
   #define NSHELL          6
   #define NORD            5
   #define NLOG            12
   #define NEQ             6
       
   /*
   Local variables
   */
   SpiceBoolean            lRoArray    [NLOG];

   SpiceBoolean            lRoArrayInp [NLOG] =
                           {
                              SPICETRUE,
                              SPICEFALSE,
                              SPICEFALSE,
                              SPICETRUE,
                              SPICETRUE,
                              SPICETRUE,
                              SPICEFALSE,
                              SPICEFALSE,
                              SPICETRUE,
                              SPICETRUE,
                              SPICETRUE,
                              SPICETRUE
                           };


   SpiceBoolean            lRoArrayExp [NLOG] =
                           {
                              SPICEFALSE,
                              SPICEFALSE,
                              SPICEFALSE,
                              SPICEFALSE,
                              SPICETRUE,
                              SPICETRUE,
                              SPICETRUE,
                              SPICETRUE,
                              SPICETRUE,
                              SPICETRUE,
                              SPICETRUE,
                              SPICETRUE
                           };

   SpiceChar               aName  [ LNSIZE ];

   SpiceChar               carray[NSCI][LNSIZE] =
                           {
                              "BOHR",
                              "EINSTEIN",
                              "FEYNMAN",
                              "GALILEO",
                              "NEWTON"
                           };

   SpiceChar               carray2[NISRCH][LNSIZE] =
                           {
                               "1",  "0",  "4",  "2" 
                           };


   SpiceChar               cBsoArrayInp [NORD][LNSIZE] =
                           {
                              "FEYNMAN",
                              "BOHR",
                              "EINSTEIN",
                              "NEWTON",
                              "GALILEO"
                           };

   SpiceChar               cEsArrayInp [NEQ][LNSIZE] =
                           {
                              "This",
                              "little",
                              "piggy",
                              "went",
                              "to",
                              "market"
                           };

   SpiceChar               cShArray    [NSHELL][LNSIZE];

   SpiceChar               cShArrayInp [NSHELL][LNSIZE] =
                           {
                              "FEYNMAN",
                              "NEWTON",
                              "EINSTEIN",
                              "GALILEO",
                              "EUCLID",
                              "Galileo"
                           };

   SpiceChar               cShArrayExp [NSHELL][LNSIZE] =
                           {
                              "EINSTEIN",
                              "EUCLID",
                              "FEYNMAN",
                              "GALILEO",
                              "Galileo",
                              "NEWTON"
                           };




   SpiceDouble             darray   [4]      = { -11.0, 0.0, 22.0, 750.0 };

   SpiceDouble             darray2  [4]      = {   1.0, 0.0,  4.0,   2.0 };


   SpiceDouble             dLeArrayInp [NSHELL] =
                           {
                              -2.0, -2.0, 0.0, 1.0, 1.0, 11.0 
                           };


   SpiceDouble             dShArray    [NSHELL];

   SpiceDouble             dShArrayInp [NSHELL] =
                           {
                               99.0, 33.0, 55.0, 44.0, -77.0, 66.0
                           };

   SpiceDouble             dShArrayExp [NSHELL] =
                           {
                               -77.0, 33.0, 44.0, 55.0, 66.0, 99.0 
                           };


   SpiceInt                cBsoVec      [NORD] =
                           {
                               1, 2, 0, 4, 3
                           };


   SpiceInt                cOrdArray    [NSHELL];

   SpiceInt                cOrdArrayExp [NSHELL] = 
                           {
                               2, 4, 0, 3, 5, 1
                           };

   SpiceInt                dOrdArray    [NSHELL];

   SpiceInt                i;

   SpiceInt                iarray [4] = { -11,     0,   22, 750 };

   SpiceInt                iarray2[4] = { 1,       0,   4,  2    };


   SpiceInt                iBsoArrayInp [NORD] =
                           {
                               100, 1, 10, 10000, 1000
                           };

   SpiceInt                iBsoVec      [NORD] =
                           {
                               1, 2, 0, 4, 3
                           };


   SpiceInt                iLeArrayInp [NSHELL] =
                           {
                              -2, -2, 0, 1, 1, 11 
                           };

   SpiceInt                iOrdArray    [NSHELL];

   SpiceInt                iOrdArrayExp [NSHELL] = 
                           {
                              4, 1, 3, 2, 5, 0 
                           };

   SpiceInt                isordvVecN [NORD] =
                           {
                              4, 1, 3, 2,  2 
                           };

   SpiceInt                isordvVecY [NORD] = 
                           {
                              4, 1, 3, 2,  0 
                           };

   SpiceInt                iShArray    [NSHELL];

   SpiceInt                iShArrayInp [NSHELL] =
                           {
                               99,   33,   55,   44,   -77,   66
                           };

   SpiceInt                iShArrayExp [NSHELL] =
                           {
                               -77,   33,   44,   55,   66,   99 
                           };

   SpiceInt                loc;

   SpiceInt                lRoVec [NLOG] =
                           {
                              1, 2, 6, 7, 0, 3, 4, 5, 8, 9, 10, 11
                           };


   SpiceStatus             status;


   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_sort_c" );
      

   /*
   bsrchd_c tests: 
   */

   tcase_c ( "bsrchd_c test #1 from header example section" );

   loc = bsrchd_c ( -11.0, 4, darray );

   chcksi_c ( "loc", loc,  "=",  0,  0,  ok );


   tcase_c ( "bsrchd_c test #2 from header example section" );

   loc = bsrchd_c ( 22.0, 4, darray );

   chcksi_c ( "loc", loc,  "=",  2,  0,  ok );



   tcase_c ( "bsrchd_c test #3 from header example section" );

   loc = bsrchd_c ( 751.0, 4, darray );

   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );


   tcase_c ( "negative dimension" );

   loc = bsrchd_c ( 751.0, -1, darray );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );



   /*
   bsrchi_c tests: 
   */

   tcase_c ( "bsrchi_c test #1 from header example section" );

   loc = bsrchi_c ( -11, 4, iarray );

   chcksi_c ( "loc", loc,  "=",  0,  0,  ok );


   tcase_c ( "bsrchi_c test #2 from header example section" );

   loc = bsrchi_c ( 22, 4, iarray );

   chcksi_c ( "loc", loc,  "=",  2,  0,  ok );



   tcase_c ( "bsrchi_c test #3 from header example section" );

   loc = bsrchi_c ( 751, 4, iarray );

   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );


   tcase_c ( "negative dimension" );

   loc = bsrchi_c ( 751, -1, iarray );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );

   /*
   bsrchc_c tests: 
   */

   tcase_c ( "bsrchc_c test #1 from header example section" );

   loc = bsrchc_c ( "NEWTON",  NSCI, LNSIZE, carray );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "loc", loc,  "=",  4,  0,  ok );


   tcase_c ( "bsrchc_c test #2 from header example section" );

   loc = bsrchc_c ( "EINSTEIN",  NSCI, LNSIZE, carray );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "loc", loc,  "=",  1,  0,  ok );



   tcase_c ( "bsrchc_c test #3 from header example section" );

   loc = bsrchc_c ( "GALILEO",  NSCI, LNSIZE, carray );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "loc", loc,  "=",  3,  0,  ok );



   tcase_c ( "bsrchc_c test #4 from header example section" );

   loc = bsrchc_c ( "Galileo",  NSCI, LNSIZE, carray );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );



   tcase_c ( "bsrchc_c test #5 from header example section" );

   loc = bsrchc_c ( "BETHE",  NSCI, LNSIZE, carray );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );


   /*
   bsrchc_c error checking tests: 
   */
   tcase_c ( "bsrchc_c string error checking tests" );


   loc = bsrchc_c ( NULLCPTR,  NSCI, LNSIZE, carray );

   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );


   loc = bsrchc_c ( "BETHE",  NSCI, 1, carray );

   chckxc_c ( SPICETRUE, "SPICE(STRINGTOOSHORT)", ok );
   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );


   loc = bsrchc_c ( "BETHE",  NSCI, 2, NULLCPTR );

   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );

   /*
   And two non-error exceptions: 
   */
   loc = bsrchc_c ( "BETHE",  -100, LNSIZE, carray );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );

   loc = bsrchc_c ( "",  NSCI, LNSIZE, carray );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );



   /*
   esrchc_c tests: 
   */   

   tcase_c ( "esrchc_c test #1 from header example section" );

   loc = esrchc_c ( "PIGGY", NEQ, LNSIZE, cEsArrayInp );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "loc", loc,  "=",  2,  0,  ok );


   tcase_c ( "esrchc_c test #2 from header example section" );

   loc = esrchc_c ( " LiTtLe  ", NEQ, LNSIZE, cEsArrayInp );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "loc", loc,  "=",  1,  0,  ok );


   tcase_c ( "esrchc_c test #3 from header example section" );

   loc = esrchc_c ( "W e n t", NEQ, LNSIZE, cEsArrayInp );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "loc", loc,  "=",  3,  0,  ok );


   tcase_c ( "esrchc_c test #4 from header example section" );

   loc = esrchc_c ( "mall", NEQ, LNSIZE, cEsArrayInp );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );


   /*
   esrchc_c error checking tests: 
   */
   tcase_c ( "esrchc_c string error checking tests" );


   loc = esrchc_c ( NULLCPTR,  NSCI, LNSIZE, carray );

   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );


   loc = esrchc_c ( "BETHE",  NSCI, 1, carray );

   chckxc_c ( SPICETRUE, "SPICE(STRINGTOOSHORT)", ok );
   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );


   loc = esrchc_c ( "BETHE",  NSCI, 2, NULLCPTR );

   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );

   /*
   And two non-error exceptions: 
   */
   loc = esrchc_c ( "BETHE",  -1, 2, carray );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );

   loc = esrchc_c ( "",  NSCI, LNSIZE, carray );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );




   /*
   isrchc_c tests: 
   */   

   tcase_c ( "isrchc_c test #1 from header example section" );

   loc = isrchc_c ( "4", 4, LNSIZE, carray2 );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "loc", loc,  "=",  2,  0,  ok );


   tcase_c ( "isrchc_c test #2 from header example section" );

   loc = isrchc_c ( "2", 4, LNSIZE, carray2 );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "loc", loc,  "=",  3,  0,  ok );


   tcase_c ( "isrchc_c test #3 from header example section" );

   loc = isrchc_c ( "3", 4, LNSIZE, carray2 );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );




   /*
   isrchc_c error checking tests: 
   */
   tcase_c ( "isrchc_c string error checking tests" );


   loc = isrchc_c ( NULLCPTR,  NSCI, LNSIZE, carray );

   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );


   loc = isrchc_c ( "BETHE",  NSCI, 1, carray );

   chckxc_c ( SPICETRUE, "SPICE(STRINGTOOSHORT)", ok );
   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );


   loc = isrchc_c ( "BETHE",  NSCI, 2, NULLCPTR );

   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );

   /*
   And two non-error exceptions: 
   */
   loc = isrchc_c ( "BETHE",  -1, 2, carray );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );

   loc = isrchc_c ( "",  NSCI, LNSIZE, carray );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );



   /*
   isrchd_c tests: 
   */   

   tcase_c ( "isrchd_c test #1 from header example section" );

   loc = isrchd_c ( 4.0, 4, darray2 );

   chcksi_c ( "loc", loc,  "=",  2,  0,  ok );


   tcase_c ( "isrchd_c test #2 from header example section" );

   loc = isrchd_c ( 2.0, 4, darray2 );

   chcksi_c ( "loc", loc,  "=",  3,  0,  ok );


   tcase_c ( "isrchd_c test #3 from header example section" );

   loc = isrchd_c ( 3.0, 4, darray2 );

   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );


   tcase_c ( "negative dimension" );

   loc = isrchd_c ( 3.0, -1, darray2 );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );

   /*
   isrchi_c tests: 
   */   

   tcase_c ( "isrchi_c test #1 from header example section" );

   loc = isrchi_c ( 4, 4, iarray2 );

   chcksi_c ( "loc", loc,  "=",  2,  0,  ok );


   tcase_c ( "isrchi_c test #2 from header example section" );

   loc = isrchi_c ( 2, 4, iarray2 );

   chcksi_c ( "loc", loc,  "=",  3,  0,  ok );


   tcase_c ( "isrchi_c test #3 from header example section" );

   loc = isrchi_c ( 3, 4, iarray2 );

   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );


   tcase_c ( "negative dimension" );

   loc = isrchi_c ( 3, -1, iarray2 );

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );


   /*
   shelld_c tests: 
   */   
   tcase_c ( "shelld_c test #1 from header example section" );

   MOVED ( dShArrayInp, NSHELL, dShArray );

   shelld_c ( NSHELL, dShArray );

   chckad_c ( "dShArray", dShArray, "=", dShArrayExp, NSHELL, 0.0, ok );
  

   tcase_c ( "negative dimension" );

   shelld_c ( -1, dShArray );

   chckxc_c ( SPICEFALSE, " ", ok );


   /*
   shelli_c tests: 
   */   
   tcase_c ( "shelli_c test #1 from header example section" );

   MOVEI ( iShArrayInp, NSHELL, iShArray );

   shelli_c ( NSHELL, iShArray );

   chckai_c ( "iShArray", iShArray, "=", iShArrayExp, NSHELL, ok );


   tcase_c ( "negative dimension" );

   shelli_c ( -1, iShArray );

   chckxc_c ( SPICEFALSE, " ", ok );


   /*
   shellc_c tests: 
   */   
   tcase_c ( "shellc_c test #1 from header example section" );

   for ( i = 0;  i < NSHELL;  i++ )
   {
      strcpy ( cShArray[i], cShArrayInp[i] );
   }

   shellc_c ( NSHELL, LNSIZE, cShArray );

   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < NSHELL;  i++ )
   {
      chcksc_c ( "cShArray[i]", cShArray[i], "=", cShArrayExp[i], ok );
   }
   

   /*
   shellc_c error checking tests: 
   */
   tcase_c ( "shellc_c string error checking tests" );

   shellc_c ( NSHELL, LNSIZE, NULLCPTR );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   shellc_c ( NSHELL, 1, cShArray );
   chckxc_c ( SPICETRUE, "SPICE(STRINGTOOSHORT)", ok );



   tcase_c ( "negative dimension" );

   shellc_c ( -1, LNSIZE, cShArray );

   chckxc_c ( SPICEFALSE, " ", ok );



   /*
   orderc_c tests: 
   */   
   tcase_c ( "orderc_c test:  find order of shellc input array." );

   orderc_c ( LNSIZE, cShArrayInp, NSHELL, cOrdArray );
   chckxc_c ( SPICEFALSE, " ", ok );
   chckai_c ( "cOrdArray", cOrdArray, "=", cOrdArrayExp, NSHELL, ok );

   /*
   orderc_c error checking tests: 
   */
   tcase_c ( "orderc_c string error checking tests" );

   orderc_c ( LNSIZE, NULLCPTR, NSHELL, cOrdArray );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   orderc_c ( 1, cShArrayInp, NSHELL, cOrdArray );
   chckxc_c ( SPICETRUE, "SPICE(STRINGTOOSHORT)", ok );


   tcase_c ( "negative dimension" );

   orderc_c ( LNSIZE, cShArrayInp, -1, cOrdArray );

   chckxc_c ( SPICEFALSE, " ", ok );



   /*
   orderd_c tests: 
   */   
   tcase_c ( "orderd_c test:  find order of shelld input array." );

   orderd_c ( dShArrayInp, NSHELL, iOrdArray );
   chckai_c ( "iOrdArray", iOrdArray, "=", iOrdArrayExp, NSHELL, ok );


   tcase_c ( "negative dimension" );

   orderd_c ( dShArrayInp, -1, iOrdArray );

   chckxc_c ( SPICEFALSE, " ", ok );



   /*
   orderi_c tests: 
   */   
   tcase_c ( "orderi_c test:  find order of shelli input array." );

   orderi_c ( iShArrayInp, NSHELL, iOrdArray );
   chckai_c ( "iOrdArray", iOrdArray, "=", iOrdArrayExp, NSHELL, ok );


   tcase_c ( "negative dimension" );

   orderi_c ( iShArrayInp, -1, iOrdArray );

   chckxc_c ( SPICEFALSE, " ", ok );


   /*
   lstlec_c tests: 
   */

   tcase_c ( "lstlec_c test #1 from header example section" );

   loc = lstlec_c ( "NEWTON",  NSCI, LNSIZE, carray );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "loc", loc,  "=",  4,  0,  ok );


   tcase_c ( "lstlec_c test #2 from header example section" );

   loc = lstlec_c ( "EINSTEIN",  NSCI, LNSIZE, carray );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "loc", loc,  "=",  1,  0,  ok );



   tcase_c ( "lstlec_c test #3 from header example section" );

   loc = lstlec_c ( "GALILEO",  NSCI, LNSIZE, carray );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "loc", loc,  "=",  3,  0,  ok );



   tcase_c ( "lstlec_c test #4 from header example section" );

   loc = lstlec_c ( "Galileo",  NSCI, LNSIZE, carray );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "loc", loc,  "=",  3,  0,  ok );



   tcase_c ( "lstlec_c test #5 from header example section" );

   loc = lstlec_c ( "BETHE",  NSCI, LNSIZE, carray );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );

   /*
   lstled_c tests: 
   */   
   tcase_c ( "lstled_c test #1 from header example section" );

   loc = lstled_c ( -3.0, NSHELL, dLeArrayInp );
   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );


   tcase_c ( "lstled_c test #2 from header example section" );

   loc = lstled_c ( -2.0, NSHELL, dLeArrayInp );
   chcksi_c ( "loc", loc,  "=",  1,  0,  ok );


   tcase_c ( "lstled_c test #3 from header example section" );

   loc = lstled_c (  0.0, NSHELL, dLeArrayInp );
   chcksi_c ( "loc", loc,  "=",  2,  0,  ok );


   tcase_c ( "lstled_c test #4 from header example section" );

   loc = lstled_c ( 1.0, NSHELL, dLeArrayInp );
   chcksi_c ( "loc", loc,  "=",  4,  0,  ok );

   tcase_c ( "lstled_c test #5 from header example section" );

   loc = lstled_c ( 11.1, NSHELL, dLeArrayInp );
   chcksi_c ( "loc", loc,  "=",  5,  0,  ok );


   tcase_c ( "negative dimension" );

   loc = lstled_c ( 11.1, -1, dLeArrayInp );

   chckxc_c ( SPICEFALSE, " ", ok );


   /*
   lstlei_c tests: 
   */   


   tcase_c ( "lstlei_c test #1 from header example section" );

   loc = lstlei_c ( -3, NSHELL, iLeArrayInp );
   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );


   tcase_c ( "lstlei_c test #2 from header example section" );

   loc = lstlei_c ( -2, NSHELL, iLeArrayInp );
   chcksi_c ( "loc", loc,  "=",  1,  0,  ok );


   tcase_c ( "lstlei_c test #3 from header example section" );

   loc = lstlei_c (  0, NSHELL, iLeArrayInp );
   chcksi_c ( "loc", loc,  "=",  2,  0,  ok );


   tcase_c ( "lstlei_c test #4 from header example section" );

   loc = lstlei_c ( 1, NSHELL, iLeArrayInp );
   chcksi_c ( "loc", loc,  "=",  4,  0,  ok );

   tcase_c ( "lstlei_c test #5 from header example section" );

   loc = lstlei_c ( 12, NSHELL, iLeArrayInp );
   chcksi_c ( "loc", loc,  "=",  5,  0,  ok );


   tcase_c ( "negative dimension" );

   loc = lstlei_c ( 12, -1, iLeArrayInp );

   chckxc_c ( SPICEFALSE, " ", ok );





   /*
   lstltc_c tests: 
   */

   tcase_c ( "lstltc_c test #1 from header example section" );

   loc = lstltc_c ( "NEWTON",  NSCI, LNSIZE, carray );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "loc", loc,  "=",  3,  0,  ok );


   tcase_c ( "lstltc_c test #2 from header example section" );

   loc = lstltc_c ( "EINSTEIN",  NSCI, LNSIZE, carray );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "loc", loc,  "=",  0,  0,  ok );



   tcase_c ( "lstltc_c test #3 from header example section" );

   loc = lstltc_c ( "GALILEO",  NSCI, LNSIZE, carray );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "loc", loc,  "=",  2,  0,  ok );



   tcase_c ( "lstltc_c test #4 from header example section" );

   loc = lstltc_c ( "Galileo",  NSCI, LNSIZE, carray );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "loc", loc,  "=",  3,  0,  ok );



   tcase_c ( "lstltc_c test #5 from header example section" );

   loc = lstltc_c ( "BETHE",  NSCI, LNSIZE, carray );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );


   /*
   lstltc_c error checking tests: 
   */
   tcase_c ( "lstltc_c string error checking tests" );

   loc = lstltc_c ( NULLCPTR,  NSCI, LNSIZE, carray );

   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );


   loc = lstltc_c ( "BETHE",  NSCI, 1, carray );

   chckxc_c ( SPICETRUE, "SPICE(STRINGTOOSHORT)", ok );
   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );


   loc = lstltc_c ( "BETHE",  NSCI, 2, NULLCPTR );

   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );

   /*
   And two non-error exceptions:  
   */
   loc = lstltc_c ( "BETHE",  -100, LNSIZE, carray );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );

   loc = lstltc_c ( "",  NSCI, LNSIZE, carray );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );



   /*
   lstltd_c tests: 
   */   
   tcase_c ( "lstltd_c test #1 from header example section" );

   loc = lstltd_c ( -3.0, NSHELL, dLeArrayInp );
   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );


   tcase_c ( "lstltd_c test #2 from header example section" );

   loc = lstltd_c ( -2.0, NSHELL, dLeArrayInp );
   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );


   tcase_c ( "lstltd_c test #3 from header example section" );

   loc = lstltd_c (  0.0, NSHELL, dLeArrayInp );
   chcksi_c ( "loc", loc,  "=",  1,  0,  ok );


   tcase_c ( "lstltd_c test #4 from header example section" );

   loc = lstltd_c ( 1.0, NSHELL, dLeArrayInp );
   chcksi_c ( "loc", loc,  "=",  2,  0,  ok );

   tcase_c ( "lstltd_c test #5 from header example section" );

   loc = lstltd_c ( 11.1, NSHELL, dLeArrayInp );
   chcksi_c ( "loc", loc,  "=",  5,  0,  ok );


   tcase_c ( "negative dimension" );

   loc = lstltd_c ( 11.1, -1, dLeArrayInp );

   chckxc_c ( SPICEFALSE, " ", ok );


   /*
   lstlti_c tests: 
   */   

   tcase_c ( "lstlti_c test #1 from header example section" );

   loc = lstlti_c ( -3, NSHELL, iLeArrayInp );
   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );


   tcase_c ( "lstlti_c test #2 from header example section" );

   loc = lstlti_c ( -2, NSHELL, iLeArrayInp );
   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );


   tcase_c ( "lstlti_c test #3 from header example section" );

   loc = lstlti_c (  0, NSHELL, iLeArrayInp );
   chcksi_c ( "loc", loc,  "=",  1,  0,  ok );


   tcase_c ( "lstlti_c test #4 from header example section" );

   loc = lstlti_c ( 1, NSHELL, iLeArrayInp );
   chcksi_c ( "loc", loc,  "=",  2,  0,  ok );

   tcase_c ( "lstlti_c test #5 from header example section" );

   loc = lstlti_c ( 12, NSHELL, iLeArrayInp );
   chcksi_c ( "loc", loc,  "=",  5,  0,  ok );


   tcase_c ( "negative dimension" );

   loc = lstlti_c ( 12, -1, iLeArrayInp );

   chckxc_c ( SPICEFALSE, " ", ok );


   /*
   reordc_c tests: 
   */   
   tcase_c ( "Sort the list of scientists from the shellc_c test "
             "using the order vector "
             "obtained from orderc_c. "                            );

   orderc_c ( LNSIZE, cShArrayInp, NSHELL, cOrdArray );
   chckxc_c ( SPICEFALSE, " ", ok );

   reordc_c ( cOrdArray, NSHELL, LNSIZE, cShArray );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < NSHELL;  i++ )
   {
      chcksc_c ( "cShArray[i]", cShArray[i], "=", cShArrayExp[i], ok );
   }
   

   tcase_c ( "Make sure that ndim < 2 doesn't cause an error." );
   reordc_c ( cOrdArray, -2, LNSIZE, cShArray );
   chckxc_c ( SPICEFALSE, " ", ok );



   /*
   reordd_c tests: 
   */   
   tcase_c ( "Sort the list of d.p. numbers from the shelld_c test "
             "using the order vector obtained from orderd_c. "      );

   MOVED    ( dShArrayInp, NSHELL, dShArray  );

   orderd_c ( dShArrayInp, NSHELL, dOrdArray );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   reordd_c ( dOrdArray, NSHELL, dShArray ); 

   chckad_c ( "dShArray", dShArray, "=",  dShArrayExp, NSHELL, 0.0, ok );

   
   tcase_c ( "Make sure that ndim < 2 doesn't cause an error." );
   reordd_c ( dOrdArray, -1, dShArray ); 
   chckxc_c ( SPICEFALSE, " ", ok );



   /*
   reordi_c tests: 
   */   
   tcase_c ( "Sort the list of integers from the shelli_c test "
             "using the order vector obtained from orderi_c. "      );

   MOVEI    ( iShArrayInp, NSHELL, iShArray  );

   orderi_c ( iShArrayInp, NSHELL, iOrdArray );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   reordi_c ( iOrdArray, NSHELL, iShArray ); 

   chckai_c ( "iShArray", iShArray, "=",  iShArrayExp, NSHELL, ok );


   tcase_c ( "Make sure that ndim < 2 doesn't cause an error." );
   reordi_c ( iOrdArray, -1, iShArray ); 
   chckxc_c ( SPICEFALSE, " ", ok );



   /*
   reordl_c tests: 
   */   
   tcase_c ( "Order a list list of SpiceBooleans according to a  "
             "specified order vector; check the result against an "
             "expected SpiceBoolean array."                        );

   for ( i = 0;  i < NLOG;  i++ )
   {
      lRoArray[i] = lRoArrayInp[i];
   }
   
   reordl_c ( lRoVec, NLOG, lRoArray ); 
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < NLOG;  i++ )
   {
      sprintf ( aName, "lRoArray[%ld]", i );
      chcksl_c ( aName, lRoArray[i], lRoArrayExp[i], ok );
   }


   tcase_c ( "Make sure that ndim < 2 doesn't cause an error." );
   reordl_c ( lRoVec, -1, lRoArray ); 
   chckxc_c ( SPICEFALSE, " ", ok );





   /*
   bschoc_c tests: 
   */   

   tcase_c ( "bschoc_c test #1 from header example section" );

   loc = bschoc_c ( "NEWTON", NORD, LNSIZE, cBsoArrayInp, cBsoVec );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "loc", loc,  "=",  3,  0,  ok );


   tcase_c ( "bschoc_c test #2 from header example section" );

   loc = bschoc_c ( "EINSTEIN", NORD, LNSIZE, cBsoArrayInp, cBsoVec );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "loc", loc,  "=",  2,  0,  ok );


   tcase_c ( "bschoc_c test #3 from header example section" );

   loc = bschoc_c ( "GALILEO", NORD, LNSIZE, cBsoArrayInp, cBsoVec );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "loc", loc,  "=",  4,  0,  ok );


   tcase_c ( "bschoc_c test #4 from header example section" );

   loc = bschoc_c ( "Galileo", NORD, LNSIZE, cBsoArrayInp, cBsoVec );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );


   tcase_c ( "bschoc_c test #5 from header example section" );

   loc = bschoc_c ( "BETHE", NORD, LNSIZE, cBsoArrayInp, cBsoVec );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );


   /*
   bschoc_c error checking tests: 
   */
   tcase_c ( "bschoc_c string error checking tests" );



   loc = bschoc_c ( NULLCPTR,  NORD, LNSIZE, cBsoArrayInp, cBsoVec );

   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );


   loc = bschoc_c ( "EINSTEIN",  NORD, 1, cBsoArrayInp, cBsoVec );

   chckxc_c ( SPICETRUE, "SPICE(STRINGTOOSHORT)", ok );
   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );


   loc = bschoc_c ( "EINSTEIN",  NORD, 1, NULLCPTR, cBsoVec );

   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );

   /*
   And two non-error exceptions: 
   */
   loc = bschoc_c (  "EINSTEIN",  -1, 1, cBsoArrayInp, cBsoVec );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );


   loc = bschoc_c ( "",  NORD, LNSIZE, cBsoArrayInp, cBsoVec );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "loc", loc,  "=",  -1, 0,  ok );


   /*
   bschoi_c tests: 
   */   

   
   tcase_c ( "bschoi_c test #1 from header example section" );
   
   loc = bschoi_c ( 1000, NORD, iBsoArrayInp, iBsoVec );
   chcksi_c ( "loc", loc,  "=",  4,  0,  ok );
   

   tcase_c ( "bschoi_c test #2 from header example section" );
   
   loc = bschoi_c ( 1, NORD, iBsoArrayInp, iBsoVec );
   chcksi_c ( "loc", loc,  "=",  1,  0,  ok );
   

   tcase_c ( "bschoi_c test #3 from header example section" );
   
   loc = bschoi_c ( 10000, NORD, iBsoArrayInp, iBsoVec );
   chcksi_c ( "loc", loc,  "=",  3,  0,  ok );
   

   tcase_c ( "bschoi_c test #4 from header example section" );
   
   loc = bschoi_c ( -1, NORD, iBsoArrayInp, iBsoVec );
   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );
   

   tcase_c ( "bschoi_c test #5 from header example section" );
   
   loc = bschoi_c ( 17, NORD, iBsoArrayInp, iBsoVec );
   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );
   


   /*
   And one non-error exception: 
   */
   loc = bschoi_c ( 17, -1, iBsoArrayInp, iBsoVec );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "loc", loc,  "=",  -1,  0,  ok );



   /*
   isordv_c tests: 
   */   
   tcase_c ( "isordv_c test #1:  input an order vector." );

   status = isordv_c ( isordvVecY, NORD );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "status", status, SPICETRUE,  ok );


   tcase_c ( "isordv_c test #2:  input a non order vector." );

   status = isordv_c ( isordvVecN, NORD );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "status", status, SPICEFALSE,  ok );


   /*
   And two non-error exceptions: 
   */
   tcase_c ( "isordv_c test #3:  zero dimension." );

   status = isordv_c ( isordvVecY, 0 );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "status", status, SPICEFALSE,  ok );

   tcase_c ( "isordv_c test #3:  negative dimension." );

   status = isordv_c ( isordvVecY, -1 );
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "status", status, SPICEFALSE,  ok );



   /*
   Retrieve the current test status.
   */ 
   t_success_c ( ok ); 
   
   
} /* End f_sort_c */




 
