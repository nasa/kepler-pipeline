function returnValue = kepler_third_law( transitGeneratorObject, semiMajorAxisAu, ...
    starRadiusSolarRadii, orbitalPeriodDays )
%
% kepler_third_law -- compute any of semi-major axis, star radius, orbital period from the
% other two values
%
% returnValue = kepler_third_law( transitGeneratorObject, semiMajorAxisAu, 
%    starRadiusSolarRadii, orbitalPeriodDays ) allows the user to take any two parameters
%    out of the set of semi-major axis, star radius, orbital period, and compute the
%    remaining parameter, which is returned.  The parameter to be computed is indicated by
%    an empty ( [] ) for its RHS argument value.  The calculation also requires the
%    base-10 log of the surface gravity in cm/sec^2.
%
% Version date:  2009-August-18.
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

% compute MKS parameters

  semiMajorAxisMks    = semiMajorAxisAu * get_unit_conversion('au2meter') ;
  starRadiusMks       = starRadiusSolarRadii * get_unit_conversion('solarRadius2meter') ;
  orbitalPeriodMks    = orbitalPeriodDays * get_unit_conversion('day2sec') ;
  log10SurfaceGravity = transitGeneratorObject.log10SurfaceGravity.value ;
  gMks                = 10^(log10SurfaceGravity) * get_unit_conversion('cm2meter') ;

% determine the calculation type (aka, "which parameter is to be computed")

  calculationType = 1 * isempty(semiMajorAxisAu) + 2 * isempty(starRadiusSolarRadii) + ...
      3 * isempty(orbitalPeriodDays) + ...
      4 * ( isempty(semiMajorAxisAu) && isempty(starRadiusSolarRadii) ) ;
  
% compute the returned value based on the type

  switch calculationType
    
    case 1 % compute semi-major axis
        
        semiMajorAxisMks = (orbitalPeriodMks * starRadiusMks * sqrt(gMks) / 2 / pi)^(2/3) ;
        returnValue = semiMajorAxisMks * get_unit_conversion('meter2au') ;
        
    case 2 % compute star radius
        
        starRadiusMks = 2*pi*semiMajorAxisMks^(3/2) / orbitalPeriodMks / sqrt(gMks) ;
        returnValue = starRadiusMks * get_unit_conversion('meter2solarRadius') ;
        
    case 3 % compute orbital period
        
        orbitalPeriodMks = 2*pi*semiMajorAxisMks^(3/2) / starRadiusMks / sqrt(gMks) ;
        returnValue = orbitalPeriodMks * get_unit_conversion('sec2day') ;
        
    otherwise % error case
        
        error('dv:keplerThirdLaw:rhsArgumentsInvalid', ...
            'kepler_third_law:  one of the first 3 RHS arguments must be empty') ;
        
  end
  
return

% and that's it!

%
%
%
