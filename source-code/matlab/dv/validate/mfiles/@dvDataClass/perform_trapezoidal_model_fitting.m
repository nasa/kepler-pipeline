function [trapezoidalModelFitData] = perform_trapezoidal_model_fitting(dvDataObject, trapezoidalModelFitData)
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

iTarget = trapezoidalModelFitData.iTarget;
iPlanet = trapezoidalModelFitData.iPlanet;

orbitalPeriodDays       = trapezoidalModelFitData.thresholdCrossingEvent.orbitalPeriodDays;
transitDurationDays     = trapezoidalModelFitData.thresholdCrossingEvent.transitDurationHours/24;
ratioDurationToPeriod   = transitDurationDays/orbitalPeriodDays;

phase        = mod(trapezoidalModelFitData.detrendOutputs.midTimestampsBkjd - trapezoidalModelFitData.detrendOutputs.timeZeroPoint, orbitalPeriodDays) ./ orbitalPeriodDays;
index        = phase > 0.5;
phase(index) = phase(index) - 1.0;

trapezoidalModelFitData.modelFittingParameters.transitSamplesPerCadence     = dvDataObject.trapezoidalFitConfigurationStruct.transitSamplesPerCadence;
trapezoidalModelFitData.modelFittingParameters.overSamplingFlag             = abs(phase) < ratioDurationToPeriod * 1.5;
transitFitRegion                                                            = dvDataObject.trapezoidalFitConfigurationStruct.transitFitRegion;
trapezoidalModelFitData.modelFittingParameters.fitDataFlag                  = abs(phase) < min([ratioDurationToPeriod*transitFitRegion; 0.25]);

maxDepth    = max( trapezoidalModelFitData.quarters.minDepthPpm(trapezoidalModelFitData.quarters.transitsFlag)./1.0e6 );

trapezoidalModelFitData.modelFittingParameters.physicalVariableNames   = {  'To',                          'Depth',            'BigT',                         'TRatio'                 };
trapezoidalModelFitData.modelFittingParameters.physicalVariableMins    = [ -transitDurationDays*1.5;       0.0;                0.5/24.0;                       0.0                      ];
trapezoidalModelFitData.modelFittingParameters.physicalVariableMaxs    = [  transitDurationDays*1.5;       maxDepth*5.0;       transitDurationDays*3.0;        1.0                      ];
trapezoidalModelFitData.modelFittingParameters.physicalVariableValues  = [  0.0;                           maxDepth;           transitDurationDays;            0.2                      ];

if sum(trapezoidalModelFitData.modelFittingParameters.fitDataFlag) < length(trapezoidalModelFitData.modelFittingParameters.physicalVariableValues)
    error('dv:performTrapezoidalModelFitting:noEnoughDataPointsForTrapezoidalFit', 'no enough data points for the trapezoidal fit');
end

if sum( isnan(trapezoidalModelFitData.detrendOutputs.newFluxValues) | ~isfinite(trapezoidalModelFitData.detrendOutputs.newFluxValues) ) > 0
    error('dv:performTrapezoidalModelFitting:NaN_in_detrendedFluxValues', 'NaNs/Infinite numbers found in the detrended flux values for trapezidal fit');
end

trapezoidalModelFitData.modelFittingParameters.boundedVariableValues   = boundedvals(trapezoidalModelFitData.modelFittingParameters.physicalVariableValues, ...
    trapezoidalModelFitData.modelFittingParameters.physicalVariableMaxs, trapezoidalModelFitData.modelFittingParameters.physicalVariableMins);

trapezoidalModelFitData.modelFittingParameters.minChiSquare            = length(trapezoidalModelFitData.detrendOutputs.newFluxValues) * 2000.0;

trapezoidalModelFitData.trapezoidalFitMinimized  = false;
trapezoidalModelFitData                          = iterative_trapezoidal_model_fitting(trapezoidalModelFitData, 10);

t0          = trapezoidalModelFitData.trapezoidalFitOutputs.bestFitParameters(1);
depth       = trapezoidalModelFitData.trapezoidalFitOutputs.bestFitParameters(2);
bigTDays    = trapezoidalModelFitData.trapezoidalFitOutputs.bestFitParameters(3);
TRatio      = trapezoidalModelFitData.trapezoidalFitOutputs.bestFitParameters(4);
littleTDays = TRatio*bigTDays;

trapezoidalModelFitData.trapezoidalFitOutputs.transitEpochBkjd                 = t0 + trapezoidalModelFitData.detrendOutputs.avarageEpochBkjd;
trapezoidalModelFitData.trapezoidalFitOutputs.transitDurationHours             = (bigTDays + littleTDays) * 24;
trapezoidalModelFitData.trapezoidalFitOutputs.transitIngressTimeHours          = littleTDays * 24;
trapezoidalModelFitData.trapezoidalFitOutputs.orbitalPeriodDays                = orbitalPeriodDays;
trapezoidalModelFitData.trapezoidalFitOutputs.transitDepthPpm                  = depth * 1e6;
trapezoidalModelFitData.trapezoidalFitOutputs.ratioPlanetRadiusToStarRadius    = sqrt( depth );

% trapezoidalModelFitData.trapezoidalFitOutputs.minImpactParameter               = sqrt( 1.0 - min([trapezoidalModelFitData.trapezoidalFitOutputs.ratioPlanetRadiusToStarRadius*bigTDays/littleTDays; 1.0]) );
% tau0                                                                           = sqrt(bigTDays*littleTDays/4.0/trapezoidalModelFitData.trapezoidalFitOutputs.ratioPlanetRadiusToStarRadius);
% trapezoidalModelFitData.trapezoidalFitOutputs.ratioSemiMajorAxisToStarRadius   = orbitalPeriodDays/2.0/pi/tau0;

minImpactParameter                                                             = sqrt( 1.0 - min([trapezoidalModelFitData.trapezoidalFitOutputs.ratioPlanetRadiusToStarRadius*bigTDays/littleTDays; 1.0]) );
if minImpactParameter < 0.1
    minImpactParameter = 0.1;
end
if minImpactParameter > 0.9
    minImpactParameter = 0.9;
end
trapezoidalModelFitData.trapezoidalFitOutputs.minImpactParameter               = minImpactParameter;
trapezoidalModelFitData.trapezoidalFitOutputs.ratioSemiMajorAxisToStarRadius   = sqrt(   ( (1 + trapezoidalModelFitData.trapezoidalFitOutputs.ratioPlanetRadiusToStarRadius)^2 - (minImpactParameter)^2 ) / ...
                                                                                         ( sin( pi * (bigTDays + littleTDays) / orbitalPeriodDays ) )^2                                                     ...
                                                                                       + (minImpactParameter)^2                                                                                             );
                                                                                   
if trapezoidalModelFitData.trapezoidalFitMinimized
    
    phase        = mod( ( trapezoidalModelFitData.detrendOutputs.midTimestampsBkjd - trapezoidalModelFitData.trapezoidalFitOutputs.transitEpochBkjd ), orbitalPeriodDays) ./ orbitalPeriodDays;
    index        = find( phase > 0.5 );
    phase(index) = phase(index) - 1.0;
    
    index        = find( abs(phase) <= trapezoidalModelFitData.trapezoidalFitOutputs.transitDurationHours/24/2/orbitalPeriodDays );
    if isempty(index)
        
        error('dv:performTrapezoidalModelFitting:noInTransitDataPointsForTrapezoidalFit', 'no in transit data points for the trapezoidal fit');
        
    else
        
        averageDepth = mean( 1 - trapezoidalModelFitData.detrendOutputs.newFluxValues(index) );
        
        if averageDepth < 0
            
            display(' ');
            display(['Warning: average transit depth is negative in the trapezoidal fit of target ' num2str(iTarget) ' planet candidate ' num2str(iPlanet) ' : averageDepth = ' num2str(averageDepth) '. Set to 0.']);
            display(' ');
            
            averageDepth = 0;
            
        end
        
        if averageDepth == 0 || trapezoidalModelFitData.detrendOutputs.madSigma == 0
            
            trapezoidalModelFitData.trapezoidalFitOutputs.averageDepth  = 0;
            trapezoidalModelFitData.trapezoidalFitOutputs.snr           = 0;
            
            if trapezoidalModelFitData.detrendOutputs.madSigma == 0
                
                display(' ');
                display(['Warning: detrendOutputs.madSigma of target ' num2str(iTarget) ' planet candidate ' num2str(iPlanet) ' is 0. Set averageDepth and snr to 0s.']);
                display(' ');
            
            end
            
        else
            
            trapezoidalModelFitData.trapezoidalFitOutputs.averageDepth  = averageDepth;
            trapezoidalModelFitData.trapezoidalFitOutputs.snr           = averageDepth / trapezoidalModelFitData.detrendOutputs.madSigma * sqrt( length(index) );
            
        end
        
    end
    
else
    
    trapezoidalModelFitData.trapezoidalFitOutputs.averageDepth  = -1;
    trapezoidalModelFitData.trapezoidalFitOutputs.snr           = -1;
    
end

return
