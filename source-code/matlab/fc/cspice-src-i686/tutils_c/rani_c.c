/*

-Procedure rani_c ( Random integer )

-Abstract
 
   Return a pseudo-random integer lying in a specified interval. 
 
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
 
   MATH 
 
*/

   #include <stdlib.h>
   #include "SpiceUsr.h"
   

   SpiceInt rani_c ( SpiceInt     lb, 
                     SpiceInt     ub  )
/*

-Brief_I/O
 
   Variable  I/O  Description 
   --------  ---  -------------------------------------------------- 
   lb,
   ub         I   Bounds of interval from which to pick integer.
    
   The function returns a pseudo-random number in the interval [lb, ub].
   
-Detailed_Input
 
   lb,
   ub             are, respectively, integers defining an interval from
                  which to pick a pseudo-random integer.
                  
-Detailed_Output
 
   The function returns a random integer in the interval [lb, ub].
   Random numbers are obtained by calling the C library function rand(), 
   then scaling and shifting so that the resulting numbers are uniformly 
   distributed on the interval [lb, ub].
   
   The underlying rand() function can be made to produce a new 
   series of pseudo-random numbers by changing the random number seed.
   This is done by calling the C library function srand():
   
      srand  ( (unsigned int) seed );  

   If rand() is called before srand() is called, the default seed value
   of 1 is used, according the the ANSI C standard.                  

-Parameters
 
   None. 
 
-Exceptions
 
   Error free. 
 
-Files
 
   None. 
 
-Particulars
 
   The randomness properties of this function are no better than 
   those of the host's implementation of rand().
    
-Examples
 
   1) Obtain 25 random integers in the interval [-100, 100].
      Use a non-default seed.
   
         #include <stdlib.h>
         #include "SpiceUsr.h"
         #include "tutils_c.h"
               .
               .
               .
         #define  LB             100
         #define  UB             100
         #define  NRAND          25
         
         SpiceInt                seed = 99999;
         SpiceInt                i;
         SpiceInt                random [ NRAND ];
   
   
         srand ( (unsigned int) seed );
         
         for ( i = 0;  i < NRAND;  i++ )
         {
            random[i] = rani_c ( LB, UB );
         }

 
-Restrictions
 
   None. 
 
-Literature_References
 
   None.
    
-Author_and_Institution
 
   N.J. Bachman   (JPL) 
 
-Version
 
   -CSPICE Version 1.0.0, 25-JUN-1999 (NJB)

-Index_Entries
 
   return random integer from interval 
 
-&
*/

{ /* Begin rani_c */
   
   /*
   Local variables
   */
   SpiceInt                intlen;
   SpiceInt                rn;


   /*
   Find the length of the random number domain.
   */
   intlen    =  ub - lb;
   
   
   /*
   Get a random number in the range 0 to RAND_MAX. Update the seed.
   */
   
   rn = rand();  

   
   /*
   Scale rn so it lies in the range 0 to intlen.
   */
   
   rn *= (  ( (SpiceDouble)intlen ) / RAND_MAX   );
   
   /*
   Shift rn so it lies in the desired interval.
   */
   
   rn += lb;
   
   return ( rn );
   
   
} /* End rani_c */

