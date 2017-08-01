/*

-Procedure tstek_c ( Produce EK column entries for EK testing )

-Abstract
 
   Create EK files for testing the EK writing and reading routines.   
 
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
 
   UTILITY 
 
*/
   #include <assert.h>
   #include <stdio.h>
   #include "SpiceUsr.h"
   #include "SpiceZfc.h"
   #include "SpiceZst.h"
   #include "SpiceZmc.h"
   #include "tutils_c.h"
   
   
   void tstek_c ( ConstSpiceChar  * file,
                  SpiceInt          fileno,
                  SpiceInt          mxrows,
                  SpiceBoolean      load,
                  SpiceInt        * handle,
                  SpiceBoolean    * ok      )

/*

-Brief_I/O
 
   Variable  I/O  Description 
   --------  ---  -------------------------------------------------- 
   file       I   The name of an EK file to create. 
   fileno     I   Index of file in sequence of test EKs. 
   mxrows     I   Maximum number of rows allowed in any table.
   load       I   Boolean indicating if file should be loaded. 
   handle     O   Handle if file is loaded by tstek_c. 
   ok         O   Status flag.
   
-Detailed_Input
 
   file        is the name of an EK file to create for use in 
               software testing.  
 
               If the file specified already exists, the existing 
               file is deleted and a new one created with the same 
               name in its place. 
 
   fileno      is the ordinal position of the named EK in a sequence 
               of test EKs.  fileno will be reflected in the EK 
               data, so data may be traced to their source EK files. 
 
   mxrows      is the maximum number of rows allowed in any table.
               mxrows should be at least 4000 for robust testing,
               but it may be set as small as 10 for quick tests.

   load        is a logical flag indicating whether or not the 
               created SPK file should be loaded.  If load is SPICETRUE 
               the file is loaded.  If load is SPICEFALSE the file is 
               not loaded by this routine. 
 
-Detailed_Output
 
   handle      is the handle attached to the EK file if load is 
               SPICETRUE 
               
   ok          is a flag indicating the status of the test.
 
-Parameters
 
   None. 
 
-Exceptions
 
   1) If the specified file already exists, it is deleted and 
      replaced by the file created by this routine. 
 
   2) All other exceptions are diagnosed by routines in the call tree 
      of this routine. 
 
-Files
 
   The column entries created by this routine are intended to  
   belong to a particular test EK in a sequence of test EKs.  The 
   index of the EK within the sequence is given by the input argument 
   FILENO.  The index is also reflected in the returned column 
   values. 
 
-Particulars
 
   This routine is meant to support the automatic, non-interactive 
   testing of the CSPICE EK system.  tstek_c uses tstent_c to create a 
   predictable set of test data with which it populates a set of 
   binary EK files.  Data fetched from those files can be compared 
   with outputs obtained directly from tstent_c. 
    
   The test data produced by this routine are reasonably  
   comprehensive in some respects: 
 
      - Both segment types (1 and 2) are represented. 
      - Every column class is represented. 
      - Indexed and non-indexed columns are represented. 
      - Null and non-null column entries for each column class 
        are created. 
      - Tables are continued across multiple files.  
 
   On the other hand, the tables created by this routine are not 
   adequate to exhaustively test all of the logic used to write and 
   read EK files.  
 
   The tables created by this routine are described below. 
 
      1) Table SCALAR_1:

            Segment type:  1

            Columns          Data type         Indexed?   Nulls ok?
            -------          ---------         --------   ---------
            TABLE_NAME       CHARACTER*(64)    No         No
            FILE_NO          INTEGER           No         No
            SEGMENT_NO       INTEGER           No         No
            ROW_NO           INTEGER           No         No
            C_COL_1          CHARACTER*(*)     No         No
            D_COL_1          DOUBLE PRECISION  No         No
            I_COL_1          INTEGER           No         No
            T_COL_1          TIME              No         No

      2) Table SCALAR_2:

            Segment type:  1

            Columns          Data type         Indexed?   Nulls ok?
            -------          ---------         --------   ---------
            TABLE_NAME       CHARACTER*(64)    Yes        No
            FILE_NO          INTEGER           Yes        No
            SEGMENT_NO       INTEGER           Yes        No
            ROW_NO           INTEGER           Yes        No
            C_COL_1          CHARACTER*(*)     Yes        Yes
            C_COL_2          CHARACTER*(*)     Yes        Yes
            C_COL_3          CHARACTER*(*)     Yes        Yes
            C_COL_4          CHARACTER*(20)    Yes        Yes
            C_COL_5          CHARACTER*(20)    Yes        Yes
            C_COL_6          CHARACTER*(20)    Yes        Yes
            D_COL_1          DOUBLE PRECISION  Yes        Yes
            D_COL_2          DOUBLE PRECISION  Yes        Yes
            D_COL_3          DOUBLE PRECISION  Yes        Yes
            I_COL_1          INTEGER           Yes        Yes
            I_COL_2          INTEGER           Yes        Yes
            I_COL_3          INTEGER           Yes        Yes
            T_COL_1          TIME              Yes        Yes
            T_COL_2          TIME              Yes        Yes
            T_COL_3          TIME              Yes        Yes


      3) Table SCALAR_3:

            Segment type:  2

            Columns          Data type         Indexed?   Nulls ok?
            -------          ---------         --------   ---------
            TABLE_NAME       CHARACTER*(64)    No         No
            FILE_NO          INTEGER           No         No
            SEGMENT_NO       INTEGER           No         No
            ROW_NO           INTEGER           No         No
            C_COL_1          CHARACTER*(20)    No         No
            D_COL_1          DOUBLE PRECISION  No         No
            I_COL_1          INTEGER           No         No
            T_COL_1          TIME              No         No


      4) Table SCALAR_4:

            Segment type:  2

            Columns          Data type         Indexed?   Nulls ok?
            -------          ---------         --------   ---------
            TABLE_NAME       CHARACTER*(64)    Yes        No
            FILE_NO          INTEGER           Yes        No
            SEGMENT_NO       INTEGER           Yes        No
            ROW_NO           INTEGER           Yes        No
            C_COL_1          CHARACTER*(20)    Yes        Yes
            C_COL_2          CHARACTER*(20)    Yes        Yes
            C_COL_3          CHARACTER*(20)    Yes        Yes
            D_COL_1          DOUBLE PRECISION  Yes        Yes
            D_COL_2          DOUBLE PRECISION  Yes        Yes
            D_COL_3          DOUBLE PRECISION  Yes        Yes
            I_COL_1          INTEGER           Yes        Yes
            I_COL_2          INTEGER           Yes        Yes
            I_COL_3          INTEGER           Yes        Yes
            T_COL_1          TIME              Yes        Yes
            T_COL_2          TIME              Yes        Yes
            T_COL_3          TIME              Yes        Yes

      5) Table VECTOR_1:

            Segment type:  1

            Columns       Data type         Indexed? Nulls ok? Dim.
            -------       ---------         -------- --------- ----
            TABLE_NAME    CHARACTER*(64)    Yes      No        1
            FILE_NO       INTEGER           Yes      No        1
            SEGMENT_NO    INTEGER           Yes      No        1
            ROW_NO        INTEGER           Yes      No        1
            C_COL_1       CHARACTER*(1024)  No       No        3
            C_COL_2       CHARACTER*(100)   No       No        *
            D_COL_1       DOUBLE PRECISION  No       No        4
            D_COL_2       DOUBLE PRECISION  No       No        *
            I_COL_1       INTEGER           No       No        5
            I_COL_2       INTEGER           No       No        *
            T_COL_1       TIME              No       No        6
            T_COL_2       TIME              No       No        *


      6) Table VECTOR_2:

            Segment type:  1

            Columns       Data type         Indexed? Nulls ok? Dim.
            -------       ---------         -------- --------- ----
            TABLE_NAME    CHARACTER*(64)    Yes      No        1
            FILE_NO       INTEGER           Yes      No        1
            SEGMENT_NO    INTEGER           Yes      No        1
            ROW_NO        INTEGER           Yes      No        1
            C_COL_1       CHARACTER*(1024)  No       Yes       3
            C_COL_2       CHARACTER*(1024)  No       Yes       5
            C_COL_3       CHARACTER*(1024)  No       Yes       *
            C_COL_4       CHARACTER*(1024)  No       Yes       *
            D_COL_1       DOUBLE PRECISION  No       Yes       4
            D_COL_2       DOUBLE PRECISION  No       Yes       6
            D_COL_3       DOUBLE PRECISION  No       Yes       *
            D_COL_4       DOUBLE PRECISION  No       Yes       *
            I_COL_1       INTEGER           No       Yes       5
            I_COL_2       INTEGER           No       Yes       7
            I_COL_3       INTEGER           No       Yes       *
            I_COL_4       INTEGER           No       Yes       *
            T_COL_1       TIME              No       Yes       6
            T_COL_2       TIME              No       Yes       8
            T_COL_3       TIME              No       Yes       *
            T_COL_4       TIME              No       Yes       *
 
-Examples
 
   None. 
 
-Restrictions
 
   None. 
 
-Literature_References
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman       (JPL) 
 
-Version
 
   -tutils_c Version 1.1.0, 20-SEP-1999 (NJB)  

      Made the local variables 
      
         cvals
         decls
         fatbuf
         dvals
         ivals
         
      static to support the MAC-PPC_C (Code Warrior compiler)
      environment.
      
      Cast fileno argument to int in sprintf call.

   -tutils_c Version 1.0.0, 19-JUL-1999 (NJB)  

-&
*/

{ /* Begin tstek_c */

   /*
   Local constants
   */
   
   #define DECLEN          201
   #define IFNLEN          60
   #define NTABS           6   
   #define MAXROW          1000
   #define MAXENT          20
   #define MAXFAT          100
   #define MAXFVL          ( MAXFAT * MAXENT )
   #define CVALSZ          101
   #define MAXVAL          ( MAXROW * MAXENT )
   #define MAXSTR          ( SPICE_EK_MAXQSTR + 1 )
   #define LNSIZE          81


   /*
   Static variables
   */
   static SpiceChar        tables [ NTABS ][ SPICE_EK_TSTRLN ] =
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
   SpiceBoolean            indexd [SPICE_EK_MXCLSG];
   SpiceBoolean            nlflgs [MAXROW         ];
   SpiceBoolean            nullok [SPICE_EK_MXCLSG];

   SpiceChar               cnames [SPICE_EK_MXCLSG][SPICE_EK_CSTRLN];
   static SpiceChar        cvals  [MAXVAL         ][CVALSZ];
   static SpiceChar        decls  [SPICE_EK_MXCLSG][DECLEN];
   SpiceChar               ifname [IFNLEN         ];
   static SpiceChar        fatbuf [MAXFVL         ][MAXSTR];

   static SpiceDouble      dvals  [MAXVAL];
   
   SpiceEKDataType         dtypes [SPICE_EK_MXCLSG];
   
   SpiceInt                cclass [SPICE_EK_MXCLSG];
   SpiceInt                colno;
   SpiceInt                dims   [SPICE_EK_MXCLSG];
   SpiceInt                entszs [MAXROW];
   SpiceInt                i;
   static SpiceInt         ivals  [MAXVAL];
   SpiceInt                maxstl;
   SpiceInt                ncols;
   SpiceInt                ncomch;
   SpiceInt                nrows;
   SpiceInt                p;
   SpiceInt                rcptrs [MAXROW];
   SpiceInt                segno;
   SpiceInt                segtyp;
   SpiceInt                stlens [SPICE_EK_MXCLSG];
   SpiceInt                tabno;
   SpiceInt                wkindx [MAXROW];




   /*
   Check the input string file.
   */
   assert ( file           !=  NULLCPTR );
   assert ( strlen(file)   >   0        );

   assert ( mxrows >= 10 );
   
   /*
   Delete the old version of the file, if it exists.
   */
   if ( exists_c( file ) )
   {
      remove ( file );
   }

   /*
   Set up the number of reserved comment characters and the internal
   file name. 
   */
   
   ncomch  =  1024 * fileno;
   
   sprintf ( ifname, "ek test file #%d", (int)fileno );
   
      
   /*
   Open a new E-kernel.  NB: handle is an integer pointer output 
   argument of this routine.
   */
   ekopn_c ( file, ifname, ncomch, handle );
   

   /*
   For each table:
   */

   for ( tabno = 0;  tabno < NTABS;  tabno++ )
   {
   
      /*
      Look up the schema for this table.
      */
      tstsch_c ( tables[tabno],  
                 mxrows,         SPICE_EK_CSTRLN,  DECLEN,   &segtyp,
                 &nrows,         &ncols,           cnames,   cclass,
                 dtypes,         stlens,           dims,     indexd,
                 nullok,         decls                              );
                 
      chckxc_c ( SPICEFALSE, " ", ok );
   
      /*
      Make sure we're not getting back more rows than we expected.
      */
      maxstl = 0;
      
      for ( i = 0;  i < ncols;  i++ )
      {
         maxstl = MaxAbs ( maxstl, stlens[i] );
      }
      
      
      if ( nrows > MAXROW )
      {
         erract_c ( "SET", LNSIZE, "ABORT"  ); 
         errdev_c ( "SET", LNSIZE, "SCREEN" ); 
         errprt_c ( "SET", LNSIZE, "ALL"    ); 
   
         chkin_c  ( "tstek_c"                                  );
         setmsg_c ( "Oops! Max number of rows that can be "
                    "handled by this routine is #; number "
                    "handed back by tstsch_c is #."            );                              
         errint_c ( "#", MAXROW                                );
         errint_c ( "#", nrows                                 );
         sigerr_c ( "SPICE(BUG)"                               );
         chkout_c ( "tstek_c"                                  );
         return;
      
      }
      else if (  ( nrows > MAXFAT ) && ( maxstl > CVALSZ )  )
      {
         erract_c ( "SET", LNSIZE, "ABORT"  ); 
         errdev_c ( "SET", LNSIZE, "SCREEN" ); 
         errprt_c ( "SET", LNSIZE, "ALL"    ); 
   
         chkin_c  ( "tstek_c"                                  );
         setmsg_c ( "Oops! Max number of long rows that can be "
                    "handled by this routine is #; number "
                    "handed back by tstsch_c is #."            );                              
         errint_c ( "#", MAXFAT                                );
         errint_c ( "#", nrows                                 );
         sigerr_c ( "SPICE(BUG)"                               );
         chkout_c ( "tstek_c"                                  );
         return;
      }
            
      
      /*
      Initiate a fast load.
      */
      ekifld_c ( *handle,  tables[tabno],     ncols,  
                 nrows,    SPICE_EK_CSTRLN,   cnames, 
                 DECLEN,   decls,             &segno,   rcptrs );
                      
      chckxc_c ( SPICEFALSE, " ", ok );
   
      /*
      Load the columns one by one. Each column and associated
      arrays must be filled in first.  Obtain data, entry sizes,
      and null flags from tstent_c.
      */
      for ( colno = 0;  colno < ncols;  colno++ )
      {
         /*
         Initialize the data pointer to point to the first free slot.
         */
         
         p  =  0;
      
         for ( i = 0;  i < nrows;  i++ )
         {
         
            if ( stlens[colno] > CVALSZ )
            {
               /*
               We're dealing with some very long strings.  Use
               the fat string buffer.
               */
               
               tstent_c ( fileno,         tables[tabno],  segno, 
                          cnames[colno],  i,              MAXENT,       
                          MAXSTR,         entszs+i,       fatbuf+p, 
                          dvals+p,        ivals+p,        dvals+p,  
                          nlflgs+i                                 );
               
               chckxc_c ( SPICEFALSE, " ", ok );

            }
            else
            {
               /*
               Use the normal buffers.
               */
               tstent_c ( fileno,         tables[tabno],  segno, 
                          cnames[colno],  i,              MAXENT,       
                          CVALSZ,         entszs+i,       cvals+p, 
                          dvals+p,        ivals+p,        dvals+p,  
                          nlflgs+i                                 );
                          
               chckxc_c ( SPICEFALSE, " ", ok );
            }
            
            /*
            Advance the data pointer by the number of elements in
            the current entry.
            */
            
            p += entszs[i];
         }
    

         /*
         The column is ready to be added.  Choose the addition
         routine based on the column's data type.
         */
         
         switch ( dtypes[colno] ) 
         {
         
            case SPICE_CHR:
            
               if ( stlens[colno] > CVALSZ )
               {
                  ekaclc_c ( *handle, segno,  cnames[colno], MAXSTR,
                             fatbuf,  entszs, nlflgs,        rcptrs,
                             wkindx                                 );

                  chckxc_c ( SPICEFALSE, " ", ok );
               }


               else
               {
                  ekaclc_c ( *handle, segno,  cnames[colno], CVALSZ,
                             cvals,   entszs, nlflgs,        rcptrs,
                             wkindx                                 );

                  chckxc_c ( SPICEFALSE, " ", ok );
               }
            
               break;
               
               
            case SPICE_DP:
            
               ekacld_c ( *handle, segno,  cnames[colno], dvals,
                          entszs,  nlflgs, rcptrs,        wkindx );
     
               chckxc_c ( SPICEFALSE, " ", ok );
        
               break;
               
               
            case SPICE_INT:
            
               ekacli_c ( *handle, segno,  cnames[colno], ivals,
                          entszs,  nlflgs, rcptrs,        wkindx );

               chckxc_c ( SPICEFALSE, " ", ok );

               break;
               
               
            case SPICE_TIME:
            
               ekacld_c ( *handle, segno,  cnames[colno], dvals,
                          entszs,  nlflgs, rcptrs,        wkindx );

               chckxc_c ( SPICEFALSE, " ", ok );

               break;
               
               
            default:
            
               erract_c ( "SET", LNSIZE, "ABORT"  ); 
               errdev_c ( "SET", LNSIZE, "SCREEN" ); 
               errprt_c ( "SET", LNSIZE, "ALL"    ); 
         
               chkin_c  ( "tstek_c"                                  );
               setmsg_c ( "Unrecognized datatype # found for column "
                          "number #."                                );
               errint_c ( "#", (SpiceInt)dtypes[colno]               );
               errint_c ( "#", colno                                 );
               sigerr_c ( "SPICE(BUG)"                               );
               chkout_c ( "tstek_c"                                  );
               return;
         }
         /*
         End switch for column data type.
         */
    
      }
      /*
      Done with all columns here.
      */
      
      /*
      Finish the fast load for this table.
      */
      ekffld_c ( *handle, segno, rcptrs );
      
      chckxc_c ( SPICEFALSE, " ", ok );
   }
   /*
   Done with all tables here.
   */
   
   
   /*
   Close the EK file.
   */
   ekcls_c ( *handle );
   
   chckxc_c ( SPICEFALSE, " ", ok );
   
   /*
   Load the file if commanded to do so.
   */
   if ( load )
   {
      eklef_c ( file, handle );
   }

 
} /* End tstek_c */
