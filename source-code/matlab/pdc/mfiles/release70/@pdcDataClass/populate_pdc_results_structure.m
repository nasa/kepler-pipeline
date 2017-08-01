function [pdcResultsStruct] = ...
populate_pdc_results_structure(pdcDataObject, correctedFluxTimeSeries, ...
harmonicTimeSeries, outliers, discontinuityIndices, uncorrectedDiscontinuityTargetList, ...
initialVariableTargetList, variableTargetList, harmonicsFittedTargetList, ...
harmonicsRestoredTargetList, badCotrendTargetList, goodnessStruct, alerts)
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
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [pdcResultsStruct] = ...
% populate_pdc_results_structure(pdcDataObject, correctedFluxTimeSeries, ...
% harmonicTimeSeries, outliers, discontinuityIndices, uncorrectedDiscontinuityTargetList, ...
% initialVariableTargetList, variableTargetList, harmonicsFittedTargetList, ...
% harmonicsRestoredTargetList, badCotrendTargetList, alerts)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Populate the PDC results structure. First restore the harmonic content 
% and convert the outputs (gap, filled and outlier indices) to 0-base for
% Java.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


% Get fields from input object.
ccdModule = pdcDataObject.ccdModule;
ccdOutput = pdcDataObject.ccdOutput;
cadenceType = pdcDataObject.cadenceType;
startCadence = pdcDataObject.startCadence;
endCadence = pdcDataObject.endCadence;

targetDataStruct = pdcDataObject.targetDataStruct;

% Get the number of targets.
nTargets = length(targetDataStruct);

% Save the corrected flux time series and outliers with harmonics removed.
harmonicFreeCorrectedFluxTimeSeries = correctedFluxTimeSeries;
harmonicFreeOutliers = outliers;

% Restore the harmonics to the corrected flux time series and to the
% outlier values.
for iTarget = 1 : nTargets
    
    gapIndicators = correctedFluxTimeSeries(iTarget).gapIndicators;
    correctedFluxTimeSeries(iTarget).values(~gapIndicators) = ...
        correctedFluxTimeSeries(iTarget).values(~gapIndicators) + ...
        harmonicTimeSeries(iTarget).values(~gapIndicators);
    
    indices = outliers(iTarget).indices;
    outliers(iTarget).values = outliers(iTarget).values + ...
        harmonicTimeSeries(iTarget).values(indices);
    
end % for iTarget

% Convert PDC outputs to 0-base. Subtract one from filled, outlier and
% discontinuity indices.
filledIndicesCellArray = arrayfun(@(x) x.filledIndices - 1, ...
    correctedFluxTimeSeries, 'UniformOutput', false);
[correctedFluxTimeSeries(1:length(filledIndicesCellArray)).filledIndices] = ...
    filledIndicesCellArray{:};
[harmonicFreeCorrectedFluxTimeSeries(1:length(filledIndicesCellArray)).filledIndices] = ...
    filledIndicesCellArray{:};

outlierIndicesCellArray = arrayfun(@(x) x.indices - 1, ...
    outliers, 'UniformOutput', false);
[outliers(1:length(filledIndicesCellArray)).indices] = ...
    outlierIndicesCellArray{:};
[harmonicFreeOutliers(1:length(filledIndicesCellArray)).indices] = ...
    outlierIndicesCellArray{:};

discontinuityIndices = cellfun(@(x) x - 1, discontinuityIndices, ...
    'UniformOutput', false);

% Populate the output structure.
[targetResultsStruct(1 : nTargets).keplerId] = targetDataStruct(:).keplerId;

correctedFluxCellArray = num2cell(correctedFluxTimeSeries);
[targetResultsStruct(1 : nTargets).correctedFluxTimeSeries] = ...
    correctedFluxCellArray{:};

correctedFluxCellArray = num2cell(harmonicFreeCorrectedFluxTimeSeries);
[targetResultsStruct(1 : nTargets).harmonicFreeCorrectedFluxTimeSeries] = ...
    correctedFluxCellArray{:};

outliersCellArray = num2cell(outliers);
[targetResultsStruct(1 : nTargets).outliers] = ...
    outliersCellArray{:};

outliersCellArray = num2cell(harmonicFreeOutliers);
[targetResultsStruct(1 : nTargets).harmonicFreeOutliers] = ...
    outliersCellArray{:};

[targetResultsStruct(1 : nTargets).discontinuityIndices] = ...
    discontinuityIndices{:};

flags = false([1, nTargets]);
flags(initialVariableTargetList) = true;
flagsCellArray = num2cell(flags);
[dataProcessingStruct(1 : nTargets).initialVariable] = flagsCellArray{:};

flags = false([1, nTargets]);
flags(variableTargetList) = true;
flagsCellArray = num2cell(flags);
[dataProcessingStruct(1 : nTargets).finalVariable] = flagsCellArray{:};

flags = false([1, nTargets]);
flags(harmonicsFittedTargetList) = true;
flagsCellArray = num2cell(flags);
[dataProcessingStruct(1 : nTargets).harmonicsFitted] = flagsCellArray{:};

flags = false([1, nTargets]);
flags(harmonicsRestoredTargetList) = true;
flagsCellArray = num2cell(flags);
[dataProcessingStruct(1 : nTargets).harmonicsRestored] = flagsCellArray{:};

flags = false([1, nTargets]);
flags(badCotrendTargetList) = true;
flagsCellArray = num2cell(flags);
[dataProcessingStruct(1 : nTargets).uncorrectedSystematics] = ...
    flagsCellArray{:};

flags = false([1, nTargets]);
flags(uncorrectedDiscontinuityTargetList) = true;
flagsCellArray = num2cell(flags);
[dataProcessingStruct(1 : nTargets).uncorrectedSuspectedDiscontinuity] = ...
    flagsCellArray{:};

%dataProcessingCellArray = num2cell(dataProcessingStruct);
%[targetResultsStruct(1 : nTargets).dataProcessingStruct] = ...
%    dataProcessingCellArray{ : };

% Update output structure with new fields in 8.0
for i=1:nTargets
   %% dataProcessingStruct
   %targetResultsStruct(i).dataProcessingStruct.discontinuitiesRemoved = ~isempty(targetResultsStruct(i).discontinuityIndices);
   %% - the indices are only populated if a discontinuity has been removed, so this can be used to set the flag
   %targetResultsStruct(i).dataProcessingStruct.mapUsed = false;
   %targetResultsStruct(i).dataProcessingStruct.priorUsed = false;
    
   %% mapProcessingStruct
   %targetResultsStruct(i).mapProcessingStruct.targetVariability = 0;
   %targetResultsStruct(i).mapProcessingStruct.priorWeight = 0;

    % pdcProcessingStruct
    pdcOutputsStruct.targetResultsStruct(iTarget).pdcProcessingStruct.pdcMethod = 'leastSquares';
    pdcOutputsStruct.targetResultsStruct(iTarget).pdcProcessingStruct.numDiscontinuitiesDetected = length(targetResultsStruct(i).discontinuityIndices);
    if (dataProcessingStruct(iTarget).uncorrectedSuspectedDiscontinuity)
        pdcOutputsStruct.targetResultsStruct(iTarget).pdcProcessingStruct.numDiscontinuitiesRemoved = 0;
    else
        pdcOutputsStruct.targetResultsStruct(iTarget).pdcProcessingStruct.numDiscontinuitiesRemoved = length(targetResultsStruct(i).discontinuityIndices);
    end
    pdcOutputsStruct.targetResultsStruct(iTarget).pdcProcessingStruct.harmonicsFitted = dataProcessingStruct(iTarget).harmonicsFitted;
    pdcOutputsStruct.targetResultsStruct(iTarget).pdcProcessingStruct.harmonicsRestored = dataProcessingStruct(iTarget).harmonicsRestored;
    % Not applicable to least squares fitting
    pdcOutputsStruct.targetResultsStruct(iTarget).pdcProcessingStruct.targetVariability = NaN;

    % Band data not applicable to least squares fitting
    pdcOutputsStruct.targetResultsStruct(iTarget).pdcProcessingStruct.bands = ...
        repmat(struct('fitType', [], 'priorWeight', [], 'priorGoodness', []), [1,1]);
 

    % pdcGoodnessMetric
    targetResultsStruct(i).pdcGoodnessMetric.total.value                   = goodnessStruct(i).total.value;                
    targetResultsStruct(i).pdcGoodnessMetric.total.percentile              = goodnessStruct(i).total.percentile;           
    targetResultsStruct(i).pdcGoodnessMetric.correlation.value             = goodnessStruct(i).correlation.value;          
    targetResultsStruct(i).pdcGoodnessMetric.correlation.percentile        = goodnessStruct(i).correlation.percentile;    
    targetResultsStruct(i).pdcGoodnessMetric.deltaVariability.value        = goodnessStruct(i).deltaVariability.value;     
    targetResultsStruct(i).pdcGoodnessMetric.deltaVariability.percentile   = goodnessStruct(i).deltaVariability.percentile;
    targetResultsStruct(i).pdcGoodnessMetric.introducedNoise.value         = goodnessStruct(i).introducedNoise.value ;     
    targetResultsStruct(i).pdcGoodnessMetric.introducedNoise.percentile    = goodnessStruct(i).introducedNoise.percentile;
    targetResultsStruct(i).pdcGoodnessMetric.earthPointRemoval.value       = goodnessStruct(i).earthPointRemoval.value ;     
    targetResultsStruct(i).pdcGoodnessMetric.earthPointRemoval.percentile  = goodnessStruct(i).earthPointRemoval.percentile;
end

pdcResultsStruct.targetResultsStruct = targetResultsStruct;
pdcResultsStruct.ccdModule = ccdModule;
pdcResultsStruct.ccdOutput = ccdOutput;
pdcResultsStruct.cadenceType = cadenceType;
pdcResultsStruct.startCadence = startCadence;
pdcResultsStruct.endCadence = endCadence;
pdcResultsStruct.alerts = alerts;
pdcResultsStruct.pdcBlobFileName = '';

% Return.
return
