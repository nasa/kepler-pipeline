/*

-Procedure tstspk_c ( Create an SPK file for use in testing)

-Abstract
 
   Create an SPK file that can be used for obtaining 
   states and testing code that makes use of the SPK system 
 
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
     SPK 
 
*/
   #include <assert.h>
   #include "tutils_c.h"
   #include "SpiceUsr.h"
   #include "SpiceZfc.h"
   #include "SpiceZmc.h"

   void tstspk_c ( ConstSpiceChar   * file,
                   SpiceBoolean       load,
                   SpiceInt         * handle ) 

/*

-Brief_I/O
 
    VARIABLE  I/O  DESCRIPTION 
    --------  ---  -------------------------------------------------- 
    file       I   The name of an SPK file to create. 
    load       I   Logical indicating if file should be loaded. 
    handle     O   Handle if file is loaded by tstspk_c. 
 
-Detailed_Input
 
   file        is the name of an SPK file to create for use in 
               software testing.  This SPK is not a good model 
               for the solar system. 
 
               If the file specified already exists, the existing 
               file is deleted and a new one created with the 
               same name in its place. 
 
   LOAD        is a logical flag indicating whether or not the 
               created SPK file should be loaded.  If load is SPICETRUE 
               the file is loaded.  If load is SPICEFALSE the file is 
               not loaded by this routine. 
 
 
-Detailed_Output
 
   handle      is the handle attached to the SPK file if load is 
               SPICETRUE. 
 
-Parameters
 
    None. 
 
-Exceptions
 
   1) If the specified file already exists, it is deleted and 
      replaced by the file created by this routine. 
 
   1) All other exceptions are diagnosed by routines in the call tree 
      of this routine. 
 
-Files
 
    This routine creates an SPK file with ephemeris information 
    for the following objects. 
 
         SUN 
            MERCURY 
               MERCURY_BARYCENTER 
            VENUS_BARYCENTER 
               VENUS 
            EARTH-MOON-BARYCENTER 
               EARTH 
                  GOLDSTONE_TRACKING_STATION 
                  MADRID_TRACKING_STATION 
                  CANBERRA_TRACKING_STATION 
                  MOON 
                     SPACECRAFT_PHOENIX 
                     TRANQUILITY_BASE 
            MARS_BARYCENTER 
               MARS 
                  PHOBOS 
                     PHOBOS_BASECAMP 
                  DEIMOS 
            JUPITER_BARYCENTER 
               JUPITER 
                  IO 
                  EUROPA 
                  GANYMEDE 
                  ISTO 
            SATURN_BARYCENTER 
               SATURN 
 
                  TITAN 
            URANUS_BARYCENTER 
               URANUS 
                  OBERON 
                  ARIEL 
                  UMBRIEL 
                  TITANIA 
                  MIRANDA 
            NEPTUNE_BARYCENTER 
               NEPTUNE 
                  TRITON 
                  NEREID 
            PLUTO_BARYCENTER 
               PLUTO 
                  CHARON 
 
 
-Particulars
 
   This routine creates a "TOY" solar system model for use 
   in testing the SPICE ephemeris system. 
 
   The data in this file are "good" for the epochs 
 
      from 1980 JAN 1, 00:00:00.000 (ET) 
      to   2011 SEP 9, 01:46:40.000 (ET) 
      (a span of exactly 1 billion seconds). 
 
 
   If the input file already exists, it is deleted prior to the 
   creation of this file. 
 
-Examples
 
   The normal way to use this routine is shown below. 
 
      #include <stdio.h>
      #include "SpiceUsr.h"
      #include "tutils_c.h"
      
      #define SPK "sstoy.bsp"
           .
           .
           .
      tstspk_c ( SPK, SPICETRUE, &handle  ); 
 
      [Perform some tests and computations.]
 
 
      spkuef_c ( handle );
      remove   ( SPK    );

 
-Restrictions
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
   W.L. Taber      (JPL) 
 
-Literature_References
 
   None. 
 
-Version
 
   -tutils_c Version 1.0.0, 27-JUN-1999 (NJB) (WLT)

-Index_Entries
 
   Create an SPK file for high-level software tests 
 
-&
*/

{ /* Begin tstspk_c */


   /*
   Local variables
   */
   logical                 ld;

 
   assert ( file          !=  NULLCPTR );
   assert ( strlen(file)  >   0        );
   
   ld = load;
   
   tstspk_ (  ( char    * ) file,
              ( logical * ) &ld,
              ( integer * ) handle,
              ( ftnlen    ) strlen(file) );


} /* End tstspk_c */
