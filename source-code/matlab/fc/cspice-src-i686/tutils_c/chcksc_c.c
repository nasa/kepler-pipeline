/*
 
-Procedure chcksc_c ( Check scalar character string )
 
 
-Abstract
 
   Check an string scalar value against some expected value.
 
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
   #include <assert.h>
   #include "SpiceUsr.h"
   #include "SpiceZfc.h"
   #include "SpiceZmc.h"
   #include "tutils_c.h"
 
 
   void chcksc_c ( ConstSpiceChar   * name,
                   ConstSpiceChar   * val,
                   ConstSpiceChar   * comp,
                   ConstSpiceChar   * exp,
                   SpiceBoolean     * ok    )
 
/*
 
-Brief_I/O
 
   VARIABLE  I/O  DESCRIPTION
   --------  ---  --------------------------------------------------
   name       I   the name of the variable to be examined.
   val        I   the actual variable
   exp        I   the comparison value for the variable
   comp       I   the kind of comparison to perform.
   tol        I   the tolerance allowed in comparing.
   ok         O   SPICETRUE if the test passes, SPICEFALSE otherwise..
 
-Detailed_Input
 
   name        is the string used to give the name of a variable
 
   val         is the actual character variable to be examined
 
   comp        a string giving the kind of comparison to perform:
 
                  =    ---   check for strict equality
                  >    ---   check for val >  exp
                  <    ---   check for val <  exp
                  >=   ---   check for val >= exp
                  <=   ---   check for val <= exp
                  !=   ---   check for val != exp
 
                  The following are the case insensitive versions
                  of the previous checks.
 
                  ~=    ---   check for strict equality
                  ~>    ---   check for val >  exp
                  ~<    ---   check for val <  exp
                  ~>=   ---   check for val >= exp
                  ~<=   ---   check for val <= exp
                  ~!=   ---   check for val != exp
 
-Detailed_Output
 
   ok         if the check of the input variable is successful then
              ok is given the value SPICETRUE.  Otherwise ok is given
              the value SPICEFALSE and a diagnostic message is sent to
              the test logger.
 
-Parameters
 
   None.
 
-Files
 
   The result of a failure is automatically logged in the testing
   log file and failure file.  Success is logged only if verbose
   testing has been enabled.
 
-Exceptions
 
   Error free.
 
-Particulars
 
   This routine handles a wide variety of comparisons between
   scalar string values.
 
-Examples
 
   Suppose that you have just made a call to a subroutine that
   you wish to test (call the routine spud) and you would like
   to test an output string against an expected value.  Using
   this routine you can automatically have the test result logged
   in via the testing utitities.
 
      spud     (  input,   output );
      chcksc_c ( "OUTPUT", output, '=', expect, &ok );
 
-Restrictions
 
   None.
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
   W.L. Taber      (JPL)
 
-Literature_References
 
   None.
 
-Version
 
   -tutils_c Version 1.0.0 12-JUN-1999 (NJB) (WLT)
 
-&
*/
 
{ /* Begin chcksc_c */
 
   /*
   Local constants
   */
 
 
   /*
   Local variables
   */
   logical                 shonuff;
 
 
 
   assert ( name          !=  NULLCPTR );
   assert ( strlen(name)  >   0        );
   
   assert ( val           !=  NULLCPTR );
   assert ( strlen(val)   >   0        );
   
   assert ( comp          !=  NULLCPTR );
   assert ( strlen(comp)  >   0        );
 
   assert ( exp           !=  NULLCPTR );
   assert ( strlen(exp)   >   0        );
 
 
   chcksc_  (  ( char        * ) name,
               ( char        * ) val,
               ( char        * ) comp,
               ( char        * ) exp,
               ( logical     * ) &shonuff,
               ( ftnlen        ) strlen(name),
               ( ftnlen        ) strlen(val),
               ( ftnlen        ) strlen(comp),
               ( ftnlen        ) strlen(exp)   );
 
   *ok  =  shonuff;
 
 
 
} /* End chcksc_c */
