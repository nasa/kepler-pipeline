function [raActual, decActual] = remove_aberration_from_ra_dec( raApparent, ...
    decApparent, velocity )
%
% remove_aberration_from_ra_dec -- convert aberrated RA / Dec pairs to actual 
%
% [raActual, decActual] = remove_aberration_from_ra_dec( raApparent, decApparent, 
%    velocity ) takes apparent RA and Dec values and a velocity (in Cartesian coordinates
%    in an equatorial coordinate system) and returns the actual (catalog) RA and Dec
%    values.  Arguments RA and Dec can be row- or column-vectors; velocity can be either 1
%    x 3 (in which case it's a single 3-component velocity used to unaberrate all RAs and
%    Decs) or length(RA) x 3 (in which case each element of RA, Dec is unaberrated with
%    its corresponding velocity vector).
%
% Version date:  2009-June-08.
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
%=========================================================================================

% Make sure that raApparent and decApparent are equal in length
 
  raApparent  = raApparent(:) ;
  decApparent = decApparent(:) ;
  if (length(raApparent) ~= length(decApparent))
      error('dva:removeAberrationFromRaDec:raDecLengthsUnequal', ...
          'remove_aberration_from_ra_dec:  ra and dec arguments must have equal lengths') ;
  end
  nRaDec = length(raApparent) ;
  
% check the dimensions of velocity, and either repmat or throw error if need be

  sizeVelocity = size(velocity) ;
  if (sizeVelocity(2) ~=3)
      error('dva:removeAberrationFromRaDec:velocityNot3Vector', ...
          'remove_aberration_from_ra_dec:  velocity argument must be n x 3') ;
  end
  if (sizeVelocity(1) == 1)
      velocity = repmat(velocity,nRaDec,1) ;
  end
  if (size(velocity,1) ~= nRaDec)
      error('dva:removeAberrationFromRaDec:velocityMatrixInvalid', ...
          'remove_aberration_from_ra_dec:  size(velocity,1) must == 1 or length(RA)') ;
  end
  
  
% convert the ra and dec into a Cartesian vector which points at the point of interest in
% an equatorial coordinate system

  [x, y, z] = convert_stars_sph2cart( raApparent, decApparent ) ;
  
% construct vectors of unabberated Cartesian coordinates which will be filled in by the
% calculation engine

  xActual = zeros(size(x)) ;
  yActual = zeros(size(x)) ;
  zActual = zeros(size(x)) ;
  
% perform the calculation:  since vel_aber_inv is not vectorized, the calculation must be
% made for one point and one velocity at a time, via the dreaded for-loop

  for iRaDec = 1:nRaDec
          [xActual(iRaDec), yActual(iRaDec), zActual(iRaDec)] = ...
              vel_aber_inv( x(iRaDec), y(iRaDec), z(iRaDec), velocity(iRaDec,:) ) ;
  end
  
% convert back to RA and Dec from Cartesian coordinates

  [raActual, decActual] = convert_stars_cart2sph( xActual, yActual, zActual ) ;
  
return

% and that's it!

%
%
%

