function lightCurve = get_transit_light_curve_for_uniform_star(...
    impactParameter, ratioPlanetRadiusToStarRadius)
% function lightCurve = get_transit_light_curve_for_uniform_star(...
%     impactParameter, ratioPlanetRadiusToStarRadius)
%
% function to compute a transit model light curve for a uniform (non-limb
% darkened) star.  Algorithms are based on the model of Mandel & Agol (2002).
%
%
% INPUTS:
%
% transitModelObject with the following relevant fields:
%
%   impactParameterArray [array] impact parameter (separation distance of
%                        the planet and star centers as a function of time)
%                        normalized by star radius ('z' in MA02)
%
%   ratioPlanetRadiusToStarRadius [scalar] planet radius normalized by star
%                       radius('p' in MA02)
%
% OUTPUTS:
%
%   lightCurve          light curve (same size as cadenceTimes) that
%                       represents the change in flux relative the the
%                       unobscured flux due to transiting planet
%--------------------------------------------------------------------------
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
% 2011-October-07, JL:
%     when the star is partly occulted and the planet crosses the limb, the
%     number of data points should be positive.
% 2010-December-1, EQ:
%     changed planetRadius to ratioPlanetRadiusToStarRadius for clarity,
%     removed original (unused) code.
% 2009-August-26, PT:
%     replaced original version with vectorized version -- slightly improved
%     performance under normal circumstances, but performance in profiler is
%     much closer to nominal than in the case with a big for-loop.
% 2009-May-5, EQ: Initial release.



numImpactParamValues = length(impactParameter);

% allocate memory for light curve
lightCurve = zeros(numImpactParamValues, 1);


%----------------------------------------------------------------------------
% the star is unobscured
%----------------------------------------------------------------------------
lightCurve( impactParameter >= 1 + ratioPlanetRadiusToStarRadius ) = 1 ;


%----------------------------------------------------------------------
% the star is completely occulted by the planet
%----------------------------------------------------------------------
if ( ratioPlanetRadiusToStarRadius >= 1 )
    lightCurve( impactParameter <= ratioPlanetRadiusToStarRadius-1 ) = 0 ;
end


%----------------------------------------------------------------------
% the star is partly occulted and the planet crosses the limb:
%----------------------------------------------------------------------
valuesToUse = impactParameter >= abs(1 - ratioPlanetRadiusToStarRadius) & ...
    (impactParameter <= 1 + ratioPlanetRadiusToStarRadius) ;

impactParamRow = impactParameter(valuesToUse) ;
nValues = length(impactParamRow) ;

if nValues>0
    
    % define kappa0 and kappa1 to simplify the flux equation
    kappa1 = acos( min( (1-ratioPlanetRadiusToStarRadius^2 + (impactParamRow.^2)) / 2 ...
        ./ impactParamRow , ones(nValues,1)  ) ) ;
    
    kappa0 = acos( min(  (ratioPlanetRadiusToStarRadius^2 + (impactParamRow.^2) - 1) / 2 ...
        / ratioPlanetRadiusToStarRadius ./ impactParamRow , ones(nValues,1)  ) ) ;
    
    
    % compute lambda_e (see Section 2 of MA02 for details)
    lambdae = ratioPlanetRadiusToStarRadius^2 * kappa0 + kappa1 ;
    lambdae = lambdae - 0.5 * sqrt( max( 4*impactParamRow.^2 - ...
        (1+impactParamRow.^2-ratioPlanetRadiusToStarRadius^2).^2 , zeros(nValues,1)  ) ) ;
    lambdae = lambdae / pi ;
    
    
    % select the values of lambdae to use
    lightCurve( valuesToUse ) = 1 - lambdae ;
    
end

%----------------------------------------------------------------------
% the planet transits the source star (but doesn't completely cover it):
%----------------------------------------------------------------------
lightCurve( impactParameter <= 1 - ratioPlanetRadiusToStarRadius ) = ...
    1 - ratioPlanetRadiusToStarRadius^2 ;


return

