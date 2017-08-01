function [inclinationAngle, jacobian] = compute_inclination_angle( transitModelObject, ...
    unitString )
%
% compute_inclination_angle -- determine the inclination angle of a transiting planet from
% its physical parameters
%
% inclinationAngle = compute_inclination_angle( transitModelObject ) computes the
%    inclination angle for a transiting planet from the star radius, semi-major axis, and
%    impact parameter.  The angle is returned in degrees.
%
% [inclinationAngle, jacobian] = compute_inclination_angle( transitModelObject ) also
%    returns the Jacobian of the transformation from physical parameters to inclination
%    angle, which can be used to estimate the uncertainty in the inclination angle.
%
% [...] = compute_inclination_angle( transitModelObject, unitString ) allows the method to
%    return the inclination angle and Jacobian using different units.  Allowed values for
%    unitString are 'degrees' (default) and 'radians'.  
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
%=========================================================================================

% Limit on minimum impact parameter which determines whether a full Jacobian calculation
% is possible, or whether a simplified one is needed

  minImpactParameterJacobianLimit = 1e-9 ;

% check the unit string, if present, and set unit conversion

  if (exist('unitString','var'))
      
      switch lower(unitString)
          
          case 'degrees'
              unitConversion = get_unit_conversion('rad2deg') ;
          case 'radians'
              unitConversion = 1 ;
              
          otherwise
              error('dv:transitGeneratorClass:computeInclinationAngle:unitStringNotRecognized', ...
                  ['compute_inclination_angle:  unrecognized unit string ''', ...
                  unitString, ''' detected']) ;
              
      end
      
  else
      unitConversion = get_unit_conversion('rad2deg') ;
  end
  
% get the parameters out of the planetModel

  semiMajorAxisAu        = transitModelObject.planetModel.semiMajorAxisAu      ;
  starRadiusSolarRadii   = transitModelObject.planetModel.starRadiusSolarRadii ;
  minImpactParameter     = transitModelObject.planetModel.minImpactParameter   ;
  
% construct an initial values vector with the current values, and an anonymous function
% which has the correct unit conversion

  beta0 = [semiMajorAxisAu ; minImpactParameter ; starRadiusSolarRadii] ;
  inclination_angle = @(beta) unitConversion * acos( ...
      beta(2) * get_unit_conversion('solarRadius2meter') * beta(3) / ...
      (get_unit_conversion('au2meter') * beta(1))  ) ;

% compute the central value

  inclinationAngle = inclination_angle( beta0 ) ;
  
% if the user specified a Jacobian calculation, perform that now as well

  if (nargout == 2)
      
%     start by setting up a properly shaped and sized Jacobian for conversion from the
%     physical parameters to the inclination angle:  this has dimension of 1 x nPhysPars.

      legalFieldNames = get_planet_model_legal_fields( 'physical' ) ;
      jacobian = zeros( 1, length(legalFieldNames) ) ;
      
%     perform the calculation of the Jacobian.  If minImpactParameter == 1, then taking a
%     positive step in the jacobian calculator will result in an error.  Thus, for this
%     calculation we will use default step sizes for pars 1 and 3, but a negative default
%     step size for par 2 (the impact parameter).

      nlinfitOptions = kepler_set_soc('kepler_nonlinear_fit_soc') ;
      stepSize = nlinfitOptions.DerivStep ;
      stepSizeVector = [stepSize ; -abs(stepSize) ; stepSize] ;

%     If the minimum impact parameter is very close to zero, then the inclination angle
%     does not depend upon the star radius or the semi-major axis to within the limits of
%     double precision, which will cause compute_jacobian to error out.  Thus, if the
%     impact parameter is in that range we need to use a slightly more simple calculation
%     to get the job done.

      if ( abs(minImpactParameter) > minImpactParameterJacobianLimit )

          numericJacobian = compute_jacobian( inclination_angle, beta0, [], ...
              stepSizeVector ) ;
          
      else
          
          numericJacobian = [ 0 ...
              -get_unit_conversion('solarRadius2meter') * starRadiusSolarRadii / ...
              (get_unit_conversion('au2meter') * semiMajorAxisAu) * unitConversion ...
              0 ] ;
              
      end
      
%     put the Jacobian terms into their correct slots in the return vector, based on their
%     order in legalFieldNames.

      [tf,fieldLocation] = ismember( {'semiMajorAxisAu', 'minImpactParameter', ...
          'starRadiusSolarRadii'}, legalFieldNames ) ;
      for iField = 1:length(fieldLocation)
          jacobian(fieldLocation(iField)) = numericJacobian(iField) ;
      end
      
  end
  
return

% and that's it!

%
%
%
