/*

-Procedure ckw02_c ( C-Kernel, write segment to C-kernel, data type 2 )

-Abstract
 
   Write a type 2 segment to a C-kernel. 
 
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
 
   CK 
   DAF 
   SCLK 
 
-Keywords
 
   POINTING 
   UTILITY 
 
*/

   #include "SpiceUsr.h"
   #include "SpiceZfc.h"
   #include "SpiceZmc.h"
   #include "SpiceZim.h"
   #undef    ckw02_c


   void ckw02_c ( SpiceInt            handle, 
                  SpiceDouble         begtim,
                  SpiceDouble         endtim,
                  SpiceInt            inst,
                  ConstSpiceChar    * ref,
                  ConstSpiceChar    * segid, 
                  SpiceInt            nrec,
                  ConstSpiceDouble    start  [],
                  ConstSpiceDouble    stop   [],
                  ConstSpiceDouble    quats  [][4],
                  ConstSpiceDouble    avvs   [][3],
                  ConstSpiceDouble    rates  []    )

/*

-Brief_I/O
 
   Variable  I/O  Description 
   --------  ---  -------------------------------------------------- 
   handle     I   Handle of an open CK file. 
   begtim     I   The beginning encoded SCLK of the segment. 
   endtim     I   The ending encoded SCLK of the segment. 
   inst       I   The NAIF instrument ID code. 
   ref        I   The reference frame of the segment. 
   segid      I   Segment identifier. 
   nrec       I   Number of pointing records. 
   start      I   Encoded SCLK interval start times. 
   stop       I   Encoded SCLK interval stop times. 
   quats      I   Quaternions representing instrument pointing. 
   avvs       I   Angular velocity vectors. 
   rates      I   Number of seconds per tick for each interval. 
 
-Detailed_Input
 
   handle     is the handle of the CK file to which the segment will 
              be written. The file must have been opened with write 
              access. 
 
   begtim     is the beginning encoded SCLK time of the segment. This 
              value should be less than or equal to the first START 
              time in the segment. 
 
   endtim     is the encoded SCLK time at which the segment ends. 
              This value should be greater than or equal to the last 
              STOP time in the segment. 
 
   inst       is the NAIF integer ID code for the instrument. 
 
   ref        is a character string that specifies the  
              reference frame of the segment. This should be one of 
              the frames supported by the SPICELIB routine NAMFRM
              which is an entry point of FRAMEX.
 
   segid      is the segment identifier.  A CK segment identifier may 
              contain up to 40 characters. 
 
   nrec       is the number of pointing intervals that will be 
              written to the segment. 
 
   start      are the start times of each interval in encoded 
              spacecraft clock. These times must be strictly 
              increasing. 
 
   stop       are the stop times of each interval in encoded 
              spacecraft clock. These times must be greater than 
              the START times that they correspond to but less 
              than or equal to the START time of the next interval. 
 
   quats      are the quaternions representing the C-matrices 
              associated with the start times of each interval. 
 
   AVVS       are the angular velocity vectors for each interval. 
 
   RATES      are the number of seconds per encoded spacecraft clock 
              tick for each interval. 
 
              In most applications this value will be the same for 
              each interval within a segment.  For example, when 
              constructing a predict C-kernel for Mars Observer, the 
              rate would be 1/256 for each interval since this is 
              the smallest time unit expressible by the MO clock. The 
              nominal seconds per tick rates for Galileo and Voyager 
              are 1/120 and 0.06 respectively. 
 
-Detailed_Output
 
   None.  See Files section. 
 
-Parameters
 
   None. 
 
-Exceptions
 
   1)  If handle is not the handle of a C-kernel opened for writing 
       the error will be diagnosed by routines called by this 
       routine. 
 
   2)  If segid is more than 40 characters long, the error 
       SPICE(SEGIDTOOLONG) is signalled. 
 
   3)  If segid contains any nonprintable characters, the error 
       SPICE(NONPRINTABLECHARS) is signalled. 
 
   4)  If the first START time is negative, the error 
       SPICE(INVALIDSCLKTIME) is signalled. If any of the subsequent 
       START times are negative the error SPICE(TIMESOUTOFORDER) 
       will be signalled. 
 
   5)  If any of the STOP times are negative, the error 
       SPICE(DEGENERATEINTERVAL) is signalled. 
 
   6)  If the STOP time of any of the intervals is less than or equal 
       to the START time, the error SPICE(DEGENERATEINTERVAL) is 
       signalled. 
 
   7)  If the START times are not strictly increasing, the 
       error SPICE(TIMESOUTOFORDER) is signalled. 
 
   8)  If the STOP time of one interval is greater than the START 
       time of the next interval, the error SPICE(BADSTOPTIME) 
       is signalled. 
 
   9)  If begtim is greater than START[0] or endtim is less than 
       STOP[NREC-1], the error SPICE(INVALIDDESCRTIME) is 
       signalled. 
 
  10)  If the name of the reference frame is not one of those 
       supported by the routine NAMFRM, the error 
       SPICE(INVALIDREFFRAME) is signalled. 
 
  11)  If nrec, the number of pointing records, is less than or 
       equal to 0, the error SPICE(INVALIDNUMRECS) is signalled. 
 
-Files
 
   This routine adds a type 2 segment to a C-kernel.  The C-kernel 
   may be either a new one or an existing one opened for writing. 
 
-Particulars
 
   For a detailed description of a type 2 CK segment please see the 
   CK Required Reading. 
 
   This routine relieves the user from performing the repetitive 
   calls to the DAF routines necessary to construct a CK segment. 
 
-Examples
 
  
   This example writes a predict type 2 C-kernel segment for 
   the Mars Observer spacecraft bus to a previously opened CK file 
   attached to handle. 
 
  
      /.
      Assume arrays of quaternions, angular velocities, and interval 
      start and stop times are produced elsewhere. 
      ./
   
      . 
      . 
      . 
 
      /.
      The nominal number of seconds in a tick for MO is 1/256.
      ./
      sectik = 1. / 256.;
  
      for ( i = 0; i < nrec;  i++ )
      {
         rate[i] = sectik;
      }
 
      /.
      The subroutine ckw02_c needs the following components of the 
      segment descriptor: 
  
         1) SCLK limits of the segment. 
         2) Instrument code. 
         3) Reference frame. 
      ./
      begtim  =  start [    0 ];
      endtim  =  stop  [nrec-1]; 
 
      inst    =  -94000;
      ref     =  "j2000";
 
      segid = "mo predict seg type 2";
 
      /.
      Write the segment. 
      ./
      ckw02_c ( handle, begtim, endtim, inst, ref, segid, 
                nrec,   start,  stop,   quat, avv, rates  ); 
 
 
-Restrictions
 
   None. 
 
-Literature_References
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
   K.R. Gehringer  (JPL) 
   J.M. Lynch      (JPL) 
 
-Version
 
   -CSPICE Version 1.2.0, 28-AUG-2001 (NJB)

       Changed prototype:  inputs start, stop, sclkdp, quats, 
       and avvs are now const-qualified.  Implemented interface 
       macros for casting these inputs to const.
            
   -CSPICE Version 1.1.0, 08-FEB-1998 (NJB)  
   
       References to C2F_CreateStr_Sig were removed; code was
       cleaned up accordingly.  String checks are now done using
       the macro CHKFSTR.
       
   -CSPICE Version 1.0.0, 25-OCT-1997 (NJB)
   
      Based on SPICELIB Version 2.0.0, 28-DEC-1993 (WLT)

-Index_Entries
 
   write ck type_2 pointing data segment 
 
-&
*/

{ /* Begin ckw02_c */

   /*
   Participate in error handling.
   */
   chkin_c ( "ckw02_c" );

   /*
   Check the input strings to make sure the pointers
   are non-null and the string lengths are non-zero.
   */
   CHKFSTR ( CHK_STANDARD, "ckw02_c", ref   );
   CHKFSTR ( CHK_STANDARD, "ckw02_c", segid );
 
 
   /*
   Write the segment.  Note that the quaternion and angular velocity
   arrays DO NOT require transposition!
   */
   
   ckw02_( ( integer    * ) &handle, 
           ( doublereal * ) &begtim, 
           ( doublereal * ) &endtim, 
           ( integer    * ) &inst, 
           ( char       * ) ref, 
           ( char       * ) segid, 
           ( integer    * ) &nrec, 
           ( doublereal * ) start,
           ( doublereal * ) stop,
           ( doublereal * ) quats, 
           ( doublereal * ) avvs, 
           ( doublereal * ) rates, 
           ( ftnlen       ) strlen(ref), 
           ( ftnlen       ) strlen(segid)  );


   chkout_c ( "ckw02_c" );

} /* End ckw02_c */
