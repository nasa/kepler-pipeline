function motionPolynomials = generate_fakedata_motion_polynomials( raDec2PixObject, ...
    mjd0, dMjd, pointing, rowGrid, colGrid, sigma, refCadence )
%
% generate_fakedata_motion_polynomials -- generate motion polynomials for simulation and
% testing purposes
%
% motionPolynomials = generate_fakedata_motion_polynomials( raDec2PixObject, mjd0, dMjd, 
%    pointing, rowGrid, colGrid ) generates a matrix of motion polynomials based on the
%    geometry in the raDec2PixObject, the matrix of pointings in pointing, the desired
%    start time mjd0, and desired period of long cadence integration dMjd.  Argument
%    definitions are as follows:
%
%        raDec2PixObject -- an object in the raDec2PixClass
%        mjd0 -- starting time for the generation of motion polynomials
%        dMjd -- length of time needed for a long cadence
%        pointing -- 3 x nCadence matrix of pointing differences from the nominal, in
%            degrees
%        rowGrid -- grid of row values used to compute the motion polynomials
%        colGrid -- grid of column values used to compute the motion polynomials
%        sigma -- uncertainty in row/column values, in pixels.
%
% The returned motionPolynomials structure has the structure of the motion polynomials
%     extractor tool:  84 x nCadence structure with fields
%
%        mjdStartTime
%        mjdMidTime
%        mjdEndTime
%        cadence
%        module
%        output
%        rowPoly
%        rowPolyStatus (always true)
%        colPoly
%        colPolyStatus (always true)
%
% Version date:  2008-October-03.
%
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

% Modification history:
%
%     2008-September-03, PT:
%         use the pointing model at each cadence to get the nominal pointing, rather than
%         using the pointing on the reference cadence as the nominal pointing.
%     2008-September-19, PT:
%         convert to one-based calculations.
%     2008-September-05, PT:
%         change rowPolyStatus and colPolyStatus from logical to double.
%     2008-July-31, PT:
%         use pointing at the mid-time of the reference cadence as the nominal, and
%         convert to use of ra_dec_2_pix_absolute, to be consistent with fitting
%         algorithm.
%
%=========================================================================================

% convert the raDec2PixObject to one-based if it is not already

  raDec2PixObject = become_one_based(raDec2PixObject) ;

% if no reference cadence is provided, assume one

  if (nargin == 7)
      refCadence = 1 ;
  end

% define the structure and dimension it properly

  nCadences = size(pointing,2) ;
  
  motionPolynomials(84,nCadences).mjdStartTime = [] ;
  motionPolynomials(84,nCadences).mjdMidTime = [] ;
  motionPolynomials(84,nCadences).mjdEndTime = [] ;
  motionPolynomials(84,nCadences).cadence = [] ;
  motionPolynomials(84,nCadences).module = [] ;
  motionPolynomials(84,nCadences).output = [] ;
  motionPolynomials(84,nCadences).rowPoly = [] ;
  motionPolynomials(84,nCadences).rowPolyStatus = [] ;
  motionPolynomials(84,nCadences).colPoly = [] ;
  motionPolynomials(84,nCadences).colPolyStatus = [] ;

% construct the grid of points to be used in the fit

  [row,col] = ndgrid(rowGrid,colGrid) ; row = row(:) ; col = col(:) ;
  ovec = ones(size(row)) ;
  
% construct the module and output vectors

  module = [2:4 6:20 22:24] ;
  module = repmat(module,4,1) ; module = module(:) ;
  output = repmat([1 ; 2 ; 3 ; 4],21,1) ;
  
% set the current MJD clock to the desired start time

  mjd = mjd0 ;
  
% get the mid-time on the reference cadence, and use that to find the pointing via the
% pointing model

  midTimeRefCadence = mjd0 + (refCadence-0.5)*dMjd ;
  pointingModel = get(raDec2PixObject,'pointingModel') ;
  
% loop over cadences, set cadence numbers and mjdtimes, and loop over channels

  for iCadence = 1:nCadences
      
      mjdEnd = mjd+dMjd ; mjdMid = mjd+dMjd/2 ;
      refPointing = get_pointing(pointingClass(pointingModel),mjdMid) ;
      pointingRa = refPointing(1) ; 
      pointingDec = refPointing(2) ; 
      pointingRoll = refPointing(3) ;

      for iChannel = 1:84
          
          motionPolynomials(iChannel,iCadence).mjdStartTime = mjd ;
          motionPolynomials(iChannel,iCadence).mjdEndTime = mjdEnd ;
          motionPolynomials(iChannel,iCadence).mjdMidTime = mjdMid ;
          motionPolynomials(iChannel,iCadence).cadence = iCadence ;
          mod = module(iChannel) ; out = output(iChannel) ;
          motionPolynomials(iChannel,iCadence).module = mod ;
          motionPolynomials(iChannel,iCadence).output = out ;
          
%         use pix_2_ra_dec_relative to get the correct RAs and Decs for the calculation,
%         including uncertainties

          rowSigma = sigma * randn(size(row)) ;
          colSigma = sigma * randn(size(row)) ;

          [ra,dec] = pix_2_ra_dec_absolute( raDec2PixObject, mod*ovec, out*ovec, ...
              row+rowSigma, col+colSigma, mjdMid, pointingRa+pointing(1,iCadence), ...
              pointingDec+pointing(2,iCadence), pointingRoll+pointing(3,iCadence) ) ;
          
%         perform the fit

          motionPolynomials(iChannel,iCadence).rowPoly = weighted_polyfit2d( ...
              ra,dec,row,1/sigma,3) ;
          motionPolynomials(iChannel,iCadence).colPoly = weighted_polyfit2d( ...
              ra,dec,col,1/sigma,3) ;
          motionPolynomials(iChannel,iCadence).rowPolyStatus = 1 ;
          motionPolynomials(iChannel,iCadence).colPolyStatus = 1 ;
          
      end % channel loop
      
      mjd = mjdEnd ;
      
  end % cadence loop 
  
% and that's it!

%
%
%
