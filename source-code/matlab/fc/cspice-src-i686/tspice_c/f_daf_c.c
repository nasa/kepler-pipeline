/*

-Procedure f_daf_c ( Test wrappers for DAF routines )

 
-Abstract
 
   Perform tests on CSPICE wrappers for the DAF routines.
    
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
   #include "SpiceUsr.h"
   #include "SpiceZfc.h"
   #include "SpiceZmc.h"
   #include "tutils_c.h"
   

   void f_daf_c ( SpiceBoolean * ok )

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
 
   This routine tests the wrappers for the DAF routines. 
   
   These are:
      
      dafbbs_c
      dafbfs_c
      dafcls_c
      dafcs_c
      daffna_c
      daffpa_c
      dafgn_c
      dafgs_c
      dafopr_c
      dafus_c
             
-Examples
 
   None.
    
-Restrictions
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
 
-Literature_References
 
   None. 
 
-Version
 
   -tspice_c Version 1.1.0 21-NOV-2001 (NJB)

      SPICE(DAFNOSUCHHANDLE) short error message was updated to 
      SPICE(NOSUCHHANDLE), in order to match that signaled by
      the new handle manager subsystem.

   -tspice_c Version 1.0.0 03-SEP-1999 (NJB)  

-&
*/

{ /* Begin f_daf_c */

 
   /*
   Constants
   */
   #define ERRLEN          321
   #define SPK1            "daftest.bsp"
   #define SPK2            "cstest.bsp"
   #define SIDLEN          41
   #define DSCSIZ          5
   #define PHOENIX         -9
   #define ND              2
   #define NI              6
   
   /*
   This is the number of segments in the SPK file created by tstspk_c.
   If that routine changes, this "constant" might need to change as 
   well.
   */
   #define N_SPK_SEG       46
   
   
   /*
   Local variables
   */
   SpiceBoolean            found;
   SpiceBoolean            found2;

   SpiceChar               segid [ SIDLEN ];

   SpiceDouble             dc    [ ND ];
   SpiceDouble             first;
   SpiceDouble             last;

   SpiceDouble             sum   [ DSCSIZ ];

 
   SpiceInt                begin;
   SpiceInt                body;
   SpiceInt                center;
   SpiceInt                end;
   SpiceInt                frame;
   SpiceInt                han2;
   SpiceInt                handle;
   SpiceInt                ic     [ NI ];
   SpiceInt                nseg;
   SpiceInt                type;
   SpiceInt                unit;






   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_daf_c" );
   

   
   /*
   Make sure the kernel pool doesn't contain any unexpected 
   definitions.
   */
   clpool_c();
   
   /*
   Create but do not load an SPK file.
   */
   tstspk_c ( SPK1, SPICEFALSE, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   /*
   Case 1:
   */
   tcase_c ( "Test the forward search routines.  Count the SPK "
             "segments."                                         );
 
   dafopr_c ( SPK1, &handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   nseg = 0;
   
   dafbfs_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );

   daffna_c ( &found );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   while ( found )
   {
      nseg++ ;
      
      daffna_c ( &found );
      chckxc_c ( SPICEFALSE, " ", ok );
   }
   
   chcksi_c ( "(forward) Segment count", nseg, "=", N_SPK_SEG, 0, ok ); 
   
   
   
   
   /*
   Case 2:
   */
   tcase_c ( "Test the backward search routines.  Count the SPK "
             "segments."                                         );
   
   nseg = 0;
   
   dafbbs_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );

   daffpa_c ( &found );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   while ( found )
   {
      nseg++ ;
      
      daffpa_c ( &found );
      chckxc_c ( SPICEFALSE, " ", ok );
   }
   
   chcksi_c ( "(backward) Segment count", nseg, "=", N_SPK_SEG, 0, ok );   
   


   
   /*
   Case 3:
   */
   tcase_c ( "Test dafgs_c and dafgn_c.  Examine the descriptor " 
             "for the Phoenix spacecraft."                       );

   nseg = 0;
   
   dafbfs_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );

   daffna_c ( &found );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   while ( found )
   {
      nseg++;
      
      dafgs_c  ( sum );
      dafgn_c  ( SIDLEN, segid );

      spkuds_c ( sum, 
                 &body,  &center,  &frame,  &type,
                 &first, &last,    &begin,  &end  );

      
      if ( body == PHOENIX )
      {

         chcksc_c ( "segid",  segid,  "=",   "PHOENIX SPACECRAFT", ok );
         
         chcksi_c ( "center", center, "=",   301,    0, ok ); 
         chcksi_c ( "type",   type,   "=",   5,      0, ok ); 
         chcksi_c ( "frame",  frame,  "=",   17,     0, ok ); 
         chcksd_c ( "first",  first,  "=",  -5.e8,   0, ok ); 
         chcksd_c ( "last",   last,   "=",   5.e8,   0, ok ); 
      
         break;
      }
      
      daffna_c ( &found );
      chckxc_c ( SPICEFALSE, " ", ok );
   }
   
   chcksi_c ( "index of Phoenix seg", nseg, "=",  1,   0, ok ); 
   
 



   /*
   Case 4:
   */
   tcase_c ( "Test dafus_c Examine the descriptor " 
             "for the Phoenix spacecraft."            );

   nseg = 0;
   
   dafbfs_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );

   daffna_c ( &found );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   while ( found )
   {
      nseg++;
      
      dafgs_c  ( sum );
      dafgn_c  ( SIDLEN, segid );

      dafus_c ( sum, ND, NI, dc, ic );
      
      body   = ic[0];
      center = ic[1];
      frame  = ic[2];
      type   = ic[3];
      
      first  = dc[0];
      last   = dc[1];
            
      if ( body == PHOENIX )
      {

         chcksc_c ( "segid",  segid,  "=",   "PHOENIX SPACECRAFT", ok );
         
         chcksi_c ( "center", center, "=",   301,    0, ok ); 
         chcksi_c ( "type",   type,   "=",   5,      0, ok ); 
         chcksi_c ( "frame",  frame,  "=",   17,     0, ok ); 
         chcksd_c ( "first",  first,  "=",  -5.e8,   0, ok ); 
         chcksd_c ( "last",   last,   "=",   5.e8,   0, ok ); 
      
         break;
      }
      
      daffna_c ( &found );
      chckxc_c ( SPICEFALSE, " ", ok );
   }
   
   chcksi_c ( "index of Phoenix seg", nseg, "=",  1,   0, ok ); 
   


   /*
   Case 5:
   */
   tcase_c ( "Test dafcs_c.  Start a search on SPK1.  Create and "
             "load a second SPK.  Start a search on the second SPK. "
             "Continue the search on the first SPK."                  );
             
             
             
             
   nseg = 0;
   
   dafbfs_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );

   daffna_c ( &found );
   chckxc_c ( SPICEFALSE, " ", ok );


   /*
   Create and load a second SPK file.
   */
   tstspk_c ( SPK2, SPICETRUE, &han2 );
   chckxc_c ( SPICEFALSE, " ", ok );
             
   /*
   Start a backward search on the second SPK.
   */
   dafbbs_c ( han2 );
   chckxc_c ( SPICEFALSE, " ", ok );

   daffpa_c ( &found2 );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   /*
   Resume the search on the first SPK.
   */
   dafcs_c ( handle );
   
   while ( found )
   {
      nseg++;
      
      dafgs_c  ( sum );
      dafgn_c  ( SIDLEN, segid );

      dafus_c ( sum, ND, NI, dc, ic );
      
      body   = ic[0];
      center = ic[1];
      frame  = ic[2];
      type   = ic[3];
      
      first  = dc[0];
      last   = dc[1];
            
      if ( body == PHOENIX )
      {

         chcksc_c ( "segid",  segid,  "=",   "PHOENIX SPACECRAFT", ok );
         
         chcksi_c ( "center", center, "=",   301,    0, ok ); 
         chcksi_c ( "type",   type,   "=",   5,      0, ok ); 
         chcksi_c ( "frame",  frame,  "=",   17,     0, ok ); 
         chcksd_c ( "first",  first,  "=",  -5.e8,   0, ok ); 
         chcksd_c ( "last",   last,   "=",   5.e8,   0, ok ); 
      
         break;
      }
      
      daffna_c ( &found );
      chckxc_c ( SPICEFALSE, " ", ok );
   }
   
   chcksi_c ( "index of Phoenix seg", nseg, "=",  1,   0, ok ); 
   
             
             
   
   /*
   Case 6:
   */
   
   tcase_c ( "Close the SPK file with dafcls_c.  Make sure the "
             "DAF handle to logical unit mapping fails with the error "
             "SPICE(NOSUCHHANDLE)."                                );
             
   dafcls_c ( handle );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   dafhlu_ ( &handle, &unit );
   chckxc_c ( SPICETRUE, "SPICE(NOSUCHHANDLE)", ok );
  
   /*
   Get rid of the SPK files.
   */ 
   remove   ( SPK1 );
   remove   ( SPK2 );
  
   
   /*
   Retrieve the current test status.
   */ 
   t_success_c ( ok ); 
   
   
} /* End f_daf_c */

