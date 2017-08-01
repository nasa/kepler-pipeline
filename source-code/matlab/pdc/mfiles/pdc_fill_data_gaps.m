function [timeSeriesWithGapsFilled, filledIndices, remainingGapIndicators, ...
    masterIndexOfAstroEvents, uncertaintiesWithGapsFilled] = ...
    pdc_fill_data_gaps(timeSeriesWithGaps, dataGapIndicators, indexOfAstroEvents, ...
    uncertaintiesWithGaps, gapFillParametersStruct, powerOfTwoLengthFlag, debugLevel)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [timeSeriesWithGapsFilled, filledIndices, remainingGapIndicators, ...
% masterIndexOfAstroEvents, uncertaintiesWithGapsFilled] = ...
% pdc_fill_data_gaps(timeSeriesWithGaps, dataGapIndicators, ...
% indexOfAstroEvents, uncertaintiesWithGaps, ...
% gapFillParametersStruct, powerOfTwoLengthFlag, debugLevel)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Fill short and then long gaps in time series. Return gap filled time
% series, indices of gap filled samples, indicators for remaining unfilled
% gaps plus uncertainties for data and gap filled values.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

% set uncertainty for long gap filled samples
uncertaintyForLongGapFilledSamples = -1;

% identify available samples
indexAvailable = find(~dataGapIndicators);

%--------------------------------------------------------------------------
% pathological case 1 - at most one valid sample is available; can't even
% use interp1 in this case
%--------------------------------------------------------------------------
if(length(indexAvailable) <= 1)
    warning('GapFill:pdc_fill_data_gaps',....
        'GapFill:pdc_fill_data_gaps:can''t fill gaps as at most one valid sample is available ...');
    timeSeriesWithGapsFilled = timeSeriesWithGaps;
    uncertaintiesWithGapsFilled = uncertaintiesWithGaps;
    filledIndices = [];
    remainingGapIndicators = dataGapIndicators;
    masterIndexOfAstroEvents = indexOfAstroEvents;
    return
end

%--------------------------------------------------------------------------
% pathological case 2 - just 3 or fewer samples are available; all gaps are
% filled by nearest neighbor interpolation
%--------------------------------------------------------------------------
if(length(indexAvailable) <= 3)
    warning('GapFill:pdc_fill_data_gaps',....
        'GapFill:pdc_fill_data_gaps:using interp1 to fill gaps as only  <= 3 samples are available  ...');

    nTimeSteps = (1:length(timeSeriesWithGaps))';
    timeSeriesWithGapsFilled = interp1(indexAvailable, ...
        timeSeriesWithGaps(indexAvailable), nTimeSteps, 'nearest', 'extrap');

    uncertaintiesWithGapsFilled = uncertaintiesWithGaps;
    uncertaintiesWithGapsFilled(dataGapIndicators) = ...
        uncertaintyForLongGapFilledSamples;
    filledIndices = find(dataGapIndicators);
    remainingGapIndicators = false(size(dataGapIndicators));
    masterIndexOfAstroEvents = indexOfAstroEvents;
    return
end

%--------------------------------------------------------------------------
% standard gaps case; all short gaps are filled by AR prediction, and all
% long gaps are filled iteratively
%--------------------------------------------------------------------------

% First fill in the short data gaps. The short data gap filling function
% will still return the master index of giant transits even if there are
% not actually any data gaps.
[timeSeriesWithShortGapsFilled, masterIndexOfAstroEvents, ...
    longDataGapIndicators, uncertaintiesWithShortGapsFilled] = ...
    fill_short_data_gaps(timeSeriesWithGaps, dataGapIndicators, indexOfAstroEvents, ...
    debugLevel, gapFillParametersStruct, uncertaintiesWithGaps);

% Now fill in the long data gaps.
if any(longDataGapIndicators)
    [timeSeriesWithGapsFilled, varianceAdjustedWaveletDetailCoefftsAtEachScale, ...
        uncertaintiesWithGapsFilled] = fill_long_data_gaps(timeSeriesWithShortGapsFilled, ...
        longDataGapIndicators, masterIndexOfAstroEvents, debugLevel, gapFillParametersStruct, ...
        powerOfTwoLengthFlag, uncertaintiesWithShortGapsFilled);
else
    timeSeriesWithGapsFilled = timeSeriesWithShortGapsFilled;
    uncertaintiesWithGapsFilled = uncertaintiesWithShortGapsFilled;
end

% Set the filled indices and remaining gap indicators.
filledIndices = find(dataGapIndicators);
remainingGapIndicators = false(size(dataGapIndicators));

% Return.
return
