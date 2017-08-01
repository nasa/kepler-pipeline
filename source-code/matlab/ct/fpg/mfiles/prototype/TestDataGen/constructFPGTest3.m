% script to construct fpgTestData objects for test 2:  one cadence, errors of up to
% 3 pixels on each CCD, orientation error of up to 20 pixels, plate scale error.
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

  fpgTest3 = fpgTestData() ;
  
% assign the random number generation information.  Run each RNG for a bit to get a new
% state for them...

  for rCount = 1:100
      rdmy = rand(100,100) ;
      rndmy = randn(100,100) ;
  end

  fpgTest3 = set(fpgTest3,'randState',rand('twister')) ;
  fpgTest3 = set(fpgTest3,'randnState',randn('state')) ;
  
% assign the centroiding error to the canonical 20 micro-pixels

  fpgTest3 = set(fpgTest3,'centroidErrorPixels',20e-6) ;
  
% assign the CCD errors and plate scale error

  ccdPointError = 3.98 / 3600 * 3 ; % 3 pixels * 3.98 arcsec -> degrees
  ccdRotError = 0.16 ; % 3 pixels / 1000 pixels -> degrees
  plateScaleError = -1e-3 ;
  
% set the overall orientation error

  raError = 3.98 / 3600 * 20 ; % 20 pixel error in RA
  decError = 3.98 / 3600 * (-20) ; %-20 pixel error in dec
  rollError = -0.23 ; % 0.23 degree roll error = 20 pixels / 5000 pixels

  fpgTest3 = set(fpgTest3,'ccdError',[ccdPointError ccdPointError ccdRotError]) ;
  fpgTest3 = set(fpgTest3,'overallOrientationError',[raError decError rollError]) ;
  fpgTest3 = set(fpgTest3,'dPlateScale',plateScaleError) ;
  
% there is only one cadence, and it is at the reference orientation

  fpgTest3 = set(fpgTest3,'cadencedOrientation',[0 ; 0 ; 0]) ;
  
% cadence pointing error isn't used if the only orientation is 0 0 0, but put it in as
% zeroes anyway

  fpgTest3 = set(fpgTest3,'cadencePointingError',[0 0 0 0 0]) ;
  
% the date:  according to my copy of Mission Plan rev C, April 15 2009 looks like a good
% day (ie, no rolls planned that day)

  fpgTest3 = set(fpgTest3,'calendarDate','15-apr-2009 12:00:00') ;
  
% finally, The Grid (as Peter Murphy would say): I'm going to use a 5 x 5 grid which
% goes from row 50 to row 950 and column 50 to column 950.  So that's rows and columns 50,
% 275, 500, 725, 950.

  ovec = ones(1,5) ;
  row = [50*ovec 275*ovec 500*ovec 725*ovec 950*ovec] ;
  cvec = [50 275 500 725 950] ;
  col = [cvec cvec cvec cvec cvec] ;
  
  fpgTest3 = set(fpgTest3,'posRowCol',[row' col']) ;
    
% generate the test data!

  fpgTest3 = generateData(fpgTest3) ;
  [drow,dcol] = fpgTestDataCheck(fpgTest3) ;
  disp(std(drow(:,1))) ; disp(std(dcol(:,1))) ;
  