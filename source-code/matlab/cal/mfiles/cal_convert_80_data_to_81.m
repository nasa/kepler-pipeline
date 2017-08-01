function [ inputsStruct ] = cal_convert_80_data_to_81( inputsStruct )
% function [ inputsStruct ] = cal_convert_80_data_to_81( inputsStruct )
%
% This function converts a SOC 8.0 or prior CAL inputsStruct to one used in the SOC 8.1 build.
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

% update to 8.0 inputsStruct
inputsStruct = cal_convert_70_data_to_80(inputsStruct);

% update black correction algorith flags to enumeration
if ~isfield(inputsStruct.moduleParametersStruct,'blackAlgorithm')
    
    moduleParametersStruct = inputsStruct.moduleParametersStruct;
    
    if isfield(moduleParametersStruct,'performExpLc1DblackFit') &&...
        isfield(moduleParametersStruct,'performExpSc1DblackFit') &&...
        isfield(moduleParametersStruct,'dynamic2DBlackEnabled')
        
        performExpLc1DblackFit = moduleParametersStruct.performExpLc1DblackFit;
        performExpSc1DblackFit = moduleParametersStruct.performExpSc1DblackFit;
        dynamic2DBlackEnabled = moduleParametersStruct.dynamic2DBlackEnabled;

        if performExpLc1DblackFit || performExpSc1DblackFit
            blackAlgorithm = 'exponentialOneDBlack';
        end

        if dynamic2DBlackEnabled
            blackAlgorithm = 'dynablack';
        end

        if ~dynamic2DBlackEnabled && ~performExpLc1DblackFit && ~performExpSc1DblackFit
            blackAlgorithm = 'polynomialOneDBlack';
        end

        moduleParametersStruct.blackAlgorithm = blackAlgorithm;    
        moduleParametersStruct = rmfield(moduleParametersStruct, {'performExpLc1DblackFit','performExpSc1DblackFit','dynamic2DBlackEnabled'});
        inputsStruct.moduleParametersStruct = moduleParametersStruct;
    end
end

% add parameters with default values if not present in module parameters struct
if ~isfield(inputsStruct.moduleParametersStruct,'stdRatioThreshold')
    inputsStruct.moduleParametersStruct.stdRatioThreshold = 1.5;
end
if ~isfield(inputsStruct.moduleParametersStruct,'coefficentModelId')
    inputsStruct.moduleParametersStruct.coefficentModelId = 4;
end
if ~isfield(inputsStruct.moduleParametersStruct,'useRobustVerticalCoeffs')
    inputsStruct.moduleParametersStruct.useRobustVerticalCoeffs = true;
end
if ~isfield(inputsStruct.moduleParametersStruct,'useRobustFrameFgsCoeffs')
    inputsStruct.moduleParametersStruct.useRobustFrameFgsCoeffs = true;
end
if ~isfield(inputsStruct.moduleParametersStruct,'useRobustParallelFgsCoeffs')
    inputsStruct.moduleParametersStruct.useRobustParallelFgsCoeffs = true;
end
if ~isfield(inputsStruct.moduleParametersStruct,'blackResidualsThresholdDnPerRead')
    inputsStruct.moduleParametersStruct.blackResidualsThresholdDnPerRead = 10.0;
end

return;

