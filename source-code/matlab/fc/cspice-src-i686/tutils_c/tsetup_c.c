/*
 
-Procedure tsetup_c ( Test utility setup )
 
-Abstract
 
   This routine handles the initializations needed for making use
   of the SPICE testing utilities.
 
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
 
   INTERFACE
 
*/
   #include <assert.h>
   #include "SpiceUsr.h"
   #include "SpiceZfc.h"
   #include "SpiceZmc.h"
   #include "tutils_c.h"
 
 
   void tsetup_c ( ConstSpiceChar * lognam,
                   ConstSpiceChar * versn   )
 
/*
 
-Brief_I/O
 
   Variable  I/O  Description
   --------  ---  --------------------------------------------------
   lognam     I   Name pattern of file where commands will be logged
   versn      I   Program name and version
 
-Detailed_Input
 
   lognam    is a pattern to use when creating the name of
             a file to which all commands will be written.
             This can be hard coded in the calling
             program, or may be determined by a file naming
             convention such as is provided by Christen
             and NOMEN.
 
   versn     is a string that may contain anything you would
             like to appear as descriptive text in the first
             line of the log file (and possibly in the greeting
             presented by the program)  Something like
             "<program name> --- Version X.Y" would be appropriate.
             For example if your programs name is KINDLE and you
             are at version 4.2.3 of your program a good value for
             VERSN would be
 
             "KINDLE --- Version 4.2.3"
 
             Your greeting routine can make use of this when
             displaying your program's greeting.  In this way
             you can centralize the name and version number of
             your program at a high level or in a subroutine and
             simply make the information available to tsetup_c so
             that the automatic aspects of presenting this
             information can be handled for you.
 
 
 
-Detailed_Output
 
   None.
 
-Parameters
 
   None.
 
-Exceptions
 
   None.  This routine cannot detect any errors in its inputs
   and all commands are regarded as legal input at this level.
 
-Files
 
   The file specified by logfil will be opened if possible
   and all test results will then be stored in that file.
 
   Other files may be used a run time by "STARTing" a command
   sequence file. Or by some result of the activity of the
   user supplied routines ACTION, GREET, PREPRC.
 
-Particulars
 
   This routine preforms the initializations needed for using
   the NAIF test utilities.  It should be called once in your
   test program.
 
-Examples
 
   None.
 
-Restrictions
 
   None.
 
-Literature_References
 
   None.
 
-Author_and_Institution
 
   N.J. Bachman  (JPL)
   W.L. Taber    (JPL)
 
-Version
 
   -tutils_c Version 1.0.0, 12-JUN-1999 (NJB) (WLT)
 
-&
*/
 
{ /* Begin tsetup_c */
 
 
 
   assert ( lognam          !=  NULLCPTR );
   assert ( strlen(lognam)  >   0        );
 
   assert ( versn           !=  NULLCPTR );
   assert ( strlen(versn)   >   0        );
 
 
 
   tsetup_ (  ( char    * ) lognam,
              ( char    * ) versn,
              ( ftnlen    ) strlen(lognam),
              ( ftnlen    ) strlen(versn)   );
 
 
 
} /* End tsetup_c */
