%************************************************************************** 
% paDataStruct = ...
%     modify_gap_indicators(paDataStruct, indicatorArray, operation)
%**************************************************************************
% Modifies gap indicators in the following fields of a paDataStruct:
%
%     paDataStruct.cadenceTimes.gapIndicators
%     paDataStruct.backgroundDataStruct.gapIndicators
%     paDataStruct.targetStarDataStruct.pixelDataStruct.gapIndicators
%
% INPUTS
%     paDataStruct   : A PA input data structure.
%     indicatorArray : An nCadences-length logical array that is combined
%                      logically with existing gap indicators. 
%     operation      : One of the following strings specifying the
%                      operation by which indicators are combined:
%                      'or'
%                      'and'
%                      'xor'
%                      'replace'
% OUTPUTS
%     paDataStruct  : A PA input data structure with modified gap
%                     indicators.
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
function paDataStruct = ...
    modify_gap_indicators(paDataStruct, indicatorArray, operation)

    EXTRACT_COLUMNS = 1;
    
    % Modify cadence time series.
    paDataStruct.cadenceTimes.gapIndicators = ...
        combine_logical_arrays( ...
            paDataStruct.cadenceTimes.gapIndicators, ...
            indicatorArray, operation);
    
    % Modify background pixel time series.
    if ~isempty( paDataStruct.backgroundDataStruct )
        
        nPixels = numel(paDataStruct.backgroundDataStruct);
        
        gapIndicatorMat = ...
            [paDataStruct.backgroundDataStruct(:).gapIndicators];
            
        gapIndicatorMat = combine_logical_arrays( gapIndicatorMat, ...
                repmat(colvec(indicatorArray), [1, nPixels]), operation);
            
        cellArray = num2cell(gapIndicatorMat, EXTRACT_COLUMNS);
        [paDataStruct.backgroundDataStruct(:).gapIndicators] = deal(cellArray{:});       
    end

    % Modify target pixel time series.
    if ~isempty( paDataStruct.targetStarDataStruct )
        targetStarDataStruct = paDataStruct.targetStarDataStruct;
        
        for iTarget = 1:numel(targetStarDataStruct)
            gapIndicatorMat = ...
                [targetStarDataStruct(iTarget).pixelDataStruct(:).gapIndicators];
            nPixels = numel(targetStarDataStruct(iTarget).pixelDataStruct);
            
            gapIndicatorMat = combine_logical_arrays( gapIndicatorMat, ...
                    repmat(colvec(indicatorArray), [1, nPixels]), operation);

            cellArray = num2cell(gapIndicatorMat, EXTRACT_COLUMNS);
            [targetStarDataStruct(iTarget).pixelDataStruct(:).gapIndicators] = ...
                deal(cellArray{:}); 
        end
        
        paDataStruct.targetStarDataStruct = targetStarDataStruct;
    end
end

%************************************************************************** 
function array1 = combine_logical_arrays(array1, array2, operation)
    switch operation
        case 'or'
            array1 = array1 | array2;
        case 'and'
            array1 = array1 & array2;
        case 'xor'
            array1 = xor(array1, array2);   
        case 'replace'
            array1 = array2;
        otherwise
            error('Invalid operationspecified: %s', operation);
    end
end

%********************************** EOF ***********************************