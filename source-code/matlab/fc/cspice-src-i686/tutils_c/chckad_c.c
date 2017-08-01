/*
 
-Procedure chckad_c ( Check an array of d.p. numbers )
 
 
-Abstract
 
   Check the values in a d.p. array.
 
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
 
 
   void chckad_c ( ConstSpiceChar    * name,
                   SpiceDouble       * array,
                   ConstSpiceChar    * comp,
                   SpiceDouble       * exp,
                   SpiceInt            size,
                   SpiceDouble         tol,
                   SpiceBoolean      * ok   )
/*
 
-Brief_I/O
 
   VARIABLE  I/O  DESCRIPTION
   --------  ---  --------------------------------------------------
   name       I   the name of the array to be examined.
   array      I   the actual array
   comp       I   the kind of comparison to perform.
   exp        I   the comparison values for the array
   size       I   the size of the input array
   tol        I   the tolerance allowed in comparing.
   ok         O   SPICETRUE if the test passes, SPICEFALSE otherwise..
 
-Detailed_Input
 
   name        is the string used to give the name of an array.
 
   array       is the actual d.p. array to be examined
 
   comp        a string giving the kind of comparison to perform:
 
                  =    ---   check for strict equality
                  ~    ---   check for array[i] ~  exp[i] for each i.
                             This checks that the difference
                             |array[i] - exp[i]| <= tol for all i.
 
                  ~/   ---   check for array[i] ~/ exp[i] ( Relative
                             difference between array[i] and exp[i]
                             <= tol for all i.
 
                  ||   ---   check that the "angle" between array
                             and exp is within tol of zero.
 
                  ~~   ---   check that the L2 distance between
                             array and exp is within tol of zero.
 
                  |_   ---   check that the angle between array
                             and exp is within tol of pi/2 radians
 
                  ~~/  ---   check that the vector relative
                             difference between array and exp is
                             within tol of zero.
 
   exp         an expected values or bounds on the values in array.
 
 
   tol        is a "tolerance" to use when checking for val to
              be nearly the same as exp.
 
-Detailed_Output
 
   ok         if the check of the input array is successful then
              ok is given the value SPICETRUE.  Otherwise ok is given
              the value SPICEFALSE and a diagnostic message is sent to
              the test logger.
 
-Parameters
 
   None.
 
-Files
 
   None.
 
-Exceptions
 
   Error free.
 
-Particulars
 
   This routine handles a wide variety of comparisons between
   double precision arrays.
 
-Examples
 
   Suppose that you have just made a call to a subroutine that
   you wish to test (call the routine SPUD) and you would like
   to test an output d.p. against an expected value and verify that
   the relative difference is less than some value.  Using
   this routine you can automatically have the test result logged
   in via the testing utitities.
 
      spud     (  input,   output );
      chckad_c ( "output", output, "~/", expect, 1.0e-12, &ok );
 
-Restrictions
 
   None.
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
   W.L. Taber      (JPL)
 
-Literature_References
 
   None.
 
-Version
 
   -tutils_c Version 1.1.0 20-SEP-1999 (NJB) (EDW)
 
      Local logical variable used as argument to underlying
      f2c'd routine.
      
   -tutils_c Version 1.0.0 12-JUN-1999 (NJB) (WLT)
 
-&
*/
 
{ /* Begin chckad_c */
 
   /*
   Local variables
   */
   logical                 shonuff;
 
 
 
   assert ( name          !=  NULLCPTR );
   assert ( strlen(name)  >   0        );
   
   assert ( comp          !=  NULLCPTR );
   assert ( strlen(comp)  >   0        );
    
   chckad_ (  ( char        * ) name,
              ( doublereal  * ) array,
              ( char        * ) comp,
              ( doublereal  * ) exp,
              ( integer     * ) &size,
              ( doublereal  * ) &tol,
              ( logical     * ) &shonuff,
              ( ftnlen        ) strlen(name),
              ( ftnlen        ) strlen(comp)  );
 
 
   *ok  =  (SpiceBoolean) shonuff;
 
  
} /* End chckad_c */
