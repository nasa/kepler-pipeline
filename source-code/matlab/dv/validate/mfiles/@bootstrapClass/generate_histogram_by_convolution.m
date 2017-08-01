function bootstrapResultsStruct = generate_histogram_by_convolution(bootstrapObject, ...
    bootstrapResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [bootstrapResultsStruct, dvResultsStruct] = ...
%    generate_histogram_by_convolution(bootstrapObject, bootstrapResultsStruct, dvResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function generates the MES probability distribution by first
% computing the null correlation time series probability distribution by
% convolution.  Normalization time series sums are then computed for each
% phase and used to divide the correlation time series axis in order to
% convert it to a MES PDF.  These PDF's are then averaged over the phases.
%
%
%
%
%
%
%
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

% get needed inputs
observedTransitCount         = bootstrapObject.observedTransitCount;
cadenceDurationInMinutes     = bootstrapObject.cadenceDurationInMinutes;
correlationTimeSeries        = bootstrapObject.singleEventStatistics.correlationTimeSeries.values;
normalizationTimeSeries      = bootstrapObject.singleEventStatistics.normalizationTimeSeries.values;
deemphasisWeights            = bootstrapObject.singleEventStatistics.deemphasisWeights.values;
histogramBinWidth            = bootstrapObject.histogramBinWidth;
maxNumberBins                = bootstrapObject.bootstrapMaxNumberBins;
sesZeroCrossingWidthDays     = bootstrapObject.sesZeroCrossingWidthDays;
sesZeroCrossingDensityFactor = bootstrapObject.sesZeroCrossingDensityFactor;
nSesPeaksToRemove            = bootstrapObject.nSesPeaksToRemove;
sesPeakRemovalThreshold      = bootstrapObject.sesPeakRemovalThreshold;
sesPeakRemovalFloor          = bootstrapObject.sesPeakRemovalFloor;
bootstrapResolutionFactor    = bootstrapObject.bootstrapResolutionFactor;

cadencesPerDay = get_unit_conversion('day2min') / cadenceDurationInMinutes;

% set up single event statistics time series from components
sesTimeSeries = correlationTimeSeries ./ normalizationTimeSeries;
sesTimeSeries(deemphasisWeights==0) = 0;

% set up logical array to store valid points for bootstrap
validPointIndicator = deemphasisWeights ~= 0;

% filter the highest and lowest ses peaks so they dont perturb the result
validPointIndicator = filter_ses_peaks(sesTimeSeries, validPointIndicator, ...
    nSesPeaksToRemove, sesPeakRemovalThreshold, sesPeakRemovalFloor);

% count sign changes in zeroCrossingWidth days
nSignChanges = count_sign_changes(sesTimeSeries, sesZeroCrossingWidthDays, cadencesPerDay);

% make sure we dont throw out everything in the case where there are not
% any nSignChanges above the median
if any(nSignChanges > median( nSignChanges(deemphasisWeights>0) ) / sesZeroCrossingDensityFactor) && ...
        any(validPointIndicator)
    validPointIndicator = validPointIndicator & ...
        nSignChanges > median( nSignChanges(deemphasisWeights>0) ) / sesZeroCrossingDensityFactor;
else
    validPointIndicator = deemphasisWeights ~= 0;
end

% estimate the MES distribution if there are valid points
if any(validPointIndicator)
    
    % estimate the distribution
    [mesPdf,~,mesGridEdges] = estimate_mes_distribution_by_2d_convolution(correlationTimeSeries(validPointIndicator), ...
        normalizationTimeSeries(validPointIndicator), observedTransitCount, bootstrapResolutionFactor, ...
        histogramBinWidth, maxNumberBins);

    % polish empirical distributions
    mesPdf = mesPdf(:,end);
    mesPdf = max(mesPdf,0);
    mesPdf = mesPdf./sum(mesPdf);

    % record results
    bootstrapResultsStruct.probabilities = mesPdf(:);
    bootstrapResultsStruct.statistics = mesGridEdges(:);

    % update the bin width for plotting to units of MES
    bootstrapResultsStruct.histogramBinWidth = histogramBinWidth;

end

return

%==========================================================================
% count_sign_changes - count the number of sign changes per nDays
%==========================================================================

function nSignChanges = count_sign_changes(sesTimeSeries, nDays, cadencesPerDay)

sesTimeSeries = sesTimeSeries(:);
signSesTimeSeries = sign(sesTimeSeries);
signChanges = -signSesTimeSeries .* circshift(signSesTimeSeries, 1);

% ignore comparisons with gapped data - this indicates the places where the
% sign of the sesTimeSeries switched 
signChanges = signChanges > 0;

% compute the number of sign changes per nDays
halfNDays = round(cadencesPerDay * nDays / 2);
nSignChanges = filter( ones(round(nDays*cadencesPerDay)+1,1), 1, ...
    [signChanges;zeros(halfNDays,1)] );

% remove padding
nSignChanges(1:halfNDays) = [];

return

%==========================================================================
% filter_ses_peaks - suppress ses peaks that would perturb the bootstrap
%==========================================================================

function validPointIndicator = filter_ses_peaks(sesTimeSeries, validPointIndicator, ...
    nSesPeaksToRemove, sesPeakRemovalThreshold, sesPeakRemovalFloor)

% find top nSesPeaksToRemove ses and associated points and remove them
for count = 1:nSesPeaksToRemove
    [maxSes,imax] = max(sesTimeSeries .* validPointIndicator);
    
    if maxSes > sesPeakRemovalThreshold;
        
        iEnd = imax;
        while ( (sesTimeSeries(iEnd) >= sesPeakRemovalFloor || ...
                sesTimeSeries(iEnd+1) >= sesPeakRemovalFloor) && ...
                iEnd < length(sesTimeSeries)-1 )
            iEnd = iEnd+1;
        end
        
        iStart = imax;
        while ( (sesTimeSeries(iStart) >= sesPeakRemovalFloor ||...
                sesTimeSeries(iStart-1) >= sesPeakRemovalFloor) && iStart > 2 )
            iStart = iStart-1;
        end
        
        validPointIndicator(iStart:iEnd) = 0;
    end
end

% find most negative 3 ses and associated points and remove them
for count = 1:nSesPeaksToRemove
    [minSes,imin] = min(sesTimeSeries .* validPointIndicator);
    
    if minSes < -sesPeakRemovalThreshold
        
        iEnd = imin;
        while ( (sesTimeSeries(iEnd) <= -sesPeakRemovalFloor ||...
                sesTimeSeries(iEnd+1) <= -sesPeakRemovalFloor) && ...
                iEnd < length(sesTimeSeries)-1 )
            iEnd = iEnd+1;
        end
        
        iStart = imin;
        while ( (sesTimeSeries(iStart) <= -sesPeakRemovalFloor || ...
                sesTimeSeries(iStart-1) <= -sesPeakRemovalFloor) && iStart > 2 )
            iStart = iStart-1;
        end
        
        validPointIndicator(iStart:iEnd) = 0;
    end
end

return

