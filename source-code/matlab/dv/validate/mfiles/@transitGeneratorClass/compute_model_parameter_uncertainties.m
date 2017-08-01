function [modelParameterStructs, covarianceModelParameters] = compute_model_parameter_uncertainties(transitModelObject, modelParameterStructs, covarianceFittedParameters, epochOffset)
%
%  compute_model_parameter_uncertainties -- compute the covaraince matrix and uncertainty of model parameters.
%
%
%   I.
%
%   The following stellar parameters are used to calculate derived model parametrrs: 
%
%           Stellar Parameters                      Symbol or Value         Uncertainties           Unit
%
%           radius                                  Rs                      sigma_Rs                solarRadii
%           log10SurfaceGravity                     log10g                  sigma_log10g            log10(cm/s^2)
%           effectiveTemp                           Teffective              sigma_Teffective        K
%           albedo                                  defaultAlbedo = 0.3     assuming 0              dimensionless
%           defaultEffectiveTemp                    5780                    assuming 0              K
%
%           surfaceGravity                          g                       sigma_g                 m/s^2
%
%   Note:   A parameter 'surfaceGravity' is introduced to simplify the calculation. The value and uncertainty of 'surfaceGravity' are determined as 
%
%               g       = 0.01 * 10^log10g
%               sigma_g = g * ln(10) * sigma_log10g 
%
%
%   II.
%
%   There are 16 parameters in modelParameterStruct of all/odd/even transit fit structures, including
%  
%       Fitted parameters:
%
%               transitEpochBkjd                    tEpoch
%               orbitalPeriodDays                   Period
%               minImpactParameter                  b
%               ratioPlanetRadiusToStarRadius       RpToRs
%               ratioSemiMajorAxisToStarRadius      aToRs
%
%
%       Derived parameters:
%
%           Independent of stellar parameters:
%
%               eccentricity                        0
%               longitudeOfPeriDegrees              0
%               transitDepthPpm                     depth       = 1.0e6 * (RpToRs)^2            (ignoring limb-darkening effect)
%               transitDurationHours                tDuration   = 2 * 24/(2*pi) * Period *     asin{ sqrt[ ((1 + RpToRs)^2 - b^2) / ((aToRs)^2 - b^2) ] }
%               transitIngressTimeHours             tIngress    =     24/(2*pi) * Period * {   asin{ sqrt[ ((1 + RpToRs)^2 - b^2) / ((aToRs)^2 - b^2) ] } 
%                                                                                            - asin{ sqrt[ ((1 - RpToRs)^2 - b^2) / ((aToRs)^2 - b^2) ] } } 
%               inclinationDegrees                  inclination = (180/pi) * acos( b/ (aToRs) )
%
%           Dependent on stellar parameters:
%
%               starRadiusSolarRadii                Rs
%
%               planetRadiusEarthRadii              Rp          = (solarRadius/earthRadius) * (RpToRs) * Rs
%
%               semiMajorAxisAu                     a           = { [ (86400*Period) * (solarRadius*Rs) / (2*pi) ]^2 * g }^(1/3)  / Au
%                                                               = 86400^( 2/3) * (solarRadius)^( 2/3) * (2*pi)^(-2/3) * (Au)^(-1)                               * (Period)^( 2/3) * (Rs)^(2/3) * (g)^( 1/3)
%
%               equilibriumTempKelvin               Teq         = Teffective * (1-albedo)^(1/4) * sqrt[ (solarRadius*Rs)/(2*Au*a) ]
%                                                               = 86400^(-1/3) * (solarRadius)^( 1/6) * (2*pi)^( 1/3)             * 2^(-1/2) * (1-albedo)^(1/4) * (Period)^(-1/3) * (Rs)^(1/6) * (g)^(-1/6) * Teffective
%
%               effectiveStellarFlux                ratioFlux   = (Teffective/defaultEffectiveTemp)^4 * Rs^2 / a^2
%                                                               = 86400^(-4/3) * (solarRadius)^(-4/3) * (2*pi)^( 4/3) * (Au)^2    * defaultEffectiveTemp^(-4)   * (Period)^(-4/3) * (Rs)^(2/3) * (g)^(-2/3) * Teffective^4
%                                      
%   Note: Unit conversion is included in the above formulas.
%
%
%   III.
%
%   Basic algorithm:
%
%   When the derived model parameter Z can be written as
%
%       Z = factor * (Period)^e_Period * (RpToRs)^e_RpToRs * (Rs)^e_Rs * (g)^e_g * (Teffective)^e_Teffective
%
%   we have
%
%       dZ / dPeriod        = e_Period     * Z / Period
%
%       dZ / dRpToRs        = e_RpToRs     * Z / RpToRs
%
%       dZ / dRs            = e_Rs         * Z / Rs
%
%       dZ / dg             = e_g          * Z / g 
%
%       dZ / dTeffective    = e_Teffective * Z / Teffective
%
%
%   IV.
%
%   Jacobian matrices of model parameetrs to fitted and stellar parameters are determined as following:
%
%
%   Fitted  parameters:    transitEpochBkjd    ratioPlanetRadiusToStarRadius    ratioSemiMajorAxisToStarRadius        minImpactParameter              orbitalPeriodDays                         
%
% jacobian_model_fitted  = [  1                               0                               0                               0                          epochOffset          %  transitEpochBkjd
%                             0                               0                               0                               0                               0               %  eccentricity
%                             0                               0                               0                               0                               0               %  longitudeOfPeriDegrees
%                             0                             Rp/RpToRs                         0                               0                               0               %  planetRadiusEarthRadii
%                             0                               0                               0                               0                        (2/3)*a/Period         %  semiMajorAxisAu
%                             0                               0                               0                               1                               0               %  minImpactParameter
%                             0                               0                               0                               0                               0               %  starRadiusSolarRadii
%                             0                     jacobian_tDuration_RpToRs       jacobian_tDuration_aToRs        jacobian_tDuration_b             tDuration/Period         %  transitDurationHours
%                             0                      jacobian_tIngress_RpToRs        jacobian_tIngress_aToRs         jacobian_tIngress_b              tIngress/Period         %  transitIngressTimeHours
%                             0                       numeric_depth_RpToRs            numeric_depth_aToRs             numeric_depth_b                         0               %  transitDepthPpm
%                             0                               0                               0                               0                               1               %  orbitalPeriodDays
%                             0                               1                               0                               0                               0               %  ratioPlanetRadiusToStarRadius
%                             0                               0                               1                               0                               0               %  ratioSemiMajorAxisToStarRadius
%                             0                               0                   jacobian_inclination_aToRs      jacobian_inclination_b                      0               %  inclinationDegrees
%                             0                               0                               0                               0                     (-1/3)*Teq/Period         %  equilibriumTempKelvin
%                             0                               0                               0                               0               (-4/3)*ratioFlux/Period  ];     %  effectiveStellarFlu
% 
%                         
% 
% 
%   Stellar parameters:     radius                        surfaceGravity                  effectiveTemp
% 
% jacobian_model_stellar = [  0                               0                               0                                                                               %  transitEpochBkjd
%                             0                               0                               0                                                                               %  eccentricity
%                             0                               0                               0                                                                               %  longitudeOfPeriDegrees
%                           Rp/Rs                             0                               0                                                                               %  planetRadiusEarthRadii
%                        (2/3)*a/Rs                      (1/3)*a/g                            0                                                                               %  semiMajorAxisAu
%                             0                               0                               0                                                                               %  minImpactParameter
%                             1                               0                               0                                                                               %  starRadiusSolarRadii
%                             0                               0                               0                                                                               %  transitDurationHours
%                             0                               0                               0                                                                               %  transitIngressTimeHours
%                             0                               0                               0                                                                               %  transitDepthPpm
%                             0                               0                               0                                                                               %  orbitalPeriodDays
%                             0                               0                               0                                                                               %  ratioPlanetRadiusToStarRadius
%                             0                               0                               0                                                                               %  ratioSemiMajorAxisToStarRadius
%                             0                               0                               0                                                                               %  inclinationDegrees
%                        (1/6)*Teq/Rs                   (-1/6)*Teq/g                       Teq/effectiveTemp                                                                  %  equilibriumTempKelvin
%                        (2/3)*ratioFlux/Rs             (-2/3)*ratioFlux/g         4*ratioFlux/effectiveTemp  ];                                                              %  effectiveStellarFlux                
%
%
%
%
%  where
%
%
%    dtDuration/dRpToRs  =   2 * 24/(2*pi) * Period *     ( 1 / sqrt{ 1 - [(1+RpToRs)^2 - b^2]/[(aToRs)^2 - b^2] } ) * ( 1 / sqrt{ [(1+RpToRs)^2 - b^2]/[(aToRs)^2 - b^2] } ) * (RpToRs+1) * (   1                       /[(aToRs)^2 - b^2]   ) 
%
%    dtDuration/daToRs   = - 2 * 24/(2*pi) * Period *     ( 1 / sqrt{ 1 - [(1+RpToRs)^2 - b^2]/[(aToRs)^2 - b^2] } ) * ( 1 / sqrt{ [(1+RpToRs)^2 - b^2]/[(aToRs)^2 - b^2] } ) *   aToRs    * ( [(1+RpToRs)^2 -  b^2]     /[(aToRs)^2 - b^2]^2 ) 
%
%    dtDuration/db       =   2 * 24/(2*pi) * Period *     ( 1 / sqrt{ 1 - [(1+RpToRs)^2 - b^2]/[(aToRs)^2 - b^2] } ) * ( 1 / sqrt{ [(1+RpToRs)^2 - b^2]/[(aToRs)^2 - b^2 ]} ) *   b        * ( [(1+RpToRs)^2 - (aToRs)^2]/[(aToRs)^2 - b^2]^2 )
%
%
%    dtIngress /dRpToRs  =       24/(2*pi) * Period * {   ( 1 / sqrt{ 1 - [(1+RpToRs)^2 - b^2]/[(aToRs)^2 - b^2] } ) * ( 1 / sqrt{ [(1+RpToRs)^2 - b^2]/[(aToRs)^2 - b^2] } ) * (RpToRs+1) * (   1                       /[(aToRs)^2 - b^2]   )    
%                                                       - ( 1 / sqrt{ 1 - [(1-RpToRs)^2 - b^2]/[(aToRs)^2 - b^2] } ) * ( 1 / sqrt{ [(1-RpToRs)^2 - b^2]/[(aToRs)^2 - b^2] } ) * (RpToRs-1) * (   1                       /[(aToRs)^2 - b^2]   ) }
%
%    dtIngress /daToRs   = -     24/(2*pi) * Period * {   ( 1 / sqrt{ 1 - [(1+RpToRs)^2 - b^2]/[(aToRs)^2 - b^2] } ) * ( 1 / sqrt{ [(1+RpToRs)^2 - b^2]/[(aToRs)^2 - b^2] } ) *   aToRs    * ( [(1+RpToRs)^2 -  b^2]     /[(aToRs)^2 - b^2]^2 ) 
%                                                       - ( 1 / sqrt{ 1 - [(1-RpToRs)^2 - b^2]/[(aToRs)^2 - b^2] } ) * ( 1 / sqrt{ [(1-RpToRs)^2 - b^2]/[(aToRs)^2 - b^2] } ) *   aToRs    * ( [(1-RpToRs)^2 -  b^2]     /[(aToRs)^2 - b^2]^2 ) }
%
%    dtIngress /db       =       24/(2*pi) * Period * {   ( 1 / sqrt{ 1 - [(1+RpToRs)^2 - b^2]/[(aToRs)^2 - b^2] } ) * ( 1 / sqrt{ [(1+RpToRs)^2 - b^2]/[(aToRs)^2 - b^2 ]} ) *   b        * ( [(1+RpToRs)^2 - (aToRs)^2]/[(aToRs)^2 - b^2]^2 )
%                                                       - ( 1 / sqrt{ 1 - [(1-RpToRs)^2 - b^2]/[(aToRs)^2 - b^2] } ) * ( 1 / sqrt{ [(1-RpToRs)^2 - b^2]/[(aToRs)^2 - b^2 ]} ) *   b        * ( [(1-RpToRs)^2 - (aToRs)^2]/[(aToRs)^2 - b^2]^2 ) }
% 
%
%    dinclination/daToRs =   { 1 / sqrt[ 1 - (b/aToRs)^2 ] } * ( b/aToRs^2 )
%
%    dinclination/db     = - { 1 / sqrt[ 1 - (b/aToRs)^2 ] } * ( 1/aToRs   )
%
%
%    numeric_depth_b, numeric_depth_RpToRs, numeric_depth_aToRs are determined numeraically
%
%
%  Note:
%
%    d arcsin(X) / dX =  1 / sqrt( 1 - X*X )
%
%    d arccos(X) / dX = -1 / sqrt( 1 - X*X )
%
%
%
% Version date:  2014-September-05.
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
%  2014-September-05, JL:
%    Implement different algorithms to calculate partial derivatives of 
%    'transitDurationHours', 'transitIngressTimeHours' and
%    'inclinationDegrees' in different cases
%  2014-August-22, JL:
%    Initial release.
%
%=========================================================================================

display(' ');
display('      Calculate the uncetainties and covariance matrix of model parameters (including propagated uncertainties of stellar parameters)');
display(' ');
display(' ');

% Set default value for the output

nModelParameters            = length(modelParameterStructs);
covarianceModelParameters   = zeros(nModelParameters, nModelParameters);

% Set augmented covariance matrix (5x5) of fitted parameters

covarianceFittedParametersAugmented = zeros(5, 5);
nFittedParameters                   = size(covarianceFittedParameters, 1);
if ( nFittedParameters<=5 )
    covarianceFittedParametersAugmented(1:nFittedParameters, 1:nFittedParameters) = covarianceFittedParameters;
else
        errorIdentifier = 'dv:compute_model_parameter_uncertainties: more than 5 fitted parameters';
        errorMessage    = 'number of fitted parameetrs is larger than 5';
        error(errorIdentifier, errorMessage);
end

% Retrieve values and uncertainties of stellar parameters: stellar radius, log10SurfaceGravity and effective stellar temperature

Rs                  = transitModelObject.radius.value;                                      % unit: solar radii
sigma_Rs            = transitModelObject.radius.uncertainty;                                % unit: solar radii
if ( isnan(Rs) || Rs<=0 || isnan(sigma_Rs) || sigma_Rs<0 )
    sigma_Rs = 0;
end

log10g              = transitModelObject.log10SurfaceGravity.value;                         % unit: log10(cm/s^2)
sigma_log10g        = transitModelObject.log10SurfaceGravity.uncertainty;                   % unit: log10(cm/s^2)
g                   = 10^(log10g) * get_unit_conversion('cm2meter');                        % unit: m/s^2
sigma_g             = g * log(10) * sigma_log10g;                                           % unit: m/s^2
if ( isnan(g) || g<=0 || isnan(sigma_g) || sigma_g<0 )
    sigma_g = 0;
end

effectiveTemp       = transitModelObject.effectiveTemp.value;                               % unit: K
sigma_effectiveTemp = transitModelObject.effectiveTemp.uncertainty;                         % unit: K
if ( isnan(effectiveTemp) || effectiveTemp<=0 || isnan(sigma_effectiveTemp) || sigma_effectiveTemp<0 )
    sigma_effectiveTemp = 0; 
end

% Determine covariance matrix of stellar parameters

covarianceStellarParameters = diag([ sigma_Rs^2  sigma_g^2  sigma_effectiveTemp^2 ]);

% Retrieve values of model parameters

modelParameterNames = { modelParameterStructs.name };

Period      = modelParameterStructs(strcmp(modelParameterNames, 'orbitalPeriodDays'             )).value;
b           = modelParameterStructs(strcmp(modelParameterNames, 'minImpactParameter'            )).value;
RpToRs      = modelParameterStructs(strcmp(modelParameterNames, 'ratioPlanetRadiusToStarRadius' )).value;
aToRs       = modelParameterStructs(strcmp(modelParameterNames, 'ratioSemiMajorAxisToStarRadius')).value;

depth       = modelParameterStructs(strcmp(modelParameterNames, 'transitDepthPpm'               )).value;
tDuration   = modelParameterStructs(strcmp(modelParameterNames, 'transitDurationHours'          )).value;
tIngress    = modelParameterStructs(strcmp(modelParameterNames, 'transitIngressTimeHours'       )).value;
Rp          = modelParameterStructs(strcmp(modelParameterNames, 'planetRadiusEarthRadii'        )).value;
a           = modelParameterStructs(strcmp(modelParameterNames, 'semiMajorAxisAu'               )).value;
Teq         = modelParameterStructs(strcmp(modelParameterNames, 'equilibriumTempKelvin'         )).value;
ratioFlux   = modelParameterStructs(strcmp(modelParameterNames, 'effectiveStellarFlux'          )).value;

% Determine partial derivatives of derived parameter 'transitDurationHours' to fitted parameters 'ratioPlanetRadiusToStarRadius', 'ratioSemiMajorAxisToStarRadius' and 'minImpactParameter'

xBuf         = aToRs*aToRs               - b*b;
xBuf1        = (1 + RpToRs)*(1 + RpToRs) - b*b;
xBuf2        = (1 - RpToRs)*(1 - RpToRs) - b*b; 
pFactor      = 24/(2*pi) * Period;

if ( aToRs > (1 + RpToRs) )
    
        coefficient1                =   pFactor / xBuf / sqrt( (xBuf - xBuf1)* xBuf1 );
    
        jacobian_tDuration_RpToRs   =   2 * coefficient1 *  xBuf        * (1 + RpToRs);
        jacobian_tDuration_aToRs    = - 2 * coefficient1 *  xBuf1       *       aToRs;
        jacobian_tDuration_b        =   2 * coefficient1 * (xBuf1-xBuf) *       b;
    
else
    
        jacobian_tDuration_RpToRs   = 0;
        jacobian_tDuration_aToRs    = 0;
        jacobian_tDuration_b        = 0;
    
end

% Determine partial derivatives of derived parameter 'transitIngressTimeHours' to fitted parameters 'ratioPlanetRadiusToStarRadius', 'ratioSemiMajorAxisToStarRadius' and 'minImpactParameter'

if (RpToRs + b) < 0.999

    if ( aToRs > (1 + RpToRs) )
        
        coefficient1                =   pFactor / xBuf / sqrt( (xBuf - xBuf1)* xBuf1 );
        coefficient2                =   pFactor / xBuf / sqrt( (xBuf - xBuf2)* xBuf2 );

        jacobian_tIngress_RpToRs    =       coefficient1 *  xBuf        * (1 + RpToRs) + coefficient2 *  xBuf        * (1 - RpToRs);
        jacobian_tIngress_aToRs     =     - coefficient1 *  xBuf1       *       aToRs  + coefficient2 *  xBuf2       *       aToRs;
        jacobian_tIngress_b         =       coefficient1 * (xBuf1-xBuf) *       b      - coefficient2 * (xBuf2-xBuf) *       b;

    else
        
        coefficient2                =   pFactor / xBuf / sqrt( (xBuf - xBuf2)* xBuf2 );

        jacobian_tIngress_RpToRs    =                                                    coefficient2 *  xBuf        * (1 - RpToRs);
        jacobian_tIngress_aToRs     =                                                    coefficient2 *  xBuf2       *       aToRs;
        jacobian_tIngress_b         =                                                  - coefficient2 * (xBuf2-xBuf) *       b;
        
    end
    
else
    
    if ( aToRs > (1 + RpToRs) )
        
        coefficient1                =   pFactor / xBuf / sqrt( (xBuf - xBuf1)* xBuf1 );
    
        jacobian_tIngress_RpToRs    =       coefficient1 *  xBuf        * (1 + RpToRs);
        jacobian_tIngress_aToRs     =     - coefficient1 *  xBuf1       *       aToRs;
        jacobian_tIngress_b         =       coefficient1 * (xBuf1-xBuf) *       b;
        
        
    else
        
        jacobian_tIngress_RpToRs    = 0;
        jacobian_tIngress_aToRs     = 0;
        jacobian_tIngress_b         = 0;
        
    end
end

        
% Determine partial derivatives of derived parameter 'inclinationDegrees' to fitted parameters 'ratioPlanetRadiusToStarRadius', 'ratioSemiMajorAxisToStarRadius' and 'minImpactParameter'

if aToRs > b
    
    jacobian_inclination_aToRs      =    (180/pi) / sqrt( aToRs*aToRs - b*b ) * (b/aToRs);
    jacobian_inclination_b          =  - (180/pi) / sqrt( aToRs*aToRs - b*b );
    
else
    
    jacobian_inclination_aToRs      = 0;
    jacobian_inclination_b          = 0;
    
end

% Calculate partial derivatives of the derived parameter 'transitDepthPpm' numerically

numeric_depth_RpToRs     = calculate_numeric_partial_derivative(transitModelObject, 'transitDepthPpm', 'ratioPlanetRadiusToStarRadius',  0.99);
if isnan(numeric_depth_RpToRs) || ~isfinite(numeric_depth_RpToRs)
    numeric_depth_RpToRs = 0;
end

numeric_depth_aToRs      = calculate_numeric_partial_derivative(transitModelObject, 'transitDepthPpm', 'ratioSemiMajorAxisToStarRadius', 1.01);
if isnan(numeric_depth_aToRs) || ~isfinite(numeric_depth_aToRs)
    numeric_depth_aToRs  = 0;
end

numeric_depth_b          = calculate_numeric_partial_derivative(transitModelObject, 'transitDepthPpm', 'minImpactParameter',             0.99);
if isnan(numeric_depth_b) || ~isfinite(numeric_depth_b)
    numeric_depth_b      = 0;
end


% Jacobian matrix (16x5) of model parameters to fitted parameters:


% Fitted  parameters:    transitEpochBkjd    ratioPlanetRadiusToStarRadius    ratioSemiMajorAxisToStarRadius        minImpactParameter              orbitalPeriodDays                         

jacobian_model_fitted  = [  1                               0                               0                               0                          epochOffset          %  transitEpochBkjd
                            0                               0                               0                               0                               0               %  eccentricity
                            0                               0                               0                               0                               0               %  longitudeOfPeriDegrees
                            0                             Rp/RpToRs                         0                               0                               0               %  planetRadiusEarthRadii
                            0                               0                               0                               0                        (2/3)*a/Period         %  semiMajorAxisAu
                            0                               0                               0                               1                               0               %  minImpactParameter
                            0                               0                               0                               0                               0               %  starRadiusSolarRadii
                            0                     jacobian_tDuration_RpToRs       jacobian_tDuration_aToRs        jacobian_tDuration_b             tDuration/Period         %  transitDurationHours
                            0                      jacobian_tIngress_RpToRs        jacobian_tIngress_aToRs         jacobian_tIngress_b              tIngress/Period         %  transitIngressTimeHours
                            0                       numeric_depth_RpToRs            numeric_depth_aToRs             numeric_depth_b                         0               %  transitDepthPpm
                            0                               0                               0                               0                               1               %  orbitalPeriodDays
                            0                               1                               0                               0                               0               %  ratioPlanetRadiusToStarRadius
                            0                               0                               1                               0                               0               %  ratioSemiMajorAxisToStarRadius
                            0                               0                   jacobian_inclination_aToRs      jacobian_inclination_b                      0               %  inclinationDegrees
                            0                               0                               0                               0                     (-1/3)*Teq/Period         %  equilibriumTempKelvin
                            0                               0                               0                               0               (-4/3)*ratioFlux/Period  ];     %  effectiveStellarFlu

                        
% Jacobian matrix (16x3) of model parameters to stellar parameters:


% Stellar parameters:     radius                        surfaceGravity                  effectiveTemp

jacobian_model_stellar = [  0                               0                               0                                                                               %  transitEpochBkjd
                            0                               0                               0                                                                               %  eccentricity
                            0                               0                               0                                                                               %  longitudeOfPeriDegrees
                          Rp/Rs                             0                               0                                                                               %  planetRadiusEarthRadii
                       (2/3)*a/Rs                      (1/3)*a/g                            0                                                                               %  semiMajorAxisAu
                            0                               0                               0                                                                               %  minImpactParameter
                            1                               0                               0                                                                               %  starRadiusSolarRadii
                            0                               0                               0                                                                               %  transitDurationHours
                            0                               0                               0                                                                               %  transitIngressTimeHours
                            0                               0                               0                                                                               %  transitDepthPpm
                            0                               0                               0                                                                               %  orbitalPeriodDays
                            0                               0                               0                                                                               %  ratioPlanetRadiusToStarRadius
                            0                               0                               0                                                                               %  ratioSemiMajorAxisToStarRadius
                            0                               0                               0                                                                               %  inclinationDegrees
                       (1/6)*Teq/Rs                   (-1/6)*Teq/g                       Teq/effectiveTemp                                                                  %  equilibriumTempKelvin
                       (2/3)*ratioFlux/Rs             (-2/3)*ratioFlux/g         4*ratioFlux/effectiveTemp  ];                                                              %  effectiveStellarFlux                


                   
% Determine covariance matrix of model parameters from covariance matrices of fitted and stellar parameters

covarianceModelParameters  = jacobian_model_fitted  * covarianceFittedParametersAugmented  * jacobian_model_fitted' + jacobian_model_stellar * covarianceStellarParameters * jacobian_model_stellar';

% Uncertainties of model parameters are determined as square roots of diagonal elements of the covariance matrix of model parameters

uncertaintyModelParameters = sqrt( diag(covarianceModelParameters) );


% Set the field 'uncertainty' in modelParameterStructs

for iPar = 1:nModelParameters
    if ( isfinite( uncertaintyModelParameters(iPar) ) && isreal( uncertaintyModelParameters(iPar) ) )
        modelParameterStructs(iPar).uncertainty = uncertaintyModelParameters(iPar);
    else
        errorIdentifier = ['dv:compute_model_parameter_uncertainties:'  modelParameterStructs(iPar).name '_uncertainty_notReal'];
        errorMessage    = ['uncertainty of model parameter ' modelParameterStructs(iPar).name ' is not a finite real number'];
        error(errorIdentifier, errorMessage);
    end
end

return



function [numericPartialDerivative] = calculate_numeric_partial_derivative(transitModelObject, dependentFieldString, independentFieldString, factor)

numericPartialDerivative = 0;

planetModel                             = get( transitModelObject, 'planetModel' );
planetModelBuf                          = planetModel;
planetModelBuf.(independentFieldString) = factor * planetModel.(independentFieldString);
transitModelObject                      = set(transitModelObject, 'planetModel', planetModelBuf);
planetModelBuf                          = get(transitModelObject, 'planetModel' );

numericPartialDerivative                = ( planetModelBuf.(dependentFieldString)   - planetModel.(dependentFieldString)   ) /    ...
                                          ( planetModelBuf.(independentFieldString) - planetModel.(independentFieldString) );


return


