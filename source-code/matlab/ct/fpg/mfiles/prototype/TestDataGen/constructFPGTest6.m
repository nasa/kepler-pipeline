% script to construct fpgTestData objects for test 7:  49 cadences, errors of up to
% 3 pixels on each CCD, no static orientation error, plate scale error, pointing
% errors on cadences.
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
% 
% NASA acknowledges the SETI Institute's primary role in authoring and
% producing the Kepler Data Processing Pipeline under Cooperative
% Agreement Nos. NNA04CC63A, NNX07AD96A, NNX07AD98A, NNX11AI13A,
% NNX11AI14A, NNX13AD01A & NNX13AD16A.
% 
% This file is available under the terms of the NASA Open Source Agreement
% (NOSA). You should have received a copy of this agreement with the
% Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
% 
% No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
% WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
% INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
% WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
% INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
% FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
% TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
% CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
% OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
% OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
% FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
% REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
% AND DISTRIBUTES IT "AS IS."
% 
% Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
% AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
% SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
% THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
% EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
% PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
% SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
% STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
% PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
% REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
% TERMINATION OF THIS AGREEMENT.
%

  fpgTest6 = fpgTestData() ;
  
% assign the random number generation information.  Run each RNG for a bit to get a new
% state for them...

  for rCount = 1:100
      rdmy = rand(100,100) ;
      rndmy = randn(100,100) ;
  end

  fpgTest6 = set(fpgTest6,'randState',rand('twister')) ;
  fpgTest6 = set(fpgTest6,'randnState',randn('state')) ;
  
% assign the centroiding error to the canonical 20 micro-pixels

  fpgTest6 = set(fpgTest6,'centroidErrorPixels',20e-6) ;
  
% assign the CCD errors and plate scale error

  ccdPointError = 3.98 / 3600 * 3 ; % 3 pixels * 3.98 arcsec -> degrees
  ccdRotError = 0.16 ; % 3 pixels / 1000 pixels -> degrees
  plateScaleError = 1e-3 ;
  
% set the overall orientation error

  raError = 3.98 / 3600 * 0 ; % 0 pixel error in RA
  decError = 3.98 / 3600 * (0) ; %0 pixel error in dec
  rollError = -0.0 ; % 0. degree roll error = 00 pixels / 5000 pixels

  fpgTest6 = set(fpgTest6,'ccdError',[ccdPointError ccdPointError ccdRotError]) ;
  fpgTest6 = set(fpgTest6,'overallOrientationError',[raError decError rollError]) ;
  fpgTest6 = set(fpgTest6,'dPlateScale',plateScaleError) ;
  
% there are 5 cadences in a grid of +/- 0.5 pixels in each direction.  The coefficients
% which relate row/col (on mod 13 output 1 on 15 April 2009) are as follows:
%
%    dRA /dRow =  0.001277559173275
%    dDec/dRow =  6.048062857715308e-04
%    dRA /dCol = -8.347614021886329e-04
%    dDec/dCol =  9.255299266683892e-04
%
% so construct column-vectors of row and column vectors, convert them to RA and Dec
% vectors, and then into cadence changes in orientation

  ovec = ones(1,5) ;
  dRowScan = [ 0.5 * ovec  0.25 * ovec   ...
                 0 * ovec ...
              -0.25 * ovec  -0.5 * ovec] ;
  dColScanVec = [0.5 0.25 0 -0.25 -0.5] ;
  dColScan = [dColScanVec dColScanVec dColScanVec dColScanVec dColScanVec ] ;
  
  dRAdRow =  0.001277559173275 ; dDecdRow =  6.048062857715308e-04 ; 
  dRAdCol = -8.347614021886329e-04 ; dDecdCol = 9.255299266683892e-04 ;
  
  dRAdDec = [dRAdRow dRAdCol ; dDecdRow dDecdCol] * [dRowScan ; dColScan] ;
  
  fpgTest6 = set(fpgTest6,'cadencedOrientation',[dRAdDec ; zeros(1,25) ]) ;
  
% cadence pointing errors -- put in errors at the 0.1 pixel / 0.1% level

  fpgTest6 = set(fpgTest6,'cadencePointingError',[1.11e-6 1.11e-6 1.15e-5 0.001 -0.001]) ;
 
% the date:  according to my copy of Mission Plan rev C, April 15 2009 looks like a good
% day (ie, no rolls planned that day)

  fpgTest6 = set(fpgTest6,'calendarDate','15-apr-2009 12:00:00') ;
  
% finally, The Grid (as Peter Murphy would say): I'm going to use a 5 x 5 grid which
% goes from row 50 to row 950 and column 50 to column 950.  So that's rows and columns 50,
% 275, 500, 725, 950.

  ovec = ones(1,5) ;
  row = [50*ovec 275*ovec 500*ovec 725*ovec 950*ovec] ;
  cvec = [50 275 500 725 950] ;
  col = [cvec cvec cvec cvec cvec] ;
  
  fpgTest6 = set(fpgTest6,'posRowCol',[row' col']) ;
    
% generate the test data!

  fpgTest6 = generateData(fpgTest6) ;
  [drow,dcol] = fpgTestDataCheck(fpgTest6) ;
  disp(std(drow(:,1))) ; disp(std(dcol(:,1))) ;
  