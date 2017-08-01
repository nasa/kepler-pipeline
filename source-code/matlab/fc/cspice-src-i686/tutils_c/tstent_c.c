/*

-Procedure tstent_c ( Produce EK column entries for EK testing )

-Abstract
 
   Make up EK column entries for use in EK testing.   
 
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
   
   
   void tstent_c ( SpiceInt           fileno,
                   ConstSpiceChar   * table,
                   SpiceInt           segno,
                   ConstSpiceChar   * column,
                   SpiceInt           rowno,
                   SpiceInt           nmax,
                   SpiceInt           vallen,
                   SpiceInt         * nelts,
                   void             * cvals,
                   SpiceDouble      * dvals,
                   SpiceInt         * ivals,
                   SpiceDouble      * tvals,
                   SpiceBoolean     * isnull  )
/*

-Brief_I/O
 
   Variable  I/O  Description 
   --------  ---  -------------------------------------------------- 
   MAXESZ     P   Maximum number of elements in the column entry. 
   fileno     I   Index of EK test file in test file sequence. 
   table      I   EK table name. 
   segno      I   Segment index within table in current file. 
   column     I   Column name. 
   rowno      I   Row index within segment. 
   nmax       I   Maximum number of column entry elements to return. 
   vallen     I   Length of strings in cvals array.
   nelts      O   Number of elements in specified column entry. 
   cvals      O   Values making up character column entry. 
   dvals      O   Values making up d.p. column entry. 
   ivals      O   Values making up integer column entry. 
   tvals      O   Values making up time column entry. 
   isnull     O   Flag indicating whether entry is null. 
 
-Detailed_Input
 
   fileno         is the index of in the EK test file sequence of 
                  the EK containing the specified column entry. 
                  The entries are a function of which file they're 
                  from. 
  
   table          is the name of the EK table containing the entry. 
                  This routine creates a fixed set of tables, each 
                  having a name given by this routine.  See the 
                  Particulars section for the table names and 
                  descriptions. 
 
   segno          is the index within the specified table, within 
                  the specified file, of the segment containing the 
                  entry. 
 
   column         is the name of the column containing the entry. 
                  Within each table, this routine creates a fixed 
                  set of columns, each having a name given by this 
                  routine.  See the Particulars section for the 
                  table names and descriptions. 
 
   rowno          is the index within the specified segment of the 
                  row containing the entry. 
   
   nmax           is the maximum number of column entry elements to  
                  return.  This input is used for error checking. 
 
   vallen         is the declared length of the strings in the output
                  array cvals.  cvals should be declared
                  
                     SpiceChar cvals[nmax][vallen]
                     
                     
-Detailed_Output
 
   nelts          is the number of elements in the specified column  
                  entry. 
 
   cvals          are the character values making up the column  
                  entry, if the specified column has character type. 
                  Otherwise, cvals is undefined. 
 
   dvals          are the d.p values  making up the column entry, if 
                  the specified column has double precision type. 
                  Otherwise, dvals is undefined. 
 
   ivals          are the integer values  making up the column 
                  entry, if the specified column has integer type. 
                  Otherwise, ivals is undefined. 
 
   tvals          are the ET values  making up the column entry, if 
                  the specified column has TIME type. Otherwise, 
                  tvals is undefined. 
 
   isnull         is a logical flag indicating whether the returned 
                  column entry is null. 
 
-Parameters
 
   MAXESZ         Maximum number of elements in the column entry. 
                  Current value is 10.
 
-Exceptions
 
   1) If the input table name is not recognized, the error  
      SPICE(NOSUCHTABLE) is signaled. 
 
   2) If the input column name is not recognized, the error  
      SPICE(NOSUCHCOLUMN) is signaled. 
 
-Files
 
   The column entries created by this routine are intended to  
   belong to a particular test EK in a sequence of test EKs.  The 
   index of the EK within the sequence is given by the input argument 
   FILENO.  The index is also reflected in the returned column 
   values. 
 
-Particulars
 
   This routine is meant to support the automatic, non-interactive 
   testing of the CSPICE EK system.  tstent_c creates a predictable 
   set of test data with which to populate a set of binary EK files, 
   and against which data fetched from those files can be compared. 
    
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
 
   -tutils_c Version 1.0.0, 07-JUL-1999 (NJB)  
-&
*/

{ /* Begin tstent_c */

   /*
   Local variables
   */
   logical                 logNull;


   /*
   Check the input strings.
   */
   assert ( table           !=  NULLCPTR );
   assert ( strlen(table)   >   0        );
   assert ( column          !=  NULLCPTR );
   assert ( strlen(column)  >   0        );

   /*
   Check the output string cvals.
   */
   assert ( cvals           !=  (void *)0 );
   assert ( vallen          >   1         );


   /*
   Call the f2c'd routine.
   */
   
   /*
   Map the file, segment, and row numbers to Fortran style ranges.
   */
   
   fileno ++;
   segno  ++;
   rowno  ++;
   
   tstent_ (  ( integer     * ) &fileno,
              ( char        * ) table,
              ( integer     * ) &segno,
              ( char        * ) column,
              ( integer     * ) &rowno,
              ( integer     * ) &nmax,
              ( integer     * ) nelts,
              ( char        * ) cvals,
              ( doublereal  * ) dvals,
              ( integer     * ) ivals,
              ( doublereal  * ) tvals,
              ( logical     * ) &logNull,
              ( ftnlen        ) strlen(table),
              ( ftnlen        ) strlen(column),
              ( ftnlen        ) vallen-1         );
               
   /*
   Convert the string array to C style.
   */ 
   
   F2C_ConvertTrStrArr ( *nelts, vallen, cvals );



   /*
   Copy the output logical flag.
   */       
   
   *isnull = logNull;
   

} /* End tstent_c */
