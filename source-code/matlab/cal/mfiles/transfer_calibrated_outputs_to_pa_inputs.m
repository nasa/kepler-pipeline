function transfer_calibrated_outputs_to_pa_inputs(nCalOutputs,nPaInputs)
%
% function transfer_calibrated_outputs_to_pa_inputs(nCalOutputs,nPaInputs)
%
% Update the pa-inputs-#.mat files with calibrated pixel outputs from cal
% in the cal-outputs-#.mat files. nCalOutputs = the largest # for the
% cal-outputs files. nPaInputs = the largest # for the pa-inputs files.
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


for iCal = 1:nCalOutputs
    
    disp(['Loading cal-outputs-',num2str(iCal),'.mat ...']);
    
    % load cal output file
    load(['cal-outputs-',num2str(iCal),'.mat']);
    
    % get location, value and gap indicators for calibrated targeta and background pixels
    outputRow    = [outputsStruct.targetAndBackgroundPixels.row];
    outputColumn = [outputsStruct.targetAndBackgroundPixels.column];
    outputValue  = [outputsStruct.targetAndBackgroundPixels.values];
    outputGap    = [outputsStruct.targetAndBackgroundPixels.gapIndicators];
    
    % build ordered pair pixel locator
    outputRowColumnPair = [outputRow',outputColumn'];
    
    for iPa = 0:nPaInputs
        
        disp(['Updating pa-inputs-',num2str(iPa)]);
        
        % load pa input file
        load(['pa-inputs-',num2str(iPa),'.mat']);
        
        % first invocation of PA has background pixels and no target pixels
        if(iPa == 0)
            T = inputsStruct.backgroundDataStruct;                       
        else
            T = [inputsStruct.targetStarDataStruct.pixelDataStruct];
            numTargets = length(inputsStruct.targetStarDataStruct);
        end
        
        inputRow    = [T.ccdRow];
        inputColumn = [T.ccdColumn];        
        inputValue  = [T.values];
        inputGap    = [T.gapIndicators];   
        
        inputRowColumnPair = [inputRow',inputColumn'];
        
        % find which PA input row/column pairs are in this invocation of CAL outputs        
        [outputRowLogical,inputRowIndex] = ismember(outputRowColumnPair,inputRowColumnPair,'rows');
        
        % copy the output from CAL to the input for PA
        inputValue(:,inputRowIndex(outputRowLogical)) = outputValue(:,outputRowLogical);
        inputGap(:,inputRowIndex(outputRowLogical))   = outputGap(:,outputRowLogical);
        
        % dmiesion cell array
        N = size(inputValue,1);
        M = ones(size(inputValue,2),1);
        
        % make cell arrays
        inputValueCell = mat2cell(inputValue,N,M);
        inputGapCell = mat2cell(inputGap,N,M);
        
        % deal into structure and save       
        [T.values] = inputValueCell{:};
        [T.gapIndicators] = inputGapCell{:};        
        
        if(iPa == 0)
            inputsStruct.backgroundDataStruct = T;
        else
            
            initialIndex = 1;
            
            for iTarget = 1:numTargets
                
                finalIndex = initialIndex + length(inputsStruct.targetStarDataStruct(iTarget).pixelDataStruct) - 1;
                
                inputsStruct.targetStarDataStruct(iTarget).pixelDataStruct = T(initialIndex:finalIndex);
                
                initialIndex = finalIndex + 1;
            end
        end
        
        save(['pa-inputs-',num2str(iPa),'.mat'],'inputsStruct');
        
    end
end