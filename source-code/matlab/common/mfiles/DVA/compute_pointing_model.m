function [ra, dec, roll, filename] = compute_pointing_model( raDec2PixModel, mjds )
%
% compute_pointing_model -- compute the mechanical pointing of the Kepler spacecraft
%
% [ra, dec, roll] = compute_pointing_model( raDec2PixModel, mjds )
%    determines the mechanical pointing of the spacecraft as a function of time.  The
%    returned ra, dec, and roll vectors are suitable for use as the spacecraft pointing
%    arguments used in ra_dec_2_pix_absolute.  This function emulates the process by which
%    the Kepler FGS are used as inputs to a feedback loop which maintains the optical
%    pointing.  
%
% [..., filename] = compute_pointing_model( ... ) writes the pointing model to an ascii
%    file and returns the filename to the user.  The filename and the file format are
%    specified in KADN-26176.
%
% All input arguments to compute_pointing_model are optional.  The arguments are:
%
%    raDec2PixModel -- a model suitable for use in producing an raDec2PixClass object.
%       The velocity aberration model used in compute_pointing_model comes from the
%       velocity aberration model in the raDec2PixModel.  If omitted, the raDec2PixModel
%       in the datastore is used.
%
%    mjds -- vector of MJD values for which the pointing model should be computed.  If
%       omitted, the full range of the raDec2PixModel will be used, with a timestep of 0.5
%       days.  The value of mjd(1) is assumed to be the instant at which the feedback was
%       turned on.
%
% Version date:  2013-November-13.
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

% Modification History:
%
%    2013-November-13, JT:
%        now support multiple fields of view; pointings are obtained from
%        roll time model; optional opticalPointing argument has been
%        removed because single FOV center can no longer be assumed;
%        pointing model is determined properly within each pointing
%        segment.
%    2009-April-24, PT:
%        move subfunction which writes pointing model file into a separate function file
%        so that other functions (like compute_pointing_model_from_attitude_history) can
%        make use of it.
%    2008-November-14, PT:
%        add option to write pointing model file with KADN-26176 formatting and name.
%
%=========================================================================================

%=========================================================================================
%
% Initial Argument Management -- handle omitted arguments
%
%=========================================================================================
  
% if the raDec2PixModel is left out, get one from the datastore

  if (nargin == 0) || (isempty(raDec2PixModel))
      raDec2PixModel = retrieve_ra_dec_2_pix_model() ;
  end
  raDec2PixObject = raDec2PixClass(raDec2PixModel,'one-based') ;

% instantiate a rollTimeObject

  rollTimeModel = get(raDec2PixObject, 'rollTimeModel');
  rollTimeObject = rollTimeClass(rollTimeModel);
  
% if the mjd vector is empty, construct one from the raDec2PixModel

  if (nargin < 2) || (isempty(mjds))
      mjds = raDec2PixModel.mjdStart:0.5:raDec2PixModel.mjdEnd ;
  end
  
  mjds = mjds(:);
  
%=========================================================================================
%
% Turn on the feedback
%
%=========================================================================================

% Obtain the RA and Dec of the guide psuedostars, which are at row==5, col==5 of the
% mod/outs which are closest to the FGS.  Do this without velocity aberration, so that the
% mechanical pointing and the optical pointing are identical.  Note that we produce a
% vector of positions which is equal in length to the vector of MJDs.  This means that the
% guide star on mod 9, out 4 (for example) has different RA/Dec coords on each seasonal
% roll (ie, it is a different physical star).  While 4 fixed guide stars would work if the
% 4-way symmetry of the spacecraft is preserved, in the as-built spacecraft with CCD
% offsets this is the only way to guarantee that there are stars at the right locations on
% each seasonal roll.

  modules = [ 9 7 17 19 ]';
  outputs = [ 4 4  4  4 ]';

  rows = 5 * [1 1 1 1]';
  cols = 5 * [1 1 1 1]';
  
  rollTime = get_roll_time(rollTimeObject, mjds) ;
  
  rollTimeMjds        = rollTime(:,1) ;
  raPointingOptical   = rollTime(:,4) ;
  decPointingOptical  = rollTime(:,5) ;
  rollPointingOptical = rollTime(:,6) ;
  
  [raGuideStars, decGuideStars] = pix_2_ra_dec_absolute( raDec2PixObject, ...
      modules, outputs, rows, cols, mjds, ...
      raPointingOptical, decPointingOptical, rollPointingOptical, 0 ) ;

% Define the return vectors

  ra              = zeros(size(mjds)) ;
  dec             = zeros(size(mjds)) ;
  roll            = zeros(size(mjds)) ;
  segmentStartMjd = zeros(size(mjds)) ;
  
% Loop over Kepler pointings and determine the pointing model segment by
% segment

  delta = sqrt(diff(raPointingOptical).^2 + diff(decPointingOptical).^2 + ...
      diff(rollPointingOptical).^2) ;
  startIndices = [1; find(delta > 0)+1] ;
  nSegments = length(startIndices) ;
  
  for iSegment = 1:nSegments
      
    % Define the start/end indices for the given pointing
    
      startIndex = startIndices(iSegment) ;
      
      if iSegment < nSegments
          endIndex = startIndices(iSegment+1)-1 ;
      else
          endIndex = length(mjds) ;
      end
      
    % The pointing we used in the previous step is the optical pointing, which is the same as
    % the mechanical pointing in the absence of velocity aberration.  In later steps we will
    % want the equivalent mechanical pointing.  This is obtained by aberrating the optical
    % pointing -- since aberration will change the apparent RA and Dec of the guide stars by
    % some amount, the feedback will make the mechanical pointing change by the same amount.

      mjd0 = mjds(startIndex) ;
      if iSegment > 1
          segmentMjd0 = rollTimeMjds(startIndex) ;
      else
          segmentMjd0 = mjd0 ;
      end
      
      [raPointingMechanical, decPointingMechanical] = aberrate_ra_dec( raDec2PixObject, ...
          raPointingOptical(startIndex), decPointingOptical(startIndex), ...
          mjd0+raDec2PixModel.mjdOffset ) ;
      rollPointingMechanical = rollPointingOptical(startIndex) ;

    %=========================================================================================
    %
    % Fit the Optimal Mechanical Pointing
    %
    %=========================================================================================

    % the initial solution is the aberrated optical pointing at the instant the feedback was
    % turned on, which we computed above

      ra(startIndex)              = raPointingMechanical ;
      dec(startIndex)             = decPointingMechanical ;
      roll(startIndex)            = rollPointingMechanical ;
      segmentStartMjd(startIndex) = segmentMjd0 ;
      
    % On each subsequent time-step, the optimal mechanical pointing is the one which minimizes
    % the RMS motion of the guide stars from one step to the next.  

      for iMjd = startIndex+1:endIndex

          [ra(iMjd), dec(iMjd), roll(iMjd)] = compute_optimal_pointing_next_timestep( ...
              raDec2PixObject, ra(iMjd-1), dec(iMjd-1), roll(iMjd-1), mjds(iMjd-1), ...
              mjds(iMjd), raGuideStars(:,iMjd-1:iMjd), decGuideStars(:,iMjd-1:iMjd) ) ;
          segmentStartMjd(iMjd) = segmentMjd0 ;

      end
  
  end
  
% if the function was called with a filename as a return argument, write the ascii file
% and return its name to the caller

  if (nargout == 4)
      filename = write_pointing_model_file( mjds, ra, dec, roll, segmentStartMjd ) ;
  end
  
return
  
% and that's it!

%
%
%

%=========================================================================================

% function which performs the least-squares fitting which minimizes motion of the guide
% stars from one time-step to the next

function [ra, dec, roll] = compute_optimal_pointing_next_timestep( ...
          raDec2PixObject, raOld, decOld, rollOld, mjdOld, mjd, raGuideStars, ...
          decGuideStars )
      
% get the row and column positions of the guide stars on the previous time step using the
% previous mechanical pointing

  oldPixelValues = get_guide_star_pixels( raDec2PixObject, [raOld ; decOld ; rollOld], ...
      mjdOld, [raGuideStars(:,1) decGuideStars(:,1)] ) ;
  
% define the anonymous function which will be used by nlinfit to get the pixel positions
% of the guide stars on the current MJD, using a guess of the correct mechanical pointing
% and the RA and Dec of the guide stars

  newPixelValues = @(b,x) get_guide_star_pixels( raDec2PixObject, b, mjd, x ) ;
  
% set the tolerances for the fit

  tolerance = 1e-10 ;
  stats = kepler_set_soc('tolx',tolerance,'tolfun',tolerance) ;

% perform the fit using kepler_nonlinear_fit_soc; the initial guess of the new mechanical pointing
% should be equal to the old mechanical pointing.  Note that since the spacecraft has
% 4-way rotational symmetry, and we do not look at the output module, the fit should
% ignore quarterly rolls to good approximation

  bestFit = kepler_nonlinear_fit_soc( [raGuideStars(:,2) decGuideStars(:,2)], oldPixelValues, ...
      newPixelValues, [raOld ; decOld ; rollOld] ) ;
  
  ra = bestFit(1) ; dec = bestFit(2) ; roll = bestFit(3) ;
  
return  
  
% and that's it!

%
%
%

%=========================================================================================

% wrapper function around the ra_dec_2_pix_absolute function which takes the star
% coordinates and pointing as single objects (rather than 2 vectors and 3 scalars), and
% returns a column vector of [rows ; columns], which is what the nlinfit requires.

function starPixels = get_guide_star_pixels( raDec2PixObject, pointing, mjd, ...
    starCoordinates )

  ra = pointing(1) ; dec = pointing(2) ; roll = pointing(3) ;
  raGuideStars = starCoordinates(:,1) ; decGuideStars = starCoordinates(:,2) ;
  
  [m,o,r,c] = ra_dec_2_pix_absolute( raDec2PixObject, raGuideStars, decGuideStars, ...
      mjd, ra, dec, roll ) ;
  starPixels = [r(:) ; c(:)] ;
  
return

% and that's it!

%
%
%

