function [dvResultsStruct] = fill_trapezoidal_fit_struct(dvDataObject, dvResultsStruct, trapezoidalModelFitData)
%
% This function fills in the trapezoidalFit struct of the planetResultsStruct
%
%
% Version date:  2014-September-02.
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
%    2014-September-02, JL:
%        Set default value to be 0 and default uncertainty to be -1
%    2014-August-20, JL:
%        Initial release.
%


iTarget                 = trapezoidalModelFitData.iTarget;
iPlanet                 = trapezoidalModelFitData.iPlanet;
keplerId                = trapezoidalModelFitData.keplerId; 
fittedFlag              = trapezoidalModelFitData.trapezoidalFitMinimized;

epochOffsetPeriods      = 0;
transitEpochBkjd        = trapezoidalModelFitData.trapezoidalFitOutputs.transitEpochBkjd;
orbitalPeriodDays       = trapezoidalModelFitData.trapezoidalFitOutputs.orbitalPeriodDays;
bufKeplerIds            = [dvDataObject.barycentricCadenceTimes.keplerId];
while (transitEpochBkjd + epochOffsetPeriods*orbitalPeriodDays) < dvDataObject.barycentricCadenceTimes(keplerId == bufKeplerIds).startTimestamps(1)
    epochOffsetPeriods  = epochOffsetPeriods + 1;
end
transitEpochBkjd        = transitEpochBkjd + epochOffsetPeriods*orbitalPeriodDays;

trapezoidalFit          = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).trapezoidalFit;

modelParameter          = struct('name', [], 'value', 0, 'uncertainty', -1, 'fitted', false) ;

legalParameterNames     = get_planet_model_legal_fields('all');
nParameters             = length(legalParameterNames);
modelParameters         = repmat(modelParameter, 1, nParameters);
for i=1:nParameters
    modelParameters(i).name = legalParameterNames{i};
end

modelParameterNames = {modelParameters.name};

index = strcmp(modelParameterNames, 'transitEpochBkjd');
modelParameters(index).value = transitEpochBkjd;
modelParameters(index).fitted = fittedFlag;

index = strcmp(modelParameterNames, 'transitDepthPpm');
modelParameters(index).value = trapezoidalModelFitData.trapezoidalFitOutputs.transitDepthPpm;
modelParameters(index).fitted = fittedFlag;

index = strcmp(modelParameterNames, 'transitDurationHours');
modelParameters(index).value = trapezoidalModelFitData.trapezoidalFitOutputs.transitDurationHours;
modelParameters(index).fitted = fittedFlag;

index = strcmp(modelParameterNames, 'transitIngressTimeHours');
modelParameters(index).value = trapezoidalModelFitData.trapezoidalFitOutputs.transitIngressTimeHours;
modelParameters(index).fitted = fittedFlag;

index = strcmp(modelParameterNames, 'orbitalPeriodDays');
modelParameters(index).value = orbitalPeriodDays;


index = strcmp(modelParameterNames, 'minImpactParameter');
modelParameters(index).value = trapezoidalModelFitData.trapezoidalFitOutputs.minImpactParameter;

index = strcmp(modelParameterNames, 'ratioPlanetRadiusToStarRadius');
modelParameters(index).value = trapezoidalModelFitData.trapezoidalFitOutputs.ratioPlanetRadiusToStarRadius;

index = strcmp(modelParameterNames, 'ratioSemiMajorAxisToStarRadius');
modelParameters(index).value = trapezoidalModelFitData.trapezoidalFitOutputs.ratioSemiMajorAxisToStarRadius;


index = strcmp(modelParameterNames, 'eccentricity');
modelParameters(index).value = 0;

index = strcmp(modelParameterNames, 'longitudeOfPeriDegrees');
modelParameters(index).value = 0;

index = strcmp(modelParameterNames, 'starRadiusSolarRadii');
modelParameters(index).value = dvDataObject.targetStruct(iTarget).radius.value;


trapezoidalFit.modelFitSnr              = trapezoidalModelFitData.trapezoidalFitOutputs.snr;
trapezoidalFit.modelChiSquare           = trapezoidalModelFitData.trapezoidalFitOutputs.minChiSquare;
trapezoidalFit.modelDegreesOfFreedom    = trapezoidalModelFitData.trapezoidalFitOutputs.degreesOfFreedom;
trapezoidalFit.fullConvergence          = trapezoidalModelFitData.trapezoidalFitMinimized;
trapezoidalFit.modelParameters          = modelParameters;


dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).trapezoidalFit  = trapezoidalFit;

return
