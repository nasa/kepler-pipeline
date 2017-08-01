function [calInputStruct, calTransformStruct, compressedData] = initialize_cal_pou_struct(calInputStruct)
% function [calInputStruct, calTransformStruct, compressedData] = initialize_cal_pou_struct(calInputStruct)
%
% This function initializes the CAL pou struct (errorPropStruct == calTransformStruct + comressedData) for each invocation of CAL.
% If this is the first invocation (firstCall = true) then an empty calTransformStruct and compressedData struct with the correct fields are
% returned and startVariableIndex in calInputStruct.pouModuleParametersStruct is set to 1. If it is any other invocation the structures are
% set up with the collateral calTransformStruct and compressedData and startVariableIndex is set to nCollateralVariables + 1 so the
% structure is set to recieve the next photometric variable (calibratedPixels#).
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

% start clock
tic;
metricsKey = metrics_interval_start;

% extract things from calInputs
pouParameterStruct  = calInputStruct.pouModuleParametersStruct;
localFilenames      = calInputStruct.localFilenames;
firstCall           = calInputStruct.firstCall;
pouEnabled          = pouParameterStruct.pouEnabled;
compressFlag        = pouParameterStruct.compressionEnabled;
cadenceThreshold    = calInputStruct.moduleParametersStruct.minCadencesForCompression;
nCadences           = length(calInputStruct.cadenceTimes.cadenceNumbers);

stateFilePath = calInputStruct.localFilenames.stateFilePath;


% don't compress POU struct if there are not enough cadences
if nCadences < cadenceThreshold
    if compressFlag
        compressFlag = false;
        calInputStruct.pouModuleParametersStruct.compressionEnabled = compressFlag;
        display(['CAL:cal_matlab_controller: Not enough cadences to compress POU struct.',...
            'Resetting module parameter pouParameterStruct.compressionEnabled --> false']);
    end
end


if pouEnabled
    if firstCall
        % create the calTransformStruct array - one entry for each cadence
        calTransformStruct = create_calTransformStruct(calInputStruct);
        compressedData = [];
        startVariableIndex = 1;
    else
        % load the collateral invocation pou struct for each photometric invocation
        load( [stateFilePath,localFilenames.pouRootFilename,'_0.mat'], 'calTransformStruct','compressedData');   
        
        % get the list of variables stored in calTransformStruct
        [~, variableList] = iserrorPropStructVariable(calTransformStruct(:,1),'');                          %#ok<NODEF>
        
%         % matlab-2007a version
%         [dummy, variableList] = iserrorPropStructVariable(calTransformStruct(:,1),'');                      %#ok<NODEF>
        
        % determine index of next empty spot
        startVariableIndex = length(variableList) + 1;
        
        if compressFlag
            calTransformStruct = seed_variable_names_in_calTransformStruct(calTransformStruct, calInputStruct );
        end        
        display_cal_status('CAL:cal_matlab_controller: Load POU struct from local file', 1);
    end    
    
    % attach startVariableIndex to pouParameterStruct
    calInputStruct.pouModuleParametersStruct.startVariableIndex = startVariableIndex;
else
    % initialize calTransformStruct and compressedData as empty
    calTransformStruct = [];
    compressedData = [];
    calInputStruct.pouModuleParametersStruct.startVariableIndex = -1;
end

display_cal_status('CAL:cal_matlab_controller: POU struct initialized',1);
metrics_interval_stop('cal.initialize_cal_pou_struct.execTimeMillis',metricsKey);
