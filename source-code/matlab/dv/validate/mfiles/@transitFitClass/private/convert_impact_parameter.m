function [convertedImpactParameter, derivative] = convert_impact_parameter(impactParameter, conversionDirection, ratioPlanetRadiusToStarRadius, impactParameterRangeZeroToOne)
%
% convert_impact_parameter -- convert the impact parameter between its
% external value (bounded [-(1+rp/Rs),(1+rp/Rs)]) and its internal value (unbounded) for fitting
%
% convertedImpactParameter = convert_impact_parameter( impactParameter, direction )
%    converts between the bounded impact parameter (which is bounded by [-1,1]), used in
%    the "real world," and its unbounded equivalent, used in fitting.  When diretion == 1,
%    the conversion is from bounded to unbounded; when direction == -1, the direction is
%    from unbounded to bounded.  
%
% [... , derivative] = convert_impact_parameter( ... ) also returns the first derivative,
%    d(convertedImpactParameter)/d(impactParameter), for use in scaling covariance
%    matrices.
%
% Version date:  2011-August-19.
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
%    2011-August-19, JL:
%        add the flag impactParameterRangeZeroToOne 
%    2011-June-28, JL:
%       add 'ratioPlanetRadiusToStarRadius' as input parameter
%    2010-Dec-01, JL:
%       fix a bug related to impactParameter, which may be a double array
%
%=========================================================================================

  if ~exist( 'ratioPlanetRadiusToStarRadius', 'var' )
      ratioPlanetRadiusToStarRadius = 0;
  end

  ratioPlanetRadiusToStarRadius = abs(ratioPlanetRadiusToStarRadius);

  if ~exist( 'impactParameterRangeZeroToOne', 'var' )
      impactParameterRangeZeroToOne = true;
  end
  
  if impactParameterRangeZeroToOne
      impactParameterLimit = 1;
  else
      impactParameterLimit = 1 + ratioPlanetRadiusToStarRadius;
  end
  
% there are 2 cases allowed, plus errors
  
  switch conversionDirection
      
      case 1 % bounded to unbounded, or "external to internal" in CERN parlance
          
          impactParameterNormalized = impactParameter ./ impactParameterLimit;
          convertedImpactParameter  = asin( impactParameterNormalized );
          derivative                = 1./sqrt( 1-impactParameterNormalized.^2 ) ./ impactParameterLimit;
          
      case -1 % unbounded to bounded, or "internal to external" in CERN parlance
          
          convertedImpactParameter  = impactParameterLimit .* sin( impactParameter );
          derivative                = impactParameterLimit .* cos( impactParameter );
          
      otherwise % error case
          
          error( 'dv:transitFitClass:convertImpactParameter:invalidDirection', 'convert_impact_parameter:  invalid direction argument' );
          
  end
  
return

% and that's it!
