function [statistics, probabilities, fullStatistics, firstIndexAboveThreshold] = ...
    compute_cumulative_probability( bootstrapObject, bootstrapResultsStruct )

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [statistics, probabilities]  = compute_cumulative_probability( ...
%    bootstrapObject, bootstrapResultsStruct )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Decription: This function computes the cumulative sum of the mes histogram 
%
% Inputs:
%
% Outputs:
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

MIN_N_STATISTICS = 10;

statistics = bootstrapResultsStruct.statistics;
probabilities = bootstrapResultsStruct.probabilities;
searchTransitThreshold = bootstrapObject.searchTransitThreshold;
convolutionMethodEnabled = bootstrapObject.convolutionMethodEnabled;

if convolutionMethodEnabled
    firstIndexAboveThreshold = find(statistics >= searchTransitThreshold, 1, 'first');
    fullStatistics = statistics;
    probabilities = cumsum(probabilities);
    probabilities = probabilities ./ max(probabilities);
    probabilities = 1 - probabilities;
else

    % get the peak location
    [~,peakIndex] = max(probabilities);

    % if the peak is to the right of the threshold then it needs adjusted back
    if statistics(peakIndex) > searchTransitThreshold
        peakIndex = find(statistics < searchTransitThreshold, 1, 'last');
    end 

    % make sure we have at least 10 points above zero before lopping off the
    % negative portion of the histogram
    if ( (length(statistics) - peakIndex) < MIN_N_STATISTICS )
        fullStatistics = statistics;
    else
        probabilities = probabilities( peakIndex:end );
        fullStatistics = statistics( peakIndex:end );
    end

    % Get ccdf   
    probabilities = flipud(probabilities); 
    probabilities = cumsum(probabilities);    
    probabilities = flipud(probabilities);

    firstIndexAboveThreshold = find(fullStatistics >= searchTransitThreshold, 1, 'first');

    % must back up one index in the rare case when maxMultipleEventSigma is between 
    % the threshold and the first statistic above threshold
    firstIndexAboveThreshold = max(firstIndexAboveThreshold - 1, 1);

    % if there are no statistics above threshold, or too few above, then just extrapolate from
    % what is available;
    if isempty(firstIndexAboveThreshold) || ...
            ( (length(fullStatistics) - firstIndexAboveThreshold) < MIN_N_STATISTICS )
        firstIndexAboveThreshold = 1;
    end

    % truncate the non-interesting part
    probabilities = nonzeros(probabilities(firstIndexAboveThreshold:end));
    statistics = fullStatistics(firstIndexAboveThreshold:firstIndexAboveThreshold+length(probabilities)-1);
end

return