/*

-Procedure f_ek02_c ( Test wrappers for EK routines, subset 1 )

 
-Abstract
 
   Perform tests on CSPICE wrappers for the first subset of EK 
   functions. 
 
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


   void f_ek02_c ( SpiceBoolean * ok )

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
      
      ekappr_c
      ekacec_c
      ekaced_c
      ekacei_c
      ekbseg_c
      ekdelr_c
      ekinsr_c
      ekrcec_c
      ekrced_c
      ekrcei_c
      ekucec_c
      ekuced_c
      ekucei_c

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

{ /* Begin f_ek02_c */

 
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
   Constants
   */
   #define  CNMLEN        SPICE_EK_CSTRLN
   #define  DECLEN        201
   #define  EKNAME        "test.ek"
   #define  FNMLEN        256
   #define  IFNAME        "Test EK/Created 20-SEP-1995"
   #define  LNMLEN        50
   #define  NCOLS         6
   #define  NROWS         100
   #define  NRESVC        0
   #define  TABLE         "SCALAR_DATA"
   #define  TNMLEN        CSPICE_EK_TAB_NAM_LEN
   #define  CVLEN         81
   #define  MAXVAL        10
          
   /*
   Local variables
   */
   SpiceBoolean            isnull;
   SpiceBoolean            xisnull;

   SpiceChar               cdecls  [ NCOLS ] [ DECLEN ];
   SpiceChar               cnames  [ NCOLS ] [ CNMLEN ];
   SpiceChar               cvals   [ MAXVAL ][ CVLEN ];
   SpiceChar               xcvals  [ MAXVAL ][ CVLEN ];
   SpiceChar               label   [ CVLEN ];

   SpiceDouble             dvals   [ MAXVAL ];
   SpiceDouble             xdvals  [ MAXVAL ];

   SpiceInt                handle;
   SpiceInt                i;
   SpiceInt                ivals   [ MAXVAL ];
   SpiceInt                j ;
   SpiceInt                nvals ;
   SpiceInt                xivals  [ MAXVAL ];
   SpiceInt                recno;
   SpiceInt                segno;



   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_ek02_c" );
      
   
   /*
   Case 1:
   */   
   tcase_c ( "Create a new EK using the record-oriented writing routines."  );


   /*   trcoff_c(); */
          
   /*
   Load a leapseconds kernel for UTC/ET conversion.
   */
   tstlsk_c();
   chckxc_c ( SPICEFALSE, " ", ok );
       

   /*
   Open a new EK file.  For simplicity, we will not 
   reserve any space for the comment area, so the 
   number of reserved comment characters is zero. 
   The constant IFNAME is the internal file name. 
   */
   if ( exists_c(EKNAME) )
      {
      TRASH ( EKNAME );
      }

   ekopn_c  ( EKNAME, IFNAME, NRESVC, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
       
   /*
   Set up the table and column names and declarations 
   for the DATAORDERS segment.  We'll index all of 
   the columns.  All columns are scalar, so we omit 
   the size declaration. 
   */
   strcpy ( cnames[0], "INT_COL_1"           );
   strcpy ( cdecls[0], "DATATYPE = INTEGER,"
                       "INDEXED  = TRUE,"
                       "NULLS_OK = TRUE"     );

   strcpy ( cnames[1], "DP_COL_1"                    );
   strcpy ( cdecls[1], "DATATYPE = DOUBLE PRECISION,"
                       "INDEXED  = TRUE,"
                       "NULLS_OK = TRUE"             );

   strcpy ( cnames[2], "CHR_COL_1"                    );
   strcpy ( cdecls[2], "DATATYPE = CHARACTER*(*),"
                       "INDEXED  = TRUE,"
                       "NULLS_OK = TRUE"             );

   strcpy ( cnames[3], "INT_COL_2"           );
   strcpy ( cdecls[3], "DATATYPE = INTEGER,"
                       "SIZE     = VARIABLE,"
                       "NULLS_OK = TRUE"     );

   strcpy ( cnames[4], "DP_COL_2"                    );
   strcpy ( cdecls[4], "DATATYPE = DOUBLE PRECISION,"
                       "SIZE     = VARIABLE,"
                       "NULLS_OK = TRUE"             );

   strcpy ( cnames[5], "CHR_COL_2"                    );
   strcpy ( cdecls[5], "DATATYPE = CHARACTER*(80),"
                       "SIZE     = VARIABLE,"
                       "NULLS_OK = TRUE"             );
       

   /*
   Start the segment. 
   */


   ekbseg_c ( handle,  TABLE,   NCOLS,   CNMLEN,  
              cnames,  DECLEN,  cdecls,  &segno  );
   chckxc_c ( SPICEFALSE, " ", ok );


   /*
   Load a bunch of values into the first integer column.
   */


   for ( i = 0; i < NROWS; i++ )
   {
      ekappr_c ( handle, segno, &recno );
      chckxc_c ( SPICEFALSE, " ", ok );


      ivals[0] = i;
     
      isnull =  ( i == 1 );
 
      ekacei_c ( handle, segno,  recno,  cnames[0], 
                 1,      ivals,  isnull            );
      chckxc_c ( SPICEFALSE, " ", ok );


      dvals[0] = (double)i;

      ekaced_c ( handle, segno,  recno,  cnames[1], 
                 1,      dvals,  isnull            );
      chckxc_c ( SPICEFALSE, " ", ok );

      sprintf ( cvals[0], "%ld", i );

      
      ekacec_c ( handle,   segno,  recno,      cnames[2], 
                 1,        CVLEN,  cvals[0],   isnull     );
      chckxc_c ( SPICEFALSE, " ", ok );
      


      /*
      Array-valued columns follow.
      */
     
      ivals[0] = 10*i;
      ivals[1] = 10*i + 1;

      ekacei_c ( handle, segno,  recno,  cnames[3], 
                 2,      ivals,  isnull            );
      chckxc_c ( SPICEFALSE, " ", ok );

      
      dvals[0] = (double)10*i;
      dvals[1] = (double)10*i+1;
      dvals[2] = (double)10*i+2;

      
      ekaced_c ( handle, segno,  recno,  cnames[4], 
                 3,      dvals,  isnull            );
      chckxc_c ( SPICEFALSE, " ", ok );

     
      sprintf ( cvals[0], "%ld", 10*i    );
      sprintf ( cvals[1], "%ld", 10*i + 1);
      sprintf ( cvals[2], "%ld", 10*i + 2);
      sprintf ( cvals[3], "%ld", 10*i + 3);

      
      ekacec_c ( handle,   segno,  recno,  cnames[5], 
                 4,        CVLEN,  cvals,  isnull     );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   /*
   End the file.
   */

   ekcls_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );


   tcase_c ( "Update the EK: knock out the even-numbered records."  );


   /*
   Open the file for write access.
   */

   ekopw_c ( EKNAME, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   Knock out all of the records containing even numbers.
   */
   

   for ( i = 0;  i < NROWS/2;  i++ )
   {
      ekdelr_c ( handle, 0, i );
      chckxc_c ( SPICEFALSE, " ", ok );
   }


   tcase_c ( "Replace the missing records with records containing "
             "the negatives of the original values."                );


   for ( i = 0; i < NROWS; i+=2 )
   {

      recno = i;

      ekinsr_c ( handle, segno, recno );

      chckxc_c ( SPICEFALSE, " ", ok );
      

      ivals[0] = -i;
     
      isnull =  ( i == 1 );
 
      ekacei_c ( handle, segno,  recno,  cnames[0], 
                 1,      ivals,  isnull            );

      chckxc_c ( SPICEFALSE, " ", ok );
      

      dvals[0] = -(double)i;

      ekaced_c ( handle, segno,  recno,  cnames[1], 
                 1,      dvals,  isnull            );
  
      chckxc_c ( SPICEFALSE, " ", ok );
      


      sprintf ( cvals[0], "%ld", -i );

      ekacec_c ( handle,   segno,  recno,      cnames[2], 
                 1,        CVLEN,  cvals[0],   isnull     );
      chckxc_c ( SPICEFALSE, " ", ok );
      

      /*
      Array-valued columns follow.
      */
     
      ivals[0] = -(10*i);
      ivals[1] = -(10*i + 1);

      ekacei_c ( handle, segno,  recno,  cnames[3], 
                 2,      ivals,  isnull            );
      chckxc_c ( SPICEFALSE, " ", ok );

      

      dvals[0] = -(double)(10*i  );
      dvals[1] = -(double)(10*i+1);
      dvals[2] = -(double)(10*i+2);

      ekaced_c ( handle, segno,  recno,  cnames[4], 
                 3,      dvals,  isnull            );
      chckxc_c ( SPICEFALSE, " ", ok );
     

      sprintf ( cvals[0], "%ld", -(10*i    ) );
      sprintf ( cvals[1], "%ld", -(10*i + 1) );
      sprintf ( cvals[2], "%ld", -(10*i + 2) );
      sprintf ( cvals[3], "%ld", -(10*i + 3) );

      ekacec_c ( handle,   segno,  recno,  cnames[5], 
                 4,        CVLEN,  cvals,  isnull     );
      chckxc_c ( SPICEFALSE, " ", ok );
           

   }


   tcase_c ( "Negate the values in the odd-numbered records "
             "using the update routines." );

   

   for ( i = 1; i < NROWS; i+=2 )
   {
      recno    = i;

      ivals[0] = -i;
     
      isnull   =  ( i == 1 );
 
      ekucei_c ( handle, segno,  recno,  cnames[0], 
                 1,      ivals,  isnull            );
      chckxc_c ( SPICEFALSE, " ", ok );



      dvals[0] = -(double)i;

      ekuced_c ( handle, segno,  recno,  cnames[1], 
                 1,      dvals,  isnull            );
      chckxc_c ( SPICEFALSE, " ", ok );



      sprintf ( cvals[0], "%ld", -i );

      ekucec_c ( handle,   segno,  recno,      cnames[2], 
                 1,        CVLEN,  cvals[0],   isnull     );
      chckxc_c ( SPICEFALSE, " ", ok );


      /*
      Array-valued columns follow.
      */
     
      ivals[0] = -(10*i);
      ivals[1] = -(10*i + 1);

      ekucei_c ( handle, segno,  recno,  cnames[3], 
                 2,      ivals,  isnull            );
      chckxc_c ( SPICEFALSE, " ", ok );

      

      dvals[0] = -(double)(10*i  );
      dvals[1] = -(double)(10*i+1);
      dvals[2] = -(double)(10*i+2);

      ekuced_c ( handle, segno,  recno,  cnames[4], 
                 3,      dvals,  isnull            );
      chckxc_c ( SPICEFALSE, " ", ok );
     

      sprintf ( cvals[0], "%ld", -(10*i    ) );
      sprintf ( cvals[1], "%ld", -(10*i + 1) );
      sprintf ( cvals[2], "%ld", -(10*i + 2) );
      sprintf ( cvals[3], "%ld", -(10*i + 3) );

      ekucec_c ( handle,   segno,  recno,  cnames[5], 
                 4,        CVLEN,  cvals,  isnull     );
      chckxc_c ( SPICEFALSE, " ", ok );
           
   }
   


   /*
   End the file.
   */
   ekcls_c  ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );


   /*
   Open the file for read access; check the values we've written. 
   */

   tcase_c( "Opening the file for read access; checking values using "
            "the EK low-level readers."                              );

   ekopr_c  ( EKNAME, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );

   for ( i = 0; i < NROWS; i++ )
   {
      tstmsg_c ( "#", "Checking row number #." );
      tstmsi_c ( i );
         
      recno = i;

      xivals[0] = -i;

      xisnull =  ( i == 1 );

      ekrcei_c ( handle, segno,  recno,  cnames[0], 
       &nvals, ivals,  &isnull           );
      chckxc_c ( SPICEFALSE, " ", ok );

      chcksl_c ( "Null flag", isnull, xisnull,         ok );
      chcksi_c ( "nvals",     nvals,  "=",     1,  0,  ok );

      if ( !isnull )
      {
         sprintf  ( label, "Column %s", cnames[0] );

         chcksi_c (  label, 
                     ivals[0], 
                     "=", 
                     xivals[0],
                     0,
                     ok           );
      }

      

      xdvals[0] = -(double)i;

      ekrced_c ( handle, segno,  recno,  cnames[1], 
       &nvals, dvals,  &isnull            );
      chckxc_c ( SPICEFALSE, " ", ok );

      chcksl_c ( "Null flag", isnull, xisnull,         ok );
      chcksi_c ( "nvals",     nvals,  "=",     1,  0,  ok );

      if ( !isnull )
      {
         sprintf  ( label, "Column %s", cnames[1] );

         chcksd_c (  label, 
                     dvals[0], 
                     "=", 
                     xdvals[0],
                     0,
                     ok           );
      }



      sprintf ( xcvals[0], "%ld", -i );

      ekrcec_c ( handle,   segno,  recno,      cnames[2], 
                 CVLEN,    &nvals,  cvals[0],  &isnull     );
      chckxc_c ( SPICEFALSE, " ", ok );

      chcksl_c ( "Null flag", isnull, xisnull,         ok );
      chcksi_c ( "nvals",     nvals,  "=",     1,  0,  ok );

      if ( !isnull )
      {
         sprintf  ( label, "Column %s", cnames[2] );

         chcksc_c (  label, 
                     cvals[0], 
                     "=", 
                     xcvals[0],
                     ok           );
      }
     

      /*
      Array-valued columns follow.
      */

      
      xivals[0] = -(10*i);
      xivals[1] = -(10*i + 1);

      ekrcei_c ( handle, segno,  recno,  cnames[3], 
                 &nvals, ivals,  &isnull            );

      chcksl_c ( "Null flag", isnull, xisnull, ok );

      if ( isnull )
      {
         chcksi_c ( "nvals", nvals,  "=",  1,  0,  ok );

      }
      else
      {
         chcksi_c ( "nvals",     nvals,  "=", 2,  0,  ok );
         sprintf  ( label, "Column %s", cnames[3] );

         chckai_c (  label, 
                     ivals, 
                     "=", 
                     xivals,
                     2,
                     ok           );
      }
      


      xdvals[0] = -(double)(10*i  );
      xdvals[1] = -(double)(10*i+1);
      xdvals[2] = -(double)(10*i+2);

      ekrced_c ( handle, segno,  recno,  cnames[4], 
                 &nvals, dvals,  &isnull            );

      chcksl_c ( "Null flag", isnull, xisnull, ok );

      if ( isnull )
      {
         chcksi_c ( "nvals", nvals,  "=",  1,  0,  ok );

      }
      else
      {
         chcksi_c ( "nvals",     nvals,  "=", 3,  0,  ok );

         sprintf  ( label, "Column %s", cnames[4] );

         chckad_c (  label, 
                     dvals, 
                     "=", 
                     xdvals,
                     3,
                     0.0,
                     ok           );
      }
    

      sprintf ( xcvals[0], "%ld", -(10*i    ) );
      sprintf ( xcvals[1], "%ld", -(10*i + 1) );
      sprintf ( xcvals[2], "%ld", -(10*i + 2) );
      sprintf ( xcvals[3], "%ld", -(10*i + 3) );

      ekrcec_c ( handle,   segno,  recno,  cnames[5], 
                 CVLEN,    &nvals, cvals,  &isnull     );
      
      chcksl_c ( "Null flag", isnull, xisnull, ok );

      if ( isnull )
      {
         chcksi_c ( "nvals", nvals,  "=",  1,  0,  ok );

      }
      else
      {
         chcksi_c ( "nvals",     nvals,  "=", 4,  0,  ok );

         sprintf  ( label, "Column %s", cnames[5] );

         for ( j = 0; j < 4; j++ )
         {
             chcksc_c (  label, 
                         cvals[j], 
                         "=", 
                         xcvals[j],
                         ok           );
         }

      }

   }
   /*
   End the file.
   */
   ekcls_c ( handle );


   
   /*
   Clean up the EK file we created.
   */
   TRASH ( EKNAME ); 
   
  
   /*
   Retrieve the current test status.
   */ 
   t_success_c ( ok ); 
   
   
} /* End f_ek02_c */

