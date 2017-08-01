/*

-Procedure  ckw01_c ( C-Kernel, write segment to C-kernel, data type 1 )

-Abstract
 
   Add a type 1 segment to a C-kernel. 
 
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
   #undef    ckw01_c
   

   void ckw01_c ( SpiceInt            handle, 
                  SpiceDouble         begtim,
                  SpiceDouble         endtim,
                  SpiceInt            inst,
                  ConstSpiceChar    * ref,
                  SpiceBoolean        avflag,
                  ConstSpiceChar    * segid, 
                  SpiceInt            nrec,
                  ConstSpiceDouble    sclkdp [],
                  ConstSpiceDouble    quats  [][4],
                  ConstSpiceDouble    avvs   [][3]  )
/*

-Brief_I/O
 
   Variable  I/O  Description 
   --------  ---  -------------------------------------------------- 
   handle     I   Handle of an open CK file. 
   begtim     I   The beginning encoded SCLK of the segment. 
   endtim     I   The ending encoded SCLK of the segment. 
   inst       I   The NAIF instrument ID code. 
   ref        I   The reference frame of the segment. 
   avflag     I   True if the segment will contain angular velocity. 
   segid      I   Segment identifier. 
   nrec       I   Number of pointing records. 
   sclkdp     I   Encoded SCLK times. 
   quats      I   Quaternions representing instrument pointing. 
   avvs       I   Angular velocity vectors. 
 
-Detailed_Input
 
   handle     is the handle of the CK file to which the segment will 
              be written. The file must have been opened with write 
              access. 
 
   begtim     is the beginning encoded SCLK time of the segment. This 
              value should be less than or equal to the first time in 
              the segment. 
 
   endtim     is the encoded SCLK time at which the segment ends. 
              This value should be greater than or equal to the last 
              time in the segment. 
 
   inst       is the NAIF integer ID code for the instrument. 
 
   ref        is a character string which specifies the  
              reference frame of the segment. This should be one of 
              the frames supported by the SPICELIB routine NAMFRM 
              which is an entry point of FRAMEX. 
 
   avflag     is a logical flag which indicates whether or not the 
              segment will contain angular velocity. 
 
   segid      is the segment identifier.  A CK segment identifier may 
              contain up to 40 characters, excluding the terminating
              null.
 
   nrec       is the number of pointing instances in the segment. 
 
   sclkdp     are the encoded spacecraft clock times associated with 
              each pointing instance. These times must be strictly 
              increasing. 
 
   quats      are the quaternions representing the C-matrices. 
 
   avvs       are the angular velocity vectors (optional). 
 
              If avflag is FALSE then this array is ignored by the 
              routine, however it still must be supplied as part of 
              the calling sequence. 
 
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
 
   4)  If the first encoded SCLK time is negative then the error 
       SPICE(INVALIDSCLKTIME) is signalled. If any subsequent times 
       are negative the error SPICE(TIMESOUTOFORDER) is signalled. 
 
   5)  If the encoded SCLK times are not strictly increasing, 
       the error SPICE(TIMESOUTOFORDER) is signalled. 
 
   6)  If begtim is greater than sclkdp[0] or endtim is less than 
       sclkdp[nrec-1], the error SPICE(INVALIDDESCRTIME) is 
       signalled. 
 
   7)  If the name of the reference frame is not one of those 
       supported by the SPICELIB routine NAMFRM, the error 
       SPICE(INVALIDREFFRAME) is signalled. 
 
   8)  If nrec, the number of pointing records, is less than or 
       equal to 0, the error SPICE(INVALIDNUMRECS) is signalled. 
 
-Files
 
   This routine adds a type 1 segment to a C-kernel.  The C-kernel 
   may be either a new one or an existing one opened for writing. 
 
-Particulars
 
   For a detailed description of a type 1 CK segment please see the 
   CK Required Reading. 
 
   This routine relieves the user from performing the repetitive 
   calls to the DAF routines necessary to construct a CK segment. 
 
-Examples
 
  
   This example writes a type 1 C-kernel segment for the 
   Galileo scan platform to a previously opened file attached to 
   handle. 
 
      /.
      Include CSPICE interface definitions.
      ./
      #include "SpiceUsr.h"
                .
                .
                .
      /.
      Assume arrays of quaternions, angular velocities, and the 
      associated SCLK times are produced elsewhere. 
      ./
                . 
                . 
                . 
      /.
      The subroutine ckw01_c needs the following items for the 
      segment descriptor: 
      
         1) SCLK limits of the segment. 
         2) Instrument code. 
         3) Reference frame. 
         4) The angular velocity flag. 
      ./
      
      begtim  = (SpiceChar *) sclk[1]; 
      endtim  = (SpiceChar *) sclk[nrec];
 
      inst    = -77001;
      ref     = "J2000";
      avflag  = SPICETRUE;
      segid   = "GLL SCAN PLT - DATA TYPE 1"; 
 
      /.
      Write the segment. 
      ./
      ckw01_c ( handle,  begtim,  endtim,  inst,  ref,  avflag, 
                segid,   nrec,    sclkdp,  quats, avvs         );
                
                . 
                . 
                . 
             
      /.
      After all segments are written, close the C-kernel.
      ./
      ckcls_c ( handle );
      
 
-Restrictions
 
   None. 
 
-Literature_References
 
   None. 
 
-Author_and_Institution
 
   K.R. Gehringer  (JPL) 
   N.J. Bachman    (JPL) 
   J.M. Lynch      (JPL) 
 
-Version
 
   -CSPICE Version 1.3.0, 28-AUG-2001 (NJB)

       Changed prototype:  inputs sclkdp, quats, and avvs are now
       const-qualified.  Implemented interface macros for casting 
       these inputs to const.
            
   -CSPICE Version 1.2.0, 02-SEP-1999 (NJB)  
   
      Local type logical variable now used for angular velocity
      flag used in interface of ckw01_.
            
   -CSPICE Version 1.1.0, 08-FEB-1998 (NJB)  
   
       References to C2F_CreateStr_Sig were removed; code was
       cleaned up accordingly.  String checks are now done using
       the macro CHKFSTR.
       
   -CSPICE Version 1.0.0, 25-OCT-1997 (NJB)
   
      Based on SPICELIB Version 2.0.0, 28-DEC-1993 (WLT)

-Index_Entries
 
   write ck type_1 pointing data segment 
 
-&
*/

{ /* Begin ckw01_c */


   /*
   Local variables
   */
   logical                 avf;
   
   
   /*
   Participate in error handling.
   */
   chkin_c ( "ckw01_c" );

 
   /*
   Check the input strings to make sure the pointers
   are non-null and the string lengths are non-zero.
   */
   CHKFSTR ( CHK_STANDARD, "ckw01_c", ref   );
   CHKFSTR ( CHK_STANDARD, "ckw01_c", segid );
 
   /*
   Get a type logical copy of the a.v. flag.
   */
   avf = avflag;
   
 
   /*
   Write the segment.  Note that the quaternion and angular velocity
   arrays DO NOT require transposition!
   */

   ckw01_( ( integer    * ) &handle, 
           ( doublereal * ) &begtim, 
           ( doublereal * ) &endtim, 
           ( integer    * ) &inst, 
           ( char       * ) ref, 
           ( logical    * ) &avf, 
           ( char       * ) segid, 
           ( integer    * ) &nrec, 
           ( doublereal * ) sclkdp,
           ( doublereal * ) quats, 
           ( doublereal * ) avvs, 
           ( ftnlen       ) strlen(ref), 
           ( ftnlen       ) strlen(segid)  );


   chkout_c ( "ckw01_c" );

} /* End ckw01_c */
