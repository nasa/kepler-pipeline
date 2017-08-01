function [ inputsStruct ] = cal_convert_92_data_to_93( inputsStruct )
% function [ inputsStruct ] = cal_convert_92_data_to_93( inputsStruct )
%
% This function converts a SOC 9.2 or prior CAL inputsStruct to one used in the SOC 9.3 build.
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

% update to 9.2 inputsStruct
inputsStruct = cal_convert_91_data_to_92(inputsStruct);

DEFAULT_QUARTER = 0;
DEFAULT_CAMPAIGN = 0;

% add module parameters 
if isfield(inputsStruct, 'moduleParametersStruct')
    moduleParametersStruct = inputsStruct.moduleParametersStruct;
    
    % add F/S flag enable parameters
    if ~isfield(moduleParametersStruct,'enableMmntmDmpFlag')
        moduleParametersStruct.enableMmntmDmpFlag = true;
    end
    
    if ~isfield(moduleParametersStruct,'enableSefiAccFlag')
        moduleParametersStruct.enableSefiAccFlag = true;
    end    
    
    if ~isfield(moduleParametersStruct,'enableSefiCadFlag')
        moduleParametersStruct.enableSefiCadFlag = true;
    end    
    
    if ~isfield(moduleParametersStruct,'enableLdeOosFlag')
        moduleParametersStruct.enableLdeOosFlag = true;
    end    
   
    if ~isfield(moduleParametersStruct,'enableLdeParErFlag')
        moduleParametersStruct.enableLdeParErFlag = true;
    end
    
    if ~isfield(moduleParametersStruct,'enableScrcErrFlag')
        moduleParametersStruct.enableScrcErrFlag = true;
    end
    
    % add bleeding columns map enable (K2) - default for nominal Kepler data processing
    if ~isfield(moduleParametersStruct,'enableSmearExcludeColumnMap')
        moduleParametersStruct.enableSmearExcludeColumnMap = true;
    end
    
    % add scene dependent row map enable (K2) - default for nominal Kepler data processing
    if ~isfield(moduleParametersStruct,'enableSceneDependentRowMap')
        moduleParametersStruct.enableSceneDependentRowMap = true;
    end
    
    % add 1D black coefficient overrides enable (K2) - default for nominal Kepler data processing
    if ~isfield(moduleParametersStruct,'enableBlackCoefficientOverrides')
        moduleParametersStruct.enableBlackCoefficientOverrides = true;
    end
    
    % add enableExcludeIndicators flag
    if ~isfield(moduleParametersStruct,'enableExcludeIndicators')
        moduleParametersStruct.enableExcludeIndicators = true;        
    end
    
    % add enableExcludePreserve flag
    if ~isfield(moduleParametersStruct,'enableExcludePreserve')
        moduleParametersStruct.enableExcludePreserve = true;        
    end    
    
    inputsStruct.moduleParametersStruct = moduleParametersStruct;
end

% add quarter number
if ~isfield(inputsStruct,'quarter')
    inputsStruct.quarter = DEFAULT_QUARTER;        
end

% add campaign number
if ~isfield(inputsStruct,'k2Campaign')
    inputsStruct.k2Campaign = DEFAULT_CAMPAIGN;        
end

% add emptyInputs flag
if ~isfield(inputsStruct, 'emptyInputs')
    inputsStruct.emptyInputs = false;
end

return;
