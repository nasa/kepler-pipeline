function [ inputsStruct ] = cal_convert_91_data_to_92( inputsStruct )
% function [ inputsStruct ] = cal_convert_91_data_to_92( inputsStruct )
%
% This function converts a SOC 9.1 or prior CAL inputsStruct to one used in the SOC 9.2 build.
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

% update to 9.1 inputsStruct
inputsStruct = cal_convert_90_data_to_91(inputsStruct);

% add module parameters 
if isfield(inputsStruct, 'moduleParametersStruct')
    moduleParametersStruct = inputsStruct.moduleParametersStruct;
    
    % add enableLcInformSmear
    if ~isfield(moduleParametersStruct,'enableLcInformSmear')
        moduleParametersStruct.enableLcInformSmear = false;
    end
    
    % add enableFfiInform
    if ~isfield(moduleParametersStruct,'enableFfiInform')
        moduleParametersStruct.enableFfiInform = false;
    end
    
    % add enableCoarsePointProcessing    
    if ~isfield(moduleParametersStruct,'enableCoarsePointProcessing')
        moduleParametersStruct.enableCoarsePointProcessing = false;
    end    
    
    inputsStruct.moduleParametersStruct = moduleParametersStruct;
end

% add smearBlobs field
if ~isfield(inputsStruct, 'smearBlobs')
    
    inputsStruct.smearBlobs = struct('blobIndices',[],...
                                     'gapIndicators',[],...
                                     'blobFilenames',[],...
                                     'startCadence',-1,...
                                     'endCadence',-1);
end

% add ffis field to inputs
if ~isfield(inputsStruct, 'ffis')
    inputsStruct.ffis = [];
end


%----------------------------------------------------------------------
% Add cosmic ray cleaning parameters, if necessary.
%----------------------------------------------------------------------

% Set verbosity of assert_field()
verbosity = false; 

% Create config struct harmonicsIdentificationConfigurationStruct if it
% doesn't exist.
if ~isfield(inputsStruct,'harmonicsIdentificationConfigurationStruct')
    inputsStruct.harmonicsIdentificationConfigurationStruct = struct();
end

% Insert fields and default values into
% harmonicsIdentificationConfigurationStruct, if necessary.
inputsStruct.harmonicsIdentificationConfigurationStruct = ...
    assert_field(inputsStruct.harmonicsIdentificationConfigurationStruct, ...
    'falseDetectionProbabilityForTimeSeries', 0.0010, verbosity);
inputsStruct.harmonicsIdentificationConfigurationStruct = ...
    assert_field(inputsStruct.harmonicsIdentificationConfigurationStruct, ...
    'maxHarmonicComponents', 25, verbosity);
inputsStruct.harmonicsIdentificationConfigurationStruct = ...
    assert_field(inputsStruct.harmonicsIdentificationConfigurationStruct, ...
    'medianWindowLengthForPeriodogramSmoothing', 47, verbosity);
inputsStruct.harmonicsIdentificationConfigurationStruct = ...
    assert_field(inputsStruct.harmonicsIdentificationConfigurationStruct, ...
    'medianWindowLengthForTimeSeriesSmoothing', 21, verbosity);
inputsStruct.harmonicsIdentificationConfigurationStruct = ...
    assert_field(inputsStruct.harmonicsIdentificationConfigurationStruct, ...
    'minHarmonicSeparationInBins', 25, verbosity);
inputsStruct.harmonicsIdentificationConfigurationStruct = ...
    assert_field(inputsStruct.harmonicsIdentificationConfigurationStruct, ...
    'movingAverageWindowLength', 47, verbosity);
inputsStruct.harmonicsIdentificationConfigurationStruct = ...
    assert_field(inputsStruct.harmonicsIdentificationConfigurationStruct, ...
    'timeOutInMinutes', 2.5000, verbosity);

% Create config struct gapFillConfigurationStruct if it doesn't exist.
if ~isfield(inputsStruct,'gapFillConfigurationStruct')
    inputsStruct.gapFillConfigurationStruct = struct();
end

% Insert fields and default values into gapFillConfigurationStruct,
% if necessary. Note that older versions of gapFillConfigurationStruct may
% be missing some fields required by the 8.3 gap filler.
inputsStruct.gapFillConfigurationStruct = ...
    assert_field(inputsStruct.gapFillConfigurationStruct, ...
    'madXFactor', 10, verbosity);
inputsStruct.gapFillConfigurationStruct = ...
    assert_field(inputsStruct.gapFillConfigurationStruct, ...
    'maxGiantTransitDurationInHours', 72, verbosity);
inputsStruct.gapFillConfigurationStruct = ...
    assert_field(inputsStruct.gapFillConfigurationStruct, ...
    'maxDetrendPolyOrder', 25, verbosity);
inputsStruct.gapFillConfigurationStruct = ...
    assert_field(inputsStruct.gapFillConfigurationStruct, ...
    'maxArOrderLimit', 25, verbosity);
inputsStruct.gapFillConfigurationStruct = ...
    assert_field(inputsStruct.gapFillConfigurationStruct, ...
    'maxCorrelationWindowXFactor', 5, verbosity);
inputsStruct.gapFillConfigurationStruct = ...
    assert_field(inputsStruct.gapFillConfigurationStruct, ...
    'gapFillModeIsAddBackPredictionError', true, verbosity);
inputsStruct.gapFillConfigurationStruct = ...
    assert_field(inputsStruct.gapFillConfigurationStruct, ...
    'waveletFamily', 'daub', verbosity);
inputsStruct.gapFillConfigurationStruct = ...
    assert_field(inputsStruct.gapFillConfigurationStruct, ...
    'waveletFilterLength', 12, verbosity);
inputsStruct.gapFillConfigurationStruct = ...
    assert_field(inputsStruct.gapFillConfigurationStruct, ...
    'giantTransitPolyFitChunkLengthInHours', 72, verbosity);
inputsStruct.gapFillConfigurationStruct = ...
    assert_field(inputsStruct.gapFillConfigurationStruct, ...
    'removeEclipsingBinariesOnList', true, verbosity);
inputsStruct.gapFillConfigurationStruct = ...
    assert_field(inputsStruct.gapFillConfigurationStruct, ...
    'arAutoCorrelationThreshold', 0.0500, verbosity);
inputsStruct.gapFillConfigurationStruct = ...
    assert_field(inputsStruct.gapFillConfigurationStruct, ...
    'cadenceDurationInMinutes', 30, verbosity);


% Insert fields and default values into cosmicRayParametersStruct,
% if necessary. 
inputsStruct.cosmicRayParametersStruct = ...
    assert_field(inputsStruct.cosmicRayParametersStruct, ...
    'gapLengthThreshold', 10, verbosity);
inputsStruct.cosmicRayParametersStruct = ...
    assert_field(inputsStruct.cosmicRayParametersStruct, ...
    'longMedianFilterLength', 49, verbosity);
inputsStruct.cosmicRayParametersStruct = ...
    assert_field(inputsStruct.cosmicRayParametersStruct, ...
    'shortMedianFilterLength', 3, verbosity);
inputsStruct.cosmicRayParametersStruct = ...
    assert_field(inputsStruct.cosmicRayParametersStruct, ...
    'arOrder', 50, verbosity);
inputsStruct.cosmicRayParametersStruct = ...
    assert_field(inputsStruct.cosmicRayParametersStruct, ...
    'detectionThreshold', 4, verbosity);
inputsStruct.cosmicRayParametersStruct = ...
    assert_field(inputsStruct.cosmicRayParametersStruct, ...
    'cosmicRayCleaningMethod', 'ar', verbosity);


return;







