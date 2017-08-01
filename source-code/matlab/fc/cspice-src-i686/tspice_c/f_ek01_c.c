/*

-Procedure f_ek01_c ( Test wrappers for EK routines, subset 1 )

 
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
   #include "SpiceZst.h"
   #include "tutils_c.h"
   

   void f_ek01_c ( SpiceBoolean * ok )

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
      
      ekaclc_c
      ekacld_c
      ekacli_c
      ekcls_c
      ekffld_c
      ekfind_c
      ekgc_c
      ekgd_c
      ekgi_c
      ekifld_c
      eklef_c
      eknelt_c
      eknseg_c
      ekopn_c
      ekopr_c
      ekopw_c
      ekpsel_c
      ekssum_c
      ekuef_c
             
-Examples
 
   None.
    
-Restrictions
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
 
-Literature_References
 
   None. 
 
-Version

   -tspice_c Version 2.0.1 20-MAR-2002 (EDW) 

      Replaced remove() calls with TRASH macro.

   -tspice_c Version 2.0.0 10-JAN-2002 (NJB) 
   
      Added test cases to exercise ZZEKTCNV.

      Added test case to make sure DAS links don't accumulate 
      when an already loaded file is reloaded.

   -tspice_c Version 1.1.0 21-SEP-1999 (NJB) 
   
      Made local variables cvals and decls static to accommodate
      the MACPPC_C environment (Code Warrior compiler).
      
      Now unloads EKs before deleting them because the MS Visual C++/C
      compiler requires this (specifically, the files must be closed
      for remove() to delete them).

   -tspice_c Version 1.0.0 26-JUL-1999 (NJB)  

-&
*/

{ /* Begin f_ek01_c */

   
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
   #define BAD_SCLK_STR    "1/2/315662457.1839"
   #define BAD_UTC_STR    "1990 JANN 01 12:00:00"
   #define CK              "SCLKtest.bc"
   #define SCLK_ID         -9
   #define SCLK_NAME       "TEST_SCLK_NAME"
   #define SCLK_NAME2      "TEST_SC_NAME"
   #define SCLK_UNDEF      "UNDEFINED_SCLK"
   #define CVALSZ          MAXSTR
   #define DECLEN          201
   #define EK1             "test1.ek"
   #define EK2             "test2.ek"
   #define FTSIZE          20
   #define IFNLEN          60
   #define LNSIZE          81
   #define MAXENT          20
   #define MAXROW          20
   #define MAXSTR          1025
   #define MAXVAL          MAXENT
   #define MSGLEN          241
   #define NTABS           6   
   #define SCLK            "testsclk.tsc"
   #define SCLK_STR        "1/315662457.1839"
   #define TICK_STR        "315662457.1839"
   #define TIMLEN          50
   #define UTC             "1990 JAN 01 12:00:00"
   

   /*
   Static variables
   */
   static SpiceChar        tables   [ NTABS ][ SPICE_EK_TSTRLN ] =
                           {
                              "SCALAR_1",
                              "SCALAR_2",
                              "SCALAR_3",
                              "SCALAR_4",
                              "VECTOR_1",
                              "VECTOR_2"       
                           };

   /*
   Local variables
   */
   
   integer                 unit;
   integer                 fHandle;
   
   SpiceBoolean            error;
   SpiceBoolean            found;
   SpiceBoolean            indexd   [SPICE_EK_MXCLSG];
   SpiceBoolean            isnull;
   SpiceBoolean            nlflgs   [MAXVAL];
   SpiceBoolean            nullok   [SPICE_EK_MXCLSG];
   SpiceBoolean            xnull;

   SpiceChar               cdata    [CVALSZ];
   SpiceChar               cnames   [SPICE_EK_MXCLSG][SPICE_EK_CSTRLN];
   SpiceChar               column   [SPICE_EK_CSTRLN];
   static SpiceChar        cvals    [MAXVAL         ][CVALSZ];
   static SpiceChar        decls    [SPICE_EK_MXCLSG][DECLEN];
   SpiceChar               errmsg   [MSGLEN         ];
   SpiceChar               query    [SPICE_EK_MAXQRY];
   SpiceChar               tabs     [SPICE_EK_MXCLSG][SPICE_EK_TSTRLN];
   SpiceChar               timstr   [TIMLEN];

   SpiceDouble             ddata    [MAXENT];
   SpiceDouble             dvals    [MAXVAL];
   SpiceDouble             et;
   SpiceDouble             tdata    [MAXENT];
   SpiceDouble             tvals    [MAXENT];
   SpiceDouble             xet;

   SpiceEKDataType         dtype;
   SpiceEKDataType         dtypes   [SPICE_EK_MXCLSG];
   SpiceEKDataType         xtypes   [SPICE_EK_MXCLSG];
   
   SpiceEKSegSum           summary;

   SpiceEKExprClass        xclass   [SPICE_EK_MAXQSEL];
   
   SpiceInt                cclass   [SPICE_EK_MXCLSG];
   SpiceInt                colno;
   SpiceInt                dims     [SPICE_EK_MXCLSG];
   SpiceInt                eltidx;
   SpiceInt                entszs   [MAXVAL];
   SpiceInt                expBegs  [SPICE_EK_MAXQSEL];
   SpiceInt                expEnds  [SPICE_EK_MAXQSEL];
   SpiceInt                expNRows;
   SpiceInt                fileno;
   SpiceInt                handle;
   SpiceInt                i;
   SpiceInt                idata    [MAXENT];
   SpiceInt                ivals    [MAXVAL];
   SpiceInt                n;
   SpiceInt                ncols;
   SpiceInt                nelts;
   SpiceInt                nmrows;
   SpiceInt                nrows;
   SpiceInt                nseg;
   SpiceInt                rcptrs   [MAXVAL];
   SpiceInt                rowno;
   SpiceInt                segno;
   SpiceInt                segtyp;
   SpiceInt                selidx;
   SpiceInt                stlens   [SPICE_EK_MXCLSG];
   SpiceInt                tabno;
   SpiceInt                wkindx   [MAXVAL];
   SpiceInt                xnelts;
   SpiceInt                xbegs  [SPICE_EK_MAXQSEL];
   SpiceInt                xends  [SPICE_EK_MAXQSEL];








   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_ek01_c" );
   

   
   
   /*
   Case 1:
   */
   
    
   
    
   tcase_c ( "Test the EK writing and fast load routines:  " 
             "ekopn_c, ekifld_c, ekaclc_c, ekacld_c, ekacli_c, "
             "ekffld_c, ekcls_c.  Also test ekssum_c.  All of "
             "this is done by tstek_c, which is called here."   );

    
   fileno = 0;
  
   tstek_c  ( EK1, fileno, MAXROW, SPICEFALSE, &handle, ok );
   chckxc_c ( SPICEFALSE, " ", ok );
      
   /*
   Case 2:  
   */
   tcase_c ( "Test ekopr_c, ekssum_c and eknseg_c.  Get segment "
             "summaries and make sure they're compatible with the "
             "schemas returned by tstsch_c."                       );
             
   
   ekopr_c ( EK1, &handle );
   
   nseg = eknseg_c ( handle );
   
   for ( segno = 0;  segno < nseg;  segno++ )
   {
      /*
      Get the summary for this segment.
      */
      ekssum_c ( handle, segno, &summary );
      chckxc_c ( SPICEFALSE, " ", ok );
   

      /*
      Look up the schema for this table.
      */
      tstsch_c ( tables[segno],  
                 MAXROW,         SPICE_EK_CSTRLN,  DECLEN,   &segtyp,
                 &nrows,         &ncols,           cnames,   cclass,
                 dtypes,         stlens,           dims,     indexd,    
                 nullok,         decls                              );

      /*
      Compare the attributes given by the segment summary to those
      returned by tstsch_c.  These are:
       
         - table name
         - column count
         - row count
         - column names
         - column descriptors
         
      For each column descriptor, compare the attributes:
      
         - data type 
         - string length
         - size
         - is the column indexed?
         - does the column allow null values?
         
      */
      chcksc_c ( "table name", 
                 summary.tabnam, 
                 "=", 
                 tables[segno],
                 ok                 );
 
      chcksi_c ( "ncols",  summary.ncols,  "=",  ncols,  0, ok  );
      chcksi_c ( "nrows",  summary.nrows,  "=",  nrows,  0, ok  );

      for ( colno = 0;  colno < ncols;  colno++ )
      {
         tstmsg_c ( "#", "Checking name and attributes of column #." );
         tstmsi_c ( colno );         

         chcksi_c ( "column class", 
                    summary.cdescrs[colno].cclass, 
                    "=", 
                    cclass[colno],
                    0,
                    ok                 );
                    
         chcksc_c ( "column name", 
                    summary.cnames[colno], 
                    "=", 
                    cnames[colno],
                    ok                 );

         chcksi_c ( "data type",  
                     (SpiceInt) summary.cdescrs[colno].dtype,  
                     "=",  
                     (SpiceInt) dtypes[colno],
                     0, 
                     ok  );

         if ( dtypes[colno] == SPICE_CHR )
         {
            chcksi_c ( "string length",  
                        (SpiceInt) summary.cdescrs[colno].strlen,  
                        "=",  
                        stlens[colno],
                        0, 
                        ok  );
         }
      
         chcksi_c ( "dimension",  
                     (SpiceInt) summary.cdescrs[colno].size,  
                     "=",  
                     (SpiceInt) dims[colno],
                     0, 
                     ok  );


         chcksi_c ( "index flag",  
                     (SpiceInt) summary.cdescrs[colno].indexd,  
                     "=",  
                     (SpiceInt) indexd[colno],
                     0, 
                     ok  );

         chcksi_c ( "nulls allowed flag",  
                     (SpiceInt) summary.cdescrs[colno].nullok,  
                     "=",  
                     (SpiceInt) nullok[colno],
                     0, 
                     ok  );
      }
      
   }
   
   ekcls_c ( handle );
   
   
   /*
   Case 3:
   */
   eklef_c ( EK1, &handle );
   
     
   
   tcase_c ( "Ah, the nitty gritty.  Test ekfind_c, enelt_c, and "
             "the fetching triplets ekgc_c, ekgd_c, ekgi_c."       );
             
   /*
   We start off with a simple case.
   */
   
   strcpy ( query, 
            "Select c_col_1, d_col_1, i_col_1, t_col_1 from scalar_2 "
            "order by row_no"                                         );
           
   ekfind_c ( query, MSGLEN, &nmrows, &error, errmsg );
           
   tstmsg_c ( "#", "The error message was:  #" );
   tstmsc_c ( errmsg );
   
   
   chckxc_c ( SPICEFALSE, " ", ok );
             
   chcksl_c ( "error", error, SPICEFALSE, ok );

   /*
   The table "scalar_2" occupies the second segment of the file 
   designated by EK1.  Segment numbers start at 0 and increment from 
   there.
   */
   
   segno = 1;
   
   ekssum_c ( handle, segno, &summary );
   
   nrows = summary.nrows;

   chcksi_c ( "nmrows", nmrows, "=", nrows, 0, ok );
   
   /*
   Check the data.
   */
   for ( rowno = 0;  rowno < nmrows;  rowno++ )
   {
   
      /*
      First, fetch and test the character data.
      */
      
      
      selidx = 0;
      eltidx = 0;
      
      tstmsg_c ( "#", "table = SCALAR_2; selidx = 0; col = c_col_1; " 
                      "row = #; eltidx = 0;"                         );
      tstmsi_c ( rowno );
                      
      ekgc_c ( selidx, rowno, eltidx, CVALSZ, cdata, &isnull, &found );
      
      chckxc_c ( SPICEFALSE, " ", ok );
      
      chcksl_c ( "found", found, SPICETRUE, ok );
      

      /*
      Look up the expected column entry.
      */
      
      tstent_c ( fileno, "SCALAR_2", segno,  "C_COL_1", rowno,  MAXVAL,
                 CVALSZ, &xnelts,    cvals,   dvals,    ivals,  tvals,
                 &xnull                                               );

      chckxc_c ( SPICEFALSE, " ", ok );

      
      /*
      Check the null flag returned by ekgc_c.
      */
      chcksl_c ( "isnull", isnull, xnull, ok );


      /*
      Check the number of elements in the entry.
      */
      
      nelts = eknelt_c ( selidx, rowno );
      
      chcksi_c ( "nelts", nelts, "=", xnelts, 0, ok );

   
      if ( !isnull )
      {
         
         /*
         Check the character string returned by ekgc_c.
         */            
         chcksc_c ( "char value from ekgc_c", 
                    cdata, 
                    "=", 
                    (SpiceChar * )cvals,
                    ok                 );
      }
   
   
      
      /*
      Check the d.p. data next.
      */

      selidx = 1;
      eltidx = 0;
      
      tstmsg_c ( "#", "table = SCALAR_2; selidx = 1; col = D_COL_1; " 
                      "row = #; eltidx = 0;"                         );
      tstmsi_c ( rowno );
      
      ekgd_c ( selidx, rowno, eltidx, ddata, &isnull, &found );
      
      chckxc_c ( SPICEFALSE, " ", ok );
      
      chcksl_c ( "found", found, SPICETRUE, ok );
      

      /*
      Look up the expected column entry.
      */
      
      tstent_c ( fileno, "SCALAR_2", segno,  "D_COL_1", rowno,  MAXVAL,
                 CVALSZ, &xnelts,    cvals,   dvals,    ivals,  tvals,
                 &xnull                                               );
      chckxc_c ( SPICEFALSE, " ", ok );

      
      /*
      Check the null flag returned by ekgd_c.
      */
      chcksl_c ( "isnull", isnull, xnull, ok );


      /*
      Check the number of elements in the entry.
      */
      
      nelts = eknelt_c ( selidx, rowno );
      
      chcksi_c ( "nelts", nelts, "=", xnelts, 0, ok );

   
   
      if ( !isnull )
      {
         /*
         Check the d.p. value returned by ekgd_c.
         */            
         chcksd_c ( "d.p. value from ekgd_c", 
                    ddata[0], 
                    "=", 
                    dvals[0],
                    0.0,
                    ok                 );
      }

      /*
      Integer data.
      */
      
      
      selidx = 2;
      eltidx = 0;
      
      tstmsg_c ( "#", "table = SCALAR_2; selidx = 2; col = I_COL_1; " 
                      "row = #; eltidx = 0;"                         );
      tstmsi_c ( rowno );
      ekgi_c ( selidx, rowno, eltidx, idata, &isnull, &found );
      
      chckxc_c ( SPICEFALSE, " ", ok );
      
      chcksl_c ( "found", found, SPICETRUE, ok );
      

      /*
      Look up the expected column entry.
      */
      
      tstent_c ( fileno, "SCALAR_2", segno,  "I_COL_1", rowno,  MAXVAL,
                 CVALSZ, &xnelts,    cvals,   dvals,    ivals,  tvals,
                 &xnull                                               );
      chckxc_c ( SPICEFALSE, " ", ok );

      
      /*
      Check the null flag returned by ekgi_c.
      */
      chcksl_c ( "isnull", isnull, xnull, ok );


      /*
      Check the number of elements in the entry.
      */
      
      nelts = eknelt_c ( selidx, rowno );
      
      chcksi_c ( "nelts", nelts, "=", xnelts, 0, ok );

   
      if ( !isnull )
      {
         /*
         Check the integer value returned by ekgi_c.
         */            
         chcksi_c ( "Integer value from ekgi_c", 
                    idata[0], 
                    "=", 
                    ivals[0],
                    0.0,
                    ok                 );
      }


      /*
      Time data.
      */

      selidx = 3;
      eltidx = 0;
      
      tstmsg_c ( "#", "table = SCALAR_2; selidx = 3; col = T_COL_1; " 
                      "row = #; eltidx = 0;"                         );
      tstmsi_c ( rowno );
      
      ekgd_c ( selidx, rowno, eltidx, tdata, &isnull, &found );
      
      chckxc_c ( SPICEFALSE, " ", ok );
      
      chcksl_c ( "found", found, SPICETRUE, ok );
      

      /*
      Look up the expected column entry.
      */
      
      tstent_c ( fileno, "SCALAR_2", segno,  "T_COL_1", rowno,  MAXVAL,
                 CVALSZ, &xnelts,    cvals,   dvals,    ivals,  tvals,
                 &xnull                                               );
      chckxc_c ( SPICEFALSE, " ", ok );

      
      /*
      Check the null flag returned by ekgd_c.
      */
      chcksl_c ( "isnull", isnull, xnull, ok );


      /*
      Check the number of elements in the entry.
      */
      
      nelts = eknelt_c ( selidx, rowno );
      
      chcksi_c ( "nelts", nelts, "=", xnelts, 0, ok );

   
   
      if ( !isnull )
      {
         /*
         Check the d.p. value returned by ekgd_c.
         */            
         chcksd_c ( "Time. value from ekgd_c", 
                    tdata[0], 
                    "=", 
                    tvals[0],
                    0.0,
                    ok                 );
      }
   }
   
   
   
   
   /*
   Cases 4-9:
   */
   
   for ( tabno =  0;  tabno < NTABS;  tabno++ ) 
   {

      tcase_c ( "This is a more involved version of Case 3.  "
                "This time, we loop over all tables, and we check "
                "all entries in each table."                       );
               
      /*
      Get the row and column count for this table.
      */ 
      segno = tabno;
      
      ekssum_c ( handle, segno, &summary );
      
      nrows = summary.nrows;
      ncols = summary.ncols;
      

      /*
      Build the query string:  select all columns from the current
      table.
      */      
      strcpy ( query, "Select "         );
      strcat ( query, summary.cnames[0] );
      
      for ( colno = 1;  colno < ncols;  colno++ )
      {
         strcat ( query, ", "                  );
         strcat ( query, summary.cnames[colno] );
      }
      
      strcat ( query, " from "                );
      strcat ( query, tables[tabno]           );
      strcat ( query, " order by ROW_NO"      );
          
      ekfind_c ( query, MSGLEN, &nmrows, &error, errmsg );

      tstmsg_c ( "#", "The error message was:  #" );
      tstmsc_c ( errmsg );
    
      /*
      Make sure there was no query resolution error.
      */
      chckxc_c ( SPICEFALSE, " ", ok );
      chcksl_c ( "error", error, SPICEFALSE, ok );


      /*
      Check nmrows.
      */
      chcksi_c ( "nmrows", nmrows, "=", nrows, 0, ok );           
           
      
      /*
      Check the data.
      */
      ncols = summary.ncols;
      
      for ( rowno = 0;  rowno < nmrows;  rowno++ )
      {              
      
         for ( selidx = 0;  selidx < ncols;  selidx++ )
         {
            tstmsg_c ( "#", "" );
            tstmsi_c ( selidx );

            /*
            Get the name and data type of the current column; process 
            the column accordingly.
            */
            
            strcpy ( column, summary.cnames[selidx] );
            
            dtype = summary.cdescrs[selidx].dtype;
            
   
            tstmsg_c ( "#", "Table is #. Column is #. Row is #. "
                            "Current select index is #." );
            tstmsc_c ( tables[tabno] );
            tstmsc_c ( column        );
            tstmsi_c ( rowno         );
            tstmsi_c ( selidx        );

            
            /*
            Look up the expected column entry.
            */
            tstent_c ( fileno, 
                       tables[tabno], 
                       segno,  
                       column, 
                       rowno,  
                       MAXVAL,
                       CVALSZ, 
                       &xnelts,    
                       cvals,   
                       dvals,    
                       ivals,  
                       tvals,
                       &xnull        );
                       
            chckxc_c ( SPICEFALSE, " ", ok );


            /*
            Get and check the number of elements in the entry.
            */            
            nelts = eknelt_c ( selidx, rowno );
            
            chcksi_c ( "nelts", nelts, "=", xnelts, 0, ok );

                        
            /*
            Time to check the data.
            */            
            for ( eltidx = 0;  eltidx < nelts;  eltidx++ )
            {
               tstmsg_c ( "#", 
                          "Table = #; Column = #; "
                          "Row = #; Elt = #"        );
   
               tstmsc_c ( tables[tabno] );
               tstmsc_c ( column        );
               tstmsi_c ( rowno         );
               tstmsi_c ( eltidx        );
                     
               switch ( dtype )
               {
                  case SPICE_CHR:
                  
                     ekgc_c ( selidx, rowno, eltidx, 
                              CVALSZ, cdata, &isnull, &found );
      
                     /*
                     Make sure no error was signaled.
                     */
                     chckxc_c ( SPICEFALSE, " ", ok );
                     
                     /*
                     Make sure the element was found.
                     */
                     chcksl_c ( "found", found, SPICETRUE, ok );
      
                     /*
                     Check the null flag returned by ekgc_c.
                     */
                     chcksl_c ( "isnull", isnull, xnull, ok );
   
   
                     if ( !isnull )
                     {
                     /*
                     Check the character string returned by ekgc_c.
                     */            
                     chcksc_c ( "char value from ekgc_c", 
                                cdata, 
                                "=", 
                                (SpiceChar * )cvals[eltidx],
                                ok                              );
                     }
            
                     break;
                     
                     
                     
                     
                  case SPICE_DP:
                  
                     ekgd_c ( selidx,        rowno,   eltidx, 
                              ddata+eltidx,  &isnull, &found  );
         
                     chckxc_c ( SPICEFALSE, " ",    ok            );
                     chcksl_c ( "found",    found,  SPICETRUE, ok );
                     chcksl_c ( "isnull",   isnull, xnull,     ok );
            
   
                     if ( !isnull )
                     {
                        /*
                        Check the d.p. value returned by ekgd_c.
                        */            
                        chcksd_c ( "d.p. values from ekgd_c", 
                                   ddata[eltidx], 
                                   "=", 
                                   dvals[eltidx],
                                   0.0,
                                   ok                            );
                     }
                     break;
                  
                  
                     
                  case SPICE_INT:
                  
                     ekgi_c ( selidx,        rowno,   eltidx, 
                              idata+eltidx,  &isnull, &found  );
         
                     chckxc_c ( SPICEFALSE, " ",    ok            );
                     chcksl_c ( "found",    found,  SPICETRUE, ok );
                     chcksl_c ( "isnull",   isnull, xnull,     ok );
            
                     if ( !isnull )
                     {
                        chcksi_c ( "Integer value from ekgi_c", 
                                   idata[eltidx], 
                                   "=", 
                                   ivals[eltidx],
                                   0.0,
                                   ok                 );
                     }
                     break;
         
         
                     
                  case SPICE_TIME:
                  
   
                     ekgd_c ( selidx,        rowno,   eltidx, 
                              tdata+eltidx,  &isnull, &found  );
         
                     chckxc_c ( SPICEFALSE, " ",    ok            );
                     chcksl_c ( "found",    found,  SPICETRUE, ok );
                     chcksl_c ( "isnull",   isnull, xnull,     ok );
            
                     if ( !isnull )
                     {
                        /*
                        Check the d.p. value returned by ekgd_c.
                        */            
                        chcksd_c ( "Time values from ekgd_c", 
                                   tdata[eltidx], 
                                   "=", 
                                   tvals[eltidx],
                                   0.0,
                                   ok                            );
                     }
                     break;
                     
                     
                                       
                  default:
               
                     erract_c ( "SET", LNSIZE, "ABORT"  ); 
                     errdev_c ( "SET", LNSIZE, "SCREEN" ); 
                     errprt_c ( "SET", LNSIZE, "ALL"    ); 
               
                     chkin_c  ( "f_ek01_c"                           );
                     setmsg_c ( "Unrecognized datatype # found for "
                                "column number #."                   );
                     errint_c ( "#", (SpiceInt)dtypes[colno]         );
                     errint_c ( "#", colno                           );
                     sigerr_c ( "SPICE(BUG)"                         );
                     chkout_c ( "f_ek01_c"                           );
                     return;
   
               }
               /*
               End switch.
               */
               
            }
            /*
            End loop over element indices.
            */
         }
         /*
         Done with the current column.
         */
      }
      /*
      Done with the current row.
      */
   
   }
   /*
   Done with the current table.
   */
   
   ekuef_c ( handle );
   
   
   
   
   /*
   Case 10:
   */
   
   tcase_c ( "Open a scratch EK.  Write to it.  Make sure the data's "
             "there.  Close it.  Make sure it goes away."            );
             
             
   ekops_c  ( &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   ekifld_c ( handle,
              "TABLE_1",
              1,
              1,
              SPICE_EK_CSTRLN,
              "COL_1",
              DECLEN,
              "DATATYPE = INTEGER",
              &segno,
              rcptrs                );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   nlflgs[0] = SPICEFALSE;
   entszs[0] = 1;
   ivals [0] = 99;
   
   ekacli_c ( handle,  segno,   "COL_1",  ivals, 
              1,       nlflgs,  rcptrs,   wkindx );
   chckxc_c ( SPICEFALSE, " ", ok );


   /*
   Finish the fast load for this table.
   */
   ekffld_c ( handle, segno, rcptrs );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   /*
   Get the summary for the table.
   */
   ekssum_c ( handle, segno, &summary );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   Check the table and column name.  That's enough.
   */
   chcksc_c ( "Table name",  summary.tabnam,    "=", "TABLE_1", ok );
   chcksc_c ( "Column name", summary.cnames[0], "=", "COL_1",   ok );
            
      
   /*
   Close this file.
   */
   ekcls_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   /*
   Is the file still there?  Shouldn't be.
   */
   
   fHandle = handle;
   
   dashlu_ ( &fHandle, &unit );
   chckxc_c ( SPICETRUE, "SPICE(DASNOSUCHHANDLE)", ok );
   


             
   /*
   Case 11:
   */
   
   tcase_c ( "Open an EK.  Write to it.  Make sure the data's "
             "there.  Close it.  Open it for appending.  Write some "
             "more.  Make sure the data's there."                    );
             
             
   tstmsg_c ( "#", "About to open EK file #." );
   tstmsc_c ( EK2                             );
   
   if ( exists_c (EK2) )
      {
      TRASH (EK2);
      } 
   
   ekopn_c  ( EK2, EK2, 0, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   tstmsg_c ( "#", "About to initiate fast load of table #." );
   tstmsc_c ( "TABLE_1"                                      );
   ekifld_c ( handle,
              "TABLE_1",
              1,
              1,
              SPICE_EK_CSTRLN,
              "COL_1",
              DECLEN,
              "DATATYPE = INTEGER",
              &segno,
              rcptrs                );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   nlflgs[0] = SPICEFALSE;
   entszs[0] = 1;
   ivals [0] = 100;
   
   ekacli_c ( handle,  segno,   "COL_1",  ivals, 
              1,       nlflgs,  rcptrs,   wkindx );
   chckxc_c ( SPICEFALSE, " ", ok );


   /*
   Finish the fast load for this table.
   */
   ekffld_c ( handle, segno, rcptrs );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   /*
   Get the summary for the table.
   */
   ekssum_c ( handle, segno, &summary );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   Check the table and column name.  That's enough.
   */
   chcksc_c ( "Table name",  summary.tabnam,    "=", "TABLE_1", ok );
   chcksc_c ( "Column name", summary.cnames[0], "=", "COL_1",   ok );
            
      
   /*
   Close this file.
   */
   ekcls_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );
             
   /*
   Now open the file for write access and add more data.
   */     
         
   tstmsg_c ( "#", "About to open EK file # for appending." );
   tstmsc_c ( EK2                                           );
   ekopw_c  ( EK2, &handle );      
   chckxc_c ( SPICEFALSE, " ", ok );
              
   ekifld_c ( handle,
              "TABLE_2",
              1,
              1,
              SPICE_EK_CSTRLN,
              "COL_2",
              DECLEN,
              "DATATYPE = INTEGER",
              &segno,
              rcptrs                );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   nlflgs[0] = SPICEFALSE;
   entszs[0] = 1;
   ivals [0] = 200;
   
   ekacli_c ( handle,  segno,   "COL_2",  ivals, 
              1,       nlflgs,  rcptrs,   wkindx );
   chckxc_c ( SPICEFALSE, " ", ok );


   /*
   Finish the fast load for this table.
   */
   ekffld_c ( handle, segno, rcptrs );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   /*
   Close this file.
   */
   ekcls_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   Open the file for read access.
   */

   tstmsg_c ( "#", "About to open EK file # for read access." );
   tstmsc_c ( EK2                                             );
   
   ekopr_c ( EK2, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   /*
   Get the summary for the table.
   */
   ekssum_c ( handle, segno, &summary );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   Check the table and column name.  That's enough.
   */
   chcksc_c ( "Table name",  summary.tabnam,    "=", "TABLE_2", ok );
   chcksc_c ( "Column name", summary.cnames[0], "=", "COL_2",   ok );
            
   /*
   Close this file.
   */
   ekcls_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );


   
   
   /*
   Case 12:
   */
   
   tcase_c ( "Test ekpsel_c.  Build a query with a complex "
             "SELECT clause; tear it apart with ekpsel_c. "
             "Verify that ekpsel_c identifies the columns' "
             "attributes correctly."                         );

   /*
   Get segment summary for the SCALAR_2 table.
   */ 
   
   eklef_c ( EK1, &handle );
   
   segno = 1;
   
   ekssum_c ( handle, segno, &summary );
   
   ncols = summary.ncols;
   


   /*
   Build the query string:  select all columns from the current
   table.  Save the beginning and end locations of the column name
   tokens.
   */
   
   strcpy ( query, "Select " );
   
   expBegs[0]  =  strlen(query);
   
   strcat ( query, summary.cnames[0] );
   
   expEnds[0]  =  strlen(query) - 1;
   
   for ( colno = 1;  colno < ncols;  colno++ )
   {
      strcat ( query, ", " );
      
      expBegs[colno]  =  strlen(query);
      
      strcat ( query, summary.cnames[colno] );
      
      expEnds[colno]  =  strlen(query) - 1;
   }
   
   strcat ( query, " from "                );
   strcat ( query, "SCALAR_2"              );
   strcat ( query, " order by ROW_NO"      );
       

   /*
   Analyze the query.
   */
   ekpsel_c ( query,  MSGLEN, SPICE_EK_TSTRLN, SPICE_EK_CSTRLN,
              &n,     xbegs,  xends,           xtypes,
              xclass, tabs,   cnames,          &error,         errmsg );

   chckxc_c ( SPICEFALSE, " ", ok );
   
   chcksl_c ( "error", error, SPICEFALSE, ok );
   
   chcksi_c ( "strlen(Error message)", 
               strlen(errmsg), "=", 0, 0, ok );

   if ( strlen(errmsg) > 0 )
   {
      chcksc_c ( "error message", errmsg, "=", " ", ok );
   }
   
   chcksi_c ( "number of SELECT expressions", n, "=", ncols, 0, ok );
   
   chckai_c ( "xbegs", xbegs, "=", expBegs, n, ok );
   chckai_c ( "xends", xends, "=", expEnds, n, ok );
   
   for ( i = 0; i < n; i++ )
   {
      chcksc_c ( "Column name", cnames[i], "=", summary.cnames[i], ok );
      chcksc_c ( "Table",       tabs[i],   "=", summary.tabnam,    ok );
      
      chcksi_c ( "Data type", 
                 (int)xtypes[i], 
                 "=", 
                 (int)summary.cdescrs[i].dtype,
                 0,
                 ok                             );
                 
      chcksi_c ( "Expression class", 
                 (int)xclass[i], 
                 "=", 
                 (int)SPICE_EK_EXP_COL,
                 0,
                 ok                             );
   }
   
   
   ekuef_c ( handle );
   
   
   /*
   Case 13:
   */
   

   tcase_c ( "Test sorting:  select rows from scalar_2, ordering "
             "by c_col_2"                                          );
             
   eklef_c ( EK1, &handle );

   strcpy ( query, "select c_col_2 from scalar_2 "
                   "where "
                   "(c_col_2 between "
                   "'SEG_2_C_COL_2_ROW_10_' "
                   "and "
                   "'SEG_2_C_COL_2_ROW_19') "
                   "or "
                   "c_col_2 like 'X*' "
                   "order by c_col_2"            );

   ekfind_c ( query, MSGLEN, &nmrows, &error, errmsg );

   tstmsg_c ( "#", "The error message was:  #" );
   tstmsc_c ( errmsg );
 
   /*
   Make sure there was no query resolution error.
   */
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "error", error, SPICEFALSE, ok );

   if ( !error )
   {
      /*
      Check nmrows.
      */
      expNRows = 5;
      chcksi_c ( "nmrows", nmrows, "=", expNRows, 0, ok );           
           
      
      for ( rowno = 0;  rowno < expNRows;  rowno++ )
      {              
         selidx = 0;
         eltidx = 0;
   
         
         /*
         Look up the expected column entry. Skip  over null entries.
         */
         tstent_c ( 1, 
                    "SCALAR_2", 
                    1,  
                    "C_COL_2", 
                    9 + 2*rowno,  
                    MAXVAL,
                    CVALSZ, 
                    &xnelts,    
                    cvals,   
                    dvals,    
                    ivals,  
                    tvals,
                    &xnull        );
                    
         chckxc_c ( SPICEFALSE, " ", ok );
   
         ekgc_c ( selidx, rowno, eltidx, 
                  CVALSZ, cdata, &isnull, &found );
   
         /*
         Make sure no error was signaled.
         */
         chckxc_c ( SPICEFALSE, " ", ok );
         
         /*
         Make sure the element was found.
         */
         chcksl_c ( "found", found, SPICETRUE, ok );
   
         /*
         Check the null flag returned by ekgc_c.
         */
         chcksl_c ( "isnull", isnull, xnull, ok );
   
   
         if ( !isnull )
         {
         
         
         /*
         Check the character string returned by ekgc_c.
         */            
         chcksc_c ( "char value from ekgc_c", 
                    cdata, 
                    "=", 
                    (SpiceChar * )cvals[eltidx],
                    ok                              );
         }
      }
   }
   
   /*
   Do the same query, but sort in descending order.
   */
   strcpy ( query, "select c_col_2 from scalar_2 "
                   "where "
                   "(c_col_2 between "
                   "'SEG_2_C_COL_2_ROW_10_' "
                   "and "
                   "'SEG_2_C_COL_2_ROW_19') "
                   "or "
                   "c_col_2 like 'X*' "
                   "order by c_col_2 desc"      );
                   
   ekfind_c ( query, MSGLEN, &nmrows, &error, errmsg );

   tstmsg_c ( "#", "The error message was:  #" );
   tstmsc_c ( errmsg );
 
   /*
   Make sure there was no query resolution error.
   */
   chckxc_c ( SPICEFALSE, " ", ok );
   chcksl_c ( "error", error, SPICEFALSE, ok );

   if ( !error )
   {
      /*
      Check nmrows.
      */
      expNRows = 5;
      chcksi_c ( "nmrows", nmrows, "=", expNRows, 0, ok );           
           
      
      for ( rowno = 0;  rowno < expNRows;  rowno++ )
      {              
         selidx = 0;
         eltidx = 0;
   
         
         /*
         Look up the expected column entry. Skip  over null entries.
         */
         tstent_c ( 1, 
                    "SCALAR_2", 
                    1,  
                    "C_COL_2", 
                    17 - 2*rowno,  
                    MAXVAL,
                    CVALSZ, 
                    &xnelts,    
                    cvals,   
                    dvals,    
                    ivals,  
                    tvals,
                    &xnull        );
                    
         chckxc_c ( SPICEFALSE, " ", ok );
   
         ekgc_c ( selidx, rowno, eltidx, 
                  CVALSZ, cdata, &isnull, &found );
   
         /*
         Make sure no error was signaled.
         */
         chckxc_c ( SPICEFALSE, " ", ok );
         
         /*
         Make sure the element was found.
         */
         chcksl_c ( "found", found, SPICETRUE, ok );
   
         /*
         Check the null flag returned by ekgc_c.
         */
         chcksl_c ( "isnull", isnull, xnull, ok );
   
   
         if ( !isnull )
         {
                  
            /*
            Check the character string returned by ekgc_c.
            */            
            chcksc_c ( "char value from ekgc_c", 
                       cdata, 
                       "=", 
                       (SpiceChar * )cvals[eltidx],
                       ok                              );
         }
      }
   }
   
   ekuef_c ( handle );
   



   /*
   Case 14:
   */   
   tcase_c ( "ekuef_c; make sure we don't accumulate DAS links "
             "when we reload a file repeatedly."                 );


   for ( i = 0;  i < 2*FTSIZE;  i++ )
   {
      eklef_c ( EK1, &handle );
      chckxc_c ( SPICEFALSE, " ", ok );
   }

   ekuef_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );

   dasfnh_ ( EK1, &handle, strlen(EK1) );
   chckxc_c ( SPICETRUE, "SPICE(DASNOSUCHFILE)", ok );



   /*
   Case 15:
   */   
   tcase_c ( "Test zzektcnv_; convert SCLK string." );

   /*
   Create an SCLK kernel.  The routine we use for this purpose
   also creates a C-kernel, which we don't need.
   */
   tstlsk_c ( );
   chckxc_c ( SPICEFALSE, " ", ok );

   tstck3_c ( CK, SCLK, SPICEFALSE, SPICETRUE, SPICEFALSE, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );

   boddef_c ( SCLK_NAME, SCLK_ID );
   chckxc_c ( SPICEFALSE, " ", ok );

   /*
   Convert an SCLK string to ET; make sure we get the same result
   returned by scs2e_c. 
   */
   scs2e_c  ( SCLK_ID, SCLK_STR, &xet );
   chckxc_c ( SPICEFALSE, " ", ok );

   sprintf ( timstr, "%s SCLK %s", SCLK_NAME, SCLK_STR );
   
   zzektcnv_ ( (char       *) timstr, 
               (doublereal *) &et, 
               (logical    *) &error, 
               (char       *) errmsg, 
               (ftnlen      ) strlen(timstr),
               (ftnlen      ) MSGLEN-1           );

   chckxc_c ( SPICEFALSE, " ", ok );

   F2C_ConvertStr ( MSGLEN, errmsg );

   chcksi_c ( "error flag from zzektcnv_", 
              error, 
              "=", 
              0,
              0,
              ok                                     );

   
   chcksi_c ( "length of error message from zzektcnv_", 
              strlen(errmsg), 
              "=", 
              0,
              0,
              ok                                     );

   if ( strlen(errmsg) > 0 ) 
   {
      chcksc_c ( "error message from zzektcnv_", 
       errmsg, 
       "=", 
       " ",
       ok                                     );
   }

   chcksd_c ( "(1) ET from SCLK converted by zzektcnv_", 
              et, 
              "=", 
              xet,
              0.0,
              ok                                     );

   /*
   Now use a name that doesn't contain the substring SCLK. 
   */
   boddef_c ( SCLK_NAME2, SCLK_ID );

   /*
   Convert an SCLK string to ET; make sure we get the same result
   returned by scs2e_c. 
   */
   scs2e_c  ( SCLK_ID, SCLK_STR, &xet );
   chckxc_c ( SPICEFALSE, " ", ok );

   sprintf ( timstr, "%s SCLK %s", SCLK_NAME2, SCLK_STR );
   
   zzektcnv_ ( (char       *) timstr, 
               (doublereal *) &et, 
               (logical    *) &error, 
               (char       *) errmsg, 
               (ftnlen      ) strlen(timstr),
               (ftnlen      ) MSGLEN-1           );

   chckxc_c ( SPICEFALSE, " ", ok );

   F2C_ConvertStr ( MSGLEN, errmsg );

   chcksi_c ( "error flag from zzektcnv_", 
              error, 
              "=", 
              0,
              0,
              ok                                     );

   
   chcksi_c ( "length of error message from zzektcnv_", 
              strlen(errmsg), 
              "=", 
              0,
              0,
              ok                                     );

   if ( strlen(errmsg) > 0 ) 
   {
      chcksc_c ( "error message from zzektcnv_", 
       errmsg, 
       "=", 
       " ",
       ok                                     );
   }

   chcksd_c ( "(2) ET from SCLK converted by zzektcnv_", 
              et, 
              "=", 
              xet,
              0.0,
              ok                                     );


   /*
   Now attempt conversion using an SCLK name that doesn't map to
   an ID code.
   */
   sprintf ( timstr, "%s SCLK %s", SCLK_UNDEF, SCLK_STR );   

   zzektcnv_ ( (char       *) timstr, 
               (doublereal *) &et, 
               (logical    *) &error, 
               (char       *) errmsg, 
               (ftnlen      ) strlen(timstr),
               (ftnlen      ) MSGLEN-1           );

   chckxc_c ( SPICEFALSE, " ", ok );

   F2C_ConvertStr ( MSGLEN, errmsg );

   chcksi_c ( "error flag from zzektcnv_", 
              error, 
              "=", 
              1,
              0,
              ok                                     );

   
   chcksi_c ( "length of error message from zzektcnv_", 
              strlen(errmsg), 
              ">", 
              0,
              0,
              ok                                     );

   if ( strlen(errmsg) > 0 ) 
   {
      chcksc_c ( "error message from zzektcnv_", 
       errmsg, 
       "=", 
       "Time conversion failed; SCLK type <"
                 SCLK_UNDEF
                 "> was not recognized.",
       ok                                     );
   }


   /*
   Now attempt conversion using an SCLK string with no clock name.
   */
   sprintf ( timstr, " SCLK %s", SCLK_STR );
   
   zzektcnv_ ( (char       *) timstr, 
               (doublereal *) &et, 
               (logical    *) &error, 
               (char       *) errmsg, 
               (ftnlen      ) strlen(timstr),
               (ftnlen      ) MSGLEN-1           );

   chckxc_c ( SPICEFALSE, " ", ok );

   F2C_ConvertStr ( MSGLEN, errmsg );

   chcksi_c ( "error flag from zzektcnv_", 
              error, 
              "=", 
              1,
              0,
              ok                                     );

   
   chcksi_c ( "length of error message from zzektcnv_", 
              strlen(errmsg), 
              ">", 
              0,
              0,
              ok                                     );

   if ( strlen(errmsg) > 0 ) 
   {
      chcksc_c ( "error message from zzektcnv_", 
       errmsg, 
       "=", 
       "Time conversion failed; SCLK name "
                 "was not supplied.",
       ok                                     );
   }

   /*
   Try a conversion without having the right SCLK kernel loaded. 
   */
   sprintf ( timstr, "GLL SCLK %s", SCLK_STR );
   
   zzektcnv_ ( (char       *) timstr, 
               (doublereal *) &et, 
               (logical    *) &error, 
               (char       *) errmsg, 
               (ftnlen      ) strlen(timstr),
               (ftnlen      ) MSGLEN-1           );

   chckxc_c ( SPICETRUE, "SPICE(KERNELVARNOTFOUND)", ok );


   /*
   Try a conversion using a string having invalid syntax.
   */
   sprintf ( timstr, "%s SCLK %s", SCLK_NAME2, BAD_SCLK_STR );
   
   zzektcnv_ ( (char       *) timstr, 
               (doublereal *) &et, 
               (logical    *) &error, 
               (char       *) errmsg, 
               (ftnlen      ) strlen(timstr),
               (ftnlen      ) MSGLEN-1           );

   chckxc_c ( SPICEFALSE, " ", ok );

   F2C_ConvertStr ( MSGLEN, errmsg );

   chcksi_c ( "error flag from zzektcnv_", 
              error, 
              "=", 
              1,
              0,
              ok                                     );

   
   chcksi_c ( "length of error message from zzektcnv_", 
              strlen(errmsg), 
              ">", 
              0,
              0,
              ok                                     );

   /*
   Try a conversion without having SCLK coefficients loaded.  This is 
   intended to trigger an SCS2E SPICE error.
   */
 
   dvpool_c ( "SCLK01_COEFFICIENTS_9" );

   sprintf ( timstr, "%s SCLK %s", SCLK_NAME2, SCLK_STR );

   zzektcnv_ ( (char       *) timstr, 
               (doublereal *) &et, 
               (logical    *) &error, 
               (char       *) errmsg, 
               (ftnlen      ) strlen(timstr),
               (ftnlen      ) MSGLEN-1           );

   chckxc_c ( SPICETRUE, "SPICE(KERNELVARNOTFOUND)", ok );

   F2C_ConvertStr ( MSGLEN, errmsg );

   chcksi_c ( "error flag from zzektcnv_", 
              error, 
              "=", 
              1,
              0,
              ok                                     );

   
   chcksi_c ( "length of error message from zzektcnv_", 
              strlen(errmsg), 
              ">", 
              0,
              0,
              ok                                     );

   if ( strlen(errmsg) > 0 ) 
   {
      chcksc_c ( "error message from zzektcnv_", 
       errmsg, 
       "=", 
       "Unexpected SPICELIB error encountered "
                 "while attempting to parse the string <"
                 SCLK_NAME2
                 " SCLK "
                 SCLK_STR
                 ">",
       ok                                     );
   }

 

   /*
   Try a conversion using a normal UTC string. 
   */
   tstck3_c ( CK, SCLK, SPICEFALSE, SPICETRUE, SPICEFALSE, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   

   strcpy   ( timstr, UTC );
   chckxc_c ( SPICEFALSE, " ", ok );

   str2et_c ( timstr, &xet );

   zzektcnv_ ( (char       *) timstr, 
               (doublereal *) &et, 
               (logical    *) &error, 
               (char       *) errmsg, 
               (ftnlen      ) strlen(timstr),
               (ftnlen      ) MSGLEN-1           );

   chckxc_c ( SPICEFALSE, " ", ok );

   F2C_ConvertStr ( MSGLEN, errmsg );

   chcksi_c ( "error flag from zzektcnv_", 
              error, 
              "=", 
              0,
              0,
              ok                                     );

   
   chcksi_c ( "length of error message from zzektcnv_", 
              strlen(errmsg), 
              "=", 
              0,
              0,
              ok                                     );

   if ( strlen(errmsg) > 0 ) 
   {
      chcksc_c ( "error message from zzektcnv_", 
       errmsg, 
       "=", 
       " ",
       ok                                     );
   }

   chcksd_c ( "ET from UTC converted by zzektcnv_", 
              et, 
              "=", 
              xet,
              0.0,
              ok            );




   /*
   Try a conversion using an invalid UTC string. 
   */   
   strcpy   ( timstr, BAD_UTC_STR );
   chckxc_c ( SPICEFALSE, " ", ok );

   zzektcnv_ ( (char       *) timstr, 
               (doublereal *) &et, 
               (logical    *) &error, 
               (char       *) errmsg, 
               (ftnlen      ) strlen(timstr),
               (ftnlen      ) MSGLEN-1           );


   F2C_ConvertStr ( MSGLEN, errmsg );

   chcksi_c ( "error flag from zzektcnv_", 
              error, 
              "=", 
              1,
              0,
              ok                                     );
   
   chcksi_c ( "length of error message from zzektcnv_", 
              strlen(errmsg), 
              ">", 
              0,
              0,
              ok                                     );

   /*
   Clean up the EK files we created.
   */
   clpool_c();
   chckxc_c ( SPICEFALSE, " ", ok );

   TRASH ( CK   );
   TRASH ( EK1  ); 
   TRASH ( EK2  );
   
  
   /*
   Retrieve the current test status.
   */ 
   t_success_c ( ok ); 
   
   
} /* End f_ek01_c */

