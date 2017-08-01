/*

-Procedure f_sclk_c ( Test wrappers for SCLK routines )

 
-Abstract
 
   Perform tests on all CSPICE wrappers that perform SCLK conversions. 
 
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
   #include <stdio.h>
   #include "SpiceUsr.h"
   #include "SpiceZfc.h"
   #include "SpiceZmc.h"
   #include "tutils_c.h"
   

   void f_sclk_c ( SpiceBoolean * ok )

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
 
   This routine tests the wrappers for the SCLK conversion interface. 
   The current set is:
      
      scdecd_c
      scencd_c
      sce2c_c
      sce2s_c
      sce2t_c
      scfmt_c
      scpart_c
      scs2e_c
      sctiks_c
      sct2e_c
      
 
-Examples
 
   None.
    
-Restrictions
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
   W.L. Taber      (JPL) 
 
-Literature_References
 
   None. 
 
-Version
 
   -tspice_c Version 2.0.1 20-MAR-2002 (EDW) 

      Replaced remove() calls with TRASH macro.

   -tspice_c Version 2.0.0 15-SEP-1999 (NJB)  
   
      Correction made to sce2c_c test.

   -tspice_c Version 1.2.0 03-SEP-1999 (NJB) (WLT)

-&
*/

{ /* Begin f_sclk_c */

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
   Local parameters
   */
   #define CK              "SCLKtest.bc"
   #define SCLK            "testsclk.tsc"
   
   #define TIMLEN          25
   
   #define UTC             "1990 JAN 01 12:00:00"
   #define SCLK_STR        "1/315662457.1839"
   #define TICK_STR        "315662457.1839"
   #define SC1             -9999
   #define SC2             -10000
   #define SC3             -10001
   #define CLK_ID          -9
   #define MXPART          50                 
                     


   /*
   Local variables
   */
 
   SpiceChar               sclkstr [ TIMLEN ];
   SpiceChar               tickstr [ TIMLEN ];
   SpiceChar               utcout  [ TIMLEN ];
 
   SpiceDouble             et;
   SpiceDouble             expet;
   SpiceDouble             expsclkdp;
   SpiceDouble             cclkdp;
   SpiceDouble             pstart  [ MXPART ];
   SpiceDouble             pstop   [ MXPART ];
   SpiceDouble             sclkdp;
   SpiceDouble             ticks;
   
   SpiceInt                handle;
   SpiceInt                npart;

 

         



   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_sclk_c" );
   

   
   
   /*
   Case 1:
   */
   tcase_c ( "Convert a UTC time to ET, then to an SCLK string. " 
             "Make sure the conversion is invertible."           );
   

   /*
   Create an SCLK kernel.  The routine we use for this purpose
   also creates a C-kernel, which we don't need.
   */
   tstlsk_c ( );
   tstck3_c ( CK, SCLK, SPICEFALSE, SPICETRUE, SPICETRUE, &handle );
   TRASH   ( CK );

   
   str2et_c ( UTC,     &et                    );
   sce2s_c  ( CLK_ID,   et,  TIMLEN,  sclkstr );
   
   chckxc_c ( SPICEFALSE, " ", ok );
   
   chcksc_c ( "sclkstr", sclkstr, "=", SCLK_STR, ok );
   
   

   scs2e_c  ( CLK_ID,  sclkstr, &et                );
   et2utc_c ( et,     "C",      0,  TIMLEN, utcout );
   
   chckxc_c ( SPICEFALSE, " ", ok );
 
   chcksc_c ( "utcout", utcout, "=", UTC, ok );
 
 
   /*
   Save this ET value as the "expected ET."
   */
   expet = et;
   

   /*
   Check scs2e_c string error cases:
   
      1) Null SCLK string.
      2) Empty SCLK string.
      
   */
   scs2e_c  ( CLK_ID,  NULLCPTR, &et );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   
   scs2e_c  ( CLK_ID,  "", &et );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );
            



   
   
   /*
   Case 2:
   */
   tcase_c ( "Encode a SCLK string as continuous ticks. " 
             "Make sure the conversion is invertible." );
   
   
   scencd_c ( CLK_ID, SCLK_STR, &cclkdp );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   scdecd_c ( CLK_ID, cclkdp, TIMLEN, sclkstr );
   chcksc_c ( "sclkstr", sclkstr, "=", SCLK_STR, ok );
   
   
   /*
   Check scencd_c string error cases:
   
      1) Null SCLK string.
      2) Empty SCLK string.
      
   */
   scencd_c ( CLK_ID,  NULLCPTR, &et );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   
   scencd_c ( CLK_ID,  "", &et );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );
            





   
   
   /*
   Case 3:
   */
   tcase_c ( "Encode ET as continuous ticks. Convert ticks to ET. " 
             "Make sure the conversion is invertible."              );
   
   /*
   Note:  according to our SCLK kernel, one tick is 1.e-4 seconds.
   */
   
   str2et_c ( "1980 Jan 1 00:00:10.00005 TDB", &expet );
    
   expsclkdp = 10.00005 * 1.e4;
      
   sce2c_c  ( CLK_ID, expet, &cclkdp );
   chckxc_c ( SPICEFALSE, " ", ok );

   chcksd_c ( "continuous ticks", cclkdp, "~", expsclkdp, 1.0e-3, ok );

   
   sct2e_c  ( CLK_ID, cclkdp,   &et );
   chcksd_c ( "et", et, "~", expet, 1.0e-6, ok );


   
   
   /*
   Case 4:
   */
   tcase_c ( "Round case 3 tick value to a long.  Convert ticks to ET. " 
             "Make sure the conversion is invertible."              );
   
   
   
   expsclkdp = (long) cclkdp;
   
   sct2e_c ( CLK_ID, expsclkdp, &et     );
   sce2t_c ( CLK_ID, et,        &sclkdp ); 
   chckxc_c ( SPICEFALSE, " ", ok );
   
   chcksd_c ( "sclkdp", sclkdp, "~", expsclkdp, 0.0, ok );
   


   
   /*
   Case 5:
   */
   tcase_c ( "Encode a tick value without partition.  Make sure "
             "the original value can be recovered.  Use sctiks_c "
             "and scfmt_c."                                        );
   
   sctiks_c ( CLK_ID, TICK_STR, &ticks );
   chckxc_c ( SPICEFALSE, " ", ok );

   scfmt_c  ( CLK_ID, ticks, TIMLEN, tickstr ); 
   chckxc_c ( SPICEFALSE, " ", ok );
   
   chcksc_c ( "tickstr", tickstr, "=", TICK_STR, ok );
   

   
   /*
   Check sctiks_c string error cases:
   
      1) Null SCLK string.
      2) Empty SCLK string.
      
   */
   sctiks_c ( CLK_ID,  NULLCPTR, &et );
   chckxc_c ( SPICETRUE, "SPICE(NULLPOINTER)", ok );
   
   sctiks_c ( CLK_ID,  "", &et );
   chckxc_c ( SPICETRUE, "SPICE(EMPTYSTRING)", ok );
            



   
   /*
   Case 6:
   */
   
   tcase_c ( "Retrieve the partitions for this clock." );
   
   scpart_c ( CLK_ID, &npart, pstart, pstop );
   chckxc_c ( SPICEFALSE, " ", ok );
   
   
   chcksi_c ( "npart",     npart,     "=", 1,     0.0, ok );
   chcksd_c ( "pstart[0]", pstart[0], "=", 0.0,   0.0, ok );
   chcksd_c ( "pstop[0]",  pstop[0],  "=", 1.e14, 0.0, ok );
   
   
   /*
   Remove the kernel(s).
   */
   TRASH ( SCLK );
   
   
   /*
   Retrieve the current test status.
   */ 
   t_success_c ( ok ); 
   
   
} /* End f_sclk_c */



