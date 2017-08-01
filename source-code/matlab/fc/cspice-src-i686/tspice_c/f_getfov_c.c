/*

-Procedure f_getfov_c ( Test wrappers for getfov_c )

 
-Abstract
 
   Perform tests on getfov_c.
 
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
   

   void f_getfov_c ( SpiceBoolean * ok )

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
 
   This routine tests getfov_c.  Only the interface is 
   exercised; the underlying routine getfov_ is expected
   to be tested thoroughly by the f2c'd versions of the
   Fortran TSPICE test families covering GETFOV.

-Examples
 
   None.
    
-Restrictions
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
 
-Literature_References
 
   None. 
 
-Version
 
   -tspice_c Version 1.0.0 10-SEP-2004 (NJB)



-&
*/

{ /* Begin f_getfov_c */


   /*
   Prototypes 
   */
   void getfov_c ( SpiceInt        instid,
                   SpiceInt        room,
                   SpiceInt        shapelen,
                   SpiceInt        framelen,
                   SpiceChar     * shape,
                   SpiceChar     * frame,
                   SpiceDouble     bsight [3],
                   SpiceInt      * n,
                   SpiceDouble     bounds [][3] );

   /*
   Local parameters
   */ 
   #define INSTID          ( -22100 )
   #define LMPOOL_NVARS    4
   #define LNSIZE          81
   #define NAMLEN          33
   #define NLINES          9
   #define ROOM            4
   #define SHAPELEN        LNSIZE
   #define TIGHT           ( 1.e-14 )

  
   /*
   Static variables 
   */

   static SpiceChar        textbuf[NLINES][LNSIZE] = 
   {
      "INS-22100_FOV_FRAME             = '22100-FRAME' ",
      "INS-22100_FOV_SHAPE             = 'RECTANGLE' ",
      "INS-22100_BORESIGHT             = ( 0.0, 0.0, 1.0 )",
      "INS-22100_FOV_BOUNDARY_CORNERS  = ( ",
      "                                     1.0,  1.0, 1.0, ",
      "                                     1.0, -1.0, 1.0, ",
      "                                    -1.0, -1.0, 1.0, ",
      "                                    -1.0,  1.0, 1.0, ",
      "                                                       )"
   };


   static SpiceDouble expBoresight[3]     =  { 0.0, 0.0, 1.0 };

   static SpiceDouble expBoundary [4][3]  =  {
                                                {  1.0,  1.0, 1.0 },
                                                {  1.0, -1.0, 1.0 },
                                                { -1.0, -1.0, 1.0 },
                                                { -1.0,  1.0, 1.0 }
                                             };
                   
   /*
   Local variables
   */
   SpiceChar               frame     [ NAMLEN   ];
   SpiceChar               shape     [ SHAPELEN ];

   SpiceDouble             boresight [ 3 ];
   SpiceDouble             boundary  [ ROOM ][ 3 ];

   SpiceInt                n;


         
   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_getfov_c" );
   
      
   /*
   Case 1:
   */
   tcase_c ( "Normal case:  retrieve rectangular FOV parameters." ) ;
   
   /*
   Insert FOV description into kernel pool. 
   */
   lmpool_c ( textbuf, LNSIZE, NLINES );
   chckxc_c ( SPICEFALSE, " ", ok );
   

   /*
   Look up the FOV parameters using getfov_c. 
   */
   getfov_c ( INSTID, ROOM,  SHAPELEN,    NAMLEN, 
              shape,  frame, boresight,   &n,     boundary );

   chckxc_c ( SPICEFALSE, " ", ok );


   /*
   Check the shape. 
   */
   chcksc_c ( "shape", shape, "=", "RECTANGLE", ok );

   /*
   Check the frame. 
   */
   chcksc_c ( "frame", frame, "=", "22100-FRAME", ok );

   /*
   Check the boresight. 
   */
   chckad_c ( "boresight", boresight, "~", expBoresight, 3, TIGHT, ok );
   /*

   Check the boundary dimension.
   */
   chcksi_c ( "n", n, "=", ROOM, 0, ok );

   /*
   Check the boundary. 
   */
   chckad_c ( "boundary", 
              (SpiceDouble *)boundary,  
              "~", 
              (SpiceDouble *)expBoundary,  
              12, 
              TIGHT, 
              ok                             );



   /*
   Check string error cases:
   
      1) Null shape pointer.
      2) Shape string length too short.
      3) Null frame pointer.
      4) Frame string length too short.

     
   */
   getfov_c ( INSTID,    ROOM,       SHAPELEN,    NAMLEN, 
              NULLCPTR,  frame,      boresight,   &n,     boundary );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );

   
   getfov_c ( INSTID,    ROOM,       1,           NAMLEN, 
              shape,     frame,      boresight,   &n,     boundary );
   chckxc_c ( SPICETRUE, "SPICE(STRINGTOOSHORT)", ok );


   getfov_c ( INSTID,    ROOM,       SHAPELEN,    NAMLEN, 
              shape,     NULLCPTR,   boresight,   &n,     boundary );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   

   getfov_c ( INSTID,    ROOM,       SHAPELEN,    1, 
              shape,     frame,      boresight,   &n,     boundary );
   chckxc_c ( SPICETRUE, "SPICE(STRINGTOOSHORT)", ok );


   /*
   Leave the kernel pool clean.
   */
   clpool_c();
   

   /*
   Retrieve the current test status.
   */ 
   t_success_c ( ok ); 
   
   
} /* End f_getfov_c */



