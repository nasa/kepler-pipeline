/*

-Procedure f_cell_c ( Test wrappers for cell routines )

 
-Abstract
 
   Perform tests on CSPICE cell wrappers.
    
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
   #include <assert.h>
   #include "SpiceUsr.h"
   #include "SpiceZfc.h"
   #include "SpiceZmc.h"
   #include "SpiceZst.h"
   #include "tutils_c.h"
   

   void f_cell_c ( SpiceBoolean * ok )

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
 
   This routine tests the wrappers for
      
      appndc_c
      appndd_c
      appndi_c
      card_c
      copy_c
      scard_c
      size_c
      ssize_c

   This routine also tests the cell declaration macros
   
      SPICECHAR_CELL
      SPICEDOUBLE_CELL
      SPICEINT_CELL

   and the cell access macros

      SPICE_CELL_ELEM_C
      SPICE_CELL_ELEM_D
      SPICE_CELL_ELEM_I
      SPICE_CELL_GET_C
      SPICE_CELL_GET_D
      SPICE_CELL_GET_I
      SPICE_CELL_SET_C
      SPICE_CELL_SET_D
      SPICE_CELL_SET_I

-Examples
 
   None.
    
-Restrictions
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
 
-Literature_References
 
   None. 
 
-Version
 
   -tspice_c Version 1.1.0 12-FEB-2003 (NJB)

      Bug fix:  cell initialization tests were modified so that
      pointer comparisions are done only when void pointers can be
      correctly cast to type SpiceInt.  On systems where this
      cannot be done, comparisons are done using dereferenced
      pointers.

   -tspice_c Version 1.0.0 22-AUG-2002 (NJB)


-&
*/

{ /* Begin f_cell_c */


   void insrtd_c ( SpiceDouble    item,
                   SpiceCell    * cell );
 
   void insrti_c ( SpiceInt       item,
                   SpiceCell    * cell );
   
   /*
   Constants
   */
   
   #define LNSIZE          81
   #define SHORT           5
   #define N_EQSTR         12
   #define T               SPICETRUE
   #define F               SPICEFALSE
   #define NMAX            5
   #define TOKLEN          11
   #define FRNMLN          33
   #define UNIQUE          1234567
   
   #define CSIZE1          10
   #define CSIZE2          10
   #define CSIZE3          20

   #define DSIZE1          10
   #define DSIZE2          10
   #define DSIZE3          20

   #define ISIZE1          10
   #define ISIZE2          10
   #define ISIZE3          20


   /*
   Local variables
   */
   SPICECHAR_CELL          ( ccell1, CSIZE1,  LNSIZE );
   SPICECHAR_CELL          ( ccell2, CSIZE2,  LNSIZE );
   SPICECHAR_CELL          ( ccell3, CSIZE3,  SHORT  );

   SPICEDOUBLE_CELL        ( dcell1, DSIZE1 );
   SPICEDOUBLE_CELL        ( dcell2, DSIZE2 );
   SPICEDOUBLE_CELL        ( dcell3, DSIZE3 );

   SPICEINT_CELL           ( icell1, ISIZE1 );
   SPICEINT_CELL           ( icell2, ISIZE2 );
   SPICEINT_CELL           ( icell3, ISIZE3 );


   SpiceBoolean            bval;

   SpiceChar               cval    [ LNSIZE ];
   SpiceChar               citem   [ LNSIZE ];
   SpiceChar             * cArray  [ CSIZE1 ] =
                           {
                              "SUN",
                              "MERCURY",
                              "VENUS",
                              "EARTH",
                              "MARS",
                              "JUPITER",
                              "SATURN",
                              "URANUS",
                              "NEPTUNE",
                              "PLUTO"
                           };

   SpiceChar             * cArrayRagged  [ CSIZE1 ] =
                           {
                              "SUN ",
                              "MERCURY  ",
                              "VENUS   ",
                              "EARTH",
                              "MARS ",
                              "JUPITER    ",
                              "SATURN ",
                              "URANUS        ",
                              "NEPTUNE ",
                              "PLUTO "
                           };

   SpiceChar             * sPtr;

   SpiceChar               label   [ LNSIZE ];

   SpiceDouble             dval;

   SpiceInt                i;
   SpiceInt                ival;

   void                  * vPtr;

   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_cell_c" );
   

   /*
   Test declaration macros. 
   */
   tcase_c ( "Make sure icell1 is initialized properly." );   

  
   ival = (SpiceInt) icell1.dtype;
   chcksi_c ( "icell1.dtype", ival, "=", (SpiceInt)SPICE_INT, 0, ok );

   ival = (SpiceInt) icell1.length;
   chcksi_c ( "icell1.length", ival, "=", 0, 0, ok );

   ival = (SpiceInt) icell1.size;
   chcksi_c ( "icell1.size", ival, "=", ISIZE1, 0, ok );

   ival = (SpiceInt) icell1.card;
   chcksi_c ( "icell1.card", ival, "=", 0, 0, ok );

   bval = icell1.isSet;
   chcksl_c ( "icell1.isSet", bval, SPICETRUE, ok );

   bval = icell1.adjust;
   chcksl_c ( "icell1.adjust", bval, SPICEFALSE, ok );

   bval = icell1.init;
   chcksl_c ( "icell1.init", bval, SPICEFALSE, ok );



   /*
   Check pointer initializations.  If we can cast the pointers
   to integers, do so and compare the resulting integers. 
   If not, assign values to the data array at locations 
   indicated by the pointers, and compare these values.
   */
   if ( sizeof(vPtr) == sizeof(SpiceInt) )
   {
      ival = (SpiceInt) icell1.base;
      chcksi_c ( "icell1.base", ival, "=", (SpiceInt)
                  &(SPICE_CELL_icell1[0]) , 0, ok );

      ival = (SpiceInt) icell1.data;
      chcksi_c ( "icell1.data", ival, "=", (SpiceInt)
                  &(SPICE_CELL_icell1[SPICE_CELL_CTRLSZ]) , 0, ok );
   }
   else
   {
      SPICE_CELL_icell1[0] = UNIQUE;

      ival = * ( (SpiceInt *) icell1.base );
      chcksi_c ( "*(icell1.base)", ival, "=", 
                                       SPICE_CELL_icell1[0], 0, ok );
      SPICE_CELL_icell1[0] = 0;

      
      SPICE_CELL_icell1[SPICE_CELL_CTRLSZ] = UNIQUE;

      ival = * ( (SpiceInt *) icell1.data );
      chcksi_c ( "*(icell1.data)", ival, "=", 
                  SPICE_CELL_icell1[SPICE_CELL_CTRLSZ], 0, ok );

      SPICE_CELL_icell1[SPICE_CELL_CTRLSZ] = 0;
   }


   tcase_c ( "Make sure dcell1 is initialized properly." );   

  
   ival = (SpiceInt) dcell1.dtype;
   chcksi_c ( "dcell1.dtype", ival, "=", (SpiceInt)SPICE_DP, 0, ok );

   ival = (SpiceInt) dcell1.length;
   chcksi_c ( "dcell1.length", ival, "=", 0, 0, ok );

   ival = (SpiceInt) dcell1.size;
   chcksi_c ( "dcell1.size", ival, "=", DSIZE1, 0, ok );

   ival = (SpiceInt) dcell1.card;
   chcksi_c ( "dcell1.card", ival, "=", 0, 0, ok );

   bval = dcell1.isSet;
   chcksl_c ( "dcell1.isSet", bval, SPICETRUE, ok );

   bval = dcell1.adjust;
   chcksl_c ( "dcell1.adjust", bval, SPICEFALSE, ok );

   bval = dcell1.init;
   chcksl_c ( "dcell1.init", bval, SPICEFALSE, ok );

   /*
   Check pointer initializations.  If we can cast the pointers
   to integers, do so and compare the resulting integers. 
   If not, assign values to the data array at locations 
   indicated by the pointers, and compare these values.
   */
   if ( sizeof(vPtr) == sizeof(SpiceInt) )
   {
      ival = (SpiceInt) dcell1.base;
      chcksi_c ( "dcell1.base", ival, "=", (SpiceInt)
                  &(SPICE_CELL_dcell1[0]) , 0, ok );

      ival = (SpiceInt) dcell1.data;
      chcksi_c ( "dcell1.data", ival, "=", (SpiceInt)
                  &(SPICE_CELL_dcell1[SPICE_CELL_CTRLSZ]) , 0, ok );
   }
   else
   {
      SPICE_CELL_dcell1[0] = (SpiceDouble)UNIQUE;

      dval = * ( (SpiceDouble *) dcell1.base );
      chcksd_c ( "*(dcell1.base)", dval, "=", 
                                       SPICE_CELL_dcell1[0], 0, ok );
      SPICE_CELL_dcell1[0] = 0;


      SPICE_CELL_dcell1[SPICE_CELL_CTRLSZ] = (SpiceDouble) UNIQUE;

      dval = * ( (SpiceDouble *) dcell1.data );
      chcksd_c ( "*(dcell1.data)", dval, "=", 
                  SPICE_CELL_dcell1[SPICE_CELL_CTRLSZ], 0, ok );
   }


   tcase_c ( "Make sure ccell1 is initialized properly." );   

  
   ival = (SpiceInt) ccell1.dtype;
   chcksi_c ( "ccell1.dtype", ival, "=", (SpiceInt)SPICE_CHR, 0, ok );

   ival = (SpiceInt) ccell1.length;
   chcksi_c ( "ccell1.length", ival, "=", LNSIZE, 0, ok );

   ival = (SpiceInt) ccell1.size;
   chcksi_c ( "ccell1.size", ival, "=", CSIZE1, 0, ok );

   ival = (SpiceInt) ccell1.card;
   chcksi_c ( "ccell1.card", ival, "=", 0, 0, ok );

   bval = ccell1.isSet;
   chcksl_c ( "ccell1.isSet", bval, SPICETRUE, ok );

   bval = ccell1.adjust;
   chcksl_c ( "ccell1.adjust", bval, SPICEFALSE, ok );

   bval = ccell1.init;
   chcksl_c ( "ccell1.init", bval, SPICEFALSE, ok );

   /*
   Check pointer initializations.  If we can cast the pointers
   to integers, do so and compare the resulting integers. 
   If not, assign values to the data array at locations 
   indicated by the pointers, and compare these values.
   */
   if ( sizeof(vPtr) == sizeof(SpiceInt) )
   {
      ival = (SpiceInt) ccell1.base;
      chcksi_c ( "ccell1.base", ival, "=", (SpiceInt)
                  &(SPICE_CELL_ccell1[0]) , 0, ok );

      ival = (SpiceInt) ccell1.data;
      chcksi_c ( "ccell1.data", ival, "=", (SpiceInt)
                  &(SPICE_CELL_ccell1[SPICE_CELL_CTRLSZ]) , 0, ok );
   }
   else
   {
      strcpy ( (SpiceChar*) SPICE_CELL_ccell1[0], "UNIQUE" );

      sPtr =   (SpiceChar *) ccell1.base;
      chcksc_c ( "*(ccell1.base)", sPtr, "=", 
                 (SpiceChar *)SPICE_CELL_ccell1[0], ok );

      SPICE_CELL_ccell1[0][0] = 0;


      strcpy ( (SpiceChar*) SPICE_CELL_ccell1[SPICE_CELL_CTRLSZ], "UNIQUE" );

      sPtr =   (SpiceChar *) ccell1.data;
      chcksc_c ( "*(cell1.data)", sPtr, "=", 
                  SPICE_CELL_ccell1[SPICE_CELL_CTRLSZ], ok );

      SPICE_CELL_ccell1[0][SPICE_CELL_CTRLSZ] = 0;
   }


   /*
   Test initialization and card_c, size_c. 
   */
  
   tcase_c ( "Make sure icell1 is initialized to size ISIZE1 and "
             "cardinality zero."                                  );   

   ival = size_c(&icell1);

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "size", ival, "=", ISIZE1, 0, ok );

   ival = card_c(&icell1);

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "card", ival, "=", 0, 0, ok );


   tcase_c ( "Make sure dcell1 is initialized to size DSIZE1 and "
             "cardinality zero."                                  );   

   ival = size_c(&dcell1);

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "size", ival, "=", DSIZE1, 0, ok );

   ival = card_c(&dcell1);

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "card", ival, "=", 0, 0, ok );


   tcase_c ( "Make sure ccell1 is initialized to size CSIZE1 and "
             "cardinality zero."                                  );   

   ival = size_c(&dcell1);

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "size", ival, "=", DSIZE1, 0, ok );

   ival = card_c(&dcell1);

   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "card", ival, "=", 0, 0, ok );


   /*
   Make sure a cell becomes a set when the cardinality becomes zero. 
   Note that ssize_c always resets the cardinality of a cell to zero.
   */
   tcase_c ( "Make sure a cell becomes a set when card is set to 0." );
   dcell1.isSet = SPICEFALSE;

   scard_c ( 0, &dcell1 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "isSet", dcell1.isSet, SPICETRUE, ok );


   tcase_c ( "Make sure a cell becomes a set when size is reset." );
   dcell1.isSet = SPICEFALSE;

   ssize_c ( DSIZE1, &dcell1 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "isSet", dcell1.isSet, SPICETRUE, ok );




   /*
   size_c error cases: 
   */

   tcase_c ( "Size is negative." );

   dcell1.size = -1;

   ival = size_c(&dcell1);
   chckxc_c ( SPICETRUE, "SPICE(INVALIDSIZE)", ok );

   dcell1.size = DSIZE1;


   /*
   More card_c tests: 
   */

   tcase_c ( "card_c normal case #1:  retrieve non-zero cardinality "
             "from an integer cell."                                 );

   scard_c ( 5, &icell1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   ival = card_c(&icell1);
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "card", ival, "=", 5, 0, ok );



   tcase_c ( "card_c normal case #2:  retrieve non-zero cardinality "
             "from a d.p. cell."                                    );

   scard_c ( 5, &dcell1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   ival = card_c(&dcell1);
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "card", ival, "=", 5, 0, ok );



   tcase_c ( "card_c normal case #3:  retrieve non-zero cardinality "
             "from a character cell."                                 );

   scard_c ( 5, &ccell1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   ival = card_c(&ccell1);
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "card", ival, "=", 5, 0, ok );


   /*
   card_c error cases: 
   */
   tcase_c ( "Cardinality is negative." );

   icell1.card = -1;

   ival = card_c(&icell1);
   chckxc_c ( SPICETRUE, "SPICE(INVALIDCARDINALITY)", ok );

   icell1.card = 0;



   tcase_c ( "Size is negative." );

   dcell1.size = -1;

   ival = card_c(&dcell1);
   chckxc_c ( SPICETRUE, "SPICE(INVALIDSIZE)", ok );

   dcell1.size = DSIZE1;



   tcase_c ( "Cardinality exceeds size." );

   ccell1.card = 2 * CSIZE1;

   ival = card_c(&ccell1);
   chckxc_c ( SPICETRUE, "SPICE(INVALIDCARDINALITY)", ok );



   /*
   scard_c tests: 
   */

   tcase_c ( "scard_c normal case #1:  set the cardinality of "
             "integer cell icell1.  Retrieve the cardinality. "
             "Also make sure the data array has its cardinality "
             "synced."                                            );


   scard_c ( ISIZE1, &icell1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   ival = card_c ( &icell1 );
   chcksi_c ( "card of icell1", ival, "=", ISIZE1, 0, ok );

   ival = cardi_ ( (integer * )(icell1.base) );
   chcksi_c ( "card of icell1's data array", ival, "=", ISIZE1, 0, ok );


   tcase_c ( "scard_c normal case #2:  set the cardinality of "
             "icell1 back to zero."                            );
   scard_c ( 0, &icell1 );
   chcksi_c ( "card of icell1", ival, "=", ISIZE1, 0, ok );

   ival = cardi_ ( (integer * )(icell1.base) );
   chcksi_c ( "card of icell1's data array", ival, "=", 0, 0, ok );




   tcase_c ( "scard_c normal case #3:  set the cardinality of "
             "d.p. cell dcell1.  Retrieve the cardinality. "
             "Also make sure the data array has its cardinality "
             "synced."                                            );


   scard_c ( DSIZE1, &dcell1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   ival = card_c ( &dcell1 );
   chcksi_c ( "card of dcell1", ival, "=", DSIZE1, 0, ok );

   ival = cardd_ ( (doublereal * )(dcell1.base) );
   chcksi_c ( "card of dcell1's data array", ival, "=", ISIZE1, 0, ok );


   tcase_c ( "scard_c normal case #4:  set the cardinality of "
             "dcell1 back to zero."                            );
   scard_c ( 0, &dcell1 );
   chcksi_c ( "card of dcell1", ival, "=", DSIZE1, 0, ok );

   ival = cardd_ ( (doublereal * )(dcell1.base) );
   chcksi_c ( "card of dcell1's data array", ival, "=", 0, 0, ok );



   tcase_c ( "scard_c normal case #5:  set the cardinality of "
             "character cell ccell1.  Retrieve the cardinality. " );


   scard_c ( CSIZE1, &ccell1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   ival = card_c ( &ccell1 );
   chcksi_c ( "card of ccell1", ival, "=", CSIZE1, 0, ok );


   tcase_c ( "scard_c normal case #6:  set the cardinality of "
             "ccell1 back to zero."                            );
   scard_c ( 0, &ccell1 );
   chcksi_c ( "card of ccell1", ival, "=", CSIZE1, 0, ok );




   /*
   scard_c error cases: 
   */
   tcase_c ( "scard_c error case #1:  set the cardinality of "
             "ccell1 to -1."                                   );

   scard_c ( -1, &ccell1 );       
   chckxc_c ( SPICETRUE, "SPICE(INVALIDCARDINALITY)", ok );


   tcase_c ( "scard_c error case #2:  set the cardinality of "
             "dcell1 to -1."                                   );

   scard_c ( -1, &dcell1 );       
   chckxc_c ( SPICETRUE, "SPICE(INVALIDCARDINALITY)", ok );


   tcase_c ( "scard_c error case #3:  set the cardinality of "
             "icell1 to 2*CSIZE1."                              );

   scard_c ( 2*CSIZE1, &icell1 );       
   chckxc_c ( SPICETRUE, "SPICE(INVALIDCARDINALITY)", ok );







   /*
   ssize_c tests: 
   */


   tcase_c ( "ssize_c normal case #1:  set the size of "
             "integer cell icell3.  Retrieve the size and cardinality. "
             "Also make sure the data array has its size and cardinality "
             "synced."                                                   );


   ssize_c ( ISIZE3/2, &icell3 );
   chckxc_c ( SPICEFALSE, " ", ok );

   ival = size_c ( &icell3 );
   chcksi_c ( "size of icell3", ival, "=", ISIZE3/2, 0, ok );

   ival = sizei_ ( (integer * )(icell3.base) );
   chcksi_c ( "size of icell3's data array", ival, "=", ISIZE3/2, 0, ok );

   ival = card_c ( &icell3 );
   chcksi_c ( "card of icell3", ival, "=", 0, 0, ok );

   ival = cardi_ ( (integer * )(icell3.base) );
   chcksi_c ( "card of icell3's data array", ival, "=", 0, 0, ok );


   tcase_c ( "ssize_c normal case #2:  set the size of "
             "icell3 back to ISIZE3."                            );

   ssize_c ( ISIZE3, &icell3 );


   ival = size_c(&icell3);
   chcksi_c ( "size of icell3", ival, "=", ISIZE3, 0, ok );

   ival = sizei_ ( (integer * )(icell3.base) );
   chcksi_c ( "size of icell3's data array", ival, "=", ISIZE3, 0, ok );

   ival = card_c ( &icell3 );
   chcksi_c ( "card of icell3", ival, "=", 0, 0, ok );

   ival = cardi_ ( (integer * )(icell3.base) );
   chcksi_c ( "card of icell3's data array", ival, "=", 0, 0, ok );




   tcase_c ( "ssize_c normal case #3:  set the size and cardinality of "
             "d.p. cell dcell3.  Retrieve the size and cardinality. "
             "Also make sure the data array has its size and cardinality "
             "synced."                                                   );


   ssize_c ( DSIZE3/2, &dcell3 );
   chckxc_c ( SPICEFALSE, " ", ok );

   ival = size_c ( &dcell3 );
   chcksi_c ( "size of dcell3", ival, "=", DSIZE3/2, 0, ok );

   ival = sized_ ( (doublereal * )(dcell3.base) );
   chcksi_c ( "size of dcell3's data array", ival, "=", DSIZE3/2, 0, ok );

   ival = card_c ( &dcell3 );
   chcksi_c ( "card of dcell3", ival, "=", 0, 0, ok );

   ival = cardd_ ( (doublereal * )(dcell3.base) );
   chcksi_c ( "card of dcell3's data array", ival, "=", 0, 0, ok );


   tcase_c ( "ssize_c normal case #4:  set the size of "
             "dcell3 back to DSIZE3."                            );

   ssize_c ( DSIZE3, &dcell3 );

   ival = size_c ( &dcell3 );

   chcksi_c ( "card of dcell3", ival, "=", DSIZE3, 0, ok );

   ival = cardd_ ( (doublereal * )(dcell3.base) );
   chcksi_c ( "card of dcell3's data array", ival, "=", 0, 0, ok );





   tcase_c ( "ssize_c normal case #5:  set the cardinality of "
             "character cell ccell1.  Retrieve the cardinality. " );


   ssize_c ( CSIZE1/2, &ccell1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   ival = size_c ( &ccell1 );
   chcksi_c ( "size of ccell1", ival, "=", CSIZE1/2, 0, ok );

   ival = card_c ( &ccell1 );
   chcksi_c ( "card of ccell1", ival, "=", 0, 0, ok );

   tcase_c ( "ssize_c normal case #6:  set the cardinality of "
             "ccell1 back to CSIZE1."       
                     );
   ssize_c ( CSIZE1, &ccell1 );

   ival = size_c ( &ccell1 );

   chcksi_c ( "card of ccell1", ival, "=", CSIZE1, 0, ok );


   ival = card_c ( &ccell1 );
   chcksi_c ( "card of ccell1", ival, "=", 0, 0, ok );



   /*
   ssize_c error cases: 
   */
   tcase_c ( "ssize_c error case #1:  set the size of "
             "ccell1 to -1."                                   );

   ssize_c ( -1, &ccell1 );       
   chckxc_c ( SPICETRUE, "SPICE(INVALIDSIZE)", ok );


   tcase_c ( "ssize_c error case #2:  set the size of "
             "dcell1 to -1."                                   );

   ssize_c ( -1, &dcell1 );       
   chckxc_c ( SPICETRUE, "SPICE(INVALIDSIZE)", ok );


   tcase_c ( "ssize_c error case #3:  set the size of "
             "icell1 to -1."                                   );

   ssize_c ( -1, &icell1 );       
   chckxc_c ( SPICETRUE, "SPICE(INVALIDSIZE)", ok );





   /*
   Macro tests:  test SPICE_CELL_SET_* and SPICE_CELL_GET_* 
   */

   tcase_c ( "Test SPICE_CELL_SET_I, SPICE_CELL_ELEM_I, "
             "SPICE_CELL_GET_I." );
   

   for ( i = 0;  i < ISIZE1;  i++ )
   {
      SPICE_CELL_SET_I ( i, i, &icell1 );
   }

   for ( i = 0;  i < ISIZE1;  i++ )
   {
      ival = SPICE_CELL_ELEM_I ( &icell1, i );

      sprintf ( label, "element %ld from ELEM macro", i );
      chcksi_c ( label, ival, "=", i, 0, ok );
   }

   for ( i = 0;  i < ISIZE1;  i++ )
   {
      SPICE_CELL_GET_I ( &icell1, i, &ival );

      sprintf ( label, "element %ld from GET macro", i );
      chcksi_c ( label, ival, "=", i, 0, ok );
   }

   /*
   Empty the cell. 
   */
   scard_c ( 0, &icell1 );


 

   tcase_c ( "Test SPICE_CELL_SET_D, SPICE_CELL_ELEM_D, "
             "SPICE_CELL_GET_D." );
   

   for ( i = 0;  i < DSIZE1;  i++ )
   {
      SPICE_CELL_SET_D ( (SpiceDouble)i, i, &dcell1 );
   }

   for ( i = 0;  i < DSIZE1;  i++ )
   {
      dval = SPICE_CELL_ELEM_D ( &dcell1, i );

      sprintf ( label, "element %ld from ELEM macro", i );
      chcksd_c ( label, dval, "=", (SpiceDouble)i, 0.0, ok );
   }

   for ( i = 0;  i < DSIZE1;  i++ )
   {
      SPICE_CELL_GET_D ( &dcell1, i, &dval );

      sprintf ( label, "element %ld from GET macro", i );
      chcksd_c ( label, dval, "=", (SpiceDouble)i, 0, ok );
   }

   /*
   Empty the cell. 
   */
   scard_c ( 0, &dcell1 );




   tcase_c ( "Test SPICE_CELL_SET_C, SPICE_CELL_ELEM_C, "
             "SPICE_CELL_GET_C." );
   

   for ( i = 0;  i < CSIZE1;  i++ )
   {
      SPICE_CELL_SET_C ( cArrayRagged[i], i, &ccell1 );
   }

   for ( i = 0;  i < CSIZE1;  i++ )
   {
      sPtr = SPICE_CELL_ELEM_C ( &ccell1, i );

      sprintf ( label, "element %ld from ELEM macro", i );
      chcksc_c ( label, sPtr, "=", cArray[i], ok );
   }

   for ( i = 0;  i < CSIZE1;  i++ )
   {
      SPICE_CELL_GET_C ( &ccell1, i, LNSIZE, cval );

      sprintf ( label, "element %ld from GET macro", i );
      chcksc_c ( label, cval, "=", cArray[i], ok );
   }

   /*
   Empty the cell. 
   */
   scard_c ( 0, &ccell1 );






   /*
   appndi_c tests:
   */
   tcase_c ( "Test appndi_c:  assign values to an integer cell." );
 
   for ( i = 0;  i < ISIZE1;  i++ )
   {
      appndi_c ( i, &icell1 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   for ( i = 0;  i < ISIZE1;  i++ )
   {
      SPICE_CELL_GET_I ( &icell1, i, &ival );

      chcksi_c ( "ival", ival, "=", i, 0, ok );
   }

   
   tcase_c ( "Check size and cardinality of cell just created." );
   
   ival = size_c ( &icell1 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "size", ival, "=", ISIZE1, 0, ok );
  
   ival = card_c ( &icell1 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "card", ival, "=", ISIZE1, 0, ok );
  

   /*
   Check that the cell is actually a set. 
   */
   chcksl_c ( "isSet", icell1.isSet, SPICETRUE, ok );


   tcase_c ( "Check maintenance of set status by appndi_c." );
   /*
   Append items that will violate the set status of icell1. 
   */
   scard_c  ( 0, &icell1 );

   appndi_c ( 2, &icell1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "isSet", icell1.isSet, SPICETRUE, ok );

   appndi_c ( 1, &icell1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "isSet", icell1.isSet, SPICEFALSE, ok );


   /*
   appndi_c error cases: 
   */
   tcase_c  ( "Try to append to a non-integer cell." );
   
   appndi_c ( 1, &dcell1 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );


   tcase_c  ( "Attempt to over-fill the cell." );
   scard_c  ( ISIZE1, &icell1 );

   appndi_c ( 1, &icell1 );
   chckxc_c ( SPICETRUE, "SPICE(CELLTOOSMALL)", ok );





   tcase_c ( "Test appndd_c:  assign values to a d.p. cell." );
 
   for ( i = 0;  i < DSIZE1;  i++ )
   {
      appndd_c ( (SpiceDouble)i, &dcell1 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   for ( i = 0;  i < DSIZE1;  i++ )
   {
      SPICE_CELL_GET_D ( &dcell1, i, &dval );

      chcksd_c ( "dval", dval, "=", (SpiceDouble)i, 0.0, ok );
   }

   
   /*
   Check size and cardinality of cell just created.
   */     
   ival = size_c ( &dcell1 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "size", ival, "=", DSIZE1, 0, ok );
  
   ival = card_c ( &dcell1 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "card", ival, "=", DSIZE1, 0, ok );
  


   /*
   Check that the cell is actually a set. 
   */
   chcksl_c ( "isSet", dcell1.isSet, SPICETRUE, ok );


   tcase_c ( "Check maintenance of set status by appndd_c." );
   /*
   Append items that will violate the set status of dcell1. 
   */
   scard_c  ( 0, &dcell1 );

   appndd_c ( 2.0, &dcell1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "isSet", dcell1.isSet, SPICETRUE, ok );

   appndd_c ( 2.0, &dcell1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "isSet", dcell1.isSet, SPICEFALSE, ok );


   /*
   appndd_c error cases: 
   */
   tcase_c  ( "Try to append to a non-d.p. cell." );
   
   appndd_c ( 1, &icell1 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );


   tcase_c  ( "Attempt to over-fill the cell." );
   scard_c  ( DSIZE1, &dcell1 );

   appndd_c ( 1, &dcell1 );
   chckxc_c ( SPICETRUE, "SPICE(CELLTOOSMALL)", ok );





   tcase_c ( "Test appndc_c:  assign values to a character cell." );
 
   for ( i = 0;  i < CSIZE1;  i++ )
   {
      sprintf  ( cval, "%ld", i );
      appndc_c ( cval, &ccell1 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   for ( i = 0;  i < CSIZE1;  i++ )
   {
      sprintf  ( cval, "%ld", i );

      SPICE_CELL_GET_C( &ccell1, i, LNSIZE, citem );

      chcksc_c ( "cval", citem, "=", cval, ok );
   }

   /*
   Check size and cardinality of cell just created.
   */       
   ival = size_c ( &ccell1 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "size", ival, "=", CSIZE1, 0, ok );
  
   ival = card_c ( &ccell1 );

   chckxc_c ( SPICEFALSE, " ", ok );
   chcksi_c ( "card", ival, "=", CSIZE1, 0, ok );
  

   /*
   Check that the cell is actually a set. 
   */
   chcksl_c ( "isSet", ccell1.isSet, SPICETRUE, ok );


   tcase_c ( "Check maintenance of set status by appndc_c." );
   /*
   Append items that will violate the set status of ccell1. 
   */
   scard_c  ( 0, &ccell1 );

   appndc_c ( "B", &ccell1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "isSet", ccell1.isSet, SPICETRUE, ok );

   appndc_c ( "A", &ccell1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksl_c ( "isSet", ccell1.isSet, SPICEFALSE, ok );


   /*
   appndc_c error cases: 
   */
   tcase_c  ( "Try to append to a non-character cell." );
   
   appndc_c ( "1", &icell1 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );


   tcase_c  ( "Attempt to over-fill the cell." );
   scard_c  ( CSIZE1, &ccell1 );

   appndc_c ( "a", &ccell1 );
   chckxc_c ( SPICETRUE, "SPICE(CELLTOOSMALL)", ok );



   tcase_c  ( "Cause string truncation while appending" );

   appndc_c ( "1234567", &ccell3 );
   chckxc_c ( SPICEFALSE, " ", ok );

   SPICE_CELL_GET_C( &ccell3, 0, LNSIZE, citem );

   chcksc_c ( "citem", citem, "=", "1234", ok );


   tcase_c  ( "Try to append a null string." );
   
   appndc_c ( NULLCPTR, &ccell1 );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );



   /*
   copy_c tests: 
   */

   tcase_c ( "copy_c normal case #1:  copy an integer cell." );

   scard_c ( 0, &icell1 );
   scard_c ( 0, &icell2 );

   for ( i = 0;  i < ISIZE1;  i++ )
   {
      appndi_c ( -i, &icell1 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   copy_c ( &icell1, &icell2 );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   for ( i = 0;  i < ISIZE1;  i++ )
   {
      SPICE_CELL_GET_I ( &icell2, i, &ival );

      chcksi_c ( "ival", ival, "=", -i, 0, ok );
   }

   tcase_c ( "copy_c normal case #2:  copy a d.p. cell." );

   scard_c ( 0, &dcell1 );
   scard_c ( 0, &dcell2 );

   for ( i = 0;  i < DSIZE1;  i++ )
   {
      appndd_c ( (SpiceDouble)(-i), &dcell1 );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   copy_c ( &dcell1, &dcell2 );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0;  i < DSIZE1;  i++ )
   {
      SPICE_CELL_GET_D ( &dcell2, i, &dval );

      chcksd_c ( "dval", dval, "=",  (SpiceDouble)(-i), 0.0, ok );
   }



   tcase_c ( "copy_c normal case #3:  copy a character cell." );


   scard_c ( 0, &ccell1 );
   scard_c ( 0, &ccell2 );

   for ( i = 0;  i < DSIZE1;  i++ )
   {
      appndc_c ( cArray[i], &ccell1  );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   copy_c ( &ccell1, &ccell2 );
   chckxc_c ( SPICEFALSE, " ", ok );


   for ( i = 0;  i < CSIZE1;  i++ )
   {
      SPICE_CELL_GET_C ( &ccell2, i, LNSIZE, cval );

      chcksc_c ( "cval", cval, "=",  cArray[i],  ok );
   }

   /*
   copy_c error cases: 
   */
   tcase_c  ( "Try to copy an integer cell to a d.p. cell." );

   copy_c ( &icell1, &dcell1 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );


   tcase_c  ( "Try to copy a character cell to a d.p. cell." );

   copy_c ( &ccell1, &dcell1 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );


   tcase_c  ( "Try to copy a d.p. cell to an integer cell." );

   copy_c ( &dcell1, &icell1 );
   chckxc_c ( SPICETRUE, "SPICE(TYPEMISMATCH)", ok );


   tcase_c  ( "Integer copy, target cell is too small." );

   scard_c  ( ISIZE1, &icell1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   ssize_c  ( 2, &icell2 );
   chckxc_c ( SPICEFALSE, " ", ok );

   copy_c ( &icell1, &icell2 );
   chckxc_c ( SPICETRUE, "SPICE(CELLTOOSMALL)", ok );


   tcase_c  ( "D.p. copy, target cell is too small." );

   scard_c  ( DSIZE1, &dcell1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   ssize_c  ( 2, &dcell2 );
   chckxc_c ( SPICEFALSE, " ", ok );

   copy_c ( &dcell1, &dcell2 );
   chckxc_c ( SPICETRUE, "SPICE(CELLTOOSMALL)", ok );


   tcase_c  ( "Character copy, target cell is too small." );

   scard_c  ( CSIZE1, &ccell1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   ssize_c  ( 2, &ccell2 );
   chckxc_c ( SPICEFALSE, " ", ok );

   copy_c ( &ccell1, &ccell2 );
   chckxc_c ( SPICETRUE, "SPICE(CELLTOOSMALL)", ok );



   tcase_c  ( "Character copy, target cell is too narrow." );
   copy_c ( &ccell1, &ccell3 );
   chckxc_c ( SPICETRUE, "SPICE(INSUFFLEN)", ok );





 
   /*
   Retrieve the current test status.
   */ 
   t_success_c ( ok ); 
   
   
} /* End f_cell_c */


