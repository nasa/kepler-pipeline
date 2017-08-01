function [pdqTempStruct, pdqOutputStruct] = compute_dynamic_range_metric_main(pdqScienceObject, pdqTempStruct, pdqOutputStruct, currentModOut)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%function [pdqTempStruct, pdqOutputStruct] =
%compute_dynamic_range_metric_main(pdqScienceObject, pdqTempStruct,
%pdqOutputStruct, currentModOut)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Generate dynamic range metric
%
% Only a limited number of reference pixels can be down linked via X-band,
% and the number will decrease as Kepler drifts away from Earth. Eventually
% we will not have sufficient number of pixels to adequately sample all 84
% module/outputs. Thhe goal is to use just a few reference pixels to see if
% the module/ouput is still functioning, by sampling pixles illuminated by
% a bright star (preferable saturated), and a background aperture.
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
pdqTempStruct = compute_dynamic_range_metric(pdqTempStruct);


% Retrieve the existing dynamic range metric structure if any (will be empty if it does
% not exist
dynamicRanges    = pdqScienceObject.inputPdqTsData.pdqModuleOutputTsData(currentModOut).dynamicRanges;

% no uncertainties are associated with dynamic range calculation
pdqTempStruct.dynamicRangesUncertainties = zeros(length(pdqTempStruct.dynamicRanges(:)), 1);

nCadences = length(pdqTempStruct.cadenceTimes);


if (isempty(dynamicRanges.values))

    dynamicRanges.values = pdqTempStruct.dynamicRanges(:);
    dynamicRanges.uncertainties = pdqTempStruct.dynamicRangesUncertainties(:);
    dynamicRanges.gapIndicators = false(nCadences,1);

    % set the gap indicators to true wherever the metric = -1;
    metricGapIndex = find(pdqTempStruct.dynamicRanges(:) == -1);

    if(~isempty(metricGapIndex))
        dynamicRanges.gapIndicators(metricGapIndex) = true;
    end

else

    dynamicRanges.values = [dynamicRanges.values(:); pdqTempStruct.dynamicRanges(:)];
    dynamicRanges.uncertainties = [dynamicRanges.uncertainties(:); pdqTempStruct.dynamicRangesUncertainties(:)];

    gapIndicators = false(nCadences,1);

    % set the gap indicators to true wherever the metric = -1;
    metricGapIndex = find(pdqTempStruct.dynamicRanges(:) == -1);

    if(~isempty(metricGapIndex))
        gapIndicators(metricGapIndex) = true;
    end

    dynamicRanges.gapIndicators = [dynamicRanges.gapIndicators(:); gapIndicators(:)];

    % Sort time series using the time stamps as a guide
    [allTimes sortedTimeSeriesIndices] = ...
        sort([pdqScienceObject.inputPdqTsData.cadenceTimes(:); ...
        pdqScienceObject.cadenceTimes(:)]);

    dynamicRanges.values = dynamicRanges.values(sortedTimeSeriesIndices);
    dynamicRanges.uncertainties = dynamicRanges.uncertainties(sortedTimeSeriesIndices);
    dynamicRanges.gapIndicators = dynamicRanges.gapIndicators(sortedTimeSeriesIndices);

end
%--------------------------------------------------------------------------
% Save results in pdqOutputStruct
% This is a time series for tracking and trending
%--------------------------------------------------------------------------
pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(currentModOut).dynamicRanges = dynamicRanges;



return
