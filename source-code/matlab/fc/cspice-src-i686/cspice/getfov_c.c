/*

-Procedure getfov_c (Get instrument FOV configuration)

-Abstract
 
   This subroutine returns the field-of-view (FOV) configuration for a
   specified instrument.
 
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
 
   INSTRUMENT
 
*/

   #include "SpiceUsr.h"
   #include "SpiceZfc.h"
   #include "SpiceZst.h"
   #include "SpiceZmc.h"

   void getfov_c ( SpiceInt        instid,
                   SpiceInt        room,
                   SpiceInt        shapelen,
                   SpiceInt        framelen,
                   SpiceChar     * shape,
                   SpiceChar     * frame,
                   SpiceDouble     bsight [3],
                   SpiceInt      * n,
                   SpiceDouble     bounds [][3] ) 

/*

-Brief_I/O
 
   VARIABLE  I/O  DESCRIPTION 
   --------  ---  -------------------------------------------------- 
   instid     I   NAIF ID of an instrument.
   room       I   Maximum number of vectors that can be returned. 
   shapelen   I   Space available in the string `shape'.
   framelen   I   Space available in the string `frame'.
   shape      O   Instrument FOV shape. 
   frame      O   Name of the frame in which FOV vectors are defined. 
   bsight     O   Boresight vector. 
   n          O   Number of boundary vectors returned. 
   bounds     O   FOV boundary vectors. 
 
-Detailed_Input
 
   instid     NAIF ID of an instrument. 
 
   room       The amount of room allocated in `bounds' for returning 
              components of boundary vectors. 

   shapelen   is the available space in the `shape' string, counting
              room for the terminating null.  Up to shapelen-1 "data"
              characters will be assigned to the output string `shape'.
 
   framelen   is the available space in the `frame' string, counting
              room for the terminating null.  Up to framelen-1 "data"
              characters will be assigned to the output string `frame'.

-Detailed_Output
 
   shape      is a character string that describes the "shape" of 
              the field of view.  Possible values returned are: 
 
                 "POLYGON"
                 "RECTANGLE"
                 "CIRCLE"
                 "ELLIPSE" 
 
              If the value of `shape' is "POLYGON" the field of view of
              the instrument is a pyramidal polyhedron. The vertex of
              the pyramid is at the instrument focal point. The rays
              along the edges of the pyramid are parallel to the
              vectors returned in `bounds'.
 
              If the value of `shape' is "RECTANGLE" the field of view
              of the instrument is a rectangular pyramid. The vertex of
              the pyramid is at the instrument focal point.  The rays
              along the edges of the pyramid are parallel to the
              vectors returned in `bounds'.  Moreover, in this case,
              the boresight points along the axis of symmetry of the
              rectangular pyramid.
 
              If the value of `shape' is "CIRCLE" the field of view of
              the instrument is a circular cone about the boresight
              vector.  The vertex of the cone is at the instrument
              focal point.  A single vector will be returned in
              `bounds'.  This vector will be parallel to a ray that
              lies in the cone that makes up the boundary of the field
              of view.
 
              If the value of `shape' is "ELLIPSE" the field of view of
              the instrument is an elliptical cone with the boresight
              vector as the axis of the cone.  The vertex of the cone
              is at the instrument focal point. Two vectors are
              returned in `bounds'. One of the vectors points to the
              end of the semi-major axis of a perpendicular cross
              section of the elliptic cone.  The other vector points to
              the end of the semi-minor axis of a perpendicular cross
              section of the cone.
 
  
   frame      is the name of the reference frame in which the field of 
              view boundary vectors are defined. 
 
   bsight     is a vector that points in the direction of the 
              center of the field of view.  The length of bsight 
              is not specified other than being non-zero. 
 
   n          is the number of boundary vectors returned. 
 
   bounds     is an array of vectors that point to the "corners" 
              of the instrument field of view.  (See the discussion 
              accompanying `shape' for an expansion of the term 
              "corner of the field of view.")  Note that the vectors 
              returned in `bounds' are not necessarily unit vectors. 
 
-Parameters
 
   MINCOS     This parameter is the lower limit on the value of the
              cosine of the cross or reference angles in the ANGLES
              specification cases (see Particulars for further
              discussion). The parameter and its current value,
              1.0x10^(-15), are employed in the C code derived from the
              Fortran version of GETFOV that this wrapper invokes.
 
-Files
 
   This routine relies upon having successfully loaded an instrument
   kernel (IK-file) via the routine furnsh_c prior to calling this
   routine.
 
-Exceptions

   1) The error SPICE(NULLPOINTER) is signaled if either the `shape' or
      `frame' string pointers are null.

   2) The user must pass values indicating the length of the `shape' 
      and `frame' strings.  If these values are not at least 2, the
      error SPICE(STRINGTOOSHORT) is signaled.
 
   3) The error SPICE(FRAMEMISSING) is signaled if the reference frame
      associated with the instrument can not be found in the kernel
      pool.
 
   4) The error SPICE(SHAPEMISSING) is signaled if the shape of the
      instrument field of view can not be found in the kernel pool.
 
   5) The error SPICE(SHAPENOTSUPPORTED) is signaled if the shape
      specified by the instrument kernel is not one of the four
      values: 'CIRCLE', 'POLYGON', 'ELLIPSE', 'RECTANGLE'.  If the
      ANGLES specification is used it must be: 'CIRCLE', 'ELLIPSE', or 
     'RECTANGLE'.
 
   6) The error SPICE(BORESIGHTMISSING) is signaled if the direction
      of the boresight cannot be located in the kernel pool.
 
   7) The error SPICE(BADBORESIGHTSPEC) is signaled if the number of
      components for the boresight vector in the kernel pool is not 3.
 
   8) The error SPICE(BOUNDARYMISSING) is signaled if the boundary
      vectors for the edge of the field of view cannot be found in the
      kernel pool.
 
   9) The error SPICE(BOUNDARYTOOBIG) is signaled if there is
      insufficient room (as specified by the variable `room') to return
      all of the vectors associated with the boundary of the field of
      view.
 
  10) The error SPICE(BADBOUNDARY) is signaled if the number of
      components of vectors making up the field of view is not a
      multiple of 3.
 
  11) The error SPICE(BADBOUNDARY) is signaled if the number of
      components of vectors making up the field of view is not
      compatible with the shape specified for the field of view.

  12) The error SPICE(REFVECTORMISSING) is signaled if the 
      reference vector for the ANGLES spec can not be found
      in the kernel pool.

  13) The error SPICE(BADREFVECTORSPEC) is signaled if the
      reference vector stored in the kernel pool to support
      the ANGLES spec contains an incorrect number of components,
      contains 3 character components, or is parallel to the
      boresight.
 
  14) The error SPICE(REFANGLEMISSING) is signaled if the reference
      angle that supports the ANGLES spec is absent from the kernel
      pool.
 
  15) The error SPICE(UNITSMISSING) is signaled if the
      keyword that stores the angular units for the angles
      used in the ANGLES spec is absent from the kernel pool.
  
  16) The error SPICE(CROSSANGLEMISSING) is signaled if the
      keyword that stores the cross angle for the ANGLES spec
      is needed and is absent from the kernel pool.
 
  17) The error SPICE(BADBOUNDARY) is signaled if the angles
      for the RECTANGLE/ANGLES spec case have cosines that
      are less than those stored in the parameter MINCOS.
 
  18) The error SPICE(UNSUPPORTEDSPEC) is signaled if the
      class specification contains something other than 'ANGLES'
      or 'CORNERS'.
 
  19) In the event that the CLASS_SPEC keyword is absent from the
      kernel pool for the instrument whose FOV is sought, this
      module assumes the default CORNERS specification is to be
      utilized.
 
-Particulars
 
   This routine provides a common interface to retrieving the
   geometric characteristics of an instrument field of view for a wide
   variety of remote sensing instruments across many different space
   missions.
 
   Given the NAIF instrument ID, and having "loaded" the instrument
   field of view description via the routine furnsh_c, this routine
   returns the boresight of the instrument, the "shape" of the field
   of view, a collection of vectors that point along the edges of the
   field of view, and the name of the reference frame in which these
   vectors are defined.

   Currently this routine supports two classes of specifications
   for FOV definitions.  Which class this module examines is
   determined by the contents of the keyword:

      INS<INSTID>_FOV_CLASS_SPEC

   where <INSTID> is replaced with the instrument ID as passed
   into the module.  In the event this keyword is absent, the
   default 'CORNERS' specification is assumed.

      CORNERS Specification:

      This specification requires keywords in the kernel pool that
      define the shape, boresight, boundary vectors, and reference
      frame of the FOV.  The list of supported shapes is:

         CIRCLE
         ELLIPSE
         RECTANGLE
         POLYGON

      ANGLES Specification:

      This specification requires keywords in the kernel pool that
      define the shape, boresight, reference vector, reference and
      cross angular extents of the FOV.  The list of supported shapes
      is:

         CIRCLE
         ELLIPSE
         RECTANGLE
 
   This routine is intended to be an intermediate level routine.  It
   is expected that users of this routine will be familiar with the
   SPICE frames subsystem and will be comfortable writing software to
   further manipulate the vectors retrieved by this routine.
 
-Examples
 
   Suppose you need to determine the planetocentric latitude and
   longitude of the points where the corners of a rectangular field of
   view intersect the surface of an object.  This routine together
   with a handful of other SPICE routines allows you to easily make
   this determination.
 
   (Note that this example assumes that all necessary SPICE kernels 
   have been loaded.) 
 
      /.
      Local Variables and Parameters 
      ./
      #define               WDSIZE            32

      SpiceChar             bdyfxd [ WDSIZE ];
      SpiceChar             frame  [ WDSIZE ];
      SpiceChar             shape  [ WDSIZE ];
 
      SpiceDouble           abc    [3]; 
      SpiceDouble           bounds [4][3];
      SpiceDouble           bsight [3]; 
      SpiceDouble           et; 
      SpiceDouble           fov    [4][3];
      SpiceDouble           lat; 
      SpiceDouble           lon; 
      SpiceDouble           lt; 
      SpiceDouble           point  [3]; 
      SpiceDouble           posobs [3]; 
      SpiceDouble           radius; 
      SpiceDouble           rot    [3][3]; 
      SpiceDouble           state  [6]; 
      SpiceDouble           frm2j2 [6][6]; 
      SpiceDouble           tsipm  [6][6];
      SpiceDouble           xform  [6][6]; 
 
      SpiceInt              body; 
      SpiceInt              dim; 
      SpiceInt              frcode; 
      SpiceInt              i; 
      SpiceInt              instid; 
      SpiceInt              j; 
      SpiceInt              n; 
      SpiceInt              obs; 
      SpiceInt              room = 4;
 
      SpiceBoolean          found; 
 
      /.  
      Determine the object, instrument and time at which the 
      latitude and longitude should be computed.  
      ./
      get_particulars ( &instid, &body, &et );

      /.
      Get the field of view information 
      ./ 
      getfov_c ( instid, room, WDSIZE, WDSIZE, shape, frame,
                 bsight, &n,    bounds                       );
 
      /.
      Using the normal SPICE convention, the observer code can be
      obtained by performing an integer divide on the instrument ID.
      ./
      obs = instid / 1000;

      /. 
      Determine the bodyfixed frame associated with the body 
      being observed. 
      ./
      cidfrm_c ( body, WDSIZE, &frcode, bdyfxd, &found );
 
      if ( !found ) 
      { 
         printf( "Could not get the bodyfixed frame for: %s\n", body ); 
         exit( 1 ); 
      }
 
      /.
      Get the state of the body relative to the bodyfixed frame 
      corrected for light time.  Then compute the apparent position 
      of the observer in the bodyfixed frame. 
      ./
      spkez_c ( body, et, bdyfxd, "LT+S", obs, state, &lt );
      vminus_c( state, posobs );
 
      /.
      Get the transformation from the instrument frame to the 
      bodyfixed frame of the body. 
      ./
      sxform_c ( frame,  "J2000", et,    frm2j2    ); 
      sxform_c ( "J2000", bdyfxd, et-lt, tsipm     ); 
      mxmg_c   ( tsipm,   frm2j2, 6, 6, 6,  xform  );
  
      /.
      We only need the rotation part of the state transformation 
      matrix. 
      ./ 

      for (i=0; i < 3; i++)
      {
         for (j=0; j < 3; j++)
         {
            rot[i][j] = xform[i][j];
         }
      }
 
      /.
      Rotate the field of view into the bodyfixed frame. 
      ./ 

      for (i=0; i < n; i++)
      {                     
         mxv_c ( rot, &(bounds[i][0]), &(fov[i][0]) ) ;
      }
 
      /.
      Look up the axes of the body. 
      ./
      bodvcd_c ( body, "RADII", 3, &dim, abc ); 
 
      /.
      We assume that all of the edges of the field of view 
      intersect the body.  A more robust example would check 
      the FOUND flag after calling surfpt_c. 
      ./ 
      printf ( "The latitude and longitude of the corners are:\n" );
 
      for ( i=0; i < n; i++ )
      {
         surfpt_c ( posobs, &(fov[i]), abc[0], abc[1], abc[2], 
                    point,  &found                            ); 
         reclat_c ( point,  &lat,      &lon,   &radius        );
         
         printf ( "\n"                                     );
         printf ( "    Corner        : %d\n", i            ); 
         printf ( "    Latitude (deg): %f\n", lat*dpr_c()  );
         printf ( "    Longitude(deg): %f\n", lon*dpr_c() );

      }
 
-Restrictions
 
   An I-kernel for the instrument specified in `instid' must have 
   been loaded via a call to furnsh_c prior to calling this routine. 
   Furthermore, the specification for the instrument field of 
   view must be consistent with the expectations of this routine. 
 
-Author_and_Institution
 
   C.H. Acton   (JPL)
   N.J. Bachman (JPL)
   B.V. Semenov (JPL) 
   W.L. Taber   (JPL) 
   F.S. Turner  (JPL)
 
-Literature_References
 
   None. 
 
-Version

   -CSPICE Version 1.0.4, 27-OCT-2005 (NJB)

       Header update:  replaced reference to bodvar_c with 
       reference to bodvcd_c.

   -CSPICE Version 1.0.3, 28-DEC-2004 (BVS)

       Fixed typo in the header example.

   -CSPICE Version 1.0.2, 29-JUL-2003 (NJB) (CHA)

       Various header changes were made to improve clarity.  Some
       minor header corrections were made.

   -CSPICE Version 1.0.1, 18-DEC-2001 (FST)

      Updated the header of this wrapper to document the changes
      in GETFOV regarding the addition of support for the ANGLES
      specification.
 
   -CSPICE Version 1.0.0, 13-APR-2000 (FST)

-Index_Entries
 
   return instrument's FOV configuration 
 
-& 
*/

{ /* Begin getfov_c */

   /*
   Participate in error tracing.
   */
   chkin_c ( "getfov_c" );

   /*
   Make sure the output strings have at least enough room for one
   output character and a null terminator.  Also check for a null
   pointer.  
   */
   CHKOSTR ( CHK_STANDARD, "getfov_c", shape, shapelen );
   CHKOSTR ( CHK_STANDARD, "getfov_c", frame, framelen );

   /*
   Call the f2c converted routine.
   */
   getfov_ ( ( integer    * ) &instid,
             ( integer    * ) &room,
             ( char       * ) shape,
             ( char       * ) frame, 
             ( doublereal * ) bsight,
             ( integer    * ) n,
             ( doublereal * ) bounds,
             ( ftnlen       ) shapelen-1,
             ( ftnlen       ) framelen-1  );

   /*
   The strings returned, shape and frame, are Fortranish type strings.
   Convert the strings to C type.  
   */
   F2C_ConvertStr ( shapelen, shape );
   F2C_ConvertStr ( framelen, frame );

   chkout_c ( "getfov_c" );

} /* End getfov_c */
