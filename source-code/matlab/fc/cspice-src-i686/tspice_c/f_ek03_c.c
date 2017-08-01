/*

-Procedure f_ek03_c ( Test wrappers for EK routines, subset 3 )

 
-Abstract
 
   Perform tests on CSPICE wrappers for subset 3 of EK functions. 
 
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
   #include <stdio.h>
   #include "SpiceUsr.h"
   #include "SpiceZfc.h"
   #include "SpiceZmc.h"
   #include "SpiceEK.h"
   #include "tutils_c.h"
   

   void f_ek03_c ( SpiceBoolean * ok )

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
 
   This routine tests the wrappers for a subset of the EK routines. 
   The subset is:

      ekccnt_c
      ekcii_c
      ekntab_c
      ektnam_c
             
-Examples
 
   None.
    
-Restrictions
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
 
-Literature_References
 
   None. 
 
-Version
 
   -tspice_c Version 1.0.1 20-MAR-2002 (EDW) 

      Replaced remove() calls with TRASH macro.

   -tspice_c Version 1.0.0 07-JAN-2002 (NJB) 
   
-&
*/

{

   /*
   Local macros
   */
   #define TRASH(file)     if ( remove(file) !=0 )                        \
                              {                                           \
                              setmsg_c ( "Unable to delete file #." );    \
                              errch_c  ( "#", file );                     \
                              sigerr_c ( "TSPICE(DELETEFAILED)"  );       \
                              }                                           \
                           chckxc_c ( SPICEFALSE, " ", ok );
 
   /*
   Local constants 
   */

   #define EK1             "test1.ek"
   #define EK2             "test2.ek"
   #define FILEN           256
   #define MAXROW          20
   #define MSGLEN          321

   #define DECLEN          201
   #define IFNLEN          60
   #define NTABS           6   
   #define MAXENT          20
   #define MAXVAL          MAXENT
   #define MAXSTR          1025
   #define CVALSZ          MAXSTR
   #define LNSIZE          81
 
   /*
   Local variables
   */ 
   SpiceBoolean            indexd   [SPICE_EK_MXCLSG];
   SpiceBoolean            nullok   [SPICE_EK_MXCLSG];

   SpiceChar               cnames   [SPICE_EK_MXCLSG][SPICE_EK_CSTRLN];
   SpiceChar               colnam   [SPICE_EK_CSTRLN];
   SpiceChar               msg      [MSGLEN];
   SpiceChar               tabnam   [SPICE_EK_TSTRLN];

   SpiceEKAttDsc           attdsc;

   SpiceEKDataType         dtypes   [SPICE_EK_MXCLSG];

   SpiceInt                cclass   [SPICE_EK_MXCLSG];
   SpiceInt                dims     [SPICE_EK_MXCLSG];
   SpiceInt                fileno;
   SpiceInt                handle;
   SpiceInt                i;
   SpiceInt                ncols;
   SpiceInt                nrows;
   SpiceInt                nseg;
   SpiceInt                ntab;
   SpiceInt                segtyp;
   SpiceInt                stlens   [SPICE_EK_MXCLSG];
   SpiceInt                tab;
   SpiceInt                xncols;

   static SpiceChar        decls    [SPICE_EK_MXCLSG][DECLEN];


   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_ek03_c" );
 
   /*
   Create an EK. 
   */
   fileno = 0;
  
   tstek_c  ( EK1, fileno, MAXROW, SPICEFALSE, &handle, ok );
   chckxc_c ( SPICEFALSE, " ", ok );


   /*
   Find out how many segments are in the EK.  By the specification
   of tstek_c, there's one segment per table. 
   */
   ekopr_c ( EK1, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );

   nseg = eknseg_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );

   tcase_c ( "Test ekntab_c: make sure the number of tables "
             "matches the number of segments in EK1."         );


   /*
   Close the EK. 
   */
   ekcls_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );


   /*
   Load the EK into the query system. 
   */
   furnsh_c ( EK1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   Make a copy of EK1 and load it as well. 
   */
   tstek_c  ( EK2, fileno, MAXROW, SPICEFALSE, &handle, ok );
   chckxc_c ( SPICEFALSE, " ", ok );

   furnsh_c ( EK2 );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   /* 
   Get the number of loaded tables. 
   */
   ekntab_c ( &ntab );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksi_c ( "Number of loaded tables ntab",  ntab, "=", nseg, 0, ok );


   /*
   Here ntab is the number of tables looked up via ekntab_c. 
   */
   for ( tab = 0;  tab < ntab;  tab++ )
   {
      sprintf ( msg, 
                "Testing ektnam_c, ekccnt_c, ekcii_c for table %ld",
                tab                                                 );

      tcase_c ( msg );

      /*
      Get the name of the current table, and look up 
      the column count for this table. 
      */
      ektnam_c ( tab, SPICE_EK_TSTRLN, tabnam );
      chckxc_c ( SPICEFALSE, " ", ok );

      /*
      Look up the schema for this table.
      */
      tstsch_c ( tabnam,  
                 MAXROW,    SPICE_EK_CSTRLN,   DECLEN,   &segtyp,
                 &nrows,    &xncols,           cnames,   cclass,
                 dtypes,    stlens,            dims,     indexd,    
                 nullok,    decls                               );

      chckxc_c ( SPICEFALSE, " ", ok );


      ekccnt_c ( tabnam, &ncols );
      chckxc_c ( SPICEFALSE, " ", ok );

      chcksi_c ( "ncols from ekccnt_c",  ncols, "=", xncols, 0, ok );

      /*
      For each column in the current table, look up the 
      column's attributes.  The attribute block 
      index parameters are defined in the include file 
      ekattdsc.inc. 
      */

      for ( i = 0;  i < ncols;  i++ )
      {
         /*
         Look up the attribute information for the ith column. 
         */
         ekcii_c ( tabnam, i, SPICE_EK_CSTRLN, colnam, &attdsc );
         chckxc_c ( SPICEFALSE, " ", ok );

         /*
         Check the column name. 
         */
         chcksc_c ( "colnam",  colnam, "=", cnames[i], ok );

       
         /*
         Check the current column's class. 
         */
         chcksi_c ( "cclass",  
                   (SpiceInt)attdsc.cclass, "=", cclass[i], 0, ok );

         /*
         Check the current column's data type. 
         */
         chcksi_c ( "dtype",  
                    (SpiceInt)attdsc.dtype, 
                    "=", 
                    (SpiceInt)dtypes[i], 
                    0, ok );

         /*
         If the data type is character, check the string length. 
         */
         if ( attdsc.dtype == SPICE_CHR )
         {
            chcksi_c ( "stlen",  
                       (SpiceInt)attdsc.strlen, 
                       "=", 
                       (SpiceInt)stlens[i], 
                       0, ok );
         }

         /*
         Check the current column's entry size. 
         */
         chcksi_c ( "size",  
                    (SpiceInt)attdsc.size, 
                    "=", 
                    (SpiceInt)dims[i], 
                    0, ok );

         /*
         Check the current column's index flag. 
         */
         chcksl_c ( "indexd",  
                    (SpiceBoolean)attdsc.indexd, 
                    (SpiceBoolean)indexd[i], 
                    ok );

         /*
         Check the current column's null flag. 
         */
         chcksl_c ( "nullok",  
                    (SpiceBoolean)attdsc.nullok, 
                    (SpiceBoolean)nullok[i], 
                    ok );
      }
      /*
      We're done with the current column.
      */
   }
   /*
   We're done with the current table.
   */


   /*
   Clean up the EK files we created.
   */
   unload_c ( EK1 );
   chckxc_c ( SPICEFALSE, " ", ok );

   unload_c ( EK2 );
   chckxc_c ( SPICEFALSE, " ", ok );

   TRASH ( EK1 );    
   TRASH ( EK2 ); 
  
   /*
   Retrieve the current test status.
   */ 
   t_success_c ( ok ); 
   
   
} /* End f_ek03_c */

