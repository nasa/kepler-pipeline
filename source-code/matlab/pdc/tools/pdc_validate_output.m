%*************************************************************************************************************
%% function [problemFields] = pdc_validate_output (outputsStruct)
%
% Checks the outputs struct and verifies that all outputs are withing established ranges and all fields are present.
%
% Inputs:
%   outputsStruct   -- [struct] The output struct to validate
%
% Outputs:
%   pdcValidateFieldsObject -- [pdcValidateFieldsClass]  List of problem Fields, their values and what's wrong with them.
%
%*************************************************************************************************************
% Checks the following fields in outputsStruct:
%
%   pdcOutputsStruct -- [struct] with the following fields:
%       .pdcVersion                         -- [float] e.g. 8.3. 9.1 etc...
%       .ccdModule   
%       .ccdOutput   
%       .cadenceType                        -- [char] {'LONG' | 'SHORT'}
%       .startCadence                       -- cadence index (NOT MJD)
%       .endCadence                         -- cadence index (NOT MJD)
%       .alerts(:)                          -- [struct array] all alert messages from PDC run (These are usefule, don't ignore them!)
%           .time                               [double]  alert time, MJD
%           .severity                           [string]  alert severity ('error' or 'warning')
%           .message                            [string]  alert message
%       .pdcBlobFileName                    -- [char] name to file that stores LC data for use with SC PDC
%       .cbvBlobFileName                    -- [char] name to file that store basis vectors and priors for use with DV and special PDC runs
%       .targetResultsStruct(:)             -- [struct array] target specific results
%           .keplerID                       -- [int]
%           .correctedFluxTimeSeries
%               .values
%               .uncertainties
%               .gapIndicators
%               .filledIndices              -- [int array] ***0-BASED***
%           .harmonicFreeCorrectedFluxTimeSeries
%               .values
%               .uncertainties
%               .gapIndicators
%               .filledIndices              -- [int array] ***0-BASED***
%           .outliers
%               .indices                    -- [int array] ***0-BASED***
%               .values
%               .uncertainties
%           .harmonicFreeOutliers
%               .indices                    -- [int array] ***0-BASED***
%               .values
%               .uncertainties
%           .discontinuityIndices           -- [int array] ***0-BASED***
%           .pdcProcessingStruct
%               .pdcMethod                  -- [char] {'multiscaleMap' | 'regularMap' | 'leastSquares' | ...}
%               .numDiscontinutiesDetected  -- [int]
%               .numDiscontinutiesRemoved   -- [int]
%               .harmonicsFitted            -- [logical]
%               .harmonicsRestored          -- [logical]
%               .targetVariability          -- [double]
%               .bands                      -- [struct array] One for each MAP band processed for this target
%                   .fitType                -- [char] {'none' | 'prior' | 'robust' | ...}
%                   .priorWeight            -- [double]
%                   .priorGoodness          -- [double]
%           .pdcGoodnessMetric
%               .total                      -- [GoodnessStruct]
%                   .value                  -- [double]
%                   .percentile             -- [double] ranking WRT all non-custom targets
%               .correlation                -- [GoodnessStruct]
%               .deltaVariability           -- [GoodnessStruct]
%               .introducedNoise            -- [GoodnessStruct]
%               .earthPointRemoval          -- [GoodnessStruct]
%
%*************************************************************************************************************
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

function [pdcValidateFieldsObject] = pdc_validate_output (outputsStruct)

% Single fields in outputsStruct

nCadences = outputsStruct.endCadence - outputsStruct.startCadence + 1;

% Top level
canonicalOutputsStruct.pdcVersion       = pdcValidRangeClass(0.0, 10.0);
canonicalOutputsStruct.ccdModule        = pdcValidRangeClass(int32(-1),    int32(24), 'mustBeScalar');
canonicalOutputsStruct.ccdOutput        = pdcValidRangeClass(int32(-1),    int32(4), 'mustBeScalar');
canonicalOutputsStruct.cadenceType      = pdcValidRangeClass(0.0,  0.0, 'isChar', 'charOptions', {'LONG', 'SHORT'}, 'mustBeScalar');
canonicalOutputsStruct.startCadence     = pdcValidRangeClass(int32(568),    int32(1e7), 'mustBeScalar');
canonicalOutputsStruct.endCadence       = pdcValidRangeClass(int32(568),    int32(1e7), 'mustBeScalar');
% This field "pdcBlobFileName" should not really be here. It's in PDC but not worth merging a change to release to fix since it has not real impact.
canonicalOutputsStruct.pdcBlobFileName  = '';

% Alerts
canonicalOutputsStruct.alerts.time     = pdcValidRangeClass(54500, 70000, 'mustBeScalar');
canonicalOutputsStruct.alerts.severity = pdcValidRangeClass(    0,     0, 'isChar', 'charOptions', {'error' , 'warning'}, 'mustBeScalar');
canonicalOutputsStruct.alerts.message  = pdcValidRangeClass(    0,     0, 'isChar', 'mustBeScalar');

% Alerts can be empty. So, account for this possibility
if (isempty(outputsStruct.alerts))
    canonicalOutputsStruct.alerts = [];
end

canonicalOutputsStruct.channelDataStruct.ccdModule  = pdcValidRangeClass(int32(-1),    int32(24), 'mustBeScalar');
canonicalOutputsStruct.channelDataStruct.ccdOutput  = pdcValidRangeClass(int32(-1),    int32(4), 'mustBeScalar');
canonicalOutputsStruct.channelDataStruct.pdcBlobFileName  = pdcValidRangeClass(0.0,  0.0, 'isChar', 'canBeEmpty');
canonicalOutputsStruct.channelDataStruct.cbvBlobFileName  = pdcValidRangeClass(0.0,  0.0, 'isChar', 'canBeEmpty');

%***
% thrusterFiringDataStruct.
% note: The flags really aught to be logicals but they we coded up as doubles, except for 'possibleThrusterActivityIndicators', which is logical!
% This is not up to JCS's coding standards, he didn't write the thruster firing code!
nThrusters = 8;
maxThrusterDuration = 60; % No thruster to ever firing longer than 1 minute? God, I hope not!
canonicalOutputsStruct.thrusterFiringDataStruct.thrusterFiringFlag      = pdcValidRangeClass(0, 1.0,  'mustBeOfLength', [nCadences,nThrusters]);
canonicalOutputsStruct.thrusterFiringDataStruct.thrusterFiringDuration  = pdcValidRangeClass(0, maxThrusterDuration,  'mustBeOfLength', [nCadences,nThrusters]);
canonicalOutputsStruct.thrusterFiringDataStruct.fineTweak1Flag          = pdcValidRangeClass(0, 1.0,  'mustBeOfLength', [nCadences,1]);
canonicalOutputsStruct.thrusterFiringDataStruct.fineTweak1Duration      = pdcValidRangeClass(0, maxThrusterDuration,  'mustBeOfLength', [nCadences,1]);
canonicalOutputsStruct.thrusterFiringDataStruct.fineTweak2Flag          = pdcValidRangeClass(0, 1.0,  'mustBeOfLength', [nCadences,1]);
canonicalOutputsStruct.thrusterFiringDataStruct.fineTweak2Duration      = pdcValidRangeClass(0, maxThrusterDuration,  'mustBeOfLength', [nCadences,1]);
canonicalOutputsStruct.thrusterFiringDataStruct.mamaBearTweak1Flag      = pdcValidRangeClass(0, 1.0,  'mustBeOfLength', [nCadences,1]);
canonicalOutputsStruct.thrusterFiringDataStruct.mamaBearTweak1Duration  = pdcValidRangeClass(0, maxThrusterDuration,  'mustBeOfLength', [nCadences,1]);
canonicalOutputsStruct.thrusterFiringDataStruct.mamaBearTweak2Flag      = pdcValidRangeClass(0, 1.0,  'mustBeOfLength', [nCadences,1]);
canonicalOutputsStruct.thrusterFiringDataStruct.mamaBearTweak2Duration  = pdcValidRangeClass(0, maxThrusterDuration,  'mustBeOfLength', [nCadences,1]);
canonicalOutputsStruct.thrusterFiringDataStruct.resatTweakFlag          = pdcValidRangeClass(0, 1.0,  'mustBeOfLength', [nCadences,1]);
canonicalOutputsStruct.thrusterFiringDataStruct.resatTweakDuration      = pdcValidRangeClass(0, maxThrusterDuration,  'mustBeOfLength', [nCadences,1]);
canonicalOutputsStruct.thrusterFiringDataStruct.unknownTweakFlag        = pdcValidRangeClass(0, 1.0,  'mustBeOfLength', [nCadences,1]);
canonicalOutputsStruct.thrusterFiringDataStruct.possibleThrusterActivityIndicators = pdcValidRangeClass(0, 0, 'isLogical', 'mustBeOfLength', [nCadences,1]);

%***
% targetResultsStruct
canonicalOutputsStruct.targetResultsStruct.keplerId = pdcValidRangeClass(int32(1),    int32(1e9), 'mustBeScalar');

% Allow for negative numbers since PA can pass negative numbers to PDC.
canonicalOutputsStruct.targetResultsStruct.correctedFluxTimeSeries.values        = pdcValidRangeClass(  -1e13,    1.0e13,            'mustBeOfLength', [nCadences,1]);
canonicalOutputsStruct.targetResultsStruct.correctedFluxTimeSeries.gapIndicators = pdcValidRangeClass(  0,    0, 'isLogical',    'mustBeOfLength', [nCadences,1]);
canonicalOutputsStruct.targetResultsStruct.correctedFluxTimeSeries.uncertainties = pdcValidRangeClass(  -1e8,    1.0e8,             'mustBeOfLength', [nCadences,1]);
canonicalOutputsStruct.targetResultsStruct.correctedFluxTimeSeries.filledIndices = pdcValidRangeClass(int32(0), int32(1e7), 'canBeEmpty');

canonicalOutputsStruct.targetResultsStruct.harmonicFreeCorrectedFluxTimeSeries.values        = pdcValidRangeClass(  -1e13,    1.0e13,            'mustBeOfLength', [nCadences,1]);
canonicalOutputsStruct.targetResultsStruct.harmonicFreeCorrectedFluxTimeSeries.gapIndicators = pdcValidRangeClass(  0,    0, 'isLogical',    'mustBeOfLength', [nCadences,1]);
canonicalOutputsStruct.targetResultsStruct.harmonicFreeCorrectedFluxTimeSeries.uncertainties = pdcValidRangeClass(  -1e8,    1.0e8,             'mustBeOfLength', [nCadences,1]);
canonicalOutputsStruct.targetResultsStruct.harmonicFreeCorrectedFluxTimeSeries.filledIndices = pdcValidRangeClass(int32(0), int32(1e7), 'canBeEmpty');

canonicalOutputsStruct.targetResultsStruct.outliers.indices       = pdcValidRangeClass(0, 1e7,  'canBeEmpty');
canonicalOutputsStruct.targetResultsStruct.outliers.values        = pdcValidRangeClass(-1e12, 1e13, 'canBeEmpty');
canonicalOutputsStruct.targetResultsStruct.outliers.uncertainties = pdcValidRangeClass(-1e7, 1e7,  'canBeEmpty');

canonicalOutputsStruct.targetResultsStruct.harmonicFreeOutliers.indices       = pdcValidRangeClass(0, 1e7,  'canBeEmpty');
canonicalOutputsStruct.targetResultsStruct.harmonicFreeOutliers.values        = pdcValidRangeClass(-1e13, 1e13, 'canBeEmpty');
canonicalOutputsStruct.targetResultsStruct.harmonicFreeOutliers.uncertainties = pdcValidRangeClass(-1e7, 1e7,  'canBeEmpty');

canonicalOutputsStruct.targetResultsStruct.discontinuityIndices = pdcValidRangeClass(0, 1e7, 'canBeEmpty');

validPdcMethods = {'noFit', 'robust', 'reducedRobust', 'msReducedRobust', 'MAP', 'msMAP', 'quickMAP'};
canonicalOutputsStruct.targetResultsStruct.pdcProcessingStruct.pdcMethod = pdcValidRangeClass(0, 0, 'isChar', 'charOptions', validPdcMethods);
canonicalOutputsStruct.targetResultsStruct.pdcProcessingStruct.numDiscontinuitiesDetected = pdcValidRangeClass(int32(0), int32(1e2), 'canBeEmpty');
canonicalOutputsStruct.targetResultsStruct.pdcProcessingStruct.numDiscontinuitiesRemoved  = pdcValidRangeClass(0, 1e2, 'canBeEmpty');
canonicalOutputsStruct.targetResultsStruct.pdcProcessingStruct.harmonicsFitted     = pdcValidRangeClass(0, 0, 'isLogical', 'mustBeScalar');
canonicalOutputsStruct.targetResultsStruct.pdcProcessingStruct.harmonicsRestored   = pdcValidRangeClass(0, 0, 'isLogical', 'mustBeScalar');
canonicalOutputsStruct.targetResultsStruct.pdcProcessingStruct.targetVariability   = pdcValidRangeClass(0, 1e4, 'mustBeScalar');
validFitTypes = {'prior', 'robust', 'reducedRobust', 'map', 'quickMap', 'none'};
canonicalOutputsStruct.targetResultsStruct.pdcProcessingStruct.bands.fitType       = pdcValidRangeClass(0, 0, 'isChar', 'charOptions', validFitTypes);
canonicalOutputsStruct.targetResultsStruct.pdcProcessingStruct.bands.priorWeight   = pdcValidRangeClass(-1, 1e7, 'mustBeScalar');
canonicalOutputsStruct.targetResultsStruct.pdcProcessingStruct.bands.priorGoodness = pdcValidRangeClass(-1, 1e7, 'mustBeScalar');


canonicalOutputsStruct.targetResultsStruct.pdcGoodnessMetric.total.value            = pdcValidRangeClass(0, 1e0, 'mustBeScalar');
canonicalOutputsStruct.targetResultsStruct.pdcGoodnessMetric.total.percentile       = pdcValidRangeClass(0, 1e2, 'mustBeScalar');
canonicalOutputsStruct.targetResultsStruct.pdcGoodnessMetric.correlation.value      = pdcValidRangeClass(0, 1e0, 'mustBeScalar');
canonicalOutputsStruct.targetResultsStruct.pdcGoodnessMetric.correlation.percentile = pdcValidRangeClass(0, 1e2, 'mustBeScalar');
canonicalOutputsStruct.targetResultsStruct.pdcGoodnessMetric.deltaVariability.value       = pdcValidRangeClass(0, 1e0, 'mustBeScalar');
canonicalOutputsStruct.targetResultsStruct.pdcGoodnessMetric.deltaVariability.percentile  = pdcValidRangeClass(0, 1e2, 'mustBeScalar');
canonicalOutputsStruct.targetResultsStruct.pdcGoodnessMetric.introducedNoise.value        = pdcValidRangeClass(0, 1e0, 'mustBeScalar');
canonicalOutputsStruct.targetResultsStruct.pdcGoodnessMetric.introducedNoise.percentile   = pdcValidRangeClass(0, 1e2, 'mustBeScalar');
canonicalOutputsStruct.targetResultsStruct.pdcGoodnessMetric.earthPointRemoval.value      = pdcValidRangeClass(0, 1e0, 'mustBeScalar', 'canBeNan');
canonicalOutputsStruct.targetResultsStruct.pdcGoodnessMetric.earthPointRemoval.percentile = pdcValidRangeClass(0, 1e2, 'mustBeScalar', 'canBeNan');
canonicalOutputsStruct.targetResultsStruct.pdcGoodnessMetric.spikeRemoval.value         = pdcValidRangeClass(0, 1e0, 'mustBeScalar');
canonicalOutputsStruct.targetResultsStruct.pdcGoodnessMetric.spikeRemoval.percentile    = pdcValidRangeClass(0, 1e2, 'mustBeScalar');
% There is a bug in the Rolltweak goodness, it can be very negative!
canonicalOutputsStruct.targetResultsStruct.pdcGoodnessMetric.rollTweak.value         = pdcValidRangeClass(-1e5, 1e0, 'mustBeScalar');
canonicalOutputsStruct.targetResultsStruct.pdcGoodnessMetric.rollTweak.percentile    = pdcValidRangeClass(0, 1e2, 'mustBeScalar');

canonicalOutputsStruct.targetResultsStruct.pdcGoodnessMetric.cdpp.value                 = pdcValidRangeClass(0, 1e12, 'mustBeScalar');
canonicalOutputsStruct.targetResultsStruct.pdcGoodnessMetric.cdpp.percentile            = pdcValidRangeClass(0, 1e2, 'mustBeScalar');
canonicalOutputsStruct.targetResultsStruct.pdcGoodnessMetric.kepstddev.value                 = pdcValidRangeClass(0, 1e12, 'mustBeScalar');
canonicalOutputsStruct.targetResultsStruct.pdcGoodnessMetric.kepstddev.percentile            = pdcValidRangeClass(0, 1e2, 'mustBeScalar');


display('Validating outputsStruct...');

pdcValidateFieldsObject = pdcValidateFieldsClass ('outputsStruct', canonicalOutputsStruct);
pdcValidateFieldsObject.display_problem_fields(10);

end
