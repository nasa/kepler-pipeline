function [skipCountArray numIterationsArray pulseOrder] = ...
    determine_skipcounts(bootstrapObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [skipCountArray numIterationsArray pulseOrder] = ...
%    determine_skipcounts(bootstrapObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Determine skipCount options when bootstrapAutoSkipCount is enabled: 
% 0 , default, or a third option.
%
% The number of iterations required for each skip count is also computed.
%
% PulseOrder is arranged so that histograms corresponging to the pulse that
% require most iterations are built first.
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

% extract necessary info from the bootstrapObject
bootstrapAutoSkipCountEnabled   = bootstrapObject.bootstrapAutoSkipCountEnabled;
defaultSkipCount                = bootstrapObject.bootstrapSkipCount;
observedTransitCount            = bootstrapObject.observedTransitCount;
searchTransitThreshold          = bootstrapObject.searchTransitThreshold;
histogramBinWidth               = bootstrapObject.histogramBinWidth;
binsBelowSearchTransitThreshold = bootstrapObject.binsBelowSearchTransitThreshold;
maxIterations                   = bootstrapObject.bootstrapMaxIterations;
nPulseWidths                    = bootstrapObject.numberPulseWidths;
lengthSES        = [bootstrapObject.degappedSingleEventStatistics.lengthSES]';
degappedSES      = [bootstrapObject.degappedSingleEventStatistics]';
lowerMarginSigma = histogramBinWidth*binsBelowSearchTransitThreshold;

meanEstimateTolerance = 0.005; % tolerance for MES distribution sampling

% randomize the normalization and correlation time series
for iPulse= 1:nPulseWidths
    index=randperm(lengthSES(iPulse));
    degappedSES(iPulse).degappedSortedCorrelationTimeSeries = ...
        degappedSES(iPulse).degappedSortedCorrelationTimeSeries(index);
    degappedSES(iPulse).degappedSortedNormalizationTimeSeries = ...
       degappedSES(iPulse).degappedSortedNormalizationTimeSeries(index);
end

numerator = vertcat(degappedSES.degappedSortedCorrelationTimeSeries);
denominator = vertcat(degappedSES.degappedSortedNormalizationTimeSeries);

% determine indices for start and end of each pulse
endIndices = cumsum(lengthSES);
startIndices = [1;endIndices(1:end-1)+1];

% convert inputs that need converting
startIndices = uint32(startIndices);
observedTransitCount = uint32(observedTransitCount);
lengthSES = uint32(lengthSES);

% estimate the iterations for each pulse based on sampling the MES distributions and
% estimating their mean and std. Do this multithreaded.
projectedNumIterations = estimate_iterations( searchTransitThreshold - lowerMarginSigma, ...
    observedTransitCount, lengthSES, numerator, denominator, startIndices, meanEstimateTolerance ) ;
    
% determine the skip counts to use to speed up the bootstrap
if bootstrapAutoSkipCountEnabled
    
    skipCountArray = zeros(nPulseWidths, 3);
    numIterationsArray = zeros(nPulseWidths, 3);

    for iPulse= 1:nPulseWidths
        
        skipCountArray(iPulse,1) = 0;
        numIterationsArray(iPulse,1) = projectedNumIterations(iPulse);

        skipCountArray(iPulse,2) = defaultSkipCount;
        numIterationsArray(iPulse,2) = ceil(projectedNumIterations(iPulse)/(skipCountArray(iPulse,2)+1));

        if numIterationsArray(iPulse,2) > maxIterations

            skipCountArray(iPulse,3) = ceil(lengthSES(iPulse)*.0025); % skipCount is 0.25% of lenghtSES
            numIterationsArray(iPulse,3) = ceil(projectedNumIterations(iPulse)/(skipCountArray(iPulse,3)+1));

            if numIterationsArray(iPulse,3) > maxIterations

                skipCountArray(iPulse,3) = ceil(projectedNumIterations(iPulse)/maxIterations);
                numIterationsArray(iPulse,3) = ceil(projectedNumIterations(iPulse)/(skipCountArray(iPulse,3)+1));

                if skipCountArray(iPulse,3) >= lengthSES(iPulse)*.1
                    skipCountArray(iPulse,3) = ceil(lengthSES(iPulse)*.1); % skipCount is 10% of lenghtSES
                    numIterationsArray(iPulse,3) = ceil(projectedNumIterations(iPulse)/(skipCountArray(iPulse,3)+1));
                end
            end

        else
            skipCountArray(iPulse,3) = ceil(mean([skipCountArray(iPulse,1),skipCountArray(iPulse,2)]));
            numIterationsArray(iPulse,3) = ceil(projectedNumIterations(iPulse)/(skipCountArray(iPulse,3)+1));
        end
        
    end
    
     % sort from highest to lowest iterations
    [pulseBase pulseOrder]= sort(projectedNumIterations, 'descend');
    skipCountArray = skipCountArray(pulseOrder,:);
    numIterationsArray = numIterationsArray(pulseOrder,:);

    % sort skipCountArray and numIterationsArray
    [skipCountArray sortKey] = sort(skipCountArray,2, 'ascend');
    for i=1:nPulseWidths
        numIterationsArray(i,:) = numIterationsArray(i,sortKey(i,:));
    end
    
else
    skipCountArray = defaultSkipCount * ones(nPulseWidths, 1);
    numIterationsArray = projectedNumIterations;
    [pulseBase pulseOrder]= sort(projectedNumIterations, 'descend');
    numIterationsArray = numIterationsArray(pulseOrder);
end


return