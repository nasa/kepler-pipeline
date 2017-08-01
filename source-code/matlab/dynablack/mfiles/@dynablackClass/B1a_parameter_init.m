function [initInfo, inputs] = B1a_parameter_init( dynablackObject )
%
% function [initInfo, inputs] = B1a_parameter_init( dynablackObject )
%
% Initializes linear fit parameters for multi-cadence thermo-temporal fitting.
% Called by B1_main.
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


% extract parameters from dynablack object
maxB1CoeffCount     = dynablackObject.dynablackModuleParameters.maxB1CoeffCount;
maxA1CoeffCount     = dynablackObject.dynablackModuleParameters.maxA1CoeffCount;
numPredictorCoeffs  = dynablackObject.dynablackModuleParameters.numB1PredictorCoeffs;
numModelTypes       = dynablackObject.dynablackModuleParameters.numModelTypes;
includeStepsInModel = dynablackObject.dynablackModuleParameters.includeStepsInModel;
cadenceGapThreshold = dynablackObject.dynablackModuleParameters.cadenceGapThreshold;
cadenceNumbers      = dynablackObject.cadenceTimes.cadenceNumbers;
cadenceGaps         = dynablackObject.cadenceTimes.gapIndicators;
channel             = convert_from_module_output( dynablackObject.ccdModule, dynablackObject.ccdOutput );


% generate valid relative cadence list
relativeCadenceList = find(~cadenceGaps);

% locate steps and find indices which immediately preceed steps
if includeStepsInModel
    stepIdx = find( diff(cadenceNumbers(~cadenceGaps)) > cadenceGapThreshold );
else
    stepIdx = [];
end
numSteps = length(stepIdx);

% define inputs structure
inputs = struct( 'channel_list', channel, ...
                 'lc_list',relativeCadenceList);
% allocate space
coefficientModels = cell(1,numModelTypes);
tempColumnLocate = cell(1,numModelTypes);
timeColumnLocate = cell(1,numModelTypes);
stepColumnLocate = cell(1,numModelTypes);

% initialize constants
dataStart = 1;
dataEnd = length(relativeCadenceList);

% get conditioned temperature data
[times, temperatures] = condition_ancillary_data_for_dynablack( dynablackObject );

% parse temperature data to the unit of work as defined in the set-up
times = times(relativeCadenceList);
temperatures = temperatures(relativeCadenceList);

% build steps term
% optionally add steps at monthly breaks (gaps longer than cadenceGapThreshold long candences)
% steps are added to design matrix as a delta from the constant term
steps = zeros(dataEnd,numSteps);
for stepID = 1:numSteps    
    
    % stop adding steps when max coeffs is reached
    if stepID > maxB1CoeffCount - numPredictorCoeffs
        break;
    end
    
    beginIdx = stepIdx(stepID) + 1;
    
    if stepID == numSteps
        endIdx = dataEnd;
    else
        endIdx = stepIdx(stepID + 1);
    end
    
    steps(beginIdx:endIdx,stepID) = 1;
    
end

% build constant term
const = ones(dataEnd,1);

% build coefficients models - 1 through numModelTypes
% type 1
coefficientModels{1} = [const steps];
tempColumnLocate{1} = [];
timeColumnLocate{1} = [];
stepColumnLocate{1} = 2:(1 + numSteps);
% type 2
coefficientModels{2} = [const temperatures(:) steps];
tempColumnLocate{2} = 2;
timeColumnLocate{2} = [];
stepColumnLocate{2} = 3:(2 + numSteps);
% type 3
coefficientModels{3} = [const times(:) steps];
tempColumnLocate{3} = [];
timeColumnLocate{3} = 2;
stepColumnLocate{3} = 3:(2 + numSteps);
% type 4
coefficientModels{4} = [const temperatures(:) times(:) steps];
tempColumnLocate{4} = 2;
timeColumnLocate{4} = 3;
stepColumnLocate{4} = 4:(3 + numSteps);

% output structure
initInfo.coefficient_models   = coefficientModels;
initInfo.tempColumnLocate     = tempColumnLocate;
initInfo.timeColumnLocate     = timeColumnLocate;
initInfo.stepColumnLocate     = stepColumnLocate;
initInfo.data_start           = dataStart;
initInfo.data_end             = dataEnd;
initInfo.A1coeff_count_Max    = maxA1CoeffCount;
initInfo.model_type_count     = length(coefficientModels);
initInfo.max_B1coeffs         = maxB1CoeffCount;

