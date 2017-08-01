function modelParameterStructs = update_model_parameter_uncertainties(transitModelObject, modelParameterStructs)
%
% update_model_parameter_uncertainties -- compute/update the uncertainties of derived model parameters to include propagated uncertainties of stellar parameters.
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
%               transitEpochBkjd                    t_epoch
%               orbitalPeriodDays                   Period
%               minImpactParameter                  b
%               ratioPlanetRadiusToStarRadius       Rp/Rs
%               ratioSemiMajorAxisToStarRadius      a/Rs
%
%
%       Derived parameters:
%
%           Independent of stellar parameters:
%
%               eccentricity                        0
%               longitudeOfPeriDegrees              0
%               transitDepthPpm                     depth       = (Rp/Rs)^2       (ignoring limb-darkening effect)
%               transitDurationHours                duration    = Period/pi     *     asin{ sqrt[ ((1 + Rp/Rs)^2 - b^2) / ((a/Rs)^2 - b^2) ] }
%               transitIngressTimeHours             t_ingress   = Period/(2*pi) * {   asin{ sqrt[ ((1 + Rp/Rs)^2 - b^2) / ((a/Rs)^2 - b^2) ] } 
%                                                                                       - asin{ sqrt[ ((1 - Rp/Rs)^2 - b^2) / ((a/Rs)^2 - b^2) ] } } 
%               inclinationDegrees                  inclination = acos( b/ (a/Rs) )
%
%           Dependent on stellar parameters:
%
%               starRadiusSolarRadii                Rs
%
%               planetRadiusEarthRadii              Rp          = (Rp/Rs) * Rs
%
%               semiMajorAxisAu                     a           = { [ (Period*Rs) / (2*pi) ]^2 * g }^(1/3)
%                                                               = (2*pi)^(-2/3) * (Period)^(2/3) * (Rs)^(2/3) * (g)^(1/3)
%
%               equilibriumTempKelvin               Teq         = Teffective * (1-albedo)^(1/4) * sqrt( Rs/a/2 )
%                                                               = 2^(-1/6) * (pi)^(1/3) * (1 - albedo)^(1/4) * (Period)^(-1/3) * (Rs)^(1/6) * (g)^(-1/6) * Teffective
%
%               effectiveStellarFlux                ratioFlux   = (Teffective/defaultEffectiveTemp)^4 * (Rp/earthRadius)^2 / (a/Au)^2
%                                                               = (2*pi)^(4/3) * (Au/earthRadius)^2 * defaultEffectiveTemp^(-4) * (Period)^(-4/3) * (Rp/Rs)^2 * (Rs)^(2/3) * (g)^(-2/3) * Teffective^4
%                                      
%   Note: Unit conversion is not included in the above formulas.
%
%
%   III.
%
%   Basic algorithm:
%
%   Assume derived parameter Z can be written as
%
%       Z = factor(Period, b, Rp/Rs, a/Rs) * (Rs)^e_Rs * (g)^e_g * (Teffective)^e_Teffective
%
%   the uncertainty of Z to include uncertainties of stellar parameters is given by
%
%       sigma_Z_with_propagatedUncertaintyOfStellarParameters = sqrt{ sigma_Z_without_propagatedUncertaintyOfStellarParameters^2 + sigma_Z_Rs^2 + sigma_Z_g^2 + sigma_Z_Teffective^2 }
%
%   where
%
%       sigma_Z_Rs         = e_Rs         * Z * sigma_Rs         / Rs
%
%       sigma_Z_g          = e_g          * Z * sigma_g          / g 
%
%       sigma_Z_Teffective = e_Teffective * Z * sigma_Teffective / Teffective
%
%
% Version date:  2014-January-23.
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
%  2014_January-23, JL:
%    Update uncertainties of starRadiusSolarRadii, planetRadiusEarthRadii, 
%    semiMajorAxisAu, equilibriumTempKelvin, effectiveStellarFlux.
%  2012-August-23, JL:
%    Initial release.
%
%=========================================================================================

starRadiusSolarRadiiValue         = transitModelObject.radius.value;
starRadiusSolarRadiiUncertainty   = transitModelObject.radius.uncertainty;
if ( isnan(starRadiusSolarRadiiUncertainty) || starRadiusSolarRadiiUncertainty<0 )
    starRadiusSolarRadiiUncertainty = 0;
end
if ( isnan(starRadiusSolarRadiiValue) || starRadiusSolarRadiiValue<=0 )
    starRadius_ratioUncertaintyToValue = 0;
else
    starRadius_ratioUncertaintyToValue = starRadiusSolarRadiiUncertainty / starRadiusSolarRadiiValue;
end

log10SurfaceGravityCmsValue         = transitModelObject.log10SurfaceGravity.value;
log10SurfaceGravityCmsUncertainty   = transitModelObject.log10SurfaceGravity.uncertainty;
gMksValue                           = 10^(log10SurfaceGravityCmsValue) * get_unit_conversion('cm2meter');
gMksUncertainty                     = gMksValue * log(10) * log10SurfaceGravityCmsUncertainty;
if ( isnan(gMksUncertainty) || gMksUncertainty<0 || isnan(gMksValue) || gMksValue<=0 )
    g_ratioUncertaintyToValue = 0;
else
    g_ratioUncertaintyToValue = gMksUncertainty / gMksValue;
end

effectiveTempKelvinValue         = transitModelObject.effectiveTemp.value;
effectiveTempKelvinUncertainty   = transitModelObject.effectiveTemp.uncertainty;
if ( isnan(effectiveTempKelvinUncertainty) || effectiveTempKelvinUncertainty<0 || isnan(effectiveTempKelvinValue) || effectiveTempKelvinValue<=0 )
    effectiveTemp_ratioUncertaintyToValue = 0;
else
    effectiveTemp_ratioUncertaintyToValue = effectiveTempKelvinUncertainty / effectiveTempKelvinValue; 
end


% Derived parameter: starRadiusSolarRadii

index                  = strcmp({modelParameterStructs.name}, 'starRadiusSolarRadii');
modelParameterStructs(index).uncertainty = starRadiusSolarRadiiUncertainty;


% Derived parameter: planetRadiusEarthRadii

index                  = strcmp({modelParameterStructs.name}, 'planetRadiusEarthRadii');
parameterValue         = modelParameterStructs(index).value;
parameterUncertainty   = modelParameterStructs(index).uncertainty;
propagatedUncertainty1 =        parameterValue * starRadius_ratioUncertaintyToValue;
modelParameterStructs(index).uncertainty = sqrt( parameterUncertainty^2 + propagatedUncertainty1^2 );


% Derived parameter: semiMajorAxisAu

index                  = strcmp({modelParameterStructs.name}, 'semiMajorAxisAu');
parameterValue         = modelParameterStructs(index).value;
parameterUncertainty   = modelParameterStructs(index).uncertainty;
propagatedUncertainty1 =  2/3 * parameterValue * starRadius_ratioUncertaintyToValue;
propagatedUncertainty2 =  1/3 * parameterValue * g_ratioUncertaintyToValue;
modelParameterStructs(index).uncertainty = sqrt( parameterUncertainty^2 + propagatedUncertainty1^2 + propagatedUncertainty2^2 );


% Derived parameter: equilibriumTemp

index                  = strcmp({modelParameterStructs.name}, 'equilibriumTempKelvin');
parameterValue         = modelParameterStructs(index).value;
parameterUncertainty   = modelParameterStructs(index).uncertainty;
propagatedUncertainty1 =  1/6 * parameterValue * starRadius_ratioUncertaintyToValue;
propagatedUncertainty2 = -1/6 * parameterValue * g_ratioUncertaintyToValue;
propagatedUncertainty3 =        parameterValue * effectiveTemp_ratioUncertaintyToValue;
modelParameterStructs(index).uncertainty = sqrt( parameterUncertainty^2 + propagatedUncertainty1^2 + propagatedUncertainty2^2 + propagatedUncertainty3^2);


% Derived parameter: effectiveStellarFlux

index                  = strcmp({modelParameterStructs.name}, 'effectiveStellarFlux');
parameterValue         = modelParameterStructs(index).value;
parameterUncertainty   = modelParameterStructs(index).uncertainty;
propagatedUncertainty1 =  2/3 * parameterValue * starRadius_ratioUncertaintyToValue;
propagatedUncertainty2 = -2/3 * parameterValue * g_ratioUncertaintyToValue;
propagatedUncertainty3 =  4   * parameterValue * effectiveTemp_ratioUncertaintyToValue;
modelParameterStructs(index).uncertainty = sqrt( parameterUncertainty^2 + propagatedUncertainty1^2 + propagatedUncertainty2^2 + propagatedUncertainty3^2);

return


