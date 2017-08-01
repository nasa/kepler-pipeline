function [pdqOutputStruct] = compute_plate_scale_metric_main(pdqScienceObject, pdqOutputStruct,nModOuts,modOutsProcessed,raDec2PixObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [pdqOutputStruct] = compute_plate_scale_metric_main(pdqScienceObject,
% pdqOutputStruct,nModOuts,raDec2PixObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% (astronomy) The ratio of the angular distance between two stars to the
% linear distance between their images on a photographic plate.
%  plateScales : time series of plate scales (1 for each module/output.
%
% Output:
%     Modifies ...
%         pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(:).plateScales 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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


attitudeSolution = pdqOutputStruct.attitudeSolution;
fprintf('PDQ:extracting centroid rows, columns from %d pdqTempStruct for plate scale metric...\n', nModOuts);

for currentModOut = 1 : nModOuts
    
    if(~modOutsProcessed(currentModOut))
        continue;
    end
    
    
    sFileName = ['pdqTempStruct_' num2str(currentModOut) '.mat'];
    
    % check to see the existence ofthe .mat file
    
    if(~exist(sFileName, 'file'))
        continue;
    end
    
    load(sFileName, 'pdqTempStruct');
    
    % Find the indices into all stellar targets (if any) on this module/output
    targetIndices       = pdqTempStruct.targetIndices;
    
    % Check data available flag and return if sufficient data are not available
    % Test for absence of stellar targets and return
    if (isempty(targetIndices))
        % set -1 the metrics and their uncertainties for current cadences and concatenate to input
        % metrics, uncertainties respectively
        
        continue;
    end
    
    
    pdqTempStruct = compute_plate_scale_metric(pdqTempStruct, attitudeSolution, currentModOut,raDec2PixObject);
    
    % Retrieve the existing platescale metric structure if any (will be empty if it does
    % not exist
    plateScales    = pdqScienceObject.inputPdqTsData.pdqModuleOutputTsData(currentModOut).plateScales;
    nCadences = length(pdqTempStruct.cadenceTimes);
    
    
    if (isempty(plateScales.values)) % If no metric history
        
        plateScales.values = pdqTempStruct.plateScaleResults(:);
        plateScales.uncertainties = pdqTempStruct.plateScaleUncertainties(:);
        plateScales.gapIndicators =  false(nCadences,1);
        % set the gap indicators to true wherever the metric = -1;
        metricGapIndex = find(pdqTempStruct.plateScaleResults(:) == -1);
        
        if(~isempty(metricGapIndex))
            plateScales.gapIndicators(metricGapIndex) = true;
        end
        
    else % Append to existing metric history
        
        plateScales.values = [plateScales.values(:); pdqTempStruct.plateScaleResults(:)];
        plateScales.uncertainties = [plateScales.uncertainties(:); pdqTempStruct.plateScaleUncertainties(:)];
        
        gapIndicators = false(nCadences,1);
        
        % set the gap indicators to true wherever the metric = -1;
        metricGapIndex = find(pdqTempStruct.plateScaleResults(:) == -1);
        
        if(~isempty(metricGapIndex))
            gapIndicators(metricGapIndex) = true;
        end
        
        plateScales.gapIndicators = [plateScales.gapIndicators(:); gapIndicators(:)];
        
        % Sort time series using the time stamps as a guide
        [allTimes sortedTimeSeriesIndices] = ...
            sort([pdqScienceObject.inputPdqTsData.cadenceTimes(:); ...
            pdqScienceObject.cadenceTimes(:)]);
        
        plateScales.values = plateScales.values(sortedTimeSeriesIndices);
        plateScales.uncertainties = plateScales.uncertainties(sortedTimeSeriesIndices);
        plateScales.gapIndicators = plateScales.gapIndicators(sortedTimeSeriesIndices);
        
    end
    %--------------------------------------------------------------------------
    % Save results in pdqOutputStruct
    % This is a time series for tracking and trending
    %--------------------------------------------------------------------------
    pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(currentModOut).plateScales = plateScales;
    
end

return




