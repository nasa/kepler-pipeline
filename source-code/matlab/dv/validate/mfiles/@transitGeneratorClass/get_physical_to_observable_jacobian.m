function J = get_physical_to_observable_jacobian( transitGeneratorObject )
%
% get_physical_to_observable_jacobian -- return the Jacobian for the transformation from
% physical to observable parameters in a transitGeneratorClass object
%
% J = get_physical_to_observable_jacobian( transitGeneratorObject ) returns the Jacobian
%    for the transformation from physical parameters (planet radius, semi-major axis,
%    orbit inclination, star radius) to observable parameters (transit duration, transit
%    ingress time, transit depth, orbital period).  Parameter order is as listed above,
%    see the help in transitGeneratorClass for the units used.
%
% Version date:  2009-July-22.
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
%    2009-July-22, PT:
%        change from inclinationDegrees to minImpactParameter in planetModel.
%
%=========================================================================================

% the function which is passed to get_jacobian has to take as an argument the vector of
% independent variables (here, the physical parameters) and return a vector of dependent
% variables (here, the observable parameters).  We will do that with an anonymous function
% which calls a subfunction -- a bit kludgey, but it meets the requirements

  transform = @(beta) phys_to_obs( transitGeneratorObject, beta ) ;
  
% get the current values of the physical parameters

  planetModel = get(transitGeneratorObject, 'planetModel') ;
  beta0 = [ planetModel.planetRadiusEarthRadii ; ...
            planetModel.semiMajorAxisAu        ; ...
            planetModel.minImpactParameter     ; ...
            planetModel.starRadiusSolarRadii         ] ;
        
% perform the Jacobian calculation

  J = compute_jacobian( transform, beta0 ) ;
  
return

% and that's it!

%
%
%

%=========================================================================================

% subfunction which takes the transit generator class object, inserts the value of the
% physical parameters, and extracts the corresponding value of the observable parameters

function obs = phys_to_obs( transitGeneratorObject, phys )

% get the planet model

  planetModel = get(transitGeneratorObject, 'planetModel') ;
  
% insert the values

  planetModel.planetRadiusEarthRadii = phys(1) ;
  planetModel.semiMajorAxisAu        = phys(2) ;
  planetModel.minImpactParameter     = phys(3) ;
  planetModel.starRadiusSolarRadii   = phys(4) ;
  
% put the values back into the object and recalculate the observable parameters

  transitGeneratorObject = set( transitGeneratorObject, 'planetModel', planetModel ) ;
  planetModel = get( transitGeneratorObject, 'planetModel' ) ;
  
% extract the observable parameters

  obs = zeros(4,1) ;

  obs(1) = planetModel.transitDurationHours ;
  obs(2) = planetModel.transitIngressTimeHours ;
  obs(3) = planetModel.transitDepthPpm ;
  obs(4) = planetModel.orbitalPeriodDays ;
  
return

% and that's it!

%
%
%
