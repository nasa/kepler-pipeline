/*

-Procedure tstsch_c ( Produce EK table schemas for EK testing )

-Abstract
 
   Return EK table schemas for use in EK testing.  These are the schemas
   used in the E-kernels produced by tstek_c.
 
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
   #include "SpiceUsr.h"
   #include "SpiceZfc.h"
   #include "SpiceZst.h"
   #include "SpiceZmc.h"
   #include "tutils_c.h"

   
   void tstsch_c ( ConstSpiceChar     * table,
                   SpiceInt             mxrows, 
                   SpiceInt             namlen,
                   SpiceInt             declen,
                   SpiceInt           * segtyp,
                   SpiceInt           * nrows,
                   SpiceInt           * ncols,
                   void               * cnames,
                   SpiceInt           * cclass,
                   SpiceEKDataType    * dtypes,
                   SpiceInt           * stlens,
                   SpiceInt           * dims,
                   SpiceBoolean       * indexd,
                   SpiceBoolean       * nullok,
                   void               * decls   )
/*

-Brief_I/O
 
   Variable  I/O  Description 
   --------  ---  -------------------------------------------------- 
   table      I   Name of table whose schema is requested. 
   mxrows     I   Maximum number of rows allowed in any table.
   namlen     I   Length of strings in column name array.
   declen     I   Length of strings in declaration array.
   segtyp     O   Segment type used to implement table. 
   nrows      O   Number of rows in table. 
   ncols      O   Number of columns in table. 
   cnames     O   Column names. 
   cclass     O   Column classes.
   dtypes     O   Column data types. 
   stlens     O   String lengths for character columns. 
   dims       O   Column entry sizes. 
   indexd     O   Flags indicating whether columns are indexed. 
   nullok     O   Flags indicating whether columns allow null values. 
   decls      O   Declaration strings for columns. 
 
-Detailed_Input
 
   table          is the name of the table whose schema is to be 
                  returned. 
 
   mxrows         is the maximum number of rows allowed in any table.
                  mxrows should be at least 4000 for robust testing,
                  but it may be set as small as 10 for quick tests.

-Detailed_Output
 
   segtyp         is an integer indicating the segment type to be used
                  to implement the specified table.  Possible values
                  are 1 or 2.
 
   namlen         is the length of the strings in the column name array.
                  The array cnames should be declared
                  
                     SpiceChar  cnames [SPICE_EK_MXCLSG][namlen]
                     
                     
   declen         is the length of the strings in the declaration array.
                  The array decls should be declared
                  
                     SpiceChar  decls [SPICE_EK_MXCLSG][declen]
                     
                     
   nrows          is the number of rows in the specified table. This is
                  not actually a property of the schema, but the number
                  of rows is selected here for uniformity.
 
   ncols          is the number of columns in the specified table. 
 
   cnames         is an array of names of the columns in the table. 
 
   cclass         is an array of integer column class codes for the
                  columns in the specified segment.  The class code of
                  a column indicates the implementation of the data
                  structure used to store the column's data.
   
   dtypes         is an array of integer data type codes for the
                  columns.  Values may be any of CHR, DP, INT, or TIME.
                  These parameters are declared in ektype.inc.
 
   stlens         is an array of string lengths for the columns. If the
                  Ith column has fixed-length strings, the Ith element
                  of STLENS gives that length.  Variable string length
                  is indicated by the value SPICE_EK_VARSIZ, which is
                  defined in ekbool.inc.  For non-character columns,
                  the corresponding element of STLENS is 0.
                   
   dims           is an array of element sizes for the columns. If the
                  Ith column has fixed-size entries, the Ith element of
                  DIMS gives that size.  Variable entry size is
                  indicated by the value SPICE_EK_VARSIZ, which is
                  defined in ekbool.inc.
 
   indexd         is an array of logical flags indicating whether the 
                  corresponding columns are indexed.   
 
   nullok         is an array of logical flags indicating whether the 
                  corresponding columns allow null values.   
 
   decls          is an array of strings containing column declarations
                  as required by ekbseg_c or ekifld_c.
 
-Parameters
 
   None. 
 
-Exceptions
 
   1) If the input table name is not recognized, the error  
      SPICE(NOSUCHTABLE) is signaled. 
 
-Files
 
   The table schemas created by this routine are intended to apply 
   to any test EK in a sequence of test EKs.  
 
-Particulars
 
   This routine is meant to support the automatic, non-interactive 
   testing of the CSPICE EK system.  tstsch_c creates table schemas 
   for a series of tables to be used in EK testing.  The tables are 
   intended to be populated with data created by TSTENT, which 
   produces a predictable set of test data.  
 
   The table schemas created by this routine are described below. 
 
 
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

   -tutils_c Version 1.1.0, 24-DEC-2001 (NJB)  
 
      Bug fix:  now a local array of type "integer" is used to
      fetch data type values from tstsch_.

   -tutils_c Version 1.0.0, 15-JUL-1999 (NJB)  

-&
*/

{ /* Begin tstsch_c */



   /*
   Local variables
   */
   SpiceInt                i;

   logical                 logIndexd [ SPICE_EK_MXCLSG ];
   logical                 logNullok [ SPICE_EK_MXCLSG ];
   
   integer                 locDtypes [ SPICE_EK_MXCLSG ];

   /*
   Check the input string table.
   */
   assert ( table           !=  NULLCPTR );
   assert ( strlen(table)   >   0        );


   /*
   Check the output strings cnames and decls.
   */
   assert ( cnames          !=  (void *)0 );
   assert ( namlen          >   1         );
   assert ( decls           !=  (void *)0 );
   assert ( declen          >   1         );


   /*
   Call the f2c'd routine.
   */
   tstsch_ ( ( char        * ) table,
             ( integer     * ) &mxrows,
             ( integer     * ) segtyp,
             ( integer     * ) nrows,
             ( integer     * ) ncols,
             ( char        * ) cnames,
             ( integer     * ) cclass,
             ( integer     * ) locDtypes,
             ( integer     * ) stlens,
             ( integer     * ) dims,
             ( logical     * ) logIndexd,
             ( logical     * ) logNullok,
             ( char        * ) decls,
             ( ftnlen        ) strlen(table),
             ( ftnlen        ) namlen-1,
             ( ftnlen        ) declen-1        );
         
   /*
   Convert the name and declaration strings to C style.
   */  
   F2C_ConvertTrStrArr ( *ncols, namlen, cnames );
   F2C_ConvertTrStrArr ( *ncols, declen, decls  );
   
   
   /*
   Set the output logical arrays.
   */
   for ( i = 0;  i < *ncols;  i++  )
   {
      indexd[i] = logIndexd[i];
      nullok[i] = logNullok[i];
   }


   /*
   Map Fortran EK data type codes to CSPICE equivalents. 
   */
   for ( i = 0;  i < *ncols;  i++  )
   {
      dtypes[i] = (SpiceEKDataType)(locDtypes[i] - 1);
   }


} /* End tstsch_c */

