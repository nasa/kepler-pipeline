/*

-Procedure  ckw03_c ( C-Kernel, write segment to C-kernel, data type 3 )

-Abstract
 
   Add a type 3 segment to a C-kernel. 
 
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
   #undef    ckw03_c


   void ckw03_c ( SpiceInt            handle, 
                  SpiceDouble         begtim,
                  SpiceDouble         endtim,
                  SpiceInt            inst,
                  ConstSpiceChar    * ref,
                  SpiceBoolean        avflag,
                  ConstSpiceChar    * segid, 
                  SpiceInt            nrec,
                  ConstSpiceDouble    sclkdp [],
                  ConstSpiceDouble    quats  [][4],
                  ConstSpiceDouble    avvs   [][3],
                  SpiceInt            nints,
                  ConstSpiceDouble    starts []    )
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
   nints      I   Number of intervals.
   starts     I   Encoded SCLK interval start times.
 
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
 
              The rotation matrices represented by the quaternions
              that are to be written to the segment transform the
              components of vectors from the inertial reference frame
              specified by ref to components in the instrument fixed
              frame. Also, the components of the angular velocity
              vectors to be written to the segment should be given
              with respect to ref.

              ref should be the name of one of the frames supported
              by the SPICELIB routine NAMFRM.


   avflag     is a boolean flag which indicates whether or not the 
              segment will contain angular velocity. 
 
   segid      is the segment identifier.  A CK segment identifier may 
              contain up to 40 characters, excluding the terminating
              null.
 
   nrec       is the number of pointing instances in the segment. 
 
   sclkdp     are the encoded spacecraft clock times associated with 
              each pointing instance. These times must be strictly 
              increasing. 
 
   quats      are the quaternions representing the C-matrices, as
              defined in the ROTATIONS Required Reading and by the
              CSPICE routine q2m_c ( quaternion to matrix ).

              The C-matrix represented by the ith quaternion in
              quats is a rotation matrix that transforms the
              components of a vector expressed in the inertial
              frame specified by ref to components expressed in
              the instrument fixed frame at the time sclkdp[i].

              Thus, if a vector V has components x, y, z in the
              inertial frame, then V has components x', y', z' in
              the instrument fixed frame where:

                   [ x' ]     [          ] [ x ]
                   | y' |  =  |   cmat   | | y |
                   [ z' ]     [          ] [ z ]

   avvs       are the angular velocity vectors ( optional ).

              The ith vector in avvs gives the angular velocity of
              the instrument fixed frame at time sclkdp[i]. The
              components of the angular velocity vectors should
              be given with respect to the inertial reference frame
              specified by ref.

              The direction of an angular velocity vector gives
              the right-handed axis about which the instrument fixed
              reference frame is rotating. The magnitude of the
              vector is the magnitude of the instantaneous velocity
              of the rotation, in radians per second.

              If avflag is FALSE then this array is ignored by the
              routine; however it still must be supplied as part of
              the calling sequence.

   nints      is the number of intervals that the pointing instances
              are partitioned into.

   starts     are the start times of each of the interpolation
              intervals. These times must be strictly increasing
              and must coincide with times for which the segment
              contains pointing.
 
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
 
   9)  If nints, the number of interpolation intervals, is less than
       or equal to 0, the error SPICE(INVALIDNUMINTS) is signalled.

   10) If the encoded SCLK interval start times are not strictly
       increasing, the error SPICE(TIMESOUTOFORDER) is signalled.

   11)  If an interval start time does not coincide with a time for
        which there is an actual pointing instance in the segment,
        then the error SPICE(INVALIDSTARTTIME) is signalled.
 
   12)  This routine assumes that the rotation between adjacent
        quaternions that are stored in the same interval has a
        rotation angle of THETA radians, where
 
           0  <  THETA  <  pi.
              _

        The routines that evaluate the data in the segment produced
        by this routine cannot distinguish between rotations of THETA
        radians, where THETA is in the interval [0, pi), and
        rotations of

           THETA   +   2 * k * pi

        radians, where k is any integer.  These `large' rotations will
        yield invalid results when interpolated.  You must ensure that
        the data stored in the segment will not be subject to this
        sort of ambiguity.

   14)  If the start time of the first interval and the time of the
        first pointing instance are not the same, the error
        SPICE(TIMESDONTMATCH) is signaled.

-Files
 
   This routine adds a type 3 segment to a C-kernel.  The C-kernel 
   may be either a new one or an existing one opened for writing. 
 
-Particulars
 
   For a detailed description of a type 3 CK segment please see the 
   CK Required Reading. 
 
   This routine relieves the user from performing the repetitive 
   calls to the DAF routines necessary to construct a CK segment. 
 
-Examples
 
   This example code fragment writes a type 3 C-kernel segment
   for the Mars Global Surveyor spacecraft bus to a previously opened CK
   file attached to HANDLE.
 
      /.
      Include CSPICE interface definitions.
      ./
      #include "SpiceUsr.h"
                .
                .
                .
      /.
      Assume arrays of quaternions, angular velocities, and the
      associated SCLK times are produced elsewhere.  The software
      that calls ckw03_c must then decide how to partition these
      pointing instances into intervals over which linear
      interpolation between adjacent points is valid.
      ./
                 .
                 .
                 .
 
      /.
      The subroutine ckw03_c needs the following items for the
      segment descriptor:
 
         1) SCLK limits of the segment.
         2) Instrument code.
         3) Reference frame.
         4) The angular velocity flag.
         
      ./
      
      begtim = sclk [      0 ];
      endtim = sclk [ nrec-1 ];

      inst   =  -94000;
      ref    =  "j2000";
      avflag =  SPICETRUE;

      segid  = "MGS spacecraft bus - data type 3";
 
      /.
      Write the segment. 
      ./
      ckw03_c ( handle,  begtim,  endtim,  inst,  ref,  avflag, 
                segid,   nrec,    sclkdp,  quats, avvs, nints,
                starts                                         );
                . 
                . 
                . 
      /.
      After all segments are written, close the C-kernel.
      ./
      ckcls_c ( handle );
      
 
-Restrictions
 
   1)  The creator of the segment is given the responsibility for
       determining whether it is reasonable to interpolate between
       two given pointing values.

   2)  This routine assumes that the rotation between adjacent
       quaternions that are stored in the same interval has a
       rotation angle of THETA radians, where

           0  <  THETA  <  pi.
              _

       The routines that evaluate the data in the segment produced
       by this routine cannot distinguish between rotations of THETA
       radians, where THETA is in the interval [0, pi), and
       rotations of

           THETA   +   2 * k * pi

       radians, where k is any integer.  These `large' rotations will
       yield invalid results when interpolated.  You must ensure that
       the data stored in the segment will not be subject to this
       sort of ambiguity.

   3)  All pointing instances in the segment must belong to one and
       only one of the intervals.
 
-Literature_References
 
   None. 
 
-Author_and_Institution
 
   K.R. Gehringer  (JPL) 
   N.J. Bachman    (JPL) 
   J.M. Lynch      (JPL)
   B.V. Semenov    (JPL) 
   E.D. Wright     (JPL)
 
-Version
 
   -CSPICE Version 1.4.1, 27-SEP-2005 (BVS)

       Added an item for SPICE(TIMESDONTMATCH) exception to the 
       Exceptions section of the header.

   -CSPICE Version 1.3.1, 07-JAN-2004 (EDW)

       Trivial typo correction in index entries section.

   -CSPICE Version 1.3.0, 28-AUG-2001 (NJB)

       Changed prototype:  inputs  sclkdp, quats, avvs, and starts 
       are now const-qualified.  Implemented interface macros for 
       casting these inputs to const.
            
   -CSPICE Version 1.2.0, 02-SEP-1999 (NJB)  
   
       Local type logical variable now used for angular velocity
       flag used in interface of ckw03_.
            
   -CSPICE Version 1.1.0, 08-FEB-1998 (NJB)  
   
       References to C2F_CreateStr_Sig were removed; code was
       cleaned up accordingly.  String checks are now done using
       the macro CHKFSTR.
       
   -CSPICE Version 1.0.0, 25-OCT-1997 (NJB)
   
       Based on SPICELIB Version 2.0.0, 28-DEC-1993 (WLT)

-Index_Entries
 
   write ck type_3 pointing data segment 
 
-&
*/

{ /* Begin ckw03_c */



   /*
   Local variables
   */
   logical                 avf;
   
   
   /*
   Participate in error handling.
   */
   chkin_c ( "ckw03_c" );

 
   /*
   Check the input strings to make sure the pointers
   are non-null and the string lengths are non-zero.
   */
   CHKFSTR ( CHK_STANDARD, "ckw03_c", ref   );
   CHKFSTR ( CHK_STANDARD, "ckw03_c", segid );
    
 
   /*
   Get a type logical copy of the a.v. flag.
   */
   avf = avflag;
   
   
   /*
   Write the segment.  Note that the quaternion and angular velocity
   arrays DO NOT require transposition!
   */
   
   ckw03_( ( integer    * ) &handle, 
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
           ( integer    * ) &nints, 
           ( doublereal * ) starts, 
           ( ftnlen       ) strlen(ref), 
           ( ftnlen       ) strlen(segid)  );


   chkout_c ( "ckw03_c" );

} /* End ckw03_c */
