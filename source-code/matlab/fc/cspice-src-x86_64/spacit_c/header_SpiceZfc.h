/*

-Header_File SpiceZfc.h ( f2c'd SPICELIB prototypes )

-Abstract

   Define prototypes for functions produced by converting Fortran
   SPICELIB routines to C using f2c.

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

-Literature_References

   None.

-Author_and_Institution

   N.J. Bachman       (JPL)
   K.R. Gehringer     (JPL)

-Version

   - CSPICE Version 6.0.0, 21-FEB-2006 (NJB)

        Added typedefs for the PC-LINUX-64BIT-GCC_C
        environment (these are identical to those for the 
        ALPHA-DIGITAL-UNIX_C environment).

   - C-SPICELIB Version 5.0.0, 06-MAR-2005 (NJB)

        Added typedefs for pointers to functions.  This change was
        made to support CSPICE wrappers for geometry finder routines.

        Added typedefs for the SUN-SOLARIS-64BIT-GCC_C
        environment (these are identical to those for the 
        ALPHA-DIGITAL-UNIX_C environment).

   - C-SPICELIB Version 4.1.0, 24-MAY-2001 (WLT)

        Moved the #ifdef __cplusplus so that it appears after the
        typedefs.  This allows us to more easily wrap CSPICE in a
        namespace for C++.

   - C-SPICELIB Version 4.0.0, 09-FEB-1999 (NJB)  
   
        Updated to accommodate the Alpha/Digital Unix platform.
        Also updated to support inclusion in C++ code.
                  
   - C-SPICELIB Version 3.0.0, 02-NOV-1998 (NJB)  
   
        Updated for SPICELIB version N0049.
        
   - C-SPICELIB Version 2.0.0, 15-SEP-1997 (NJB)  
   
        Changed variable name "typeid" to "typid" in prototype
        for zzfdat_.  This was done to enable compilation under
        Borland C++.
        
   - C-SPICELIB Version 1.0.0, 15-SEP-1997 (NJB) (KRG)

-Index_Entries

   protoypes of f2c'd SPICELIB functions

*/


#ifndef HAVE_SPICEF2C_H
#define HAVE_SPICEF2C_H



/*
   Include Files:

   Many of the prototypes below use data types defined by f2c.  We
   copy here the f2c definitions that occur in prototypes of functions
   produced by running f2c on Fortran SPICELIB routines.
   
   The reason we don't simply conditionally include f2c.h itself here
   is that f2c.h defines macros that conflict with stdlib.h on some
   systems.  It's simpler to just replicate the few typedefs we need.
*/

#if (    defined( CSPICE_ALPHA_DIGITAL_UNIX    )    \
      || defined( CSPICE_PC_LINUX_64BIT_GCC    )    \
      || defined( CSPICE_SUN_SOLARIS_64BIT_GCC )  )

   #define VOID      void
   
   typedef VOID      H_f;
   typedef int       integer;
   typedef double    doublereal;
   typedef int       logical;
   typedef int       ftnlen;
 

   /*
   Type H_fp is used for character return type.
   Type S_fp is used for subroutines.
   Type U_fp is used for functions of unknown type.
   */
   typedef VOID       (*H_fp)();
   typedef doublereal (*D_fp)();
   typedef doublereal (*E_fp)();
   typedef int        (*S_fp)();
   typedef int        (*U_fp)();
   typedef integer    (*I_fp)();
   typedef logical    (*L_fp)();

#else

   #define VOID      void
   
   typedef VOID      H_f;
   typedef long      integer;
   typedef double    doublereal;
   typedef long      logical;
   typedef long      ftnlen;

   /*
   Type H_fp is used for character return type.
   Type S_fp is used for subroutines.
   Type U_fp is used for functions of unknown type.
   */
   typedef VOID       (*H_fp)();
   typedef doublereal (*D_fp)();
   typedef doublereal (*E_fp)();
   typedef int        (*S_fp)();
   typedef int        (*U_fp)();
   typedef integer    (*I_fp)();
   typedef logical    (*L_fp)();

#endif


#ifdef __cplusplus
   extern "C" { 
#endif


/*
   Function prototypes for functions created by f2c are listed below.
   See the headers of the Fortran routines for descriptions of the
   routines' interfaces.

   The functions listed below are those expected to be called by
   C-SPICELIB wrappers.  Prototypes are not currently provided for other
   f2c'd functions.

*/

/*
-Prototypes
*/

