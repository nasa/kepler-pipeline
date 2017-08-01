/*

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

*/

 
   /*
 
   The following are wrappers for tstlgr entry points.
 
 
      07-JUN-1999 (NJB)
 
   */
 
 
   #include <string.h>
   #include "SpiceZfc.h"
   #include "SpiceUsr.h"
   #include "SpiceZmc.h"
   #include "tutils_c.h"
 
 
 
   /*
   tstmsg_c sets up a message template in a manner analogous to
   setmsg_c.  The message will be printed if an error is detected.
   */
 
   void tstmsg_c ( ConstSpiceChar    * marker,
                   ConstSpiceChar    * message )
   {
      tstmsg_ ( ( char    * ) marker,
                ( char    * ) message,
                ( ftnlen    ) strlen(marker),
                ( ftnlen    ) strlen(message)  );
   }
 
 
   /*
   tstmsi_c replaces a marker in a message set up via tstmsg_c with
   an integer.
   */
 
   void tstmsi_c ( SpiceInt  ival )
   {
      tstmsi_ ( ( integer * ) &ival );
   }
 
 
 
   /*
   tstmsd_c replaces a marker in a message set up via tstmsg_c with
   a d.p. number.  Format is floating point.
   */
 
   void tstmsd_c ( SpiceDouble  dval )
   {
      tstmsd_ ( ( doublereal * ) &dval );
   }
 
 
   /*
   tstmsf_c replaces a marker in a message set up via tstmsg_c with
   a d.p. number.  Format is fixed point.
   */
 
   void tstmsf_c ( SpiceDouble  dval )
   {
      tstmsf_ ( ( doublereal * ) &dval );
   }
 
 
 
   /*
   tstmsc_c replaces a marker in a message set up via tstmsg_c with
   a string.
   */
 
   void tstmsc_c ( ConstSpiceChar * msg )
   {
      tstmsc_ ( ( char   * ) msg,
                ( ftnlen   ) strlen(msg) );
   }
 
 
 
   /*
   tstmso_c replaces a marker in a message set up via tstmsg_c with
   an ordinal number represented in English.
   */
 
   void tstmso_c (  SpiceInt           ival,
                    ConstSpiceChar   * marker )
   {
      tstmso_ ( ( integer * ) &ival,
                ( char    * ) marker,
                ( ftnlen    ) strlen(marker) );
   }
 
 
 
   /*
   tstmst_c replaces a marker in a message set up via tstmsg_c with
   a cardinal number represented in English.
   */
 
   void tstmst_c (  SpiceInt           ival,
                    ConstSpiceChar   * marker )
   {
      tstmst_ ( ( integer * ) &ival,
                ( char    * ) marker,
                ( ftnlen    ) strlen(marker) );
   }
