function [raApparent, decApparent] = apply_aberration_to_ra_dec( raActual, decActual, ...
    velocity )
%
% apply_aberration_to_ra_dec -- apply velocity aberration to selected points in the sky
%
% [raApparent, decApparent] = apply_aberration_to_ra_dec( raActual, decActual, velocity )
%    accepts vectors of actual (ie, catalog) RA and Dec coordinates and a matrix of
%    velocity cartesian components (in a Sun-centered or barycentered equatorial
%    coordinate system, typically J2000) and returns the aberrated (ie, apparent) RAs and
%    Decs.  The raActual and decActual arguments may be either row or column vectors; the
%    shape of the velocity argument may be either nTimes x 3 or 3 x nTimes (since there
%    are 3 components to a velocity in our universe).  The shape of the returned apparent
%    coordinate matrices will be nTimes x nStars.
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

% convert the ra and dec arguments to column vectors, and make sure that they are equal in
% length

  raActual  = raActual(:)  ;
  decActual = decActual(:) ;
  if (length(raActual) ~= length(decActual))
      error('dva:applyAberrationToRaDec:raDecLengthsUnequal', ...
          'apply_aberration_to_ra_dec:  ra and dec arguments must have equal lengths') ;
  end
  
% convert the velocity matrix to nTimes x 3

  sizeVelocity = size(velocity) ;
  
  if (sizeVelocity(1) == 3)
      velocity = velocity' ;
  elseif (sizeVelocity(2) ~= 3)
      error('dva:applyAberrationToRaDec:velocityShapeInvalid', ...
          'apply_aberration_to_ra_dec:  shape of velocity must be N x 3 or 3 x N') ;
  end
  
% convert the ra and dec into a Cartesian vector which points at the point of interest in
% an equatorial coordinate system

  [x, y, z] = convert_stars_sph2cart( raActual, decActual ) ;
  
% aberrate the point of interest with the velocity vectors

  [x, y, z] = vel_aber( x, y, z, velocity ) ;
  
% convert back to RA and Dec

  [raApparent, decApparent] = convert_stars_cart2sph( x, y, z ) ;
  
return

% and that's it!

%
%
%
