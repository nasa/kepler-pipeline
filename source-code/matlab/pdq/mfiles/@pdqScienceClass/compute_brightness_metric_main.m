function [pdqTempStruct,pdqOutputStruct] = compute_brightness_metric_main(pdqScienceObject, pdqTempStruct, pdqOutputStruct,currentModOut)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [pdqTempStruct,pdqOutputStruct] =
% compute_brightness_metric_main(pdqScienceObject, pdqTempStruct,
% pdqOutputStruct,currentModOut)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function generates brightness metric (a weighted mean brightness of
% all targets in the current module output) and appends to the existing
% brightness metric time series.
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

pdqTempStruct = compute_pdq_brightness_metric(pdqTempStruct);

% Save results of time series generation in the outputs


% Retrieve the existing brightness metric structure if any (will be empty if it does
% not exist
meanFluxes    = pdqScienceObject.inputPdqTsData.pdqModuleOutputTsData(currentModOut).meanFluxes;

nCadences = length(pdqTempStruct.cadenceTimes);


if (isempty(meanFluxes.values))
    
    meanFluxes.values = pdqTempStruct.meanFluxes(:);
    meanFluxes.uncertainties = pdqTempStruct.meanFluxesUncertainties(:);
    
    meanFluxes.gapIndicators = false(nCadences,1);

    % set the gap indicators to true wherever the metric = -1;
    metricGapIndex = find(pdqTempStruct.meanFluxes(:) == -1);

    if(~isempty(metricGapIndex))
        meanFluxes.gapIndicators(metricGapIndex) = true;
    end

else
    
    meanFluxes.values = [meanFluxes.values(:); pdqTempStruct.meanFluxes(:)];
    meanFluxes.uncertainties = [meanFluxes.uncertainties(:); pdqTempStruct.meanFluxesUncertainties(:)];

    gapIndicators = false(nCadences,1);

    % set the gap indicators to true wherever the metric = -1;
    metricGapIndex = find(pdqTempStruct.meanFluxes(:) == -1);

    if(~isempty(metricGapIndex))
        gapIndicators(metricGapIndex) = true;
    end

    meanFluxes.gapIndicators = [meanFluxes.gapIndicators(:); gapIndicators(:)];

    % Sort time series using the time stamps as a guide
    [allTimes sortedTimeSeriesIndices] = ...
        sort([pdqScienceObject.inputPdqTsData.cadenceTimes(:); ...
        pdqScienceObject.cadenceTimes(:)]);

    meanFluxes.values = meanFluxes.values(sortedTimeSeriesIndices);
    meanFluxes.uncertainties = meanFluxes.uncertainties(sortedTimeSeriesIndices);
    meanFluxes.gapIndicators = meanFluxes.gapIndicators(sortedTimeSeriesIndices);

end
%--------------------------------------------------------------------------
% Save results in pdqOutputStruct
% This is a time series for tracking and trending
%--------------------------------------------------------------------------
pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(currentModOut).meanFluxes = meanFluxes;


return
