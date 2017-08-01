function transitObject = get_transit_object_with_new_star_radius( transitObject, ...
              kicStarRadius )
%
% get_transit_object_with_new_star_radius -- produce a new transitGeneratorClass object
% which has the same observable parameters as the old one but with a different star
% radius
%
% transitObject = get_transit_object_with_new_star_radius( transitObject, kicStarRadius )
%    returns a new transit object which has the same observable properties as the original
%    object, but uses the new star radius instead of the one in the old object.  If the
%    new radius cannot be used to produce an equivalent transit, the method will error
%    out.
%
% Version date:  2009-August-28.
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

% get the planet model

  planetModel = get( transitObject, 'planetModel' ) ;
  planetModelNew = planetModel ;
  orbitalPeriodDays = planetModel.orbitalPeriodDays ; 
  
  planetModelNew.starRadiusSolarRadii = kicStarRadius ;

% The physical parameters which need to change are:  planet radius, semi-major axis,
% impact parameter.

% the planet radius scales with the star radius

  planetModelNew.planetRadiusEarthRadii = planetModel.planetRadiusEarthRadii * ...
      kicStarRadius / planetModel.starRadiusSolarRadii ; 
  
% the semi-major axis can be obtained from -- yeah, you got it -- Kepler's Third Law (or
% was that, "time machines"?)

  planetModelNew.semiMajorAxisAu = kepler_third_law( transitObject, [], ...
      kicStarRadius, orbitalPeriodDays ) ;
  
% the impact parameter can be obtained from the transit duration relationship, now that we
% have the other physical parameters

  transitDurationSec = planetModel.transitDurationHours * get_unit_conversion('hour2sec') ;
  starRadiusMeters = kicStarRadius * get_unit_conversion('solarRadius2meter') ;
  semiMajorAxisMeters = planetModelNew.semiMajorAxisAu * get_unit_conversion('au2meter') ;
  planetRadiusMeters = planetModelNew.planetRadiusEarthRadii * ...
      get_unit_conversion('earthRadius2meter') ;
  
  surfaceGravityMks = 10^(transitObject.log10SurfaceGravity) * ...
      get_unit_conversion('cm2meter') ;
  
  impactParameterSquared = ...
      (starRadiusMeters + planetRadiusMeters)^2 / starRadiusMeters^2 - ...
      surfaceGravityMks * transitDurationSec^2 / 4 / semiMajorAxisMeters ;
  
% check to see whether the impact parameter is in bounds, error out if not

  if ( impactParameterSquared < 0 || impactParameterSquared > 1 )
      error( 'dv:getTransitObjectWithNewStarRadius:impactParameterInvalid', ...
          'get_transit_object_with_new_star_radius:  impact parameter is not within [0,1]' ) ;
  end
  
% otherwise, put it into the planet model, get the new transit object, and return

  planetModelNew.minImpactParameter = sqrt( impactParameterSquared ) ;
  transitObject = set( transitObject, 'planetModel', planetModelNew ) ;
  
return

% and that's it!

%
%
%

  