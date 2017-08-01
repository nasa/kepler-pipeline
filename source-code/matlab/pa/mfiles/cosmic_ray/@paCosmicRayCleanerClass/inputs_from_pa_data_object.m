function inputStruct = inputs_from_pa_data_object(paDataObject, motionPolyStruct)
%**************************************************************************
% function inputStruct = ...
%     inputs_from_pa_data_object(paDataObject, motionPolyStruct)
%**************************************************************************
% Convert a paDataClass object to a valid cosmicRayInputStruct.
%
%**************************************************************************
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
    paDataStruct = struct(paDataObject);
    inputStruct  = struct;
    
    % Are we processing K2 data?
    processingK2Data = paDataStruct.cadenceTimes.startTimestamps(1) > ...
        paDataStruct.fcConstants.KEPLER_END_OF_MISSION_MJD;

    % If motion polynomials were not provided as a separate argument to
    % this fucntion, check the paDataStruct and use them if they exist. If
    % no motion polynomials are available, assign the empty array to
    % motionPolyStruct.
    if ~exist('motionPolyStruct', 'var')
        if isfield(paDataStruct, 'motionPolyStruct') ...
            && ~isempty(paDataStruct.motionPolyStruct)
            motionPolyStruct = paDataStruct.motionPolyStruct;
        else
            motionPolyStruct = [];
        end
    end
    
    % Extract parameters requiring no manipulation.
    inputStruct.cadenceTimes = paDataStruct.cadenceTimes;
    inputStruct.cadenceType  = paDataStruct.cadenceType;
    inputStruct.debugLevel   = paDataStruct.paConfigurationStruct.debugLevel;
    inputStruct.params       = paDataStruct.cosmicRayConfigurationStruct;
    inputStruct.params.harmonicsIdentificationConfigurationStruct ...
        = paDataStruct.harmonicsIdentificationConfigurationStruct;
    inputStruct.params.gapFillConfigurationStruct ...
        = paDataStruct.gapFillConfigurationStruct;
    
    % Assemble the target array and set the target type.
    if ~isempty(paDataStruct.targetStarDataStruct)
        inputStruct.targetType      = 'stellar';
        inputStruct.targetArray      = paDataStruct.targetStarDataStruct;
    elseif ~isempty(paDataStruct.backgroundDataStruct)
        inputStruct.targetType      = 'background';
        inputStruct.targetArray ...
            = paCosmicRayCleanerClass.assemble_background_targets(...
                  paDataStruct.backgroundDataStruct);
    else
        error('No valid targets.');            
    end

    
    % Derive motion and focus time series if motion polynomials
    % are available. Don't use motion information if processing
    % short cadence. 
    if ~isempty(motionPolyStruct) ...
       && strcmpi(inputStruct.cadenceType, 'long')
   
        inputStruct.targetArray = ...
            fill_missing_target_ra_dec(...
                inputStruct.targetArray, ...
                motionPolyStruct, ...
                paDataStruct.fcConstants, ...
                processingK2Data ...
        );
          
        [rowPositionMat, colPositionMat] = ...
            paCosmicRayCleanerClass.derive_motion_time_series_matrices( ...
                inputStruct.targetArray, ...
                motionPolyStruct ...
        );
    
        [focusMat] = ...
            paCosmicRayCleanerClass.derive_focus_time_series_matrix( ...
                inputStruct.targetArray, ...
                motionPolyStruct ...
        );                

        inputStruct.ancillary = {rowPositionMat, colPositionMat, focusMat};
        inputStruct.ancillaryLabels = ...
            {'rowPositionMat', 'colPositionMat', 'focusMat'};
    else
        inputStruct.ancillary       = {};
        inputStruct.ancillaryLabels = {};
    end   
end

%********************************** EOF ***********************************