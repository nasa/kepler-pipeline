/*

-Procedure f_edln_c ( Test wrapper for npedln_c )

 
-Abstract
 
   Perform tests on the CSPICE wrapper for the npedln_c, which finds
   the nearest point on an ellipsoid to a specified line.
    
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
   

   void f_edln_c ( SpiceBoolean * ok )

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
 
   This routine tests the wrappers for the CSPICE routine npedln_c.
             
-Examples
 
   None.
    
-Restrictions
 
   None. 
 
-Author_and_Institution
 
   N.J. Bachman    (JPL)
 
-Literature_References
 
   None. 
 
-Version
 
   -tspice_c Version 2.0.0 09-NOV-2005 (NJB)  

       Tightest tolerance value increased from 1.e-15 to 1.e-14.

   -tspice_c Version 1.0.0 03-SEP-1999 (NJB)  

-&
*/

{ /* Begin f_edln_c */

 
   /*
   Constants
   */
   
   #define LINELN          81
   #define NUMCAS          35
   #define NUMSMP          3
   #define NUMTOL          3

   
   /*
   Local variables
   */
   SpiceDouble             a          [ NUMCAS ];
   SpiceDouble             b          [ NUMCAS ];
   SpiceDouble             c          [ NUMCAS ];

   SpiceDouble             dist2;

   SpiceDouble             ica;
   SpiceDouble             icb;
   SpiceDouble             icc;
   SpiceDouble             icd        [3];
   SpiceDouble             icv        [3];
   SpiceDouble             icnear     [3];
   SpiceDouble             icdist;

   SpiceDouble             linedr     [ NUMCAS ][3];
   SpiceDouble             linept     [ NUMCAS ][3];
   SpiceDouble             linmin     [3];
   SpiceDouble             normal     [3];

   SpiceDouble             smpr       [ NUMSMP ][3] =
                           {
                               10.,       100.,       1000.,
                                3.e300,     3.e300,      3.e300, 
                                1.e-2,      1.e-2,       1.e-2    
                           };
                           
                           
   SpiceDouble             smpdir     [ NUMSMP ][3] =
                           {
                               0.,     0.,    -1.,
                              -1.,    -1.,     2.,
                               0.,    -2.,    -2.    
                           };
   
   
   SpiceDouble             smppt      [ NUMSMP ][3] =
                           {
                               20.,         0.,          0.,
                                4.e300,     4.e300,      4.e300, 
                                0.,         1.,          2.   
                           };
   

   /*
   We'd like to effect the following declaration and initialization:

  
   SpiceDouble             smpexppt   [ NUMSMP ][3] =
                           {
                              10.,         0.,                0.,
                                   
                              sqrt(3)*1.e300,  
                              sqrt(3)*1.e300,  
                              sqrt(3)*1.e300,  
                                   
                              0.,   -sqrt(2)*5.e-3,  sqrt(2)*5.e-3 
                           };
   
   
   However, the Sun/Sun C environment can't handle non-constant
   array initializers.  So we introduce the kludge variables
   
      kvar0,
      kvar1,
        .
        .
        .
        
   to hold the initializers we need.  We apply this initializers
   at run time.
   
   */
   
   
   SpiceDouble             kvar0;
   SpiceDouble             kvar1;
   SpiceDouble             kvar2;
   
   SpiceDouble             smpexppt   [ NUMSMP ][3] =
                           {
                              10.,        0.,       0.,
                                   
                               0.,        0.,       0.,  
                                   
                               0.,        0.,       0. 
                           };
   
   
   SpiceDouble             kvar3;
   SpiceDouble             kvar4;
   
   
   SpiceDouble             smpexpdist [ NUMSMP ] =
                           {
                              10.,  0.,  0.
                           };
                           
   
   SpiceDouble             tol        [ NUMTOL ] = 
                           {  
                              1.e-9, 1.e-12, 1.e-14
                           };
                           
   SpiceDouble             pnear    [3];
   SpiceDouble             dist;
   SpiceDouble             ratio;

   SpiceInt                i;


   /*
   Begin every test family with an open call.
   */
   topen_c ( "f_edln_c" );


   /*
   Initialization work-around:
   */


   kvar0  =   sqrt(3) * 1.e300;
   kvar1  =   -sqrt(2) * 5.e-3;
   kvar2  =   sqrt(2) * 5.e-3;
   kvar3  =   ( 4 * sqrt(3) - 3 ) * 1.e300;
   kvar4  =   (sqrt(2)/2) - 0.01;

   smpexppt   [1][0]  =  kvar0;
   smpexppt   [1][1]  =  kvar0;
   smpexppt   [1][2]  =  kvar0;
   
   smpexppt   [2][1]  =  kvar1;
   smpexppt   [2][2]  =  kvar2;
                           
   smpexpdist [ 1 ]   =  kvar3;
   smpexpdist [ 2 ]   =  kvar4;
   
   
   /*
   Cases 1-NUMSMP:
   */
     
    
   for ( i = 0;  i < NUMSMP;  i++ )
   {
      tcase_c ( "Test npedln_c:  run some simple cases." );
      
      tstmsg_c ( "#", "Simple sub case number #." );
      tstmsi_c ( i );

      npedln_c ( smpr  [i][0],
                 smpr  [i][1],
                 smpr  [i][2],
                 smppt [i],
                 smpdir[i],
                 pnear,
                 &dist        );
                 
      chckxc_c ( SPICEFALSE, " ", ok );
   
      chckad_c ( "near point", 
                 pnear, "~~/", smpexppt[i], 3, tol[2], ok );
                 
      chcksd_c ( "distance", dist, "~/", smpexpdist[i], tol[2], ok );
   }
    
    
   /*
   Set up the inputs for the more challenging cases.
   */
   
   /*
   Case 1:  Sphere-ish, line parallel to y-axis, passing above
   */

   a[0]          =    2.0e5;   
   b[0]          =    3.0e5;   
   c[0]          =    1.0e5;
   
   linept [0][0] =    0.0;     
   linept [0][1] =    0.0;     
   linept [0][2] =    1.e8;     
      
   linedr [0][0] =    0.0;     
   linedr [0][1] =    1.0;     
   linedr [0][2] =    0.0;     
   
   
   /*
   Case 2:  Sphere-ish, line parallel to z-axis, passing "behind"
            in the y- direction.
   */
   
   a[1]          =    2.0e5;   
   b[1]          =    3.0e5;   
   c[1]          =    1.0e5;
   
   linept [1][0] =    0.0;     
   linept [1][1] =   -1.e6;     
   linept [1][2] =    0.0;     
      
   linedr [1][0] =    0.0;     
   linedr [1][1] =    0.0;     
   linedr [1][2] =   -1.0;     
   
   
   /*
   Case 3:  Sphere-ish, line parallel to x-axis, passing "behind"
            in the y- direction     
   */
   a[2]          =    2.0e5;   
   b[2]          =    3.0e5;   
   c[2]          =    1.0e5;
   
   linept [2][0] =    0.0;     
   linept [2][1] =   -1.e12;     
   linept [2][2] =    0.0;     
      
   linedr [2][0] =   -30.0;     
   linedr [2][1] =     0.0;     
   linedr [2][2] =     0.0;     
   
   
   /*
   Case 4:  Sphere, near point in x>0, y>0, z>0 octant
   */
   a[3]          =    2.0e5;   
   b[3]          =    3.0e5;   
   c[3]          =    1.0e5;
   
   linept [3][0] =    1.e8;     
   linept [3][1] =    1.e8;     
   linept [3][2] =    1.e8;     
      
   linedr [3][0] =   -30.0;     
   linedr [3][1] =   -10.0;     
   linedr [3][2] =    30.0;     
 
   /*
   Case 5:  y-cigar-ish, near point in x>0, y>0, z<0 octant
   */
   a[4]          =    2.0e5;   
   b[4]          =    8.0e5;   
   c[4]          =    1.0e5;
   
   linept [4][0] =    1.e8;     
   linept [4][1] =    1.e8;     
   linept [4][2] =   -1.e8;     
      
   linedr [4][0] =   -30.0;     
   linedr [4][1] =   -10.0;     
   linedr [4][2] =   -30.0; 
   
   
   /*
   Case 6:  y-cigar-ish, near point in x<0, y>0, z<0 octant
   */
   a[5]          =    2.0e5;   
   b[5]          =    8.0e5;   
   c[5]          =    1.0e6;
   
   linept [5][0] =   -1.e8;     
   linept [5][1] =    1.e8;     
   linept [5][2] =   -1.e8;     
      
   linedr [5][0] =   -30.0;     
   linedr [5][1] =   -10.0;     
   linedr [5][2] =   -30.0; 
   

   /* 
   Case 7:  x-cigar-ish, near point in x<0, y>0, z<0 octant
   */
   a[6]          =    2.0e7;   
   b[6]          =    8.0e5;   
   c[6]          =    1.0e6;
   
   linept [6][0] =   -1.e9;     
   linept [6][1] =    1.e9;     
   linept [6][2] =   -1.e9;     
      
   linedr [6][0] =   -30.0;     
   linedr [6][1] =   -10.0;     
   linedr [6][2] =   -30.0; 
   
   /*
   Case 8:  Similar to case 4, but very, very z-oblate
   */
   a[7]          =    2.0e5;   
   b[7]          =    3.0e5;   
   c[7]          =    1.0e2;
   
   linept [7][0] =    1.e8;     
   linept [7][1] =    1.e8;     
   linept [7][2] =    1.e8;     
      
   linedr [7][0] =   -30.0;     
   linedr [7][1] =   -10.0;     
   linedr [7][2] =    90.0; 



   /*    
   Case 9:  Case 4, but very, very z-prolate
   */
   a[8]          =    2.0e2;   
   b[8]          =    3.0e2;   
   c[8]          =    1.0e6;
   
   linept [8][0] =    1.e8;     
   linept [8][1] =    1.e8;     
   linept [8][2] =    1.e8;     
      
   linedr [8][0] =   -30.0;     
   linedr [8][1] =   -10.0;     
   linedr [8][2] =    90.0; 


   /*
   Case 10:  An ugly one:  very prolate, with the line close to 
                  parallel to long axis.  A real needle, about 3.E7 
                  times as long as it is thick.  This gives a very 
                   long, thin "candidate ellipse."  
   */
 
   a[9]          =    2.0e2;   
   b[9]          =    3.0e2;   
   c[9]          =    1.0e10;
   
   linept [9][0] =    1.e8;     
   linept [9][1] =    1.e8;     
   linept [9][2] =    1.e8;     
      
   linedr [9][0] =    1.e-7;     
   linedr [9][1] =    1.e-7;     
   linedr [9][2] =    1.0; 

 
   /*
   Cases 11 -- 15.  "2-D"-type cases, where we move around the
                    ellipse formed by the y-z projection of the
                    ellipsoid.  The ellipsoid is oblate, 100 times
                    as fat as it is high.
   */
   
   
   /*                   
   Case 11:  a little off vertical
   */                           
                                
   a[10]          =    1.0e2;   
   b[10]          =    1.0e2;   
   c[10]          =    1.0;
   
   linept [10][0] =    0.0;     
   linept [10][1] =    1.5e2;     
   linept [10][2] =    3.e1;     
      
   linedr [10][0] =    0.0;     
   linedr [10][1] =   -1.e-1;     
   linedr [10][2] =    1.0; 

   
 
   /*                    
   Case 12:  a little more off vertical
   */                        
                                
   a[11]          =    1.0e2;   
   b[11]          =    1.0e2;   
   c[11]          =    1.0;
   
   linept [11][0] =    0.0;     
   linept [11][1] =    1.5e2;     
   linept [11][2] =    3.e1;     
      
   linedr [11][0] =    0.0;     
   linedr [11][1] =   -3.e-1;     
   linedr [11][2] =    1.0; 

   
   /*   
                     o
   Case 13:        45
   */
                                
   a[12]          =    1.0e2;   
   b[12]          =    1.0e2;   
   c[12]          =    1.0;
   
   linept [12][0] =    0.0;     
   linept [12][1] =    1.5e2;     
   linept [12][2] =    1.5e2;     
      
   linedr [12][0] =    0.0;     
   linedr [12][1] =   -1.0;     
   linedr [12][2] =   -1.0; 
   
   
   /*
   Case 14:  somewhat off horizontal
   */                            
                                
   a[13]          =    1.0e2;   
   b[13]          =    1.0e2;   
   c[13]          =    1.0;
   
   linept [13][0] =    0.0;     
   linept [13][1] =    1.5e1;     
   linept [13][2] =    1.5e2;     
      
   linedr [13][0] =    0.0;     
   linedr [13][1] =   -1.0;     
   linedr [13][2] =   -3.0e-1; 
   
   
   /*
   Case 15:  jest a little off horizontal
   */                               
                                
   a[14]          =    1.0e2;   
   b[14]          =    1.0e2;   
   c[14]          =    1.0;
   
   linept [14][0] =    0.0;     
   linept [14][1] =    0.0;     
   linept [14][2] =    1.5e2;     
      
   linedr [14][0] =    0.0;     
   linedr [14][1] =   -1.0;     
   linedr [14][2] =   -1.0e-1; 
      
 
   /*
   Cases 16 -- 20.  "2-D"-type cases, where we move around the
                         ellipse formed by the y-z projection of the
                         ellipsoid.  The ellipsoid is very oblate, 
                         1000  times as fat as it is high.
   */

   
   /*
   Case 16:  a little off vertical
   */                          
                                
   a[15]          =    1.0e2;   
   b[15]          =    1.0e2;   
   c[15]          =    1.0e-1;
   
   linept [15][0] =    0.0;     
   linept [15][1] =    1.5e2;     
   linept [15][2] =    0.0;     
      
   linedr [15][0] =    0.0;     
   linedr [15][1] =   -1.0e-1;     
   linedr [15][2] =    1.0; 
     
     
   /* 
   Case 17:  a little more off vertical
   */                           
   a[16]          =    1.0e2;   
   b[16]          =    1.0e2;   
   c[16]          =    1.0e-1;
   
   linept [16][0] =    0.0;     
   linept [16][1] =    1.5e2;     
   linept [16][2] =    3.0e1;     
      
   linedr [16][0] =    0.0;     
   linedr [16][1] =   -3.0e-1;     
   linedr [16][2] =    1.0; 
                                

   /*  
                     o
   Case 18:        45
   */                      
                                
   a[17]          =    1.0e2;   
   b[17]          =    1.0e2;   
   c[17]          =    1.0e-1;
   
   linept [17][0] =    0.0;     
   linept [17][1] =    1.5e2;     
   linept [17][2] =    1.5e2;     
      
   linedr [17][0] =    0.0;     
   linedr [17][1] =   -1.0;     
   linedr [17][2] =    1.0; 
                        
   
   /*                                 
   Case 19:  somewhat off horizontal
   */                         
                                
   a[18]          =    1.0e2;   
   b[18]          =    1.0e2;   
   c[18]          =    1.0e-1;
   
   linept [18][0] =    0.0;     
   linept [18][1] =    1.5e1;     
   linept [18][2] =    1.5e2;     
      
   linedr [18][0] =    0.0;     
   linedr [18][1] =   -1.0;     
   linedr [18][2] =   -3.0e-1; 
      
  
   /*
   Case 20:  jest a little off horizontal
   */                           
   a[19]          =    1.0e2;   
   b[19]          =    1.0e2;   
   c[19]          =    1.0e-1;
   
   linept [19][0] =    0.0;     
   linept [19][1] =    0.0;     
   linept [19][2] =    1.5e2;     
      
   linedr [19][0] =    0.0;     
   linedr [19][1] =   -1.0;     
   linedr [19][2] =   -1.0e-1; 
      
  
   /*                        
      
   Cases 21 -- 25.  "2-D"-type cases, where we move around the
                     ellipse formed by the y-z projection of the
                    ellipsoid.  The ellipsoid is oblate, 10 times
                    as fat as it is high.

                    
                    
   Case 21:  a little off vertical
   */                   
   
   
   a[20]          =    1.0e2;   
   b[20]          =    1.0e2;   
   c[20]          =    1.0e1;
   
   linept [20][0] =    0.0;     
   linept [20][1] =    1.5e2;     
   linept [20][2] =    3.0e1;     
      
   linedr [20][0] =    0.0;     
   linedr [20][1] =   -1.0e-1;     
   linedr [20][2] =    1.0; 
      
   
   /*
   Case 22:  a little more off vertical
   */
   
   a[21]          =    1.0e2;   
   b[21]          =    1.0e2;   
   c[21]          =    1.0e1;
   
   linept [21][0] =    0.0;     
   linept [21][1] =    1.5e2;     
   linept [21][2] =    3.0e1;     
      
   linedr [21][0] =    0.0;     
   linedr [21][1] =   -3.0e-1;     
   linedr [21][2] =    1.0; 
      
   
   /*
                     o
   Case 23:        45
   */                          
                                
   a[22]          =    1.0e2;   
   b[22]          =    1.0e2;   
   c[22]          =    1.0e1;
   
   linept [22][0] =    0.0;     
   linept [22][1] =    1.5e2;     
   linept [22][2] =    1.5e2;     
      
   linedr [22][0] =    0.0;     
   linedr [22][1] =   -1.0;     
   linedr [22][2] =    1.0; 
      
      
   /*
   Case 24:  somewhat off horizontal
   */             
                 
   a[23]          =    1.0e2;   
   b[23]          =    1.0e2;   
   c[23]          =    1.0e1;
   
   linept [23][0] =    0.0;     
   linept [23][1] =    1.5e1;     
   linept [23][2] =    1.5e2;     
      
   linedr [23][0] =    0.0;     
   linedr [23][1] =   -1.0;     
   linedr [23][2] =   -3.e-1; 

    
   /*                      
   Case 25:  jest a little off horizontal
   */                            
                                
   a[24]          =    1.0e2;   
   b[24]          =    1.0e2;   
   c[24]          =    1.0e1;
   
   linept [24][0] =    0.0;     
   linept [24][1] =    0.0;     
   linept [24][2] =    1.5e2;     
      
   linedr [24][0] =    0.0;     
   linedr [24][1] =   -1.0;     
   linedr [24][2] =   -1.e-1; 


   /*
   Cases 26 -- 30.  "2-D"-type cases, where we move around the
                    ellipse formed by the x=y plane projection of 
                    the ellipsoid.  The ellipsoid is oblate, 100 
                    times as fat as it is high.

                    
                    
   Case 26:  a little off vertical
   */                   

   a[25]          =    1.0e2;   
   b[25]          =    1.0e2;   
   c[25]          =    1.0;
   
   linept [25][0] =    1.5e2;     
   linept [25][1] =    1.5e2;     
   linept [25][2] =    3.0e1;     
      
   linedr [25][0] =   -1.e-1;     
   linedr [25][1] =   -1.e-1;     
   linedr [25][2] =    1.0; 


   /*                    
   Case 27:  a little more off vertical
   */                         
                                
   a[26]          =    1.0e2;   
   b[26]          =    1.0e2;   
   c[26]          =    1.0;
   
   linept [26][0] =    1.5e2;     
   linept [26][1] =    1.5e2;     
   linept [26][2] =    3.0e1;     
      
   linedr [26][0] =   -3.e-1;     
   linedr [26][1] =   -3.e-1;     
   linedr [26][2] =    1.0; 


   /*                      
                     o
   Case 28:        45
   */                           
                                
   a[27]          =    1.0e2;   
   b[27]          =    1.0e2;   
   c[27]          =    1.0;
   
   linept [27][0] =    1.5e2;     
   linept [27][1] =    1.5e2;     
   linept [27][2] =    1.5e2;     
      
   linedr [27][0] =   -1.0;     
   linedr [27][1] =   -1.0;     
   linedr [27][2] =    1.0; 

    
   /*                      
   Case 29:  somewhat off horizontal
   */                            
                                
   a[28]          =    1.0e2;   
   b[28]          =    1.0e2;   
   c[28]          =    1.0;
   
   linept [28][0] =    1.5e1;     
   linept [28][1] =    1.5e1;     
   linept [28][2] =    1.5e2;     
      
   linedr [28][0] =   -1.0;     
   linedr [28][1] =   -1.0;     
   linedr [28][2] =   -3.0-1; 

   /*
   Case 30:  jest a little off horizontal
   */
                                
   a[29]          =    1.0e2;   
   b[29]          =    1.0e2;   
   c[29]          =    1.0;
   
   linept [29][0] =    0.0;     
   linept [29][1] =    0.0;     
   linept [29][2] =    1.5e2;     
      
   linedr [29][0] =   -1.0;     
   linedr [29][1] =   -1.0;     
   linedr [29][2] =   -1.0-1; 


   /* 
   Cases 31 -- 35.  "2-D"-type cases, where we move around the
                    ellipse formed by the x=y plane projection of 
                    the ellipsoid.  The ellipsoid is quite close
                    to spherical, 1.1 times as fat as it is high.

                    
                    
   Case 31:  a little off vertical
   */
   
                                
   a[30]          =    1.1;   
   b[30]          =    1.1;   
   c[30]          =    1.0;
   
   linept [30][0] =    1.5e2;     
   linept [30][1] =    1.5e2;     
   linept [30][2] =    3.0e1;     
      
   linedr [30][0] =   -1.0e-1;     
   linedr [30][1] =   -1.0e-1;     
   linedr [30][2] =    1.0; 



   /*
   Case 32:  a little more off vertical
   */                          
                                
   a[31]          =    1.1;   
   b[31]          =    1.1;   
   c[31]          =    1.0;
   
   linept [31][0] =    1.5e2;     
   linept [31][1] =    1.5e2;     
   linept [31][2] =    3.0e1;     
      
   linedr [31][0] =   -3.0e-1;     
   linedr [31][1] =   -3.0e-1;     
   linedr [31][2] =    1.0; 


   /*
                     o
   Case 33:        45
   */                             
                                
                                
   a[32]          =    1.1;   
   b[32]          =    1.1;   
   c[32]          =    1.0;
   
   linept [32][0] =    1.5e2;     
   linept [32][1] =    1.5e2;     
   linept [32][2] =    1.5e2;     
      
   linedr [32][0] =   -1.0;     
   linedr [32][1] =   -1.0;     
   linedr [32][2] =    1.0; 
      
      
   /*
   Case 34:  somewhat off horizontal
   */                         
                                
   a[33]          =    1.1;   
   b[33]          =    1.1;   
   c[33]          =    1.0;
   
   linept [33][0] =    1.5e1;     
   linept [33][1] =    1.5e1;     
   linept [33][2] =    1.5e2;     
      
   linedr [33][0] =   -1.0;     
   linedr [33][1] =   -1.0;     
   linedr [33][2] =   -3.0e-1; 

                         
     
   /*                     
   Case 35:  jest a little off horizontal
   */                             
                                
   a[34]          =    1.1;   
   b[34]          =    1.1;   
   c[34]          =    1.0;
   
   linept [34][0] =    0.0;     
   linept [34][1] =    0.0;     
   linept [34][2] =    1.5e2;     
      
   linedr [34][0] =   -1.0;     
   linedr [34][1] =   -1.0;     
   linedr [34][2] =   -1.0e-1; 


    
   /*
   Cases NUMSMP+1 : NUMSMP+NUMCAS:
   */
    
   /*
   Now run npedln_c on the test data sets.  
   */
   
   for ( i = 0;  i < 35;  i++ )
   {
      tcase_c ( "Test npedln_c:  run some challenging cases." );
      
      tstmsg_c ( "#", "`Challenging' sub case number #." );
      tstmsi_c ( i );
      
      
      /*
      The call.
      */
      npedln_c ( a[i], b[i], c[i], linept[i], linedr[i], pnear, &dist );
      chckxc_c ( SPICEFALSE, " ", ok );
      
      
      /*
      The point on the line closest to the ellipsoid ( linmin ).
      */
      nplnpt_c ( linept[i], linedr[i], pnear, linmin, &dist2 );      
      chckxc_c ( SPICEFALSE, " ", ok );


      /*
      Ellipsoid surface normal at the near point.
      */
      surfnm_c ( a[i], b[i], c[i], pnear, normal );
      chckxc_c ( SPICEFALSE, " ", ok );

      /*
      Approximation to linmin.
      */
      vscl_c ( dist,  normal, normal );
      vadd_c ( pnear, normal, normal );   
   
      /*
      The error in the approximation.
      */
      
      ratio = vrel_c ( normal, linmin );
      
      chcksd_c ( "relative error", ratio, "<", tol[0], 0., ok );
      
   }
   

   /*
   Now for the intercept cases.
   */

   for ( i = 0;  i < 2;  i++ )
   {
      tcase_c ( "Test npedln_c:  run the intercept cases." );
      
      tstmsg_c ( "#", "intercept sub case number #." );
      tstmsi_c ( i );
      
      ica     = 1.0e10;
      icb     = 1.0e10;
      icc     = 1.0e10;
      
      icv[0]  = 2.0e10;
      icv[1]  = 0.0;
      icv[2]  = 0.0;
      
      if ( i == 1 ) 
      {
         icd[0]  = -1.0;
      }
      else 
      {
         icd[0]  =  1.0;
      }

      icd[1] = 0.0;
      icd[2] = 0.0;
               
      npedln_c ( ica, icb, icc, icv, icd, icnear, &icdist );
      chckxc_c ( SPICEFALSE, " ", ok );
      
      chcksd_c ( "icdist", icdist, "=", 0.0, 0.0, ok );
   }
    
      
   /*
   Now for the error cases.
   */
      
      
   tcase_c ( "Zero direction vection error case." );
   
   vpack_c ( 0., 0., 0., linedr[0] );
   
   npedln_c ( 1.0,  1.0, 1.0, linept[0], linedr[0], pnear, &dist );
   chckxc_c ( SPICETRUE, "SPICE(ZEROVECTOR)", ok );
      
      
   tcase_c ( "Zero length x-semi axis" );
   
   vpack_c ( 1., 0., 0., linedr[0] );
   
   npedln_c ( 0.0,  1.0, 1.0, linept[0], linedr[0], pnear, &dist );
   chckxc_c ( SPICETRUE, "SPICE(INVALIDAXISLENGTH)", ok );
      
      
   tcase_c ( "Zero length y-semi axis" );
   
   vpack_c ( 0., 1., 0., linedr[0] );
   
   npedln_c ( 1.0,  0.0, 1.0, linept[0], linedr[0], pnear, &dist );
   chckxc_c ( SPICETRUE, "SPICE(INVALIDAXISLENGTH)", ok );
      
      
   tcase_c ( "Zero length z-semi axis" );
   
   vpack_c ( 0., 1., 0., linedr[0] );
   
   npedln_c ( 1.0,  1.0, 0.0, linept[0], linedr[0], pnear, &dist );
   chckxc_c ( SPICETRUE, "SPICE(INVALIDAXISLENGTH)", ok );
      
      
   tcase_c ( "Smallest axis vanishes when scaled and squared." );
   
   vpack_c ( 0., 1., 0., linedr[0] );
   
   npedln_c ( 1.e300,  1.0, 1.0, linept[0], linedr[0], pnear, &dist );
   chckxc_c ( SPICETRUE, "SPICE(DEGENERATECASE)", ok );
      
      
   /*
   Retrieve the current test status.
   */ 
   t_success_c ( ok ); 
   
   
} /* End f_edln_c */


